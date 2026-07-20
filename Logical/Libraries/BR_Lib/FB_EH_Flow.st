FUNCTION_BLOCK FB_EH_Flow (*TODO: FB za upravljanje elektricnim grejacima*) (*$GROUP=Pedja,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)

(* ============================================================ *)
(* 1) Inicijalizacija parametara pri rising-edge signala Enable *)
(* ============================================================ *)
IF NOT EH_Internal.Prev_Enable AND EH_Input.Enable THEN
	EH_Internal.PID_Controller.PIDParameters.Gain := EH_Constant.PID_GAIN;
	EH_Internal.PID_Controller.PIDParameters.IntegrationTime := EH_Constant.PID_INTEGRATION_TIME;
	EH_Internal.PID_Controller.PIDParameters.DerivativeTime := EH_Constant.PID_DERIVATIVE_TIME;
	EH_Internal.PID_Controller.MaxOut := EH_Constant.PID_MAX_OUT;
	EH_Internal.PID_Controller.MinOut := EH_Constant.PID_MIN_OUT;
	EH_Internal.PID_Controller.Update := TRUE;
	EH_Internal.Temp_Filter.WindowLength := EH_Constant.FILTER_LENGTH;
END_IF

IF EH_Internal.PID_Controller.UpdateDone THEN
	EH_Internal.PID_Controller.Update := TRUE;
END_IF

EH_Internal.Prev_Enable := EH_Input.Enable;

(* ================================================ *)
(* 2) Edge detekcija i priprema jednokratnih reseta *)
(* ================================================ *)
EH_Internal.Trig_Enable.CLK := EH_Input.Enable;
EH_Internal.Trig_Enable();
EH_Internal.Trig_BreakerFB_Fall.CLK := EH_Input.BreakerFB;
EH_Internal.Trig_BreakerFB_Fall();

IF EH_Internal.Trig_Enable.Q THEN
	EH_Internal.PID_Init_Pending := TRUE;
	EH_Internal.Filter_Init_Pending := TRUE;
END_IF;

(* ========================== *)
(* 3) Podesavanje svih tajmera *)
(* ========================== *)
EH_Internal.Timer_No_Flow.PT := EH_Constant.NO_FLOW_TIMEOUT;
EH_Internal.Timer_Over_Temp.PT := EH_Constant.OVER_TEMP_TIMEOUT;
EH_Internal.Timer_Breaker_On.PT := EH_Constant.BREAKER_DELAY;
EH_Internal.Timer_Breaker_Off.PT := EH_Constant.BREAKER_DELAY;

(* Svaki ciklus krecemo od FALSE, zatim po uslovima ukljucujemo IN. *)
EH_Internal.Timer_No_Flow.IN := FALSE;
EH_Internal.Timer_Over_Temp.IN := FALSE;
EH_Internal.Timer_Breaker_On.IN := FALSE;
EH_Internal.Timer_Breaker_Off.IN := FALSE;

(* ========================================================= *)
(* 4) Ogranicenje broja grejaca na validan opseg 0..MAX_HEATERS *)
(* ========================================================= *)
EH_Internal.NumHeaters_Valid := EH_Param.NumHeaters;
IF EH_Internal.NumHeaters_Valid < 0 THEN
	EH_Internal.NumHeaters_Valid := 0;
ELSIF EH_Internal.NumHeaters_Valid > EH_Constant.MAX_HEATERS THEN
	EH_Internal.NumHeaters_Valid := EH_Constant.MAX_HEATERS;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 5) Validacija konfiguracije                                                 *)
(* -------------------------------------------------------------------------- *)
EH_Internal.ConfigValid := TRUE;
EH_Internal.ConfigFaultText := 'CONFIG_OK';

IF (EH_Param.OutputType <> 0) AND (EH_Param.OutputType <> 1) THEN
	EH_Internal.ConfigValid := FALSE;
	EH_Internal.ConfigFaultText := 'OutputType mora biti 0 (analog) ili 1 (PWM)';
