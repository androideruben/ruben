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
0='No menthol'
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

**Y=Exp(Log(COTININE))= 1.1+ 0.3 RACE+ 0.0001 MENTHOL+ 0.001 ARM*TIME1+ 0.01 ARM*TIME2+ 0.001 ARM*TIME3
0.0005 ARM*TIME4+ 0.0003 ARM*TIME5+ 0.0001 ARM*TIME6+ 0.02 AvgCigs+ 0.9 SUBJECT(ARM)+ epsilon
with RANDOM SUBJECT(ARM) and epsilon N(0,S2)


Expected for:
a) RACE=0, MENTHOL=0, 0=ARM*TIME1=ARM*TIME2=ARM*TIM3=ARM*TIME4=ARM*TIME5=ARM*TIME6, AvgCigs=any number, SUBJECT(ARM)=any number:



;


%macro repeated(data, startN, endN, race, arm, time0, time1, time2, time3, time4, time5, time6);

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
		time0=&time0;
		time1=&time1;
		time2=&time2;
		time3=&time3;
		time4=&time4;
		time5=&time5;
		time6=&time6;

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

%macro transpose(datain, dataout);

proc transpose data=work.&datain out=work.&dataout(drop=col1 rename=(_name_=visit));
var time0-time6;
by subject arm race menthol;
run;

data work.&dataout;
set work.&dataout;

**LOG OF COTININE, AVERAGE NUMBER OF CIGARETTES PET VISIT:;
***A normal variate X with mean MU and variance S2 can be generated with this code:
x=MU+sqrt(S2)*rannor(seed);

**race=0=Black, arm=0=UNC: cotinine=0.07 and avgcigs=18;
%let seed00=1200;

if race=0 & arm=0 then do;
if visit='time0' then do; Lncotinine=abs(0.07+sqrt(0.01)*rannor(&seed00)); AvgCigs=abs(18+sqrt(3)*rannor(&seed00)); end;
if visit='time1' then do; Lncotinine=abs(0.07+sqrt(0.01)*rannor(&seed00)); AvgCigs=abs(18+sqrt(3)*rannor(&seed00)); end;
if visit='time2' then do; Lncotinine=abs(0.07+sqrt(0.01)*rannor(&seed00)); AvgCigs=abs(18+sqrt(3)*rannor(&seed00)); end;
if visit='time3' then do; Lncotinine=abs(0.07+sqrt(0.01)*rannor(&seed00)); AvgCigs=abs(18+sqrt(3)*rannor(&seed00)); end;
if visit='time4' then do; Lncotinine=abs(0.07+sqrt(0.01)*rannor(&seed00)); AvgCigs=abs(18+sqrt(3)*rannor(&seed00)); end;
if visit='time5' then do; Lncotinine=abs(0.07+sqrt(0.01)*rannor(&seed00)); AvgCigs=abs(18+sqrt(3)*rannor(&seed00)); end;
if visit='time6' then do; Lncotinine=abs(0.07+sqrt(0.01)*rannor(&seed00)); AvgCigs=abs(18+sqrt(3)*rannor(&seed00)); end;
end;

**race=0=Black, arm=1=RNC:: cotinine=0.06 and avgcigs=17;
%let seed01=1201;

if race=0 & arm=1 then do;
if visit='time0' then do; Lncotinine=abs(0.06+sqrt(0.01)*rannor(&seed01)); AvgCigs=abs(17+sqrt(2)*rannor(&seed01)); end;
if visit='time1' then do; Lncotinine=abs(0.06+sqrt(0.01)*rannor(&seed01)); AvgCigs=abs(17+sqrt(2)*rannor(&seed01)); end;
if visit='time2' then do; Lncotinine=abs(0.06+sqrt(0.01)*rannor(&seed01)); AvgCigs=abs(17+sqrt(2)*rannor(&seed01)); end;
if visit='time3' then do; Lncotinine=abs(0.06+sqrt(0.01)*rannor(&seed01)); AvgCigs=abs(17+sqrt(2)*rannor(&seed01)); end;
if visit='time4' then do; Lncotinine=abs(0.06+sqrt(0.01)*rannor(&seed01)); AvgCigs=abs(17+sqrt(2)*rannor(&seed01)); end;
if visit='time5' then do; Lncotinine=abs(0.06+sqrt(0.01)*rannor(&seed01)); AvgCigs=abs(17+sqrt(2)*rannor(&seed01)); end;
if visit='time6' then do; Lncotinine=abs(0.06+sqrt(0.01)*rannor(&seed01)); AvgCigs=abs(17+sqrt(2)*rannor(&seed01)); end;
end;

