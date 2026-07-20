FUNCTION_BLOCK FB_V_ON_OFF_FB (* Jednokalemni pneumatski ON/OFF ventil *)

(* -------------------------------------------------------------------------- *)
(* 1) Validacija parametara                                                   *)
(* -------------------------------------------------------------------------- *)
Cfg.OpenMinTime_Valid := V_Param.OpenMinTime;
Cfg.OpenMaxTime_Valid := V_Param.OpenMaxTime;
Cfg.CloseMinTime_Valid := V_Param.CloseMinTime;
Cfg.CloseMaxTime_Valid := V_Param.CloseMaxTime;
Cfg.StableFbDelay_Valid := V_Param.StableFbDelay;

V_Output.ConfigFaultText := 'CONFIG_OK';

IF V_Param.OpenMaxTime <= T#0ms THEN
	Cfg.OpenMaxTime_Valid := T#1s;
	V_Output.ConfigFaultText := 'OpenMaxTime mora biti veci od T#0ms';
ELSIF V_Param.CloseMaxTime <= T#0ms THEN
	Cfg.CloseMaxTime_Valid := T#1s;
	V_Output.ConfigFaultText := 'CloseMaxTime mora biti veci od T#0ms';
ELSIF V_Param.OpenMaxTime < V_Param.OpenMinTime THEN
	Cfg.OpenMaxTime_Valid := Cfg.OpenMinTime_Valid;
	V_Output.ConfigFaultText := 'OpenMaxTime mora biti veci ili jednak OpenMinTime';
ELSIF V_Param.CloseMaxTime < V_Param.CloseMinTime THEN
	Cfg.CloseMaxTime_Valid := Cfg.CloseMinTime_Valid;
	V_Output.ConfigFaultText := 'CloseMaxTime mora biti veci ili jednak CloseMinTime';
END_IF;

IF Cfg.StableFbDelay_Valid < T#0ms THEN
	Cfg.StableFbDelay_Valid := T#0ms;
	V_Output.ConfigFaultText := 'StableFbDelay ne sme biti negativan';
END_IF;

(* -------------------------------------------------------------------------- *)
(* 2) Izbor zahteva i konverzija na komandu kalema                            *)
(* -------------------------------------------------------------------------- *)
IF V_Input.EnableManual THEN
	Internal.DesiredOpen := V_Input.Open_Manual;
ELSE
	Internal.DesiredOpen := Open;
END_IF;

(* NC: energizacija otvara. NO: energizacija zatvara. *)
Internal.CmdRequest := Internal.DesiredOpen XOR V_Param.DeEnergizedOpen;

(* -------------------------------------------------------------------------- *)
(* 3) Fizicke potvrde i memorija pretpostavljenog polozaja                     *)
(* -------------------------------------------------------------------------- *)
IF V_Param.FbOpenExists AND V_Param.FbCloseExists THEN
	Internal.OpenConfirm := V_Input.OpenFb AND NOT V_Input.CloseFb;
	Internal.CloseConfirm := V_Input.CloseFb AND NOT V_Input.OpenFb;
ELSIF V_Param.FbOpenExists THEN
	Internal.OpenConfirm := V_Input.OpenFb;
	Internal.CloseConfirm := FALSE;
ELSIF V_Param.FbCloseExists THEN
	Internal.OpenConfirm := FALSE;
	Internal.CloseConfirm := V_Input.CloseFb;
ELSE
	Internal.OpenConfirm := FALSE;
	Internal.CloseConfirm := FALSE;
END_IF;

IF V_Param.FbOpenExists THEN
	Internal.OpenAssumed := FALSE;
END_IF;
IF V_Param.FbCloseExists THEN
	Internal.CloseAssumed := FALSE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 4) Tajmeri tranzicije, merenja i stabilnog feedback-a                      *)
(* -------------------------------------------------------------------------- *)
Internal.OpenMinTimer.IN := Internal.Step = Cfg.ST_OPENING;
Internal.OpenMinTimer.PT := Cfg.OpenMinTime_Valid;
Internal.OpenMaxTimer.IN := Internal.Step = Cfg.ST_OPENING;
Internal.OpenMaxTimer.PT := Cfg.OpenMaxTime_Valid;
Internal.OpenMeasureTimer.IN := Internal.Step = Cfg.ST_OPENING;
Internal.OpenMeasureTimer.PT := T#24d;

