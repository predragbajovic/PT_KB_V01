PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* VALVE RESET SERVICE - RESET POJEDINACNIH I SVIH VENTILA                 *)
	(* ResetAlarm je impuls; posle validnog reseta Enable se obara jedan scan  *)
	(* i zatim ponovo podize, kako zahtevaju FB_V_EMV i FB_V_ON_OFF_FB.        *)
	(* ======================================================================== *)
	ResetPulse_01 := FALSE;
	ResetPulse_02 := FALSE;
	ResetPulse_03 := FALSE;
	ResetPulse_04 := FALSE;
	ResetPulse_05 := FALSE;
	ResetPulse_06 := FALSE;
	ResetPulse_07 := FALSE;

	ResetAllInProgress := ResetInProgress_01 OR ResetInProgress_02 OR ResetInProgress_03
		OR ResetInProgress_04 OR ResetInProgress_05 OR ResetInProgress_06 OR ResetInProgress_07;
	ResetAllDone := ResetDone_01 AND ResetDone_02 AND ResetDone_03 AND ResetDone_04
		AND ResetDone_05 AND ResetDone_06 AND ResetDone_07;
	ResetAllFault := ResetFault_01 OR ResetFault_02 OR ResetFault_03 OR ResetFault_04
		OR ResetFault_05 OR ResetFault_06 OR ResetFault_07;
	StateComment_01 := PG.Act.AV._1.V_Output.State_comment;
	FaultText_01 := PG.Act.AV._1.V_Output.FaultText;
	Diag_01 := PG.Act.AV._1.V_Output.Diag;
	StateComment_02 := PG.Act.AV._2.V_Output.State_comment;
	FaultText_02 := PG.Act.AV._2.V_Output.FaultText;
	Diag_02 := PG.Act.AV._2.V_Output.Diag;
	StateComment_03 := PG.Act.AV._3.V_Output.State_comment;
	FaultText_03 := PG.Act.AV._3.V_Output.FaultText;
	Diag_03 := PG.Act.AV._3.V_Output.Diag;
	StateComment_04 := PG.Act.AV._4.V_Output.State_comment;
	FaultText_04 := PG.Act.AV._4.V_Output.FaultText;
	Diag_04 := PG.Act.AV._4.V_Output.Diag;
	StateComment_05 := PG.Act.AV._5.V_Output.State_comment;
	FaultText_05 := PG.Act.AV._5.V_Output.FaultText;
	Diag_05 := PG.Act.AV._5.V_Output.Diag;
	StateComment_06 := PG.Act.AV._6.V_Output.State_comment;
	FaultText_06 := PG.Act.AV._6.V_Output.FaultText;
	Diag_06 := PG.Act.AV._6.V_Output.Diag;
	StateComment_07 := PG.Act.AV._7.V_Output.State_comment;
	FaultText_07 := PG.Act.AV._7.V_Output.FaultText;
	Diag_07 := PG.Act.AV._7.V_Output.Diag;
	ValveAlarmActive := PG.Act.AV._1.V_Output.FaultLatched
		OR PG.Act.AV._2.V_Output.FaultLatched
		OR PG.Act.AV._3.V_Output.FaultLatched
		OR PG.Act.AV._4.V_Output.FaultLatched
		OR PG.Act.AV._5.V_Output.FaultLatched
		OR PG.Act.AV._6.V_Output.FaultLatched
		OR PG.Act.AV._7.V_Output.FaultLatched;

