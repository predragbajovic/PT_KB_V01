FUNCTION_BLOCK FB_PvAiAo_Fast

(* Preporuka za commissioning (nije automatsko prepisivanje parametara):
	DeviationOnLimit = 8.0
	DeviationOffLimit = 3.0
	DeviationTime = T#5s
*)

(* -------------------------------------------------------------------------- *)
(* 1) Osnovni statusi bloka                                                    *)
(* -------------------------------------------------------------------------- *)
PV_Output.Valid := PV_Input.Enable;
PV_Output.ManualActive := PV_Input.EnableManual;

(* -------------------------------------------------------------------------- *)
(* 2) Ogranicenje AI ulaza i skaliranje u procente                             *)
(* -------------------------------------------------------------------------- *)
IF PV_Input.AI_Raw < PV_Constant.RAW_MIN THEN
	PV_Output.AI_Raw_Limited := PV_Constant.RAW_MIN;
ELSIF PV_Input.AI_Raw > PV_Constant.RAW_MAX THEN
	PV_Output.AI_Raw_Limited := PV_Constant.RAW_MAX;
ELSE
	PV_Output.AI_Raw_Limited := PV_Input.AI_Raw;
END_IF;

PV_Internal.rAi := INT_TO_REAL(PV_Output.AI_Raw_Limited);
PV_Output.PV_Percent := (PV_Internal.rAi * PV_Constant.PCT_MAX) / INT_TO_REAL(PV_Constant.RAW_MAX);

(* -------------------------------------------------------------------------- *)
(* 3) Ogranicenje auto i manual komande                                        *)
(* -------------------------------------------------------------------------- *)
IF PV_Input.SP_Percent < PV_Constant.PCT_MIN THEN
	PV_Output.SP_Percent_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Input.SP_Percent > PV_Constant.PCT_MAX THEN
	PV_Output.SP_Percent_Limited := PV_Constant.PCT_MAX;
ELSE
	PV_Output.SP_Percent_Limited := PV_Input.SP_Percent;
END_IF;

IF PV_Input.ManualValue_Percent < PV_Constant.PCT_MIN THEN
	PV_Output.ManualValue_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Input.ManualValue_Percent > PV_Constant.PCT_MAX THEN
	PV_Output.ManualValue_Limited := PV_Constant.PCT_MAX;
ELSE
	PV_Output.ManualValue_Limited := PV_Input.ManualValue_Percent;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 4) Izbor aktivne komande (manual ima prioritet)                             *)
(* -------------------------------------------------------------------------- *)
IF PV_Input.EnableManual THEN
	PV_Output.ActiveSP_Limited := PV_Output.ManualValue_Limited;
ELSE
	PV_Output.ActiveSP_Limited := PV_Output.SP_Percent_Limited;
END_IF;
PV_Output.ActiveSP_Percent := PV_Output.ActiveSP_Limited;

(* -------------------------------------------------------------------------- *)
(* 5) Validacija devijacionih granica i vremena                                *)
(* -------------------------------------------------------------------------- *)
IF PV_Param.DeviationOnLimit < PV_Constant.PCT_MIN THEN
	PV_Output.DeviationOn_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Param.DeviationOnLimit > PV_Constant.PCT_MAX THEN
	PV_Output.DeviationOn_Limited := PV_Constant.PCT_MAX;
ELSE
	PV_Output.DeviationOn_Limited := PV_Param.DeviationOnLimit;
END_IF;

IF PV_Param.DeviationOffLimit < PV_Constant.PCT_MIN THEN
	PV_Output.DeviationOff_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Param.DeviationOffLimit > PV_Constant.PCT_MAX THEN
	PV_Output.DeviationOff_Limited := PV_Constant.PCT_MAX;
ELSE
	PV_Output.DeviationOff_Limited := PV_Param.DeviationOffLimit;
END_IF;