Internal.CloseMinTimer.IN := Internal.Step = Cfg.ST_CLOSING;
Internal.CloseMinTimer.PT := Cfg.CloseMinTime_Valid;
Internal.CloseMaxTimer.IN := Internal.Step = Cfg.ST_CLOSING;
Internal.CloseMaxTimer.PT := Cfg.CloseMaxTime_Valid;
Internal.CloseMeasureTimer.IN := Internal.Step = Cfg.ST_CLOSING;
Internal.CloseMeasureTimer.PT := T#24d;

Internal.StableOpenedFbTimer.IN := V_Param.FbOpenExists AND
	(Internal.Step = Cfg.ST_IDLE_OPENED) AND Internal.DesiredOpen AND
	(NOT Internal.OpenConfirm);
Internal.StableOpenedFbTimer.PT := Cfg.StableFbDelay_Valid;

Internal.StableClosedFbTimer.IN := V_Param.FbCloseExists AND
	(Internal.Step = Cfg.ST_IDLE_CLOSED) AND (NOT Internal.DesiredOpen) AND
	(NOT Internal.CloseConfirm);
Internal.StableClosedFbTimer.PT := Cfg.StableFbDelay_Valid;

Internal.OpenMinTimer();
Internal.OpenMaxTimer();
Internal.OpenMeasureTimer();
Internal.CloseMinTimer();
Internal.CloseMaxTimer();
Internal.CloseMeasureTimer();
Internal.StableOpenedFbTimer();
Internal.StableClosedFbTimer();

(* -------------------------------------------------------------------------- *)
(* 5) Blokirajuci fault i neblokirajuci feedback alarm                        *)
(* -------------------------------------------------------------------------- *)
Internal.FaultCondition := FALSE;

IF V_Input.ManualAlarm THEN
	Internal.FaultCondition := TRUE;
	Internal.FaultCode := Cfg.FLT_MANUAL_ALARM;
END_IF;

IF V_Param.FbOpenExists AND V_Param.FbCloseExists AND
	V_Input.OpenFb AND V_Input.CloseFb THEN
	Internal.FaultCondition := TRUE;
	Internal.FaultCode := Cfg.FLT_FB_CONFLICT;
END_IF;

IF V_Output.ConfigFaultText <> 'CONFIG_OK' THEN
	Internal.FaultCondition := TRUE;
	Internal.FaultCode := Cfg.FLT_TIME_CONFIG_INVALID;
END_IF;

IF Internal.FaultCondition THEN
	Internal.FaultLatched := TRUE;
	IF V_Input.EnableManual THEN
		Internal.FaultInManual := TRUE;
	END_IF;
END_IF;

Internal.StableOpenedFbError := Internal.StableOpenedFbTimer.Q;
Internal.StableClosedFbError := Internal.StableClosedFbTimer.Q;
Internal.FeedbackAlarmCondition := Internal.StableOpenedFbError OR Internal.StableClosedFbError;

IF Internal.StableOpenedFbError THEN
	Internal.FeedbackAlarmLatched := TRUE;
	Internal.FeedbackAlarmCode := Cfg.FB_ALM_STABLE_OPEN_LOST;
ELSIF Internal.StableClosedFbError THEN
	Internal.FeedbackAlarmLatched := TRUE;
	Internal.FeedbackAlarmCode := Cfg.FB_ALM_STABLE_CLOSE_LOST;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 6) Reset, Stop i Enable politika                                            *)
(* -------------------------------------------------------------------------- *)
IF V_Input.ResetAlarm THEN
	IF Internal.FaultLatched AND (NOT Internal.FaultCondition) THEN
		Internal.FaultLatched := FALSE;
		Internal.FaultInManual := FALSE;
		Internal.FaultCode := Cfg.FLT_NONE;
		Internal.ReEnableRequired := TRUE;
	END_IF;

	IF Internal.FeedbackAlarmLatched AND (NOT Internal.FeedbackAlarmCondition) THEN
		Internal.FeedbackAlarmLatched := FALSE;
		Internal.FeedbackAlarmCode := Cfg.FB_ALM_NONE;
	END_IF;
END_IF;

IF V_Input.Stop THEN
	Internal.ReEnableRequired := TRUE;
	Internal.Step := Cfg.ST_STOPPED;
