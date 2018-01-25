\l p.q
npar:.p.import [`numpy;`:array;>];
pd:.p.import[`pandas;`:DataFrame;*];
pre:.p.import `sklearn.preprocessing
mms:pre[`:MinMaxScaler;*][];

c:`id`cycle`setting1`setting2`setting3`s1`s2`s3`s4`s5`s6`s7`s8`s9`s10`s11`s12`s13`s14`s15`s16`s17`s18`s19`s20`s21;
colStr:"II",(-2+count c)#"F";
d:(colStr;enlist " ")0: `:PM_train.txt;
t:(colStr;enlist " ")0: `:PM_test.txt;
k)floatCols:(!+0!d)[&:"F"=colStr];

/ Generate sequences for LSTM
/ 50-row windows for each id
seqw:({k:-50+count tmp x;if[0=k or 1=k;k+:1];v:(til k)+\:til 50;:(tmp x) v}':);
/ Process data
\l inc/pminc.k
d:.pm.pd[d;colStr;"xxxx"];
t:.pm.pd[t;colStr;"test"];

floatCols,:`cyclenorm; / Add a column "cyclenorm"
/ Normalize sensor columns for training and test
normalize:{[df] df:pd[npar df];mms[`:fit_transform;<;df]};
s:(normalize ':) (flip d floatCols;flip t floatCols)
/ Reconstruct training and testing
d:(flip (`id`cycle`rul`lbl1`lbl2)!d`id`cycle`rul`lbl1`lbl2),'flip floatCols !flip (0^'s 0 )
t:(flip (`id`cycle`rul`lbl1`lbl2)!t`id`cycle`rul`lbl1`lbl2),'flip floatCols !flip (0^s 1 )

/ LSTM preps
/ Group by id and get only floatCols
tmp:(flip d floatCols )group d`id / Id- wise grouping and indexing
r:raze seqw key tmp; /15631,50,25
/ Get last (count each) - 50 label values
cdl:count each dl:reverse each (d`lbl1)group d`id;
dl:raze over reverse each (cdl-50) # 'dl;

/ LSTM network here
nf:count r[0][0]; / 25
nout:count dl[0]; / 1
/ Get model - LSTM with dense and dropouts
\l inc/pmnn.q
show "IRIWER";
model:.nn.getModel[nf;nout];
model[`:summary;<][];
show "IRIWER";
/ Train LSTM with training set
model[`:fit;<;npar r;npar dl;pykwargs `epochs`batch_size`validation_split`verbose!(5;200;0.05;1)]
/ Evaluate with training set
show "Evaluating with training set...";
scores:model[`:evaluate;<;npar r;npar dl;pykwargs `verbose`batch_size!(1;200)]
show "Training evaluation score:";
show scores;
/ Make predictions with test set
show "Predicting using training set...";
ypreds:model[`:predict_classes;<;npar r;`verbose pykw 1]
metrics:.p.import `sklearn.metrics;
show "Precision Score:";
show metrics[`:precision_score;<;npar dl;npar ypreds];
show "Recall Score:";
show metrics[`:recall_score;<;npar dl;npar ypreds];

/ Now to handle the test set
tmp:(flip t floatCols )group t`id; / Id- wise grouping and indexing
kt:(key tmp) where 50 <= count each value tmp;
rt:seqw kt;
/ take last sequence of each id for testing - meaning, last cycle for each id
rt:last each rt;
/ Get last (count each) - 50 label values
tl:reverse each (t`lbl1)group t`id;
tle:count each tl;
kt:(key tle) where 50 <= value tle ;
g:kt! (tle kt)
tl:last each reverse each g #' tl kt
tl:((count tl),1)#value tl;

show "Evaluating using test set...";
scorestest:model[`:evaluate;<;npar rt;npar tl;`verbose pykw 2]
show "Test evaluation score:";
show scorestest;

/ Predict using test set
show "Predicting using test set...";
ytpreds:model[`:predict_classes;<;npar rt;`verbose pykw 1]
show "Test Precision Score:";
show metrics[`:precision_score;<;npar tl;npar ytpreds];
show "Test Recall Score:";
show metrics[`:recall_score;<;npar tl;npar ytpreds];
