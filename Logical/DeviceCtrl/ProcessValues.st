ACTION ProcessValues:
	(* ======================================================================== *)
	(* 1) Izvedene procesne velicine                                            *)
	(* ======================================================================== *)
	NivoPRihvatniSud := (PG.Sens.Pt._NS1.AI_Output.ScaledValue - PG.Sens.Pt._NS2.AI_Output.ScaledValue) / 0.09804;
	Predata_Snaga := 4.181 * (PG.Sens.MP._1.AI_Output.ScaledValue * (PG.Sens.Tt._1.AI_Output.ScaledValue - PG.Sens.Tt._2.AI_Output.ScaledValue));
	DP_strainer := PG.Sens.Pt._1.AI_Output.ScaledValue - PG.Sens.Pt._2.AI_Output.ScaledValue + 0.123;
	DP_Izmejnivac := PG.Sens.Pt._2.AI_Output.ScaledValue - PG.Sens.Pt._3.AI_Output.ScaledValue + 0.0015;
END_ACTION
