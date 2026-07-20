{REDUND_ERROR} FUNCTION_BLOCK fbCheckStateCanOpenENC (* Dekodiranje status reci CANopen ENC varijante u standardni state kod. *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT (* Ulazni podaci za dekodiranje status reci. *)
		in_addr_StatusWord : {REDUND_UNREPLICABLE} UDINT; (* Adresa status reci uredjaja. *)
	END_VAR
	VAR_OUTPUT (* Izlaz dekodiranog internog state koda. *)
		out_State : UINT; (* Dekodirani interni state kod. *)
	END_VAR
	VAR (* Interne reference i pomocne promenljive bloka. *)
		ref_statusWord : REFERENCE TO UINT; (* Referenca na status rec zbog bit-level dekodiranja. *)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} FUNCTION_BLOCK fbControlCanOpenENC (* Komandovanje CANopen ENC varijante kroz CtrlWord sekvencu. *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT (* Ulazni komandni i adresni podaci za ENC upravljanje. *)
		cmd : vfd_commands; (* Grupisane komande sa nadredjenog nivoa. *)
		in_addr_StatusWord : UDINT; (* Adresa status reci uredjaja. *)
		in_addr_r_CtrlWord : UDINT; (* Adresa povratne/eho komandne reci. *)
		in_addr_CtrlWord : UDINT; (* Adresa komandne reci za upis. *)
	END_VAR
	VAR_OUTPUT (* Izlazi statusa izvrsenja komandi. *)
		out_BUSY : BOOL; (* TRUE dok je tranzicija komande u toku. *)
		out_DONE : BOOL; (* TRUE kada je trazena komanda potvrdena. *)
	END_VAR
	VAR (* Interne reference i pomocni flagovi sekvence. *)
		en : BOOL; (* Interna kopija Enable logike. *)
		ref_statusWord : REFERENCE TO UINT; (* Referenca na status rec. *)
		r_ctrlWord : REFERENCE TO UINT; (* Referenca na feedback ctrl rec. *)
		ref_ctrlWord : REFERENCE TO UINT; (* Referenca na izlaznu ctrl rec. *)
		start_check : BOOL; (* Memorija za auto-reset sekvencu. *)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} FUNCTION_BLOCK vfdMain (* Glavni VFD blok: dispatch po metodi, kontrola i monitoring. *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT (* Ulazni podaci instance glavnog VFD bloka. *)
		addr_struct : UDINT; (* Adresa agregatne VFD strukture (VFD_type). *)
	END_VAR
	VAR_OUTPUT (* Izlazni dijagnosticki i statusni signali bloka. *)
		errorID : UINT; (* Izlazni kod greske prema aktivnoj metodi mapiranja. *)
		errorText : STRING[40]; (* Izlazni tekst greske za HMI dijagnostiku. *)
		Done : BOOL; (* Operacija komande zavrsena. *)
		Busy : BOOL; (* Operacija komande je u toku. *)
	END_VAR
	VAR (* Interne FB instance, reference i pomocne promenljive. *)
		fControlENC : fbControlCanOpenENC; (* Komandni pod-blok za ENC varijantu. *)
		fStateENC : fbCheckStateCanOpenENC; (* State dekoder za ENC varijantu. *)
		fControlATV : fbControlCanOpenATV; (* Komandni pod-blok za ATV varijantu. *)
		fStateATV : fbCheckStateCanOpenATV; (* State dekoder za ATV varijantu. *)
		vfd_struct_data : REFERENCE TO VFD_type; (* Referenca ka centralnoj VFD strukturi. *)
		state_case : UINT; (* Privremeni state izbor za mapiranje izlaza states.*)
		acum_time : TIME; (* Akumulirano trajanje duzih prekida komunikacije. *)
		DTGetTime_1 : DTGetTime; (* Sistemski blok za uzimanje vremena dogadaja. *)
		ton_dur : TON; (* Tajmer trajanja komunikacionog ispada. *)
		zzEdge00000 : BOOL; (* Rezervisano/interne potrebe (legacy). *)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} FUNCTION_BLOCK fbCheckStateCanOpenATV (* Dekodiranje ATV status reci u ATV state kod. *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT (* Ulazni podaci za dekodiranje ATV status reci. *)
		in_addr_StatusWord : {REDUND_UNREPLICABLE} UDINT; (* Adresa ATV status reci. *)
	END_VAR
	VAR_OUTPUT (* Izlaz dekodiranog ATV state koda i pomocnih stanja. *)
		out_State : {REDUND_UNREPLICABLE} UINT; (* Dekodirani ATV state kod. *)
		DC_BUS_ON : BOOL; (* Informacija da je DC bus aktivan. *)
	END_VAR
	VAR (* Interne reference za citanje status reci. *)
		ref_statusWord : REFERENCE TO UINT; (* Referenca na ATV status rec. *)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} FUNCTION_BLOCK fbControlCanOpenATV (* Komandovanje ATV CANopen varijante preko CtrlWord logike. *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT (* Ulazni komandni i procesni podaci za ATV upravljanje. *)
		cmd : {REDUND_UNREPLICABLE} vfd_commands; (* Komande sa nadredjenog nivoa. *)
		in_set_freq : INT; (* Trazeni speed/freq setpoint u ATV skali. *)
		in_addr_CtrlWord : {REDUND_UNREPLICABLE} UDINT; (* Adresa ctrl reci za upis. *)
		StatusWord : {REDUND_UNREPLICABLE} UINT; (* Trenutni ATV state kod (dekodiran). *)
		DC_BUS_STATE : {REDUND_UNREPLICABLE} BOOL; (* Status DC bus-a iz state dekodera. *)
	END_VAR
	VAR_OUTPUT (* Izlazi statusa izvrsenja i zadavanja frekvencije. *)
		out_BUSY : {REDUND_UNREPLICABLE} BOOL; (* TRUE kada je komanda u tranziciji. *)
		set_freq : INT; (* Izracunata/odobrena izlazna frekvencija. *)
		out_DONE : {REDUND_UNREPLICABLE} BOOL; (* TRUE kada je komanda zavrsena. *)
	END_VAR
	VAR (* Interne reference i pomocne promenljive upravljanja. *)
		en : {REDUND_UNREPLICABLE} BOOL; (* Legacy enable medjupromenljiva. *)
		ref_ctrlWord : REFERENCE TO UINT; (* Referenca na komandnu rec ATV mapiranja. *)
	END_VAR
END_FUNCTION_BLOCK