**race=1=White, arm=0=UNC:;
%let seed10=1210;

if race=1 & arm=0 then do;
if visit='time0' then do; Lncotinine=abs(0.08+sqrt(0.01)*rannor(&seed10)); AvgCigs=abs(19+sqrt(3)*rannor(&seed10)); end;
if visit='time1' then do; Lncotinine=abs(0.08+sqrt(0.01)*rannor(&seed10)); AvgCigs=abs(19+sqrt(3)*rannor(&seed10)); end;
if visit='time2' then do; Lncotinine=abs(0.08+sqrt(0.01)*rannor(&seed10)); AvgCigs=abs(19+sqrt(3)*rannor(&seed10)); end;
if visit='time3' then do; Lncotinine=abs(0.08+sqrt(0.01)*rannor(&seed10)); AvgCigs=abs(19+sqrt(3)*rannor(&seed10)); end;
if visit='time4' then do; Lncotinine=abs(0.08+sqrt(0.01)*rannor(&seed10)); AvgCigs=abs(19+sqrt(3)*rannor(&seed10)); end;
if visit='time5' then do; Lncotinine=abs(0.08+sqrt(0.01)*rannor(&seed10)); AvgCigs=abs(19+sqrt(3)*rannor(&seed10)); end;
if visit='time6' then do; Lncotinine=abs(0.08+sqrt(0.01)*rannor(&seed10)); AvgCigs=abs(19+sqrt(3)*rannor(&seed10)); end;
end;

**race=1=White, arm=1=RNC:;
%let seed11=1211;

if race=1 & arm=1 then do;
if visit='time0' then do; Lncotinine=abs(0.05+sqrt(0.01)*rannor(&seed11)); AvgCigs=abs(17+sqrt(2)*rannor(&seed11)); end;
if visit='time1' then do; Lncotinine=abs(0.05+sqrt(0.01)*rannor(&seed11)); AvgCigs=abs(17+sqrt(2)*rannor(&seed11)); end;
if visit='time2' then do; Lncotinine=abs(0.05+sqrt(0.01)*rannor(&seed11)); AvgCigs=abs(17+sqrt(2)*rannor(&seed11)); end;
if visit='time3' then do; Lncotinine=abs(0.05+sqrt(0.01)*rannor(&seed11)); AvgCigs=abs(17+sqrt(2)*rannor(&seed11)); end;
if visit='time4' then do; Lncotinine=abs(0.05+sqrt(0.01)*rannor(&seed11)); AvgCigs=abs(17+sqrt(2)*rannor(&seed11)); end;
if visit='time5' then do; Lncotinine=abs(0.05+sqrt(0.01)*rannor(&seed11)); AvgCigs=abs(17+sqrt(2)*rannor(&seed11)); end;
if visit='time6' then do; Lncotinine=abs(0.05+sqrt(0.01)*rannor(&seed11)); AvgCigs=abs(17+sqrt(2)*rannor(&seed11)); end;
end;

**Exp Log(COTININE):;		
eLnCotinine=Exp(LnCotinine);

proc sort; by subject visit; 
run;

%mend transpose;
%transpose(WideWhiteUNC, LongWhiteUNC);
%transpose(WideBlackUNC, LongBlackUNC);
%transpose(WideWhiteRNC, LongWhiteRNC);
%transpose(WideBlackRNC, LongBlackRNC);

**add time to data, for arm=1 we will simulate decreasing Lncotinine over time:;
%macro timeRNCT(data);

proc sort data=work.&data;
by subject descending Lncotinine;
run;

