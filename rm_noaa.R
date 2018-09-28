###########################################################################
#program: rm_noaa.R
#purpose: practice noaa data 

#programmer: ruben montes de oca
#starting date: september 2018
###########################################################################

#setwd("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/")
setwd("rm_EXPLORE/0-Misc/data/")
getwd()

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
chisq <- chisq.test(StormData$monthN~StormData$floodN)
chisq
chisq.test(StormData1, simulate.p.value = TRUE)






#Time series
data(airpass, package="faraway")
str(airpass)

plot (pass~year, data=airpass, type="l", ylab="Passengers") #l is lines
?plot

plot(sin, -pi, 2*pi) 
x <- seq(0,8*pi,length.out=100)
x
y <- sin(x)
plot(x,y,type="l")

#If y is a function of x, you can use curve if you like: 
curve(sin, to = 2*pi) 
#curve(x, to = 2*pi) 

#create new data using a function RxR->R
col <- function(x,y) {airpass[,x]+y}
col(1, 100)
col(2, 2)

airpass2 <- data.frame(col(1,100), col(2,1))
names(airpass2) <- c("pass", "year")
str(airpass2)











rcorr(as.matrix(StormData))
plot(fitness[,1:4])

#https://www.r-bloggers.com/correlation-and-linear-regression/
m1<-lm(weight~age, data=fitness)
summary(m1)
plot(m1)

par(mfrow=c(2,2))
plot(m1)


#transform data
fitness$Lweight<-log(fitness$weight)
plot(Lweight~age,fitness)
plot(weight~age,fitness)
hist(fitness$weight)
hist(fitness$Lweight)

#add normal curve:
Lweight <- fitness$Lweight
h<-hist(Lweight, breaks=10, col="red", xlab="xlab", main="main")
xfit<-seq(min(Lweight),max(Lweight),length=40)
yfit<-dnorm(xfit,mean=mean(Lweight),sd=sd(Lweight))
yfit <- yfit*diff(h$mids[1:2])*length(Lweight)
lines(xfit, yfit, col="blue", lwd=2)

weight <- fitness$weight
h<-hist(weight, breaks=10, col="red", xlab="xlab", main="main")
xfit<-seq(min(weight),max(weight),length=40)
yfit<-dnorm(xfit,mean=mean(weight),sd=sd(weight))
yfit <- yfit*diff(h$mids[1:2])*length(weight)
lines(xfit, yfit, col="blue", lwd=2)






library(aplpack)
stem.leaf(precip, depth=F)
summary(precip)
s <- sort(precip)
s

#quartiles 1.statistics wiki p29
p29 <- c(1,3,5,8,9,12,24,25,28,30,41,50)
p29

#The function "summary" is based on a definition of quantiles that is biased 
#to equate the min to the 0%-quantile and max to the 100%-quantile. "The 
#algorithm linearly interpolates between order statistics of x, assuming 
#that the ith order statistic is the (i-1)/(length(x)-1) quantile:"

summary(p29)
quantile(p29, c(0.25, 0.5, 0.75), type=1)
quantile(p29, c(0.25, 0.5, 0.75), type=2)
quantile(p29, c(0.25, 0.5, 0.75), type=3)
?quantile

fivenum(p29)








library(arsenal)
compare(csvACS, sasACS, allowAll=T)
summary(compare(csvACS, sasACS, allowAll=T))


keep <- c("SERIALNO",  "DIVISION", "PUMA",  "REGION", "ST", "ADJUST", "WGTP")
#sas <- sasACS[keep]
csv <- csvACS[keep]

summary(sas)
summary(csv)



##########################################################################################
# End of rm_noaa.R
##########################################################################################

