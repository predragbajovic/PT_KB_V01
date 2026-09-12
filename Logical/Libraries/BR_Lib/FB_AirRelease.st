FUNCTION_BLOCK FB_AirRelease (* Automatsko odzracivanje cevovoda sa 1 do 3 LS senzora. *)

(* -------------------------------------------------------------------------- *)
(* 1) Runtime vreme task ciklusa                                               *)
(* -------------------------------------------------------------------------- *)
AR_Internal.RtInfo(enable := TRUE);
AR_Internal.RuntimeTimeValid :=
	(AR_Internal.RtInfo.status = 0)
	AND (AR_Internal.RtInfo.cycle_time > 0)
	AND (AR_Internal.RtInfo.cycle_time <= 1000000);

IF AR_Internal.RuntimeTimeValid THEN
	AR_Output.CycleTime_s := UDINT_TO_REAL(AR_Internal.RtInfo.cycle_time) / 1000000.0;
ELSE
	AR_Output.CycleTime_s := 0.0;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 2) Validacija parametara                                                    *)
(* -------------------------------------------------------------------------- *)
AR_Internal.ConfigValid := TRUE;
AR_Internal.ConfigFaultText := 'CONFIG_OK';

IF (AR_Param.NumberOfLS < 1) OR (AR_Param.NumberOfLS > 3) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'NumberOfLS mora biti u opsegu 1..3';
ELSIF AR_Param.PressureSP_bar < 0.0 THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'PressureSP_bar ne sme biti negativan';
ELSIF (AR_Param.PressureHysteresis_bar < 0.0)
	OR (AR_Param.PressureHysteresis_bar > AR_Param.PressureSP_bar) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'PressureHysteresis_bar mora biti 0..PressureSP';
ELSIF (AR_Param.LS1.SP_Percent < AR_Constant.PCT_MIN)
	OR (AR_Param.LS1.SP_Percent > AR_Constant.PCT_MAX) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS1 SP mora biti u opsegu 0..100%';
ELSIF AR_Param.LS1.Ramp_PercentPerSecond < AR_Constant.RAMP_MIN THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS1 rampa mora biti veca od 0%/s';
ELSIF (AR_Param.LS1.ConfirmTime_s < 0.0)
	OR (AR_Param.LS1.ConfirmTime_s > AR_Constant.CONFIRM_TIME_MAX_S) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS1 ConfirmTime_s mora biti 0..3600 s';
ELSIF (AR_Param.NumberOfLS >= 2)
	AND ((AR_Param.LS2.SP_Percent < AR_Constant.PCT_MIN)
		OR (AR_Param.LS2.SP_Percent > AR_Constant.PCT_MAX)) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS2 SP mora biti u opsegu 0..100%';
ELSIF (AR_Param.NumberOfLS >= 2)
	AND (AR_Param.LS2.Ramp_PercentPerSecond < AR_Constant.RAMP_MIN) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS2 rampa mora biti veca od 0%/s';
ELSIF (AR_Param.NumberOfLS >= 2)
	AND ((AR_Param.LS2.ConfirmTime_s < 0.0)
		OR (AR_Param.LS2.ConfirmTime_s > AR_Constant.CONFIRM_TIME_MAX_S)) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS2 ConfirmTime_s mora biti 0..3600 s';
ELSIF (AR_Param.NumberOfLS >= 2)
	AND (AR_Param.LS2.SP_Percent < AR_Param.LS1.SP_Percent) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS2 SP mora biti veci ili jednak LS1 SP';
ELSIF (AR_Param.NumberOfLS = 3)
	AND ((AR_Param.LS3.SP_Percent < AR_Constant.PCT_MIN)
		OR (AR_Param.LS3.SP_Percent > AR_Constant.PCT_MAX)) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS3 SP mora biti u opsegu 0..100%';
ELSIF (AR_Param.NumberOfLS = 3)
	AND (AR_Param.LS3.Ramp_PercentPerSecond < AR_Constant.RAMP_MIN) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS3 rampa mora biti veca od 0%/s';
