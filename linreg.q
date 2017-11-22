\l p.q
isroutine:.p.imp[`inspect;`isroutine];
getmembers:.p.callable_imp[`inspect;`getmembers];
wrapm:{[x]
        names:getmembers[x;isroutine];
        res:``_pyobj!((::);x);
        res,:(`$names[;0])!{.p.pycallable y 1}[x]each names; res}
        pylinmodel:{wrapm .p.import`sklearn.linear_model}
pylinmodel[];

linreg:.p.obj2dict .p.pyeval"linear_model.LinearRegression()"
ds:wrapm .p.import`sklearn.datasets
qdiab:.p.py2q ds.load_diabetes[]

Xtrain:(qdiab`data)[til 300];
Xtest:(qdiab`data)[300+til((count qdiab`data)-300]
Ytrain:(qdiab`target)[til 300]
Ytest:(qdiab`target)[300+til((count qdiab`target)-300)]
linreg.fit[Xtrain;Ytrain]
pred:linreg.predict[Xtest]
pymetrics:wrapm .p.import`sklearn.metrics
.p.py2q pym.mean_squared_error[Ytest;pred]

