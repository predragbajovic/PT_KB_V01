PROGRAM _INIT
	(* ======================================================================== *)
	(* 1) Inicijalizacija Podstanica trend prikaza                              *)
	(* ======================================================================== *)
	PGRad_TrendCursor.Position := 0.5;
	PGRad_TrendCursor.ViewSpan := 14400;
	PGRad_TrendCursor.PreviousViewSpan := 14400;
	PGRad_TrendCursor.FollowNow := TRUE;
	PGRad_TrendCursor.CmdBack := FALSE;
	PGRad_TrendCursor.CmdForward := FALSE;
	PGRad_TrendCursor.CmdNow := FALSE;
	AlarmCmdAcknowledge := FALSE;
	AlarmCmdResetRecords := FALSE;
	AlarmCmdResetDevices := FALSE;
	AlarmCmdResetProcess := FALSE;
END_PROGRAM