ELSIF (AR_Param.NumberOfLS = 3)
	AND ((AR_Param.LS3.ConfirmTime_s < 0.0)
		OR (AR_Param.LS3.ConfirmTime_s > AR_Constant.CONFIRM_TIME_MAX_S)) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS3 ConfirmTime_s mora biti 0..3600 s';
ELSIF (AR_Param.NumberOfLS = 3)
	AND (AR_Param.LS3.SP_Percent < AR_Param.LS2.SP_Percent) THEN
	AR_Internal.ConfigValid := FALSE;
	AR_Internal.ConfigFaultText := 'LS3 SP mora biti veci ili jednak LS2 SP';
END_IF;

IF AR_Internal.ConfigValid THEN
	AR_Internal.LS1ConfirmTime := REAL_TO_TIME(AR_Param.LS1.ConfirmTime_s * 1000.0);
	AR_Internal.LS2ConfirmTime := REAL_TO_TIME(AR_Param.LS2.ConfirmTime_s * 1000.0);
	AR_Internal.LS3ConfirmTime := REAL_TO_TIME(AR_Param.LS3.ConfirmTime_s * 1000.0);
ELSE
	AR_Internal.LS1ConfirmTime := T#1s;
	AR_Internal.LS2ConfirmTime := T#1s;
	AR_Internal.LS3ConfirmTime := T#1s;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 3) Dvosmerna vremenska potvrda LS signala                                  *)
(* -------------------------------------------------------------------------- *)
AR_Internal.TonLS1Change.IN :=
	AR_Internal.ConfigValid
	AND (AR_Input.LS1_Upper <> AR_Internal.LS1Confirmed);
AR_Internal.TonLS1Change.PT := AR_Internal.LS1ConfirmTime;
AR_Internal.TonLS1Change();

IF AR_Internal.TonLS1Change.Q THEN
	AR_Internal.LS1Confirmed := AR_Input.LS1_Upper;
END_IF;

IF AR_Param.NumberOfLS >= 2 THEN
	AR_Internal.TonLS2Change.IN :=
		AR_Internal.ConfigValid
		AND (AR_Input.LS2_Middle <> AR_Internal.LS2Confirmed);
	AR_Internal.TonLS2Change.PT := AR_Internal.LS2ConfirmTime;
	AR_Internal.TonLS2Change();

	IF AR_Internal.TonLS2Change.Q THEN
		AR_Internal.LS2Confirmed := AR_Input.LS2_Middle;
	END_IF;
ELSE
	AR_Internal.TonLS2Change(IN := FALSE, PT := T#0ms);
	AR_Internal.LS2Confirmed := FALSE;
END_IF;

IF AR_Param.NumberOfLS = 3 THEN
	AR_Internal.TonLS3Change.IN :=
		AR_Internal.ConfigValid
		AND (AR_Input.LS3_Lower <> AR_Internal.LS3Confirmed);
	AR_Internal.TonLS3Change.PT := AR_Internal.LS3ConfirmTime;
	AR_Internal.TonLS3Change();

	IF AR_Internal.TonLS3Change.Q THEN
		AR_Internal.LS3Confirmed := AR_Input.LS3_Lower;
	END_IF;
ELSE
	AR_Internal.TonLS3Change(IN := FALSE, PT := T#0ms);
	AR_Internal.LS3Confirmed := FALSE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 4) Monitoring aktivnog pritiska sa histerezom                              *)
(* -------------------------------------------------------------------------- *)
IF NOT AR_Input.Enable OR NOT AR_Internal.ConfigValid THEN
	AR_Internal.PressureActive := FALSE;
ELSIF NOT AR_Internal.PressureActive THEN
	IF AR_Input.Pressure_bar > AR_Param.PressureSP_bar THEN
		AR_Internal.PressureActive := TRUE;
	END_IF;
