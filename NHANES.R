##########################################################################################
# NHANES 2009-2010 demographics and questionnaire files	
# Program: \\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\
# rm04_NHANES\code\NHANES 2009-2010.R
# Programmer: Ruben Montes de Oca FDA- CTP
# Purpose: Analyze the 2009-2010 NHANES demographics and questionnaire components				
##########################################################################################

setwd("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/rm_EXPLORE/3-NHANES/data/")
getwd()

#foreign(converts data files into R), survey(analyzes complex design surveys)
#reporting(nicer outputs) , downloader(not used: CDC's ftp not found)
library(foreign) 
library(survey)  
library(stargazer) 
library(downloader) 
library(sqldf) #sql
library(plyr)
library(dplyr)
library(gmodels)
library(ggplot2)
#Loading required package: gsubfn
#Loading required package: proto
#Loading required package: RSQLite
#plyr

# set the number of digits in all output
options(digits=7)

# set R to produce conservative standard errors instead of crashing
# http://r-survey.r-forge.r-project.org/survey/exmample-lonely.html
# this setting matches the MISSUNIT option in SUDAAN
# See also 
#https://www.cdc.gov/nchs/tutorials/NHANES/downloads/Continuous/Descriptive_Mean%20R%20Output.txt

options(survey.lonely.psu = "adjust")

###############################################
# 0. Create permanent data:										#
###############################################

#DEMOGRAPHICS AND WEIGHTS:
demo2005 <-read.xport('./nhanes20052006/DEMO_D.XPT')
demo2007 <-read.xport('./nhanes20072008/DEMO_E.XPT')
demo2009 <-read.xport('./nhanes20092010/DEMO_F.XPT')
demo2011 <-read.xport('./nhanes20112012/DEMO_G.XPT')
demo2013 <-read.xport('./nhanes20132014/DEMO_H.XPT')
demo2015 <-read.xport('./nhanes20152016/DEMO_I.XPT')

#Smoking - Cigarette Use:
smq2005 <-read.xport('./nhanes20052006/SMQ_D.XPT')
smq2007 <-read.xport('./nhanes20072008/SMQ_E.XPT')
smq2009 <-read.xport('./nhanes20092010/SMQ_F.XPT')
smq2011 <-read.xport('./nhanes20112012/SMQ_G.XPT')
smq2013 <-read.xport('./nhanes20132014/SMQ_H.XPT')
smq2015 <-read.xport('./nhanes20152016/SMQ_I.XPT')
head(smq2015)