ELSIF (EH_Param.OutputType = 0) AND (EH_Param.AnalogMin > EH_Param.AnalogMax) THEN
	EH_Internal.ConfigValid := FALSE;
	EH_Internal.ConfigFaultText := 'AnalogMin ne sme biti veci od AnalogMax';
ELSIF (EH_Param.OutputType = 1) AND (EH_Internal.NumHeaters_Valid <= 0) THEN
	EH_Internal.ConfigValid := FALSE;
	EH_Internal.ConfigFaultText := 'PWM zahteva najmanje jedan grejac';
ELSIF (EH_Param.OutputType = 1) AND (EH_Param.PWM_Width <= 0.0) THEN
	EH_Internal.ConfigValid := FALSE;
	EH_Internal.ConfigFaultText := 'PWM_Width mora biti veci od 0.0';
ELSIF (EH_Param.OutputType = 1) AND (EH_Param.ScanTime <= 0.0) THEN
	EH_Internal.ConfigValid := FALSE;
	EH_Internal.ConfigFaultText := 'ScanTime mora biti veci od 0.0 za PWM';
ELSIF EH_Param.HeaterPower < 0.0 THEN
	EH_Internal.ConfigValid := FALSE;
	EH_Internal.ConfigFaultText := 'HeaterPower ne sme biti negativan';
ELSIF EH_Param.ActiveFlowMeter AND (EH_Param.FlowNominal <= 0.0) THEN
	EH_Internal.ConfigValid := FALSE;
	EH_Internal.ConfigFaultText := 'FlowNominal mora biti veci od 0.0 uz protokomer';
END_IF;

