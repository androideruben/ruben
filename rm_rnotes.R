setwd("//1-LowSES/data")
getwd()

###LOG:
# save your command history (put at the end of program):
savehistory(file="rm_notesLOG.Rhistory") # default is ".Rhistory"

# recall your command history:
loadhistory(file="rm_notesLOG.Rhistory") # default is ".Rhistory" which is a txt file, the log


###DATA MANAGEMENT:
library(foreign)
data() #list internal data sets
summary(iris) #iris is an internal data set

#save data to my folder:
write.table(iris, "//1-LowSES/data/iris.csv", sep="\t")

#read the saved data:
rr<-read.table("//1-LowSES/data/iris.csv")
summary(rr)

#save data used in this program to my folder:
save.image("rm_lowses.RData")

#next time, load data in this way...
load("rm_lowses.RData")

#or load the data in this way:
rr<-read.table("//1-LowSES/data/iris.csv")

resultsmy<- summary(rr)
resultsmy

###OUTPUT goes my folder
rm_summary<-summary(iris)
sink("rm_summary.txt", append=FALSE, split=FALSE); 
rm_summary
sink()

sink("//1-LowSES/data/rm_summary.txt", append=FALSE, split=FALSE); 
rm_summary
sink()

##stargazer LateX creates txt or html
###https://www.jakeruss.com/cheatsheets/stargazer/:


stargazer(iris[1:3,], type="text", title="test", summary=FALSE, rownames=FALSE,
	out="//1-LowSES/data/models.txt")

stargazer(iris[1:3,], type="html", title="test", summary=FALSE, rownames=FALSE,
	out="//1-LowSES/data/models.html")

stargazer(iris, type="text", title="test", summary=FALSE, rownames=TRUE,
	out="//1-LowSES/data/models.txt")

stargazer(iris, type="text", title="test", summary=F, rownames=TRUE, 
	out="//1-LowSES/data/models.txt")

library(ggplot2)
df= data.frame(matrix(rnorm(400), nrow=100)); dfplot=ggplot(df, aes(x=X1, X2)) + geom_point()
pdf("\\\\fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm04_ITP/1-LowSES/data/test.pdf", height=11, width=8.5)
dfplot
dev.off()


###https://thusithamabotuwana.wordpress.com/2016/01/02/creating-pdf-documents-with-rrstudio/
library(grid)
library(gridExtra)


pdf("//1-LowSES/data/test.pdf", height=11, width=8.5)
grid.table(rm_summary)
dev.off()


