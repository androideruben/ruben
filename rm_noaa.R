###########################################################################
#program: rm_noaa.R
#purpose: practice noaa data 

#programmer: ruben montes de oca
#starting date: september 2018
###########################################################################

setwd("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/")
#setwd("rm_EXPLORE/0-Misc/data/")
getwd()

#dev.copy(pdf,"//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/rm_noaaB.pdf")
sink("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/rm_noaaB.txt")


library(Hmisc)
library(psych)

#1. read data set ftp://ftp.ncdc.noaa.gov/pub/data/swdi/stormevents/csvfiles/legacy/
StormData <-  read.csv("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/stormdata_2013.csv", header=T, sep=",")
summary(StormData$BEGIN_DATE_TIME)
head(StormData$BEGIN_DATE_TIME)
nrow(StormData); ncol(StormData)
length(StormData)
str(StormData) #structure
names(StormData)
dim(StormData)

#2. work with dates:
summary(StormData$BEGIN_DATE_TIME)  #date time
my_date <- as.Date(StormData$BEGIN_DATE_TIME, format='%m/%d/%Y')
summary(my_date) #can now calculate min, max...
summary(StormData$MONTH_NAME)

#3. convert char  into numeric, add to data set and do plots:

##MONTH_NAME
StormData$monthN <- ifelse(StormData$MONTH_NAME=="January", 1, 
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

unique(StormData$monthN); unique(StormData$STATE); unique(StormData$FLOOD_CAUSE) 
keep=c("STATE", "MONTH_NAME", "monthN", "FLOOD_CAUSE")

test <- StormData[keep]

summary(subset(StormData, select=c(STATE, MONTH_NAME, monthN, FLOOD_CAUSE)))
Hmisc::describe(test)
psych::describe(test)
psych::describeBy(test, test$STATE)
psych::describeBy(test, test$STATE, mat=T)

library(summarytools)
dfSummary(test, style="grid", plain.ascii=T)

##FLOOD_CAUSE
StormData$floodN <- ifelse(StormData$FLOOD_CAUSE=="Heavy Rain",                       1, 
												ifelse(StormData$FLOOD_CAUSE=="Ice Jam",                      2,
												ifelse(StormData$FLOOD_CAUSE=="Heavy Rain / Snow Melt",       3,
												ifelse(StormData$FLOOD_CAUSE=="Dam / Levee Break",            4,
												ifelse(StormData$FLOOD_CAUSE=="Heavy Rain / Burn Area",       5,
												ifelse(StormData$FLOOD_CAUSE=="Planned Dam Release",          6,
												ifelse(StormData$FLOOD_CAUSE=="Heavy Rain / Tropical System", 7, 0)))))))

keep=c("FLOOD_CAUSE", "floodN")
test <- StormData[keep]
head(test)
Hmisc::describe(test)
psych::describeBy(test, test$FLOOD_CAUSE)
dfSummary(test, style="grid", plain.ascii=T)

#put data together:
keep=c("FLOOD_CAUSE", "floodN", "MONTH_NAME", "monthN", "STATE")
StormData <- StormData[keep]
dfSummary(StormData, style="grid", plain.ascii=T)

#some descriptives:
library(descr)
CrossTable(StormData$floodN, StormData$monthN, expected=F, prop.chisq=F)

hist(StormData$floodN,breaks=40,col="blue", xlab="floodN", xlim = c(-2, 8), 
					main="floodN", freq=F)
hist(StormData$monthN,breaks=40,col="red", xlab="floodN", xlim = c(-2, 11), 
					main="monthN", freq=F)

boxplot(StormData$monthN~StormData$floodN, xlab="xlab", ylab="ylab") 
boxplot(StormData$monthN~StormData$floodN, subset=StormData$floodN %in% c(1,2), xlab="xlab", ylab="ylab") 

#chi square
##https://www.rdocumentation.org/packages/stats/versions/3.5.1/topics/chisq.test
keep=c("floodN", "monthN")

StormData1 <- StormData[keep]
xsq <- chisq.test(StormData1)
xsq

xsq$observed   # observed counts (same as M)
xsq$expected   # expected counts under the null
xsq$residuals  # Pearson residuals
xsq$stdres     # standardized residuals

xsqdata <- data.frame(xsq$observed, xsq$expected)
head(xsqdata, 10)

rcorr(as.matrix(StormData1))
plot(StormData1[,1:2])

#dev.off()
sink()

##########################################################################################
# End of rm_noaa.R
##########################################################################################


curve(dchisq(x, df = 3), from = 0, to = 20, ylab = "y")
ind <- c(4, 5, 10, 15)
for (i in ind) curve(dchisq(x, df = i), 0, 20, add = TRUE)


##columns of exercising, scores of heavy, never, ocassional, regular smoking:
freq <- c(7, 87, 12, 9)
none <- c(1, 18, 3, 1) 
some <- c(3, 84, 4, 7)

data1 <- data.frame(freq, none, some)

# products of margins give expected: 
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

x2= sum( (a-7)^2/ a, (b-87)^2 / b, (c-12)^2/ c, (d-9)^2 /d, 
				 (e-1)^2 /e , (f-18)^2 /f , (g-3)^2 /g , (h-1)^2 /h ,
				 (i-3)^2 /i , (j-84)^2 /j , (k-4)^2 /k , (l-7)^2 /l )
x2

#All cumulative probability functions in R compute left tail probabilities by default
pchisq(x2, 6, lower.tail=F)
1-pchisq(x2, 6, lower.tail=T)
qchisq(0.95, 6)

xdata1 <- chisq.test(data1)
xdata1

curve(dchisq(x, df = 6), from = 0, to = 20, ylab = "y")


library(HH)
 old.omd <- par(omd=c(0.05, 0.88, 0.05, 1.00))
 chisq.setup(df=6)
 chisq.curve(df=6, col='blue')
 chisq.observed(5.48, df=6)
 par(old.omd)