(* =============================================== *)
(* 6) Glavna logika kada je blok omogucen (Enable) *)
(* =============================================== *)
IF EH_Input.Enable THEN
	(* Provera protoka *)
	IF EH_Param.ActiveFlowSwitch THEN
		EH_Internal.Timer_No_Flow.IN := NOT EH_Input.FlowSwitch;
	ELSIF EH_Param.ActiveFlowMeter THEN
		EH_Internal.Timer_No_Flow.IN := EH_Input.FlowRate < EH_Constant.MIN_FLOW;
	ELSE
		EH_Internal.Timer_No_Flow.IN := TRUE;  (* Alarm ako nijedan nije aktivan *)
	END_IF;
	
	(* Provera temperature *)
	EH_Internal.Timer_Over_Temp.IN := (EH_Input.TempOut > EH_Constant.MAX_TEMP);
	
	(* Havarijska situacija: gubitak BreakerFB tokom rada *)
	IF EH_Internal.Breaker_On AND EH_Internal.Trig_BreakerFB_Fall.Q THEN
		EH_Internal.Fault_Latched := TRUE;
	END_IF;
	
	EH_Output.Alarm := (NOT EH_Internal.ConfigValid) OR
		EH_Internal.Timer_No_Flow.Q OR EH_Internal.Timer_Over_Temp.Q;
	IF EH_Internal.Fault_Latched THEN
		EH_Output.Alarm := TRUE;
	END_IF;
	
	(* Sekvenca glavnog prekidaca *)
	IF NOT EH_Internal.Breaker_On THEN
		EH_Output.MainBreaker := TRUE;
		EH_Internal.Timer_Breaker_On.IN := EH_Input.BreakerFB;
		IF EH_Internal.Timer_Breaker_On.Q THEN
			EH_Internal.Breaker_On := TRUE;
		END_IF;
	END_IF;
	
	(* Omoguci PID i filter *)
	EH_Internal.PID_Controller.Enable := TRUE;
	EH_Internal.Temp_Filter.Enable := TRUE;
	
	IF EH_Output.Alarm OR NOT EH_Internal.Breaker_On THEN
		(* Iskljuci sve grejace u slucaju alarma ili ako breaker nije spreman *)
		EH_Internal.Breaker_On := FALSE;
		FOR EH_Internal.i := 0 TO EH_Constant.MAX_HEATERS-1 BY 1 DO
			EH_Output.HeaterOn[EH_Internal.i] := FALSE;
		END_FOR;
		EH_Output.AnalogOut := 0;
		EH_Output.PWMOut := 0.0;
		EH_Output.PowerConsumption := 0.0;
		EH_Internal.Demand_Percent := 0.0;
		EH_Output.Status := EH_Constant.STATUS_ALARM_OR_WAIT; (* Alarm ili breaker nije spreman *)
	ELSE
		(* Filtriranje temperature *)
		EH_Internal.Temp_Filter.Update := EH_Internal.Filter_Init_Pending;
		EH_Internal.Temp_Filter.In := EH_Input.TempOut;
		EH_Internal.Temp_Filter();
		IF EH_Internal.Filter_Init_Pending THEN
			EH_Internal.Filter_Init_Pending := FALSE;
		END_IF;
		
		(* PID kontrola *)
		EH_Internal.PID_Controller.IntegrationPartPresetValue := 0.0;
		EH_Internal.PID_Controller.SetIntegrationPart := EH_Internal.PID_Init_Pending;
		EH_Internal.PID_Controller.SetValue := EH_Input.Setpoint;
		EH_Internal.PID_Controller.ActValue := EH_Internal.Temp_Filter.Out;
		EH_Internal.PID_Controller();
		IF EH_Internal.PID_Init_Pending THEN
			EH_Internal.PID_Init_Pending := FALSE;
		END_IF;
		
		EH_Internal.Demand_Percent := EH_Internal.PID_Controller.Out;

		(* Globalni clamp da zahtev uvek ostane u opsegu 0..100% *)
		IF EH_Internal.Demand_Percent > 100.0 THEN
			EH_Internal.Demand_Percent := 100.0;
		ELSIF EH_Internal.Demand_Percent < 0.0 THEN
			EH_Internal.Demand_Percent := 0.0;
		END_IF;
		
		(* Korekcija za protok ako je protokomer aktivan *)
		IF EH_Param.ActiveFlowMeter AND (EH_Param.FlowNominal > 0.0) THEN
			IF EH_Input.FlowRate < EH_Param.FlowNominal THEN
				EH_Internal.Demand_Percent := EH_Internal.Demand_Percent * (EH_Input.FlowRate / EH_Param.FlowNominal);
			END_IF;
			(* Ogranici na 0-100% *)
			IF EH_Internal.Demand_Percent > 100.0 THEN
				EH_Internal.Demand_Percent := 100.0;
			ELSIF EH_Internal.Demand_Percent < 0.0 THEN
				EH_Internal.Demand_Percent := 0.0;
			END_IF;
		END_IF;
		
		(* Izlaz u zavisnosti od tipa *)
		CASE EH_Param.OutputType OF
			0: (* Analog *)
				EH_Output.AnalogOut := REAL_TO_INT(INT_TO_REAL(EH_Param.AnalogMin) + (INT_TO_REAL(EH_Param.AnalogMax) - INT_TO_REAL(EH_Param.AnalogMin)) * (EH_Internal.Demand_Percent / 100.0));
				EH_Output.PWMOut := 0.0;
				FOR EH_Internal.i := 0 TO EH_Internal.NumHeaters_Valid-1 BY 1 DO
					EH_Output.HeaterOn[EH_Internal.i] := TRUE;
				END_FOR;
				FOR EH_Internal.i := EH_Internal.NumHeaters_Valid TO EH_Constant.MAX_HEATERS-1 BY 1 DO
					EH_Output.HeaterOn[EH_Internal.i] := FALSE;
				END_FOR;
			1: (* PWM *)
				EH_Output.AnalogOut := 0;
				IF (EH_Internal.NumHeaters_Valid > 0) AND (EH_Param.PWM_Width > 0.0) THEN
					EH_Output.PWMOut := EH_Internal.Demand_Percent / 100.0;
					EH_Internal.Phase := EH_Internal.Phase + EH_Param.ScanTime / EH_Param.PWM_Width;
					IF EH_Internal.Phase >= 1.0 THEN
						EH_Internal.Phase := EH_Internal.Phase - 1.0;
					END_IF;
					FOR EH_Internal.i := 0 TO EH_Internal.NumHeaters_Valid-1 BY 1 DO
						EH_Internal.local_phase := EH_Internal.Phase + INT_TO_REAL(EH_Internal.i) * (1.0 / INT_TO_REAL(EH_Internal.NumHeaters_Valid));
						IF EH_Internal.local_phase >= 1.0 THEN
							EH_Internal.local_phase := EH_Internal.local_phase - 1.0;
						END_IF;
						IF EH_Internal.local_phase < EH_Internal.Demand_Percent / 100.0 THEN
							EH_Output.HeaterOn[EH_Internal.i] := TRUE;
						ELSE
							EH_Output.HeaterOn[EH_Internal.i] := FALSE;
						END_IF;
					END_FOR;
				ELSE
					(* Nedvosmislen fallback: neispravna PWM konfiguracija -> svi grejaci OFF *)
					EH_Output.PWMOut := 0.0;
					FOR EH_Internal.i := 0 TO EH_Constant.MAX_HEATERS-1 BY 1 DO
						EH_Output.HeaterOn[EH_Internal.i] := FALSE;
					END_FOR;
				END_IF;
				FOR EH_Internal.i := EH_Internal.NumHeaters_Valid TO EH_Constant.MAX_HEATERS-1 BY 1 DO
					EH_Output.HeaterOn[EH_Internal.i] := FALSE;
				END_FOR;
		ELSE
			(* Nepodrzan tip izlaza: svi izlazi se gase radi bezbednosti. *)
			EH_Output.AnalogOut := 0;
			EH_Output.PWMOut := 0.0;
			FOR EH_Internal.i := 0 TO EH_Constant.MAX_HEATERS-1 BY 1 DO
				EH_Output.HeaterOn[EH_Internal.i] := FALSE;
			END_FOR;
		END_CASE;
		
		(* Potrosnja energije *)
		EH_Output.PowerConsumption := INT_TO_REAL(EH_Internal.NumHeaters_Valid) * EH_Param.HeaterPower * (EH_Internal.Demand_Percent / 100.0);
		EH_Output.Status := EH_Constant.STATUS_RUNNING; (* Normalan rad *)
	END_IF;
