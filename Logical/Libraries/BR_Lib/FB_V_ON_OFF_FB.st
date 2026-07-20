FUNCTION_BLOCK FB_V_ON_OFF_FB (* Predlog FB za ON/OFF ventil - odvojeno od FB_AI_01 *)

(* ============================================================ *)
(* 1) Validacija vremena i zastite za granicne slucajeve        *)
(* ============================================================ *)
Cfg.OpenMinTime_Valid := V_Param.OpenMinTime;
Cfg.OpenMaxTime_Valid := V_Param.OpenMaxTime;
Cfg.CloseMinTime_Valid := V_Param.CloseMinTime;
Cfg.CloseMaxTime_Valid := V_Param.CloseMaxTime;
Cfg.StableFbDelay_Valid := V_Param.StableFbDelay;

(* Svaki nevalidan/nenegativan parametar dobija bezbednu podrazumevanu vrednost. *)
(* OpenMinTime/CloseMinTime = T#0ms je validan: znaci da nema provjere minimalnog vremena. *)
IF Cfg.OpenMaxTime_Valid <= T#0ms THEN
	Cfg.OpenMaxTime_Valid := T#1s;
END_IF;
IF Cfg.CloseMaxTime_Valid <= T#0ms THEN
	Cfg.CloseMaxTime_Valid := T#1s;
END_IF;
IF Cfg.StableFbDelay_Valid <= T#0ms THEN
	Cfg.StableFbDelay_Valid := T#200ms;
END_IF;

(* Kontrola konzistentnosti: max mora biti >= min *)
IF Cfg.OpenMaxTime_Valid < Cfg.OpenMinTime_Valid THEN
	Cfg.OpenMaxTime_Valid := Cfg.OpenMinTime_Valid;
END_IF;
IF Cfg.CloseMaxTime_Valid < Cfg.CloseMinTime_Valid THEN
	Cfg.CloseMaxTime_Valid := Cfg.CloseMinTime_Valid;
END_IF;

(* ============================================================ *)
(* 2) Izbor komandovanog stanja (Manual ima prioritet)          *)
(* ============================================================ *)
(* Kada je EnableManual=TRUE, manual komanda uvek prepisuje auto zahtev. *)
IF V_Input.EnableManual THEN
	Internal.DesiredOpen := V_Input.Open_Manual;
ELSE
	Internal.DesiredOpen := Open;
END_IF;

(* ============================================================ *)
(* 3) Osnovne potvrde pozicije                                   *)
(* ============================================================ *)
(*
Potvrde pozicije zavise od dostupnosti feedback-a:
- Ako FB postoji za smer, potvrda je signalom sa terena.
- Ako FB ne postoji za smer, potvrda je vremenska (po isteku max vremena tranzicije).
*)
IF V_Param.FbOpenExists AND V_Param.FbCloseExists THEN
	(* Oba feedback-a postoje: potvrde su medjusobno iskljucive. *)
	Internal.OpenConfirm := V_Input.OpenFb AND NOT V_Input.CloseFb;
	Internal.CloseConfirm := V_Input.CloseFb AND NOT V_Input.OpenFb;
ELSIF V_Param.FbOpenExists THEN
	(* Postoji samo Open FB: Close potvrda je vremenska. *)
	Internal.OpenConfirm := V_Input.OpenFb;
	Internal.CloseConfirm := (Internal.Step = Cfg.ST_IDLE_CLOSED) OR ((Internal.Step = Cfg.ST_CLOSING) AND Internal.CloseMaxTimer.Q);
ELSIF V_Param.FbCloseExists THEN
	(* Postoji samo Close FB: Open potvrda je vremenska. *)
	Internal.CloseConfirm := V_Input.CloseFb;
	Internal.OpenConfirm := (Internal.Step = Cfg.ST_IDLE_OPENED) OR ((Internal.Step = Cfg.ST_OPENING) AND Internal.OpenMaxTimer.Q);
ELSE
	(* Nema nijednog FB signala: obe potvrde su vremenske. *)
	Internal.OpenConfirm := (Internal.Step = Cfg.ST_IDLE_OPENED) OR ((Internal.Step = Cfg.ST_OPENING) AND Internal.OpenMaxTimer.Q);
	Internal.CloseConfirm := (Internal.Step = Cfg.ST_IDLE_CLOSED) OR ((Internal.Step = Cfg.ST_CLOSING) AND Internal.CloseMaxTimer.Q);
