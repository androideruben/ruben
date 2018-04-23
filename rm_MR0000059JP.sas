%let program_name=rm_MR0000059JP;

%let permanent=*;

%let permanent=*; 
*%let permanent=; *This row only: put "*%let permanent=" if wanted to keep old permanent data;

/*proc printto log="\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name &sysdate9..log" new; run;*/

	%put code executed on &sysdate9. at &systime.;
	data _null_; call symput('begintime',time()); run;

	options source nostimer nocenter pagesize = 60 linesize = 132 noquotelenmax orientation=landscape
	mprint mlogic validvarname=v7;
	ods noproctitle;

/**************************************************************************************************

Purpose of rm_MR0000059JP.sas:

	FDA Analysis: 
		0. Create data set for mixed models analysis, and BLOQ analysis

		1. Run mixed models for primary, secondary endpoints, risk markers, nicotine, and cotinine
			including mixewd models for log of nicotine and cotinine
		2. Print clean report
		   (note: lst and log will be available to compare and check all results)
		3. Other clinical results

	MRTPA data folders are:
		\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\data\ADaM\
		\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\data\sdtm\

Programmer: Ruben Montes de Oca, CTP\OS\Statistics Branch
	Date started 3/28/2017. 
	See time stamps &sysdate9 for current date.

ods rtf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name &sysdate9..rtf";
ods rtf close;

***************************************************************************************************/

ods pdf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name lst &sysdate9..pdf";

title1 "MRTPA\iQOS-THS 2.2: ZRHR-REXC-04-JP";
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

	data work.&data;
	set work.&data;

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
%xpt(adam, ADLB);**choloesterol;
%xpt(adam, ADDX);**stick plugs;

data work.adbx;
set work.adbx(keep=anl02fl avisit atm atpt aval base bloqfl chg fasfl paramcd param trta ucpdgr1 usubjid sexc);
	if aval>0 then logaval=log(AVAL); label logaval='logaval=log(AVAL)';
	if BASE>0 then logbase=log(BASE); label logbase='logbase=log(BASE)'; 
run;
data work.adpc;  
set work.adpc(keep=anl02fl avisit atm atpt aval base bloqfl chg fasfl paramcd param trta ucpdgr1 usubjid sexc);
	if aval>0 then logaval=log(AVAL); label logaval='logaval=log(AVAL)';
	if BASE>0 then logbase=log(BASE); label logbase='logbase=log(BASE)'; 
run;
data work.adlb; 
set work.adlb(keep=anl01fl atm atpt avisit aval base bloqfl chg fasfl usubjid param paramcd sexc trta ucpdgr1 usubjid);
	if aval>0 then logaval=log(AVAL); label logaval='logaval=log(AVAL)';
	if BASE>0 then logbase=log(BASE); label logbase='logbase=log(BASE)'; 
run;
data work.addxb; 
set work.addx(keep=avisit aval avalu fasfl paramcd param sexc trta ucpdgr1 usubjid);
	if aval>0 then logaval=log(AVAL); label logaval='logaval=log(AVAL)';
run;

***********************************************************************************************
End of First: Load all these data sets. They will be used to construct new data sets as needed:
***********************************************************************************************;

*******************************************************************************************
0. Create data set for mixed models analysis, and BLOQ analysis.
*******************************************************************************************;

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
22='COT'
;
run; 		

title3 "FDA Analysis: Mixed models for primary and secondary endpoints";

**data for mixed models;
data work.adbxB;
set work.adbx;

if avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & 
		(paramcd in 
					('UMHBMCRE','U3HPMCRE','USPMACRE','U1OHPCRE',
					'UNNNCRE','U4ABPCRE','U1NACRE','U2NACRE',
					'UOTOLCRE','UCEMACRE','UHEMACRE','UBAPCRE',
					'UHMPMCRE','USBMACRE','UNNALCRE','UNEQCRE',
					'UPGF2CRE', 'UTXB2CRE')  
					or 
					(paramcd in ('CARBXHGB', 'CO') & atpt='08:00-09:30 PM'));
