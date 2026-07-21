
PROGRAM _CYCLIC

(* ============================================================================ *)
(* IO_CYCLIC  Pozivi svih BR_Lib FB instanci                                   *)
(* Objekat: PG  Podstanica grejanja 1, Kursumlijska Banja                     *)
(* Sva IO mapiranja su u IoMap.iom  ovde su samo pozivi FB-ova.               *)
(* Redosled: senzori -> DI -> AV -> RV -> PV -> Pu                            *)
(* ============================================================================ *)

(* -------------------------------------------------------------------------- *)
(* 1) FBAI01_DI01  Senzori pritiska Pt (_0_0, _1.._5, _NS1, _NS2)            *)
(* Skaliranje raw AI -> bar. Parametri postavljeni u IO_Init.                 *)
(* -------------------------------------------------------------------------- *)
PG.Sens.Pt._0_0();  (* Pritisak komprimovanog vazduha, skalirani opseg -1 do 14 [bar] *)
PG.Sens.Pt._1();    (* Pritisak termalne vode na ulazu u podstanicu [bar] *)
PG.Sens.Pt._2();    (* Pritisak termalne vode posle streinera grubih filtera [bar] *)
PG.Sens.Pt._3();    (* Pritisak termalne vode posle velikog izmenjivaca [bar] *)
PG.Sens.Pt._4();    (* Pritisak termalne vode na ulazu u prihvatni tank [bar] *)
PG.Sens.Pt._5();    (* Pritisak na potisu transportnih pumpi [bar] *)
PG.Sens.Pt._NS1();  (* Pritisak na dnu prihvatnog tanka [bar] *)
PG.Sens.Pt._NS2();  (* Pritisak na vrhu prihvatnog tanka [bar] *)
NivoPRihvatniSud := (PG.Sens.Pt._NS1.AI_Output.ScaledValue - PG.Sens.Pt._NS2.AI_Output.ScaledValue) / 0.09804; (* nivo u prihvatnom sudu [m] - dif. pritisak NS1(dno)-NS2(vrh) *)

(* -------------------------------------------------------------------------- *)
(* 2) FBAI01_DI01  Temperature Tt (_1.._3)                                    *)
(* Skaliranje raw AI -> degC. Parametri postavljeni u IO_Init.                *)
(* -------------------------------------------------------------------------- *)
PG.Sens.Tt._1();  (* Temperatura na ulazu termalne vode u podstanicu [degC] *)
PG.Sens.Tt._2();  (* Temperatura termalne vode posle izmenjivaca [degC] *)
PG.Sens.Tt._3();  (* Temperatura termalne vode u distributivnom tanku [degC] *)

(* -------------------------------------------------------------------------- *)
(* 3) FBAI01_DI01  Merac protoka MP (_1)                                      *)
(* Skaliranje raw AI -> m3/h. TransmitterStatus DI aktivan (EnableStatusCheck).*)
(* -------------------------------------------------------------------------- *)
PG.Sens.MP._1();  (* Merac protoka na potisu tople termalne vode ka potrosacima [m3/h] *)

(* -------------------------------------------------------------------------- *)
(* 4) FB_DI  Nivo prekidaci LS (_1.._5)                                       *)
(* DI detekcija prisustva tecnosti u odzraci. DelayOn/Off=T#1s.               *)
(* -------------------------------------------------------------------------- *)
PG.Sens.LS._1();  (* Nizak nivo vode u prihvatnom tanku za rad pumpi *)
PG.Sens.LS._2();  (* Donji nivo u odzracnom cilindru na ulazu vode u podstanicu *)
PG.Sens.LS._3();  (* Gornji nivo u odzracnom cilindru na ulazu vode u podstanicu *)
PG.Sens.LS._4();  (* Donji nivo u odzracnom cilindru na ulazu vode u prihvatni tank *)
PG.Sens.LS._5();  (* Gornji nivo u odzracnom cilindru na ulazu vode u prihvatni tank *)

(* -------------------------------------------------------------------------- *)
(* 5) FB_DI  Prestrujni ventili OWF (_1, _2)                                  *)
(* DI povratni signal otvorenog polozaja. DelayOn/Off=T#500ms.                *)
(* -------------------------------------------------------------------------- *)
PG.Sens.OWF._1();  (* Zastitni prestrujni ventil od hidraulickog udara 1 *)
PG.Sens.OWF._2();  (* Zastitni prestrujni ventil od hidraulickog udara 2 *)

(* -------------------------------------------------------------------------- *)
(* 6) FB_V_EMV + FB_V_ON_OFF_FB  Automatski ventili AV (_1.._4)               *)
(* AV._1/2: bistabilni - CmdOpen i CmdClose mapirani u IoMap.                 *)
(* AV._3/4: spring-return NC - samo CmdOpen mapiran u IoMap.                  *)
(* -------------------------------------------------------------------------- *)
PG.Act.AV._1();  (* Elektromotorni bistabilni leptir ventil DN125, OpenMaxTime=30s *)
PG.Act.AV._2();  (* Elektromotorni bistabilni leptir ventil DN125, OpenMaxTime=30s *)
PG.Act.AV._3();  (* Pneumatski NC spring-return leptir ventil DN125, OpenMaxTime=10s *)
PG.Act.AV._4();  (* Pneumatski NC spring-return leptir ventil DN125, OpenMaxTime=10s *)

