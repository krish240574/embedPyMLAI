\d .
\l p.q

\d .pm
pd:{[d;cs;tt]
        floatCols:(!+0!d)[&:"F"=cs]; / !+0!d is safe because we know d is a table for sure, otherwise one needs to run checks, like the "cols" method
        gd:?[d;();(enlist `id)!enlist `id;()];
        gid:=:d`id;
        vgd:.:gd;
        if[&/"test"=tt;[tr:([]remcycles:"I"$0:: `:PMtruth.txt);cycle:([]cycle:(tr`remcycles)+vgd`cycle);vgd:![vgd;();0b;enlist`cycle];vgd:cycle,'vgd]];
        d:([]rul:,/(vgd`cycle)-(d`cycle)[.:gid]),'d;
        d:([]lbl1:30>(d`rul)|30=d`rul),'([]lbl2:15>(d`rul)|15=d`rul),'([]cyclenorm:d`cycle),'d;
        :d};

npar:.p.import [`numpy;`array;>];
pd:.p.import[`pandas;`DataFrame;*];
pre:.p.import `sklearn.preprocessing;
norm:{[d;fc]
        / Normalize training and test data
        mms:pre[`MinMaxScaler;*][];
        / fc,:`cyclenorm; / Add a column "cyclenorm"
        df:pd[npar d];
        .p.set[`mms;mms];
        .p.set[`df;df];
        ft:.p.eval"mms.fit_transform(df)";
        :ft`};
