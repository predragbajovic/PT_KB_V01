TYPE
	CanIn : 	STRUCT 
		b_NodeState : BOOL; (*Status Noda CAN uredjaja na mrezi*)
		w_StatusReg : UINT; (*Status registar - statusna recenica*)
		w_MotorStruja : UINT; (*Trenutna struja motora u 0,1A *)
		w_MotorBrz : INT; (*Trenutna brzina motora u obrt/min *)
		w_MotorSnaga : INT; (*Trenutna snaga motora u % *)
	END_STRUCT;
	CanOut : 	STRUCT 
		w_ControlReg : UINT; (*Kontrolni registar - kontrolna recenica*)
		w_ZadataBrz : INT; (*Brzina koja se salje na regulator u obrt/min*)
	END_STRUCT;
END_TYPE