colStr:"DSSJI",80#"I";
/ Download dataset from https://www.backblaze.com/b2/hard-drive-test-data.html - 2013 dateset used here
d:(colStr;enlist ",")0: `:/home/kkumar/q/l64/backblaze/2013/all.csv
/ t:select diskid:serial_number,model:model,capacitybytes:capacity_bytes,mindate:min date,maxdate:max date, nrecords:count date,minhours:min smart_9_raw, maxhours:max smart_9_raw, failed:sum failure by serial_number, model, capacity_bytes  from d
