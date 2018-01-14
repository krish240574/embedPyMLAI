\l p.q
tf:.p.import`tensorflow;
npar:.p.import[`numpy;`array;>];
\l inc/dsbowlpd.q
readlabels:{[lst]
        lbl:("SI";enlist ",")0: `:stage1_labels.csv;
        lbl:select from lbl where id in `$lst;
        k::lbl`cancer; labeldata:((count k)#());
        labeldata:@[labeldata;where 0=k;:;(count where 0=k)#(1 2)#(1;0)];
        labeldata:@[labeldata;where 1=k;:;(count where 1=k)#(1 2)#(0;1)];
        :labeldata};
lst:system "ls ./input/sample_images";
path:"/sample_images/";
fin:{.dsbowl.pd[x,"/";path]}each lst;

\l inc/dsbowlnn.q
prediction:.dsnn.predict[fin];

/ Add predictions to tf graph explicitly
tf[`add_to_collection;<;`prediction;prediction];

/ Read label data from disk
labeldata:readlabels[lst];

/ prediction has one extra
if[(count prediction) <> (count labeldata); prediction:prediction[til count labeldata]];

/ Add softmax cross entropy as loss function
temp:{tf[`nn.softmax_cross_entropy_with_logits;<;`logits pykw prediction[x];`labels pykw npar labeldata[x]]}each til count prediction;
cost:tf[`reduce_mean;<;temp];
optimizer:opt[`minimize;>;cost] / Can safely set as foreign

/ prediction and labeldata are nested, so un-nest them
prediction:((count prediction),2)#raze over getval each prediction;
labeldata:((count labeldata),2)#raze over labeldata;

/ prediction has one extra
p)import tensorflow as tf
/ sess:.p.eval"tf.Session()";
sess:tf[`Session;*][];

/ This initializes all the weights and biases defined above
sess[`run;<;.p.pyeval"tf.global_variables_initializer()"];

/ lose one image for now - the missing patient mystery
if[(count fin) <> count labeldata; fin:fin[til count labeldata]];

/ Split into training and validation sets 80-20 split
ktmp:ceiling 0.8*count fin;
fintrain:fin til ktmp;
finvalidate:fin ktmp + til (count fin) - ktmp;
k1train:labeldata til ktmp;
k1validate:labeldata ktmp + til (count labeldata) - ktmp ;

/ Ready data and variables for session.Run()
p)x = tf.placeholder('float')
p)y = tf.placeholder('float')
.p.set[`sess;sess];.p.set[`optimizer;optimizer];.p.set[`cost;cost];

/ Function for evaluating accuracy
evalacc:{[acc]
        .p.set[`Xval;finvalidate];.p.set[`Yval;k1validate];.p.set[`accuracy;acc];
        show "Validation data accuracy :";
        acceval:.p.eval"accuracy.eval({x:Xval,y:Yval}, session=sess)";
        show acceval`};
runsession:{
        .p.set[`X;xdata[x]];
        .p.set[`Y;labeldata[x]];
         o:.p.eval"sess.run([tf.get_collection(\"prediction\"), optimizer, cost], feed_dict={x: X, y: Y})";
        / Location 0 of the returned value contains predictions
        / reshape, average and return
        t:count raze (o`)0;
        t:(t,2)#raze over (o`)0;
        show avg t;
        :avg t;
        };
runepochs:{
        prediction:runsession each til count xdata;
        correct:tf[`equal;<;tf[`argmax;<;npar prediction;npar 1];tf[`argmax;<;npar labeldata;npar 1]];
        accuracy:tf[`reduce_mean;<;tf[`cast;<;correct;`float]];
        evalacc[accuracy] ;
        };
show "Training for 5 epochs now...";
xdata:fintrain;labeldata:k1train;
runepochs each til 5; / 5 epochs - 5 runs through the same data

/ test data now
lst:system "ls ./input/test_images";
path:"/test_images/";
fin:{.dsbowl.pd[x,"/";path]}each lst;
show "Test images pre-processed and resized...";

show "Test predictions now...";
prediction:.dsnn.predict[fin];

/ Now to evaluate with test data
.p.eval"tf.get_default_graph().clear_collection('prediction')";
tf[`add_to_collection;<;`prediction;prediction];
xdata:fin; / data
labeldata:readlabels[lst]; / labels for test data
labeldata:((count xdata),2)#raze over labeldata

runepochs[]; / run once - test data - and evaluate accuracy
