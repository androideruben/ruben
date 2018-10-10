##############################################################################################
#rm_Ch4.R 
#programmer: Ruben Montes de Oca, CTP
#Purpose: Review of regression
#Started on February 1, 2018

##############################################################################################

##############################################################################################
setwd("\\\\fda.gov/WODC/CTP_Sandbox/OS/DPHS/StatisticsBranch/Team 2/Montes de Oca/Linear Regression Assignment/Ch4/code/")
getwd()

##############################################################################################

##############################################################################################

###4.5. The accompanying table presents data on one dependent variable and five 
#independent variables.

###(a) Give the linear model in matrix form for regressing Y on the five 
#independent variables. 
###Completely define each matrix and give its order and rank.

Y=matrix(c(6.68, 6.31, 7.13, 5.81, 5.68, 7.66, 7.30, 6.19, 7.31), 
	nrow=9, ncol=1, byrow=TRUE)
colnames(Y) <- c("Y")
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
colnames(X) <- c("X0", "X1", "X2", "X3", "X4", "X5")

bh = solve( t(X) %*% X ) %*% t(X) %*% Y
bh

#Since bh is the vector of estimated slopes, the resulted model is:
#Y^= 23.0856 * b0 -0.3631* b1 -0.4944* b2 -0.0020* b3+ 
#0.0114* b4 -0.1884* b5, with b1,...,b5 the estimated betas.

#X=QR with Q orthonormal and R upper-triangular matrix
QR=qr(X)
QR

#R is a upper-triangular 6x6
R=qr.R(QR)
R

#and Q is orthogonal 9x6:
Q=X %*% solve(R)
Q

#Q * R is X:
Q %*% R

##Definitions of I, J, P, n:
	I=diag(9)  #identity; 

	J=matrix(1,nrow=9,ncol=9) #ones everywhere

	P= X %*% solve( t(X) %*% X ) %*% t(X) ##P=[X (X'X)^{-1} X']

	dim(P)
	n=9
	
##(b) The following quadratic forms were computed. 
#Y'PY=404.532; Y'Y=405.012; Y'(I-P)Y=0.480; 
#Y'(I-J/n)Y=4.078; Y'(P-J/n)Y=3.598; 
#Y'(J'/n)Y=400.934.
	
#Use a matrix algebra computer program to reproduce each of these 
#sums of squares. 

#Verify that Y'PY=404.532: 
round( t(Y) %*% P %*% Y, 3)

#verify that Y' Y = 405.012:
round( t(Y) %*% Y, 3 )

#verify that Y'(I-P)Y=0.480:
round( t(Y) %*% ( I - P ) %*% Y, 3)

#verify that  Y'(I-J/n)Y=4.078:
round( t(Y) %*% ( I-J/n) %*% Y, 3)

#verify that Y'(P-J/n)Y=3.598:
round( t(Y) %*% (P - J/n) %*% Y, 3)
	
#verify that Y'(J'/n)Y=400.934
round( t(Y) %*% ( t(J)/n) %*% Y, 3)

#Use these results to give the complete analysis of variance summary. 
#Source of variation: Total (uncorrected)= Y'*Y
t(Y) %*% Y

#Source of variation: due to model
t(bh) %*% t(X) %*% Y

#Source of variation: Residual
t(Y) %*% Y - t(bh) %*% t(X) %*% Y

#(c) The partial sums of squares for X1, X2, X3, X4, and X5 are .895,
#.238, .270, .337, and .922, respectively. Give the R-notation that
#describes the partial sum of squares for X2. Use a matrix algebra
#program to verify the partial sum of squares for X2.

####R-notation is: beta0=0=(0 0 1 0 0 0) * (beta1 beta2... beta5)', with beta^= bh.
##Matrix algebra to show the partial sum of squares:

K=matrix(c( 0, 0, 1, 0, 0, 0), nrow=6, ncol=1, byrow=TRUE)
q=( t( t(K) %*% bh ) ) %*%  solve( t(K) %*% solve(t(X) %*% X) %*% K) %*% ( t(K) %*% bh)
q