run;
data work.adpcB;
set work.adpc;
if paramcd in ('NIC', 'COT') & '19:00't < atm< '21:00't & avisit='DAY 5' & fasfl='Y' & anl02fl='Y';
run;

data work.bxANDpc;
set work.adbxB work.adpcB;

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

**BLOQFL is the below limit of detection flag:
'Y' is BLOQ, and ''. We will make ''='N' (detected);
if BLOQFL='' then do; BLOQFL='N'; end;
run;

proc freq data=work.bxANDpc; 
title4 '0. Check there are 22 correct BoExp'; 
where myorder ne .; 
tables myorder* paramcd*param/list missing nopercent nocum; 
format param $54. myorder myorder.;
run;

*******************************************************************************************
End of 
0. Create data set for mixed models analysis, and BLOQ analysis
*******************************************************************************************;

*******************************************************************************************
1. Run mixed models for primary, secondary endpoints, risk markers, nicotine, and cotinine
*******************************************************************************************;

**Primary BoExp are 4 that compare reduction THS 2.2 to CC.;
%macro log4(BoExp, title5);**log values with 4 covariates 3 arms;

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.bxANDpc;
	where paramcd="&BoExp";
	class trta sexc ucpdgr1;
	model logaval=logbase trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
	run;

data work.lsmeans_&BoExp;
format note $130.;
set work.lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';
LBRatio=round(exp(upper)*100, 0.01); label LBRatio='LB Ratio';
UBRatio=round(exp(lower)*100, 0.01); label UBRatio='UB Ratio';

Reduction=100-round(exp(estimate)*100, 0.01); label reduction='Reduction';
LBReduction=100-round(exp(lower)*100, 0.01); label LBReduction='LB Reduction';
UBReduction=100-round(exp(upper)*100, 0.01); label UBReduction='UB Reduction';
run;

