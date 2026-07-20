FUNCTION_BLOCK FB_DI (* Univerzalni DI sa opcionim status signalom i fault dijagnostikom *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)

(* -------------------------------------------------------------------------- *)
(* 1) Podrazumevane vrednosti po scan-u                                        *)
(* -------------------------------------------------------------------------- *)
(* default *)
DI_Output.Status := FALSE;
DI_Output.Alarm := FALSE;
DI_Output.Error := FALSE;
DI_Output.ManualActive := FALSE;
DI_Internal.FaultCondition := FALSE;
DI_Internal.AlarmCondition := FALSE;
DI_Output.StatusSignalIn := DI_Input.StatusIn;

(* -------------------------------------------------------------------------- *)
(* 2) Obrada ulaza, reset i fault uslova                                       *)
(* -------------------------------------------------------------------------- *)
(* obrada sirovog signala *)
IF DI_Param.InvertSignal THEN
	DI_Internal.SignalRaw := NOT DI_Input.SensorIn;
ELSE
	DI_Internal.SignalRaw := DI_Input.SensorIn;
END_IF;

(* reset latched fault-a *)
IF DI_Input.ResetAlarm THEN
	DI_Internal.FaultLatched := FALSE;
END_IF;

(* fault logika *)
IF DI_Input.ManualAlarm THEN
	DI_Internal.FaultCondition := TRUE;
END_IF;

(* opcioni statusni ulaz *)
IF DI_Param.UseStatusInput THEN
	IF NOT DI_Input.StatusIn THEN
		DI_Internal.FaultCondition := TRUE;
	END_IF;
END_IF;

(* latched fault *)
IF DI_Internal.FaultCondition THEN
	DI_Internal.FaultLatched := TRUE;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 3) Glavna obrada po Enable/Manual/Auto granama                              *)
(* -------------------------------------------------------------------------- *)
(* blok nije aktivan *)
IF NOT DI_Input.Enable THEN
	DI_Output.Value := FALSE;
	DI_Internal.SignalFiltered := FALSE;

	DI_Output.State := DI_Constant.ST_DISABLED;
	DI_Output.State_comment := 'Digitalni ulaz neaktivan';

	DI_Output.Status := FALSE;
	DI_Output.Alarm := FALSE;
	DI_Output.Error := FALSE;
	DI_Output.ManualActive := FALSE;

	DI_Internal.TonOn(IN := FALSE, PT := DI_Param.DelayOn);
	DI_Internal.TonOff(IN := FALSE, PT := DI_Param.DelayOff);

ELSE
	(* ---------------------------------------------------------------------- *)
	(* 3.1) Manual rezim                                                       *)
	(* ---------------------------------------------------------------------- *)
	(* rucni mod *)
	IF DI_Input.EnableManual THEN
		DI_Output.Value := DI_Input.ManualValue;
		DI_Output.ManualActive := TRUE;

		DI_Internal.TonOn(IN := FALSE, PT := DI_Param.DelayOn);
		DI_Internal.TonOff(IN := FALSE, PT := DI_Param.DelayOff);

		(* procesni alarm u rucnom modu *)
		DI_Internal.AlarmCondition := FALSE;

		IF DI_Output.Value AND DI_Param.AlarmOnTrue THEN
			DI_Internal.AlarmCondition := TRUE;
		END_IF;

		IF (NOT DI_Output.Value) AND DI_Param.AlarmOnFalse THEN
			DI_Internal.AlarmCondition := TRUE;
		END_IF;

		DI_Output.Alarm := DI_Internal.AlarmCondition;
		DI_Output.Error := DI_Internal.FaultLatched;

		IF DI_Internal.FaultLatched THEN
			DI_Output.State := DI_Constant.ST_MAN_FAULT;
			DI_Output.State_comment := DI_Param.TextFault;
			DI_Output.Status := FALSE;

		ELSIF DI_Internal.AlarmCondition THEN
			DI_Output.State := DI_Constant.ST_MAN_ALARM;
			DI_Output.State_comment := DI_Param.TextAlarm;
			DI_Output.Status := FALSE;

		ELSE
			DI_Output.Status := TRUE;

			IF DI_Output.Value THEN
				DI_Output.State := DI_Constant.ST_MAN_TRUE;
				DI_Output.State_comment := DI_Param.TextTrue;
			ELSE
				DI_Output.State := DI_Constant.ST_MAN_FALSE;
				DI_Output.State_comment := DI_Param.TextFalse;
			END_IF;
		END_IF;

	ELSE
		(* ------------------------------------------------------------------ *)
		(* 3.2) Auto rezim sa DelayOn/DelayOff filtracijom                   *)
		(* ------------------------------------------------------------------ *)
		(* automatski mod sa DelayOn / DelayOff filtracijom *)
		DI_Output.ManualActive := FALSE;

		DI_Internal.TonOn(
			IN := DI_Internal.SignalRaw AND NOT DI_Internal.SignalFiltered,
			PT := DI_Param.DelayOn
		);

		DI_Internal.TonOff(
			IN := (NOT DI_Internal.SignalRaw) AND DI_Internal.SignalFiltered,
			PT := DI_Param.DelayOff
		);

		(* filtracija *)
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

		(* procesni alarm *)
		DI_Internal.AlarmCondition := FALSE;

		IF DI_Output.Value AND DI_Param.AlarmOnTrue THEN
			DI_Internal.AlarmCondition := TRUE;
		END_IF;

		IF (NOT DI_Output.Value) AND DI_Param.AlarmOnFalse THEN
			DI_Internal.AlarmCondition := TRUE;
		END_IF;

		DI_Output.Alarm := DI_Internal.AlarmCondition;
		DI_Output.Error := DI_Internal.FaultLatched;

		IF DI_Internal.FaultLatched THEN
			DI_Output.State := DI_Constant.ST_AUTO_FAULT;
			DI_Output.State_comment := DI_Param.TextFault;
			DI_Output.Status := FALSE;

		ELSIF DI_Internal.AlarmCondition THEN
			DI_Output.State := DI_Constant.ST_AUTO_ALARM;
			DI_Output.State_comment := DI_Param.TextAlarm;
			DI_Output.Status := FALSE;

		ELSE
			DI_Output.Status := TRUE;

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

(* -------------------------------------------------------------------------- *)
(* 4) Zavrsno mapiranje dijagnostickih izlaza                                  *)
(* -------------------------------------------------------------------------- *)
DI_Output.FaultLatched := DI_Internal.FaultLatched;
DI_Output.FaultCondition := DI_Internal.FaultCondition;
DI_Output.AlarmCondition := DI_Internal.AlarmCondition;

END_FUNCTION_BLOCK
