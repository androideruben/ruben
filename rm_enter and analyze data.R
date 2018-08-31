###########################################################################
#program: rm_EXPLORE/0-MISC/code/rm_enter and analyze.R
#purpose: practice data 

#programmer: ruben montes de oca
#starting date: july 2018
###########################################################################

setwd("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/")
getwd()

library(Hmisc)
library(psych)

###1. we will enter data and do basic statistics and output to pdf, jpg:

##http://support.sas.com/documentation/cdl/en/procstat/66703/HTML/default/viewer.htm#procstat_univariate_examples01.htm

#create a data frame from scratch: columns will be variables and rows will be subjects
#data frame is similar to data in SAS or Excel and can combine text and numeric values:

#COMBINE objects into a vector: 
#https://www.statmethods.net/input/datatypes.html

patientID <- c('CK','CP','CP','FC','DS','JW','GS','HH','SS','BL','JI','RW','JW','SB','AB','FR','ES','MC','KD','BH','NS','EC')	
Systolic <- c(120,120,165,125,110,134,122,122,96, 140,110,133,130,118,122,100,120,119,108,120,122,112)
Diastolic <- c(50,75,11,76,50,80,70,82,60,90,40,60,80,76,78,70,70,66,54,65,78,62)
BPressure <- data.frame(patientID, Systolic, Diastolic)
	
summary(BPressure)
describe(BPressure)	

pdf("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-MISC/code/results/SystolicDiastolic.pdf")
plot(Systolic, Diastolic)
abline(lm(Systolic~Diastolic))
title("Systolic vs. Diastolic and Regression of Systolic on Diastolic")
dev.off()

#or
dev.copy(png,"//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-MISC/code/results/SystolicDiastolic.png")
plot(Systolic, Diastolic)
abline(lm(Systolic~Diastolic))
dev.off()

dev.copy(pdf,"//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-MISC/code/results/SystolicDiastolic.pdf")
plot(Systolic, Diastolic)
abline(lm(Systolic~Diastolic))
dev.off()

#data fitness:
age <- c(44,44,38,40,44,44,45,54,51,48,57,52,51,51,49,52,40,42,47,43,38,45,47,49,51,49,54,50,54,57,48)
weight <- c(89.47,85.84,89.02,75.98,81.42,73.03,66.45,83.12,69.63,91.63,73.37,76.32,67.25,73.71,76.32,82.78,75.07,
68.15,77.45,81.19,81.87,87.66,79.15,81.42,77.91,73.37,79.38,70.87,91.63,59.08,61.24)
oxygen <- c(44.609,54.297,49.874,45.681,39.442,50.541,44.754,51.855,40.836,46.774,39.407,45.441,45.118,45.790,NA,
47.467,45.313,59.571,44.811,49.091,60.055,37.388,47.273,49.156,46.672,NA,46.080,54.625,39.203,50.545,47.920)
time <- c(11.37,  8.65,NA, 11.95, 13.08, 10.13, 11.12, 10.33, 10.95, 10.25, 12.63,  9.63, 11.08, 10.47,NA, 10.50,10.07,
 8.17,11.63,10.85, 8.63,14.03,10.60, 8.95,10.00,10.08,11.17, 8.92,12.88, 9.93,11.50)
fitness <- data.frame(age, weight, oxygen, time)
describe(fitness)
cor(age,weight)
cor(fitness, use="complete.obs", method="pearson")
cor(fitness, use="complete.obs", method="spearman")

cor(fitness, use="complete.obs")

library(Hmisc)
rcorr(as.matrix(fitness))
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

###2. import, export data:

#http://www.sthda.com/english/wiki/r-xlsx-package-a-quick-start-guide-to-manipulate-excel-files-in-r

write.csv(mtcars, "mtcars.csv")
mycars <-  read.csv("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/mtcars.csv", header=T, sep=",")

library(xlsx)
write.xlsx(mtcars, "//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/mtcars.xlsx")

library(readxl)
mycarsxlsx <- read_excel("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/mtcars.xlsx", 
	col_names=T, sheet="Sheet1", range="A1:B15")
mycarsxlsx

mycarsxlsx2 <- read_excel("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/mtcars.xlsx", 
	col_names=T, sheet="Sheet1", range="A1:c15")
mycarsxlsx2

mycarsxlsx3 <- read_excel("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/mtcars.xlsx", 
	col_names=T, sheet="Sheet1", range="A1:d15")
mycarsxlsx3

library(xlsx)

# Write the first data set in a new workbook multiple.xlsx
write.xlsx(mycarsxlsx, file="multiple.xlsx", sheetName="one", append=FALSE)
# Add a second data set in a new worksheet
write.xlsx(mycarsxlsx2, file="multiple.xlsx", sheetName="two", append=TRUE)
# Add a third data set
write.xlsx(mycarsxlsx3, file="multiple.xlsx", sheetName="three", append=TRUE)

###3. read large data set:
StormData <-  read.csv("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/0-Misc/data/repdata_data_StormData.csv", header=T, sep=",")

summary(StormData)
head(StormData)
nrow(StormData); ncol(StormData)
length(StormData)
str(StormData) #structure
ls()

summary(StormData$STATE__)   #num
summary(StormData$BGN_DATE)  #Factor
summary(StormData$COUNTY)    #num
summary(StormData$COUNTYENDN) #logi
summary(StormData$F)          #int

#work with dates:
#https://www.stat.berkeley.edu/~s133/dates.html

summary(StormData$BGN_DATE)  #date time
bgn_date <- as.Date(StormData$BGN_DATE, format='%m/%d/%Y')
mean(bgn_date)
max(bgn_date)
min(bgn_date)
summary(bgn_date) #can now calculate min, max...

#add bgn_date as a new column:
StormData$bgn_date <- bgn_date
str(StormData) #added!


#box plots:
#https://www.statmethods.net/graphs/boxplot.html

boxplot(bgn_date~StormData$STATE__) #whaaat?

boxplot(StormData$bgn_date) #better
boxplot(bgn_date~STATE, data=StormData, subset=STATE %in% c('AK', "AZ"), main="bgn_date~STATE", xlab="States", ylab="Dates") #whaaat?

#keep vars
keep= c("STATE", "bgn_date")
rr <- StormData[keep]
head(rr)

# convert STATE to a factor
rr$STATE <- as.factor(rr$STATE)
rr <- rr[rr$STATE %in% c('AK', "AZ"),]
rr$STATE <- droplevels(rr$STATE)
summary(rr)
boxplot(bgn_date~STATE, data=rr,  main="bgn_date~STATE rr data", xlab="States", ylab="Dates") #whaaat?

##########################################################################################
# End of rm_EXPLORE/0-MISC/code/rm_enter and analyze.R
##########################################################################################







