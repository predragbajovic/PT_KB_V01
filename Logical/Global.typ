
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
		_5 : FB_PvAiAo_Fast; (* Dodatni proporcionalni ventil, Fast varijanta kao ostali PV kanali *)
	END_STRUCT;
	PG_Act_AV_type : 	STRUCT  (* Automatski leptir ventili End Armaturen DN125, bistabilni i spring-return *)
		_1 : FB_V_EMV; (* Elektromotorni bistabilni, CmdOpen + CmdClose, OpenMaxTime=20s *)
		_2 : FB_V_EMV; (* Elektromotorni bistabilni, CmdOpen + CmdClose, OpenMaxTime=20s *)
		_3 : FB_V_ON_OFF_FB; (* Pneumatski NC spring-return, samo CmdOpen, OpenMaxTime=10s *)
		_4 : FB_V_ON_OFF_FB; (* Pneumatski NC spring-return, samo CmdOpen, OpenMaxTime=10s *)
		_5 : FB_V_ON_OFF_FB; (* Pneumatski NC spring-return, samo CmdOpen, OpenMaxTime=10s *)
		_6 : FB_V_ON_OFF_FB; (* Pneumatski NC spring-return, samo CmdOpen, OpenMaxTime=10s *)
		_7 : FB_V_ON_OFF_FB; (* Pneumatski NC spring-return, samo CmdOpen, OpenMaxTime=10s *)
	END_STRUCT;
	PG_Act_RV_type : 	STRUCT  (* Rucni leptir ventili NIOB FLUID / End Armaturen, monitoring 2 krajnja prekidaca *)
		_19 : FB_HV_2LS; (* Rucni ventil posle membranskog ventila PG_PV01 *)
		_21 : FB_HV_2LS; (* Rucni ventil posle membranskog ventila PG_PV02 *)
		_22 : FB_HV_2LS; (* Drenazni total ventil na dnu prihvatnog tanka *)
		_23 : FB_HV_2LS; (* Ulaz u Pumpu PG_Pu01 *)
		_24 : FB_HV_2LS; (* Ulaz u Pumpu PG_Pu02 *)
		_25 : FB_HV_2LS; (* Bajpasni izlaz iz tanka ka instalaciji za izbacivanje gasa van kotlarnice *)
		_26 : FB_HV_2LS; (* Ulaz u vakuum pumpu *)
		_27 : FB_HV_2LS; (* Izlaz iz vakuum pumpe ka instalaciji za izbacivanje gasa van kotlarnice *)
	END_STRUCT;
	PG_Sens_Pt_type : 	STRUCT  (* Senzori pritiska termalne vode, 9x FBAI01_DI01, Cerabar PMP23, 4-20mA, opseg -1..9 bar / -100..300 mbar / -1..14 bar *)
		_0_0 : FBAI01_DI01; (* Pritisak komprimovanog vazduha, opseg -1..14 bar *)
		_1 : FBAI01_DI01; (* Pritisak termalne vode na ulazu u podstanicu *)
		_2 : FBAI01_DI01; (* Pritisak termalne vode posle streinera grubih filtera *)
		_3 : FBAI01_DI01; (* Pritisak termalne vode posle velikog izmenjivaca *)
		_4 : FBAI01_DI01; (* Pritisak termalne vode na ulazu u prihvatni tank *)
		_5 : FBAI01_DI01; (* Pritisak na potisu transportnih pumpi *)
		_6 : FBAI01_DI01; (* Dodatni transmiter pritiska, opseg -1..9 bar *)
		_NS1 : FBAI01_DI01; (* Pritisak na dnu prihvatnog tanka [mbar] *)
		_NS2 : FBAI01_DI01; (* Pritisak na vrhu prihvatnog tanka [mbar] *)
	END_STRUCT;
	PG_Sens_Tt_type : 	STRUCT  (* Senzori temperature termalne vode, Easytemp TMR35, 4-20mA, opseg 0-120 degC *)
		_1 : FBAI01_DI01; (* TT_PG_01 - ulaz u veliki razmenjivac PGRT01. *)
		_2 : FBAI01_DI01; (* TT_PG_02 - temperatura na ulazu u prihvatni tank. *)
		_3 : FBAI01_DI01; (* TT_PG_03 - temperatura u prihvatnom tanku. *)
		_4 : FBAI01_DI01; (* TT_PG_04 - izlaz iz velikog razmenjivaca PGRT01. *)
		_5 : FBAI01_DI01; (* TT_PG_05 - ulaz u mali razmenjivac PGRT02. *)
		_6 : FBAI01_DI01; (* TT_PG_06 - izlaz iz malog razmenjivaca PGRT02. *)
		_7 : FBAI01_DI01; (* TT_PG_07 - drenazni vod za potvrdu zavrsetka preispiranja. *)
		_8 : FBAI01_DI01; (* TT_PG_08 - Ulaz tehnicke vode u direktni iztmenbjivac toplote*)
		_9 : FBAI01_DI01; (* TT_PG_09 - Izlaz tehnicke vode iz direktnog iztmenbjivaca toplote*)
		_10 : FBAI01_DI01; (* TT_PG_10 - Ulaz tsanitarne vode u direktni iztmenbjivac toplote*)
		_11 : FBAI01_DI01; (* TT_PG_11 - Izlaz sanitarne vode iz direktnog iztmenbjivaca toplote*)
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
	E_PGRad_State : 
		( (* Koraci state masine podstanice. *)
		PG_00_Stand_By,
		PG_01_Priprema_BRB2,
		PG_02_Rad_BRB2,
		PG_03_Zaustavljanje_BRB2,
		PG_11_Priprema_IEBKB1,
		PG_12_Rad_IEBKB1,
		PG_13_Zaustavljanje_IEBKB1
		);
	E_RegulacionaVarijanta : 
		(
		_00_neaktivan, (* 0 - sve ugaseno, ni jedna varijanta nije izabrana. *)
		_01_REG_PRITISAK, (* 1 - PT vodi, prati zadati pritisak. *)
		_02_REG_NIVO, (* 2 - PT vodi nivo prihvatnog tanka preko izlazne pumpe. *)
		_03_REG_TEMPERATURA (* 3 - temperatura/snaga sekundara. *)
		);
	E_SelektovaniIzvor : 
		(
		_00_IZVOR_NIJE_IZABRAN, (* 0 - nijedan izvor nije izabran. *)
		_01_BRB2, (* 1 - BRB2 kao izvor. *)
		_02_IEBKB1 (* 2 - IEBKB1 kao izvor. *)
		);
	E_AktivnaPumpaIzlazTanka : 
		(
		_00_nijedna, (* 0 - nijedna pumpa aktivna na izlazu iz tanka. *)
		_01_Pu_PG_01, (* 1 - Pu_PG_01 aktivna. *)
		_02_Pu_PG_02 (* 2 - Pu_PG_02 aktivna. *)
		);
	E_AktivniPropVentilUlazTanka : 
		(
		_00_PROP_VENTIL_NIJE_IZABRAN, (* 0 - nijedan prop. ventil nije izabran. *)
		_01_PG_PV01, (* 1 - PG_PV01 aktivan. *)
		_02_PG_PV02 (* 2 - PG_PV02 aktivan. *)
		);
	typCmdRetainUlazniVentiliPGRad : 	STRUCT 
		V01_Open : BOOL; (* PG_V01 - zapamceni zahtev IEBKB1 ulaznog ventila. *)
		V02_Open : BOOL; (* PG_V02 - zapamceni zahtev BRB2 ulaznog ventila. *)
	END_STRUCT;
	typParAirReleaseModePGRad : 	STRUCT  (* Parametri odzracivanja za jedan izvor vode. *)
		PV03 : typParAirRelease; (* Odzracivanje na ulazu termalne vode u podstanicu. *)
		PV04 : typParAirRelease; (* Odzracivanje na ulazu termalne vode u prihvatni tank. *)
	END_STRUCT;
	typParAirReleasePGRad : 	STRUCT  (* Grupisani parametri odzracivanja prema aktivnom izvoru. *)
		BRB2 : typParAirReleaseModePGRad; (* Parametri rada sa izvorom BRB2. *)
		IEBKB1 : typParAirReleaseModePGRad; (* Parametri rada sa izvorom IEBKB1. *)
	END_STRUCT;
	typParPGRad : 	STRUCT 
		SetPritisakPotisa : REAL; (* Zadati pritisak potisa glavne pumpe [bar]. *)
		MinProtok : REAL; (* Donja granica protoka. *)
		MaxProtok : REAL; (* Gornja granica protoka. *)
		MinFR_Pumpe : REAL; (* Minimalni dozvoljeni protok izlazne pumpe [l/s]. *)
		MaxFR_Pumpe : REAL; (* Maksimalni dozvoljeni protok izlazne pumpe [l/s]. *)
		SetPointNivoTanka : REAL; (* Ciljani nivo prihvatnog tanka [m]. *)
		SetPointMinTempIspiranja : REAL; (* Minimalna temperatura za zavrsetak ispiranja [degC]. *)
		SetPointPritisakPV05Ispiranje : REAL; (* PT06 SP tokom preispiranja [bar]. *)
		SetPointPritisakUlazTanka : REAL; (* PT04 SP aktivnog ulaznog ventila [bar]. *)
		SetPointMaxPritisakDolaznaCev : REAL; (* PT06 SP cuvara instalacije [bar]. *)
		T_PrelazPV05Cuvar : TIME; (* Vreme PT06 SP rampe. *)
		PocetnaFrekvencaIzlaznePumpe : REAL; (* PID tracking frekvenca pri startu [Hz]. *)
		MaxOtvorPropZaZatvaranje : REAL; (* Najveca otvorenost za potvrdu zatvaranja [%]. *)
		T_OverlapPumpi : TIME; (* Maksimalno vreme paralelnog rada pri rotaciji. *)
		T_AutoRestartDelay : TIME; (* Zadrzavanje pre automatskog starta. *)
		T_ValvePositionTimeout : TIME; (* Maksimalno vreme hoda ventila. *)
		T_InterlockDebounce : TIME; (* Vreme potvrde interlock povratnog signala. *)
		AirRelease : typParAirReleasePGRad; (* RETAIN parametri PV03/PV04 za oba izvora. *)
	END_STRUCT;
	typCtrlAirReleasePGRad : 	STRUCT  (* HMI i servisne komande jednog odzracnog ventila. *)
		EnableManual : BOOL; (* TRUE = direktna rucna komanda ima prioritet nad automatikom. *)
		ManualSP_Percent : REAL; (* Direktna rucna komanda ventila [%]. *)
		ResetAlarm : BOOL; (* Pojedinacni jednokratni reset memorisanog alarma. *)
	END_STRUCT;
	typAirReleaseChannelPGRad : 	STRUCT  (* Izvrsni FB i komande jednog odzracnog ventila. *)
		FB : FB_AirRelease; (* Instanca upravljanja odzracivanjem. *)
		Ctrl : typCtrlAirReleasePGRad; (* HMI i servisne komande instance. *)
	END_STRUCT;
	typAirReleasePGRad : 	STRUCT  (* Grupisane runtime instance odzracivanja PV03/PV04. *)
		PV03 : typAirReleaseChannelPGRad; (* Odzracivanje ulaza u podstanicu. *)
		PV04 : typAirReleaseChannelPGRad; (* Odzracivanje ulaza u prihvatni tank. *)
	END_STRUCT;
	typCtrlPGRad : 	STRUCT 
		SelektovaniIzvor : E_SelektovaniIzvor; (* Izbor izvora termalne vode. *)
		RegulacionaVarijanta : E_RegulacionaVarijanta; (* Izabrana regulaciona varijanta. *)
		AktivnaPumpaIzlazTanka : E_AktivnaPumpaIzlazTanka; (* Aktivna izlazna pumpa. *)
		AktivniPropVentilUlazTanka : E_AktivniPropVentilUlazTanka; (* Aktivni ulazni prop. ventil. *)
		AutoRestart : BOOL; (* Automatski start nakon cold boot-a. *)
	END_STRUCT;
	typManualPGRad : STRUCT
		Enable : BOOL; (* Dozvola servisnog rucnog rezima; aktivan samo u Standby. *)
		Sequence : USINT; (* Izabrana sekvenca: 1=BRB2 priprema/ispiranje, 2=IEBKB1 priprema, 3=kontrolisani stop. *)
		Start : BOOL; (* Impuls za pokretanje izabrane servisne sekvence. *)
		Stop : BOOL; (* Impuls za bezbedan prekid servisne sekvence. *)
		NextStep : BOOL; (* Impuls za zahtev sledeceg dozvoljenog podkoraka. *)
		Abort : BOOL; (* Impuls za povratak u Standby bez preskakanja stop logike. *)
	END_STRUCT;
	typCmdOnOffPGRad : 	STRUCT 
		_03_Open : BOOL; (* PG_V03 - zahtev otvaranja izlazne grane pumpe 1. *)
		_04_Open : BOOL; (* PG_V04 - zahtev otvaranja izlazne grane pumpe 2. *)
		_05_Open : BOOL; (* PG_V05 - zahtev otvaranja bypass-a/preispiranja. *)
		_06_Open : BOOL; (* PG_V06 - zahtev otvaranja grane PV01 ka tanku. *)
		_07_Open : BOOL; (* PG_V07 - zahtev otvaranja grane PV02 ka tanku. *)
	END_STRUCT;
	typCmdPropVentilPGRad : 	STRUCT 
		Enable : BOOL; (* Dozvola automatskog upravljanja ventilom. *)
		SP_Percent : REAL; (* Automatski zahtev otvorenosti 0..100%. *)
	END_STRUCT;
	typCmdPropVentiliPGRad : 	STRUCT 
		PV01 : typCmdPropVentilPGRad; (* PG_PV01 - ulazni proporcionalni ventil 1. *)
		PV02 : typCmdPropVentilPGRad; (* PG_PV02 - ulazni proporcionalni ventil 2. *)
		PV05 : typCmdPropVentilPGRad; (* PG_PV05 - drenazni proporcionalni ventil. *)
	END_STRUCT;
	typCmdAirReleaseChannelPGRad : 	STRUCT  (* Procesna dozvola jednog odzracnog ventila. *)
		Enable : BOOL; (* TRUE = dozvoljen automatski ili rucni rad FB_AirRelease. *)
	END_STRUCT;
	typCmdAirReleasePGRad : 	STRUCT  (* Komandni vektor odzracivanja iz state masine. *)
		PV03 : typCmdAirReleaseChannelPGRad; (* Dozvola odzracivanja ulaza u podstanicu. *)
		PV04 : typCmdAirReleaseChannelPGRad; (* Dozvola odzracivanja ulaza u tank. *)
		UseIEBKB1Parameters : BOOL; (* TRUE = koristi IEBKB1, FALSE = koristi BRB2 parametre. *)
		ResetAll : BOOL; (* Zajednicki reset oba FB-a iz KomandaReset. *)
	END_STRUCT;
	typCmdPumpaPGRad : 	STRUCT 
		Run : BOOL; (* Dozvola rada pumpe; frekvencu iskljucivo vodi PID_Pu_01. *)
	END_STRUCT;
	typCmdPumpePGRad : 	STRUCT 
		_01 : typCmdPumpaPGRad; (* PG_Pu01 - komandni zahtev za izlaznu pumpu 1. *)
		_02 : typCmdPumpaPGRad; (* PG_Pu02 - komandni zahtev za izlaznu pumpu 2. *)
	END_STRUCT;
	typCmdPIDPumpePGRad : 	STRUCT 
		Enable : BOOL; (* Dozvola rada jedinog PID_Pu_01 regulatora. *)
		ActValue : REAL; (* Aktivna regulisana vrednost: nivo tanka ili PT05 [m/bar]. *)
		SetValue : REAL; (* SP aktivne regulisane vrednosti [m/bar]. *)
		Invert : BOOL; (* Smer PID-a: TRUE za nivo, FALSE za pritisak. *)
		MaxOut : REAL; (* Maksimalni frekventni izlaz izabrane pumpe [Hz]. *)
		EnableTracking : BOOL; (* Dozvola bumpless starta na TrackingValue. *)
		TrackingValue : REAL; (* Pocetni frekventni zahtev PID-a pri startu [Hz]. *)
	END_STRUCT;
	typVezaPGRadBRB2 : 	STRUCT 
		RadKaPodstanici : BOOL; (* PT izbor rute BRB2 ka podstanici; prihvata se samo u BRB2 standby. *)
		ManualMode : BOOL; (* Dozvola servisnog rucnog rezima. *)
		ManualSequence : USINT; (* Izabrana servisna sekvenca. *)
		ManualStart : BOOL; (* Impuls za pokretanje servisne sekvence. *)
		ManualStop : BOOL; (* Impuls za bezbedan prekid servisne sekvence. *)
		ManualNextStep : BOOL; (* Impuls za sledeci dozvoljeni podkorak. *)
		ManualAbort : BOOL; (* Impuls za povratak u Standby. *)
		ZahtevStarta : BOOL; (* PT zahtev BRB2 za pripremu i start bunarske pumpe. *)
		ZahtevZaustavljanja : BOOL; (* PT zahtev BRB2 za kontrolisano zaustavljanje. *)
		VentiliPodstaniceZatvoreni : BOOL; (* PT potvrda zatvorenosti PG_PV01, PG_PV02 i PG_PV05. *)
		PritisakIEBKB1 : REAL; (* PT prosledjuje stvarni pritisak IEBKB1 odredista [bar]. *)
		PodstanicaURezimuRada : BOOL; (* PT tank je na nivou i izabrana izlazna pumpa je stvarno u radu. *)
		PumpaAktivna : BOOL; (* BRB2 stvarna potvrda da je RB2_01 u InRun stanju. *)
		IspiranjeProtokDostignut : BOOL; (* BRB2 stvarni protok je dostigao ProtokIspiranja. *)
		IspiranjeMinTrajanjeDostignuto : BOOL; (* BRB2 je na ProtokIspiranja najmanje T_IspiranjeMin. *)
		StopSPDostignut : BOOL; (* BRB2 potvrda dostignutog FR_MinZeroFlow. *)
		RB2V01Zatvoren : BOOL; (* BRB2 potvrda zatvorenog RB2_V01 za IEBKB1 granu. *)
		RB2V02Zatvoren : BOOL; (* BRB2 potvrda zatvorenog RB2_V02. *)
	END_STRUCT;
	typCmdPGRad : 	STRUCT 
		Aktivan : BOOL; (* State masina je vlasnik neretentivnih fizickih komandi. *)
		Ventili : typCmdOnOffPGRad; (* Zahtevi automatskih ON/OFF ventila. *)
		PropVentili : typCmdPropVentiliPGRad; (* Zahtevi proporcionalnih ventila. *)
		AirRelease : typCmdAirReleasePGRad; (* Zahtevi odzracivanja PV03/PV04. *)
		Pumpe : typCmdPumpePGRad; (* Zahtevi izlaznih pumpi. *)
		PID : typCmdPIDPumpePGRad; (* Ulazi jedinog PID-a izlazne pumpe. *)
	END_STRUCT;
	typPGRadStatus : 	STRUCT 
		State : USINT; (* Eksplicitni PGRad state kod za komunikaciju i HMI. *)
		Substep : USINT; (* Aktivni podkorak state masine. *)
		Fault : BOOL; (* Zakacena procesna greska. *)
		FaultCode : USINT; (* Sifra zakacene procesne greske. *)
	END_STRUCT;
	typPGRad : 	STRUCT 
		CmdRetain : typCmdRetainUlazniVentiliPGRad; (* Retain komande bistabilnih ulaznih ventila. *)
		Par : typParPGRad; (* Retain projektni parametri procesa podstanice. *)
		Ctrl : typCtrlPGRad; (* Retain HMI izbor izvora i regulacije. *)
	END_STRUCT;
END_TYPE
