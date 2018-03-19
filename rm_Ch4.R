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


##################################################################################
#End of rm_Ch4.R##################################################################
##################################################################################



