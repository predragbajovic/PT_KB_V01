FUNCTION_BLOCK FBAI01_DI01 (* Skaliranje transmitera sa AI + statusnim DI signalom *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)

(* -------------------------------------------------------------------------- *)
(* 1) Podrazumevane vrednosti po scan-u                                        *)
(* -------------------------------------------------------------------------- *)
(* Podrazumevane vrednosti po scan-u. *)
AI_Output.Status := FALSE;
AI_Internal.FaultCondition := FALSE;
AI_Internal.ActiveFaultCode := AI_Constant.FLT_NONE;
AI_Internal.ConfigValid := TRUE;
AI_Internal.ConfigFaultText := '';
AI_Output.TransmitterStatusIn := AI_Input.TransmitterStatus;
AI_Internal.ResetRequest := AI_Input.ResetAlarm;

(* -------------------------------------------------------------------------- *)
(* 2) Validacija parametara i priprema raspona                                 *)
(* -------------------------------------------------------------------------- *)
(* Validacija opsega. RawMax mora biti veci od RawMin. *)
IF AI_Param.RawMax <= AI_Param.RawMin THEN
	AI_Internal.ConfigValid := FALSE;
	AI_Internal.ConfigFaultText := 'RawMax mora biti veci od RawMin';
END_IF;

(* Validacija skaliranog opsega. ScaledMax mora biti veci od ScaledMin. *)
IF AI_Internal.ConfigValid AND (AI_Param.ScaledMax <= AI_Param.ScaledMin) THEN
	AI_Internal.ConfigValid := FALSE;
	AI_Internal.ConfigFaultText := 'ScaledMax mora biti veci od ScaledMin';
END_IF;

IF AI_Internal.ConfigValid THEN
	AI_Internal.ScaleSpanRaw := INT_TO_REAL(AI_Param.RawMax - AI_Param.RawMin);
	AI_Internal.ScaleSpanScaled := AI_Param.ScaledMax - AI_Param.ScaledMin;
ELSE
	AI_Internal.ScaleSpanRaw := 0.0;
	AI_Internal.ScaleSpanScaled := 0.0;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 3) Ogranicenje manual vrednosti                                             *)
(* -------------------------------------------------------------------------- *)
(* Ogranicenje manual vrednosti na opseg. *)
AI_Internal.ManualValueLimited := AI_Input.ManualValue;
IF AI_Internal.ManualValueLimited < AI_Param.ScaledMin THEN
	AI_Internal.ManualValueLimited := AI_Param.ScaledMin;
END_IF;
IF AI_Internal.ManualValueLimited > AI_Param.ScaledMax THEN
	AI_Internal.ManualValueLimited := AI_Param.ScaledMax;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 4) Fault evaluacija                                                         *)
(* -------------------------------------------------------------------------- *)
IF AI_Input.Enable THEN
	IF NOT AI_Internal.ConfigValid THEN
		AI_Internal.FaultCondition := TRUE;
		AI_Internal.ActiveFaultCode := AI_Constant.FLT_CONFIG_INVALID;
	ELSIF AI_Input.ManualAlarm THEN
		AI_Internal.FaultCondition := TRUE;
		AI_Internal.ActiveFaultCode := AI_Constant.FLT_MANUAL_ALARM;
	ELSIF (NOT AI_Input.EnableManual) AND AI_Input.UnderRange THEN
		AI_Internal.FaultCondition := TRUE;
		AI_Internal.ActiveFaultCode := AI_Constant.FLT_UNDERRANGE;
	ELSIF (NOT AI_Input.EnableManual) AND AI_Input.OverRange THEN
		AI_Internal.FaultCondition := TRUE;
		AI_Internal.ActiveFaultCode := AI_Constant.FLT_OVERRANGE;
	END_IF;
END_IF;

(* Reset je dozvoljen samo kada je latch aktivan i nema aktivnog fault uslova. *)
AI_Internal.ResetAllowed := AI_Internal.FaultLatched AND (NOT AI_Internal.FaultCondition);
IF AI_Internal.ResetRequest AND AI_Internal.ResetAllowed THEN
	AI_Internal.FaultLatched := FALSE;
	AI_Internal.FaultCode := AI_Constant.FLT_NONE;
	AI_Internal.FaultText := '';
END_IF;

(* Latch fault-a pamti prvi uzrok do validnog reset-a. *)
IF AI_Internal.FaultCondition THEN
	IF NOT AI_Internal.FaultLatched THEN
		AI_Internal.FaultCode := AI_Internal.ActiveFaultCode;
		IF AI_Internal.ActiveFaultCode = AI_Constant.FLT_MANUAL_ALARM THEN
			AI_Internal.FaultText := 'ManualAlarm aktivan';
		ELSIF AI_Internal.ActiveFaultCode = AI_Constant.FLT_UNDERRANGE THEN
			AI_Internal.FaultText := 'UnderRange signal aktivan';
		ELSIF AI_Internal.ActiveFaultCode = AI_Constant.FLT_OVERRANGE THEN
			AI_Internal.FaultText := 'OverRange signal aktivan';
		ELSIF AI_Internal.ActiveFaultCode = AI_Constant.FLT_CONFIG_INVALID THEN
			AI_Internal.FaultText := AI_Internal.ConfigFaultText;
		ELSE
			AI_Internal.FaultText := 'AI fault';
		END_IF;
	END_IF;
	AI_Internal.FaultLatched := TRUE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 5) Glavna obrada kada je blok omogucen                                      *)