ELSE
	(* ================================= *)
	(* 6) Logika kada je blok onemogucen *)
	(* ================================= *)
	(* Onemoguci PID i filter *)
	EH_Internal.PID_Controller.Enable := FALSE;
	EH_Internal.Temp_Filter.Enable := FALSE;
	EH_Internal.PID_Controller.SetIntegrationPart := FALSE;
	EH_Internal.Temp_Filter.Update := FALSE;
	
	(* Iskljuci sve kada nije omoguceno *)
	EH_Internal.Breaker_On := FALSE;
	EH_Internal.Fault_Latched := FALSE;
	EH_Internal.PID_Init_Pending := FALSE;
	EH_Internal.Filter_Init_Pending := FALSE;
	FOR EH_Internal.i := 0 TO EH_Constant.MAX_HEATERS-1  BY 1 DO
		EH_Output.HeaterOn[EH_Internal.i] := FALSE;
	END_FOR;
	EH_Output.AnalogOut := 0;
	EH_Output.PWMOut := 0.0;
	EH_Output.PowerConsumption := 0.0;
	EH_Internal.Demand_Percent := 0.0;
	EH_Output.Alarm := FALSE;
	EH_Output.Status := EH_Constant.STATUS_DISABLED; (* Blok nije aktivan *)
	
	(* Sekvenca iskljucivanja prekidaca *)
	EH_Internal.Timer_Breaker_Off.IN := TRUE;
	IF EH_Internal.Timer_Breaker_Off.Q THEN
		EH_Output.MainBreaker := FALSE;
	ELSE
		EH_Output.MainBreaker := TRUE;
	END_IF;
END_IF;

