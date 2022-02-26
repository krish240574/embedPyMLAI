/ Preproc code for task2 - purchase prediction for the SIGIR competition 
/ https://sigir-ecom.github.io/data-task.html
/ https://github.com/NVIDIA-Merlin/competitions/blob/main/SIGIR_eCommerce_Challenge_2021/task2_purchase_prediction/code/preprocessing/preproc-V1/coveo-ETL-NVT-Task2-V1-phase2.ipynb


/ Get browsing data and metge with test dataset to create event dataset
bColStr:`session_id_hash`event_type`product_action`product_sku_hash`server_timestamp_epoch_ms`hashed_url
c:"SSSSIS"
.Q.fs[{`btrain insert flip bColStr!(c;",")0:x}]`:browsing_train.csv
btrain:btrain,'([]is_search:(count btrain)#0;is_test:(count btrain)#0;nb_after_add:(count btrain)#0)
q)p)import json
q)p)test_queries = json.load(open("./intention_test_phase_2.json"))
q)f:(.p.get`test_queries)`
tbl:(f 0)`query
{tbl::tbl,(f x)`query}each (1+til (-1 + count f))
tbl:tbl,'([]nb_after_add:(count tbl)#0;is_test:(count tbl)#1)
tb:tb where not (tb:flip ((cols btrain))!(tbl(cols btrain)))`is_search
event_df:tb,btrain

// Generate search table from train and test data 
sColStr:`session_id_hash`query_vector`clicked_skus_hash`product_skus_hash`server_timestamp_epoch_ms
sc:"SSSSI"
.Q.fs[{`strain insert flip sColStr!(sc;",")0:x}]`:search_train.csv
strain:strain,'([]event_type:(count strain)#"search";is_search:(count strain)#1;is_test:(count strain)#0)

strain:strain where not null strain`product_skus_hash
(strain`query_vector):" " vs 'string strain`query_vector
(strain`clicked_skus_hash):"," vs 'string strain`clicked_skus_hash
(strain`product_skus_hash):"," vs 'string strain`product_skus_hash

p)import json
p)test_queries = json.load(open("./intention_test_phase_2.json"))
f:(.p.get`test_queries)`
tbl:(f 0)`query
{tbl::tbl,(f x)`query}each (1+til (-1 + count f))
tbl:tbl,'([]nb_after_add:(count tbl)#0;is_test:(count tbl)#1)
tbs:tbs where (tbs:flip ((cols strain))!(tbl(cols strain)))`is_search
strain:strain,tbs
tmp:(select by session_id_hash from strain)
tmp:tmp,'([]nb_queries:(count tmp)#0)
tmp:strain lj tmp
strain:tmp
/ product_skus_hash is read as a column of lists, need to convert to strings as follows
impression_size:([]impression_size:count each "," vs 'raze over 'string strain`product_skus_hash)
/ similar treatment for clicked_skus_hash
clicks_size:([]clicks_size:count each raze over 'string each strain`clicked_skus_hash)
/ Define the session search as a sequence of search queries and the interacted items
gstrain:select by session_id_hash from `session_id_hash`server_timestamp_epoch_ms xasc strain
/ "F$"," vs 'raze over 'string gstrain`query_vector




