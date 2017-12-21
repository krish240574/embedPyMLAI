/ Data science bowl 2017 on kaggle - https://www.kaggle.com/c/data-science-bowl-2017
/ Complete rewrite of code to read scan images -
/ Reading using read_file of pydicom returns a FileDataSet object
/ on passing to q, all data is clobbered
/ Hence this code, read inside python and pick only relevant(image pixel data)
/ and pass to q

p)import os
p)import numpy as np
p)import dicom
p)import matplotlib.pyplot as plt
imgs:()
fig:()
shape:{if[1<count x;show count x;shape x 0]}; / implement this as a closure
rsz:{np:.p.import`numpy;cv:.p.import`cv2;tup:.p.eval"tuple([50,50])";:cv[`resize;<;np[`array;>;x];tup`.]}
pd:{
        show x;
        ret:0;
        .p.set[`x;x];
        .p.set[`inp;"./input/sample_images/"];
        / read images from disk, (each directory contains multiple images, or slices)
        .p.set[`slices;.p.pyeval"[dicom.read_file(inp+x+s) for s in os.listdir(inp+x)]"];
        / Sort(in-place) by image position
        .p.eval"slices.sort(key = lambda x: int(x.ImagePositionPatient[2]))";
        / Get image pixel data
        tmp:.p.eval"[(slices[i].pixel_array) for i in np.arange(len(slices))]";
        imgs::tmp`;

        / 512x512 is too large - resize to 50,50
        / If null image , resize by force and don't call buggy cv2 resize()
        ret:{$[0=(sum/) imgs[x];imgs[x]::(50,50)#100;imgs[x]::rsz imgs[x]]}each til count imgs;

        / Now to chunk each directory of images into blocks of ((count imgs)%20)
        / then average each block into one image each.
        numslices:20;
        chunksize:ceiling((count imgs)%numslices);
        taken:(t where (count imgs)>t:chunksize*til numslices) _ imgs;
        tmp:last taken;
        / Make the last block = chunksize
        l: (((first count each taken)-count tmp)#) over tmp;
        taken[-1+count taken]:tmp,l;
        / Need to make all blocks of size 20  - some are 18, some 19
        taken:taken,(numslices-count taken)#taken;
        / Now average images over blocks
        newvals:avg each raze each ''taken;
        :newvals}
        / Now to plot all resized images as a grid - uncomment if you want to see the grid
/        fig::.p.eval"plt.figure()";
/        k:{(.p.wrap fig[`add_subplot;<;4;5;x+1])[`imshow;<;newvals x;`cmap pykw `gray]}each til count newvals;
/        k[];
/        plt:.p.import `matplotlib.pyplot;
/        plt[`show;<][]
/       }

lst:system "ls ./input/sample_images"
/ fin contains the pre-processed resized list of lists of slices
fin:{pd[x,"/"]}each lst;

/ ================== Neural net begins here ====================

/ Now on to the convolutional neural net - great reference page at -
/ https://en.wikipedia.org/wiki/Convolutional_neural_network
/ Simple conv net here , two conv3D layers, each activated using
/ relU layers, then a fully-connected(fc) layer(relU-activated again),
/ then to end with an output layer
/ Usually, one starts with an approximate architecture, then
/ tweaks values to get better results.
/ Imitating the visual cortex in animals, the conv net
/ moves over the source image, with a window(also called filter) as the lens
/ the movements are decided by the "strides" parameter


/ Create a conv 3D layer, with dimemsion(5x5x5) filters, compute 32 features
/ Pass those 32 outputs to another conv 3D layer, with dimension(5x5x5) filters, compute 64 features
/ pass those 64 outputs to a dense(fully-connected) layer
/ Import tensorflow here and then begin:
tf:.p.import `tensorflow
keras:.p.import `keras.backend;
/ Initialise all weights and biases as tenforflow tensors
/ of correct dimensions
/ Utility method to get a foeign pointer to n-dim arrays
/ Workaround for the tuple problem - ndim arrays get converted to tuples (n>1)
npar:{(.p.import `numpy)[`array;>;x]}
/ Utility method to get a value inside a TensorFlow object
getval:{keras[`get_value;<;x]}
/ Utility method for tf.Variable
tfvar:{tf:.p.import `tensorflow;tf[`Variable;>;x]};
/ Initialize weights and biases
wconv1:tfvar tf[`random_normal;<;npar[(3;3;3;1;32)]]; / 32 features, 1 channel
wconv2:tfvar tf[`random_normal;<;npar[(3;3;3;32;64)]]; / 64 features, 32 channel
wfc:tfvar tf[`random_normal;<;npar[(54080;1024)]];
nclasses:2 / if cancer, if not cancer - returned as probabilities
wout:tfvar tf[`random_normal;<;npar[(1024;nclasses)]];
wts:(`wconv1;`wconv2;`wfc;`out)!(wconv1;wconv2;wfc;wout);

