##############################################################################################
#rm_Ch4.R 
#programmer: Ruben Montes de Oca, CTP
#Purpose: Review of regression
#Started on February 1, 2018

##############################################################################################

##############################################################################################
setwd("//fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/Linear Regression Assignment/Dataset")
getwd()
rm(list=ls())

##list of my packages:
ip = as.data.frame(installed.packages()[,c(1,3:4)])
ip = ip[is.na(ip$Priority),1:2,drop=FALSE]
ip

##############################################################################################

##############################################################################################
####4.1. A dependent variable Y (20 × 1) was regressed onto 3 independent variables plus an 
#intercept (so that X was of dimension 20×4). The following matrices were computed.

##X'X:
tX_X= matrix( 
c(20,0,0,0, 0,250,401,0, 0,401,1013,0, 0,0,0,128), # the data elements 
nrow=4,              # number of rows 
ncol=4,              # number of columns 
byrow = TRUE)        # fill matrix by rows 
 
tX_X       

##X'Y:
tX_Y=matrix(c(1900.00,970.45,1674.41,-396.80), nrow=4, ncol=1, byrow=TRUE)
tX_Y

##Y'Y:
tY_Y=matrix(c(185.883), nrow=1, ncol=1, byrow=TRUE)
tY_Y

#(a) Compute beta^ and write the regression equation.
###we know that beta^ = ((X'X)^(-1)) X'Y, solve() takes the inverse of a matrix.
det(tX_X) #non-zero, then invertible

bh = solve( tX_X ) %*% tX_Y
bh

#(b) Compute the analysis of variance of Y. Partition the sum of squares due to the 
#model into a part due to the mean and a part due to regression on the Xs after 
#adjustment for the mean. Summarize the results, including degrees of freedom and mean
#squares, in an analysis of variance table.

###Sum of Squares Total uncorrected is: Y' Y= YtY:
SSTO=tY_Y 
SSTO

###Sum of Squares Model is: beta^t Xt Y:
SSM=t(bh) %*% tX_Y 
SSM

###Sum of Squares Residual is: SSTO- SSModel:
SSE=SSTO- SSM
SSE

SSE<- tY_Y - t(bh) %*% tX_Y
SSE



#(c) Compute the estimate of sigma^2 and the standard error for each regression coefficient. 
#Compute the covariance between beta1^ and beta2^, Cov(beta1^, beta2^). 
#Compute the covariance between beta1^ and beta3^, Cov(beta1^, beta3^).


#(d) Drop X3 from the model. Reconstruct X' X and X' Y for this model without X3 and 
#repeat Questions (a) and (b). Put X3 back in the model but drop X2 and repeat (a) and (b).
#(i) Which of the two independent variables X2 or X3 made the greater contribution to Y 
#in the presence of the remaining X; that is, compare R(beta2| beat0, beta1, beta3) 
#and R(beta3|beta0, beta1, beta2).
#(ii) Explain why beta1^ changed in value when X2 was dropped but not when X3 was dropped.
#(iii) Explain the differences in meaning of beta1 in the three models.


#(e) From inspection of X'X how can you tell that X1, X2, and X3 were expressed as 
#deviations from their respective means? Would (X'X)^−1 have been easier or harder to 
#obtain if the original X (without subtraction of their means) had been used? Explain.

###4.5. The accompanying table presents data on one dependent variable and five independent variables.
###(a) Give the linear model in matrix form for regressing Y on the five independent variables. 
###Completely define each matrix and give its order and rank.


Y=matrix(c(6.68, 6.31, 7.13, 5.81, 5.68, 7.66, 7.30, 6.19, 7.31), nrow=9, ncol=1, byrow=TRUE)
Y


X=matrix(c( 
1, 32.6, 4.78, 1092, 293.09, 17.1,
1, 33.4, 4.62, 1279, 252.18, 14.0,
1, 33.2, 3.72,  511, 109.31, 12.7,
1, 31.2, 3.29,  518, 131.63, 25.7,
1, 31.0, 3.25,  582, 124.50, 24.3,
1, 31.8, 7.35,  509,  95.19,  0.3,
1, 26.4, 4.92,  942, 173.25, 21.1,
1, 26.2, 4.02,  952, 172.21, 26.1,
1, 26.6, 5.47,  792, 142.34, 19.8
), nrow=9, ncol=6, byrow=TRUE)
X

##(b) The following quadratic forms were computed. 
#Y' PY = 404.532; Y' Y = 405.012; Y' (I − P)Y = 0.480; Y' (I − J/n)Y= 4.078; Y' (P − J/n)Y= 3.598; Y' (J'/n)Y = 400.934.
#Use a matrix algebra computer program to reproduce each of these sums of squares. Use these results to give the complete
#analysis of variance summary. 

##Definitions of I, J, P, n:
	I=diag(9)  #identity; 
	I

	J=matrix(1,nrow=9,ncol=9) #ones everywhere
	J

	P= X %*% solve( t(X) %*% X ) %*% t(X) ##P=[X (X'X)^{-1} X']
	P	

	n=9
	n
		
#Verify that Y' P Y = 404.532: 
round( t(Y) %*% P %*% Y, 3)

#verify that Y' Y = 405.012:
round( t(Y) %*% Y, 3 )

#verify that Y' (I − P)Y = 0.480:
round( t(Y) %*% ( I - P ) %*% Y, 3)

#verify that  Y' (I − J/n)Y= 4.078:
round( t(Y) %*% ( I-J/n) %*% Y, 3)

#verify that Y' (P − J/n)Y= 3.598:
round( t(Y) %*% (P - J/n) %*% Y, 3)
	
#verify that Y' (J'/n)Y = 400.934
round( t(Y) %*% ( t(J)/n) %*% Y, 3)

##############################################################################################

####4.1. Using lm:
M=cbind(Y, X)
summary(M)

MF=data.frame(M)
MF
	
summary(lm(X1 ~ X2+ X3+ X4+ X5+ X6, data = MF))

##############################################################################################



bh= solve( t(X) %*% X) %*% t(X) %*% Y
bh



#(c) The partial sums of squares for X1, X2, X3, X4, and X5 are .895,
#.238, .270, .337, and .922, respectively. Give the R-notation that
#describes the partial sum of squares for X2. Use a matrix algebra
#program to verify the partial sum of squares for X2.





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

####Formulas page 112:
t(Y)%*%Y #Total SS uncorrected
t(Y)%*%Y -n* (mean(Y))^2 #Total SS corrected
t(bh) %*% t(X) %*% Y -n* (mean(Y))^2 #SS Model
t(Y)%*%Y - t(bh)%*% t(X)%*%Y

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
#End of rm_Ch4.R##################################################################
##################################################################################



