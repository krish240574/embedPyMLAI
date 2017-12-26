/ Kaggle competition at - https://www.kaggle.com/c/statoil-iceberg-classifier-challenge
q)train:.j.k (read0 `:train.json )0;
q)band1:((75,75)#/:) train`band_1;
q)band2:((75,75)#/:) train`band_2;
train:train,'([]band_3:avg each band1+band2);

pyplot:.p.import `matplotlib.pyplot;
models:.p.import `keras.models;
layers:.p.import `keras.layers;
init:.p.import `keras.initializers;
adam:.p.import `keras.opimizers.Adam;


getModel:{
        / Start with Sequential(), then keep add[]ing to it.
        gmodel:models`Sequential;
        gmodel[`