%mend log4;
*value myorder
1= 'UMHBMCRE'  
2= 'U3HPMCRE' 
3= 'USPMACRE' 
4= 'CARBXHGB' 
;
%log4(UMHBMCRE, "MHBMA(Primary): Tables 27, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(U3HPMCRE, "3-HPMA(Primary): Tables 30, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(USPMACRE, "S-PMA(Primary): Tables 33, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(CARBXHGB, "COHb(Primary): Tables 24, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

**Secondary BoExp;
*value myorder
5= 'CO' 		
6= 'U1OHPCRE' 
7= 'UNNNCRE' 	
8= 'U4ABPCRE' 
;
%log4(CO, "Carbon Monoxide: Table 44 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(U1OHPCRE, "Total 1-OHP: Table 45 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(UNNNCRE, "Total NNN: Table 46 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%log4(U4ABPCRE, "4-ABP: Table 47 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	

*
value myorder
9= 'U1NACRE' 	
10='U2NACRE' 	
11='UOTOLCRE' 
12='UCEMACRE' 
;
%log4(U1NACRE, "1-NA: Table 48 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%log4(U2NACRE, "2-NA: Table 49 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(UOTOLCRE, "O-tol: Table 50 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(UCEMACRE, "CEMA: Tables 51 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

*
value myorder
13='UHEMACRE' 
14='UBAPCRE' 	
15='UHMPMCRE' 
16='USBMACRE' 

17='UNNALCRE' 
18='UNEQCRE' 	
;
%log4(UHEMACRE, "HEMA: Tables 52 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(UBAPCRE, "B[a]P: Table 1 in ZRHR-REXC-04-JP_CSR_addendum v1.0.pdf");
%log4(UHMPMCRE, "3-HPMA: Table 53 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%log4(USBMACRE, "S-BMA: Table 54 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

%log4(UNNALCRE, "Total NNAL: Table 55 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(UNEQCRE, "NEQ: Table 56 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

***Risk markers:
value myorder
19='8-EPI-PGF2 ALPHA'
20='11-DTX-B2'
;
*• Selected risk markers (expressed as quantity excreted and concentration adjusted for creatinine):
8-epi-prostaglandine F2a (8-epi-PGF2a) and 11-dehydrothromboxane B2 (DTX-B2) measured in
24-hour urine on Day 5:;
**See also Table 15.2.4.45 in Clinical Study Report Appendix 15.2 - Tables.pdf; 
%log4(UPGF2CRE, "UPGF2CRE (8-epi-PGF2 Alpha): Table 68 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%log4(UTXB2CRE, "UTXB2CRE (11-DTX-B2): Table 69 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

*
value myorder
21='NIC' 		
22='COT';
%macro univ(BoExp, var);
proc univariate plot data=work.bxANDpc;
title4 "1. Disitribution of &var for &BoExp:";
where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & '19:00't < atm< '21:00't & trta in ('THS 2.2');
class paramcd;
var &var;
format trta avisit sexc $16.;
run;
%mend univ;
%univ(NIC, chg);
%univ(COT, chg);

%macro chgA(BoExp, title5);**chg and 4 covariates and arms THS 2.2 and CC;

title4 "&BoExp";
title5 &title5;

*A. This replicates table 57, 60 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf:;
	ods output Diffs=work.lsmeansA_&BoExp;
	proc mixed data=work.bxANDpc;
	*where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & '19:00't < atm< '21:00't & trta in ('THS 2.2','CC');
	where paramcd="&BoExp" & trta in ('THS 2.2','CC');
	class trta sexc ucpdgr1;
	model chg=base trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	run;

data work.lsmeansA_&BoExp;
format note $130.;
set work.lsmeansA_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';*Not ratio for NIC, just LSMeans;
LBRatio=round(exp(lower)*100, 0.01); label LBRatio='LB Ratio';
UBRatio=round(exp(upper)*100, 0.01); label UBRatio='UB Ratio';

Reduction=100-round(exp(estimate)*100, 0.01); label reduction='Reduction';
LBReduction=100-round(exp(upper)*100, 0.01); label LBReduction='LB Reduction';
UBReduction=100-round(exp(lower)*100, 0.01); label UBReduction='UB Reduction';

DiffLSMeans=round(estimate, 0.01); label DiffLSMeans='Diff LSMeans';
UB=round(lower, 0.01); label UB='UB Diff LSMeans';
LB=round(upper, 0.01); label LB='LB Diff LSMeans';

run;

%mend chg;
%chgA(NIC, "Nicotine: Table 57 (LSMean Differences) in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, analyses of 'chg', SA not reported");
%chgA(COT, "Cotinine: Table 60 (LSMean Differences) in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, analyses of 'chg', SA not reported");

%macro chgB(BoExp, title5);

title4 "&BoExp";
title5 &title5;

*B. This analyzes THS 2.2 vs. SA, not reported in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf:;
	ods output Diffs=lsmeansB_&BoExp;
	proc mixed data=work.bxANDpc;
	*where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & '19:00't < atm< '21:00't & trta in ('THS 2.2','SA');
	where paramcd="&BoExp" & trta in ('THS 2.2','SA');
	class trta sexc ucpdgr1;
	model chg=base trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
	run;

data work.lsmeansB_&BoExp;
format note $130.;
set work.lsmeansB_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';*Not ratio for NIC, just LSMeans;
LBRatio=round(exp(lower)*100, 0.01); label LBRatio='LB Ratio';
UBRatio=round(exp(upper)*100, 0.01); label UBRatio='UB Ratio';

Reduction=100-round(exp(estimate)*100, 0.01); label reduction='Reduction';
LBReduction=100-round(exp(upper)*100, 0.01); label LBReduction='LB Reduction';
UBReduction=100-round(exp(lower)*100, 0.01); label UBReduction='UB Reduction';

DiffLSMeans=round(estimate, 0.01); label DiffLSMeans='Diff LSMeans';
UB=round(lower, 0.01); label UB='UB Diff LSMeans';
LB=round(upper, 0.01); label LB='LB Diff LSMeans';

run;
%mend chg2;
%chgB(NIC, "Nicotine: Table 57 (LSMean Differences) in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, analyses of 'chg', SA not reported");
%chgB(COT, "Cotinine: Table 60 (LSMean Differences) in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, analyses of 'chg', SA not reported");

**Extra: analysis of log(NIC), log(COT):;
*Distribution:;
%univ(NIC, logaval);
%univ(COT, logaval);

**and model:;
%log4(NIC, "Nicotine: Table 57 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, FDA analysis log transformed");
%log4(COT, "Cotinine: Table 60 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf, FDA analysis log transformed");

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
data work.model0;
format BoExpTxt $28. note $154.;
set 
work.lsmeans_UMHBMCRE
work.lsmeans_U3HPMCRE
work.lsmeans_USPMACRE
work.lsmeans_CARBXHGB

work.lsmeans_CO
work.lsmeans_U1OHPCRE
work.lsmeans_UNNNCRE
work.lsmeans_U4ABPCRE
work.lsmeans_U1NACRE
work.lsmeans_U2NACRE
work.lsmeans_UOTOLCRE
work.lsmeans_UCEMACRE
work.lsmeans_UHEMACRE
work.lsmeans_UBAPCRE
work.lsmeans_UHMPMCRE
work.lsmeans_USBMACRE
work.lsmeans_UNNALCRE
work.lsmeans_UNEQCRE

work.lsmeans_UPGF2CRE
work.lsmeans_UTXB2CRE

work.lsmeans_NIC
work.lsmeans_COT
work.lsmeansA_NIC(in=a)
work.lsmeansA_COT(in=a)
work.lsmeansB_NIC(in=a)
work.lsmeansB_COT(in=a)
;

**BLOQFL is the below limit of detection flag. it has two values: 'Y' which is BLOQ, and ''. We will make ''='N':;
if BLOQFL='' then do; BLOQFL='N'; end;

*for reduction, the UB is the LB and vice versa:;

CIReduction='(' || left(compress(put(UBReduction,8.2))) || ',' || left(compress(put(LBReduction,8.2))) ||')';
label CIReduction='CI Reduction';

CIRatio='(' || left(compress(put(UBRatio,8.2))) || ',' || left(compress(put(LBRatio,8.2))) ||')';
label CIRatio='CI Ratio';

CIDiff='(' || left(compress(put(UB,8.2))) || ',' || left(compress(put(LB,8.2))) ||')';
label CIDiff='CI Diff LSMeans';

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

if BoExp='NIC' 		then BoExpTxt='Nicotine (log) (ng/ml)';			
if BoExp='COT' 		then BoExpTxt='Cotinine (log) (ng/ml)';			

if BoExp='NIC' & a	then BoExpTxt='Nicotine (chg) (ng/ml)';					
if BoExp='COT' & a	then BoExpTxt='Cotinine (chg) (ng/ml)';					

run;
data work.modelA work.modelB;
set work.model0;
if trta='THS 2.2' and _trta='CC' then output modelA;
if trta='THS 2.2' and _trta='SA' then output modelB;
run;

data work.model;
merge 
modelA(rename=(BoExp=BoExpCC BoExpTxt=BoExpTxtCC 
				reduction=reductionCC probt=probtCC LSMRatio=LSMRatioCC 
					CIReduction=CIReductionCC CIRatio=CIRatioCC CIDiff=CIDiffCC 
						DiffLSMeans=DiffLSMeansCC)) 
modelB(rename=(BoExp=BoExpSA BoExpTxt=BoExpTxtCC 
				reduction=reductionSA probt=probtSA LSMRatio=LSMRatioSA
					CIReduction=CIReductionSA CIRatio=CIRatioSA CIDiff=CIDiffSA
						DiffLSMeans=DiffLSMeansSA));

label BoExpCC='BoExp' 

probtCC='p-value reduction THS 2.2/ CC' 

reductionCC='Reduction THS 2.2/ CC in %' 
LSMRatioCC='LSM Ratio THS/CC'
DiffLSMeansCC='LSMeans THS-CC'

CIReductionCC='95% C.I. for reduction THS 2.2/ CC' 
CIRatioCC='95% C.I. for ratio THS 2.2/ CC' 
CIDiffCC='95% C.I. for difference THS 2.2- CC' 

reductionSA='Reduction THS 2.2/ SA in %' probtSA='p-value reduction THS 2.2/ SA' 
LSMRatioSA='LSM Ratio THS/SA'
DiffLSMeansSA='LSMeans THS-SA'
CIReductionSA='95% C.I. for reduction THS 2.2/ SA' 
CIRatioSA='95% C.I. for ratio THS 2.2/ SA' 
CIDiffSA='95% C.I. for difference THS 2.2- SA'
;
run;
proc freq data=work.model; 
title4 "0. Check that columns 'BoExpCC', 'BoExpSA' match then, merge was fine"; 
tables BoExpCC*BoExpSA/list; 
run;

**Report D. Sticks or plugs consumption Day 1 to Day 5
avalu='STICKS/DAY' is the sum of sticks per subject per day;
proc tabulate data=work.addx out=work.sticks;
title4 "Report D. Sticks or plugs consumption Day 1 to Day 5";
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

**Report E. Percent of values BLOQ, all arms, at DAY 5;
proc tabulate data=work.bxANDpc out=work.bloq0;
title4 "Report E. Percent of values BLOQ, all arms, at DAY 5";
where paramcd in ('UMHBMCRE','U3HPMCRE','USPMACRE','CARBXHGB',
					'CO','U1OHPCRE','UNNNCRE','U4ABPCRE',
					'U1NACRE','U2NACRE','UOTOLCRE','UCEMACRE',
					'UHEMACRE','UBAPCRE','UHMPMCRE','USBMACRE',
					'UNNALCRE','UNEQCRE',
					'UPGF2CRE','UTXB2CRE'
					'NIC', 'COT') & avisit='DAY 5' & fasfl='Y' & anl02fl='Y';
class myorder paramcd param bloqfl;

tables myorder='BoExp'*param, bloqfl * (N='Subjects'*f=10.0 rowpctn='Row %'*f=10.2) all='Total Subjects'*f=10.0
/misstext='0' rts=40;
format myorder myorder.;
run;
proc sort data=work.bloq0; by myorder; run;
data work.No work.Yes work.Tot;
set work.bloq0(keep=myorder bloqfl N pctn_110);
if bloqfl='N' then output work.No;
if bloqfl='Y' then output work.Yes;
if bloqfl='' then output work.Tot;
run;
data work.bloq(drop=bloqfl pctn_110);
merge work.No(rename=(N=n_No pctn_110=pct_No)) work.Yes(rename=(N=N_Yes pctn_110=pct_Yes)) work.Tot(rename=(N=N_Tot));
by myorder;
if n_Yes in (.) then do; n_Yes=0; pct_yes=0; end;
if pct_yes in (.) then do; pct_t_yes=0; end;
run;

	data work.JP;
	set 
	work.bxANDpc(in=a)
	work.model(in=b)
	work.adlb(in=d)
	work.sticks(in=e)
	work.bloq(in=f);
	if a then bxANDpc=1;
	if b then model=1;
	if d then adlb=1;
	if e then sticks=1;
	if f then bloq=1;
	run;
	proc compare base=rm_THS.JP compare=work.JP;
	title4 "Control changes by comparing old vs. new data sets";
	run;

	*make permanent data:;
	&permanent data rm_THS.JP;**JP=Japan study;
	&permanent set work.JP;
	&permanent run;

title3; title4; title5;

ods pdf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name report &sysdate9..pdf";
proc print noobs label data=work.JP;
title5 "Report A. Reduction in ZRHR-REXC-04-JP";
where trta='THS 2.2' & (_trta='CC' or _trta='SA') & CIDIffCC eq '(.,.)'
& model=1;
var BoExpTxtCC ReductionCC CIReductionCC ReductionSA CIReductionSA note;
run;
proc print noobs label data=work.JP;
title5 "Report B. Ratio in ZRHR-REXC-04-JP";
where trta='THS 2.2' & (_trta='CC' or _trta='SA') & CIDIffCC eq '(.,.)'
& model=1;
var BoExpTxtCC LSMRatioCC CIRatioCC LSMRatioSA CIRatioSA note;
format 
trta _trta $10. note $130.;
run;
proc print noobs label data=work.JP;
title5 "Report C. LSMeans Differences in ZRHR-REXC-04-JP";
where trta='THS 2.2' & (_trta='CC' or _trta='SA') & BoExpCC in ('NIC', 'COT') & CIDIffCC ne '(.,.)'
& model=1;
var BoExpTxtCC DiffLSMeansCC CIDiffCC DiffLSMeansSA CIDiffSA note;
format 
trta _trta $10. note $130.;
run;

**Sticks or plugs consumption Day 1 to Day 5.
avalu='STICKS/DAY' is the sum of sticks per subject per day;
title4; title5;
proc format;
value _table_
1='D1: totals for THS 2.2'
2='D2: by avisit'
3='D3: by cigarette consumption'
4='D4: by avisit and cigarette consumption'
;
run;
proc print noobs label data=work.JP;
title5 "Report D. Sticks or plugs consumption Day 1 to Day 5";
where sticks=1;
by _table_;
var avisit trta ucpdgr1 aval_n aval_mean aval_lclm aval_uclm;
label
_table_='Table'
avisit='avisit'   
trta='arm'     
ucpdgr1='Usual daily cigarette consumption' 
aval_n='N'
aval_mean='Mean'
aval_lclm='LCLM'
aval_uclm='UCLM'
;
format 
avisit trta ucpdgr1 $13.
aval_n 5.0
aval_mean aval_lclm aval_uclm 10.2 
_table_ _table_.;
run;

title4;

proc print noobs label n data=work.JP;
title5 "Report E. Percent of values BLOQ, all arms, at DAY 5";
where bloq=1;
var myorder n_No pct_No N_Yes pct_Yes N_Tot;

label 
myorder='paramcd'
n_No='Detected'
pct_No='% detected'

n_Yes='Undetected (BLOQ)'
pct_Yes='% undetected (BLOQ)'

n_Tot='Total subjects'
;
format pct_: 10.2;
run;
ods pdf close;

/*******************************************************************************************
End of
2. Print clean report
(note: lst and log will be available to compare and check all results)
*******************************************************************************************/

*******************************************************************************************
	3. Other clinical results
*******************************************************************************************;

**Clinical Chemistry:;
%macro meansADLB(BoExp, title5);

title4 "&BoExp";
title5 &title5;

proc means n mean median min max clm data=work.JP maxdec=3;
*where paramcd="&BoExp" & saffl='Y' & parcat1='CLINICAL CHEMISTRY' & anl01fl='Y' & avisit="DAY 6/DISCHARGE" & randfl='Y';
where paramcd="&BoExp" & anl01fl='Y' & avisit="DAY 6/DISCHARGE" & TRTA IN ('THS 2.2', 'CC', 'SA')
& adlb=1;
class trta;
var aval;
output out=means_&BoExp
n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_ lclm=lclm_ uclm=uclm_;
run;

data work.means_&BoExp(drop=n_ mean_ median_ std_ min_ max_ lclm_ uclm_);
set work.means_&BoExp;
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
proc mixed data=work.JP;
where paramcd="&BoExp" & anl01fl='Y' & avisit="DAY 6/DISCHARGE" & TRTA IN ('THS 2.2', 'CC', 'SA')
& adlb=1;;
class trta sexc ucpdgr1;
model logaval=logbase trta sexc ucpdgr1;
lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
run;

data work.lsmeans_&BoExp;
format note $130.;
set work.lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';
reduction=100-round(exp(estimate)*100, 0.01); label reduction='reduction=exp(estimate)';
LB=100-round(exp(lower)*100, 0.01); label LB='LB=exp(lower)';
UB=100-round(exp(upper)*100, 0.01); label UB='UB=exp(upper)';
run;

%mend meansADLB;
%meansADLB(ALT, "ALANINE AMINOTRANSFERASE (IU/L) (change): Table 15.2.6.13 in Clinical Study Report Appendix 15.2 - Tables.pdf");
/*%meansADLB(CHOL, "CHOLESTEROL (change): Table 15.2.6.13 in Clinical Study Report Appendix 15.2 - Tables.pdf");
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
*/
*******************************************************************************************
	End of 3. Other clinical results
*******************************************************************************************;

/*******************************************************************************************
End of FDA Analysis
*******************************************************************************************/

/*proc printto log=log; run;*/

ods pdf close;

/*******************************************************************************************
End of \\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\
Montes de Oca\Programs\rm_MR0000059JP.sas
*******************************************************************************************/






