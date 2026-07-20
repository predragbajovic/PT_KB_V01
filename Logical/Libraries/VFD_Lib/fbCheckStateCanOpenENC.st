(* Dekodiranje CANopen ENC status reci u standardni state kod. *)
FUNCTION_BLOCK fbCheckStateCanOpenENC
	(* ---------------------------------------------------------------------- *)
	(* Referentna mapa bitova status reci (ENC):                               *)
	(* b0=bus voltage, b1=run effective, b2=jog effective, b3=running,         *)
	(* b4=aktuelni smer reverse, b5=zadati smer reverse,                        *)
	(* b6=deceleration braking, b7=acceleration, b8=deceleration,              *)
	(* b9=alarm, b10=fault, b11=current limit, b12=fault self recovery,        *)
	(* b13=self tuning, b14=free stop, b15=speed tracking start.               *)
	(* ---------------------------------------------------------------------- *)
	
	(* ---------------------------------------------------------------------- *)
	(* 1) Povezivanje status reci preko adrese                               *)
	(* ---------------------------------------------------------------------- *)
	ref_statusWord ACCESS in_addr_StatusWord;
	
	(* ---------------------------------------------------------------------- *)
	(* 2) Prioritetna dekodiranja stanja (alarm/fault/tuning/operacija)      *)
	(* ---------------------------------------------------------------------- *)
	IF (ref_statusWord.9 = 1) THEN
		out_State := ST_ALARM; (* Alarm bit aktivan. *)
	ELSIF (ref_statusWord.10 = 1) OR (ref_statusWord.12 = 1) THEN
		out_State := ST_FAULT; (* Fault ili self-recovery fault signal. *)
	ELSIF (ref_statusWord.13 = 1) THEN
		out_State := ST_TUNING; (* Samopodesavanje aktivno. *)
	ELSIF (ref_statusWord.0 = 0) THEN
		out_State := ST_PWR_OFF; (* Nema bus napona. *)
	ELSIF (ref_statusWord = 1) THEN
		out_State := ST_READY; (* Osnovno ready stanje. *)
	ELSIF (ref_statusWord.14 = 1) OR (ref_statusWord.6 = 1) OR (ref_statusWord.8 = 1) THEN
		out_State := ST_STOPPING; (* Free stop/deceleration uslovi. *)
	ELSIF (ref_statusWord.7 = 1) THEN
		out_State := ST_PREOPERATIONAL; (* Ubrzavanje/tranzicija pre stabilnog rada. *)
	ELSIF (ref_statusWord.2 = 1) THEN
		out_State := ST_JOG; (* Jog komanda efektivna. *)
	ELSIF (ref_statusWord.3 = 1) AND (ref_statusWord.1 = 1) THEN
		out_State := ST_RUN; (* Kontinualni rad potvrden. *)
	END_IF;
	
END_FUNCTION_BLOCK
