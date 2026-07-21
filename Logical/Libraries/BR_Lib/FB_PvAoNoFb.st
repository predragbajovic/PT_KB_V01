FUNCTION_BLOCK FB_PvAoNoFb

(* -------------------------------------------------------------------------- *)
(* 1) Osnovni statusi i izbor rezima                                           *)
(* -------------------------------------------------------------------------- *)
PV_Output.ManualActive := PV_Input.ManualMode;
PV_Output.ForceActive := FALSE;
PV_Output.ParamInvalid := FALSE;

(* -------------------------------------------------------------------------- *)
(* 2) Validacija parametara i priprema efektivnih granica                      *)
(* -------------------------------------------------------------------------- *)
IF (PV_Param.OutMin < PV_Constant.PCT_MIN) OR
   (PV_Param.OutMin > PV_Constant.PCT_MAX) OR
   (PV_Param.OutMax < PV_Constant.PCT_MIN) OR
   (PV_Param.OutMax > PV_Constant.PCT_MAX) OR
   (PV_Param.OutMin >= PV_Param.OutMax) OR
   (PV_Param.RampUp < 0.0) OR
   (PV_Param.RampDown < 0.0) OR
   (PV_Param.OnDelay < T#0ms) OR
   (PV_Param.OffDelay < T#0ms) THEN
	PV_Output.ParamInvalid := TRUE;
END_IF;

IF PV_Output.ParamInvalid THEN
	PV_Output.OutMin_Effective := PV_Constant.PCT_MIN;
	PV_Output.OutMax_Effective := PV_Constant.PCT_MAX;
	PV_Output.RampUp_Effective := PV_Constant.PCT_MAX;
	PV_Output.RampDown_Effective := PV_Constant.PCT_MAX;
	PV_Output.OnDelay_Effective := T#0ms;
	PV_Output.OffDelay_Effective := T#0ms;
ELSE
	PV_Output.OutMin_Effective := PV_Param.OutMin;
	PV_Output.OutMax_Effective := PV_Param.OutMax;

	IF PV_Param.RampUp <= PV_Constant.STEP_MIN THEN
		PV_Output.RampUp_Effective := PV_Constant.PCT_MAX;
	ELSE
		PV_Output.RampUp_Effective := PV_Param.RampUp;
	END_IF;

	IF PV_Param.RampDown <= PV_Constant.STEP_MIN THEN
		PV_Output.RampDown_Effective := PV_Constant.PCT_MAX;
	ELSE
		PV_Output.RampDown_Effective := PV_Param.RampDown;
	END_IF;

	PV_Output.OnDelay_Effective := PV_Param.OnDelay;
	PV_Output.OffDelay_Effective := PV_Param.OffDelay;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 3) Fault latch i reset politika                                              *)
(* -------------------------------------------------------------------------- *)
IF PV_Input.ResetFault AND NOT PV_Output.ParamInvalid THEN
	PV_Output.FaultActive := FALSE;
	PV_Output.FaultCode := PV_Constant.FLT_NONE;
END_IF;

IF PV_Output.ParamInvalid THEN
	PV_Output.FaultActive := TRUE;
	PV_Output.FaultCode := PV_Constant.FLT_PARAM_INVALID;
END_IF;

IF NOT PV_Input.Enable THEN
	PV_Output.ForceActive := FALSE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 4) Izbor i ogranicenje komandnog cilja                                       *)
(* -------------------------------------------------------------------------- *)
IF PV_Input.ManualMode THEN
	PV_Output.CmdTarget := PV_Input.ManualOut;
ELSE
	PV_Output.CmdTarget := PV_Input.AutoSP;
END_IF;

IF PV_Output.CmdTarget < PV_Constant.PCT_MIN THEN
	PV_Output.CmdTarget := PV_Constant.PCT_MIN;
ELSIF PV_Output.CmdTarget > PV_Constant.PCT_MAX THEN
	PV_Output.CmdTarget := PV_Constant.PCT_MAX;
END_IF;

PV_Output.CmdLimited := PV_Output.CmdTarget;
IF PV_Output.CmdLimited < PV_Output.OutMin_Effective THEN
	PV_Output.CmdLimited := PV_Output.OutMin_Effective;
ELSIF PV_Output.CmdLimited > PV_Output.OutMax_Effective THEN
	PV_Output.CmdLimited := PV_Output.OutMax_Effective;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 5) OnDelay/OffDelay logika bez feedback-a                                   *)