ELSIF AR_Input.Pressure_bar <
	(AR_Param.PressureSP_bar - AR_Param.PressureHysteresis_bar) THEN
	AR_Internal.PressureActive := FALSE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 5) Validacija fizickog redosleda potvrdenih LS signala                     *)
(* -------------------------------------------------------------------------- *)
AR_Internal.LSSequenceInvalid := FALSE;

IF AR_Internal.ConfigValid THEN
	CASE AR_Param.NumberOfLS OF
		2:
			AR_Internal.LSSequenceInvalid :=
				AR_Internal.LS1Confirmed
				AND NOT AR_Internal.LS2Confirmed;
		3:
			AR_Internal.LSSequenceInvalid :=
				(AR_Internal.LS1Confirmed AND NOT AR_Internal.LS2Confirmed)
				OR (AR_Internal.LS2Confirmed AND NOT AR_Internal.LS3Confirmed);
	END_CASE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 6) Aktivni alarmni uslov, latch i kontrolisani reset                       *)
(* -------------------------------------------------------------------------- *)
AR_Internal.ActiveConditionCode := AR_Constant.ACT_NONE;

IF NOT AR_Internal.ConfigValid THEN
	AR_Internal.ActiveConditionCode := AR_Constant.ACT_CONFIG_INVALID;
ELSIF NOT AR_Internal.RuntimeTimeValid THEN
	AR_Internal.ActiveConditionCode := AR_Constant.ACT_RUNTIME_TIME_INVALID;
ELSIF AR_Internal.LSSequenceInvalid THEN
	AR_Internal.ActiveConditionCode := AR_Constant.ACT_LS_SEQUENCE_INVALID;
END_IF;

AR_Internal.FaultCondition :=
	AR_Internal.ActiveConditionCode <> AR_Constant.ACT_NONE;

IF AR_Internal.FaultCondition THEN
	IF NOT AR_Internal.FaultLatched THEN
		CASE AR_Internal.ActiveConditionCode OF
			1: AR_Internal.FaultCode := AR_Constant.FLT_CONFIG_INVALID;
			2: AR_Internal.FaultCode := AR_Constant.FLT_LS_SEQUENCE_INVALID;
			3: AR_Internal.FaultCode := AR_Constant.FLT_RUNTIME_TIME_INVALID;
		ELSE
			AR_Internal.FaultCode := AR_Constant.FLT_NONE;
		END_CASE;
	END_IF;
	AR_Internal.FaultLatched := TRUE;
END_IF;

AR_Internal.ResetAllowed :=
	AR_Internal.FaultLatched
	AND NOT AR_Internal.FaultCondition
	AND AR_Internal.ConfigValid
	AND AR_Internal.RuntimeTimeValid;

IF AR_Input.ResetAlarm AND AR_Internal.ResetAllowed THEN
	AR_Internal.FaultLatched := FALSE;
	AR_Internal.FaultCode := AR_Constant.FLT_NONE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 7) Izbor manual komande ili automatskog LS stepena                         *)
(* -------------------------------------------------------------------------- *)
IF NOT AR_Input.Enable
	OR (NOT AR_Internal.PressureActive AND NOT AR_Input.EnableManual)
	OR AR_Internal.FaultCondition
	OR AR_Internal.FaultLatched THEN
	(* Bez dozvole, pritiska ili pri alarmu: isto kao potvrden gornji LS1. *)
	AR_Internal.OpeningMode := FALSE;
	AR_Internal.ActiveStage := 1;
	IF AR_Internal.ConfigValid THEN
		IF AR_Internal.ValveCmd > AR_Param.LS1.SP_Percent THEN
			AR_Internal.ValveCmd := AR_Param.LS1.SP_Percent;
		END_IF;
	ELSIF AR_Internal.ValveCmd > AR_Constant.SAFE_CLOSE_SP THEN
		AR_Internal.ValveCmd := AR_Constant.SAFE_CLOSE_SP;
	END_IF;
