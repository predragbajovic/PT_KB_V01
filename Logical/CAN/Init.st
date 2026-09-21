PROGRAM _INIT
	(* -------------------------------------------------------------------------- *)
	(* 1) Config2 CANopen parametri izlaznih pumpi                                *)
	(* -------------------------------------------------------------------------- *)
	PG.Act.Pu._1.Enable := TRUE;
	PG.Act.Pu._1.FR_min := 10.0; (* Minimalna dozvoljena frekvencija PG_Pu01 [Hz]. *)
	PG.Act.Pu._1.FR_max := 50.0; (* Maksimalna dozvoljena frekvencija PG_Pu01 [Hz]. *)
	PG.Act.Pu._1.Motor_Nominalna_Snaga := 7.5; (* Nazivna snaga motora PG_Pu01 [kW]. *)

	PG.Act.Pu._2.Enable := TRUE;
	PG.Act.Pu._2.FR_min := 10.0; (* Minimalna dozvoljena frekvencija PG_Pu02 [Hz]. *)
	PG.Act.Pu._2.FR_max := 50.0; (* Maksimalna dozvoljena frekvencija PG_Pu02 [Hz]. *)
	PG.Act.Pu._2.Motor_Nominalna_Snaga := 7.5; (* Nazivna snaga motora PG_Pu02 [kW]. *)
END_PROGRAM