(* -------------------------------------------------------------------------- *)
PV_Internal.RiseRequest := (PV_Output.CmdLimited > (PV_Output.OutMin_Effective + PV_Internal.EpsPercent));
PV_Internal.FallRequest := NOT PV_Internal.RiseRequest;

PV_Internal.OnDelayTimer(IN := (PV_Input.Enable AND PV_Internal.RiseRequest), PT := PV_Output.OnDelay_Effective);
PV_Internal.OffDelayTimer(IN := (PV_Input.Enable AND PV_Internal.FallRequest), PT := PV_Output.OffDelay_Effective);

IF NOT PV_Input.Enable THEN
	PV_Output.CmdDelayed := PV_Constant.PCT_MIN;
ELSIF PV_Internal.RiseRequest THEN
	IF (PV_Output.OnDelay_Effective <= T#0ms) OR PV_Internal.OnDelayTimer.Q THEN
		PV_Output.CmdDelayed := PV_Output.CmdLimited;
	ELSE
		PV_Output.CmdDelayed := PV_Output.OutMin_Effective;
	END_IF;
ELSE
	IF (PV_Output.OffDelay_Effective <= T#0ms) OR PV_Internal.OffDelayTimer.Q THEN
		PV_Output.CmdDelayed := PV_Output.OutMin_Effective;
	ELSE
		PV_Output.CmdDelayed := PV_Internal.CmdWorking;
	END_IF;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 6) Fault reakcija i force/hold ponasanje                                    *)
(* -------------------------------------------------------------------------- *)
IF NOT PV_Input.Enable THEN
	PV_Output.CmdDelayed := PV_Constant.PCT_MIN;
	PV_Output.ForceActive := FALSE;
ELSIF PV_Output.FaultActive THEN
	IF PV_Input.ForceCmd THEN
		PV_Output.ForceActive := TRUE;
	ELSE
		PV_Output.ForceActive := FALSE;
		IF PV_Param.HoldOnFault THEN
			PV_Output.CmdDelayed := PV_Internal.LastHealthyCmd;
		ELSE
			PV_Output.CmdDelayed := PV_Output.OutMin_Effective;
		END_IF;
	END_IF;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 7) Ramp limit komande (po ciklusu)                                          *)
(* -------------------------------------------------------------------------- *)
IF NOT PV_Input.Enable THEN
	PV_Internal.CmdWorking := PV_Constant.PCT_MIN;
ELSE
	IF PV_Output.CmdDelayed > PV_Internal.CmdWorking THEN
		PV_Internal.CmdWorking := PV_Internal.CmdWorking + PV_Output.RampUp_Effective;
		IF PV_Internal.CmdWorking > PV_Output.CmdDelayed THEN
			PV_Internal.CmdWorking := PV_Output.CmdDelayed;
		END_IF;
	ELSIF PV_Output.CmdDelayed < PV_Internal.CmdWorking THEN
		PV_Internal.CmdWorking := PV_Internal.CmdWorking - PV_Output.RampDown_Effective;
		IF PV_Internal.CmdWorking < PV_Output.CmdDelayed THEN
			PV_Internal.CmdWorking := PV_Output.CmdDelayed;
		END_IF;
	END_IF;
END_IF;

IF PV_Internal.CmdWorking < PV_Constant.PCT_MIN THEN
	PV_Internal.CmdWorking := PV_Constant.PCT_MIN;
ELSIF PV_Internal.CmdWorking > PV_Constant.PCT_MAX THEN
	PV_Internal.CmdWorking := PV_Constant.PCT_MAX;
END_IF;

PV_Output.AO_Cmd := PV_Internal.CmdWorking;

IF PV_Input.Enable AND NOT PV_Output.FaultActive THEN
	PV_Internal.LastHealthyCmd := PV_Output.AO_Cmd;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 8) Standardni izlazi stanja                                                 *)
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
		PV_Output.State_comment := 'ST_FAULT_HOLD - fault aktivan, izlaz hold/zero';
	END_IF;
ELSIF PV_Output.ManualActive THEN
	PV_Output.Status := TRUE;
	PV_Output.State := PV_Constant.ST_MANUAL_ACTIVE;
	PV_Output.State_comment := 'ST_MANUAL_ACTIVE - manuelni rezim';
ELSE
	PV_Output.Status := TRUE;
	PV_Output.State := PV_Constant.ST_AUTO_ACTIVE;
	PV_Output.State_comment := 'ST_AUTO_ACTIVE - automatski rezim';
END_IF;

END_FUNCTION_BLOCK

