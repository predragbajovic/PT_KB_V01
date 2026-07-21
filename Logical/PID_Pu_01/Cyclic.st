
PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* PID_Pu_01_CYCLIC                                                          *)
	(* Zatvorena petlja nivoa: ActValue uzima nivo prihvatnog suda,              *)
	(* a izlaz PID-a se, kada je dozvoljeno startPIDPu1, mapira na Pu._1 freq.   *)
	(* ======================================================================== *)

	(* Aktualna procesna vrednost regulatora je izmereni nivo u prihvatnom sudu. *)
	PID_Pu_01.ActValue := NivoPRihvatniSud;

	(* Ako je dozvoljen PID rezim pumpe 1, primeni izlaz regulatora na frekvencu. *)
	IF startPIDPu1 THEN
		PG.Act.Pu._1.params.Freq := PID_Pu_01.Out;
	END_IF

	(* Obavezan poziv PID FB instance u svakom ciklusu taska. *)
	PID_Pu_01();
	
END_PROGRAM
