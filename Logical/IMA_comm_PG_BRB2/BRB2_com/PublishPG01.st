
ACTION PublishPG01:
	(* ======================================================================== *)
	(* 1) PG01 kontrolni snapshot za AsIMA DTO                                  *)
	(* ======================================================================== *)
	(* Lokalna stanja se pretvaraju u stabilne brojcane vrednosti komunikacionog ugovora. *)
	(* 1.1) Izabrani izvor termalne vode. *)
	CASE PGRad.Ctrl.SelektovaniIzvor OF
		_01_BRB2: PG01_Local.PGCtrl.Izvor := 1;
		_02_IEBKB1: PG01_Local.PGCtrl.Izvor := 2;
	ELSE
		PG01_Local.PGCtrl.Izvor := 0;
	END_CASE

	(* 1.2) Izabrana regulaciona varijanta izlazne pumpe. *)
	CASE PGRad.Ctrl.RegulacionaVarijanta OF
		_01_REG_PRITISAK: PG01_Local.PGCtrl.Regulacija := 1;
		_02_REG_NIVO: PG01_Local.PGCtrl.Regulacija := 2;
		_03_REG_TEMPERATURA: PG01_Local.PGCtrl.Regulacija := 3;
	ELSE
		PG01_Local.PGCtrl.Regulacija := 0;
	END_CASE

	(* 1.3) Izabrana izlazna pumpa prihvatnog tanka. *)
	CASE PGRad.Ctrl.AktivnaPumpaIzlazTanka OF
		_01_Pu_PG_01: PG01_Local.PGCtrl.IzlaznaPumpa := 1;
		_02_Pu_PG_02: PG01_Local.PGCtrl.IzlaznaPumpa := 2;
	ELSE
		PG01_Local.PGCtrl.IzlaznaPumpa := 0;
	END_CASE

	(* 1.4) Aktivni proporcionalni ventil na ulazu tanka. *)
	CASE PGRad.Ctrl.AktivniPropVentilUlazTanka OF
		_01_PG_PV01: PG01_Local.PGCtrl.UlazniPV := 1;
		_02_PG_PV02: PG01_Local.PGCtrl.UlazniPV := 2;
	ELSE
		PG01_Local.PGCtrl.UlazniPV := 0;
	END_CASE

	PG01_Local.PGCtrl.AutoRestart := PGRad.Ctrl.AutoRestart;
	PG01_Local.PGCtrl.State := PGRad_Status.State;
	PG01_Local.PGCtrl.Substep := PGRad_Status.Substep;
	PG01_Local.PGCtrl.Fault := PGRad_Status.Fault;
	PG01_Local.PGCtrl.FaultCode := PGRad_Status.FaultCode;

	(* ======================================================================== *)
	(* 2) PG01 lokalni snapshot za AsIMA sinoptiku                              *)
	(* ======================================================================== *)
	(* 2.1) Pu01: komanda, ostvareni rad, frekvencija i fault prve izlazne pumpe. *)
	PG01_Local.PGAct.Pu01.RunCmd := PG.Act.Pu._1.Start;
	PG01_Local.PGAct.Pu01.Running := PG.Act.Pu._1.Status_inRun;
	PG01_Local.PGAct.Pu01.Frequency := PG.Act.Pu._1.Ostvarena_brzina;
	PG01_Local.PGAct.Pu01.Alarm := PG.Act.Pu._1.Alarm_FR OR PG.Act.Pu._1.Alarm_CAN;

	(* 2.2) Pu02: komanda, ostvareni rad, frekvencija i fault druge izlazne pumpe. *)
	PG01_Local.PGAct.Pu02.RunCmd := PG.Act.Pu._2.Start;
	PG01_Local.PGAct.Pu02.Running := PG.Act.Pu._2.Status_inRun;
	PG01_Local.PGAct.Pu02.Frequency := PG.Act.Pu._2.Ostvarena_brzina;
	PG01_Local.PGAct.Pu02.Alarm := PG.Act.Pu._2.Alarm_FR OR PG.Act.Pu._2.Alarm_CAN;

	(* 2.3) PV01 i PV02: komandovana i stvarna pozicija ulaznih ventila tanka. *)
	PG01_Local.PGAct.PV01.Enable := PG.Act.PV._1.PV_Input.Enable;
	PG01_Local.PGAct.PV01.CmdPercent := PG.Act.PV._1.PV_Output.ActiveSP_Percent;
	PG01_Local.PGAct.PV01.PositionPercent := PG.Act.PV._1.PV_Output.PV_Percent;
	PG01_Local.PGAct.PV01.Alarm := PG.Act.PV._1.PV_Output.FaultActive;
	PG01_Local.PGAct.PV02.Enable := PG.Act.PV._2.PV_Input.Enable;
	PG01_Local.PGAct.PV02.CmdPercent := PG.Act.PV._2.PV_Output.ActiveSP_Percent;
	PG01_Local.PGAct.PV02.PositionPercent := PG.Act.PV._2.PV_Output.PV_Percent;
	PG01_Local.PGAct.PV02.Alarm := PG.Act.PV._2.PV_Output.FaultActive;
	(* 2.4) PV03, PV04 i PV05: lokalni status ostalih proporcionalnih ventila. *)
	PG01_Local.PGAct.PV03.Enable := PG.Act.PV._3.PV_Input.Enable;
	PG01_Local.PGAct.PV03.CmdPercent := PG.Act.PV._3.PV_Output.ActiveSP_Percent;
	PG01_Local.PGAct.PV03.PositionPercent := PG.Act.PV._3.PV_Output.PV_Percent;
	PG01_Local.PGAct.PV03.Alarm := PG.Act.PV._3.PV_Output.FaultActive;
	PG01_Local.PGAct.PV04.Enable := PG.Act.PV._4.PV_Input.Enable;
	PG01_Local.PGAct.PV04.CmdPercent := PG.Act.PV._4.PV_Output.ActiveSP_Percent;
	PG01_Local.PGAct.PV04.PositionPercent := PG.Act.PV._4.PV_Output.PV_Percent;
	PG01_Local.PGAct.PV04.Alarm := PG.Act.PV._4.PV_Output.FaultActive;
	PG01_Local.PGAct.PV05.Enable := PG.Act.PV._5.PV_Input.Enable;
	PG01_Local.PGAct.PV05.CmdPercent := PG.Act.PV._5.PV_Output.ActiveSP_Percent;
	PG01_Local.PGAct.PV05.PositionPercent := PG.Act.PV._5.PV_Output.PV_Percent;
	PG01_Local.PGAct.PV05.Alarm := PG.Act.PV._5.PV_Output.FaultActive;

	(* 2.5) AV01 i AV02: dvosmerne komande i granicni prekidaci dovodnih ventila. *)
	PG01_Local.PGAct.AV01.OpenCmd := PG.Act.AV._1.V_Output.CmdOpen;
	PG01_Local.PGAct.AV01.CloseCmd := PG.Act.AV._1.V_Output.CmdClose;
	PG01_Local.PGAct.AV01.Opened := PG.Act.AV._1.Opened;
	PG01_Local.PGAct.AV01.Closed := PG.Act.AV._1.Closed;
	PG01_Local.PGAct.AV01.Alarm := PG.Act.AV._1.V_Output.FaultLatched;
	PG01_Local.PGAct.AV02.OpenCmd := PG.Act.AV._2.V_Output.CmdOpen;
	PG01_Local.PGAct.AV02.CloseCmd := PG.Act.AV._2.V_Output.CmdClose;
	PG01_Local.PGAct.AV02.Opened := PG.Act.AV._2.Opened;
	PG01_Local.PGAct.AV02.Closed := PG.Act.AV._2.Closed;
	PG01_Local.PGAct.AV02.Alarm := PG.Act.AV._2.V_Output.FaultLatched;
	(* 2.6) AV03 do AV07: zahtev otvaranja, polozaj i fault procesnih ventila. *)
	PG01_Local.PGAct.AV03.OpenCmd := PG.Act.AV._3.Open;
	PG01_Local.PGAct.AV03.Opened := PG.Act.AV._3.Opened;
	PG01_Local.PGAct.AV03.Closed := PG.Act.AV._3.Closed;
	PG01_Local.PGAct.AV03.Alarm := PG.Act.AV._3.V_Output.FaultLatched;
	PG01_Local.PGAct.AV04.OpenCmd := PG.Act.AV._4.Open;
	PG01_Local.PGAct.AV04.Opened := PG.Act.AV._4.Opened;
	PG01_Local.PGAct.AV04.Closed := PG.Act.AV._4.Closed;
	PG01_Local.PGAct.AV04.Alarm := PG.Act.AV._4.V_Output.FaultLatched;
	PG01_Local.PGAct.AV05.OpenCmd := PG.Act.AV._5.Open;
	PG01_Local.PGAct.AV05.Opened := PG.Act.AV._5.Opened;
	PG01_Local.PGAct.AV05.Closed := PG.Act.AV._5.Closed;
	PG01_Local.PGAct.AV05.Alarm := PG.Act.AV._5.V_Output.FaultLatched;
	PG01_Local.PGAct.AV06.OpenCmd := PG.Act.AV._6.Open;
	PG01_Local.PGAct.AV06.Opened := PG.Act.AV._6.Opened;
	PG01_Local.PGAct.AV06.Closed := PG.Act.AV._6.Closed;
	PG01_Local.PGAct.AV06.Alarm := PG.Act.AV._6.V_Output.FaultLatched;
	PG01_Local.PGAct.AV07.OpenCmd := PG.Act.AV._7.Open;
	PG01_Local.PGAct.AV07.Opened := PG.Act.AV._7.Opened;
	PG01_Local.PGAct.AV07.Closed := PG.Act.AV._7.Closed;
	PG01_Local.PGAct.AV07.Alarm := PG.Act.AV._7.V_Output.FaultLatched;
	(* 2.7) RV19 i RV21 do RV27: samo fizicki polozaj i alarm rucnih ventila. *)
	PG01_Local.PGAct.RV19.Opened := PG.Act.RV._19.HV_Output.Opened;
	PG01_Local.PGAct.RV19.Closed := PG.Act.RV._19.HV_Output.Closed;
	PG01_Local.PGAct.RV19.Alarm := PG.Act.RV._19.HV_Output.AlarmLatched;
	PG01_Local.PGAct.RV21.Opened := PG.Act.RV._21.HV_Output.Opened;
	PG01_Local.PGAct.RV21.Closed := PG.Act.RV._21.HV_Output.Closed;
	PG01_Local.PGAct.RV21.Alarm := PG.Act.RV._21.HV_Output.AlarmLatched;
	PG01_Local.PGAct.RV22.Opened := PG.Act.RV._22.HV_Output.Opened;
	PG01_Local.PGAct.RV22.Closed := PG.Act.RV._22.HV_Output.Closed;
	PG01_Local.PGAct.RV22.Alarm := PG.Act.RV._22.HV_Output.AlarmLatched;
	PG01_Local.PGAct.RV23.Opened := PG.Act.RV._23.HV_Output.Opened;
	PG01_Local.PGAct.RV23.Closed := PG.Act.RV._23.HV_Output.Closed;
	PG01_Local.PGAct.RV23.Alarm := PG.Act.RV._23.HV_Output.AlarmLatched;
	PG01_Local.PGAct.RV24.Opened := PG.Act.RV._24.HV_Output.Opened;
	PG01_Local.PGAct.RV24.Closed := PG.Act.RV._24.HV_Output.Closed;
	PG01_Local.PGAct.RV24.Alarm := PG.Act.RV._24.HV_Output.AlarmLatched;
	PG01_Local.PGAct.RV25.Opened := PG.Act.RV._25.HV_Output.Opened;
	PG01_Local.PGAct.RV25.Closed := PG.Act.RV._25.HV_Output.Closed;
	PG01_Local.PGAct.RV25.Alarm := PG.Act.RV._25.HV_Output.AlarmLatched;
	PG01_Local.PGAct.RV26.Opened := PG.Act.RV._26.HV_Output.Opened;
	PG01_Local.PGAct.RV26.Closed := PG.Act.RV._26.HV_Output.Closed;
	PG01_Local.PGAct.RV26.Alarm := PG.Act.RV._26.HV_Output.AlarmLatched;
	PG01_Local.PGAct.RV27.Opened := PG.Act.RV._27.HV_Output.Opened;
	PG01_Local.PGAct.RV27.Closed := PG.Act.RV._27.HV_Output.Closed;
	PG01_Local.PGAct.RV27.Alarm := PG.Act.RV._27.HV_Output.AlarmLatched;

	(* 2.8) Pritisci: vrednost, validnost i fault za svaki analogni Pt kanal. *)
	PG01_Local.PGSens.Pt00.Value := PG.Sens.Pt._0_0.AI_Output.ScaledValue;
	PG01_Local.PGSens.Pt00.Valid := PG.Sens.Pt._0_0.AI_Output.Status;
	PG01_Local.PGSens.Pt00.Alarm := PG.Sens.Pt._0_0.AI_Output.FaultLatched;
	PG01_Local.PGSens.Pt01.Value := PG.Sens.Pt._1.AI_Output.ScaledValue;
	PG01_Local.PGSens.Pt01.Valid := PG.Sens.Pt._1.AI_Output.Status;
	PG01_Local.PGSens.Pt01.Alarm := PG.Sens.Pt._1.AI_Output.FaultLatched;
	PG01_Local.PGSens.Pt02.Value := PG.Sens.Pt._2.AI_Output.ScaledValue;
	PG01_Local.PGSens.Pt02.Valid := PG.Sens.Pt._2.AI_Output.Status;
	PG01_Local.PGSens.Pt02.Alarm := PG.Sens.Pt._2.AI_Output.FaultLatched;
	PG01_Local.PGSens.Pt03.Value := PG.Sens.Pt._3.AI_Output.ScaledValue;
	PG01_Local.PGSens.Pt03.Valid := PG.Sens.Pt._3.AI_Output.Status;
	PG01_Local.PGSens.Pt03.Alarm := PG.Sens.Pt._3.AI_Output.FaultLatched;
	PG01_Local.PGSens.Pt04.Value := PG.Sens.Pt._4.AI_Output.ScaledValue;
	PG01_Local.PGSens.Pt04.Valid := PG.Sens.Pt._4.AI_Output.Status;
	PG01_Local.PGSens.Pt04.Alarm := PG.Sens.Pt._4.AI_Output.FaultLatched;
	PG01_Local.PGSens.Pt05.Value := PG.Sens.Pt._5.AI_Output.ScaledValue;
	PG01_Local.PGSens.Pt05.Valid := PG.Sens.Pt._5.AI_Output.Status;
	PG01_Local.PGSens.Pt05.Alarm := PG.Sens.Pt._5.AI_Output.FaultLatched;
	PG01_Local.PGSens.Pt06.Value := PG.Sens.Pt._6.AI_Output.ScaledValue;
	PG01_Local.PGSens.Pt06.Valid := PG.Sens.Pt._6.AI_Output.Status;
	PG01_Local.PGSens.Pt06.Alarm := PG.Sens.Pt._6.AI_Output.FaultLatched;
	PG01_Local.PGSens.PtNS1.Value := PG.Sens.Pt._NS1.AI_Output.ScaledValue;
	PG01_Local.PGSens.PtNS1.Valid := PG.Sens.Pt._NS1.AI_Output.Status;
	PG01_Local.PGSens.PtNS1.Alarm := PG.Sens.Pt._NS1.AI_Output.FaultLatched;
	PG01_Local.PGSens.PtNS2.Value := PG.Sens.Pt._NS2.AI_Output.ScaledValue;
	PG01_Local.PGSens.PtNS2.Valid := PG.Sens.Pt._NS2.AI_Output.Status;
	PG01_Local.PGSens.PtNS2.Alarm := PG.Sens.Pt._NS2.AI_Output.FaultLatched;
	(* 2.9) Temperature: vrednost, validnost i fault za svaki analogni Tt kanal. *)
	PG01_Local.PGSens.Tt01.Value := PG.Sens.Tt._1.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt01.Valid := PG.Sens.Tt._1.AI_Output.Status;
	PG01_Local.PGSens.Tt01.Alarm := PG.Sens.Tt._1.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt02.Value := PG.Sens.Tt._2.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt02.Valid := PG.Sens.Tt._2.AI_Output.Status;
	PG01_Local.PGSens.Tt02.Alarm := PG.Sens.Tt._2.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt03.Value := PG.Sens.Tt._3.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt03.Valid := PG.Sens.Tt._3.AI_Output.Status;
	PG01_Local.PGSens.Tt03.Alarm := PG.Sens.Tt._3.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt04.Value := PG.Sens.Tt._4.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt04.Valid := PG.Sens.Tt._4.AI_Output.Status;
	PG01_Local.PGSens.Tt04.Alarm := PG.Sens.Tt._4.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt05.Value := PG.Sens.Tt._5.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt05.Valid := PG.Sens.Tt._5.AI_Output.Status;
	PG01_Local.PGSens.Tt05.Alarm := PG.Sens.Tt._5.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt06.Value := PG.Sens.Tt._6.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt06.Valid := PG.Sens.Tt._6.AI_Output.Status;
	PG01_Local.PGSens.Tt06.Alarm := PG.Sens.Tt._6.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt07.Value := PG.Sens.Tt._7.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt07.Valid := PG.Sens.Tt._7.AI_Output.Status;
	PG01_Local.PGSens.Tt07.Alarm := PG.Sens.Tt._7.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt08.Value := PG.Sens.Tt._8.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt08.Valid := PG.Sens.Tt._8.AI_Output.Status;
	PG01_Local.PGSens.Tt08.Alarm := PG.Sens.Tt._8.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt09.Value := PG.Sens.Tt._9.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt09.Valid := PG.Sens.Tt._9.AI_Output.Status;
	PG01_Local.PGSens.Tt09.Alarm := PG.Sens.Tt._9.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt10.Value := PG.Sens.Tt._10.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt10.Valid := PG.Sens.Tt._10.AI_Output.Status;
	PG01_Local.PGSens.Tt10.Alarm := PG.Sens.Tt._10.AI_Output.FaultLatched;
	PG01_Local.PGSens.Tt11.Value := PG.Sens.Tt._11.AI_Output.ScaledValue;
	PG01_Local.PGSens.Tt11.Valid := PG.Sens.Tt._11.AI_Output.Status;
	PG01_Local.PGSens.Tt11.Alarm := PG.Sens.Tt._11.AI_Output.FaultLatched;
	(* 2.10) MP01: vrednost, validnost i fault merenja nivoa/pritiska. *)
	PG01_Local.PGSens.MP01.Value := PG.Sens.MP._1.AI_Output.ScaledValue;
	PG01_Local.PGSens.MP01.Valid := PG.Sens.MP._1.AI_Output.Status;
	PG01_Local.PGSens.MP01.Alarm := PG.Sens.MP._1.AI_Output.FaultLatched;

	(* 2.11) Digitalni nivo prekidaci i prestrujni ventili: vrednost i alarm. *)
	PG01_Local.PGSens.LS01.Value := PG.Sens.LS._1.DI_Output.Value;
	PG01_Local.PGSens.LS01.Alarm := PG.Sens.LS._1.DI_Output.Alarm;
	PG01_Local.PGSens.LS02.Value := PG.Sens.LS._2.DI_Output.Value;
	PG01_Local.PGSens.LS02.Alarm := PG.Sens.LS._2.DI_Output.Alarm;
	PG01_Local.PGSens.LS03.Value := PG.Sens.LS._3.DI_Output.Value;
	PG01_Local.PGSens.LS03.Alarm := PG.Sens.LS._3.DI_Output.Alarm;
	PG01_Local.PGSens.LS04.Value := PG.Sens.LS._4.DI_Output.Value;
	PG01_Local.PGSens.LS04.Alarm := PG.Sens.LS._4.DI_Output.Alarm;
	PG01_Local.PGSens.LS05.Value := PG.Sens.LS._5.DI_Output.Value;
	PG01_Local.PGSens.LS05.Alarm := PG.Sens.LS._5.DI_Output.Alarm;
	PG01_Local.PGSens.OWF01.Value := PG.Sens.OWF._1.DI_Output.Value;
	PG01_Local.PGSens.OWF01.Alarm := PG.Sens.OWF._1.DI_Output.Alarm;
	PG01_Local.PGSens.OWF02.Value := PG.Sens.OWF._2.DI_Output.Value;
	PG01_Local.PGSens.OWF02.Alarm := PG.Sens.OWF._2.DI_Output.Alarm;
END_ACTION
