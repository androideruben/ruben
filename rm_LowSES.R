###################################################################################################################################
#rm_LowSES.R 
#programmer: Ruben Montes de Oca
#Purpose: Simulation and analyses of ITP
#Started on January 17, 2018
##############################################

##DIRECTORIES:
###setwd("//1-LowSES/data")
###getwd()
###dir()
###data()
##############################################

##LOG:
###save your LOG (put at the end of the program):
###savehistory(file="//1-LowSES/code/rm_LowSESLOG.Rhistory") # default is ".Rhistory"
##############################################

##OUTPUT:
####sink("//1-LowSES/results/rm_summary.txt", append=FALSE, split=FALSE); 
####rm_summary
####sink()

###STARGAZER CREATES txt OF html (LateX):
####stargazer(iris[1:3,], type="text", title="test", summary=FALSE, rownames=FALSE,
####	out="//1-LowSES/results/models.txt")
####
####stargazer(iris[1:3,], type="html", title="test", summary=FALSE, rownames=FALSE,
####	out="//1-LowSES/results/models.html")
####
####stargazer(iris, type="html", title="test", summary=FALSE, rownames=TRUE,
####	out=//1-LowSES/results/models.html")
####
####stargazer(iris, type="text", title="test", summary=F, rownames=TRUE, 
####	out="//1-LowSES/results/models.txt")

###PDF OUTPUT:
####df= data.frame(matrix(rnorm(400), nrow=100)); dfplot=ggplot(df, aes(x=X1, X2)) + geom_point()
####pdf("//1-LowSES/results/test.pdf", 
####height=11, width=8.5)
####dfplot
####dev.off()

##############################################

###LIBRARIES:
####library(stargazer) #Nice outputs, https://www.jakeruss.com/cheatsheets/stargazer/, https://www.princeton.edu/~otorres/NiceOutputR.pdf
####library(grid)			 #plots
####library(gridExtra) #plots
####library(ggplot2)   #plots
####library(lme4)      #linear algebra
####################################################################################################################################







###https://thusithamabotuwana.wordpress.com/2016/01/02/creating-pdf-documents-with-rrstudio/


pdf("//1-LowSES/results/test.pdf", height=11, width=8.5)
grid.table(rm_summary)
dev.off()





# Linear Mixed Model y = X*B + Z*U + e
# Y, 12 observations
Y=c(0.81854, 0.60196, 0.54850, 0.14487, 0.05872, 0.00930, 0.80621, 0.41986, 0.42066, 0.24141, 0.50429, 0.88710)
# X, design matrix for the fixed effects
X=matrix(c(1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,0,0,0,0,0,0, 0,0,0,0,0,0, 1,1,1,1,1,1, 1,1,1,1,1,1, 0,0,0,0,0,0), 12, 4)
# Z, design matrix for the random effects
Z=diag(12); #identity matrix of size 12x12
# G = var(U)
Su2=1; # random effect variance
G=diag(12)*Su2;

# R = var(e)
Se2=3; # error variance
R=diag(12)*Se2;
# V=var(Y) 12x12
V=Z%*%G%*%t(Z) + R

#solve(a, b, ...): This generic function solves the equation ( a %*% x = b ) for x, where b can be either a vector or a matrix. 
#a: a square numeric or complex matrix; 
# b: a numeric or complex vector or matrix giving the right-hand side(s) of the linear system. If b is absent, 
#the default is a unit matrix.
Vi= solve(V) #12x12
B = solve( t(X)%*%Vi%*%X )%*%t(X)%*%Vi%*%Y;
U = G%*%t(Z)%*%Vi%*%(Y - X%*%B);
# Print out solutions
print (U, quote=T, row.names=F)

# Or produce histogram of BLUP values
hist(U, col="lightblue")

##############################################################

str(sleepstudy)
fm1 <-lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
fm1


