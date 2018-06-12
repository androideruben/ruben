%let program_name=rm_nhanes;

%let permanent=*;

%let permanent=*; 
*%let permanent=; *This row only: put " *%let permanent= " if wanted to keep old permanent data;

/*proc printto log="\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm_EXPLORE\3-NHANES\results\&program_name &sysdate9..log" new; run;*/

	%put code executed on &sysdate9. at &systime.;
	data _null_; call symput('begintime',time()); run;

	options source nostimer nocenter pagesize = 60 linesize = 132 noquotelenmax orientation=landscape
	mprint mlogic validvarname=v7;
	ods noproctitle;

/**************************************************************************************************

Purpose of rm_nhanes.sas:
Explore data related to tobacco from the NHANES:
https://wwwn.cdc.gov/nchs/nhanes/Default.aspx

Programmer: Ruben Montes de Oca, CTP\OS\Statistics Branch
	Date started 09/01/2017. 
	See time stamps &sysdate9 for current date.

ods pdf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm_EXPLORE\3-NHANES\results\&program_name &sysdate9..pdf";
ods pdf close;

***************************************************************************************************/

title "NHANES";
title2;
footnote1 "RM-CTP-OS &program_name..sas executed on &sysdate9. at &systime.";

libname nhanes "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm_EXPLORE\3-NHANES\data\";

*******************************************************************************************
Time stamps of data used
*******************************************************************************************;

  %macro stamps(folder);
  filename dirlist pipe &folder;
  data dirlist;
    length buffer $256 ; infile dirlist length=reclen;
    input buffer $varying256. reclen; list ;
  run;
  %mend stamps;
%stamps('dir "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm_EXPLORE\3-NHANES\data\nhanes\"');

/*
%macro xpt(library, data);

libname xpt xport "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm_EXPLORE\3-NHANES\data\&library\&data..xpt"

access=readonly;

proc copy inlib=xpt outlib=work;
run;

data work.&data;
set work.&data;

*this array groups all the character variables together into one array;
array vars(*) _character_;                                                                                                            
do i=1 to dim(vars); 
                                                                                                                 
*use the UPCASE function to uppercase each value;                                                                                     
vars(i)=upcase(vars(i));                                                                                                            
end;                                                                                                                                  
drop i;    
run;

%mend xpt;

%xpt(nhanes20052006, DEMO_D);
%xpt(nhanes20072008, DEMO_E);
%xpt(nhanes20092010, DEMO_F);
%xpt(nhanes20112012, DEMO_G);
%xpt(nhanes20132014, DEMO_H);
%xpt(nhanes20152016, DEMO_I);

%xpt(nhanes20052006, SMQ_D);
%xpt(nhanes20072008, SMQ_E);
%xpt(nhanes20092010, SMQ_F);
%xpt(nhanes20112012, SMQ_G);
%xpt(nhanes20132014, SMQ_H);
%xpt(nhanes20152016, SMQ_I);
*/

proc format;

value povcat
1='Individuals in families below the poverty line'
2='Individuals in families between 100% and 199% of poverty'
3='Individuals in families at or above 200% of poverty';

value riagendr
1='Male'
2='Female';

value ridreth15cat
1='Mexican American'
2='Other Hispanic'
3='Non-Hispanic White'
4='Non-Hispanic Black'
5='Other Race - Including Multi-Racial';

value smq0203cat 
1='Never smoker'
2='Past smoker'
3='Current smoker';

value yesno
1='Yes'
2='No';

run;

%macro join(datainA, datainB, dataout);

proc sql;
create table work.&dataout as
select a.SEQN, a.riagendr, a.ridageyr, a.ridreth1, a.wtint2yr, a.SDMVPSU, a.SDMVSTRA,
	   b.SEQN, b.smq040, 

		1 as one,
		case smq040 
			when 1 then '1. Smoke daily'
			when 2 then '2. Smoke some days'
			when 3 then '3. Dont smoke'
 				else 'missing'
		end as smq040cat,

		case smq040 
			when 1 or 2 then 1
			when 3 then 2
 				else .
		end as smq040cat2

        from work.&datainA as a
             left join work.&datainB as b
                 on a.SEQN = b.SEQN
order by sdmvstra, sdmvpsu;
quit;

/*
proc crosstab data=work.&dataout design=wr;
nest sdmvstra sdmvpsu/nosortck;
weight wtint2yr; 
class ridreth1 riagendr; 
tables ridreth1*riagendr;
setenv rowspce=2 colspce=1 rowwidth=10 colwidth=11 decwidth=1;
print rowper lowrow uprow nsum wsum /style=nchs;
output rowper lowrow uprow nsum wsum setot/filename=work.freqs_&dataout replace;
run;
*/

