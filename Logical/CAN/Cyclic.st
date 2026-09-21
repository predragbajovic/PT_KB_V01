PROGRAM _CYCLIC
	(* -------------------------------------------------------------------------- *)
	(* 1) PG_Pu01 CANopen upravljanje                                              *)
	(* -------------------------------------------------------------------------- *)
	PG.Act.Pu._1.CAN_FB.b_Enable := PG.Act.Pu._1.Enable;
	PG.Act.Pu._1.CAN_FB.b_Start := PG.Act.Pu._1.Start;
	PG.Act.Pu._1.CAN_FB.b_AlarmRst := PG.Act.Pu._1.Reset_Alarm OR PT_Alarm.ResetPulse.Devices;
	PG.Act.Pu._1.CAN_FB.w_FR_min := PG.Act.Pu._1.FR_min;
	PG.Act.Pu._1.CAN_FB.w_FR_max := PG.Act.Pu._1.FR_max;
	PG.Act.Pu._1.CAN_FB.w_NomSnaga := PG.Act.Pu._1.Motor_Nominalna_Snaga;
	PG.Act.Pu._1.CAN_FB.w_ZadataBrzHz := PG.Act.Pu._1.FR_set;
	PG.Act.Pu._1.CAN_FB();
	PG.Act.Pu._1.Status_inRun := PG.Act.Pu._1.CAN_FB.b_Running;
	PG.Act.Pu._1.Alarm_FR := PG.Act.Pu._1.CAN_FB.b_Alarm_FR;
	PG.Act.Pu._1.Alarm_CAN := PG.Act.Pu._1.CAN_FB.b_Alarm_CAN;
	PG.Act.Pu._1.Ostvarena_brzina := PG.Act.Pu._1.CAN_FB.w_MotorBrz;
	PG.Act.Pu._1.Motor_Snaga := PG.Act.Pu._1.CAN_FB.w_MotorSnaga;
	PG.Act.Pu._1.Motor_Struja := PG.Act.Pu._1.CAN_FB.w_MotorStruja;

	(* -------------------------------------------------------------------------- *)
	(* 2) PG_Pu02 CANopen upravljanje                                              *)
	(* -------------------------------------------------------------------------- *)
	PG.Act.Pu._2.CAN_FB.b_Enable := PG.Act.Pu._2.Enable;
	PG.Act.Pu._2.CAN_FB.b_Start := PG.Act.Pu._2.Start;
	PG.Act.Pu._2.CAN_FB.b_AlarmRst := PG.Act.Pu._2.Reset_Alarm OR PT_Alarm.ResetPulse.Devices;
	PG.Act.Pu._2.CAN_FB.w_FR_min := PG.Act.Pu._2.FR_min;
	PG.Act.Pu._2.CAN_FB.w_FR_max := PG.Act.Pu._2.FR_max;
	PG.Act.Pu._2.CAN_FB.w_NomSnaga := PG.Act.Pu._2.Motor_Nominalna_Snaga;
	PG.Act.Pu._2.CAN_FB.w_ZadataBrzHz := PG.Act.Pu._2.FR_set;
	PG.Act.Pu._2.CAN_FB();
	PG.Act.Pu._2.Status_inRun := PG.Act.Pu._2.CAN_FB.b_Running;
	PG.Act.Pu._2.Alarm_FR := PG.Act.Pu._2.CAN_FB.b_Alarm_FR;
	PG.Act.Pu._2.Alarm_CAN := PG.Act.Pu._2.CAN_FB.b_Alarm_CAN;
	PG.Act.Pu._2.Ostvarena_brzina := PG.Act.Pu._2.CAN_FB.w_MotorBrz;
	PG.Act.Pu._2.Motor_Snaga := PG.Act.Pu._2.CAN_FB.w_MotorSnaga;
	PG.Act.Pu._2.Motor_Struja := PG.Act.Pu._2.CAN_FB.w_MotorStruja;
END_PROGRAM