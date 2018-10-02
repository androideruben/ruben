###########################################################################
#program: rm_noaa.R
#purpose: practice noaa data 

#programmer: ruben montes de oca
#starting date: september 2018
###########################################################################

#setwd("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/")
#setwd("rm_EXPLORE/0-Misc/data/")
getwd()

library(Hmisc)
library(psych)
library(xlsx)
library(summarytools)
library(descr)

#1. read data set ftp://ftp.ncdc.noaa.gov/pub/data/swdi/stormevents/csvfiles/legacy/
##read document: http://www.nws.noaa.gov/directives/sym/pd01016005curr.pdf

StormData0 <- read.csv("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/stormdata_2013.csv", header=T, sep=",")

summary(StormData0)
head(StormData0)

nrow(StormData0); ncol(StormData0); length(StormData0)

str(StormData0) #structure
sort(names(StormData0)) #alphabetic order of columns

dim(StormData0)
summary(StormData0$DAMAGE_PROPERTY)
#complete.cases(StormData0$DAMAGE_PROPERTY)

#2 make a usable subset
##a. keep useful vars and obs (assume repeated events of rain are measures in different counties:
StormData <- subset(StormData0[c("MONTH_NAME", "STATE", "FLOOD_CAUSE")], 
																STATE %in% c("CALIFORNIA", "NEW YORK", "TEXAS") 
																& !(FLOOD_CAUSE %in% c("Dam / Levee Break", "Planned Dam Release", "") ))
View(StormData)
summary(StormData) #disconcerting, structure keeps all the states but prints vales for selected ones

#write.xlsx(StormData, file="StormData.xlsx", sheetName="one", append=FALSE)

#3. convert char vars to numeric and create categories:

##a. STATE
StormData$stateN <- ifelse(StormData$STATE==    "CALIFORNIA",   1, 
												ifelse(StormData$STATE=="NEW YORK",     2,
												ifelse(StormData$STATE=="TEXAS",        3, NA)))

#labels would make stateN a char, avoid that
StormData$stateNL <- factor(StormData$stateN, levels=c(1,2,3), 
															labels=c("California", "New York", "Texas"))	

##b. MONTH_NAME
unique(StormData$month) #only ten months

StormData$monthN <- ifelse(StormData$MONTH_NAME==    "January",   1, 
												ifelse(StormData$MONTH_NAME=="February",  2,
												ifelse(StormData$MONTH_NAME=="March",     3,
												ifelse(StormData$MONTH_NAME=="April",     4,
												ifelse(StormData$MONTH_NAME=="May",       5,
												ifelse(StormData$MONTH_NAME=="June",      6,
												ifelse(StormData$MONTH_NAME=="July",      7,
												ifelse(StormData$MONTH_NAME=="August",    8,
												ifelse(StormData$MONTH_NAME=="September", 9,
												ifelse(StormData$MONTH_NAME=="October",   10,
												ifelse(StormData$MONTH_NAME=="November",  11,
												ifelse(StormData$MONTH_NAME=="December",  12, 0))))))))))))

StormData$monthNL <- factor(StormData$monthN, levels=c(1,2,3,4,5,6,7,8,9,10), 
															labels=c("January", "February", "March", "April", "May", 
																			 "June", "July", "August", "September", "October"))	
##c. FLOOD_CAUSE
StormData$floodN1 <- ifelse(StormData$FLOOD_CAUSE=="Heavy Rain",                      1, 
												ifelse(StormData$FLOOD_CAUSE=="Ice Jam",                      2,
												ifelse(StormData$FLOOD_CAUSE=="Heavy Rain / Snow Melt",       3,
												ifelse(StormData$FLOOD_CAUSE=="Dam / Levee Break",            4,
												ifelse(StormData$FLOOD_CAUSE=="Heavy Rain / Burn Area",       5,
												ifelse(StormData$FLOOD_CAUSE=="Planned Dam Release",          6,
												ifelse(StormData$FLOOD_CAUSE=="Heavy Rain / Tropical System", 7, NA)))))))

StormData$floodN1L <- factor(StormData$floodN, levels=c(1,2,3,4,5,6,7), labels=c("Heavy Rain", "Ice Jam",                    
																																								"Heavy Rain / Snow Melt",     
																																								"Dam / Levee Break",          
																																								"Heavy Rain / Burn Area",     
																																								"Planned Dam Release",        
																																								"Heavy Rain / Tropical System"))	
