FUNCTION_BLOCK FB_HV_2LS (* Rucni ventil sa dva krajnja prekidaca *)

(* -------------------------------------------------------------------------- *)
(* 1) Sirovi DI uslovi i validnost polozaja                                   *)
(* -------------------------------------------------------------------------- *)
Internal.BothActiveRaw := HV_Input.CloseFb AND HV_Input.OpenFb;
Internal.TransitionRaw := (NOT HV_Input.CloseFb) AND (NOT HV_Input.OpenFb);

HV_Output.Closed := HV_Input.CloseFb AND (NOT HV_Input.OpenFb);
HV_Output.Opened := HV_Input.OpenFb AND (NOT HV_Input.CloseFb);
HV_Output.Intermediate := Internal.TransitionRaw;
HV_Output.FeedbackConflict := Internal.BothActiveRaw;
HV_Output.PositionValid := HV_Output.Opened XOR HV_Output.Closed;

(* -------------------------------------------------------------------------- *)
(* 2) Validacija parametara                                                   *)
(* -------------------------------------------------------------------------- *)
Internal.ConfigValid := TRUE;
Internal.ConfigFaultText := 'CONFIG_OK';

Cfg.T_OpenClose_Valid := HV_Param.TransitionMaxTime;
Cfg.T_BothActive_Valid := HV_Param.BothActiveFilterTime;

IF HV_Param.TransitionMaxTime <= T#0ms THEN
	Internal.ConfigValid := FALSE;
	Internal.ConfigFaultText := 'TransitionMaxTime mora biti vece od T#0ms';
	Cfg.T_OpenClose_Valid := T#10s;
END_IF;

IF HV_Param.BothActiveFilterTime < T#0ms THEN
	Internal.ConfigValid := FALSE;
	IF Internal.ConfigFaultText = 'CONFIG_OK' THEN
		Internal.ConfigFaultText := 'BothActiveFilterTime ne sme biti negativan';
	END_IF;
	Cfg.T_BothActive_Valid := T#500ms;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 3) Tajmeri uslova                                                           *)
(* -------------------------------------------------------------------------- *)
Internal.TonTransition.IN := HV_Input.Enable AND Internal.ConfigValid AND Internal.TransitionRaw;
Internal.TonTransition.PT := Cfg.T_OpenClose_Valid;

Internal.TonBothActive.IN := HV_Input.Enable AND Internal.ConfigValid AND Internal.BothActiveRaw;
Internal.TonBothActive.PT := Cfg.T_BothActive_Valid;

Internal.TonTransition();
Internal.TonBothActive();

(* -------------------------------------------------------------------------- *)
(* 4) Trenutni aktivni uslov (real-time)                                      *)
(* -------------------------------------------------------------------------- *)
Internal.ActiveConditionCode := Cfg.ACT_NONE;
Internal.FaultCondition := FALSE;

IF HV_Input.Enable THEN
	IF NOT Internal.ConfigValid THEN
		Internal.ActiveConditionCode := Cfg.ACT_CONFIG_INVALID;
		Internal.FaultCondition := TRUE;
	ELSIF Internal.TonBothActive.Q THEN
		Internal.ActiveConditionCode := Cfg.ACT_BOTH_ACTIVE;
		Internal.FaultCondition := TRUE;
	ELSIF Internal.TonTransition.Q THEN
		Internal.ActiveConditionCode := Cfg.ACT_TRANSITION_TIMEOUT;
		Internal.FaultCondition := TRUE;
	END_IF;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 5) Latch i reset politika                                                   *)
(* -------------------------------------------------------------------------- *)
IF HV_Input.Enable AND Internal.FaultCondition THEN
	IF NOT Internal.FaultLatched THEN
		CASE Internal.ActiveConditionCode OF
			1: Internal.FaultCode := Cfg.FLT_TRANSITION_TIMEOUT;
			2: Internal.FaultCode := Cfg.FLT_BOTH_ACTIVE;
			3: Internal.FaultCode := Cfg.FLT_CONFIG_INVALID;
		ELSE
			Internal.FaultCode := Cfg.FLT_NONE;
		END_CASE;
	END_IF;
	Internal.FaultLatched := TRUE;
END_IF;

Internal.ResetAllowed := HV_Input.Enable AND Internal.ConfigValid AND
	Internal.FaultLatched AND (NOT Internal.FaultCondition) AND HV_Output.PositionValid;

IF HV_Input.ResetAlarm AND Internal.ResetAllowed THEN
	Internal.FaultLatched := FALSE;
	Internal.FaultCode := Cfg.FLT_NONE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 6) State mapiranje                                                           *)
