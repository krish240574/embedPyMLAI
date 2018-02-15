\d .bb
cox:{[d] k:select from d where smart_9_raw > avg smart_9_raw, failure=1;s9:avg k`smart_9_raw;g:(count d)#0;g[where (s9<d`smart_9_raw) and  (0=d`failure)]:1;d:(([]cox:g)),'d}
