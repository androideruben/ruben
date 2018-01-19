%let program_name=rm_LowSES;

title "Linear Mixed Models ITP";
title2;

/**************************************************************************************************
rm_LowSES.sas

ANALYSIS of an ITP (Investigational Tobacco Product) using Linear Mixed Models

PROGRAMMER: Ruben, CTP\OS\Statistics Branch
DATE STARTED: November 2017. See time stamps &sysdate9 for current date.

PURPOSE: Create simulation data for mixed model.

MODEL:
**model is (Log(cotinine)= intercept+ race+ menthol+ arm*(time0 to time6)+ 
							SUBJECT(ARM)+ epsilon;
proc mixed data=work.LONG;
class arm race menthol time;
model LnCotinine=arm race menthol arm*time/solution;
random subject(arm)/solution;
run;

REFERENCES:
**https://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_mixed_sect026.htm
For models with fixed effects involving classification variables, there are more design columns in constructed 
than there are degrees of freedom for the effect. Thus, there are linear dependencies among the columns of X
The solution values are not displayed unless you specify the SOLUTION option in the MODEL statement;




ods pdf file=
"\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm04_ITP\1-LowSES\CODE\results\&program_name &sysdate9..pdf";

ods pdf close;

PROC DATASETS LIBRARY=WORK;
SAVE LONG WIDE SUBJECT FORMATS;
RUN;

**************************************************************************************************/

libname LowSES "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm04_ITP\1-LowSES\data";

proc format;

value arm
0='UNC'
1='RNC';

value race
0='Black'
1='White';

value menthol
1='Yes menthol'
2='No menthol'
;

run;

**simulate data for model: 
Exp(Log(COTININE))= intercept+ arm+ race+ menthol+ arm*(time0 to time6)+ AvgCigs+ SUBJECT(ARM)+ epsilon
with RANDOM SUBJECT(ARM) and epsilon N(0,S2)

where 
ARM=0=UNC, ARM=1RNC
RACE=0=Black, RACE=1=White
MENTHOL=0=No, MENTHOL=1=Yes
TIME=1=Visit1=Dose1
TIME=2=Visit1=Dose2
TIME=3=Visit1=Dose3
TIME=4=Visit1=Dose4
TIME=5=Visit1=Dose5
TIME=6=Visit1=Dose6
TIME=7=Visit1=Dose7
;

%macro repeated(data, startN, endN, race, arm, time1, time2, time3, time4, time5, time6, time7);

data work.&data;

do subject=&startN to &endN;

	**Fixed attribuites:;

		**ARM:;
		arm=&arm;

		**RACE:;
		race=&race;

		**MENTHOL(Y/N):;
		menthol=ranbin(1234,1,0.1)+1;**seed=1234;

		**TIME:;
		time1=&time1;
		time2=&time2;
		time3=&time3;
		time4=&time4;
		time5=&time5;
		time6=&time6;
		time7=&time7;

      output;
   end;
run;

%mend repeated;
*%macro 
repeated(data, startN, endN, race, arm, dose0, dose1, dose2, dose3, dose4, dose5, dose6);

%repeated(WideWhiteUNC,   1,  70, 1, 0,  1, 1, 1, 1, 1, 1, 1);
%repeated(WideBlackUNC,  71, 140, 0, 0,  1, 1, 1, 1, 1, 1, 1);
%repeated(WideWhiteRNC, 141, 210, 1, 1,  1, 1, 1, 1, 1, 1, 1);
%repeated(WideBlackRNC, 211, 280, 0, 1,  1, 1, 1, 1, 1, 1, 1);

data work.SUBJECT;
set 
WideWhiteUNC
WideBlackUNC
WideWhiteRNC
WideBlackRNC
;
run;

proc transpose data=work.SUBJECT out=work.LONG0(rename=(_name_=visit));
var time1-time7;
by subject arm race menthol;
run;

proc freq data=long0;
tables arm race menthol;
run;

data work.LONG;
set work.LONG0;

if visit='time1' then time=1;
if visit='time2' then time=2;
if visit='time3' then time=3;
if visit='time4' then time=4;
if visit='time5' then time=5;
if visit='time6' then time=6;
if visit='time7' then time=7;

**Y=Exp(Log(COTININE))= 1.1+ 0.3 RACE+ 0.0001 MENTHOL+ 0.001 ARM*TIME1+ 0.01 ARM*TIME2+ 0.001 ARM*TIME3
0.0005 ARM*TIME4+ 0.0003 ARM*TIME5+ 0.0001 ARM*TIME6+ 0.02 AvgCigs+ 0.9 SUBJECT(ARM)+ epsilon
with RANDOM SUBJECT(ARM) and epsilon N(0,S2)


A.- Expected for:

0=RACE
1=MENTHOL
1=ARM
1=ARM*TIME1
0=ARM*TIME2
0=ARM*TIM3
0=ARM*TIME4
0=ARM*TIME5
0=ARM*TIME6
x=AvgCigs=any number
s=SUBJECT(ARM)=any number: 

