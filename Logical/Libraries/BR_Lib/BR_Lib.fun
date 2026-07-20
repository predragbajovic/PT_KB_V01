(* ============================================================================ *)
(* BR_LIB - SVE FB VAR DEKLARACIJE (B&R Automation Studio stil)                *)
(* Sadrzi samo deklaracije interfejsa i internih varijabli po FUNCTION_BLOCK-u. *)
(* Bez implementacione logike.                                                  *)
(* ============================================================================ *)

FUNCTION_BLOCK FBAI01_DI01 (* Skaliranje transmitera sa AI + statusnim DI signalom *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*) (* Deklaracija interfejsa FUNCTION_BLOCK FBAI01_DI01. *)
VAR_INPUT
	AI_Input : typInAI01_DI01; (* Deklaracija ulazne strukture bloka FBAI01_DI01. *)
	AI_Param : typParAI01_DI01; (* Deklaracija parametarske strukture bloka FBAI01_DI01. *)
END_VAR
VAR_OUTPUT
	AI_Output : typOutAI01_DI01; (* Deklaracija izlazne strukture bloka FBAI01_DI01. *)
END_VAR
VAR
	AI_Internal : typIntAI01_DI01; (* Deklaracija interne strukture bloka FBAI01_DI01. *)
	AI_Constant : typConstAI01_DI01; (* Deklaracija strukture konstanti bloka FBAI01_DI01. *)
END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FBAI01_DI01_DO02 (* Skaliranje transmitera sa AI + status DI + 2 DO izbora opsega *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*) (* Deklaracija interfejsa FUNCTION_BLOCK FBAI01_DI01_DO02. *)
VAR_INPUT
	AI_Input : typInAI01_DI01_DO02; (* Deklaracija ulazne strukture bloka FBAI01_DI01_DO02. *)
	AI_Param : typParAI01_DI01_DO02; (* Deklaracija parametarske strukture bloka FBAI01_DI01_DO02. *)
END_VAR
VAR_OUTPUT
	AI_Output : typOutAI01_DI01_DO02; (* Deklaracija izlazne strukture bloka FBAI01_DI01_DO02. *)
END_VAR
VAR
	AI_Internal : typIntAI01_DI01_DO02; (* Deklaracija interne strukture bloka FBAI01_DI01_DO02. *)
	AI_Constant : typConstAI01_DI01_DO02; (* Deklaracija strukture konstanti bloka FBAI01_DI01_DO02. *)
END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_DI (* Univerzalni DI sa opcionim status signalom i fault dijagnostikom *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*) (* Deklaracija interfejsa FUNCTION_BLOCK FB_DI. *)
VAR_INPUT
	DI_Input : typInDI; (* Deklaracija ulazne strukture bloka FB_DI. *)
	DI_Param : typParDI; (* Deklaracija parametarske strukture bloka FB_DI. *)
END_VAR
VAR_OUTPUT
	DI_Output : typOutDI; (* Deklaracija izlazne strukture bloka FB_DI. *)
END_VAR
VAR
	DI_Internal : typIntDI; (* Deklaracija interne strukture bloka FB_DI. *)
	DI_Constant : typConstDI; (* Deklaracija strukture konstanti bloka FB_DI. *)
END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_V_ON_OFF_FB (* Predlog FB za ON/OFF ventil - odvojeno od FB_AI_01 *) (* Deklaracija interfejsa FUNCTION_BLOCK FB_V_ON_OFF_FB. *)
VAR_INPUT
	Open : BOOL; (* Komandni zahtev: TRUE otvori, FALSE zatvori *)
	V_Input : typInVOnOff; (* Deklaracija ulazne strukture bloka FB_V_ON_OFF_FB. *)
	V_Param : typParVOnOff := (
		FbOpenExists := TRUE,
		FbCloseExists := TRUE,
		OpenMinTime := T#1s,
		OpenMaxTime := T#30s,
		CloseMinTime := T#1s,
		CloseMaxTime := T#30s,
		StableFbDelay := T#2s
	);
END_VAR
VAR_OUTPUT
	Opened : BOOL; (* Cista potvrda otvorenog stanja: OpenFb=1 i CloseFb=0 *)
	Closed : BOOL; (* Cista potvrda zatvorenog stanja: CloseFb=1 i OpenFb=0 *)
	V_Output : typOutVOnOff; (* Deklaracija izlazne strukture bloka FB_V_ON_OFF_FB. *)
END_VAR
VAR
	Internal : typIntVOnOff; (* Deklaracija interne strukture bloka FB_V_ON_OFF_FB. *)
	Cfg : typCfgVOnOff; (* Deklaracija konfiguracione strukture bloka FB_V_ON_OFF_FB. *)
