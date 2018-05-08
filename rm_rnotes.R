###################################################################################################################################
#rm_Notes.R 
#programmer: Ruben
#Purpose: Simulation and analyses of ITP
#Started on January 17, 2018
##############################################

##DIRECTORIES:
###setwd("~/rm04_ITP/1-LowSES/data")
###getwd()
###dir()
###data()
###demo2011 <-read.xport('./nhanes20112012/DEMO_G.XPT') #no need to type long working dir
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

rr<-read.xlsx("./8-ACS/data/st99_2_025_025B.xlsx", sheetName="Table 1", startRow=149, endRow=198)
rr2 <- rename(rr, "FarmsHarvest2012"=NA., "AcresHarvest2012"=NA..1,	"QuantityHarvest2012"=NA..2, "FarmsIrrigated2012"=NA..3, "AcresIrrigated2012"=NA..4,	"FarmsHarvest2007"=NA..5,	"AcresHarvest2007"=NA..6,	"QuantityHarvest2007"=NA..7,	"FarmsIrrigated2007"=NA..8, "AcresIrrigated2007"=NA..9)
summary(rr2)
str(rr2) #data frame is like data sets in SAS

rr2[rr2=="-"] <- 0  #replace by 0
summary(rr2)

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

###sql:
#join data and analyze data:
data <- "select a.SEQN, a.riagendr, a.wtint2yr,
								b.SEQN, b.SMQ040,

										count(a.SEQN) as count_seqn,
                    round(avg(a.wtint2yr), 2) as mean_wt, 
                    sum(a.wtint2yr) as sum_wt,
                    max(a.wtint2yr) as max_wt, 
										round(avg(b.SMQ040), 2) as mean_smq040

                 from demo2015 as a
                 left join smq2015 as b
                 on a.SEQN = b.SEQN
group by a.RIAGENDR"
data2 <- sqldf(data)
demokeep <- c("RIAGENDR", "mean_wt", "sum_wt", "max_wt", "count_seqn", "mean_smq040")
nhanes11 <- data2[ , demokeep ]
nhanes11

###convert data to data frame and keep variables
library(SASxport)
rm_adbx<-read.xport("\\\\fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/MRTPA/PMPSA MR0000059+/Montes de Oca/04 REXC04JP/data/ADaM/adbx.xpt")
head(rm_adbx)
names(rm_adbx)
XDF<-as.data.frame((rm_adbx))  #make data as data frame
myvars<-names(XDF)[c(2,9,16,41,45,109)]
X <- XDF[myvars]