ELSIF AR_Input.EnableManual THEN
	(* Manual ima prioritet nad pressure/LS automatikom, ali ne nad Enable/fault. *)
	AR_Internal.ActiveStage := 0;
	AR_Internal.OpeningMode := FALSE;
	IF AR_Input.ManualSP_Percent < AR_Constant.PCT_MIN THEN
		AR_Internal.ValveCmd := AR_Constant.PCT_MIN;
	ELSIF AR_Input.ManualSP_Percent > AR_Constant.PCT_MAX THEN
		AR_Internal.ValveCmd := AR_Constant.PCT_MAX;
	ELSE
		AR_Internal.ValveCmd := AR_Input.ManualSP_Percent;
	END_IF;
ELSIF NOT AR_Internal.ControlActivePrev THEN
	(* Prvi aktivni scan bira stanje prema najvisem potvrdenom LS-u. *)
	IF AR_Internal.LS1Confirmed THEN
		AR_Internal.OpeningMode := FALSE;
		AR_Internal.ActiveStage := 1;
		IF AR_Internal.ValveCmd > AR_Param.LS1.SP_Percent THEN
			AR_Internal.ValveCmd := AR_Param.LS1.SP_Percent;
		END_IF;
	ELSIF (AR_Param.NumberOfLS >= 2) AND AR_Internal.LS2Confirmed THEN
		AR_Internal.OpeningMode := FALSE;
		AR_Internal.ActiveStage := 1;
		IF AR_Internal.ValveCmd > AR_Param.LS1.SP_Percent THEN
			AR_Internal.ValveCmd := AR_Param.LS1.SP_Percent;
		END_IF;
	ELSIF (AR_Param.NumberOfLS = 3) AND AR_Internal.LS3Confirmed THEN
		AR_Internal.OpeningMode := FALSE;
		AR_Internal.ActiveStage := 2;
		IF AR_Internal.ValveCmd > AR_Param.LS2.SP_Percent THEN
			AR_Internal.ValveCmd := AR_Param.LS2.SP_Percent;
		END_IF;
	ELSE
		AR_Internal.OpeningMode := TRUE;
		AR_Internal.ActiveStage := AR_Param.NumberOfLS;
	END_IF;
ELSE
	(* Aktivacija vode ima prioritet; najvisi novi LS odreduje trenutni clamp. *)
	IF AR_Internal.LS1Confirmed AND NOT AR_Internal.LS1ConfirmedPrev THEN
		AR_Internal.OpeningMode := FALSE;
		AR_Internal.ActiveStage := 1;
		IF AR_Internal.ValveCmd > AR_Param.LS1.SP_Percent THEN
			AR_Internal.ValveCmd := AR_Param.LS1.SP_Percent;
		END_IF;
	ELSIF (AR_Param.NumberOfLS >= 2)
		AND AR_Internal.LS2Confirmed
		AND NOT AR_Internal.LS2ConfirmedPrev THEN
		AR_Internal.OpeningMode := FALSE;
		AR_Internal.ActiveStage := 1;
		IF AR_Internal.ValveCmd > AR_Param.LS1.SP_Percent THEN
			AR_Internal.ValveCmd := AR_Param.LS1.SP_Percent;
		END_IF;
	ELSIF (AR_Param.NumberOfLS = 3)
		AND AR_Internal.LS3Confirmed
		AND NOT AR_Internal.LS3ConfirmedPrev THEN
		AR_Internal.OpeningMode := FALSE;
		AR_Internal.ActiveStage := 2;
		IF AR_Internal.ValveCmd > AR_Param.LS2.SP_Percent THEN
			AR_Internal.ValveCmd := AR_Param.LS2.SP_Percent;
		END_IF;
	ELSIF (AR_Param.NumberOfLS = 3)
		AND NOT AR_Internal.LS3Confirmed
		AND AR_Internal.LS3ConfirmedPrev THEN
		AR_Internal.OpeningMode := TRUE;
		AR_Internal.ActiveStage := 3;
	ELSIF (AR_Param.NumberOfLS >= 2)
		AND NOT AR_Internal.LS2Confirmed
		AND AR_Internal.LS2ConfirmedPrev THEN
		AR_Internal.OpeningMode := TRUE;
		AR_Internal.ActiveStage := 2;
	ELSIF NOT AR_Internal.LS1Confirmed
		AND AR_Internal.LS1ConfirmedPrev THEN
		AR_Internal.OpeningMode := TRUE;
		AR_Internal.ActiveStage := 1;
	END_IF;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 8) Izbor cilja i rampe automatskog stepena                                *)
