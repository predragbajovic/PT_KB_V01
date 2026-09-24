ACTION ValveCtrl:
	(* ======================================================================== *)
	(* VALVECTRL - PROPORCIONALNI VENTILI I IZLAZNI LIMITI                    *)
	(* AUTO: ProcessUnit/FB_AirRelease daje automatski SP.                    *)
	(* MANUAL: FB manual ulaz se postuje samo kada je lokalni EnableManual TRUE. *)
	(* COMMON: svaki procenat se ogranicava na fizicki opseg 0..100 %.         *)
	(* STOP/FAULT: bez dozvole pripadajuci FB primenjuje svoj bezbedni izlaz.  *)
	(* ======================================================================== *)
	(* ======================================================================== *)
	(* 1) ProcessUnit izlazi odzracnih ventila                                  *)
	(* ======================================================================== *)
	(* ProcessUnit poseduje SP za PV03/PV04; manualni FB ulaz je prisilno iskljucen. *)
	PG.Act.PV._3.PV_Input.EnableManual := FALSE;
	PG.Act.PV._3.PV_Input.SP_Percent := PGRad_AirRelease.PV03.FB.AR_Output.ValveSP_Percent;
	PG.Act.PV._4.PV_Input.EnableManual := FALSE;
	PG.Act.PV._4.PV_Input.SP_Percent := PGRad_AirRelease.PV04.FB.AR_Output.ValveSP_Percent;

	(* ======================================================================== *)
	(* 2) Granice proporcionalnih ventila procesa                               *)
	(* ======================================================================== *)
	(* Clamp 0..100% primenjuje se i na manualnu vrednost i na automatski SP. *)
	IF PG.Act.PV._1.PV_Input.ManualValue_Percent > 100.0 THEN
		PG.Act.PV._1.PV_Input.ManualValue_Percent := 100.0;
	ELSIF PG.Act.PV._1.PV_Input.ManualValue_Percent < 0.0 THEN
		PG.Act.PV._1.PV_Input.ManualValue_Percent := 0.0;
	END_IF;
	IF PG.Act.PV._1.PV_Input.SP_Percent > 100.0 THEN
		PG.Act.PV._1.PV_Input.SP_Percent := 100.0;
	ELSIF PG.Act.PV._1.PV_Input.SP_Percent < 0.0 THEN
		PG.Act.PV._1.PV_Input.SP_Percent := 0.0;
	END_IF;

	IF PG.Act.PV._2.PV_Input.ManualValue_Percent > 100.0 THEN
		PG.Act.PV._2.PV_Input.ManualValue_Percent := 100.0;
	ELSIF PG.Act.PV._2.PV_Input.ManualValue_Percent < 0.0 THEN
		PG.Act.PV._2.PV_Input.ManualValue_Percent := 0.0;
	END_IF;
	IF PG.Act.PV._2.PV_Input.SP_Percent > 100.0 THEN
		PG.Act.PV._2.PV_Input.SP_Percent := 100.0;
	ELSIF PG.Act.PV._2.PV_Input.SP_Percent < 0.0 THEN
		PG.Act.PV._2.PV_Input.SP_Percent := 0.0;
	END_IF;

	IF PG.Act.PV._5.PV_Input.ManualValue_Percent > 100.0 THEN
		PG.Act.PV._5.PV_Input.ManualValue_Percent := 100.0;
	ELSIF PG.Act.PV._5.PV_Input.ManualValue_Percent < 0.0 THEN
		PG.Act.PV._5.PV_Input.ManualValue_Percent := 0.0;
	END_IF;
	IF PG.Act.PV._5.PV_Input.SP_Percent > 100.0 THEN
		PG.Act.PV._5.PV_Input.SP_Percent := 100.0;
	ELSIF PG.Act.PV._5.PV_Input.SP_Percent < 0.0 THEN
		PG.Act.PV._5.PV_Input.SP_Percent := 0.0;
	END_IF;
END_ACTION