END_IF;

(* ============================================================ *)
(* 4) Rising-edge Enable i inicijalno stanje                     *)
(* ============================================================ *)
IF (NOT Internal.PrevEnable) AND V_Input.Enable THEN
	(* Inicijalna sinkronizacija state machine sa stvarnim feedback-om pri ukljucenju FB-a. *)
	IF Internal.OpenConfirm THEN
		Internal.Step := Cfg.ST_IDLE_OPENED;
	ELSIF Internal.CloseConfirm THEN
		Internal.Step := Cfg.ST_IDLE_CLOSED;
	ELSE
		(* Neodredjena pozicija pri startu -> bezbedan izbor je zatvaranje. *)
		Internal.Step := Cfg.ST_CLOSING;
	END_IF;

	Internal.OpeningStarted := FALSE;
	Internal.ClosingStarted := FALSE;
END_IF;
Internal.PrevEnable := V_Input.Enable;

(* ============================================================ *)
(* 5) Glavna alarm logika (trenutni uslov + latch)              *)
(* ============================================================ *)
Internal.FaultCondition := FALSE;

(* Alarm izvori se evaluiraju svaku iteraciju. Bilo koji aktivan izvor podize FaultCondition. *)
IF V_Input.ManualAlarm THEN
	Internal.FaultCondition := TRUE;
	Internal.FaultCode := Cfg.FLT_MANUAL_ALARM;
END_IF;

(* Konflikt feedback-a ima smisla proveravati samo kada postoje oba signala. *)
IF V_Param.FbOpenExists AND V_Param.FbCloseExists AND V_Input.OpenFb AND V_Input.CloseFb THEN
	Internal.FaultCondition := TRUE;
	Internal.FaultCode := Cfg.FLT_FB_CONFLICT;
END_IF;

(* MinTime = T#0ms je dozvoljen. MaxTime mora biti > T#0ms i >= MinTime. *)
IF (V_Param.OpenMaxTime <= T#0ms) OR (V_Param.CloseMaxTime <= T#0ms) OR
	(V_Param.OpenMaxTime < V_Param.OpenMinTime) OR (V_Param.CloseMaxTime < V_Param.CloseMinTime) THEN
	Internal.FaultCondition := TRUE;
	Internal.FaultCode := Cfg.FLT_TIME_CONFIG_INVALID;
END_IF;

IF Internal.FaultCondition THEN
	(* Latch memorise fault i prebacuje automat u ST_FAULT. *)
	Internal.FaultLatched := TRUE;
	Internal.Step := Cfg.ST_FAULT;
	IF V_Input.EnableManual THEN
		Internal.FaultInManual := TRUE;
	END_IF;
END_IF;

IF V_Input.ResetAlarm AND (NOT Internal.FaultCondition) THEN
	(* Reset je dozvoljen samo kada trenutno nema aktivnog fault uslova. *)
	Internal.FaultLatched := FALSE;
	Internal.FaultInManual := FALSE;
	Internal.FaultCode := Cfg.FLT_NONE;

	IF Internal.OpenConfirm THEN
		Internal.Step := Cfg.ST_IDLE_OPENED;
	ELSIF Internal.CloseConfirm THEN
		Internal.Step := Cfg.ST_IDLE_CLOSED;
	ELSE
		Internal.Step := Cfg.ST_CLOSING;
	END_IF;
END_IF;

(* ============================================================ *)
(* 6) Komandna logika i state machine                            *)
(* ============================================================ *)
(*
State machine - operativni tok:
1) ST_DISABLED:
	- Ulaz: Enable=FALSE
	- Izlaz: CmdOpen=0, CmdClose=0
	- Izlaz iz stanja: na rising edge Enable prelazi u CLOSED/OPENED/CLOSING prema feedback-u

2) ST_IDLE_CLOSED:
	- Ventil je stabilno zatvoren
	- Pri DesiredOpen=TRUE prelazi u ST_OPENING

3) ST_IDLE_OPENED:
	- Ventil je stabilno otvoren
	- Pri DesiredOpen=FALSE prelazi u ST_CLOSING

