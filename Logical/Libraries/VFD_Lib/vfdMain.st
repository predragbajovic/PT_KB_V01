(* Glavni VFD orchestrator: kontrola, monitoring i dijagnostika po metodi rada. *)
FUNCTION_BLOCK vfdMain
	
	(* ---------------------------------------------------------------------- *)
	(* 1) Pristup centralnoj VFD strukturi preko prosledjene adrese            *)
	(* ---------------------------------------------------------------------- *)
	vfd_struct_data ACCESS addr_struct;
	
	
	(* ---------------------------------------------------------------------- *)
	(* 2) METOD_ENC_CANOPEN                                                     *)
	(* ---------------------------------------------------------------------- *)
	IF vfd_struct_data.settings.METOD_OF_CONTROL = METOD_ENC_CANOPEN THEN
		
		vfd_struct_data.status.act_power := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_power)/10.0;
		vfd_struct_data.status.act_current := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_current)/100.0;
		vfd_struct_data.status.act_torque := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_torque);
		vfd_struct_data.status.act_freq := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_freq)/100.0;
		vfd_struct_data.status.act_voltage := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_voltage);
		vfd_struct_data.status.act_velocity := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_velocity);
		
		IF vfd_struct_data.params.Freq > 100.0 THEN
			vfd_struct_data.params.Freq := 100.0;
		END_IF
		
		(* Skaliranje procentualnog zahteva frekvencije u raw CANopen opseg. *)
		vfd_struct_data.mapping.CanOpen.w_freq := REAL_TO_UINT((((vfd_struct_data.settings.MAX_Freq - vfd_struct_data.settings.MIN_Freq)/100.0)*vfd_struct_data.params.Freq - vfd_struct_data.settings.MIN_Freq)*100.0);
		vfd_struct_data.mapping.CanOpen.w_acc := REAL_TO_UINT(vfd_struct_data.params.Acc*10.0);
		vfd_struct_data.mapping.CanOpen.w_dec := REAL_TO_UINT(vfd_struct_data.params.Dec*10.0);
	
		fControlENC.cmd := vfd_struct_data.cmds;
		fControlENC.in_addr_CtrlWord := ADR(vfd_struct_data.mapping.CanOpen.CtrlWord);
		fControlENC.in_addr_StatusWord := ADR(vfd_struct_data.mapping.CanOpen.StatusWord);
		fControlENC.in_addr_r_CtrlWord := ADR(vfd_struct_data.mapping.CanOpen.r_CtrlWord);
		fControlENC();
	
		fStateENC.in_addr_StatusWord := ADR(vfd_struct_data.mapping.CanOpen.StatusWord);
		fStateENC();
		vfd_struct_data.states.state_word := fStateENC.out_State;
	
		IF NOT(vfd_struct_data.cmds.Enable) THEN
			state_case := ST_PWR_OFF;
		ELSE	
			state_case := vfd_struct_data.states.state_word;
		END_IF;
		
		IF (vfd_struct_data.settings.HaveOverCurrentProtection) AND NOT(vfd_struct_data.mapping.CanOpenATV.r_OverCurrentProtect) THEN
			state_case := ST_CURRPROTECT;
			vfd_struct_data.states.OVERCURRENT_PROTECT := TRUE;
		ELSE
			vfd_struct_data.states.OVERCURRENT_PROTECT := FALSE;
		END_IF;
	
		Done := fControlENC.out_DONE;
		Busy := fControlENC.out_BUSY;
		errorID := vfd_struct_data.mapping.CanOpen.r_errorCode;
		
		(* Mapiranje internog state_case u bool state izlaze za HMI/SCADA. *)
		CASE state_case OF
			ST_PWR_OFF:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_READY:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := TRUE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_PREOPERATIONAL:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := TRUE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_RUN:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := TRUE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_STOPPING:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := TRUE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_STOPPED:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := TRUE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_FAULT:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := TRUE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_ALARM:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := TRUE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_TUNING:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := TRUE;
				vfd_struct_data.states.JOG := FALSE;
			ST_JOG:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := TRUE;
			ST_CURRPROTECT:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
				vfd_struct_data.states.OVERCURRENT_PROTECT := TRUE;
			ELSE
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
		END_CASE;
		
	END_IF;
	
	(* ---------------------------------------------------------------------- *)
	(* 3) METOD_DIO                                                             *)
	(* ---------------------------------------------------------------------- *)
	IF vfd_struct_data.settings.METOD_OF_CONTROL = METOD_DIO THEN
		
		IF vfd_struct_data.cmds.Enable THEN
			
			(* Legacy ekvivalent skale: REAL_TO_INT((Freq)*32767.0/100.0). *)
			IF vfd_struct_data.params.Freq > 100.0 THEN
				vfd_struct_data.params.Freq := 100.0;
			END_IF
			
			vfd_struct_data.mapping.DIO.w_freq := REAL_TO_INT((32767.0/100.0)*vfd_struct_data.params.Freq);
			vfd_struct_data.mapping.DIO.w_run_fwd := vfd_struct_data.cmds.Run_fwd;
			vfd_struct_data.mapping.DIO.w_run_rev := vfd_struct_data.cmds.Run_rev;
			vfd_struct_data.mapping.DIO.w_jog_fwd := vfd_struct_data.cmds.Jog_fwd;
			vfd_struct_data.mapping.DIO.w_jog_rev := vfd_struct_data.cmds.Jog_rev;
			vfd_struct_data.mapping.DIO.w_Stop := vfd_struct_data.cmds.Stop;
			vfd_struct_data.mapping.DIO.w_faststop := vfd_struct_data.cmds.FastStop;
			
			vfd_struct_data.status.act_freq := (((vfd_struct_data.settings.MAX_Freq - vfd_struct_data.settings.MIN_Freq)/32767.0)*vfd_struct_data.mapping.DIO.r_freq - vfd_struct_data.settings.MIN_Freq)*100.0;
			
			(* Legacy ekvivalent citanja: REAL_TO_UINT((r_freq)*100.0/32767.0). *)
			state_case := ST_READY;
		ELSE
			vfd_struct_data.mapping.DIO.w_freq := 0;
			vfd_struct_data.mapping.DIO.w_run_fwd := FALSE;
			vfd_struct_data.mapping.DIO.w_run_rev := FALSE;
			vfd_struct_data.mapping.DIO.w_jog_fwd := FALSE;
			vfd_struct_data.mapping.DIO.w_jog_rev := FALSE;
			vfd_struct_data.mapping.DIO.w_Stop := FALSE;
			vfd_struct_data.mapping.DIO.w_faststop := FALSE;
			state_case := ST_PWR_OFF;
		END_IF
			
			vfd_struct_data.mapping.DIO.w_reset := vfd_struct_data.cmds.Reset;
		   IF NOT (vfd_struct_data.mapping.DIO.r_error) THEN
			   state_case := ST_FAULT;
		   END_IF
		
		IF (vfd_struct_data.settings.HaveOverCurrentProtection) AND NOT(vfd_struct_data.mapping.CanOpenATV.r_OverCurrentProtect) THEN
			state_case := ST_CURRPROTECT;
			vfd_struct_data.states.OVERCURRENT_PROTECT := TRUE;
		ELSE
			vfd_struct_data.states.OVERCURRENT_PROTECT := FALSE;
		END_IF;
		
		(* U DIO metodi koristi se isti izlazni model states.*) 
		CASE state_case OF
			ST_PWR_OFF:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_READY:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := TRUE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_PREOPERATIONAL:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := TRUE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_RUN:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := TRUE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_STOPPING:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := TRUE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_STOPPED:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := TRUE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_FAULT:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := TRUE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_ALARM:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := TRUE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_TUNING:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := TRUE;
				vfd_struct_data.states.JOG := FALSE;
			ST_JOG:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := TRUE;
			ST_CURRPROTECT:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
				vfd_struct_data.states.OVERCURRENT_PROTECT := TRUE;
			ELSE
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
		END_CASE;
		
	END_IF;
	
	(* ---------------------------------------------------------------------- *)
	(* 4) METOD_DIO_CANOPEN                                                     *)
	(* ---------------------------------------------------------------------- *)
	IF vfd_struct_data.settings.METOD_OF_CONTROL = METOD_DIO_CANOPEN THEN
		
		IF vfd_struct_data.cmds.Enable THEN
			
			IF vfd_struct_data.params.Freq > 100.0 THEN
				vfd_struct_data.params.Freq := 100.0;
			END_IF
			
			vfd_struct_data.mapping.DIO.w_freq := REAL_TO_INT((32767.0/100.0)*vfd_struct_data.params.Freq);
			
			(* Legacy alternativa skale (ne koristi se u aktivnoj logici). *)
			vfd_struct_data.mapping.DIO.w_run_fwd := vfd_struct_data.cmds.Run_fwd;
			vfd_struct_data.mapping.DIO.w_run_rev := vfd_struct_data.cmds.Run_rev;
			vfd_struct_data.mapping.DIO.w_jog_fwd := vfd_struct_data.cmds.Jog_fwd;
			vfd_struct_data.mapping.DIO.w_jog_rev := vfd_struct_data.cmds.Jog_rev;
			vfd_struct_data.mapping.DIO.w_Stop := vfd_struct_data.cmds.Stop;
			vfd_struct_data.mapping.DIO.w_faststop := vfd_struct_data.cmds.FastStop;
			(* Legacy ekvivalent citanja: REAL_TO_UINT((r_freq)*100.0/32767.0). *)
		ELSE
			vfd_struct_data.mapping.DIO.w_freq := 0;
			vfd_struct_data.mapping.DIO.w_run_fwd := FALSE;
			vfd_struct_data.mapping.DIO.w_run_rev := FALSE;
			vfd_struct_data.mapping.DIO.w_jog_fwd := FALSE;
			vfd_struct_data.mapping.DIO.w_jog_rev := FALSE;
			vfd_struct_data.mapping.DIO.w_Stop := FALSE;
			vfd_struct_data.mapping.DIO.w_faststop := FALSE;
			
		END_IF
		
		vfd_struct_data.mapping.DIO.w_reset := vfd_struct_data.cmds.Reset;
	
		vfd_struct_data.status.act_power := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_power)/10.0;
		vfd_struct_data.status.act_current := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_current)/100.0;
		vfd_struct_data.status.act_torque := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_torque);
		vfd_struct_data.status.act_freq := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_freq)/100.0;
		vfd_struct_data.status.act_voltage := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_voltage);
		vfd_struct_data.status.act_velocity := UINT_TO_REAL(vfd_struct_data.mapping.CanOpen.r_velocity);
		
		vfd_struct_data.mapping.CanOpen.w_acc := REAL_TO_UINT(vfd_struct_data.params.Acc*10.0);
		vfd_struct_data.mapping.CanOpen.w_dec := REAL_TO_UINT(vfd_struct_data.params.Dec*10.0);
	
		fStateENC.in_addr_StatusWord := ADR(vfd_struct_data.mapping.CanOpen.StatusWord);
		fStateENC();
		vfd_struct_data.states.state_word := fStateENC.out_State;
	
		IF NOT(vfd_struct_data.cmds.Enable) THEN
			state_case := ST_PWR_OFF;
		ELSE	
			state_case := vfd_struct_data.states.state_word;
		END_IF;
		
		IF (vfd_struct_data.settings.HaveOverCurrentProtection) AND NOT(vfd_struct_data.mapping.CanOpenATV.r_OverCurrentProtect) THEN
			state_case := ST_CURRPROTECT;
			vfd_struct_data.states.OVERCURRENT_PROTECT := TRUE;
		ELSE
			vfd_struct_data.states.OVERCURRENT_PROTECT := FALSE;
		END_IF;
	
		(* U kombinovanoj metodi Done/Busy se ne preuzimaju iz ENC control FB-a. *)
		errorID := vfd_struct_data.mapping.CanOpen.r_errorCode;
		
		(* Kombinovana metoda: komande kroz DIO, status kroz CANopen. *)
		CASE state_case OF
			ST_PWR_OFF:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_READY:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := TRUE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_PREOPERATIONAL:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := TRUE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_RUN:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := TRUE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_STOPPING:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := TRUE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_STOPPED:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := TRUE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_FAULT:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := TRUE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_ALARM:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := TRUE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			ST_TUNING:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := TRUE;
				vfd_struct_data.states.JOG := FALSE;
			ST_JOG:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := TRUE;
			ST_CURRPROTECT:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
				vfd_struct_data.states.OVERCURRENT_PROTECT := TRUE;
			ELSE
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
		END_CASE;
		
	END_IF;
	
	(* ---------------------------------------------------------------------- *)
	(* 5) METOD_ATV_CANOPEN                                                     *)
	(* ---------------------------------------------------------------------- *)
	IF vfd_struct_data.settings.METOD_OF_CONTROL = METOD_ATV_CANOPEN THEN
			
		vfd_struct_data.status.act_power := INT_TO_REAL(vfd_struct_data.mapping.CanOpenATV.r_power)*vfd_struct_data.settings.RatedMotorPower/100.0;
		vfd_struct_data.status.act_current := UINT_TO_REAL(vfd_struct_data.mapping.CanOpenATV.r_current)/10.0;
		vfd_struct_data.status.act_torque := INT_TO_REAL(vfd_struct_data.mapping.CanOpenATV.r_torque);
		vfd_struct_data.status.act_freq := INT_TO_REAL(vfd_struct_data.mapping.CanOpenATV.r_freq)/100.0;
		vfd_struct_data.status.act_voltage := UINT_TO_REAL(vfd_struct_data.mapping.CanOpenATV.r_voltage);
		vfd_struct_data.status.act_velocity := INT_TO_REAL(vfd_struct_data.mapping.CanOpenATV.ControlEffort);
		
		vfd_struct_data.mapping.CanOpenATV.w_acc := REAL_TO_UINT(vfd_struct_data.params.Acc*10.0);
		vfd_struct_data.mapping.CanOpenATV.w_dec := REAL_TO_UINT(vfd_struct_data.params.Dec*10.0);
		
		fStateATV.in_addr_StatusWord := ADR(vfd_struct_data.mapping.CanOpenATV.StatusWord);
		fStateATV();
		vfd_struct_data.states.state_word := fStateATV.out_State;
		
		fControlATV.cmd := vfd_struct_data.cmds;
		fControlATV.in_addr_CtrlWord := ADR(vfd_struct_data.mapping.CanOpenATV.CtrlWord);
		fControlATV.DC_BUS_STATE := fStateATV.DC_BUS_ON;
		fControlATV.StatusWord := fStateATV.out_State;
		
		IF vfd_struct_data.params.Freq > 100.0 THEN
			vfd_struct_data.params.Freq := 100.0;
		END_IF
		
		(* Konverzija procentualnog SP u ATV velocity zahtev. *)
		fControlATV.in_set_freq := REAL_TO_INT(vfd_struct_data.params.Freq*(vfd_struct_data.settings.MAX_Velocity)/100.0);
		
		fControlATV();
		vfd_struct_data.mapping.CanOpenATV.w_TargetVelocity := fControlATV.set_freq;
		
		
		IF NOT(vfd_struct_data.cmds.Enable) THEN
			state_case := STATV_PWR_OFF;
		ELSE
			state_case := vfd_struct_data.states.state_word;
		END_IF;
		
		IF (vfd_struct_data.settings.HaveOverCurrentProtection) AND NOT(vfd_struct_data.mapping.CanOpenATV.r_OverCurrentProtect) THEN
			state_case := STATV_OVR_CURR;
			vfd_struct_data.states.OVERCURRENT_PROTECT := TRUE;
		ELSE
			vfd_struct_data.states.OVERCURRENT_PROTECT := FALSE;
		END_IF;
		
		Done := fControlATV.out_DONE;
		Busy := fControlATV.out_BUSY;
		errorID := vfd_struct_data.mapping.CanOpen.r_errorCode;
		
		(* ATV-specific state kodovi se mapiraju na zajednicke states bool izlaze. *)
		CASE state_case OF
			STATV_PWR_OFF:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			STATV_RDY:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := TRUE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			STATV_SWH_ON:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := TRUE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			STATV_RUN:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := TRUE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			STATV_SWH_DISABLE:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := TRUE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			STATV_FAST_STOP:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := TRUE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			STATV_ERR:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := TRUE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			STATV_ERR_MNG:
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := TRUE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
			STATV_OVR_CURR:
				vfd_struct_data.states.PWR_ON := FALSE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := TRUE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
				vfd_struct_data.states.OVERCURRENT_PROTECT := TRUE;
			ELSE
				vfd_struct_data.states.PWR_ON := TRUE;
				vfd_struct_data.states.READY := FALSE;
				vfd_struct_data.states.PREOPERATIONAL := FALSE;
				vfd_struct_data.states.RUN := FALSE;
				vfd_struct_data.states.STOPPING := FALSE;
				vfd_struct_data.states.STOPED := FALSE;
				vfd_struct_data.states.FAULT := FALSE;
				vfd_struct_data.states.ALARM := FALSE;
				vfd_struct_data.states.TUNING := FALSE;
				vfd_struct_data.states.JOG := FALSE;
		END_CASE;
		
	END_IF;
	
	(* ATV modul status se prepisuje u zajednicki ModuleStatusOK kanal. *)
	IF vfd_struct_data.settings.METOD_OF_CONTROL = METOD_ATV_CANOPEN THEN
		vfd_struct_data.mapping.CanOpen.ModuleStatusOK := vfd_struct_data.mapping.CanOpenATV.ModuleStatusOK;
	END_IF;
	
	(* ---------------------------------------------------------------------- *)
	(* 6) Error management komunikacije                                         *)
	(* ---------------------------------------------------------------------- *)
	ton_dur.PT := T#60s;
	IF (EDGENEG(vfd_struct_data.mapping.CanOpen.ModuleStatusOK)) THEN
		ton_dur.IN := TRUE;
		vfd_struct_data.errorMgmt.Counter_errors := vfd_struct_data.errorMgmt.Counter_errors + 1;
		acum_time := 0;
	END_IF
	
	IF (ton_dur.Q) AND NOT(vfd_struct_data.mapping.CanOpen.ModuleStatusOK) THEN
		acum_time := acum_time + ton_dur.PT;
		ton_dur.IN := FALSE;
	ELSIF NOT(vfd_struct_data.mapping.CanOpen.ModuleStatusOK) THEN
		ton_dur.IN := TRUE;
	END_IF;
	
	IF (ton_dur.IN) AND (vfd_struct_data.mapping.CanOpen.ModuleStatusOK) THEN
		ton_dur.IN := FALSE;
		vfd_struct_data.errorMgmt.Last_Duration := ton_dur.ET + acum_time;
		DTGetTime_1.enable:=TRUE;
		DTGetTime_1();
		vfd_struct_data.errorMgmt.Last_time := DTGetTime_1.DT1;
		DTGetTime_1.enable:=FALSE;
		IF(vfd_struct_data.errorMgmt.Last_Duration > vfd_struct_data.errorMgmt.Max_duration) THEN
			vfd_struct_data.errorMgmt.Max_duration := vfd_struct_data.errorMgmt.Last_Duration;
		END_IF
		
	END_IF
	ton_dur();
	vfd_struct_data.errorMgmt.StatusOK := vfd_struct_data.mapping.CanOpen.ModuleStatusOK;
	
END_FUNCTION_BLOCK