//	PG.Act.AV._1.V_Input.Enable := NOT Disable_01;
	PG.Act.AV._1.V_Input.ResetAlarm := ResetPulse_01;
	IF (Reset_01 OR ResetAll) AND NOT PrevReset_01 AND NOT ResetInProgress_01 THEN
		ResetDone_01 := FALSE;
		ResetFault_01 := NOT PG.Act.AV._1.V_Output.ResetAllowed;
		IF PG.Act.AV._1.V_Output.ResetAllowed THEN ResetPulse_01 := TRUE; ResetInProgress_01 := TRUE; END_IF;
	END_IF;
	IF ResetInProgress_01 THEN
		IF ResetPulse_01 THEN ResetPulse_01 := FALSE; Disable_01 := TRUE;
		ELSIF Disable_01 THEN Disable_01 := FALSE; ResetInProgress_01 := FALSE; ResetDone_01 := TRUE; END_IF;
	END_IF;
	IF PG.Act.AV._1.V_Output.FaultLatched THEN ResetDone_01 := FALSE; END_IF;

	PG.Act.AV._2.V_Input.Enable := NOT Disable_02;
	PG.Act.AV._2.V_Input.ResetAlarm := ResetPulse_02;
	IF (Reset_02 OR ResetAll) AND NOT PrevReset_02 AND NOT ResetInProgress_02 THEN
		ResetDone_02 := FALSE;
		ResetFault_02 := NOT PG.Act.AV._2.V_Output.ResetAllowed;
		IF PG.Act.AV._2.V_Output.ResetAllowed THEN ResetPulse_02 := TRUE; ResetInProgress_02 := TRUE; END_IF;
	END_IF;
	IF ResetInProgress_02 THEN
		IF ResetPulse_02 THEN ResetPulse_02 := FALSE; Disable_02 := TRUE;
		ELSIF Disable_02 THEN Disable_02 := FALSE; ResetInProgress_02 := FALSE; ResetDone_02 := TRUE; END_IF;
	END_IF;
	IF PG.Act.AV._2.V_Output.FaultLatched THEN ResetDone_02 := FALSE; END_IF;

	PG.Act.AV._3.V_Input.Enable := NOT Disable_03;
	PG.Act.AV._3.V_Input.ResetAlarm := ResetPulse_03;
	IF (Reset_03 OR ResetAll) AND NOT PrevReset_03 AND NOT ResetInProgress_03 THEN
		ResetDone_03 := FALSE;
		ResetFault_03 := NOT PG.Act.AV._3.V_Output.ResetAllowed;
		IF PG.Act.AV._3.V_Output.ResetAllowed THEN ResetPulse_03 := TRUE; ResetInProgress_03 := TRUE; END_IF;
	END_IF;
	IF ResetInProgress_03 THEN
		IF ResetPulse_03 THEN ResetPulse_03 := FALSE; Disable_03 := TRUE;
		ELSIF Disable_03 THEN Disable_03 := FALSE; ResetInProgress_03 := FALSE; ResetDone_03 := TRUE; END_IF;
	END_IF;
	IF PG.Act.AV._3.V_Output.FaultLatched THEN ResetDone_03 := FALSE; END_IF;

	PG.Act.AV._4.V_Input.Enable := NOT Disable_04;
	PG.Act.AV._4.V_Input.ResetAlarm := ResetPulse_04;
	IF (Reset_04 OR ResetAll) AND NOT PrevReset_04 AND NOT ResetInProgress_04 THEN
		ResetDone_04 := FALSE;
		ResetFault_04 := NOT PG.Act.AV._4.V_Output.ResetAllowed;
		IF PG.Act.AV._4.V_Output.ResetAllowed THEN ResetPulse_04 := TRUE; ResetInProgress_04 := TRUE; END_IF;
	END_IF;
	IF ResetInProgress_04 THEN
		IF ResetPulse_04 THEN ResetPulse_04 := FALSE; Disable_04 := TRUE;
		ELSIF Disable_04 THEN Disable_04 := FALSE; ResetInProgress_04 := FALSE; ResetDone_04 := TRUE; END_IF;
	END_IF;
	IF PG.Act.AV._4.V_Output.FaultLatched THEN ResetDone_04 := FALSE; END_IF;

	PG.Act.AV._5.V_Input.Enable := NOT Disable_05;
	PG.Act.AV._5.V_Input.ResetAlarm := ResetPulse_05;
	IF (Reset_05 OR ResetAll) AND NOT PrevReset_05 AND NOT ResetInProgress_05 THEN
		ResetDone_05 := FALSE;
		ResetFault_05 := NOT PG.Act.AV._5.V_Output.ResetAllowed;
		IF PG.Act.AV._5.V_Output.ResetAllowed THEN ResetPulse_05 := TRUE; ResetInProgress_05 := TRUE; END_IF;
	END_IF;
	IF ResetInProgress_05 THEN
		IF ResetPulse_05 THEN ResetPulse_05 := FALSE; Disable_05 := TRUE;
		ELSIF Disable_05 THEN Disable_05 := FALSE; ResetInProgress_05 := FALSE; ResetDone_05 := TRUE; END_IF;
	END_IF;
	IF PG.Act.AV._5.V_Output.FaultLatched THEN ResetDone_05 := FALSE; END_IF;

	PG.Act.AV._6.V_Input.Enable := NOT Disable_06;
	PG.Act.AV._6.V_Input.ResetAlarm := ResetPulse_06;
	IF (Reset_06 OR ResetAll) AND NOT PrevReset_06 AND NOT ResetInProgress_06 THEN
		ResetDone_06 := FALSE;
		ResetFault_06 := NOT PG.Act.AV._6.V_Output.ResetAllowed;
		IF PG.Act.AV._6.V_Output.ResetAllowed THEN ResetPulse_06 := TRUE; ResetInProgress_06 := TRUE; END_IF;
	END_IF;
	IF ResetInProgress_06 THEN
		IF ResetPulse_06 THEN ResetPulse_06 := FALSE; Disable_06 := TRUE;
		ELSIF Disable_06 THEN Disable_06 := FALSE; ResetInProgress_06 := FALSE; ResetDone_06 := TRUE; END_IF;
	END_IF;
	IF PG.Act.AV._6.V_Output.FaultLatched THEN ResetDone_06 := FALSE; END_IF;

	PG.Act.AV._7.V_Input.Enable := NOT Disable_07;
	PG.Act.AV._7.V_Input.ResetAlarm := ResetPulse_07;
	IF (Reset_07 OR ResetAll) AND NOT PrevReset_07 AND NOT ResetInProgress_07 THEN
		ResetDone_07 := FALSE;
		ResetFault_07 := NOT PG.Act.AV._7.V_Output.ResetAllowed;
		IF PG.Act.AV._7.V_Output.ResetAllowed THEN ResetPulse_07 := TRUE; ResetInProgress_07 := TRUE; END_IF;
	END_IF;
	IF ResetInProgress_07 THEN
		IF ResetPulse_07 THEN ResetPulse_07 := FALSE; Disable_07 := TRUE;
		ELSIF Disable_07 THEN Disable_07 := FALSE; ResetInProgress_07 := FALSE; ResetDone_07 := TRUE; END_IF;
	END_IF;
	IF PG.Act.AV._7.V_Output.FaultLatched THEN ResetDone_07 := FALSE; END_IF;

	PrevResetAll := ResetAll;
	PrevReset_01 := Reset_01;
	PrevReset_02 := Reset_02;
	PrevReset_03 := Reset_03;
	PrevReset_04 := Reset_04;
	PrevReset_05 := Reset_05;
	PrevReset_06 := Reset_06;
	PrevReset_07 := Reset_07;
END_PROGRAM
