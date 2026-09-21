PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* 1) Lokalni PT-BRB2 procesni ugovor                                       *)
	(* ======================================================================== *)
	(* PGRad_BRB2Cmd je jedini lokalni izvor komandi. Ovaj program preslikava   *)
	(* komande u zajednicki procesni prikaz koji koristi master sekvenca.       *)
	PGRad_BRB2.RadKaPodstanici := PGRad_BRB2Cmd.RadKaPodstanici;
	PGRad_BRB2.ManualMode := PGRad_BRB2Cmd.ManualMode;
	PGRad_BRB2.ManualSequence := PGRad_BRB2Cmd.ManualSequence;
	PGRad_BRB2.ManualStart := PGRad_BRB2Cmd.ManualStart;
	PGRad_BRB2.ManualStop := PGRad_BRB2Cmd.ManualStop;
	PGRad_BRB2.ManualNextStep := PGRad_BRB2Cmd.ManualNextStep;
	PGRad_BRB2.ManualAbort := PGRad_BRB2Cmd.ManualAbort;
	PGRad_BRB2.ZahtevStarta := PGRad_BRB2Cmd.ZahtevStarta;
	PGRad_BRB2.ZahtevZaustavljanja := PGRad_BRB2Cmd.ZahtevZaustavljanja;
	PGRad_BRB2.VentiliPodstaniceZatvoreni := PGRad_BRB2Cmd.VentiliPodstaniceZatvoreni;
	PGRad_BRB2.PritisakIEBKB1 := PGRad_BRB2Cmd.PritisakIEBKB1;
	PGRad_BRB2.PodstanicaURezimuRada := PGRad_BRB2Cmd.PodstanicaURezimuRada;
	PGRad_BRB2.RegulationMode := PGRad_BRB2Cmd.RegulationMode;
	PGRad_BRB2.RegulationPV := PGRad_BRB2Cmd.RegulationPV;
	PGRad_BRB2.RegulationSP := PGRad_BRB2Cmd.RegulationSP;
	PGRad_BRB2.RegulationPVValid := PGRad_BRB2Cmd.RegulationPVValid;
	PGRad_BRB2.RegulationInvert := PGRad_BRB2Cmd.RegulationInvert;
	(* Brojac se menja svakim ciklusom i udaljenom PLC-u dokazuje da snapshot   *)
	(* nije samo poslednja zadrzana vrednost nakon prekida komunikacije.        *)
	PGRad_BRB2Cmd.CommandCounter := PGRad_BRB2Cmd.CommandCounter + 1;
	PGRad_BRB2.CommandCounter := PGRad_BRB2Cmd.CommandCounter;

	(* ======================================================================== *)
	(* 2) PT izlazni AsIMA snapshot                                             *)
	(* ======================================================================== *)
	(* Tx struktura je jedini komunikacioni izlaz Podstanice prema BRB2.        *)
	(* Odvajanje od lokalnog prikaza sprecava vise pisaca nad istim podacima.   *)
	PGRad_BRB2_Tx.RadKaPodstanici := PGRad_BRB2Cmd.RadKaPodstanici;
	PGRad_BRB2_Tx.ManualMode := PGRad_BRB2Cmd.ManualMode;
	PGRad_BRB2_Tx.ManualSequence := PGRad_BRB2Cmd.ManualSequence;
	PGRad_BRB2_Tx.ManualStart := PGRad_BRB2Cmd.ManualStart;
	PGRad_BRB2_Tx.ManualStop := PGRad_BRB2Cmd.ManualStop;
	PGRad_BRB2_Tx.ManualNextStep := PGRad_BRB2Cmd.ManualNextStep;
	PGRad_BRB2_Tx.ManualAbort := PGRad_BRB2Cmd.ManualAbort;
	PGRad_BRB2_Tx.CommandCounter := PGRad_BRB2Cmd.CommandCounter;
	PGRad_BRB2_Tx.ZahtevStarta := PGRad_BRB2Cmd.ZahtevStarta;
	PGRad_BRB2_Tx.ZahtevZaustavljanja := PGRad_BRB2Cmd.ZahtevZaustavljanja;
	PGRad_BRB2_Tx.VentiliPodstaniceZatvoreni := PGRad_BRB2Cmd.VentiliPodstaniceZatvoreni;
	PGRad_BRB2_Tx.PritisakIEBKB1 := PGRad_BRB2Cmd.PritisakIEBKB1;
	PGRad_BRB2_Tx.PodstanicaURezimuRada := PGRad_BRB2Cmd.PodstanicaURezimuRada;
	PGRad_BRB2_Tx.RegulationMode := PGRad_BRB2Cmd.RegulationMode;
	PGRad_BRB2_Tx.RegulationPV := PGRad_BRB2Cmd.RegulationPV;
	PGRad_BRB2_Tx.RegulationSP := PGRad_BRB2Cmd.RegulationSP;
	PGRad_BRB2_Tx.RegulationPVValid := PGRad_BRB2Cmd.RegulationPVValid;
	PGRad_BRB2_Tx.RegulationInvert := PGRad_BRB2Cmd.RegulationInvert;

	(* ======================================================================== *)
	(* 3) BRB2 ulazni procesni status                                           *)
	(* ======================================================================== *)
	(* 3.1) StatusCounter mora da se menja; zadrzan snapshot duze od 5 s nije validna veza. *)
	(* Svaka promena ponovo pokrece vremenski nadzor. Nepromenjen brojac drzi    *)
	(* TON aktivnim sve dok se ne potvrdi timeout komunikacionog statusa.       *)
	IF PGRad_BRB2_Rx.StatusCounter <> PGRad_BRB2Watchdog.LastCounter THEN
		PGRad_BRB2Watchdog.LastCounter := PGRad_BRB2_Rx.StatusCounter;
		PGRad_BRB2Watchdog.ReceivedOnce := TRUE;
		PGRad_BRB2Watchdog.ReceiveTimeout.IN := FALSE;
	ELSE
		PGRad_BRB2Watchdog.ReceiveTimeout.IN := TRUE;
	END_IF;
	PGRad_BRB2Watchdog.ReceiveTimeout.PT := T#5s;
	PGRad_BRB2Watchdog.ReceiveTimeout();
	PGRad_BRB2Watchdog.Valid :=
		PGRad_BRB2Watchdog.ReceivedOnce AND NOT PGRad_BRB2Watchdog.ReceiveTimeout.Q;

	(* 3.2) Lokalni proces prihvata BRB2 status samo dok je komunikacija validna. *)
	IF PGRad_BRB2Watchdog.Valid THEN
		PGRad_BRB2.PumpaAktivna := PGRad_BRB2_Rx.PumpaAktivna;
		PGRad_BRB2.IspiranjeProtokDostignut := PGRad_BRB2_Rx.IspiranjeProtokDostignut;
		PGRad_BRB2.IspiranjeMinTrajanjeDostignuto := PGRad_BRB2_Rx.IspiranjeMinTrajanjeDostignuto;
		PGRad_BRB2.StopSPDostignut := PGRad_BRB2_Rx.StopSPDostignut;
		PGRad_BRB2.RB2V01Zatvoren := PGRad_BRB2_Rx.RB2V01Zatvoren;
		PGRad_BRB2.RB2V02Zatvoren := PGRad_BRB2_Rx.RB2V02Zatvoren;
		PGRad_BRB2.StatusCounter := PGRad_BRB2_Rx.StatusCounter;
		PGRad_BRB2.BRB2Fault := PGRad_BRB2_Rx.BRB2Fault;
		PGRad_BRB2.BRB2FaultCode := PGRad_BRB2_Rx.BRB2FaultCode;
		PGRad_BRB2.RegulationPVFault := PGRad_BRB2_Rx.RegulationPVFault;
	ELSE
		PGRad_BRB2.PumpaAktivna := FALSE;
		PGRad_BRB2.IspiranjeProtokDostignut := FALSE;
		PGRad_BRB2.IspiranjeMinTrajanjeDostignuto := FALSE;
		PGRad_BRB2.StopSPDostignut := FALSE;
		PGRad_BRB2.RB2V01Zatvoren := FALSE;
		PGRad_BRB2.RB2V02Zatvoren := FALSE;
		PGRad_BRB2.StatusCounter := 0;
		PGRad_BRB2.BRB2Fault := TRUE;
		PGRad_BRB2.BRB2FaultCode := 3; (* Gubitak komunikacije sa BRB2. *)
		PGRad_BRB2.RegulationPVFault := FALSE;
	END_IF;
END_PROGRAM