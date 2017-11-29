\l p.q
isroutine:.p.imp[`inspect;`isroutine];
getmembers:.p.callable_imp[`inspect;`getmembers];
wrapm:{[x]
        / call getmembers defined above, on the import of your choice
        names:getmembers[x;isroutine];
        / initialise dict with :: and _pyobj, necessary in every pydict object
        res:``_pyobj!((::);x);
        / update and return results as a dictionary of function names for later use
        res,:(`$names[;0])!{.p.pycallable y 1}[x]each names; res} / end function wrapm

/ c:`id`timestamp`derived0`derived1`derived2`derived3`derived4`fundamental0`fundamental1`fundamental2`fundamental3`fundamental5`fundamental6`fundamental7`fundamental8`fundamental9`fundamental10`fundamental11`fundamental12`fundamental13`fundamental14`fundamental15`fundamental16`fundamental17`fundamental18`fundamental19`fundamental20`fundamental21`fundamental22`fundamental23`fundamental24`fundamental25`fundamental26`fundamental27`fundamental28`fundamental29`fundamental30`fundamental31`fundamental32`fundamental33`fundamental34`fundamental35`fundamental36`fundamental37`fundamental38`fundamental39`fundamental40`fundamental41`fundamental42`fundamental43`fundamental44`fundamental45`fundamental46`fundamental47`fundamental48`fundamental49`fundamental50`fundamental51`fundamental52`fundamental53`fundamental54`fundamental55`fundamental56`fundamental57`fundamental58`fundamental59`fundamental60`fundamental61`fundamental62`fundamental63`technical0`technical1`technical2`technical3`technical5`technical6`technical7`technical9`technical10`technical11`technical12`technical13`technical14`technical16`technical17`technical18`technical19`technical20`technical21`technical22`technical24`technical25`technical27`technical28`technical29`technical30`technical31`technical32`technical33`technical34`technical35`technical36`technical37`technical38`technical39`technical40`technical41`technical42`technical43`technical44`y
/ colStr:"II",109#"F"
/ .Q.fs[{`tr insert flip c!(colStr;",")0:x}]`:train.csv;
/ show "reading done..."
/ reading as CSV causes a wsfull error, here is a workaround

/ export PYTHONPATH=$QHOME/l64(where the kagglegym.py is)
p)import kagglegym 
p)env = kagglegym.make()
p)obs = env.reset()
/ train is a pandas dataframe
p)train = obs.train 
/ Column names
p)kcols = train.columns
kcols:.p.obj2dict .p.get[`kcols]
kcols:`$.p.py2q kcols.tolist[]

/ Need to transpose train, so that inside q, when values[] is called, all columns are maintained
p)train = train.transpose()
/ enter q now
train:.p.obj2dict .p.get[`train]; / convert to dict, so one can reach the values[] call
train:.p.py2q train.values[] / this gets the shape intact 806928x111

/ Create train dataset table here
train:flip kcols!train
train:fills each train / fill `NA values
tkcols:kcols where not kcols in (`id`timestamp`y); 
k:train[tkcols]; / filtered out `id`timestamp`y

/ Prepare for the plotting of data
np:wrapm .p.import`numpy;
coeff:k cor \: train[`y];
ind:.p.py2q np.arange[count k];
width:0.9;
p)import matplotlib.pyplot as plt
p)fig,ax = plt.subplots(figsize = (12,40))
ax:.p.obj2dict .p.get`ax
ax.barh[ind;asc coeff;`color pykw `y]  / this contains the meat for the plot - in ascending order of corrs
ax.set_yticks[ind+(width%2)]
ax.set_yticklabels[tkcols iasc coeff;`rotation pykw `horizontal] / index column names by ascending order of corr
plt:wrapm .p.get[`plt]
plt.show[]

/ Now to take the top 4 variables, corr-wise and plot a heatmap
p)temp = obs.train
/ top 4 variables, with highest correlation
p)temp_df = temp[['technical_30','fundamental_51','technical_37','technical_25']]
p)corrmat = temp_df.corr(method='spearman')
corrmat:.p.obj2dict .p.get[`corrmat]
corrmat:.p.py2q corrmat.values[]
p)f,ax = plt.subplots(figsize=(8,8))
sns:wrapm .p.import`seaborn
sns.heatmap[corrmat;`vmax pykw 0.8;`square pykw `True]
plt.show[]