1.1+ 0+ 0.001+ 0+ 0+ 0+ 0+ 0+ 0.02+ 0.9= 2.021
;

AvgCigs=abs(18+sqrt(3)*rannor(2021));

if (RACE=0) & 
	(MENTHOL=1) & 
	(ARM=1 & TIME=1) & 
	(ARM=1 & TIME=0) & 
	(ARM=1 & TIME=0) & 
	(ARM=1 & TIME=0) &
	(ARM=1 & TIME=0) & 
	(ARM=1 & TIME=0) & 
	(ARM=1 & TIME=0) &
	AvgCigs>-1 &
	SUBJECT>1 then LnCotinine=abs(2.021+sqrt(0.01)*rannor(subject)); 

		else LnCotinine=1;

**Exp Log(COTININE):;		
eLnCotinine=Exp(LnCotinine);

format 
SUBJECT time arm race menthol 3.0
LnCotinine AvgCigs  10.2;

proc sort; by subject time;
run;

proc compare base=LowSES.LONG compare=work.LONG;
run;
/*
data LowSES.LONG;
*retain SUBJECT time arm race menthol LnCotinine_baseline cotinine AvgCigs;
set work.LONG;
run;
*/

proc transpose data=work.long out=work.WIDE(rename=(col1=LNCOTININE1 col2=LNCOTININE2 
col3=LNCOTININE3 col4=LNCOTININE4 col5=LNCOTININE5 col6=LNCOTININE6 col7=LNCOTININE7));
var Lncotinine;
by subject arm race menthol;
run;

proc export data= LowSES.LONG 
outfile= "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm04_ITP\1-LowSES\data\LONG.csv"
dbms=csv replace;
putnames=yes;
run;

ods pdf file="\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm04_ITP\1-LowSES\code\results\&program_name &sysdate9..pdf";

proc print n noobs data=work.LONG;
title3 "First subject in each arm:";
title4 "Figure3";
by subject;
where subject in (1,2, 141,142);
format arm arm. race race. menthol menthol.;
run;
title4;

proc means min max data=work.subject maxdec=0;
title3 "All 280 subjects, 140 in each arm (UNC, or RNC), by arm";
class race arm;
var subject;
format arm arm. race race.;
run;

proc tabulate data=work.LONG;
title3 "All 280 subjects, 140 in each arm (UNC, or RNC) by arm";
class arm race;
var LnCotinine: eLnCotinine: AvgCigs;
tables (arm='ARM'*race='Race'), (eLnCotinine='Exp(Log(cotinine))' AvgCigs)* 
	(n='N'*f=4.0 (mean='MEAN' var='VAR')*f=6.3)/rts=15;
format arm arm. race race.;
run;
proc tabulate data=work.LONG;
title3 "All 280 subjects, 140 in each arm (UNC, or RNC) by arm and time";
class arm race time;
var LnCotinine: eLnCotinine: AvgCigs;
tables (arm='ARM'*race='Race'*time='Time'), (eLnCotinine='Exp(Log(cotinine))' AvgCigs)* 
	(n='N'*f=4.0 (mean='MEAN' var='VAR')*f=6.3)/rts=15;
format arm arm. race race.;
run;

proc sort data=work.wide; by arm race; run;
proc corr data=wide cov outp=covMatrix noprint;
by arm;
var LnCotinine1 LnCotinine2 LnCotinine3 LnCotinine4 LnCotinine5 LnCotinine6 LnCotinine7;
run;
proc print noobs data=covMatrix;
title3 "Variance-covariance by arm:";
where _type_='COV';
run;

**checking normality:;
proc sgpanel data=work.LONG;
title3 "Checking normality of Log(cotinine) by time and ARM:";
panelby time arm/uniscale=row;**UNISCALE= ROW option specifies that only the shared row axes are identical;
histogram lncotinine;
density lncotinine;
run;

**model is Log(cotinine)= intercept+ race+ menthol+ arm*(time0 to time6)+ SUBJECT(ARM)+ epsilon;
proc mixed data=work.LONG;
title3 "COTININE= intercept+ arm+ race+ menthol+ arm*(time0 to time6)+ SUBJECT(ARM)+ epsilon";
title4 "with RANDOM SUBJECT(ARM) and epsilon N(0,S2)";
class race menthol arm time;
model LnCotinine=race menthol arm*time/solution;
random subject(arm)/solution;
run;

ods pdf close;

arm=1
RACE=1
MENTHOL=1
TIME1=1
TIME2=0
TIME3=0
TIME4=0
TIME5=0
TIME6=0
AvgCigs=18
SUBJECT=1 

y=1.1+ 
0.3* RACE+ 
0.0001* MENTHOL+ 
0.001* TIME1+ 
0.01* TIME2+ 
0.001* TIME3
0.0005* TIME4+ 
0.0003* TIME5+ 
0.0001* TIME6+ 
0.02* AvgCigs+ 
0.9* SUBJECT

y

/******************************************************************************************
End of \\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\
	rm04_ITP\1-LowSES\code\rm_LowSES.sas
******************************************************************************************/

