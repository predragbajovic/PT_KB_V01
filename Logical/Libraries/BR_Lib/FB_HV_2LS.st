FUNCTION_BLOCK FB_HV_2LS (* Rucni ventil sa dva krajnja prekidaca *)

(* ============================================================ *)
(* 1) Validacija parametara                                      *)
(* ============================================================ *)
(* Konverzija REAL sekundi u TIME milisekundi sa bezbednim default-om. *)
IF HV_Param.T_OpenClose_SP <= 0.0 THEN
	Cfg.T_OpenClose_Valid := T#10s;
ELSE
	Cfg.T_OpenClose_Valid := DINT_TO_TIME(REAL_TO_DINT(HV_Param.T_OpenClose_SP * 1000.0));
END_IF;

IF HV_Param.T_BothActive_SP <= 0.0 THEN
	Cfg.T_BothActive_Valid := T#500ms;
ELSE
	Cfg.T_BothActive_Valid := DINT_TO_TIME(REAL_TO_DINT(HV_Param.T_BothActive_SP * 1000.0));
END_IF;

(* ============================================================ *)
(* 2) Enable logika i resetovanje pri deaktivaciji               *)
(* ============================================================ *)
IF NOT HV_Input.Enable THEN
	Internal.Step := Cfg.ST_DISABLED;
	Internal.FaultLatched := FALSE;
	Internal.FaultCondition := FALSE;
	Internal.FaultCode := Cfg.FLT_NONE;
END_IF;

(* ============================================================ *)
(* 3) Evaluacija fault uslova (samo kada je Enable=TRUE)          *)
(* ============================================================ *)
IF HV_Input.Enable THEN
	(* Sirovi fizicki uslovi za proveru tokom latch-a. *)
	Internal.BothActiveRaw := HV_Input.CloseFb AND HV_Input.OpenFb;
	Internal.TransitionRaw := NOT HV_Input.CloseFb AND NOT HV_Input.OpenFb;

	Internal.FaultCondition := FALSE;

	(* Tajmerski potvrdjeni uslovi se uvek evaluiraju, bez obzira na latch. *)
	(* Novi alarm prepisuje prethodni ako prethodni nije aknowledgovan.     *)
	(* Prioritet: Stanje 5 (oba aktivna) je iznad Stanja 4 (tranzicija timeout). *)
	IF Internal.TonBothActive.Q THEN
		Internal.FaultCondition := TRUE;
		Internal.FaultCode := Cfg.FLT_BOTH_ACTIVE;
	ELSIF Internal.TonTransition.Q THEN
		Internal.FaultCondition := TRUE;
		Internal.FaultCode := Cfg.FLT_TRANSITION_TIMEOUT;
	END_IF;

	(* Kada je latch aktivan ali tajmeri nisu aktivni, FaultCondition se odrzava *)
	(* na osnovu fizickog signala i tekuceg FaultCode-a.                         *)
	(* Ovo sprecava reset dok fizicki uzrok nije otklonjen.                      *)
	IF Internal.FaultLatched AND NOT Internal.FaultCondition THEN
		IF (Internal.FaultCode = Cfg.FLT_BOTH_ACTIVE) AND Internal.BothActiveRaw THEN
			Internal.FaultCondition := TRUE;
		END_IF;
		IF (Internal.FaultCode = Cfg.FLT_TRANSITION_TIMEOUT) AND Internal.TransitionRaw THEN
			Internal.FaultCondition := TRUE;
		END_IF;
	END_IF;

	(* Latch: jednom aktivan, ostaje do validnog reset-a. *)
	IF Internal.FaultCondition AND NOT Internal.FaultLatched THEN
		Internal.FaultLatched := TRUE;
	END_IF;

	(* Reset: dozvoljen samo kada trenutno nema aktivnog fault uslova (fizicki uzrok otklonjen). *)
	IF HV_Input.ResetAlarm AND NOT Internal.FaultCondition THEN
		Internal.FaultLatched := FALSE;
		Internal.FaultCode := Cfg.FLT_NONE;
	END_IF;

	(* ============================================================ *)
	(* 4) Odredjivanje stanja na osnovu DI signala i fault-a        *)
	(* Step uvek prati trenutno fizicko stanje DI signala.          *)
	(* Alarm state (4/5) se prikazuje samo dok je FaultCondition    *)
	(* aktivna (fizicki uzrok prisutan). Kada uzrok nestane,        *)
	(* Step se vraca na 1/2/3 - AlarmLatched i FaultText ostaju    *)
	(* jednoznacni pokazatelj da alarm ceka potvrdu.                *)
	(* ============================================================ *)
	IF Internal.FaultCondition THEN
		(* Aktivni fizicki fault uslov -> alarm state. *)
		IF Internal.FaultCode = Cfg.FLT_BOTH_ACTIVE THEN
			Internal.Step := Cfg.ST_FLT_BOTH_ACTIVE;
		ELSE
			Internal.Step := Cfg.ST_FLT_TRANSITION_TIMEOUT;
		END_IF;
	ELSIF HV_Input.CloseFb AND NOT HV_Input.OpenFb THEN
		Internal.Step := Cfg.ST_CLOSED;
	ELSIF NOT HV_Input.CloseFb AND HV_Input.OpenFb THEN
		Internal.Step := Cfg.ST_OPEN;
	ELSIF Internal.TransitionRaw THEN
		Internal.Step := Cfg.ST_TRANSITION;
	ELSIF Internal.BothActiveRaw THEN
		(* Oba signala aktivna ali tajmer jos nije istekao - zadrzava se prethodno stanje. *)
		(* Implicitno: Internal.Step se ne menja, filtriranje suma. *)
	END_IF;
