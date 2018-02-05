pos:0;
t:([parent_id:`$()];comment_id:`$();parent:();comment:();subreddit:();created_utc:();score:());
t:([]parent_id:();comment_id:();parent:();comment:();subreddit:();created_utc:();score:());
f:`:/home/kkumar/Desktop/bigdata.json;
n:100000;
acc:{[body]$[(50<count(" " vs body)) or (1000<count body) or (body like "[deleted]") or (body like "[removed]");0;1]};
ges:{[pid](select score from t where parent_id=pid)`score};
gpd:{[dji] g:(select comment from t where comment_id = `$dji`parent_id)`comment;$[0<count g;:enlist g 0;:enlist dji`body]}
fp:{[dji]show dji`body;if[2<=dji`score;e:ges(`$dji`pid);$[0<count e;[if[((dji`score)>e 0);if[acc(dji`body);![t;enlist(=;`parent_id;`$dji`parent_id);();(enlist `body)!(enlist dji`body)]]]];[if acc(dji`body);g:gpd(dji);$[0<count g;ihp(dji);ihnp(dji)]]]]};
/ g:(select comment from t where comment_id = `$dji`parent_id)`comment;$[0<count g;:enlist g 0;:enlist dji`body]
fn:{show "Number f rows :";show count t;d:read0(f;pos;n);cb:where each "}"=d;if[0<count cb[0];k:(where 0=count each cb)0;if[k>0;d:k#d];dj::.j.k each d;pos+::k+count raze d;{i:([]parent_id:`$enlist x`parent_id;comment_id:`$enlist x`name;parent:fp[x];comment:enlist x`body;subreddit:enlist x`subreddit;created_utc:enlist x`created_utc;score:0^x`score);`t insert i}each dj]};
