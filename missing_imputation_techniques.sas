/* Step 0: Import the CSV File */
proc import datafile = "/home/u63353163/EPG1V2/practices/ABA_class/c.csv"
            out = work.c
            dbms = CSV replace;
run;

/* If .sas file is in the directory, libname can be used */
*libname c "/home/u63353163/EPG1V2/practices/ABA_class";
*data c;
*set c.c;
*run;

/* Task 1 */ 

/* Descriptives */ 
proc means data = c n nmiss mean std stderr lclm uclm;
		var x1 y_t1 y_t2;
	run;
	
proc freq data=c;
   tables trt x2;
run;

/* Histograms */
proc univariate data=c;
   histogram x1 y_t1 y_t2 / normal;
run;

/* Check only missing data */
proc sql;   
create table missing_c as
   select * from c
   where y_t2=.;
   quit;

proc means data = missing_c n nmiss mean std stderr lclm uclm;
		var x1 y_t1 y_t2;
	run;
	
proc freq data=missing_c;
   tables trt x2; 
run;

/* Histogram for missing data */
proc univariate data=missing_c;
   histogram x1 y_t1 y_t2 / normal; 
run;

/* Task 2 */

/* Data preparation */
data c_mod;
 set c;
 if missing(y_t2) then miss=1; *missing data indicator;
 else miss=0;
 id=_n_; *to join appropriate rows;
 chg = y_t2 - y_t1; *target;
run;

/* Correlation */
proc corr data = c_mod;
	var miss y_t1 x1 x2 trt;
run;

/* Tests */

proc ttest data=c_mod;
   class miss;
   var y_t1;
run;
*reject H0 that means are equal;

proc ttest data=c_mod;
   class miss;
   var x1;
run;
*fail to reject H0 that means are equal;

proc freq data=c_mod;
tables trt*miss / chisq; *H0: variable is independent from another;
run;
*reject H0 that variables are independent;

proc freq data=c_mod;
tables x2*miss / chisq;
run;
*reject H0 that variables are independent;

/* Plots (relationship) */

proc sgplot data=c_mod;
  histogram y_t1 / group=miss fillattrs=(transparency=0.5);
run;

proc sgplot data=c_mod;
  histogram trt / group=miss fillattrs=(transparency=0.5);
run;

proc sgplot data=c_mod;
  histogram x2 / group=miss fillattrs=(transparency=0.5);
run;

/* Task 3 */

/* Testing MCAR vs MAR/MNAR */
proc ttest data = c_mod sides=2;
var trt;
class miss;
run;

/* MCAR */
proc mixed data = c_mod;
class trt;
model chg = trt y_t1 / solution;
lsmeans trt / pdiff=all adjust=tukey;
run;
 
/* MAR */
/* Change nimpute parameter from 10 to 100 in next iteration */
proc mi data = c_mod out=out01 nimpute=100 seed=2012;
class trt x2; 
var trt y_t1 x2 x1 y_t2;     
monotone reg(y_t2 / details); 
run;

/* MNAR */
/* Change nimpute parameter from 10 to 100 in next iteration */
proc mi data = c_mod out=out02 nimpute=100 seed=2012;
class trt x2; 
var trt y_t1 x2 x1 y_t2;     
monotone reg(y_t2 / details);  
mnar adjust(y_t2 / delta= 1 adjustobs=(trt= "2"));*deltas -1,-2,-3,-4,-5;
run;

data out02;
set out01;
chg = y_t2-y_t1;
run;

/* Task 4 */

ods select none;
proc mixed data=out02;
 class trt;
 model chg = y_t1 trt  / solution covb;
 lsmeans trt / pdiff=all adjust=tukey;
 by _imputation_;
 ods output SolutionF=mixparms CovB=mixcovb LSMEANS=lsm01 DIFFS=lsmdiffs01;
run;
ods select all;

* Summarizing parameters;
proc mianalyze parms=mixparms;
class trt;
modeleffects Intercept y_t1 trt;
run;

* Summarizing Least Square Means;
proc mianalyze parms=lsm01;
class trt;
modeleffects trt;
ods output parameterestimates=lsm02;
run;

* Summarizing Least Square Means Differences;
proc mianalyze parms=lsmdiffs01;
class trt;
modeleffects trt;
ods output parameterestimates=lsmdiffs02;
run;
