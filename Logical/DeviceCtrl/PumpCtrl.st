ACTION PumpCtrl:
	(* ======================================================================== *)
	(* 1) Rucna korekcija frekvencije pumpi                                     *)
	(* ======================================================================== *)
	IF NOT PGRad_Cmd.Aktivan THEN
		IF EDGEPOS(Pu1_1_plus) THEN
			PG.Act.Pu._1.params.Freq := PG.Act.Pu._1.params.Freq + 1.0;
		END_IF;
		IF EDGEPOS(Pu1_01_plus) THEN
			PG.Act.Pu._1.params.Freq := PG.Act.Pu._1.params.Freq + 0.1;
		END_IF;
		IF EDGEPOS(Pu1_1_minus) THEN
			PG.Act.Pu._1.params.Freq := PG.Act.Pu._1.params.Freq - 1.0;
		END_IF;
		IF EDGEPOS(Pu1_01_minus) THEN
			PG.Act.Pu._1.params.Freq := PG.Act.Pu._1.params.Freq - 0.1;
		END_IF;

		IF EDGEPOS(Pu2_1_plus) THEN
			PG.Act.Pu._2.params.Freq := PG.Act.Pu._2.params.Freq + 1.0;
		END_IF;
		IF EDGEPOS(Pu2_01_plus) THEN
			PG.Act.Pu._2.params.Freq := PG.Act.Pu._2.params.Freq + 0.1;
		END_IF;
		IF EDGEPOS(Pu2_1_minus) THEN
			PG.Act.Pu._2.params.Freq := PG.Act.Pu._2.params.Freq - 1.0;
		END_IF;
		IF EDGEPOS(Pu2_01_minus) THEN
			PG.Act.Pu._2.params.Freq := PG.Act.Pu._2.params.Freq - 0.1;
		END_IF;
	END_IF;

	(* ======================================================================== *)
	(* 2) Granice frekvencije pumpi                                             *)
	(* ======================================================================== *)
	IF PG.Act.Pu._1.params.Freq > 100.0 THEN
		PG.Act.Pu._1.params.Freq := 100.0;
	ELSIF PG.Act.Pu._1.params.Freq < 10.0 THEN
		PG.Act.Pu._1.params.Freq := 10.0;
	END_IF;
	IF PG.Act.Pu._2.params.Freq > 50.0 THEN
		PG.Act.Pu._2.params.Freq := 50.0;
	ELSIF PG.Act.Pu._2.params.Freq < 10.0 THEN
		PG.Act.Pu._2.params.Freq := 10.0;
	END_IF;
END_ACTION
