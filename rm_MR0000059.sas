%let program_name=rm_MR0000059;

%let permanent=*;

%let permanent=*; 
*%let permanent=; *This row only: put "*%let permanent=" if wanted to keep old permanent data;

proc printto log="\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name &sysdate9..log" new; run;

	%put code executed on &sysdate9. at &systime.;
	data _null_; call symput('begintime',time()); run;

	options source nostimer nocenter pagesize = 60 linesize = 132 noquotelenmax orientation=landscape
	mprint mlogic validvarname=v7;
	ods noproctitle;

/**************************************************************************************************

Purpose of rm_MR0000059.sas:

	FDA Analysis: 
		0. Create data set for mixed models analysis, and BLOQ analysis

		1. Run mixed models for primary, secondary endpoints, risk markers, nicotine, and cotinine
		2. Print clean report
		   (note: lst and log will be available to compare and check all results)
		
		3. Additional analysis
		3.1. Means, mixed and frequencies for exploratory
		3.2. Other clinical results
		3.2. Sample size and power

	MRTPA data folders are:
		\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\data\ADaM\
		\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\data\sdtm\

Programmer: Ruben Montes de Oca, CTP\OS\Statistics Branch
	Date started 3/28/2017. 
	See time stamps &sysdate9 for current date.

Notes: 

QSU-brief:
take the sum per subject for answers QSUFACT1 for DAY 1. 
aval is average of scores with the denominator the number of questions answered (0 to 10), 
chg is the difference chg=aval-base=average-base. Repeat for each of DAY.

Minnesota Nicotine Withdrawal Scale (MNWS)
Subjects will be asked to rate the items for the previous 24-hours on a scale ranging from 0 to
4 (where 0 = none, 1 = slight, 2 = mild, 3 = moderate, 4 = severe) Day 0 to Day 6.
The total scores will be derived by summing the individual item scores if all items are
non-missing, otherwise the total score will be set to missing. The first total score
calculated by summing the first 9 items is based on validated items, the second score is
based on 6 extra items which are thought to have an impact on withdrawal but have not
been validated.

Human Smoking Topography Questionnaire
A specific questionnaire, used for exploratory purposes, has been developed by PMI to
evaluate the impact of the utilization of the HST SODIM® device on smoker’s
smoking/inhalation experience in terms of ritual disruption.
This is a questionnaire with 5 items to be rated on a 5-point scale and open questions.

ods rtf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name &sysdate9..rtf";
ods rtf close;

***************************************************************************************************/

ods pdf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name lst &sysdate9..pdf";

title1 "MRTPA\iQOS- THS 2.2: ZRHR-REXC-04-JP";
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

  %stamps('dir "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\data\ADaM\"*.xpt');
  %stamps('dir "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\data\sdtm\"*.xpt');

*******************************************************************************************
First: Load all these data sets. They will be used to construct new data sets as needed:
*******************************************************************************************;

	%macro xpt(lib, data);

	libname xptadam xport "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\data\&lib\&data..xpt"
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
data work.rm_04JPA;
set work.adbx;
if paramcd in ('UMHBMCRE','U3HPMCRE','USPMACRE') & avisit='DAY 5' & fasfl='Y' & anl02fl='Y'
	or paramcd in ('CARBXHGB') & avisit='DAY 5' & atpt='08:00-09:30 PM' & fasfl='Y' & anl02fl='Y'

	or paramcd in ('CO') & avisit='DAY 5' & atpt='08:00-09:30 PM' & fasfl='Y' & anl02fl='Y'
	or paramcd in ('U1OHPCRE','UNNNCRE','U4ABPCRE','U1NACRE','U2NACRE','UOTOLCRE','UCEMACRE',
					'UHEMACRE','UBAPCRE','UHMPMCRE','USBMACRE','UNNALCRE','UNEQCRE'
					'UPGF2CRE', 'UTXB2CRE') 
					& avisit='DAY 5' & fasfl='Y' & anl02fl='Y';
run;
data work.rm_04JPB;
set work.adpc;
if paramcd in ('NIC', 'COT') & fasfl='Y' & anl02fl='Y' & '19:00't < atm< '21:00't;
run;
data work.rm_04JPC;
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

data work.rm_04JP;**Max and Avg for nicotine, cotinine:;
set work.rm_04JPA(drop=DTYPE) work.rm_04JPB(drop=DTYPE) work.rm_04JPC;

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

