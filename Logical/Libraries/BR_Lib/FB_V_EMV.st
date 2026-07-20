FUNCTION_BLOCK FB_V_EMV (* Elektromotorni ventil sa odvojenim OPEN/CLOSE komandama *)

(* -------------------------------------------------------------------------- *)
(* 1) Podrazumevane vrednosti i izbor aktivnog zahteva                       *)
(* -------------------------------------------------------------------------- *)
V_Output.CmdOpen := FALSE;
V_Output.CmdClose := FALSE;

IF V_Input.EnableManual THEN
	Internal.DesiredOpen := V_Input.OpenManual;
ELSE
	Internal.DesiredOpen := Open;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 2) Validacija parametara                                                   *)
(* -------------------------------------------------------------------------- *)
Cfg.OpenMaxTimeValid := V_Param.OpenMaxTime;
Cfg.CloseMaxTimeValid := V_Param.CloseMaxTime;
Cfg.DeadTimeValid := V_Param.DeadTime;
Cfg.EndLimitFilterTimeValid := V_Param.EndLimitFilterTime;
Cfg.PositionFbFilterTimeValid := V_Param.PositionFbFilterTime;
Cfg.OverTorqueFilterTimeValid := V_Param.OverTorqueFilterTime;
Cfg.PositionConfirmTimeValid := V_Param.PositionConfirmTime;
Cfg.StableFbLossTimeValid := V_Param.StableFbLossTime;

Internal.ConfigValid := TRUE;
Internal.ConfigFaultText := 'CONFIG_OK - parametri su validni';

IF V_Param.OpenMaxTime <= T#0ms THEN
	Internal.ConfigValid := FALSE;
	Internal.ConfigFaultText := 'OpenMaxTime mora biti vece od T#0ms';
ELSIF V_Param.CloseMaxTime <= T#0ms THEN
	Internal.ConfigValid := FALSE;
	Internal.ConfigFaultText := 'CloseMaxTime mora biti vece od T#0ms';
ELSIF V_Param.DeadTime < T#500ms THEN
	Internal.ConfigValid := FALSE;
	Internal.ConfigFaultText := 'DeadTime mora biti najmanje T#500ms';
ELSIF V_Param.EndLimitFilterTime < T#0ms THEN
	Internal.ConfigValid := FALSE;
	Internal.ConfigFaultText := 'EndLimitFilterTime ne sme biti negativan';
ELSIF V_Param.PositionFbFilterTime < T#0ms THEN
	Internal.ConfigValid := FALSE;
	Internal.ConfigFaultText := 'PositionFbFilterTime ne sme biti negativan';
ELSIF V_Param.OverTorqueFilterTime < T#0ms THEN
	Internal.ConfigValid := FALSE;
	Internal.ConfigFaultText := 'OverTorqueFilterTime ne sme biti negativan';
ELSIF V_Param.PositionConfirmTime <= T#0ms AND
	((V_Param.LampOpenExists AND V_Param.OpenFbExists) OR
	(V_Param.LampCloseExists AND V_Param.CloseFbExists)) THEN
	Internal.ConfigValid := FALSE;
	Internal.ConfigFaultText := 'PositionConfirmTime mora biti vece od T#0ms';
ELSIF V_Param.StableFbLossTime < T#0ms THEN
	Internal.ConfigValid := FALSE;
	Internal.ConfigFaultText := 'StableFbLossTime ne sme biti negativan';
END_IF;

(* -------------------------------------------------------------------------- *)
(* 3) Filtracija fizickih ulaza                                               *)
(* -------------------------------------------------------------------------- *)
IF V_Param.LampOpenExists THEN
	Internal.LampOpenFilterTimer.IN := (V_Input.LampOpen <> Internal.LampOpenStable);
	Internal.LampOpenFilterTimer.PT := Cfg.EndLimitFilterTimeValid;
	Internal.LampOpenFilterTimer();
	IF Internal.LampOpenFilterTimer.Q THEN
		Internal.LampOpenStable := V_Input.LampOpen;
	END_IF;
ELSE
	Internal.LampOpenFilterTimer.IN := FALSE;
	Internal.LampOpenFilterTimer();
	Internal.LampOpenStable := FALSE;
END_IF;

IF V_Param.LampCloseExists THEN
	Internal.LampCloseFilterTimer.IN := (V_Input.LampClose <> Internal.LampCloseStable);
	Internal.LampCloseFilterTimer.PT := Cfg.EndLimitFilterTimeValid;
	Internal.LampCloseFilterTimer();
	IF Internal.LampCloseFilterTimer.Q THEN
		Internal.LampCloseStable := V_Input.LampClose;
	END_IF;
ELSE
	Internal.LampCloseFilterTimer.IN := FALSE;
	Internal.LampCloseFilterTimer();
	Internal.LampCloseStable := FALSE;
END_IF;

IF V_Param.OpenFbExists THEN
	Internal.OpenFbFilterTimer.IN := (V_Input.OpenFb <> Internal.OpenFbStable);
	Internal.OpenFbFilterTimer.PT := Cfg.PositionFbFilterTimeValid;
	Internal.OpenFbFilterTimer();
	IF Internal.OpenFbFilterTimer.Q THEN
		Internal.OpenFbStable := V_Input.OpenFb;
	END_IF;
ELSE
	Internal.OpenFbFilterTimer.IN := FALSE;
	Internal.OpenFbFilterTimer();
	Internal.OpenFbStable := FALSE;
END_IF;

IF V_Param.CloseFbExists THEN
	Internal.CloseFbFilterTimer.IN := (V_Input.CloseFb <> Internal.CloseFbStable);
	Internal.CloseFbFilterTimer.PT := Cfg.PositionFbFilterTimeValid;
	Internal.CloseFbFilterTimer();
	IF Internal.CloseFbFilterTimer.Q THEN
		Internal.CloseFbStable := V_Input.CloseFb;
	END_IF;
ELSE
	Internal.CloseFbFilterTimer.IN := FALSE;
	Internal.CloseFbFilterTimer();
	Internal.CloseFbStable := FALSE;
END_IF;

IF V_Param.OverTorqueExists THEN
	Internal.OverTorqueFilterTimer.IN := V_Input.OverTorque;
	Internal.OverTorqueFilterTimer.PT := Cfg.OverTorqueFilterTimeValid;
	Internal.OverTorqueFilterTimer();
	Internal.OverTorqueStable := Internal.OverTorqueFilterTimer.Q;
ELSE
	Internal.OverTorqueFilterTimer.IN := FALSE;
	Internal.OverTorqueFilterTimer();
	Internal.OverTorqueStable := FALSE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 4) Tajmeri state machine                                                   *)
(* -------------------------------------------------------------------------- *)
Internal.InitSyncTimer.IN := (Internal.Step = Cfg.ST_INIT_SYNC);
Internal.InitSyncTimer.PT := Cfg.PositionFbFilterTimeValid;

Internal.DeadTimeTimer.IN := (Internal.Step = Cfg.ST_DIRECTION_DEADTIME) OR
	(Internal.Step = Cfg.ST_FORCE_DEADTIME);
