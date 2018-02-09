###################################################################################################################################
#rm_chapter1.R 
#programmer: Ruben Montes de Oca, CTP
#Purpose: Review of regression
#Started on February 1, 2018
##############################################

###############################################
setwd("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/Linear Regression Assignment/Dataset")
library(readxl)
dat1<-read_excel("dat1.xlsx", sheet = "Sheet1")
#attach(dat1); summary(dat1); 
sapply(dat1,is.numeric)

###Create a new numeric variable exp_n with values 0, 1 using values in the char variable exp UNEXP, EXP:
dat1$exp_n <- NA
dat1$exp_n[dat1$exp=='EXP'] <- 1
dat1$exp_n[dat1$exp=='UNEXP'] <- 0
dat1

#######################
##1. Calculations by hand using summary of X, Y from Table 1:
###beta1 formula (4) or (1.7) from book and SAS output above, Table 1
beta1= (72.7883687 - (45.00* 151.9104163/100))/ (45.00- (45.00*45.00/100))
beta1

###beta0 formuula (5) of (1.7) from book
beta0=151.9104163/100- beta1*0.4500
beta0

###formula (8) or (1.13) from book
ssres=53.139 #SAS output yresid

###formula (10) or (1.16) from book
ssreg=beta1^2* 24.750 #SAS output exp_n_Mean_exp_n2
ssreg

###formula (11) or (1.17) from book
sstotal=ssreg+ssres
sstotal

###s^2=ssres/(n-2):
s=sqrt((53.139)/(100-2))
s

### Formula (15) or (1.26) from book
sebeta1=s / ((24.750) )^0.5
sebeta1

###Formula 15 or (1.32)
sebeta0= s*( (1/100) + 0.45^2 / (24.750) )^0.5
sebeta0	

###Formula 14 or (1.36) from book
t1=beta1-0/ sebeta1
t1

###Formula 14 or (1.36) from book
t0=beta0-0/ sebeta0
t0	
	
###Formula 10 or page 18 from book
msreg=ssreg/1; msres=ssres/(100-2)
F=msreg/msres
F

### Formula (13) or (1.18) from the book
rsq=ssreg/sstotal
rsq


###2. Using lm:
summary(lm(out ~ exp_n, data = dat1))

###3. Calculate regression manually using matrix algebra in R

## Create X and Y matrices for this specific regression, cbind adds a column of ones
X <- as.matrix(cbind(1,dat1$exp_n))
Y<-as.matrix(dat1$out)

###beta-hat = ((X'X)^(-1))X'y, solve() takes the inverse of a matrix.
det(t(X) %*% X) #not- zero, then invertible

bh = solve( t(X) %*% X ) %*% t(X) %*% Y
bh

##residuals
res = as.matrix(dat1$out-bh[1]-bh[2]*dat1$exp_n)
res

##n=number of observations and k=number of parameters 
n = nrow(dat1); k = ncol(X)
n
k

##Variance-Covariance Matrix
varcov = 1/(n-k) * as.numeric( t(res)%*%res ) * solve(t(X)%*%X)
varcov

## Standard errors of the estimated coefficients
stderr = sqrt(diag(varcov))
stderr

##t-test
tbeta0=bh[1]/ stderr[1]
tbeta0

tbeta1=bh[2]/ stderr[2]
tbeta1

##p-values for a t-test
pvalues = rbind(2*pt(abs(bh[1]/stderr[1]), df=n-k,lower.tail= FALSE), 2*pt(abs(bh[2]/stderr[2]), df=n-k,lower.tail= FALSE))
pvalues

##Goodness of fit: 
#### Total sum of Square corrected 
J = matrix(1, nrow=n, ncol=n)
SSTO = t(Y) %*% Y - (1/n)*t(Y)%*%J%*%Y
SSTO

#Model, Total and Error sum of squares 
SSM = t(bh)%*%t(X)%*%Y - (1/n)%*%t(Y)%*%J%*%Y
SSM

SSE= SSTO- SSM
SSE

##Model, Error Mean squares
SSMM=SSM/1 ##df
SSM

SSEM=SSE/(n-k) ##df
SSEM

F=SSMM/SSEM
F

Fp=1-pf(F, 1, 98)
Fp

##R-square
R2=1- (SSE/SSTO)
R2

##Adjusted R-square
RA2=1-( (SSE/(n-k) ) / ( SSTO/(n-1) ) )
RA2

##Dependent mean is the same as the mean of Y
Dmean=mean(Y)
Dmean

CV <- function(rootSSEM, Dmean){
      (rootSSEM/Dmean)*100
}
CV(sqrt(SSEM), Dmean)


#End of rm_Ch1.R#############################################