(* -------------------------------------------------------------------------- *)
IF AR_Input.EnableManual
	AND AR_Input.Enable
	AND NOT AR_Internal.FaultCondition
	AND NOT AR_Internal.FaultLatched THEN
	AR_Internal.TargetSP := AR_Internal.ValveCmd;
	AR_Internal.ActiveRamp := 0.0;
ELSE
	CASE AR_Internal.ActiveStage OF
		1:
			IF AR_Internal.ConfigValid THEN
				AR_Internal.ActiveRamp := AR_Param.LS1.Ramp_PercentPerSecond;
			ELSE
				AR_Internal.ActiveRamp := AR_Constant.SAFE_CLOSE_RAMP;
			END_IF;
			IF AR_Internal.OpeningMode AND AR_Internal.ConfigValid THEN
				AR_Internal.TargetSP := AR_Param.LS1.SP_Percent;
			ELSE
				AR_Internal.TargetSP := AR_Constant.PCT_MIN;
			END_IF;
		2:
			AR_Internal.ActiveRamp := AR_Param.LS2.Ramp_PercentPerSecond;
			IF AR_Internal.OpeningMode THEN
				AR_Internal.TargetSP := AR_Param.LS2.SP_Percent;
			ELSE
				AR_Internal.TargetSP := AR_Constant.PCT_MIN;
			END_IF;
		3:
			AR_Internal.ActiveRamp := AR_Param.LS3.Ramp_PercentPerSecond;
			IF AR_Internal.OpeningMode THEN
				AR_Internal.TargetSP := AR_Param.LS3.SP_Percent;
			ELSE
				AR_Internal.TargetSP := AR_Constant.PCT_MIN;
			END_IF;
	ELSE
		AR_Internal.ActiveStage := 1;
		AR_Internal.ActiveRamp := AR_Param.LS1.Ramp_PercentPerSecond;
		AR_Internal.TargetSP := AR_Constant.PCT_MIN;
	END_CASE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 9) Rampa komande u %/s prema stvarnom vremenu task ciklusa                 *)
(* -------------------------------------------------------------------------- *)
IF AR_Input.EnableManual
	AND AR_Input.Enable
	AND NOT AR_Internal.FaultCondition
	AND NOT AR_Internal.FaultLatched THEN
	(* Direktna manual komanda ne koristi procesnu rampu. *)
ELSIF AR_Internal.RuntimeTimeValid THEN
	AR_Internal.RampStep := AR_Internal.ActiveRamp * AR_Output.CycleTime_s;

	IF AR_Internal.TargetSP > AR_Internal.ValveCmd THEN
		AR_Internal.ValveCmd := AR_Internal.ValveCmd + AR_Internal.RampStep;
		IF AR_Internal.ValveCmd > AR_Internal.TargetSP THEN
			AR_Internal.ValveCmd := AR_Internal.TargetSP;
		END_IF;
	ELSIF AR_Internal.TargetSP < AR_Internal.ValveCmd THEN
		AR_Internal.ValveCmd := AR_Internal.ValveCmd - AR_Internal.RampStep;
		IF AR_Internal.ValveCmd < AR_Internal.TargetSP THEN
			AR_Internal.ValveCmd := AR_Internal.TargetSP;
		END_IF;
	END_IF;