(* -------------------------------------------------------------------------- *)
IF NOT HV_Input.Enable THEN
	Internal.Step := Cfg.ST_DISABLED;
ELSIF Internal.BothActiveRaw THEN
	(* Fizicki konflikt se prikazuje odmah; alarm je debounced preko TonBothActive. *)
	Internal.Step := Cfg.ST_FLT_BOTH_ACTIVE;
ELSIF Internal.TransitionRaw THEN
	IF Internal.TonTransition.Q THEN
		Internal.Step := Cfg.ST_FLT_TRANSITION_TIMEOUT;
	ELSE
		Internal.Step := Cfg.ST_TRANSITION;
	END_IF;
ELSIF HV_Output.Closed THEN
	Internal.Step := Cfg.ST_CLOSED;
ELSIF HV_Output.Opened THEN
	Internal.Step := Cfg.ST_OPEN;
ELSE
	Internal.Step := Cfg.ST_TRANSITION;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 7) Tekstovi stanja i dijagnostike                                           *)
(* -------------------------------------------------------------------------- *)
CASE Internal.Step OF
	0: HV_Output.State_comment := 'Stanje 0: Blok neaktivan';
	1: HV_Output.State_comment := 'Stanje 1: Ventil zatvoren';
	2: HV_Output.State_comment := 'Stanje 2: Ventil otvoren';
	3: HV_Output.State_comment := 'Stanje 3: Ventil u medjupolozaju';
	4: HV_Output.State_comment := 'Stanje 4: Medjupolozaj traje predugo';
	5: HV_Output.State_comment := 'Stanje 5: Oba krajnja signala aktivna';
ELSE
	HV_Output.State_comment := 'Stanje ?: Nepoznato stanje';
END_CASE;

CASE Internal.FaultCode OF
	0: HV_Output.FaultText := 'FLT_NONE - nema memorisanog alarma';
	1: HV_Output.FaultText := 'FLT_TRANSITION_TIMEOUT - medjupolozaj predugo traje';
	2: HV_Output.FaultText := 'FLT_BOTH_ACTIVE - oba krajnja prekidaca su aktivna';
	3: HV_Output.FaultText := 'FLT_CONFIG_INVALID - nevalidna konfiguracija parametara';
ELSE
	HV_Output.FaultText := 'FLT_UNKNOWN - nepoznat memorisani kod';
END_CASE;

IF NOT HV_Input.Enable THEN
	HV_Output.Diag := 'DISABLED';
ELSIF NOT Internal.ConfigValid THEN
	HV_Output.Diag := 'CONFIG_INVALID';
ELSIF Internal.ActiveConditionCode = Cfg.ACT_BOTH_ACTIVE THEN
	HV_Output.Diag := 'BOTH_ACTIVE_ALARM';
ELSIF Internal.ActiveConditionCode = Cfg.ACT_TRANSITION_TIMEOUT THEN
	HV_Output.Diag := 'TRANSITION_TIMEOUT_ALARM';
ELSIF Internal.FaultLatched THEN
	HV_Output.Diag := 'ALARM_LATCHED_WAIT_RESET';
ELSIF Internal.BothActiveRaw THEN
	HV_Output.Diag := 'BOTH_ACTIVE_PENDING';
ELSIF Internal.TransitionRaw THEN
	HV_Output.Diag := 'TRANSITION_TIMING';
ELSIF HV_Output.Closed THEN
	HV_Output.Diag := 'READY_CLOSED';
ELSIF HV_Output.Opened THEN
	HV_Output.Diag := 'READY_OPEN';
ELSE
	HV_Output.Diag := 'STATE_UNDEFINED';
END_IF;

(* -------------------------------------------------------------------------- *)
(* 8) Izlazi                                                                    *)
(* -------------------------------------------------------------------------- *)
HV_Output.Status := HV_Input.Enable AND Internal.ConfigValid;
HV_Output.State := Internal.Step;
HV_Output.AlarmActive := Internal.FaultCondition;
HV_Output.AlarmLatched := Internal.FaultLatched;
HV_Output.FaultCode := Internal.FaultCode;
HV_Output.ActiveConditionCode := Internal.ActiveConditionCode;
HV_Output.ConfigValid := Internal.ConfigValid;
HV_Output.ConfigFaultText := Internal.ConfigFaultText;
HV_Output.ResetAllowed := Internal.ResetAllowed;

END_FUNCTION_BLOCK