4) ST_OPENING:
	- CmdOpen=1, CmdClose=0
	- Ako OpenMaxTimer.Q -> FLT_OPEN_TIMEOUT -> ST_FAULT
	- Ako OpenConfirm pre isteka OpenMinTimer -> FLT_OPEN_TOO_FAST -> ST_FAULT
	- Ako OpenConfirm nakon OpenMinTimer -> ST_IDLE_OPENED

5) ST_CLOSING:
	- CmdOpen=0, CmdClose=1
	- Ako CloseMaxTimer.Q -> FLT_CLOSE_TIMEOUT -> ST_FAULT
	- Ako CloseConfirm pre isteka CloseMinTimer -> FLT_CLOSE_TOO_FAST -> ST_FAULT
	- Ako CloseConfirm nakon CloseMinTimer -> ST_IDLE_CLOSED

6) ST_FAULT:
	- CmdOpen/CmdClose prate Internal.DesiredOpen i kada je fault aktivan
	- Ostaje aktivno do validnog ResetAlarm
*)
V_Output.CmdOpen := FALSE;
V_Output.CmdClose := FALSE;

IF NOT V_Input.Enable THEN
	Internal.Step := Cfg.ST_DISABLED;
END_IF;

CASE Internal.Step OF
	0: (* ST_DISABLED *)
		(* Blok nije omogucen: bez komandovanja aktuatora. *)
		V_Output.CmdOpen := FALSE;
		V_Output.CmdClose := FALSE;

	10: (* ST_IDLE_CLOSED *)
		(* Mirno stanje zatvorenog ventila. *)
		V_Output.CmdOpen := FALSE;
		V_Output.CmdClose := FALSE;

		IF Internal.DesiredOpen THEN
			(* Zahtev za otvaranje pokrece tranziciju. *)
			Internal.Step := Cfg.ST_OPENING;
			Internal.OpeningStarted := TRUE;
			Internal.ClosingStarted := FALSE;
		END_IF;

	20: (* ST_IDLE_OPENED *)
		(* Mirno stanje otvorenog ventila. Spring-return ventil zahteva CmdOpen=TRUE da drzi solenoid. *)
		V_Output.CmdOpen := TRUE;
		V_Output.CmdClose := FALSE;

		IF NOT Internal.DesiredOpen THEN
			(* Zahtev za zatvaranje pokrece tranziciju. *)
			Internal.Step := Cfg.ST_CLOSING;
			Internal.ClosingStarted := TRUE;
			Internal.OpeningStarted := FALSE;
		END_IF;

	30: (* ST_OPENING *)
		(* Aktivna komanda otvaranja. Timeri odlucuju da li je tranzicija validna. *)
		V_Output.CmdOpen := TRUE;
		V_Output.CmdClose := FALSE;

		(* Timeout samo ako postoji Open FB. Bez Open FB, istek OpenMaxTime je potvrda krajnjeg polozaja. *)
		IF V_Param.FbOpenExists AND Internal.OpenMaxTimer.Q THEN
			Internal.FaultCondition := TRUE;
			Internal.FaultCode := Cfg.FLT_OPEN_TIMEOUT;
			Internal.FaultLatched := TRUE;
			Internal.Step := Cfg.ST_FAULT;
		ELSIF Internal.OpenConfirm THEN
			IF (NOT V_Param.FbOpenExists) OR Internal.OpenMinTimer.Q THEN
				Internal.Step := Cfg.ST_IDLE_OPENED;
				(* LastOpenTime: vreme od komande do punog otvaranja. *)
				IF V_Param.FbOpenExists THEN
					V_Output.LastOpenTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenMeasureTimer.ET)) / 1000.0;
				ELSE
					V_Output.LastOpenTime := 0.0;
				END_IF;
			ELSE
				Internal.FaultCondition := TRUE;
				Internal.FaultCode := Cfg.FLT_OPEN_TOO_FAST;
				Internal.FaultLatched := TRUE;
				Internal.Step := Cfg.ST_FAULT;
			END_IF;
		END_IF;

		(* LastOpenStartTime: CloseFb falling edge = ventil napustio zatvorenu poziciju. *)
		IF V_Param.FbCloseExists THEN
			IF Internal.PrevCloseFb AND NOT V_Input.CloseFb THEN
				V_Output.LastOpenStartTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.OpenMeasureTimer.ET)) / 1000.0;
			END_IF;
		ELSE
			V_Output.LastOpenStartTime := 0.0;
		END_IF;

	40: (* ST_CLOSING *)
		(* Aktivna komanda zatvaranja. Timeri odlucuju da li je tranzicija validna. *)
		V_Output.CmdOpen := FALSE;
		V_Output.CmdClose := TRUE;

		(* Timeout samo ako postoji Close FB. Bez Close FB, istek CloseMaxTime je potvrda krajnjeg polozaja. *)
		IF V_Param.FbCloseExists AND Internal.CloseMaxTimer.Q THEN
			Internal.FaultCondition := TRUE;
			Internal.FaultCode := Cfg.FLT_CLOSE_TIMEOUT;
			Internal.FaultLatched := TRUE;
			Internal.Step := Cfg.ST_FAULT;
		ELSIF Internal.CloseConfirm THEN
			IF (NOT V_Param.FbCloseExists) OR Internal.CloseMinTimer.Q THEN
				Internal.Step := Cfg.ST_IDLE_CLOSED;
				(* LastCloseTime: vreme od ukidanja komande do punog zatvaranja. *)
				IF V_Param.FbCloseExists THEN
					V_Output.LastCloseTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseMeasureTimer.ET)) / 1000.0;
				ELSE
					V_Output.LastCloseTime := 0.0;
				END_IF;
			ELSE
				Internal.FaultCondition := TRUE;
				Internal.FaultCode := Cfg.FLT_CLOSE_TOO_FAST;
				Internal.FaultLatched := TRUE;
				Internal.Step := Cfg.ST_FAULT;
			END_IF;
		END_IF;

		(* LastCloseStartTime: OpenFb falling edge = ventil napustio otvorenu poziciju. *)
		IF V_Param.FbOpenExists THEN
			IF Internal.PrevOpenFb AND NOT V_Input.OpenFb THEN
				V_Output.LastCloseStartTime := UDINT_TO_REAL(TIME_TO_UDINT(Internal.CloseMeasureTimer.ET)) / 1000.0;
			END_IF;
		ELSE
			V_Output.LastCloseStartTime := 0.0;
		END_IF;

	90: (* ST_FAULT *)
		(* Default: komanda blokirana u faultu - bezbedan polozaj (oba FALSE). *)
		(* ForceCmd=TRUE: komanda prolazi - operator svesno override-uje fault blokadu. *)
		IF V_Input.ForceCmd THEN
			V_Output.CmdOpen  := Internal.DesiredOpen;
			V_Output.CmdClose := NOT Internal.DesiredOpen;
		ELSE
			V_Output.CmdOpen  := FALSE;
			V_Output.CmdClose := FALSE;
		END_IF;

