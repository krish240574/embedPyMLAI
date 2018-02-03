/ Very rough code, don't bother using !
pos:0;
t:([parent_id:()];comment_id:();parent:();comment:();subreddit:();created_utc:();score:());
t:([]parent_id:();comment_id:();parent:();comment:();subreddit:();created_utc:();score:());
f:`:/home/kkumar/Desktop/bigdata.json;
n:100000;

fp:{[dji]g:(select comment from t where comment_id like dji`parent_id)`comment;$[0<count g;:enlist g;:enlist dji`body]};
fn:{show "Number f rows :";show count t;d:read0(f;pos;n);cb:where each "}"=d;if[0<count cb[0];k:(where 0=count each cb)0;if[k>0;d:k#d];dj::.j.k each d;pos+::k+count raze d;{i:([]parent_id:enlist x`parent_id;comment_id:enlist x`name;parent:enlist x`body ;comment:enlist x`body;subreddit:enlist x`subreddit;created_utc:enlist x`created_utc;score:0^x`score);`t insert i}each dj]};

\

/
c:floor (count t)%10;
k:{(c*(1+x))+til c}each til 10
k:(c*(1+0))+til c
f0:t k[0];save `:f0.csv;
show "0";
f1:t k[1];save `:f1.csv;
show "1";
f2:t k[2];save `:f2.csv;
show "2";
f3:t k[3];save `:f3.csv;
show "3";
f4:t k[4];save `:f4.csv;
show "4";
f5:t k[5];save `:f5.csv;
show "5";
f6:t k[6];save `:f6.csv;
show "6";
f7:t k[7];save `:f7.csv;
show "7";
f8:t k[8];save `:f8.csv;
show "8";
f9:t k[9];save `:f9.csv;
show "9";

g:(`$":",/:string (til 10)),\:`$".csv"

\
/ find parent comments
q)k:t where (t`comment_id) in t`parent_id
/ link comments to parents
/ w:where (k`comment_id) in t`parent_id
/ w:select from t where parent_id in k`comment_id
w:(select i from t where parent_id in k`comment_id)`x / need to verify this 
c:t`comment
{c[x]:k[x]`parent}each w
t:([]c),'t;
~

