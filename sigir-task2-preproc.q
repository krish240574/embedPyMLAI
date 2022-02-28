/ Preproc code for task2 - purchase prediction for the SIGIR competition 
/ https://sigir-ecom.github.io/data-task.html
/ https://github.com/NVIDIA-Merlin/competitions/blob/main/SIGIR_eCommerce_Challenge_2021/task2_purchase_prediction/code/preprocessing/preproc-V1/coveo-ETL-NVT-Task2-V1-phase2.ipynb
/ data available and explained at : https://github.com/coveooss/SIGIR-ecom-data-challenge
/ Paper for this solution by NVidia - https://arxiv.org/pdf/2107.05124.pdf

/ Get browsing data and merge with test dataset to create event dataset
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
/ strain`query vector is loaded as a list of lists of strings, do this to store as list of lists of floats
(strain`query_vector):"F"${"," vs x} each raze over 'string each select query_vector from strain
/ Similar treatment for clicked_skus_hash, loaded as a list of lists of `symbols
(strain`clicked_skus_hash):"," vs 'string each (select clicked_skus_hash from strain)`clicked_skus_hash 
/ Similar treatment for product_skus_hash
(strain`product_skus_hash):"," vs 'string each (select product_skus_hash from strain)`product_skus_hash 

/ https://arxiv.org/pdf/2107.05124.pdf - explains why test data is also used
p)import json
p)test_queries = json.load(open("./intention_test_phase_2.json"))
f:(.p.get`test_queries)`
tbl:(f 0)`query
{tbl::tbl,(f x)`query}each (1+til (-1 + count f))
/ add column is_test
tbl:tbl,'([]nb_after_add:(count tbl)#0;is_test:(count tbl)#1)
/ Add search events from test data
/ Concat test and train search data
tbs:tbs where (tbs:flip ((cols strain))!(tbl(cols strain)))`is_search
strain:strain,tbs
/ Compute number of returned and clicked items 
strain:strain,'([]impression_size:count each strain`product_skus_hash)
/ little trickstery for clicked_size 
wheregt0:where first each 0<count each 'strain`clicked_skus_hash
/ assign number of clicks
strain:strain,'([]clicked_size:@[z;wheregt0;:;count each (strain`clicked_skus_hash )wheregt0])
/ Compute number of search queries per session 
tmp:(select by session_id_hash from strain)
tmp:tmp,'([]nb_queries:(count tmp)#0)
tmp:strain lj tmp
strain:tmp
/ Update list of impressions by the clicked item when it is missing
/ first, clicked_skus_hash has too many repetitions of clicked_skus_hashes, replace with distinct values
clicked:strain`clicked_skus_hash
f:where raze not  {"" in x}each clicked
strain:((delete clicked_skus_hash from strain),'([]clicked_skus_hash:@[clicked;f;:;{distinct x}each clicked f]))
/ Add clicked_size to the main table
(strain`clicked_size):@[(count strain)#0;f;:;count each kk f]

/ Define the session search as a sequence of search queries and the interacted items
gstrain:select by session_id_hash from `session_id_hash`server_timestamp_epoch_ms xasc strain
/ "F$"," vs 'raze over 'string gstrain`query_vector




