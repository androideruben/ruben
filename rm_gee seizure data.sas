%let program_name=gee;

**http://support.sas.com/documentation/cdl/en/statug/67523/HTML/default/viewer.htm#statug_gee_examples02.htm
Example 42.2 Log-Linear Model for Count Data
The following example demonstrates how you can fit a GEE model to count data. 
The data are analyzed by Diggle, Liang, and Zeger (1994). The response is the number 
of epileptic seizures, which was measured at the end of each of eight two-week treatment 
periods over sixteen weeks. The first eight weeks were the baseline period 
(during which no treatment was given), and the second eight weeks were the treatment 
period, during which patients received either a placebo or the drug progabide. 
The question of scientific interest is whether progabide is effective in reducing 
the rate of epileptic seizures;

data seizure;
retain ID Count Visit Trt Age Weeks;
label
Count='number of epileptic seizures';
input
ID Count Visit Trt Age Weeks;
datalines;
104 5 1  0 11 31
104 3 2  0 11 31
104 3 3  0 11 31
104 3 4  0 11 31
106 3 1  0 11 30
106 5 2  0 11 30
106 3 3  0 11 30
106 3 4  0 11 30
107 2 1  0 6 25
107 4 2  0 6 25
107 0 3  0 6 25
107 5 4  0 6 25
114 4 1  0 8 36
114 4 2  0 8 36
114 1 3  0 8 36
114 4 4  0 8 36
116 7 1  0 66 22
116 18 2  0 66 22
116 9 3  0 66 22
116 21 4 0 66 22
118 5 1  0 27 29
118 2 2  0 27 29
118 8 3  0 27 29
118 7 4  0 27 29
123 6 1  0 12 31
123 4 2  0 12 31
123 0 3  0 12 31
123 2 4  0 12 31
126 40 1 0 52 42
126 20 2 0 52 42
126 23 3 0 52 42
126 12 4 0 52 42
130 5 1  0 23 37
130 6 2  0 23 37
130 6 3  0 23 37
130 5 4  0 23 37
135 14 1  0 10 28
135 13 2  0 10 28
135  6 3  0 10 28
135  0 4  0 10 28
141 26 1  0 52 36
141 12 2  0 52 36
141  6 3  0 52 36
141 22 4 0 52 36
145 12 1  0 33 24
145  6 2  0 33 24
145  8 3  0 33 24
145  4 4  0 33 24
201 4 1  0 18 23
201 4 2  0 18 23
201 6 3  0 18 23
201 2 4  0 18 23
202 7 1  0 42 36
202 9 2  0 42 36
202 12 3  0 42 36
202 14 4  0 42 36
205 16 1  0 87 26
205 24 2  0 87 26
205 10 3  0 87 26
205 9  4  0 87 26
206 11 1  0 50 26
206  0 2  0 50 26
206  0 3  0 50 26
206  5 4  0 50 26
210 0 1  0 18 28
210 0 2 0 18 28
210 3 3 0 18 28
210 3 4 0 18 28
213 37 1 0 111 31
213 29 2 0 111 31
213 28 3 0 111 31
213 29 4 0 111 31
215 3 1 0 18 32
215 5 2 0 18 32
215 2 3 0 18 32
215 5 4 0 18 32
217 3 1 0 20 21
217 0 2 0 20 21
217 6 3 0 20 21
217 7 4 0 20 21
219 3 1 0 12 29
219 4 2 0 12 29
219 3 3 0 12 29
219 4 4 0 12 29
220 3 1 0 9 21
220 4 2 0 9 21
220 3 3 0 9 21
220 4 4 0 9 21
222 2 1 0 17 32
222 3 2 0 17 32
222 3 3 0 17 32
222 5 4 0 17 32
226 8 1 0 28 25
226 12 2 0 28 25
226 2 3 0 28 25
226 8 4 0 28 25
227 18 1 0 55 30
227 24 2 0 55 30
227 76 3 0 55 30
227 25 4 0 55 30
230 2 1  0 9 40
230 1 2 0 9 40
230 2 3 0 9 40
230 1 4 0 9 40
234 3 1 0 10 19
234 1 2 0 10 19
234 4 3 0 10 19
234 2 4 0 10 19
238 13 1 0 47 22
238 15 2 0 47 22
238 13 3 0 47 22
238 12 4 0 47 22
101 11 1 1 76 18
101 14 2 1 76 18
101 9 3 1 76 18
101 8 4 1 76 18
102 8 1 1 38 32
102 7 2 1 38 32
102 9 3 1 38 32
102 4 4 1 38 32
103 0 1 1 19 20
103 4 2 1 19 20
103 3 3 1 19 20
103 0 4 1 19 20
108 3 1 1 10 30
108 6 2 1 10 30
108 1 3 1 10 30
108 3 4 1 10 30
110 2 1 1 19 18
110 6 2 1 19 18
110 7 3 1 19 18
110 4 4 1 19 18
111 4 1 1 24 24
111 3 2 1 24 24
111 1 3 1 24 24
111 3 4 1 24 24
112 22 1 1 31 30
112 17 2 1 31 30
112 19 3 1 31 30
112 16 4 1 31 30
113 5 1  1 14 35
113 4 2 1 14 35
113 7 3 1 14 35
113 4 4 1 14 35
117 2 1 1 11 27
117 4 2 1 11 27
117 0 3 1 11 27
117 4 4 1 11 27
121 3 1 1 67 20
121 7 2 1 67 20
121 7 3 1 67 20
121 7 4 1 67 20
122 4 1 1 41 22
122 18 2 1 41 22
122 2 3 1 41 22
122 5 4 1 41 22
124 2 1 1 7 28
124 1 2 1 7 28
124 1 3 1 7 28
124 0 4 1 7 28
128 0 1 1 22 23
128 2 2 1 22 23
128 4 3 1 22 23
128 0 4 1 22 23
129 5 1 1 13 40
129 4 2 1 13 40
129 0 3 1 13 40
129 3 4 1 13 40
137 11 1 1 46 33
137 14 2 1 46 33
137 25 3 1 46 33
137 15 4 1 46 33
139 10 1 1 36 21
139 5 2 1 36 21
139 3 3 1 36 21
139 8 4 1 36 21
143 19 1 1 38 35
143 7 2 1 38 35
143 6 3 1 38 35
143 7 4 1 38 35
147 1 1 1 7 25
147 1 2 1 7 25
147 2 3 1 7 25
147 3 4 1 7 25
203 6 1 1 36 26
203 10 2 1 36 26
203 8 3 1 36 26
203 8 4 1 36 26
204 2 1 1 11 25
204 1 2 1 11 25
204 0 3 1 11 25
204 0 4 1 11 25
207 102 1 1 151 22
207 65 2 1 151 22
207 72 3 1 151 22
207 63 4 1 151 22
208 4 1 1 22 32
208 3 2 1 22 32
208 2 3 1 22 32
208 4 4 1 22 32
209 8 1 1 41 25
209 6 2 1 41 25
209 5 3 1 41 25
209 7 4 1 41 25
211 1 1 1 32 35
211 3 2 1 32 35
211 1 3 1 32 35
211 5 4 1 32 35
214 18 1 1 56 21
214 11 2 1 56 21
214 28 3 1 56 21
214 13 4 1 56 21
218 6 1 1 24 41
218 3 2 1 24 41
218 4 3 1 24 41
218 0 4 1 24 41
221 3 1 1 16 32
221 5 2 1 16 32
221 4 3 1 16 32
221 3 4 1 16 32
225 1 1 1 22 26
225 23 2 1 22 26
225 19 3 1 22 26
225 8 4 1 22 26
228 2 1 1 25 21
228 3 2 1 25 21
228 0 3 1 25 21
228 1 4 1 25 21
232 0 1 1 13 36
232 0 2 1 13 36
232 0 3 1 13 36
232 0 4 1 13 36
236 1 1 1 12 37
236 4 2 1 12 37
236 3 3 1 12 37
236 2 4 1 12 37
;
run;
proc freq;
tables visit;
run;