#(d) Assume that none of the partial sums of squares for X2, X3,
#and X4 is significant and that the partial sums of squares for
#X1 and X5 are significant (at alpha = .05). Indicate whether each
#of the following statements is valid based on these results. If it
#is not a valid statement, explain why.

#(i) X1 and X5 are important causal variables whereas X2, X3,
#and X4 are not (TRUE)

#(ii) X2, X3, and X4 can be dropped from the model with no
#meaningful loss in predictability of Y (FALSE)

XX=matrix(c( 
1, 32.6,  17.1,
1, 33.4,  14.0,
1, 33.2,  12.7,
1, 31.2,  25.7,
1, 31.0,  24.3,
1, 31.8,   0.3,
1, 26.4,  21.1,
1, 26.2,  26.1,
1, 26.6,  19.8
), nrow=9, ncol=3, byrow=TRUE)

bbh= solve( t(XX) %*% XX ) %*% t(XX) %*% Y
bbh

#but these estimates for beta1, beta5 are not the same
bh
	
#(iii) There is no need for all five independent variables to be
#retained in the model (FALSE)

##Numerical example:

Y=matrix(c( 
44.609,
45.313,
54.297,
59.571,
49.874,
44.811,
45.681,
49.091,
39.442,
60.055,
50.541,
37.388,
44.754,
47.273,
51.855,
49.156,
40.836,
46.672,
46.774,
50.388,
39.407,
46.080,
45.441,
54.625,
45.118,
39.203,
45.790,
50.545,
48.673,
47.920,
47.467
), nrow=31, ncol=1, byrow=TRUE)
colnames(Y) <- c("Y")

X=matrix(c( 
1, 11.37, 62, 178, 182,
1, 10.07, 62, 185, 185,
1,  8.65, 45, 156, 184,
1,  8.17, 40, 166, 172,
1,  9.22, 55, 178, 180,
1, 11.63, 58, 176, 176,
1, 11.95, 70, 176, 180,
1, 10.85, 64, 162, 170,
1, 13.08, 63, 174, 176,
1,  8.63, 48, 170, 186,
1, 10.13, 45, 168, 168,
1, 14.03, 56, 186, 192,
1, 11.12, 51, 176, 176,
1, 10.60, 47, 162, 164,
1, 10.33, 50, 166, 170,
1,  8.95, 44, 180, 185,
1, 10.95, 57, 168, 172,
1, 10.00, 48, 162, 168,
1, 10.25, 48, 162, 164,
1, 10.08, 67, 168, 168,
1, 12.63, 58, 174, 176,
1, 11.17, 62, 156, 176,
1,  9.63, 48, 164, 166,
1,  8.92, 48, 146, 186,
1, 11.08, 48, 172, 172,
1, 12.88, 44, 168, 172,
1, 10.47, 59, 186, 188,
1,  9.93, 49, 148, 160,
1,  9.40, 56, 186, 188,
1, 11.50, 52, 170, 176,
1, 10.50, 53, 170, 172
), nrow=31, ncol=5, byrow=TRUE)
colnames(X) <- c("X0", "X1", "X2", "X3", "X4")

##Use lm for regression analysis:
XDF<-as.data.frame((X))  #make data as data frame
summary(lm(Y ~ X0+X1+X2+X3+X4, data=XDF))

##We will reproduce these lm results using matrix algbra

##The book has Yi = 84.26902 - 3.06981 Xi1 + 0.00799 Xi2 - 0.11671 Xi3 + 0.08518 Xi4:
bh = solve( t(X) %*% X ) %*% t(X) %*% Y
bh  #bh is multivariate Normal with mean=beta, and var=sigma^2 (X' X)^-1

###We need these: n, J, I, P:
	n=31
	J=matrix(1,nrow=31,ncol=31) 
	sum(diag(J/31)) #trace (J/n)
	I=diag(31)
	P=X %*% solve( ( t(X) %*% X ))  %*% t(X) #page 109

##SS Residual:
SSRes=t(Y) %*% Y - t(bh) %*% t(X) %*% Y
SSRes

##SS Total uncorrected:
TotUncorr=t(Y) %*% Y

