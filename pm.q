/ Predictive maintenance using LSTM 
c:`id`cycle`setting1`setting2`setting3`s1`s2`s3`s4`s5`s6`s7`s8`s9`s10`s11`s12`s13`s14`s15`s16`s17`s18`s19`s20`s21;
colStr:"II",(-2+count c)#"F";

/ Training data
d:(colStr;enlist " ")0: `:PM_train.txt;
gd:select by id from d;
gid:group d`id;
vgd:value gd
rul:([]rul:raze (vgd`cycle) - (d`cycle )value gid)
d:rul,'d;

/ Testing data

/ Read truth data first and then use
tr:([]remcycles:"I"$read0 `:PM_truth.txt);

t:(colStr;enlist " ")0: `:PM_test.txt;
gt:select by id from t;
git:group t`id;
vgt:value gt
cycle:([]cycle:(tr`remcycles)+vgt`cycle)
vgt:delete cycle from vgt
vgt:cycle,'vgt
rul:([]rul:raze (vgt`cycle) - (t`cycle )value git)
t:rul,'t;
