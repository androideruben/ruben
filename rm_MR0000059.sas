	%let program_name=rm_MR0000059;

	/*
	proc printto log="\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\programs\rm_analysis &sysdate9..log" new; run;
	*/

	%put code executed on &sysdate9. at &systime.;
	data _null_; call symput('begintime',time()); run;

	options source nostimer nocenter pagesize = 60 linesize = 132 noquotelenmax orientation=landscape
	mprint mlogic validvarname=v7;
	ods noproctitle;


/**************************************************************************************************

Purpose of rm_MR0000059.sas:

	I. FDA analyses: 
		A. Mixed models for primary and secondary endpoints
		B. Sample size and power
		C. Means, mixed and frequencies for exploratory
		D. Other clinical results
		E. Printout clean report (note: lst available to compare and check all results.)

	MRTPA data folders are:
		\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\data\ADaM\
		\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\04 REXC04JP\data\sdtm\

Programmer: Ruben Montes de Oca, CTP\OS\Statistics Branch
	Date started 3/28/2017. 
	See time stamps &sysdate9 for current date.

ods rtf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name &sysdate9..rtf";
ods rtf close;
***************************************************************************************************/

title1 "MRTPA\PMPSA 04 MR0000059: ZRHR-REXC-04-JP";
title2;
footnote1 "RM\CTP\OS &program_name..sas executed on &sysdate9. at &systime.";

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
	
	/*
	proc contents out=contents_&data data=&data;
	run;
	*/

	data &data;
	set &data;

	*this array groups all the character variables together into one array;
  	array vars(*) _character_;                                                                                                            
  	do i=1 to dim(vars); 
                                                                                                                 
	*use the UPCASE function to uppercase each value;                                                                                     
    vars(i)=upcase(vars(i));                                                                                                            
  	end;                                                                                                                                  
  	drop i;    

	proc sort nodupkey; by _all_;
	run;

	%mend xpt;

%xpt(adam, adbx);
%xpt(adam, adpc);
%xpt(adam, adpp);**Warning: adam.ADPP does not have 'BASE';
%xpt(adam, adlb);

%xpt(adam, adsl);
%xpt(adam, ADQSSU);
%xpt(adam, ADQSND);
%xpt(adam, ADQSPA);
%xpt(adam, ADXT);
%xpt(adam, ADDX);

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
	A. Mixed models for primary and secondary endpoints
*******************************************************************************************;

title3 "I. FDA analyses: Mixed models for primary and secondary endpoints";

**data for mixed models;
data work.rm_04JPA;
set work.adbx;
if paramcd in ('UMHBMCRE','U3HPMCRE','USPMACRE') & avisit='DAY 5' & fasfl='Y' & anl02fl='Y'
	or paramcd in ('CARBXHGB') & avisit='DAY 5' & atpt='08:00-09:30 PM' & fasfl='Y' & anl02fl='Y'

	or paramcd in ('CO') & avisit='DAY 5' & atpt='08:00-09:30 PM' & fasfl='Y' & anl02fl='Y'
	or paramcd in ('U1OHPCRE','UNNNCRE','U4ABPCRE','U1NACRE','U2NACRE','UOTOLCRE','UCEMACRE',
					'UHEMACRE','UBAPCRE','UHMPMCRE','USBMACRE','UNNALCRE','UNEQCRE') 
					& avisit='DAY 5' & fasfl='Y' & anl02fl='Y';