Internal.DeadTimeTimer.PT := Cfg.DeadTimeValid;

Internal.OpenTravelTimer.IN := (Internal.Step = Cfg.ST_OPENING) OR
	(Internal.Step = Cfg.ST_FORCE_OPENING);
Internal.OpenTravelTimer.PT := Cfg.OpenMaxTimeValid;

Internal.CloseTravelTimer.IN := (Internal.Step = Cfg.ST_CLOSING) OR
	(Internal.Step = Cfg.ST_FORCE_CLOSING);
Internal.CloseTravelTimer.PT := Cfg.CloseMaxTimeValid;

Internal.OpenConfirmTimer.IN := (Internal.Step = Cfg.ST_WAIT_OPEN_CONFIRM) OR
	(Internal.Step = Cfg.ST_FORCE_WAIT_OPEN_CONFIRM);
Internal.OpenConfirmTimer.PT := Cfg.PositionConfirmTimeValid;

Internal.CloseConfirmTimer.IN := (Internal.Step = Cfg.ST_WAIT_CLOSE_CONFIRM) OR
	(Internal.Step = Cfg.ST_FORCE_WAIT_CLOSE_CONFIRM);
Internal.CloseConfirmTimer.PT := Cfg.PositionConfirmTimeValid;

Internal.StableOpenLossTimer.IN := V_Param.OpenFbExists AND
	(Internal.Step = Cfg.ST_IDLE_OPENED) AND (NOT Internal.OpenFbStable);
Internal.StableOpenLossTimer.PT := Cfg.StableFbLossTimeValid;

Internal.StableCloseLossTimer.IN := V_Param.CloseFbExists AND
	(Internal.Step = Cfg.ST_IDLE_CLOSED) AND (NOT Internal.CloseFbStable);
Internal.StableCloseLossTimer.PT := Cfg.StableFbLossTimeValid;

Internal.InitSyncTimer();
Internal.DeadTimeTimer();
Internal.OpenTravelTimer();
Internal.CloseTravelTimer();
Internal.OpenConfirmTimer();
Internal.CloseConfirmTimer();
Internal.StableOpenLossTimer();
Internal.StableCloseLossTimer();

(* -------------------------------------------------------------------------- *)
(* 5) Globalni fault uslovi                                                   *)
(* -------------------------------------------------------------------------- *)
Internal.FaultCondition := FALSE;

IF NOT Internal.ConfigValid THEN
	Internal.FaultCondition := TRUE;
	IF NOT Internal.FaultLatched THEN
		Internal.FaultCode := Cfg.FLT_INVALID_CONFIG;
		Internal.FaultDirection := Cfg.DIR_NONE;
	END_IF;
ELSIF V_Input.ManualAlarm THEN
	Internal.FaultCondition := TRUE;
	IF NOT Internal.FaultLatched THEN
		Internal.FaultCode := Cfg.FLT_MANUAL_ALARM;
		IF (Internal.Step = Cfg.ST_OPENING) OR (Internal.Step = Cfg.ST_FORCE_OPENING) THEN
			Internal.FaultDirection := Cfg.DIR_OPEN;
		ELSIF (Internal.Step = Cfg.ST_CLOSING) OR (Internal.Step = Cfg.ST_FORCE_CLOSING) THEN
			Internal.FaultDirection := Cfg.DIR_CLOSE;
		ELSE
			Internal.FaultDirection := Cfg.DIR_NONE;
		END_IF;
	END_IF;
ELSIF V_Param.OpenFbExists AND V_Param.CloseFbExists AND
	Internal.OpenFbStable AND Internal.CloseFbStable THEN
	Internal.FaultCondition := TRUE;
	IF NOT Internal.FaultLatched THEN
		Internal.FaultCode := Cfg.FLT_POSITION_CONFLICT;
		Internal.FaultDirection := Cfg.DIR_NONE;
	END_IF;
ELSIF V_Param.OverTorqueExists AND Internal.OverTorqueStable AND
	((Internal.Step = Cfg.ST_OPENING) OR (Internal.Step = Cfg.ST_CLOSING) OR
	(Internal.Step = Cfg.ST_FORCE_OPENING) OR (Internal.Step = Cfg.ST_FORCE_CLOSING)) THEN
	Internal.FaultCondition := TRUE;
	IF NOT Internal.FaultLatched THEN
		Internal.FaultCode := Cfg.FLT_OVER_TORQUE;
		IF (Internal.Step = Cfg.ST_OPENING) OR (Internal.Step = Cfg.ST_FORCE_OPENING) THEN
			Internal.FaultDirection := Cfg.DIR_OPEN;
		ELSE
			Internal.FaultDirection := Cfg.DIR_CLOSE;
		END_IF;
	ELSE
		Internal.RecoveryFaultCode := Cfg.FLT_OVER_TORQUE;
		Internal.FaultInForce := TRUE;
	END_IF;
ELSIF V_Param.UnexpectedOpenLimitCheck AND V_Param.LampOpenExists AND
	Internal.LampOpenStable AND
	((Internal.Step = Cfg.ST_CLOSING) OR (Internal.Step = Cfg.ST_FORCE_CLOSING)) THEN
	Internal.FaultCondition := TRUE;
	IF NOT Internal.FaultLatched THEN
		Internal.FaultCode := Cfg.FLT_UNEXPECTED_OPEN_LIMIT;
		Internal.FaultDirection := Cfg.DIR_CLOSE;
	ELSE
		Internal.RecoveryFaultCode := Cfg.FLT_UNEXPECTED_OPEN_LIMIT;
		Internal.FaultInForce := TRUE;
	END_IF;
ELSIF V_Param.UnexpectedCloseLimitCheck AND V_Param.LampCloseExists AND
	Internal.LampCloseStable AND
	((Internal.Step = Cfg.ST_OPENING) OR (Internal.Step = Cfg.ST_FORCE_OPENING)) THEN
	Internal.FaultCondition := TRUE;
	IF NOT Internal.FaultLatched THEN
		Internal.FaultCode := Cfg.FLT_UNEXPECTED_CLOSE_LIMIT;
		Internal.FaultDirection := Cfg.DIR_OPEN;
	ELSE
		Internal.RecoveryFaultCode := Cfg.FLT_UNEXPECTED_CLOSE_LIMIT;
		Internal.FaultInForce := TRUE;
	END_IF;
ELSIF Internal.StableOpenLossTimer.Q THEN
	Internal.FaultCondition := TRUE;
	IF NOT Internal.FaultLatched THEN
		Internal.FaultCode := Cfg.FLT_OPEN_FB_LOST;
		Internal.FaultDirection := Cfg.DIR_OPEN;
	END_IF;
ELSIF Internal.StableCloseLossTimer.Q THEN
	Internal.FaultCondition := TRUE;
	IF NOT Internal.FaultLatched THEN
		Internal.FaultCode := Cfg.FLT_CLOSE_FB_LOST;
		Internal.FaultDirection := Cfg.DIR_CLOSE;
	END_IF;
END_IF;