##SS Total corrected:
TotCorr=t(Y) %*% Y - n* (mean(Y)* mean(Y))
TotCorr

TotCorr=(t(Y)%*%Y) - ( t(Y) %*% (J/n) %*% Y )  #Total(uncorr) - SS(mu)
TotCorr

##SS Model:
SSModel=t(bh) %*% t(X)  %*% Y
SSModel

##SS Regr
SSReg=t(Y) %*% P %*% Y - ( t(Y) %*% (J/n) %*% Y )  #SSReg= SSModel- SS(mu)
SSReg

SSReg= t(Y) %*% (P - J/n) %*% Y  #Also, SSReg= Y' (P-J/n) Y
SSReg


##Also, SSRes is:
SSRes=TotCorr- SSReg
SSRes

##And the estimated variance is:
sh2=SSRes/ sum(diag(I-P))   #SSRes/n-p' is also s^2
sh2

##The s.e. is:
sh=sqrt(sh2)
sh

##Coefficient of Determination or multiple R^2:
R2=SSReg/TotCorr
R2

##Adjusted R^2:
R2=SSReg/TotCorr
R2


#Full rank model if the rank of X equals its number of columns:
qr(X)$rank












SSReg/sum(diag(P-J/n))   #SSReg/n-p', p' is sum(diag(P))












##SS Regression:
t(Y) %*% Y - t(bh) %*% t(X) %*% Y

##F:
(t(Y) %*% Y - t(bh) %*% t(X) %*% Y) / (t(Y) %*% Y - n* (mean(Y)* mean(Y)))



#Since it is a full rank model, the bh=bhat is unique:

#The defining matrices J/n, (P - J/n), and (I - P) are pairwise
#orthogonal to each other and sum to I. Consequently, they partition
#the total uncorrected sum of squares into orthogonal sums of squares.

## J is ones everywhere. J/n is idempotent with tr(J/n)=1
J=matrix(1,nrow=31,ncol=31) 
sum(diag(J/31)) #trace (J/n)

##P:
P=X %*% solve( ( t(X) %*% X ))  %*% t(X) #page 109

##I:
I=diag(31)

#Residual SS:
(t(Y) %*% Y) - t(bh) %*% t(X) %*% Y  

##Degrees of freedom for the Residual SS:
qr(I-P)$rank

##The residual mean square is an unbiased estimate of sigma^2:
((t(Y) %*% Y) - t(bh) %*% t(X) %*% Y ) / qr(I-P)$rank

#To test H0: beta2=beta4=0=m:
m=0

K=matrix(c( 
	0, 0,
	0, 0,
	1, 0,
	0, 0,
	0, 1
), nrow=5, ncol=2, byrow=TRUE)

##df is 2:
qr(t(K))$rank

#Q = (K' _^ -m)' [K' (X' X)^-1 * K]^-1 * (K' _^ -m)= 10.0016:
Q=t( t(K) %*% bh - m) %*% solve( t(K) %*% ( solve(t(X) %*% X)) %*% K) %*% ( t(K) %*% bh - m)
Q

#F-test of the null hypothesis is F= (Q/2) / s^2 = 0.673 with 2 and 26 df:
F= (Q/2) / ( ((t(Y) %*% Y) - t(bh) %*% t(X) %*% Y ) / qr(I-P)$rank ) 
F

##The computed F is much smaller than the critical value F(.05,2,26) = 3.37
##and, therefore, there is no reason to reject the null hypothesis that ß2 and
##ß4 are both zero:
qf(0.95, df1=2, df2=26) 
pf(F, 2, 26)


#TABLE 4.4. Summary analysis of variance for the regression of oxygen uptake on
#run time, heart rate while resting, heart rate while running, and maximum heart rate.

##Source  		df  SS  			MS
##Total(corr)	30 	851.3815
##Regression 	4 	658.2368 	164.5659
##Residual 		26 	193.1178 	7.4276 = s^2

TotCorr=(t(Y)%*%Y) - ( t(Y) %*% (J/n) %*% Y )  #Total(uncorr) - SS(mu)
TotCorr

