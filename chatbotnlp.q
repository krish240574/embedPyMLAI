pos:0;
t:([]k:();v:());
fn:{d:read0(`:10k.json;pos;10000);cb:where each "}"=d;k:(where 0=count each cb)0;if[k>0;d:k#d];dj::.j.k each d;pos+::k+count raze d;{`t insert ((key dj x);value dj x)}each til count dj}each til 20