ELSIF AR_Internal.FaultCondition THEN
	(* Bez validne vremenske baze nije moguca kontrolisana rampa. *)
	AR_Internal.ValveCmd := AR_Constant.PCT_MIN;
END_IF;

IF AR_Internal.ValveCmd < AR_Constant.PCT_MIN THEN
	AR_Internal.ValveCmd := AR_Constant.PCT_MIN;
ELSIF AR_Internal.ValveCmd > AR_Constant.PCT_MAX THEN
	AR_Internal.ValveCmd := AR_Constant.PCT_MAX;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 10) State, tekst i HMI dijagnostika                                        *)
(* -------------------------------------------------------------------------- *)
IF AR_Internal.FaultCondition OR AR_Internal.FaultLatched THEN
	AR_Internal.Step := AR_Constant.ST_FAULT_SAFE_CLOSE;
ELSIF NOT AR_Input.Enable THEN
	AR_Internal.Step := AR_Constant.ST_DISABLED;
ELSIF AR_Input.EnableManual THEN
	AR_Internal.Step := AR_Constant.ST_MANUAL;
ELSIF NOT AR_Internal.PressureActive THEN
	AR_Internal.Step := AR_Constant.ST_WAIT_PRESSURE;
ELSIF AR_Internal.ValveCmd <= AR_Constant.PCT_MIN THEN
	AR_Internal.Step := AR_Constant.ST_CLOSED;
ELSIF AR_Internal.OpeningMode THEN
	CASE AR_Internal.ActiveStage OF
		1: AR_Internal.Step := AR_Constant.ST_OPENING_LS1;
		2: AR_Internal.Step := AR_Constant.ST_OPENING_LS2;
		3: AR_Internal.Step := AR_Constant.ST_OPENING_LS3;
	END_CASE;
ELSE
	CASE AR_Internal.ActiveStage OF
		1: AR_Internal.Step := AR_Constant.ST_CLOSING_LS1;
		2: AR_Internal.Step := AR_Constant.ST_CLOSING_LS2;
	ELSE
		AR_Internal.Step := AR_Constant.ST_CLOSING_LS1;
	END_CASE;
END_IF;

CASE AR_Internal.Step OF
	0: AR_Output.State_comment := 'ST_DISABLED - bezbedno zatvaranje ventila';
	1: AR_Output.State_comment := 'ST_WAIT_PRESSURE - ceka aktivni pritisak';
	2: AR_Output.State_comment := 'ST_OPENING_LS1 - otvaranje rampom LS1';
	3: AR_Output.State_comment := 'ST_OPENING_LS2 - otvaranje rampom LS2';
	4: AR_Output.State_comment := 'ST_OPENING_LS3 - otvaranje rampom LS3';
	5: AR_Output.State_comment := 'ST_CLOSING_LS1 - zatvaranje rampom LS1';
	6: AR_Output.State_comment := 'ST_CLOSING_LS2 - zatvaranje rampom LS2';
	7: AR_Output.State_comment := 'ST_CLOSED - komanda ventila je 0%';
	8: AR_Output.State_comment := 'ST_FAULT_SAFE_CLOSE - alarm, bezbedno zatvaranje';
	9: AR_Output.State_comment := 'ST_MANUAL - direktna rucna komanda 0..100%';
ELSE
	AR_Output.State_comment := 'ST_UNKNOWN - nepoznato stanje';
END_CASE;

CASE AR_Internal.FaultCode OF
	0: AR_Output.FaultText := 'FLT_NONE - nema memorisanog alarma';
	1: AR_Output.FaultText := 'FLT_CONFIG_INVALID - nevalidni parametri';
	2: AR_Output.FaultText := 'FLT_LS_SEQUENCE_INVALID - nelogican LS redosled';
	3: AR_Output.FaultText := 'FLT_RUNTIME_TIME_INVALID - nema vremena ciklusa';
ELSE
	AR_Output.FaultText := 'FLT_UNKNOWN - nepoznat memorisani alarm';
END_CASE;

