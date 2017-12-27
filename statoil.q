\l p.q
np:.p.import `numpy
npar:{np[`array;<;x]};
train:.j.k (read0 `:train.json )0;
band1:(npar (75,75)#/:) train`band_1;
band2:(npar (75,75)#/:) train`band_2;

Xtrain:flip `band_1`band_2`band_3!(npar band1;npar band2;npar (band1+band2)%2);
show "Data reading done...";

pyplot:.p.import `matplotlib.pyplot;
models:.p.import `keras.models;
layers:.p.import `keras.layers;
init:.p.import `keras.initializers;
opti:.p.import `keras.optimizers;
ms:.p.import `sklearn.model_selection;
p)from keras.models import Sequential;
p)from keras.layers import Flatten;
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

        /Layer 3
        gmodel[`add;<;layers[`Conv2D;<;128;pykwargs `kernel_size`activation!(3 3;`relu)]];
        gmodel[`add;<;layers[`MaxPooling2D;<;pykwargs `pool_size`strides!(2 2;2 2)]];
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
        gmodel[`add;<;layers[`Dense;<;128]];
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
        splitdata:ms[`train_test_split;<;Xtrain;y;pykwargs `random_state`train_size`test_size!(1;0.75;0.25)];
        fnpar:{np[`array;>;x]};
        kumar;
        t:flip (splitdata 0)[`band_1`band_2`band_3];
        Xtraincv:fnpar ((count t),75,75,3)#raze over t;
        t:flip (splitdata 1)[`band_1`band_2`band_3];
        Xvalid:fnpar ((count t),75,75,3)#raze over t;
        Ytraincv:fnpar splitdata 2;
        / Training here
        show "Training commences ...";
        Yvalid:fnpar splitdata 3;
        gmodel:getModel[];
        gmodel[`fit;<;Xtraincv;Ytraincv;pykwargs `batch_size`epochs`verbose`validation_data!(24;50;1;(Xvalid;Yvalid))]
