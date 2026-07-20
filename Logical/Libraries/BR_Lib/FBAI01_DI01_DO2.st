FUNCTION_BLOCK FBAI01_DI01_DO02 (* Skaliranje transmitera sa AI + status DI + 2 DO izbora opsega *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)

(* -------------------------------------------------------------------------- *)
(* 1) Podrazumevane vrednosti po scan-u                                        *)
(* -------------------------------------------------------------------------- *)
(* Podrazumevane vrednosti po scan-u. *)
AI_Output.Status := FALSE;
AI_Internal.FaultCondition := FALSE;
AI_Internal.FaultProcess := FALSE;
AI_Internal.FaultConfig := FALSE;
AI_Output.UnitOfMeasureOut := AI_Param.UnitOfMeasure;
AI_Output.TransmitterStatusIn := AI_Input.TransmitterStatus;
AI_Output.RangeChanging := FALSE;
AI_Output.FaultProcessOut := FALSE;
AI_Output.FaultConfigOut := FALSE;
AI_Internal.ResetRequest := AI_Input.ResetAlarm;

(* -------------------------------------------------------------------------- *)
(* 2) Reset i detekcija promene opsega                                         *)
(* -------------------------------------------------------------------------- *)
(* Eksplicitni reset latched alarma. *)
IF AI_Internal.ResetRequest THEN
	AI_Internal.FaultLatched := FALSE;
END_IF;

(* Detekcija promene opsega. *)
IF AI_Input.RangeSelect <> AI_Internal.PrevRangeSelect THEN
	AI_Internal.RangeChangeMem := TRUE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 3) Izbor opsega i mapiranje DO bitova                                       *)
(* -------------------------------------------------------------------------- *)
(* Izbor aktivnog opsega i mapiranje u 2 izlazna DO bita. *)
CASE AI_Input.RangeSelect OF
	1:
		AI_Output.ActiveRange := 1;
		AI_Output.RangeBit0_out := FALSE;
		AI_Output.RangeBit1_out := FALSE;
		AI_Internal.ActiveScaledMin := AI_Param.ScaledMin_R1;
		AI_Internal.ActiveScaledMax := AI_Param.ScaledMax_R1;
		AI_Output.RangeComment := 'Opseg 1';
	2:
		AI_Output.ActiveRange := 2;
		AI_Output.RangeBit0_out := TRUE;
		AI_Output.RangeBit1_out := FALSE;
		AI_Internal.ActiveScaledMin := AI_Param.ScaledMin_R2;
		AI_Internal.ActiveScaledMax := AI_Param.ScaledMax_R2;
		AI_Output.RangeComment := 'Opseg 2';
	3:
		AI_Output.ActiveRange := 3;
		AI_Output.RangeBit0_out := FALSE;
		AI_Output.RangeBit1_out := TRUE;
		AI_Internal.ActiveScaledMin := AI_Param.ScaledMin_R3;
		AI_Internal.ActiveScaledMax := AI_Param.ScaledMax_R3;
		AI_Output.RangeComment := 'Opseg 3';
	4:
		AI_Output.ActiveRange := 4;
		AI_Output.RangeBit0_out := TRUE;
		AI_Output.RangeBit1_out := TRUE;
		AI_Internal.ActiveScaledMin := AI_Param.ScaledMin_R4;
		AI_Internal.ActiveScaledMax := AI_Param.ScaledMax_R4;
		AI_Output.RangeComment := 'Opseg 4';
	ELSE
		AI_Output.ActiveRange := 1;
		AI_Output.RangeBit0_out := FALSE;
		AI_Output.RangeBit1_out := FALSE;
		AI_Internal.ActiveScaledMin := AI_Param.ScaledMin_R1;
		AI_Internal.ActiveScaledMax := AI_Param.ScaledMax_R1;
		AI_Output.RangeComment := 'Nevalidan opseg';
		AI_Internal.FaultConfig := TRUE;
END_CASE;

(* -------------------------------------------------------------------------- *)
(* 4) Ogranicenje manual vrednosti i range-settle tajmer                       *)
(* -------------------------------------------------------------------------- *)
(* Ogranicenje manual vrednosti na aktivni opseg. *)
AI_Internal.ManualValueLimited := AI_Input.ManualValue;
IF AI_Internal.ManualValueLimited < AI_Internal.ActiveScaledMin THEN
	AI_Internal.ManualValueLimited := AI_Internal.ActiveScaledMin;
END_IF;
IF AI_Internal.ManualValueLimited > AI_Internal.ActiveScaledMax THEN
	AI_Internal.ManualValueLimited := AI_Internal.ActiveScaledMax;
END_IF;

(* Tajmer stabilizacije nakon promene opsega. *)
AI_Internal.RangeSettleTimeEffective := AI_Input.RangeSettleTime;
IF AI_Internal.RangeSettleTimeEffective <= T#0ms THEN
	AI_Internal.RangeSettleTimeEffective := T#2s;
	AI_Internal.FaultConfig := TRUE;
