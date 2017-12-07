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
/ Plot image here, only one for now. (512X512 image)
q)plt:.p.import `matplotlib.pyplot
plt[`imshow;<;imgs[0]]
plt[`show;<][]
 
/ Split the list of images into chunks of 20 each
/ Take them separately, in order to average and resize
numslices:20;
chunksize:ceiling((count imgs)%numslices);
taken:(20*til chunksize) _ imgs  
/ fill up the last list to chunksize
tmp:last taken
l: ((-1+chunksize)#) over tmp
taken[-1+count taken]:tmp,l




