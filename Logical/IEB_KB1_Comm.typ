TYPE
	ST_VALVE_PV_ACT : STRUCT
		iREF_RAW : INT;
		rREF : REAL;
		iFB_RAW : INT;
		rFB_SCALED : REAL;
	END_STRUCT;
	ST_VALVE_ACT_TYPE : STRUCT
		iSTATUS : INT;
		xOPEN_FB : BOOL;
		xCLOSE_FB : BOOL;
		xREQUEST : BOOL;
		xSET : BOOL;
		xVALVE_ALARM : BOOL;
		xAlarm_RESET : BOOL;
		iCounter_Act : UDINT;
		xCounter_RESET : BOOL;
		T_MAX_Preclosing_ms : UDINT;
		T_MIN_Closing_ms : UDINT;
		T_MAX_Closing_ms : UDINT;
		T_MAX_Preopening_ms : UDINT;
		T_MIN_Opening_ms : UDINT;
		T_MAX_Opening_ms : UDINT;
		T_Preopening_ms : UDINT;
		T_Opening_ms : UDINT;
		T_Preclosing_ms : UDINT;
		T_Closing_ms : UDINT;
		xMANUAL_SET : BOOL;
		xMODE_AUTO_MAN : BOOL;
	END_STRUCT;
	ST_SENSORS_TYPE : STRUCT
		_00_raw_value : INT;
		_01_value : REAL;
		_02_status : BOOL;
	END_STRUCT;
	ST_SENSORS_K_TYPE : STRUCT
		_00_raw_value : INT;
		_01_value : REAL;
		_02_status : BOOL;
		_03_CB_1 : BOOL;
		_04_CB_2 : BOOL;
	END_STRUCT;
	ST_PUMP : STRUCT
		x_RUN : BOOL;
		xAL : BOOL;
		xAL_RST : BOOL;
		rFR_REF_scaled : REAL;
		iFR_REF_raw : INT;
	END_STRUCT;
	ST_MAN_VALVE : STRUCT
		xCLOSE_FB : BOOL;
		xOPEN_FB : BOOL;
		xALARM_RESET : BOOL;
		rALARM_DELAY_PT : REAL;
		rALARM_ET : REAL;
		xALARM : BOOL;
		iSTATUS : INT;
	END_STRUCT;
	Sens_Tt_type : STRUCT
		B_00 : ST_SENSORS_TYPE;
		B_01 : ST_SENSORS_TYPE;
		B_02 : ST_SENSORS_TYPE;
		B_101 : ST_SENSORS_TYPE;
		B_111 : ST_SENSORS_TYPE;
		B_201 : ST_SENSORS_TYPE;
	END_STRUCT;
	Sens_Pt_type : STRUCT
		B_00 : ST_SENSORS_TYPE;
		B_01 : ST_SENSORS_TYPE;
		B_02 : ST_SENSORS_TYPE;
		B_101 : ST_SENSORS_TYPE;
		B_102 : ST_SENSORS_TYPE;
		B_103 : ST_SENSORS_TYPE;
		B_111 : ST_SENSORS_TYPE;
		B_112 : ST_SENSORS_TYPE;
		B_113 : ST_SENSORS_TYPE;
		B_140 : ST_SENSORS_TYPE;
		B_200 : ST_SENSORS_TYPE;
		B_201 : ST_SENSORS_TYPE;
		B_521 : ST_SENSORS_TYPE;
	END_STRUCT;
	Sens_Power_type : STRUCT
		Fuse_DC : BOOL;
		Fuse_AC : BOOL;
		Suply_24VDC_1 : BOOL;
		Suply_24VDC_2 : BOOL;
		DC_UPS_1 : BOOL;
		DC_UPS_2 : BOOL;
	END_STRUCT;
	Sens_pH_type : STRUCT
		proba : ST_SENSORS_TYPE;
	END_STRUCT;
	Sens_MP_type : STRUCT
		B_01 : ST_SENSORS_TYPE;
		B_02 : ST_SENSORS_TYPE;
	END_STRUCT;
	Sens_LS_type : STRUCT
		B_01 : BOOL;
		B_101 : BOOL;
		B_102 : BOOL;
		B_111 : BOOL;
		B_112 : BOOL;
		B_201 : BOOL;
		B_301 : BOOL;
	END_STRUCT;
	Sens_K_type : STRUCT
		proba : ST_SENSORS_TYPE;
	END_STRUCT;
	Sens_type : STRUCT
		Pt : Sens_Pt_type;
		Tt : Sens_Tt_type;
		LS : Sens_LS_type;
		MP : Sens_MP_type;
		K : Sens_K_type;
		pH : Sens_pH_type;
		Power : Sens_Power_type;
	END_STRUCT;
	Cntrl_Comm_Podstanica_type : STRUCT
		Zahtev : typPodstanicaZahtev;
		Parametri : typPodstanicaParametri;
		Status : typPodstanicaStatus;
	END_STRUCT;
	typPodstanicaZahtev : STRUCT
		ZahtevVode : BOOL;
		NivoPrihvatnogTanka : REAL;
		CiljaniProtok : REAL;
		ModRada : USINT;
	END_STRUCT;
	typPodstanicaParametri : STRUCT
		MinimalniProtok : REAL;
		MaksimalniProtok : REAL;
		MinimalnaFrekvenca : REAL;
		MaksimalnaFrekvenca : REAL;
		TolerancijaFrekvence : REAL;
	END_STRUCT;
	typPodstanicaStatus : STRUCT
		TrenutniProtok : REAL;
		TrenutnaFrekvencaPumpe : REAL;
		MinimalniProtokDostignut : BOOL;
		MaksimalniProtokDostignut : BOOL;
	END_STRUCT;
	Cntrl_Comm_BRB2_type : STRUCT
		Reserved : USINT;
	END_STRUCT;
	Cntrl_Comm_type : STRUCT
		Podstanica : Cntrl_Comm_Podstanica_type;
		BRB2 : Cntrl_Comm_BRB2_type;
	END_STRUCT;
	Cntrl_type : STRUCT
		proba : BOOL;
		State : INT;
		Comm : Cntrl_Comm_type;
	END_STRUCT;
	Act_RV_type : STRUCT
		B_01 : ST_MAN_VALVE;
		B_02 : ST_MAN_VALVE;
		B_03 : ST_MAN_VALVE;
		B_04 : ST_MAN_VALVE;
		B_06 : ST_MAN_VALVE;
		B_07 : ST_MAN_VALVE;
		B_08 : ST_MAN_VALVE;
		B_09 : ST_MAN_VALVE;
		B_10 : ST_MAN_VALVE;
		B_11 : ST_MAN_VALVE;
		B_21 : ST_MAN_VALVE;
		B_22 : ST_MAN_VALVE;
		B_23 : ST_MAN_VALVE;
		B_221 : ST_MAN_VALVE;
	END_STRUCT;
	Act_PV_type : STRUCT
		B_01 : ST_VALVE_PV_ACT;
		B_201 : ST_VALVE_PV_ACT;
	END_STRUCT;
	Act_Pu_type : STRUCT
		B_101 : ST_PUMP;
		B_111 : ST_PUMP;
		B_201 : ST_PUMP;
		B_211 : ST_PUMP;
		B_RB1 : ST_PUMP;
	END_STRUCT;
	Act_AV_type : STRUCT
		B_00 : ST_VALVE_ACT_TYPE;
		B_02 : ST_VALVE_ACT_TYPE;
		B_100 : ST_VALVE_ACT_TYPE;
		B_101 : ST_VALVE_ACT_TYPE;
		B_102 : ST_VALVE_ACT_TYPE;
		B_103 : ST_VALVE_ACT_TYPE;
		B_104 : ST_VALVE_ACT_TYPE;
		B_105 : ST_VALVE_ACT_TYPE;
		B_106 : ST_VALVE_ACT_TYPE;
		B_107 : ST_VALVE_ACT_TYPE;
		B_108 : ST_VALVE_ACT_TYPE;
		B_111 : ST_VALVE_ACT_TYPE;
		B_112 : ST_VALVE_ACT_TYPE;
		B_113 : ST_VALVE_ACT_TYPE;
		B_114 : ST_VALVE_ACT_TYPE;
		B_115 : ST_VALVE_ACT_TYPE;
		B_116 : ST_VALVE_ACT_TYPE;
		B_117 : ST_VALVE_ACT_TYPE;
		B_118 : ST_VALVE_ACT_TYPE;
		B_200 : ST_VALVE_ACT_TYPE;
		B_201 : ST_VALVE_ACT_TYPE;
		B_202 : ST_VALVE_ACT_TYPE;
		B_203 : ST_VALVE_ACT_TYPE;
		B_204 : ST_VALVE_ACT_TYPE;
		B_205 : ST_VALVE_ACT_TYPE;
		B_211 : ST_VALVE_ACT_TYPE;
		B_212 : ST_VALVE_ACT_TYPE;
		B_213 : ST_VALVE_ACT_TYPE;
		B_214 : ST_VALVE_ACT_TYPE;
		B_215 : ST_VALVE_ACT_TYPE;
		B_220 : ST_VALVE_ACT_TYPE;
		B_301 : ST_VALVE_ACT_TYPE;
		B_U22 : ST_VALVE_ACT_TYPE;
		B_U23 : ST_VALVE_ACT_TYPE;
	END_STRUCT;
	Act_type : STRUCT
		AV : Act_AV_type;
		RV : Act_RV_type;
		PV : Act_PV_type;
		Pu : Act_Pu_type;
	END_STRUCT;
	IEB_KB1_type : STRUCT
		Act : Act_type;
		Sens : Sens_type;
		Cntrl : Cntrl_type;
	END_STRUCT;
END_TYPE