**Primary BoExp are 4 that compare reduction THS 2.2 to CC.
We report reduction and reduction C.I.:;
%macro mixedADBX(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.rm_04JP;
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
%mixedADBX(UMHBMCRE, "MHBMA(Primary, shown Reduction C.I.): Tables 27, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(U3HPMCRE, "3-HPMA(Primary, shown Reduction C.I.): Tables 30, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(USPMACRE, "S-PMA(Primary, shown Reduction C.I.): Tables 33, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(CARBXHGB, "COHb(Primary, shown Reduction C.I.): Tables 24, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

**Secondary BoExp. 
We report ratio and ratio C.I.:;
%macro mixedADBX(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.rm_04JP;
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
%mixedADBX(CO, "Carbon Monoxide(Shown Ratio C.I.): Table 44 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(U1OHPCRE, "Total 1-OHP(Shown Ratio C.I.): Table 45 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UNNNCRE, "Total NNN(Shown Ratio C.I.): Table 46 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%mixedADBX(U4ABPCRE, "4-ABP(Shown Ratio C.I.): Table 47 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	

*
value myorder
9= 'U1NACRE' 	
10='U2NACRE' 	
11='UOTOLCRE' 
12='UCEMACRE' 
;
%mixedADBX(U1NACRE, "1-NA(Shown Ratio C.I.): Table 48 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%mixedADBX(U2NACRE, "2-NA(Shown Ratio C.I.): Table 49 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UOTOLCRE, "O-tol(Shown Ratio C.I.): Table 50 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UCEMACRE, "CEMA(Shown Ratio C.I.): Tables 51 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

*
value myorder
13='UHEMACRE' 
14='UBAPCRE' 	
15='UHMPMCRE' 
16='USBMACRE' 

17='UNNALCRE' 
18='UNEQCRE' 	
;
%mixedADBX(UHEMACRE, "HEMA(Shown Ratio C.I.): Tables 52 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UBAPCRE, "B[a]P(Shown Ratio C.I.): Table 1 in ZRHR-REXC-04-JP_CSR_addendum v1.0.pdf");
%mixedADBX(UHMPMCRE, "3-HPMA(Shown Ratio C.I.): Table 53 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%mixedADBX(USBMACRE, "S-BMA(Shown Ratio C.I.): Table 54 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

%mixedADBX(UNNALCRE, "Total NNAL(Shown Ratio C.I.): Table 55 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UNEQCRE, "NEQ(Shown Ratio C.I.): Table 56 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

***Risk markers:
value myorder
19='8-EPI-PGF2 ALPHA'
20='11-DTX-B2'
;
*• Selected risk markers (expressed as quantity excreted and concentration adjusted for creatinine):
8-epi-prostaglandine F2a (8-epi-PGF2a) and 11-dehydrothromboxane B2 (DTX-B2) measured in
24-hour urine on Day 5:;
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
**See also Table 15.2.4.45 in Clinical Study Report Appendix 15.2 - Tables.pdf; 
%mixedADBX2(UPGF2CRE, "UPGF2CRE (8-epi-PGF2 Alpha)(Shown Ratio C.I.): Table 68 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX2(UTXB2CRE, "UTXB2CRE (11-DTX-B2)(Shown Ratio C.I.): Table 69 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

*
value myorder
21='NIC' 		
22='COT';
%macro mixedADPC(BoExp, title5);

title4 "&BoExp";
title5 &title5;

*A. This replicates table 57, 60 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf:;
	ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.rm_04JP;
	where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & '19:00't < atm< '21:00't & trta in ('THS 2.2','CC');
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
%mixedADPC(NIC, "Nicotine(Shown LSMean Differences): Table 57 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, analyses of 'chg' and report of THS-CC instead of Ratios, SA not reported");
%mixedADPC(COT, "Cotinine(Shown LSMean Differences): Table 60 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, analyses of 'chg' and report of THS-CC instead of Ratios, SA not reported");

%macro mixedADPC(BoExp, title5);

title4 "&BoExp";
title5 &title5;

*B. This analyzes THS 2.2 vs. SA, not reported in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf:;
	ods output Diffs=lsmeansB_&BoExp;
	proc mixed data=work.rm_04JP;
	where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & '19:00't < atm< '21:00't & trta in ('THS 2.2','SA');
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
%mixedADPC(NIC, "Nicotine(Shown LSMean Differences): Table 57 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, analyses of 'chg' and report of THS-CC instead of Ratios, SA not reported");
%mixedADPC(COT, "Cotinine(Shown LSMean Differences): Table 60 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, analyses of 'chg' and report of THS-CC instead of Ratios, SA not reported");

*******************************************************************************************
End of 
1. Run mixed models for primary, secondary endpoints, risk markers, nicotine, and cotinine
*******************************************************************************************;

title4;
title5;

*******************************************************************************************
2. Print clean report
(note: lst and log will be available to compare and check all results)
*******************************************************************************************;

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

data partI;
merge 
partIA(rename=(BoExp=BoExpCC BoExpTxt=BoExpTxtCC reduction=reductionCC CI=CICC probt=probtCC LSMRatio=LSMRatioCC)) 
partIB(rename=(BoExp=BoExpSA BoExpTxt=BoExpTxtCC reduction=reductionSA CI=CISA probt=probtSA LSMRatio=LSMRatioSA));

label BoExpCC='BoExp' 
reductionCC='Reduction THS 2.2/ CC in %' CICC='95% C.I. for reduction THS 2.2/ CC' probtCC='p-value reduction THS 2.2/ CC' LSMRatioCC='LSM Ratio THS/CC'
reductionSA='Reduction THS 2.2/ SA in %' CISA='95% C.I. for reduction THS 2.2/ SA' probtSA='p-value reduction THS 2.2/ SA' LSMRatioSA='LSM Ratio THS/SA';

run;
proc freq data=work.partI; 
title4 "0. Check that columns 'BoExpCC', 'BoExpSA' match then, merge was fine"; 
tables BoExpCC*BoExpSA/list; 
run;

proc compare base=rm_THS.partI compare=work.partI;
title4 "Control changes by comparing old vs. new data sets";
run;

&permanent data rm_THS.partI;
&permanent set work.partI;
&permanent run;

proc datasets lib=work nolist; 
**delete data sets that may have common name in the following parts of this program;
  delete lsmeans:; 
quit; 
run;
title3; title4; title5;

ods rtf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name report &sysdate9..rtf";
proc print noobs label data=work.partI;
title5 "Report: Primary and Secondary BoExp ZRHR-REXC-04-JP";
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
title4;

proc tabulate data=work.rm_04JP;
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


/*******************************************************************************************
3. Additional analysis
*******************************************************************************************/

*******************************************************************************************
	3.1. Means, mixed and frequencies for exploratory
*******************************************************************************************;
**Exploratory (page 4 of ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf):

Exploratory Objectives and Endpoints:
The exploratory objectives and endpoints of this study were:
1. To describe the following parameters in smokers switching from CC to THS 2.2 as compared to
smokers continuing to smoke CC and smokers switching from CC to SA.
Endpoints:
• Excretion of mutagenic material in urine: Ames Mutagenicity test (YG1024+S9) on Day 5 in
24-hour urine.
• Questionnaire of Smoking Urges (brief version) total score, Factor 1 (relief) and Factor 2 (reward).
• Minnesota Nicotine Withdrawal Scale (MNWS) total score, revised version on Day 5.
• Cytochrome P450 2A6 (CYP2A6) enzymatic activity: in plasma on Day 6, using the molar
metabolic ratio of trans-3’-hydroxycotinine/cotinine.
• Selected risk markers (expressed as quantity excreted and concentration adjusted for creatinine):
8-epi-prostaglandine F2a (8-epi-PGF2a) and 11-dehydrothromboxane B2 (DTX-B2) measured in
24-hour urine on Day 5.

2. To evaluate in smokers switching from CC to THS 2.2, smokers continuing to smoke CC and smokers
switching from CC to SA the relationship between:
Endpoints:
• NEQ and primary and secondary BoExp in 24-hour urine on Day 5.
• Primary, secondary BoExp, NEQ, and risk markers (8-epi-PGF2a and 11-DTX-B2) measured in
24-hour urine on Day 5.

3. To describe the following parameters over the course of the study in smokers switching from CC to
THS 2.2 as compared to smokers continuing to smoke CC:
Endpoints:
• Product evaluation: Modified Cigarette Evaluation Questionnaire (MCEQ):
-Smoking Satisfaction subscale.
-Enjoyment of Respiratory Tract Sensation subscale.
-Psychological Reward subscale.
-Aversion subscale.
-Craving Reduction subscale.

• Smoking pattern: human smoking topography (HST) parameters and HST questionnaire.
-HST parameters (Table 14 and Table 15).
-HST questionnaire.

4. To describe the following parameter over the course of the study in smokers switching from CC to
THS 2.2:
Endpoint:
• Potential combustion occurrences in tobacco plugs: visual inspection of the tobacco plugs.

Also, we present statistics of stick or plugs per day
;

**Solution of 1. To describe the following parameters...;
*• Excretion of mutagenic material in urine: Ames Mutagenicity test (YG1024+S9) on Day 5 in 24-hour urine:;
%macro ExploreADBX(BoExp, title5);

title4 "&BoExp";
title5 &title5;

proc means n mean median min max clm data=work.adbx maxdec=3;
where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y';
class trta avisit;
var aval base;
output out=means_&BoExp
n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_ lclm=lclm_ uclm=uclm_;
run;

data means_&BoExp(drop=n_ mean_ median_ std_ min_ max_ lclm_ uclm_);
format note $130.;
set means_&BoExp;
if trta ne '' & avisit ne '';
n=n_;
mean=round(mean_, 0.01);   
median=round(median_, 0.01);        
std=round(std_, 0.01);   
min=round(min_, 0.01);   
max=round(max_, 0.01);   
lclm=round(lclm_, 0.01);   
uclm=round(uclm_, 0.01);   
note=&title5;
run;
%mend ExploreADBX;
%ExploreADBX(UAMES24U, "Ames Mutagenecity Test (YG1024): Tables 65 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");**similar results, not identical;

*• Questionnaire of Smoking Urges (brief version) total score, Factor 1 (relief) and Factor 2 (reward):;

*https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3432274/:

The QSU-Brief was developed in order to provide a quick, reliable, and valid measure of craving 
to be used in both laboratory and clinical settings. Evaluation indicates that a two-factor 
structure emerges from the QSU and QSU-Brief- one factor captures craving associated with the 
positive reinforcement of smoking, while the second factor reflects anticipation of the negative 
reinforcement of smoking

Clinical Study Report Appendix 16.1.8 - Documentation on Stat Methods.pdf:
7.3.2 Questionnaire of Smoking Urges-Brief (QSU-brief )
The QSU-brief (Cox et al. 2001) is a self-reported questionnaire completed daily from
Day -1 to Day 5 between 08:00 PM and 11:00 PM.
The QSU-brief consists of 10 items as presented in Table 4.

Question 															Factor
1. I have a desire for a cigarette right now						1
2. Nothing would be better than smoking  a cigarette right now 		2
3. If it were possible, I probably  would smoke right now 			1
4. I could control things better now if  I could smoke				2
5. All I want right now is a cigarette								2
6. I have an urge for a cigarette									1
7. A cigarette would taste good right now							1
8. I would do almost anything for a  cigarette right now			2
9. Smoking would make me less depressed 							2
10. I am going to smoke as soon as possible 						1

All items will be rated on a 7-point scale, ranging from 1 (strongly disagree) to 7
(strongly agree). Higher scores indicate a higher urge to smoke.
Two factor scores and a total score will also be derived (Cox et al. 2001). Each factor is a
subset that includes 5 of the 10 questions as defined in Table 4. Factor 1 represents the
desire and intention to smoke with smoking perceived as rewarding, while Factor 2
represents an anticipation of relief from negative effect with an urgent desire to smoke.
The factors and total scores will be calculated by averaging non-missing item scores if at
least 50% are non-missing, otherwise the factor or total score will be set to missing.
;
proc format;*answers;

value $ qsu
'1'='Strongly disagree'
'2'='Disagree'
'3'='Somewhat disagree'
'4'='Do not agree or disagree'
'5'='Somewhat agree'
'6'='Agree'
'7'='Strongly agree';

value qsuN
1='Strongly disagree'
2='Disagree'
3='Somewhat disagree'
4='Do not agree or disagree'
5='Somewhat agree'
6='Agree'
7='Strongly agree';

run;

*from folder datasets\adqssu.pdf:
the data set ADQSSU is the one used for the analysis, it is derived from the data set QS.
This section checks the derivation of the 'aval' and 'chg' variables;
data qs2;
format qstestb $66.;
set work.qs;
if qscat='QUESTIONNAIRE ON SMOKING URGES';

if qstestcd in ('QSU01' 'QSU03' 'QSU06' 'QSU07' 'QSU10') then do;
parcat2 = 'Factor 1 - Reward';
parcat2n = 1;
end;

if qstestcd in ('QSU02' 'QSU04' 'QSU05' 'QSU08' 'QSU09') then do;
parcat2 = 'Factor 2 - Relief';
parcat2n = 2;
end;

if QSTEST='DESIRE FOR CIGARETTE' 		then qstestB='01. I have a desire for a cigarette right now';
if QSTEST='NOTHING BETTER THAN SMOKING' then qstestB='02. Nothing would be better than smoking  a cigarette right now';
if QSTEST='PROBABLY SMOKE NOW' 			then qstestB='03. If it were possible, I probably  would smoke right now'; 
if QSTEST='CONTROL THINGS BETTER' 		then qstestB='04. I could control things better now if  I could smoke';
if QSTEST='CIGARETTE RIGHT NOW' 		then qstestB='05. All I want right now is a cigarette';
if QSTEST='URGE FOR A CIGARETTE' 		then qstestB='06. I have an urge for a cigarette';
if QSTEST='CIGARETTE TASTE GOOD' 		then qstestB='07. A cigarette would taste good right now';
if QSTEST='DO ANYTHING FOR A CIGARETTE' then qstestB='08. I would do almost anything for a  cigarette right now';
if QSTEST='LESS DEPRESSED' 				then qstestB='09. Smoking would make me less depressed'; 
if QSTEST='SMOKE AS SOON AS POSSIBLE' 	then qstestB='10. I am going to smoke as soon as possible'; 

* analysis variables ;
if qsstresc='STRONGLY DISAGREE' then aval=1;
else if qsstresc='DISAGREE' then aval=2;
else if qsstresc='SOMEWHAT DISAGREE' then aval=3;
else if qsstresc='DO NOT AGREE OR DISAGREE' then aval=4;
else if qsstresc='SOMEWHAT AGREE' then aval=5;
else if qsstresc='AGREE' then aval=6;
else if qsstresc='STRONGLY AGREE' then aval=7;
format qsstresc $ qsu.;
run;
**Check distribution, values and compare work.QS and work.ADQSSU:;
title4; title5;
proc univariate plot data=ADQSSU;
title4 "1. ADQSSU data: Disitribution of 'chg' for QSU-brief (check distribution of 'chg'):";
where paramcd in ('QSUFACT1', 'QSUFACT2') & avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5') & fasfl='Y';
class paramcd;
var chg;
format trta avisit sexc $16.;
run;

**check categories and number of questions:;
proc freq data=qs2;
title4 "2. QS data: Questionnaire of Smoking Urges (Brief) Total score, Factor 1 (relief) and Factor 2 (reward):";
title5 "(Check categories. See that five questions QSU01, QSU03, QSU06,QSU07, QSU10 correspond to Factor 1)";
where visit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5');
tables aval qstestB*qstest parcat2* qstestcd/list missing nopercent norow;
format aval qsuN.;
run;
title5;
**Show how the scores of an individual are computed:;
proc print n noobs data=ADQSSU;
title4 "3a. ADQSSU data: Questionnaire of Smoking Urges Total score, Factor 1 (relief) and Factor 2 (reward):";
title5 "(selected usubjid, and factor)";
sum aval;
by avisit;
where usubjid='ZRHR-REXC-04-JP-HIG-0003' & avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5') & fasfl='Y' 
& parcat2='FACTOR 1 - REWARD' & paramcd notin ('QSUFACT1', 'QSUFACT2', 'QSUTOTAL');
var paramcd subjidn chg aval base avisit;
format trta avisit sexc $16.;
run;
proc means sum mean data=ADQSSU maxdec=2;
title4 "3b. ADQSSU data: Questionnaire of Smoking Urges Total score, Factor 1 (relief) and Factor 2 (reward):";
title5 "(selected usubjid, and factor)";
where usubjid='ZRHR-REXC-04-JP-HIG-0003' & avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5') & fasfl='Y' & parcat2='FACTOR 1 - REWARD'
& paramcd notin ('QSUFACT1', 'QSUFACT2', 'QSUTOTAL');
class avisit;
var aval ;
format trta avisit sexc $16.;
run;
**For a day, sum all points for answers in Factor 1, take the average over the number of questions n=5.
That average is aval. chg=aval-base;
proc means sum mean data=ADQSSU maxdec=2;
title4 "4. ADQSSU data: Questionnaire of Smoking Urges Total score, Factor 1 (relief) and Factor 2 (reward):";
title5 "For a day, sum all points for answers in Factor 1, take the average over the number of questions n=5";
title6 "If at least 50% is non-missing, take the average as 'aval'. chg=aval-base."; 
where avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5') & fasfl='Y' & paramcd in ('QSUFACT1', 'QSUFACT2', 'QSUTOTAL');
class parcat2 avisit paramcd ;
var aval ;
format trta avisit sexc $16.;
run;
title4;
title5;
title6;

%macro ExploreADQSSU(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.ADQSSU;
	where paramcd="&BoExp" & avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5') & fasfl='Y' & 
		trta in ('THS 2.2', 'CC', 'SA');

	class trta sexc ucpdgr1 avisit subjidn;
	model chg=base trta sexc ucpdgr1 avisit trta*avisit; **adam.ADPP does not have 'BASE';
	repeated avisit / subject=subjidn type=un; 

	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	lsmeans trta/pdiff=control('SA') alpha=0.05 cl;

	*lsmeans trta*avisit/ slice=avisit pdiff alpha=0.05 cl;
	*lsmeans trta*avisit/ pdiff alpha=0.05 cl;
	*estimate "trta CC-THS" trta 1 0 -1 trta*avisit 0 0 0 0 1 0 0 0 0 0 0 0 0 0 -1 ;**report is only trta, this compares more;
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

proc freq data=adqssu;
title6 "One is missing for DAY 2 to DAY 5:";
	where paramcd="&BoExp" & avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5') & fasfl='Y' & 
		trta in ('THS 2.2', 'CC', 'SA');
tables avisit;
run;
title6;

%mend ExploreADQSSU;
**Table 72 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf;
%ExploreADQSSU(QSUFACT1, "QSU-brief Questionnaire: Table 72 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADQSSU(QSUFACT2, "QSU-brief Questionnaire: Table 72 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

**Minnesota Nicotine Withdrawal Scale (MNWS) total score, revised version on Day 5;

*https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2527730/
This eight-item scale measures withdrawal symptoms (i.e., craving, irritability, anxiety, 
difficulty concentrating, restlessness, increased appetite or weight gain, depression, 
and insomnia) listed in the Diagnostic and Statistical Manual of Mental Disorders 
(4th ed.- DSM–IV- American Psychiatric Association, 1994), and these symptoms are generally 
scored on an ordinal scale ranging from 0 (not present) to 4 (severe)

Clinical Study Report Appendix 16.1.8 - Documentation on Stat Methods.pdf:
7.3.4 Minnesota Nicotine Withdrawal Scale (revised edition) Questionnaire
The MNWS (Hughes and Hatsukami 2008) is a 24 hour recall that will be completed by
the subject him/herself daily on Day 0 to Day 6 prior to product use to reflect the previous
days experience. Therefore although it is collected on Days 0 to 6 it will be reported as
Days -1 to 5. Only the self-reported part of the MNWS will be used.
The self-reported part of the MNWS consists of the following 15 items which are rated
over the last 24 hours on a scale of 0 to 4 (see Table 6). Higher scores indicate greater
intensity on that scale.
The total scores will be derived by summing the individual item scores if all items are
non-missing, otherwise the total score will be set to missing. The first total score
calculated by summing the first 9 items is based on validated items, the second score is
based on 6 extra items which are thought to have an impact on withdrawal but have not
been validated.

Question Total Score
1 Angry, irritable, frustrated. 				1 and 2
2 Anxious, nervous. 							1 and 2
3 Depressed mood, sad. 							1 and 2
4 Desire or craving to smoke. 					1 and 2
5 Difficulty concentrating. 					1 and 2
6 Increased appetite, hungry, weight gain. 		1 and 2
7 Insomnia, sleep problems, awakening at night. 1 and 2
8 Restless. 									1 and 2
9 Impatient. 									1 and 2
10 Constipation 								2
11 Dizziness 									2
12 Coughing 									2
13 Dreaming or nightmares 						2
14 Nausea 										2
15 Sore throat 									2

;
proc univariate plot data=ADQSND;
title4 "1. ADQSND data: Disitribution of 'chg' for MNWRWDS1 (check distribution of 'chg'):";

where paramcd in ('MNWRWDS1') & fasfl='Y' & avisit in ('DAY 2', 'DAY 3', 'DAY 4', 'DAY 5', 'DAY 6/DISCHARGE');
var chg;
format trta avisit sexc $16.;
run;

%macro ExploreADQSND(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.ADQSND;
	where paramcd="&BoExp" & fasfl='Y' & avisit in ('DAY 2', 'DAY 3', 'DAY 4', 'DAY 5', 'DAY 6/DISCHARGE');

	class trta sexc ucpdgr1 avisit subjidn;
	model chg=base trta sexc ucpdgr1 avisit avisit*trta; 
	repeated avisit / subject=subjidn type=cs; 

	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
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

*The total scores will be derived by summing the individual item scores if all items are
non-missing, otherwise the total score will be set to missing:;
proc freq data=ADQSND;
title6 "One is missing after DAY 2:";
	where paramcd="&BoExp" & fasfl='Y' & avisit in ('DAY 2', 'DAY 3', 'DAY 4', 'DAY 5', 'DAY 6/DISCHARGE');
tables avisit;
run;
title6;

/*
proc means n mean median min max clm data=work.ADQSND maxdec=3;
	where paramcd="&BoExp" & fasfl='Y' & avisit in ('DAY 2', 'DAY 3', 'DAY 4', 'DAY 5', 'DAY 6/DISCHARGE');
class trta avisit;
var aval base;
output out=means_&BoExp
n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_ lclm=lclm_ uclm=uclm_;
run;

data means_&BoExp(drop=n_ mean_ median_ std_ min_ max_ lclm_ uclm_);
format note $130.;
set means_&BoExp;
if trta ne '' & avisit ne '';
n=n_;
mean=round(mean_, 0.01);   
median=round(median_, 0.01);        
std=round(std_, 0.01);   
min=round(min_, 0.01);   
max=round(max_, 0.01);   
lclm=round(lclm_, 0.01);   
uclm=round(uclm_, 0.01);   
note=&title5;
run;
*/

%mend ExploreADQSND;
**See also Table 15.2.4.45 in Clinical Study Report Appendix 15.2 - Tables.pdf
and Listing 15.4.4.46 in Clinical Study Report Appendix 15.4 - Stat Output.pdf;
%ExploreADQSND(MNWRWDS1, "Minnesota Nicotine Withdrawal Scale (MNWS)- Total Score 1: Table 73 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADQSND(MNWRWDS2, "Minnesota Nicotine Withdrawal Scale (MNWS)- Total Score 2: Table 73 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

*• Cytochrome P450 2A6 (CYP2A6) enzymatic activity: in plasma on Day 6, using the molar
metabolic ratio of trans-3’-hydroxycotinine/cotinine;
%macro ExploreADBX(BoExp, title5);

title4 "&BoExp";
title5 &title5;

proc means n mean median min max clm data=work.adbx maxdec=3;
where paramcd="&BoExp" & avisit='DAY 6/DISCHARGE';* & fasfl='Y' & anl02fl='Y';
class trta avisit;
var aval base;
output out=means_&BoExp
n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_ lclm=lclm_ uclm=uclm_;
run;

data means_&BoExp(drop=n_ mean_ median_ std_ min_ max_ lclm_ uclm_);
format note $130.;
set means_&BoExp;
if trta ne '' & avisit ne '';
n=n_;
mean=round(mean_, 0.01);   
median=round(median_, 0.01);        
std=round(std_, 0.01);   
min=round(min_, 0.01);   
max=round(max_, 0.01);   
lclm=round(lclm_, 0.01);   
uclm=round(uclm_, 0.01);   
note=&title5;
run;
%mend ExploreADBX;
**similar results, not identical in Table 73 ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf;
%ExploreADBX(CYP2A6, "CYP2A6 enzymatic activity Day 6: Table 15.2.4.51 in Clinical Study Report Appendix 15.2 - Tables.pdf");
**End of Solution of 1. To describe the following parameters...;

**Solution of 2. This was answered in Primary- Secondary and 1. already:
2. To evaluate in smokers switching from CC to THS 2.2, smokers continuing to smoke CC and smokers
switching from CC to SA the relationship between:
Endpoints:
• NEQ and primary and secondary BoExp in 24-hour urine on Day 5.
• Primary, secondary BoExp, NEQ, and risk markers (8-epi-PGF2a and 11-DTX-B2) measured in
24-hour urine on Day 5;

**Solution of 3. 
To describe the following parameters over the course of the study in smokers switching from CC to
THS 2.2 as compared to smokers continuing to smoke CC:
Endpoints:
• Product evaluation: Modified Cigarette Evaluation Questionnaire (MCEQ):
-Smoking Satisfaction subscale.
-Enjoyment of Respiratory Tract Sensation subscale.
-Psychological Reward subscale.
-Aversion subscale.
-Craving Reduction subscale.

• Smoking pattern: human smoking topography (HST) parameters and HST questionnaire.
-HST parameters (Table 14 and Table 15).
-HST questionnaire;

**• Product evaluation: Modified Cigarette Evaluation Questionnaire (MCEQ):
-Smoking Satisfaction subscale.
-Enjoyment of Respiratory Tract Sensation subscale.
-Psychological Reward subscale.
-Aversion subscale.
-Craving Reduction subscale

Clinical Study Report Appendix 16.1.8 - Documentation on Stat Methods.pdf:
7.3.3 Modified Cigarette Evaluation Questionnaire
The MCEQ (Cappelleri et al. 2007) will be completed by the subject him/herself daily
from Day -1 to Day 5 between 08:00 PM and 11:00 PM. On Day -1 and Day 0, all
subjects will complete the questionnaire. From Day 1 onwards it will be completed by
subjects in the CC and THS 2.2 arms only to assess the degree to which subjects
experience the reinforcing effects of smoking.
The MCEQ consists of 12 items as presented in Table 5:

Question 															Subscale
1 Was smoking satisfying? 											Smoking Satisfaction
2 Did cigarettes taste good? 										Smoking Satisfaction
3 Did you enjoy the sensation in your throat and chest? 			Enjoyment of Respiratory Tract Sensations
4 Did smoking calm you down? 										Psychological Reward
5 Did smoking make you feel more aware? 							Psychological Reward
6 Did smoking make you feel less irritable? 						Psychological Reward
7 Did smoking help you concentrate? 								Psychological Reward
8 Did smoking reduce your hunger for food? 							Psychological Reward
9 Did smoking make you dizzy? 										Aversion
10 Did smoking make you nauseous? 									Aversion
11 Did smoking immediately relieve your craving for a cigarette? 	Craving Reduction
12 Did you enjoy smoking? 											Smoking Satisfaction

Items are assessed on a 7-point scale, ranging from 1 (not at all) to 7 (extremely). Higher
scores indicate greater intensity on that scale.
The subscales scores will be derived by averaging the individual non-missing item scores
if at least 50% are non-missing, otherwise the subscale score will be set to missing.
;

proc univariate plot data=ADQSPA;
title4 "1. ADQSPA data: Disitribution of 'chg' for MCEQ (check distribution of 'chg'):";
where paramcd="MCEQA" & fasfl='Y' & avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5');
var chg;
format trta avisit sexc $16.;
run;
**For a day, sum all points for answers in Factor 1, take the average over the number of questions n=5.
That average is aval. chg=aval-base;
proc means sum mean data=ADQSPA maxdec=2;
title4 "2. ADQSPA data: Modified Cigarette Evaluation Questionnaire:";
title5 "Average of the individual non-missing item scores if at least";
title6 "50% are non-missing, otherwise the subscale score will be set to missing";
where paramcd="MCEQA" & fasfl='Y' & avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5');
class parcat2 avisit paramcd ;
var aval base chg;
format trta avisit sexc $16.;
run;

%macro ExploreADQSPA(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.ADQSPA;
	where paramcd="&BoExp" & fasfl='Y' & avisit in ('DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5');
	class trta sexc ucpdgr1 avisit subjidn;
	model chg=base trta sexc ucpdgr1 avisit trta*avisit;**including 'base' in model for 'chg' replicates results in Table 74;
	repeated avisit / subject=subjidn type=un; 
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	run;

data lsmeans_&BoExp;
format note $130.;
set lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(estimate, 0.01); label LSMRatio='LS Mean Differences';
reduction=.; label reduction='reduction=exp(estimate)';*not reported;
LB=round((upper), 0.01); label LB='LB=exp(upper)';
UB=round((lower), 0.01); label UB='UB=exp(lower)';
run;

%mend ExploreADQSPA;
%ExploreADQSPA(MCEQA,    "MCEQ- Aversion: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf. THS-CC instead of Ratios. No SA data.");
%ExploreADQSPA(MCEQCR,   "MCEQ- Craving Reduction: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf. THS-CC instead of Ratios. No SA data.");
%ExploreADQSPA(MCEQERTS, "MCEQ- Enjoyment of respiratory tract sensation: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf. THS-CC instead of Ratios. No SA data.");
%ExploreADQSPA(MCEQPR,	 "MCEQ- Psychological Reward: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf. THS-CC instead of Ratios. No SA data.");
%ExploreADQSPA(MCEQSS, 	 "MCEQ- Smoking Satisfaction: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf. THS-CC instead of Ratios. No SA data.");

**• Smoking pattern: human smoking topography (HST) parameters and HST questionnaire.
-HST parameters (Table 14 and Table 15).
-HST questionnaire;
data adxtsort;

set adxt;
if paramcd in (
'ANPC', 
'ATVOL',
'AAVGVI',
'AAVGDI',
'ATDI',
'AAVGQMI',
'AAVGQCI',
'ATII',
'ATDFI',
'ATWI',
'AAVGPMI',
'AAVGPCI',
'ASMINT',
'APTI',
'APFEQ',

'AVGII', 'II', 'TII', 'PN',

'AAVGWI', 'ATWI', 'AVGWI', 'TWI', 'WI'
);
proc sort; by avisit;
run;
%macro ExploreADXT(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.ADXTsort;
where paramcd="&BoExp" & fasfl='Y' & avisit in ('DAY 4');

	class trta sexc ucpdgr1;
	model logaval=logbase trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	run;

data lsmeans_&BoExp;
format note $130.;
set lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';
reduction=.; label reduction='reduction=exp(estimate)';*not reported;
LB=round(exp(upper)*100, 0.01); label LB='LB=exp(upper)';
UB=round(exp(lower)*100, 0.01); label UB='UB=exp(lower)';
run;
%mend ExploreADXT;
%ExploreADXT(ANPC,     "HST- Total number of puffs (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");**similar results, not identical;
%ExploreADXT(ATVOL,    "HST- Total puff volume (ml) (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(AAVGVI,   "HST- Average puff volume (ml) (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(AAVGDI,   "HST- Average puff duration (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(ATDI,     "HST- Total puff duration (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(AAVGQMI,  "HST- Average flow (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(AAVGQCI,  "HST- Average peak flow (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(ATII,     "HST- Total inter puff interval average (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
*%ExploreADXT(not found,    "HST- Average inter puff interval(s) (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(ATDFI,    "HST- Total smoking duration average (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(ATWI,     "HST- Total work average (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(AAVGWI,    "HST- Average work (mJ) (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(AAVGPMI,  "HST- Average pressure drop (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(AAVGPCI,  "HST- Average peak pressure drop (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(ASMINT,   "HST- Smoking intensity (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(APTI,     "HST- Puffing time index (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");
%ExploreADXT(APFEQ,    "HST- Puff frequency (Day 4): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, No SA data");

**Clinical Study Report Appendix 16.1.8 - Documentation on Stat Methods.pdf:
**7.3.5 Human Smoking Topography Questionnaire
The HST questionnaire will be completed on Days 0 and 4 by all subjects smoking CC
that are compatible with the HST SODIM® device (i.e., non-slim CC) to evaluate the
impact of the use of the HST SODIM® device.
The HST questionnaire has 5 items rated on a 5-point Likert scale (strongly agree, agree,
neither agree nor disagree, disagree and strongly disagree). The items are:

1. The smoking of the conventional cigarettes/products is different with the device.
2. You enjoy smoking with the device as much as without it.
3. The taste of the conventional cigarettes/products is different with the device.
4. The device is easy to use.
5. Your smoking is disturbed by the device.;

*5-point Likert scale;
proc format;
value aval
1='Strongly disagree'
2='Disagree'
3='Neither agree nor disagree'
4='Agree'
5='Strongly agree';
run;

%macro ExploreADQSPA(BoExp, title5);

title4 "&BoExp";
title5 &title5;
*Table 15.2.4.60 in Clinical Study Report Appendix 15.2 - Tables.pdf;

proc freq data=work.ADQSPA(keep=subjidn paramcd trta parcat1 avisit aval);
*where paramcd="&BoExp" & avisit in('DAY 0' 'DAY 4') & fasfl ='Y' & trta in ('THS 2.2', 'CC') & parcat1 in ('HUMAN SMOKING TOPOGRAPHY QUESTIONNAIRE');**see t_hstqu.pdf;
where paramcd="&BoExp" & avisit in('DAY 0' 'DAY 4') & trta in ('THS 2.2', 'CC') & parcat1 in ('HUMAN SMOKING TOPOGRAPHY QUESTIONNAIRE');**see t_hstqu.pdf;
*tables avisit*aval*trta/missing norow out=freq_&BoExp outpct;
tables avisit*aval*trta/missing norow;**no output, see macro below;

format aval aval.;
run;

%mend ExploreADQSPA;
***The denominators are wrong:;
%ExploreADQSPA(HSSMOK,  "HST- The smoking of the CC/Products differs with the device: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");
*%ExploreADQSPA(HSENJ,   "HST- You enjoy smoking with the device as much as without it: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");
*%ExploreADQSPA(HSTASTE, "HST- The taste of the CC /products is different with the device: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");
*%ExploreADQSPA(HSEASY,  "HST- The device is easy to use: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");
*%ExploreADQSPA(HSDISTU, "HST- Your smoking is disturbed by the device: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");

**There are missing: this corrects the denominators:;
data test;
set adqspa(keep=subjidn paramcd trta avisit parcat1 aval);
if paramcd in ('HSSMOK','HSENJ','HSTASTE','HSEASY','HSDISTU') & trta in ('THS 2.2', 'CC') & avisit in ('DAY 0', 'DAY 4') &
parcat1 in ('HUMAN SMOKING TOPOGRAPHY QUESTIONNAIRE');**see t_hstqu.pdf;
run;
proc freq data=test;
tables paramcd*trta*avisit aval/nopercent norow list missing;
format avisit trta $10. ;
run;

%macro HST_Q7880(paramcd, trta, avisit, dataout, title4);

data temp;
format avisit trta $10. ;
set test;
if paramcd="&paramcd" & trta=&TRTA & avisit=&AVISIT;
run;

data &dataout;
set temp end=nomore; output;
	
if nomore then do;
paramcd="&paramcd"; trta=&trta; avisit=&AVISIT; aval=.;

*add rows until complete n:;
output; output; 
end;

proc print n noobs data=&dataout(drop=parcat1);
title4 "N should be &title4";
run;

%mend HST_Q7880;

%macro HST_Qsame(paramcd, trta, avisit, dataout, title4);*no changes here;
data temp;
format avisit trta $10. ;
set test;
if paramcd="&paramcd" & trta=&TRTA & avisit=&AVISIT;
run;

data &dataout;
set temp;
run;

%mend HST_Qsame;

*
HSDISTU     CC            DAY 0               40
HSDISTU     CC            DAY 4               40
HSDISTU     THS 2.2       DAY 0               78
HSDISTU     THS 2.2       DAY 4               80
;
%HST_Qsame(HSDISTU, "CC", "DAY 0", HSDISTUCC0, 40);
%HST_Qsame(HSDISTU, "CC", "DAY 4", HSDISTUCC4, 40);
%HST_Q7880(HSDISTU, "THS 2.2", "DAY 0", HSDISTUTHS0, 80);
%HST_Qsame(HSDISTU, "THS 2.2", "DAY 4", HSDISTUTHS4, 80);

*
HSEASY      CC            DAY 0               40
HSEASY      CC            DAY 4               40
HSEASY      THS 2.2       DAY 0               78
HSEASY      THS 2.2       DAY 4               80
;
%HST_Qsame(HSEASY, "CC", "DAY 0", HSEASYCC0, 41);
%HST_Qsame(HSEASY, "CC", "DAY 4", HSEASYCC4, 41);
%HST_Q7880(HSEASY, "THS 2.2", "DAY 0", HSEASYTHS0, 80);
%HST_Qsame(HSEASY, "THS 2.2", "DAY 4", HSEASYTHS4, 80);

*
HSENJ       CC            DAY 0               40
HSENJ       CC            DAY 4               40
HSENJ       THS 2.2       DAY 0               78
HSENJ       THS 2.2       DAY 4               80
;
%HST_Qsame(HSENJ, "CC", "DAY 0", HSENJCC0, 41);
%HST_Qsame(HSENJ, "CC", "DAY 4", HSENJCC4, 41);
%HST_Q7880(HSENJ, "THS 2.2", "DAY 0", HSENJTHS0, 80);
%HST_Qsame(HSENJ, "THS 2.2", "DAY 4", HSENJTHS4, 80);

*
HSSMOK      CC            DAY 0               40
HSSMOK      CC            DAY 4               40
HSSMOK      THS 2.2       DAY 0               78
HSSMOK      THS 2.2       DAY 4               80
;
%HST_Qsame(HSSMOK, "CC", "DAY 0", HSSMOKCC0, 41);
%HST_Qsame(HSSMOK, "CC", "DAY 4", HSSMOKCC4, 41);
%HST_Q7880(HSSMOK, "THS 2.2", "DAY 0", HSSMOKTHS0, 80);
%HST_Qsame(HSSMOK, "THS 2.2", "DAY 4", HSSMOKTHS4, 80);

*
HSTASTE     CC            DAY 0               40
HSTASTE     CC            DAY 4               40
HSTASTE     THS 2.2       DAY 0               78
HSTASTE     THS 2.2       DAY 4               80
;
%HST_Qsame(HSTASTE, "CC", "DAY 0", HSTASTECC0, 41);
%HST_Qsame(HSTASTE, "CC", "DAY 4", HSTASTECC4, 41);
%HST_Q7880(HSTASTE, "THS 2.2", "DAY 0", HSTASTETHS0, 80);
%HST_Qsame(HSTASTE, "THS 2.2", "DAY 4", HSTASTETHS4, 80);

data HST_Q;
set 

HSDISTUCC0(in=a1)
HSDISTUCC4(in=a2)
HSDISTUTHS0(in=a3)
HSDISTUTHS4(in=a4)

HSEASYCC0(in=a5)
HSEASYCC4(in=a6)
HSEASYTHS0(in=a7)
HSEASYTHS4(in=a8)

HSENJCC0 (in=a9)
HSENJCC4 (in=a10)
HSENJTHS0 (in=a11)
HSENJTHS4 (in=a12)

HSSMOKCC0(in=a13)
HSSMOKCC4(in=a14)
HSSMOKTHS0(in=a15)
HSSMOKTHS4(in=a16)

HSTASTECC0(in=a17)
HSTASTECC4(in=a18)
HSTASTETHS0(in=a19)
HSTASTETHS4(in=a20)
;
run;

%macro ExploreADQSPA2(BoExp, title5);

title4 "&BoExp";
title5 &title5;
*Table 15.2.4.60 csr-v2-app-15_2-tables.pdf;

proc freq data=work.HST_Q;
where paramcd="&BoExp" & avisit in('DAY 0', 'DAY 4') & trta in ('THS 2.2', 'CC') 
	& parcat1 in ('HUMAN SMOKING TOPOGRAPHY QUESTIONNAIRE');**see t_hstqu.pdf;
tables avisit*aval*trta/norow nopct missing out=freq_&BoExp outpct;
format aval aval.;
run;

data freq_&BoExp;
format note $130.;
set freq_&BoExp;
BoExp="&BoExp";
note=&title5;
run;

%mend ExploreADQSPA2;
***Same results. The problem was the denominator;
%ExploreADQSPA2(HSSMOK,  "HST- The smoking of the CC/Products differs with the device: Table 15.2.4.60 csr-v2-app-15_2-tables.pdf");
%ExploreADQSPA2(HSENJ,   "HST- You enjoy smoking with the device as much as without it: Table 15.2.4.60 csr-v2-app-15_2-tables.pdf");
%ExploreADQSPA2(HSTASTE, "HST- The taste of the CC /products is different with the device: Table 15.2.4.60 csr-v2-app-15_2-tables.pdf");
%ExploreADQSPA2(HSEASY,  "HST- The device is easy to use: Table 15.2.4.60 csr-v2-app-15_2-tables.pdf");
%ExploreADQSPA2(HSDISTU, "HST- Your smoking is disturbed by the device: Table 15.2.4.60 csr-v2-app-15_2-tables.pdf");
**end of Solution of 3...;

**Theses data sets will be printed as the ods rtf file in
'VI. Printout clean report (note: lst available to compare and check all results.)';

***Exploratory report:;
data partIImeans0;
format note $130.;
set 

means_UAMES24U(in=a1) 
means_CYP2A6(in=a2) 

;

if a1 then data='UAMES24U';
if a2 then data='CYP2A6';

*for reduction, the UB is the LB and vice versa:;
CI='(' || left(compress(put(LCLM,8.2))) || ',' || left(compress(put(UCLM,8.2))) ||')';

run;
data work.partIImeansA work.partIImeansB work.partIImeansC;
set work.partIImeans0(keep=data trta avisit n mean ci note);
if trta='THS 2.2' then output partIImeansA;
if trta='CC' then output partIImeansB;
if trta='SA' then output partIImeansC;
run;
data partIImeans;
merge 
partIImeansA(rename=(trta=trtaTHS avisit=avisitTHS n=nTHS mean=meanTHS ci=ciTHS))
partIImeansB(rename=(trta=trtaCC avisit=avisitCC n=nCC mean=meanCC ci=ciCC))
partIImeansC(rename=(trta=trtaSA avisit=avisitSA n=nSA mean=meanSA ci=ciSA));

*label 
meansTHS='Means THS 2.2' CITHS='95% C.I. THS 2.2' 
meansCC='Means CC' CICC='95% C.I. CC' 
meansCC='Means SA' CISA='95% C.I. SA' 
;
run;

proc compare base=rm_THS.partIImeans compare=work.partIImeans;
title4 "Control changes by comparing old vs. new data sets";
run;

&permanent data rm_THS.partIImeans;
&permanent set work.partIImeans;
&permanent run;

proc freq data=work.partIImeans; 
title4 "Check"; 
tables data*trtaTHS*trtaCC*trtaSA/list missing; 
run;

data partIIlsmeans0;
set

lsmeans_QSUFACT1
lsmeans_QSUFACT2

lsmeans_MNWRWDS1
lsmeans_MNWRWDS2

lsmeans_MCEQA  
lsmeans_MCEQCR 
lsmeans_MCEQERTS
lsmeans_MCEQPR	
lsmeans_MCEQSS

lsmeans_ANPC
lsmeans_ATVOL
lsmeans_AAVGVI
lsmeans_AAVGDI
lsmeans_ATDI
lsmeans_AAVGQMI
lsmeans_AAVGQCI
lsmeans_ATII
lsmeans_ATDFI
lsmeans_ATWI
lsmeans_AAVGPMI
lsmeans_AAVGPCI
lsmeans_ASMINT
lsmeans_APTI
lsmeans_APFEQ;

*for reduction, the UB is the LB and vice versa:;
CI='(' || left(compress(put(UB,8.2))) || ',' || left(compress(put(LB,8.2))) ||')';

if BoExp='QSUFACT1' then BoExpTxt='QSUFACT1';
if BoExp='QSUFACT2' then BoExpTxt='QSUFACT2';

if BoExp='MNWRWDS1' then BoExpTxt='MNWRWDS1';
if BoExp='MNWRWDS2' then BoExpTxt='MNWRWDS2';

if BoExp='UPGF2CRE' then BoExpTxt='UPGF2CRE';
if BoExp='UTXB2CRE' then BoExpTxt='UTXB2CRE';

if BoExp='MCEQA'	then BoExpTxt='MCEQA';  
if BoExp='MCEQCR'	then BoExpTxt='MCEQCR'; 
if BoExp='MCEQERTS'	then BoExpTxt='MCEQERTS';
if BoExp='MCEQPR'	then BoExpTxt='MCEQPR';	
if BoExp='MCEQSS'	then BoExpTxt='MCEQSS'; 

if BoExp='ANPC' 	then BoExpTxt='ANPC';  
if BoExp='ATVOL' 	then BoExpTxt='ATVOL';  
if BoExp='AAVGVI' 	then BoExpTxt='AAVGVI';  
if BoExp='AAVGDI' 	then BoExpTxt='AAVGDI';  
if BoExp='ATDI' 	then BoExpTxt='ATDI';  
if BoExp='AAVGQMI' 	then BoExpTxt='AAVGQMI';  
if BoExp='AAVGQCI' 	then BoExpTxt='AAVGQCI';  
if BoExp='ATII' 	then BoExpTxt='ATII';  
if BoExp='ATDFI' 	then BoExpTxt='ATDFI';  
if BoExp='ATWI' 	then BoExpTxt='ATWI';  
if BoExp='AAVGPMI' 	then BoExpTxt='AAVGPMI';  
if BoExp='AAVGPCI' 	then BoExpTxt='AAVGPCI';  
if BoExp='ASMINT' 	then BoExpTxt='ASMINT';  
if BoExp='APTI' 	then BoExpTxt='APTI';  
if BoExp='APFEQ' 	then BoExpTxt='APFEQ';  

run;
data work.partIIlsmeansA work.partIIlsmeansB;
set work.partIIlsmeans0;
if trta='THS 2.2' and _trta='CC' then output partIIlsmeansA;
if trta='THS 2.2' and _trta='SA' then output partIIlsmeansB;
run;
data partIIlsmeans;
merge 
partIIlsmeansA(rename=(BoExp=BoExpCC BoExpTxt=BoExpTxtCC reduction=reductionCC CI=CICC probt=probtCC LSMRatio=LSMRatioCC)) 
partIIlsmeansB(rename=(BoExp=BoExpSA BoExpTxt=BoExpTxtCC reduction=reductionSA CI=CISA probt=probtSA LSMRatio=LSMRatioSA));

label BoExpCC='BoExp' 
reductionCC='Reduction THS 2.2/ CC in %' CICC='95% C.I. THS 2.2/ CC' probtCC='p-value THS 2.2/ CC' LSMRatioCC='LSM Ratio THS/CC'
reductionSA='Reduction THS 2.2/ SA in %' CISA='95% C.I. THS 2.2/ SA' probtSA='p-value THS 2.2/ SA' LSMRatioSA='LSM Ratio THS/SA';

run;

proc compare base=rm_THS.partIIlsmeans compare=work.partIIlsmeans;
title4 "Control changes by comparing old vs. new data sets";
run;

&permanent data rm_THS.partIIlsmeans;
&permanent set work.partIIlsmeans;
&permanent run;

proc freq data=work.partIIlsmeans; title4 "Check that left and rigth columns match"; 
tables BoExpCC*BoExpSA/list missing; 
run;

data partIIfreq0;
set
freq_HSSMOK(in=a1)
freq_HSENJ(in=a2)
freq_HSTASTE(in=a3)
freq_HSEASY(in=a4)
freq_HSDISTU(in=a5);

if a1 then data=1;
if a2 then data=2;
if a3 then data=3;
if a4 then data=4;
if a5 then data=5;
run;

data work.partIIfreqA work.partIIfreqB;
set work.partIIfreq0(drop=percent pct_tabl pct_row);
if trta='THS 2.2' then output partIIfreqA;
if trta='CC' then output partIIfreqB;
proc sort data=partIIfreqA; by data avisit aval;
proc sort data=partIIfreqB; by data avisit aval;
run;
data partIIfreq;
merge 
partIIfreqA(rename=(count=countTHS pct_col=pct_colTHS trta=trtaTHS BoExp=BoExpTHS)) 
partIIfreqB(rename=(count=countCC pct_col=pct_colCC trta=trtaCC BoExp=BoExpCC));

by data avisit aval;

label 
countTHS='count THS 2.2' pct_colTHS='Col % THS'
countCC='count CC' pct_colCC='Col % CC';
format avisit trta: $10. ;
proc sort; by data avisit descending aval;
run;

proc compare base=rm_THS.partIIfreq compare=work.partIIfreq;
title4 "Control changes by comparing old vs. new data sets";
run;

&permanent data rm_THS.partIIfreq;
&permanent set work.partIIfreq;
&permanent run;

proc freq data=work.partIIfreq; 
title4 "Check that left and rigth columns match"; 
tables BoExpTHS*BoExpCC/list missing; 
run;

proc print noobs label data=work.partIImeans;
title5 "Report: Exploratory ZRHR-REXC-04-JP";
*var data avisitTHS nTHS meanTHS ciTHS nCC meanCC ciCC nSA meanSA ciSA note;
var data avisitTHS nTHS meanTHS nCC meanCC nSA meanSA note;

label 
avisitTHS='Visit' 

nTHS='N THS' meanTHS='Mean THS' ciTHS='95% CI THS'
nCC='N CC' meanCC='Mean CC' ciCC='95% CI CC'
nSA='N SA' meanSA='Mean SA' ciSA='95% CI SA';

format trta: avisit: $10. note $130.;
run;
proc print noobs label data=work.partIIlsmeans;
title5 "Report: Exploratory ZRHR-REXC-04-JP";
where trta='THS 2.2' & (_trta='CC' or _trta='SA');
var BoExpTxtCC LSMRatioCC reductionCC CICC LSMRatioSA reductionSA CISA note;

label
BoExpTxtCC='BoExp'

LSMRatioCC='THS/CC or THS-CC'
reductionCC='% Reduction THS/CC'
CICC='95% CI (THS/CC or THS-CC)'

LSMRatioSA='THS/SA or THS-SA'
reductionSA='% Reduction THS/SA'
CISA='95% CI (THS/SA or THS-SA)';

format 
trta _trta $10. note $130.;
run;
proc print noobs label data=work.partIIfreq;
title5 "Report: Exploratory ZRHR-REXC-04-JP";
var BoExpTHS avisit trtaTHS countTHS pct_colTHS countCC pct_colCC note;

label
BoExpThs='BoExp'
avisit='Visit'

trtaTHS='Arm'
countTHS='N THS 2.2'
pct_colTHS='Col THS 2.2 %'

countCC='N CC'
pct_colCC'Col CC %';

format 
BoExp: trta: $10. note $130. pct: 10.2;
run;

*******************************************************************************************
	End of 3.1. Means, mixed and frequencies for exploratory
*******************************************************************************************;

*******************************************************************************************
	3.2. Other clinical results
*******************************************************************************************;

**4. To describe the following parameter over the course of the study in smokers
switching from CC to THS 2.2:
Endpoint:
-Potential combustion occurrences in tobacco plugs: visual inspection of the
tobacco plugs.
;

**Clinical Chemistry:;
%macro meansADLB(BoExp, title5);

title4 "&BoExp";
title5 &title5;

proc means n mean median min max clm data=work.adlb maxdec=3;
*where paramcd="&BoExp" & saffl='Y' & parcat1='CLINICAL CHEMISTRY' & anl01fl='Y' & avisit="DAY 6/DISCHARGE" & randfl='Y';
where paramcd="&BoExp" & anl01fl='Y' & avisit="DAY 6/DISCHARGE" & TRTA IN ('THS 2.2', 'CC', 'SA');
class trta;
var aval;
output out=means_&BoExp
n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_ lclm=lclm_ uclm=uclm_;
run;

data means_&BoExp(drop=n_ mean_ median_ std_ min_ max_ lclm_ uclm_);
set means_&BoExp;
if trta ne '';
n=n_;
mean=round(mean_, 0.01);   
median=round(median_, 0.01);        
std=round(std_, 0.01);   
min=round(min_, 0.01);   
max=round(max_, 0.01);   
lclm=round(lclm_, 0.01);   
uclm=round(uclm_, 0.01); 
note=&title5;  
run;

ods output Diffs=lsmeans_&BoExp;
proc mixed data=work.adlb;
where paramcd="&BoExp" & anl01fl='Y' & avisit="DAY 6/DISCHARGE" & TRTA IN ('THS 2.2', 'CC', 'SA');
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

%mend meansADLB;
%meansADLB(ALT, "ALANINE AMINOTRANSFERASE (IU/L) (change): Table 15.2.6.13 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(CHOL, "CHOLESTEROL (change): Table 15.2.6.13 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(ALB, "ALBUMIN (change): Table 15.6.13 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(K, "POTASIUM (change): Table 15.6.13 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(PLAT, "PLATELETS (change): Table 15.6.13 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(WBC, "LEUKOCYTES (WBC) (change): Table 15.6.13 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(NEUT, "NEUTROPHILS (change): Table 15.2.6.14 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(MONO, "MONOCYTES (change): Table 15.2.6.14 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(TRIG, "TRIGLICERIDES (change): Table 15.2.6.14 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(LYM, "LYMPHOCYTES (change): Table 15.2.6.14 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(MONO, "MONOOCYTES (change): Table 15.2.6.14 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(EOS, "EOSINOPHILS (change): Table 15.2.6.14 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%meansADLB(BASO, "BASOPHILS (change): Table 15.2.6.14 in Clinical Study Report Appendix 15.2 - Tables.pdf");

%macro mixedADBX(BoExp, title5);

title4 "&BoExp";
title5 &title5;

proc means n mean median min max clm data=work.adbx maxdec=3;
where paramcd="&BoExp" & fasfl='Y' and anl02fl='Y' & avisit="DAY 5";
class trta;
var aval chg;
output out=means_&BoExp
n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_ lclm=lclm_ uclm=uclm_;
run;

data means_&BoExp(drop=n_ mean_ median_ std_ min_ max_ lclm_ uclm_);
set means_&BoExp;
if trta ne '';
n=n_;
mean=round(mean_, 0.01);   
median=round(median_, 0.01);        
std=round(std_, 0.01);   
min=round(min_, 0.01);   
max=round(max_, 0.01);   
lclm=round(lclm_, 0.01);   
uclm=round(uclm_, 0.01); 
note=&title5;  
run;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.adbx;
	where paramcd="&BoExp" & fasfl='Y' and anl02fl='Y' & avisit="DAY 5";
	class trta sexc ucpdgr1;
	model aval=base trta sexc ucpdgr1;**statval is defined as aval in PMI programs;
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
%mixedADBX(CYP1A2, "CYP1A2: 15.2.4.49 in Clinical Study Report Appendix 15.2 - Tables & Tables 63 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
*******************************************************************************************
	End of 3.2. Other clinical results
*******************************************************************************************;

*******************************************************************************************
	3.3. Sample size and power
*******************************************************************************************;

**https://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_power_a0000001005.htm
Example 68.4 Noninferiority Test with Lognormal Data;

%macro power(meanratio, cv); 

title5 "Sample size: meanratio=&meanratio, cv=&cv, groupsn=80|40"; 

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

*******************************************************************************************
	End of 3.3. Sample size and power
*******************************************************************************************;

/*******************************************************************************************
End of 3. Additional analysis
*******************************************************************************************/

/*******************************************************************************************
End of FDA Analysis
*******************************************************************************************/

proc printto log=log; run;

ods pdf close;

/*******************************************************************************************
End of \\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\
Montes de Oca\Programs\rm_MR0000059.sas
*******************************************************************************************/






