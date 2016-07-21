###1. set working directory, loading survey and data:
setwd("/users/montesdeocar/rm/RM100096/DATA/ACS/")
getwd()

library(survey)
acs1 <- read.csv("acs_fake1.csv", as.is=TRUE)

###2. convert sex and age group to factors 
acs1$SEX <- factor(acs1$SEX, labels = c("M","F")) 
acs1$agegrp <- cut(acs1$AGEP, c(0,5,10,15,20,25,35,45,55,60,65,75,85,100), right = FALSE) 

###3. create replicate-weight survey object 
options( "survey.replicates.mse" = TRUE ) 

acs1.rep <- svrepdesign(repweights = acs1[200:279], weights = ~PWGTP, combined.weights = TRUE, type = "JK1", scale = 4/80, 
                            rscales = rep(1, 80), data = acs1) 


###4. using type "JK1" with scale = 4/80= 0.05 and rscales = rep(1,80) 


####OUTPUT goes to the file acs2013 results.txt
sink("/users/montesdeocar/rm/RM100096/LST AND LOG/acs1 results.txt", append=FALSE, split=FALSE)


##A. Check:
#table(acs1$SEX)
#summary(acs1)

##B. total population by sex with SE's 
by.sex <- svyby(~SEX, ~ST, acs1.rep, svytotal, na.rm = TRUE) 
by.sex
#round((by.sex[1,4:5]) 
      
#     se1  se2 
# 33 1606 1606 
# compare results with Census 
#pums_est[966:967, 5] 
#[1] 1610 1610 

##C. total population by age group with SE's 
by.agegrp <- svyby(~agegrp, ~ST, acs1.rep, svytotal, na.rm = TRUE) 
round((by.agegrp)[15:27]) 

#       se1  se2  se3  se4  se5  se6  se7  se8  se9 se10 se11 se12 se13 
#    33 874 2571 2613 1463 1398 1475 1492 1552 2191 2200  880 1700 1678 
# compare results with Census 
#pums_est[968:980, 5] 
#  [1]  874 2578 2613 1463 1399 1476 1493 1555 2191 2200  880 1702 1684 


####Close OUTPUT goes to the file acs2013 results.txt
sink()



###This part is testing:

ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
group <- gl(2,10,20, labels=c("Ctl","Trt"))
weight <- c(ctl, trt)
lm.D9 <- lm(weight ~ group) 


fun1<-function(x){
  res<-c(paste(as.character(summary(x)$call),collapse=" "),
         x$coefficients[1],
         x$coefficients[2],
         length(x$model),
         summary(x)$coefficients[2,2],
         summary(x)$r.squared,
         summary(x)$adj.r.squared,
         summary(x)$fstatistic,
         pf(summary(x)$fstatistic[1],summary(x)$fstatistic[2],summary(x)$fstatistic[3],lower.tail=FALSE))
  names(res)<-c("call","intercept","slope","n","slope.SE","r.squared","Adj. r.squared",
                "F-statistic","numdf","dendf","p.value")
  return(res)} 
res2<-fun1(lm.D9)

write.csv(res2,"/users/montesdeocar/rm/RM100096/LST AND LOG/newregsummary.csv") 

sink("/users/montesdeocar/rm/RM100096/LST AND LOG/newregsummary.csv")
res2
sink()

sink("/users/montesdeocar/rm/RM100096/LST AND LOG/newregsummary.txt", append=FALSE, split=FALSE)
res2
sink()
  file.show("/users/montesdeocar/rm/RM100096/LST AND LOG/newregsummary.txt")




