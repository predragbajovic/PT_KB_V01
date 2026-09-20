PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* 1) Priprema i prenos PG01 lokalnog snapshot-a                            *)
	(* ======================================================================== *)
	(* PublishPG01 priprema lokalni AsIMA DTO; IMAcomm obavlja dvosmerni prenos. *)
	(* Ako statusInit nije IMA_OK, PublishPG01 i IMAcomm se ne pozivaju. *)
	IF statusInit = IMA_OK THEN
		PublishPG01;
		statusComm := IMAcomm(stationId, connInfoPV, connInfoAUX);
	END_IF

	(* ======================================================================== *)
	(* 2) Automatsko brisanje komunikacione greske                              *)
	(* ======================================================================== *)
	(* ClearError se zadaje samo dok AsIMA prijavljuje gresku ili povezivanje. *)
	IF (connInfoPV.connectionStatus = IMA_ERROR)
		OR (connInfoPV.connectionStatus = IMA_CONNECTING) THEN
		connInfoPV.commandClearError := 1;
	ELSE
		connInfoPV.commandClearError := 0;
	END_IF
	
END_PROGRAM
