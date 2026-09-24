PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* 1) Rezim i raspolozivi vremenski opseg Podstanica trenda                 *)
	(* ======================================================================== *)
	(* VC pri otvaranju continuous trenda postavlja mod 1; mod 0 drzi zadati prozor. *)
	PGRad_TrendCursor.AxisMode := 0;

	TrendClock.enable := TRUE;
	TrendClock();
	TrendNow_s := DT_TO_UDINT(TrendClock.DT1);
	IF TrendNow_s > 864000 THEN
		TrendEarliest_s := TrendNow_s - 864000;
	ELSE
		TrendEarliest_s := 0;
	END_IF;
	IF (DT_TO_UDINT(PGRad_TrendCursor.RecordingStart) > TrendEarliest_s)
		AND (DT_TO_UDINT(PGRad_TrendCursor.RecordingStart) <= TrendNow_s) THEN
		TrendEarliest_s := DT_TO_UDINT(PGRad_TrendCursor.RecordingStart);
	END_IF;

	(* ======================================================================== *)
	(* 2) Zoom i navigacija vremenskog prozora                                  *)
	(* ======================================================================== *)
	IF PGRad_TrendCursor.ViewSpan < 3600 THEN
		PGRad_TrendCursor.ViewSpan := 3600;
	ELSIF PGRad_TrendCursor.ViewSpan > 172800 THEN
		PGRad_TrendCursor.ViewSpan := 172800;
	END_IF;

	IF (DT_TO_UDINT(PGRad_TrendCursor.ViewStart) = 0)
		AND (TrendNow_s >= DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan)) THEN
		PGRad_TrendCursor.ViewStart := UDINT_TO_DT(
			TrendNow_s - DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan));
		PGRad_TrendCursor.FollowNow := FALSE;
	END_IF;

	IF PGRad_TrendCursor.ViewSpan <> PGRad_TrendCursor.PreviousViewSpan THEN
		IF PGRad_TrendCursor.FollowNow THEN
			PGRad_TrendCursor.ViewStart := UDINT_TO_DT(
				TrendNow_s - DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan));
		ELSE
			PGRad_TrendCursor.ViewStart := UDINT_TO_DT(
				DT_TO_UDINT(PGRad_TrendCursor.ViewStart)
				+ DINT_TO_UDINT(PGRad_TrendCursor.PreviousViewSpan)
				- DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan));
		END_IF;
		PGRad_TrendCursor.PreviousViewSpan := PGRad_TrendCursor.ViewSpan;
		PGRad_TrendCursor.FollowNow := FALSE;
	END_IF;

	IF PGRad_TrendCursor.CmdNow THEN
		IF TrendNow_s >= DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan) THEN
			PGRad_TrendCursor.ViewStart := UDINT_TO_DT(
				TrendNow_s - DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan));
		END_IF;
		PGRad_TrendCursor.FollowNow := FALSE;
	END_IF;

	IF PGRad_TrendCursor.CmdBack THEN
		PGRad_TrendCursor.FollowNow := FALSE;
		IF DT_TO_UDINT(PGRad_TrendCursor.ViewStart) > (TrendEarliest_s + DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan)) THEN
			PGRad_TrendCursor.ViewStart := UDINT_TO_DT(
				DT_TO_UDINT(PGRad_TrendCursor.ViewStart) - DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan));
		ELSE
			PGRad_TrendCursor.ViewStart := UDINT_TO_DT(TrendEarliest_s);
		END_IF;
	END_IF;

	IF PGRad_TrendCursor.CmdForward THEN
		IF (DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + (2 * DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan))) >= TrendNow_s THEN
			PGRad_TrendCursor.ViewStart := UDINT_TO_DT(
				TrendNow_s - DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan));
			PGRad_TrendCursor.FollowNow := FALSE;
		ELSE
			PGRad_TrendCursor.ViewStart := UDINT_TO_DT(
				DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan));
		END_IF;
	END_IF;

	(* ======================================================================== *)
	(* 3) Oznake vremenske ose i apsolutno vreme kursora                        *)
	(* ======================================================================== *)
	PGRad_TrendCursor.AxisTime0 := PGRad_TrendCursor.ViewStart;
	PGRad_TrendCursor.AxisTime1 := UDINT_TO_DT(
		DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + (DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan) / 8));
	PGRad_TrendCursor.AxisTime2 := UDINT_TO_DT(
		DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + ((2 * DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan)) / 8));
	PGRad_TrendCursor.AxisTime3 := UDINT_TO_DT(
		DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + ((3 * DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan)) / 8));
	PGRad_TrendCursor.AxisTime4 := UDINT_TO_DT(
		DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + ((4 * DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan)) / 8));
	PGRad_TrendCursor.AxisTime5 := UDINT_TO_DT(
		DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + ((5 * DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan)) / 8));
	PGRad_TrendCursor.AxisTime6 := UDINT_TO_DT(
		DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + ((6 * DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan)) / 8));
	PGRad_TrendCursor.AxisTime7 := UDINT_TO_DT(
		DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + ((7 * DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan)) / 8));
	PGRad_TrendCursor.AxisTime8 := UDINT_TO_DT(
		DT_TO_UDINT(PGRad_TrendCursor.ViewStart) + DINT_TO_UDINT(PGRad_TrendCursor.ViewSpan));

	(* VC vraca vreme kursora u ms od pocetka referentnog trend zapisa. *)
	PGRad_TrendCursor.DateTime := UDINT_TO_DT(
		DT_TO_UDINT(PGRad_TrendCursor.RecordingStart)
		+ (PGRad_TrendCursor.Time / 1000));

	PGRad_TrendCursor.CmdBack := FALSE;
	PGRad_TrendCursor.CmdForward := FALSE;
	PGRad_TrendCursor.CmdNow := FALSE;

	(* ======================================================================== *)
	(* 4) Alarmne komande i status za VC                                        *)
	(* ======================================================================== *)
	IF AlarmCmdAcknowledge THEN
		PT_Alarm.Cmd.AcknowledgeAll := TRUE;
		AlarmCmdAcknowledge := FALSE;
	END_IF;
	IF AlarmCmdResetRecords THEN
		PT_Alarm.Cmd.ResetAlarmRecords := TRUE;
		AlarmCmdResetRecords := FALSE;
	END_IF;
	IF AlarmCmdResetDevices THEN
		PT_Alarm.Cmd.ResetDevices := TRUE;
		AlarmCmdResetDevices := FALSE;
	END_IF;
	IF AlarmCmdResetProcess THEN
		PT_Alarm.Cmd.ResetProcess := TRUE;
		AlarmCmdResetProcess := FALSE;
	END_IF;

	AlarmAnyActive := PT_Alarm.Summary.AnyActive;
	AlarmAnyLatched := PT_Alarm.Summary.AnyLatched;
	AlarmAnyUnacknowledged := PT_Alarm.Summary.AnyUnacknowledged;
	AlarmAnyTrip := PT_Alarm.Summary.AnyTrip;
	AlarmRestartBlocked := PT_Alarm.Summary.RestartBlocked;
	AlarmHighestSeverity := PT_Alarm.Summary.HighestSeverity;
	AlarmFirstOutCode := PT_Alarm.Summary.FirstOutCode;
	AlarmActiveCount := PT_Alarm.Summary.ActiveCount;
	AlarmLatchedCount := PT_Alarm.Summary.LatchedCount;
	Alarm_21001 := PT_Alarm.Comm.BRB2.Latched;
	Alarm_21002 := PT_Alarm.Comm.IEBKB1.Latched;
	Alarm_21003 := PT_Alarm.Comm.BRB2RemoteFault.Latched;
	Alarm_22001 := PT_Alarm.Drive.PG_Pu01_VFD.Latched;
	Alarm_22002 := PT_Alarm.Drive.PG_Pu01_CAN.Latched;
	Alarm_22003 := PT_Alarm.Drive.PG_Pu02_VFD.Latched;
	Alarm_22004 := PT_Alarm.Drive.PG_Pu02_CAN.Latched;
	Alarm_25010 := PT_Alarm.Process.ValveRequestConflict.Latched;
	Alarm_25011 := PT_Alarm.Process.V01CloseTimeout.Latched;
	Alarm_25012 := PT_Alarm.Process.V02OpenTimeout.Latched;
	Alarm_25013 := PT_Alarm.Process.V02CloseTimeout.Latched;
	Alarm_25014 := PT_Alarm.Process.V01OpenTimeout.Latched;
	Alarm_25015 := PT_Alarm.Process.V01CloseIEBStopTimeout.Latched;
	Alarm_25016 := PT_Alarm.Process.IEBFlowStopTimeout.Latched;
	Alarm_25017 := PT_Alarm.Process.V05CloseTimeout.Latched;
	Alarm_25018 := PT_Alarm.Process.IEBFlowStartTimeout.Latched;
	Alarm_25021 := PT_Alarm.Process.BRB2FlowNotConfirmed.Latched;
	Alarm_25022 := PT_Alarm.Process.BRB2TemperatureNotReached.Latched;
	Alarm_25023 := PT_Alarm.Process.PT06HighPressure.Latched;
	Alarm_25031 := PT_Alarm.Process.TransferIEBFlowNotZero.Latched;
	Alarm_25032 := PT_Alarm.Process.TransferV05CloseTimeout.Latched;
	Alarm_25033 := PT_Alarm.Process.TransferV01CloseTimeout.Latched;
	Alarm_25034 := PT_Alarm.Process.TransferV02OpenTimeout.Latched;
	Alarm_25035 := PT_Alarm.Process.TransferBRB2FlowNotConfirmed.Latched;
	Alarm_26001 := PT_Alarm.AirRelease.PG_PV03.Latched;
	Alarm_26002 := PT_Alarm.AirRelease.PG_PV04.Latched;
	Alarm_41001 := PT_Alarm.IO.X20AI4622.Latched;
	Alarm_41002 := PT_Alarm.IO.X20AI4622a.Latched;
	Alarm_41003 := PT_Alarm.IO.X20AI4622b.Latched;
	Alarm_41004 := PT_Alarm.IO.X20AI4622c.Latched;
	Alarm_41005 := PT_Alarm.IO.X20AI4622d.Latched;
	Alarm_41101 := PT_Alarm.IO.X20AO4622.Latched;
	Alarm_41102 := PT_Alarm.IO.X20AO4622a.Latched;
	Alarm_41103 := PT_Alarm.IO.X20AO4622b.Latched;
	Alarm_41201 := PT_Alarm.IO.X20DI9371.Latched;
	Alarm_41202 := PT_Alarm.IO.X20DI9371a.Latched;
	Alarm_41203 := PT_Alarm.IO.X20DI9371b.Latched;
	Alarm_41301 := PT_Alarm.IO.X20DO9322.Latched;
	Alarm_41302 := PT_Alarm.IO.X20DO9322a.Latched;
	Alarm_41401 := PT_Alarm.IO.X20BC0083.Latched;
	Alarm_41402 := PT_Alarm.IO.X20PS9400.Latched;
	Alarm_41403 := PT_Alarm.IO.X20BT9100a.Latched;
	Alarm_41501 := PT_Alarm.IO.X67AI1323.Latched;
	Alarm_41502 := PT_Alarm.IO.X67AI1333b.Latched;
	Alarm_41601 := PT_Alarm.IO.X67DI1371_L12.Latched;
	Alarm_41701 := PT_Alarm.IO.X67DM1321_L12.Latched;
END_PROGRAM