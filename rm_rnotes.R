setwd("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm04_ITP/1-LowSES/data")
getwd()

###Data management:
library(foreign)
data() #list internal data sets
summary(iris) #iris is an internal data set

#save data to my folder:
write.table(iris, "\\\\fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm04_ITP/1-LowSES/data/iris.csv", sep="\t")

#read the saved data:
rr<-read.table("\\\\fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm04_ITP/1-LowSES/data/iris.csv")
summary(rr)

#save data used in this program to my folder:
save.image("rm_lowses.RData")

#next time, load data in this way...
load("rm_lowses.RData")

#or load the data in this way:
rr<-read.table("\\\\fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm04_ITP/1-LowSES/data/iris.csv")