SSReg=t(Y) %*% P %*% Y - ( t(Y) %*% (J/n) %*% Y )  #SSReg= SSModel- SS(mu)
SSReg
SSReg= t(Y) %*% (P - J/n) %*% Y  #Also, SSReg= Y' (P-J/n) Y
SSReg

SSReg/sum(diag(P-J/n))   #SSReg/n-p', p' is sum(diag(P))

SSRes=TotCorr- SSReg
SSRes/ sum(diag(I-P))   #SSRes/n-p' is also s^2




##The second hypothesis illustrates a case where m = 0. Suppose prior
###information suggested that the intercept ß0 for a group of men of this
###age and weight should be 90. Then the null hypothesis of interest is ß0 =
###90 and, for illustration, we construct a composite hypothesis by adding
###this constraint to the two conditions in the first null hypothesis. The null
###hypothesis is now H0: K' ß -m = 0:

#To test H0: beta2=beta4=0=m:
m=matrix(c( 
	90,
	0,
	0
), nrow=3, ncol=1, byrow=TRUE)

K=matrix(c( 
	1, 0, 0,
	0, 0, 0,
	0, 1, 0,
	0, 0, 0,
	0, 0, 1
), nrow=5, ncol=3, byrow=TRUE)

#For this hypothesis:
t(K) %*% bh - m

#and

solve( t(K) %*% solve( t(X) %*% X ) %*% K)

Q = t( t(K) %*% bh -m) %*% solve( t(K) %*% solve( t(X) %*% X ) %*% K) %*% ( t(K) %*% bh -m)
Q

##and has 3 degrees of freedom. The computed F-statistic is:
F= (Q/3) / ( ((t(Y) %*% Y) - t(bh) %*% t(X) %*% Y ) / qr(I-P)$rank )
F

##which, again, is much less than the critical value of F for a = .05 and 3
###and 26 degrees of freedom, F(.05,3,26) = 2.98. There is no reason to reject
###the null hypothesis that ß0 = 90 and ß2 = ß4 = 0.

qf(0.95, df1=3, df2=26) 
pf(F, 3, 26)

##df is 2:
qr(t(K))$rank

#Q = (K' _^ -m)' [K' (X' X)^-1 * K]^-1 * (K' _^ -m)= 10.0016:
Q=t( t(K) %*% bh - m) %*% solve( t(K) %*% ( solve(t(X) %*% X)) %*% K) %*% ( t(K) %*% bh - m)
Q

#F-test of the null hypothesis is F= s^2 *(Q/2)= 0.673 with 2 and 26 df:
F= (Q/2) / ( ((t(Y) %*% Y) - t(bh) %*% t(X) %*% Y ) / qr(I-P)$rank ) 
F

##The computed F is much smaller than the critical value F(.05,2,26) = 3.37
##and, therefore, there is no reason to reject the null hypothesis that ß2 and
##ß4 are both zero:
qf(0.95, df1=2, df2=26) 
pf(F, 2, 26)


#TABLE 4.4. Summary analysis of variance for the regression of oxygen uptake on
#run time, heart rate while resting, heart rate while running, and maximum heart rate.

##Source  		df  SS  			MS
##Total(corr)	30 	851.3815
##Regression 	4 	658.2368 	164.5659
##Residual 		26 	193.1178 	7.4276 = s^2

TotCorr=(t(Y)%*%Y) - ( t(Y) %*% (J/n) %*% Y )  #Total(uncorr) - SS(mu)
TotCorr

SSReg=t(Y) %*% P %*% Y - ( t(Y) %*% (J/n) %*% Y )  #SSReg= SSModel- SS(mu)
SSReg
SSReg= t(Y) %*% (P - J/n) %*% Y  #Also, SSReg= Y' (P-J/n) Y
SSReg

SSReg/sum(diag(P-J/n))   #SSReg/n-p', p' is sum(diag(P))

SSRes=TotCorr- SSReg
SSRes/ sum(diag(I-P))   #SSRes/n-p' is also s^2

##################################################################################
#End of rm_Ch4.R##################################################################
##################################################################################



