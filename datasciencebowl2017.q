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

