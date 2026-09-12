PROGRAM _INIT
	(* ======================================================================== *)
	(* 1) Otvaranje AsIMA master sesije prema BRB2                               *)
	(* ======================================================================== *)
	(* Ime DataObject-a identifikuje AsIMA server BRB2 i vraca stationId sesije. *)
	pDatObjName := ADR('BRB2');
	statusInit := IMAinit(pDatObjName, errorInfo, ADR(stationId));
END_PROGRAM
