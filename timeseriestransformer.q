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
doy:{[dt]dom:(31 28 31 30 31 30 31 31 30 31 30 31);
    $[
        1=count dt;ret:(`dd$dt)+sum dom til -1+`mm$dt;
        ret:(`dd$dt)+sum each dom each til each -1+`mm$dt
     ];
     :(0=(`year$dt) mod 4)+ret
    }


