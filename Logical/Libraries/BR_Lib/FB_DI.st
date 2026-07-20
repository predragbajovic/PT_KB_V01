FUNCTION_BLOCK FB_DI (* Univerzalni DI sa opcionim status signalom i fault dijagnostikom *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)

(* -------------------------------------------------------------------------- *)
(* 1) Podrazumevane vrednosti po scan-u                                        *)
(* -------------------------------------------------------------------------- *)
DI_Output.Status := FALSE;
DI_Output.Alarm := FALSE;
DI_Output.Error := FALSE;
DI_Output.ManualActive := FALSE;
DI_Output.StatusSignalIn := DI_Input.StatusIn;

DI_Internal.FaultCondition := FALSE;
DI_Internal.AlarmCondition := FALSE;
DI_Internal.ResetAllowed := FALSE;

DI_Output.ResetAllowed := FALSE;
DI_Output.ConfigValid := TRUE;
DI_Output.ConfigFaultText := 'CONFIG_OK';
DI_Output.FaultCode := DI_Internal.FaultCode;
DI_Output.FaultText := DI_Internal.FaultText;
DI_Output.Diag := 'IDLE';

(* -------------------------------------------------------------------------- *)
(* 2) Validacija parametara i obrada sirovog signala                           *)
(* -------------------------------------------------------------------------- *)
DI_Internal.ConfigValid := TRUE;

IF DI_Param.DelayOn < T#0ms THEN
	DI_Internal.ConfigValid := FALSE;
	DI_Output.ConfigFaultText := 'DelayOn ne sme biti negativan';
END_IF;

IF DI_Param.DelayOff < T#0ms THEN
	DI_Internal.ConfigValid := FALSE;
	IF DI_Output.ConfigFaultText = 'CONFIG_OK' THEN
		DI_Output.ConfigFaultText := 'DelayOff ne sme biti negativan';
	END_IF;
END_IF;

IF DI_Param.InvertSignal THEN
	DI_Internal.SignalRaw := NOT DI_Input.SensorIn;
ELSE
	DI_Internal.SignalRaw := DI_Input.SensorIn;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 3) Fault uslovi i reset politika (samo kada je Enable=TRUE)                 *)
(* -------------------------------------------------------------------------- *)
IF DI_Input.Enable THEN
	IF DI_Input.ManualAlarm THEN
		DI_Internal.FaultCondition := TRUE;
	END_IF;

	IF DI_Param.UseStatusInput AND (NOT DI_Input.StatusIn) THEN
		DI_Internal.FaultCondition := TRUE;
	END_IF;

	IF NOT DI_Internal.ConfigValid THEN
		DI_Internal.FaultCondition := TRUE;
	END_IF;

	DI_Internal.ResetAllowed := DI_Internal.FaultLatched AND (NOT DI_Internal.FaultCondition);

	IF DI_Input.ResetAlarm AND DI_Internal.ResetAllowed THEN
		DI_Internal.FaultLatched := FALSE;
		DI_Internal.FaultCode := DI_Constant.FLT_NONE;
	END_IF;

	IF DI_Internal.FaultCondition THEN
		IF NOT DI_Internal.FaultLatched THEN
			IF NOT DI_Internal.ConfigValid THEN
				DI_Internal.FaultCode := DI_Constant.FLT_CONFIG_INVALID;
			ELSIF DI_Input.ManualAlarm THEN
				DI_Internal.FaultCode := DI_Constant.FLT_MANUAL_ALARM;
			ELSE
				DI_Internal.FaultCode := DI_Constant.FLT_STATUS_INPUT;
			END_IF;
		END_IF;
		DI_Internal.FaultLatched := TRUE;
	END_IF;
ELSE
	DI_Internal.ResetAllowed := FALSE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 4) Glavna obrada po Enable/Manual/Auto granama                              *)
(* -------------------------------------------------------------------------- *)
IF NOT DI_Input.Enable THEN
	DI_Output.Value := FALSE;
	DI_Internal.SignalFiltered := FALSE;

	DI_Output.State := DI_Constant.ST_DISABLED;
	DI_Output.State_comment := 'Digitalni ulaz neaktivan';

	DI_Internal.TonOn(IN := FALSE, PT := DI_Param.DelayOn);
	DI_Internal.TonOff(IN := FALSE, PT := DI_Param.DelayOff);
