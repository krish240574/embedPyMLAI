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
/ one-hot one-liner
oh:"h"$ raze over 'flip flip each (kt in/: 'distinct each kt:(train,test) c1 til count c1:`country`store`product)
/ columns for one-hot table
cs:`$raze over 'raze string c1,/:'dk:distinct each kt 
all_data:all_data,'flip cs!flip oh

/ one-hot encoded table ready
all_data:delete country, store, product from all_data
train:all_data[til count train]
test:all_data[(count train)+til count test]

/ get transformer model defined inside inc/tst.p
NUM_FOLDS:10
TSETSZ:floor (count train)%NUM_FOLDS
/ this code mimics the TimeSeriesSplit in python - form NUM_FOLDS lists
/ f:{(til (x*TSETSZ);(x*TSETSZ)+til TSETSZ)}each 1+til NUM_FOLDS
cxl:count each xl:til each (TSETSZ*/:1+til NUM_FOLDS);fxl:(xl;cxl+\:til TSETSZ);

trainlist:train fxl[0;];valtrainlist:train fxl[1;];
ylist:y fxl[0;];valylist:y fxl[1;];

/ Sliding window - window size = 65 for now. 
/ Generate indices and index in one shot
gensw:{t:(til x) +\: til y;(t;last each t)}
/ trsw:gensw[train;65]
/ tstsw:gensw[test;65]
smape:.p.get`smape;
/ training routine 
ft:((.p.import`sklearn.preprocessing)`:RobustScaler)[][`:fit_transform;<]
es:(.p.import`keras.callbacks)[`:EarlyStopping;<;pykwargs `monitor`patience`verbose`mode`restore_best_weights!(smape;700;0;"min";`True)]
na:(.p.import`numpy)`:array;
trf:{
 ca:cols all_data;
 tg:gensw[1+(count trx:ft flip (trainlist x)ca)-65;65];
 x_tr_sw:trx tg 0;
 y_tr_sw:(ft flip (ylist x) cols y)tg 1;
 vg:gensw[1+(count vx:ft flip (valtrainlist x)ca)-65;65];
 x_v_sw:vx vg 0;
 y_v_sw:(ft flip (valylist x) cols y)vg 1

 / x_tr_sw:gensw[ft flip (trainlist x)ca;65];y_tr_sw:gensw[ft flip (ylist x) cols y;65];
 / x_v_sw:gensw[ft flip (valtrainlist x)ca;65];y_v_sw:gensw[ft flip (valylist x) cols y;65];
 .p.set[`xv;na x_v_sw];.p.set[`yv;na y_v_sw];
 
 m:get_model[(WINDOWSIZE,INPSL);T2VDIM];
 m[`:fit;na x_tr_sw;na y_tr_sw;`epochs pykw 20;`batch_size pykw 64;`validation_data pykw (.p.eval"tuple((xv,yv))")`;`callbacks pykw es;`verbose pykw 1]
/// Might need to change TF version to 2.6.0 - I keep getting a "Nonetype is not callable" error
 }each til NUM_FOLDS;





