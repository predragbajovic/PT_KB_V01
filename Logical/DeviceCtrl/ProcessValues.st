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
	(* 4.181 je specificni toplotni kapacitet vode; uz protok [l/s] i delta T [degC] rezultat je [kW]. *)
	Predata_Snaga := 4.181 * AktivniUlazniProtok
		* (PG.Sens.Tt._1.AI_Output.ScaledValue - PG.Sens.Tt._2.AI_Output.ScaledValue);
	Snaga_grejanja_hotela := 4.181 * AktivniUlazniProtok
		* (PG.Sens.Tt._1.AI_Output.ScaledValue - PG.Sens.Tt._4.AI_Output.ScaledValue);
	Snaga_sanitarnog_grejanja := Predata_Snaga - Snaga_grejanja_hotela;

	(* ======================================================================== *)
	(* 3) Ostale izvedene procesne velicine                                     *)
	(* ======================================================================== *)
	(* Faktor 0.09804 pretvara diferencijalni hidrostatski pritisak [bar] u nivo vode [m]. *)
	NivoPRihvatniSud := (PG.Sens.Pt._NS1.AI_Output.ScaledValue - PG.Sens.Pt._NS2.AI_Output.ScaledValue) / 0.09804;
	(* 0.123 je postojeca commissioning korekcija DP strainer-a; fizicko poreklo treba potvrditi. *)
	DP_strainer := PG.Sens.Pt._1.AI_Output.ScaledValue - PG.Sens.Pt._2.AI_Output.ScaledValue + 0.123;
	(* 0.0015 je postojeca commissioning korekcija DP izmenjivaca; fizicko poreklo treba potvrditi. *)
	DP_Izmejnivac := PG.Sens.Pt._2.AI_Output.ScaledValue - PG.Sens.Pt._3.AI_Output.ScaledValue + 0.0015;
END_ACTION