IF NOT AR_Internal.ConfigValid THEN
	AR_Output.Diag := 'CONFIG_INVALID';
ELSIF NOT AR_Internal.RuntimeTimeValid THEN
	AR_Output.Diag := 'RUNTIME_TIME_INVALID';
ELSIF AR_Internal.LSSequenceInvalid THEN
	AR_Output.Diag := 'LS_SEQUENCE_INVALID';
ELSIF AR_Internal.FaultLatched THEN
	AR_Output.Diag := 'ALARM_LATCHED_WAIT_RESET';
ELSIF NOT AR_Input.Enable THEN
	AR_Output.Diag := 'DISABLED_SAFE_CLOSING';
ELSIF AR_Input.EnableManual THEN
	AR_Output.Diag := 'MANUAL_DIRECT_COMMAND';
ELSIF NOT AR_Internal.PressureActive THEN
	AR_Output.Diag := 'WAITING_ACTIVE_PRESSURE';
ELSIF AR_Internal.OpeningMode THEN
	AR_Output.Diag := 'AIR_RELEASE_OPENING';
ELSE
	AR_Output.Diag := 'WATER_CONFIRMED_CLOSING';
END_IF;

(* -------------------------------------------------------------------------- *)
(* 11) Izlazno mapiranje                                                       *)
(* -------------------------------------------------------------------------- *)
AR_Output.ValveSP_Percent := AR_Internal.ValveCmd;
AR_Output.Status :=
	AR_Input.Enable
	AND AR_Internal.ConfigValid
	AND AR_Internal.RuntimeTimeValid
	AND NOT AR_Internal.FaultLatched;
AR_Output.State := AR_Internal.Step;
AR_Output.ManualActive :=
	AR_Input.Enable
	AND AR_Input.EnableManual
	AND NOT AR_Internal.FaultCondition
	AND NOT AR_Internal.FaultLatched;
AR_Output.PressureActive := AR_Internal.PressureActive;
AR_Output.LS1_Confirmed := AR_Internal.LS1Confirmed;
AR_Output.LS2_Confirmed := AR_Internal.LS2Confirmed;
AR_Output.LS3_Confirmed := AR_Internal.LS3Confirmed;
AR_Output.ActiveStage := AR_Internal.ActiveStage;
AR_Output.Opening := NOT AR_Output.ManualActive
	AND AR_Internal.OpeningMode
	AND (AR_Internal.ValveCmd < AR_Internal.TargetSP);
AR_Output.Closing := NOT AR_Output.ManualActive
	AND NOT AR_Internal.OpeningMode
	AND (AR_Internal.ValveCmd > AR_Constant.PCT_MIN);
AR_Output.AlarmActive := AR_Internal.FaultCondition;
AR_Output.AlarmLatched := AR_Internal.FaultLatched;
AR_Output.FaultCode := AR_Internal.FaultCode;
AR_Output.ActiveConditionCode := AR_Internal.ActiveConditionCode;
AR_Output.ResetAllowed := AR_Internal.ResetAllowed;
AR_Output.ConfigValid := AR_Internal.ConfigValid;
AR_Output.ConfigFaultText := AR_Internal.ConfigFaultText;
AR_Output.LSSequenceInvalid := AR_Internal.LSSequenceInvalid;

(* -------------------------------------------------------------------------- *)
(* 12) Memorija prethodnog ciklusa                                            *)
(* -------------------------------------------------------------------------- *)
AR_Internal.ControlActivePrev :=
	AR_Input.Enable
	AND NOT AR_Input.EnableManual
	AND AR_Internal.PressureActive
	AND NOT AR_Internal.FaultCondition
	AND NOT AR_Internal.FaultLatched;
AR_Internal.LS1ConfirmedPrev := AR_Internal.LS1Confirmed;
AR_Internal.LS2ConfirmedPrev := AR_Internal.LS2Confirmed;
AR_Internal.LS3ConfirmedPrev := AR_Internal.LS3Confirmed;

END_FUNCTION_BLOCK