ELSIF NOT V_Input.Enable THEN
	Internal.ReEnableRequired := FALSE;
	Internal.Step := Cfg.ST_DISABLED;
ELSIF Internal.FaultLatched THEN
	Internal.Step := Cfg.ST_FAULT;
ELSIF Internal.ReEnableRequired THEN
	Internal.Step := Cfg.ST_WAIT_REENABLE;
ELSIF (NOT Internal.PrevEnable) AND V_Input.Enable THEN
	(* Na prvom Enable-u izvrsava se aktuelni auto/manual zahtev. *)
	IF Internal.DesiredOpen AND Internal.OpenConfirm THEN
		Internal.Step := Cfg.ST_IDLE_OPENED;
	ELSIF (NOT Internal.DesiredOpen) AND Internal.CloseConfirm THEN
		Internal.Step := Cfg.ST_IDLE_CLOSED;
	ELSIF Internal.DesiredOpen THEN
		Internal.Step := Cfg.ST_OPENING;
		Internal.OpenAssumed := FALSE;
	ELSE
		Internal.Step := Cfg.ST_CLOSING;
		Internal.CloseAssumed := FALSE;
	END_IF;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 7) State machine jednokalemnog ventila                                     *)
(* -------------------------------------------------------------------------- *)
CASE Internal.Step OF
	0: (* ST_DISABLED *)
		;

	10: (* ST_IDLE_CLOSED *)
		IF Internal.DesiredOpen THEN
			Internal.Step := Cfg.ST_OPENING;
			Internal.OpenAssumed := FALSE;
			Internal.CloseAssumed := FALSE;
		END_IF;

	20: (* ST_IDLE_OPENED *)
		IF NOT Internal.DesiredOpen THEN
			Internal.Step := Cfg.ST_CLOSING;
			Internal.OpenAssumed := FALSE;
			Internal.CloseAssumed := FALSE;
		END_IF;

	30: (* ST_OPENING *)
		IF NOT Internal.DesiredOpen THEN
			Internal.Step := Cfg.ST_CLOSING;
			Internal.OpenAssumed := FALSE;
			Internal.CloseAssumed := FALSE;
		ELSIF V_Param.FbOpenExists AND Internal.OpenConfirm THEN
			IF (V_Param.OpenMinTime = T#0ms) OR Internal.OpenMinTimer.Q THEN
				Internal.Step := Cfg.ST_IDLE_OPENED;
				V_Output.LastOpenTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenMeasureTimer.ET)) / 1000.0;
			ELSE
				Internal.FaultCondition := TRUE;
				Internal.FaultLatched := TRUE;
				Internal.FaultCode := Cfg.FLT_OPEN_TOO_FAST;
				Internal.Step := Cfg.ST_FAULT;
			END_IF;
		ELSIF V_Param.FbOpenExists AND Internal.OpenMaxTimer.Q THEN
			Internal.FaultCondition := TRUE;
			Internal.FaultLatched := TRUE;
			Internal.FaultCode := Cfg.FLT_OPEN_TIMEOUT;
			Internal.Step := Cfg.ST_FAULT;
		ELSIF (NOT V_Param.FbOpenExists) AND Internal.OpenMaxTimer.Q THEN
			Internal.OpenAssumed := TRUE;
			Internal.CloseAssumed := FALSE;
			V_Output.LastOpenTime := 0.0;
			Internal.Step := Cfg.ST_IDLE_OPENED;
		END_IF;

		IF V_Param.FbCloseExists AND Internal.PrevCloseFb AND (NOT V_Input.CloseFb) THEN
			V_Output.LastOpenStartTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenMeasureTimer.ET)) / 1000.0;
		ELSIF NOT V_Param.FbCloseExists THEN
			V_Output.LastOpenStartTime := 0.0;
		END_IF;

	40: (* ST_CLOSING *)
		IF Internal.DesiredOpen THEN
			Internal.Step := Cfg.ST_OPENING;
			Internal.OpenAssumed := FALSE;
			Internal.CloseAssumed := FALSE;
		ELSIF V_Param.FbCloseExists AND Internal.CloseConfirm THEN
			IF (V_Param.CloseMinTime = T#0ms) OR Internal.CloseMinTimer.Q THEN
				Internal.Step := Cfg.ST_IDLE_CLOSED;
				V_Output.LastCloseTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseMeasureTimer.ET)) / 1000.0;
			ELSE
				Internal.FaultCondition := TRUE;
				Internal.FaultLatched := TRUE;
				Internal.FaultCode := Cfg.FLT_CLOSE_TOO_FAST;
				Internal.Step := Cfg.ST_FAULT;
			END_IF;
		ELSIF V_Param.FbCloseExists AND Internal.CloseMaxTimer.Q THEN
			Internal.FaultCondition := TRUE;
			Internal.FaultLatched := TRUE;
			Internal.FaultCode := Cfg.FLT_CLOSE_TIMEOUT;
			Internal.Step := Cfg.ST_FAULT;
		ELSIF (NOT V_Param.FbCloseExists) AND Internal.CloseMaxTimer.Q THEN
			Internal.OpenAssumed := FALSE;
			Internal.CloseAssumed := TRUE;
			V_Output.LastCloseTime := 0.0;
			Internal.Step := Cfg.ST_IDLE_CLOSED;
		END_IF;

		IF V_Param.FbOpenExists AND Internal.PrevOpenFb AND (NOT V_Input.OpenFb) THEN
			V_Output.LastCloseStartTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseMeasureTimer.ET)) / 1000.0;
		ELSIF NOT V_Param.FbOpenExists THEN
			V_Output.LastCloseStartTime := 0.0;
		END_IF;

	50: (* ST_STOPPED *)
		;

	60: (* ST_WAIT_REENABLE *)
		;

	90: (* ST_FAULT *)
		;

