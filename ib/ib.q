/ Access interactive brokers api and perform algo trading - Code from James Ma Weiming book. 
\l p.q
contract:.p.import `ib.ext.Contract;
contract:contract[`Contract;*];
order:.p.import `ib.ext.Order;
order:order[`Order;*];
conn:.p.import `ib.opt.connection;
conn:conn[`Connection;*];
create_contract:{[symbol;sectype;exch;primexch;curr]
        contr:contract[];
        contr[:;`m_symbol;symbol];;
        contr[:;`m_secType;sectype];
        contr[:;`m_exchange;exch];
        contr[:;`m_primaryExch;primexch];
        contr[:;`m_currency;curr];:contract}
        
