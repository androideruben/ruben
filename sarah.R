##########################################################################################
# NLongitudinal plots	
# Program: \\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\
# rm04_NHANES\code\NHANES 2009-2010.R
# Programmer: Ruben Montes de Oca FDA- CTP
# Purpose: Analyze the 2009-2010 NHANES demographics and questionnaire components				
##########################################################################################

setwd("H:/Ruben.MontesdeOca/Documents")
getwd()

##https://tutorials.iq.harvard.edu/R/Rgraphics/Rgraphics.html

library(Hmisc)
mydata <- sasxport.get("H:/Ruben.MontesdeOca/Documents/sarah.xpt")
summary(mydata)
head(mydata,10)

ggplot(data=mydata, mapping=aes(x = visit, y = y)) + geom_point()

ggplot(data=mydata, mapping=aes(x = visit, y = y, group=visit)) + geom_boxplot()

ggplot(data=mydata, aes(x = visit), binwidth=1) +   geom_histogram()

mydata2 <- subset(mydata, id='GCB 001') 
ggplot(data=mydata2, mapping=aes(x = visit, y = y, group=visit)) + geom_boxplot()
summary(mydata2)