ELSE
	Internal.FaultCondition := TRUE;
	Internal.FaultLatched := TRUE;
	Internal.FaultCode := Cfg.FLT_FB_CONFLICT;
	Internal.Step := Cfg.ST_FAULT;
END_CASE;

(* -------------------------------------------------------------------------- *)
(* 8) Zavrsna bezbednosna primena komande                                     *)
(* -------------------------------------------------------------------------- *)
V_Output.Cmd := FALSE;

IF V_Input.Enable AND (NOT V_Input.Stop) AND
	(V_Output.ConfigFaultText = 'CONFIG_OK') AND (NOT Internal.ReEnableRequired) THEN
	IF Internal.FaultLatched THEN
		IF V_Input.ForceCmd THEN
			V_Output.Cmd := Internal.CmdRequest;
		END_IF;
	ELSE
		V_Output.Cmd := Internal.CmdRequest;
	END_IF;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 9) State, fault i alarm tekstovi                                            *)
(* -------------------------------------------------------------------------- *)
CASE Internal.Step OF
	0: V_Output.State_comment := 'ST_DISABLED - FB nije omogucen';
	10: V_Output.State_comment := 'ST_IDLE_CLOSED - ventil je zatvoren';
	20: V_Output.State_comment := 'ST_IDLE_OPENED - ventil je otvoren';
	30: V_Output.State_comment := 'ST_OPENING - ventil ide ka otvorenom';
	40: V_Output.State_comment := 'ST_CLOSING - ventil ide ka zatvorenom';
	50: V_Output.State_comment := 'ST_STOPPED - operativni Stop je aktivan';
	60: V_Output.State_comment := 'ST_WAIT_REENABLE - potreban novi Enable ciklus';
	90: V_Output.State_comment := 'ST_FAULT - blokirajuci fault je aktivan';
ELSE
	V_Output.State_comment := 'ST_UNKNOWN - nepoznato stanje';
END_CASE;

CASE Internal.FaultCode OF
	0: Internal.FaultText := 'FLT_NONE - nema blokirajuceg fault-a';
	1: Internal.FaultText := 'FLT_MANUAL_ALARM - spoljni alarm je aktivan';
	2: Internal.FaultText := 'FLT_FB_CONFLICT - oba feedback-a su aktivna';
	3: Internal.FaultText := 'FLT_OPEN_TIMEOUT - nema OpenFb potvrde';
	4: Internal.FaultText := 'FLT_OPEN_TOO_FAST - OpenFb je stigao prerano';
	5: Internal.FaultText := 'FLT_CLOSE_TIMEOUT - nema CloseFb potvrde';
	6: Internal.FaultText := 'FLT_CLOSE_TOO_FAST - CloseFb je stigao prerano';
	9: Internal.FaultText := 'FLT_TIME_CONFIG_INVALID - nevalidni vremenski parametri';
