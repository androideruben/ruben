	%let program_name=rm_MR0000059EU;

%let permanent=*; 
*%let permanent=; *This row only: put "*%let permanent=" if wanted to keep old permanent data;

proc printto log="\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name &sysdate9..log" new; run;

	%put code executed on &sysdate9. at &systime.;
	data _null_; call symput('begintime',time()); run;

	options source nostimer nocenter pagesize = 60 linesize = 132 noquotelenmax orientation=landscape
	mprint mlogic validvarname=v7;
	ods noproctitle;

/**************************************************************************************************

Purpose of rm_MR0000059EU.sas:

	FDA Analysis: 
		0. Create data set for mixed models analysis, and BLOQ analysis
		1. Run mixed models for primary, secondary endpoints, risk markers, nicotine, and cotinine
		2. Print clean report
		   (note: lst and log will be available to compare and check all results)

	MRTPA data folders are:
		\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Oniyide\03 REXC03EU\data\ADaM\
		\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Oniyide\03 REXC03EU\data\sdtm\

Programmer: Ruben Montes de Oca, CTP\OS\Statistics Branch
	Date started April 2018. 
	See time stamps &sysdate9 for current date.

Notes: 

ods rtf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name &sysdate9..rtf";
ods rtf close;

***************************************************************************************************/

ods pdf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name lst &sysdate9..pdf";

title1 "MRTPA\iQOS- THS 2.2: ZRHR-REXC-03-EU";
title2;
footnote1 "RM\CTP &program_name..sas executed on &sysdate9. at &systime.";

libname rm_ths "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\data";

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

  %stamps('dir "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Oniyide\03 REXC03EU\data\ADaM\"*.xpt');
  %stamps('dir "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Oniyide\03 REXC03EU\data\sdtm\"*.xpt');

*******************************************************************************************
First: Load all these data sets. They will be used to construct new data sets as needed:
*******************************************************************************************;

	%macro xpt(lib, data);

	libname xptadam xport "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Oniyide\03 REXC03EU\data\&lib\&data..xpt"
	access=readonly;
	proc copy inlib=xptadam outlib=work;
	run;
	
	/*proc contents out=contents_&data data=&data; run;*/

	data &data;
	set &data;

	*this array groups all the character variables together into one array;
  	array vars(*) _character_;                                                                                                            
  	do i=1 to dim(vars); 
                                                                                                                 
	*use the UPCASE function to uppercase each value;                                                                                     
    vars(i)=upcase(vars(i));                                                                                                            
  	end;                                                                                                                                  
  	drop i;    

	/*proc sort nodupkey; by _all_; run;*/
	run;
	%mend xpt;

%xpt(adam, ADBX);
%xpt(adam, ADPC);**NICotine, COTinine;
%xpt(adam, ADPP);**Warning: adam.ADPP does not have 'BASE';
%xpt(adam, ADLB);

%xpt(adam, ADSL);
%xpt(adam, ADQSSU);
%xpt(adam, ADQSND);
%xpt(adam, ADQSPA);
%xpt(adam, ADXT);
%xpt(adam, ADDX);

%xpt(sdtm, QS);*Questionnaire on smoking urges;

data work.adbx;
set work.adbx;
	if aval>0 then logaval=log(AVAL); label logaval='logaval=log(AVAL)';
	if BASE>0 then logbase=log(BASE); label logbase='logbase=log(BASE)'; **Warning: adam.ADPP does not have 'BASE';
run;
data work.adpc;
set work.adpc;
	if aval>0 then logaval=log(AVAL); label logaval='logaval=log(AVAL)';
	if BASE>0 then logbase=log(BASE); label logbase='logbase=log(BASE)'; **Warning: adam.ADPP does not have 'BASE';
run;
data work.adpp;
set work.adpp;
	if aval>0 then logaval=log(AVAL); label logaval='logaval=log(AVAL)';
run;
data work.adlb;
set work.adlb;
	if aval>0 then logaval=log(AVAL); label logaval='logaval=log(AVAL)';
	if BASE>0 then logbase=log(BASE); label logbase='logbase=log(BASE)'; **Warning: adam.ADPP does not have 'BASE';
run;
data work.adxt;
set work.adxt;
	if aval>0 then logaval=log(AVAL); label logaval='logaval=log(AVAL)';
	if BASE>0 then logbase=log(BASE); label logbase='logbase=log(BASE)'; **Warning: adam.ADPP does not have 'BASE';
