* Encoding: UTF-8.
* SGR004F, Lab assignment 6, Joel Hansson.


* Descriptives.

FREQUENCIES VARIABLES=ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 
    ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 sex party liberal
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 
    ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 sex party liberal
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

EXAMINE VARIABLES=ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 
    ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 sex party liberal
  /PLOT BOXPLOT STEMLEAF HISTOGRAM
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


* Correlations.

CORRELATIONS
  /VARIABLES=ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 liberal
  /PRINT=TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.


* Exclude cases with missing values.

COMPUTE missing=NMISS(ar1 to ar28).
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (missing < 1).
EXECUTE.


* Initial PCA.

FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT UNIVARIATE INITIAL EXTRACTION
  /PLOT EIGEN
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /ROTATION NOROTATE
  /METHOD=CORRELATION.


* Chi-squared test of Mahalanobis distances.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT liberal
  /METHOD=ENTER ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 
    ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /SAVE MAHAL.

COMPUTE outlier_p=1 - CDF.CHISQ(MAH_1, 28).
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (outlier_p > .001).
EXECUTE.


* Chi-square vs Mahalanobis distance plot.

SORT CASES BY MAH_1(A).

COMPUTE pval=($CASENUM - .5) / 145.
EXECUTE.

COMPUTE chisq=IDF.CHISQ(pval, 28).
EXECUTE.

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=chisq MAH_1 MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE 
  /FITLINE TOTAL=YES SUBGROUP=NO. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: chisq=col(source(s), name("chisq")) 
  DATA: MAH_1=col(source(s), name("MAH_1")) 
  GUIDE: axis(dim(1), label("chisq")) 
  GUIDE: axis(dim(2), label("Mahalanobis Distance")) 
  GUIDE: text.title(label("Scatter Plot of Mahalanobis Distance by chisq")) 
  ELEMENT: point(position(chisq*MAH_1)) 
END GPL.

* Factor analysis.

FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT UNIVARIATE INITIAL KMO EXTRACTION
  /PLOT EIGEN
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION ML
  /ROTATION NOROTATE.


* Unrotated with 3 factors.

FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT UNIVARIATE INITIAL KMO EXTRACTION
  /FORMAT SORT BLANK(.20)
  /PLOT EIGEN
  /CRITERIA FACTORS(3) ITERATE(25)
  /EXTRACTION ML
  /ROTATION NOROTATE.


* Direct oblimin rotation with 3 factors.

FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT SORT BLANK(.20)
  /PLOT EIGEN
  /CRITERIA FACTORS(3) ITERATE(25)
  /EXTRACTION ML
  /CRITERIA ITERATE(25) DELTA(0)
  /ROTATION OBLIMIN.


* Final factor structure, seven items excluded after several iterations (excluded from the code).

FACTOR
  /VARIABLES ar2 ar4 ar5 ar6 ar7 ar9 ar10 ar12 ar13 ar15 ar17 ar19 ar20 ar21 ar23 ar24 ar25 ar26 
    ar27 ar28 ar18
  /MISSING LISTWISE 
  /ANALYSIS ar2 ar4 ar5 ar6 ar7 ar9 ar10 ar12 ar13 ar15 ar17 ar19 ar20 ar21 ar23 ar24 ar25 ar26 
    ar27 ar28 ar18
  /PRINT UNIVARIATE INITIAL KMO EXTRACTION ROTATION
  /FORMAT SORT BLANK(.20)
  /CRITERIA FACTORS(3) ITERATE(25)
  /EXTRACTION ML
  /CRITERIA ITERATE(25) DELTA(0)
  /ROTATION OBLIMIN
  /SAVE REG(ALL).


* Linear regression model for prediction of liberal based on the factor scores.

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT liberal
  /METHOD=ENTER FAC1_1 FAC2_1 FAC3_1.

