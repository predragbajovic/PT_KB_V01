
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
		PGRad.Par.SetPritisakPotisa := 1.5;
		PGRad.Par.MinProtok := 2.0;
		PGRad.Par.MaxProtok := 16.2;
		PGRad.Par.MinFR_Pumpe := 2.0;
		PGRad.Par.MaxFR_Pumpe := 16.2;
		PGRad.Par.SetPointNivoTanka := 1.5;
		PGRad.Par.SetPointMinTempIspiranja := 60.0;
		PGRad.Par.SetPointPritisakPV05Ispiranje := 5.5;
		PGRad.Par.SetPointPritisakUlazTanka := 5.5;
		PGRad.Par.SetPointMaxPritisakDolaznaCev := 6.5;
		PGRad.Par.TimeSP.PrelazPV05Cuvar_s := 15.0;
		PGRad.Par.PocetnaFrekvencaIzlaznePumpe := 20.0;
		PGRad.Par.MaxOtvorPropZaZatvaranje := 0.1;
		PGRad.Par.TimeSP.OverlapPumpi_s := 10.0;
		PGRad.Par.TimeSP.AutoRestartDelay_s := 60.0;
		PGRad.Par.TimeSP.ValvePositionTimeout_s := 30.0;
		PGRad.Par.TimeSP.InterlockDebounce_s := 2.0;

		(* BRB2 odzracivanje: oba ventila, prag 1.5 bar sa 0.5 bar histerezom. *)
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

		(* IEBKB1 odzracivanje: aktivan je PV03 sa nizim pragom pritiska. *)
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
	PGRad_Cmd.PID.MaxOut := 0.0;
	PGRad_Cmd.PID.EnableTracking := FALSE;
	PGRad_Cmd.PID.TrackingValue := 0.0;
	PGRad_BRB2.RadKaPodstanici := FALSE;
	PGRad_BRB2.ZahtevStarta := FALSE;
	PGRad_BRB2.ZahtevZaustavljanja := FALSE;
	PGRad_BRB2.ManualMode := ManualMode;
	PGRad_BRB2.ManualSequence := ManualSequence;
	PGRad_BRB2.ManualStart := ManualStart;
	PGRad_BRB2.ManualStop := ManualStop;
	PGRad_BRB2.ManualNextStep := ManualNextStep;
	PGRad_BRB2.ManualAbort := ManualAbort;
	PGRad_BRB2.VentiliPodstaniceZatvoreni := FALSE;
	PGRad_BRB2.PritisakIEBKB1 := IEB_KB1.Sens.Pt.B_02._01_value;
	PGRad_BRB2.PodstanicaURezimuRada := FALSE;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ZahtevVode := FALSE;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.NivoPrihvatnogTanka := NivoPRihvatniSud;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.CiljaniProtok := PGRad.Par.MaxProtok;
	IEB_KB1.Cntrl.Comm.Podstanica.Zahtev.ModRada := 0;
	IEB_KB1.Cntrl.proba := FALSE;

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
			PGRad_BRB2.RadKaPodstanici := TRUE;
			PGRad_BRB2.ZahtevStarta := TRUE;
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
						_01_PG_PV01:
							PGRad_Cmd.Ventili._06_Open := TRUE;
							PGRad_Cmd.PropVentili.PV01.Enable := TRUE;
							Substep := 5;
						_02_PG_PV02:
							PGRad_Cmd.Ventili._07_Open := TRUE;
							PGRad_Cmd.PropVentili.PV02.Enable := TRUE;
							Substep := 5;
					END_CASE

				5:
					(* Mek prelaz: ulazni PV vodi PT04, a PT06 SP PG_PV05 raste 5.5 -> 6.5 bar. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					T_PrelazPV05Cuvar.IN := TRUE;
					CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
						_01_PG_PV01:
							PGRad_Cmd.Ventili._06_Open := TRUE;
							PGRad_Cmd.PropVentili.PV01.Enable := TRUE;
						_02_PG_PV02:
							PGRad_Cmd.Ventili._07_Open := TRUE;
							PGRad_Cmd.PropVentili.PV02.Enable := TRUE;
					END_CASE
					IF T_PrelazPV05Cuvar.Q AND (NOT ManualMode OR ManualNextStep) THEN
						ManualNextStep := FALSE;
						Substep := 6;
					END_IF

				6:
					(* Punjenje tanka: PV05 je cuvar PT06, a aktivni ulazni PV odrzava PT04. *)
					PGRad_Cmd.Aktivan := TRUE;
					PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
					CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
						_01_PG_PV01:
							PGRad_Cmd.Ventili._06_Open := TRUE;
							PGRad_Cmd.PropVentili.PV01.Enable := TRUE;
						_02_PG_PV02:
							PGRad_Cmd.Ventili._07_Open := TRUE;
							PGRad_Cmd.PropVentili.PV02.Enable := TRUE;
					END_CASE
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
			PGRad_BRB2.RadKaPodstanici := TRUE;
			PGRad_BRB2.ZahtevStarta := TRUE;
			(* Odrzava PID regulaciju ulaza i PT06 cuvara nakon punjenja tanka. *)
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
			CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
				_01_PG_PV01:
					PGRad_Cmd.Ventili._06_Open := TRUE;
					PGRad_Cmd.PropVentili.PV01.Enable := TRUE;
				_02_PG_PV02:
					PGRad_Cmd.Ventili._07_Open := TRUE;
					PGRad_Cmd.PropVentili.PV02.Enable := TRUE;
			END_CASE

			(* Izlaznu pumpu pokrece i frekvencu vodi iskljucivo PID_Pu_01. *)
			CASE PGRad.Ctrl.RegulacionaVarijanta OF
				_01_REG_PRITISAK:
					PGRad_Cmd.PID.Enable := TRUE;
					PGRad_Cmd.PID.ActValue := PG.Sens.Pt._5.AI_Output.ScaledValue;
					PGRad_Cmd.PID.SetValue := PGRad.Par.SetPritisakPotisa;
					PGRad_Cmd.PID.Invert := FALSE;
				_02_REG_NIVO:
					PGRad_Cmd.PID.Enable := TRUE;
					PGRad_Cmd.PID.ActValue := NivoPRihvatniSud;
					PGRad_Cmd.PID.SetValue := PGRad.Par.SetPointNivoTanka;
					PGRad_Cmd.PID.Invert := TRUE;
			END_CASE

			IF PGRad_Cmd.PID.Enable THEN
				PGRad_Cmd.PID.TrackingValue := PGRad.Par.PocetnaFrekvencaIzlaznePumpe;
				PGRad_Cmd.PID.EnableTracking := (Substep = 0);
				CASE PGRad.Ctrl.AktivnaPumpaIzlazTanka OF
					_01_Pu_PG_01:
						PGRad_Cmd.Ventili._03_Open := TRUE;
						PGRad_Cmd.Pumpe._01.Run := TRUE;
						PGRad_Cmd.PID.MaxOut := 70.0;
					_02_Pu_PG_02:
						PGRad_Cmd.Ventili._04_Open := TRUE;
						PGRad_Cmd.Pumpe._02.Run := TRUE;
						PGRad_Cmd.PID.MaxOut := 50.0;
				END_CASE
				Substep := 1;
			END_IF

			(* BRB2 sme preci u rad tek kada je tank pun i izabrana PG pumpa stvarno radi. *)
			PGRad_BRB2.PodstanicaURezimuRada :=
				(NivoPRihvatniSud >= PGRad.Par.SetPointNivoTanka)
				AND (
					((PGRad.Ctrl.AktivnaPumpaIzlazTanka = _01_Pu_PG_01)
						AND PG.Act.Pu._1.states.RUN)
					OR ((PGRad.Ctrl.AktivnaPumpaIzlazTanka = _02_Pu_PG_02)
						AND PG.Act.Pu._2.states.RUN)
				);

			(* Napusta granu cim PGRad.Ctrl.SelektovaniIzvor vise nije _01_BRB2. *)
			IF KomandaStop OR (PGRad.Ctrl.SelektovaniIzvor <> _01_BRB2) THEN
				State := PG_03_Zaustavljanje_BRB2;
				Substep := 0;
			END_IF

		PG_03_Zaustavljanje_BRB2:
			(* PT najpre trazi BRB2 ramp-down, zatim zatvara PV grane po stop SP potvrdi. *)
			PGRad_Cmd.Aktivan := TRUE;
			PGRad_BRB2.ZahtevZaustavljanja := TRUE;

			IF Substep = 0 THEN
				IzlaznaPumpaUStopu := TRUE;
				Substep := 1;
			END_IF;

			(* Izlazna pumpa ostaje na aktivnoj regulaciji dok tank ne padne ispod 60% SP-a. *)
			IF NivoPRihvatniSud < (0.6 * PGRad.Par.SetPointNivoTanka) THEN
				IzlaznaPumpaUStopu := FALSE;
			END_IF;

			IF IzlaznaPumpaUStopu THEN
				CASE PGRad.Ctrl.RegulacionaVarijanta OF
					_01_REG_PRITISAK:
						PGRad_Cmd.PID.Enable := TRUE;
						PGRad_Cmd.PID.ActValue := PG.Sens.Pt._5.AI_Output.ScaledValue;
						PGRad_Cmd.PID.SetValue := PGRad.Par.SetPritisakPotisa;
						PGRad_Cmd.PID.Invert := FALSE;
					_02_REG_NIVO:
						PGRad_Cmd.PID.Enable := TRUE;
						PGRad_Cmd.PID.ActValue := NivoPRihvatniSud;
						PGRad_Cmd.PID.SetValue := PGRad.Par.SetPointNivoTanka;
						PGRad_Cmd.PID.Invert := TRUE;
				END_CASE

				CASE PGRad.Ctrl.AktivnaPumpaIzlazTanka OF
					_01_Pu_PG_01:
						PGRad_Cmd.Ventili._03_Open := TRUE;
						PGRad_Cmd.Pumpe._01.Run := TRUE;
						PGRad_Cmd.PID.MaxOut := 70.0;
					_02_Pu_PG_02:
						PGRad_Cmd.Ventili._04_Open := TRUE;
						PGRad_Cmd.Pumpe._02.Run := TRUE;
						PGRad_Cmd.PID.MaxOut := 50.0;
				END_CASE
			END_IF;

			IF NOT PGRad_BRB2.StopSPDostignut THEN
				(* Dok BRB2 spusta frekvenciju, PT06 i PT04 ostaju u regulaciji. *)
				PGRad_Cmd.PropVentili.PV05.Enable := TRUE;
				CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
					_01_PG_PV01:
						PGRad_Cmd.Ventili._06_Open := TRUE;
						PGRad_Cmd.PropVentili.PV01.Enable := TRUE;
					_02_PG_PV02:
						PGRad_Cmd.Ventili._07_Open := TRUE;
						PGRad_Cmd.PropVentili.PV02.Enable := TRUE;
				END_CASE
			END_IF;

			(* Nakon BRB2 stop SP-a svi proporcionalni ventili ostaju bez zahteva. *)
			PGRad_BRB2.VentiliPodstaniceZatvoreni := PGRad_BRB2.StopSPDostignut
				AND (PG.Act.PV._1.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje)
				AND (PG.Act.PV._2.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje)
				AND (PG.Act.PV._5.PV_Output.PV_Percent <= PGRad.Par.MaxOtvorPropZaZatvaranje);

			IF PGRad_BRB2.RB2V02Zatvoren AND NOT IzlaznaPumpaUStopu THEN
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
					PGRad.CmdRetain.V02_Open := FALSE;
					Substep := 1;

				1:
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

			CASE PGRad.Ctrl.RegulacionaVarijanta OF
				_01_REG_PRITISAK:
					PGRad_Cmd.PID.Enable := TRUE;
					PGRad_Cmd.PID.ActValue := PG.Sens.Pt._5.AI_Output.ScaledValue;
					PGRad_Cmd.PID.SetValue := PGRad.Par.SetPritisakPotisa;
					PGRad_Cmd.PID.Invert := FALSE;
				_02_REG_NIVO:
					PGRad_Cmd.PID.Enable := TRUE;
					PGRad_Cmd.PID.ActValue := NivoPRihvatniSud;
					PGRad_Cmd.PID.SetValue := PGRad.Par.SetPointNivoTanka;
					PGRad_Cmd.PID.Invert := TRUE;
			END_CASE

			IF PGRad_Cmd.PID.Enable THEN
				PGRad_Cmd.PID.TrackingValue := PGRad.Par.PocetnaFrekvencaIzlaznePumpe;
				PGRad_Cmd.PID.EnableTracking := (Substep = 0);
				CASE PGRad.Ctrl.AktivnaPumpaIzlazTanka OF
					_01_Pu_PG_01:
						PGRad_Cmd.Ventili._03_Open := TRUE;
						PGRad_Cmd.Pumpe._01.Run := TRUE;
						PGRad_Cmd.PID.MaxOut := 70.0;
					_02_Pu_PG_02:
						PGRad_Cmd.Ventili._04_Open := TRUE;
						PGRad_Cmd.Pumpe._02.Run := TRUE;
						PGRad_Cmd.PID.MaxOut := 50.0;
				END_CASE
				Substep := 1;
			END_IF

			IF KomandaStop OR (PGRad.Ctrl.SelektovaniIzvor <> _02_IEBKB1) THEN
				State := PG_13_Zaustavljanje_IEBKB1;
				Substep := 0;
			END_IF

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
				CASE PGRad.Ctrl.RegulacionaVarijanta OF
					_01_REG_PRITISAK:
						PGRad_Cmd.PID.Enable := TRUE;
						PGRad_Cmd.PID.ActValue := PG.Sens.Pt._5.AI_Output.ScaledValue;
						PGRad_Cmd.PID.SetValue := PGRad.Par.SetPritisakPotisa;
						PGRad_Cmd.PID.Invert := FALSE;
					_02_REG_NIVO:
						PGRad_Cmd.PID.Enable := TRUE;
						PGRad_Cmd.PID.ActValue := NivoPRihvatniSud;
						PGRad_Cmd.PID.SetValue := PGRad.Par.SetPointNivoTanka;
						PGRad_Cmd.PID.Invert := TRUE;
				END_CASE

				CASE PGRad.Ctrl.AktivnaPumpaIzlazTanka OF
					_01_Pu_PG_01:
						PGRad_Cmd.Ventili._03_Open := TRUE;
						PGRad_Cmd.Pumpe._01.Run := TRUE;
						PGRad_Cmd.PID.MaxOut := 70.0;
					_02_Pu_PG_02:
						PGRad_Cmd.Ventili._04_Open := TRUE;
						PGRad_Cmd.Pumpe._02.Run := TRUE;
						PGRad_Cmd.PID.MaxOut := 50.0;
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
							IF NOT IzlaznaPumpaUStopu THEN
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
					IF PG.Act.AV._1.Closed AND NOT IzlaznaPumpaUStopu THEN
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
	(* 4) Rezim rada i dozvole odzracivanja                                      *)
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
	(* 5) Izvrsavanje tajmera pripreme, stop sekvence i prelaza PV05              *)
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

	(* -------------------------------------------------------------------------- *)
	(* 6) PID petlje proporcionalnih ventila                                     *)
	(* -------------------------------------------------------------------------- *)
	(* 6.1) PV05 cuva PT06 tokom punjenja, rada BRB2 i njegovog ramp-down-a. *)
	PID_PV05.Enable := ((State = PG_01_Priprema_BRB2) AND (Substep >= 3))
		OR (State = PG_02_Rad_BRB2)
		OR ((State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut);
	PID_PV05.ActValue := PG.Sens.Pt._6.AI_Output.ScaledValue; (* Merena vrednost PT06. *)
	(* U prelazu se SP linearno podize od ispiranja do maksimalnog pritiska voda. *)
	IF (State = PG_01_Priprema_BRB2) AND (Substep = 5) THEN
		SP_PV05 := PGRad.Par.SetPointPritisakPV05Ispiranje
			+ ((PGRad.Par.SetPointMaxPritisakDolaznaCev - PGRad.Par.SetPointPritisakPV05Ispiranje)
			* TIME_TO_REAL(T_PrelazPV05Cuvar.ET) / TIME_TO_REAL(T_PrelazPV05Cuvar.PT));
	ELSIF (((State = PG_01_Priprema_BRB2) AND (Substep >= 6))
		OR (State = PG_02_Rad_BRB2)
		OR ((State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut)) THEN
		SP_PV05 := PGRad.Par.SetPointMaxPritisakDolaznaCev;
	ELSE
		SP_PV05 := PGRad.Par.SetPointPritisakPV05Ispiranje;
	END_IF
	PID_PV05.SetValue := SP_PV05; (* Izracunati SP pritiska dolaznog voda. *)
	PID_PV05();
	IF PID_PV05.UpdateDone THEN
		PID_PV05.Update := FALSE;
	END_IF

	(* 6.2) Aktivni ulazni ventil tanka odrzava PT04 po zadrzanom setpoint-u. *)
	PID_PV_UlazTanka.Enable := ((State = PG_01_Priprema_BRB2) AND (Substep >= 4))
		OR (State = PG_02_Rad_BRB2)
		OR ((State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut);
	PID_PV_UlazTanka.ActValue := PG.Sens.Pt._4.AI_Output.ScaledValue; (* Merena vrednost PT04. *)
	PID_PV_UlazTanka.SetValue := PGRad.Par.SetPointPritisakUlazTanka; (* Zadrzani PT04 SP. *)
	PID_PV_UlazTanka();
	IF PID_PV_UlazTanka.UpdateDone THEN
		PID_PV_UlazTanka.Update := FALSE;
	END_IF

	(* 6.3) PID izlazi se upisuju samo kada odgovarajuca sekvenca dozvoljava ventil. *)
	IF (((State = PG_01_Priprema_BRB2) AND (Substep >= 3))
		OR (State = PG_02_Rad_BRB2)
		OR ((State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut)) THEN
		PGRad_Cmd.PropVentili.PV05.SP_Percent := PID_PV05.Out;
	END_IF
	IF (((State = PG_01_Priprema_BRB2) AND (Substep >= 4))
		OR (State = PG_02_Rad_BRB2)
		OR ((State = PG_03_Zaustavljanje_BRB2) AND NOT PGRad_BRB2.StopSPDostignut)) THEN
		CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
			_01_PG_PV01:
				PGRad_Cmd.PropVentili.PV01.SP_Percent := PID_PV_UlazTanka.Out;
			_02_PG_PV02:
				PGRad_Cmd.PropVentili.PV02.SP_Percent := PID_PV_UlazTanka.Out;
		END_CASE
	END_IF

	(* -------------------------------------------------------------------------- *)
	(* 7) Adapter RETAIN ulaznih ventila                                         *)
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
	(* 9) Procesni status za Communication/HMI task                              *)
	(* -------------------------------------------------------------------------- *)
	(* Enum State se preslikava u stabilan brojcani status AsIMA/HMI ugovora. *)
	CASE State OF
		PG_01_Priprema_BRB2:
			PGRad_Status.State := 1;
		PG_02_Rad_BRB2:
			PGRad_Status.State := 2;
		PG_03_Zaustavljanje_BRB2:
			PGRad_Status.State := 3;
		PG_11_Priprema_IEBKB1:
			PGRad_Status.State := 11;
		PG_12_Rad_IEBKB1:
			PGRad_Status.State := 12;
		PG_13_Zaustavljanje_IEBKB1:
			PGRad_Status.State := 13;
	ELSE
		PGRad_Status.State := 0;
	END_CASE
	PGRad_Status.Substep := Substep;
	PGRad_Status.Fault := FaultLatched;
	PGRad_Status.FaultCode := FaultCode;



END_PROGRAM
