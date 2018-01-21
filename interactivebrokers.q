\l p.q

sys:.p.import`sys;
sys[`path;`append;*;raze (system"pwd"),\:"/inc"];
ibw:.p.import[`IBWrapper;`IBWrapper;*];
contract:.p.import[`IBWrapper;`contract;*];
ecs:.p.import `ib.ext.EClientSocket;
co:contract[];
/ Why can't I .p.import[`ib;`ext;`EClientSocket;`EClientSocket;*] directly?
ssub:.p.import `ib.ext.ScannerSubscription
callback:ibw[]
tws:ecs[`EClientSocket;*;callback]
host:""
port:7497
clientId:6000
tws[`eConnect;*;host;port;clientId]
aapl:co[`create_contract;*;`AAPL;`STK;`SMART;`USD];
ibm:co[`create_contract;*;`IBM;`STK;`SMART;`USD];
aaplo:co[`create_order;*;`15169;`MKT;1000;`BUY];
callback[`initiate_variables;*][];
tws[`placeOrder;*;300;aapl;aaplo]
tws[`reqMktData;*;0;aapl;"";0];system"sleep 2"
