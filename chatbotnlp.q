pos:0;
t:([]parent_id:();body:();score:();name:();subreddit:();created_utc:());
f:`:/home/kkumar/Desktop/10k.json;
fn:{show "Number f rows :";show count t;d:read0(f;pos;1000);cb:where each "}"=d;if[0<count cb[0];k:(where 0=count each cb)0;if[k>0;d:k#d]];dj::.j.k each d;pos+::k+count raze d;{i:([]parent_id:enlist x`parent_id;body:enlist x`body;score:x`score;name:enlist x`name;subreddit:enlist x`subreddit;created_utc:enlist x`created_utc);`t insert i}each dj};
