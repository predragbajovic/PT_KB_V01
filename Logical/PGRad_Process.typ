
TYPE
	E_RegulacijaBRB2 :
		( (* Regulaciona petlja pumpe koja doprema vodu iz BRB2. *) (* -------------------------------------------------------------------------- *) (* 1) Glavna stanja, izbor izvora i izbor aktivne opreme                     *)
		BRB2_00_NEAKTIVNA,
		BRB2_01_REG_PROTOK, (* Protok ka Podstanici/Hotelu. *)
		BRB2_02_REG_NIVO, (* Nivo prihvatnog suda. *)
		BRB2_03_REG_TEMPERATURA (* Temperatura sekundara izmenjivaca. *)
		);
	E_PGRad_State : 
		( (* Glavna procesna stanja rada Podstanice prema izabranom izvoru. *)
		PG_00_Stand_By, (* Bez aktivnog izvora; izlazi su u bezbednom stanju i ceka se izbor/start. *)
		PG_01_Priprema_BRB2, (* Pokrece BRB2 i priprema ulaznu granu do potvrde pritiska/protoka. *)
		PG_02_Rad_BRB2, (* BRB2 napaja tank; aktivni su regulacija ulaza, izlazna pumpa i odzracivanje. *)
		PG_03_Zaustavljanje_BRB2, (* Kontrolisano ukida zahtev BRB2 i zatvara pripadajuce ventile. *)
		PG_11_Priprema_IEBKB1, (* Priprema IEBKB1 granu pre dozvole punjenja prihvatnog tanka. *)
		PG_12_Rad_IEBKB1, (* IEBKB1 je aktivni izvor i Podstanica vodi lokalnu regulaciju. *)
		PG_13_Zaustavljanje_IEBKB1, (* Kontrolisano zaustavlja IEBKB1 i zatvara njegovu ulaznu granu. *)
		PG_14_Transfer_IEBKB1_BRB2 (* Prebacuje napajanje sa IEBKB1 na prethodno pripremljeni BRB2. *)
		);
	E_BRB2PreparationState : 
		( (* Stanja paralelne pripreme BRB2 pre transfera izvora. *)
		BRB2_PREP_00_IDLE, (* Priprema nije trazena; resetuju se privremene potvrde. *)
		BRB2_PREP_10_START, (* Poslat je start zahtev i ceka se potvrda protoka BRB2. *)
		BRB2_PREP_20_ZAGREVANJE, (* BRB2 ispira/zagreva cev do minimalne temperature. *)
		BRB2_PREP_30_SPReady, (* Protok i temperatura su potvrdeni; transfer izvora je dozvoljen. *)
		BRB2_PREP_40_STOPPING, (* Priprema se kontrolisano prekida i ceka se potvrda stopa. *)
		BRB2_PREP_90_FAULT (* Priprema je blokirana timeout-om ili procesnim interlockom. *)
		);
	E_RegulacionaVarijanta : 
		( (* Izbor procesne velicine koju Podstanica regulise. *)
		_00_neaktivan, (* 0 - sve ugaseno, ni jedna varijanta nije izabrana. *)
		_01_REG_PRITISAK, (* 1 - PT vodi, prati zadati pritisak. *)
		_02_REG_NIVO (* 2 - PT vodi nivo prihvatnog tanka preko izlazne pumpe. *)
		);
	E_SelektovaniIzvor : 
		( (* Izbor aktivnog izvora termalne vode za Podstanicu. *)
		_00_IZVOR_NIJE_IZABRAN, (* 0 - rezervisano za inicijalizaciju i dijagnostiku; binarni HMI selektor ne zadaje ovu vrednost. *)
		_01_BRB2, (* 1 - BRB2 kao izvor. *)
		_02_IEBKB1 (* 2 - IEBKB1 kao izvor. *)
		);
	E_AktivnaPumpaIzlazTanka : 
		( (* Izbor aktivne izlazne pumpe prihvatnog tanka. *)
		_00_nijedna, (* 0 - nijedna pumpa aktivna na izlazu iz tanka. *)
		_01_Pu_PG_01, (* 1 - Pu_PG_01 aktivna. *)
		_02_Pu_PG_02 (* 2 - Pu_PG_02 aktivna. *)
		);
	E_AktivniPropVentilUlazTanka : 
		( (* Izbor aktivnog proporcionalnog ventila na ulazu u tank. *) (* -------------------------------------------------------------------------- *) (* 2) Retentivni parametri procesa i pomocne runtime strukture                *)
		_00_PROP_VENTIL_NIJE_IZABRAN, (* 0 - nijedan prop. ventil nije izabran. *)
		_01_PG_PV01, (* 1 - PG_PV01 aktivan. *)
		_02_PG_PV02 (* 2 - PG_PV02 aktivan. *)
		);
	typCmdRetainUlazniVentiliPGRad : 	STRUCT  (* Zapamceni zahtevi bistabilnih ulaznih ventila PG_V01 i PG_V02. *)
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
	typTimeSPPGRad : 	STRUCT  (* Grupisani vremenski SP parametri u sekundama. *)
		PrelazPV05Cuvar_s : REAL; (* Vreme PT06 SP rampe [s]. *)
		OverlapPumpi_s : REAL; (* Maksimalno vreme paralelnog rada pri rotaciji [s]. *)
		AutoRestartDelay_s : REAL; (* Zadrzavanje pre automatskog starta [s]. *)
		ValvePositionTimeout_s : REAL; (* Maksimalno vreme hoda ventila [s]. *)
		InterlockDebounce_s : REAL; (* Vreme potvrde interlock povratnog signala [s]. *)
	END_STRUCT;
	typParBRB2PreparationPGRad : 	STRUCT  (* Paralelna priprema BRB2 dok IEBKB1 snabdeva tank. *)
		MinTemperature_degC : REAL; (* Minimalna temperatura TT_PG_07 za spremnost BRB2. *)
		MinFlow_lps : REAL; (* Minimalni potvrdeni protok BRB2 tokom zagrevanja. *)
		FlowTimeout_s : REAL; (* Maksimalno cekanje potvrde protoka nakon starta BRB2. *)
		TemperatureAlarm_s : REAL; (* Vreme do alarma ako temperatura nije dostignuta. *)
		TemperatureStopDelay_s : REAL; (* Dodatno vreme od alarma do kontrolisanog stopa. *)
		PressureAlarmDelay_s : REAL; (* Vreme visokog PT06 do alarma. *)
		PressureStopDelay_s : REAL; (* Dodatno vreme visokog PT06 do kontrolisanog stopa. *)
	END_STRUCT;
	typParTransferPGRad : 	STRUCT  (* Parametri transfera IEBKB1 na pripremljeni BRB2. *)
		PV05StartPressure_bar : REAL; (* Pocetni PT06 SP regulatora PG_PV05. *)
		PV05FinalPressure_bar : REAL; (* Krajnji PT06 SP regulatora PG_PV05. *)
		TankInletPressure_bar : REAL; (* Stalni PT04 SP aktivnog PG_PV01/PV02. *)
		PressureRamp_s : REAL; (* Trajanje rampe PT06 SP-a. *)
		FlowTimeout_s : REAL; (* Maksimalno cekanje potvrde BRB2 protoka pri transferu. *)
		PV05ClosedPercent : REAL; (* Otvorenost ispod koje se drenaÅ¾a smatra zatvorenom. *)
	END_STRUCT;
	typParPGRad : 	STRUCT  (* Zbirni procesni, vremenski i odzracni parametri Podstanice. *)
		SetPritisakPotisa : REAL; (* Zadati pritisak potisa glavne pumpe [bar]. *)
		MinProtok : REAL; (* Donja granica protoka. *)
		MaxProtok : REAL; (* Gornja granica protoka. *)
		MinFR_Pumpe : REAL; (* Minimalna frekvencija PID izlaza pumpi [Hz]. *)
		MaxFR_Pumpe : REAL; (* Maksimalna frekvencija PID izlaza pumpi [Hz]. *)
		SetPointNivoTanka : REAL; (* Ciljani nivo prihvatnog tanka [m]. *)
		SetPointMinTempIspiranja : REAL; (* Minimalna temperatura za zavrsetak ispiranja [degC]. *)
		SetPointPritisakPV05Ispiranje : REAL; (* PT06 SP tokom preispiranja [bar]. *)
		SetPointPritisakUlazTanka : REAL; (* PT04 SP aktivnog ulaznog ventila [bar]. *)
		SetPointMaxPritisakDolaznaCev : REAL; (* PT06 SP cuvara instalacije [bar]. *)
		PocetnaFrekvencaIzlaznePumpe : REAL; (* PID tracking frekvenca pri startu [Hz]. *)
		MaxOtvorPropZaZatvaranje : REAL; (* Najveca otvorenost za potvrdu zatvaranja [%]. *)
		BRB2Preparation : typParBRB2PreparationPGRad; (* Parametri nezavisnog zagrevanja BRB2. *)
		Transfer : typParTransferPGRad; (* Parametri kontrolisanog transfera izvora. *)
		TimeSP : typTimeSPPGRad; (* RETAIN vremenski SP parametri u sekundama. *)
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
	typCtrlPGRad : 	STRUCT  (* Retentivni HMI izbori izvora, regulacije i aktivne opreme. *)
		SelektovaniIzvor : E_SelektovaniIzvor; (* Izbor izvora termalne vode. *)
		RegulacionaVarijanta : E_RegulacionaVarijanta; (* Izabrana regulaciona varijanta. *)
		AktivnaPumpaIzlazTanka : E_AktivnaPumpaIzlazTanka; (* Aktivna izlazna pumpa. *)
		AktivniPropVentilUlazTanka : E_AktivniPropVentilUlazTanka; (* Aktivni ulazni prop. ventil. *)
		AutoRestart : BOOL; (* Automatski start nakon cold boot-a. *)
		BRB2Regulacija : E_RegulacijaBRB2; (* Zaseban izbor regulacije pumpe BRB2; ne menja regulaciju izlaznih pumpi. *)
	END_STRUCT;
	typManualPGRad : 	STRUCT  (* Servisne rucne komande procesnih sekvenci Podstanice. *)
		Enable : BOOL; (* Dozvola servisnog rucnog rezima; aktivan samo u Standby. *)
		Sequence : USINT; (* Izabrana sekvenca: 1=BRB2 priprema/ispiranje, 2=IEBKB1 priprema, 3=kontrolisani stop. *)
		Start : BOOL; (* Impuls za pokretanje izabrane servisne sekvence. *)
		Stop : BOOL; (* Impuls za bezbedan prekid servisne sekvence. *)
		NextStep : BOOL; (* Impuls za zahtev sledeceg dozvoljenog podkoraka. *)
		Abort : BOOL; (* Impuls za povratak u Standby bez preskakanja stop logike. *)
	END_STRUCT;
