\l p.q
dicom:.p.import `dicom
readfile:.p.qcallable dicom`read_file
/ test with this path for now, contains 134 chest scan files(each file is a 'slice'
`dcmpath setenv "/home/kkumar/q/l64/input/sample_images/00cba091fa4ad62cc3200a657aeb957e"
/ read slices as dcm inputs from $dcmpath
slices:{readfile[(getenv `dcmpath),"/",x]}each system "ls $dcmpath"
/ hold all slices in one place for now, the data read returns a weird dict, clean up here
allslices:{value slices[x]}each til count slices
/ the 15th row, 3rd column contains the ImagePatientPosition, an array of 3 floats
/ sort in ascending order based on ImagePatientPosition[2]
/ Get the ImagePatientPosition array here, append it to the main slice table, for sorting
/ Like so :
/  v1     v2     v3
/  --------------------
/ -145.5 -158.2 -316.2
/ -145.5 -158.2 -68.7
/ -145.5 -158.2 -131.2
/ -145.5 -158.2 -121.2
/ -145.5 -158.2 -353.7
/ -145.5 -158.2 -28.7
/ -145.5 -158.2 -78.7
/ -145.5 -158.2 -51.2
/ -145.5 -158.2 -241.2
/ -145.5 -158.2 -56.2
/ -145.5 -158.2 -343.7
/ -145.5 -158.2 -163.7
/ -145.5 -158.2 -298.7
v:flip (`$"v",/:string (1+til 3)) ! flip {"E"$ "\\" vs allslices[x][15;3]}each til count slices

/ Prepare allslices, wth column names
allslices:flip (`$"slicecol",/:string (1+til 35)) ! flip allslices

/ Add the ImagePatientPosition values here and sort
allslices:v,'allslices
allslices:`v3 xasc allslices

/ Now we have all slices for 1 patient, sorted by ImagePatientPosition[2]
/ Each row contains one slice, and the `slicecol35 column contains the scanned image for that slice. 
/ Like so:
/q)allslices[0]`slicecol35 
/ 2145386512
/ "OW"
/ 524288 - size of image
/ "0\3700\3700\3700\3700\3700\3700\3700\3700\3700\3700\3700\3700\3700\3700\3700..
/ 1154
/ 0b
/ 1b



