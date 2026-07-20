FUNCTION_BLOCK FBAI01_DI01 (* Skaliranje transmitera sa AI + statusnim DI signalom *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)

(* -------------------------------------------------------------------------- *)
(* 1) Podrazumevane vrednosti po scan-u                                        *)
(* -------------------------------------------------------------------------- *)
(* Podrazumevane vrednosti po scan-u. *)
AI_Output.Status := FALSE;
AI_Internal.FaultCondition := FALSE;
AI_Output.TransmitterStatusIn := AI_Input.TransmitterStatus;
AI_Internal.ResetRequest := AI_Input.ResetAlarm;

(* -------------------------------------------------------------------------- *)
(* 2) Obrada reset-a i ogranicenje manual vrednosti                            *)
(* -------------------------------------------------------------------------- *)
(* Eksplicitni reset latched alarma. *)
IF AI_Internal.ResetRequest THEN
	AI_Internal.FaultLatched := FALSE;
END_IF;

(* Ogranicenje manual vrednosti na opseg. *)
AI_Internal.ManualValueLimited := AI_Input.ManualValue;
IF AI_Internal.ManualValueLimited < AI_Param.ScaledMin THEN
	AI_Internal.ManualValueLimited := AI_Param.ScaledMin;
END_IF;
IF AI_Internal.ManualValueLimited > AI_Param.ScaledMax THEN
	AI_Internal.ManualValueLimited := AI_Param.ScaledMax;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 3) Glavna obrada kada je blok omogucen                                      *)
(* -------------------------------------------------------------------------- *)
IF NOT AI_Input.Enable THEN
	AI_Output.ScaledValue := 0.0;
	AI_Output.State := AI_Constant.ST_DISABLED;
	AI_Output.State_comment := AI_Constant.CMT_DISABLED;
	AI_Output.Status := FALSE;
	AI_Output.UnitOfMeasureOut := AI_Param.UnitOfMeasure;
ELSE
	(* Racunanje raspona za linearnu transformaciju raw -> scaled. *)
	AI_Internal.ScaleSpanRaw := INT_TO_REAL(AI_Param.RawMax - AI_Param.RawMin);
	AI_Internal.ScaleSpanScaled := AI_Param.ScaledMax - AI_Param.ScaledMin;

	IF AI_Internal.ScaleSpanRaw <= 0.0 THEN
		AI_Internal.FaultCondition := TRUE;
	END_IF;

	IF AI_Input.ManualAlarm THEN
		AI_Internal.FaultCondition := TRUE;
	END_IF;

	IF AI_Input.EnableManual THEN
		AI_Output.ScaledValue := AI_Internal.ManualValueLimited;
	ELSE
		IF AI_Input.UnderRange OR AI_Input.OverRange THEN
			AI_Internal.FaultCondition := TRUE;
		END_IF;

		IF AI_Internal.ScaleSpanRaw > 0.0 THEN
			AI_Output.ScaledValue :=
				AI_Param.ScaledMin +
				((INT_TO_REAL(AI_Input.RawValue - AI_Param.RawMin) / AI_Internal.ScaleSpanRaw) * AI_Internal.ScaleSpanScaled);
		ELSE
			AI_Output.ScaledValue := AI_Param.ScaledMin;
		END_IF;
	END_IF;

	IF AI_Internal.FaultCondition THEN
		AI_Internal.FaultLatched := TRUE;
	END_IF;

	(* ---------------------------------------------------------------------- *)
	(* 4) State i status mapiranje                                             *)
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

END_FUNCTION_BLOCK