IF PV_Output.DeviationOff_Limited > PV_Output.DeviationOn_Limited THEN
	PV_Output.DeviationOff_Limited := PV_Output.DeviationOn_Limited;
END_IF;

IF PV_Param.DeviationTime <= T#0ms THEN
	PV_Output.DeviationTime_Effective := PV_Constant.MIN_DEV_TIME;
ELSE
	PV_Output.DeviationTime_Effective := PV_Param.DeviationTime;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 6) Proracun devijacije i tolerancije                                        *)
(* -------------------------------------------------------------------------- *)
PV_Output.DeviationPercent := ABS(PV_Output.ActiveSP_Limited - PV_Output.PV_Percent);
PV_Output.InTolerance := (PV_Output.DeviationPercent <= PV_Output.DeviationOff_Limited);

(* -------------------------------------------------------------------------- *)
(* 7) Fault/reset/deviation stanje i tajmer                                     *)
(* -------------------------------------------------------------------------- *)
IF PV_Input.Reset THEN
	PV_Output.FaultActive := FALSE;
	PV_Output.DeviationTimeout := FALSE;
	PV_Output.InDeviation := FALSE;

	PV_Internal.FB_DeviationTimer.PT := PV_Output.DeviationTime_Effective;
	PV_Internal.FB_DeviationTimer.IN := FALSE;
	PV_Internal.FB_DeviationTimer();
	PV_Output.DeviationElapsed := PV_Internal.FB_DeviationTimer.ET;

ELSIF NOT PV_Input.Enable THEN
	PV_Output.InDeviation := FALSE;

	PV_Internal.FB_DeviationTimer.PT := PV_Output.DeviationTime_Effective;
	PV_Internal.FB_DeviationTimer.IN := FALSE;
	PV_Internal.FB_DeviationTimer();
	PV_Output.DeviationElapsed := PV_Internal.FB_DeviationTimer.ET;

ELSE
	IF PV_Output.FaultActive THEN
		PV_Output.InDeviation := FALSE;

		PV_Internal.FB_DeviationTimer.PT := PV_Output.DeviationTime_Effective;
		PV_Internal.FB_DeviationTimer.IN := FALSE;
		PV_Internal.FB_DeviationTimer();
		PV_Output.DeviationElapsed := PV_Internal.FB_DeviationTimer.ET;
	ELSE
		IF NOT PV_Output.InDeviation THEN
			IF PV_Output.DeviationPercent >= PV_Output.DeviationOn_Limited THEN
				PV_Output.InDeviation := TRUE;
			END_IF;
		ELSE
			IF PV_Output.DeviationPercent <= PV_Output.DeviationOff_Limited THEN
				PV_Output.InDeviation := FALSE;
			END_IF;
		END_IF;

		PV_Internal.FB_DeviationTimer.PT := PV_Output.DeviationTime_Effective;
		PV_Internal.FB_DeviationTimer.IN := PV_Output.InDeviation;
		PV_Internal.FB_DeviationTimer();
		PV_Output.DeviationElapsed := PV_Internal.FB_DeviationTimer.ET;

		IF PV_Output.InDeviation AND PV_Internal.FB_DeviationTimer.Q THEN
			PV_Output.FaultActive := TRUE;
			PV_Output.DeviationTimeout := TRUE;
			PV_Output.InDeviation := FALSE;
		END_IF;
	END_IF;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 8) Izbor stvarno primenjene izlazne komande                                  *)
(* -------------------------------------------------------------------------- *)
IF NOT PV_Input.Enable THEN
	PV_Output.AppliedOutput_Limited := PV_Constant.PCT_MIN;
	PV_Output.FrozenOutput_Percent := PV_Constant.PCT_MIN;
	PV_Output.CommandPermitted := FALSE;
	PV_Output.ForceActive := FALSE;