END_TYPE

(* -------------------------------------------------------------------------- *)
(* 3) Krovni lokalni kontekst programa Rad_PG_KB                            *)
(* -------------------------------------------------------------------------- *)

TYPE
	typRadPGKBHmiCntrl : 	STRUCT  (* Komande automatskog rada iz HMI-ja Podstanice. *)
		Start : BOOL; (* Zahtev za pokretanje izabranog automatskog izvora. *)
		Stop : BOOL; (* Zahtev za kontrolisano zaustavljanje aktivnog izvora. *)
		Reset : BOOL; (* Zahtev za reset zakacenog procesnog fault-a. *)
		SelectIEBKB1 : BOOL; (* FALSE = BRB2 izvor; TRUE = IEBKB1 izvor. Prihvata se u Standby. *)
		SetDefaultParameters : BOOL; (* Jednokratni zahtev za vracanje RETAIN parametara na default vrednosti. *)
		PrepareBRB2 : BOOL; (* Zahtev za nezavisnu pripremu/zagrevanje BRB2 izvora. *)
		TransferToBRB2 : BOOL; (* Zahtev za transfer sa IEBKB1 na prethodno pripremljeni BRB2. *)
		Continue : BOOL; (* Zahtev za nastavak nakon potvrdenog protoka BRB2. *)
	END_STRUCT;
	typRadPGKBHmiManual : 	STRUCT  (* Komande servisnog manuelnog rada procesne sekvence. *)
		Enable : BOOL; (* Dozvola manuelnog rezima; koristi se samo kada je sekvenca u Standby. *)
		Sequence : USINT; (* Izbor manuelne sekvence: 1 = BRB2, 2 = IEBKB1. *)
		Start : BOOL; (* Impuls za pokretanje izabrane manuelne sekvence. *)
		Stop : BOOL; (* Impuls za kontrolisani prekid manuelne sekvence. *)
		NextStep : BOOL; (* Impuls za potvrdu sledeceg dozvoljenog podkoraka. *)
		Abort : BOOL; (* Impuls za prekid i povratak u bezbedni Standby. *)
	END_STRUCT;
	typRadPGKBHmi : 	STRUCT  (* Zbirni HMI interfejs lokalnog programa Rad_PG_KB. *)
		Cntrl : typRadPGKBHmiCntrl; (* Komande automatskog rada. *)
		Manual : typRadPGKBHmiManual; (* Komande servisnog manuelnog rada. *)
	END_STRUCT;
	typRadPGKBSequenceBRB2 : 	STRUCT  (* Lokalno stanje paralelne pripreme izvora BRB2. *)
		PreparationState : E_BRB2PreparationState; (* Stanje pripreme: start, zagrevanje, SP spreman, stop ili fault. *)
		PreparationSubstep : USINT; (* Aktivni podkorak pripreme BRB2. *)
		Ready : BOOL; (* TRUE kada su potvrdeni uslovi spremnosti BRB2 za transfer. *)
	END_STRUCT;
	typRadPGKBSequenceTransfer : 	STRUCT  (* Lokalna memorija zahteva transfera izvora. *)
		Requested : BOOL; (* Zakacen zahtev transfera do zavrsetka ili opoziva. *)
	END_STRUCT;
	typRadPGKBSequence : 	STRUCT  (* Izvrsni kontekst glavne state masine. *)
		State : E_PGRad_State; (* Aktivno glavno stanje rada Podstanice. *)
		Substep : USINT; (* Aktivni podkorak glavnog stanja; 0 je ulaz u stanje. *)
		BRB2 : typRadPGKBSequenceBRB2; (* Podstanje pripreme BRB2. *)
		Transfer : typRadPGKBSequenceTransfer; (* Podaci zahteva transfera IEBKB1 -> BRB2. *)
	END_STRUCT;
	typRadPGKBDiagFault : 	STRUCT  (* Zakacena procesna dijagnostika lokalne sekvence. *)
		Latched : BOOL; (* TRUE kada fault ostaje memorisan do dozvoljenog reset-a. *)
		Code : USINT; (* Numericki kod fault-a za HMI i komunikacioni status. *)
		Text : STRING[80]; (* Tekstualni opis aktivnog fault-a za operatera. *)
	END_STRUCT;
	typRadPGKBStatusPV05 : 	STRUCT  (* Status regulatora i funkcije PV05. *)
		FlushingOpened : BOOL; (* PT06 je dostigao uslov za dozvolu PV05 ispiranja. *)
	END_STRUCT;
	typRadPGKBStatusPump : 	STRUCT  (* Status izlazne pumpe prihvatnog tanka. *)
		OutletStopped : BOOL; (* Pumpa je u kontrolisanom praznjenju do donje granice histereze. *)
	END_STRUCT;
	typRadPGKBStatus : 	STRUCT  (* Izvedeni statusi lokalnih regulacionih funkcija. *)
		PV05 : typRadPGKBStatusPV05; (* Status PV05 funkcije. *)
		Pump : typRadPGKBStatusPump; (* Status izlazne pumpe. *)
	END_STRUCT;
	typRadPGKBDiag : 	STRUCT  (* Zbirna dijagnostika programa Rad_PG_KB. *)
		Fault : typRadPGKBDiagFault; (* Zakaceni procesni fault. *)
	END_STRUCT;
	typRadPGKBControlPV05 : 	STRUCT  (* Izvrsna regulacija pritiska preko PV05. *)
		PID : MTBasicsPID; (* PID koji koristi PT06 kao PV i upravlja otvorenoscu PV05. *)
		FlushingSP : REAL; (* Trenutni rampirani SP pritiska PT06 [bar]. *)
	END_STRUCT;
	typRadPGKBControlPVUlazTanka : 	STRUCT  (* Izvrsna regulacija ulaznog proporcionalnog ventila. *)
		PID : MTBasicsPID; (* PID koji reguliše PT04 preko aktivnog PV01/PV02 ventila. *)
	END_STRUCT;
	typRadPGKBControl : 	STRUCT  (* Zbirni regulacioni FB-ovi programa Rad_PG_KB. *)
		PV05 : typRadPGKBControlPV05; (* Regulacija pritiska i cuvar PT06. *)
		PV_UlazTanka : typRadPGKBControlPVUlazTanka; (* Regulacija pritiska ulaza u prihvatni tank. *)
	END_STRUCT;
	typRadPGKBTimerValve : 	STRUCT  (* Tajmeri hoda PG_V01. *)
		Close : TON; (* Timeout potvrde zatvaranja PG_V01. *)
		Open : TON; (* Timeout potvrde otvaranja PG_V01. *)
	END_STRUCT;
	typRadPGKBTimerPGV02 : 	STRUCT  (* Tajmeri hoda PG_V02. *)
		Open : TON; (* Timeout potvrde otvaranja PG_V02. *)
		Close : TON; (* Timeout potvrde zatvaranja PG_V02. *)
	END_STRUCT;
	typRadPGKBTimerIEBKB1 : 	STRUCT  (* Tajmeri potvrde protoka izvora IEBKB1. *)
		StartProtokTimeout : TON; (* Maksimalno cekanje pocetka dotoka IEBKB1. *)
		ProtokNula : TON; (* Debounce potvrda da je protok IEBKB1 pao ispod praga. *)
		StopProtokTimeout : TON; (* Maksimalno cekanje prestanka dotoka IEBKB1. *)
	END_STRUCT;
	typRadPGKBTimerPGV05 : 	STRUCT  (* Tajmer zatvaranja izlaznog ventila PG_V05. *)
		Close : TON; (* Timeout potvrde zatvaranja PG_V05. *)
	END_STRUCT;
	typRadPGKBTimerBRB2 : 	STRUCT  (* Tajmeri nadzora pripreme izvora BRB2. *)
		PreparationFlow : TON; (* Timeout potvrde protoka BRB2 tokom pripreme. *)
		TemperatureAlarm : TON; (* Vreme do alarma ako temperatura BRB2 nije dostignuta. *)
		TemperatureStop : TON; (* Dodatno vreme do kontrolisanog stopa posle alarma temperature. *)
		PressureAlarm : TON; (* Vreme potvrde previsokog PT06 pritiska pre alarma. *)
		PressureStop : TON; (* Dodatno vreme do kontrolisanog stopa zbog PT06 pritiska. *)
	END_STRUCT;
	typRadPGKBTimerTransfer : 	STRUCT  (* Tajmeri kontrolisanog transfera izvora. *)
		PV05Guard : TON; (* Vreme rampe/cekanja promene PT06 SP-a. *)
		Flow : TON; (* Timeout potvrde BRB2 protoka tokom transfera. *)
	END_STRUCT;
	typRadPGKBTimer : 	STRUCT  (* Svi interni TON tajmeri programa Rad_PG_KB. *)
		PG_V01 : typRadPGKBTimerValve; (* Tajmeri ulaznog ventila IEBKB1. *)
		PG_V02 : typRadPGKBTimerPGV02; (* Tajmeri ulaznog ventila BRB2. *)
		PG_V05 : typRadPGKBTimerPGV05; (* Tajmer izlaznog/prelaznog ventila PG_V05. *)
		IEBKB1 : typRadPGKBTimerIEBKB1; (* Tajmeri protoka izvora IEBKB1. *)
		BRB2 : typRadPGKBTimerBRB2; (* Tajmeri pritiska, temperature i protoka BRB2. *)
		Transfer : typRadPGKBTimerTransfer; (* Tajmeri transfera i cuvara PT06. *)
	END_STRUCT;
	typRadPGKB : 	STRUCT  (* Krovni lokalni kontekst programa Rad_PG_KB. *)
		HMI : typRadPGKBHmi; (* HMI komande automatskog i manuelnog rada. *)
		Sequence : typRadPGKBSequence; (* Stanje glavne i pomocnih sekvenci. *)
		Control : typRadPGKBControl; (* Lokalni PID regulatori i njihove procesne vrednosti. *)
		Status : typRadPGKBStatus; (* Izvedeni statusi regulacije i aktuatora. *)
		Diag : typRadPGKBDiag; (* Fault status i tekst za HMI. *)
		Timer : typRadPGKBTimer; (* Interni tajmeri svih sekvenci. *)
	END_STRUCT;