IF Internal.FaultCondition THEN
	IF NOT Internal.FaultLatched THEN
		Internal.FaultLatched := TRUE;
		Internal.FaultInManual := V_Input.EnableManual;
	END_IF;
	Internal.Step := Cfg.ST_FAULT;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 6) Reset i prioritet Enable/Stop                                           *)
(* -------------------------------------------------------------------------- *)
V_Output.ResetAllowed := Internal.FaultLatched AND
	(NOT Internal.FaultCondition) AND
	(NOT V_Input.Stop) AND
	(NOT V_Input.ManualAlarm) AND
	(NOT Internal.OverTorqueStable) AND
	Internal.ConfigValid AND
	(NOT (Internal.OpenFbStable AND Internal.CloseFbStable));

IF V_Input.ResetAlarm AND V_Output.ResetAllowed THEN
	Internal.FaultLatched := FALSE;
	Internal.FaultCode := Cfg.FLT_NONE;
	Internal.FaultDirection := Cfg.DIR_NONE;
	Internal.FaultInManual := FALSE;
	Internal.FaultInForce := FALSE;
	Internal.RecoveryFaultCode := Cfg.FLT_NONE;
	IF V_Input.Enable THEN
		Internal.Step := Cfg.ST_WAIT_REENABLE;
	ELSE
		Internal.Step := Cfg.ST_DISABLED;
	END_IF;
ELSIF NOT V_Input.Enable THEN
	Internal.Step := Cfg.ST_DISABLED;
ELSIF Internal.FaultLatched AND
	(Internal.Step <> Cfg.ST_FORCE_DEADTIME) AND
	(Internal.Step <> Cfg.ST_FORCE_OPENING) AND
	(Internal.Step <> Cfg.ST_FORCE_CLOSING) AND
	(Internal.Step <> Cfg.ST_FORCE_WAIT_OPEN_CONFIRM) AND
	(Internal.Step <> Cfg.ST_FORCE_WAIT_CLOSE_CONFIRM) THEN
	Internal.Step := Cfg.ST_FAULT;
ELSIF V_Input.Stop AND (NOT Internal.FaultLatched) THEN
	Internal.Step := Cfg.ST_STOPPED;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 7) Force dozvola iz fault stanja                                           *)
(* -------------------------------------------------------------------------- *)
Internal.ForceDirection := Cfg.DIR_NONE;
IF Internal.FaultDirection = Cfg.DIR_OPEN THEN
	Internal.ForceDirection := Cfg.DIR_CLOSE;
ELSIF Internal.FaultDirection = Cfg.DIR_CLOSE THEN
	Internal.ForceDirection := Cfg.DIR_OPEN;
END_IF;

Internal.ForceRequested := V_Input.ForceCmd AND
	(NOT Internal.ForceRecoveryDone) AND
	(((Internal.ForceDirection = Cfg.DIR_OPEN) AND Internal.DesiredOpen) OR
	((Internal.ForceDirection = Cfg.DIR_CLOSE) AND (NOT Internal.DesiredOpen)));

IF NOT V_Input.ForceCmd THEN
	Internal.ForceRecoveryDone := FALSE;
END_IF;

Internal.ForceAllowed := Internal.FaultLatched AND V_Input.Enable AND
	(NOT V_Input.Stop) AND Internal.ConfigValid AND
	(NOT V_Input.ManualAlarm) AND (NOT Internal.OverTorqueStable) AND
	(NOT (Internal.OpenFbStable AND Internal.CloseFbStable)) AND
	(Internal.ForceDirection <> Cfg.DIR_NONE);

