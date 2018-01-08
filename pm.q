c:`id`cycle`setting1`setting2`setting3`s1`s2`s3`s4`s5`s6`s7`s8`s9`s10`s11`s12`s13`s14`s15`s16`s17`s18`s19`s20`s21;
colStr:"II",(-2+count c)#"F";
/ Training data
d:(colStr;enlist " ")0: `:PM_train.txt;
floatCols:(cols d)where "F"=colStr;
gd:select by id from d;
gid:group d`id;
vgd:value gd
rul:([]rul:raze (vgd`cycle) - (d`cycle )value gid)
d:rul,'d;
d:lbl1:([]lbl1:(d`rul)<=30),'d
d:([]lbl2:(d`rul)<=15),'d
d:([]cyclenorm:d`cycle),'d;

/ Read truth data first and then use
tr:([]remcycles:"I"$read0 `:PM_truth.txt);

/ Testing data
t:(colStr;enlist " ")0: `:PM_test.txt;
gt:select by id from t;
git:group t`id;
vgt:value gt
cycle:([]cycle:(tr`remcycles)+vgt`cycle)
vgt:delete cycle from vgt
vgt:cycle,'vgt
rul:([]rul:raze (vgt`cycle) - (t`cycle )value git)
t:rul,'t;
t:lbl1:([]lbl1:(t`rul)<=30),'t
t:([]lbl2:(t`rul)<=15),'t
t:([]cyclenorm:t`cycle),'t;

\l p.q
npar:.p.import [`numpy;`array;>];
pd:.p.import[`pandas;`DataFrame;*];
/ pre:.p.import[`sklearn;`preprocessing;*];
pre:.p.import `sklearn.preprocessing
mms:pre[`MinMaxScaler;*][];

/ mms:.p.import[`sklearn;`preprocessing;`MinMaxScaler;*][];
floatCols,:`cyclenorm;
/ Normalize training and test data
normalize:{[df] df:pd[npar df];mms[`fit_transform;<;df]};
/ Get only sensor value columns
s:(normalize ':) (flip d floatCols;flip t floatCols)
/ Reconstruct training and testing
d:(flip (`id`cycle`rul`lbl1`lbl2)!d`id`cycle`rul`lbl1`lbl2),'flip floatCols !flip (s 0 )
t:(flip (`id`cycle`rul`lbl1`lbl2)!t`id`cycle`rul`lbl1`lbl2),'flip floatCols !flip (s 1 )

/ LSTM preps
/ Group by id and get only floatCols
tmp:(flip d floatCols )group d`id / Id- wise grouping and indexing
/ Generate sequences for LSTM
seqw:({v:(til(-50+count tmp x))+\:til 50;:(tmp x) v}':);
r:raze seqw key tmp; /15631,50,25
/ Same for labels, too
dl:(d`lbl1)group d`id;ce:count each dl;dl:raze over value (ce-50)# '(d`lbl1)group d`id; / 15631,1
.Q.gc[]

/ LSTM network here
nf:count seqw[0][0][0]; / 25
nout:count dl[0]; / 1
models:.p.import`keras.models;
layers:.p.import`keras.layers;
model:models[`Sequential;*][]; / Instantiating an object here

model[`add;<;layers[`LSTM;<;pykwargs `input_shape`units`return_sequences!((50;nf);100;1)]];
model[`add;<;layers[`Dropout;<;0.2]];
model[`add;<;layers[`LSTM;<;pykwargs `units`return_sequences!(50;0)]];
model[`add;<;layers[`Dropout;<;0.2]];
model[`add;<;layers[`Dense;<;pykwargs `units`activation!(nout;`sigmoid)]];

model[`compile;<;pykwargs `loss`optimizer!(`binary_crossentropy`adam)];
model[`summary;<][];
model[`fit;<;npar r;npar dl;pykwargs `epochs`batch_size`validation_split`verbose!(10;200;0.05;1)]
model[`evaluate;<;npar r;npar dl;pykwargs `verbose`batch_size"(1;200)]
ypreds:model[predict_classes;<;npar r;`verbose pykw 1]

/ test data - take last sequence of each id for testing - meaning, last cycle for each id
tmp:(flip t floatCols )group t`id; / Id- wise grouping and indexing
rt:last each seqw (key tmp) where 50 <= value count each tmp; / Only for cycles >= 50 in length
/ Same for labels, in test data
tl:(t`lbl1)group t`id;tle:count each tl;kt:(key tle) where 50 <= value tle;g:kt! (tle kt);tl:raze over last each value (g-50)#'tl kt;