ELSE
	IF DI_Input.EnableManual THEN
		DI_Output.Value := DI_Input.ManualValue;
		DI_Output.ManualActive := TRUE;

		DI_Internal.TonOn(IN := FALSE, PT := DI_Param.DelayOn);
		DI_Internal.TonOff(IN := FALSE, PT := DI_Param.DelayOff);
	ELSE
		DI_Output.ManualActive := FALSE;

		DI_Internal.TonOn(
			IN := DI_Internal.SignalRaw AND (NOT DI_Internal.SignalFiltered),
			PT := DI_Param.DelayOn
		);

		DI_Internal.TonOff(
			IN := (NOT DI_Internal.SignalRaw) AND DI_Internal.SignalFiltered,
			PT := DI_Param.DelayOff
		);

		IF (NOT DI_Internal.SignalFiltered) AND DI_Internal.SignalRaw THEN
			IF (DI_Param.DelayOn = T#0s) OR DI_Internal.TonOn.Q THEN
				DI_Internal.SignalFiltered := TRUE;
			END_IF;
		END_IF;

		IF DI_Internal.SignalFiltered AND (NOT DI_Internal.SignalRaw) THEN
			IF (DI_Param.DelayOff = T#0s) OR DI_Internal.TonOff.Q THEN
				DI_Internal.SignalFiltered := FALSE;
			END_IF;
		END_IF;

		DI_Output.Value := DI_Internal.SignalFiltered;
	END_IF;

	DI_Internal.AlarmCondition := FALSE;

	IF DI_Output.Value AND DI_Param.AlarmOnTrue THEN
		DI_Internal.AlarmCondition := TRUE;
	END_IF;

	IF (NOT DI_Output.Value) AND DI_Param.AlarmOnFalse THEN
		DI_Internal.AlarmCondition := TRUE;
	END_IF;

	IF DI_Internal.FaultLatched THEN
		DI_Output.Status := FALSE;
		DI_Output.Alarm := DI_Internal.AlarmCondition;
		DI_Output.Error := TRUE;

		IF DI_Input.EnableManual THEN
			DI_Output.State := DI_Constant.ST_MAN_FAULT;
		ELSE
			DI_Output.State := DI_Constant.ST_AUTO_FAULT;
		END_IF;
		DI_Output.State_comment := DI_Param.TextFault;
	ELSE
		DI_Output.Status := TRUE;
		DI_Output.Alarm := DI_Internal.AlarmCondition;
		DI_Output.Error := FALSE;

		IF DI_Input.EnableManual THEN
			IF DI_Internal.AlarmCondition THEN
				DI_Output.State := DI_Constant.ST_MAN_ALARM;
				DI_Output.State_comment := DI_Param.TextAlarm;
			ELSE
				IF DI_Output.Value THEN
					DI_Output.State := DI_Constant.ST_MAN_TRUE;
					DI_Output.State_comment := DI_Param.TextTrue;
				ELSE
					DI_Output.State := DI_Constant.ST_MAN_FALSE;
					DI_Output.State_comment := DI_Param.TextFalse;
				END_IF;
			END_IF;
		ELSE
			IF DI_Internal.AlarmCondition THEN
				DI_Output.State := DI_Constant.ST_AUTO_ALARM;
				DI_Output.State_comment := DI_Param.TextAlarm;
			ELSE
				IF DI_Output.Value THEN
					DI_Output.State := DI_Constant.ST_AUTO_TRUE;
					DI_Output.State_comment := DI_Param.TextTrue;
				ELSE
					DI_Output.State := DI_Constant.ST_AUTO_FALSE;
					DI_Output.State_comment := DI_Param.TextFalse;
				END_IF;
			END_IF;
		END_IF;
	END_IF;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 5) Fault tekst i dijagnostika                                               *)
(* -------------------------------------------------------------------------- *)
CASE DI_Internal.FaultCode OF
	0:
		DI_Internal.FaultText := 'FLT_NONE - nema memorisanog fault-a';
	1:
		DI_Internal.FaultText := 'FLT_MANUAL_ALARM - aktivan ManualAlarm ulaz';
	2:
		DI_Internal.FaultText := 'FLT_STATUS_INPUT - StatusIn je FALSE uz aktivan UseStatusInput';
	3:
		DI_Internal.FaultText := 'FLT_CONFIG_INVALID - nevalidni Delay parametri';
ELSE
	DI_Internal.FaultText := 'FLT_UNKNOWN - nepoznat fault kod';
END_CASE;

IF NOT DI_Input.Enable THEN
	DI_Internal.Diag := 'DISABLED';
ELSIF NOT DI_Internal.ConfigValid THEN
	DI_Internal.Diag := 'CONFIG_INVALID';
ELSIF DI_Internal.FaultLatched THEN
	DI_Internal.Diag := 'FAULT_LATCHED';
ELSIF DI_Input.EnableManual THEN
	IF DI_Internal.AlarmCondition THEN
		DI_Internal.Diag := 'MANUAL_ALARM';
	ELSE
		DI_Internal.Diag := 'MANUAL_OK';
	END_IF;
ELSE
	IF DI_Internal.AlarmCondition THEN
		DI_Internal.Diag := 'AUTO_ALARM';
	ELSE
		DI_Internal.Diag := 'AUTO_OK';
	END_IF;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 6) Zavrsno mapiranje dijagnostickih izlaza                                  *)
(* -------------------------------------------------------------------------- *)
DI_Output.FaultLatched := DI_Internal.FaultLatched;
DI_Output.FaultCondition := DI_Internal.FaultCondition;
DI_Output.AlarmCondition := DI_Internal.AlarmCondition;
DI_Output.ResetAllowed := DI_Internal.ResetAllowed;
DI_Output.ConfigValid := DI_Internal.ConfigValid;
DI_Output.FaultCode := DI_Internal.FaultCode;
DI_Output.FaultText := DI_Internal.FaultText;
DI_Output.Diag := DI_Internal.Diag;

END_FUNCTION_BLOCK