#c (cont'd). better option: group floodN:
StormData$floodN2 <- ifelse(StormData$FLOOD_CAUSE %in% c("Heavy Rain",  
																												"Heavy Rain / Snow Melt", 
																												"Heavy Rain / Burn Area",
																												"Heavy Rain / Tropical System"),           1, 
	
														ifelse(StormData$FLOOD_CAUSE=="Ice Jam",                               2,
														ifelse(StormData$FLOOD_CAUSE %in% c("Dam / Levee Break",  
																																"Heavy Rain / Tropical System"),   NA, 
																																												           NA)))

StormData$floodN2L <- factor(StormData$floodN2, levels=c(1,2), labels=c("Rain related", "Ice"))	

View(StormData)

#4. Descriptives:
psych::describeBy(StormData, StormData$MONTH_NAME)
Hmisc::describe(StormData)
dfSummary(StormData, style="grid", plain.ascii=T)

CrossTable(StormData$monthN, StormData$stateN, expected=F, prop.chisq=F)
hist(StormData$monthN,breaks=40,col="blue", xlab="floodN", xlim = c(-2, 12), main="floodN2", freq=F)
boxplot(StormData$monthN~StormData$stateNL, xlab="xlab", ylab="ylab") 

#5. chi square test of independence
##(Ho: variables random and independent, small p-value rejects Ho)
##https://www.rdocumentation.org/packages/stats/versions/3.5.1/topics/chisq.test

keep=c("floodN1", "stateN")

StormData1 <- StormData[keep]
xsq <- chisq.test(StormData1) #expected very small, approximations of p may not be right
xsq
View(StormData1)

xsq$observed   # observed counts (same as M)
xsq$expected   # expected counts under the null
xsq$residuals  # Pearson residuals
xsq$stdres     # standardized residuals

xsqdata <- data.frame(xsq$observed, xsq$expected)
head(xsqdata, 10)

rcorr(as.matrix(StormData1))
plot(StormData1[,1:2])

#6. example chi square test of independence
#(Ho: variables random and independent, small p-value rejects Ho)

##columns of exercising, and 4 scores of smoking: heavy, never, ocassional, regular
freq <- c(7, 87, 12, 9) #7 are heavy smokers, 87 never, 12 ocassional, 9 regular
none <- c(1, 18, 3, 1) 
some <- c(3, 84, 4, 7)

###               Exercises No exercise Some Exercise |
###Heavy smoking  7           1             3         |  11
###No smoking    87          18            84         | 189
###Occasional    12           3             4         |  19
###Regular        9           1             7         |  17
###---------------------------------------------------------
###             115         23            98          | 236

data1 <- data.frame(freq, none, some)
names(data1) <- c("Exercises", "No exercise", "Some Exercise")
data1

xdata1 <- chisq.test(data1)
xdata1 #X-squared = 5.4885, df = 6, p-value = 0.4828 (exercise is not associated to smoking.)

##By hand:  products of margins give expected: 
a=11*115/236
b=189*115/236
c=19*115/236
d=17*115/236

e=11*23/236
f=189*23/236
g=19*23/236
h=17*23/236

i=11*98/236
j=189*98/236
k=19*98/236
l=17*98/236

a; b; c; d; e; f; g; h; i; j; k; l;

x2= sum( (a-7)^2/ a, (b-87)^2 / b, (c-12)^2/ c, (d-9)^2 /d, 
				 (e-1)^2 /e , (f-18)^2 /f , (g-3)^2 /g , (h-1)^2 /h ,
				 (i-3)^2 /i , (j-84)^2 /j , (k-4)^2 /k , (l-7)^2 /l )
x2

#All cumulative probability functions in R compute left tail probabilities by default
pchisq(0x2, 6, lower.tail=F) #density
1-pchisq(x2, 6, lower.tail=T)
qchisq(0.95, 6) #quantile

#plots
x <- c(5.360169, 92.09746, 9.258475, 8.283898, 1.072034, 18.41949, 1.851695, 1.65678, 4.567797, 78.48305, 7.889831, 7.059322)

hist(x, freq=F, main='main', breaks=seq(-10,100, by=10), ylim=c(0,0.1))	
curve( dchisq(x, df=6),   col='red',   add=T, xlim= c(-10, 100))
curve( dchisq(x, df=10), col='green', add=T, xlim= c(-10, 100))


##########################################################################################
# End of rm_noaa.R
##########################################################################################