(* -------------------------------------------------------------------------- *)
(* 8) State machine                                                           *)
(* -------------------------------------------------------------------------- *)
CASE Internal.Step OF
	0: (* ST_DISABLED *)
		IF V_Input.Enable AND (NOT Internal.PrevEnable) THEN
			Internal.Step := Cfg.ST_INIT_SYNC;
		END_IF;

	5: (* ST_INIT_SYNC *)
		IF Internal.InitSyncTimer.Q THEN
			IF Internal.OpenFbStable AND (NOT Internal.CloseFbStable) THEN
				IF Internal.DesiredOpen THEN
					Internal.Step := Cfg.ST_IDLE_OPENED;
				ELSE
					Internal.NextDirection := Cfg.DIR_CLOSE;
					Internal.Step := Cfg.ST_DIRECTION_DEADTIME;
				END_IF;
			ELSIF Internal.CloseFbStable AND (NOT Internal.OpenFbStable) THEN
				IF NOT Internal.DesiredOpen THEN
					Internal.Step := Cfg.ST_IDLE_CLOSED;
				ELSE
					Internal.NextDirection := Cfg.DIR_OPEN;
					Internal.Step := Cfg.ST_DIRECTION_DEADTIME;
				END_IF;
			ELSE
				IF Internal.DesiredOpen THEN
					Internal.NextDirection := Cfg.DIR_OPEN;
				ELSE
					Internal.NextDirection := Cfg.DIR_CLOSE;
				END_IF;
				Internal.Step := Cfg.ST_DIRECTION_DEADTIME;
			END_IF;
		END_IF;

	10: (* ST_IDLE_CLOSED *)
		IF Internal.DesiredOpen THEN
			Internal.NextDirection := Cfg.DIR_OPEN;
			Internal.Step := Cfg.ST_DIRECTION_DEADTIME;
		END_IF;

	20: (* ST_IDLE_OPENED *)
		IF NOT Internal.DesiredOpen THEN
			Internal.NextDirection := Cfg.DIR_CLOSE;
			Internal.Step := Cfg.ST_DIRECTION_DEADTIME;
		END_IF;

	30: (* ST_IDLE_CLOSE_ASSUMED *)
		IF Internal.DesiredOpen THEN
			Internal.NextDirection := Cfg.DIR_OPEN;
			Internal.Step := Cfg.ST_DIRECTION_DEADTIME;
		END_IF;

	40: (* ST_IDLE_OPEN_ASSUMED *)
		IF NOT Internal.DesiredOpen THEN
			Internal.NextDirection := Cfg.DIR_CLOSE;
			Internal.Step := Cfg.ST_DIRECTION_DEADTIME;
		END_IF;

	50: (* ST_INTERMEDIATE *)
		IF Internal.DesiredOpen THEN
			Internal.NextDirection := Cfg.DIR_OPEN;
		ELSE
			Internal.NextDirection := Cfg.DIR_CLOSE;
		END_IF;
		Internal.Step := Cfg.ST_DIRECTION_DEADTIME;

	60: (* ST_DIRECTION_DEADTIME *)
		IF Internal.DesiredOpen THEN
			Internal.NextDirection := Cfg.DIR_OPEN;
		ELSE
			Internal.NextDirection := Cfg.DIR_CLOSE;
		END_IF;

		IF (Internal.NextDirection = Cfg.DIR_OPEN) AND Internal.OpenFbStable THEN
			Internal.Step := Cfg.ST_IDLE_OPENED;
		ELSIF (Internal.NextDirection = Cfg.DIR_CLOSE) AND Internal.CloseFbStable THEN
			Internal.Step := Cfg.ST_IDLE_CLOSED;
		ELSIF Internal.DeadTimeTimer.Q THEN
			IF Internal.NextDirection = Cfg.DIR_OPEN THEN
				Internal.OpenEndReached := FALSE;
				Internal.OpenFbSeen := FALSE;
				Internal.OpenLampSeen := FALSE;
				Internal.OpenStartMeasured := FALSE;
				V_Output.OpenFbOffsetValid := FALSE;
				Internal.PrevDirection := Cfg.DIR_OPEN;
				Internal.Step := Cfg.ST_OPENING;
			ELSE
				Internal.CloseEndReached := FALSE;
				Internal.CloseFbSeen := FALSE;
				Internal.CloseLampSeen := FALSE;
				Internal.CloseStartMeasured := FALSE;
				V_Output.CloseFbOffsetValid := FALSE;
				Internal.PrevDirection := Cfg.DIR_CLOSE;
				Internal.Step := Cfg.ST_CLOSING;
			END_IF;
		END_IF;

	70: (* ST_OPENING *)
		IF NOT Internal.DesiredOpen THEN
			Internal.NextDirection := Cfg.DIR_CLOSE;
			Internal.Step := Cfg.ST_DIRECTION_DEADTIME;
		ELSE
			IF V_Param.OpenFbExists AND V_Input.OpenFb AND (NOT Internal.PrevOpenFbRaw) AND
				(NOT Internal.OpenFbSeen) THEN
				Internal.OpenFbEventTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
			END_IF;
			IF V_Param.LampOpenExists AND V_Input.LampOpen AND (NOT Internal.PrevLampOpenRaw) AND
				(NOT Internal.OpenLampSeen) THEN
				Internal.OpenLampEventTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
			END_IF;

			IF V_Param.CloseFbExists AND Internal.PrevCloseFbStable AND
				(NOT Internal.CloseFbStable) AND (NOT Internal.OpenStartMeasured) THEN
				V_Output.LastOpenStartTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
				Internal.OpenStartMeasured := TRUE;
			END_IF;

			IF V_Param.OpenFbExists AND Internal.OpenFbStable AND (NOT Internal.OpenFbSeen) THEN
				V_Output.LastOpenFbTime := Internal.OpenFbEventTime;
				Internal.OpenFbSeen := TRUE;
			END_IF;

			IF V_Param.LampOpenExists AND Internal.LampOpenStable THEN
				V_Output.LastOpenTime := Internal.OpenLampEventTime;
				Internal.OpenLampSeen := TRUE;
				Internal.OpenEndReached := TRUE;
				IF Internal.OpenFbSeen THEN
					V_Output.LastOpenFbOffset := Internal.OpenFbEventTime - Internal.OpenLampEventTime;
					V_Output.OpenFbOffsetValid := TRUE;
					Internal.Step := Cfg.ST_IDLE_OPENED;
				ELSIF V_Param.OpenFbExists THEN
					Internal.Step := Cfg.ST_WAIT_OPEN_CONFIRM;
				ELSE
					Internal.Step := Cfg.ST_IDLE_OPEN_ASSUMED;
				END_IF;
			ELSIF (NOT V_Param.LampOpenExists) AND V_Param.OpenFbExists AND Internal.OpenFbStable THEN
				V_Output.LastOpenTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
				Internal.Step := Cfg.ST_IDLE_OPENED;
			ELSIF Internal.OpenTravelTimer.Q THEN
				IF V_Param.LampOpenExists OR V_Param.OpenFbExists THEN
					Internal.FaultCode := Cfg.FLT_OPEN_TIMEOUT;
					Internal.FaultDirection := Cfg.DIR_OPEN;
					Internal.FaultLatched := TRUE;
					Internal.FaultInManual := V_Input.EnableManual;
					Internal.Step := Cfg.ST_FAULT;
				ELSE
					V_Output.LastOpenTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
					Internal.Step := Cfg.ST_IDLE_OPEN_ASSUMED;
				END_IF;
			ELSE
				V_Output.CmdOpen := TRUE;
			END_IF;
		END_IF;

	80: (* ST_CLOSING *)
		IF Internal.DesiredOpen THEN
			Internal.NextDirection := Cfg.DIR_OPEN;
			Internal.Step := Cfg.ST_DIRECTION_DEADTIME;
		ELSE
			IF V_Param.CloseFbExists AND V_Input.CloseFb AND (NOT Internal.PrevCloseFbRaw) AND
				(NOT Internal.CloseFbSeen) THEN
				Internal.CloseFbEventTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
			END_IF;
			IF V_Param.LampCloseExists AND V_Input.LampClose AND (NOT Internal.PrevLampCloseRaw) AND
				(NOT Internal.CloseLampSeen) THEN
				Internal.CloseLampEventTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
			END_IF;

			IF V_Param.OpenFbExists AND Internal.PrevOpenFbStable AND
				(NOT Internal.OpenFbStable) AND (NOT Internal.CloseStartMeasured) THEN
				V_Output.LastCloseStartTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
				Internal.CloseStartMeasured := TRUE;
			END_IF;

			IF V_Param.CloseFbExists AND Internal.CloseFbStable AND (NOT Internal.CloseFbSeen) THEN
				V_Output.LastCloseFbTime := Internal.CloseFbEventTime;
				Internal.CloseFbSeen := TRUE;
			END_IF;

			IF V_Param.LampCloseExists AND Internal.LampCloseStable THEN
				V_Output.LastCloseTime := Internal.CloseLampEventTime;
				Internal.CloseLampSeen := TRUE;
				Internal.CloseEndReached := TRUE;
				IF Internal.CloseFbSeen THEN
					V_Output.LastCloseFbOffset := Internal.CloseFbEventTime - Internal.CloseLampEventTime;
					V_Output.CloseFbOffsetValid := TRUE;
					Internal.Step := Cfg.ST_IDLE_CLOSED;
				ELSIF V_Param.CloseFbExists THEN
					Internal.Step := Cfg.ST_WAIT_CLOSE_CONFIRM;
				ELSE
					Internal.Step := Cfg.ST_IDLE_CLOSE_ASSUMED;
				END_IF;
			ELSIF (NOT V_Param.LampCloseExists) AND V_Param.CloseFbExists AND Internal.CloseFbStable THEN
				V_Output.LastCloseTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
				Internal.Step := Cfg.ST_IDLE_CLOSED;
			ELSIF Internal.CloseTravelTimer.Q THEN
				IF V_Param.LampCloseExists OR V_Param.CloseFbExists THEN
					Internal.FaultCode := Cfg.FLT_CLOSE_TIMEOUT;
					Internal.FaultDirection := Cfg.DIR_CLOSE;
					Internal.FaultLatched := TRUE;
					Internal.FaultInManual := V_Input.EnableManual;
					Internal.Step := Cfg.ST_FAULT;
				ELSE
					V_Output.LastCloseTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
					Internal.Step := Cfg.ST_IDLE_CLOSE_ASSUMED;
				END_IF;
			ELSE
				V_Output.CmdClose := TRUE;
			END_IF;
		END_IF;

	90: (* ST_WAIT_OPEN_CONFIRM *)
		IF Internal.OpenFbStable THEN
			Internal.OpenFbEventTime := Internal.OpenLampEventTime +
				(UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenConfirmTimer.ET)) / 1000.0);
			V_Output.LastOpenFbTime := Internal.OpenFbEventTime;
			V_Output.LastOpenFbOffset := Internal.OpenFbEventTime - Internal.OpenLampEventTime;
			V_Output.OpenFbOffsetValid := TRUE;
			Internal.Step := Cfg.ST_IDLE_OPENED;
		ELSIF Internal.OpenConfirmTimer.Q THEN
			Internal.FaultCode := Cfg.FLT_OPEN_CONFIRM_TIMEOUT;
			Internal.FaultDirection := Cfg.DIR_OPEN;
			Internal.FaultLatched := TRUE;
			Internal.FaultInManual := V_Input.EnableManual;
			Internal.Step := Cfg.ST_FAULT;
		END_IF;

	100: (* ST_WAIT_CLOSE_CONFIRM *)
		IF Internal.CloseFbStable THEN
			Internal.CloseFbEventTime := Internal.CloseLampEventTime +
				(UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseConfirmTimer.ET)) / 1000.0);
			V_Output.LastCloseFbTime := Internal.CloseFbEventTime;
			V_Output.LastCloseFbOffset := Internal.CloseFbEventTime - Internal.CloseLampEventTime;
			V_Output.CloseFbOffsetValid := TRUE;
			Internal.Step := Cfg.ST_IDLE_CLOSED;
		ELSIF Internal.CloseConfirmTimer.Q THEN
			Internal.FaultCode := Cfg.FLT_CLOSE_CONFIRM_TIMEOUT;
			Internal.FaultDirection := Cfg.DIR_CLOSE;
			Internal.FaultLatched := TRUE;
			Internal.FaultInManual := V_Input.EnableManual;
			Internal.Step := Cfg.ST_FAULT;
		END_IF;

	110: (* ST_STOPPED *)
		IF NOT V_Input.Stop THEN
			IF V_Input.Enable THEN
				Internal.Step := Cfg.ST_WAIT_REENABLE;
			ELSE
				Internal.Step := Cfg.ST_DISABLED;
			END_IF;
		END_IF;

	120: (* ST_WAIT_REENABLE *)
		(* Globalni Enable=FALSE prioritet vraca FB u ST_DISABLED. *)

	200: (* ST_FAULT *)
		IF Internal.ForceAllowed AND Internal.ForceRequested THEN
			Internal.NextDirection := Internal.ForceDirection;
			Internal.Step := Cfg.ST_FORCE_DEADTIME;
		END_IF;

	210: (* ST_FORCE_DEADTIME *)
		IF (NOT Internal.ForceAllowed) OR (NOT Internal.ForceRequested) THEN
			Internal.Step := Cfg.ST_FAULT;
		ELSIF Internal.DeadTimeTimer.Q THEN
			IF Internal.ForceDirection = Cfg.DIR_OPEN THEN
				Internal.OpenEndReached := FALSE;
				Internal.OpenFbSeen := FALSE;
				Internal.OpenLampSeen := FALSE;
				Internal.OpenStartMeasured := FALSE;
				V_Output.OpenFbOffsetValid := FALSE;
				Internal.PrevDirection := Cfg.DIR_OPEN;
				Internal.Step := Cfg.ST_FORCE_OPENING;
			ELSE
				Internal.CloseEndReached := FALSE;
				Internal.CloseFbSeen := FALSE;
				Internal.CloseLampSeen := FALSE;
				Internal.CloseStartMeasured := FALSE;
				V_Output.CloseFbOffsetValid := FALSE;
				Internal.PrevDirection := Cfg.DIR_CLOSE;
				Internal.Step := Cfg.ST_FORCE_CLOSING;
			END_IF;
		END_IF;

	220: (* ST_FORCE_OPENING *)
		IF (NOT Internal.ForceAllowed) OR (NOT Internal.ForceRequested) THEN
			Internal.Step := Cfg.ST_FAULT;
		ELSE
			IF V_Param.OpenFbExists AND V_Input.OpenFb AND (NOT Internal.PrevOpenFbRaw) AND
				(NOT Internal.OpenFbSeen) THEN
				Internal.OpenFbEventTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
			END_IF;
			IF V_Param.LampOpenExists AND V_Input.LampOpen AND (NOT Internal.PrevLampOpenRaw) AND
				(NOT Internal.OpenLampSeen) THEN
				Internal.OpenLampEventTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
			END_IF;
			IF V_Param.CloseFbExists AND Internal.PrevCloseFbStable AND
				(NOT Internal.CloseFbStable) AND (NOT Internal.OpenStartMeasured) THEN
				V_Output.LastOpenStartTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
				Internal.OpenStartMeasured := TRUE;
			END_IF;
			IF V_Param.OpenFbExists AND Internal.OpenFbStable AND (NOT Internal.OpenFbSeen) THEN
				V_Output.LastOpenFbTime := Internal.OpenFbEventTime;
				Internal.OpenFbSeen := TRUE;
			END_IF;
			IF V_Param.LampOpenExists AND Internal.LampOpenStable THEN
				V_Output.LastOpenTime := Internal.OpenLampEventTime;
				Internal.OpenEndReached := TRUE;
				IF Internal.OpenFbSeen THEN
					V_Output.LastOpenFbOffset := Internal.OpenFbEventTime - Internal.OpenLampEventTime;
					V_Output.OpenFbOffsetValid := TRUE;
					Internal.ForceRecoveryDone := TRUE;
					Internal.Step := Cfg.ST_FAULT;
				ELSIF V_Param.OpenFbExists THEN
					Internal.Step := Cfg.ST_FORCE_WAIT_OPEN_CONFIRM;
				ELSE
					Internal.ForceRecoveryDone := TRUE;
					Internal.Step := Cfg.ST_FAULT;
				END_IF;
			ELSIF (NOT V_Param.LampOpenExists) AND V_Param.OpenFbExists AND Internal.OpenFbStable THEN
				V_Output.LastOpenTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
				Internal.ForceRecoveryDone := TRUE;
				Internal.Step := Cfg.ST_FAULT;
			ELSIF Internal.OpenTravelTimer.Q THEN
				IF V_Param.LampOpenExists OR V_Param.OpenFbExists THEN
					Internal.RecoveryFaultCode := Cfg.FLT_OPEN_TIMEOUT;
					Internal.FaultInForce := TRUE;
				ELSE
					Internal.ForceRecoveryDone := TRUE;
				END_IF;
				Internal.Step := Cfg.ST_FAULT;
			ELSE
				V_Output.CmdOpen := TRUE;
			END_IF;
		END_IF;

	230: (* ST_FORCE_CLOSING *)
		IF (NOT Internal.ForceAllowed) OR (NOT Internal.ForceRequested) THEN
			Internal.Step := Cfg.ST_FAULT;
		ELSE
			IF V_Param.CloseFbExists AND V_Input.CloseFb AND (NOT Internal.PrevCloseFbRaw) AND
				(NOT Internal.CloseFbSeen) THEN
				Internal.CloseFbEventTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
			END_IF;
			IF V_Param.LampCloseExists AND V_Input.LampClose AND (NOT Internal.PrevLampCloseRaw) AND
				(NOT Internal.CloseLampSeen) THEN
				Internal.CloseLampEventTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
			END_IF;
			IF V_Param.OpenFbExists AND Internal.PrevOpenFbStable AND
				(NOT Internal.OpenFbStable) AND (NOT Internal.CloseStartMeasured) THEN
				V_Output.LastCloseStartTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
				Internal.CloseStartMeasured := TRUE;
			END_IF;
			IF V_Param.CloseFbExists AND Internal.CloseFbStable AND (NOT Internal.CloseFbSeen) THEN
				V_Output.LastCloseFbTime := Internal.CloseFbEventTime;
				Internal.CloseFbSeen := TRUE;
			END_IF;
			IF V_Param.LampCloseExists AND Internal.LampCloseStable THEN
				V_Output.LastCloseTime := Internal.CloseLampEventTime;
				Internal.CloseEndReached := TRUE;
				IF Internal.CloseFbSeen THEN
					V_Output.LastCloseFbOffset := Internal.CloseFbEventTime - Internal.CloseLampEventTime;
					V_Output.CloseFbOffsetValid := TRUE;
					Internal.ForceRecoveryDone := TRUE;
					Internal.Step := Cfg.ST_FAULT;
				ELSIF V_Param.CloseFbExists THEN
					Internal.Step := Cfg.ST_FORCE_WAIT_CLOSE_CONFIRM;
				ELSE
					Internal.ForceRecoveryDone := TRUE;
					Internal.Step := Cfg.ST_FAULT;
				END_IF;
			ELSIF (NOT V_Param.LampCloseExists) AND V_Param.CloseFbExists AND Internal.CloseFbStable THEN
				V_Output.LastCloseTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
				Internal.ForceRecoveryDone := TRUE;
				Internal.Step := Cfg.ST_FAULT;
			ELSIF Internal.CloseTravelTimer.Q THEN
				IF V_Param.LampCloseExists OR V_Param.CloseFbExists THEN
					Internal.RecoveryFaultCode := Cfg.FLT_CLOSE_TIMEOUT;
					Internal.FaultInForce := TRUE;
				ELSE
					Internal.ForceRecoveryDone := TRUE;
				END_IF;
				Internal.Step := Cfg.ST_FAULT;
			ELSE
				V_Output.CmdClose := TRUE;
			END_IF;
		END_IF;

	240: (* ST_FORCE_WAIT_OPEN_CONFIRM *)
		IF Internal.OpenFbStable THEN
			Internal.OpenFbEventTime := Internal.OpenLampEventTime +
				(UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenConfirmTimer.ET)) / 1000.0);
			V_Output.LastOpenFbTime := Internal.OpenFbEventTime;
			V_Output.LastOpenFbOffset := Internal.OpenFbEventTime - Internal.OpenLampEventTime;
			V_Output.OpenFbOffsetValid := TRUE;
			Internal.ForceRecoveryDone := TRUE;
			Internal.Step := Cfg.ST_FAULT;
		ELSIF Internal.OpenConfirmTimer.Q THEN
			Internal.RecoveryFaultCode := Cfg.FLT_OPEN_CONFIRM_TIMEOUT;
			Internal.FaultInForce := TRUE;
			Internal.Step := Cfg.ST_FAULT;
		END_IF;

	250: (* ST_FORCE_WAIT_CLOSE_CONFIRM *)
		IF Internal.CloseFbStable THEN
			Internal.CloseFbEventTime := Internal.CloseLampEventTime +
				(UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseConfirmTimer.ET)) / 1000.0);
			V_Output.LastCloseFbTime := Internal.CloseFbEventTime;
			V_Output.LastCloseFbOffset := Internal.CloseFbEventTime - Internal.CloseLampEventTime;
			V_Output.CloseFbOffsetValid := TRUE;
			Internal.ForceRecoveryDone := TRUE;
			Internal.Step := Cfg.ST_FAULT;
		ELSIF Internal.CloseConfirmTimer.Q THEN
			Internal.RecoveryFaultCode := Cfg.FLT_CLOSE_CONFIRM_TIMEOUT;
			Internal.FaultInForce := TRUE;
			Internal.Step := Cfg.ST_FAULT;
		END_IF;