END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_HV_2LS (* Rucni ventil sa dva krajnja prekidaca *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*) (* Deklaracija interfejsa FUNCTION_BLOCK FB_HV_2LS. *)
VAR_INPUT
	HV_Input : typInHV2LS; (* Deklaracija ulazne strukture bloka FB_HV_2LS. *)
	HV_Param : typParHV2LS := (
		T_OpenClose_SP := 30.0,
		T_BothActive_SP := 0.5
	); (* Deklaracija parametarske strukture bloka FB_HV_2LS. *)
END_VAR
VAR_OUTPUT
	HV_Output : typOutHV2LS; (* Deklaracija izlazne strukture bloka FB_HV_2LS. *)
END_VAR
VAR
	Internal : typIntHV2LS; (* Deklaracija interne strukture bloka FB_HV_2LS. *)
	Cfg : typCfgHV2LS; (* Deklaracija konfiguracione strukture bloka FB_HV_2LS. *)
END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_EH_Flow (*TODO: FB za upravljanje elektricnim grejacima*) (*$GROUP=Pedja,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*) (* Deklaracija interfejsa FUNCTION_BLOCK FB_EH_Flow. *)
VAR_INPUT
	EH_Input : EH_input; (* Deklaracija ulazne strukture bloka FB_EH_Flow. *)
	EH_Param : EH_param; (* Deklaracija parametarske strukture bloka FB_EH_Flow. *)
END_VAR
VAR_OUTPUT
	EH_Output : EH_output; (* Deklaracija izlazne strukture bloka FB_EH_Flow. *)
END_VAR
VAR
	EH_Internal : EH_internal; (* Deklaracija interne strukture bloka FB_EH_Flow. *)
	EH_Constant : EH_constant; (* Deklaracija strukture konstanti bloka FB_EH_Flow. *)
END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PvAiAo_Fast (* Deklaracija interfejsa FUNCTION_BLOCK FB_PvAiAo_Fast. *)
VAR_INPUT
	PV_Input : typInPvAiAo; (* Deklaracija ulazne strukture bloka FB_PvAiAo_Fast. *)
	PV_Param : typParPvAiAo; (* Deklaracija parametarske strukture bloka FB_PvAiAo_Fast. *)
END_VAR
VAR_OUTPUT
	PV_Output : typOutPvAiAo; (* Deklaracija izlazne strukture bloka FB_PvAiAo_Fast. *)
END_VAR
VAR
	PV_Internal : typIntPvAiAo; (* Deklaracija interne strukture bloka FB_PvAiAo_Fast. *)
	PV_Constant : typConstPvAiAo; (* Deklaracija strukture konstanti bloka FB_PvAiAo_Fast. *)
END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PvAiAo_Slow (* Deklaracija interfejsa FUNCTION_BLOCK FB_PvAiAo_Slow. *)
VAR_INPUT
	PV_Input : typInPvAiAo; (* Deklaracija ulazne strukture bloka FB_PvAiAo_Slow. *)
	PV_Param : typParPvAiAo; (* Deklaracija parametarske strukture bloka FB_PvAiAo_Slow. *)
END_VAR
VAR_OUTPUT
	PV_Output : typOutPvAiAo; (* Deklaracija izlazne strukture bloka FB_PvAiAo_Slow. *)
END_VAR
VAR
	PV_Internal : typIntPvAiAoSlow; (* Deklaracija interne strukture bloka FB_PvAiAo_Slow. *)
	PV_Constant : typConstPvAiAo; (* Deklaracija strukture konstanti bloka FB_PvAiAo_Slow. *)
END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PvAoNoFb (* Deklaracija interfejsa FUNCTION_BLOCK FB_PvAoNoFb. *)
VAR_INPUT
	PV_Input : typInPvAoNoFb; (* Deklaracija ulazne strukture bloka FB_PvAoNoFb. *)
	PV_Param : typParPvAoNoFb; (* Deklaracija parametarske strukture bloka FB_PvAoNoFb. *)
END_VAR
VAR_OUTPUT
	PV_Output : typOutPvAoNoFb; (* Deklaracija izlazne strukture bloka FB_PvAoNoFb. *)
END_VAR
VAR
	PV_Internal : typIntPvAoNoFb; (* Deklaracija interne strukture bloka FB_PvAoNoFb. *)
	PV_Constant : typConstPvAoNoFb; (* Deklaracija strukture konstanti bloka FB_PvAoNoFb. *)
END_VAR
END_FUNCTION_BLOCK

