# Machine learning and AI code using embedPy - call python inside q

datasciencebowl2017.q - Data science bowl 2017 on kaggle - https://www.kaggle.com/c/data-science-bowl-2017 - medical images, convolutional NN(3D).

statoil.q - Statoil competition at Kaggle - https://www.kaggle.com/c/statoil-iceberg-classifier-challenge/ - satellite images, convolutional NN(2D).

predictivemaintenance.q - Australian Water Corp. data analysis for predictive maintenance of their water system - https://ministryofdata.org.au/mod-2017-hackathon-problems/wc-pr11-predictive-pumps-pipes-maintenance/ - In progress, building RUL and label columns from unlabelled data. 

2sigma_regression.q - Two Sigma Financial Modelling challenge - https://www.kaggle.com/c/two-sigma-financial-modeling - Linear regression.

pm.q - LSTM for predictive maintenance. 


# Ways the embedPy feature/object gets used:

## Import a module - 
np:.p.import`numpy - returns an embedPy object with pointers to all methods inside numpy

## Import a function inside a module 

npar:.p.import[\`numpy;`array;* or < or >] - returns a embedPy, q or foreign(python) object with the array() method as callable,qcallable, or pycallable  - 
#### The callable, pycallable or qcallable is implicit on usage of the [] in the above call, it automatically happens. 

## The above is equivalent to :
np:.p.import \`numpy; 

npar:.p.callable np\`array; / or qcallable or pycallable

or 

npar:np[\`array;\*]; 

## Can also be used as :
np:.p.import\`numpy;

np[\`array;<;(1000 1000 1000;1000 1000 1000)]

## Another example :
drf:.p.import[\`dicom;\`read_file;\*] - .p.callable return of method read_file inside dicom

drf \<filename\>  - string file name

## Instantiating objects 
pd:.p.import \`pandas

pd[\`DataFrame;\*][] - calls default constructor and instantiates

or

.p.import[\`pandas;\`DataFrame;\*][] - calls default constructor and instantiates

## Non-default constructor :
#### without parens, returns an embedPy object containing a \<class> - \<class DataFframe> in this case
df:.p.import[\`pandas;\`DataFrame;\*] - get class , then instantiate later by 
df[\<appropriate object\>]; / instantiation happens here with value passed

## Chaining embedpy objects :
q)np:.p.import\`numpy

q)v:np[\`arange;\*;12]

q)v`

0 1 2 3 4 5 6 7 8 9 10 11

q)v[\`mean;<][]

5.5

q)rs:v[\`reshape;<]

q)rs[3;4]

0 1 2  3 

4 5 6  7 

8 9 10 11

q)rs[2;6]

0 1 2 3 4  5 

6 7 8 9 10 11

q)np[\`arange;\*;12][\`reshape;\*;3;4]`

0 1 2  3 

4 5 6  7 

8 9 10 11

q)np[\`arange;\*;12][\`reshape;\*;3;4][\`T]`

0 1  2 

3 4  5 

6 7  8 

9 10 11

### Equivalence of .p.import[] and .p.callable - 

q)stdout:.p.callable(.p.import[\`sys]`stdout.write)

q)stdout"hello\n";

hello

q)stderr:.p.import[\`sys;`stderr.write;*]

q)stderr"goodbye\n";

goodbye

## Some examples 
### Allowed - CoxPHSurvivalAnalysis is a class that can be instantiated later

cox:.p.import[\`sksurv;\`linear_model;\`CoxPHSurvivalAnalysis;*]  

q)print  cox

<class 'sksurv.linear_model.coxph.CoxPHSurvivalAnalysis'>

### Allowed - kaplan_meier_estimator is a function

q)km:.p.import[\`sksurv;\`nonparametric ;\`kaplan_meier_estimator;\*] 

q)print km

<function kaplan_meier_estimator at 0x7f775b7d5ae8>

### Not allowed - pyplot is a module, so must be loaded as below , since the [] tries to make the innermost import a .callable. 

q)plt:.p.import[\`matplotlib;\`pyplot;\*] - 

AttributeError: module 'matplotlib' has no attribute 'pyplot'

plt:.p.import \`matplotlib.pyplot;

## Notes
If a method returns a foreign and one wants to access the returned object's methods, .p.wrap the foreign and then access methods. 
In order to bring a python object and access its methods inside q, use an embedPy object, via either .p.import, .p.get or .p.eval, r .p.wrap. An embedPy object is effectively the representation of a python object inside q, with behaviour just like in the python world. 
Once an embedPy object is created, one can either access attributes, or call methods and get q objects.