ELSE
	Internal.FaultCode := Cfg.FLT_OUTPUT_CONFLICT;
	Internal.FaultDirection := Cfg.DIR_NONE;
	Internal.FaultLatched := TRUE;
	Internal.Step := Cfg.ST_FAULT;
END_CASE;

(* Defensive XOR provera nakon state machine odluke. *)
IF V_Output.CmdOpen AND V_Output.CmdClose THEN
	V_Output.CmdOpen := FALSE;
	V_Output.CmdClose := FALSE;
	IF Internal.FaultLatched THEN
		Internal.RecoveryFaultCode := Cfg.FLT_OUTPUT_CONFLICT;
		Internal.FaultInForce := TRUE;
	ELSE
		Internal.FaultCode := Cfg.FLT_OUTPUT_CONFLICT;
		Internal.FaultDirection := Cfg.DIR_NONE;
		Internal.FaultLatched := TRUE;
	END_IF;
	Internal.Step := Cfg.ST_FAULT;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 9) Polozaj, status i merenja                                               *)
(* -------------------------------------------------------------------------- *)
V_Output.Opened := V_Param.OpenFbExists AND Internal.OpenFbStable AND
	(NOT Internal.CloseFbStable);
V_Output.Closed := V_Param.CloseFbExists AND Internal.CloseFbStable AND
	(NOT Internal.OpenFbStable);
