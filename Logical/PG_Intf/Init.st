PROGRAM _INIT
	(* Inicijalizacija BRB2 watchdog-a; status je nevalidan do prve promene udaljenog brojača. *)
	PGRad_BRB2Watchdog.LastCounter := 0;
	PGRad_BRB2Watchdog.ReceivedOnce := FALSE;
	PGRad_BRB2Watchdog.ReceiveTimeout(IN := FALSE, PT := T#5s);
	PGRad_BRB2Watchdog.Valid := FALSE;
END_PROGRAM