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
EMBED_DIM:64
INPSL:16
N_HEADS:8
FF_DIM:256
DROPOUT_RATE:0.0
mult:.p.import[`tensorflow]`:math.multiply / directly access the method inside a module this way
add:.p.import[`tensorflow]`:math.add
lyr:.p.import`tensorflow.keras.layers

inp:x:lyr[`:Input;(65,16)];
t2v:(.p.get`Time2Vec)[2];
temb:lyr[`:TimeDistributed;t2v][x];
.p.set[`temb;temb];.p.set[`x;x];.p.set[`conc;lyr[`:Concatenate;`axis pykw -1]];x:.p.eval"conc([x,temb])";
x:(lyr[`:LayerNormalization;`epsilon pykw 0.000001])[x];
flt:lyr[`:Flatten][];
dense128:lyr[`:Dense;128;`activation pykw "selu"]
dropout:lyr[`:Dropout;DROPOUT_RATE]
dense1:lyr[`:Dense;1;`activation pykw "linear"]
mdl:.p.import[`tensorflow]`:keras.models.Model

finp:x;
func:{0N!x;;x_old:finp;finp::((.p.get`TransformerBlock)[EMBED_DIM;INPSL + (INPSL * T2VDIM); N_HEADS; FF_DIM; DROPOUT_RATE])[finp];.p.print finp;finp::add[mult[0.1;finp];mult[0.9;x_old]];:x+1}
(7>)func \1 / run func 6 times 
finp:flt[finp] /Flatten
finp:dense128[finp]
finp:dropout[finp]
finp:dense1[finp]
out:finp
model:mdl[inp;out]






