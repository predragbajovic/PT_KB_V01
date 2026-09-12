
PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* PID_Pu_01_CYCLIC                                                          *)
	(* Zatvorena petlja nivoa: ActValue uzima nivo prihvatnog suda,              *)
	(* a izlaz PID-a se, kada je dozvoljeno startPIDPu1, mapira na Pu._1 freq.   *)
	(* ======================================================================== *)

	(* -------------------------------------------------------------------------- *)
	(* 1) Rad po komandi state masine: PID je jedini vlasnik frekvencije i Run-a. *)
	(* -------------------------------------------------------------------------- *)
	IF PGRad_Cmd.Aktivan THEN
		Start_Pu_01 := FALSE;
		startPIDPu1 := PGRad_Cmd.PID.Enable;

		(* 1.1) Prenos procesnog zahteva u PID regulator. *)
		PID_Pu_01.Enable := PGRad_Cmd.PID.Enable;
		PID_Pu_01.ActValue := PGRad_Cmd.PID.ActValue;
		PID_Pu_01.SetValue := PGRad_Cmd.PID.SetValue;
		PID_Pu_01.Invert := PGRad_Cmd.PID.Invert;
		PID_Pu_01.MaxOut := PGRad_Cmd.PID.MaxOut;
		PID_Pu_01.EnableTracking := PGRad_Cmd.PID.EnableTracking;
		PID_Pu_01.TrackingValue := PGRad_Cmd.PID.TrackingValue;
		IF EDGEPOS(PGRad_Cmd.PID.Enable) THEN
			PID_Pu_01.Update := TRUE;
		END_IF
		PID_Pu_01();
		IF PID_Pu_01.UpdateDone THEN
			PID_Pu_01.Update := FALSE;
		END_IF

		(* 1.2) Iskljucivo izabrana izlazna pumpa dobija PID frekvenciju i Run. *)
		PG.Act.Pu._1.cmds.Run_fwd := FALSE;
		PG.Act.Pu._2.cmds.Run_fwd := FALSE;
		IF PGRad_Cmd.PID.Enable THEN
			IF PGRad_Cmd.Pumpe._01.Run THEN
				PG.Act.Pu._1.params.Freq := PID_Pu_01.Out;
				PG.Act.Pu._1.cmds.Run_fwd := TRUE;
			ELSIF PGRad_Cmd.Pumpe._02.Run THEN
				PG.Act.Pu._2.params.Freq := PID_Pu_01.Out;
				PG.Act.Pu._2.cmds.Run_fwd := TRUE;
			END_IF
		END_IF

	ELSE
		(* -------------------------------------------------------------------------- *)
		(* 2) Nasledjeni rucni/auto rad pumpe 1                                    *)
		(* -------------------------------------------------------------------------- *)
		(* 2.1) Ciklicni PID poziv sa nivoom prihvatnog suda kao merenom vrednoscu. *)
		PID_Pu_01.EnableTracking := FALSE;
		PID_Pu_01.ActValue := NivoPRihvatniSud;
		PID_Pu_01();

		IF startPIDPu1 THEN
			PG.Act.Pu._1.params.Freq := PID_Pu_01.Out;
		END_IF

		(* 2.2) Automatski start/stop iz nivoa i rucne komande. *)
		IF Pu_01_Auto THEN
			IF NivoPRihvatniSud > PID_Pu_01.SetValue THEN
				Start_Pu_01 := TRUE;
				startPIDPu1 := TRUE;
				PG.Act.AV._3.Open := TRUE;
			ELSIF (NivoPRihvatniSud < (PID_Pu_01.SetValue - 0.6))
				OR (NivoPRihvatniSud < 0.75) THEN
				Start_Pu_01 := FALSE;
				startPIDPu1 := FALSE;
				PG.Act.AV._3.Open := FALSE;
			END_IF
		END_IF

		IF EDGENEG(Pu_01_Auto) THEN
			Start_Pu_01 := FALSE;
		END_IF

		IF EDGEPOS(Start_Pu_01) THEN
			PID_Pu_01.Update := TRUE;
		END_IF

		(* 2.3) Primena Run komande i reset PID dozvole na ivicama zahteva. *)
		IF Start_Pu_01 THEN
			PID_Pu_01.Enable := TRUE;
			PG.Act.Pu._1.cmds.Run_fwd := TRUE;

			IF PID_Pu_01.UpdateDone THEN
				PID_Pu_01.Update := FALSE;
			END_IF
		END_IF

		IF EDGENEG(Start_Pu_01) THEN
			PID_Pu_01.Enable := FALSE;
			PG.Act.Pu._1.cmds.Run_fwd := FALSE;
		END_IF

		(* -------------------------------------------------------------------------- *)
		(* 3) Zadrzavanje otvorenog izlaznog ventila                                *)
		(* -------------------------------------------------------------------------- *)
		(* PG_V05 prati otvoren ulazni ventil PG_V01 u nasledjenom lokalnom rezimu. *)
		IF PG.Act.AV._1.Open THEN
			PG.Act.AV._5.Open := TRUE;
		END_IF
	END_IF
END_PROGRAM

