

PROGRAM _INIT
	(* ======================================================================== *)
	(* 1) Inicijalizacija izvrsnog konteksta                                     *)
	(* ======================================================================== *)
	State := PG_00_Stand_By;
	Substep := 0;

	KomandaStart := FALSE;
	KomandaStop := FALSE;
	KomandaReset := FALSE;
	CmdSetDefaultParameters := FALSE;
	IF PGRad.Ctrl.SelektovaniIzvor = _02_IEBKB1 THEN
		SelectIEBKB1 := TRUE;
	ELSE
		SelectIEBKB1 := FALSE;
		PGRad.Ctrl.SelektovaniIzvor := _01_BRB2;
	END_IF;

	FaultLatched := FALSE;
	FaultCode := 0;
	FaultText := '';
	T_PG_V01_Close(IN := FALSE, PT := T#0s);
	T_PG_V02_Open(IN := FALSE, PT := T#0s);
	T_PrelazPV05Cuvar(IN := FALSE, PT := T#0s);
	SP_PV05 := 0.0;
	PV05IspiranjeOtvoreno := FALSE;
	IzlaznaPumpaUStopu := FALSE;

	(* ======================================================================== *)
	(* 2) Inicijalizacija PID parametara proporcionalnih ventila                *)
	(* ======================================================================== *)
	(* PV05 cuva pritisak dolaznog voda, a aktivni ulazni PV odrzava PT04. *)
	PID_PV05.MinOut := 0.0;
	PID_PV05.MaxOut := 100.0;
	PID_PV05.PIDParameters.DerivativeTime := 0.0;
	PID_PV05.PIDParameters.FilterTime := 45.0;
	PID_PV05.PIDParameters.Gain := 1.0;
	PID_PV05.PIDParameters.IntegrationTime := 180.0;
	PID_PV05.Invert := TRUE;
	PID_PV05.Update := TRUE;

	PID_PV_UlazTanka.MinOut := 0.0;
	PID_PV_UlazTanka.MaxOut := 100.0;
	PID_PV_UlazTanka.PIDParameters.DerivativeTime := 0.0;
	PID_PV_UlazTanka.PIDParameters.FilterTime := 45.0;
	PID_PV_UlazTanka.PIDParameters.Gain := 1.0;
	PID_PV_UlazTanka.PIDParameters.IntegrationTime := 180.0;
	PID_PV_UlazTanka.Invert := FALSE;
	PID_PV_UlazTanka.Update := TRUE;

	(* ======================================================================== *)
	(* 3) Obnova RETAIN komandi bistabilnih ulaznih ventila                      *)
	(* ======================================================================== *)
	(* RETAIN polozaji se neposredno prenose na bistabilne ulazne ventile. *)
	PG.Act.AV._1.Open := PGRad.CmdRetain.V01_Open; (* PG_V01: dolaz sa IEBKB1. *)
	PG.Act.AV._2.Open := PGRad.CmdRetain.V02_Open; (* PG_V02: dolaz sa BRB2. *)

	(* ======================================================================== *)
	(* 4) Bezbedan reset neretentivnog upravljackog vektora                      *)
	(* ======================================================================== *)
	PGRad_Cmd.Aktivan := FALSE;
	PGRad_Cmd.Ventili._03_Open := FALSE;
	PGRad_Cmd.Ventili._04_Open := FALSE;
	PGRad_Cmd.Ventili._05_Open := FALSE;
	PGRad_Cmd.Ventili._06_Open := FALSE;
	PGRad_Cmd.Ventili._07_Open := FALSE;

	PGRad_Cmd.PropVentili.PV01.Enable := FALSE;
	PGRad_Cmd.PropVentili.PV02.Enable := FALSE;
	PGRad_Cmd.PropVentili.PV05.Enable := FALSE;
	PGRad_Cmd.AirRelease.PV03.Enable := FALSE;
	PGRad_Cmd.AirRelease.PV04.Enable := FALSE;
	PGRad_Cmd.AirRelease.UseIEBKB1Parameters := FALSE;
	PGRad_Cmd.AirRelease.ResetAll := FALSE;

	PGRad_Cmd.Pumpe._01.Run := FALSE;
	PGRad_Cmd.Pumpe._02.Run := FALSE;
	PGRad_Cmd.PID.Enable := FALSE;
	PGRad_Cmd.PID.ActValue := 0.0;
	PGRad_Cmd.PID.SetValue := 0.0;
	PGRad_Cmd.PID.Invert := FALSE;
	PGRad_Cmd.PID.MaxOut := 0.0;
	PGRad_Cmd.PID.EnableTracking := FALSE;
	PGRad_Cmd.PID.TrackingValue := 0.0;
	PGRad_BRB2Cmd.ZahtevZaustavljanja := FALSE;
	PGRad_BRB2Cmd.VentiliPodstaniceZatvoreni := FALSE;

	(* ======================================================================== *)
	(* 5) Cold-boot provera RETAIN parametara                                   *)
	(* ======================================================================== *)
	(* RETAIN parametri se inicijalizuju i na cold boot-u. *)
	IF (PGRad.Par.SetPritisakPotisa <= 0.0)
		OR (PGRad.Par.MaxFR_Pumpe <= 0.0)
		OR (PGRad.Par.SetPointPritisakPV05Ispiranje <= 0.0)
		OR (PGRad.Par.SetPointPritisakUlazTanka <= 0.0)
		OR (PGRad.Par.TimeSP.PrelazPV05Cuvar_s <= 0.0)
		OR (PGRad.Par.PocetnaFrekvencaIzlaznePumpe <= 0.0)
		OR (PGRad.Par.MaxOtvorPropZaZatvaranje <= 0.0)
		OR (PGRad.Par.TimeSP.OverlapPumpi_s <= 0.0)
		OR (PGRad.Par.TimeSP.AutoRestartDelay_s <= 0.0)
		OR (PGRad.Par.TimeSP.ValvePositionTimeout_s <= 0.0)
		OR (PGRad.Par.TimeSP.InterlockDebounce_s <= 0.0)
		OR (PGRad.Par.AirRelease.BRB2.PV03.NumberOfLS = 0)
		OR (PGRad.Par.AirRelease.BRB2.PV04.NumberOfLS = 0)
		OR (PGRad.Par.AirRelease.IEBKB1.PV03.NumberOfLS = 0)
		OR (PGRad.Par.AirRelease.IEBKB1.PV04.NumberOfLS = 0) THEN
		CmdSetDefaultParameters := TRUE;
	END_IF

END_PROGRAM