from keras.models import Sequential
import bayesopt
import keras
from keras.layers import Dense, Activation
import keras.backend as K
import pandas as pd
import numpy as np
import horovod.tensorflow as hvd

train_dataset_fp = '/home/kkumar/q/l64/hdata.csv'
train_df = pd.read_csv(train_dataset_fp)

def dataframe_to_deepsurv_ds(df, event_col = 'Event', time_col = 'Time'):
    # Extract the event and time columns as numpy arrays
    print("Here")
    e = df[event_col].values.astype(np.int32)
    t = df[time_col].values.astype(np.float32)

    # Extract the patient's covariates as a numpy array
    x_df = df.drop([event_col, time_col], axis = 1)
    x = x_df.values.astype(np.float32)

    # Return the deep surv dataframe
    return {
        'x' : x,
        'e' : e,
        't' : t
    }
# If the headers of the csv change, you can replace the values of
# 'event_col' and 'time_col' with the names of the new headers
# You can also use this function on your training dataset, validation dataset, and testing dataset
train_data = dataframe_to_deepsurv_ds(train_df, event_col = 'Event', time_col= 'Time')

hvd.init()

import tensorflow as tf
#e = tf.placeholder(shape=(1000,), dtype=tf.float32, name='e')
#x = tf.placeholder(shape=(1000,3), dtype=tf.float32, name='x')
#t = tf.placeholder(shape=(1000,), dtype=tf.float32, name = 't')
e = tf.placeholder(dtype=tf.float32, name='e')
x = tf.placeholder(dtype=tf.float32, name='x')
t = tf.placeholder(dtype=tf.float32, name = 't')
def trainnet(data):
        nn = tf.layers.dense(data,3,activation=tf.nn.relu)
        nn = tf.layers.dense(nn,100,activation=tf.nn.relu)
        nn = tf.layers.dense(nn,100,activation=tf.nn.relu)
        nn = tf.layers.dense(nn,100,activation=tf.nn.relu)
        nn = tf.layers.dense(nn,100,activation=tf.nn.relu)
        nn = tf.layers.dense(nn,1,activation=tf.nn.relu)
        return nn
nn = trainnet(tf.convert_to_tensor((train_data.get('x'))[0:1000],dtype=tf.float32))
cost = ((tf.transpose(nn) - tf.log(tf.cumsum(tf.exp(nn))))*e)/tf.to_float((tf.reduce_sum(e)))
opt = tf.train.GradientDescentOptimizer(0.001*hvd.size())
global_step = tf.train.get_or_create_global_step()
opt = (hvd.DistributedOptimizer(opt)).minimize(cost, global_step=global_step)

K.get_session().run(tf.global_variables_initializer())

config = tf.ConfigProto()
config.gpu_options.allow_growth = True
config.gpu_options.visible_device_list = str(hvd.local_rank())
K.set_session(tf.Session(config=config))

#train_op = opt.minimize(cost, global_step=global_step)

tf.add_to_collection('prediction',trainnet(tf.convert_to_tensor((train_data.get('x'))[0:1000],dtype=tf.float32)))
l = list()
sz = len(train_data.get('e'))
with tf.Session(config=config) as mon_sess:
    mon_sess.run(tf.global_variables_initializer())
    i=0
    while i<sz:
        print("i=",i)
        if ((sz-i)>=1000):
                X = (train_data.get('x'))[i:i+1000]
                E = (train_data.get('e'))[i:i+1000]
#        else:
#                X = (train_data.get('x'))[i:sz-1]
#                E = (train_data.get('e'))[i:sz-1]
        i=i+1000
        o = mon_sess.run([tf.get_collection("prediction"), opt, cost],feed_dict={x:X,e:E})
        l.append(o[0])
l = np.ravel(l)
#correct = tf.equal(tf.argmax(np.array(l),1),tf.argmax(np.array(train_data.get('e')),1))
#accuracy = tf.reduce_mean(tf.cast(correct,tf.float32))
accuracy = tf.reduce_mean(tf.square((l[0:5064291]-train_data.get('t'))))
print("Acc = ",K.get_value(accuracy))

# Bayesian OPtimization from here
params = {}
        params['n_iterations'] = 50
        params['n_iter_relearn'] = 1
        params['n_init_samples'] = 2

        print "*** Model Selection with BayesOpt ***"
        n = 6  # n dimensions
        # params: #layer, width, dropout, nonlinearity, l1_rate, l2_rate
        lb = np.array([1 , 10 , 0., 0., 0., 0.])
        ub = np.array([10, 500, 1., 1., 0., 0.])

        mvalue, x_out, _ = bayesopt.optimize(cost, n, lb, ub, params)
