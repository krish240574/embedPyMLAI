/ load the TimeSeriesTransformer and Time2Vec classes as python code. 
/ Can access them as q variables later
\l inc/tst.p
\l p.q
\l inc/tst.q / contains get_model[] and other functions

/ this file demonstrates using a time-series transformer
/ code ported from https://www.kaggle.com/krish240574/tutorial-time-series-transformer-time2vec
c:`row_id`date`country`store`product`num_sold
colStr:"IDSSSI"

train:(colStr;enlist ",")0: `:train.csv
y:([]y:train`num_sold)
train:delete num_sold from train

test:(colStr;enlist ",")0: `:test.csv
test:delete x from test

all_data:train,test
/ use the date field to get separate values
all_data:all_data,'([]day:`dd$(all_data`date))
all_data:all_data,'([]month:`mm$(all_data`date))
all_data:all_data,'([]year:`year$(all_data`date))
all_data:all_data,'([]weekofyear:{1 + (x - `week $ `date $ 12 xbar `month $ x) div 7}all_data`date)
all_data:all_data,'([]dayofweek:(all_data`date) mod 7)
all_data:all_data,'([]weekday:(all_data`date) mod 7)
all_data:all_data,'([]daysinmonth:{dom:(31 28 31 30 31 30 31 31 30 31 30 31);f:dom -1+`mm$all_data`date;:f:@[f;where {mod[;2] sum 0=x mod\: 4 100 400} each `year$all_data`date;:;29]}[])
/ this is slow code - owing to too many each calls
/ dayofyear:{[dt]dom:(31 28 31 30 31 30 31 31 30 31 30 31);
/    $[
/        1=count dt;ret:(`dd$dt)+sum dom til -1+`mm$dt;
/        ret:(`dd$dt)+sum each dom each til each -1+`mm$dt
/     ];
/     :(0=(`year$dt) mod 4)+ret
/    }
/ this is 24 times faster than the above code
all_data:all_data,'([]dayofyear:{1+x - `date $ 12 xbar `month $ x}all_data`date)
all_data:delete row_id,date from all_data

/ Now to one-hot encode the categorical columns
/ this is a workaround so I can use pd.get_dummies() and get all data inside q, without entering the python world, per se
pd:.p.import`pandas
npar:.p.import[`numpy]`:array

tmp:flip all_data cols all_data
/ only the first 3 columns need to be one-hot encoded
k:{pd[`:get_dummies;string tmp[;x]]}each til 3
/ k is a "foreign" object, can be converted to a np.array() in the python space
/ the np.array is returned as rows of 0x, rows of bytes, convert them to int 
kk:raze over 'flip {"h"$ ' ((npar each k) x)`}each til 3
/ get count of distinct values of each categorical column
cc:count each {"h"$(((npar each k)x)`) 0}each til 3
/ Now to add column names for the categorical values, and we're good to go
/ form column string cat1, cat2, cat3, etc
cl:raze {`$(string (cols all_data) x),/: string til cc x}each til count cc
all_data:all_data,'flip cl!flip kk

/ one-hot encoded table ready
all_data:delete country, store, product from all_data
train:all_data[til count train]
test:all_data[(count train)+til count test]

/ get transformer model defined inside inc/tst.p
NUM_FOLDS:10
TSETSZ:floor (count train)%NUM_FOLDS
/ this code mimics the TimeSeriesSplit in python - form NUM_FOLDS lists
f:{(til (x*TSETSZ);(x*TSETSZ)+til TSETSZ)}each 1+til NUM_FOLDS
trainlist:(train f)[;0];valtrainlist:(train f)[;1]
ylist:(y f)[;0];valylist:(y f)[;1]

/ Sliding window - window size = 65 for now. 
/ Generate indices and index in one shot
gensw:{x (til (y+count x)) +\: til y}
trsw:gensw[train;65]
tstsw:gensw[test;65]
smape:.p.get`smape;
/ training routine 
ft:((.p.import`sklearn.preprocessing)`:RobustScaler)[][`:fit_transform;<]
es:(.p.import`keras.callbacks)[`:EarlyStopping;<;pykwargs `monitor`patience`verbose`mode`restore_best_weights!(smape;700;0;"min";`True)]

trf:{
 ca:cols all_data;
 x_tr_sw:gensw[ft flip (trainlist x)ca;65];y_tr_sw:gensw[ft flip (ylist x) cols y;65];
 x_v_sw:gensw[ft flip (valtrainlist x)ca;65];y_v_sw:gensw[ft flip (valylist x) cols y;65];
 .p.set[`xv;x_v_sw];.p.set[`yv;y_v_sw];
 
 m:get_model[(WINDOWSIZE,INPSL);T2VDIM];
 m[`:fit;x_tr_sw;y_tr_sw;`epochs pykw 20;`batch_size pykw 64;`validation_data pykw (.p.eval"tuple((xv,yv))")`;`callbacks pykw es;`verbose pykw 1]

 }each til NUM_FOLDS;





