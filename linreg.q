/ Equivalent python code at : http://scikit-learn.org/stable/auto_examples/linear_model/plot_ols.html
/ this is an embedPy translate to highlight the succinctness of the integration between python and q - clean as a whistle !

/ load up embedPy
\l p.q

/ import if a routine i.e only function call names
isroutine:.p.imp[`inspect;`isroutine];

/ get pointers to all functions as callable_imps
getmembers:.p.callable_imp[`inspect;`getmembers];

/ this function takes all function names in a module and
/ returns a dictionary containing pointers to them as callable_imps
wrapm:{[x]
        / call getmembers defined above, on the import of your choice
        names:getmembers[x;isroutine];
        / initialise dict with :: and _pyobj, necessary in every pydict object
        res:``_pyobj!((::);x);
        / update and return results as a dictionary of function names for later use
        res,:(`$names[;0])!{.p.pycallable y 1}[x]each names; res} / end function wrapm


/ Now to import the LinearRegression object from inside linear_model from inside sklearn. 
/ Ideally, I'd like to avoid writing the slightest bit of python - would be nice to have a means 
/ to reach an *object* inside a python module, after an import.
/ Something akin to .p.impobj[`sklearn;`linear_model;`LinearRegression] - import an object directly into q
/ the following code makes some headway - 
/ isroutine:.p.imp[`inspect;`isclass] / note the 'isclass' here 
/ getmembers:.p.callable_imp[`inspect;`getmembers]
/ objs:getmembers[.p.import`sklearn.linear_model;isroutine]
/ 'objs' now contains the following :
/ q)objs
"ARDRegression"         foreign
"BayesianRidge"         foreign
"ElasticNet"            foreign
"ElasticNetCV"          foreign
"Hinge"                 foreign
"Huber"                 foreign
"HuberRegressor"        foreign
"Lars"                  foreign
"LarsCV"                foreign
"Lasso"                 foreign
"LassoCV"               foreign
"LassoLars"             foreign
"LassoLarsCV"           foreign
"LassoLarsIC"           foreign
"LinearRegression"      foreign
"Log"                   foreign
"LogisticRegression"    foreign
"LogisticRegressionCV"  foreign
"ModifiedHuber"         foreign
"MultiTaskElasticNet"   foreign
"MultiTaskElasticNetCV" foreign
"MultiTaskLasso"        foreign
...
/ these are however, class names, I think, I'm still trying to figure out how to instantiate
/ an object of these, through 'objs'


/ the following lines are an indirect way to reach the desired python object inside
/ a python module. - LinearRegression inside linear_model inside sklearn. 
p)from sklearn import linear_model

/ get the LinearRegression object from sklearn
linreg:.p.obj2dict .p.pyeval"linear_model.LinearRegression()"

/ use wrapm for sklearn's dataset function names
ds:wrapm .p.import`sklearn.datasets

/ load diabetes dataset
qdiab:.p.py2q ds.load_diabetes[]

/ split into train and test
Xtrain:(qdiab`data)[til 300];
Xtest:(qdiab`data)[300+til((count qdiab`data)-300)]
Ytrain:(qdiab`target)[til 300]
Ytest:(qdiab`target)[300+til((count qdiab`target)-300)]

/ fit here
linreg.fit[Xtrain;Ytrain]

/ predict
pred:linreg.predict[Xtest]

/ use wrapm for skpearn's metrics module function names
pymetrics:wrapm .p.import`sklearn.metrics

/ print results (mse here)
.p.py2q pymetrics.mean_squared_error[Ytest;pred]

