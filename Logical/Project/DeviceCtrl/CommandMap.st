ACTION CommandMap:
	(* ======================================================================== *)
	(* 1) Adapter RETAIN ulaznih ventila                                        *)
	(* ======================================================================== *)
	(* RETAIN vektor je uvek vlasnik komandi V01/V02, nezavisno od procesnog rezima. *)
	PG.Act.AV._1.Open := PGRad.CmdRetain.V01_Open;
	PG.Act.AV._2.Open := PGRad.CmdRetain.V02_Open;

	(* ======================================================================== *)
	(* 2) Adapter neretentivnog upravljackog vektora                            *)
	(* ======================================================================== *)
	(* Ostale komande se prepisuju samo kada je PGRad_Cmd.Aktivan; u suprotnom servisni/lokalni rezim zadrzava ownership. *)
	IF PGRad_Cmd.Aktivan THEN
		PG.Act.AV._3.Open := PGRad_Cmd.Ventili._03_Open;
		PG.Act.AV._4.Open := PGRad_Cmd.Ventili._04_Open;
		PG.Act.AV._5.Open := PGRad_Cmd.Ventili._05_Open;
		PG.Act.AV._6.Open := PGRad_Cmd.Ventili._06_Open;
		PG.Act.AV._7.Open := PGRad_Cmd.Ventili._07_Open;

		PG.Act.PV._1.PV_Input.Enable := PGRad_Cmd.PropVentili.PV01.Enable;
		PG.Act.PV._1.PV_Input.EnableManual := FALSE;
		PG.Act.PV._1.PV_Input.SP_Percent := PGRad_Cmd.PropVentili.PV01.SP_Percent;
		PG.Act.PV._2.PV_Input.Enable := PGRad_Cmd.PropVentili.PV02.Enable;
		PG.Act.PV._2.PV_Input.EnableManual := FALSE;
		PG.Act.PV._2.PV_Input.SP_Percent := PGRad_Cmd.PropVentili.PV02.SP_Percent;
		PG.Act.PV._5.PV_Input.Enable := PGRad_Cmd.PropVentili.PV05.Enable;
		PG.Act.PV._5.PV_Input.EnableManual := FALSE;
		PG.Act.PV._5.PV_Input.SP_Percent := PGRad_Cmd.PropVentili.PV05.SP_Percent;
	END_IF;
END_ACTION