V_Output.OpenAssumed := (Internal.Step = Cfg.ST_IDLE_OPEN_ASSUMED);
V_Output.CloseAssumed := (Internal.Step = Cfg.ST_IDLE_CLOSE_ASSUMED);
V_Output.PositionConfirmed := V_Output.Opened OR V_Output.Closed;
V_Output.PositionAssumed := V_Output.OpenAssumed OR V_Output.CloseAssumed;
V_Output.Intermediate := (NOT V_Output.PositionConfirmed) AND
	(NOT V_Output.PositionAssumed) AND
	(NOT (Internal.OpenFbStable AND Internal.CloseFbStable));

IF Internal.OpenFbStable AND Internal.CloseFbStable THEN
	V_Output.Position := Cfg.POS_CONFLICT;
ELSIF V_Output.Closed THEN
	V_Output.Position := Cfg.POS_CLOSED_CONFIRMED;
ELSIF V_Output.Opened THEN
	V_Output.Position := Cfg.POS_OPENED_CONFIRMED;
ELSIF V_Output.CloseAssumed THEN
	V_Output.Position := Cfg.POS_CLOSED_ASSUMED;
ELSIF V_Output.OpenAssumed THEN
	V_Output.Position := Cfg.POS_OPENED_ASSUMED;
ELSIF V_Output.Intermediate THEN
	V_Output.Position := Cfg.POS_INTERMEDIATE;
ELSE
	V_Output.Position := Cfg.POS_UNKNOWN;
END_IF;