bconv1:tfvar tf[`random_normal;<;enlist (32)]
bconv2:tfvar tf[`random_normal;<;enlist (64)]
bfc:tfvar tf[`random_normal;<;enlist (1024)]
bout:tfvar tf[`random_normal;<;enlist (nclasses)];
biases:(`bconv1;`bconv2;`bfc;`out)!(bconv1;bconv2;bfc;bout)

/ resize all input image chunks to 3D images
/ original dimensions - 20, 50, 50(20 blocks of 50x50 each)
/ final - 20 images of 50, 50, 20 each
/ and typecast to float 32 to match "input" variable inside conv3d call - tensorflow requirements
show count each fin;
fin:{npar getval tf[`reshape;<;npar "e"$fin x;`shape pykw npar (-1;50;50;count fin x;1)]}each til count fin;

opt:tf[`train.AdamOptimizer;*;`learning_rate pykw 0.001]
/ this function trains the neural net on all the reshaped 3D images
trainnet:{
        l1:tf[`nn.conv3d;<;fin x;wts`wconv1;`strides pykw .p.pyeval"list([1,1,1,1,1])";`padding pykw `SAME];
        l1:tf[`nn.max_pool3d;<;l1;`ksize pykw .p.pyeval"list([1,2,2,2,1])"; `strides pykw .p.pyeval"list([1,2,2,2,1])";`padding pykw `SAME];
        l2:tf[`nn.relu;<;tf[`nn.conv3d;<;l1;wts`wconv2;`strides pykw .p.pyeval"list([1,1,1,1,1])";`padding pykw `SAME]];
        l2:tf[`nn.max_pool3d;<;l2;`ksize pykw .p.pyeval"list([1,2,2,2,1])"; `strides pykw .p.pyeval"list([1,2,2,2,1])";`padding pykw `SAME];
        fc:tf[`reshape;<;l2;npar(-1;54080)];
        fc:tf[`nn.relu;<;tf[`matmul;<;fc;wts`wfc]];
        fc:tf[`nn.dropout;<;fc;0.8];
        :tf[`matmul;<;fc;wts`out]
         }
output:trainnet each til count fin;

/ read labels from disk - for some reason, 1 is missing. 
lbl:("SI";enlist ",")0: `stage1_labels.csv
lbl:select from lbl where id in `$lst
k:lbl`cancer;
k1:((count k)#());
t:{$[0=k[x];k1[x]:(1 2)#(1;0);k1[x]:(1 2)#(0,1)]}
k1:t each til count k;

/ output has one extra
output:output[til count k1];
temp:{tf[`nn.softmax_cross_entropy_with_logits;<;`logits pykw output[x];`labels pykw npar k1[x]]}each til count output
cost:tf[`reduce_mean;<;temp];
optimizer:opt[`minimize;*;cost]

/ Now to run the computation graph in a tf Session
p)import tensorflow as tf
sess:.p.eval"tf.Session()";
sess[`run;<;.p.pyeval"tf.global_variables_initializer()"];
fin:fin[til count k1]; / lose one image for now - the missing patient mystery
.p.set[`X;fin]
.p.set[`Y;k1]
p)x = tf.placeholder('float')
p)y = tf.placeholder('float')
.p.set[`optimizer;optimizer]
.p.set[`cost;cost]
.p.set[`sess;sess]
/ p)sess.run([optimizer, cost], feed_dict={x: X, y: Y})
/ Could run as sess[`run;(optimizer;cost) ; don't know how to pass the feed_dict - x and y need to be tf placeholders - will figure it out
o:.p.eval"sess.run([optimizer, cost], feed_dict={x: X, y: Y})"
/ Loss
show (o`)1;

/ Evaluate
/ prediction and k1 are nested, so un-nest them
prediction:((count prediction),2)#raze over getval each prediction;
k1:((count k1),2)#raze over k1;
correct:tf[`equal;<;tf[`argmax;<;npar prediction;npar 1];tf[`argmax;<;npar k1;npar 1]];
accuracy:tf[`reduce_mean;<;tf[`cast;<;correct;`float]]
show getval accuracy;
