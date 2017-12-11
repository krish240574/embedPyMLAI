/ Complete rewrite of code to read scan images - 
/ Reading using read_file of pydicom returns a FileDataSet object
/ on passing to q, all data is clobbered
/ Hence this code, read inside python and pick only relevant(image pixel data) 
/ and pass to q

p)import os
p)import dicom
/ Work with one directory(patient) for now, 134 images/scans/slices inside it. 
p)path = "./input/sample_images" + "/" + "00cba091fa4ad62cc3200a657aeb957e"
/ dicom read_file here
p)slices = [dicom.read_file(path + '/' + s) for s in os.listdir(path)]
/ Sort 
p)slices.sort(key = lambda x: int(x.ImagePositionPatient[2]))

q)p)import numpy as np
/ Get all pixel data, for the scans, the rest of the info inside each returned object is meta about the patient
p)imgs = [(slices[i].pixel_array) for i in np.arange(len(slices))]
/ Enter the quniverse here
imgs:(.p.get`imgs)`;
/ resize, 512x512 is too large
/ Workaround for tuple - .p.q2py enlist 150 150 fails in the resize call,
/ .p.i `tuple fails too
p)t = tuple([150,150])
tup:.p.get`t
np:.p.import`numpy
cv:.p.import`cv2
imgs:{cv[`resize;<;np[`array;>;imgs[x]]; tup`. ]}each til count imgs

/ Plot image here, only one for now. (512X512 image)
q)plt:.p.import `matplotlib.pyplot
plt[`imshow;<;imgs[0]]
plt[`show;<][]
 
/ Split the list of images/slices into chunks of 20 each
/ then collapse each to average of those 20
numineachchunk:20; / number of slices in each chunk
chunksize:ceiling((count imgs)%numineachchunk);
taken:(20*til chunksize) _ imgs  
/ fill up the last list to chunksize
tmp:last taken
l: ((numineachchunk-count tmp)#) over tmp
taken[-1+count taken]:tmp,l
/ Now to average color values in each chunk, across images in it
newvals:avg each raze each ''taken;
/Equivalent code - {(imgsize imgsize)#avg raze each taken[x]}each til count taken





