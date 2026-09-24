

PROGRAM _INIT
	(* ======================================================================== *)
	(* 1) Inicijalizacija izvrsnog konteksta                                     *)
	(* ======================================================================== *)
	Rad_PG_KB.Sequence.State := PG_00_Stand_By;
	Rad_PG_KB.Sequence.Substep := 0;

	Rad_PG_KB.HMI.Cntrl.Start := FALSE;
	Rad_PG_KB.HMI.Cntrl.Stop := FALSE;
	Rad_PG_KB.HMI.Cntrl.Reset := FALSE;
	Rad_PG_KB.HMI.Cntrl.SetDefaultParameters := FALSE;
	Rad_PG_KB.HMI.Cntrl.PrepareBRB2 := FALSE;
	Rad_PG_KB.HMI.Cntrl.TransferToBRB2 := FALSE;
	Rad_PG_KB.HMI.Cntrl.Continue := FALSE;
	Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_00_IDLE;
	Rad_PG_KB.Sequence.BRB2.PreparationSubstep := 0;
	Rad_PG_KB.Sequence.BRB2.Ready := FALSE;
	Rad_PG_KB.Sequence.Transfer.Requested := FALSE;
	IF PGRad.Ctrl.BRB2Regulacija = BRB2_00_NEAKTIVNA THEN
		PGRad.Ctrl.BRB2Regulacija := BRB2_01_REG_PROTOK;
	END_IF;
	IF PGRad.Ctrl.SelektovaniIzvor = _02_IEBKB1 THEN
		Rad_PG_KB.HMI.Cntrl.SelectIEBKB1 := TRUE;
	ELSE
		Rad_PG_KB.HMI.Cntrl.SelectIEBKB1 := FALSE;
		PGRad.Ctrl.SelektovaniIzvor := _01_BRB2;
	END_IF;

	Rad_PG_KB.Diag.Fault.Latched := FALSE;
	Rad_PG_KB.Diag.Fault.Code := 0;
	Rad_PG_KB.Diag.Fault.Text := '';
	Rad_PG_KB.Timer.PG_V01.Close(IN := FALSE, PT := T#0s);
	Rad_PG_KB.Timer.PG_V02.Open(IN := FALSE, PT := T#0s);
	Rad_PG_KB.Timer.Transfer.PV05Guard(IN := FALSE, PT := T#0s);
	Rad_PG_KB.Timer.BRB2.PreparationFlow(IN := FALSE, PT := T#0s);
	Rad_PG_KB.Timer.BRB2.TemperatureAlarm(IN := FALSE, PT := T#0s);
	Rad_PG_KB.Timer.BRB2.TemperatureStop(IN := FALSE, PT := T#0s);
	Rad_PG_KB.Timer.BRB2.PressureAlarm(IN := FALSE, PT := T#0s);
	Rad_PG_KB.Timer.BRB2.PressureStop(IN := FALSE, PT := T#0s);
	Rad_PG_KB.Timer.Transfer.Flow(IN := FALSE, PT := T#0s);
	Rad_PG_KB.Control.PV05.FlushingSP := 0.0;
	Rad_PG_KB.Status.PV05.FlushingOpened := FALSE;
	Rad_PG_KB.Status.Pump.OutletStopped := FALSE;

	(* ======================================================================== *)
	(* 2) Inicijalizacija PID parametara proporcionalnih ventila                *)
	(* ======================================================================== *)
	(* PV05 cuva pritisak dolaznog voda, a aktivni ulazni PV odrzava PT04. *)
	(* FilterTime filtrira D clan i nema uticaja dok je DerivativeTime = 0.0. *)
	Rad_PG_KB.Control.PV05.PID.MinOut := 0.0;
	Rad_PG_KB.Control.PV05.PID.MaxOut := 100.0;
	Rad_PG_KB.Control.PV05.PID.PIDParameters.DerivativeTime := 0.0;
	Rad_PG_KB.Control.PV05.PID.PIDParameters.FilterTime := 10.0;
	Rad_PG_KB.Control.PV05.PID.PIDParameters.Gain := 1.0;
	Rad_PG_KB.Control.PV05.PID.PIDParameters.IntegrationTime := 180.0;
	Rad_PG_KB.Control.PV05.PID.Invert := TRUE;
	Rad_PG_KB.Control.PV05.PID.Update := TRUE;

	Rad_PG_KB.Control.PV_UlazTanka.PID.MinOut := 0.0;
	Rad_PG_KB.Control.PV_UlazTanka.PID.MaxOut := 100.0;
	Rad_PG_KB.Control.PV_UlazTanka.PID.PIDParameters.DerivativeTime := 0.0;
	Rad_PG_KB.Control.PV_UlazTanka.PID.PIDParameters.FilterTime := 10.0;
	Rad_PG_KB.Control.PV_UlazTanka.PID.PIDParameters.Gain := 1.0;
	Rad_PG_KB.Control.PV_UlazTanka.PID.PIDParameters.IntegrationTime := 180.0;
	Rad_PG_KB.Control.PV_UlazTanka.PID.Invert := FALSE;
	Rad_PG_KB.Control.PV_UlazTanka.PID.Update := TRUE;

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
		OR (PGRad.Par.BRB2Preparation.MinTemperature_degC <= 0.0)
		OR (PGRad.Par.BRB2Preparation.FlowTimeout_s <= 0.0)
		OR (PGRad.Par.Transfer.PV05StartPressure_bar <= 0.0)
		OR (PGRad.Par.Transfer.PV05FinalPressure_bar <= 0.0)
		OR (PGRad.Par.Transfer.TankInletPressure_bar <= 0.0)
		OR (PGRad.Par.Transfer.PressureRamp_s <= 0.0)
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
		Rad_PG_KB.HMI.Cntrl.SetDefaultParameters := TRUE;
	END_IF

END_PROGRAM