PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* 1) Priprema PT procesnog snapshot-a                                      *)
	(* ======================================================================== *)
	PGRad_BRB2_Tx.RadKaPodstanici := PGRad_BRB2.RadKaPodstanici;
	PGRad_BRB2_Tx.ZahtevStarta := PGRad_BRB2.ZahtevStarta;
	PGRad_BRB2_Tx.ZahtevZaustavljanja := PGRad_BRB2.ZahtevZaustavljanja;
	PGRad_BRB2_Tx.VentiliPodstaniceZatvoreni := PGRad_BRB2.VentiliPodstaniceZatvoreni;
	PGRad_BRB2_Tx.PritisakIEBKB1 := PGRad_BRB2.PritisakIEBKB1;
	PGRad_BRB2_Tx.PodstanicaURezimuRada := PGRad_BRB2.PodstanicaURezimuRada;

	(* ======================================================================== *)
	(* 2) Priprema i prenos PG01 lokalnog snapshot-a                            *)
	(* ======================================================================== *)
	(* PublishPG01 priprema lokalni AsIMA DTO; IMAcomm obavlja dvosmerni prenos. *)
	IF statusInit = IMA_OK THEN
		PublishPG01;
		statusComm := IMAcomm(stationId, connInfoPV, connInfoAUX);
	END_IF

	(* ======================================================================== *)
	(* 3) Prijem BRB2 procesnog statusa                                         *)
	(* ======================================================================== *)
	PGRad_BRB2.PumpaAktivna := PGRad_BRB2_Rx.PumpaAktivna;
	PGRad_BRB2.IspiranjeProtokDostignut := PGRad_BRB2_Rx.IspiranjeProtokDostignut;
	PGRad_BRB2.IspiranjeMinTrajanjeDostignuto := PGRad_BRB2_Rx.IspiranjeMinTrajanjeDostignuto;
	PGRad_BRB2.StopSPDostignut := PGRad_BRB2_Rx.StopSPDostignut;
	PGRad_BRB2.RB2V01Zatvoren := PGRad_BRB2_Rx.RB2V01Zatvoren;
	PGRad_BRB2.RB2V02Zatvoren := PGRad_BRB2_Rx.RB2V02Zatvoren;

	(* ======================================================================== *)
	(* 4) Automatsko brisanje komunikacione greske                              *)
	(* ======================================================================== *)
	(* ClearError se zadaje samo dok AsIMA prijavljuje gresku ili povezivanje. *)
	IF (connInfoPV.connectionStatus = IMA_ERROR)
		OR (connInfoPV.connectionStatus = IMA_CONNECTING) THEN
		connInfoPV.commandClearError := 1;
	ELSE
		connInfoPV.commandClearError := 0;
	END_IF
	
	PG01_Remote := PG01_Remote;
END_PROGRAM
