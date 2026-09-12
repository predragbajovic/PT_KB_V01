
TYPE
	typPG01SynVentil : 	STRUCT 
		OpenCmd : BOOL; (* Lokalna komanda otvaranja. *)
		CloseCmd : BOOL; (* Lokalna komanda zatvaranja. *)
		Opened : BOOL; (* Povratni signal otvorenog polozaja. *)
		Closed : BOOL; (* Povratni signal zatvorenog polozaja. *)
		Alarm : BOOL; (* Dijagnosticki alarm ventila. *)
	END_STRUCT;
	typPG01SynPropVentil : 	STRUCT 
		Enable : BOOL; (* Dozvola automatske regulacije. *)
		CmdPercent : REAL; (* Zadata otvorenost [%]. *)
		PositionPercent : REAL; (* Ostvarena otvorenost [%]. *)
		Alarm : BOOL; (* Dijagnosticki alarm ventila. *)
	END_STRUCT;
	typPG01SynPumpa : 	STRUCT 
		RunCmd : BOOL; (* Lokalni zahtev rada. *)
		Running : BOOL; (* Stvarni status rada. *)
		Frequency : REAL; (* Frekventni zahtev/ostvarenje [Hz]. *)
		Alarm : BOOL; (* Dijagnosticki alarm pumpe. *)
	END_STRUCT;
	typPG01SynAnalog : 	STRUCT 
		Value : REAL; (* Skalirana merena vrednost. *)
		Valid : BOOL; (* Validnost signala. *)
		Alarm : BOOL; (* Dijagnosticki alarm signala. *)
	END_STRUCT;
	typPG01SynDigital : 	STRUCT 
		Value : BOOL; (* Digitalna merena vrednost. *)
		Alarm : BOOL; (* Dijagnosticki alarm signala. *)
	END_STRUCT;
	typPG01SynPGAct : 	STRUCT 
		Pu01 : typPG01SynPumpa;
		Pu02 : typPG01SynPumpa;
		PV01 : typPG01SynPropVentil;
		PV02 : typPG01SynPropVentil;
		PV03 : typPG01SynPropVentil;
		PV04 : typPG01SynPropVentil;
		PV05 : typPG01SynPropVentil;
		AV01 : typPG01SynVentil;
		AV02 : typPG01SynVentil;
		AV03 : typPG01SynVentil;
		AV04 : typPG01SynVentil;
		AV05 : typPG01SynVentil;
		AV06 : typPG01SynVentil;
		AV07 : typPG01SynVentil;
		RV19 : typPG01SynVentil;
		RV21 : typPG01SynVentil;
		RV22 : typPG01SynVentil;
		RV23 : typPG01SynVentil;
		RV24 : typPG01SynVentil;
		RV25 : typPG01SynVentil;
		RV26 : typPG01SynVentil;
		RV27 : typPG01SynVentil;
	END_STRUCT;
	typPG01SynPGSens : 	STRUCT 
		Pt00 : typPG01SynAnalog;
		Pt01 : typPG01SynAnalog;
		Pt02 : typPG01SynAnalog;
		Pt03 : typPG01SynAnalog;
		Pt04 : typPG01SynAnalog;
		Pt05 : typPG01SynAnalog;
		Pt06 : typPG01SynAnalog;
		PtNS1 : typPG01SynAnalog;
		PtNS2 : typPG01SynAnalog;
		Tt01 : typPG01SynAnalog;
		Tt02 : typPG01SynAnalog;
		Tt03 : typPG01SynAnalog;
		Tt04 : typPG01SynAnalog;
		Tt05 : typPG01SynAnalog;
		Tt06 : typPG01SynAnalog;
		Tt07 : typPG01SynAnalog;
		Tt08 : typPG01SynAnalog; (* TT_PG_08 - ulaz tehnicke vode u direktni izmenjivac. *)
		Tt09 : typPG01SynAnalog; (* TT_PG_09 - izlaz tehnicke vode iz direktnog izmenjivaca. *)
		Tt10 : typPG01SynAnalog; (* TT_PG_10 - ulaz sanitarne vode u direktni izmenjivac. *)
		Tt11 : typPG01SynAnalog; (* TT_PG_11 - izlaz sanitarne vode iz direktnog izmenjivaca. *)
		MP01 : typPG01SynAnalog;
		LS01 : typPG01SynDigital;
		LS02 : typPG01SynDigital;
		LS03 : typPG01SynDigital;
		LS04 : typPG01SynDigital;
		LS05 : typPG01SynDigital;
		OWF01 : typPG01SynDigital;
		OWF02 : typPG01SynDigital;
	END_STRUCT;
	typPG01SynPGCtrl : 	STRUCT 
		Izvor : USINT; (* E_SelektovaniIzvor kao numericka vrednost. *)
		Regulacija : USINT; (* E_RegulacionaVarijanta kao numericka vrednost. *)
		IzlaznaPumpa : USINT; (* E_AktivnaPumpaIzlazTanka kao numericka vrednost. *)
		UlazniPV : USINT; (* E_AktivniPropVentilUlazTanka kao numericka vrednost. *)
		AutoRestart : BOOL;
		State : USINT; (* E_PGRad_State kao numericka vrednost. *)
		Substep : USINT;
		Fault : BOOL;
		FaultCode : USINT;
	END_STRUCT;
	typPG01SynBRB2Act : 	STRUCT 
		RB101 : typPG01SynPumpa;
		RB201 : typPG01SynPumpa;
		RB202 : typPG01SynPumpa;
		RB211 : typPG01SynPumpa;
		AVRB1V01 : typPG01SynVentil;
		AVRB1V02 : typPG01SynVentil;
		AVRB2V01 : typPG01SynVentil;
		AVRB2V02 : typPG01SynVentil;
		AVRB2V20 : typPG01SynVentil;
		AVRB2V21 : typPG01SynVentil;
		RVRB1RV04 : typPG01SynVentil;
		RVRB1RV05 : typPG01SynVentil;
		RVRB2RV04 : typPG01SynVentil;
		RVRB2RV05 : typPG01SynVentil;
		RVRB2RV06 : typPG01SynVentil;
		RVRB2RV10 : typPG01SynVentil;
		RVRB2RV51 : typPG01SynVentil;
		PVRB1PV01 : typPG01SynPropVentil;
		PVRB2PV01 : typPG01SynPropVentil;
		PVRB2PV11 : typPG01SynPropVentil;
		PVRB2PV21 : typPG01SynPropVentil;
	END_STRUCT;
	typPG01SynBRB2Sens : 	STRUCT 
		PtAir : typPG01SynAnalog;
		PtColdWater : typPG01SynAnalog;
		PtRB10 : typPG01SynAnalog;
		PtRB11 : typPG01SynAnalog;
		PtRB20A : typPG01SynAnalog;
		PtRB20B : typPG01SynAnalog;
		PtRB21 : typPG01SynAnalog;
		PtRB22 : typPG01SynAnalog;
		PtRB211 : typPG01SynAnalog;
		PtRB212 : typPG01SynAnalog;
		PtRB213 : typPG01SynAnalog;
		TtRB11 : typPG01SynAnalog;
		TtRB21 : typPG01SynAnalog;
		TtRB22 : typPG01SynAnalog;
		TtRB211 : typPG01SynAnalog;
		TtPump : typPG01SynAnalog;
		FtRB11 : typPG01SynAnalog;
		FtRB21 : typPG01SynAnalog;
		FtRB211 : typPG01SynAnalog;
		KRB211 : typPG01SynAnalog;
		RHT01T : typPG01SynAnalog;
		RHT01RH : typPG01SynAnalog;
		RHT02T : typPG01SynAnalog;
		RHT02RH : typPG01SynAnalog;
		RHT03T : typPG01SynAnalog;
		RHT03RH : typPG01SynAnalog;
		LSRB11 : typPG01SynDigital;
		LSRB21 : typPG01SynDigital;
		OWFRB101 : typPG01SynDigital;
		OWFRB201 : typPG01SynDigital;
		OWFRB202 : typPG01SynDigital;
	END_STRUCT;
	typPG01SynBRB2Ctrl : 	STRUCT 
		Odrediste : USINT; (* E_OdredisteBRB2 kao numericka vrednost. *)
		Regulacija : USINT; (* E_RegulacionaVarijanta kao numericka vrednost. *)
		Ispiranje : BOOL;
		Aktivan : BOOL;
		StopFaza : USINT; (* E_FazaZaustavljanjaBRB2 kao numericka vrednost. *)
		PumpaPotvrdjena : BOOL;
		StopSPDostignut : BOOL;
		RB2V02Zatvoren : BOOL;
	END_STRUCT;
	typPG01Syn : 	STRUCT 
		PGAct : typPG01SynPGAct; (* PT Act snapshot za sinoptiku. *)
		PGSens : typPG01SynPGSens; (* PT Sens snapshot za sinoptiku. *)
		PGCtrl : typPG01SynPGCtrl; (* PT Ctrl i state snapshot. *)
		BRB2Act : typPG01SynBRB2Act; (* BRB2 Act snapshot za sinoptiku. *)
		BRB2Sens : typPG01SynBRB2Sens; (* BRB2 Sens snapshot za sinoptiku. *)
		BRB2Ctrl : typPG01SynBRB2Ctrl; (* BRB2 Ctrl i state snapshot. *)
	END_STRUCT;
END_TYPE