ELSE
	(* Defensive fallback: bilo koje nepoznato stanje forsira fault. *)
	Internal.Step := Cfg.ST_FAULT;
	Internal.FaultCondition := TRUE;
	Internal.FaultLatched := TRUE;
	IF Internal.FaultCode = Cfg.FLT_NONE THEN
		Internal.FaultCode := Cfg.FLT_FB_CONFLICT;
	END_IF;
END_CASE;

(* ============================================================ *)
(* 7) Stabilni feedback nadzor u mirnim stanjima                 *)
(* ============================================================ *)
(* U stabilnim stanjima provera postoji samo za smer koji ima odgovarajuci FB. *)
Internal.StableOpenedFbTimer.IN := V_Param.FbOpenExists AND (Internal.Step = Cfg.ST_IDLE_OPENED) AND (NOT Internal.OpenConfirm);
Internal.StableOpenedFbTimer.PT := Cfg.StableFbDelay_Valid;

Internal.StableClosedFbTimer.IN := V_Param.FbCloseExists AND (Internal.Step = Cfg.ST_IDLE_CLOSED) AND (NOT Internal.CloseConfirm);
Internal.StableClosedFbTimer.PT := Cfg.StableFbDelay_Valid;

Internal.StableOpenedFbError := Internal.StableOpenedFbTimer.Q;
Internal.StableClosedFbError := Internal.StableClosedFbTimer.Q;

IF Internal.StableOpenedFbError THEN
	(* U otvorenom stabilnom stanju izgubili smo open potvrdu -> fault. *)
	Internal.FaultCondition := TRUE;
	Internal.FaultCode := Cfg.FLT_STABLE_OPEN_FB;
	Internal.FaultLatched := TRUE;
	Internal.Step := Cfg.ST_FAULT;
