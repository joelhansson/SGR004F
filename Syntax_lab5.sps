* Encoding: UTF-8.
* SGR004F, Lab assignment 4, Joel Hansson.

* Descriptives.

FREQUENCIES VARIABLES=pain1 pain2 pain3 pain4 sex age STAI_trait pain_cat cortisol_serum mindfulness    
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=pain1 pain2 pain3 pain4 age STAI_trait pain_cat cortisol_serum mindfulness
  /STATISTICS=MEAN STDDEV MIN MAX.

EXAMINE VARIABLES=pain1 pain2 pain3 pain4 age STAI_trait pain_cat cortisol_serum mindfulness
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


* Recode sex variable to dummy for female.

RECODE sex ('female'=1) ('male'=0) INTO female.
EXECUTE.


* Wide to long dataframe conversion.

VARSTOCASES
  /MAKE pain FROM pain1 pain2 pain3 pain4
  /INDEX=day(4) 
  /KEEP=ID age female STAI_trait pain_cat mindfulness cortisol_serum
  /NULL=KEEP.


* Linear mixed model with random intercept.

MIXED pain WITH age female STAI_trait pain_cat mindfulness cortisol_serum day
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age female STAI_trait pain_cat mindfulness cortisol_serum day | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED.


* Linear mixed model with random intercept and random slope.

MIXED pain WITH age female STAI_trait pain_cat mindfulness cortisol_serum day
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age female STAI_trait pain_cat mindfulness cortisol_serum day | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB SOLUTION
  /RANDOM=INTERCEPT day | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.

RENAME VARIABLES (PRED_1 PRED_2 = pred_int pred_slope).


* Predictions vs observations plots.

VARSTOCASES
  /MAKE pain FROM pain pred_int pred_slope
  /INDEX=obs_or_pred(pain) 
  /KEEP=ID day
  /NULL=KEEP.

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=day MEAN(pain)[name="MEAN_pain"] obs_or_pred 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: day=col(source(s), name("day"), unit.category())
  DATA: MEAN_pain=col(source(s), name("MEAN_pain"))
  DATA: obs_or_pred=col(source(s), name("obs_or_pred"), unit.category())
  GUIDE: axis(dim(1), label("day"))
  GUIDE: axis(dim(2), label("Mean pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obs_or_pred"))
  GUIDE: text.title(label("Multiple Line Mean of pain by day by obs_or_pred"))
  SCALE: linear(dim(2), min(1), max(8))
  ELEMENT: line(position(day*MEAN_pain), color.interior(obs_or_pred), missing.wings())
END GPL.


* Return to the unaltered dataset (before the plots) and calculate day_centered and its squared value.

DATASET ACTIVATE DataSet1.
COMPUTE day_centered=day - 2.5.
EXECUTE.

COMPUTE day_centered_sq=day_centered ** 2.
EXECUTE.


* New linear mixed model with random intercept and random slope, including the second order term of day (with random slope also for the squared term).

MIXED pain WITH age female STAI_trait pain_cat mindfulness cortisol_serum day_centered day_centered_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age female STAI_trait pain_cat mindfulness cortisol_serum day_centered day_centered_sq | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB SOLUTION
  /RANDOM=INTERCEPT day_centered day_centered_sq | SUBJECT(ID) COVTYPE(UN) SOLUTION
  /SAVE=PRED RESID.

RENAME VARIABLES (PRED_1 RESID_1 = pred_q resid_q).


* Plot observations and predicted values.

VARSTOCASES
  /MAKE pain FROM pain pred_q
  /INDEX=obs_or_pred(pain) 
  /KEEP=ID day
  /NULL=KEEP.

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=day pain obs_or_pred MISSING=LISTWISE REPORTMISSING=NO    
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: day=col(source(s), name("day"), unit.category())
  DATA: pain=col(source(s), name("pain"))
  DATA: obs_or_pred=col(source(s), name("obs_or_pred"), unit.category())
  GUIDE: axis(dim(1), label("day"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obs_or_pred"))
  GUIDE: text.title(label("Multiple Line of pain by day by obs_or_pred"))
  SCALE: linear(dim(2), min(1), max(8))
  ELEMENT: line(position(day*pain), color.interior(obs_or_pred), missing.wings())
END GPL.


* Return to the unaltered dataset (before the plots) for model diagnostics.
* Check for influential outliers through line chart.

DATASET ACTIVATE DataSet1.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=day pain ID MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: day=col(source(s), name("day"), unit.category())
  DATA: pain=col(source(s), name("pain"), unit.category())
  DATA: ID=col(source(s), name("ID"), unit.category())
  GUIDE: axis(dim(1), label("day"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("ID"))
  GUIDE: text.title(label("Multiple Line of pain by day by ID"))
  ELEMENT: line(position(day*pain), color.interior(ID), missing.wings())
END GPL.


* Check for influential outliers through boxplots.

EXAMINE VARIABLES=pain BY ID
  /PLOT BOXPLOT.

EXAMINE VARIABLES=resid_q BY ID
  /PLOT BOXPLOT.


* Check for normality of the residuals.

EXAMINE VARIABLES=resid_q
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

EXAMINE VARIABLES=resid_q BY ID
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


* Check for linearity and homoscedasticity.

GRAPH
  /SCATTERPLOT(BIVAR)=pred_q WITH resid_q
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=age WITH resid_q
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=STAI_trait WITH resid_q
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=pain_cat WITH resid_q
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=mindfulness WITH resid_q
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=cortisol_serum WITH resid_q
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=day_centered WITH resid_q
  /MISSING=LISTWISE.


* Check for multicollinearity.

CORRELATIONS
  /VARIABLES=age female STAI_trait pain_cat mindfulness cortisol_serum day_centered day_centered_sq
  /PRINT=TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.


* ANOVA for checking constant variance of residuals across clusters.

COMPUTE resid_q_sq=resid_q ** 2.
EXECUTE.

UNIANOVA resid_q_sq BY ID
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /POSTHOC=ID(TUKEY) 
  /CRITERIA=ALPHA(0.05)
  /DESIGN=ID.


* New dataset with random effect parameters, for normality checks.

DATASET ACTIVATE DataSet4.
EXAMINE VARIABLES=prediction BY parameter
  /PLOT BOXPLOT NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.