(* -------------------------------------------------------------------------- *)
(* 7) FB_HV_2LS  Rucni leptir ventili RV (_16, _18.._27)                     *)
(* Monitoring 2 krajnja prekidaca, alarm pri timeout tranziciji.              *)
(* -------------------------------------------------------------------------- *)
PG.Act.RV._16();  (* Bajpasni ventil regulacije pritiska u cevovodu na ulazu tople vode u prihvatni tank *)
PG.Act.RV._18();  (* Rucni ventil pre membranskog ventila PG_PV01 *)
PG.Act.RV._19();  (* Rucni ventil posle membranskog ventila PG_PV01 *)
PG.Act.RV._20();  (* Rucni ventil pre membranskog ventila PG_PV02 *)
PG.Act.RV._21();  (* Rucni ventil posle membranskog ventila PG_PV02 *)
PG.Act.RV._22();  (* Drenazni total ventil na dnu prihvatnog tanka *)
PG.Act.RV._23();  (* Ulaz u Pumpu PG_Pu01 *)
PG.Act.RV._24();  (* Ulaz u Pumpu PG_Pu02 *)
PG.Act.RV._25();  (* Bajpasni izlaz iz tanka ka instalaciji za izbacivanje gasa van kotlarnice *)
PG.Act.RV._26();  (* Ulaz u vakuum pumpu *)
PG.Act.RV._27();  (* Izlaz iz vakuum pumpe ka instalaciji za izbacivanje gasa van kotlarnice *)

(* -------------------------------------------------------------------------- *)
(* 8) FB_PvAiAo_Fast  Proporcionalni membranski ventili PV (_1.._4)           *)
(* AI_Raw povratni signal i AO_Raw komanda direktno mapirani u IoMap.         *)
(* SP_Percent zadaje visi nivo upravljanja.                                   *)
(* -------------------------------------------------------------------------- *)

	(* Ogranicavanje manualne i SP vrednosti ventila PV._1 na opseg 0..100%. *)
	IF (PG.Act.PV._1.PV_Input.ManualValue_Percent > 100) THEN PG.Act.PV._1.PV_Input.ManualValue_Percent := 100 ; END_IF
	IF (PG.Act.PV._1.PV_Input.ManualValue_Percent < 0) THEN PG.Act.PV._1.PV_Input.ManualValue_Percent := 0 ; END_IF
	IF (PG.Act.PV._1.PV_Input.SP_Percent > 100) THEN PG.Act.PV._1.PV_Input.SP_Percent := 100 ; END_IF
	IF (PG.Act.PV._1.PV_Input.SP_Percent < 0) THEN PG.Act.PV._1.PV_Input.SP_Percent := 0 ; END_IF
	
	PG.Act.PV._1();  (* Ulazni regulacioni ventil 1 - prihvatni tank, DN050 NC *)
	
	(* Ogranicavanje manualne i SP vrednosti ventila PV._2 na opseg 0..100%. *)
	IF (PG.Act.PV._2.PV_Input.ManualValue_Percent > 100) THEN PG.Act.PV._2.PV_Input.ManualValue_Percent := 100 ; END_IF
	IF (PG.Act.PV._2.PV_Input.ManualValue_Percent < 0) THEN PG.Act.PV._2.PV_Input.ManualValue_Percent := 0 ; END_IF
	IF (PG.Act.PV._2.PV_Input.SP_Percent > 100) THEN PG.Act.PV._2.PV_Input.SP_Percent := 100 ; END_IF
	IF (PG.Act.PV._2.PV_Input.SP_Percent < 0) THEN PG.Act.PV._2.PV_Input.SP_Percent := 0 ; END_IF
	
	PG.Act.PV._2();  (* Ulazni regulacioni ventil 2 - prihvatni tank, DN050 NC *)
	
	(* Ogranicavanje manualne i SP vrednosti ventila PV._3 na opseg 0..100%. *)
	IF (PG.Act.PV._3.PV_Input.ManualValue_Percent > 100) THEN PG.Act.PV._3.PV_Input.ManualValue_Percent := 100 ; END_IF
	IF (PG.Act.PV._3.PV_Input.ManualValue_Percent < 0) THEN PG.Act.PV._3.PV_Input.ManualValue_Percent := 0 ; END_IF
	IF (PG.Act.PV._3.PV_Input.SP_Percent > 100) THEN PG.Act.PV._3.PV_Input.SP_Percent := 100 ; END_IF
	IF (PG.Act.PV._3.PV_Input.SP_Percent < 0) THEN PG.Act.PV._3.PV_Input.SP_Percent := 0 ; END_IF
	
	PG.Act.PV._3();  (* Odzracni ventil na ulazu termalne vode u kotlarnicu, DN025 NC *)
	
	(* Ogranicavanje manualne i SP vrednosti ventila PV._4 na opseg 0..100%. *)
	IF (PG.Act.PV._4.PV_Input.ManualValue_Percent > 100) THEN PG.Act.PV._4.PV_Input.ManualValue_Percent := 100 ; END_IF
	IF (PG.Act.PV._4.PV_Input.ManualValue_Percent < 0) THEN PG.Act.PV._4.PV_Input.ManualValue_Percent := 0 ; END_IF
	IF (PG.Act.PV._4.PV_Input.SP_Percent > 100) THEN PG.Act.PV._4.PV_Input.SP_Percent := 100 ; END_IF
	IF (PG.Act.PV._4.PV_Input.SP_Percent < 0) THEN PG.Act.PV._4.PV_Input.SP_Percent := 0 ; END_IF
	
	PG.Act.PV._4();  (* Odzracni ventil na ulazu termalne vode u prihvatni tank, DN025 NC *)