END_TYPE

(* -------------------------------------------------------------------------- *)
(* 4) Procesne komande aktuatora i regulacioni ulazi                        *)
(* -------------------------------------------------------------------------- *)

TYPE
	typCmdOnOffPGRad : 	STRUCT  (* Procesni zahtevi otvaranja lokalnih ON/OFF ventila PG_V03..PG_V07. *)
		_03_Open : BOOL; (* PG_V03 - zahtev otvaranja izlazne grane pumpe 1. *)
		_04_Open : BOOL; (* PG_V04 - zahtev otvaranja izlazne grane pumpe 2. *)
		_05_Open : BOOL; (* PG_V05 - zahtev otvaranja bypass-a/preispiranja. *)
		_06_Open : BOOL; (* PG_V06 - zahtev otvaranja grane PV01 ka tanku. *)
		_07_Open : BOOL; (* PG_V07 - zahtev otvaranja grane PV02 ka tanku. *)
	END_STRUCT;
	typCmdPropVentilPGRad : 	STRUCT  (* Automatska dozvola i zahtev otvorenosti jednog proporcionalnog ventila. *)
		Enable : BOOL; (* Dozvola automatskog upravljanja ventilom. *)
		SP_Percent : REAL; (* Automatski zahtev otvorenosti 0..100%. *)
	END_STRUCT;
	typCmdPropVentiliPGRad : 	STRUCT  (* Grupisane procesne komande proporcionalnih ventila PG_PV01, PG_PV02 i PG_PV05. *)
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
	typCmdPumpaPGRad : 	STRUCT  (* Procesna dozvola rada jedne izlazne pumpe. *)
		Run : BOOL; (* Dozvola rada pumpe; frekvencu iskljucivo vodi PID_Pu_PT. *)
	END_STRUCT;
	typCmdPumpePGRad : 	STRUCT  (* Grupisane procesne komande izlaznih pumpi PG_Pu01 i PG_Pu02. *)
		_01 : typCmdPumpaPGRad; (* PG_Pu01 - komandni zahtev za izlaznu pumpu 1. *)
		_02 : typCmdPumpaPGRad; (* PG_Pu02 - komandni zahtev za izlaznu pumpu 2. *)
	END_STRUCT;
	typCmdPIDPumpePGRad : 	STRUCT  (* Ulazi i granice jedinog PID regulatora aktivne izlazne pumpe. *)
		Enable : BOOL; (* Dozvola rada PID_Pu_PT regulatora. *)
		ActValue : REAL; (* Aktivna regulisana vrednost: nivo tanka ili PT05 [m/bar]. *)
		SetValue : REAL; (* SP aktivne regulisane vrednosti [m/bar]. *)
		Invert : BOOL; (* Smer PID-a: TRUE za nivo, FALSE za pritisak. *)
		MaxOut : REAL; (* Maksimalni frekventni izlaz izabrane pumpe [Hz]. *)
		EnableTracking : BOOL; (* Dozvola bumpless starta na TrackingValue. *)
		TrackingValue : REAL; (* Pocetni frekventni zahtev PID-a pri startu [Hz]. *)
	END_STRUCT;
	typCmdPGRad : 	STRUCT  (* Neretentivni komandni vektor procesne state masine Podstanice. *)
		Aktivan : BOOL; (* State masina je vlasnik neretentivnih fizickih komandi. *)
		Ventili : typCmdOnOffPGRad; (* Zahtevi automatskih ON/OFF ventila. *)
		PropVentili : typCmdPropVentiliPGRad; (* Zahtevi proporcionalnih ventila. *)
		AirRelease : typCmdAirReleasePGRad; (* Zahtevi odzracivanja PV03/PV04. *)
		Pumpe : typCmdPumpePGRad; (* Zahtevi izlaznih pumpi. *)
		PID : typCmdPIDPumpePGRad; (* Ulazi jedinog PID-a izlazne pumpe. *)
	END_STRUCT;
