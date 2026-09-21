
PROGRAM _CYCLIC
	(* ======================================================================== *)
	(* Rad_PG_KB_CYCLIC                                                          *)
	(* State masina izbora i rada izvora termalne vode: BRB2 (1) ili IEBKB1 (2). *)
	(* Prelazak izmedju grana ide iskljucivo preko PG_00_Stand_By - direktan     *)
	(* prelazak 1->2 ili 2->1 nije moguc.                                       *)
	(* ======================================================================== *)

	(* -------------------------------------------------------------------------- *)
	(* 1) Vracanje projektnih podrazumevanih parametara                          *)
	(* -------------------------------------------------------------------------- *)
	IF CmdSetDefaultParameters THEN
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

		CmdSetDefaultParameters := FALSE;
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
	PGRad_Cmd.AirRelease.ResetAll := KomandaReset;

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
	PGRad_BRB2Cmd.ManualMode := ManualMode;
	PGRad_BRB2Cmd.ManualSequence := ManualSequence;
	PGRad_BRB2Cmd.ManualStart := ManualStart;
	PGRad_BRB2Cmd.ManualStop := ManualStop;
	PGRad_BRB2Cmd.ManualNextStep := ManualNextStep;
	PGRad_BRB2Cmd.ManualAbort := ManualAbort;
	PGRad_BRB2Cmd.VentiliPodstaniceZatvoreni := FALSE;
	PGRad_BRB2Cmd.PritisakIEBKB1 := IEB_KB1.Sens.Pt.B_02._01_value;
	PGRad_BRB2Cmd.PodstanicaURezimuRada := FALSE;
	PGRad_BRB2Cmd.RegulationMode := 0;
	PGRad_BRB2Cmd.RegulationPV := 0.0;
	PGRad_BRB2Cmd.RegulationSP := 0.0;
	PGRad_BRB2Cmd.RegulationPVValid := FALSE;
	PGRad_BRB2Cmd.RegulationInvert := FALSE;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ZahtevVode := FALSE;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.NivoPrihvatnogTanka := NivoPRihvatniSud;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.CiljaniProtok := PGRad.Par.MaxProtok;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ModRada := 0;
	IEB_KB1.Cntrl.proba := FALSE;

	(* Izbor izvora sa HMI prihvata se samo u bezbednom Standby stanju. *)
	IF State = PG_00_Stand_By THEN
		IF SelectIEBKB1 THEN
			PGRad.Ctrl.SelektovaniIzvor := _02_IEBKB1;
		ELSE
			PGRad.Ctrl.SelektovaniIzvor := _01_BRB2;
		END_IF;
	ELSE
		SelectIEBKB1 := PGRad.Ctrl.SelektovaniIzvor = _02_IEBKB1;
	END_IF;

	(* -------------------------------------------------------------------------- *)
	(* 3) Tajmeri pripreme BRB2 dovodne putanje                                  *)
	(* -------------------------------------------------------------------------- *)
	T_PG_V01_Close.IN := FALSE;
	T_PG_V01_Close.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	T_PG_V02_Open.IN := FALSE;
	T_PG_V02_Open.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	T_PG_V02_Close.IN := FALSE;
	T_PG_V02_Close.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	T_PG_V01_Open.IN := FALSE;
	T_PG_V01_Open.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	T_IEBKB1_StartProtokTimeout.IN := FALSE;
	T_IEBKB1_StartProtokTimeout.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	T_IEBKB1_ProtokNula.IN := FALSE;
	T_IEBKB1_ProtokNula.PT := REAL_TO_TIME(PGRad.Par.TimeSP.InterlockDebounce_s * 1000.0);
	T_IEBKB1_StopProtokTimeout.IN := FALSE;
	T_IEBKB1_StopProtokTimeout.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	T_PG_V05_Close.IN := FALSE;
	T_PG_V05_Close.PT := REAL_TO_TIME(PGRad.Par.TimeSP.ValvePositionTimeout_s * 1000.0);
	T_PrelazPV05Cuvar.IN := FALSE;
	T_PrelazPV05Cuvar.PT := REAL_TO_TIME(PGRad.Par.TimeSP.PrelazPV05Cuvar_s * 1000.0);
	T_BRB2PreparationFlow.IN := FALSE;
	T_BRB2PreparationFlow.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.FlowTimeout_s * 1000.0);
	T_BRB2TemperatureAlarm.IN := FALSE;
	T_BRB2TemperatureAlarm.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.TemperatureAlarm_s * 1000.0);
	T_BRB2TemperatureStop.IN := FALSE;
	T_BRB2TemperatureStop.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.TemperatureStopDelay_s * 1000.0);
	T_BRB2PressureAlarm.IN := FALSE;
	T_BRB2PressureAlarm.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.PressureAlarmDelay_s * 1000.0);
	T_BRB2PressureStop.IN := FALSE;
	T_BRB2PressureStop.PT := REAL_TO_TIME(PGRad.Par.BRB2Preparation.PressureStopDelay_s * 1000.0);
	T_TransferFlow.IN := FALSE;
	T_TransferFlow.PT := REAL_TO_TIME(PGRad.Par.Transfer.FlowTimeout_s * 1000.0);

	(* -------------------------------------------------------------------------- *)
	(* 4) Glavna state masina izvora termalne vode                                *)
	(* -------------------------------------------------------------------------- *)
	(* ManualStart grane imaju prioritet evaluacije. BRB2 auto-start je blokiran  *)
	(* sa ManualMode, dok IEBKB1 auto-start grana nema eksplicitnu tu proveru.    *)
	CASE State OF

		PG_00_Stand_By:
			(* Neretentivni vektor je bezbedno resetovan u sekciji 2; V01/V02 se ne menjaju. *)
			PV05IspiranjeOtvoreno := FALSE;
			(* Start je dozvoljen samo sa izabranim izvorom i regulacionom varijantom. *)
			IF ManualMode AND ManualStart AND (ManualSequence = 1) THEN
				PGRad.Ctrl.SelektovaniIzvor := _01_BRB2;
				ManualStart := FALSE;
				State := PG_01_Priprema_BRB2;
				Substep := 0;
			ELSIF ManualMode AND ManualStart AND (ManualSequence = 2) THEN
				PGRad.Ctrl.SelektovaniIzvor := _02_IEBKB1;
				ManualStart := FALSE;
				State := PG_11_Priprema_IEBKB1;
				Substep := 0;
			ELSIF KomandaStart
				AND (NOT ManualMode)
				AND (NOT FaultLatched)
				AND (PGRad.Ctrl.RegulacionaVarijanta <> _00_neaktivan)
				AND (PGRad.Ctrl.SelektovaniIzvor = _01_BRB2) THEN
				State := PG_01_Priprema_BRB2;
				Substep := 0;
			ELSIF KomandaStart
				AND (NOT FaultLatched)
				AND (PGRad.Ctrl.RegulacionaVarijanta <> _00_neaktivan)
				AND (PGRad.Ctrl.SelektovaniIzvor = _02_IEBKB1) THEN
				State := PG_11_Priprema_IEBKB1;
				Substep := 0;
			END_IF

		PG_01_Priprema_BRB2:
			IF ManualStop OR ManualAbort THEN
				KomandaStop := TRUE;
				ManualStop := FALSE;
				ManualAbort := FALSE;
			END_IF;
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			CASE Substep OF
				0:
					(* Prioritet BRB2: najpre zatvori dovod sa IEBKB1. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					Substep := 1;

				1:
					(* Otvaranje BRB2 dovoda je dozvoljeno tek po potvrdi zatvorenog V01. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					T_PG_V01_Close.IN := NOT PG.Act.AV._1.Closed;
					IF PG.Act.AV._1.Closed AND (NOT ManualMode OR ManualNextStep) THEN
						ManualNextStep := FALSE;
						PGRad.CmdRetain.V02_Open := TRUE;
						Substep := 2;
					ELSIF T_PG_V01_Close.Q THEN
						PGRad.CmdRetain.V01_Open := FALSE;
						PGRad.CmdRetain.V02_Open := FALSE;
						FaultLatched := TRUE;
						FaultCode := 11;
						FaultText := 'PG_V01 nije zatvoren za zadato vreme';
						State := PG_00_Stand_By;
						Substep := 0;
					END_IF

				2:
					(* Ceka se fizicka potvrda otvorenog BRB2 dovoda. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					PGRad.CmdRetain.V02_Open := TRUE;
					T_PG_V02_Open.IN := NOT PG.Act.AV._2.Opened;
					IF PG.Act.AV._2.Opened AND (NOT ManualMode OR ManualNextStep) THEN
						ManualNextStep := FALSE;
						Substep := 3;
					ELSIF T_PG_V02_Open.Q THEN
						PGRad.CmdRetain.V01_Open := FALSE;
						PGRad.CmdRetain.V02_Open := FALSE;
						FaultLatched := TRUE;
						FaultCode := 12;
						FaultText := 'PG_V02 nije otvoren za zadato vreme';
						State := PG_00_Stand_By;
						Substep := 0;
					END_IF

				3:
					(* PG_PV05 se otvara nakon dostignutog PT06 pritiska; temperatura se proverava tek posle BRB2 minimuma. *)
					IF PG.Sens.Pt._6.AI_Output.ScaledValue >= PGRad.Par.SetPointPritisakPV05Ispiranje THEN
						PV05IspiranjeOtvoreno := TRUE;
					END_IF;
					IF PV05IspiranjeOtvoreno THEN
						PGRad_Cmd.Aktivan := TRUE;
						PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					END_IF;
					IF PGRad_BRB2.IspiranjeMinTrajanjeDostignuto
						AND (PG.Sens.Tt._7.AI_Output.ScaledValue >= PGRad.Par.SetPointMinTempIspiranja) THEN
						IF ManualMode AND NOT ManualNextStep THEN
							(* Manual mode holds the completed rinse step until operator confirmation. *)
						ELSE
							ManualNextStep := FALSE;
							IF ManualMode AND (ManualSequence = 1) THEN
								(* Manual flush ends here; controlled stop closes the BRB2 path. *)
								KomandaStop := TRUE;
								State := PG_03_Zaustavljanje_BRB2;
								Substep := 0;
							ELSE
								Substep := 4;
							END_IF
						END_IF
					END_IF

				4:
					(* Priprema puta ka tanku: otvara se samo ON/OFF ventil izabranog ulaznog PV-a. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
						_01_PG_PV01, _02_PG_PV02:
							Substep := 5;
					END_CASE

				5:
					(* Mek prelaz: ulazni PV vodi PT04, a PT06 SP PG_PV05 raste 5.5 -> 6.5 bar. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					T_PrelazPV05Cuvar.IN := TRUE;
					IF T_PrelazPV05Cuvar.Q AND (NOT ManualMode OR ManualNextStep) THEN
						ManualNextStep := FALSE;
						Substep := 6;
					END_IF

				6:
					(* Punjenje tanka: PV05 je cuvar PT06, a aktivni ulazni PV odrzava PT04. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					IF (NivoPRihvatniSud >= PGRad.Par.SetPointNivoTanka)
						AND (NOT ManualMode OR ManualNextStep) THEN
						ManualNextStep := FALSE;
						State := PG_02_Rad_BRB2;
						Substep := 0;
					END_IF

			ELSE
				Substep := 0;
			END_CASE

		PG_02_Rad_BRB2:
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			(* Podstanica bira aktivni BRB2 PV/SP; BRB2 lokalno menja samo FR_set. *)
			CASE PGRad.Ctrl.RegulacionaVarijanta OF
				_01_REG_PRITISAK:
					PGRad_BRB2Cmd.RegulationMode := 1;
					PGRad_BRB2Cmd.RegulationPV := PG.Sens.Pt._5.AI_Output.ScaledValue;
					PGRad_BRB2Cmd.RegulationSP := PGRad.Par.SetPritisakPotisa;
					PGRad_BRB2Cmd.RegulationPVValid := PG.Sens.Pt._5.AI_Output.Status;
				_02_REG_NIVO:
					PGRad_BRB2Cmd.RegulationMode := 2;
					PGRad_BRB2Cmd.RegulationPV := PG.Sens.MP._1.AI_Output.ScaledValue;
					PGRad_BRB2Cmd.RegulationSP := PGRad.Par.MaxProtok;
					PGRad_BRB2Cmd.RegulationPVValid := PG.Sens.MP._1.AI_Output.Status;
				_03_REG_TEMPERATURA:
					PGRad_BRB2Cmd.RegulationMode := 3;
					PGRad_BRB2Cmd.RegulationPV := PG.Sens.Tt._6.AI_Output.ScaledValue;
					PGRad_BRB2Cmd.RegulationSP := PGRad.Par.SetPointMinTempIspiranja;
					PGRad_BRB2Cmd.RegulationPVValid := PG.Sens.Tt._6.AI_Output.Status;
			END_CASE
			(* Odrzava PID regulaciju ulaza i PT06 cuvara nakon punjenja tanka. *)
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.PropVentili.PV05.Enable := TRUE;

			(* Izlaznu pumpu pokrece i frekvencu vodi iskljucivo PID_Pu_PT. *)
			PGRad_Cmd.PID.Enable :=
				(PGRad.Ctrl.RegulacionaVarijanta = _01_REG_PRITISAK)
				OR (PGRad.Ctrl.RegulacionaVarijanta = _02_REG_NIVO);

			IF PGRad_Cmd.PID.Enable THEN
				PGRad_Cmd.PID.EnableTracking := (Substep = 0);
				Substep := 1;
			END_IF

			(* BRB2 sme preci u rad tek kada je tank pun i izabrana PG pumpa stvarno radi. *)
			PGRad_BRB2Cmd.PodstanicaURezimuRada :=
				(NivoPRihvatniSud >= PGRad.Par.SetPointNivoTanka)
				AND (
					((PGRad.Ctrl.AktivnaPumpaIzlazTanka = _01_Pu_PG_01)
						AND PG.Act.Pu._1.Status_inRun)
					OR ((PGRad.Ctrl.AktivnaPumpaIzlazTanka = _02_Pu_PG_02)
						AND PG.Act.Pu._2.Status_inRun)
				);

			(* Napusta granu cim PGRad.Ctrl.SelektovaniIzvor vise nije _01_BRB2. *)
			IF KomandaStop OR (PGRad.Ctrl.SelektovaniIzvor <> _01_BRB2) THEN
				State := PG_03_Zaustavljanje_BRB2;
				Substep := 0;
			END_IF

		PG_03_Zaustavljanje_BRB2:
			(* PT najpre trazi BRB2 ramp-down, zatim zatvara PV grane po stop SP potvrdi. *)
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_BRB2Cmd.ZahtevZaustavljanja := TRUE;

			IF Substep = 0 THEN
				IzlaznaPumpaUStopu := TRUE;
				Substep := 1;
			END_IF;

			(* Izlazna pumpa ostaje na aktivnoj regulaciji dok tank ne padne ispod 60% SP-a. *)
			IF NivoPRihvatniSud < (0.6 * PGRad.Par.SetPointNivoTanka) THEN
				IzlaznaPumpaUStopu := FALSE;
			END_IF;

			IF IzlaznaPumpaUStopu THEN
				PGRad_Cmd.PID.Enable :=
					(PGRad.Ctrl.RegulacionaVarijanta = _01_REG_PRITISAK)
					OR (PGRad.Ctrl.RegulacionaVarijanta = _02_REG_NIVO);
			END_IF;

			(* Izlazni ventil ostaje otvoren dok ATV ne potvrdi da se pumpa zaustavila. *)
			IF NOT IzlaznaPumpaUStopu THEN
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
				AND NOT IzlaznaPumpaUStopu
				AND NOT PG.Act.Pu._1.Status_inRun
				AND NOT PG.Act.Pu._2.Status_inRun THEN
				State := PG_00_Stand_By;
				Substep := 0;
			END_IF

		PG_11_Priprema_IEBKB1:
			(* IEBKB1 put koristi samo PG_V01 i PG_V05; PV01/PV02/V06/V07 ostaju zatvoreni. *)
			IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ZahtevVode := TRUE;
			IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ModRada := 1;
			IEB_KB1.Cntrl.proba := TRUE;
			CASE Substep OF
				0:
					(* Najpre se opoziva zahtev otvaranja BRB2 dovoda PG_V02. *)
					PGRad.CmdRetain.V02_Open := FALSE;
					Substep := 1;

				1:
					(* Ceka se zatvoren PG_V02, pa se dozvoljava otvaranje IEBKB1 dovoda PG_V01. *)
					PGRad.CmdRetain.V02_Open := FALSE;
					T_PG_V02_Close.IN := NOT PG.Act.AV._2.Closed;
					IF PG.Act.AV._2.Closed THEN
						PGRad.CmdRetain.V01_Open := TRUE;
						Substep := 2;
					ELSIF T_PG_V02_Close.Q THEN
						PGRad.CmdRetain.V01_Open := FALSE;
						PGRad.CmdRetain.V02_Open := FALSE;
						FaultLatched := TRUE;
						FaultCode := 13;
						FaultText := 'PG_V02 nije zatvoren za zadato vreme';
						State := PG_00_Stand_By;
						Substep := 0;
					END_IF

				2:
					(* Ceka se fizicka potvrda otvorenog PG_V01 za IEBKB1 dovod. *)
					PGRad.CmdRetain.V01_Open := TRUE;
					PGRad.CmdRetain.V02_Open := FALSE;
					T_PG_V01_Open.IN := NOT PG.Act.AV._1.Opened;
					IF PG.Act.AV._1.Opened THEN
						Substep := 3;
					ELSIF T_PG_V01_Open.Q THEN
						PGRad.CmdRetain.V01_Open := FALSE;
						FaultLatched := TRUE;
						FaultCode := 14;
						FaultText := 'PG_V01 nije otvoren za zadato vreme';
						State := PG_00_Stand_By;
						Substep := 0;
					END_IF

				3:
					(* V05 vodi IEBKB1 vodu direktno u prihvatni tank. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.Ventili._05_Open := TRUE;
					T_IEBKB1_StartProtokTimeout.IN :=
						IEB_KB1.Cntrl.Comm.Podstanica.Status.TrenutniProtok <= 0.1;
					IF IEB_KB1.Cntrl.Comm.Podstanica.Status.TrenutniProtok > 0.1 THEN
						Substep := 4;
					ELSIF T_IEBKB1_StartProtokTimeout.Q THEN
						FaultLatched := TRUE;
						FaultCode := 18;
						FaultText := 'IEBKB1 dotok nije poceo za zadato vreme';
						State := PG_13_Zaustavljanje_IEBKB1;
						Substep := 0;
					END_IF

				4:
					(* PG_V05 ostaje otvoren dok prihvatni tank ne dostigne zadati nivo. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.Ventili._05_Open := TRUE;
					IF NivoPRihvatniSud >= PGRad.Par.SetPointNivoTanka THEN
						State := PG_12_Rad_IEBKB1;
						Substep := 0;
					END_IF

			ELSE
				Substep := 0;
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
				PGRad_Cmd.PID.EnableTracking := (Substep = 0);
				Substep := 1;
			END_IF

			IF KomandaStop OR (PGRad.Ctrl.SelektovaniIzvor <> _02_IEBKB1) THEN
				State := PG_13_Zaustavljanje_IEBKB1;
				Substep := 0;
			ELSIF KomandaTransferNaBRB2 THEN
				KomandaTransferNaBRB2 := FALSE;
				IF BRB2Ready
					AND PGRad_IEBKB1Prepared.Enable
					AND PGRad_IEBKB1Prepared.InterfaceReady
					AND PGRad_IEBKB1Prepared.CommValid
					AND PGRad_IEBKB1Prepared.HeartbeatValid
					AND NOT PGRad_IEBKB1Prepared.Fault THEN
					TransferRequested := TRUE;
					State := PG_14_Transfer_IEBKB1_BRB2;
					Substep := 0;
				END_IF
			END_IF

		PG_14_Transfer_IEBKB1_BRB2:
			(* Transfer je dozvoljen samo uz kompletan buduci IEBKB1 statusni ugovor. *)
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ModRada := 3;
			CASE Substep OF
				0:
					(* IEBKB1 zahtev vode je opozvan; PG_V05 ostaje otvoren do nultog protoka. *)
					PGRad.CmdRetain.V01_Open := TRUE;
					PGRad.CmdRetain.V02_Open := FALSE;
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.Ventili._05_Open := TRUE;
					T_IEBKB1_ProtokNula.IN := IEB_KB1.Sens.MP.B_01._01_value < 0.1;
					T_IEBKB1_StopProtokTimeout.IN := NOT T_IEBKB1_ProtokNula.Q;
					IF T_IEBKB1_ProtokNula.Q THEN
						Substep := 1;
					ELSIF T_IEBKB1_StopProtokTimeout.Q THEN
						FaultLatched := TRUE;
						FaultCode := 31;
						FaultText := 'Transfer: IEBKB1 protok nije pao na nulu';
						State := PG_13_Zaustavljanje_IEBKB1;
						Substep := 1;
					END_IF

				1:
					(* Pneumatski PG_V05 se zatvara pre izolovanja IEBKB1 dovoda. *)
					PGRad.CmdRetain.V01_Open := TRUE;
					PGRad.CmdRetain.V02_Open := FALSE;
					T_PG_V05_Close.IN := NOT PG.Act.AV._5.Closed;
					IF PG.Act.AV._5.Closed THEN
						Substep := 2;
					ELSIF T_PG_V05_Close.Q THEN
						FaultLatched := TRUE;
						FaultCode := 32;
						FaultText := 'Transfer: PG_V05 nije zatvoren';
						State := PG_13_Zaustavljanje_IEBKB1;
						Substep := 2;
					END_IF

				2:
					(* Tek posle zatvorenog PG_V05 zatvara se elektromotorni PG_V01. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					PGRad.CmdRetain.V02_Open := FALSE;
					T_PG_V01_Close.IN := NOT PG.Act.AV._1.Closed;
					IF PG.Act.AV._1.Closed THEN
						Substep := 3;
					ELSIF T_PG_V01_Close.Q THEN
						FaultLatched := TRUE;
						FaultCode := 33;
						FaultText := 'Transfer: PG_V01 nije zatvoren';
						State := PG_13_Zaustavljanje_IEBKB1;
						Substep := 3;
					END_IF

				3:
					(* PG_V02 se otvara samo uz fizicku potvrdu zatvorenog PG_V01. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					PGRad.CmdRetain.V02_Open := TRUE;
					T_PG_V02_Open.IN := NOT PG.Act.AV._2.Opened;
					IF PG.Act.AV._2.Opened THEN
						Substep := 4;
					ELSIF T_PG_V02_Open.Q THEN
						FaultLatched := TRUE;
						FaultCode := 34;
						FaultText := 'Transfer: PG_V02 nije otvoren';
						State := PG_03_Zaustavljanje_BRB2;
						Substep := 0;
					END_IF

				4:
					(* Dve petlje rade istovremeno: PV05/PT06 rampa i PV01/02/PT04 na 5.5 bar. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					T_PrelazPV05Cuvar.IN := TRUE;
					T_TransferFlow.IN := NOT PGRad_BRB2.IspiranjeProtokDostignut;
					IF T_TransferFlow.Q THEN
						FaultLatched := TRUE;
						FaultCode := 35;
						FaultText := 'Transfer: BRB2 protok nije potvrden';
						State := PG_03_Zaustavljanje_BRB2;
						Substep := 0;
					ELSIF T_PrelazPV05Cuvar.Q
						AND PGRad_BRB2.IspiranjeProtokDostignut
						AND (PG.Act.PV._5.PV_Output.PV_Percent <= PGRad.Par.Transfer.PV05ClosedPercent) THEN
						TransferRequested := FALSE;
						BRB2PreparationState := BRB2_PREP_00_IDLE;
						State := PG_02_Rad_BRB2;
						Substep := 0;
					END_IF

			ELSE
				Substep := 0;
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
			IF Substep = 0 THEN
				IzlaznaPumpaUStopu := TRUE;
				Substep := 1;
			END_IF;

			IF NivoPRihvatniSud < (0.6 * PGRad.Par.SetPointNivoTanka) THEN
				IzlaznaPumpaUStopu := FALSE;
			END_IF;

			IF IzlaznaPumpaUStopu THEN
				PGRad_Cmd.PID.Enable :=
					(PGRad.Ctrl.RegulacionaVarijanta = _01_REG_PRITISAK)
					OR (PGRad.Ctrl.RegulacionaVarijanta = _02_REG_NIVO);
			END_IF

			(* Izlazni ventil ostaje otvoren dok ATV ne potvrdi da se pumpa zaustavila. *)
			IF NOT IzlaznaPumpaUStopu THEN
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
			CASE Substep OF
				1:
					PGRad.CmdRetain.V01_Open := TRUE;
					PGRad_Cmd.Ventili._05_Open := TRUE;
					T_IEBKB1_ProtokNula.IN := IEB_KB1.Sens.MP.B_01._01_value < 0.1;
					T_IEBKB1_StopProtokTimeout.IN := NOT T_IEBKB1_ProtokNula.Q;
					IF T_IEBKB1_ProtokNula.Q THEN
						Substep := 2;
					ELSIF T_IEBKB1_StopProtokTimeout.Q THEN
						FaultLatched := TRUE;
						FaultCode := 16;
						FaultText := 'IEBKB1 dotok nije prestao za zadato vreme';
					END_IF

				2:
					(* PG_V05 se zatvara tek nakon stabilne potvrde nultog dotoka. *)
					T_PG_V05_Close.IN := NOT PG.Act.AV._5.Closed;
					IF PG.Act.AV._5.Closed THEN
						IF PGRad.Ctrl.SelektovaniIzvor = _02_IEBKB1 THEN
							IF NOT IzlaznaPumpaUStopu
								AND NOT PG.Act.Pu._1.Status_inRun
								AND NOT PG.Act.Pu._2.Status_inRun THEN
								State := PG_00_Stand_By;
								Substep := 0;
							END_IF
						ELSE
							PGRad.CmdRetain.V01_Open := FALSE;
							Substep := 3;
						END_IF
					ELSIF T_PG_V05_Close.Q THEN
						FaultLatched := TRUE;
						FaultCode := 17;
						FaultText := 'PG_V05 nije zatvoren za zadato vreme';
					END_IF

				3:
					(* V01 se zatvara samo kada je zadrzani izbor izvora promenjen. *)
					PGRad.CmdRetain.V01_Open := FALSE;
					T_PG_V01_Close.IN := NOT PG.Act.AV._1.Closed;
					IF PG.Act.AV._1.Closed
						AND NOT IzlaznaPumpaUStopu
						AND NOT PG.Act.Pu._1.Status_inRun
						AND NOT PG.Act.Pu._2.Status_inRun THEN
						State := PG_00_Stand_By;
						Substep := 0;
					ELSIF T_PG_V01_Close.Q THEN
						FaultLatched := TRUE;
						FaultCode := 15;
						FaultText := 'PG_V01 nije zatvoren za zadato vreme';
					END_IF

			ELSE
				Substep := 0;
			END_CASE

	ELSE
		(* Nepoznato stanje - bezbedan povratak na Stand_By. *)
		State := PG_00_Stand_By;

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
				PGRad_Cmd.PID.ActValue := NivoPRihvatniSud;
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
	IF (State = PG_12_Rad_IEBKB1) AND KomandaPripremaBRB2
		AND (BRB2PreparationState = BRB2_PREP_00_IDLE) THEN
		KomandaPripremaBRB2 := FALSE;
		BRB2Ready := FALSE;
		BRB2PreparationSubstep := 0;
		BRB2PreparationState := BRB2_PREP_10_START;
	END_IF;

	CASE BRB2PreparationState OF
		BRB2_PREP_00_IDLE:
			BRB2Ready := FALSE;

		BRB2_PREP_10_START:
			(* BRB2 startuje ka drenažnoj grani; PG_V02 ostaje zatvoren uz aktivan IEBKB1. *)
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
			T_BRB2PreparationFlow.IN := NOT PGRad_BRB2.IspiranjeProtokDostignut;
			IF PGRad_BRB2.PumpaAktivna AND PGRad_BRB2.IspiranjeProtokDostignut THEN
				BRB2PreparationState := BRB2_PREP_20_ZAGREVANJE;
			ELSIF T_BRB2PreparationFlow.Q THEN
				FaultLatched := TRUE;
				FaultCode := 21;
				FaultText := 'BRB2 priprema: protok nije potvrden';
				BRB2PreparationState := BRB2_PREP_40_STOPPING;
			END_IF

		BRB2_PREP_20_ZAGREVANJE:
			(* IEBKB1 i dalje puni tank; BRB2 odrzava protok i zagreva vod ka PG_PV05. *)
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
			T_BRB2TemperatureAlarm.IN :=
				PG.Sens.Tt._7.AI_Output.ScaledValue < PGRad.Par.BRB2Preparation.MinTemperature_degC;
			T_BRB2TemperatureStop.IN := T_BRB2TemperatureAlarm.Q;
			IF PGRad_BRB2.IspiranjeMinTrajanjeDostignuto
				AND PGRad_BRB2.IspiranjeProtokDostignut
				AND ((PG.Sens.Tt._7.AI_Output.ScaledValue >= PGRad.Par.BRB2Preparation.MinTemperature_degC)
					OR KomandaNastavak) THEN
				KomandaNastavak := FALSE;
				BRB2Ready := TRUE;
				BRB2PreparationState := BRB2_PREP_30_SPReady;
			ELSIF T_BRB2TemperatureAlarm.Q THEN
				FaultLatched := TRUE;
				FaultCode := 22;
				FaultText := 'BRB2 priprema: temperatura nije dostignuta';
				IF T_BRB2TemperatureStop.Q THEN
					BRB2PreparationState := BRB2_PREP_40_STOPPING;
				END_IF
			END_IF

		BRB2_PREP_30_SPReady:
			(* Spreman BRB2 ostaje na drenaži do transfera ili kontrolisanog stopa. *)
			BRB2Ready := TRUE;
			PGRad_BRB2Cmd.RadKaPodstanici := TRUE;
			PGRad_BRB2Cmd.ZahtevStarta := TRUE;
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
			IF KomandaStop OR ManualStop OR ManualAbort THEN
				BRB2PreparationState := BRB2_PREP_40_STOPPING;
			END_IF

		BRB2_PREP_40_STOPPING, BRB2_PREP_90_FAULT:
			BRB2Ready := FALSE;
			PGRad_BRB2Cmd.ZahtevZaustavljanja := TRUE;
			PGRad_BRB2Cmd.VentiliPodstaniceZatvoreni :=
				(PG.Act.PV._1.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje)
				AND (PG.Act.PV._2.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje)
				AND (PG.Act.PV._5.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje);
			IF PGRad_BRB2.RB2V02Zatvoren THEN
				BRB2PreparationState := BRB2_PREP_00_IDLE;
			END_IF
	END_CASE

	(* Visok PT06 prvo daje alarm, a tek nakon dodatnog vremena kontrolisani stop. *)
	T_BRB2PressureAlarm.IN :=
		(BRB2PreparationState <> BRB2_PREP_00_IDLE)
		AND (PG.Sens.Pt._6.AI_Output.ScaledValue > PGRad.Par.Transfer.PV05FinalPressure_bar);
	T_BRB2PressureStop.IN := T_BRB2PressureAlarm.Q;
	IF T_BRB2PressureAlarm.Q THEN
		FaultLatched := TRUE;
		FaultCode := 23;
		FaultText := 'BRB2 priprema: visok PT06 pritisak';
		IF T_BRB2PressureStop.Q THEN
			BRB2PreparationState := BRB2_PREP_40_STOPPING;
		END_IF
	END_IF;

	(* Nevalidna BRB2 komunikacija ili udaljeni fault uvek vode u kontrolisani stop. *)
	IF (BRB2PreparationState <> BRB2_PREP_00_IDLE)
		AND (NOT PGRad_BRB2Watchdog.Valid OR PGRad_BRB2.BRB2Fault) THEN
		BRB2PreparationState := BRB2_PREP_40_STOPPING;
	END_IF;
	IF (State = PG_02_Rad_BRB2)
		AND (NOT PGRad_BRB2Watchdog.Valid OR PGRad_BRB2.BRB2Fault) THEN
		State := PG_03_Zaustavljanje_BRB2;
		Substep := 0;
	END_IF;

	(* -------------------------------------------------------------------------- *)
	(* 6) Rezim rada i dozvole odzracivanja                                      *)
	(* -------------------------------------------------------------------------- *)
	(* Tokom pripreme, rada i zaustavljanja zadrzava se parametarski skup izvora. *)
	CASE State OF
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
	T_PG_V01_Close();
	T_PG_V01_Open();
	T_PG_V02_Open();
	T_PG_V02_Close();
	T_IEBKB1_StartProtokTimeout();
	T_IEBKB1_ProtokNula();
	T_IEBKB1_StopProtokTimeout();
	T_PG_V05_Close();
	T_PrelazPV05Cuvar();
	T_BRB2PreparationFlow();
	T_BRB2TemperatureAlarm();
	T_BRB2TemperatureStop();
	T_BRB2PressureAlarm();
	T_BRB2PressureStop();
	T_TransferFlow();

	(* -------------------------------------------------------------------------- *)
	(* 8) PID petlje proporcionalnih ventila                                     *)
	(* -------------------------------------------------------------------------- *)
	(* 8.1) PV05 cuva PT06 tokom punjenja, rada BRB2 i njegovog ramp-down-a. *)
	PID_PV05.Enable := ((State = PG_01_Priprema_BRB2) AND (Substep >= 3))
		OR (State = PG_02_Rad_BRB2)
		OR ((State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut)
		OR (BRB2PreparationState = BRB2_PREP_10_START)
		OR (BRB2PreparationState = BRB2_PREP_20_ZAGREVANJE)
		OR (BRB2PreparationState = BRB2_PREP_30_SPReady)
		OR ((State = PG_14_Transfer_IEBKB1_BRB2) AND (Substep = 4));
	PID_PV05.ActValue := PG.Sens.Pt._6.AI_Output.ScaledValue; (* Merena vrednost PT06. *)
	(* U prelazu se SP linearno podize od ispiranja do maksimalnog pritiska voda. *)
	IF (State = PG_14_Transfer_IEBKB1_BRB2) AND (Substep = 4) THEN
		SP_PV05 := PGRad.Par.Transfer.PV05StartPressure_bar
			+ ((PGRad.Par.Transfer.PV05FinalPressure_bar - PGRad.Par.Transfer.PV05StartPressure_bar)
			* TIME_TO_REAL(T_PrelazPV05Cuvar.ET) / TIME_TO_REAL(T_PrelazPV05Cuvar.PT));
	ELSIF (State = PG_01_Priprema_BRB2) AND (Substep = 5) THEN
		SP_PV05 := PGRad.Par.SetPointPritisakPV05Ispiranje
			+ ((PGRad.Par.SetPointMaxPritisakDolaznaCev - PGRad.Par.SetPointPritisakPV05Ispiranje)
			* TIME_TO_REAL(T_PrelazPV05Cuvar.ET) / TIME_TO_REAL(T_PrelazPV05Cuvar.PT));
	ELSIF (((State = PG_01_Priprema_BRB2) AND (Substep >= 6))
		OR (State = PG_02_Rad_BRB2)
		OR ((State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut)) THEN
		SP_PV05 := PGRad.Par.SetPointMaxPritisakDolaznaCev;
	ELSIF (BRB2PreparationState = BRB2_PREP_10_START)
		OR (BRB2PreparationState = BRB2_PREP_20_ZAGREVANJE)
		OR (BRB2PreparationState = BRB2_PREP_30_SPReady) THEN
		SP_PV05 := PGRad.Par.Transfer.PV05StartPressure_bar;
	ELSE
		SP_PV05 := PGRad.Par.SetPointPritisakPV05Ispiranje;
	END_IF
	PID_PV05.SetValue := SP_PV05; (* Izracunati SP pritiska dolaznog voda. *)
	PID_PV05();
	IF PID_PV05.UpdateDone THEN
		PID_PV05.Update := FALSE;
	END_IF

	(* 8.2) Aktivni ulazni ventil tanka odrzava PT04 po zadrzanom setpoint-u. *)
	PID_PV_UlazTanka.Enable := ((State = PG_01_Priprema_BRB2) AND (Substep >= 4))
		OR (State = PG_02_Rad_BRB2)
		OR ((State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut)
		OR ((State = PG_14_Transfer_IEBKB1_BRB2) AND (Substep = 4));
	PID_PV_UlazTanka.ActValue := PG.Sens.Pt._4.AI_Output.ScaledValue; (* Merena vrednost PT04. *)
	IF State = PG_14_Transfer_IEBKB1_BRB2 THEN
		PID_PV_UlazTanka.SetValue := PGRad.Par.Transfer.TankInletPressure_bar;
	ELSE
		PID_PV_UlazTanka.SetValue := PGRad.Par.SetPointPritisakUlazTanka;
	END_IF;
	PID_PV_UlazTanka();
	IF PID_PV_UlazTanka.UpdateDone THEN
		PID_PV_UlazTanka.Update := FALSE;
	END_IF

	(* 8.3) PID izlazi se upisuju samo kada odgovarajuca sekvenca dozvoljava ventil. *)
	IF PID_PV05.Enable THEN
		PGRad_Cmd.PropVentili.PV05.SP_Percent := PID_PV05.Out;
	END_IF
	IF PID_PV_UlazTanka.Enable THEN
		CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
			_01_PG_PV01:
				PGRad_Cmd.Ventili._06_Open := TRUE;
				PGRad_Cmd.PropVentili.PV01.Enable := TRUE;
				PGRad_Cmd.PropVentili.PV01.SP_Percent := PID_PV_UlazTanka.Out;
			_02_PG_PV02:
				PGRad_Cmd.Ventili._07_Open := TRUE;
				PGRad_Cmd.PropVentili.PV02.Enable := TRUE;
				PGRad_Cmd.PropVentili.PV02.SP_Percent := PID_PV_UlazTanka.Out;
		END_CASE
	END_IF

	(* -------------------------------------------------------------------------- *)
	(* 9) Adapter RETAIN ulaznih ventila                                         *)
	(* -------------------------------------------------------------------------- *)
	(* Medjusobno iskljucenje V01/V02 stiti od paralelnog spajanja dva izvora. *)
	IF PGRad.CmdRetain.V01_Open AND PGRad.CmdRetain.V02_Open THEN
		PGRad.CmdRetain.V01_Open := FALSE;
		PGRad.CmdRetain.V02_Open := FALSE;
		FaultLatched := TRUE;
		FaultCode := 10;
		FaultText := 'PG_V01 i PG_V02 istovremeno zahtevani';
	END_IF;

	(* -------------------------------------------------------------------------- *)
	(* 10) Fault/reset politika                                                   *)
	(* -------------------------------------------------------------------------- *)
	(* KomandaReset se prosledjuje AirRelease blokovima preko ResetAll. Procesni  *)
	(* FaultLatched u pregledanom kodu nema implementirano brisanje/reset.        *)

	(* -------------------------------------------------------------------------- *)
	(* 11) Procesni status za Communication/HMI task                             *)
	(* -------------------------------------------------------------------------- *)
	(* Enum State se preslikava u stabilan brojcani status AsIMA/HMI ugovora. *)
	CASE State OF
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
	PGRad_Status.Substep := Substep;

	CASE State OF
		PG_00_Stand_By:
			PGRad_Status.SubstepComment := 'PODKORAK: Ceka komandu START';

		PG_01_Priprema_BRB2:
			CASE Substep OF
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
			IF Substep = 0 THEN
				PGRad_Status.SubstepComment := 'PODKORAK: Pokretanje izlazne pumpe';
			ELSE
				PGRad_Status.SubstepComment := 'PODKORAK: Regulacija i odrzavanje rada';
			END_IF

		PG_03_Zaustavljanje_BRB2:
			PGRad_Status.SubstepComment := 'PODKORAK: Kontrolisano zaustavljanje BRB2';

		PG_11_Priprema_IEBKB1:
			CASE Substep OF
				0: PGRad_Status.SubstepComment := 'PODKORAK: Ulazak u pripremu IEBKB1';
				1: PGRad_Status.SubstepComment := 'PODKORAK: Ceka zatvaranje PG_V02';
				2: PGRad_Status.SubstepComment := 'PODKORAK: Ceka otvaranje PG_V01';
				3: PGRad_Status.SubstepComment := 'PODKORAK: Ceka pocetak dotoka IEBKB1';
				4: PGRad_Status.SubstepComment := 'PODKORAK: Punjenje prihvatnog tanka';
			ELSE
				PGRad_Status.SubstepComment := 'PODKORAK: Nepoznata priprema IEBKB1';
			END_CASE

		PG_12_Rad_IEBKB1:
			IF Substep = 0 THEN
				PGRad_Status.SubstepComment := 'PODKORAK: Pokretanje izlazne pumpe';
			ELSE
				PGRad_Status.SubstepComment := 'PODKORAK: Regulacija i odrzavanje rada';
			END_IF

		PG_13_Zaustavljanje_IEBKB1:
			CASE Substep OF
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
	PGRad_Status.Fault := FaultLatched;
	PGRad_Status.FaultCode := FaultCode;
	CASE BRB2PreparationState OF
		BRB2_PREP_10_START: PGRad_Status.BRB2PreparationState := 10;
		BRB2_PREP_20_ZAGREVANJE: PGRad_Status.BRB2PreparationState := 20;
		BRB2_PREP_30_SPReady: PGRad_Status.BRB2PreparationState := 30;
		BRB2_PREP_40_STOPPING: PGRad_Status.BRB2PreparationState := 40;
		BRB2_PREP_90_FAULT: PGRad_Status.BRB2PreparationState := 90;
	ELSE
		PGRad_Status.BRB2PreparationState := 0;
	END_CASE
	PGRad_Status.BRB2Ready := BRB2Ready;
	PGRad_Status.IEBKB1InterfaceReady := PGRad_IEBKB1Prepared.Enable
		AND PGRad_IEBKB1Prepared.InterfaceReady
		AND PGRad_IEBKB1Prepared.CommValid
		AND PGRad_IEBKB1Prepared.HeartbeatValid
		AND NOT PGRad_IEBKB1Prepared.Fault;
	PGRad_Status.TransferBlocked := BRB2Ready AND NOT PGRad_Status.IEBKB1InterfaceReady;



END_PROGRAM