**The following DATA step creates a log time interval variable for use 
as an offset and an indicator variable for whether the observation is 
for a baseline measurement or a visit measurement. 
Patient 207 is deleted as an outlier, which was done in the 
Diggle et al. (2002) analysis:;
data Seizure;
   set Seizure;
   if ID ne 207;   
   if Visit = 0 then do;
      X1=0;
      Ltime = log(8);
   end;     
   else do;
      X1=1;
      Ltime=log(2);
   end;
run;

**Poisson regression is commonly used to model count data. In this example, the 
log-linear Poisson model is specified by Var(mu)=mu (the Poisson variance function) and a log link function,
log(E(Yij))=beta0+xi1 beta1+xi2 beta2+ xi1 xi2 beta3+ log(tij)

where
    Yij=number of epileptic seizures in interval j

    tij=length of interval j

    xi1= 1: weeks 8-16 (treatment)
		 0: weeks 0-8 (baseline)

    xi2= 1: progabide group
	     0: placebo group

Because the visits represent repeated measurements, the responses from the same individual are correlated 
and inferences need to take this into account. The correlations between the counts are modeled as 
rij=alphai, i neq j (exchangeable correlations).;

ods pdf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm_EXPLORE\4-LMM\results\&program_name &sysdate9..pdf";

ods graphics on;
proc gee data=work.seizure desc plots=histogram;
class ID Visit;
model count=X1 Trt X1*Trt/dist=poisson link=log offset=Ltime;
repeated subject=ID/within=Visit type=unstr covb corrw;
run;
ods graphics off;

ods pdf close;


**http://www.sascommunity.org/planet/blog/category/statistical-graphics/page/6/;
ods pdf file = "\\fda.gov\WODC\CTP_Sandbox\OS\DPHS\StatisticsBranch\Team 2\Montes de Oca\rm_EXPLORE\4-LMM\results\&program_name &sysdate9..pdf";

title "PROC SGPANEL with PANELBY statement";
proc sgpanel data=work.seizure;
  panelby visit / rows=3 layout=rowlattice;
  histogram count;
run;

proc sgplot data=work.seizure;
histogram count/group=visit transparency=0.5; 
density count/type=kernel group=visit; *overlay density estimates;
run;

title "Overlay Histograms with PROC SGPLOT";
proc sgplot data=work.seizure;
  histogram count / binwidth=5 transparency=0.5 name="count" legendlabel="count";
  *histogram SepalLength / binwidth=5 transparency=0.5 name="sepal" legendlabel="Sepal Width";
  density count / type=kernel lineattrs=GraphData1;
  *density SepalLength / type=kernel lineattrs=GraphData2;
  xaxis label="x axis" min=0;
  keylegend "count"/ across=1 position=TopRight location=Inside;
run;
ods pdf close;
