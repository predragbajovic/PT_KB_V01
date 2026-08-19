
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
	
	IF Pu_01_Auto THEN
		IF NivoPRihvatniSud > PID_Pu_01.SetValue THEN
			Start_Pu_01 := TRUE;
			startPIDPu1 := TRUE;
			PG.Act.AV._3.Open := TRUE;
		ELSIF ((NivoPRihvatniSud < (PID_Pu_01.SetValue - 0.6)) OR (NivoPRihvatniSud < 0.75)) THEN
			Start_Pu_01 := FALSE;
			startPIDPu1 := FALSE;
			PG.Act.AV._3.Open := FALSE;
		END_IF
	END_IF
	
	IF EDGENEG (Pu_01_Auto) THEN
		Start_Pu_01:= FALSE;
	END_IF
	
	IF EDGEPOS (Start_Pu_01) THEN
		PID_Pu_01.Update:= TRUE;
	END_IF
	
	IF Start_Pu_01 THEN
		
		PID_Pu_01.Enable:= TRUE;
		PG.Act.Pu._1.cmds.Run_fwd := TRUE;
		
		IF PID_Pu_01.UpdateDone THEN
			PID_Pu_01.Update:= FALSE;
		END_IF
		
	END_IF
	
	IF EDGENEG (Start_Pu_01) THEN
		PID_Pu_01.Enable:= FALSE;
		PG.Act.Pu._1.cmds.Run_fwd := FALSE;
	END_IF
	

	
END_PROGRAM

