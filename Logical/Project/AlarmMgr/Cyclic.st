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
	(* 2) Postojeci procesni FaultCode u imenovane alarmne zapise               *)
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

	PT_Alarm.Summary.AnyActive := PT_Alarm.Summary.ActiveCount > 0;
	PT_Alarm.Summary.AnyLatched := PT_Alarm.Summary.LatchedCount > 0;
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
		OR (PT_Alarm.AirRelease.PG_PV04.Latched AND NOT PT_Alarm.AirRelease.PG_PV04.Acknowledged);
	PT_Alarm.Summary.AnyTrip := PT_Alarm.Comm.BRB2.Latched
		OR PT_Alarm.Comm.IEBKB1.Latched
		OR PT_Alarm.Comm.BRB2RemoteFault.Latched
		OR PT_Alarm.Drive.PG_Pu01_VFD.Latched
		OR PT_Alarm.Drive.PG_Pu01_CAN.Latched
		OR PT_Alarm.Drive.PG_Pu02_VFD.Latched
		OR PT_Alarm.Drive.PG_Pu02_CAN.Latched
		OR ProcessAnyLatched;
	PT_Alarm.Summary.RestartBlocked := PT_Alarm.Summary.AnyTrip;
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

	(* ======================================================================== *)
	(* 6) Jednociklusne komande                                                  *)
	(* ======================================================================== *)
	PT_Alarm.ResetPulse.Devices := PT_Alarm.Cmd.ResetDevices;
	PT_Alarm.ResetPulse.Process := PT_Alarm.Cmd.ResetProcess;
	PT_Alarm.Cmd.AcknowledgeAll := FALSE;
	PT_Alarm.Cmd.ResetAlarmRecords := FALSE;
	PT_Alarm.Cmd.ResetDevices := FALSE;
	PT_Alarm.Cmd.ResetProcess := FALSE;
END_PROGRAM