ELSE
	Internal.FaultText := 'FLT_UNKNOWN - nepoznat uzrok fault-a';
END_CASE;

CASE Internal.FeedbackAlarmCode OF
	0: V_Output.FeedbackAlarmText := 'FB_ALM_NONE - nema feedback alarma';
	1: V_Output.FeedbackAlarmText := 'FB_ALM_STABLE_OPEN_LOST - proveriti OpenFb senzor';
	2: V_Output.FeedbackAlarmText := 'FB_ALM_STABLE_CLOSE_LOST - proveriti CloseFb senzor';
ELSE
	V_Output.FeedbackAlarmText := 'FB_ALM_UNKNOWN - nepoznat feedback alarm';
END_CASE;

IF Internal.FaultLatched THEN
	IF V_Input.ForceCmd AND (NOT V_Input.Stop) AND
		(V_Output.ConfigFaultText = 'CONFIG_OK') THEN
		V_Output.Diag := 'FAULT_FORCE_ACTIVE';
	ELSE
		V_Output.Diag := 'FAULT_BLOCKING_COMMAND';
	END_IF;
ELSIF Internal.FeedbackAlarmLatched THEN
	V_Output.Diag := 'FEEDBACK_ALARM_NONBLOCKING';
ELSIF Internal.Step = Cfg.ST_WAIT_REENABLE THEN
	V_Output.Diag := 'WAIT_REENABLE';
ELSIF Internal.Step = Cfg.ST_STOPPED THEN
	V_Output.Diag := 'STOP_ACTIVE';
ELSIF (Internal.Step = Cfg.ST_OPENING) OR (Internal.Step = Cfg.ST_CLOSING) THEN
	V_Output.Diag := 'IN_TRANSITION';
ELSE
	V_Output.Diag := 'READY';
END_IF;

(* -------------------------------------------------------------------------- *)
(* 10) Zavrsno mapiranje izlaza i memorije prethodnog ciklusa                  *)
(* -------------------------------------------------------------------------- *)
V_Output.Opened := Internal.OpenConfirm OR Internal.OpenAssumed;
V_Output.Closed := Internal.CloseConfirm OR Internal.CloseAssumed;
V_Output.OpenAssumed := Internal.OpenAssumed;
V_Output.CloseAssumed := Internal.CloseAssumed;
V_Output.PositionConfirmed := Internal.OpenConfirm OR Internal.CloseConfirm;
V_Output.PositionAssumed := Internal.OpenAssumed OR Internal.CloseAssumed;
V_Output.Status := V_Input.Enable AND (NOT V_Input.Stop) AND
	(NOT Internal.FaultLatched) AND (NOT Internal.ReEnableRequired);
V_Output.InTransition := (Internal.Step = Cfg.ST_OPENING) OR (Internal.Step = Cfg.ST_CLOSING);
V_Output.StopActive := V_Input.Stop;
V_Output.WaitingReEnable := Internal.Step = Cfg.ST_WAIT_REENABLE;
V_Output.ResetAllowed := (Internal.FaultLatched AND (NOT Internal.FaultCondition)) OR
	(Internal.FeedbackAlarmLatched AND (NOT Internal.FeedbackAlarmCondition));
V_Output.State := Internal.Step;
V_Output.FaultLatched := Internal.FaultLatched;
V_Output.FaultCondition := Internal.FaultCondition;
V_Output.FaultInManual := Internal.FaultInManual;
V_Output.FaultCode := Internal.FaultCode;
V_Output.FaultText := Internal.FaultText;
V_Output.ForceActive := Internal.FaultLatched AND V_Input.ForceCmd AND
	V_Input.Enable AND (NOT V_Input.Stop) AND
	(V_Output.ConfigFaultText = 'CONFIG_OK');
V_Output.FeedbackAlarmCondition := Internal.FeedbackAlarmCondition;
V_Output.FeedbackAlarmLatched := Internal.FeedbackAlarmLatched;
V_Output.FeedbackAlarmCode := Internal.FeedbackAlarmCode;

Opened := V_Output.Opened;
Closed := V_Output.Closed;

Internal.PrevEnable := V_Input.Enable;
Internal.PrevCloseFb := V_Input.CloseFb;
Internal.PrevOpenFb := V_Input.OpenFb;

END_FUNCTION_BLOCK