data work.&data; 
set work.&data; 
by subject; 
if first.subject then time=0; time+1; 
run;

%mend timeRNCT;
%timeRNCT(LongWhiteRNC);
%timeRNCT(LongBlackRNC);

%macro timeUNCT(data);

data work.&data; 
set work.&data; 
by subject; 
if first.subject then time=0; time+1; 
run;

%mend timeUNCT;
%timeUNCT(LongWhiteUNC);
%timeUNCT(LongBlackUNC);

data work.LONG(drop=visit);
set work.LongWhiteUNC work.LONGBlackUNC work.LongWhiteRNC work.LONGBlackRNC;

LnCotinineB=LnCotinine+abs(0.00+sqrt(0.01)*rannor(subject));
**Exp Log(COTININE):;		
eLnCotinineB=Exp(LnCotinineB);

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

data work.subject;
set work.LONG(keep=subject arm race);
proc sort nodupkey; by arm race subject;
run;

proc transpose data=work.long out=work.widea(rename=(col1=LNCOTININE1 col2=LNCOTININE2 
col3=LNCOTININE3 col4=LNCOTININE4 col5=LNCOTININE5 col6=LNCOTININE6 col7=LNCOTININE7));
var Lncotinine;
by subject arm race menthol;
run;
proc transpose data=work.long out=work.wideb(rename=(col1=LNCOTININEB1 col2=LNCOTININEB2 
col3=LNCOTININEB3 col4=LNCOTININEB4 col5=LNCOTININEB5 col6=LNCOTININEB6 col7=LNCOTININEB7));
var LNCOTININEB;
by subject arm race menthol;
run;
data work.WIDE;
merge work.widea work.wideb;
by subject;
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
tables (arm='ARM'*race='Race'), (eLnCotinine='Exp(Log(cotinine))' eLnCotinineB='Exp(Log(cotinineB))' AvgCigs)* 
	(n='N'*f=4.0 (mean='MEAN' var='VAR')*f=6.3)/rts=15;
format arm arm. race race.;
run;
proc tabulate data=work.LONG;
title3 "All 280 subjects, 140 in each arm (UNC, or RNC) by arm and time";
class arm race time;
var LnCotinine: eLnCotinine: AvgCigs;
tables (arm='ARM'*race='Race'*time='Time'), (eLnCotinine='Exp(Log(cotinine))' eLnCotinineB='Exp(Log(cotinineB))' AvgCigs)* 
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
proc corr data=wide cov outp=covMatrix noprint;
by arm;
var LNCOTININEB1 LNCOTININEB2 LNCOTININEB3 LNCOTININEB4 LNCOTININEB5 LNCOTININEB6 LNCOTININEB7;
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
proc sgpanel data=work.LONG;
title3 "Checking normality of Log(cotinineB) by time and ARM:";
panelby time arm/uniscale=row;**UNISCALE= ROW option specifies that only the shared row axes are identical;
histogram LnCotinineB;
density LnCotinineB;
run;

**model is Log(cotinine)= intercept+ race+ menthol+ arm*(time0 to time6)+ SUBJECT(ARM)+ epsilon;
proc mixed data=work.LONG;
title3 "COTININE= intercept+ arm+ race+ menthol+ arm*(time0 to time6)+ SUBJECT(ARM)+ epsilon";
title4 "with RANDOM SUBJECT(ARM) and epsilon N(0,S2)";
class race menthol arm time;
model LnCotinine=race menthol arm*time/solution;
random subject(arm)/solution;
run;
proc mixed data=work.LONG;
title3 "COTININEB= intercept+ arm+ race+ menthol+ arm*(time0 to time6)+ SUBJECT(ARM)+ epsilon";
title4 "with RANDOM SUBJECT(ARM) and epsilon N(0,S2)";
class race menthol arm time;
model LnCotinineB=race menthol arm*time/solution;
random subject(arm)/solution;
run;

ods pdf close;

/******************************************************************************************
End of \\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\
	rm04_ITP\1-LowSES\code\rm_LowSES.sas
******************************************************************************************/