END_IF;

(* ============================================================ *)
(* 5) Tajmeri                                                     *)
(* ============================================================ *)
(* Tranzicioni tajmer: aktivan samo kad ni jedan DI nije aktivan i nema latched fault-a. *)
Internal.TonTransition.IN := HV_Input.Enable AND Internal.TransitionRaw AND NOT Internal.FaultLatched;
Internal.TonTransition.PT := Cfg.T_OpenClose_Valid;

(* Debounce tajmer za oba signala: aktivan samo kad su oba DI aktivna i nema latched fault-a. *)
Internal.TonBothActive.IN := HV_Input.Enable AND Internal.BothActiveRaw AND NOT Internal.FaultLatched;
Internal.TonBothActive.PT := Cfg.T_BothActive_Valid;

(* TON instance se pozivaju na kraju sekcije, nakon azuriranja IN/PT polja. *)
Internal.TonTransition();
Internal.TonBothActive();

(* ============================================================ *)
(* 6) Tekstovi stanja i alarma za HMI                            *)
(* ============================================================ *)
CASE Internal.Step OF
	0: (* ST_DISABLED *)
		HV_Output.State_comment := 'Stanje 0: Blok neaktivan';
	1: (* ST_CLOSED *)
		HV_Output.State_comment := 'Stanje 1: Aktivan - zatvoren';
	2: (* ST_OPEN *)
		HV_Output.State_comment := 'Stanje 2: Aktivan - otvoren';
	3: (* ST_TRANSITION *)
		HV_Output.State_comment := 'Stanje 3: Aktivan - u tranziciji';
	4: (* ST_FLT_TRANSITION_TIMEOUT *)
		HV_Output.State_comment := 'Stanje 4: Predugo u medjupolozaju (Alarm)';
	5: (* ST_FLT_BOTH_ACTIVE *)
		HV_Output.State_comment := 'Stanje 5: Aktivna oba signala (Alarm)';
ELSE
	HV_Output.State_comment := 'Nepoznato stanje';
END_CASE;

CASE Internal.FaultCode OF
	0: (* FLT_NONE *)
		HV_Output.FaultText := 'FLT_NONE - nema aktivnog alarma';
	1: (* FLT_TRANSITION_TIMEOUT *)
		HV_Output.FaultText := 'FLT_TRANSITION_TIMEOUT - ventil predugo u medjupolozaju';
	2: (* FLT_BOTH_ACTIVE *)
		HV_Output.FaultText := 'FLT_BOTH_ACTIVE - oba krajnja prekidaca aktivna';
ELSE
	HV_Output.FaultText := 'FLT_UNKNOWN - nepoznat uzrok alarma';
END_CASE;

(* ============================================================ *)
(* 7) Mapiranje izlaza                                            *)
(* ============================================================ *)
(* Status FALSE samo kada je blok ugasen ili kada je alarm fizicki aktivan. *)
(* Kada fizicki uzrok nestane ali alarm ceka ACK, Status je TRUE.           *)
HV_Output.Status := HV_Input.Enable AND NOT Internal.FaultCondition;
HV_Output.State := Internal.Step;
HV_Output.AlarmActive := Internal.FaultCondition;
HV_Output.AlarmLatched := Internal.FaultLatched;
HV_Output.FaultCode := Internal.FaultCode;

END_FUNCTION_BLOCK
