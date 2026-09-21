
PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* PID_Pu_PT_CYCLIC                                                           *)
	(* PID petlja pumpi na izlazu iz prihvatnog tanka.                            *)
	(* ======================================================================== *)

	(* -------------------------------------------------------------------------- *)
	(* 1) Rad po komandi state masine: PID je jedini vlasnik frekvencije i Run-a. *)
	(* -------------------------------------------------------------------------- *)
	(* Donja granica PID izlaza centralno se preuzima iz parametara pumpi. *)
	PID_Pu_PT.MinOut := PGRad.Par.MinFR_Pumpe;

	IF PGRad_Cmd.Aktivan THEN
		(* 1.1) Prenos procesnog zahteva u PID regulator. *)
		PID_Pu_PT.Enable := PGRad_Cmd.PID.Enable;
		PID_Pu_PT.ActValue := PGRad_Cmd.PID.ActValue;
		PID_Pu_PT.SetValue := PGRad_Cmd.PID.SetValue;
		PID_Pu_PT.Invert := PGRad_Cmd.PID.Invert;
		PID_Pu_PT.MaxOut := PGRad_Cmd.PID.MaxOut; (* Preuzima PGRad.Par.MaxFR_Pumpe. *)
		PID_Pu_PT.EnableTracking := PGRad_Cmd.PID.EnableTracking;
		PID_Pu_PT.TrackingValue := PGRad_Cmd.PID.TrackingValue;
		IF EDGEPOS(PGRad_Cmd.PID.Enable) THEN
			PID_Pu_PT.Update := TRUE;
		END_IF
		PID_Pu_PT();
		IF PID_Pu_PT.UpdateDone THEN
			PID_Pu_PT.Update := FALSE;
		END_IF

		(* 1.2) Iskljucivo izabrana izlazna pumpa dobija PID frekvenciju i Run. *)
		PG.Act.Pu._1.Start := FALSE;
		PG.Act.Pu._2.Start := FALSE;
		IF PGRad_Cmd.PID.Enable THEN
			IF PGRad_Cmd.Pumpe._01.Run THEN
				PG.Act.Pu._1.FR_set := PID_Pu_PT.Out;
				PG.Act.Pu._1.Start := TRUE;
			ELSIF PGRad_Cmd.Pumpe._02.Run THEN
				PG.Act.Pu._2.FR_set := PID_Pu_PT.Out;
				PG.Act.Pu._2.Start := TRUE;
			END_IF
		END_IF

	ELSE
		(* -------------------------------------------------------------------------- *)
		(* 2) Rucni rad pumpi                                                       *)
		(* -------------------------------------------------------------------------- *)
		(* U rucnom rezimu HMI neposredno zadaje Start i FR_set izabrane pumpe. *)
		PID_Pu_PT.Enable := FALSE;
		PID_Pu_PT.EnableTracking := FALSE;
		PID_Pu_PT();

		(* -------------------------------------------------------------------------- *)
		(* 3) Zadrzavanje postojeceg nasledjenog bypass zahteva                     *)
		(* -------------------------------------------------------------------------- *)
		(* PG_V05 prati otvoren ulazni ventil PG_V01 u nasledjenom lokalnom rezimu. *)
		IF PG.Act.AV._1.Open THEN
			PG.Act.AV._5.Open := TRUE;
		END_IF
	END_IF
END_PROGRAM

