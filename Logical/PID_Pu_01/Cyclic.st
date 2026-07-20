
PROGRAM _CYCLIC
	
	
	
	
	PID_Pu_01.Enable;
	PID_Pu_01.SetValue;
	PID_Pu_01.MaxOut;
	PID_Pu_01.MinOut;
	PID_Pu_01.ActValue := NivoPRihvatniSud ;
	
	PID_Pu_01.PIDParameters.Gain;
	PID_Pu_01.PIDParameters.FilterTime;
	PID_Pu_01.PIDParameters.IntegrationTime;
	PID_Pu_01.PIDParameters.DerivativeTime;
	
	IF startPIDPu1 THEN
		PG.Act.Pu._1.params.Freq := PID_Pu_01.Out;
	END_IF
	
	PID_Pu_01();
	
END_PROGRAM
