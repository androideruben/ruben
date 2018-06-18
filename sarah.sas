
**http://www2.sas.com/proceedings/sugi22/STATS/PAPER278.PDF;

proc import datafile="H:\Ruben.MontesdeOca\Documents\red trampeo sf semanal 2013-2017.xlsx"
out=work.red_trampeo_2014a dbms=xlsx
replace;
range="2014a$A1:AQ185" ;
run;
data work.red_trampeo_2014(drop=lat long altura t_cnico localidad rename=(var1=id municipio=trt));
set work.red_trampeo_2014a;
proc sort; by id trt;
run;
proc transpose data=work.red_trampeo_2014 out=work.red_trampeo_2014T0(drop=_name_ rename=(col1=y));
by id trt;
run;
data work.red_trampeo_2014T(drop=_label_);
set work.red_trampeo_2014T0;
visit=_label_*1;
run;
**save SAS dataset in trasport format;
libname out xport 'H:\Ruben.MontesdeOca\Documents\sarah.xpt';
data out.sarah;
set work.red_trampeo_2014T;
run;
proc freq data=work.red_trampeo_2014T;
tables id trt visit/list missing;
run;
proc means mean p10 q1 median q3 p90 data=work.red_trampeo_2014T maxdec=1;
class trt;
var y;
run;
proc means n nmiss max data=work.red_trampeo_2014T maxdec=1;
where id='GCB 001';
class trt visit;
var y;
run;


goptions reset=all noborder nocell htext=1 ftext="arial" hby=0 vsize=8 hsize=8;
axis1 label=('Visit') order=(0 to 40 by 2) minor=none;
axis2 label=('Count') order=(0 to 60 by 5) minor=none;
symbol color=black value=dot height=0.5;

proc greplay igout=work.gseg nofs;
delete _all_;
run; quit;
proc greplay igout=work.listing nofs;
delete _all_;
run; quit;
proc gplot data=work.red_trampeo_2014T uniform;
by id;
where id in ('GCB 001','GCB 002','GCB 003','GCB 004');
note justify=right 'ID #byval(ID)';  
plot y*visit/haxis=axis1 vaxis=axis2 frame;
run; 
proc greplay igout=work.gseg tc=sashelp.templt template=h4 nofs;
treplay  1:1  2:2  3:3  4:4;
treplay  1:5  2:6  3:7  4:8;
treplay  1:9 2:10 3:11 4:12;
treplay 1:13 2:14 3:15 4:16;
run;
quit;
proc greplay igout=work.gseg tc=sashelp.templt template=v2 nofs nobyline;
treplay 1:template 2:templat1;
treplay 1: templat2 2: templat3; run;
proc greplay igout=work.gseg tc=sashelp.templt template=v2 nofs nobyline;
treplay 1:templat4 2:templat5; run;
quit;

proc genmod data=work.red_trampeo_2014T;
class id trt;
*model y=visit | trt/d=poisson offset=ltime itprint;
model y=visit | trt/d=poisson  itprint;
repeated subject=id / corrw type=exch;
run;

