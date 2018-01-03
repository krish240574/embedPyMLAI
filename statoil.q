\l p.q
np:.p.import `numpy
npar:{np[`array;<;x]};
fnpar:{np[`array;>;x]};
show "Reading data..."
train:.j.k (read0 `:train.json )0;

band1:(npar (75,75)#/:) train`band_1;
band2:(npar (75,75)#/:) train`band_2;
Xtrain:flip `band_1`band_2`band_3!(npar band1;npar band2;npar (band1+band2)%2);

/ This code adds extra training data, by flipping the existing images
/band1:(npar (75,75)#/:) train`band_1;
/fband1:npar flip each band1;
/band2:(npar (75,75)#/:) train`band_2;
/fband2:npar flip each band2;
/band3:(band1+band2)%2;
/fband3:npar flip each band3;
/Xtrain:flip `band_1`band_2`band_3!(npar band1,fband1;npar band2,fband2;npar band3,fband3);

show "Data reading done...";

pyplot:.p.import `matplotlib.pyplot;
models:.p.import `keras.models;
layers:.p.import `keras.layers;
init:.p.import `keras.initializers;
opti:.p.import `keras.optimizers;
ms:.p.import `sklearn.model_selection;
p)from keras.models import Sequential;
p)from keras.layers import Flatten;
p)from keras.callbacks import ModelCheckpoint, Callback, EarlyStopping

p)l = list(['accuracy']);
l:.p.get`l;
getModel:{
        / Start with Sequential(), then keep add[]ing to it.

        / Layer 1
        gmodel:.p.eval"Sequential()";
        gmodel[`add;<;layers[`Conv2D;<;64;pykwargs `kernel_size`activation`input_shape!(3 3;`relu;75 75 3)]];
        gmodel[`add;<;layers[`MaxPooling2D;<;pykwargs `pool_size`strides!(3 3;2 2)]] gmodel[`add;<;layers[`Dropout;<;0.2]];

        / Layer 2
        gmodel[`add;<;layers[`Conv2D;<;128;pykwargs `kernel_size`activation!(3 3;`relu)]];
        gmodel[`add;<;layers[`MaxPooling2D;<;pykwargs `pool_size`strides!(2 2;2 2)]];
        gmodel[`add;<;layers[`Dropout;<;0.2]];

        / Layer 3
        gmodel[`add;<;layers[`Conv2D;<;128;pykwargs `kernel_size`activation!(3 3;`relu)]];
        gmodel[`add;<;layers[`MaxPooling2D;<;pykwargs `pool_size`strides!(2 2;2 2)]];
        gmodel[`add;<;layers[`Dropout;<;0.2]];
        / Layer 3
        gmodel[`add;<;layers[`Conv2D;<;128;pykwargs `kernel_size`activation!(2 2;`relu)]];
        gmodel[`add;<;layers[`MaxPooling2D;<;pykwargs `pool_size`strides!(1 1;1 1)]];
        gmodel[`add;<;layers[`Dropout;<;0.2]];
        / Layer 3
        gmodel[`add;<;layers[`Conv2D;<;128;pykwargs `kernel_size`activation!(2 2;`relu)]];
        gmodel[`add;<;layers[`MaxPooling2D;<;pykwargs `pool_size`strides!(1 1;1 1)]];
        gmodel[`add;<;layers[`Dropout;<;0.2]];

        /Layer 4
        gmodel[`add;<;layers[`Conv2D;<;64;pykwargs `kernel_size`activation!(3 3;`relu)]];
        gmodel[`add;<;layers[`MaxPooling2D;<;pykwargs `pool_size`strides!(2 2;2 2)]];
        gmodel[`add;<;layers[`Dropout;<;0.2]];

        / Flatten
        / Have to .p.eval or I get TypeError: "The added layer must be an instance of class Layer. Found: <class 'keras.layers.core.Flatten'>"
        gmodel[`add;<;.p.eval"Flatten()"];

        /Dense layer 1
        gmodel[`add;<;layers[`Dense;<;512]];
        gmodel[`add;<;layers[`Activation;<;`relu]];
        gmodel[`add;<;layers[`Dropout;<;0.2]];

        / Dense layer 2
        gmodel[`add;<;layers[`Dense;<;256]];
        gmodel[`add;<;layers[`Activation;<;`relu]];
        gmodel[`add;<;layers[`Dropout;<;0.2]];

        / Sigmoid layer
        gmodel[`add;<;layers[`Dense;<;1]];
        gmodel[`add;<;layers[`Activation;<;`sigmoid]];
        adamopti:opti[`Adam;<;pykwargs `lr`beta_1`beta_2`epsilon`decay!(0.001;0.9;0.999;1e-8;0.0)];
        gmodel[`compile;<;pykwargs `loss`optimizer!(`binary_crossentropy;adamopti)];
        gmodel[`summary;<];
        :gmodel};

y:train`is_iceberg;
/y:y,y; /extra data now

/ Split into train and validate sets
splitdata:ms[`train_test_split;<;Xtrain;y;pykwargs `random_state`train_size`test_size!(1;0.75;0.25)];
t:flip (splitdata 0)[`band_1`band_2`band_3];
Xtraincv:fnpar ((count t),75,75,3)#raze over t;
t:flip (splitdata 1)[`band_1`band_2`band_3];
Xvalid:fnpar ((count t),75,75,3)#raze over t;
Ytraincv:fnpar splitdata 2;
Yvalid:fnpar splitdata 3;

/ Training here
show "Training commences ...";
gmodel:getModel[];
/ gmodel[`fit;<;Xtraincv;Ytraincv;`callbacks pykw .p.pyeval "list(callbacks)";pykwargs `batch_size`epochs`verbose`validation_data!(24;50;1;(Xvalid;Yvalid))];
gmodel[`fit;<;Xtraincv;Ytraincv;pykwargs `batch_size`epochs`verbose`validation_data!(24;50;1;(Xvalid;Yvalid))];
/.p.set[`gmodel;gmodel];
/.p.set[`Xtraincv;Xtraincv];
/.p.set[`Ytraincv;Ytraincv];
/.p.set[`Xvalid;Xvalid];
/.p.set[`Yvalid;Yvalid];
/p)gmodel.fit(Xtraincv,Ytraincv,callbacks=list([es,msave]),batch_size=24,epochs=50,verbose=1,validation_data=(Xvalid,Yvalid));

/ Load the best weights
/ gmodel[`load_weights;`filepath pykw filepath]
/ Evaluate
scores:gmodel[`evaluate;<;Xvalid;Yvalid;`verbose pykw 1];
show "Scores:";
show scores;

/ Test data preprocessing here
show "Preprocessing test data now...";
test:.j.k (read0 `:test.json )0;
show "json read...";
testband1:(npar (75,75)#/:) test`band_1;
testband2:(npar (75,75)#/:) test`band_2;
Xtest:flip `band_1`band_2`band_3!(npar testband1;npar testband2;npar (testband1+testband2)%2);
Xtest:((count Xtest),75,75,3)#raze over Xtest;
Xtest:fnpar Xtest;
show "Running test, predicting...";

preds:gmodel[`predict_proba;<;Xtest;`verbose pykw 1];

show "Generating submission file...";
.p.set[`preds;fnpar preds]
.p.set[`id;fnpar test`id]
p)import pandas as pd
p)submission = pd.DataFrame();
p)submission['id']=id;
p)submission['is_iceberg']=preds.reshape((preds.shape[0]));
p)submission.to_csv('sub.csv', index=False)
show "Done !";