END_IF;

IF Internal.StableClosedFbError THEN
	(* U zatvorenom stabilnom stanju izgubili smo close potvrdu -> fault. *)
	Internal.FaultCondition := TRUE;
	Internal.FaultCode := Cfg.FLT_STABLE_CLOSE_FB;
	Internal.FaultLatched := TRUE;
	Internal.Step := Cfg.ST_FAULT;
END_IF;

(* ============================================================ *)
(* 8) Tajmeri za tranzicije i merenje vremena                    *)
(* ============================================================ *)
(* OpenMin/OpenMax vaze samo tokom ST_OPENING. *)
Internal.OpenMinTimer.IN := (Internal.Step = Cfg.ST_OPENING);
Internal.OpenMinTimer.PT := Cfg.OpenMinTime_Valid;

Internal.OpenMaxTimer.IN := (Internal.Step = Cfg.ST_OPENING);
Internal.OpenMaxTimer.PT := Cfg.OpenMaxTime_Valid;

(* CloseMin/CloseMax vaze samo tokom ST_CLOSING. *)
Internal.CloseMinTimer.IN := (Internal.Step = Cfg.ST_CLOSING);
Internal.CloseMinTimer.PT := Cfg.CloseMinTime_Valid;

Internal.CloseMaxTimer.IN := (Internal.Step = Cfg.ST_CLOSING);
Internal.CloseMaxTimer.PT := Cfg.CloseMaxTime_Valid;

(* Measure tajmeri sluze za dijagnostiku i pracenje trajanja tranzicije. *)
Internal.OpenMeasureTimer.IN := (Internal.Step = Cfg.ST_OPENING);
Internal.OpenMeasureTimer.PT := T#24d;

Internal.CloseMeasureTimer.IN := (Internal.Step = Cfg.ST_CLOSING);
Internal.CloseMeasureTimer.PT := T#24d;

(* Sve TON instance se izvrsavaju na kraju scan-a, nakon azuriranja IN/PT polja. *)
Internal.OpenMinTimer();
Internal.OpenMaxTimer();
Internal.CloseMinTimer();
Internal.CloseMaxTimer();
Internal.OpenMeasureTimer();
Internal.CloseMeasureTimer();
Internal.StableClosedFbTimer();
Internal.StableOpenedFbTimer();

(* ============================================================ *)
(* 9) Tekstovi stanja i alarma za HMI                            *)
(* ============================================================ *)
(* State_comment je jednoznacan opis aktivnog state-a. *)
CASE Internal.Step OF
	0: (* ST_DISABLED *)
		V_Output.State_comment := 'ST_DISABLED - FB nije omogucen';
	10: (* ST_IDLE_CLOSED *)
		V_Output.State_comment := 'ST_IDLE_CLOSED - ventil stabilno zatvoren';
	20: (* ST_IDLE_OPENED *)
		V_Output.State_comment := 'ST_IDLE_OPENED - ventil stabilno otvoren';
	30: (* ST_OPENING *)
		V_Output.State_comment := 'ST_OPENING - ventil je u tranziciji ka otvorenom';
	40: (* ST_CLOSING *)
		V_Output.State_comment := 'ST_CLOSING - ventil je u tranziciji ka zatvorenom';
	90: (* ST_FAULT *)
		V_Output.State_comment := 'ST_FAULT - alarm aktivan, komanda je i dalje dostupna';
ELSE
	V_Output.State_comment := 'ST_UNKNOWN - nepoznato stanje';
END_CASE;

(* Kratka dijagnostika po trenutnom stanju procesa, nezavisno od fault text-a. *)
CASE Internal.Step OF
	0: (* ST_DISABLED *)
		V_Output.Diag := 'DISABLED';
	10: (* ST_IDLE_CLOSED *)
		V_Output.Diag := 'READY_CLOSED';
	20: (* ST_IDLE_OPENED *)
		V_Output.Diag := 'READY_OPENED';
	30: (* ST_OPENING *)
		V_Output.Diag := 'TRANSITION_OPENING';
	40: (* ST_CLOSING *)
		V_Output.Diag := 'TRANSITION_CLOSING';
	90: (* ST_FAULT *)
		V_Output.Diag := 'FAULT_ACTIVE';
ELSE
	V_Output.Diag := 'STATE_UNKNOWN';
END_CASE;

