setwd("C:\\Users\\ruben\\Downloads\\ACS\\data\\ACS2014\\csv_hus2014")

#http://eglenn.scripts.mit.edu/citystate/wp-content/uploads/2013/06/wpid-working_with_acs_R3.pdf
install.packages("acs")


#After installing, be sure to load the package with library(acs) each time
#you start a new session.


library(acs)
# load PUMS data
ss14husa <- read.csv("ss14husa.csv")
summary(ss14husa)

head(ss14husa,1)
nrow(ss14husa)
str(ss14husa)
tail(ss14husa, 2)
ss14husa[47,]

# convert sex and age group to factors
ss14husa$SEX <- factor(ss14husa$SEX, labels = c("M","F"))
ss14husa$agegrp <- cut(ss14husa$AGEP,
                     c(0,5,10,15,20,25,35,45,55,60,65,75,85,100),
                     right = FALSE)
