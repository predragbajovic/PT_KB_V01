ACTION ProcessValues:
	(* ======================================================================== *)
	(* 1) Izbor realnog protoka aktivnog izvora                                 *)
	(* ======================================================================== *)
	CASE PGRad.Ctrl.SelektovaniIzvor OF
		_01_BRB2:
			AktivniUlazniProtok := PG01_Remote.BRB2Sens.FtRB21.Value;

		_02_IEBKB1:
			AktivniUlazniProtok := IEB_KB1.Cntrl.Comm.Podstanica.Status.TrenutniProtok;

	ELSE
		AktivniUlazniProtok := 0.0;
	END_CASE

	(* ======================================================================== *)
	(* 2) Toplotne snage                                                        *)
	(* ======================================================================== *)
	Predata_Snaga := 4.181 * AktivniUlazniProtok
		* (PG.Sens.Tt._1.AI_Output.ScaledValue - PG.Sens.Tt._2.AI_Output.ScaledValue);
	Snaga_grejanja_hotela := 4.181 * AktivniUlazniProtok
		* (PG.Sens.Tt._1.AI_Output.ScaledValue - PG.Sens.Tt._4.AI_Output.ScaledValue);
	Snaga_sanitarnog_grejanja := Predata_Snaga - Snaga_grejanja_hotela;

	(* ======================================================================== *)
	(* 3) Ostale izvedene procesne velicine                                     *)
	(* ======================================================================== *)
	NivoPRihvatniSud := (PG.Sens.Pt._NS1.AI_Output.ScaledValue - PG.Sens.Pt._NS2.AI_Output.ScaledValue) / 0.09804;
	DP_strainer := PG.Sens.Pt._1.AI_Output.ScaledValue - PG.Sens.Pt._2.AI_Output.ScaledValue + 0.123;
	DP_Izmejnivac := PG.Sens.Pt._2.AI_Output.ScaledValue - PG.Sens.Pt._3.AI_Output.ScaledValue + 0.0015;
END_ACTION
