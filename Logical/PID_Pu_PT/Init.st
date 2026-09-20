

PROGRAM _INIT
	(* ======================================================================== *)
	(* PID_Pu_PT_INIT                                                             *)
	(* PID petlja pumpi na izlazu iz prihvatnog tanka.                            *)
	(* Procesni rezim kasnije prosledjuje aktivne PV/SP, smer i izlazne granice. *)
	(* ======================================================================== *)
	(* -------------------------------------------------------------------------- *)
	(* 1) Inicijalni parametri PID izlazne pumpe                                  *)
	(* -------------------------------------------------------------------------- *)
	(* Granice PID izlaza preuzimaju se iz centralnih parametara pumpi. *)
	PID_Pu_PT.MaxOut := PGRad.Par.MaxFR_Pumpe; (* Gornja granica iz MaxFR_Pumpe [Hz]. *)
	PID_Pu_PT.MinOut := PGRad.Par.MinFR_Pumpe; (* Donja granica iz MinFR_Pumpe [Hz]. *)
	
	(* Parametri nivo regulacije; D clan je iskljucen. *)
	(* FilterTime filtrira D clan i nema uticaja dok je DerivativeTime = 0.0. *)
	PID_Pu_PT.PIDParameters.DerivativeTime := 0.0; (* D vreme [s]. *)
	PID_Pu_PT.PIDParameters.FilterTime := 10.0; (* Vremenska konstanta filtera D clana [s]. *)
	PID_Pu_PT.PIDParameters.Gain := 96.3; (* Proporcionalno pojacanje. *)
	PID_Pu_PT.PIDParameters.IntegrationTime := 180; (* Integraciono vreme [s]. *)
	PID_Pu_PT.Invert := TRUE; (* Nivo regulacija koristi inverzni smer. *)
	
	PID_Pu_PT.SetValue := 1.5; (* Lokalni pocetni setpoint nivoa [m]. *)
	
	
	
	
END_PROGRAM