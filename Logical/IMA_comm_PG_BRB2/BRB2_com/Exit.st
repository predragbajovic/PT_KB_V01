PROGRAM _EXIT
	(* ======================================================================== *)
	(* 1) Zatvaranje otvorene AsIMA master sesije                                *)
	(* ======================================================================== *)
	(* Sesija se zatvara samo kada je INIT uspesno dodelio vazeci stationId. *)
	IF stationId <> 0 THEN
		statusClose := IMAclose(stationId);
	END_IF
END_PROGRAM
