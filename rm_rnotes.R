###################################################################################################################################
#rm_LowSES.R 
#programmer: Ruben
#Purpose: Simulation and analyses of ITP
#Started on January 17, 2018
##############################################

##DIRECTORIES:
###setwd("~/rm04_ITP/1-LowSES/data")
###getwd()
###dir()
###data()
##############################################

##LOG:
###save your LOG (put at the end of the program):
####savehistory(file="~/rm04_ITP/1-LowSES/code/results/rm_LowSESLOG.Rhistory") # default is ".Rhistory"

###recall your command history:
####loadhistory(file="rm_notesLOG.Rhistory") # default is ".Rhistory" which is a txt file, the log

##############################################

##OUTPUT:
####sink("~/rm04_ITP/1-LowSES/code/results/rm_summary.txt", append=FALSE, split=FALSE); 
####rm_summary
####sink()

###STARGAZER CREATES txt OF html (LateX):
####stargazer(iris[1:3,], type="text", title="test", summary=FALSE, rownames=FALSE,
####	out="~/rm04_ITP/1-LowSES/code/results/models.txt")
####
####stargazer(iris[1:3,], type="html", title="test", summary=FALSE, rownames=FALSE,
####	out="~/rm04_ITP/1-LowSES/code/results/models.html")
####
####stargazer(iris, type="html", title="test", summary=FALSE, rownames=TRUE,
####	out="~/rm04_ITP/1-LowSES/code/results/models.html")
####
####stargazer(iris, type="text", title="test", summary=F, rownames=TRUE, 
####	out="~/rm04_ITP/1-LowSES/code/results/models.txt")

###PDF OUTPUT:
####df= data.frame(matrix(rnorm(400), nrow=100)); dfplot=ggplot(df, aes(x=X1, X2)) + geom_point()
####pdf("~/rm04_ITP/1-LowSES/code/results/test.pdf", 
####height=11, width=8.5)
####dfplot
####dev.off()
####open output (file.show does not work):
####file.edit("~/rm04_ITP/1-LowSES/code/results/model3.lmer.txt")

##############################################

###SUMMARY, PRINT, QUALITY:
####iris[1:3,]
####head(iris, 10)
####tail(iris, 10)
####rr=summary(iris)

####To simplify reference execute attach(rr) so that ratpup can be accessed sex rather than ratpup$sex):
####attach(rr); summary(Lcotinine)
##############################################

###LIBRARIES:
####library(stargazer) #Nice outputs, https://www.jakeruss.com/cheatsheets/stargazer/, https://www.princeton.edu/~otorres/NiceOutputR.pdf
####library(grid)			 #plots
####library(gridExtra) #plots #https://thusithamabotuwana.wordpress.com/2016/01/02/creating-pdf-documents-with-rrstudio/
####library(ggplot2)   #plots
####library(lme4)      #linear algebra
####library(foreign)   #read data
####################################################################################################################################

###DATA MANAGEMENT:

data() #list internal data sets
summary(iris) #iris is an internal data set

#save data to my folder:
write.table(iris, "~/rm04_ITP/1-LowSES/data/iris.csv", sep="\t")

#READ THE SAVED DATA:
rr<-read.csv("~/rm04_ITP/1-LowSES/data/iris.csv")
summary(rr)

#save data used in this program to my folder:
save.image("rm_lowses.RData")

#next time, load data in this way...
load("rm_lowses.RData")

#or load the data in this way:
rr<-read.table("~/rm04_ITP/1-LowSES/data/iris.csv")

resultsmy<- summary(rr)
resultsmy