END_TYPE

(* -------------------------------------------------------------------------- *)
(* 5) Statusni i retentivni kontekst Podstanice                              *)
(* -------------------------------------------------------------------------- *)

TYPE
	typPGRadStatus : 	STRUCT  (* Procesno stanje, podkorak i zakacena dijagnostika Podstanice. *)
		State : USINT; (* Eksplicitni PGRad state kod za komunikaciju i HMI. *)
		StateComment : STRING[80]; (* Operaterski opis aktivnog stanja. *)
		Substep : USINT; (* Aktivni podkorak state masine. *)
		SubstepComment : STRING[80]; (* Operaterski opis aktivnog podkoraka. *)
		Fault : BOOL; (* Zakacena procesna greska. *)
		FaultCode : USINT; (* Sifra zakacene procesne greske. *)
		BRB2PreparationState : USINT; (* Nezavisno stanje pripreme BRB2. *)
		BRB2PreparationStateComment : STRING[80]; (* Tekstualni opis nezavisnog stanja pripreme BRB2. *)
		BRB2Ready : BOOL; (* Temperatura, protok i minimalno trajanje su potvrdeni. *)
		IEBKB1InterfaceReady : BOOL; (* Buduci IEBKB1 ugovor je kompletan i validan. *)
		TransferBlocked : BOOL; (* Transfer je blokiran zbog nepotpunog IEBKB1 ugovora ili interlocka. *)
	END_STRUCT;
	typPGRad : 	STRUCT  (* Retentivni kontekst komandi, parametara i HMI izbora Podstanice. *)
		CmdRetain : typCmdRetainUlazniVentiliPGRad; (* Retain komande bistabilnih ulaznih ventila. *)
		Par : typParPGRad; (* Retain projektni parametri procesa podstanice. *)
		Ctrl : typCtrlPGRad; (* Retain HMI izbor izvora i regulacije. *)
	END_STRUCT;
END_TYPE
