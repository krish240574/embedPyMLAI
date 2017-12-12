\l p.q
p)import os
p)import dicom
p)import numpy as np
p)import matplotlib.pyplot as plt
processdata:{
        .p.set[`x]x;
        .p.set[`inp]("./input/sample_images/");
        / dicom read_file here
        t:(.p.pyeval"[dicom.read_file(inp+x+s) for s in os.listdir(inp+x)]")
        .p.set[`slices]t
        / Sort
        t:(.p.pyeval"slices.sort(key = lambda x: int(x.ImagePositionPatient[2]))");
        /       .p.set[`slices]t

        / Get all pixel data, for the scans, the rest of the info inside each returned object is meta about the patient
        imgs:(.p.eval"[(slices[i].pixel_array) for i in np.arange(len(slices))]")`
        -1"1";
        / Enter the quniverse here
        -1"1.5";
        / resize, 512x512 is too large
        / Workaround for tuple - .p.q2py enlist 150 150 fails in the resize call,
        / .p.i `tuple fails too
        .p.eval"t = tuple([150,150])"
        tup:.p.get`t
        np:.p.import`numpy
        cv:.p.import`cv2
        imgs:{cv[`resize;<;np[`array;>;imgs[x]]; tup`. ]}each til count imgs
        -1"2";
        / Split the list of images/slices into chunks of 20 each
        / then collapse each to average of those 20
        numslices:20; / number of slices
        chunksize:ceiling((count imgs)%numslices);
        taken:(chunksize*til numslices) _ imgs;
        / fill up the last list to chunksize
        tmp:last taken;
        l: (((first count each taken)-count tmp)#) over tmp;
        taken[-1+count taken]:tmp,l;
        / Now to average color values in each chunk, across images in it
        newvals:avg each raze each ''taken;
        / Equivalent code - {(imgsize imgsize)#avg raze each taken[x]}each til count taken
        / Can't one instantiate an object directly - plt`figure?
        / Display as a grid of rescaled, gray-scale images - sexy !
        fig:.p.eval"plt.figure()";
        k:{t:(.p.wrap fig[`add_subplot;<;4;5;x+1])[`imshow;<;newvals x;`cmap pykw `gray]}each til count newvals;

        plt:.p.import `matplotlib.pyplot;
        plt[`show;<];
 }
show "here"
processdata["00cba091fa4ad62cc3200a657aeb957e","/"]