run;
data work.rm_04JPB;
set work.adpc;
run;
data work.rm_04JPC;**Nicotine and Cotinine using chg=aval-base;
set work.adpp;**adam.ADPP does not have 'BASE';
run;
data work.rm_04JP;**Max and Avg for nicotine, cotinine:;
set work.rm_04JPA work.rm_04JPB work.rm_04JPC;
run;

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
%mixedADBX(UMHBMCRE, "MHBMA: Tables 27, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(U3HPMCRE, "3-HPMA: Tables 30, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(USPMACRE, "S-PMA: Tables 33, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(CARBXHGB, "COHb: Tables 24, 34 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

%mixedADBX(CO, "Carbon Monoxide: Table 44 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(U1OHPCRE, "Total 1-OHP: Table 45 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UNNNCRE, "Total NNN: Table 46 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%mixedADBX(U4ABPCRE, "4-ABP: Table 47 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%mixedADBX(U1NACRE, "1-NA: Table 48 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%mixedADBX(U2NACRE, "2-NA: Table 49 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UOTOLCRE, "O-tol: Table 50 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UCEMACRE, "CEMA: Tables 51 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UHEMACRE, "HEMA: Tables 52 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UBAPCRE, "B[a]P: Table 1 in ZRHR-REXC-04-JP_CSR_addendum v1.0.pdf");
%mixedADBX(UHMPMCRE, "3-HMPMA: Table 53 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");	
%mixedADBX(USBMACRE, "S-BMA: Table 54 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UNNALCRE, "Total NNAL: Table 55 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX(UNEQCRE, "NEQ: Table 56 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

**Nicotine and Cotinine using chg=aval-base;
%macro mixedADPC(BoExp, title5);

title4 "&BoExp";
title5 &title5;

/* A. This part for being consistent using logaval and reporting ratio, not change. Includes SA analysis.
	see also Listing 15.4.4.41 in Stat Output.pdf:;
ods output Diffs=lsmeans_&BoExp;
proc mixed data=work.rm_04JP;
where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & '19:00't < atm< '21:00't;
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
run;*/

*B. This replicates table 57 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf:;
	ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.rm_04JP;
	where paramcd="&BoExp" & avisit='DAY 5' & fasfl='Y' & anl02fl='Y' & '19:00't < atm< '21:00't & trta in ('THS 2.2','CC');
	class trta sexc ucpdgr1;
	model chg= base trta sexc ucpdgr1;
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
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
%mixedADPC(NIC, "Nicotine: Table 57 in ZRHR-REXC-04-JP_CSR_Final_v1.0 using 'chg' instead of logaval. LSMeans Ratio is in fact LSMeans differences");
%mixedADPC(COT, "Cotinine: Table 60 in ZRHR-REXC-04-JP_CSR_Final_v1.0 using 'chg' instead of logaval. LSMeans Ratio is in fact LSMeans differences");

**Max and Avg for nicotine, cotinine:;
%macro mixedADPP(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.rm_04JP;
	where paramcd="&BoExp" & trta in ('THS 2.2','CC'); 

	class trta sexc ucpdgr1;
	model logaval= trta sexc ucpdgr1; **adam.ADPP does not have 'BASE';
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	run;

data lsmeans_&BoExp;
format note $130.;
set lsmeans_&BoExp;
BoExp="&BoExp";
note=&title5;

LSMRatio=round(exp(estimate)*100, 0.01); label LSMRatio='LSM Ratio';
reduction=100-round(exp(estimate)*100, 0.01); label reduction='reduction=exp(estimate)';
UB=round(exp(lower)*100, 0.01); label UB='UB=exp(upper)';**LB not for reduction, but for LSMRatio. LB becomes UB and vice versa;
LB=round(exp(upper)*100, 0.01); label LB='LB=exp(lower)';
run;

%mend mixedADPP;
%mixedADPP(NCAVG, "Nicotine average: Table 59 in ZRHR-REXC-04-JP_CSR_Final_v1.0 (no data for SA, see Listing 15.4.4.39 in Stat Output.pdf)");
%mixedADPP(NCMAX, "Nicotine peak: Table 59 in ZRHR-REXC-04-JP_CSR_Final_v1.0. (no data for SA, see Listing 15.4.4.39 in Stat Output.pdf)");
%mixedADPP(CCAVG, "Cotinine average: Table 62 in ZRHR-REXC-04-JP_CSR_Final_v1.0 (no data for SA, see Listing 15.4.4.39 in Stat Output.pdf)");
%mixedADPP(CCMAX, "Cotinine peak: Table 62 in ZRHR-REXC-04-JP_CSR_Final_v1.0 (no data for SA, see Listing 15.4.4.39 in Stat Output.pdf)");

title4;
title5;

**report;
data work.report0;
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

LSMEANS_NIC
LSMEANS_COT

LSMEANS_NCAVG
LSMEANS_NCMAX
LSMEANS_CCAVG
LSMEANS_CCMAX
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
if BoExp='UHMPMCRE' then BoExpTxt='3-HMPMA (ng/mg creat)';
if BoExp='USBMACRE' then BoExpTxt='S-BMA (pg/mg creat)';
if BoExp='UNNALCRE' then BoExpTxt='Total NNAL(pg/mg creat)';
if BoExp='UNEQCRE' 	then BoExpTxt='NEQ (mg/g creat)';

if BoExp='NIC' 		then BoExpTxt='Nicotine (chg) (ng/ml)';
if BoExp='COT' 		then BoExpTxt='Cotinine (chg) (ng/ml)';

if BoExp='NCAVG' 	then BoExpTxt='Nicotine average (ng/ml)';
if BoExp='NCMAX' 	then BoExpTxt='Nicotine peak (ng/ml)';
if BoExp='CCAVG' 	then BoExpTxt='Cotinine average (ng/ml)';
if BoExp='CCMAX' 	then BoExpTxt='Cotinine peak (ng/ml)';
run;
data work.reportA work.reportB;
set work.report0;
if trta='THS 2.2' and _trta='CC' then output reportA;
if trta='THS 2.2' and _trta='SA' then output reportB;
run;

**This data set will be printed as the ods rtf file in
'E. Printout clean report (note: lst available to compare and check all results.)';

data report;
merge 
reportA(rename=(BoExp=BoExpCC BoExpTxt=BoExpTxtCC reduction=reductionCC CI=CICC probt=probtCC LSMRatio=LSMRatioCC)) 
reportB(rename=(BoExp=BoExpSA BoExpTxt=BoExpTxtCC reduction=reductionSA CI=CISA probt=probtSA LSMRatio=LSMRatioSA));

label BoExpCC='BoExp' 
reductionCC='Reduction THS 2.2/ CC in %' CICC='95% C.I. THS 2.2/ CC' probtCC='p-value THS 2.2/ CC' LSMRatioCC='LSM Ratio THS/CC'
reductionSA='Reduction THS 2.2/ SA in %' CISA='95% C.I. THS 2.2/ SA' probtSA='p-value THS 2.2/ SA' LSMRatioSA='LSM Ratio THS/SA';

run;
proc freq data=work.report; title4 "Check that columns 'BoExpCC', 'BoExpSA' match then, merge was fine"; 
tables BoExpCC*BoExpSA/list; 
run;

proc datasets lib=work nolist; 
**delete data sets that may have common name in the following parts of this program;
  delete lsmeans:; 
quit; 
run;

*******************************************************************************************
	End of A. Mixed models for primary and secondary endpoints
*******************************************************************************************;

*******************************************************************************************
	B. Sample size and power
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
	End of B. Sample size and power
*******************************************************************************************;

*******************************************************************************************
	C. Means, mixed and frequencies for exploratory
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

/*
proc print noobs data=means_&BoExp(drop=_type_);
*var BoExpTxtCC LSMRatioCC reductionCC CICC LSMRatioSA reductionSA CISA note;
format 
trta _trta avisit $10.;
run;
*/
%mend ExploreADBX;
%ExploreADBX(UAMES24U, "Ames Mutagenecity Test (YG1024): Tables 65 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");**similar results, not identical;

*• Questionnaire of Smoking Urges (brief version) total score, Factor 1 (relief) and Factor 2 (reward):;
%macro ExploreADQSSU(BoExp, title5);

title4 "&BoExp";
title5 &title5;

/*
ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.ADQSSU;
	where paramcd="&BoExp" & avisit in ('DAY 5') & fasfl='Y';

	class trta sexc ucpdgr1 avisit;
	model chg=base trta sexc ucpdgr1 avisit; **adam.ADPP does not have 'BASE';
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
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
*/

proc means n mean median min max clm data=work.ADQSSU maxdec=3;
where paramcd="&BoExp" & avisit in ('DAY 5') & fasfl='Y';
class trta;
var aval;
output out=means_&BoExp
n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_ lclm=lclm_ uclm=uclm_;
run;

data means_&BoExp(drop=n_ mean_ median_ std_ min_ max_ lclm_ uclm_);
format note $130.;
set means_&BoExp;
*if trta ne '' & avisit ne '';
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

/*
proc print noobs data=means_&BoExp(drop=_type_);
*var BoExpTxtCC LSMRatioCC reductionCC CICC LSMRatioSA reductionSA CISA note;
format 
trta _trta avisit $10.;
run;
*/

%mend ExploreADQSSU;
**similar results, not identical for LSMeans Table 72* in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf;
%ExploreADQSSU(QSUFACT1, "QSU-brief Questionnaire: Table 15.2.4.43 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSSU(QSUFACT2, "QSU-brief Questionnaire: Table 15.2.4.43 in Clinical Study Report Appendix 15.2 - Tables.pdf");
**Minnesota Nicotine Withdrawal Scale (MNWS) total score, revised version on Day 5;
%macro ExploreADQSND(BoExp, title5);

/*
title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.ADQSND;
	where paramcd="&BoExp" & fasfl='Y' & avisit in ('DAY 2', 'DAY 3', 'DAY 4', 'DAY 5', 'DAY 6/DISCHARGE');

	class trta sexc ucpdgr1 avisit;
	model chg=base trta sexc ucpdgr1 avisit; **adam.ADPP does not have 'BASE';
	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
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
*/

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

%mend ExploreADQSND;
**See also Table 73 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf;
%ExploreADQSND(MNWRWDS1, "Minnesota Nicotine Withdrawal Scale (MNWS)- Total Score 1: Table 15.2.4.45 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSND(MNWRWDS2, "Minnesota Nicotine Withdrawal Scale (MNWS)- Total Score 2: Table 15.2.4.45 in Clinical Study Report Appendix 15.2 - Tables.pdf");

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

/*
proc print noobs data=means_&BoExp(drop=_type_);
*var BoExpTxtCC LSMRatioCC reductionCC CICC LSMRatioSA reductionSA CISA note;
format 
trta _trta avisit $10.;
run;
*/
%mend ExploreADBX;
**similar results, not identical in Table 73 ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf;
%ExploreADBX(CYP2A6, "CYP2A6 enzymatic activity Day 6: Table 15.2.4.51 in Clinical Study Report Appendix 15.2 - Tables.pdf");

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
reduction=.; label reduction='reduction=exp(estimate)';**not reported;
LB=round(exp(upper)*100, 0.01); label LB='LB=exp(upper)';
UB=round(exp(lower)*100, 0.01); label UB='UB=exp(lower)';
run;

%mend mixedADBX2;
**See also Table 15.2.4.45 in Clinical Study Report Appendix 15.2 - Tables.pdf; 
%mixedADBX2(UPGF2CRE, "UPGF2CRE (8-epi-PGF2 Alpha): Table 68 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%mixedADBX2(UTXB2CRE, "UTXB2CRE (11-DTX-B2): Table 69 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
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
-Craving Reduction subscale;
%macro ExploreADQSPA(BoExp, title5);

title4 "&BoExp";
title5 &title5;

ods output Diffs=lsmeans_&BoExp;
	proc mixed data=work.ADQSPA;
	where paramcd="&BoExp" & fasfl='Y';

	class trta sexc ucpdgr1;
	*model chg= trta sexc ucpdgr1;
	model chg= base trta sexc ucpdgr1;**including 'base' in model for 'chg' replicates results in Table 74;

	lsmeans trta/pdiff=control('CC') alpha=0.05 cl;
	*lsmeans trta/pdiff=control('SA') alpha=0.05 cl;
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
%ExploreADQSPA(MCEQA,    "MCEQ- Aversion: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf (check C.I.)");
%ExploreADQSPA(MCEQCR,   "MCEQ- Craving Reduction: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf (check C.I.)");
%ExploreADQSPA(MCEQERTS, "MCEQ- Enjoyment of respiratory tract sensation: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf (check C.I.)");
%ExploreADQSPA(MCEQPR,	 "MCEQ- Psychological Reward: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf (check C.I.)");
%ExploreADQSPA(MCEQSS, 	 "MCEQ- Smoking Satisfaction: Table 74 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf (check C.I.)");

**• Smoking pattern: human smoking topography (HST) parameters and HST questionnaire.
-HST parameters (Table 14 and Table 15).
-HST questionnaire;
data adxtsort;

set adxt;
if paramcd in (
"ANPC", 
"ATVOL",
"AAVGVI",
"AAVGDI",
"ATDI",
"AAVGQMI",
"AAVGQCI",
"ATII",
"ATDFI",
"ATWI",
"AAVGPMI",
"AAVGPCI",
"ASMINT",
"APTI",
"APFEQ"
);
logaval=log(aval);
logbase=log(base);
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
%ExploreADXT(ANPC,     "HST- Total number of puffs: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");**similar results, not identical;
%ExploreADXT(ATVOL,    "HST- Total puff volume (ml): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(AAVGVI,   "HST- Average puff volume (ml): Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(AAVGDI,   "HST- Average puff duration: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(ATDI,     "HST- Total puff duration: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(AAVGQMI,  "HST- Average flow: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(AAVGQCI,  "HST- Average peak flow: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(ATII,     "HST- Total inter puff interval average: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(ATDFI,    "HST- Total smoking duration average: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(ATWI,     "HST- Total work average: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(AAVGPMI,  "HST- Average pressure drop: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(AAVGPCI,  "HST- Average peak pressure drop: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(ASMINT,   "HST- Smoking intensity: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(APTI,     "HST- Puffing time index: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");
%ExploreADXT(APFEQ,    "HST- Puff frequency: Table 75 in ZRHR-REXC-04-JP_CSR_Final_v1.0.pdf");

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
proc freq data=work.ADQSPA;
*where paramcd="&BoExp" & avisit in('DAY 0' 'DAY 4') & fasfl ='Y' & trta in ('THS 2.2', 'CC') & parcat1 in ('HUMAN SMOKING TOPOGRAPHY QUESTIONNAIRE');**see t_hstqu.pdf;
where paramcd="&BoExp" & avisit in('DAY 0' 'DAY 4') & trta in ('THS 2.2', 'CC') & parcat1 in ('HUMAN SMOKING TOPOGRAPHY QUESTIONNAIRE');**see t_hstqu.pdf;
tables avisit*aval*trta/nopercent;
format aval aval.;
run;

%mend ExploreADQSPA;
***similar results, not identical;
%ExploreADQSPA(HSSMOK,  "HST- The smoking of the CC/Products differs with the device: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSPA(HSENJ,   "HST- You enjoy smoking with the device as much as without it: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSPA(HSTASTE, "HST- The taste of the CC /products is different with the device: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSPA(HSEASY,  "HST- The device is easy to use: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSPA(HSDISTU, "HST- Your smoking is disturbed by the device: Table 15.2.4.60* in Clinical Study Report Appendix 15.2 - Tables.pdf");
title4; title5;
**end of Solution of 3...;

proc tabulate data=work.addx;
title4 "Sticks or plugs consumption";

**avalu='STICKS/DAY' is the sum of sticks per subject per day;
where trta='THS 2.2' & paramcd='DTHS2_2' & avalu='STICKS/DAY';

*class trta paramcd avisit ucpdgr1;
class trta paramcd avisit;

var aval;

*tables (trta='Arm'*paramcd='Daily THS 2.2 Administration'*avisit='Day'*ucpdgr1='ucpdgr1'),
	aval=''*(n='N'*f=10.0 min='Min'*f=10.0 mean='Mean'*f=10.1 max='Max'*f=10.0)/rts= 35;

tables (trta='Arm'*paramcd='Daily THS 2.2 Administration'*avisit='Day'),
	aval=''*(n='N'*f=10.0 mean='Mean'*f=10.1 LCLM='LCLM' UCLM='UCLM')/rts= 35;

run;

**Theses data sets will be printed as the ods rtf file in
'E. Printout clean report (note: lst available to compare and check all results.)';

***Exploratory report:;
data Exploremeans0;
format note $130.;
set 

means_UAMES24U(in=a1) 
means_CYP2A6(in=a2) 

means_QSUFACT1(in=a3)
means_QSUFACT2(in=a4)

means_MNWRWDS1(in=a5)
means_MNWRWDS2(in=a6)
;

if a1 then data='UAMES24U';
if a2 then data='CYP2A6';

if a3 then data='QSUFACT1';
if a4 then data='QSUFACT2';

if a5 then data='MNWRWDS1';
if a6 then data='MNWRWDS2';

*for reduction, the UB is the LB and vice versa:;
CI='(' || left(compress(put(LCLM,8.2))) || ',' || left(compress(put(UCLM,8.2))) ||')';

run;
data work.ExploremeansA work.exploremeansB work.exploremeansC;
set work.exploremeans0(keep=data trta avisit n mean ci note);
if trta='THS 2.2' then output ExploremeansA;
if trta='CC' then output exploremeansB;
if trta='SA' then output exploremeansC;
run;
data exploremeans;
merge 
ExploremeansA(rename=(trta=trtaTHS avisit=avisitTHS n=nTHS mean=meanTHS ci=ciTHS))
ExploremeansB(rename=(trta=trtaCC avisit=avisitCC n=nCC mean=meanCC ci=ciCC))
ExploremeansC(rename=(trta=trtaSA avisit=avisitSA n=nSA mean=meanSA ci=ciSA));

*label 
meansTHS='Means THS 2.2' CITHS='95% C.I. THS 2.2' 
meansCC='Means CC' CICC='95% C.I. CC' 
meansCC='Means SA' CISA='95% C.I. SA' 
;
run;
proc freq data=work.exploremeans; 
title4 "Check"; 
tables data*trtaTHS*trtaCC*trtaSA/list missing; 
run;

data explorelsmeans0;
set
lsmeans_UPGF2CRE
lsmeans_UTXB2CRE

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
data work.explorelsmeansA work.explorelsmeansB;
set work.explorelsmeans0;
if trta='THS 2.2' and _trta='CC' then output explorelsmeansA;
if trta='THS 2.2' and _trta='SA' then output explorelsmeansB;
run;
data explorelsmeans;
merge 
explorelsmeansA(rename=(BoExp=BoExpCC BoExpTxt=BoExpTxtCC reduction=reductionCC CI=CICC probt=probtCC LSMRatio=LSMRatioCC)) 
explorelsmeansB(rename=(BoExp=BoExpSA BoExpTxt=BoExpTxtCC reduction=reductionSA CI=CISA probt=probtSA LSMRatio=LSMRatioSA));

label BoExpCC='BoExp' 
reductionCC='Reduction THS 2.2/ CC in %' CICC='95% C.I. THS 2.2/ CC' probtCC='p-value THS 2.2/ CC' LSMRatioCC='LSM Ratio THS/CC'
reductionSA='Reduction THS 2.2/ SA in %' CISA='95% C.I. THS 2.2/ SA' probtSA='p-value THS 2.2/ SA' LSMRatioSA='LSM Ratio THS/SA';

run;

proc freq data=work.explorelsmeans; title4 "Check that left and rigth columns match"; 
tables BoExpCC*BoExpSA/list missing; 
run;


*******************************************************************************************
	End of C. Means, mixed and frequencies for exploratory
*******************************************************************************************;

*******************************************************************************************
	D. Other clinical results
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

/*
proc print noobs data=means_&BoExp(drop=_type_);
*var BoExpTxtCC LSMRatioCC reductionCC CICC LSMRatioSA reductionSA CISA note;
format 
trta _trta avisit $10.;
run;
*/

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

/*
proc print noobs data=means_&BoExp(drop=_type_);
*var BoExpTxtCC LSMRatioCC reductionCC CICC LSMRatioSA reductionSA CISA note;
format 
trta _trta avisit $10.;
run;
*/

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
	End of D. Other clinical results
*******************************************************************************************;

*******************************************************************************************
	E. Printout clean report (note: lst available to compare and check all results.)
*******************************************************************************************;
title3; title4; title5;

ods rtf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\MRTPA\PMPSA MR0000059+\Montes de Oca\Programs\results\&program_name &sysdate9..rtf";
proc print noobs label data=work.report;
title5 "Report: Primary and Secondary BoExp ZRHR-REXC-04-JP";
where trta='THS 2.2' & (_trta='CC' or _trta='SA');
var BoExpTxtCC LSMRatioCC reductionCC CICC LSMRatioSA reductionSA CISA note;
format 
trta _trta $10. note $130.;
run;
proc print noobs label data=Exploremeans;
title5 "Report: Exploratory ZRHR-REXC-04-JP";
var data avisitTHS nTHS meanTHS ciTHS nCC meanCC ciCC nSA meanSA ciSA note;
label 
avisitTHS='avisit' nTHS='n THS' meanTHS='Mean THS' ciTHS='95% C.I. THS'
nCC='n CC' meanCC='Mean CC' ciCC='95% C.I. CC'
nSA='n SA' meanSA='Mean SA' ciSA='95% C.I. SA';
format trta: avisit: $10. note $130.;
run;
proc print noobs label data=work.explorelsmeans;
title5 "Report: Exploratory ZRHR-REXC-04-JP";
where trta='THS 2.2' & (_trta='CC' or _trta='SA');
var BoExpTxtCC LSMRatioCC reductionCC CICC LSMRatioSA reductionSA CISA note;
format 
trta _trta $10. note $130.;
run;

%ExploreADQSPA(HSSMOK,  "HST- The smoking of the CC/Products differs with the device: Table 15.2.4.60 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSPA(HSENJ,   "HST- You enjoy smoking with the device as much as without it: Table 15.2.4.60 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSPA(HSTASTE, "HST- The taste of the CC /products is different with the device: Table 15.2.4.60 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSPA(HSEASY,  "HST- The device is easy to use: Table 15.2.4.60 in Clinical Study Report Appendix 15.2 - Tables.pdf");
%ExploreADQSPA(HSDISTU, "HST- Your smoking is disturbed by the device: Table 15.2.4.60 in Clinical Study Report Appendix 15.2 - Tables.pdf");

ods rtf close;

*******************************************************************************************
	End of E. Printout clean report (note: lst available to compare and check all results.)
*******************************************************************************************;

/*******************************************************************************************
End of I. FDA analyses
*******************************************************************************************;

/*proc printto log=log; run;*/

*ods rtf close;









