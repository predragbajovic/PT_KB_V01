FUNCTION_BLOCK FbCanAtv (*** 	FB za upravljanje ATV Schneider frekventnim regulatorima preko CanOpena	***)
	VAR_INPUT
		AtvCanIn : CanIn; (*Ulazna struktura u CAN FB iz frekventnog regulatora*)
		w_ZadataBrzHz : REAL; (*Zadata brzina u 0,1Hz *)
		w_FR_min : REAL; (*Zadata minimalna brzina u 0,1Hz *)
		w_FR_max : REAL; (*Zadata maksimalna brzina u 0,1Hz *)
		w_NomSnaga : REAL; (*Zadata nominalna snaga frekventnog u kW *)
		b_Enable : BOOL;
		b_Start : BOOL;
		b_AlarmRst : BOOL;
	END_VAR
	VAR_OUTPUT
		AtvCanOut : CanOut;
		w_MotorStruja : REAL; (*Trenutna struja motora u A *)
		w_MotorBrz : REAL; (*Trenutna broj obrtaja motora prevedena u Hz*)
		w_MotorSnaga : REAL; (*Trenutna snaga motora u kW*)
		b_Alarm_FR : BOOL; (*Alarm frekventnog regulatora*)
		b_Alarm_CAN : BOOL; (*Alarm CAN komunikacije*)
		b_Running : BOOL; (*In run status frekventnog regulatora*)
	END_VAR
	VAR
		b_StatusBit00 : BOOL;
		b_StatusBit01 : BOOL;
		b_StatusBit02 : BOOL;
		b_StatusBit03 : BOOL;
		b_StatusBit04 : BOOL;
		b_StatusBit05 : BOOL;
		b_StatusBit06 : BOOL;
		b_StatusBit07 : BOOL;
		b_StatusDissable : BOOL;
		b_StatusSwitchReady : BOOL;
		b_StatusSwitchOn : BOOL;
	END_VAR
END_FUNCTION_BLOCK