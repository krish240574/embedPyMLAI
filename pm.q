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
q)d:lbl1:([]lbl1:(d`rul)<=30),'d
q)d:([]lbl2:(d`rul)<=15),'d
d:([]cyclenorm:d`cycle),'d;

/ Read truth data first and then use
tr:([]remcycles:"I"$read0 `:PM_truth.txt);

/ Testing data
t:(colStr;enlist " ")0: `:PM_test.txt;
gt:select by id from t;
git:group t`id;
vgt:value gt
q)cycle:([]cycle:(tr`remcycles)+vgt`cycle)
q)vgt:delete cycle from vgt
q)vgt:cycle,'vgt
rul:([]rul:raze (vgt`cycle) - (t`cycle )value git)
t:rul,'t;
q)t:lbl1:([]lbl1:(t`rul)<=30),'t
q)t:([]lbl2:(t`rul)<=15),'t
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
tmp:(flip d floatCols )group d`id
/ Generate sequences for LSTM
/ 50-row windows for each id
seq:({(til -50+count x),'(50 + til (-50+count x))}':) tmp
seqw:({v:(value seq) -1+x;(tmp x) (v[;0]+\:til 50)}':) 1+til count tmp
r:raze seqw;

dl:(d`lbl1)group d`id;
ce:count each dl;
dl:raze over value (ce-50)# '(d`lbl1)group d`id;