run;

***********************************************************************************************
End of First: Load all these data sets. They will be used to construct new data sets as needed:
***********************************************************************************************;

*******************************************************************************************
0. Create data set for mixed models analysis, and BLOQ analysis.
*******************************************************************************************;

title3 "FDA Analysis: Mixed models for primary and secondary endpoints";

**data for mixed models;
data work.rm_03EUA;
set work.adbx;
if paramcd in ('UMHBMCRE','U3HPMCRE','USPMACRE') & avisit='DAY 5' & fasfl='Y' & anl02fl='Y'
	or paramcd in ('CARBXHGB') & avisit='DAY 5' & atpt='08:00-10:00 PM' & fasfl='Y' & anl02fl='Y'

	or paramcd in ('CO') & avisit='DAY 5' & atpt='08:00-10:00 PM' & fasfl='Y' & anl02fl='Y'
	or paramcd in ('U1OHPCRE','UNNNCRE','U4ABPCRE','U1NACRE','U2NACRE','UOTOLCRE','UCEMACRE',
					'UHEMACRE','UBAPCRE','UHMPMCRE','USBMACRE','UNNALCRE','UNEQCRE'
					'UPGF2CRE', 'UTXB2CRE') 
					& avisit='DAY 5' & fasfl='Y' & anl02fl='Y';
run;
data work.rm_03EUB;
set work.adpc;
if paramcd in ('NIC', 'COT') & fasfl='Y' & anl02fl='Y';
run;
data work.rm_03EUC;
set work.adpp;**adam.ADPP does not have 'BASE';
run;

**Put some order:;
proc format;
value myorder
1= 'UMHBMCRE'  
2= 'U3HPMCRE' 
3= 'USPMACRE' 
4= 'CARBXHGB' 

5= 'CO' 		
6= 'U1OHPCRE' 
7= 'UNNNCRE' 	
8= 'U4ABPCRE' 

9= 'U1NACRE' 	
10='U2NACRE' 	
11='UOTOLCRE' 
12='UCEMACRE' 

13='UHEMACRE' 
14='UBAPCRE' 	
15='UHMPMCRE' 
16='USBMACRE' 

17='UNNALCRE' 
18='UNEQCRE' 	
19='8-EPI-PGF2 ALPHA'
20='11-DTX-B2'

21='NIC' 		
22='COT';
run; 		
data work.rm_03EU;
set work.rm_03EUA(drop=DTYPE) work.rm_03EUB(drop=DTYPE) work.rm_03EUC;

**Put some order:;
if paramcd='UMHBMCRE' 			then myorder=1;
if paramcd='U3HPMCRE' 			then myorder=2; 
if paramcd='USPMACRE' 			then myorder=3; 
if paramcd='CARBXHGB' 			then myorder=4; 

if paramcd='CO' 				then myorder=5; 
if paramcd='U1OHPCRE' 			then myorder=6; 
if paramcd='UNNNCRE' 			then myorder=7; 	
if paramcd='U4ABPCRE' 			then myorder=8; 

if paramcd='U1NACRE' 			then myorder=9; 	
if paramcd='U2NACRE' 			then myorder=10; 	
if paramcd='UOTOLCRE' 			then myorder=11; 
if paramcd='UCEMACRE' 			then myorder=12; 

if paramcd='UHEMACRE' 			then myorder=13; 
if paramcd='UBAPCRE' 			then myorder=14; 	
if paramcd='UHMPMCRE' 			then myorder=15; 
if paramcd='USBMACRE' 			then myorder=16; 

if paramcd='UNNALCRE' 			then myorder=17; 
if paramcd='UNEQCRE' 			then myorder=18; 	
if paramcd='UPGF2CRE' 			then myorder=19; 
if paramcd='UTXB2CRE' 			then myorder=20; 

if paramcd='NIC' 				then myorder=21; 
if paramcd='COT' 				then myorder=22; 

**BLOQFL is the below limit of detection flag. it has two values: 'Y' which is BLOQ, and ''. We will make ''='N':;
if BLOQFL='' then do; BLOQFL='N'; end;
run;
proc freq; 
title4 '0. Check there are 22 correct BoExp'; 
where myorder ne .; 
tables myorder* paramcd*param/list missing nopercent nocum; 
format param $54.;
run;
*******************************************************************************************
End of 
0. Create data set for mixed models analysis, and BLOQ analysis
*******************************************************************************************;

