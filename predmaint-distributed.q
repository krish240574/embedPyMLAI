/ mpirun --allow-run-as-root -np 4   -H localhost:4   -bind-to none -map-by slot q predmaint-distributed.q - 
/ this runs only on localhost with 4 threads for now
/ To run on 4 machines with 1 GPU/CPU each - (yet to test, will test with 4 CPUs - install of OpenMPI on 4 hosts and config in progress
/ mpirun -np 16 -H host1:1,host2:1,host3:1,host4:1 -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH =mca pml ob1 -mca btl ^openib q predmaint-distributed.q
\l p.q

seq:.p.import[`keras;`:models;`:Sequential;*]
keras:.p.import `keras
dense:.p.import[`keras;`:layers;`:Dense;*]
K:.p.import[`keras;`:backend]
pd:.p.import `pandas
np:.p.import `numpy
hvd:.p.import `horovod.tensorflow

hvd[`:init;*][]

nparray:.p.import[`numpy;`:array;>]

colStr:"IIIII"
d:(colStr;enlist ",")0: `:/home/kkumar/q/l64/hdata.csv

cd:cols d

e:"f"$d`Event;t:"f"$d`Time

x:"f"$flip d cd where not cd in `Event`Time

hvd[`:init;*]
tf:.p.import `tensorflow

trainnet:{[data]
    nn:tf[`:layers;`:dense;*;data;3;`activation pykw tf[`:nn;`:relu]];
    nn:tf[`:layers;`:dense;*;nn;100;`activation pykw tf[`:nn;`:relu]];
    nn:tf[`:layers;`:dense;*;nn;100;`activation pykw tf[`:nn;`:relu]];
    nn:tf[`:layers;`:dense;*;nn;100;`activation pykw tf[`:nn;`:relu]];
    nn:tf[`:layers;`:dense;*;nn;1;`activation pykw tf[`:nn;`:relu]];
    :nn
    }

nn:trainnet[tf[`:convert_to_tensor;*;nparray x til 1000]]

ev:tf[`:placeholder;*;pykwargs (`dtype;`name)!(`float64;`e)]
tm:tf[`:placeholder;*;pykwargs (`dtype;`name)!(`float64;`t)]
xv:tf[`:placeholder;*;pykwargs (`dtype;`name)!(`float64;`x)]

cost:tf[`:divide;*;tf[`:subtract;*;tf[`:transpose;*;nn];tf[`:log;*;tf[`:cumsum;*;tf[`:exp;*;nn]]]];tf[`:reduce_sum;*;e]];

opt:tf[`:train;`:GradientDescentOptimizer;*;0.01*hvd[`:size;<][]]

global_step:tf[`:train;`:get_or_create_global_step;*][]

dop:hvd[`:DistributedOptimizer;*;opt]
opt:dop[`:minimize;*;cost;`global_step pykw global_step]

sess:K[`:get_session][]
sess[`:run;*;tf[`:global_variables_initializer;*][]]

p)import tensorflow as tf
p)import horovod.tensorflow as hvd
p)config = tf.ConfigProto()
p)config.gpu_options.allow_growth=True
p)config.gpu_options.visible_device_list=str(hvd.local_rank())
config:.p.get`config

K[`:set_session;*;tf[`:Session;*;`config pykw config]]

tf[`:add_to_collection;*;`prediction;nn]
p)l=list()
sz:count d

mon_sess:tf[`:Session;*;`config pykw config]
mon_sess[`:run;*;[tf[`:global_variables_initializer;*][]]]

i:0;
.p.set[`mon_sess;mon_sess]
.p.set[`opt;opt]
.p.set[`cost;cost]
.p.set[`x;xv]
.p.set[`e;ev]
while[i<sz;
    if[1000<=(sz-i);
        .p.set[`X;nparray x til 1000];
        .p.set[`E;nparray e til 1000];
        o:.p.eval"mon_sess.run([tf.get_collection(\"prediction\"),opt,cost],feed_dict={x:X,e:E})";
        .p.set[`o;o];
        .p.eval"l.append(o[0])"];
    i:i+1000;
    ]


l:.p.get`l

l: l`

count raze over l

l:(count d)#(raze over l)
