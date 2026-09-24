PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* 1) Komunikacioni, pogonski i AirRelease izvori                           *)
	(* ======================================================================== *)
	PT_Alarm.Comm.BRB2.Active := PGRad_Cmd.Aktivan AND NOT PGRad_BRB2Watchdog.Valid;
	PT_Alarm.Comm.IEBKB1.Active := PGRad_Cmd.Aktivan
		AND (PGRad.Ctrl.SelektovaniIzvor = _02_IEBKB1)
		AND (NOT PGRad_IEBKB1Prepared.CommValid OR NOT PGRad_IEBKB1Prepared.HeartbeatValid);
	PT_Alarm.Comm.BRB2RemoteFault.Active := PGRad_BRB2.BRB2Fault;
	PT_Alarm.Drive.PG_Pu01_VFD.Active := PG.Act.Pu._1.Alarm_FR;
	PT_Alarm.Drive.PG_Pu01_CAN.Active := PG.Act.Pu._1.Alarm_CAN;
	PT_Alarm.Drive.PG_Pu02_VFD.Active := PG.Act.Pu._2.Alarm_FR;
	PT_Alarm.Drive.PG_Pu02_CAN.Active := PG.Act.Pu._2.Alarm_CAN;
	PT_Alarm.AirRelease.PG_PV03.Active := PGRad_AirRelease.PV03.FB.AR_Output.AlarmActive;
	PT_Alarm.AirRelease.PG_PV04.Active := PGRad_AirRelease.PV04.FB.AR_Output.AlarmActive;

	PT_Alarm.Comm.BRB2.ResetAllowed := NOT PT_Alarm.Comm.BRB2.Active;
	PT_Alarm.Comm.IEBKB1.ResetAllowed := NOT PT_Alarm.Comm.IEBKB1.Active;
	PT_Alarm.Comm.BRB2RemoteFault.ResetAllowed := NOT PT_Alarm.Comm.BRB2RemoteFault.Active;
	PT_Alarm.Drive.PG_Pu01_VFD.ResetAllowed := NOT PT_Alarm.Drive.PG_Pu01_VFD.Active;
	PT_Alarm.Drive.PG_Pu01_CAN.ResetAllowed := NOT PT_Alarm.Drive.PG_Pu01_CAN.Active;
	PT_Alarm.Drive.PG_Pu02_VFD.ResetAllowed := NOT PT_Alarm.Drive.PG_Pu02_VFD.Active;
	PT_Alarm.Drive.PG_Pu02_CAN.ResetAllowed := NOT PT_Alarm.Drive.PG_Pu02_CAN.Active;
	PT_Alarm.AirRelease.PG_PV03.ResetAllowed := PGRad_AirRelease.PV03.FB.AR_Output.ResetAllowed;
	PT_Alarm.AirRelease.PG_PV04.ResetAllowed := PGRad_AirRelease.PV04.FB.AR_Output.ResetAllowed;
	PT_Alarm.AirRelease.PG_PV03.SourceCode := PGRad_AirRelease.PV03.FB.AR_Output.FaultCode;
	PT_Alarm.AirRelease.PG_PV04.SourceCode := PGRad_AirRelease.PV04.FB.AR_Output.FaultCode;

	(* ======================================================================== *)
	(* 2) IO_Modules: status, latch, potvrda i STOP svih fizickih modula       *)
	(* ======================================================================== *)
	PT_Alarm.IO.X20AI4622.Fault := NOT PT_Alarm.IO.X20AI4622.ModuleOk;
	PT_Alarm.IO.X20AI4622a.Fault := NOT PT_Alarm.IO.X20AI4622a.ModuleOk;
	PT_Alarm.IO.X20AI4622b.Fault := NOT PT_Alarm.IO.X20AI4622b.ModuleOk;
	PT_Alarm.IO.X20AI4622c.Fault := NOT PT_Alarm.IO.X20AI4622c.ModuleOk;
	PT_Alarm.IO.X20AI4622d.Fault := NOT PT_Alarm.IO.X20AI4622d.ModuleOk;
	PT_Alarm.IO.X20AO4622.Fault := NOT PT_Alarm.IO.X20AO4622.ModuleOk;
	PT_Alarm.IO.X20AO4622a.Fault := NOT PT_Alarm.IO.X20AO4622a.ModuleOk;
	PT_Alarm.IO.X20AO4622b.Fault := NOT PT_Alarm.IO.X20AO4622b.ModuleOk;
	PT_Alarm.IO.X20DI9371.Fault := NOT PT_Alarm.IO.X20DI9371.ModuleOk;
	PT_Alarm.IO.X20DI9371a.Fault := NOT PT_Alarm.IO.X20DI9371a.ModuleOk;
	PT_Alarm.IO.X20DI9371b.Fault := NOT PT_Alarm.IO.X20DI9371b.ModuleOk;
	PT_Alarm.IO.X20DO9322.Fault := NOT PT_Alarm.IO.X20DO9322.ModuleOk;
	PT_Alarm.IO.X20DO9322a.Fault := NOT PT_Alarm.IO.X20DO9322a.ModuleOk;
	PT_Alarm.IO.X20BC0083.Fault := NOT PT_Alarm.IO.X20BC0083.ModuleOk;
	PT_Alarm.IO.X20PS9400.Fault := NOT PT_Alarm.IO.X20PS9400.ModuleOk;
	PT_Alarm.IO.X20BT9100a.Fault := NOT PT_Alarm.IO.X20BT9100a.ModuleOk;
	PT_Alarm.IO.X67AI1323.Fault := NOT PT_Alarm.IO.X67AI1323.ModuleOk;
	PT_Alarm.IO.X67AI1333b.Fault := NOT PT_Alarm.IO.X67AI1333b.ModuleOk;
	PT_Alarm.IO.X67DI1371_L12.Fault := NOT PT_Alarm.IO.X67DI1371_L12.ModuleOk;
	PT_Alarm.IO.X67DM1321_L12.Fault := NOT PT_Alarm.IO.X67DM1321_L12.ModuleOk;
	PT_Alarm.IO.X20AI4622.Code := 41001; PT_Alarm.IO.X20AI4622.ResetAllowed := NOT PT_Alarm.IO.X20AI4622.Fault; PT_Alarm.IO.X20AI4622.Blocking := TRUE;
	PT_Alarm.IO.X20AI4622a.Code := 41002; PT_Alarm.IO.X20AI4622a.ResetAllowed := NOT PT_Alarm.IO.X20AI4622a.Fault; PT_Alarm.IO.X20AI4622a.Blocking := TRUE;
	PT_Alarm.IO.X20AI4622b.Code := 41003; PT_Alarm.IO.X20AI4622b.ResetAllowed := NOT PT_Alarm.IO.X20AI4622b.Fault; PT_Alarm.IO.X20AI4622b.Blocking := TRUE;
	PT_Alarm.IO.X20AI4622c.Code := 41004; PT_Alarm.IO.X20AI4622c.ResetAllowed := NOT PT_Alarm.IO.X20AI4622c.Fault; PT_Alarm.IO.X20AI4622c.Blocking := TRUE;
	PT_Alarm.IO.X20AI4622d.Code := 41005; PT_Alarm.IO.X20AI4622d.ResetAllowed := NOT PT_Alarm.IO.X20AI4622d.Fault; PT_Alarm.IO.X20AI4622d.Blocking := TRUE;
	PT_Alarm.IO.X20AO4622.Code := 41101; PT_Alarm.IO.X20AO4622.ResetAllowed := NOT PT_Alarm.IO.X20AO4622.Fault; PT_Alarm.IO.X20AO4622.Blocking := TRUE;
	PT_Alarm.IO.X20AO4622a.Code := 41102; PT_Alarm.IO.X20AO4622a.ResetAllowed := NOT PT_Alarm.IO.X20AO4622a.Fault; PT_Alarm.IO.X20AO4622a.Blocking := TRUE;
	PT_Alarm.IO.X20AO4622b.Code := 41103; PT_Alarm.IO.X20AO4622b.ResetAllowed := NOT PT_Alarm.IO.X20AO4622b.Fault; PT_Alarm.IO.X20AO4622b.Blocking := TRUE;
	PT_Alarm.IO.X20DI9371.Code := 41201; PT_Alarm.IO.X20DI9371.ResetAllowed := NOT PT_Alarm.IO.X20DI9371.Fault; PT_Alarm.IO.X20DI9371.Blocking := TRUE;
	PT_Alarm.IO.X20DI9371a.Code := 41202; PT_Alarm.IO.X20DI9371a.ResetAllowed := NOT PT_Alarm.IO.X20DI9371a.Fault; PT_Alarm.IO.X20DI9371a.Blocking := TRUE;
	PT_Alarm.IO.X20DI9371b.Code := 41203; PT_Alarm.IO.X20DI9371b.ResetAllowed := NOT PT_Alarm.IO.X20DI9371b.Fault; PT_Alarm.IO.X20DI9371b.Blocking := TRUE;
	PT_Alarm.IO.X20DO9322.Code := 41301; PT_Alarm.IO.X20DO9322.ResetAllowed := NOT PT_Alarm.IO.X20DO9322.Fault; PT_Alarm.IO.X20DO9322.Blocking := TRUE;
	PT_Alarm.IO.X20DO9322a.Code := 41302; PT_Alarm.IO.X20DO9322a.ResetAllowed := NOT PT_Alarm.IO.X20DO9322a.Fault; PT_Alarm.IO.X20DO9322a.Blocking := TRUE;
	PT_Alarm.IO.X20BC0083.Code := 41401; PT_Alarm.IO.X20BC0083.ResetAllowed := NOT PT_Alarm.IO.X20BC0083.Fault; PT_Alarm.IO.X20BC0083.Blocking := TRUE;
	PT_Alarm.IO.X20PS9400.Code := 41402; PT_Alarm.IO.X20PS9400.ResetAllowed := NOT PT_Alarm.IO.X20PS9400.Fault; PT_Alarm.IO.X20PS9400.Blocking := TRUE;
	PT_Alarm.IO.X20BT9100a.Code := 41403; PT_Alarm.IO.X20BT9100a.ResetAllowed := NOT PT_Alarm.IO.X20BT9100a.Fault; PT_Alarm.IO.X20BT9100a.Blocking := TRUE;
	PT_Alarm.IO.X67AI1323.Code := 41501; PT_Alarm.IO.X67AI1323.ResetAllowed := NOT PT_Alarm.IO.X67AI1323.Fault; PT_Alarm.IO.X67AI1323.Blocking := TRUE;
	PT_Alarm.IO.X67AI1333b.Code := 41502; PT_Alarm.IO.X67AI1333b.ResetAllowed := NOT PT_Alarm.IO.X67AI1333b.Fault; PT_Alarm.IO.X67AI1333b.Blocking := TRUE;
	PT_Alarm.IO.X67DI1371_L12.Code := 41601; PT_Alarm.IO.X67DI1371_L12.ResetAllowed := NOT PT_Alarm.IO.X67DI1371_L12.Fault; PT_Alarm.IO.X67DI1371_L12.Blocking := TRUE;
	PT_Alarm.IO.X67DM1321_L12.Code := 41701; PT_Alarm.IO.X67DM1321_L12.ResetAllowed := NOT PT_Alarm.IO.X67DM1321_L12.Fault; PT_Alarm.IO.X67DM1321_L12.Blocking := TRUE;
	IF PT_Alarm.IO.X20AI4622.Fault OR PT_Alarm.IO.X20AI4622a.Fault OR PT_Alarm.IO.X20AI4622b.Fault OR PT_Alarm.IO.X20AI4622c.Fault OR PT_Alarm.IO.X20AI4622d.Fault OR PT_Alarm.IO.X20AO4622.Fault OR PT_Alarm.IO.X20AO4622a.Fault OR PT_Alarm.IO.X20AO4622b.Fault OR PT_Alarm.IO.X20DI9371.Fault OR PT_Alarm.IO.X20DI9371a.Fault OR PT_Alarm.IO.X20DI9371b.Fault OR PT_Alarm.IO.X20DO9322.Fault OR PT_Alarm.IO.X20DO9322a.Fault OR PT_Alarm.IO.X20BC0083.Fault OR PT_Alarm.IO.X20PS9400.Fault OR PT_Alarm.IO.X20BT9100a.Fault OR PT_Alarm.IO.X67AI1323.Fault OR PT_Alarm.IO.X67AI1333b.Fault OR PT_Alarm.IO.X67DI1371_L12.Fault OR PT_Alarm.IO.X67DM1321_L12.Fault THEN
		PT_Alarm.IO.X20AI4622.Latched := PT_Alarm.IO.X20AI4622.Latched OR PT_Alarm.IO.X20AI4622.Fault;
		PT_Alarm.IO.X20AI4622a.Latched := PT_Alarm.IO.X20AI4622a.Latched OR PT_Alarm.IO.X20AI4622a.Fault;
		PT_Alarm.IO.X20AI4622b.Latched := PT_Alarm.IO.X20AI4622b.Latched OR PT_Alarm.IO.X20AI4622b.Fault;
		PT_Alarm.IO.X20AI4622c.Latched := PT_Alarm.IO.X20AI4622c.Latched OR PT_Alarm.IO.X20AI4622c.Fault;
		PT_Alarm.IO.X20AI4622d.Latched := PT_Alarm.IO.X20AI4622d.Latched OR PT_Alarm.IO.X20AI4622d.Fault;
		PT_Alarm.IO.X20AO4622.Latched := PT_Alarm.IO.X20AO4622.Latched OR PT_Alarm.IO.X20AO4622.Fault;
		PT_Alarm.IO.X20AO4622a.Latched := PT_Alarm.IO.X20AO4622a.Latched OR PT_Alarm.IO.X20AO4622a.Fault;
		PT_Alarm.IO.X20AO4622b.Latched := PT_Alarm.IO.X20AO4622b.Latched OR PT_Alarm.IO.X20AO4622b.Fault;
		PT_Alarm.IO.X20DI9371.Latched := PT_Alarm.IO.X20DI9371.Latched OR PT_Alarm.IO.X20DI9371.Fault;
		PT_Alarm.IO.X20DI9371a.Latched := PT_Alarm.IO.X20DI9371a.Latched OR PT_Alarm.IO.X20DI9371a.Fault;
		PT_Alarm.IO.X20DI9371b.Latched := PT_Alarm.IO.X20DI9371b.Latched OR PT_Alarm.IO.X20DI9371b.Fault;
		PT_Alarm.IO.X20DO9322.Latched := PT_Alarm.IO.X20DO9322.Latched OR PT_Alarm.IO.X20DO9322.Fault;
		PT_Alarm.IO.X20DO9322a.Latched := PT_Alarm.IO.X20DO9322a.Latched OR PT_Alarm.IO.X20DO9322a.Fault;
		PT_Alarm.IO.X20BC0083.Latched := PT_Alarm.IO.X20BC0083.Latched OR PT_Alarm.IO.X20BC0083.Fault;
		PT_Alarm.IO.X20PS9400.Latched := PT_Alarm.IO.X20PS9400.Latched OR PT_Alarm.IO.X20PS9400.Fault;
		PT_Alarm.IO.X20BT9100a.Latched := PT_Alarm.IO.X20BT9100a.Latched OR PT_Alarm.IO.X20BT9100a.Fault;
		PT_Alarm.IO.X67AI1323.Latched := PT_Alarm.IO.X67AI1323.Latched OR PT_Alarm.IO.X67AI1323.Fault;
		PT_Alarm.IO.X67AI1333b.Latched := PT_Alarm.IO.X67AI1333b.Latched OR PT_Alarm.IO.X67AI1333b.Fault;
		PT_Alarm.IO.X67DI1371_L12.Latched := PT_Alarm.IO.X67DI1371_L12.Latched OR PT_Alarm.IO.X67DI1371_L12.Fault;
		PT_Alarm.IO.X67DM1321_L12.Latched := PT_Alarm.IO.X67DM1321_L12.Latched OR PT_Alarm.IO.X67DM1321_L12.Fault;
	END_IF;
	IF PT_Alarm.Cmd.ResetAlarmRecords THEN
		IF PT_Alarm.IO.X20AI4622.ResetAllowed THEN PT_Alarm.IO.X20AI4622.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20AI4622a.ResetAllowed THEN PT_Alarm.IO.X20AI4622a.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20AI4622b.ResetAllowed THEN PT_Alarm.IO.X20AI4622b.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20AI4622c.ResetAllowed THEN PT_Alarm.IO.X20AI4622c.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20AI4622d.ResetAllowed THEN PT_Alarm.IO.X20AI4622d.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20AO4622.ResetAllowed THEN PT_Alarm.IO.X20AO4622.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20AO4622a.ResetAllowed THEN PT_Alarm.IO.X20AO4622a.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20AO4622b.ResetAllowed THEN PT_Alarm.IO.X20AO4622b.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20DI9371.ResetAllowed THEN PT_Alarm.IO.X20DI9371.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20DI9371a.ResetAllowed THEN PT_Alarm.IO.X20DI9371a.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20DI9371b.ResetAllowed THEN PT_Alarm.IO.X20DI9371b.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20DO9322.ResetAllowed THEN PT_Alarm.IO.X20DO9322.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20DO9322a.ResetAllowed THEN PT_Alarm.IO.X20DO9322a.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20BC0083.ResetAllowed THEN PT_Alarm.IO.X20BC0083.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20PS9400.ResetAllowed THEN PT_Alarm.IO.X20PS9400.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X20BT9100a.ResetAllowed THEN PT_Alarm.IO.X20BT9100a.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X67AI1323.ResetAllowed THEN PT_Alarm.IO.X67AI1323.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X67AI1333b.ResetAllowed THEN PT_Alarm.IO.X67AI1333b.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X67DI1371_L12.ResetAllowed THEN PT_Alarm.IO.X67DI1371_L12.Latched := FALSE; END_IF;
		IF PT_Alarm.IO.X67DM1321_L12.ResetAllowed THEN PT_Alarm.IO.X67DM1321_L12.Latched := FALSE; END_IF;
	END_IF;
	PT_Alarm.IO.AnyFault :=
		PT_Alarm.IO.X20AI4622.Fault OR PT_Alarm.IO.X20AI4622a.Fault OR PT_Alarm.IO.X20AI4622b.Fault OR
		PT_Alarm.IO.X20AI4622c.Fault OR PT_Alarm.IO.X20AI4622d.Fault OR PT_Alarm.IO.X20AO4622.Fault OR
		PT_Alarm.IO.X20AO4622a.Fault OR PT_Alarm.IO.X20AO4622b.Fault OR PT_Alarm.IO.X20DI9371.Fault OR
		PT_Alarm.IO.X20DI9371a.Fault OR PT_Alarm.IO.X20DI9371b.Fault OR PT_Alarm.IO.X20DO9322.Fault OR
		PT_Alarm.IO.X20DO9322a.Fault OR PT_Alarm.IO.X20BC0083.Fault OR PT_Alarm.IO.X20PS9400.Fault OR
		PT_Alarm.IO.X20BT9100a.Fault OR PT_Alarm.IO.X67AI1323.Fault OR PT_Alarm.IO.X67AI1333b.Fault OR
		PT_Alarm.IO.X67DI1371_L12.Fault OR PT_Alarm.IO.X67DM1321_L12.Fault;
	PT_Alarm.IO.AnyLatched :=
		PT_Alarm.IO.X20AI4622.Latched OR PT_Alarm.IO.X20AI4622a.Latched OR PT_Alarm.IO.X20AI4622b.Latched OR
		PT_Alarm.IO.X20AI4622c.Latched OR PT_Alarm.IO.X20AI4622d.Latched OR PT_Alarm.IO.X20AO4622.Latched OR
		PT_Alarm.IO.X20AO4622a.Latched OR PT_Alarm.IO.X20AO4622b.Latched OR PT_Alarm.IO.X20DI9371.Latched OR
		PT_Alarm.IO.X20DI9371a.Latched OR PT_Alarm.IO.X20DI9371b.Latched OR PT_Alarm.IO.X20DO9322.Latched OR
		PT_Alarm.IO.X20DO9322a.Latched OR PT_Alarm.IO.X20BC0083.Latched OR PT_Alarm.IO.X20PS9400.Latched OR
		PT_Alarm.IO.X20BT9100a.Latched OR PT_Alarm.IO.X67AI1323.Latched OR PT_Alarm.IO.X67AI1333b.Latched OR
		PT_Alarm.IO.X67DI1371_L12.Latched OR PT_Alarm.IO.X67DM1321_L12.Latched;
	PT_Alarm.IO.StopRequest := PT_Alarm.IO.AnyFault OR PT_Alarm.IO.AnyLatched;
	IF PT_Alarm.IO.FirstOutCode = 0 AND PT_Alarm.IO.AnyFault THEN
		IF PT_Alarm.IO.X20AI4622.Fault THEN PT_Alarm.IO.FirstOutCode := 41001;
		ELSIF PT_Alarm.IO.X20AI4622a.Fault THEN PT_Alarm.IO.FirstOutCode := 41002;
		ELSIF PT_Alarm.IO.X20AI4622b.Fault THEN PT_Alarm.IO.FirstOutCode := 41003;
		ELSIF PT_Alarm.IO.X20AI4622c.Fault THEN PT_Alarm.IO.FirstOutCode := 41004;
		ELSIF PT_Alarm.IO.X20AI4622d.Fault THEN PT_Alarm.IO.FirstOutCode := 41005;
		ELSIF PT_Alarm.IO.X20AO4622.Fault THEN PT_Alarm.IO.FirstOutCode := 41101;
		ELSIF PT_Alarm.IO.X20AO4622a.Fault THEN PT_Alarm.IO.FirstOutCode := 41102;
		ELSIF PT_Alarm.IO.X20AO4622b.Fault THEN PT_Alarm.IO.FirstOutCode := 41103;
		ELSIF PT_Alarm.IO.X20DI9371.Fault THEN PT_Alarm.IO.FirstOutCode := 41201;
		ELSIF PT_Alarm.IO.X20DI9371a.Fault THEN PT_Alarm.IO.FirstOutCode := 41202;
		ELSIF PT_Alarm.IO.X20DI9371b.Fault THEN PT_Alarm.IO.FirstOutCode := 41203;
		ELSIF PT_Alarm.IO.X20DO9322.Fault THEN PT_Alarm.IO.FirstOutCode := 41301;
		ELSIF PT_Alarm.IO.X20DO9322a.Fault THEN PT_Alarm.IO.FirstOutCode := 41302;
		ELSIF PT_Alarm.IO.X20BC0083.Fault THEN PT_Alarm.IO.FirstOutCode := 41401;
		ELSIF PT_Alarm.IO.X20PS9400.Fault THEN PT_Alarm.IO.FirstOutCode := 41402;
		ELSIF PT_Alarm.IO.X20BT9100a.Fault THEN PT_Alarm.IO.FirstOutCode := 41403;
		ELSIF PT_Alarm.IO.X67AI1323.Fault THEN PT_Alarm.IO.FirstOutCode := 41501;
		ELSIF PT_Alarm.IO.X67AI1333b.Fault THEN PT_Alarm.IO.FirstOutCode := 41502;
		ELSIF PT_Alarm.IO.X67DI1371_L12.Fault THEN PT_Alarm.IO.FirstOutCode := 41601;
		ELSIF PT_Alarm.IO.X67DM1321_L12.Fault THEN PT_Alarm.IO.FirstOutCode := 41701;
		END_IF;
	END_IF;

	(* ======================================================================== *)
	(* 3) Postojeci procesni FaultCode u imenovane alarmne zapise               *)
	(* ======================================================================== *)
	PT_Alarm.Process.ValveRequestConflict.Active := FALSE;
	PT_Alarm.Process.V01CloseTimeout.Active := FALSE;
	PT_Alarm.Process.V02OpenTimeout.Active := FALSE;
	PT_Alarm.Process.V02CloseTimeout.Active := FALSE;
	PT_Alarm.Process.V01OpenTimeout.Active := FALSE;
	PT_Alarm.Process.V01CloseIEBStopTimeout.Active := FALSE;
	PT_Alarm.Process.IEBFlowStopTimeout.Active := FALSE;
	PT_Alarm.Process.V05CloseTimeout.Active := FALSE;
	PT_Alarm.Process.IEBFlowStartTimeout.Active := FALSE;
	PT_Alarm.Process.BRB2FlowNotConfirmed.Active := FALSE;
	PT_Alarm.Process.BRB2TemperatureNotReached.Active := FALSE;
	PT_Alarm.Process.PT06HighPressure.Active := FALSE;
	PT_Alarm.Process.TransferIEBFlowNotZero.Active := FALSE;
	PT_Alarm.Process.TransferV05CloseTimeout.Active := FALSE;
	PT_Alarm.Process.TransferV01CloseTimeout.Active := FALSE;
	PT_Alarm.Process.TransferV02OpenTimeout.Active := FALSE;
	PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Active := FALSE;

	IF PGRad_Status.Fault THEN
		CASE PGRad_Status.FaultCode OF
			10: PT_Alarm.Process.ValveRequestConflict.Active := TRUE;
			11: PT_Alarm.Process.V01CloseTimeout.Active := TRUE;
			12: PT_Alarm.Process.V02OpenTimeout.Active := TRUE;
			13: PT_Alarm.Process.V02CloseTimeout.Active := TRUE;
			14: PT_Alarm.Process.V01OpenTimeout.Active := TRUE;
			15: PT_Alarm.Process.V01CloseIEBStopTimeout.Active := TRUE;
			16: PT_Alarm.Process.IEBFlowStopTimeout.Active := TRUE;
			17: PT_Alarm.Process.V05CloseTimeout.Active := TRUE;
			18: PT_Alarm.Process.IEBFlowStartTimeout.Active := TRUE;
			21: PT_Alarm.Process.BRB2FlowNotConfirmed.Active := TRUE;
			22: PT_Alarm.Process.BRB2TemperatureNotReached.Active := TRUE;
			23: PT_Alarm.Process.PT06HighPressure.Active := TRUE;
			31: PT_Alarm.Process.TransferIEBFlowNotZero.Active := TRUE;
			32: PT_Alarm.Process.TransferV05CloseTimeout.Active := TRUE;
			33: PT_Alarm.Process.TransferV01CloseTimeout.Active := TRUE;
			34: PT_Alarm.Process.TransferV02OpenTimeout.Active := TRUE;
			35: PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Active := TRUE;
		END_CASE;
	END_IF;

	PT_Alarm.Process.ValveRequestConflict.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.V01CloseTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.V02OpenTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.V02CloseTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.V01OpenTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.V01CloseIEBStopTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.IEBFlowStopTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.V05CloseTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.IEBFlowStartTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.BRB2FlowNotConfirmed.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.BRB2TemperatureNotReached.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.PT06HighPressure.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.TransferIEBFlowNotZero.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.TransferV05CloseTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.TransferV01CloseTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.TransferV02OpenTimeout.ResetAllowed := NOT PGRad_Status.Fault;
	PT_Alarm.Process.TransferBRB2FlowNotConfirmed.ResetAllowed := NOT PGRad_Status.Fault;

	(* ======================================================================== *)
	(* 3) Latch i first-out memorija                                            *)
	(* ======================================================================== *)
	IF PT_Alarm.Comm.BRB2.Active THEN
		PT_Alarm.Comm.BRB2.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Comm.IEBKB1.Active THEN
		PT_Alarm.Comm.IEBKB1.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Comm.BRB2RemoteFault.Active THEN
		PT_Alarm.Comm.BRB2RemoteFault.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu01_VFD.Active THEN
		PT_Alarm.Drive.PG_Pu01_VFD.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu01_CAN.Active THEN
		PT_Alarm.Drive.PG_Pu01_CAN.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu02_VFD.Active THEN
		PT_Alarm.Drive.PG_Pu02_VFD.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu02_CAN.Active THEN
		PT_Alarm.Drive.PG_Pu02_CAN.Latched := TRUE;
	END_IF;
	IF PGRad_AirRelease.PV03.FB.AR_Output.AlarmLatched THEN
		PT_Alarm.AirRelease.PG_PV03.Latched := TRUE;
	END_IF;
	IF PGRad_AirRelease.PV04.FB.AR_Output.AlarmLatched THEN
		PT_Alarm.AirRelease.PG_PV04.Latched := TRUE;
	END_IF;

	IF PT_Alarm.Process.ValveRequestConflict.Active THEN
		PT_Alarm.Process.ValveRequestConflict.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.V01CloseTimeout.Active THEN
		PT_Alarm.Process.V01CloseTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.V02OpenTimeout.Active THEN
		PT_Alarm.Process.V02OpenTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.V02CloseTimeout.Active THEN
		PT_Alarm.Process.V02CloseTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.V01OpenTimeout.Active THEN
		PT_Alarm.Process.V01OpenTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.V01CloseIEBStopTimeout.Active THEN
		PT_Alarm.Process.V01CloseIEBStopTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.IEBFlowStopTimeout.Active THEN
		PT_Alarm.Process.IEBFlowStopTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.V05CloseTimeout.Active THEN
		PT_Alarm.Process.V05CloseTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.IEBFlowStartTimeout.Active THEN
		PT_Alarm.Process.IEBFlowStartTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.BRB2FlowNotConfirmed.Active THEN
		PT_Alarm.Process.BRB2FlowNotConfirmed.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.BRB2TemperatureNotReached.Active THEN
		PT_Alarm.Process.BRB2TemperatureNotReached.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.PT06HighPressure.Active THEN
		PT_Alarm.Process.PT06HighPressure.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.TransferIEBFlowNotZero.Active THEN
		PT_Alarm.Process.TransferIEBFlowNotZero.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.TransferV05CloseTimeout.Active THEN
		PT_Alarm.Process.TransferV05CloseTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.TransferV01CloseTimeout.Active THEN
		PT_Alarm.Process.TransferV01CloseTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.TransferV02OpenTimeout.Active THEN
		PT_Alarm.Process.TransferV02OpenTimeout.Latched := TRUE;
	END_IF;
	IF PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Active THEN
		PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Latched := TRUE;
	END_IF;

	IF PT_Alarm.Summary.FirstOutCode = 0 THEN
		IF PT_Alarm.Comm.BRB2.Active THEN
			PT_Alarm.Summary.FirstOutCode := PT_Alarm.Comm.BRB2.Code;
		ELSIF PT_Alarm.Comm.IEBKB1.Active THEN
			PT_Alarm.Summary.FirstOutCode := PT_Alarm.Comm.IEBKB1.Code;
		ELSIF PT_Alarm.Comm.BRB2RemoteFault.Active THEN
			PT_Alarm.Summary.FirstOutCode := PT_Alarm.Comm.BRB2RemoteFault.Code;
		ELSIF PT_Alarm.Drive.PG_Pu01_VFD.Active THEN
			PT_Alarm.Summary.FirstOutCode := PT_Alarm.Drive.PG_Pu01_VFD.Code;
		ELSIF PT_Alarm.Drive.PG_Pu01_CAN.Active THEN
			PT_Alarm.Summary.FirstOutCode := PT_Alarm.Drive.PG_Pu01_CAN.Code;
		ELSIF PT_Alarm.Drive.PG_Pu02_VFD.Active THEN
			PT_Alarm.Summary.FirstOutCode := PT_Alarm.Drive.PG_Pu02_VFD.Code;
		ELSIF PT_Alarm.Drive.PG_Pu02_CAN.Active THEN
			PT_Alarm.Summary.FirstOutCode := PT_Alarm.Drive.PG_Pu02_CAN.Code;
		ELSIF PGRad_Status.Fault THEN
			PT_Alarm.Summary.FirstOutCode := 25000 + USINT_TO_UINT(PGRad_Status.FaultCode);
		ELSIF PGRad_AirRelease.PV03.FB.AR_Output.AlarmLatched THEN
			PT_Alarm.Summary.FirstOutCode := PT_Alarm.AirRelease.PG_PV03.Code;
		ELSIF PGRad_AirRelease.PV04.FB.AR_Output.AlarmLatched THEN
			PT_Alarm.Summary.FirstOutCode := PT_Alarm.AirRelease.PG_PV04.Code;
		END_IF;
	END_IF;

	(* ======================================================================== *)
	(* 4) Operatorska potvrda i reset alarmnog zapisa                           *)
	(* ======================================================================== *)
	IF PT_Alarm.Cmd.AcknowledgeAll THEN
		PT_Alarm.Comm.BRB2.Acknowledged := PT_Alarm.Comm.BRB2.Latched;
		PT_Alarm.Comm.IEBKB1.Acknowledged := PT_Alarm.Comm.IEBKB1.Latched;
		PT_Alarm.Comm.BRB2RemoteFault.Acknowledged := PT_Alarm.Comm.BRB2RemoteFault.Latched;
		PT_Alarm.Drive.PG_Pu01_VFD.Acknowledged := PT_Alarm.Drive.PG_Pu01_VFD.Latched;
		PT_Alarm.Drive.PG_Pu01_CAN.Acknowledged := PT_Alarm.Drive.PG_Pu01_CAN.Latched;
		PT_Alarm.Drive.PG_Pu02_VFD.Acknowledged := PT_Alarm.Drive.PG_Pu02_VFD.Latched;
		PT_Alarm.Drive.PG_Pu02_CAN.Acknowledged := PT_Alarm.Drive.PG_Pu02_CAN.Latched;
		PT_Alarm.Process.ValveRequestConflict.Acknowledged := PT_Alarm.Process.ValveRequestConflict.Latched;
		PT_Alarm.Process.V01CloseTimeout.Acknowledged := PT_Alarm.Process.V01CloseTimeout.Latched;
		PT_Alarm.Process.V02OpenTimeout.Acknowledged := PT_Alarm.Process.V02OpenTimeout.Latched;
		PT_Alarm.Process.V02CloseTimeout.Acknowledged := PT_Alarm.Process.V02CloseTimeout.Latched;
		PT_Alarm.Process.V01OpenTimeout.Acknowledged := PT_Alarm.Process.V01OpenTimeout.Latched;
		PT_Alarm.Process.V01CloseIEBStopTimeout.Acknowledged := PT_Alarm.Process.V01CloseIEBStopTimeout.Latched;
		PT_Alarm.Process.IEBFlowStopTimeout.Acknowledged := PT_Alarm.Process.IEBFlowStopTimeout.Latched;
		PT_Alarm.Process.V05CloseTimeout.Acknowledged := PT_Alarm.Process.V05CloseTimeout.Latched;
		PT_Alarm.Process.IEBFlowStartTimeout.Acknowledged := PT_Alarm.Process.IEBFlowStartTimeout.Latched;
		PT_Alarm.Process.BRB2FlowNotConfirmed.Acknowledged := PT_Alarm.Process.BRB2FlowNotConfirmed.Latched;
		PT_Alarm.Process.BRB2TemperatureNotReached.Acknowledged := PT_Alarm.Process.BRB2TemperatureNotReached.Latched;
		PT_Alarm.Process.PT06HighPressure.Acknowledged := PT_Alarm.Process.PT06HighPressure.Latched;
		PT_Alarm.Process.TransferIEBFlowNotZero.Acknowledged := PT_Alarm.Process.TransferIEBFlowNotZero.Latched;
		PT_Alarm.Process.TransferV05CloseTimeout.Acknowledged := PT_Alarm.Process.TransferV05CloseTimeout.Latched;
		PT_Alarm.Process.TransferV01CloseTimeout.Acknowledged := PT_Alarm.Process.TransferV01CloseTimeout.Latched;
		PT_Alarm.Process.TransferV02OpenTimeout.Acknowledged := PT_Alarm.Process.TransferV02OpenTimeout.Latched;
		PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Acknowledged := PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Latched;
		PT_Alarm.AirRelease.PG_PV03.Acknowledged := PT_Alarm.AirRelease.PG_PV03.Latched;
		PT_Alarm.AirRelease.PG_PV04.Acknowledged := PT_Alarm.AirRelease.PG_PV04.Latched;
	END_IF;

	IF PT_Alarm.Cmd.ResetAlarmRecords THEN
		IF PT_Alarm.Comm.BRB2.ResetAllowed THEN
			PT_Alarm.Comm.BRB2.Latched := FALSE;
			PT_Alarm.Comm.BRB2.Acknowledged := FALSE;
		END_IF;
		IF PT_Alarm.Comm.IEBKB1.ResetAllowed THEN
			PT_Alarm.Comm.IEBKB1.Latched := FALSE;
			PT_Alarm.Comm.IEBKB1.Acknowledged := FALSE;
		END_IF;
		IF PT_Alarm.Comm.BRB2RemoteFault.ResetAllowed THEN
			PT_Alarm.Comm.BRB2RemoteFault.Latched := FALSE;
			PT_Alarm.Comm.BRB2RemoteFault.Acknowledged := FALSE;
		END_IF;
		IF PT_Alarm.Drive.PG_Pu01_VFD.ResetAllowed THEN
			PT_Alarm.Drive.PG_Pu01_VFD.Latched := FALSE;
			PT_Alarm.Drive.PG_Pu01_VFD.Acknowledged := FALSE;
		END_IF;
		IF PT_Alarm.Drive.PG_Pu01_CAN.ResetAllowed THEN
			PT_Alarm.Drive.PG_Pu01_CAN.Latched := FALSE;
			PT_Alarm.Drive.PG_Pu01_CAN.Acknowledged := FALSE;
		END_IF;
		IF PT_Alarm.Drive.PG_Pu02_VFD.ResetAllowed THEN
			PT_Alarm.Drive.PG_Pu02_VFD.Latched := FALSE;
			PT_Alarm.Drive.PG_Pu02_VFD.Acknowledged := FALSE;
		END_IF;
		IF PT_Alarm.Drive.PG_Pu02_CAN.ResetAllowed THEN
			PT_Alarm.Drive.PG_Pu02_CAN.Latched := FALSE;
			PT_Alarm.Drive.PG_Pu02_CAN.Acknowledged := FALSE;
		END_IF;
		IF NOT PGRad_Status.Fault THEN
			PT_Alarm.Process.ValveRequestConflict.Latched := FALSE;
			PT_Alarm.Process.ValveRequestConflict.Acknowledged := FALSE;
			PT_Alarm.Process.V01CloseTimeout.Latched := FALSE;
			PT_Alarm.Process.V01CloseTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.V02OpenTimeout.Latched := FALSE;
			PT_Alarm.Process.V02OpenTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.V02CloseTimeout.Latched := FALSE;
			PT_Alarm.Process.V02CloseTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.V01OpenTimeout.Latched := FALSE;
			PT_Alarm.Process.V01OpenTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.V01CloseIEBStopTimeout.Latched := FALSE;
			PT_Alarm.Process.V01CloseIEBStopTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.IEBFlowStopTimeout.Latched := FALSE;
			PT_Alarm.Process.IEBFlowStopTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.V05CloseTimeout.Latched := FALSE;
			PT_Alarm.Process.V05CloseTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.IEBFlowStartTimeout.Latched := FALSE;
			PT_Alarm.Process.IEBFlowStartTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.BRB2FlowNotConfirmed.Latched := FALSE;
			PT_Alarm.Process.BRB2FlowNotConfirmed.Acknowledged := FALSE;
			PT_Alarm.Process.BRB2TemperatureNotReached.Latched := FALSE;
			PT_Alarm.Process.BRB2TemperatureNotReached.Acknowledged := FALSE;
			PT_Alarm.Process.PT06HighPressure.Latched := FALSE;
			PT_Alarm.Process.PT06HighPressure.Acknowledged := FALSE;
			PT_Alarm.Process.TransferIEBFlowNotZero.Latched := FALSE;
			PT_Alarm.Process.TransferIEBFlowNotZero.Acknowledged := FALSE;
			PT_Alarm.Process.TransferV05CloseTimeout.Latched := FALSE;
			PT_Alarm.Process.TransferV05CloseTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.TransferV01CloseTimeout.Latched := FALSE;
			PT_Alarm.Process.TransferV01CloseTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.TransferV02OpenTimeout.Latched := FALSE;
			PT_Alarm.Process.TransferV02OpenTimeout.Acknowledged := FALSE;
			PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Latched := FALSE;
			PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Acknowledged := FALSE;
		END_IF;
		IF PT_Alarm.AirRelease.PG_PV03.ResetAllowed THEN
			PT_Alarm.AirRelease.PG_PV03.Latched := FALSE;
			PT_Alarm.AirRelease.PG_PV03.Acknowledged := FALSE;
		END_IF;
		IF PT_Alarm.AirRelease.PG_PV04.ResetAllowed THEN
			PT_Alarm.AirRelease.PG_PV04.Latched := FALSE;
			PT_Alarm.AirRelease.PG_PV04.Acknowledged := FALSE;
		END_IF;
	END_IF;

	(* ======================================================================== *)
	(* 5) Zbirni status                                                         *)
	(* ======================================================================== *)
	ProcessAnyLatched := PT_Alarm.Process.ValveRequestConflict.Latched
		OR PT_Alarm.Process.V01CloseTimeout.Latched
		OR PT_Alarm.Process.V02OpenTimeout.Latched
		OR PT_Alarm.Process.V02CloseTimeout.Latched
		OR PT_Alarm.Process.V01OpenTimeout.Latched
		OR PT_Alarm.Process.V01CloseIEBStopTimeout.Latched
		OR PT_Alarm.Process.IEBFlowStopTimeout.Latched
		OR PT_Alarm.Process.V05CloseTimeout.Latched
		OR PT_Alarm.Process.IEBFlowStartTimeout.Latched
		OR PT_Alarm.Process.BRB2FlowNotConfirmed.Latched
		OR PT_Alarm.Process.BRB2TemperatureNotReached.Latched
		OR PT_Alarm.Process.PT06HighPressure.Latched
		OR PT_Alarm.Process.TransferIEBFlowNotZero.Latched
		OR PT_Alarm.Process.TransferV05CloseTimeout.Latched
		OR PT_Alarm.Process.TransferV01CloseTimeout.Latched
		OR PT_Alarm.Process.TransferV02OpenTimeout.Latched
		OR PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Latched;
	ProcessAnyUnacknowledged :=
		(PT_Alarm.Process.ValveRequestConflict.Latched AND NOT PT_Alarm.Process.ValveRequestConflict.Acknowledged)
		OR (PT_Alarm.Process.V01CloseTimeout.Latched AND NOT PT_Alarm.Process.V01CloseTimeout.Acknowledged)
		OR (PT_Alarm.Process.V02OpenTimeout.Latched AND NOT PT_Alarm.Process.V02OpenTimeout.Acknowledged)
		OR (PT_Alarm.Process.V02CloseTimeout.Latched AND NOT PT_Alarm.Process.V02CloseTimeout.Acknowledged)
		OR (PT_Alarm.Process.V01OpenTimeout.Latched AND NOT PT_Alarm.Process.V01OpenTimeout.Acknowledged)
		OR (PT_Alarm.Process.V01CloseIEBStopTimeout.Latched AND NOT PT_Alarm.Process.V01CloseIEBStopTimeout.Acknowledged)
		OR (PT_Alarm.Process.IEBFlowStopTimeout.Latched AND NOT PT_Alarm.Process.IEBFlowStopTimeout.Acknowledged)
		OR (PT_Alarm.Process.V05CloseTimeout.Latched AND NOT PT_Alarm.Process.V05CloseTimeout.Acknowledged)
		OR (PT_Alarm.Process.IEBFlowStartTimeout.Latched AND NOT PT_Alarm.Process.IEBFlowStartTimeout.Acknowledged)
		OR (PT_Alarm.Process.BRB2FlowNotConfirmed.Latched AND NOT PT_Alarm.Process.BRB2FlowNotConfirmed.Acknowledged)
		OR (PT_Alarm.Process.BRB2TemperatureNotReached.Latched AND NOT PT_Alarm.Process.BRB2TemperatureNotReached.Acknowledged)
		OR (PT_Alarm.Process.PT06HighPressure.Latched AND NOT PT_Alarm.Process.PT06HighPressure.Acknowledged)
		OR (PT_Alarm.Process.TransferIEBFlowNotZero.Latched AND NOT PT_Alarm.Process.TransferIEBFlowNotZero.Acknowledged)
		OR (PT_Alarm.Process.TransferV05CloseTimeout.Latched AND NOT PT_Alarm.Process.TransferV05CloseTimeout.Acknowledged)
		OR (PT_Alarm.Process.TransferV01CloseTimeout.Latched AND NOT PT_Alarm.Process.TransferV01CloseTimeout.Acknowledged)
		OR (PT_Alarm.Process.TransferV02OpenTimeout.Latched AND NOT PT_Alarm.Process.TransferV02OpenTimeout.Acknowledged)
		OR (PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Latched AND NOT PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Acknowledged);

	PT_Alarm.Summary.ActiveCount := 0;
	PT_Alarm.Summary.LatchedCount := 0;
	IF PT_Alarm.Comm.BRB2.Active THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;
	IF PT_Alarm.Comm.IEBKB1.Active THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;
	IF PT_Alarm.Comm.BRB2RemoteFault.Active THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu01_VFD.Active THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu01_CAN.Active THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu02_VFD.Active THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu02_CAN.Active THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;
	IF PGRad_Status.Fault THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;
	IF PT_Alarm.AirRelease.PG_PV03.Active THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;
	IF PT_Alarm.AirRelease.PG_PV04.Active THEN
		PT_Alarm.Summary.ActiveCount := PT_Alarm.Summary.ActiveCount + 1;
	END_IF;

	IF PT_Alarm.Comm.BRB2.Latched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;
	IF PT_Alarm.Comm.IEBKB1.Latched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;
	IF PT_Alarm.Comm.BRB2RemoteFault.Latched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu01_VFD.Latched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu01_CAN.Latched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu02_VFD.Latched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;
	IF PT_Alarm.Drive.PG_Pu02_CAN.Latched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;
	IF ProcessAnyLatched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;
	IF PT_Alarm.AirRelease.PG_PV03.Latched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;
	IF PT_Alarm.AirRelease.PG_PV04.Latched THEN
		PT_Alarm.Summary.LatchedCount := PT_Alarm.Summary.LatchedCount + 1;
	END_IF;

	PT_Alarm.Summary.AnyActive := (PT_Alarm.Summary.ActiveCount > 0) OR PT_Alarm.IO.AnyFault;
	PT_Alarm.Summary.AnyLatched := (PT_Alarm.Summary.LatchedCount > 0) OR PT_Alarm.IO.AnyLatched;
	PT_Alarm.Summary.AnyUnacknowledged :=
		(PT_Alarm.Comm.BRB2.Latched AND NOT PT_Alarm.Comm.BRB2.Acknowledged)
		OR (PT_Alarm.Comm.IEBKB1.Latched AND NOT PT_Alarm.Comm.IEBKB1.Acknowledged)
		OR (PT_Alarm.Comm.BRB2RemoteFault.Latched AND NOT PT_Alarm.Comm.BRB2RemoteFault.Acknowledged)
		OR (PT_Alarm.Drive.PG_Pu01_VFD.Latched AND NOT PT_Alarm.Drive.PG_Pu01_VFD.Acknowledged)
		OR (PT_Alarm.Drive.PG_Pu01_CAN.Latched AND NOT PT_Alarm.Drive.PG_Pu01_CAN.Acknowledged)
		OR (PT_Alarm.Drive.PG_Pu02_VFD.Latched AND NOT PT_Alarm.Drive.PG_Pu02_VFD.Acknowledged)
		OR (PT_Alarm.Drive.PG_Pu02_CAN.Latched AND NOT PT_Alarm.Drive.PG_Pu02_CAN.Acknowledged)
		OR ProcessAnyUnacknowledged
		OR (PT_Alarm.AirRelease.PG_PV03.Latched AND NOT PT_Alarm.AirRelease.PG_PV03.Acknowledged)
		OR (PT_Alarm.AirRelease.PG_PV04.Latched AND NOT PT_Alarm.AirRelease.PG_PV04.Acknowledged)
		OR PT_Alarm.IO.AnyLatched;
	PT_Alarm.Summary.AnyTrip := PT_Alarm.Comm.BRB2.Latched
		OR PT_Alarm.Comm.IEBKB1.Latched
		OR PT_Alarm.Comm.BRB2RemoteFault.Latched
		OR PT_Alarm.Drive.PG_Pu01_VFD.Latched
		OR PT_Alarm.Drive.PG_Pu01_CAN.Latched
		OR PT_Alarm.Drive.PG_Pu02_VFD.Latched
		OR PT_Alarm.Drive.PG_Pu02_CAN.Latched
		OR ProcessAnyLatched
		OR PT_Alarm.IO.StopRequest;
	PT_Alarm.Summary.RestartBlocked := PT_Alarm.Summary.AnyTrip OR PT_Alarm.IO.StopRequest;
	IF PT_Alarm.Summary.AnyTrip THEN
		PT_Alarm.Summary.HighestSeverity := 4;
	ELSIF PT_Alarm.Summary.AnyLatched THEN
		PT_Alarm.Summary.HighestSeverity := 3;
	ELSE
		PT_Alarm.Summary.HighestSeverity := 0;
	END_IF;
	IF NOT PT_Alarm.Summary.AnyLatched THEN
		PT_Alarm.Summary.FirstOutCode := 0;
	END_IF;
	IF NOT PT_Alarm.IO.AnyLatched THEN
		PT_Alarm.IO.FirstOutCode := 0;
	END_IF;
	IF PT_Alarm.Summary.FirstOutCode = 0 THEN
		PT_Alarm.Summary.FirstOutCode := PT_Alarm.IO.FirstOutCode;
	END_IF;

	(* ======================================================================== *)
	(* 7) Jednociklusne komande                                                  *)
	(* ======================================================================== *)
	PT_Alarm.ResetPulse.Devices := PT_Alarm.Cmd.ResetDevices;
	PT_Alarm.ResetPulse.Process := PT_Alarm.Cmd.ResetProcess;
	PT_Alarm.Cmd.AcknowledgeAll := FALSE;
	PT_Alarm.Cmd.ResetAlarmRecords := FALSE;
	PT_Alarm.Cmd.ResetDevices := FALSE;
	PT_Alarm.Cmd.ResetProcess := FALSE;
END_PROGRAM