* Encoding: UTF-8.
* SGR004F, Lab assignment 4, Joel Hansson.

* Dataset A.

DATASET ACTIVATE DataSet1.


* Descriptives.

FREQUENCIES VARIABLES=pain age sex STAI_trait pain_cat mindfulness cortisol_serum hospital
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat mindfulness cortisol_serum hospital
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

EXAMINE VARIABLES=pain age STAI_trait pain_cat mindfulness cortisol_serum
  /PLOT BOXPLOT STEMLEAF HISTOGRAM
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


* Recode string variable sex to dummy for female.

RECODE sex ('male'=0) ('man'=0) ('female'=1) INTO female.
EXECUTE.


* Null model with only random effects.

MIXED pain WITH age female STAI_trait pain_cat mindfulness cortisol_serum
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=| SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC).


* Linear mixed model.

MIXED pain WITH age female STAI_trait pain_cat mindfulness cortisol_serum
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age female STAI_trait pain_cat mindfulness cortisol_serum | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED.


* Calculate fixed effects variance.

DESCRIPTIVES VARIABLES=FXPRED_1
  /STATISTICS=VARIANCE.


* Dataset B.

DATASET ACTIVATE DataSet2.


* Descriptives.

FREQUENCIES VARIABLES=pain sex age STAI_trait pain_cat cortisol_serum mindfulness hospital
  /ORDER=ANALYSIS.


* Recode string variable sex to dummy for female.

RECODE sex ('male'=0) ('female'=1) INTO female.
EXECUTE.


* Calculate predicted values.

COMPUTE pred_pain=2.762749 - .022589 * age - .200128 * female - .046043 * STAI_trait + .081194 * 
    pain_cat - .183630 * mindfulness + .626308 * cortisol_serum.
EXECUTE.


* Add mean pain score as new variable.

AGGREGATE OUTFILE * MODE ADDVARIABLES
    /mean_pain = MEAN(pain).


* Squared residuals and squared differences between the observations and the mean value.

COMPUTE res_sq = (pain - pred_pain) ** 2.
COMPUTE res_mean_sq = (pain - mean_pain) ** 2.
EXECUTE.


* RSS and TSS.

DESCRIPTIVES VARIABLES=res_sq res_mean_sq
  /STATISTICS=SUM.