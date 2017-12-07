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
q)p)import numpy as np
/ Get all pixel data, for the scans, the rest of the info inside each returned object is meta about the patient
p)imgs = [(slices[i].pixel_array) for i in np.arange(len(slices))]
/ Ebter the quniverse here
imgs:(.p.get`imgs)`;
/ Plot image here, only one for now. (512X512 image)
q)plt:.p.import `matplotlib.pyplot
plt[`imshow;<;imgs[0]]
plt[`show;<][]
~                     



