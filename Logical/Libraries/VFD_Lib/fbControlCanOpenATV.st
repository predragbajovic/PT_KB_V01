(* Kontrola ATV CANopen varijante kroz state-zavisnu CtrlWord logiku. *)
FUNCTION_BLOCK fbControlCanOpenATV
			
	(* ---------------------------------------------------------------------- *)
	(* 1) Povezivanje komandne reci preko adrese                               *)
	(* ---------------------------------------------------------------------- *)
	ref_ctrlWord ACCESS in_addr_CtrlWord;

	(* FastStop se tretira prioritetno kad nije vec u switch-disable stanju. *)
	IF(cmd.FastStop = TRUE) AND NOT(StatusWord = STATV_SWH_DISABLE) THEN
		ref_ctrlWord := 2;
		set_freq := 0;
	END_IF;

	(* ---------------------------------------------------------------------- *)
	(* 2) State-zavisna obrada komandi                                         *)
	(* ---------------------------------------------------------------------- *)
	CASE StatusWord OF
		
		STATV_PWR_OFF:
			(* Nema aktivne akcije dok je pogon bez napajanja. *)

			
		STATV_RDY_NOT:
			(* Pogon nije ready; ceka se validan prelaz stanja iz drive-a. *)

			
		STATV_SWH_DISABLE:
			
			IF (cmd.Enable = TRUE) THEN
				ref_ctrlWord := 6; (* Prelaz ka ready sekvenci. *)
			END_IF
			
		STATV_RDY:
			
			IF(DC_BUS_STATE = TRUE) AND (cmd.Enable) THEN
				ref_ctrlWord := 7; (* Uslovi ispunjeni za switch-on. *)
			END_IF
			IF (cmd.Enable = FALSE) THEN
				ref_ctrlWord := 0;
			END_IF
			
		STATV_SWH_ON:
			IF(cmd.Run_fwd = TRUE) AND (cmd.Enable = TRUE) THEN
				ref_ctrlWord := 15;
				ref_ctrlWord.11 := FALSE;
				ref_ctrlWord.12 := TRUE;
			ELSIF (cmd.Run_rev = TRUE) AND (cmd.Enable = TRUE) THEN
				ref_ctrlWord := 15;
				ref_ctrlWord.12 := FALSE;
				ref_ctrlWord.11 := TRUE;
			ELSIF (cmd.Enable = FALSE) THEN
				ref_ctrlWord := 0;
			END_IF
			
		STATV_RUN:
			
			IF(cmd.FastStop = TRUE) THEN
				ref_ctrlWord := 2;
				set_freq := 0;
			ELSIF(cmd.Enable = FALSE) THEN
				ref_ctrlWord := 0;
				set_freq := 0;
				ref_ctrlWord.8 := cmd.Stop;
			
			ELSIF ((cmd.Run_fwd = FALSE) AND (cmd.Run_rev = FALSE)) OR cmd.Stop THEN
				ref_ctrlWord := 7;
				set_freq := 0;
			ELSE
				set_freq := in_set_freq;
			END_IF
		
		STATV_FAST_STOP:
			
			IF (cmd.FastStop = FALSE) THEN
				ref_ctrlWord := 0;
				set_freq := 0;
				cmd.Run_fwd := FALSE;
				cmd.Run_rev := FALSE;
				cmd.Stop := FALSE;
				(* Legacy napomena: cmd.Enable se namerno ne resetuje automatski. *)
			END_IF;
		
				
			(* STATV_ERR_MNG je obradjen kroz state dekoder i mapiranje u glavnom FB-u. *)
			
		STATV_ERR:
			
			IF (cmd.Reset = TRUE) THEN	
				cmd.Run_fwd := FALSE;
				cmd.Run_rev := FALSE;
				cmd.Stop := FALSE;
				(* Legacy napomena: cmd.Enable se namerno ne resetuje automatski. *)
				ref_ctrlWord := 128;
				set_freq := 0;
			END_IF;
	END_CASE	

END_FUNCTION_BLOCK
