// Preproc code for task2 - purchase prediction for the SIGIR competition 
// https://sigir-ecom.github.io/data-task.html


// Get browsing data and metge with test dataset to create event dataset
bColStr:`session_id_hash`event_type`product_action`product_sku_hash`server_timestamp_epoch_ms`hashed_url
c:"SSSSIS"
.Q.fs[{`btrain insert flip bColStr!(c;",")0:x}]`:browsingtrain.csv
btrain:btrain,'([]is_search:(count btrain)#0;is_test:(count btrain)#0;nb_after_add:(count btrain)#0)
q)p)import json
q)p)test_queries = json.load(open("./intention_test_phase_2.json"))
q)f:(.p.get`test_queries)`
tbl:(f 0)`query
{tbl::tbl,(f x)`query}each (1+til (-1 + count f))
tbl:tbl,'([]nb_after_add:(count tbl)#0;is_test:(count tbl)#1)
tb:tb where not (tb:flip ((cols btrain))!(tbl(cols btrain)))`is_search
event_df:tb,btrain
