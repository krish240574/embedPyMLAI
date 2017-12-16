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
rsz:{np:.p.import`numpy;cv:.p.import`cv2;tup:.p.eval"tuple([150,150])";:cv[`resize;<;np[`array;>;x];tup`.]}
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

        / 512x512 is too large - resize to 150,150
        / If null image , resize by force and don't call buggy cv2 resize()
        ret:{$[0=(sum/) imgs[x];imgs[x]::(150,150)#100;imgs[x]::rsz imgs[x]]}each til count imgs;

        / Now to chunk each directory of images into blocks of ((count imgs)%20)
        / then average each block into one image each.
        numslices:20;
        chunksize:ceiling((count imgs)%numslices);
        taken:(t where (count imgs)>t:chunksize*til numslices) _ imgs;
        tmp:last taken;
        l: (((first count each taken)-count tmp)#) over tmp;
        taken[-1+count taken]:tmp,l;
        newvals::avg each raze each ''taken;
        / Now to plot all resized images as a grid
        fig::.p.eval"plt.figure()";
        k:{(.p.wrap fig[`add_subplot;<;4;5;x+1])[`imshow;<;newvals x;`cmap pykw `gray]}each til count newvals;
        k[];
        plt:.p.import `matplotlib.pyplot;
        plt[`show;<][]}

lst:system "ls ./input/sample_images"
fin:{pd[x,"/"]}each lst;

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
/ Each filter captures its results as one feature

/ Create a conv 3D layer, with 5x5x5 filters, 32 of them
/ Also, since the images are gray scale, only one channel is being used
/ One needs to initialise weights and biases according to the architecture

/ Import tensorflow here and then begin:
tf:.p.import `tensorflow

/ Initialise all weights and biases as tenforflow tensors
/ of correct dimensions
npar:{(.p.import `numpy)[`array;>;x]}
getval:{keras:.p.import `keras;keras[`backend.get_value;<;x]}
tfvar:{tf:.p.import `tensorflow;tf[`Variable;>;x]};
wconv1:tfvar tf[`random_normal;<;npar[(5;5;5;1;32)]];
wconv2:tfvar tf[`random_normal;<;npar[(5;5;5;32;64)]];
wfc:tfvar tf[`random_normal;<;npar[(54080;1024)]];
nclasses:2
wout:tfvar tf[`random_normal;<;npar[(1024;nclasses)]];
wts:(`wconv1;`wconv2;`wfc;`out)!(wconv1;wconv2;wfc;wout);

bconv1:tfvar tf[`random_normal;<;enlist (32)]
bconv2:tfvar tf[`random_normal;<;enlist (64)]
bfc:tfvar tf[`random_normal;<;enlist (1024)]
bout:tfvar tf[`random_normal;<;enlist (nclasses)];
biases:(`bconv1;`bconv2;`bfc;`out)!(bconv1;bconv2;bfc;bout)

/ fin:{show"inside reshape";keras:.p.import`keras;npar "f"$getval tf[`reshape;<;npar fin x;`shape pykw npar (-1;50;50;count fin x;1)]]}each til count fin;
/ tf[`nn.conv3d;<;tfvar fin 0;npar "f"$getval wts`wconv1];`strides pykw .p.pyeval"list([1,1,1,1,1])";`padding pykw `SAME];

/ resize all input image chunks to 3D images
/ original dimensions - 20, 50, 50(20 blocks of 50x50 each)
/ final - 20 images of 50, 50, 20 each
fin:{show"inside reshape";tf[`reshape;<;npar fin x;`shape pykw npar (-1;50;50;count fin x;1)]}each til count fin;

/ Conv layer 1
l1:tf[`nn.conv3d;<;fin 0;wts`wconv1;`strides pykw .p.pyeval"list([1,1,1,1,1])";`padding pykw `SAME];
/ Max pool conv layer 1
l1:tf[`nn.max_pool3d;<;l1;`ksize pykw .p.pyeval"list([1,1,1,1,1])"; `strides pykw .p.pyeval"list([1,2,2,2,1])";`padding pykw `SAME]
/ Conv layer 2, apply relU to it
l2:tf[`nn.relu;<;tf[`nn.conv3d;<;l1;wts`wconv2;`strides pykw .p.pyeval"list([1,1,1,1,1])";`padding pykw `SAME]]
/  Max pool conv layer 2
l2:tf[`nn.max_pool3d;<;l2;`ksize pykw .p.pyeval"list([1,1,1,1,1])"; `strides pykw .p.pyeval"list([1,2,2,2,1])";`padding pykw `SAME]
/ Fully-connected(dense) layer
fc:tf[`reshape;<;l2;npar(-1;54080)]
/ Relu dense layer
fc:tf[`nn.relu;<;tf[`matmul;<;fc;wts`wfc]]
/ Dropout on dense layer
fc:tf[`nn.dropout;<;fc;0.8]
/ Finally , output !(2 classes)
output:tf[`matmul;<;fc;wts`out]
