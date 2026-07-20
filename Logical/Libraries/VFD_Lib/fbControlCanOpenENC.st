(* Kontrola CANopen ENC varijante kroz CtrlWord sekvencu. *)
FUNCTION_BLOCK fbControlCanOpenENC
	
	(* ---------------------------------------------------------------------- *)
	(* 1) Povezivanje mapiranih reci preko adresa                              *)
	(* ---------------------------------------------------------------------- *)
	ref_statusWord ACCESS in_addr_StatusWord;
	ref_ctrlWord ACCESS in_addr_CtrlWord;
	r_ctrlWord ACCESS in_addr_r_CtrlWord;
	
	(* ---------------------------------------------------------------------- *)
	(* 2) Interna enable priprema                                               *)
	(* ---------------------------------------------------------------------- *)
	IF cmd.Enable THEN
		en := 1;
	ELSE
		en := 0;
	END_IF;
	
	(* ---------------------------------------------------------------------- *)
	(* 3) Komandna sekvenca u aktivnom bus stanju                              *)
	(* ---------------------------------------------------------------------- *)
	IF en AND (ref_statusWord.0 = 1) THEN
		
		IF (ref_statusWord.1 = 0) AND (ref_statusWord.2 = 0) THEN
			
			IF (ref_ctrlWord = 6) AND  ref_statusWord.8 = 0  AND NOT(cmd.Stop) THEN	
				ref_ctrlWord := 6;
			END_IF;
			
			IF cmd.Jog_fwd AND NOT(out_BUSY) THEN
				ref_ctrlWord := 3;
				out_BUSY := TRUE;
				out_DONE := FALSE;
			END_IF;
			
			IF cmd.Jog_rev AND NOT(out_BUSY) THEN
				ref_ctrlWord := 4;
				out_BUSY := TRUE;
				out_DONE := FALSE;
			END_IF;
			
			IF cmd.Run_fwd AND NOT(out_BUSY) THEN
				ref_ctrlWord := 7;
				out_BUSY := TRUE;
				out_DONE := FALSE;
			END_IF;
			
			IF cmd.Run_rev AND NOT(out_BUSY) THEN
				ref_ctrlWord := 8;
				out_BUSY := TRUE;
				out_DONE := FALSE;
			END_IF;
			
		ELSE
			
			IF cmd.Jog_fwd AND (ref_statusWord.2 = 1) THEN
				out_BUSY := FALSE;
				out_DONE := TRUE;
			ELSIF cmd.Jog_rev AND (ref_statusWord.2 = 1) THEN
				out_BUSY := FALSE;
				out_DONE := TRUE;
			ELSIF (ref_statusWord.2 = 1) THEN
				ref_ctrlWord := 6;
			END_IF;
			
			IF cmd.Run_fwd AND (ref_statusWord.1 = 1) THEN
				out_BUSY := FALSE;
				out_DONE := TRUE;
			ELSIF cmd.Run_rev AND (ref_statusWord.1 = 1) THEN
				out_BUSY := FALSE;
				out_DONE := TRUE;
			ELSIF (ref_statusWord.1 = 1) THEN
				ref_ctrlWord := 6;
			END_IF;
			IF NOT(cmd.Jog_fwd) AND NOT(cmd.Jog_rev) AND NOT(cmd.Stop) AND NOT(cmd.Run_fwd) AND NOT(cmd.Run_rev) THEN
				ref_ctrlWord := 6;
			END_IF;
			
		END_IF;
		
		(* Stop komanda ima prioritet nad run/jog namerom. *)
		IF cmd.Stop THEN
			ref_ctrlWord := 6;
			(* Legacy alternativa sa toggle 0/6 je uklonjena iz aktivne logike. *)
		END_IF;
		
		(* Rucni reset fault uslova. *)
		IF cmd.Reset THEN
			ref_ctrlWord := 9;
			out_BUSY := FALSE;
			out_DONE := TRUE;
		END_IF;
		
		IF NOT(cmd.Reset) AND NOT(cmd.Jog_fwd) AND NOT(cmd.Jog_rev) AND NOT(cmd.Stop) AND NOT(cmd.Run_fwd) AND NOT(cmd.Run_rev) THEN
			out_BUSY := FALSE;
			out_DONE := FALSE;
		END_IF;	
	ELSE
		(* ------------------------------------------------------------------ *)
		(* 4) Fallback kada nije enable ili nema bus napona                    *)
		(* ------------------------------------------------------------------ *)
		ref_ctrlWord := 6;
		
		IF cmd.Reset THEN
			ref_ctrlWord := 9;
		END_IF;
		
		out_BUSY := FALSE;
		out_DONE := FALSE;
	END_IF;
	
	(* ---------------------------------------------------------------------- *)
	(* 5) Auto-reset sekvenca nakon detekcije fault/self-recovery signala      *)
	(* ---------------------------------------------------------------------- *)
	IF cmd.en_autoReset THEN
		IF  NOT(ref_ctrlWord = 3) AND  (r_ctrlWord = 3) THEN

			IF start_check THEN
	  			ref_ctrlWord := 9;
				start_check := FALSE;
			ELSE
				ref_ctrlWord := 6;
				start_check := TRUE;
			END_IF;
		END_IF;
	END_IF;
	
END_FUNCTION_BLOCK
