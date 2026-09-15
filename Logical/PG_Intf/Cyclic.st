PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* 1) Lokalni PT-BRB2 procesni ugovor                                       *)
	(* ======================================================================== *)
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

	(* ======================================================================== *)
	(* 2) PT izlazni AsIMA snapshot                                             *)
	(* ======================================================================== *)
	PGRad_BRB2_Tx.RadKaPodstanici := PGRad_BRB2Cmd.RadKaPodstanici;
	PGRad_BRB2_Tx.ManualMode := PGRad_BRB2Cmd.ManualMode;
	PGRad_BRB2_Tx.ManualSequence := PGRad_BRB2Cmd.ManualSequence;
	PGRad_BRB2_Tx.ManualStart := PGRad_BRB2Cmd.ManualStart;
	PGRad_BRB2_Tx.ManualStop := PGRad_BRB2Cmd.ManualStop;
	PGRad_BRB2_Tx.ManualNextStep := PGRad_BRB2Cmd.ManualNextStep;
	PGRad_BRB2_Tx.ManualAbort := PGRad_BRB2Cmd.ManualAbort;
	PGRad_BRB2_Tx.ZahtevStarta := PGRad_BRB2Cmd.ZahtevStarta;
	PGRad_BRB2_Tx.ZahtevZaustavljanja := PGRad_BRB2Cmd.ZahtevZaustavljanja;
	PGRad_BRB2_Tx.VentiliPodstaniceZatvoreni := PGRad_BRB2Cmd.VentiliPodstaniceZatvoreni;
	PGRad_BRB2_Tx.PritisakIEBKB1 := PGRad_BRB2Cmd.PritisakIEBKB1;
	PGRad_BRB2_Tx.PodstanicaURezimuRada := PGRad_BRB2Cmd.PodstanicaURezimuRada;

	(* ======================================================================== *)
	(* 3) BRB2 ulazni procesni status                                           *)
	(* ======================================================================== *)
	PGRad_BRB2.PumpaAktivna := PGRad_BRB2_Rx.PumpaAktivna;
	PGRad_BRB2.IspiranjeProtokDostignut := PGRad_BRB2_Rx.IspiranjeProtokDostignut;
	PGRad_BRB2.IspiranjeMinTrajanjeDostignuto := PGRad_BRB2_Rx.IspiranjeMinTrajanjeDostignuto;
	PGRad_BRB2.StopSPDostignut := PGRad_BRB2_Rx.StopSPDostignut;
	PGRad_BRB2.RB2V01Zatvoren := PGRad_BRB2_Rx.RB2V01Zatvoren;
	PGRad_BRB2.RB2V02Zatvoren := PGRad_BRB2_Rx.RB2V02Zatvoren;
END_PROGRAM