ELSIF PV_Output.FaultActive THEN
	IF PV_Input.ForceCmd THEN
		PV_Output.AppliedOutput_Limited := PV_Output.ActiveSP_Limited;
		PV_Output.CommandPermitted := TRUE;
		PV_Output.ForceActive := TRUE;
	ELSE
		PV_Output.CommandPermitted := FALSE;
		PV_Output.ForceActive := FALSE;

		IF PV_Param.HoldOutputOnFault THEN
			PV_Output.AppliedOutput_Limited := PV_Output.FrozenOutput_Percent;
		ELSE
			PV_Output.AppliedOutput_Limited := PV_Constant.PCT_MIN;
		END_IF;
	END_IF;
ELSE
	PV_Output.AppliedOutput_Limited := PV_Output.ActiveSP_Limited;
	PV_Output.CommandPermitted := TRUE;
	PV_Output.ForceActive := FALSE;
	PV_Output.FrozenOutput_Percent := PV_Output.AppliedOutput_Limited;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 9) Zavrsno ogranicenje i AO skaliranje                                      *)
(* -------------------------------------------------------------------------- *)
IF PV_Output.AppliedOutput_Limited < PV_Constant.PCT_MIN THEN
	PV_Output.AppliedOutput_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Output.AppliedOutput_Limited > PV_Constant.PCT_MAX THEN
	PV_Output.AppliedOutput_Limited := PV_Constant.PCT_MAX;
END_IF;
PV_Output.AppliedOutput_Percent := PV_Output.AppliedOutput_Limited;

PV_Internal.rAo := (PV_Output.AppliedOutput_Limited * INT_TO_REAL(PV_Constant.RAW_MAX)) / PV_Constant.PCT_MAX;
PV_Internal.AO_Raw_Calc := REAL_TO_INT(PV_Internal.rAo);

IF PV_Internal.AO_Raw_Calc < PV_Constant.RAW_MIN THEN
	PV_Internal.AO_Raw_Calc := PV_Constant.RAW_MIN;
ELSIF PV_Internal.AO_Raw_Calc > PV_Constant.RAW_MAX THEN
	PV_Internal.AO_Raw_Calc := PV_Constant.RAW_MAX;
END_IF;
PV_Output.AO_Raw := PV_Internal.AO_Raw_Calc;

(* -------------------------------------------------------------------------- *)
(* 10) Standardni izlazi stanja za HMI/SCADA                                    *)
(* -------------------------------------------------------------------------- *)
IF NOT PV_Input.Enable THEN
	PV_Output.Status := FALSE;
	PV_Output.State := PV_Constant.ST_DISABLED;
	PV_Output.State_comment := 'ST_DISABLED - blok nije omogucen';
ELSIF PV_Output.FaultActive THEN
	PV_Output.Status := FALSE;
	IF PV_Output.ForceActive THEN
		PV_Output.State := PV_Constant.ST_FAULT_FORCE;
		PV_Output.State_comment := 'ST_FAULT_FORCE - fault aktivan, izlaz forsiran';
	ELSE
		PV_Output.State := PV_Constant.ST_FAULT_HOLD;
		PV_Output.State_comment := 'ST_FAULT_HOLD - fault aktivan, izlaz blokiran/hold';
	END_IF;
ELSIF PV_Output.InDeviation THEN
	PV_Output.Status := TRUE;
	PV_Output.State := PV_Constant.ST_DEVIATION_ACTIVE;
	PV_Output.State_comment := 'ST_DEVIATION_ACTIVE - aktivno pracenje devijacije';
ELSIF PV_Output.ManualActive THEN
	PV_Output.Status := TRUE;
	PV_Output.State := PV_Constant.ST_MANUAL_ACTIVE;
	PV_Output.State_comment := 'ST_MANUAL_ACTIVE - aktivan manuelni rezim';
ELSE
	PV_Output.Status := TRUE;
	PV_Output.State := PV_Constant.ST_AUTO_ACTIVE;
	PV_Output.State_comment := 'ST_AUTO_ACTIVE - aktivan automatski rezim';
END_IF;

END_FUNCTION_BLOCK