END_IF;

AI_Internal.RangeSettleTimer(
	IN := AI_Internal.RangeChangeMem,
	PT := AI_Internal.RangeSettleTimeEffective
);
AI_Output.RangeChanging := AI_Internal.RangeChangeMem;
IF AI_Internal.RangeSettleTimer.Q THEN
	AI_Internal.RangeChangeMem := FALSE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 5) Glavna obrada kada je blok omogucen                                      *)
(* -------------------------------------------------------------------------- *)
IF NOT AI_Input.Enable THEN
	AI_Output.ScaledValue := 0.0;
	AI_Output.State := AI_Constant.ST_DISABLED;
	AI_Output.State_comment := AI_Constant.CMT_DISABLED;
	AI_Output.Status := FALSE;
ELSE
	(* Racunanje raspona za linearnu transformaciju raw -> scaled. *)
	AI_Internal.ScaleSpanRaw := INT_TO_REAL(AI_Param.RawMax - AI_Param.RawMin);
	AI_Internal.ScaleSpanScaled := AI_Internal.ActiveScaledMax - AI_Internal.ActiveScaledMin;

	IF AI_Internal.ScaleSpanRaw <= 0.0 THEN
		AI_Internal.FaultConfig := TRUE;
	END_IF;

	IF AI_Internal.ScaleSpanScaled <= 0.0 THEN
		AI_Internal.FaultConfig := TRUE;
	END_IF;

	IF AI_Input.ManualAlarm THEN
		AI_Internal.FaultProcess := TRUE;
	END_IF;

	IF NOT AI_Output.RangeChanging THEN
		IF AI_Input.UnderRange OR AI_Input.OverRange THEN
			AI_Internal.FaultProcess := TRUE;
		END_IF;

		IF NOT AI_Input.TransmitterStatus THEN
			AI_Internal.FaultProcess := TRUE;
		END_IF;
	END_IF;

	IF AI_Output.RangeChanging THEN
		AI_Output.ScaledValue := AI_Internal.LastGoodScaledValue;
	ELSIF AI_Input.EnableManual THEN
		AI_Output.ScaledValue := AI_Internal.ManualValueLimited;
		AI_Internal.LastGoodScaledValue := AI_Output.ScaledValue;
	ELSE
		IF AI_Internal.ScaleSpanRaw > 0.0 THEN
			AI_Output.ScaledValue :=
				AI_Internal.ActiveScaledMin +
				((INT_TO_REAL(AI_Input.RawValue - AI_Param.RawMin) / AI_Internal.ScaleSpanRaw) * AI_Internal.ScaleSpanScaled);
			AI_Internal.LastGoodScaledValue := AI_Output.ScaledValue;
		ELSE
			AI_Output.ScaledValue := AI_Internal.ActiveScaledMin;
		END_IF;
	END_IF;

	AI_Internal.FaultCondition := AI_Internal.FaultProcess OR AI_Internal.FaultConfig;
	AI_Output.FaultProcessOut := AI_Internal.FaultProcess;
	AI_Output.FaultConfigOut := AI_Internal.FaultConfig;

	IF AI_Internal.FaultCondition THEN
		AI_Internal.FaultLatched := TRUE;
	END_IF;

	(* ---------------------------------------------------------------------- *)
	(* 6) State i status mapiranje                                             *)
	(* ---------------------------------------------------------------------- *)
	IF AI_Output.RangeChanging THEN
		AI_Output.State := AI_Constant.ST_RANGE_CHANGING;
		AI_Output.State_comment := AI_Constant.CMT_RANGE_CHANGING;
		AI_Output.Status := FALSE;
	ELSIF AI_Internal.FaultLatched AND AI_Input.EnableManual THEN
		AI_Output.State := AI_Constant.ST_MANUAL_FAULT;
		AI_Output.State_comment := AI_Constant.CMT_MANUAL_FAULT;
		AI_Output.Status := FALSE;
	ELSIF AI_Input.EnableManual THEN
		AI_Output.State := AI_Constant.ST_MANUAL;
		AI_Output.State_comment := AI_Constant.CMT_MANUAL;
		AI_Output.Status := AI_Input.TransmitterStatus;
	ELSIF AI_Internal.FaultLatched THEN
		AI_Output.State := AI_Constant.ST_FAULT;
		AI_Output.State_comment := AI_Constant.CMT_FAULT;
		AI_Output.Status := FALSE;
	ELSIF NOT AI_Input.TransmitterStatus THEN
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
END_IF;

(* -------------------------------------------------------------------------- *)
(* 7) Pamcenje prethodnog opsega za sledeci scan                               *)
(* -------------------------------------------------------------------------- *)
(* Pamcenje prethodnog opsega. *)
AI_Internal.PrevRangeSelect := AI_Input.RangeSelect;

END_FUNCTION_BLOCK
