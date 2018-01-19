%let program_name=rm_LowSES;

title "Linear Mixed Models ITP";
title2;

options source nostimer nocenter pagesize = 60 linesize = 132 noquotelenmax orientation=landscape
mprint mlogic validvarname=v7 ;
ods noproctitle;

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

proc freq data=work.long0;
tables arm race menthol;
run;

%macro long(dataout, 
arm,
RACE,
MENTHOL,
TIME1,
TIME2,
TIME3,
TIME4,
TIME5,
TIME6,
AvgCigs,
SUBJECT);


data work.&dataout;
set work.LONG0;

if arm=&arm & race=&race & menthol=&menthol;

if visit='time1' then do; time1=1; time2=0; time3=0; time4=0; time5=0; time6=0; time7=0; time=1; end;
if visit='time2' then do; time1=0; time2=1; time3=0; time4=0; time5=0; time6=0; time7=0; time=2; end;
if visit='time3' then do; time1=0; time2=0; time3=1; time4=0; time5=0; time6=0; time7=0; time=3; end;
if visit='time4' then do; time1=0; time2=0; time3=0; time4=1; time5=0; time6=0; time7=0; time=4; end;
if visit='time5' then do; time1=0; time2=0; time3=0; time4=0; time5=1; time6=0; time7=0; time=5; end;
if visit='time6' then do; time1=0; time2=0; time3=0; time4=0; time5=0; time6=1; time7=0; time=6; end;
if visit='time7' then do; time1=0; time2=0; time3=0; time4=0; time5=0; time6=0; time7=1; time=7; end;

AvgCigs=abs(&AvgCigs+sqrt(3)*rannor(1234));
SUBJECTEFFECT=abs(0.00+sqrt(1)*rannor(subject));

mymean=0.09+ 
0.3000* RACE+ 
0.0001* MENTHOL+ 
0.0010* TIME1+ 
0.0100* TIME2+ 
0.0010* TIME3+
0.0005* TIME4+ 
0.0003* TIME5+ 
0.0001* TIME6+ 
(1/180)* AvgCigs+
0.01* SUBJECTEFFECT
;

LnCotinine=abs(mymean+sqrt(0.01)*rannor(subject)); 

**Exp Log(COTININE):;		
eLnCotinine=Exp(LnCotinine);

format 
SUBJECT time arm race menthol 3.0
LnCotinine AvgCigs  10.2;

proc sort; by subject time;
run;

proc print n noobs data=&dataout;
title3 "data=&dataout where LnCotinine ne .";
where LnCotinine ne .;
var subject time LnCotinine eLnCotinine mymean;
run;

%mend LONG;
*%long(data,arm,race,menthol,time1,time2,time3,time4,time5,time6,AvgCigs,SUBJECTEFFECTS);**coefficients;

**arm=1=RNC;
%long(longR1, 1,   1,      1,    1,    0,    0,    0,    0,    0,     18,             1);
%long(longR2, 1,   1,      1,    0,    1,    0,    0,    0,    0,     18,             1);
%long(longR3, 1,   1,      1,    0,    0,    1,    0,    0,    0,     18,             1);
%long(longR4, 1,   1,      1,    0,    0,    0,    1,    0,    0,     18,             1);
%long(longR5, 1,   1,      1,    0,    0,    0,    0,    1,    0,     18,             1);
%long(longR6, 1,   1,      1,    0,    0,    0,    0,    0,    1,     18,             1);

**arm=0=UNC;
%long(longU1, 0,   1,      1,    1,    0,    0,    0,    0,    0,     18,             1);
%long(longU2, 0,   1,      1,    0,    1,    0,    0,    0,    0,     18,             1);
%long(longU3, 0,   1,      1,    0,    0,    1,    0,    0,    0,     18,             1);
%long(longU4, 0,   1,      1,    0,    0,    0,    1,    0,    0,     18,             1);
%long(longU5, 0,   1,      1,    0,    0,    0,    0,    1,    0,     18,             1);
%long(longU6, 0,   1,      1,    0,    0,    0,    0,    0,    1,     18,             1);

data work.long(drop=time1-time7 col1);
set 
longr1
longr2
longr3
longr4
longr5
longr6
longu1
longu2
longu3
longu4
longu5
longu6
;
format LnCotinine eLnCotinine subjecteffect 6.3;

proc sort; by arm subject;
run;

proc means nmiss mean data=long;
class arm race;
var mymean LnCotinine eLnCotinine;
format arm arm. race race.;
run;
 
proc compare base=LowSES.LONG compare=work.LONG;
run;
/*
data LowSES.LONG;
*retain SUBJECT time arm race menthol LnCotinine_baseline cotinine AvgCigs;
set work.LONG;
run;
*/

proc transpose data=work.long out=work.WIDE;*(rename=(col1=LNCOTININE1 col2=LNCOTININE2 
col3=LNCOTININE3 col4=LNCOTININE4 col5=LNCOTININE5 col6=LNCOTININE6 col7=LNCOTININE7));
var Lncotinine;
by subject arm;
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

/******************************************************************************************
End of \\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\
	rm04_ITP\1-LowSES\code\rm_LowSES.sas
******************************************************************************************/