CASE V_Output.Position OF
	0: V_Output.PositionText := 'POS_UNKNOWN - polozaj nije poznat';
	1: V_Output.PositionText := 'POS_CLOSED_CONFIRMED - zatvoren, fizicki potvrdjen';
	2: V_Output.PositionText := 'POS_OPENED_CONFIRMED - otvoren, fizicki potvrdjen';
	3: V_Output.PositionText := 'POS_INTERMEDIATE - ventil je izmedju krajnjih polozaja';
	4: V_Output.PositionText := 'POS_CLOSED_ASSUMED - zatvoren, vremenski pretpostavljen';
	5: V_Output.PositionText := 'POS_OPENED_ASSUMED - otvoren, vremenski pretpostavljen';
	6: V_Output.PositionText := 'POS_CONFLICT - OpenFb i CloseFb su istovremeno aktivni';
ELSE
	V_Output.PositionText := 'POS_INVALID - nepoznat numericki kod polozaja';
END_CASE;

V_Output.Status := V_Input.Enable AND (NOT Internal.FaultLatched);
V_Output.Ready := (Internal.Step = Cfg.ST_IDLE_CLOSED) OR
	(Internal.Step = Cfg.ST_IDLE_OPENED) OR
	(Internal.Step = Cfg.ST_IDLE_CLOSE_ASSUMED) OR
	(Internal.Step = Cfg.ST_IDLE_OPEN_ASSUMED) OR
	(Internal.Step = Cfg.ST_INTERMEDIATE);
V_Output.Opening := (Internal.Step = Cfg.ST_OPENING) OR
	(Internal.Step = Cfg.ST_FORCE_OPENING);
V_Output.Closing := (Internal.Step = Cfg.ST_CLOSING) OR
	(Internal.Step = Cfg.ST_FORCE_CLOSING);
V_Output.InTransition := V_Output.Opening OR V_Output.Closing;
V_Output.Stopped := (Internal.Step = Cfg.ST_STOPPED);
V_Output.StopActive := V_Input.Stop;
V_Output.InitActive := (Internal.Step = Cfg.ST_INIT_SYNC);
V_Output.WaitingReEnable := (Internal.Step = Cfg.ST_WAIT_REENABLE);
V_Output.DeadTimeActive := (Internal.Step = Cfg.ST_DIRECTION_DEADTIME) OR
	(Internal.Step = Cfg.ST_FORCE_DEADTIME);
V_Output.WaitingPositionConfirm := (Internal.Step = Cfg.ST_WAIT_OPEN_CONFIRM) OR
	(Internal.Step = Cfg.ST_WAIT_CLOSE_CONFIRM) OR
	(Internal.Step = Cfg.ST_FORCE_WAIT_OPEN_CONFIRM) OR
	(Internal.Step = Cfg.ST_FORCE_WAIT_CLOSE_CONFIRM);
V_Output.ManualActive := V_Input.EnableManual;
V_Output.ForceAllowed := Internal.ForceAllowed;
V_Output.ForceActive := (Internal.Step = Cfg.ST_FORCE_DEADTIME) OR
	(Internal.Step = Cfg.ST_FORCE_OPENING) OR
	(Internal.Step = Cfg.ST_FORCE_CLOSING) OR
	(Internal.Step = Cfg.ST_FORCE_WAIT_OPEN_CONFIRM) OR
	(Internal.Step = Cfg.ST_FORCE_WAIT_CLOSE_CONFIRM);
V_Output.ForceBlocked := V_Input.ForceCmd AND Internal.FaultLatched AND
	((NOT Internal.ForceAllowed) OR (NOT Internal.ForceRequested));
V_Output.DesiredOpen := Internal.DesiredOpen;
V_Output.FaultCondition := Internal.FaultCondition;
V_Output.FaultLatched := Internal.FaultLatched;
V_Output.FaultCode := Internal.FaultCode;
V_Output.FaultDirection := Internal.FaultDirection;
V_Output.FaultInManual := Internal.FaultInManual;
V_Output.FaultInForce := Internal.FaultInForce;
V_Output.ForceDirection := Internal.ForceDirection;
V_Output.RecoveryFaultCode := Internal.RecoveryFaultCode;
V_Output.ConfigFaultText := Internal.ConfigFaultText;
V_Output.OpenEndReached := Internal.OpenEndReached;
V_Output.CloseEndReached := Internal.CloseEndReached;
V_Output.OpenFbStable := Internal.OpenFbStable;
V_Output.CloseFbStable := Internal.CloseFbStable;
V_Output.OverTorqueActive := Internal.OverTorqueStable;
V_Output.State := Internal.Step;

IF V_Output.Opening THEN
	V_Output.CurrentTravelTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenTravelTimer.ET)) / 1000.0;
ELSIF V_Output.Closing THEN
	V_Output.CurrentTravelTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseTravelTimer.ET)) / 1000.0;
ELSE
	V_Output.CurrentTravelTime := 0.0;
END_IF;

Opened := V_Output.Opened;
Closed := V_Output.Closed;

(* -------------------------------------------------------------------------- *)
(* 10) Tekstualno mapiranje state, fault i smer kodova                       *)
(* -------------------------------------------------------------------------- *)
CASE Internal.Step OF
	0: V_Output.State_comment := 'ST_DISABLED - FB nije omogucen';
	5: V_Output.State_comment := 'ST_INIT_SYNC - proverava se pocetni polozaj';
	10: V_Output.State_comment := 'ST_IDLE_CLOSED - ventil je potvrdjeno zatvoren';
	20: V_Output.State_comment := 'ST_IDLE_OPENED - ventil je potvrdjeno otvoren';
	30: V_Output.State_comment := 'ST_IDLE_CLOSE_ASSUMED - zatvoren polozaj je pretpostavljen';
	40: V_Output.State_comment := 'ST_IDLE_OPEN_ASSUMED - otvoren polozaj je pretpostavljen';
	50: V_Output.State_comment := 'ST_INTERMEDIATE - ventil miruje u medjupolozaju';
	60: V_Output.State_comment := 'ST_DIRECTION_DEADTIME - pauza pre regularnog smera';
	70: V_Output.State_comment := 'ST_OPENING - aktivno regularno otvaranje';
	80: V_Output.State_comment := 'ST_CLOSING - aktivno regularno zatvaranje';
	90: V_Output.State_comment := 'ST_WAIT_OPEN_CONFIRM - ceka se trajni OpenFb';
	100: V_Output.State_comment := 'ST_WAIT_CLOSE_CONFIRM - ceka se trajni CloseFb';
	110: V_Output.State_comment := 'ST_STOPPED - operativni Stop je aktivan';
	120: V_Output.State_comment := 'ST_WAIT_REENABLE - potreban je novi Enable ciklus';
	200: V_Output.State_comment := 'ST_FAULT - fault je latched, regularne komande su blokirane';
	210: V_Output.State_comment := 'ST_FORCE_DEADTIME - pauza pre force oporavka';
	220: V_Output.State_comment := 'ST_FORCE_OPENING - force otvaranje iz CLOSE fault-a';
	230: V_Output.State_comment := 'ST_FORCE_CLOSING - force zatvaranje iz OPEN fault-a';
	240: V_Output.State_comment := 'ST_FORCE_WAIT_OPEN_CONFIRM - force OPEN ceka OpenFb';
	250: V_Output.State_comment := 'ST_FORCE_WAIT_CLOSE_CONFIRM - force CLOSE ceka CloseFb';
