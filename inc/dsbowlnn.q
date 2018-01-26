\d .dsnn
/ ================== Neural net begins here ====================

/ https://en.wikipedia.org/wiki/Convolutional_neural_network
/ Simple conv net here , two conv3D layers, each activated using
/ relU layers, then a fully-connected(fc) layer(relU-activated again),
/ then to end with an prediction layer
/ Usually, one starts with an approximate architecture, then
/ tweaks values to get better results.
/ Imitating the visual cortex in animals, the conv net
/ moves over the source image, with a window(also called filter) as the lens
/ the movements are decided by the "strides" parameter

/ Create a conv 3D layer, with dimemsion(3x3x3) filters, compute 32 features
/ Pass those 32 predictions to another conv 3D layer, with dimension(5x5x5) filters, compute 64 features
/ pass those 64 predictions to a dense(fully-connected) layer
/ Import tensorflow here and then begin:

tf:.p.import `tensorflow
.dsnn.npar:.p.import[`numpy;`:array;>];

/ Utility method to get a value inside a TensorFlow object
.dsnn.getval:.p.import[`keras;`:backend;`:get_value;<];

/ Utility method for tf.Variable
.dsnn.tfvar:.p.import[`tensorflow;`:Variable;<];

/ Initialise all weights and biases as tenforflow tensors
/ of correct dimensions
/ Initialize weights and biases

nclasses:2 / if cancer, if not cancer - returned as probabilities
/ 32 features, 1 channel
wconv1:.dsnn.tfvar tf[`:random_normal;<;.dsnn.npar[(3;3;3;1;32)]];
/ 64 features, 32 channels
wconv2:.dsnn.tfvar tf[`:random_normal;<;.dsnn.npar[(3;3;3;32;64)]];
wfc:.dsnn.tfvar tf[`:random_normal;<;.dsnn.npar[(54080;1024)]];
wout:.dsnn.tfvar tf[`:random_normal;<;.dsnn.npar[(1024;nclasses)]];
wts:(`wconv1;`wconv2;`wfc;`out)!(wconv1;wconv2;wfc;wout);
bconv1:.dsnn.tfvar tf[`:random_normal;<;enlist (32)];
bconv2:.dsnn.tfvar tf[`:random_normal;<;enlist (64)];
bfc:.dsnn.tfvar tf[`:random_normal;<;enlist (1024)];
bout:.dsnn.tfvar tf[`:random_normal;<;enlist (nclasses)];
biases:(`bconv1;`bconv2;`bfc;`out)!(bconv1;bconv2;bfc;bout);

/ resize all input image chunks to 3D images
/ original dimensions - 20, 50, 50(20 blocks of 50x50 each)
/ final - 20 images of 50, 50, 20 each
/ and typecast to float 32 to match "input" variable inside conv3d call - tensorflow requirements
.dsnn.reshape:{[findata;c].dsnn.npar .dsnn.getval tf[`:reshape;<;.dsnn.npar "e"$findata c;`shape pykw .dsnn.npar (-1;50;50;count findata c;1)]};
show "Images resized to 3D - to suit NN...";

/ this function trains the neural net on all the reshaped 3D images
.dsnn.trainnet:{[nndata;c]
        l1:tf[`:nn.conv3d;<;nndata c;wts`wconv1;`strides pykw .p.pyeval"list([1,1,1,1,1])";`padding pykw `SAME];
        l1:tf[`:nn.max_pool3d;<;l1;`ksize pykw .p.pyeval"list([1,2,2,2,1])"; `strides pykw .p.pyeval"list([1,2,2,2,1])";`padding pykw `SAME];
        l2:tf[`:nn.relu;<;tf[`:nn.conv3d;<;l1;wts`wconv2;`strides pykw .p.pyeval"list([1,1,1,1,1])";`padding pykw `SAME]];
        l2:tf[`:nn.max_pool3d;<;l2;`ksize pykw .p.pyeval"list([1,2,2,2,1])"; `strides pykw .p.pyeval"list([1,2,2,2,1])";`padding pykw `SAME];
        fc:tf[`:reshape;<;l2;.dsnn.npar(-1;54080)];
        fc:tf[`:nn.relu;<;tf[`:matmul;<;fc;wts`wfc]];
        fc:tf[`:nn.dropout;<;fc;0.8];
        :tf[`:matmul;<;fc;wts`out]
         }

/ Make predictions using nnet
.dsnn.predict:{[fin]
        fin:.dsnn.reshape[fin] each til count fin;
        prediction:.dsnn.trainnet[fin] each til count fin;
        :prediction
        };

\d .
/ Use Adam Optimizer
opt::tf[`:train.AdamOptimizer;*;`learning_rate pykw 0.001]
getval::.p.import[`keras;`:backend;`:get_value;<];