*******************************************************************************************
1. Run mixed models for primary, secondary endpoints, risk markers, nicotine, and cotinine
*******************************************************************************************;

**Primary BoExp are 4 that compare reduction THS 2.2 to CC.compare pro
We report reduction and reduction C.I.:;
%macro mixedADBX(BoExp, title5);*primary;

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.rm_03EU;
	where paramcd="&BoExp";
	class trta sexc ucpdgr1;
	model logaval=logbase trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
	run;

data lsmeans_&BoExp;
format note $130.;
set lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';
reduction=100-round(exp(estimate)*100, 0.01); label reduction='reduction=exp(estimate)';
LB=100-round(exp(lower)*100, 0.01); label LB='LB=exp(lower)';
UB=100-round(exp(upper)*100, 0.01); label UB='UB=exp(upper)';
run;

%mend mixedADBX;
*value myorder
1= 'UMHBMCRE'  
2= 'U3HPMCRE' 
3= 'USPMACRE' 
4= 'CARBXHGB' 
;
%mixedADBX(UMHBMCRE, "MHBMA(Primary, shown Reduction C.I.): Tables 30, 37 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(U3HPMCRE, "3-HPMA(Primary, shown Reduction C.I.): Tables 33, 37 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(USPMACRE, "S-PMA(Primary, shown Reduction C.I.): Tables 36, 37 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(CARBXHGB, "COHb(Primary, shown Reduction C.I.): Tables 27, 37 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");

**Secondary BoExp. 
We report ratio and ratio C.I.:;
%macro mixedADBX(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.rm_03EU;
	where paramcd="&BoExp";
	class trta sexc ucpdgr1;
	model logaval=logbase trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
	run;

data lsmeans_&BoExp;
format note $130.;
set lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';
reduction=100-round(exp(estimate)*100, 0.01); label reduction='reduction=exp(estimate)';
LB=round(exp(upper)*100, 0.01); label LB='LB=exp(upper)';
UB=round(exp(lower)*100, 0.01); label UB='UB=exp(lower)';
run;

%mend mixedADBX;
*value myorder
5= 'CO' 		
6= 'U1OHPCRE' 
7= 'UNNNCRE' 	
8= 'U4ABPCRE' 
;
%mixedADBX(CO, "Carbon Monoxide(Shown Ratio C.I.): Table 47 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(U1OHPCRE, "Total 1-OHP(Shown Ratio C.I.): Table 48 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(UNNNCRE, "Total NNN(Shown Ratio C.I.): Table 49 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");	
%mixedADBX(U4ABPCRE, "4-ABP(Shown Ratio C.I.): Table 50 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");	

*
value myorder
9= 'U1NACRE' 	
10='U2NACRE' 	
11='UOTOLCRE' 
12='UCEMACRE' 
;
%mixedADBX(U1NACRE, "1-NA(Shown Ratio C.I.): Table 51 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");	
%mixedADBX(U2NACRE, "2-NA(Shown Ratio C.I.): Table 52 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(UOTOLCRE, "O-tol(Shown Ratio C.I.): Table 53 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(UCEMACRE, "CEMA(Shown Ratio C.I.): Tables 54 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");

*
value myorder
13='UHEMACRE' 
14='UBAPCRE' 	
15='UHMPMCRE' 
16='USBMACRE' 

17='UNNALCRE' 
18='UNEQCRE' 	
;
%mixedADBX(UHEMACRE, "HEMA(Shown Ratio C.I.): Tables 55 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(UBAPCRE, "B[a]P(Shown Ratio C.I.): Tables 56 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(UHMPMCRE, "3-HPMA(Shown Ratio C.I.): Table 57 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");	
%mixedADBX(USBMACRE, "S-BMA(Shown Ratio C.I.): Table 58 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");

%mixedADBX(UNNALCRE, "Total NNAL(Shown Ratio C.I.): Table 59 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");
%mixedADBX(UNEQCRE, "NEQ(Shown Ratio C.I.): Table 60 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");

*
value myorder
19='8-EPI-PGF2 ALPHA'
20='11-DTX-B2'
;
**Risk markers:;
%macro mixedADBX2(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.adbx;
where paramcd="&BoExp" & fasfl='Y' & anl02fl='Y' & avisit="DAY 5";

	class trta sexc ucpdgr1;
	model logaval=logbase trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
	run;

data lsmeans_&BoExp;
format note $130.;
set lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';
reduction=100-round(exp(estimate)*100, 0.01); label reduction='reduction=exp(estimate)';
LB=round(exp(upper)*100, 0.01); label LB='LB=exp(upper)';
UB=round(exp(lower)*100, 0.01); label UB='UB=exp(lower)';
run;

%mend mixedADBX2;
**See also Listing Listing 15.4.4.53 in csr-v2-app-15_4-stat-output.pdf; 
%mixedADBX2(UPGF2CRE, "UPGF2CRE (8-epi-PGF2 Alpha)(Shown Ratio C.I.): Table 72 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");

/*%macro mixedADBX2(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.adbx;
where paramcd="&BoExp" & fasfl='Y' & anl02fl='Y' & avisit="DAY 5";

	class trta sexc ucpdgr1;
	model logaval=logbase trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
	run;

data lsmeans_&BoExp;
format note $130.;
set lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';
reduction=100-round(exp(estimate)*100, 0.01); label reduction='reduction=exp(estimate)';
LB=round(exp(upper)*100, 0.01); label LB='LB=exp(upper)';
UB=round(exp(lower)*100, 0.01); label UB='UB=exp(lower)';
run;

%mend mixedADBX2;
*/
**See also Listing Listing 15.4.4.55 in csr-v2-app-15_4-stat-output.pdf; 
%mixedADBX2(UTXB2CRE, "(11-DTX-B2)(Shown Ratio C.I.): Table 73 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf");

*
value myorder
21='NIC' 		
22='COT'
;
**Nicotine and Cotinine use chg=aval-base;
%macro mixedADPC(BoExp, title5);

title4 "&BoExp";
title5 &title5;

*A. This replicates table 61, 64 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf:;
	ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.rm_03EU;
	where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & trta in ('THS 2.2','CC');
	class trta sexc ucpdgr1;
	model chg=base trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	*lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
	run;

data lsmeans_&BoExp;
format note $130.;
set lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(estimate, 0.01); label LSMRatio='LS Mean';*Not ratio for NIC, just LSMeans;
reduction=.; label reduction='reduction=estimate';**In this case, reduction is not reported;
UB=round(lower, 0.01); label UB='UB=upper';**reverse labels because at the end 'reduction' is reported for all except these;
LB=round(upper, 0.01); label LB='LB=lower';
run;
%mend mixedADPC;
**See also Listing 15.4.4.41 in csr-v2-app-15_4-stat-output.pdf;
%mixedADPC(NIC, "Nicotine(Shown LSMean Differences): Table 61 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf, analyses of 'chg' and report of THS-CC instead of Ratios, SA not reported");*need to report LS MEans, not ratios!;
%mixedADPC(COT, "Cotinine(Shown LSMean Differences): Table 64 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf, analyses of 'chg' and report of THS-CC instead of Ratios, SA not reported");*need to report LS MEans, not ratios!;

%macro mixedADPC(BoExp, title5);

title4 "&BoExp";
title5 &title5;

*B. This analyzes THS 2.2 vs. SA, not reported in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf:;
	ods output Diffs=lsmeansB_&BoExp;
	proc mixed data=work.rm_03EU;
	where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & trta in ('THS 2.2','SA');
	class trta sexc ucpdgr1;
	model chg=base trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
	run;

data lsmeansB_&BoExp;
format note $130.;
set lsmeansB_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(estimate, 0.01); label LSMRatio='LS Mean';*Not ratio for NIC, just LSMeans;
reduction=.; label reduction='reduction=estimate';**In this case, reduction is not reported;
UB=round(lower, 0.01); label UB='UB=upper';**reverse labels because at the end 'reduction' is reported for all except these;
LB=round(upper, 0.01); label LB='LB=lower';
run;
%mend mixedADPC;
%mixedADPC(NIC, "Nicotine(Shown LSMean Differences): Table 61 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf, analyses of 'chg' and report of THS-CC instead of Ratios, SA not reported");
%mixedADPC(COT, "Cotinine(Shown LSMean Differences): Table 64 in ZRHR-REXC-03-EU_CSR_FINAL_v2.0_08March2016.pdf, analyses of 'chg' and report of THS-CC instead of Ratios, SA not reported");

title4;
title5;
*******************************************************************************************
End of 
1. Run mixed models for primary, secondary endpoints, risk markers, nicotine, and cotinine
*******************************************************************************************;

*******************************************************************************************
End of 1. Mixed models for primary, secondary endpoints, risk markers, nicotine, and cotinine
*******************************************************************************************;

*******************************************************************************************
2. Print clean report
(note: lst and log will be available to compare and check all results)
*******************************************************************************************;
title3; title4; title5;

**prepare data for report;
data work.partI0;
format BoExpTxt $28. note $154.;
set 
LSMEANS_UMHBMCRE
LSMEANS_U3HPMCRE
LSMEANS_USPMACRE
LSMEANS_CARBXHGB

LSMEANS_CO
LSMEANS_U1OHPCRE
LSMEANS_UNNNCRE
LSMEANS_U4ABPCRE
LSMEANS_U1NACRE
LSMEANS_U2NACRE
LSMEANS_UOTOLCRE
LSMEANS_UCEMACRE
LSMEANS_UHEMACRE
LSMEANS_UBAPCRE
LSMEANS_UHMPMCRE
LSMEANS_USBMACRE
LSMEANS_UNNALCRE
LSMEANS_UNEQCRE

LSMEANS_UPGF2CRE
LSMEANS_UTXB2CRE

LSMEANS_NIC
LSMEANS_COT
;

*for reduction, the UB is the LB and vice versa:;
CI='(' || left(compress(put(UB,8.2))) || ',' || left(compress(put(LB,8.2))) ||')';

if BoExp='UMHBMCRE' then BoExpTxt='MHBMA (pg/mg creat)';
if BoExp='U3HPMCRE' then BoExpTxt='3-HPMA (ng/mg creat)';
if BoExp='USPMACRE' then BoExpTxt='S-PMA (pg/mg creat)';
if BoExp='CARBXHGB' then BoExpTxt='COHb (%)';

if BoExp='CO' 		then BoExpTxt='Carbon monoxide';
if BoExp='U1OHPCRE' then BoExpTxt='Total 1-OHP (pg/mg creat)';
if BoExp='UNNNCRE' 	then BoExpTxt='Total NNN (pg/mg creat)';
if BoExp='U4ABPCRE' then BoExpTxt='4-ABP (pg/mg creat)';
if BoExp='U1NACRE' 	then BoExpTxt='1-NA (pg/mg creat)';
if BoExp='U2NACRE' 	then BoExpTxt='2-NA (pg/mg creat)';
if BoExp='UOTOLCRE' then BoExpTxt='O-tol (pg/mg creat)';
if BoExp='UCEMACRE' then BoExpTxt='CEMA (ng/mg creat)';
if BoExp='UHEMACRE' then BoExpTxt='HEMA(pg/mg creat)';
if BoExp='UBAPCRE' 	then BoExpTxt='B[a]P (fg/mg creat)';
if BoExp='UHMPMCRE' then BoExpTxt='3-HPMA (ng/mg creat)';
if BoExp='USBMACRE' then BoExpTxt='S-BMA (pg/mg creat)';
if BoExp='UNNALCRE' then BoExpTxt='Total NNAL(pg/mg creat)';
if BoExp='UNEQCRE' 	then BoExpTxt='NEQ (mg/g creat)';

if BoExp='UPGF2CRE'	then BoExpTxt='8-epi-PGF2 Alpha (pg/mg creat)';
if BoExp='UTXB2CRE'	then BoExpTxt='11-DTX-B2 (pg/mg creat)';

if BoExp='NIC' 		then BoExpTxt='Nicotine (chg) (ng/ml)';
if BoExp='COT' 		then BoExpTxt='Cotinine (chg) (ng/ml)';

run;
data work.partIA work.partIB;
set work.partI0;
if trta='THS 2.2' and _trta='CC' then output partIA;
if trta='THS 2.2' and _trta='SA' then output partIB;
run;

**This data set will be printed as the ods rtf file;
data partI;
merge 
partIA(rename=(BoExp=BoExpCC BoExpTxt=BoExpTxtCC reduction=reductionCC CI=CICC probt=probtCC LSMRatio=LSMRatioCC)) 
partIB(rename=(BoExp=BoExpSA BoExpTxt=BoExpTxtCC reduction=reductionSA CI=CISA probt=probtSA LSMRatio=LSMRatioSA));

label BoExpCC='BoExp' 
reductionCC='Reduction THS 2.2/ CC in %' CICC='95% C.I. for reduction THS 2.2/ CC' probtCC='p-value reduction THS 2.2/ CC' LSMRatioCC='LSM Ratio THS/CC'
reductionSA='Reduction THS 2.2/ SA in %' CISA='95% C.I. for reduction THS 2.2/ SA' probtSA='p-value reduction THS 2.2/ SA' LSMRatioSA='LSM Ratio THS/SA';

run;
proc freq data=work.partI; 
title4 "Check that columns 'BoExpCC', 'BoExpSA' match then, merge was fine"; 
tables BoExpCC*BoExpSA/list; 
run;

proc compare base=rm_THS.partIEU compare=work.partI;
title4 "0. Control changes by comparing old vs. new data sets";
run;

*Create permanent data:;
&permanent data rm_THS.partIEU;
&permanent set work.partI;
&permanent run;

ods rtf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name report &sysdate9..rtf";
proc print noobs label data=work.partI;
title5 "Report: Primary and Secondary BoExp ZRHR-REXC-03-EU";
where trta='THS 2.2' & (_trta='CC' or _trta='SA');
var BoExpTxtCC LSMRatioCC reductionCC CICC LSMRatioSA reductionSA CISA note;

label
BoExpTxtCC='BoExp'

LSMRatioCC='THS/CC or THS-CC (see note)'
reductionCC='% Reduction THS/CC (see note)'
CICC='95% CI (see note)'

LSMRatioSA='THS/SA or THS-SA (see note)'
reductionSA='% Reduction THS/SA (see note)'
CISA='95% CI (THS/SA or THS-SA) (see note)';

format 
trta _trta $10. note $130.;
run;

**Sticks or plugs consumption Day 1 to Day 5:;
proc tabulate data=work.addx;
title4 "Sticks or plugs consumption Day 1 to Day 5";

**avalu='STICKS/DAY' is the sum of sticks per subject per day;
where trta='THS 2.2' & paramcd='DTHS2_2' & avalu='STICKS/DAY' & avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5');
class trta paramcd avisit ucpdgr1;
var aval;

tables (trta='Arm'),
	aval=''*(n='N'*f=10.0 mean='Mean'*f=10.1 LCLM='LCLM' UCLM='UCLM')/rts= 35;


tables (trta='Arm'*avisit='Day'),
	aval=''*(n='N'*f=10.0 mean='Mean'*f=10.1 LCLM='LCLM' UCLM='UCLM')/rts= 35;

tables (trta='Arm'*ucpdgr1),
	aval=''*(n='N'*f=10.0 mean='Mean'*f=10.1 LCLM='LCLM' UCLM='UCLM')/rts= 35;

tables (trta='Arm'*avisit='Day'*ucpdgr1),
	aval=''*(n='N'*f=10.0 mean='Mean'*f=10.1 LCLM='LCLM' UCLM='UCLM')/rts= 35;

run;

proc tabulate data=work.rm_03EU;
title4 "Percent of values BLOQ, all arms, at DAY 5";
where avisit in ('DAY 5') & paramcd in ('UMHBMCRE','U3HPMCRE','USPMACRE','CARBXHGB',
										'CO','U1OHPCRE','UNNNCRE','U4ABPCRE',
										'U1NACRE','U2NACRE','UOTOLCRE','UCEMACRE',
										'UHEMACRE','UBAPCRE','UHMPMCRE','USBMACRE',
										'UNNALCRE','UNEQCRE',
										'UPGF2CRE','UTXB2CRE'
										'NIC', 'COT');
class myorder paramcd param bloqfl;

tables myorder='BoExp'*param, bloqfl * (N='Subjects'*f=10.0 rowpctn='Row %'*f=10.2) all='Total Subjects'*f=10.0
/misstext='0' rts=40;
format myorder myorder.;
run;

ods rtf close;

/*******************************************************************************************
End of
2. Print clean report
(note: lst and log will be available to compare and check all results)
*******************************************************************************************/

proc printto log=log; run;

ods pdf close;

/*******************************************************************************************
End of \\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\
Montes de Oca\Programs\rm_MR0000059EU.sas
*******************************************************************************************/

