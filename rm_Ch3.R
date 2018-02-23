##############################################################################################
#rm_Ch2.R 
#programmer: Ruben Montes de Oca, CTP
#Purpose: Review of regression
#Started on February 1, 2018
##############################################################################################

##############################################################################################
setwd("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/Linear Regression Assignment/Dataset")
getwd()
rm(list=ls())

##############################################################################################
library(stargazer)
library(readxl)
dat3<-read_excel("dat3.xlsx", sheet = "Sheet1")

##Use bmi as Y
summary(dat3)

dat3$exposureN <- NA
dat3$exposureN[dat3$exposure=='exposed'] <- 1
dat3$exposureN[dat3$exposure=='unexposed'] <- 0
dat3

dat3$sexN <- NA
dat3$sexN[dat3$sex=='male'] <- 1
dat3$sexN[dat3$sex=='female'] <- 0
dat3
drop<-names(dat3) %in% c("X__1", "sex", "exposure")
dat3<-dat3[!drop]
summary(dat3)

###I want to use numeric vars:
str(dat3)

##################################################################################
#PART A1: Matrix regression for dat3.xlsx to be compared to Part A2:
##################################################################################

###create X, Y matrices for this specific regression, cbind adds a column of ones
X <- as.matrix(cbind(1,dat3$glucose, dat3$diastolic, dat3$triceps, dat3$insulin, 
dat3$diabetes, dat3$age, dat3$exposureN, dat3$sexN))

####print first five obs:
head(X, n=5)

####print first six obs:
Y<-as.matrix(dat3$bmi)
head(Y, n=6)

###beta-hat = ((X'X)^(-1))X'y, solve() takes the inverse of a matrix.
det(t(X) %*% X) #not- zero, then invertible

bh = solve( t(X) %*% X ) %*% t(X) %*% Y
bh

###Yhat, print first 7 obs:
Yh= X %*% bh
head(Yh, n=7)

###residuals are: e=Y-Yh, print first eight obs:
res=Y-Yh
head(res, n=8)

###n=number of observations and k=number of parameters 
n = nrow(dat3); k = ncol(X)
n
k

###Variance-Covariance Matrix Var(bh|X)=ehat' ehat (X' X)^-1
varcov = (1/(n-k)) * as.numeric( t(res)%*%res ) * solve(t(X)%*%X)
varcov

###standard errors of the estimated coefficients
stderr = sqrt(diag(varcov))
stderr

###t-test
tbeta0=bh[1]/ stderr[1]
tbeta1=bh[2]/ stderr[2]
tbeta2=bh[3]/ stderr[3]
tbeta3=bh[4]/ stderr[4]
tbeta4=bh[5]/ stderr[5]
tbeta5=bh[6]/ stderr[6]
tbeta6=bh[7]/ stderr[7]
tbeta7=bh[8]/ stderr[8]
tbeta8=bh[9]/ stderr[9]

tbeta=rbind(tbeta0, tbeta1, tbeta2, tbeta3, tbeta4, tbeta5, tbeta6, tbeta7, tbeta8)
tbeta

###p-values for the t-test
pvalues = rbind(
	2*pt(abs(bh[1]/stderr[1]), df=n-k,lower.tail= FALSE), 
	2*pt(abs(bh[2]/stderr[2]), df=n-k,lower.tail= FALSE),
	2*pt(abs(bh[3]/stderr[3]), df=n-k,lower.tail= FALSE), 
	2*pt(abs(bh[4]/stderr[4]), df=n-k,lower.tail= FALSE), 
	2*pt(abs(bh[5]/stderr[5]), df=n-k,lower.tail= FALSE), 
	2*pt(abs(bh[6]/stderr[6]), df=n-k,lower.tail= FALSE), 
	2*pt(abs(bh[7]/stderr[7]), df=n-k,lower.tail= FALSE), 
	2*pt(abs(bh[8]/stderr[8]), df=n-k,lower.tail= FALSE), 
	2*pt(abs(bh[9]/stderr[9]), df=n-k,lower.tail= FALSE)
	)
pvalues

###goodness of fit: 
J = matrix(1, nrow=n, ncol=n)

####Sum of Squares for total, error, and model 
SSTO = t(Y) %*% Y - (1/n)*t(Y)%*%J%*%Y
SSTO

SSM = t(bh)%*%t(X)%*%Y - (1/n)%*%t(Y)%*%J%*%Y
SSM

SSE= SSTO- SSM
SSE

####mean squares Model, and error
SSMM=SSM/(k-1) ##df
SSMM

SSEM=SSE/(n-k) ##df
SSEM

####F Value
F=SSMM/SSEM
F

####Pr>F
Fp=1-pf(F, 1, 98)
Fp

##R-square
R2=1- (SSE/SSTO)
R2

####adjusted R-square
RA2=1-( (SSE/(n-k) ) / ( SSTO/(n-1) ) )
RA2

####dependent mean is the same as the mean of Y
Dmean=mean(Y)
Dmean

####coefficient of variation
CV <- function(rootSSEM, Dmean){
      (rootSSEM/Dmean)*100
}
CV(sqrt(SSEM), Dmean)

##################################################################################
#PART A2: Compare results from A to this part that uses lm (compare to Part A1.)
##################################################################################

summary(lm(bmi ~ glucose+ diastolic+ triceps+ insulin+ diabetes+ age+ 
					exposureN+ sexN, data=dat3))

##################################################################################
#PART C: Book exercises
##################################################################################


##################################################################################
####3.2 For each of the following matrices, indicate whether there will be a 
####unique solution to the normal quations. Show how you arrived at your answer.

####A. ######################################

col1=c(1, 1, 1, 1)
col2=c(2, 3, 0, -1)
col3=c(4, 8, 6, 2)

X <- as.matrix(data.frame(col1, col2, col3))
X

#####transpose of X:
t(X)
	
det(t(X) %*% X)
solve( t(X) %*% X ) %*% t(X) 

####B. ######################################
col1=c(1,1,1,1)
col2=c(1,1,0,0)
col3=c(0,0,0,1)

X <- as.matrix(data.frame(col1, col2, col3))
X

#####transpose of X:
t(X)
	
det(t(X) %*% X)
solve( t(X) %*% X ) %*% t(X) 

####C. ######################################
col1=c(1,1,1,1)
col2=c(2,1,-3,-1)
col3=c(4,2,-6,-2)

X <- as.matrix(data.frame(col1, col2, col3))
X

#####transpose of X:
t(X)
	
det(t(X) %*% X)
####solve( t(X) %*% X ) %*% t(X)  will not work because matrix is singular: 

##################################################################################
###3.4. A data set with one independent variable and an intercept gave the 
####following (X' X)^1:

col1 = c(31/177, -3/177)
col2=c(-3/177, 6/177)

####xtx_1=(X'X)^-1:
xtx_1 <- as.matrix(data.frame(col1, col2))
xtx_1

####How many observations were there in the data set? Find sum(Xi)^2i.

det(xtx_1)
solve( xtx_1)

###Then, since row1(X')=[1 1... 1] and row2(X')=[X1 x2... Xn]:
#X'X is the 2x2 matrix:

# n        sum(Xi) 
# sum(Xi)  sum(Xi^2) 

#and n=6, sum(Xi^2)=31

##################################################################################
#End of rm_Ch3.R##################################################################
##################################################################################





