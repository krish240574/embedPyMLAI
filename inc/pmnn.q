\d .nn
models:.p.import`keras.models;
layers:.p.import`keras.layers;
/ Get model - LSTM with dense and dropouts
getModel:{[nf;nout]
        model:models[`Sequential;*][]; / Instantiating an object here
        model[`add;<;layers[`LSTM;<;pykwargs `input_shape`units`return_sequences!((50;nf);100;1)]];
        model[`add;<;layers[`Dropout;<;0.2]];
        model[`add;<;layers[`LSTM;<;pykwargs `units`return_sequences!(50;0)]];
        model[`add;<;layers[`Dropout;<;0.2]];
        model[`add;<;layers[`Dense;<;pykwargs `units`activation!(nout;`sigmoid)]];
        model[`compile;<;pykwargs `loss`optimizer!(`binary_crossentropy`adam)];
        :model};
