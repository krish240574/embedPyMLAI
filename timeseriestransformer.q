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
all_data:all_data,'([]dayofweek:`Sat`Sun`Mon`Tue`Wed`Thu`Fri (all_data`date) mod 7)
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
train:all_data[til count train]
test:all_data[(count train)+til count test]

/ Sliding window - window size = 65 for now. 
/ Generate indices and index in one shot
gensw:{x (til (y+count x)) +\: til y}
trsw:gensw[train;65]
tstsw:gensw[test;65]
/ load the TimeSeriesTransformer and Time2Vec classes as python code. 
/ Can access them as q variables later
\l inc/tst.p
\l p.q
WINDOWSIZE:65
NUMCOLS:16
T2VDIM:3
/ embedpy code to create our TimeSeriesTransformer model
lyr:.p.import`keras.layers
x:lyr[`:Input;(WINDOWSIZE,NUMCOLS)]
td:lyr[`:TimeDistributed;(.p.get`Time2Vec)[T2VDIM-1]]
x:td[x] /Stack layers, as in the Tensorflow functional API



