/ https://ministryofdata.org.au/mod-2017-hackathon-problems/wc-pr11-predictive-pumps-pipes-maintenance/
/ A weird dataset, with no machine Ids, only date-time and 379 columns of sensor data
/ I'm asking the question here - "What is the time to failure?", and the approach is quite roundabout, as follows: 
/ I shall predict if a failure occurs at a certain point in time, and then find the difference 
/ of the failure time and start of cycle - that would be the time to failure. Crude, but it is a first foray into the data, 
/ will improve upon it as I see more clearly. 

c:`dt`1000BV2700`300BV2719`400BV2684`400BV2686`415VPowerFail`500BV2680`500BV2681`600BV1157ReservoirILValve`600BV2682`600BV2687`600BV2688`700BV2683`800BV2716`900BV2689`900BV2710`915SV1154ReservoirOLValve`AuxTrans2TempFault`AuxTrans2TempWarn`AuxTransOverTempFault`AuxTransOverTempWarn`BUILDINGTEMPHigh`BV2711Fault`BV2711LocalSelected`BV2711Status`BV2712Fault`BV2712LocalSelected`BV2712Status`BV3605`BatteryChargerNo1Fail`BatteryChargerNo2Fail`BatteryDischargedStatus`BatteryVoltsHighStatus`BatteryVoltsLowStatus`COMMONCONTROLPLC`CascadeDSPress1PidActive`CascadeDSPress2PidActive`CascadeFlowPidActive`ChlLeak20ppmChlRoom`ChlLeak5ppmChlRoom`ChlLeakDetectorCellFailChlRoom`ChlLevelCellNo1ChlRoom`ChlLevelCellNo2ChlRoom`ChlVentilationChlRoom`ChlorinationShutdown`Chlorinator1LossOfChlorine`Chlorinator1VacuumLow`Chlorinator2LossOfChlorine`Chlorinator2VacuumLow`Chlorinator3LossOfChlorine`Chlorinator3VacuumLow`Chlorinator4LossOfChlorine`Chlorinator4VacuumLow`Chlorinator5LossOfChlorine`Chlorinator5VacuumLow`Chlorinator6LossOfChlorine`Chlorinator6VacuumLow`ChlorineLeak20ppm`ChlorineLeak5ppm`ChlorineLeakDetector1`ChlorineLeakDetector2`CommandFault`ContainmentDoorsOpen`DCAuxBatteryDischarged`DCAuxBatteryVoltsHigh`DCAuxBatteryVoltsLow`DCAuxChargerFail`DCChargerFault`DCVoltsLow`DSFullwayLocal`DSFullwayStatus`DSPressure`DWaterPmp1Fault`DWaterPmp2Fault`DWaterPmp3Fault`DWaterPmp4Fault`DWaterPmp5Fault`DWaterPmp6Fault`DelPressureCtrlAvail`DeliveryPressure`DeliveryPressurePidActive`DoorOpen`EBV2711Available`EBV2711InterlockActive`EBV2711InterlockOverride`EBV2712Available`EBV3601Available`EBV3601CmdFailed`EBV3601Opened`EBV3601ValveFault`EBV3602Available`EBV3602CmdFailed`EBV3602Opened`EBV3602ValveFault`Ebv9509Available`Ebv9509Fault`Ebv9509MoveFault`Ebv9509Posn`Ebv9509RemlocalMode`EjectorValve1Fault`EjectorValve2Fault`EjectorValve3Fault`EjectorValve4Fault`EjectorValve5Fault`EjectorValve6Fault`ElectricFence`ElectricFenceStatus`EnergyUsagePeakTariff`FIREDETECTION`FIREDETECTIONSYSTEM`FlowCtrlAvail`FlowCtrlPidActive`FlowMeterError`FlowSetpoint`FlowmeterComms`FlowmeterStatus`GMChlorineResidual`GmChlIsolFault`GmDoseWaterPmpFault`GravityMainChlorineResidual`GravityMainControlMode`GravityMainHighChlShutdown`GravityMainLowChlShutdown`GroupSpecificPowerConsumption`HVSWITCHROOMAUXDCSUPPLY`HillsInletFlowTotal`INTERLOCKPSBV`InflowRate`InflowTotal`InletFlow`InletFlowMeterError`InletPLCCabinetDoorOpen`InletPressure`LevelSetpoint`MAINSPowerWTP`MainsPowerFail`ManifoldsVacuumHigh`MillarPressureCtrlAvail`MillarRdPres`MundijongCtrlAvail`MundijongRdPres`OutflowRate`OutflowTotal`OutletFlow`OutletFlowMeterError`OutletFlowTotal`PEAKTARIFF`PONDLEVELHigh`PRV400PilotSetpoint`PRV400Position`PSAgInLocal`PSAtMaxFlow`PSAtMaxPress`PSDelFlowHighFault`PSDelFlowTransFault`PSDelPressureKDInUse`PSDelPressureKIInUse`PSDelPressureKPInUse`PSDelPressureLow`PSDelPressureModeInUse`PSDelPressureSetpointInUse`PSDelivPressDevFault`PSDeliveryFlow`PSDeliveryFlowTotal`PSDeliveryPres`PSDeliveryPressHigh`PSDischPressTransFault`PSFault`PSFlow`PSFlowKDInUse`PSFlowKIInUse`PSFlowMeterError`PSFlowModeInUse`PSFlowRatioLimitHigh`PSFlowRatioLimitHighHigh`PSFlowSetpointInUse`PSHighDelPress`PSInhibitStatus`PSInhibitedByMillarSv`PSInletPressDevFault`PSInletPressLowWarn`PSInletPressureTransFault`PSMillarPressureKDInUse`PSMillarPressureKIInUse`PSMillarPressureKPInUse`PSMillarPressureModeInUse`PSMillarPressureSetpointInUse`PSMundPressureModeInUse`PSMundijongPressureKDInUse`PSMundijongPressureKIInUse`PSMundijongPressureKPInUse`PSMundijongPressureSetpointInUse`PSNoFlow`PSOverideStop`PSPressureDiff`PSSUMPLEVELHigh`PSSpeedModeInUse`PSSpeedSetpointInUse`PSStarting`PSStartstopStatus`PSSuctionPressureLow`PSTNEfficiency`PhaseFailure`Pmp1Available`Pmp1BEARINGTEMPHigh`Pmp1BEARINGTEMPWARNING`Pmp1BearingTemperatureDE`Pmp1BearingTemperatureDNDE`Pmp1CoolingFlowSwitch`Pmp1CoolingLeakRelay`Pmp1DischargePressureSwitch`Pmp1Efficiency`Pmp1ElectricalFault`Pmp1Flow`Pmp1FlowSwitch`Pmp1HYDRAULICFault`Pmp1InletPressureSwitch`Pmp1MotorBearingTemperatureDE`Pmp1MotorBearingTemperatureDNDE`Pmp1MotorTempAlarm`Pmp1MotorTempWarning`Pmp1PlantFault`Pmp1PowerConsumption`Pmp1Pressure`Pmp1RunHours`Pmp1Running`Pmp1Speed`Pmp1TRANSFORMERAlarm`Pmp1TRANSFORMERWARNING`Pmp1TotalPower`Pmp1VARIABLESPEEDDRIVE`Pmp1VibrationHighFault`Pmp1VibrationHighWarn`Pmp2Available`Pmp2BEARINGTEMPHigh`Pmp2BEARINGTEMPWARNING`Pmp2BearingTemperatureDE`Pmp2BearingTemperatureDNDE`Pmp2CommsHealth`Pmp2CoolingFlowSwitch`Pmp2CoolingLeakRelay`Pmp2DischargePressureSwitch`Pmp2Efficiency`Pmp2ElectricalFault`Pmp2Flow`Pmp2FlowSwitch`Pmp2HYDRAULICFault`Pmp2InletPressureSwitch`Pmp2MotorBearingTemperatureDE`Pmp2MotorBearingTemperatureDNDE`Pmp2MotorTempAlarm`Pmp2MotorTempWarning`Pmp2PlantFault`Pmp2PowerConsumption`Pmp2Pressure`Pmp2RunHours`Pmp2Running`Pmp2Speed`Pmp2TRANSFORMERAlarm`Pmp2TRANSFORMERWARNING`Pmp2TotalPower`Pmp2VARIABLESPEEDDRIVE`Pmp2VibrationHighFault`Pmp2VibrationHighWarn`Pmp3Available`Pmp3BEARINGTEMPHigh`Pmp3BEARINGTEMPWARNING`Pmp3BearingTemperatureDE`Pmp3BearingTemperatureDNDE`Pmp3CoolingFlowSwitch`Pmp3CoolingLeakRelay`Pmp3DischargePressureSwitch`Pmp3Efficiency`Pmp3ElectricalFault`Pmp3Flow`Pmp3FlowSwitch`Pmp3HYDRAULICFault`Pmp3InletPressureSwitch`Pmp3MotorBearingTemperatureDE`Pmp3MotorBearingTemperatureDNDE`Pmp3MotorTempAlarm`Pmp3MotorTempWarning`Pmp3PlantFault`Pmp3PowerConsumption`Pmp3Pressure`Pmp3RunHours`Pmp3Running`Pmp3Speed`Pmp3TRANSFORMERAlarm`Pmp3TRANSFORMERWARNING`Pmp3TotalPower`Pmp3VARIABLESPEEDDRIVE`Pmp3VibrationHighFault`Pmp3VibrationHighWarn`PmpStationDeliveryFlow`PmpStationDeliveryFlowTotal`PondLevel`PondLevelBTOC`PosnCtrlPidActive`PressureSetpoint`PriCtrlActive`Pt6011USPressureSigFault`REGV1158DSPressure`REGV1158USPressure`REGVFlowKDInUse`REGVFlowKIInUse`REGVFlowKPInUse`REGVFlowSetpointInUse`REGVPriCtrlIdInUse`REGVRemPositionKDInUse`REGVRemPositionKPInUse`REGVSecCtrlIdInUse`REGVUSPressureKDInUse`REGVUSPressureKIInUse`REGVUSPressureKPInUse`REGVUSPressureSetpointInUse`REGValve1158Position`RMBV2711ShutFlowNorthTotal`RMChlorineResidual`RMFlowNorthBV2711CLOSED`RMFlowNorthFlowMeterError`RTUBatterylow`RTUPower`RTUPowerFail`RV1158Fault`Regv1158CircuitBreakerTrip`RegvFlow`RegvPosition`RegvUSPress`ResFlowMeterError`ResLowLevelFault`ResRapidfillFlowRate`ResRapidfillTotalFlow`ResRegfillFlowRateMFE6013`ResRegfillTotalFlow`RisingMainChlorineResidual`RisingMainControlMode`RmChlIsolVlvFault`RtuCcPLCHealthy`SecCtrlActive`SecurityWTP`SecurityPS`SiteBypassAgInLocal`SitePowerConsumption`SuctionPressure`TMBv2711OpenFlowNorthTotal`TMFlowNorthBV2711OPEN`TMFlowNorthFlowMeterError`TMFlowSouth`TMFlowSouthFlowMeterError`TMFlowSouthTotal`TamworthBankDeliveryPressure`TamworthBankInletManifoldPressure`TamworthPsInhibit`TariffRateFlatcentskWh`TariffRateOffPeakcentskWh`TariffRateOnPeakcentskWh`TotalPowerConsumption`TrunkMainFlowDirectionTamworthHill`UPS1BatteryVoltsLow`UPS1LineFault`UPS1OnBypass`UPS2BatteryVoltsLow`UPS2LineFault`UPS2OnBypass`UPSBatteryLow`UPSFaultWTP`USPressure`VSD1Inhibit`VSD1RoomTemp`VSD1StartInhibit`VSD2Inhibit`VSD2RoomTemp`VSD2StartInhibit`VSD3Inhibit`VSD3RoomTemp`VSD3StartInhibit`WTPPLCCommsFail`WTPPowerConsumption`pH2
onehot:{[dummycol;dummytbl]k:group dummytbl dummycol;h:value k;z:flip ((count ds),(count k))#0;:flip (key k)! @'[z;h;:;1]};
colStr:"*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSFSSSSSSSFSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSFSSSSSSSSFSSSFSSFSSSSSSSSSSFSFSSSFSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSFSSSSSSSSSSFFSSFSSSSSSSSSSSSSSSSSSSSSSSSSSFFSSFSSSSSSSSSSSSSSSSSSSSSSSSSFFSSFSSSSSSSSFSSSSSSSSSSSSSSSSSSSFFFFSSSSSSSSSSSSSSSSSSSSSSSFFSFSFSFSSSSSSSSSSSSSSSSFSSSSSSSSSSSS";
d:(colStr;enlist ",")0: `:base1.csv;

cd:cols d;
/ Remove floating point columns, keep only categorical
cd:cd where not cd in `dt,(cols d) where "F" = colStr;
/ For now - don't use this, too complex
cd:cd where not cd in `TotalPowerConsumption;
ccd:d cd;
/ Find where `Bad happens, in each categorical column,
/ then calculate time to failure
wcd:cd where 0< sum each `Bad = ccd;
bad:ccd where 0< sum each `Bad = ccd;
if[0<count bad;fbad:wcd!bad;k:"Z"$(d first each where each `Bad = (value fbad))`dt; f:k - "Z"$first d`dt];
show (key fbad) ! f;

/ One-hot encode all categorical columns
ds:d;
f:{show x;s:onehot[x;ds];cs:string cols s;cs:"," sv cs;cs:ssr[cs;" ";"-"];cs:"," vs cs;cs[where 0= count each " " = cs]:"E";cs:`$((string x),"_"),/: cs;ds::(flip cs!(s cols s)),'ds};
f each cd;
/ Delete all categorical columns from original table
ds:![ds;();0b;cd];

/ Create RUL and label columns here
firstbad:first first each where each `Bad = fbad;
g:neg ("Z"$d[til firstbad]`dt) - "Z"$d[firstbad]`dt
rul:([]rul:g,((count d) - (count g))#0f)
q)ds:rul,'ds
lbl:([]lbl:20>rul`rul)
q)ds:lbl,'ds

/ Now remove one-hot encoded columns with occurence of 1 >50%
q)cds:cols ds
q)fc:(cols d) where "F"=colStr
q)cds:cds where not cds in fc
q)dd:ds cds
q)dss: sum each dd 2+til (-4+count dd)
q)tss:dss%count ds
wtss:where (tss>0.7) and (tss<1)
q)wtss+:2 / readjust for 2+til (-4+count dd) above
q)tds:flip (cds wtss) ! ds cds wtss
tds:tds,'flip fc!ds fc;
tds:([]dt:ds`dt),'([]rul:ds`rul),'([]lbl:ds`lbl),'tds;
/ Need to get rid of d and ds here, too much memory leakage !



