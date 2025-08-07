libname dane "D:\STUDIA\SGH_mag\SEMESTR_2\Analiza_czasu_trwania";

data tree;
    set dane.TREE_DATA;
run;

proc lifereg data=tree;
model time*event(0)= /dist=weibull;
run;

proc lifereg data=tree;
model time*event(0)= /dist=gamma;
run;


/* AMF */
data tree;
set tree;
if AMF <= 13.4 then AMF_c = 1; 
if 13.4 < AMF <= 18 then AMF_c = 2; 
if 18 < AMF <= 24.445 then AMF_c = 3; 
if AMF > 24.445 then AMF_c = 4; 
run; 

/* EMF -> wywalic z modeli; 1500 NA */
data tree;
set tree;
if EMF='NA' then EMF=-99;
run;

data tree;
set tree;
num_EMF = input(EMF, best32.);
drop EMF;
rename num_EMF=EMF;
run;

data tree;
set tree;
if EMF = -99 then EMF_c = 0;
if EMF>= 0 and EMF <= 13.78 then EMF_c = 1; 
if 13.78 < EMF <= 27.72 then EMF_c = 2; 
if 27.72 < EMF <= 35.71 then EMF_c = 3; 
if EMF > 35.71 then EMF_c = 4; 
run; 

/* Phenolics */
data tree;
set tree;
if Phenolics <= 0.17 then Phenolics_c = 1; 
if 0.17 < Phenolics <= 0.75 then Phenolics_c = 2; 
if 0.75 < Phenolics <= 3.78 then Phenolics_c = 3; 
if Phenolics > 3.78 then Phenolics_c = 4; 
run; 

/* Lignin */
data tree;
set tree;
if Lignin <= 10.355 then Lignin_c = 1; 
if 10.355 < Lignin <= 14.040 then Lignin_c = 2; 
if 14.040 < Lignin <= 21.115 then Lignin_c = 3; 
if Lignin > 21.115 then Lignin_c = 4; 
run; 

/* NSC */
data tree;
set tree;
if NSC <= 11.605 then NSC_c = 1; 
if 11.605 < NSC <= 12.660 then NSC_c = 2; 
if 12.660 < NSC <= 17.275 then NSC_c = 3; 
if NSC > 17.275 then NSC_c = 4; 
run;

proc lifereg data=tree;
class Plot Subplot Species Light_Cat Core Soil Sterile Conspecific Myco SoilMyco AMF_c EMF_C Phenolics_c Lignin_c NSC_c; 
model time*event(0)= Plot Subplot Species Light_Cat Core Soil Sterile Conspecific Myco SoilMyco AMF_c EMF_C Phenolics_c Lignin_c NSC_c / dist=weibull;
run;
*AIC - 2623;

proc lifereg data=tree;
class Plot Species Light_Cal Soil EMF_C Phenolics_c; 
model time*event(0)= Plot Species Light_Cal Soil EMF_C Phenolics_c / dist=weibull;
run;
*AIC - 2612;

proc lifereg data=tree;
class Plot Subplot Species Light_Cat Core Soil Sterile Conspecific Myco SoilMyco AMF_c EMF_C Phenolics_c Lignin_c NSC_c; 
model time*event(0)= Plot Subplot Species Light_Cat Core Soil Sterile Conspecific Myco SoilMyco AMF_c EMF_C Phenolics_c Lignin_c NSC_c / dist=gamma;
run;

proc lifereg data=tree;
class Plot Species Light_Cal Soil EMF_C Phenolics_c; 
model time*event(0)= Plot Species Light_Cal Soil EMF_C Phenolics_c / dist=gamma;
run;

proc lifereg data=tree;
model time*event(0)= /dist=WEIBULL;
bayes seed=123;
ods output PosteriorSample=PS_WEIBULL;
run;

proc lifereg data=tree;
model time*event(0)= /dist=llogistic;
bayes seed=123;
ods output PosteriorSample=PS_LLOGISTIC;
run;

proc lifereg data=tree;
model time*event(0)= /dist=lnormal;
bayes seed=123;
ods output PosteriorSample=PS_LNORMAL;
run;

proc lifereg data=tree;
class Plot Phenolics_c Lignin_c;
model time*event(0)= Plot Phenolics_c Lignin_c / dist=lnormal;
bayes seed=123 nbi=2000 nmc=10000 coeffprior=normal diagnostics=all;
ods output PosteriorSample=PS_LNORMAL;
run;