CASE Internal.FaultCode OF
	0: (* FLT_NONE *)
		Internal.FaultText := 'FLT_NONE - nema aktivnog uzroka alarma';
	1: (* FLT_MANUAL_ALARM *)
		Internal.FaultText := 'FLT_MANUAL_ALARM - rucno zadat alarm';
	2: (* FLT_FB_CONFLICT *)
		Internal.FaultText := 'FLT_FB_CONFLICT - OpenFb i CloseFb su istovremeno TRUE';
	3: (* FLT_OPEN_TIMEOUT *)
		Internal.FaultText := 'FLT_OPEN_TIMEOUT - prekoraceno maksimalno vreme otvaranja';
	4: (* FLT_OPEN_TOO_FAST *)
		Internal.FaultText := 'FLT_OPEN_TOO_FAST - dostignut open feedback pre minimalnog vremena';
	5: (* FLT_CLOSE_TIMEOUT *)
		Internal.FaultText := 'FLT_CLOSE_TIMEOUT - prekoraceno maksimalno vreme zatvaranja';
	6: (* FLT_CLOSE_TOO_FAST *)
		Internal.FaultText := 'FLT_CLOSE_TOO_FAST - dostignut close feedback pre minimalnog vremena';
	7: (* FLT_STABLE_OPEN_FB *)
		Internal.FaultText := 'FLT_STABLE_OPEN_FB - nestabilan/open feedback u otvorenom stanju';
	8: (* FLT_STABLE_CLOSE_FB *)
		Internal.FaultText := 'FLT_STABLE_CLOSE_FB - nestabilan/close feedback u zatvorenom stanju';
	9: (* FLT_TIME_CONFIG_INVALID *)
		Internal.FaultText := 'FLT_TIME_CONFIG_INVALID - nevalidna podesavanja vremena';
ELSE
	Internal.FaultText := 'FLT_UNKNOWN - nepoznat uzrok alarma';
END_CASE;

(* Ako fault postoji, dijagnostika prelazi na jednoznacan fault uzrok. *)
IF Internal.FaultLatched OR Internal.FaultCondition THEN
	CASE Internal.FaultCode OF
		0: V_Output.Diag := 'FAULT_UNSPECIFIED';
		1: V_Output.Diag := 'FAULT_MANUAL_ALARM';
		2: V_Output.Diag := 'FAULT_FB_CONFLICT';
		3: V_Output.Diag := 'FAULT_OPEN_TIMEOUT';
		4: V_Output.Diag := 'FAULT_OPEN_TOO_FAST';
		5: V_Output.Diag := 'FAULT_CLOSE_TIMEOUT';
		6: V_Output.Diag := 'FAULT_CLOSE_TOO_FAST';
		7: V_Output.Diag := 'FAULT_STABLE_OPEN_FB';
		8: V_Output.Diag := 'FAULT_STABLE_CLOSE_FB';
		9: V_Output.Diag := 'FAULT_TIME_CONFIG';
	ELSE
		V_Output.Diag := 'FAULT_UNKNOWN';
	END_CASE;
END_IF;

(* ============================================================ *)
(* 10) Mapiranje izlaza                                           *)
(* ============================================================ *)
(* Struktuirani i cisti izlazi mapirani su na samom kraju radi preglednosti. *)
V_Output.Status := V_Input.Enable AND (NOT Internal.FaultLatched);
V_Output.InTransition := (Internal.Step = Cfg.ST_OPENING) OR (Internal.Step = Cfg.ST_CLOSING);
V_Output.ResetAllowed := Internal.FaultLatched AND (NOT Internal.FaultCondition);
V_Output.ForceActive := Internal.FaultLatched AND V_Input.ForceCmd;
V_Output.State := Internal.Step;
V_Output.FaultLatched := Internal.FaultLatched;
V_Output.FaultCondition := Internal.FaultCondition;
V_Output.FaultInManual := Internal.FaultInManual;
V_Output.FaultCode := Internal.FaultCode;
V_Output.FaultText := Internal.FaultText;
Opened := Internal.OpenConfirm;
Closed := Internal.CloseConfirm;

(* Memorija signala za falling-edge detekciju u narednom scan-u. *)
Internal.PrevCloseFb := V_Input.CloseFb;
Internal.PrevOpenFb  := V_Input.OpenFb;

END_FUNCTION_BLOCK
