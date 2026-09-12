

PROGRAM _INIT
	(* ======================================================================== *)
	(* PID_Pu_01_INIT                                                            *)
	(* U ovom tasku trenutno nema inicijalizacionih dodela.                      *)
	(* Retain procesni parametri se postavljaju iz HMI/visih nivoa logike.       *)
	(* ======================================================================== *)
	(* -------------------------------------------------------------------------- *)
	(* 1) Inicijalni parametri PID izlazne pumpe                                  *)
	(* -------------------------------------------------------------------------- *)
	(* Frekvencija izlazne pumpe je ogranicena na radni opseg 20.0..70.0 Hz. *)
	PID_Pu_01.MaxOut := 70.0; (* Gornja granica PID izlaza [Hz]. *)
	PID_Pu_01.MinOut := 20.0; (* Donja granica PID izlaza [Hz]. *)
	
	(* Parametri nivo regulacije; D deo je iskljucen, a filter prigusuje merenje. *)
	PID_Pu_01.PIDParameters.DerivativeTime := 0.0; (* D vreme [s]. *)
	PID_Pu_01.PIDParameters.FilterTime := 45.0; (* Filter merenja [s]. *)
	PID_Pu_01.PIDParameters.Gain := 96.3; (* Proporcionalno pojacanje. *)
	PID_Pu_01.PIDParameters.IntegrationTime := 180; (* Integraciono vreme [s]. *)
	PID_Pu_01.Invert := TRUE; (* Nivo regulacija koristi inverzni smer. *)
	
	PID_Pu_01.SetValue := 1.5; (* Lokalni pocetni setpoint nivoa [m]. *)
	
	
	
	
END_PROGRAM