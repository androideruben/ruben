proc printto log="S:\OS\StatisticsBranch\TeamT\Montes de Oca\rm001\results\rm001_data.log" new; run;

%put code executed on &sysdate9. at &systime.;
data _null_; call symput('begintime',time()); run;

options source nostimer nocenter pagesize = 60 linesize = 132 noquotelenmax orientation=landscape
mprint mlogic validvarname=v7 ;
ods noproctitle;

/*************************************************
rm001_data.sas
Prepare data for the analysis of the BRFSS survey

Programmer: Ruben Montes de Oca
CTP\OS\Statistics Branch
**************************************************/

%let program_name=rm001_data;

title "rm001: BRFSS Data";
footnote1 "Ruben Montes de Oca\CTP\OS &program_name..sas executed on &sysdate9. at &systime.";

libname brfssH "S:\OS\StatisticsBranch\Data Harmonization\BRFSS\Data";**Harmonized data;
libname rm001 "S:\OS\StatisticsBranch\TeamT\Montes de Oca\rm001\data";

%include "S:\OS\StatisticsBranch\Data Harmonization\BRFSS\programs\formats.sas";


ods listing close;
ods tagsets.ExcelXP path="S:\OS\StatisticsBranch\TeamT\Montes de Oca\rm001\results\"
            		body="&program_name XLSX &sysdate9..xml"
            		style=default;

ods tagsets.excelxp options(sheet_interval='none' 
							embedded_titles='yes' embedded_footnotes='yes'
							orientation='landscape'
							suppress_bylines='no' 
							print_footer='page &amp;p of &amp;n'
							sheet_name='A. Contents');

%macro contents(data);

title2 "Contents &data";

proc contents data=brfssH.&data ;
run;

/*proc freq data=brfssH.&data;
tables iyear:;
run;*/

%mend contents;

*%contents(_all_);
%contents(harmonized_brfss);
%contents(LLCP2011);

%contents(CDBRFS00);

  ods tagsets.excelxp options(sheet_interval='none' 
								embedded_titles='yes' embedded_footnotes='yes'
								orientation='landscape'
								suppress_bylines='no' 
								print_footer='page &amp;p of &amp;n'
								sheet_name='B. Complete listing');
title2 "B. Complete listing";

proc format;
value sex
0='Total'
1='Male'
2='Female';
run;

proc surveyfreq method=taylor missing nomcar page nosummary data=brfssH.CDBRFS00(obs=1000);
title3 "brfssH.CDBRFS00";

strata _ststr; 
cluster _psu; 
weight _finalwt; 

tables sex/cvwt ;
ods output OneWay=work.s00_temp;

format sex sex.;
run;

ods tagsets.ExcelXP close;
ods listing;




ods listing close;
ods pdf file = "S:\OS\StatisticsBranch\TeamT\Montes de Oca\rm001\results\&program_name RTF &sysdate9..pdf";

title2 "C. Clean Analysis";

data work.s00;
set work.s00_temp;
if sex=. then do; sex=0; end;
run;

proc tabulate missing format=comma20.0 data=work.s00;
title3 "brfssH.CDBRFS00";
class sex;
var Frequency WgtFreq StdDev CVWgtFreq Percent StdErr;
tables sex='Sex'*f=sex., sum='' *( (frequency WgtFreq) (Percent StdDev CVWgtFreq  StdErr)*f=comma20.2 );
run;

ods pdf;
ods listing;

***II. Time stamps;
  %macro stamps(folder);
  filename dirlist pipe &folder;
  data dirlist;
    length buffer $256 ; infile dirlist length=reclen;
    input buffer $varying256. reclen; list ;
  run;
  %mend stamps;
  %stamps('dir "S:\OS\StatisticsBranch\Data Harmonization\BRFSS\Data\"');

options nomprint nomlogic;

data _null_; call symput('endtime',time()); run;
data _null_; howlong=((&endtime-&begintime)/60); 
	put "total time processing took >>>> " howlong 6. " minutes";
run;


/**************************************************************************
End of S:\OS\StatisticsBranch\Data Harmonization\BRFSS\code\rm001_data.sas
**************************************************************************/
proc printto log=log; run;