ELSE
	V_Output.State_comment := 'ST_UNKNOWN - nepoznat numericki state kod';
END_CASE;

CASE Internal.FaultCode OF
	0: V_Output.FaultText := 'FLT_NONE - nema aktivnog fault-a';
	1: V_Output.FaultText := 'FLT_MANUAL_ALARM - aktivan je spoljasnji alarm/interlock';
	2: V_Output.FaultText := 'FLT_OVER_TORQUE - aktivirana je momentna zastita';
	3: V_Output.FaultText := 'FLT_POSITION_CONFLICT - OpenFb i CloseFb su istovremeno aktivni';
	4: V_Output.FaultText := 'FLT_OUTPUT_CONFLICT - CmdOpen i CmdClose su istovremeno aktivni';
	5: V_Output.FaultText := 'FLT_OPEN_TIMEOUT - OPEN kraj nije dostignut na vreme';
	6: V_Output.FaultText := 'FLT_CLOSE_TIMEOUT - CLOSE kraj nije dostignut na vreme';
	7: V_Output.FaultText := 'FLT_OPEN_CONFIRM_TIMEOUT - LampOpen bez trajnog OpenFb';
	8: V_Output.FaultText := 'FLT_CLOSE_CONFIRM_TIMEOUT - LampClose bez trajnog CloseFb';
	9: V_Output.FaultText := 'FLT_OPEN_FB_LOST - izgubljen OpenFb u otvorenom stanju';
	10: V_Output.FaultText := 'FLT_CLOSE_FB_LOST - izgubljen CloseFb u zatvorenom stanju';
	11: V_Output.FaultText := 'FLT_INVALID_CONFIG - konfiguracija parametara nije validna';
	12: V_Output.FaultText := 'FLT_UNEXPECTED_OPEN_LIMIT - LampOpen tokom zatvaranja';
	13: V_Output.FaultText := 'FLT_UNEXPECTED_CLOSE_LIMIT - LampClose tokom otvaranja';
ELSE
	V_Output.FaultText := 'FLT_UNKNOWN - nepoznat numericki fault kod';
END_CASE;

CASE Internal.RecoveryFaultCode OF
	0: V_Output.RecoveryFaultText := 'FLT_NONE - nema fault-a tokom force oporavka';
	1: V_Output.RecoveryFaultText := 'FLT_MANUAL_ALARM - alarm tokom force oporavka';
	2: V_Output.RecoveryFaultText := 'FLT_OVER_TORQUE - momentna zastita tokom force oporavka';
	3: V_Output.RecoveryFaultText := 'FLT_POSITION_CONFLICT - konflikt polozaja tokom force oporavka';
	4: V_Output.RecoveryFaultText := 'FLT_OUTPUT_CONFLICT - konflikt izlaza tokom force oporavka';
	5: V_Output.RecoveryFaultText := 'FLT_OPEN_TIMEOUT - force otvaranje nije zavrseno na vreme';
	6: V_Output.RecoveryFaultText := 'FLT_CLOSE_TIMEOUT - force zatvaranje nije zavrseno na vreme';
	7: V_Output.RecoveryFaultText := 'FLT_OPEN_CONFIRM_TIMEOUT - force OPEN bez OpenFb potvrde';
	8: V_Output.RecoveryFaultText := 'FLT_CLOSE_CONFIRM_TIMEOUT - force CLOSE bez CloseFb potvrde';
	9: V_Output.RecoveryFaultText := 'FLT_OPEN_FB_LOST - OpenFb izgubljen tokom oporavka';
	10: V_Output.RecoveryFaultText := 'FLT_CLOSE_FB_LOST - CloseFb izgubljen tokom oporavka';
	11: V_Output.RecoveryFaultText := 'FLT_INVALID_CONFIG - konfiguracija nije validna';
	12: V_Output.RecoveryFaultText := 'FLT_UNEXPECTED_OPEN_LIMIT - neocekivan LampOpen';
	13: V_Output.RecoveryFaultText := 'FLT_UNEXPECTED_CLOSE_LIMIT - neocekivan LampClose';
ELSE
	V_Output.RecoveryFaultText := 'FLT_UNKNOWN - nepoznat recovery fault kod';
END_CASE;

CASE Internal.FaultDirection OF
	0: V_Output.FaultDirectionText := 'DIR_NONE - nema smera';
	1: V_Output.FaultDirectionText := 'DIR_OPEN - otvaranje';
	2: V_Output.FaultDirectionText := 'DIR_CLOSE - zatvaranje';
ELSE
	V_Output.FaultDirectionText := 'DIR_UNKNOWN';
END_CASE;

CASE Internal.ForceDirection OF
	0: V_Output.ForceDirectionText := 'DIR_NONE - nema smera';
	1: V_Output.ForceDirectionText := 'DIR_OPEN - otvaranje';
	2: V_Output.ForceDirectionText := 'DIR_CLOSE - zatvaranje';
ELSE
	V_Output.ForceDirectionText := 'DIR_UNKNOWN';
END_CASE;

IF V_Output.ForceActive THEN
	V_Output.ForceDiag := 'FORCE_ACTIVE - aktivan kontrolisani povratni smer';
ELSIF V_Output.ForceBlocked THEN
	V_Output.ForceDiag := 'FORCE_BLOCKED - zahtev/smer ili zastitni uslovi nisu validni';
ELSIF V_Output.ForceAllowed THEN
	V_Output.ForceDiag := 'FORCE_ALLOWED - dozvoljen je samo suprotan smer';
ELSE
	V_Output.ForceDiag := 'FORCE_NOT_AVAILABLE';
END_IF;

IF Internal.FaultLatched THEN
	V_Output.Diag := V_Output.FaultText;
ELSIF V_Output.WaitingPositionConfirm THEN
	V_Output.Diag := 'WAIT_POSITION_CONFIRM';
ELSIF V_Output.DeadTimeActive THEN
	V_Output.Diag := 'DIRECTION_DEADTIME_ACTIVE';
ELSIF V_Output.Opening THEN
	V_Output.Diag := 'OPENING_WAIT_END_SIGNAL';
ELSIF V_Output.Closing THEN
	V_Output.Diag := 'CLOSING_WAIT_END_SIGNAL';
ELSE
	V_Output.Diag := V_Output.State_comment;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 11) Memorija prethodnog ciklusa                                            *)
(* -------------------------------------------------------------------------- *)
Internal.PrevEnable := V_Input.Enable;
Internal.PrevOpenFbStable := Internal.OpenFbStable;
Internal.PrevCloseFbStable := Internal.CloseFbStable;
Internal.PrevOpenFbRaw := V_Input.OpenFb;
Internal.PrevCloseFbRaw := V_Input.CloseFb;
Internal.PrevLampOpenRaw := V_Input.LampOpen;
Internal.PrevLampCloseRaw := V_Input.LampClose;

END_FUNCTION_BLOCK
