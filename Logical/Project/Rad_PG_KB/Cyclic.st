
PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* Rad_PG_KB_CYCLIC                                                          *)
	(* Rad_PG_KB.Sequence.State masina izbora i rada izvora termalne vode: BRB2 (1) ili IEBKB1 (2). *)
	(* Prelazak izmedju grana ide iskljucivo preko PG_00_Stand_By - direktan     *)
	(* prelazak 1->2 ili 2->1 nije moguc.                                       *)
	(* ======================================================================== *)

	(* -------------------------------------------------------------------------- *)
	(* 1) Vracanje projektnih podrazumevanih parametara                          *)
	(* -------------------------------------------------------------------------- *)
	IF Rad_PG_KB.HMI.Cntrl.SetDefaultParameters THEN
		(* 1.1) Izlazne pumpe iza prihvatnog tanka. *)
		(* Aktivni SP zavisi od izabrane regulacije pritiska ili nivoa. *)
		PGRad.Par.SetPritisakPotisa := 1.2;
		PGRad.Par.SetPointNivoTanka := 1.5;
		PGRad.Par.PocetnaFrekvencaIzlaznePumpe := 10.0;

		(* Centralne granice PID izlaza za obe pumpe iza prihvatnog tanka. *)
		PGRad.Par.MinFR_Pumpe := 10.0;
		PGRad.Par.MaxFR_Pumpe := 45.0;
		(* MinFR_Pumpe se u PID_Pu_PT propagira na PID_Pu_PT.MinOut. *)
		(* MaxFR_Pumpe se preko PGRad_Cmd.PID.MaxOut propagira na PID_Pu_PT.MaxOut. *)
		PGRad.Par.TimeSP.OverlapPumpi_s := 10.0;
		PGRad.Par.TimeSP.AutoRestartDelay_s := 60.0;

		(* 1.2) BRB2 priprema i ispiranje dovodne grane. *)
		PGRad.Par.MinProtok := 1.5; (* Rezervisano; trenutno nema izvrsnog potrosaca. *)
		PGRad.Par.MaxProtok := 16.2;
		PGRad.Par.SetPointMinTempIspiranja := 60.0;
		PGRad.Par.BRB2Preparation.MinTemperature_degC := 60.0;
		PGRad.Par.BRB2Preparation.MinFlow_lps := 3.0;
		PGRad.Par.BRB2Preparation.FlowTimeout_s := 30.0;
		PGRad.Par.BRB2Preparation.TemperatureAlarm_s := 5400.0;
		PGRad.Par.BRB2Preparation.TemperatureStopDelay_s := 900.0;
		PGRad.Par.BRB2Preparation.PressureAlarmDelay_s := 5.0;
		PGRad.Par.BRB2Preparation.PressureStopDelay_s := 8.0;

		(* 1.3) Lokalna hidraulika PV05 i ulaza u prihvatni tank. *)
		PGRad.Par.SetPointPritisakPV05Ispiranje := 5.5;
		PGRad.Par.SetPointPritisakUlazTanka := 5.5;
		PGRad.Par.SetPointMaxPritisakDolaznaCev := 6.5;
		PGRad.Par.TimeSP.PrelazPV05Cuvar_s := 15.0;
		PGRad.Par.MaxOtvorPropZaZatvaranje := 3;

		(* 1.4) Kontrolisani transfer sa IEBKB1 na BRB2. *)
		PGRad.Par.Transfer.PV05StartPressure_bar := 5.5;
		PGRad.Par.Transfer.PV05FinalPressure_bar := 6.5;
		PGRad.Par.Transfer.TankInletPressure_bar := 5.5;
		PGRad.Par.Transfer.PressureRamp_s := 15.0;
		PGRad.Par.Transfer.FlowTimeout_s := 30.0;
		PGRad.Par.Transfer.PV05ClosedPercent := 4.0;

		(* 1.5) Zajednicki nadzor ventila i procesnih interlock-a. *)
		PGRad.Par.TimeSP.ValvePositionTimeout_s := 30.0;
		PGRad.Par.TimeSP.InterlockDebounce_s := 2.0;

		(* 1.6) BRB2 odzracivanje: oba ventila, prag 1.5 bar sa 0.5 bar histerezom. *)
		PGRad.Par.AirRelease.BRB2.PV03.NumberOfLS := 2;
		PGRad.Par.AirRelease.BRB2.PV03.PressureSP_bar := 1.5;
		PGRad.Par.AirRelease.BRB2.PV03.PressureHysteresis_bar := 0.5;
		PGRad.Par.AirRelease.BRB2.PV03.LS1.SP_Percent := 20.0;
		PGRad.Par.AirRelease.BRB2.PV03.LS1.Ramp_PercentPerSecond := 2.0;
		PGRad.Par.AirRelease.BRB2.PV03.LS1.ConfirmTime_s := 1.0;
		PGRad.Par.AirRelease.BRB2.PV03.LS2.SP_Percent := 89.0;
		PGRad.Par.AirRelease.BRB2.PV03.LS2.Ramp_PercentPerSecond := 15.0;
		PGRad.Par.AirRelease.BRB2.PV03.LS2.ConfirmTime_s := 1.0;
		PGRad.Par.AirRelease.BRB2.PV04 := PGRad.Par.AirRelease.BRB2.PV03;

		(* 1.7) IEBKB1 odzracivanje: aktivan je PV03 sa nizim pragom pritiska. *)
		PGRad.Par.AirRelease.IEBKB1.PV03.NumberOfLS := 2;
		PGRad.Par.AirRelease.IEBKB1.PV03.PressureSP_bar := 0.15;
		PGRad.Par.AirRelease.IEBKB1.PV03.PressureHysteresis_bar := 0.05;
		PGRad.Par.AirRelease.IEBKB1.PV03.LS1.SP_Percent := 20.0;
		PGRad.Par.AirRelease.IEBKB1.PV03.LS1.Ramp_PercentPerSecond := 2.0;
		PGRad.Par.AirRelease.IEBKB1.PV03.LS1.ConfirmTime_s := 1.0;
		PGRad.Par.AirRelease.IEBKB1.PV03.LS2.SP_Percent := 89.0;
		PGRad.Par.AirRelease.IEBKB1.PV03.LS2.Ramp_PercentPerSecond := 15.0;
		PGRad.Par.AirRelease.IEBKB1.PV03.LS2.ConfirmTime_s := 1.0;
		PGRad.Par.AirRelease.IEBKB1.PV04 := PGRad.Par.AirRelease.IEBKB1.PV03;

		Rad_PG_KB.HMI.Cntrl.SetDefaultParameters := FALSE;
	END_IF

	(* -------------------------------------------------------------------------- *)
	(* 2) Podrazumevane neretentivne komande po scan-u                            *)
	(* -------------------------------------------------------------------------- *)
	PGRad_Cmd.Aktivan := FALSE;
	PGRad_Cmd.Ventili._03_Open := FALSE;
	PGRad_Cmd.Ventili._04_Open := FALSE;
	PGRad_Cmd.Ventili._05_Open := FALSE;
	PGRad_Cmd.Ventili._06_Open := FALSE;
	PGRad_Cmd.Ventili._07_Open := FALSE;

	PGRad_Cmd.PropVentili.PV01.Enable := FALSE;
	PGRad_Cmd.PropVentili.PV01.SP_Percent := 0.0;
	PGRad_Cmd.PropVentili.PV02.Enable := FALSE;
	PGRad_Cmd.PropVentili.PV02.SP_Percent := 0.0;
	PGRad_Cmd.PropVentili.PV05.Enable := FALSE;
	PGRad_Cmd.PropVentili.PV05.SP_Percent := 0.0;
	PGRad_Cmd.AirRelease.PV03.Enable := FALSE;
	PGRad_Cmd.AirRelease.PV04.Enable := FALSE;
	PGRad_Cmd.AirRelease.UseIEBKB1Parameters := FALSE;
	PGRad_Cmd.AirRelease.ResetAll := Rad_PG_KB.HMI.Cntrl.Reset;

	PGRad_Cmd.Pumpe._01.Run := FALSE;
	PGRad_Cmd.Pumpe._02.Run := FALSE;
	PGRad_Cmd.PID.Enable := FALSE;
	PGRad_Cmd.PID.ActValue := 0.0;
	PGRad_Cmd.PID.SetValue := 0.0;
	PGRad_Cmd.PID.Invert := FALSE;
	(* Jedinstvena maksimalna PID frekvencija ne zavisi od izabrane pumpe. *)
	PGRad_Cmd.PID.MaxOut := PGRad.Par.MaxFR_Pumpe;
	PGRad_Cmd.PID.EnableTracking := FALSE;
	(* Jedinstvena pocetna frekvencija koristi se pri ukljucenju PID tracking-a. *)
	PGRad_Cmd.PID.TrackingValue := PGRad.Par.PocetnaFrekvencaIzlaznePumpe;
	PGRad_BRB2Cmd.RadKaPodstanici := FALSE;
	PGRad_BRB2Cmd.ZahtevStarta := FALSE;
	PGRad_BRB2Cmd.ZahtevZaustavljanja := FALSE;
	PGRad_BRB2Cmd.ManualMode := Rad_PG_KB.HMI.Manual.Enable;
	PGRad_BRB2Cmd.ManualSequence := Rad_PG_KB.HMI.Manual.Sequence;
	PGRad_BRB2Cmd.ManualStart := Rad_PG_KB.HMI.Manual.Start;
	PGRad_BRB2Cmd.ManualStop := Rad_PG_KB.HMI.Manual.Stop;
	PGRad_BRB2Cmd.ManualNextStep := Rad_PG_KB.HMI.Manual.NextStep;
	PGRad_BRB2Cmd.ManualAbort := Rad_PG_KB.HMI.Manual.Abort;
	PGRad_BRB2Cmd.VentiliPodstaniceZatvoreni := FALSE;
	PGRad_BRB2Cmd.PritisakIEBKB1 := IEB_KB1.Sens.Pt.B_02._01_value;
	PGRad_BRB2Cmd.PodstanicaURezimuRada := FALSE;
	PGRad_BRB2Cmd.RegulationMode := 0;
	PGRad_BRB2Cmd.RegulationPV := 0.0;
	PGRad_BRB2Cmd.RegulationSP := 0.0;
	PGRad_BRB2Cmd.RegulationPVValid := FALSE;
	PGRad_BRB2Cmd.RegulationInvert := FALSE;
	PGRad_BRB2Cmd.NivoPrihvatniSud := NivoPrihvatniSud;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ZahtevVode := FALSE;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.NivoPrihvatnogTanka := NivoPrihvatniSud;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.CiljaniProtok := PGRad.Par.MaxProtok;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ModRada := 0;
	IEB_KB1.Cntrl.proba := FALSE;

	(* Izbor izvora sa HMI prihvata se samo u bezbednom Standby stanju. *)
	IF Rad_PG_KB.Sequence.State = PG_00_Stand_By THEN
		IF Rad_PG_KB.HMI.Cntrl.SelectIEBKB1 THEN
			PGRad.Ctrl.SelektovaniIzvor := _02_IEBKB1;
		ELSE
			PGRad.Ctrl.SelektovaniIzvor := _01_BRB2;
		END_IF;
	ELSE
		Rad_PG_KB.HMI.Cntrl.SelectIEBKB1 := PGRad.Ctrl.SelektovaniIzvor = _02_IEBKB1;
	END_IF;

	(* -------------------------------------------------------------------------- *)
	(* 3) Tajmeri pripreme BRB2 dovodne putanje                                  *)
	(* -------------------------------------------------------------------------- *)
	Rad_PG_KB.Timer.PG_V01.Close.IN := FALSE;
	Rad_PG_KB.Timer.PG_V01.Close.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	Rad_PG_KB.Timer.PG_V02.Open.IN := FALSE;
	Rad_PG_KB.Timer.PG_V02.Open.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	Rad_PG_KB.Timer.PG_V02.Close.IN := FALSE;
	Rad_PG_KB.Timer.PG_V02.Close.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	Rad_PG_KB.Timer.PG_V01.Open.IN := FALSE;
	Rad_PG_KB.Timer.PG_V01.Open.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	Rad_PG_KB.Timer.IEBKB1.StartProtokTimeout.IN := FALSE;
	Rad_PG_KB.Timer.IEBKB1.StartProtokTimeout.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	Rad_PG_KB.Timer.IEBKB1.ProtokNula.IN := FALSE;
	Rad_PG_KB.Timer.IEBKB1.ProtokNula.PT := REAL_TO_TIME(PGRad.Par.TimeSP.InterlockDebounce_s * 1000.0);
	Rad_PG_KB.Timer.IEBKB1.StopProtokTimeout.IN := FALSE;
	Rad_PG_KB.Timer.IEBKB1.StopProtokTimeout.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	Rad_PG_KB.Timer.PG_V05.Close.IN := FALSE;
	Rad_PG_KB.Timer.PG_V05.Close.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	Rad_PG_KB.Timer.Transfer.PV05Guard.IN := FALSE;
	Rad_PG_KB.Timer.Transfer.PV05Guard.PT := REAL_TO_TIME(PGRad.Par.TimeSP.PrelazPV05Cuvar_s * 1000.0);
	Rad_PG_KB.Timer.BRB2.PreparationFlow.IN := FALSE;
	Rad_PG_KB.Timer.BRB2.PreparationFlow.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.FlowTimeout_s * 1000.0);
	Rad_PG_KB.Timer.BRB2.TemperatureAlarm.IN := FALSE;
	Rad_PG_KB.Timer.BRB2.TemperatureAlarm.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.TemperatureAlarm_s * 1000.0);
	Rad_PG_KB.Timer.BRB2.TemperatureStop.IN := FALSE;
	Rad_PG_KB.Timer.BRB2.TemperatureStop.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.TemperatureStopDelay_s * 1000.0);
	Rad_PG_KB.Timer.BRB2.PressureAlarm.IN := FALSE;
	Rad_PG_KB.Timer.BRB2.PressureAlarm.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.PressureAlarmDelay_s * 1000.0);
	Rad_PG_KB.Timer.BRB2.PressureStop.IN := FALSE;
	Rad_PG_KB.Timer.BRB2.PressureStop.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.PressureStopDelay_s * 1000.0);
	Rad_PG_KB.Timer.Transfer.Flow.IN := FALSE;
	Rad_PG_KB.Timer.Transfer.Flow.PT := REAL_TO_TIME(PGRad.Par.Transfer.FlowTimeout_s * 1000.0);

	(* -------------------------------------------------------------------------- *)
	(* 4) Glavna state masina izvora termalne vode                                *)
	(* -------------------------------------------------------------------------- *)
	(* Rad_PG_KB.HMI.Manual.Start grane imaju prioritet evaluacije. BRB2 auto-start je blokiran  *)
	(* sa Rad_PG_KB.HMI.Manual.Enable, dok IEBKB1 auto-start grana nema eksplicitnu tu proveru.    *)
	CASE Rad_PG_KB.Sequence.State OF

		PG_00_Stand_By:
			(* Neretentivni vektor je bezbedno resetovan u sekciji 2; V01/V02 se ne menjaju. *)
			Rad_PG_KB.Status.PV05.FlushingOpened := FALSE;
			(* Start je dozvoljen samo sa izabranim izvorom i regulacionom varijantom. *)
			IF Rad_PG_KB.HMI.Manual.Enable AND Rad_PG_KB.HMI.Manual.Start AND (Rad_PG_KB.HMI.Manual.Sequence = 1) THEN
				PGRad.Ctrl.SelektovaniIzvor := _01_BRB2;
				Rad_PG_KB.HMI.Manual.Start := FALSE;
				Rad_PG_KB.Sequence.State := PG_01_Priprema_BRB2;
				Rad_PG_KB.Sequence.Substep := 0;
			ELSIF Rad_PG_KB.HMI.Manual.Enable AND Rad_PG_KB.HMI.Manual.Start AND (Rad_PG_KB.HMI.Manual.Sequence = 2) THEN
				PGRad.Ctrl.SelektovaniIzvor := _02_IEBKB1;
				Rad_PG_KB.HMI.Manual.Start := FALSE;
				Rad_PG_KB.Sequence.State := PG_11_Priprema_IEBKB1;
				Rad_PG_KB.Sequence.Substep := 0;
			ELSIF Rad_PG_KB.HMI.Cntrl.Start
				AND (NOT Rad_PG_KB.HMI.Manual.Enable)
				AND (NOT Rad_PG_KB.Diag.Fault.Latched)
				AND (PGRad.Ctrl.RegulacionaVarijanta <> _00_neaktivan)
				AND (PGRad.Ctrl.SelektovaniIzvor = _01_BRB2) THEN
				Rad_PG_KB.Sequence.State := PG_01_Priprema_BRB2;
				Rad_PG_KB.Sequence.Substep := 0;
			ELSIF Rad_PG_KB.HMI.Cntrl.Start
				AND (NOT Rad_PG_KB.Diag.Fault.Latched)
				AND (PGRad.Ctrl.RegulacionaVarijanta <> _00_neaktivan)
				AND (PGRad.Ctrl.SelektovaniIzvor = _02_IEBKB1) THEN
				Rad_PG_KB.Sequence.State := PG_11_Priprema_IEBKB1;
				Rad_PG_KB.Sequence.Substep := 0;
			END_IF

		PG_01_Priprema_BRB2:
			IF Rad_PG_KB.HMI.Manual.Stop OR Rad_PG_KB.HMI.Manual.Abort THEN
				Rad_PG_KB.HMI.Cntrl.Stop := TRUE;
				Rad_PG_KB.HMI.Manual.Stop := FALSE;
				Rad_PG_KB.HMI.Manual.Abort := FALSE;
			END_IF;
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			CASE Rad_PG_KB.Sequence.Substep OF
				0:
					(* Prioritet BRB2: najpre zatvori dovod sa IEBKB1. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					Rad_PG_KB.Sequence.Substep := 1;

				1:
					(* Otvaranje BRB2 dovoda je dozvoljeno tek po potvrdi zatvorenog V01. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					Rad_PG_KB.Timer.PG_V01.Close.IN := NOT PG.Act.AV._1.Closed;
					IF PG.Act.AV._1.Closed AND (NOT Rad_PG_KB.HMI.Manual.Enable OR Rad_PG_KB.HMI.Manual.NextStep) THEN
						Rad_PG_KB.HMI.Manual.NextStep := FALSE;
						PGRad.CmdRetain.V02_Open := TRUE;
						Rad_PG_KB.Sequence.Substep := 2;
					ELSIF Rad_PG_KB.Timer.PG_V01.Close.Q THEN
						PGRad.CmdRetain.V01_Open := FALSE;
						PGRad.CmdRetain.V02_Open := FALSE;
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 11;
						Rad_PG_KB.Diag.Fault.Text := 'PG_V01 nije zatvoren za zadato vreme';
						Rad_PG_KB.Sequence.State := PG_00_Stand_By;
						Rad_PG_KB.Sequence.Substep := 0;
					END_IF

				2:
					(* Ceka se fizicka potvrda otvorenog BRB2 dovoda. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					PGRad.CmdRetain.V02_Open := TRUE;
					Rad_PG_KB.Timer.PG_V02.Open.IN := NOT PG.Act.AV._2.Opened;
					IF PG.Act.AV._2.Opened AND (NOT Rad_PG_KB.HMI.Manual.Enable OR Rad_PG_KB.HMI.Manual.NextStep) THEN
						Rad_PG_KB.HMI.Manual.NextStep := FALSE;
						Rad_PG_KB.Sequence.Substep := 3;
					ELSIF Rad_PG_KB.Timer.PG_V02.Open.Q THEN
						PGRad.CmdRetain.V01_Open := FALSE;
						PGRad.CmdRetain.V02_Open := FALSE;
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 12;
						Rad_PG_KB.Diag.Fault.Text := 'PG_V02 nije otvoren za zadato vreme';
						Rad_PG_KB.Sequence.State := PG_00_Stand_By;
						Rad_PG_KB.Sequence.Substep := 0;
					END_IF

				3:
					(* PG_PV05 se otvara nakon dostignutog PT06 pritiska; temperatura se proverava tek posle BRB2 minimuma. *)
					IF PG.Sens.Pt._6.AI_Output.ScaledValue >= PGRad.Par.SetPointPritisakPV05Ispiranje THEN
						Rad_PG_KB.Status.PV05.FlushingOpened := TRUE;
					END_IF;
					IF Rad_PG_KB.Status.PV05.FlushingOpened THEN
						PGRad_Cmd.Aktivan := TRUE;
						PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					END_IF;
					IF PGRad_BRB2.IspiranjeMinTrajanjeDostignuto
						AND (PG.Sens.Tt._7.AI_Output.ScaledValue >= PGRad.Par.SetPointMinTempIspiranja) THEN
						IF Rad_PG_KB.HMI.Manual.Enable AND NOT Rad_PG_KB.HMI.Manual.NextStep THEN
							(* Manual mode holds the completed rinse step until operator confirmation. *)
						ELSE
							Rad_PG_KB.HMI.Manual.NextStep := FALSE;
							IF Rad_PG_KB.HMI.Manual.Enable AND (Rad_PG_KB.HMI.Manual.Sequence = 1) THEN
								(* Manual flush ends here; controlled stop closes the BRB2 path. *)
								Rad_PG_KB.HMI.Cntrl.Stop := TRUE;
								Rad_PG_KB.Sequence.State := PG_03_Zaustavljanje_BRB2;
								Rad_PG_KB.Sequence.Substep := 0;
							ELSE
								Rad_PG_KB.Sequence.Substep := 4;
							END_IF
						END_IF
					END_IF

				4:
					(* Priprema puta ka tanku: otvara se samo ON/OFF ventil izabranog ulaznog PV-a. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
						_01_PG_PV01, _02_PG_PV02:
							Rad_PG_KB.Sequence.Substep := 5;
					END_CASE

				5:
					(* Mek prelaz: ulazni PV vodi PT04, a PT06 SP PG_PV05 raste 5.5 -> 6.5 bar. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					Rad_PG_KB.Timer.Transfer.PV05Guard.IN := TRUE;
					IF Rad_PG_KB.Timer.Transfer.PV05Guard.Q AND (NOT Rad_PG_KB.HMI.Manual.Enable OR Rad_PG_KB.HMI.Manual.NextStep) THEN
						Rad_PG_KB.HMI.Manual.NextStep := FALSE;
						Rad_PG_KB.Sequence.Substep := 6;
					END_IF

				6:
					(* Punjenje tanka: PV05 je cuvar PT06, a aktivni ulazni PV odrzava PT04. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					IF (NivoPrihvatniSud >= PGRad.Par.SetPointNivoTanka)
						AND (NOT Rad_PG_KB.HMI.Manual.Enable OR Rad_PG_KB.HMI.Manual.NextStep) THEN
						Rad_PG_KB.HMI.Manual.NextStep := FALSE;
						Rad_PG_KB.Sequence.State := PG_02_Rad_BRB2;
						Rad_PG_KB.Sequence.Substep := 0;
					END_IF

			ELSE
				Rad_PG_KB.Sequence.Substep := 0;
			END_CASE

		PG_02_Rad_BRB2:
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			(* Podstanica bira aktivni BRB2 PV/SP; BRB2 lokalno menja samo FR_set. *)
			CASE PGRad.Ctrl.BRB2Regulacija OF
				BRB2_01_REG_PROTOK:
					PGRad_BRB2Cmd.RegulationMode := 1;
					PGRad_BRB2Cmd.RegulationPV := PG.Sens.MP._1.AI_Output.ScaledValue;
					PGRad_BRB2Cmd.RegulationSP := PGRad.Par.MaxProtok;
					PGRad_BRB2Cmd.RegulationPVValid := PG.Sens.MP._1.AI_Output.Status;
				BRB2_02_REG_NIVO:
					PGRad_BRB2Cmd.RegulationMode := 2;
					PGRad_BRB2Cmd.RegulationPV := NivoPrihvatniSud;
					PGRad_BRB2Cmd.RegulationSP := PGRad.Par.SetPointNivoTanka;
					PGRad_BRB2Cmd.RegulationPVValid :=
						PG.Sens.Pt._NS1.AI_Output.Status
						AND PG.Sens.Pt._NS2.AI_Output.Status;
				BRB2_03_REG_TEMPERATURA:
					PGRad_BRB2Cmd.RegulationMode := 3;
					PGRad_BRB2Cmd.RegulationPV := PG01_Local.PGSens.Tt09.Value;
					PGRad_BRB2Cmd.RegulationSP := PGRad.Par.SetPointMinTempIspiranja;
					PGRad_BRB2Cmd.RegulationPVValid := PG01_Local.PGSens.Tt09.Valid;
			END_CASE
			(* Odrzava PID regulaciju ulaza i PT06 cuvara nakon punjenja tanka. *)
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.PropVentili.PV05.Enable := TRUE;

			(* Izlaznu pumpu pokrece i frekvencu vodi iskljucivo PID_Pu_PT. *)
			PGRad_Cmd.PID.Enable :=
				(PGRad.Ctrl.RegulacionaVarijanta = _01_REG_PRITISAK)
				OR (PGRad.Ctrl.RegulacionaVarijanta = _02_REG_NIVO);

			IF PGRad_Cmd.PID.Enable THEN
				PGRad_Cmd.PID.EnableTracking := (Rad_PG_KB.Sequence.Substep = 0);
				Rad_PG_KB.Sequence.Substep := 1;
			END_IF

			(* BRB2 sme preci u rad tek kada je tank pun i izabrana PG pumpa stvarno radi. *)
			PGRad_BRB2Cmd.PodstanicaURezimuRada :=
				(NivoPrihvatniSud >= PGRad.Par.SetPointNivoTanka)
				AND (
					((PGRad.Ctrl.AktivnaPumpaIzlazTanka = _01_Pu_PG_01)
						AND PG.Act.Pu._1.Status_inRun)
					OR ((PGRad.Ctrl.AktivnaPumpaIzlazTanka = _02_Pu_PG_02)
						AND PG.Act.Pu._2.Status_inRun)
				);

			(* Napusta granu cim PGRad.Ctrl.SelektovaniIzvor vise nije _01_BRB2. *)
			IF Rad_PG_KB.HMI.Cntrl.Stop OR (PGRad.Ctrl.SelektovaniIzvor <> _01_BRB2) THEN
				Rad_PG_KB.Sequence.State := PG_03_Zaustavljanje_BRB2;
				Rad_PG_KB.Sequence.Substep := 0;
			END_IF

		PG_03_Zaustavljanje_BRB2:
			(* PT najpre trazi BRB2 ramp-down, zatim zatvara PV grane po stop SP potvrdi. *)
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_BRB2Cmd.ZahtevZaustavljanja := TRUE;

			IF Rad_PG_KB.Sequence.Substep = 0 THEN
				Rad_PG_KB.Status.Pump.OutletStopped := TRUE;
				Rad_PG_KB.Sequence.Substep := 1;
			END_IF;

			(* Izlazna pumpa ostaje na aktivnoj regulaciji dok tank ne padne ispod 60% SP-a. *)
			IF NivoPrihvatniSud < (0.6 * PGRad.Par.SetPointNivoTanka) THEN
				Rad_PG_KB.Status.Pump.OutletStopped := FALSE;
			END_IF;

			IF Rad_PG_KB.Status.Pump.OutletStopped THEN
				PGRad_Cmd.PID.Enable :=
					(PGRad.Ctrl.RegulacionaVarijanta = _01_REG_PRITISAK)
					OR (PGRad.Ctrl.RegulacionaVarijanta = _02_REG_NIVO);
			END_IF;

			(* Izlazni ventil ostaje otvoren dok ATV ne potvrdi da se pumpa zaustavila. *)
			IF NOT Rad_PG_KB.Status.Pump.OutletStopped THEN
				CASE PGRad.Ctrl.AktivnaPumpaIzlazTanka OF
					_01_Pu_PG_01:
						PGRad_Cmd.Ventili._03_Open := PG.Act.Pu._1.Status_inRun;
					_02_Pu_PG_02:
						PGRad_Cmd.Ventili._04_Open := PG.Act.Pu._2.Status_inRun;
				END_CASE
			END_IF;

			IF NOT PGRad_BRB2.StopSPDostignut THEN
				(* Dok BRB2 spusta frekvenciju, PT06 i PT04 ostaju u regulaciji. *)
				PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
			END_IF;

			(* Nakon BRB2 stop SP-a svi proporcionalni ventili ostaju bez zahteva. *)
			PGRad_BRB2Cmd.VentiliPodstaniceZatvoreni := PGRad_BRB2.StopSPDostignut
				AND (PG.Act.PV._1.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje)
				AND (PG.Act.PV._2.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje)
				AND (PG.Act.PV._5.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje);

			IF PGRad_BRB2.RB2V02Zatvoren
				AND NOT Rad_PG_KB.Status.Pump.OutletStopped
				AND NOT PG.Act.Pu._1.Status_inRun
				AND NOT PG.Act.Pu._2.Status_inRun THEN
				Rad_PG_KB.Sequence.State := PG_00_Stand_By;
				Rad_PG_KB.Sequence.Substep := 0;
			END_IF

		PG_11_Priprema_IEBKB1:
			(* IEBKB1 put koristi samo PG_V01 i PG_V05; PV01/PV02/V06/V07 ostaju zatvoreni. *)
			IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ZahtevVode := TRUE;
			IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ModRada := 1;
			IEB_KB1.Cntrl.proba := TRUE;
			CASE Rad_PG_KB.Sequence.Substep OF
				0:
					(* Najpre se opoziva zahtev otvaranja BRB2 dovoda PG_V02. *)
					PGRad.CmdRetain.V02_Open := FALSE;
					Rad_PG_KB.Sequence.Substep := 1;

				1:
					(* Ceka se zatvoren PG_V02, pa se dozvoljava otvaranje IEBKB1 dovoda PG_V01. *)
					PGRad.CmdRetain.V02_Open := FALSE;
					Rad_PG_KB.Timer.PG_V02.Close.IN := NOT PG.Act.AV._2.Closed;
					IF PG.Act.AV._2.Closed THEN
						PGRad.CmdRetain.V01_Open := TRUE;
						Rad_PG_KB.Sequence.Substep := 2;
					ELSIF Rad_PG_KB.Timer.PG_V02.Close.Q THEN
						PGRad.CmdRetain.V01_Open := FALSE;
						PGRad.CmdRetain.V02_Open := FALSE;
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 13;
						Rad_PG_KB.Diag.Fault.Text := 'PG_V02 nije zatvoren za zadato vreme';
						Rad_PG_KB.Sequence.State := PG_00_Stand_By;
						Rad_PG_KB.Sequence.Substep := 0;
					END_IF

				2:
					(* Ceka se fizicka potvrda otvorenog PG_V01 za IEBKB1 dovod. *)
					PGRad.CmdRetain.V01_Open := TRUE;
					PGRad.CmdRetain.V02_Open := FALSE;
					Rad_PG_KB.Timer.PG_V01.Open.IN := NOT PG.Act.AV._1.Opened;
					IF PG.Act.AV._1.Opened THEN
						Rad_PG_KB.Sequence.Substep := 3;
					ELSIF Rad_PG_KB.Timer.PG_V01.Open.Q THEN
						PGRad.CmdRetain.V01_Open := FALSE;
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 14;
						Rad_PG_KB.Diag.Fault.Text := 'PG_V01 nije otvoren za zadato vreme';
						Rad_PG_KB.Sequence.State := PG_00_Stand_By;
						Rad_PG_KB.Sequence.Substep := 0;
					END_IF

				3:
					(* V05 vodi IEBKB1 vodu direktno u prihvatni tank. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.Ventili._05_Open := TRUE;
					Rad_PG_KB.Timer.IEBKB1.StartProtokTimeout.IN :=
						IEB_KB1.Cntrl.Comm.Podstanica.Status.TrenutniProtok <= 0.1;
					IF IEB_KB1.Cntrl.Comm.Podstanica.Status.TrenutniProtok > 0.1 THEN
						Rad_PG_KB.Sequence.Substep := 4;
					ELSIF Rad_PG_KB.Timer.IEBKB1.StartProtokTimeout.Q THEN
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 18;
						Rad_PG_KB.Diag.Fault.Text := 'IEBKB1 dotok nije poceo za zadato vreme';
						Rad_PG_KB.Sequence.State := PG_13_Zaustavljanje_IEBKB1;
						Rad_PG_KB.Sequence.Substep := 0;
					END_IF

				4:
					(* PG_V05 ostaje otvoren dok prihvatni tank ne dostigne zadati nivo. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.Ventili._05_Open := TRUE;
					IF NivoPrihvatniSud >= PGRad.Par.SetPointNivoTanka THEN
						Rad_PG_KB.Sequence.State := PG_12_Rad_IEBKB1;
						Rad_PG_KB.Sequence.Substep := 0;
					END_IF

			ELSE
				Rad_PG_KB.Sequence.Substep := 0;
			END_CASE

		PG_12_Rad_IEBKB1:
			(* IEBKB1 dovod ostaje otvoren; PT lokalno vodi samo izlaznu pumpu. *)
			PGRad.CmdRetain.V01_Open := TRUE;
			PGRad.CmdRetain.V02_Open := FALSE;
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.Ventili._05_Open := TRUE;
			IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ZahtevVode := TRUE;
			IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ModRada := 2;
			IEB_KB1.Cntrl.proba := TRUE;

			PGRad_Cmd.PID.Enable :=
				(PGRad.Ctrl.RegulacionaVarijanta = _01_REG_PRITISAK)
				OR (PGRad.Ctrl.RegulacionaVarijanta = _02_REG_NIVO);

			IF PGRad_Cmd.PID.Enable THEN
				PGRad_Cmd.PID.EnableTracking := (Rad_PG_KB.Sequence.Substep = 0);
				Rad_PG_KB.Sequence.Substep := 1;
			END_IF

			IF Rad_PG_KB.HMI.Cntrl.Stop OR (PGRad.Ctrl.SelektovaniIzvor <> _02_IEBKB1) THEN
				Rad_PG_KB.Sequence.State := PG_13_Zaustavljanje_IEBKB1;
				Rad_PG_KB.Sequence.Substep := 0;
			ELSIF Rad_PG_KB.HMI.Cntrl.TransferToBRB2 THEN
				Rad_PG_KB.HMI.Cntrl.TransferToBRB2 := FALSE;
				IF Rad_PG_KB.Sequence.BRB2.Ready
					AND PGRad_IEBKB1Prepared.Enable
					AND PGRad_IEBKB1Prepared.InterfaceReady
					AND PGRad_IEBKB1Prepared.CommValid
					AND PGRad_IEBKB1Prepared.HeartbeatValid
					AND NOT PGRad_IEBKB1Prepared.Fault THEN
					Rad_PG_KB.Sequence.Transfer.Requested := TRUE;
					Rad_PG_KB.Sequence.State := PG_14_Transfer_IEBKB1_BRB2;
					Rad_PG_KB.Sequence.Substep := 0;
				END_IF
			END_IF

		PG_14_Transfer_IEBKB1_BRB2:
			(* Transfer je dozvoljen samo uz kompletan buduci IEBKB1 statusni ugovor. *)
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ModRada := 3;
			CASE Rad_PG_KB.Sequence.Substep OF
				0:
					(* IEBKB1 zahtev vode je opozvan; PG_V05 ostaje otvoren do nultog protoka. *)
					PGRad.CmdRetain.V01_Open := TRUE;
					PGRad.CmdRetain.V02_Open := FALSE;
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.Ventili._05_Open := TRUE;
					Rad_PG_KB.Timer.IEBKB1.ProtokNula.IN := IEB_KB1.Sens.MP.B_01._01_value < 0.1;
					Rad_PG_KB.Timer.IEBKB1.StopProtokTimeout.IN := NOT Rad_PG_KB.Timer.IEBKB1.ProtokNula.Q;
					IF Rad_PG_KB.Timer.IEBKB1.ProtokNula.Q THEN
						Rad_PG_KB.Sequence.Substep := 1;
					ELSIF Rad_PG_KB.Timer.IEBKB1.StopProtokTimeout.Q THEN
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 31;
						Rad_PG_KB.Diag.Fault.Text := 'Transfer: IEBKB1 protok nije pao na nulu';
						Rad_PG_KB.Sequence.State := PG_13_Zaustavljanje_IEBKB1;
						Rad_PG_KB.Sequence.Substep := 1;
					END_IF

				1:
					(* Pneumatski PG_V05 se zatvara pre izolovanja IEBKB1 dovoda. *)
					PGRad.CmdRetain.V01_Open := TRUE;
					PGRad.CmdRetain.V02_Open := FALSE;
					Rad_PG_KB.Timer.PG_V05.Close.IN := NOT PG.Act.AV._5.Closed;
					IF PG.Act.AV._5.Closed THEN
						Rad_PG_KB.Sequence.Substep := 2;
					ELSIF Rad_PG_KB.Timer.PG_V05.Close.Q THEN
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 32;
						Rad_PG_KB.Diag.Fault.Text := 'Transfer: PG_V05 nije zatvoren';
						Rad_PG_KB.Sequence.State := PG_13_Zaustavljanje_IEBKB1;
						Rad_PG_KB.Sequence.Substep := 2;
					END_IF

				2:
					(* Tek posle zatvorenog PG_V05 zatvara se elektromotorni PG_V01. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					PGRad.CmdRetain.V02_Open := FALSE;
					Rad_PG_KB.Timer.PG_V01.Close.IN := NOT PG.Act.AV._1.Closed;
					IF PG.Act.AV._1.Closed THEN
						Rad_PG_KB.Sequence.Substep := 3;
					ELSIF Rad_PG_KB.Timer.PG_V01.Close.Q THEN
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 33;
						Rad_PG_KB.Diag.Fault.Text := 'Transfer: PG_V01 nije zatvoren';
						Rad_PG_KB.Sequence.State := PG_13_Zaustavljanje_IEBKB1;
						Rad_PG_KB.Sequence.Substep := 3;
					END_IF

				3:
					(* PG_V02 se otvara samo uz fizicku potvrdu zatvorenog PG_V01. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					PGRad.CmdRetain.V02_Open := TRUE;
					Rad_PG_KB.Timer.PG_V02.Open.IN := NOT PG.Act.AV._2.Opened;
					IF PG.Act.AV._2.Opened THEN
						Rad_PG_KB.Sequence.Substep := 4;
					ELSIF Rad_PG_KB.Timer.PG_V02.Open.Q THEN
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 34;
						Rad_PG_KB.Diag.Fault.Text := 'Transfer: PG_V02 nije otvoren';
						Rad_PG_KB.Sequence.State := PG_03_Zaustavljanje_BRB2;
						Rad_PG_KB.Sequence.Substep := 0;
					END_IF

				4:
					(* Dve petlje rade istovremeno: PV05/PT06 rampa i PV01/02/PT04 na 5.5 bar. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					Rad_PG_KB.Timer.Transfer.PV05Guard.IN := TRUE;
					Rad_PG_KB.Timer.Transfer.Flow.IN := NOT PGRad_BRB2.IspiranjeProtokDostignut;
					IF Rad_PG_KB.Timer.Transfer.Flow.Q THEN
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 35;
						Rad_PG_KB.Diag.Fault.Text := 'Transfer: BRB2 protok nije potvrden';
						Rad_PG_KB.Sequence.State := PG_03_Zaustavljanje_BRB2;
						Rad_PG_KB.Sequence.Substep := 0;
					ELSIF Rad_PG_KB.Timer.Transfer.PV05Guard.Q
						AND PGRad_BRB2.IspiranjeProtokDostignut
						AND (PG.Act.PV._5.PV_Output.PV_Percent <= PGRad.Par.Transfer.PV05ClosedPercent) THEN
						Rad_PG_KB.Sequence.Transfer.Requested := FALSE;
						Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_00_IDLE;
						Rad_PG_KB.Sequence.State := PG_02_Rad_BRB2;
						Rad_PG_KB.Sequence.Substep := 0;
					END_IF

			ELSE
				Rad_PG_KB.Sequence.Substep := 0;
			END_CASE

		PG_13_Zaustavljanje_IEBKB1:
			(* ==================================================================== *)
			(* 1) Podrazumevane komande za kontrolisano zaustavljanje IEBKB1       *)
			(* ==================================================================== *)
			(* Zahtev bunaru je uklonjen; V05 ostaje otvoren do potvrdenog nultog protoka. *)
			PGRad_Cmd.Aktivan := TRUE;
			PGRad.CmdRetain.V02_Open := FALSE;
			IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ModRada := 3;
			IEB_KB1.Cntrl.proba := FALSE;

			(* ==================================================================== *)
			(* 2) Zadrzavanje rada izlazne pumpe dok se tank ne isprazni            *)
			(* ==================================================================== *)
			IF Rad_PG_KB.Sequence.Substep = 0 THEN
				Rad_PG_KB.Status.Pump.OutletStopped := TRUE;
				Rad_PG_KB.Sequence.Substep := 1;
			END_IF;

			IF NivoPrihvatniSud < (0.6 * PGRad.Par.SetPointNivoTanka) THEN
				Rad_PG_KB.Status.Pump.OutletStopped := FALSE;
			END_IF;

			IF Rad_PG_KB.Status.Pump.OutletStopped THEN
				PGRad_Cmd.PID.Enable :=
					(PGRad.Ctrl.RegulacionaVarijanta = _01_REG_PRITISAK)
					OR (PGRad.Ctrl.RegulacionaVarijanta = _02_REG_NIVO);
			END_IF

			(* Izlazni ventil ostaje otvoren dok ATV ne potvrdi da se pumpa zaustavila. *)
			IF NOT Rad_PG_KB.Status.Pump.OutletStopped THEN
				CASE PGRad.Ctrl.AktivnaPumpaIzlazTanka OF
					_01_Pu_PG_01:
						PGRad_Cmd.Ventili._03_Open := PG.Act.Pu._1.Status_inRun;
					_02_Pu_PG_02:
						PGRad_Cmd.Ventili._04_Open := PG.Act.Pu._2.Status_inRun;
				END_CASE
			END_IF

			(* ==================================================================== *)
			(* 3) Stop podkoraci: nulti protok, PG_V05, zatim PG_V01                *)
			(* ==================================================================== *)
			CASE Rad_PG_KB.Sequence.Substep OF
				1:
					PGRad.CmdRetain.V01_Open := TRUE;
					PGRad_Cmd.Ventili._05_Open := TRUE;
					Rad_PG_KB.Timer.IEBKB1.ProtokNula.IN := IEB_KB1.Sens.MP.B_01._01_value < 0.1;
					Rad_PG_KB.Timer.IEBKB1.StopProtokTimeout.IN := NOT Rad_PG_KB.Timer.IEBKB1.ProtokNula.Q;
					IF Rad_PG_KB.Timer.IEBKB1.ProtokNula.Q THEN
						Rad_PG_KB.Sequence.Substep := 2;
					ELSIF Rad_PG_KB.Timer.IEBKB1.StopProtokTimeout.Q THEN
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 16;
						Rad_PG_KB.Diag.Fault.Text := 'IEBKB1 dotok nije prestao za zadato vreme';
					END_IF

				2:
					(* PG_V05 se zatvara tek nakon stabilne potvrde nultog dotoka. *)
					Rad_PG_KB.Timer.PG_V05.Close.IN := NOT PG.Act.AV._5.Closed;
					IF PG.Act.AV._5.Closed THEN
						IF PGRad.Ctrl.SelektovaniIzvor = _02_IEBKB1 THEN
							IF NOT Rad_PG_KB.Status.Pump.OutletStopped
								AND NOT PG.Act.Pu._1.Status_inRun
								AND NOT PG.Act.Pu._2.Status_inRun THEN
								Rad_PG_KB.Sequence.State := PG_00_Stand_By;
								Rad_PG_KB.Sequence.Substep := 0;
							END_IF
						ELSE
							PGRad.CmdRetain.V01_Open := FALSE;
							Rad_PG_KB.Sequence.Substep := 3;
						END_IF
					ELSIF Rad_PG_KB.Timer.PG_V05.Close.Q THEN
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 17;
						Rad_PG_KB.Diag.Fault.Text := 'PG_V05 nije zatvoren za zadato vreme';
					END_IF

				3:
					(* V01 se zatvara samo kada je zadrzani izbor izvora promenjen. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					Rad_PG_KB.Timer.PG_V01.Close.IN := NOT PG.Act.AV._1.Closed;
					IF PG.Act.AV._1.Closed
						AND NOT Rad_PG_KB.Status.Pump.OutletStopped
						AND NOT PG.Act.Pu._1.Status_inRun
						AND NOT PG.Act.Pu._2.Status_inRun THEN
						Rad_PG_KB.Sequence.State := PG_00_Stand_By;
						Rad_PG_KB.Sequence.Substep := 0;
					ELSIF Rad_PG_KB.Timer.PG_V01.Close.Q THEN
						Rad_PG_KB.Diag.Fault.Latched := TRUE;
						Rad_PG_KB.Diag.Fault.Code := 15;
						Rad_PG_KB.Diag.Fault.Text := 'PG_V01 nije zatvoren za zadato vreme';
					END_IF

			ELSE
				Rad_PG_KB.Sequence.Substep := 0;
			END_CASE

	ELSE
		(* Nepoznato stanje - bezbedan povratak na Stand_By. *)
		Rad_PG_KB.Sequence.State := PG_00_Stand_By;

	END_CASE

	(* -------------------------------------------------------------------------- *)
	(* 4.1) Centralno mapiranje PID regulacije izlazne pumpe                      *)
	(* -------------------------------------------------------------------------- *)
	(* Aktivno stanje odredjuje Enable, a izbori jedinstveno mapiraju PID i pumpu. *)
	IF PGRad_Cmd.PID.Enable THEN
		CASE PGRad.Ctrl.RegulacionaVarijanta OF
			_01_REG_PRITISAK:
				PGRad_Cmd.PID.ActValue := PG.Sens.Pt._5.AI_Output.ScaledValue;
				PGRad_Cmd.PID.SetValue := PGRad.Par.SetPritisakPotisa;
				PGRad_Cmd.PID.Invert := FALSE;

			_02_REG_NIVO:
				PGRad_Cmd.PID.ActValue := NivoPrihvatniSud;
				PGRad_Cmd.PID.SetValue := PGRad.Par.SetPointNivoTanka;
				PGRad_Cmd.PID.Invert := TRUE;
		END_CASE

		CASE PGRad.Ctrl.AktivnaPumpaIzlazTanka OF
			_01_Pu_PG_01:
				PGRad_Cmd.Ventili._03_Open := TRUE;
				PGRad_Cmd.Pumpe._01.Run := TRUE;

			_02_Pu_PG_02:
				PGRad_Cmd.Ventili._04_Open := TRUE;
				PGRad_Cmd.Pumpe._02.Run := TRUE;
		END_CASE
	END_IF

	(* -------------------------------------------------------------------------- *)
	(* 5) Nezavisna priprema BRB2 uz aktivno snabdevanje IEBKB1                   *)
	(* -------------------------------------------------------------------------- *)
	IF (Rad_PG_KB.Sequence.State = PG_12_Rad_IEBKB1) AND Rad_PG_KB.HMI.Cntrl.PrepareBRB2
		AND (Rad_PG_KB.Sequence.BRB2.PreparationState = BRB2_PREP_00_IDLE) THEN
		Rad_PG_KB.HMI.Cntrl.PrepareBRB2 := FALSE;
		Rad_PG_KB.Sequence.BRB2.Ready := FALSE;
		Rad_PG_KB.Sequence.BRB2.PreparationSubstep := 0;
		Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_10_START;
	END_IF;

	CASE Rad_PG_KB.Sequence.BRB2.PreparationState OF
		BRB2_PREP_00_IDLE:
			Rad_PG_KB.Sequence.BRB2.Ready := FALSE;

		BRB2_PREP_10_START:
			(* BRB2 startuje ka drenažnoj grani; PG_V02 ostaje zatvoren uz aktivan IEBKB1. *)
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
			Rad_PG_KB.Timer.BRB2.PreparationFlow.IN := NOT PGRad_BRB2.IspiranjeProtokDostignut;
			IF PGRad_BRB2.PumpaAktivna AND PGRad_BRB2.IspiranjeProtokDostignut THEN
				Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_20_ZAGREVANJE;
			ELSIF Rad_PG_KB.Timer.BRB2.PreparationFlow.Q THEN
				Rad_PG_KB.Diag.Fault.Latched := TRUE;
				Rad_PG_KB.Diag.Fault.Code := 21;
				Rad_PG_KB.Diag.Fault.Text := 'BRB2 priprema: protok nije potvrden';
				Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_40_STOPPING;
			END_IF

		BRB2_PREP_20_ZAGREVANJE:
			(* IEBKB1 i dalje puni tank; BRB2 odrzava protok i zagreva vod ka PG_PV05. *)
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
			Rad_PG_KB.Timer.BRB2.TemperatureAlarm.IN :=
				PG.Sens.Tt._7.AI_Output.ScaledValue < PGRad.Par.BRB2Preparation.MinTemperature_degC;
			Rad_PG_KB.Timer.BRB2.TemperatureStop.IN := Rad_PG_KB.Timer.BRB2.TemperatureAlarm.Q;
			IF PGRad_BRB2.IspiranjeMinTrajanjeDostignuto
				AND PGRad_BRB2.IspiranjeProtokDostignut
				AND ((PG.Sens.Tt._7.AI_Output.ScaledValue >= PGRad.Par.BRB2Preparation.MinTemperature_degC)
					OR Rad_PG_KB.HMI.Cntrl.Continue) THEN
				Rad_PG_KB.HMI.Cntrl.Continue := FALSE;
				Rad_PG_KB.Sequence.BRB2.Ready := TRUE;
				Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_30_SPReady;
			ELSIF Rad_PG_KB.Timer.BRB2.TemperatureAlarm.Q THEN
				Rad_PG_KB.Diag.Fault.Latched := TRUE;
				Rad_PG_KB.Diag.Fault.Code := 22;
				Rad_PG_KB.Diag.Fault.Text := 'BRB2 priprema: temperatura nije dostignuta';
				IF Rad_PG_KB.Timer.BRB2.TemperatureStop.Q THEN
					Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_40_STOPPING;
				END_IF
			END_IF

		BRB2_PREP_30_SPReady:
			(* Spreman BRB2 ostaje na drenaži do transfera ili kontrolisanog stopa. *)
			Rad_PG_KB.Sequence.BRB2.Ready := TRUE;
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
			IF Rad_PG_KB.HMI.Cntrl.Stop OR Rad_PG_KB.HMI.Manual.Stop OR Rad_PG_KB.HMI.Manual.Abort THEN
				Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_40_STOPPING;
			END_IF

		BRB2_PREP_40_STOPPING, BRB2_PREP_90_FAULT:
			Rad_PG_KB.Sequence.BRB2.Ready := FALSE;
			PGRad_BRB2Cmd.ZahtevZaustavljanja := TRUE;
			PGRad_BRB2Cmd.VentiliPodstaniceZatvoreni :=
				(PG.Act.PV._1.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje)
				AND (PG.Act.PV._2.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje)
				AND (PG.Act.PV._5.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje);
			IF PGRad_BRB2.RB2V02Zatvoren THEN
				Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_00_IDLE;
			END_IF
	END_CASE

	(* Visok PT06 prvo daje alarm, a tek nakon dodatnog vremena kontrolisani stop. *)
	Rad_PG_KB.Timer.BRB2.PressureAlarm.IN :=
		(Rad_PG_KB.Sequence.BRB2.PreparationState <> BRB2_PREP_00_IDLE)
		AND (PG.Sens.Pt._6.AI_Output.ScaledValue > PGRad.Par.Transfer.PV05FinalPressure_bar);
	Rad_PG_KB.Timer.BRB2.PressureStop.IN := Rad_PG_KB.Timer.BRB2.PressureAlarm.Q;
	IF Rad_PG_KB.Timer.BRB2.PressureAlarm.Q THEN
		Rad_PG_KB.Diag.Fault.Latched := TRUE;
		Rad_PG_KB.Diag.Fault.Code := 23;
		Rad_PG_KB.Diag.Fault.Text := 'BRB2 priprema: visok PT06 pritisak';
		IF Rad_PG_KB.Timer.BRB2.PressureStop.Q THEN
			Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_40_STOPPING;
		END_IF
	END_IF;

	(* Nevalidna BRB2 komunikacija ili udaljeni fault uvek vode u kontrolisani stop. *)
	IF (Rad_PG_KB.Sequence.BRB2.PreparationState <> BRB2_PREP_00_IDLE)
		AND (NOT PGRad_BRB2Watchdog.Valid OR PGRad_BRB2.BRB2Fault) THEN
		Rad_PG_KB.Sequence.BRB2.PreparationState := BRB2_PREP_40_STOPPING;
	END_IF;
	IF (Rad_PG_KB.Sequence.State = PG_02_Rad_BRB2)
		AND (NOT PGRad_BRB2Watchdog.Valid OR PGRad_BRB2.BRB2Fault) THEN
		Rad_PG_KB.Sequence.State := PG_03_Zaustavljanje_BRB2;
		Rad_PG_KB.Sequence.Substep := 0;
	END_IF;

	(* -------------------------------------------------------------------------- *)
	(* 6) Rezim rada i dozvole odzracivanja                                      *)
	(* -------------------------------------------------------------------------- *)
	(* Tokom pripreme, rada i zaustavljanja zadrzava se parametarski skup izvora. *)
	CASE Rad_PG_KB.Sequence.State OF
		PG_01_Priprema_BRB2, PG_02_Rad_BRB2, PG_03_Zaustavljanje_BRB2:
			PGRad_Cmd.AirRelease.PV03.Enable := TRUE;
			PGRad_Cmd.AirRelease.PV04.Enable := TRUE;
			PGRad_Cmd.AirRelease.UseIEBKB1Parameters := FALSE;
		PG_11_Priprema_IEBKB1, PG_12_Rad_IEBKB1, PG_13_Zaustavljanje_IEBKB1:
			PGRad_Cmd.AirRelease.PV03.Enable := TRUE;
			PGRad_Cmd.AirRelease.PV04.Enable := FALSE;
			PGRad_Cmd.AirRelease.UseIEBKB1Parameters := TRUE;
	END_CASE

	(* -------------------------------------------------------------------------- *)
	(* 7) Izvrsavanje tajmera pripreme, stop sekvence i prelaza PV05              *)
	(* -------------------------------------------------------------------------- *)
	(* IN/PT su pripremljeni u sekciji 3 i aktivnom stanju; ovde se osvezava Q/ET. *)
	Rad_PG_KB.Timer.PG_V01.Close();
	Rad_PG_KB.Timer.PG_V01.Open();
	Rad_PG_KB.Timer.PG_V02.Open();
	Rad_PG_KB.Timer.PG_V02.Close();
	Rad_PG_KB.Timer.IEBKB1.StartProtokTimeout();
	Rad_PG_KB.Timer.IEBKB1.ProtokNula();
	Rad_PG_KB.Timer.IEBKB1.StopProtokTimeout();
	Rad_PG_KB.Timer.PG_V05.Close();
	Rad_PG_KB.Timer.Transfer.PV05Guard();
	Rad_PG_KB.Timer.BRB2.PreparationFlow();
	Rad_PG_KB.Timer.BRB2.TemperatureAlarm();
	Rad_PG_KB.Timer.BRB2.TemperatureStop();
	Rad_PG_KB.Timer.BRB2.PressureAlarm();
	Rad_PG_KB.Timer.BRB2.PressureStop();
	Rad_PG_KB.Timer.Transfer.Flow();

	(* -------------------------------------------------------------------------- *)
	(* 8) PID petlje proporcionalnih ventila                                     *)
	(* -------------------------------------------------------------------------- *)
	(* 8.1) PV05 cuva PT06 tokom punjenja, rada BRB2 i njegovog ramp-down-a. *)
	Rad_PG_KB.Control.PV05.PID.Enable := ((Rad_PG_KB.Sequence.State = PG_01_Priprema_BRB2) AND (Rad_PG_KB.Sequence.Substep >= 3))
		OR (Rad_PG_KB.Sequence.State = PG_02_Rad_BRB2)
		OR ((Rad_PG_KB.Sequence.State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut)
		OR (Rad_PG_KB.Sequence.BRB2.PreparationState = BRB2_PREP_10_START)
		OR (Rad_PG_KB.Sequence.BRB2.PreparationState = BRB2_PREP_20_ZAGREVANJE)
		OR (Rad_PG_KB.Sequence.BRB2.PreparationState = BRB2_PREP_30_SPReady)
		OR ((Rad_PG_KB.Sequence.State = PG_14_Transfer_IEBKB1_BRB2) AND (Rad_PG_KB.Sequence.Substep = 4));
	Rad_PG_KB.Control.PV05.PID.ActValue := PG.Sens.Pt._6.AI_Output.ScaledValue; (* Merena vrednost PT06. *)
	(* U prelazu se SP linearno podize od ispiranja do maksimalnog pritiska voda. *)
	IF (Rad_PG_KB.Sequence.State = PG_14_Transfer_IEBKB1_BRB2) AND (Rad_PG_KB.Sequence.Substep = 4) THEN
		Rad_PG_KB.Control.PV05.FlushingSP := PGRad.Par.Transfer.PV05StartPressure_bar
			+ ((PGRad.Par.Transfer.PV05FinalPressure_bar - PGRad.Par.Transfer.PV05StartPressure_bar)
			* TIME_TO_REAL(Rad_PG_KB.Timer.Transfer.PV05Guard.ET) / TIME_TO_REAL(Rad_PG_KB.Timer.Transfer.PV05Guard.PT));
	ELSIF (Rad_PG_KB.Sequence.State = PG_01_Priprema_BRB2) AND (Rad_PG_KB.Sequence.Substep = 5) THEN
		Rad_PG_KB.Control.PV05.FlushingSP := PGRad.Par.SetPointPritisakPV05Ispiranje
			+ ((PGRad.Par.SetPointMaxPritisakDolaznaCev - PGRad.Par.SetPointPritisakPV05Ispiranje)
			* TIME_TO_REAL(Rad_PG_KB.Timer.Transfer.PV05Guard.ET) / TIME_TO_REAL(Rad_PG_KB.Timer.Transfer.PV05Guard.PT));
	ELSIF (((Rad_PG_KB.Sequence.State = PG_01_Priprema_BRB2) AND (Rad_PG_KB.Sequence.Substep >= 6))
		OR (Rad_PG_KB.Sequence.State = PG_02_Rad_BRB2)
		OR ((Rad_PG_KB.Sequence.State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut)) THEN
		Rad_PG_KB.Control.PV05.FlushingSP := PGRad.Par.SetPointMaxPritisakDolaznaCev;
	ELSIF (Rad_PG_KB.Sequence.BRB2.PreparationState = BRB2_PREP_10_START)
		OR (Rad_PG_KB.Sequence.BRB2.PreparationState = BRB2_PREP_20_ZAGREVANJE)
		OR (Rad_PG_KB.Sequence.BRB2.PreparationState = BRB2_PREP_30_SPReady) THEN
		Rad_PG_KB.Control.PV05.FlushingSP := PGRad.Par.Transfer.PV05StartPressure_bar;
	ELSE
		Rad_PG_KB.Control.PV05.FlushingSP := PGRad.Par.SetPointPritisakPV05Ispiranje;
	END_IF
	Rad_PG_KB.Control.PV05.PID.SetValue := Rad_PG_KB.Control.PV05.FlushingSP; (* Izracunati SP pritiska dolaznog voda. *)
	Rad_PG_KB.Control.PV05.PID();
	IF Rad_PG_KB.Control.PV05.PID.UpdateDone THEN
		Rad_PG_KB.Control.PV05.PID.Update := FALSE;
	END_IF

	(* 8.2) Aktivni ulazni ventil tanka odrzava PT04 po zadrzanom setpoint-u. *)
	Rad_PG_KB.Control.PV_UlazTanka.PID.Enable := ((Rad_PG_KB.Sequence.State = PG_01_Priprema_BRB2) AND (Rad_PG_KB.Sequence.Substep >= 4))
		OR (Rad_PG_KB.Sequence.State = PG_02_Rad_BRB2)
		OR ((Rad_PG_KB.Sequence.State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut)
		OR ((Rad_PG_KB.Sequence.State = PG_14_Transfer_IEBKB1_BRB2) AND (Rad_PG_KB.Sequence.Substep = 4));
	Rad_PG_KB.Control.PV_UlazTanka.PID.ActValue := PG.Sens.Pt._4.AI_Output.ScaledValue; (* Merena vrednost PT04. *)
	IF Rad_PG_KB.Sequence.State = PG_14_Transfer_IEBKB1_BRB2 THEN
		Rad_PG_KB.Control.PV_UlazTanka.PID.SetValue := PGRad.Par.Transfer.TankInletPressure_bar;
	ELSE
		Rad_PG_KB.Control.PV_UlazTanka.PID.SetValue := PGRad.Par.SetPointPritisakUlazTanka;
	END_IF;
	Rad_PG_KB.Control.PV_UlazTanka.PID();
	IF Rad_PG_KB.Control.PV_UlazTanka.PID.UpdateDone THEN
		Rad_PG_KB.Control.PV_UlazTanka.PID.Update := FALSE;
	END_IF

	(* 8.3) PID izlazi se upisuju samo kada odgovarajuca sekvenca dozvoljava ventil. *)
	IF Rad_PG_KB.Control.PV05.PID.Enable THEN
		PGRad_Cmd.PropVentili.PV05.SP_Percent := Rad_PG_KB.Control.PV05.PID.Out;
	END_IF
	IF Rad_PG_KB.Control.PV_UlazTanka.PID.Enable THEN
		CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
			_01_PG_PV01:
				PGRad_Cmd.Ventili._06_Open := TRUE;
				PGRad_Cmd.PropVentili.PV01.Enable := TRUE;
				PGRad_Cmd.PropVentili.PV01.SP_Percent := Rad_PG_KB.Control.PV_UlazTanka.PID.Out;
			_02_PG_PV02:
				PGRad_Cmd.Ventili._07_Open := TRUE;
				PGRad_Cmd.PropVentili.PV02.Enable := TRUE;
				PGRad_Cmd.PropVentili.PV02.SP_Percent := Rad_PG_KB.Control.PV_UlazTanka.PID.Out;
		END_CASE
	END_IF

	(* -------------------------------------------------------------------------- *)
	(* 9) Adapter RETAIN ulaznih ventila                                         *)
	(* -------------------------------------------------------------------------- *)
	(* Medjusobno iskljucenje V01/V02 stiti od paralelnog spajanja dva izvora. *)
	IF PGRad.CmdRetain.V01_Open AND PGRad.CmdRetain.V02_Open THEN
		PGRad.CmdRetain.V01_Open := FALSE;
		PGRad.CmdRetain.V02_Open := FALSE;
		Rad_PG_KB.Diag.Fault.Latched := TRUE;
		Rad_PG_KB.Diag.Fault.Code := 10;
		Rad_PG_KB.Diag.Fault.Text := 'PG_V01 i PG_V02 istovremeno zahtevani';
	END_IF;

	(* -------------------------------------------------------------------------- *)
	(* 10) Fault/reset politika                                                   *)
	(* -------------------------------------------------------------------------- *)
	(* Rad_PG_KB.HMI.Cntrl.Reset se prosledjuje AirRelease blokovima preko ResetAll. Procesni  *)
	(* Rad_PG_KB.Diag.Fault.Latched u pregledanom kodu nema implementirano brisanje/reset.        *)

	(* -------------------------------------------------------------------------- *)
	(* 11) Procesni status za Communication/HMI task                             *)
	(* -------------------------------------------------------------------------- *)
	(* Enum Rad_PG_KB.Sequence.State se preslikava u stabilan brojcani status AsIMA/HMI ugovora. *)
	CASE Rad_PG_KB.Sequence.State OF
		PG_01_Priprema_BRB2:
			PGRad_Status.State := 1;
			PGRad_Status.StateComment := 'STANJE: PRIPREMA BRB2';
		PG_02_Rad_BRB2:
			PGRad_Status.State := 2;
			PGRad_Status.StateComment := 'STANJE: RAD BRB2';
		PG_03_Zaustavljanje_BRB2:
			PGRad_Status.State := 3;
			PGRad_Status.StateComment := 'STANJE: ZAUSTAVLJANJE BRB2';
		PG_11_Priprema_IEBKB1:
			PGRad_Status.State := 11;
			PGRad_Status.StateComment := 'STANJE: PRIPREMA IEBKB1';
		PG_12_Rad_IEBKB1:
			PGRad_Status.State := 12;
			PGRad_Status.StateComment := 'STANJE: RAD IEBKB1';
		PG_13_Zaustavljanje_IEBKB1:
			PGRad_Status.State := 13;
			PGRad_Status.StateComment := 'STANJE: ZAUSTAVLJANJE IEBKB1';
		PG_14_Transfer_IEBKB1_BRB2:
			PGRad_Status.State := 14;
			PGRad_Status.StateComment := 'STANJE: TRANSFER IEBKB1 NA BRB2';
	ELSE
		PGRad_Status.State := 0;
		PGRad_Status.StateComment := 'STANJE: STANDBY';
	END_CASE
	PGRad_Status.Substep := Rad_PG_KB.Sequence.Substep;

	CASE Rad_PG_KB.Sequence.State OF
		PG_00_Stand_By:
			PGRad_Status.SubstepComment := 'PODKORAK: Ceka komandu START';

		PG_01_Priprema_BRB2:
			CASE Rad_PG_KB.Sequence.Substep OF
				0: PGRad_Status.SubstepComment := 'PODKORAK: Ulazak u pripremu BRB2';
				1: PGRad_Status.SubstepComment := 'PODKORAK: Ceka zatvaranje PG_V01';
				2: PGRad_Status.SubstepComment := 'PODKORAK: Ceka otvaranje PG_V02';
				3: PGRad_Status.SubstepComment := 'PODKORAK: Ispiranje BRB2 grane';
				4: PGRad_Status.SubstepComment := 'PODKORAK: Priprema ulaza prihvatnog tanka';
				5: PGRad_Status.SubstepComment := 'PODKORAK: Mek prelaz pritiska PG_PV05';
				6: PGRad_Status.SubstepComment := 'PODKORAK: Punjenje prihvatnog tanka';
			ELSE
				PGRad_Status.SubstepComment := 'PODKORAK: Nepoznata priprema BRB2';
			END_CASE

		PG_14_Transfer_IEBKB1_BRB2:
			PGRad_Status.SubstepComment := 'PODKORAK: Transfer IEBKB1 na BRB2';

		PG_02_Rad_BRB2:
			IF Rad_PG_KB.Sequence.Substep = 0 THEN
				PGRad_Status.SubstepComment := 'PODKORAK: Pokretanje izlazne pumpe';
			ELSE
				PGRad_Status.SubstepComment := 'PODKORAK: Regulacija i odrzavanje rada';
			END_IF

		PG_03_Zaustavljanje_BRB2:
			PGRad_Status.SubstepComment := 'PODKORAK: Kontrolisano zaustavljanje BRB2';

		PG_11_Priprema_IEBKB1:
			CASE Rad_PG_KB.Sequence.Substep OF
				0: PGRad_Status.SubstepComment := 'PODKORAK: Ulazak u pripremu IEBKB1';
				1: PGRad_Status.SubstepComment := 'PODKORAK: Ceka zatvaranje PG_V02';
				2: PGRad_Status.SubstepComment := 'PODKORAK: Ceka otvaranje PG_V01';
				3: PGRad_Status.SubstepComment := 'PODKORAK: Ceka pocetak dotoka IEBKB1';
				4: PGRad_Status.SubstepComment := 'PODKORAK: Punjenje prihvatnog tanka';
			ELSE
				PGRad_Status.SubstepComment := 'PODKORAK: Nepoznata priprema IEBKB1';
			END_CASE

		PG_12_Rad_IEBKB1:
			IF Rad_PG_KB.Sequence.Substep = 0 THEN
				PGRad_Status.SubstepComment := 'PODKORAK: Pokretanje izlazne pumpe';
			ELSE
				PGRad_Status.SubstepComment := 'PODKORAK: Regulacija i odrzavanje rada';
			END_IF

		PG_13_Zaustavljanje_IEBKB1:
			CASE Rad_PG_KB.Sequence.Substep OF
				0: PGRad_Status.SubstepComment := 'PODKORAK: Ulazak u zaustavljanje IEBKB1';
				1: PGRad_Status.SubstepComment := 'PODKORAK: Ceka prestanak dotoka IEBKB1';
				2: PGRad_Status.SubstepComment := 'PODKORAK: Ceka zatvaranje PG_V05';
				3: PGRad_Status.SubstepComment := 'PODKORAK: Ceka zatvaranje PG_V01';
			ELSE
				PGRad_Status.SubstepComment := 'PODKORAK: Nepoznat stop IEBKB1';
			END_CASE

	ELSE
		PGRad_Status.SubstepComment := 'PODKORAK: Nepoznato stanje sistema';
	END_CASE
	PGRad_Status.Fault := Rad_PG_KB.Diag.Fault.Latched;
	PGRad_Status.FaultCode := Rad_PG_KB.Diag.Fault.Code;
	CASE Rad_PG_KB.Sequence.BRB2.PreparationState OF
		BRB2_PREP_10_START:
			PGRad_Status.BRB2PreparationState := 10;
			PGRad_Status.BRB2PreparationStateComment := 'BRB2 PRIPREMA: START I CEKANJE PROTOKA';
		BRB2_PREP_20_ZAGREVANJE:
			PGRad_Status.BRB2PreparationState := 20;
			PGRad_Status.BRB2PreparationStateComment := 'BRB2 PRIPREMA: ZAGREVANJE CEVOVODA';
		BRB2_PREP_30_SPReady:
			PGRad_Status.BRB2PreparationState := 30;
			PGRad_Status.BRB2PreparationStateComment := 'BRB2 PRIPREMA: SP SPREMAN ZA TRANSFER';
		BRB2_PREP_40_STOPPING:
			PGRad_Status.BRB2PreparationState := 40;
			PGRad_Status.BRB2PreparationStateComment := 'BRB2 PRIPREMA: KONTROLISANO ZAUSTAVLJANJE';
		BRB2_PREP_90_FAULT:
			PGRad_Status.BRB2PreparationState := 90;
			PGRad_Status.BRB2PreparationStateComment := 'BRB2 PRIPREMA: FAULT';
	ELSE
		PGRad_Status.BRB2PreparationState := 0;
		PGRad_Status.BRB2PreparationStateComment := 'BRB2 PRIPREMA: IDLE';
	END_CASE
	PGRad_Status.BRB2Ready := Rad_PG_KB.Sequence.BRB2.Ready;
	PGRad_Status.IEBKB1InterfaceReady := PGRad_IEBKB1Prepared.Enable
		AND PGRad_IEBKB1Prepared.InterfaceReady
		AND PGRad_IEBKB1Prepared.CommValid
		AND PGRad_IEBKB1Prepared.HeartbeatValid
		AND NOT PGRad_IEBKB1Prepared.Fault;
	PGRad_Status.TransferBlocked := Rad_PG_KB.Sequence.BRB2.Ready AND NOT PGRad_Status.IEBKB1InterfaceReady;



END_PROGRAM
