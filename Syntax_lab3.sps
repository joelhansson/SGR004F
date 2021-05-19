* Encoding: UTF-8.
* SGR004F, Lab assignment 2, Joel Hansson.

* Extract title from Name.

STRING  title (A16).
COMPUTE title=CHAR.SUBSTR(Name, CHAR.INDEX(Name, ",") + 2, CHAR.INDEX(Name, ".") - (CHAR.INDEX(Name, ",") + 2)).
EXECUTE.


* Create new variable mwc with categories man, woman, child.

IF  (Sex = "male" & Age >= 12) mwc = 0.
IF  (Sex = "female" & Age >= 12) mwc = 1.
IF  (Age < 12) mwc = 2.
VALUE LABELS mwc
  0 'man'
  1 'woman'
  2 'child'.
EXECUTE.


* Assign missing data to mwc category based on title.

IF  (Missing(Age) & title = "Master") mwc = 2.
IF  (Missing(Age) & title <> "Master" & Sex = "female") mwc = 1.
IF  (Missing(Age) & title <> "Master" & Sex = "male") mwc = 0.
EXECUTE.


* mwc dummies.

RECODE mwc (1=1) (MISSING=SYSMIS) (ELSE=0) INTO d_woman.
RECODE mwc (2=1) (MISSING=SYSMIS) (ELSE=0) INTO d_child.
EXECUTE.


* Number of adults in the travel group.

IF  (mwc < 2) adults = 1 + SibSp.
IF  (mwc = 2) adults = Parch.
EXECUTE.


* Number of accomanying children (self not included).

IF  (mwc < 2) children = Parch.
IF  (mwc = 2) children = SibSp.
EXECUTE.


* adults dummy (cases with 0 adults are discarded).

RECODE adults (1=0) (2 thru Highest=1) INTO d_adults.
EXECUTE.


* accomanying children dummiy.

RECODE children (0=0) (ELSE=1) INTO d_children.
EXECUTE.


* pclass dummies.

RECODE Pclass (1=1) (ELSE=0) INTO d_1class.
RECODE Pclass (2=1) (ELSE=0) INTO d_2class.
EXECUTE.


* cabin dummy.

RECODE Cabin (' '=0) (ELSE=1) INTO d_hascabin.
EXECUTE.


* Embarked from Cherbourg dummy.

RECODE Embarked ('C'=1) (ELSE=0) INTO d_cherbourg.
EXECUTE.


* Interaction terms.

COMPUTE int_woman_x_withspouse=d_woman * d_adults.
COMPUTE int_child_x_2parents=d_child * d_adults.
EXECUTE.


* Logistic regression.

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH d_woman d_child d_adults d_children d_1class 
    d_2class d_hascabin d_cherbourg int_woman_x_withspouse int_child_x_2parents
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.


* Bar chart illustrating the effect of more than one adult in the travel group.

GRAPH
  /BAR(GROUPED)=MEAN(Survived) BY mwc BY d_adults
  /INTERVAL CI(95.0).