proc descript data=work.&dataout design=wr;
nest sdmvstra sdmvpsu/nosortck;
weight wtint2yr; 
class riagendr; 
var ridageyr;
setenv rowspce=2 colspce=1 rowwidth=10 colwidth=15 decwidth=1;
print mean lowmean upmean semean nsum wsum/style=nchs;
output mean lowmean upmean semean nsum wsum/filename=work.means_&dataout replace;
run;

%mend join;

%join(demo_d, smq_d, nhanes05);
%join(demo_e, smq_e, nhanes07);
%join(demo_f, smq_f, nhanes09);
%join(demo_g, smq_g, nhanes11);
%join(demo_h, smq_h, nhanes13);
%join(demo_i, smq_i, nhanes15);

data work.nhanesL;
set work.nhanes05(in=a)
work.nhanes07(in=b)
work.nhanes09(in=c)
work.nhanes11(in=d)
work.nhanes13(in=e)
work.nhanes15(in=f);

if a then year=2005;
if b then year=2007;
if c then year=2009;
if d then year=2011;
if e then year=2013;
if f then year=2015;

run;

proc means mean data=work.nhanesL;
class year;
var ridageyr;
run;
proc means mean data=work.nhanesL;
weight wtint2yr; 
class year;
var ridageyr;
run;
proc means n mean stderr sdev data=work.nhanesL;
weight wtint2yr; 
var ridageyr;
run;
proc freq data=work.nhanesL;
tables ridageyr*smq040cat2;
run;
proc tabulate data=work.nhanesL;
weight wtint2yr; 
class smq040cat2;
var one ridageyr;
tables smq040cat2* one* sum='weighted n'*f=comma15.0/rts=35;
run;
proc means mean p10 q1 median q3 data=work.nhanesL;
weight wtint2yr; 
var ridageyr;
run;

proc descript data=work.nhanesL design=wr;
nest sdmvstra sdmvpsu/nosortck;
weight wtint2yr; 
class year; 
var ridageyr;
setenv rowspce=2 colspce=1 rowwidth=10 colwidth=15 decwidth=1;
print mean lowmean upmean semean nsum wsum/style=nchs;
output mean lowmean upmean semean nsum wsum/filename=work.means_dataout replace;
run;









proc sql;
create table work.nhanes as
select 

a.procnum as procnumA, a.tableno as tablenoA, a.riagendr as riagendrA, a.nsum as nsumA, a.wsum as wsumA,
a.mean as meanA, a.lowmean as lowmeanA, a.upmean as upmeanA, a.semean as semeanA, 1 as oneA,  2011 as yearA,
		case riagendrA 
			when 0 then '0. Total'
			when 1 then '1. Male'
			when 2 then '2. Female'
			else 'missing'
		end as riagendrAA,

b.procnum as procnumB, b.tableno as tablenoB, b.riagendr as riagendrB, b.nsum as nsumB, b.wsum as wsumB,
b.mean as meanB, b.lowmean as lowmeanB, b.upmean as upmeanB, b.semean as semeanB, 1 as oneB,  2013 as yearB,
		case riagendrB 
			when 0 then '0. Total'
			when 1 then '1. Male'
			when 2 then '2. Female'
			else 'missing'
		end as riagendrBB,

c.procnum as procnumC, c.tableno as tablenoC, c.riagendr as riagendrC, c.nsum as nsumC, c.wsum as wsumC,
c.mean as meanC, c.lowmean as lowmeanC, c.upmean as upmeanC, c.semean as semeanC, 1 as oneC, 2015 as yearC,
		case riagendrC 
			when 0 then '0. Total'
			when 1 then '1. Male'
			when 2 then '2. Female'
			else 'missing'
		end as riagendrCC

        from work.means_nhanes11 as a
             left join work.means_nhanes13 as b on a.riagendr=b.riagendr
             left join work.means_nhanes15 as c on a.riagendr=c.riagendr

order by riagendrA;
quit;

data work.nhanes_long11 work.nhanes_long13 work.nhanes_long15;
set nhanes;
if yearA=2011 then output work.nhanes_long11;
if yearB=2013 then output work.nhanes_long13;
if yearC=2015 then output work.nhanes_long15;
run;

data work.report;
set work.nhanes;

