\d .wpd
nparray:.p.import[`numpy;`:array;>];
pre:.p.import `sklearn.preprocessing
mms:pre[`:MinMaxScaler;*][]
pndf:.p.import[`pandas;`:DataFrame;*];
pd:{[d;wsize;cd;colStr]
        / Float columns
        fc:cd where "F"=colStr;
        / Categorical columns
        cd:cd where not cd in `dt,(cols d) where "F" = colStr;
        / For now - don't use this, too complex
        cd:cd where not cd in `TotalPowerConsumption;

        / Find where `Bad happens, in each categorical column,
        / then calculate time to failure
        ccd:d cd;
        wcd:cd where 0< sum each `Bad = ccd;
        bad:ccd where 0< sum each `Bad = ccd;
        if[0<count bad;fbad:wcd!bad;k:"Z"$(d first each where each `Bad = (value fbad))`dt; f:k - "Z"$first d`dt];
        / Create RUL and label columns here
        firstbad:first first each where each `Bad = fbad;
        g:neg ("Z"$d[til firstbad]`dt) - "Z"$d[firstbad]`dt;
        d:([]lbl:20>rul`rul),'(rul:([]rul:g,((count d) - (count g))#0f)),'d;
        / Normalize float columns
        normdf:mms[`:fit_transform;<;pndf[nparray 0^'flip d fc]];
        normdf:([]rul:d`rul),'([]lbl:d`lbl),'flip fc !flip normdf;
        / Labels for LSTM
        l:reverse ((neg wsize) + count normdf) # reverse normdf`lbl;
        normdf:0^'flip normdf cols normdf;
        / wsize - row sequences for LSTM
        tv:normdf v:(til((neg wsize)+count normdf))+\:til wsize;
        / Return data and labels in LSTM-ready format
        :(tv;l)};
