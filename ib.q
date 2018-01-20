\l p.q
/ Using latest IB API from - http://interactivebrokers.github.io
sys:.p.import`sys;
sys[`path;`append;*;"/home/kkumar/q/l64/inc"];
contract:.p.import[`IBWrapper;`contract;*];
ibw:.p.import[`IBWrapper;`IBWrapper;*];
ecs:.p.import `ib.ext.EClientSocket;

/ Why can't I .p.impot[`ib;`ext;`EClientSocket;`EClientSocket;*] directly?
ssub:.p.import `ib.ext.ScannerSubscription
callback:ibw[]
tws:ecs[`EClientSocket;*;callback]
host:""
port:7497
clientId:5000
tws[`eConnect;*;host;port;clientId]
aapl:co[`create_contract;*;`AAPL;`STK;`SMART;`USD]
aplo:co[`create_order;*;`DU15114;`MKT;1000;`BUY]
tws[`placeOrder;*;200;aapl;aaplo]