(* -------------------------------------------------------------------------- *)
(* 9) vfdMain  Pumpe Pu (_1, _2)  DIO metod                                  *)
(* w_run_fwd/w_reset (DO) i w_freq (AO) mapirani u IoMap.                    *)
(* Trenutni clamp u kodu: Pu._1 = 10..100 Hz, Pu._2 = 10..50 Hz.             *)
(* addr_struct postavljen jednom u IO_Init tasku.                             *)
(* -------------------------------------------------------------------------- *)
	
	(* Rucno inkrementiranje i dekrementiranje frekvence pumpe Pu._1. *)
	IF EDGEPOS(Pu1_1_plus) THEN PG.Act.Pu._1.params.Freq := PG.Act.Pu._1.params.Freq + 1 ; END_IF
	IF EDGEPOS(Pu1_01_plus) THEN PG.Act.Pu._1.params.Freq := PG.Act.Pu._1.params.Freq + 0.1 ; END_IF
	IF EDGEPOS(Pu1_1_minus) THEN PG.Act.Pu._1.params.Freq := PG.Act.Pu._1.params.Freq - 1 ; END_IF
	IF EDGEPOS(Pu1_01_minus) THEN PG.Act.Pu._1.params.Freq := PG.Act.Pu._1.params.Freq - 0.1 ; END_IF
	
	(* Ogranicavanje vrednosti pumpe Pu._1 na opseg 10..100 Hz (trenutna logika). *)
	IF (PG.Act.Pu._1.params.Freq > 100) THEN PG.Act.Pu._1.params.Freq := 100 ; END_IF
	IF (PG.Act.Pu._1.params.Freq < 10) THEN PG.Act.Pu._1.params.Freq := 10 ; END_IF
	
	PG.Act.Pu.VFD_function._1();  (* Pumpa za snabdevanje potrosaca 01, Grundfoss CR45, METOD_DIO *)	
	
	(* Rucno inkrementiranje i dekrementiranje frekvence pumpe Pu._2. *)
	IF EDGEPOS(Pu2_1_plus) THEN PG.Act.Pu._2.params.Freq := PG.Act.Pu._2.params.Freq + 1 ; END_IF
	IF EDGEPOS(Pu2_01_plus) THEN PG.Act.Pu._2.params.Freq := PG.Act.Pu._2.params.Freq + 0.1 ; END_IF
	IF EDGEPOS(Pu2_1_minus) THEN PG.Act.Pu._2.params.Freq := PG.Act.Pu._2.params.Freq - 1 ; END_IF
	IF EDGEPOS(Pu2_01_minus) THEN PG.Act.Pu._2.params.Freq := PG.Act.Pu._2.params.Freq - 0.1 ; END_IF
	
	(* Ogranicavanje vrednosti pumpe Pu._2 na opseg 10..50 Hz. *)
	IF (PG.Act.Pu._2.params.Freq > 50) THEN PG.Act.Pu._2.params.Freq := 50 ; END_IF
	IF (PG.Act.Pu._2.params.Freq < 10) THEN PG.Act.Pu._2.params.Freq := 10 ; END_IF

	PG.Act.Pu.VFD_function._2();  (* Pumpa za snabdevanje potrosaca 02, Grundfoss CR45, METOD_DIO *)

	(* Racunanje predate snage i diferencijalnih pritisaka. *)
	Predata_Snaga := 4.181 * (PG.Sens.MP._1.AI_Output.ScaledValue * (PG.Sens.Tt._1.AI_Output.ScaledValue - PG.Sens.Tt._2.AI_Output.ScaledValue)) ;
	DP_strainer := PG.Sens.Pt._1.AI_Output.ScaledValue - PG.Sens.Pt._2.AI_Output.ScaledValue + 0.123 ;
	DP_Izmejnivac := PG.Sens.Pt._2.AI_Output.ScaledValue - PG.Sens.Pt._3.AI_Output.ScaledValue + 0.0015 ;
	
END_PROGRAM