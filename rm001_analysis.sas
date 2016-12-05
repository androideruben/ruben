proc printto log="S:\OS\StatisticsBranch\TeamT\Montes de Oca\rm001\results\rm001_analysis.log" new; run;

%put code executed on &sysdate9. at &systime.;
data _null_; call symput('begintime',time()); run;

options source nostimer nocenter pagesize = 60 linesize = 132 noquotelenmax orientation=landscape
mprint mlogic validvarname=v7 ;
ods noproctitle;

/**************************************************************************************************
rm001_analysis.sas

Analysis of data created by rm001_data.sas for the analysis of the BRFSS survey

Programmer: Ruben Montes de Oca
CTP\OS\Statistics Branch
***************************************************************************************************/

%let program_name=rm001_analysis;

title "rm001: BRFSS Data";
footnote1 "Ruben Montes de Oca\CTP\OS &program_name..sas executed on &sysdate9. at &systime.";

libname brfssH "S:\OS\StatisticsBranch\Data Harmonization\BRFSS\Data";**Harmonized data;
libname rm001 "S:\OS\StatisticsBranch\TeamT\Montes de Oca\rm001\data";

%include "S:\OS\StatisticsBranch\Data Harmonization\BRFSS\programs\formats.sas";



ods listing close;
ods pdf file = "S:\OS\StatisticsBranch\TeamT\Montes de Oca\rm001\results\&program_name &sysdate9..pdf";

title2 "C. Clean Analysis";

proc tabulate missing format=comma20.0 data=rm001.s00;
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

  %stamps('dir "S:\OS\StatisticsBranch\TeamT\Montes de Oca\rm001\data\"');

options nomprint nomlogic;

data _null_; call symput('endtime',time()); run;
data _null_; howlong=((&endtime-&begintime)/60); 
	put "total time processing took >>>> " howlong 6. " minutes";
run;


/******************************************************************************
End of S:\OS\StatisticsBranch\Data Harmonization\BRFSS\code\rm001_analysis.sas
******************************************************************************/
proc printto log=log; run;