#join data and derive variables:
data <-  function(dataA, dataB) {
							sqldf("select a.SEQN, a.riagendr, a.ridageyr, a.ridreth1, a.wtint2yr, a.SDMVPSU, a.SDMVSTRA,
													b.SEQN, b.smq040, 1 as one, 0 as zero,

									case smq040 
										when 1 then '1. Smoke daily'
                    when 2 then '2. Smoke some days'
										when 3 then '3. Dont smoke'
 										else 'missing'
									end as smq040cat,

									case smq040 
										when smq040 in (1,2) then 1
										when 3 then 2
 										else NULL
									end as smq040cat2

                 from dataA as a
                 left join dataB as b
                 on a.SEQN = b.SEQN")
}

nhanes05 <- data(demo2005, smq2005)
nhanes07 <- data(demo2007, smq2007)
nhanes09 <- data(demo2009, smq2009)
nhanes11 <- data(demo2011, smq2011)
nhanes13 <- data(demo2013, smq2013)
nhanes15 <- data(demo2015, smq2015)

#add a column year:
nhanes05$year=2005
nhanes07$year=2007
nhanes09$year=2009
nhanes11$year=2011
nhanes13$year=2013
nhanes15$year=2015

#concatenate as a long data set:
nhanesL <- rbind(nhanes05, nhanes07, nhanes09, nhanes11, nhanes13, nhanes15)
summary(nhanesL)

#naming categories:
race <- function(data) { 
					factor(data$RIDRETH1, levels=c(1,2,3,4,5,.), 
					labels=c("1. Mexican American","2. Hispanic", 
						"3. White", "4. Black", "5. Other", "."))
}

sex <- function(data) { 
					factor(data$RIAGENDR, levels=c(1,2,.), 
					labels=c("1. Male", "2. Female", "."))
}

nhanesL$RIDRETH1 <-  race(nhanesL)
nhanesL$RIAGENDR <-  sex(nhanesL)

age.summary <- function(data){ summary(data$RIDAGEYR)}
age.summary(nhanesL)

#Check missing (long output):
#is.na(nhanesL)

#total missing and percent:
sum(is.na(nhanesL$smq040cat2))
mean(is.na(nhanesL$smq040cat2))

#Save as permanent data as 
#\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\
#Montes de Oca\rm_EXPLORE\3-NHANES\data\nhanesL.rda: 
save(nhanesL, file="nhanesL.rda")

#load the rda file
#load(file="nhanesL.rda")

###############################################
# end of 0. Create permanent data:
###############################################

#################################################
# check data #
#################################################

head(nhanesL)
summary(nhanesL)
keep= c("RIDAGEYR", "year")

rr <- nhanesL[keep]
head(rr)

rrsumm <- ddply(rr, c("year"), summarise, age=mean(RIDAGEYR), sd=sd(RIDAGEYR))

#unweighted plots:
ggplot(data=rrsumm, aes(x=year, y=age)) + geom_line()

#################################################
# end of check data #
#################################################

#################################################
# survey design for taylor-series linearization #
#################################################

# create survey design object with NHANES design information 
##using the final data frame NHANES data
nhanesL.svydesign <- 
	svydesign(
		id = ~SDMVPSU,          #cluster ids  
		strata = ~SDMVSTRA,
		nest = TRUE ,
		weights = ~WTINT2YR ,
		data = nhanesL
	)


nhanes15.svydesign <- 
							svydesign(
								id = ~SDMVPSU,          #cluster ids  
								strata = ~SDMVSTRA,
								nest = TRUE,
								weights = ~WTINT2YR,
								data = nhanes15
	)

nhanes05.svydesign <- 
	svydesign(
		id = ~SDMVPSU,          #cluster ids  
		strata = ~SDMVSTRA ,
		nest = TRUE ,
		weights = ~WTINT2YR ,
		data = nhanes05
	)

#all.equal(nhanes15.svydesign, nhanes05.svydesign) # using all.equal


# notice the 'nhanes15.svydesign' object used in all subsequent analysis commands
#http://r-survey.r-forge.r-project.org/survey/html/svydesign.html

#survey design objects
class(nhanesL)
class(nhanesL.svydesign)

#####################
# analysis examples #
#####################

#count the total(unweighted) number of records in nhanes #
nrow(nhanesL.svydesign)

#count the total(unweighted) number of records in nhanes broken out by category
#unwtd.count is designed to be passed to svyby to report the number of non-missing observation
svyby(~RIDAGEYR, ~smq040cat2, nhanesL.svydesign, unwtd.count)

#count the weighted number of individuals in nhanes
svytotal(~one, nhanesL.svydesign)

	#also in this way
	sum(nhanesL$WTINT2YR)

#by smq040cat2 category
svyby(~one, ~smq040cat2, nhanesL.svydesign, svytotal)

#calculate means
svymean(~RIDAGEYR, design=nhanesL.svydesign)

#by smq040cat2 category
svyby(~RIDAGEYR, ~smq040cat2, design=nhanesL.svydesign, svymean)

svyby(~RIDAGEYR, ~smq040cat2, design=nhanesL.svydesign, svymean, ci=TRUE,vartype="ci")

svyby(~RIDAGEYR, ~smq040cat2, design=nhanesL.svydesign, svyquantile, quantiles=0.5, ci=TRUE,vartype="ci")

#smq040cat2 should be treated as a factor(categorical) variable
nhanesL.svydesign <-update(smq040cat2=factor(smq040cat2), nhanes15.svydesign)

#calculate the median and other percentiles
# force r to output a confidence interval
# by setting this parameter to true
# if confidence intervals are not desired,
# use keep.var = FALSE in its place
svyquantile(~RIDAGEYR, design=nhanesL.svydesign, c(0 , 0.25 , 0.5 , 0.75 , 1), ci = TRUE)

######################
# subsetting example #
######################

# restrict the nhanes15.svydesign object to females only
nhanesL.svydesign.female <-subset(nhanesL.svydesign, RIAGENDR %in% 2)

# now any of the above commands can be re-run using the nhanes15.svydesign.female object
#instead of the nhanes15.svydesign object

# average age - nationwide, restricted to females
svymean(~RIDAGEYR, design=nhanesL.svydesign.female, na.rm=T)

###################
# export examples #
###################

# calculate the distribution of a categorical variable #
# by poverty category

# store the results into a new object
coverage.by.RIAGENDR <-
												svyby(
													~RIAGENDR , 
													~smq040cat2 ,
													design = nhanesL.svydesign ,
													svymean  ,
													na.rm = T 
												)

# print the results to the screen 
coverage.by.RIAGENDR

#proc freq; tables _all_;
library(psych)
psych::describe(nhanesL[,sapply(nhanesL, class) %in% c("numeric", "integer") ])

#export to working directory
stargazer(coverage.by.RIAGENDR, type="text", title= "coverage by sex", digits=1, out="covBp.txt")
stargazer(coverage.by.RIAGENDR, type="html", title= "coverage by sex", digits=1, out="covBp.htm")
write.csv(coverage.by.RIAGENDR , "coverage by sex.csv")

# now you have the results saved into a new object of type "svyby"
class(coverage.by.RIAGENDR)

# print only the statistics(coefficients) to the screen 
coef(coverage.by.RIAGENDR)

# print only the standard errors to the screen 
SE(coverage.by.RIAGENDR)

# this object can be coerced(converted) to a data frame.. 
coverage.by.RIAGENDR <- data.frame(coverage.by.RIAGENDR)

# ..and then immediately exported as a comma-separated value file 
# into your current working directory 
write.csv(coverage.by.RIAGENDR , "coverage by sex")

# ..or directly made into a bar plot
counts <- table(coverage.by.RIAGENDR$RIAGENDR)
barplot(counts, main="Sex Distribution",
   xlab="Sex") 

# 2-Way Frequency Table
attach(nhanesL)
mytable <- table(SMQ040,RIAGENDR) # A will be rows, B will be columns
mytable # print table 
margin.table(mytable, 1) # A frequencies (summed over B)
margin.table(mytable, 2) # B frequencies (summed over A)

round(prop.table(mytable),2) # cell percentages
round(prop.table(mytable, 1),2) # row percentages
round(prop.table(mytable, 2),2) # column percentages

table(nhanesL$SMQ040, useNA="ifany")
summary(nhanesL$SEQN)
glimpse(nhanesL)
CrossTable(nhanesL$RIAGENDR,nhanesL$SMQ040, digits=2, prop.c=F, prop.t=F, 
	prop.chisq=F, chisq=T, dnn=c("RIAGENDR", "SMQ040"))

##########################################################################################
# End of //fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/
#Montes de Oca/rm_EXPLORE/3-NHANES/dat/code/NHANES 2009-2010.R
##########################################################################################