ciA="(" || compress(put(lowmeanA, 5.1)) || " , " || compress(put(upmeanA, 5.1)) || ")";
ciB="(" || compress(put(lowmeanB, 5.1)) || " , " || compress(put(upmeanB, 5.1)) || ")";
ciC="(" || compress(put(lowmeanC, 5.1)) || " , " || compress(put(upmeanC, 5.1)) || ")";

label
ciA='95% C.I. 2011'
ciB='95% C.I. 2013'
ciC='95% C.I. 2015'
;
run;
data work.report_long11(rename=(yearA=year nsumA=nsum wsumA=wsum meanA=mean ciA=ci)) 
work.report_long13(rename=(yearB=year nsumB=nsum wsumB=wsum meanB=mean ciB=ci))  
work.report_long15(rename=(yearC=year nsumC=nsum wsumC=wsum meanC=mean ciC=ci));
set work.report;
if yearA=2011 then output work.report_long11;
if yearB=2013 then output work.report_long13;
if yearC=2015 then output work.report_long15;
run;
data work.report_long;
set work.report_long11
work.report_long13
work.report_long15;
run;

ods pdf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm_EXPLORE\3-NHANES\results\&program_name &sysdate9..pdf";

proc print noobs label data=work.report;
var riagendrAA 
nsumA wsumA meanA ciA 
nsumB wsumB meanB ciB 
nsumC wsumC meanC ciC;
format nsum: wsum: comma15.0;
run;

proc print noobs label data=work.report_long;
var riagendrAA 
year nsum wsum mean ci; 
format nsum: wsum: comma15.0;
run;

ods pdf close;

proc timeseries data=work.report_long out=work.ts plots=(series corr decomp) crossplots=all;
where riagendrAA='0. Total';
id year interval=year;
var wsum mean;
*crossvar ridreth1/dif=(1);
label nsum="N" wsum="Weighted N" year='Year';
run;

goptions reset= all noborder nocell 
rotate = portrait htext = 1
 ftext = "arial" hby = 0
 vsize = 8 hsize = 8;
axis1 label = ('axis1') order = (2011 to 2015 by 1) minor = none;
axis2 label = none order = (10000000 to 300000000 by 1000000) minor = none;
symbol color = black value = dot height = 2.5;
proc gplot data=report_long uniform;
*by id;
note justify=right 'ID #byval(ID)';  
plot wsum*year/ nolegend haxis=year vaxis=axis2 noframe;
run; 
quit;

proc boxplot data=nhanes;
   plot riagendr*year=ridreth1;
run;










proc sort data=work.report; by year;
proc timeseries data=work.report
                out=series
                outtrend=trend
                outseason=season print=seasons;
*where ridreth1=1 & riagendr=1;

   id year interval=day accumulate=avg;
   var wsum;
run;
proc sgplot data=trend;
   series x=year y=max  / lineattrs=(pattern=solid);
run;

proc timeseries data=sashelp.air
                out=series
                outtrend=trend
                outseason=season print=seasons;
   id date interval=qtr accumulate=avg;
   var air;
run;
proc sgplot data=trend;
   series x=date y=max  / lineattrs=(pattern=solid);
   series x=date y=mean / lineattrs=(pattern=solid);
   series x=date y=min  / lineattrs=(pattern=solid);
   yaxis display=(nolabel);
   format date year4.;
run;

proc sgplot data=report;
    series x=year y=wsum / group=riagendr;
run;

goptions reset= all noborder nocell 
rotate = portrait htext = 1
 ftext = "arial" hby = 0
 vsize = 8 hsize = 8;
axis1 label = ('axis1') order = (0 to 7 by 1) minor = none;
axis2 label = none order = (10000000 to 300000000 by 1000000) minor = none;
symbol color = black value = dot height = 2.5;
proc gplot data=report uniform;
*by id;
note justify=right 'ID #byval(ID)';  
plot wsum*year/ nolegend haxis=axis1 vaxis=axis2 noframe;
run; 
quit;

proc boxplot data=nhanes;
   plot riagendr*year=ridreth1;
run;

/*
nhanes.tsl.design <- 
	svydesign(
		id = ~SDMVPSU , 
		strata = ~SDMVSTRA ,
		nest = TRUE ,
		weights = ~WTINT2YR ,
		data = x
	)

*/


/******************************************************************************************
End of 
\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\
Montes de Oca\rm04_NHANES\Programs\rm_nhanes.sas
******************************************************************************************/
/*proc printto log=log; run;*/


proc gplot data=report;
where ridreth1 in (1,3) & riagendr=1;
symbol1 i=spline v=circle h=2;
symbol2 i=spline l=5;
plot wsum * year=ridreth1;*/vaxis =(14000000 to 100000000 by 1000000);
run;
quit;

