l p.q
\l inc/tst.p

WINDOWSIZE:65; NUMCOLS:16;T2VDIM:3;EMBED_DIM:64;INPSL:16;N_HEADS:8;FF_DIM:256;DROPOUT_RATE:0.0;

mult:.p.import[`tensorflow]`:math.multiply / directly access the method inside a module this way
add:.p.import[`tensorflow]`:math.add
lyr:.p.import`tensorflow.keras.layers

flt:lyr[`:Flatten][];
dense128:lyr[`:Dense;128;`activation pykw "selu"]
dropout:lyr[`:Dropout;DROPOUT_RATE]
dense1:lyr[`:Dense;1;`activation pykw "linear"]
mdl:.p.import[`tensorflow]`:keras.models.Model
ln:lyr[`:LayerNormalization;`epsilon pykw 0.000001];
Adam:.p.import[`tensorflow]`:keras.optimizers.Adam;
tb:((.p.get`TransformerBlock)[EMBED_DIM;INPSL + (INPSL * T2VDIM); N_HEADS; FF_DIM; DROPOUT_RATE]);

finp::()
get_model:{[inshape;t2vdim]
 inp:xx:lyr[`:Input;inshape];
 t2v:(.p.get`Time2Vec)[t2vdim-1];
 temb:lyr[`:TimeDistributed;t2v][xx];
 .p.set[`temb;temb];.p.set[`xx;xx];.p.set[`conc;lyr[`:Concatenate;`axis pykw -1]];xx:.p.eval"conc([xx,temb])";
 xx:ln[xx];
 finp::xx;
 
 func:{
  0N!x;
  x_old:finp;
  finp::tb[finp];
  .p.print finp;
  finp::add[mult[0.1;finp];mult[0.9;x_old]];
  :x+1};
 (7>)func \1;
 
 finp::flt[finp]; finp::dense128[finp]; finp::dropout[finp]; finp::dense1[finp];
 out:finp;
 model:mdl[inp;out];
 model[`:compile;Adam[0.001];`metrics pykw .p.get`smape];
 :model
 }
