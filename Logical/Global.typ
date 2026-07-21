
TYPE
	PG_type : 	STRUCT  (* Korenski tip objekta: Podstanica grejanja 1, Kursumlijska Banja *)
		Act : PG_Act_type; (* Aktuatori podstanice: pumpe, ventili *)
		Sens : PG_Sens_type; (* Senzori podstanice: pritisak, temperatura, protok, nivo *)
	END_STRUCT;
	PG_Act_type : 	STRUCT  (* Svi aktuatori podstanice PG *)
		Pu : PG_Act_Pu_type; (* Pumpe za snabdevanje potrosaca, Grundfoss CR45, METOD_DIO, 0-50 Hz *)
		PV : PG_Act_PV_type; (* Proporcionalni membranski ventili Burkert, AI/AO 4-20mA *)
		AV : PG_Act_AV_type; (* Automatski leptir ventili End Armaturen DN125 *)
		RV : PG_Act_RV_type; (* Rucni leptir ventili sa 2 krajnja prekidaca, monitoring pozicije *)
	END_STRUCT;
	PG_Sens_type : 	STRUCT  (* Svi senzori podstanice PG *)
		Pt : PG_Sens_Pt_type; (* Senzori pritiska termalne vode, Cerabar PMP23, 4-20mA *)
		Tt : PG_Sens_Tt_type; (* Senzori temperature termalne vode, Easytemp TMR35, 4-20mA *)
		MP : PG_Sens_MP_type; (* Meraci protoka termalne vode, Promag H10, 4-20mA *)
		LS : PG_Sens_LS_type; (* Nivo prekidaci u prihvatnom tanku i odzracnim cilindrima *)
		OWF : PG_Sens_OWF_type; (* Zastitni prestrujni ventili od hidraulickog udara *)
	END_STRUCT;
	PG_Act_Pu_type : 	STRUCT  (* Pumpe za snabdevanje potrosaca + vfdMain FB instance *)
		_1 : VFD_type; (* Pumpa za snabdevanje potrosaca 01, Grundfoss CR45 *)
		_2 : VFD_type; (* Pumpa za snabdevanje potrosaca 02, Grundfoss CR45 *)
		VFD_function : PG_Act_Pu_VFD_func_type; (* vfdMain FB instance za obe pumpe, METOD_DIO *)
	END_STRUCT;
	PG_Act_Pu_VFD_func_type : 	STRUCT  (* vfdMain FB instance za upravljanje frekventnim regulatorima pumpi, 0-50 Hz *)
		_1 : vfdMain; (* vfdMain FB za Pumpu 01, addr_struct inicijalizovan u IO_Init *)
		_2 : vfdMain; (* vfdMain FB za Pumpu 02, addr_struct inicijalizovan u IO_Init *)
	END_STRUCT;
	PG_Act_PV_type : 	STRUCT  (* Proporcionalni membranski ventili Burkert, AI povratni + AO komanda, 4-20mA *)
		_1 : FB_PvAiAo_Fast; (* Ulazni regulacioni ventil 1 - prihvatni tank, DN050 NC *)
		_2 : FB_PvAiAo_Fast; (* Ulazni regulacioni ventil 2 - prihvatni tank, DN050 NC *)
		_3 : FB_PvAiAo_Fast; (* Odzracni ventil na ulazu termalne vode u kotlarnicu, DN025 NC *)
		_4 : FB_PvAiAo_Fast; (* Odzracni ventil na ulazu termalne vode u prihvatni tank, DN025 NC *)
	END_STRUCT;
	PG_Act_AV_type : 	STRUCT  (* Automatski leptir ventili End Armaturen DN125, bistabilni i spring-return *)
		_1 : FB_V_EMV; (* Elektromotorni bistabilni, CmdOpen + CmdClose, OpenMaxTime=30s *)
		_2 : FB_V_EMV; (* Elektromotorni bistabilni, CmdOpen + CmdClose, OpenMaxTime=30s *)
		_3 : FB_V_ON_OFF_FB; (* Pneumatski NC spring-return, samo CmdOpen, OpenMaxTime=10s *)
		_4 : FB_V_ON_OFF_FB; (* Pneumatski NC spring-return, samo CmdOpen, OpenMaxTime=10s *)
	END_STRUCT;
	PG_Act_RV_type : 	STRUCT  (* Rucni leptir ventili NIOB FLUID / End Armaturen, monitoring 2 krajnja prekidaca *)
		_16 : FB_HV_2LS; (* Bajpasni ventil regulacije pritiska u cevovodu na ulazu tople vode u prihvatni tank *)
		_18 : FB_HV_2LS; (* Rucni ventil pre membranskog ventila PG_PV01 *)
		_19 : FB_HV_2LS; (* Rucni ventil posle membranskog ventila PG_PV01 *)
		_20 : FB_HV_2LS; (* Rucni ventil pre membranskog ventila PG_PV02 *)
		_21 : FB_HV_2LS; (* Rucni ventil posle membranskog ventila PG_PV02 *)
		_22 : FB_HV_2LS; (* Drenazni total ventil na dnu prihvatnog tanka *)
		_23 : FB_HV_2LS; (* Ulaz u Pumpu PG_Pu01 *)
		_24 : FB_HV_2LS; (* Ulaz u Pumpu PG_Pu02 *)
		_25 : FB_HV_2LS; (* Bajpasni izlaz iz tanka ka instalaciji za izbacivanje gasa van kotlarnice *)
		_26 : FB_HV_2LS; (* Ulaz u vakuum pumpu *)
		_27 : FB_HV_2LS; (* Izlaz iz vakuum pumpe ka instalaciji za izbacivanje gasa van kotlarnice *)
	END_STRUCT;
	PG_Sens_Pt_type : 	STRUCT  (* Senzori pritiska termalne vode, 8x FBAI01_DI01, Cerabar PMP23, 4-20mA, opseg -1..9 bar / -100..300 mbar / -1..14 bar *)
		_0_0 : FBAI01_DI01; (* Pritisak komprimovanog vazduha, opseg -1..14 bar *)
		_1 : FBAI01_DI01; (* Pritisak termalne vode na ulazu u podstanicu *)
		_2 : FBAI01_DI01; (* Pritisak termalne vode posle streinera grubih filtera *)
		_3 : FBAI01_DI01; (* Pritisak termalne vode posle velikog izmenjivaca *)
		_4 : FBAI01_DI01; (* Pritisak termalne vode na ulazu u prihvatni tank *)
		_5 : FBAI01_DI01; (* Pritisak na potisu transportnih pumpi *)
		_NS1 : FBAI01_DI01; (* Pritisak na dnu prihvatnog tanka [mbar] *)
		_NS2 : FBAI01_DI01; (* Pritisak na vrhu prihvatnog tanka [mbar] *)
	END_STRUCT;
	PG_Sens_Tt_type : 	STRUCT  (* Senzori temperature termalne vode, 3x FBAI01_DI01, Easytemp TMR35, 4-20mA, opseg 0-120 degC *)
		_1 : FBAI01_DI01; (* Temperatura na ulazu termalne vode u podstanicu *)
		_2 : FBAI01_DI01; (* Temperatura termalne vode posle izmenjivaca *)
		_3 : FBAI01_DI01; (* Temperatura termalne vode u distributivnom tanku *)
	END_STRUCT;
	PG_Sens_MP_type : 	STRUCT  (* Meraci protoka, 1x FBAI01_DI01, Promag H10 DN065, 4-20mA, opseg 0-72 m3/h *)
		_1 : FBAI01_DI01; (* Merač protoka na potisu tople termalne vode ka potrosacima *)
	END_STRUCT;
	PG_Sens_LS_type : 	STRUCT  (* Nivo prekidaci Liquipoint FTW23, 5x FB_DI, detekcija tecnosti u prihvatnom tanku i odzracnim cilindrima *)
		_1 : FB_DI; (* Nizak nivo vode u prihvatnom tanku za rad pumpi *)
		_2 : FB_DI; (* Donji nivo u odzracnom cilindru na ulazu vode u podstanicu *)
		_3 : FB_DI; (* Gornji nivo u odzracnom cilindru na ulazu vode u podstanicu *)
		_4 : FB_DI; (* Donji nivo u odzracnom cilindru na ulazu vode u prihvatni tank *)
		_5 : FB_DI; (* Gornji nivo u odzracnom cilindru na ulazu vode u prihvatni tank *)
	END_STRUCT;
	PG_Sens_OWF_type : 	STRUCT  (* Zastitni prestrujni ventili NIOB FLUID 5371 DN050, 2x FB_DI, zastita od hidraulickog udara *)
		_1 : FB_DI; (* Zastitni prestrujni ventil od hidraulickog udara 1 *)
		_2 : FB_DI; (* Zastitni prestrujni ventil od hidraulickog udara 2 *)
	END_STRUCT;
END_TYPE
