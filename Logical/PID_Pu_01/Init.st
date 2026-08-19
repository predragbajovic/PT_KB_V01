

PROGRAM _INIT
	(* ======================================================================== *)
	(* PID_Pu_01_INIT                                                            *)
	(* U ovom tasku trenutno nema inicijalizacionih dodela.                      *)
	(* PID parametri i ulazi/izlazi se postavljaju iz HMI/visih nivoa logike.   *)
	(* ======================================================================== *)
	 
	
	PID_Pu_01.MaxOut:= 70.0;
	PID_Pu_01.MinOut:= 20.0;
	
	PID_Pu_01.PIDParameters.DerivativeTime:= 0.0;
	PID_Pu_01.PIDParameters.FilterTime:= 45.0;
	PID_Pu_01.PIDParameters.Gain:= 96.3;
	PID_Pu_01.PIDParameters.IntegrationTime:= 180;
	PID_Pu_01.Invert:= TRUE;
	
	PID_Pu_01.SetValue:= 1.5;
	
	
	
	
END_PROGRAM