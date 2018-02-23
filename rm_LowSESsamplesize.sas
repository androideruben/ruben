	%let program_name=rm_samplesize;

libname lowses "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm04_ITP\1-LowSES\data";

ods pdf file=
"\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm04_ITP\1-LowSES\code\results\&program_name &sysdate9..pdf";

**https://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_power_a0000001005.htm
Example 68.4 Noninferiority Test with Lognormal Data
The typical goal in noninferiority testing is to conclude that a new treatment or process or product is not appreciably 
worse than some standard. This is accomplished by convincingly rejecting a one-sided null hypothesis that the new 
treatment is appreciably worse than the standard. When designing such studies, investigators must define precisely 
what constitutes "appreciably worse."
You can use the POWER procedure for sample size analyses for a variety of noninferiority tests, by specifying custom, 
one-sided null hypotheses for common tests. This example illustrates the strategy (often called Blackwelder’s scheme--
Blackwelder 1982) by comparing the means of two independent lognormal samples. The logic applies to one-sample, 
two-sample, and paired-sample problems involving normally distributed measures and proportions.
Suppose you are designing a study hoping to show that a new (less expensive) manufacturing process does not 
produce appreciably more pollution than the current process. Quantifying "appreciably worse" as 10%, you seek to show that the mean pollutant level from the new process is less than 110% of that from the current process. In standard hypothesis testing notation, you seek to reject
in favor of

H0: (mu_new/mu_current)>= 1.10
Ha: ~H0

equivallently:
H0: log(mu_new) - log(mu_current) >= log(1.10)

Measurements of the pollutant level will be taken by using laboratory models of the two processes and will be treated 
as independent lognormal observations with a coefficient of variation CV=sigma/mu between 0.5 and 0.6 for both processes. 
You will end up with 300 measurements for the current process and 180 for the new one. It is important to avoid a
Type I error here, so you set the Type I error rate to 0.01. Your theoretical work suggests that the new process will 
actually reduce the pollutant by about 10% (to 90% of current), but you need to compute and graph the power of the 
study if the new levels are actually between 70% and 120% of current levels;

proc power;
title1 "My CV: cv=0.5 0.6";
title2 "My sizes: groupns=(300 180)";
title3 "My reduction: nullratio=1.10 (10% decrease, or 90% of current)";
   
twosamplemeans test=ratio
sides     = L

cv        = 0.5 0.6
groupns   = (300 180)
alpha     = 0.01

nullratio = 1.10
meanratio = 0.7 to 1.2 by 0.1

power     = .;

plot x=effect step=0.05;
run;

/*************************************************************************/

***ITP:;
proc power;
title1 "My CV: cvA=240/120=0.5, cvB=116/113=1.02";
title2 "My sizes: groupns=(70 70)";
title3 "My reduction: nullratio=1.25 (25% decrease of 240~58)";
   
twosamplemeans test	=ratio
sides     			= L
cv        			= 0.5 1.02
groupns   			= (70 70)
alpha     			= 0.05
nullratio 			= 1.25
meanratio 			= 1.0 to 1.50 by 0.1
power     = .;
plot x=effect step=0.05;
run;

***Clinical trial ZRHR-REXC-04-JP:;
%macro power(meanratio, cv); 

title4 "ZRHR-REXC-04-JP: meanratio=&meanratio, cv=&cv, groupsn=80|40"; 

proc power; 
twosamplemeans test=ratio 
sides=L 
nullratio=1.5 /*H0: THS/CC = 1.5*/
meanratio=&meanratio /*mean THS/ mean CC*/
cv=&cv 

groupns = (40  80) /*40 CC and 80 THS*/
alpha=0.05 
power = .; 
run; 

%mend power; 

%power(0.40, 0.32); 
%power(0.30, 0.50); 
%power(0.15, 0.70); 
%power(0.20, 0.70); 