(* -------------------------------------------------------------------------- *)
IF NOT AI_Input.Enable THEN
	AI_Output.ScaledValue := 0.0;
	AI_Output.State := AI_Constant.ST_DISABLED;
	AI_Output.State_comment := AI_Constant.CMT_DISABLED;
	AI_Output.Status := FALSE;
	AI_Output.UnitOfMeasureOut := AI_Param.UnitOfMeasure;
ELSE
	IF AI_Input.EnableManual THEN
		AI_Output.ScaledValue := AI_Internal.ManualValueLimited;
	ELSE
		IF AI_Internal.ConfigValid AND (AI_Internal.ScaleSpanRaw > 0.0) THEN
			AI_Output.ScaledValue :=
				AI_Param.ScaledMin +
				((INT_TO_REAL(AI_Input.RawValue - AI_Param.RawMin) / AI_Internal.ScaleSpanRaw) * AI_Internal.ScaleSpanScaled);

			(* Zavrsno ogranicenje skalirane vrednosti na parametarski opseg. *)
			IF AI_Output.ScaledValue < AI_Param.ScaledMin THEN
				AI_Output.ScaledValue := AI_Param.ScaledMin;
			END_IF;
			IF AI_Output.ScaledValue > AI_Param.ScaledMax THEN
				AI_Output.ScaledValue := AI_Param.ScaledMax;
			END_IF;
		ELSE
			AI_Output.ScaledValue := AI_Param.ScaledMin;
		END_IF;
	END_IF;

	(* ---------------------------------------------------------------------- *)
	(* 6) State i status mapiranje                                             *)
	(* ---------------------------------------------------------------------- *)
	IF AI_Internal.FaultLatched AND AI_Input.EnableManual THEN
		AI_Output.State := AI_Constant.ST_MANUAL_FAULT;
		AI_Output.State_comment := AI_Constant.CMT_MANUAL_FAULT;
		AI_Output.Status := FALSE;
	ELSIF AI_Input.EnableManual THEN
		AI_Output.State := AI_Constant.ST_MANUAL;
		AI_Output.State_comment := AI_Constant.CMT_MANUAL;
		AI_Output.Status := (NOT AI_Param.EnableStatusCheck) OR AI_Input.TransmitterStatus;
	ELSIF AI_Internal.FaultLatched THEN
		AI_Output.State := AI_Constant.ST_FAULT;
		AI_Output.State_comment := AI_Constant.CMT_FAULT;
		AI_Output.Status := FALSE;
	ELSIF AI_Param.EnableStatusCheck AND (NOT AI_Input.TransmitterStatus) THEN
		AI_Output.State := AI_Constant.ST_TRANSMITTER_STATUS_0;
		AI_Output.State_comment := AI_Constant.CMT_TRANSMITTER_STATUS_0;
		AI_Output.Status := FALSE;
	ELSIF AI_Input.RawValue < AI_Param.RawMin THEN
		AI_Output.State := AI_Constant.ST_UNDERRANGE;
		AI_Output.State_comment := AI_Constant.CMT_UNDERRANGE;
		AI_Output.Status := FALSE;
	ELSIF AI_Input.RawValue > AI_Param.RawMax THEN
		AI_Output.State := AI_Constant.ST_OVERRANGE;
		AI_Output.State_comment := AI_Constant.CMT_OVERRANGE;
		AI_Output.Status := FALSE;
	ELSE
		AI_Output.State := AI_Constant.ST_ACTIVE;
		AI_Output.State_comment := AI_Constant.CMT_ACTIVE;
		AI_Output.Status := TRUE;
	END_IF;

	AI_Output.UnitOfMeasureOut := AI_Param.UnitOfMeasure;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 7) Dijagnostika i prosireni izlazi                                          *)
(* -------------------------------------------------------------------------- *)
IF NOT AI_Input.Enable THEN
	AI_Internal.Diag := 'DISABLED';
ELSIF AI_Internal.FaultLatched THEN
	IF AI_Internal.FaultCode = AI_Constant.FLT_CONFIG_INVALID THEN
		AI_Internal.Diag := 'FAULT_CONFIG_INVALID';
	ELSE
		AI_Internal.Diag := 'FAULT_LATCHED';
	END_IF;
ELSIF AI_Input.EnableManual THEN
	AI_Internal.Diag := 'MANUAL_OK';
ELSIF AI_Param.EnableStatusCheck AND (NOT AI_Input.TransmitterStatus) THEN
	AI_Internal.Diag := 'TRANSMITTER_STATUS_0';
ELSIF AI_Input.RawValue < AI_Param.RawMin THEN
	AI_Internal.Diag := 'UNDERRANGE';
ELSIF AI_Input.RawValue > AI_Param.RawMax THEN
	AI_Internal.Diag := 'OVERRANGE';
ELSE
	AI_Internal.Diag := 'ACTIVE';
END_IF;

AI_Output.FaultLatched := AI_Internal.FaultLatched;
AI_Output.FaultCondition := AI_Internal.FaultCondition;
AI_Output.ResetAllowed := AI_Internal.ResetAllowed;
AI_Output.ConfigValid := AI_Internal.ConfigValid;
AI_Output.ConfigFaultText := AI_Internal.ConfigFaultText;
AI_Output.FaultCode := AI_Internal.FaultCode;
AI_Output.FaultText := AI_Internal.FaultText;
AI_Output.Diag := AI_Internal.Diag;

END_FUNCTION_BLOCK
