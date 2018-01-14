/ All function definitions for datasciencebowl.q in this namespace
\l p.q
p)import os
p)import numpy as np
p)import dicom

\d .dsbowl
counter:0;
/ Workaround for the tuple problem - ndim arrays get converted to tuples (n>1)
npar:.p.import[`numpy;`array;>];
/ CV2 resize function
resize:.p.import[`cv2;`resize;<];
rsz:{tup:.p.eval"tuple([50,50])";:resize[npar x;tup`.]};
/ Preprocessing function - all images are read, sorted and resized here
pd:{[fx;path]
        show fx;
        ret:0;
        show "Counter:";
        show counter;
        .p.set[`fx;fx];
        .p.set[`inp;"./input",path];
        / read images from disk, (each directory contains multiple images, or slices)
        .p.set[`slices;.p.pyeval"[dicom.read_file(inp+fx+s) for s in os.listdir(inp+fx)]"];
        / Sort(in-place) by image position
        .p.eval"slices.sort(key = lambda x: int(x.ImagePositionPatient[2]))";
        / Get image pixel data
        tmp:.p.eval"[(slices[i].pixel_array) for i in np.arange(len(slices))]";
        imgs::tmp`;
        show count imgs;
        counter+::1;

        / 512x512 is too large - resize to 50,50
        / If null image , resize by force and don't call buggy cv2 resize()
        ret:{$[0=(sum/) imgs[x];imgs[x]::(50,50)#100;imgs[x]::rsz imgs[x]]}each til count imgs;

        / TODO - Need to refactor this code into a new function - too much code here.
        / Now to chunk each directory of images into blocks of ((count imgs)%20)
                / then average each block into one image each.
        numslices:20;
        chunksize:ceiling((count imgs)%numslices);
        cutexp:(t where (count imgs)>t:chunksize*til numslices);
        taken:cutexp _ imgs;
        tmp:last taken;

        / Make the last block = chunksize
        diffexp:(((first count each taken)-count tmp)#);
        l: diffexp over tmp;
        taken[-1+count taken]:tmp,l;

        / When one firsst splits into slices, some images are
        / discarded at the end, this fixes that
        extra:-1+(count imgs) - last cutexp;
        tmp::imgs ((count imgs)-extra)+til extra;

        / Create a new chunk of size chunksize from the discarded images here
        tmp::tmp,l:diffexp over tmp;

        / Need to make all blocks of size 20 slices - some are 18, some 19
        if[numslices>count taken;taken:taken,((numslices-count taken),chunksize)#tmp];

        / Now average images over blocks
        show (count taken);
        show count each taken;
        newvals:avg each raze each ''taken;
        :newvals}
