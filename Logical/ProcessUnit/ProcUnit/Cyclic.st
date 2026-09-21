PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* 1) Izbor parametara odzracivanja prema aktivnom izvoru                   *)
	(* ======================================================================== *)
	IF PGRad_Cmd.AirRelease.UseIEBKB1Parameters THEN
		PGRad_AirRelease.PV03.FB.AR_Param := PGRad.Par.AirRelease.IEBKB1.PV03;
		PGRad_AirRelease.PV04.FB.AR_Param := PGRad.Par.AirRelease.IEBKB1.PV04;
	ELSE
		PGRad_AirRelease.PV03.FB.AR_Param := PGRad.Par.AirRelease.BRB2.PV03;
		PGRad_AirRelease.PV04.FB.AR_Param := PGRad.Par.AirRelease.BRB2.PV04;
	END_IF;

	(* ======================================================================== *)
	(* 2) PV03 odzracivanje ulaza u podstanicu                                  *)
	(* ======================================================================== *)
	PGRad_AirRelease.PV03.FB.AR_Input.Enable := PGRad_Cmd.AirRelease.PV03.Enable;
	PGRad_AirRelease.PV03.FB.AR_Input.EnableManual := PGRad_AirRelease.PV03.Ctrl.EnableManual;
	PGRad_AirRelease.PV03.FB.AR_Input.ManualSP_Percent := PGRad_AirRelease.PV03.Ctrl.ManualSP_Percent;
	PGRad_AirRelease.PV03.FB.AR_Input.Pressure_bar := PG.Sens.Pt._1.AI_Output.ScaledValue;
	PGRad_AirRelease.PV03.FB.AR_Input.LS1_Upper := PG.Sens.LS._3.DI_Output.Value;
	PGRad_AirRelease.PV03.FB.AR_Input.LS2_Middle := PG.Sens.LS._2.DI_Output.Value;
	PGRad_AirRelease.PV03.FB.AR_Input.LS3_Lower := FALSE;
	PGRad_AirRelease.PV03.FB.AR_Input.ResetAlarm :=
		PGRad_Cmd.AirRelease.ResetAll
		OR PGRad_AirRelease.PV03.Ctrl.ResetAlarm
		OR (PT_Alarm.ResetPulse.Devices AND PGRad_AirRelease.PV03.FB.AR_Output.ResetAllowed);
	PGRad_AirRelease.PV03.FB();
	PGRad_AirRelease.PV03.Ctrl.ResetAlarm := FALSE;

	(* ======================================================================== *)
	(* 3) PV04 odzracivanje ulaza u prihvatni tank                              *)
	(* ======================================================================== *)
	PGRad_AirRelease.PV04.FB.AR_Input.Enable := PGRad_Cmd.AirRelease.PV04.Enable;
	PGRad_AirRelease.PV04.FB.AR_Input.EnableManual := PGRad_AirRelease.PV04.Ctrl.EnableManual;
	PGRad_AirRelease.PV04.FB.AR_Input.ManualSP_Percent := PGRad_AirRelease.PV04.Ctrl.ManualSP_Percent;
	PGRad_AirRelease.PV04.FB.AR_Input.Pressure_bar := PG.Sens.Pt._4.AI_Output.ScaledValue;
	PGRad_AirRelease.PV04.FB.AR_Input.LS1_Upper := PG.Sens.LS._5.DI_Output.Value;
	PGRad_AirRelease.PV04.FB.AR_Input.LS2_Middle := PG.Sens.LS._4.DI_Output.Value;
	PGRad_AirRelease.PV04.FB.AR_Input.LS3_Lower := FALSE;
	PGRad_AirRelease.PV04.FB.AR_Input.ResetAlarm :=
		PGRad_Cmd.AirRelease.ResetAll
		OR PGRad_AirRelease.PV04.Ctrl.ResetAlarm
		OR (PT_Alarm.ResetPulse.Devices AND PGRad_AirRelease.PV04.FB.AR_Output.ResetAllowed);
	PGRad_AirRelease.PV04.FB();
	PGRad_AirRelease.PV04.Ctrl.ResetAlarm := FALSE;
END_PROGRAM
