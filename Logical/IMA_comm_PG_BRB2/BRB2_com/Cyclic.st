PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* BRB2_COM - ASIMA PRENOS PG01 SNAPSHOT-A                                *)
	(* COMMON: priprema lokalni PG01 snapshot i poziva AsIMA komunikaciju.     *)
	(* AUTO/MANUAL: komande se ne generisu ovde; samo se prenose kroz ugovor.  *)
	(* STOP/FAULT: pri IMA gresci aktivira se brisanje komunikacione greske.   *)
	(* STATUS: connectionStatus i statusComm ostaju vlasnistvo komunikacije.   *)
	(* ======================================================================== *)
	(* ======================================================================== *)
	(* 1) HMI reset AsIMA sesije                                                *)
	IF ResetCommunication THEN
		ResetCommunication := FALSE;
		ResetInProgress := TRUE;
		ResetDone := FALSE;
		ResetFault := FALSE;
		IF stationId <> 0 THEN
			statusClose := IMAclose(stationId);
		END_IF;
		stationId := 0;
		statusInit := 0;
		pDatObjName := ADR('BRB2');
		statusInit := IMAinit(pDatObjName, errorInfo, ADR(stationId));
		PGRad_BRB2Watchdog.LastCounter := 0;
		PGRad_BRB2Watchdog.ReceivedOnce := FALSE;
		PGRad_BRB2Watchdog.ReceiveTimeout(IN := FALSE, PT := T#5s);
		PGRad_BRB2Watchdog.Valid := FALSE;
		ResetInProgress := FALSE;
		ResetDone := (statusInit = IMA_OK) AND (stationId <> 0);
		ResetFault := NOT ResetDone;
	END_IF;

	(* 2) Priprema i prenos PG01 lokalnog snapshot-a                            *)
	(* ======================================================================== *)
	(* PublishPG01 priprema lokalni AsIMA DTO; IMAcomm obavlja dvosmerni prenos. *)
	(* Ako statusInit nije IMA_OK, PublishPG01 i IMAcomm se ne pozivaju. *)
	IF statusInit = IMA_OK THEN
		PublishPG01;
		statusComm := IMAcomm(stationId, connInfoPV, connInfoAUX);
	END_IF

	(* ======================================================================== *)
	(* 3) Automatsko brisanje komunikacione greske                              *)
	(* ======================================================================== *)
	(* ClearError se zadaje samo dok AsIMA prijavljuje gresku ili povezivanje. *)
	IF (connInfoPV.connectionStatus = IMA_ERROR)
		OR (connInfoPV.connectionStatus = IMA_CONNECTING) THEN
		connInfoPV.commandClearError := 1;
	ELSE
		connInfoPV.commandClearError := 0;
	END_IF
	
END_PROGRAM
