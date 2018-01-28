b:read0 `:10k.json
q)b:.j.k each b
q)k:key b 0
q)t:([]k;v:value b 0)
q){`t insert (key x;value x)}each b
q)select from t where k=`name


