/ Updated to embedPy ver 0.2-beta - a bunch of methods changed, a few deprecated.

/ export PYTHONPATH=$QHOME/l64(where the kagglegym.py is)
p)import kagglegym
p)env = kagglegym.make()
p)obs = env.reset()
/ train is a pandas dataframe, retrieved from a HDF5 read of the input file
p)train = obs.train
/ Column names
p)kcols = train.columns.tolist()
kcols:.p.get`kcols / retrieve as q using kcols`

/ Need to transpose train, so that inside q, when values[] is called, all columns are maintained
p)train = train.transpose()

p)tvals = train.values
train:.p.get`tvals / this gets the shape intact 806928x111
train:fills train`;
kcols:`$kcols`

/ Create train dataset table here
train:flip kcols!train
tkcols:kcols where not kcols in (`id`timestamp`y);
k:(train[tkcols]); / filtered out `id`timestamp`y

/ Prepare for the plotting of data
np:.p.import`numpy;
coeff:k cor \: train[`y];
ind:np[`arange;<;count k];
width:0.9;
p)import matplotlib.pyplot as plt
p)fig,ax = plt.subplots(figsize = (12,40))
ax:.p.get`ax;
barh:.p.qcallable ax`barh
barh[ind;asc coeff;`color pykw `y]  / this contains the meat for the plot
syt:.p.qcallable ax`set_yticks
syt[ind+width%2]
setylabels:.p.qcallable ax`set_yticklabels
setylabels[tkcols iasc coeff;`rotation pykw `horizontal]
plt:.p.get`plt
pshow:.p.qcallable plt`show
pshow[]

/ Now to take the top 4 variables, corr-wise and plot a heatmap
p)temp = obs.train
p)temp_df = temp[['technical_30','fundamental_51','technical_37','technical_25']]
p)corrmat = (temp_df.corr(method='spearman'))
corrmat:.p.get`corrmat
p)f,ax = plt.subplots(figsize=(8,8))
sns:.p.import`seaborn
sns[`heatmap;<;corrmat;`vmax pykw 0.8;`square pykw `True]
pshow[]


/ Fit a linear regression model using all four top columns
p)from sklearn import linear_model
lm:.p.eval"linear_model.LinearRegression()"
fit:.p.qcallable lm`fit
/ leave out 1000 rows for test
fit[(flip k)[til((count train)-1000)];(train[`y])(til((count train)-1000))]
np:.p.import`numpy
array:.p.qcallable np`array
i:-1;
p)import numpy as np
p)testfeatures = np.array(obs.features[['technical_30','fundamental_51','technical_37','technical_25']])

/ Create test set here - last 1000 rows
testx:(train[((neg 1000) + count train)+til 1000])[tkcols]
testy:(train[((neg 1000) + count train)+til 1000])[`y]
/ predict using test set here
predict:.p.qcallable lm`predict
preds:predict flip  testx;
show preds:

/ show mse here
metrics:.p.import `sklearn.metrics
mse:.p.qcallable metrics`mean_squared_error
mse[testy;preds]
