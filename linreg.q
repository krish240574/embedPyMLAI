\l p.q / load up embedPy
isroutine:.p.imp[`inspect;`isroutine]; / import if a routine, only function call names
getmembers:.p.callable_imp[`inspect;`getmembers]; / get pointers to all functions as callable_imps
wrapm:{[x]
        names:getmembers[x;isroutine]; / call getmembers defined above, on the import of your choice
        res:``_pyobj!((::);x); / initialise dict with :: and _pyobj, necessary in every pydict object
        res,:(`$names[;0])!{.p.pycallable y 1}[x]each names; res} / update and return results as a dictionary of function names for later use
        pylinmodel:{wrapm .p.import`sklearn.linear_model} / use wrapm for sklearn's linear_model
pylinmodel[];

linreg:.p.obj2dict .p.pyeval"linear_model.LinearRegression()" / get the LinearRegression object from sklearn
ds:wrapm .p.import`sklearn.datasets / use wrapm for sklearn's dataset function names
qdiab:.p.py2q ds.load_diabetes[] / load diabetes dataset

/ split into train and test
Xtrain:(qdiab`data)[til 300];
Xtest:(qdiab`data)[300+til((count qdiab`data)-300]
Ytrain:(qdiab`target)[til 300]
Ytest:(qdiab`target)[300+til((count qdiab`target)-300)]
/ fit here
linreg.fit[Xtrain;Ytrain]
/ predict
pred:linreg.predict[Xtest]
/ use wrapm for skpearn's metrics module function names
pymetrics:wrapm .p.import`sklearn.metrics
/ print results (mse here) 
.p.py2q pym.mean_squared_error[Ytest;pred]

