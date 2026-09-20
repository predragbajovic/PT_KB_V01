FUNCTION_BLOCK FbCanAtv
	AtvCanOut.w_ZadataBrz:=REAL_TO_INT(w_ZadataBrzHz*60);	//Brzina se na Atv zadaje u Obrt/min
	(* Provera zadate brzine u opsegu Min-Max *)
	IF w_ZadataBrzHz<w_FR_min THEN AtvCanOut.w_ZadataBrz:= REAL_TO_INT(w_FR_min*60); END_IF
	IF w_ZadataBrzHz>w_FR_max THEN AtvCanOut.w_ZadataBrz:= REAL_TO_INT(w_FR_max*60); END_IF
	
	w_MotorStruja:= UINT_TO_REAL (AtvCanIn.w_MotorStruja) /10;
	w_MotorBrz:= INT_TO_REAL(AtvCanIn.w_MotorBrz)/60;
	w_MotorSnaga:=w_NomSnaga * (INT_TO_REAL(AtvCanIn.w_MotorSnaga))/100; //AtvCanIn.w_MotorSnaga se prima u %
		
	b_StatusBit00:=	AtvCanIn.w_StatusReg.0;
	b_StatusBit01:=	AtvCanIn.w_StatusReg.1;
	b_StatusBit02:=	AtvCanIn.w_StatusReg.2;
	b_StatusBit03:=	AtvCanIn.w_StatusReg.3;
	b_StatusBit04:=	AtvCanIn.w_StatusReg.4;
	b_StatusBit05:=	AtvCanIn.w_StatusReg.5;
	b_StatusBit06:=	AtvCanIn.w_StatusReg.6;
	b_StatusBit07:=	AtvCanIn.w_StatusReg.7;
	
	b_StatusDissable:=		NOT(b_StatusBit00) AND NOT(b_StatusBit01) AND NOT(b_StatusBit02) AND NOT(b_StatusBit03) AND b_StatusBit06; 
	b_StatusSwitchReady:=	b_StatusBit00 AND NOT(b_StatusBit01) AND NOT(b_StatusBit02) AND NOT(b_StatusBit03) AND b_StatusBit05 AND NOT(b_StatusBit06); 
	b_StatusSwitchOn:=		b_StatusBit00 AND b_StatusBit01 AND NOT(b_StatusBit02) AND NOT(b_StatusBit03) AND b_StatusBit05 AND NOT(b_StatusBit06);
	b_Alarm_CAN:=			NOT(AtvCanIn.b_NodeState);
	b_Alarm_FR:=			b_StatusBit03 AND b_Enable;
	b_Running:=				b_StatusBit00 AND b_StatusBit01 AND b_StatusBit02 AND NOT(b_StatusBit03) AND b_StatusBit05 AND NOT(b_StatusBit06);
		
	IF b_Enable AND NOT(b_StatusSwitchOn) THEN
		IF b_StatusDissable THEN AtvCanOut.w_ControlReg:=6; END_IF //Prebacivanje Atv u stanje SwitchReady 
		IF b_StatusSwitchReady THEN AtvCanOut.w_ControlReg:=7; END_IF //Prebacivanje Atv u stanje SwitchOn 
	END_IF
	AtvCanOut.w_ControlReg.3:= b_Enable AND b_Start AND (b_StatusSwitchOn OR b_Running);
	//IF NOT(b_Enable) OR b_Alarm_CAN OR b_Alarm_FR THEN AtvCanOut.w_ControlReg:=0; END_IF
	IF NOT(b_Enable) THEN AtvCanOut.w_ControlReg:=0; END_IF	
	AtvCanOut.w_ControlReg.7:=b_AlarmRst;
END_FUNCTION_BLOCK