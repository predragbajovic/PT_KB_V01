(* Dekodiranje ATV status reci u ATV state kod i DC bus status. *)
FUNCTION_BLOCK fbCheckStateCanOpenATV
	
	(* ---------------------------------------------------------------------- *)
	(* 1) Povezivanje status reci preko adrese                               *)
	(* ---------------------------------------------------------------------- *)
	ref_statusWord ACCESS in_addr_StatusWord;	
	
	
	(* ---------------------------------------------------------------------- *)
	(* 2) Prioritetna dekodiranja ATV stanja                                  *)
	(* ---------------------------------------------------------------------- *)
	IF (ref_statusWord.3 = TRUE) THEN
		IF(ref_statusWord.0 = FALSE) AND (ref_statusWord.1 = FALSE) AND (ref_statusWord.2 = FALSE) THEN
			out_State := STATV_ERR; (* Hard error stanje. *)
		ELSE
			out_State := STATV_ERR_MNG; (* Error management aktivan. *)
		END_IF;
		
	ELSIF (ref_statusWord.6 = TRUE) THEN
		out_State := STATV_SWH_DISABLE; (* Switch disable stanje. *)
		
	ELSIF (ref_statusWord.5 = FALSE) THEN
		IF(ref_statusWord.0 = TRUE) AND (ref_statusWord.1 = TRUE) AND (ref_statusWord.2 = TRUE) THEN
			out_State := STATV_FAST_STOP; (* Fast stop stanje. *)
		ELSE
			out_State := STATV_RDY_NOT; (* Nije ready. *)
		END_IF;
		
	ELSIF (ref_statusWord.2 = TRUE) THEN
		out_State := STATV_RUN; (* Run stanje. *)
		
	ELSIF (ref_statusWord.1 = TRUE) THEN
		out_State := STATV_SWH_ON; (* Switched on stanje. *)
		
	ELSIF (ref_statusWord.0 = FALSE) THEN	
		out_State := STATV_RDY_NOT; (* Nije spreman za rad. *)
		
	ELSIF (ref_statusWord.0 = TRUE) THEN
		out_State := STATV_RDY; (* Ready stanje. *)
		DC_BUS_ON := ref_statusWord.4; (* U ready stanju preuzima se DC bus bit. *)
	END_IF;	
		
END_FUNCTION_BLOCK
