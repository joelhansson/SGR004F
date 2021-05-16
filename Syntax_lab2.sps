* Encoding: UTF-8.
* SGR004F, Lab assignment 2, Joel Hansson.

* Descriptives.

FREQUENCIES VARIABLES=pain age sex STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

EXAMINE VARIABLES=pain age STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva
  /PLOT BOXPLOT STEMLEAF HISTOGRAM
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


* Clear value outside possible range of Pain Catastrophizing Scale.

RECODE pain_cat (330=SYSMIS).
EXECUTE.


* Recode string variable sex to dummy for female.

RECODE sex ('male'=0) ('female'=1) INTO female.
EXECUTE.


* Check correlations.

CORRELATIONS
  /VARIABLES=pain age female STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva
  /PRINT=TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.


*Scatterplots.

GRAPH
  /SCATTERPLOT(BIVAR)=age WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=STAI_trait WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=pain_cat WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=mindfulness WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=cortisol_serum WITH pain
  /MISSING=LISTWISE.


* Full model with diagnostics.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age female STAI_trait pain_cat mindfulness cortisol_serum
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.


* Cook's distance scatterplot.

COMPUTE casenum=$CASENUM.
EXECUTE.

GRAPH
  /SCATTERPLOT(BIVAR)=casenum WITH COO_1
  /MISSING=LISTWISE.


* Residual descriptives to check for normality.

EXAMINE VARIABLES=RES_1
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


* Breusch-Pagan test for homoscedasticity.

COMPUTE res_sq=RES_1 ** 2.
EXECUTE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT res_sq
  /METHOD=ENTER age female STAI_trait pain_cat mindfulness cortisol_serum.


* Model comparison.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age female
  /METHOD=ENTER STAI_trait pain_cat mindfulness cortisol_serum.
