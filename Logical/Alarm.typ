TYPE
	typAlarmState : STRUCT (* Standardno stanje jednog projektnog alarma. *)
		Active : BOOL; (* TRUE dok je fizicki ili programski uzrok trenutno prisutan. *)
		Latched : BOOL; (* TRUE od prve pojave alarma do dozvoljenog reseta. *)
		Acknowledged : BOOL; (* TRUE nakon operatorske potvrde memorisanog alarma. *)
		ResetAllowed : BOOL; (* TRUE kada aktivni uzrok vise nije prisutan. *)
		Blocking : BOOL; (* TRUE kada alarm blokira novi start ili zahteva kontrolisani stop. *)
		Code : UINT; (* Stabilan projektni alarmni kod. *)
		SourceCode : USINT; (* Lokalni FaultCode izvornog FB-a, kada postoji. *)
		Severity : USINT; (* Prioritet: 1=INFO, 2=WARNING, 3=ALARM, 4=TRIP. *)
	END_STRUCT;

	typAlarmCommand : STRUCT (* Jednociklusne komande projektnog alarmnog sistema. *)
		AcknowledgeAll : BOOL; (* Potvrda svih trenutno memorisanih alarma bez reseta opreme. *)
		ResetAlarmRecords : BOOL; (* Brisanje dozvoljenih alarmnih zapisa bez reseta opreme. *)
		ResetDevices : BOOL; (* Jednociklusni reset uredjajskih FB-ova; ne pokrece proces. *)
		ResetProcess : BOOL; (* Reset procesnog fault-a iz definisanog bezbednog stanja. *)
	END_STRUCT;

	typAlarmResetPulse : STRUCT (* Interni impulsi dostupni vlasnicima tokom celog PLC ciklusa. *)
		Devices : BOOL; (* Reset uredjaja koji ne menja procesno stanje. *)
		Process : BOOL; (* Reset procesnog fault-a koji ne pokrece sekvencu. *)
	END_STRUCT;

	typAlarmSummary : STRUCT (* Zbirni status projektnog alarmnog sistema. *)
		AnyActive : BOOL; (* Najmanje jedan alarmni uzrok je trenutno aktivan. *)
		AnyLatched : BOOL; (* Najmanje jedan alarm je memorisan. *)
		AnyUnacknowledged : BOOL; (* Najmanje jedan memorisan alarm nije potvrden. *)
		AnyTrip : BOOL; (* Najmanje jedan aktivan ili memorisan TRIP alarm postoji. *)
		RestartBlocked : BOOL; (* Novi procesni start nije dozvoljen. *)
		HighestSeverity : USINT; (* Najvisi prioritet aktivnog ili memorisanog alarma. *)
		FirstOutCode : UINT; (* Kod prvog memorisanog alarma do potpunog reseta. *)
		ActiveCount : UINT; (* Broj trenutno aktivnih alarmnih uzroka. *)
		LatchedCount : UINT; (* Broj memorisanih alarma. *)
	END_STRUCT;

	typPTAlarmComm : STRUCT (* Alarmi komunikacije Podstanice sa udaljenim PLC-ovima. *)
		BRB2 : typAlarmState; (* Gubitak validne komunikacije sa BRB2. *)
		IEBKB1 : typAlarmState; (* Gubitak komunikacije ili heartbeat-a sa IEBKB1. *)
		BRB2RemoteFault : typAlarmState; (* Udaljeni BRB2 prijavljuje aktivan fault. *)
	END_STRUCT;

	typPTAlarmDrive : STRUCT (* Alarmi izlaznih pumpi Podstanice. *)
		PG_Pu01_VFD : typAlarmState; (* Fault frekventnog regulatora pumpe PG_Pu01. *)
		PG_Pu01_CAN : typAlarmState; (* Fault CAN komunikacije pumpe PG_Pu01. *)
		PG_Pu02_VFD : typAlarmState; (* Fault frekventnog regulatora pumpe PG_Pu02. *)
		PG_Pu02_CAN : typAlarmState; (* Fault CAN komunikacije pumpe PG_Pu02. *)
	END_STRUCT;

	typPTAlarmProcess : STRUCT (* Postojeci procesni fault kodovi Podstanice. *)
		ValveRequestConflict : typAlarmState; (* Kod 10: PG_V01 i PG_V02 istovremeno zahtevani. *)
		V01CloseTimeout : typAlarmState; (* Kod 11: PG_V01 nije zatvoren u roku. *)
		V02OpenTimeout : typAlarmState; (* Kod 12: PG_V02 nije otvoren u roku. *)
		V02CloseTimeout : typAlarmState; (* Kod 13: PG_V02 nije zatvoren u roku. *)
		V01OpenTimeout : typAlarmState; (* Kod 14: PG_V01 nije otvoren u roku. *)
		V01CloseIEBStopTimeout : typAlarmState; (* Kod 15: PG_V01 nije zatvoren pri stopu IEBKB1. *)
		IEBFlowStopTimeout : typAlarmState; (* Kod 16: IEBKB1 protok nije zaustavljen u roku. *)
		V05CloseTimeout : typAlarmState; (* Kod 17: PG_V05 nije zatvoren u roku. *)
		IEBFlowStartTimeout : typAlarmState; (* Kod 18: IEBKB1 dotok nije poceo u roku. *)
		BRB2FlowNotConfirmed : typAlarmState; (* Kod 21: BRB2 pripremni protok nije potvrden. *)
		BRB2TemperatureNotReached : typAlarmState; (* Kod 22: BRB2 pripremna temperatura nije dostignuta. *)
		PT06HighPressure : typAlarmState; (* Kod 23: PT06 pritisak je previsok tokom pripreme. *)
		TransferIEBFlowNotZero : typAlarmState; (* Kod 31: IEBKB1 protok nije pao na nulu pri transferu. *)
		TransferV05CloseTimeout : typAlarmState; (* Kod 32: PG_V05 nije zatvoren pri transferu. *)
		TransferV01CloseTimeout : typAlarmState; (* Kod 33: PG_V01 nije zatvoren pri transferu. *)
		TransferV02OpenTimeout : typAlarmState; (* Kod 34: PG_V02 nije otvoren pri transferu. *)
		TransferBRB2FlowNotConfirmed : typAlarmState; (* Kod 35: BRB2 protok nije potvrden pri transferu. *)
	END_STRUCT;

	typPTAlarmAirRelease : STRUCT (* Alarmi funkcije odzracivanja Podstanice. *)
		PG_PV03 : typAlarmState; (* Alarm odzracivanja na ulazu u Podstanicu. *)
		PG_PV04 : typAlarmState; (* Alarm odzracivanja na ulazu u prihvatni tank. *)
	END_STRUCT;

	typPTAlarm : STRUCT (* Korenski alarmni objekat PT_KB_V01 projekta. *)
		Cmd : typAlarmCommand; (* Operatorske alarmne komande. *)
		ResetPulse : typAlarmResetPulse; (* Interni reset impulsi za vlasnicke programe. *)
		Summary : typAlarmSummary; (* Zbirni status za proces i HMI. *)
		Comm : typPTAlarmComm; (* Komunikacioni alarmi. *)
		Drive : typPTAlarmDrive; (* Alarmi pogona. *)
		Process : typPTAlarmProcess; (* Procesni i sekvencni alarmi. *)
		AirRelease : typPTAlarmAirRelease; (* Alarmi odzracivanja. *)
	END_STRUCT;
END_TYPE