(* ================================================= *)
(* 7) Tekstualni opisi stanja za HMI i dijagnostiku *)
(* ================================================= *)
CASE EH_Output.Status OF
	0:
		EH_Output.StatusText := 'RUNNING_NORMAL';
	1:
		IF NOT EH_Internal.ConfigValid THEN
			EH_Output.StatusText := 'ALARM_CONFIG';
		ELSIF EH_Internal.Fault_Latched THEN
			EH_Output.StatusText := 'ALARM_BREAKER_FB';
		ELSIF EH_Internal.Timer_Over_Temp.Q THEN
			EH_Output.StatusText := 'ALARM_OVER_TEMP';
		ELSIF EH_Internal.Timer_No_Flow.Q THEN
			EH_Output.StatusText := 'ALARM_NO_FLOW';
		ELSIF NOT EH_Internal.Breaker_On THEN
			EH_Output.StatusText := 'ALARM_BREAKER_WAIT';
		ELSE
			EH_Output.StatusText := 'ALARM_GENERAL';
		END_IF;
	2:
		EH_Output.StatusText := 'DISABLED';
ELSE
	EH_Output.StatusText := 'UNKNOWN_STATUS';
END_CASE;

CASE EH_Param.OutputType OF
	0: EH_Output.OutputTypeText := 'ANALOG_OUT';
	1: EH_Output.OutputTypeText := 'PWM_OUT';
ELSE
	EH_Output.OutputTypeText := 'UNKNOWN';
END_CASE;

IF EH_Output.Status = EH_Constant.STATUS_DISABLED THEN
	EH_Output.AlarmCauseText := 'DISABLED_BY_ENABLE';
ELSIF EH_Output.Status <> EH_Constant.STATUS_ALARM_OR_WAIT THEN
	EH_Output.AlarmCauseText := 'NONE';
ELSIF NOT EH_Internal.ConfigValid THEN
	EH_Output.AlarmCauseText := 'CONFIG_INVALID';
ELSIF EH_Internal.Fault_Latched THEN
	EH_Output.AlarmCauseText := 'BREAKER_FB_LOST';
ELSIF EH_Internal.Timer_Over_Temp.Q THEN
	EH_Output.AlarmCauseText := 'OVER_TEMP';
ELSIF EH_Internal.Timer_No_Flow.Q THEN
	EH_Output.AlarmCauseText := 'NO_FLOW';
ELSIF NOT EH_Internal.Breaker_On THEN
	EH_Output.AlarmCauseText := 'BREAKER_NOT_READY';
ELSIF (EH_Param.OutputType = 1) AND ((EH_Internal.NumHeaters_Valid <= 0) OR (EH_Param.PWM_Width <= 0.0)) THEN
	EH_Output.AlarmCauseText := 'PWM_CONFIG_INVALID';
ELSIF (EH_Param.OutputType <> 0) AND (EH_Param.OutputType <> 1) THEN
	EH_Output.AlarmCauseText := 'INVALID_OUTPUT_TYPE';
ELSE
	EH_Output.AlarmCauseText := 'ALARM';
END_IF;

EH_Output.ConfigValid := EH_Internal.ConfigValid;
EH_Output.ConfigFaultText := EH_Internal.ConfigFaultText;

(* Standardni izlazi State i State_comment uskladjeni sa Status logikom. *)
CASE EH_Output.Status OF
	0:
		EH_Output.State := 1;
		EH_Output.State_comment := 'ST_ACTIVE - normalan rad protocnog grejaca';
	1:
		EH_Output.State := 2;
		EH_Output.State_comment := 'ST_ALARM_OR_WAIT - cekanje uslova ili aktivan alarm';
	2:
		EH_Output.State := 0;
		EH_Output.State_comment := 'ST_DISABLED - blok nije omogucen';
ELSE
	EH_Output.State := 255;
	EH_Output.State_comment := 'ST_UNKNOWN - nepoznato stanje';
END_CASE;

(* Pozovi tajmere *)
EH_Internal.Timer_No_Flow();
EH_Internal.Timer_Over_Temp();
EH_Internal.Timer_Breaker_On();
EH_Internal.Timer_Breaker_Off();

END_FUNCTION_BLOCK
