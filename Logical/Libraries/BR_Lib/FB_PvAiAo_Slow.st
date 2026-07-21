(* SLOW VARIJANTA: Za elektromotorne ventile sa sporim odzivom (30-180 s). *)
(* Implementirana logika: trenutna komanda + nadzor fizickog pracenja ventila. *)

(*
===============================================================================
SLOW LOGIC SPEC (USAGLASENO PRE IMPLEMENTACIJE)
===============================================================================

Osnovni princip:
1) Komanda izlaza se NE rampira softverski.
2) Kada se promeni setpoint, izlaz odmah dobija novu komandnu vrednost.
3) Umesto rampe proverava se da li ventil fizicki prati ocekivano vreme putovanja.

Definicije:
- PV_Internal.StepDeltaPercent = ABS(NewSP - PV_Internal.PrevSP)
- Smer kretanja:
	- Opening: NewSP > PV_Internal.PrevSP
	- Closing: NewSP < PV_Internal.PrevSP
- Ocekivano vreme putovanja:
	- Texp_open  = PV_Internal.StepDeltaPercent/100 * PV_Internal.TravelTimeOpenFull
	- Texp_close = PV_Internal.StepDeltaPercent/100 * PV_Internal.TravelTimeCloseFull
- Dozvoljeni prozor:
	- Tmin = Texp * (1 - PV_Internal.TimeTolerancePercent/100)
	- Tmax = Texp * (1 + PV_Internal.TimeTolerancePercent/100)

Ulaz u tracking poteza:
- Tracking se aktivira kada je ABS(NewSP - PV_Internal.PrevSP) >= StepMinPercent.
- Ako je manji korak od StepMinPercent, tretira se kao mali pomak bez punog timing nadzora.

Uslovi tokom tracking-a:
1) Start movement timeout:
	 - Ako nema detektovanog pocetnog pomeranja PV u PV_Internal.StartMoveTimeout -> FaultNoMovement.
2) Smer kretanja:
	 - Opening: PV mora da raste.
	 - Closing: PV mora da opada.
	 - Suprotan smer duze od PV_Internal.DirectionCheckTime -> FaultWrongDirection.
3) Stall nadzor:
	 - Ako je tracking aktivan, a PV ne menja vrednost duze od PV_Internal.StallTimeout -> FaultStall.
4) Zavrsetak poteza:
	 - Potez je zavrsen kada PV udje u ciljnu traku:
		 ABS(TargetSP - PV) <= TargetBandPercent.
	 - Ako zavrsetak nastupi pre Tmin -> warning ili fault (po parametru PV_Internal.EnableTooFastFault).
	 - Ako zavrsetak ne nastupi do Tmax -> FaultTimeout.

Nova komanda tokom aktivnog poteza:
- Aktivni tracking se prekida i odmah se formira novi tracking od trenutnog PV/SP stanja.

Fault politika:
- Fault je latched (ostaje aktivan do Reset).
- Fault tipovi:
	1) NoMovement
	2) WrongDirection
	3) Stall
	4) TimeoutSlow
	5) (opciono) TooFast

Interakcija sa postojecim logikama:
- Enable i dalje ima apsolutni prioritet (disable gasi komandu).
- ForceCmd i HoldOutputOnFault zadrzavaju isto ponasanje kao FAST varijanta.
- Status/State/State_comment ostaju obavezni izlazi.

Napomena za implementaciju:
- Uvesti odvojene interne tajmere za:
	- start movement timeout,
	- direction confirm,
	- stall timeout,
	- tracking timeout (Tmax).
- Uvesti internu memoriju prethodnog SP i prethodnog PV za detekciju koraka i trenda.
===============================================================================
*)

FUNCTION_BLOCK FB_PvAiAo_Slow

(* Commissioning preset (pocetne preporuke, po potrebi menjati na terenu):
   PV_Internal.TravelTimeOpenFull = T#120s
   PV_Internal.TravelTimeCloseFull = T#120s
   PV_Internal.TimeTolerancePercent = 35.0
   PV_Internal.StartMoveTimeout = T#8s
   PV_Internal.DirectionCheckTime = T#8s
   PV_Internal.StallTimeout = T#20s
   PV_Internal.MovementStartDeltaPercent = 0.7
   PV_Internal.PerScanProgressMinPercent = 0.03
   PV_Internal.DirectionEpsPercent = 0.03
   PV_Internal.EnableTooFastFault = FALSE
*)

(* -------------------------------------------------------------------------- *)
(* 1) Osnovni statusi bloka                                                    *)
(* -------------------------------------------------------------------------- *)
PV_Output.Valid := PV_Input.Enable;
PV_Output.ManualActive := PV_Input.EnableManual;

(* -------------------------------------------------------------------------- *)
(* 2) Ogranicenje AI ulaza i skaliranje u procente                             *)
(* -------------------------------------------------------------------------- *)
IF PV_Input.AI_Raw < PV_Constant.RAW_MIN THEN
	PV_Output.AI_Raw_Limited := PV_Constant.RAW_MIN;
ELSIF PV_Input.AI_Raw > PV_Constant.RAW_MAX THEN
	PV_Output.AI_Raw_Limited := PV_Constant.RAW_MAX;
ELSE
	PV_Output.AI_Raw_Limited := PV_Input.AI_Raw;
END_IF;

PV_Internal.rAi := INT_TO_REAL(PV_Output.AI_Raw_Limited);
PV_Output.PV_Percent := (PV_Internal.rAi * PV_Constant.PCT_MAX) / INT_TO_REAL(PV_Constant.RAW_MAX);

(* -------------------------------------------------------------------------- *)
(* 3) Ogranicenje auto i manual komande                                        *)
(* -------------------------------------------------------------------------- *)
IF PV_Input.SP_Percent < PV_Constant.PCT_MIN THEN
	PV_Output.SP_Percent_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Input.SP_Percent > PV_Constant.PCT_MAX THEN
	PV_Output.SP_Percent_Limited := PV_Constant.PCT_MAX;
ELSE
	PV_Output.SP_Percent_Limited := PV_Input.SP_Percent;
END_IF;

IF PV_Input.ManualValue_Percent < PV_Constant.PCT_MIN THEN
	PV_Output.ManualValue_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Input.ManualValue_Percent > PV_Constant.PCT_MAX THEN
	PV_Output.ManualValue_Limited := PV_Constant.PCT_MAX;
ELSE
	PV_Output.ManualValue_Limited := PV_Input.ManualValue_Percent;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 4) Izbor aktivne komande (manual ima prioritet)                             *)
(* -------------------------------------------------------------------------- *)
IF PV_Input.EnableManual THEN
	PV_Output.ActiveSP_Limited := PV_Output.ManualValue_Limited;
ELSE
	PV_Output.ActiveSP_Limited := PV_Output.SP_Percent_Limited;
END_IF;
PV_Output.ActiveSP_Percent := PV_Output.ActiveSP_Limited;

(* -------------------------------------------------------------------------- *)
(* 5) Validacija devijacionih granica i vremena                                *)
(* -------------------------------------------------------------------------- *)
IF PV_Param.DeviationOnLimit < PV_Constant.PCT_MIN THEN
	PV_Output.DeviationOn_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Param.DeviationOnLimit > PV_Constant.PCT_MAX THEN
	PV_Output.DeviationOn_Limited := PV_Constant.PCT_MAX;
ELSE
	PV_Output.DeviationOn_Limited := PV_Param.DeviationOnLimit;
END_IF;

IF PV_Param.DeviationOffLimit < PV_Constant.PCT_MIN THEN
	PV_Output.DeviationOff_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Param.DeviationOffLimit > PV_Constant.PCT_MAX THEN
	PV_Output.DeviationOff_Limited := PV_Constant.PCT_MAX;
ELSE
	PV_Output.DeviationOff_Limited := PV_Param.DeviationOffLimit;
END_IF;

IF PV_Output.DeviationOff_Limited > PV_Output.DeviationOn_Limited THEN
	PV_Output.DeviationOff_Limited := PV_Output.DeviationOn_Limited;
END_IF;

IF PV_Param.DeviationTime <= T#0ms THEN
	PV_Output.DeviationTime_Effective := PV_Constant.MIN_DEV_TIME;
ELSE
	PV_Output.DeviationTime_Effective := PV_Param.DeviationTime;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 6) Proracun devijacije i tolerancije                                        *)
(* -------------------------------------------------------------------------- *)
PV_Output.DeviationPercent := ABS(PV_Output.ActiveSP_Limited - PV_Output.PV_Percent);
PV_Output.InTolerance := (PV_Output.DeviationPercent <= PV_Output.DeviationOff_Limited);

(* -------------------------------------------------------------------------- *)
(* 7) Tracking i fault nadzor za SLOW ponasanje                                *)
(* -------------------------------------------------------------------------- *)
(* Reset/safe defaults za tracking i fault nadzor. *)
IF PV_Input.Reset THEN
	PV_Output.FaultActive := FALSE;
	PV_Output.DeviationTimeout := FALSE;
	PV_Internal.TrackActive := FALSE;
	PV_Internal.MovementStarted := FALSE;
	PV_Internal.FaultReasonText := 'RESET';
	PV_Output.InDeviation := FALSE;

	PV_Internal.TrackTimer(IN := FALSE, PT := T#1ms);
	PV_Internal.StartMoveTimer(IN := FALSE, PT := PV_Internal.StartMoveTimeout);
	PV_Internal.DirectionTimer(IN := FALSE, PT := PV_Internal.DirectionCheckTime);
	PV_Internal.StallTimer(IN := FALSE, PT := PV_Internal.StallTimeout);

ELSIF NOT PV_Input.Enable THEN
	PV_Internal.TrackActive := FALSE;
	PV_Internal.MovementStarted := FALSE;
	PV_Output.InDeviation := FALSE;
	PV_Internal.FaultReasonText := 'DISABLED';

	PV_Internal.TrackTimer(IN := FALSE, PT := T#1ms);
	PV_Internal.StartMoveTimer(IN := FALSE, PT := PV_Internal.StartMoveTimeout);
	PV_Internal.DirectionTimer(IN := FALSE, PT := PV_Internal.DirectionCheckTime);
	PV_Internal.StallTimer(IN := FALSE, PT := PV_Internal.StallTimeout);

ELSE
	(* Novo pracenje na znacajnu promenu komande.
	   Prag za aktivaciju tracking-a je vezan za DeviationOn_Limited. *)
	PV_Internal.StepDeltaPercent := ABS(PV_Output.ActiveSP_Limited - PV_Internal.PrevSP);
	IF PV_Internal.StepDeltaPercent >= PV_Output.DeviationOn_Limited THEN
		PV_Internal.TrackActive := TRUE;
		PV_Internal.MovementStarted := FALSE;
		PV_Internal.PV_AtTrackStart := PV_Output.PV_Percent;
		PV_Internal.LastProgressPV := PV_Output.PV_Percent;
		PV_Internal.TrackDirectionOpen := (PV_Output.ActiveSP_Limited > PV_Internal.PrevSP);

		IF PV_Internal.TrackDirectionOpen THEN
			PV_Internal.ExpectedTravelSec := (PV_Internal.StepDeltaPercent / 100.0) * (TIME_TO_REAL(PV_Internal.TravelTimeOpenFull) / 1000.0);
		ELSE
			PV_Internal.ExpectedTravelSec := (PV_Internal.StepDeltaPercent / 100.0) * (TIME_TO_REAL(PV_Internal.TravelTimeCloseFull) / 1000.0);
		END_IF;

		PV_Internal.TminSec := PV_Internal.ExpectedTravelSec * (1.0 - PV_Internal.TimeTolerancePercent / 100.0);
		PV_Internal.TmaxSec := PV_Internal.ExpectedTravelSec * (1.0 + PV_Internal.TimeTolerancePercent / 100.0);
		IF PV_Internal.TminSec < 0.0 THEN
			PV_Internal.TminSec := 0.0;
		END_IF;
		IF PV_Internal.TmaxSec <= 0.0 THEN
			PV_Internal.TmaxSec := 0.1;
		END_IF;
	END_IF;

	(* Tajmeri nadzora putovanja. *)
	PV_Internal.TrackTimer(IN := PV_Internal.TrackActive, PT := REAL_TO_TIME(PV_Internal.TmaxSec * 1000.0));
	PV_Internal.StartMoveTimer(IN := PV_Internal.TrackActive AND (NOT PV_Internal.MovementStarted), PT := PV_Internal.StartMoveTimeout);

	IF PV_Internal.TrackActive THEN
		IF ABS(PV_Output.PV_Percent - PV_Internal.PV_AtTrackStart) >= PV_Internal.MovementStartDeltaPercent THEN
			PV_Internal.MovementStarted := TRUE;
		END_IF;

		IF PV_Internal.TrackDirectionOpen THEN
			PV_Internal.DirectionTimer(IN := (PV_Output.PV_Percent < (PV_Internal.PrevPV - PV_Internal.DirectionEpsPercent)), PT := PV_Internal.DirectionCheckTime);
		ELSE
			PV_Internal.DirectionTimer(IN := (PV_Output.PV_Percent > (PV_Internal.PrevPV + PV_Internal.DirectionEpsPercent)), PT := PV_Internal.DirectionCheckTime);
		END_IF;

		PV_Internal.StallTimer(IN := PV_Internal.MovementStarted AND (ABS(PV_Output.PV_Percent - PV_Internal.PrevPV) < PV_Internal.PerScanProgressMinPercent), PT := PV_Internal.StallTimeout);
	ELSE
		PV_Internal.DirectionTimer(IN := FALSE, PT := PV_Internal.DirectionCheckTime);
		PV_Internal.StallTimer(IN := FALSE, PT := PV_Internal.StallTimeout);
	END_IF;

	(* Fault uslovi i zavrsetak tracking-a. *)
	PV_Output.DeviationTimeout := FALSE;
	IF PV_Internal.TrackActive THEN
		IF PV_Internal.StartMoveTimer.Q THEN
			PV_Output.FaultActive := TRUE;
			PV_Internal.FaultReasonText := 'FAULT_NO_MOVEMENT';
			PV_Internal.TrackActive := FALSE;
		ELSIF PV_Internal.DirectionTimer.Q THEN
			PV_Output.FaultActive := TRUE;
			PV_Internal.FaultReasonText := 'FAULT_WRONG_DIRECTION';
			PV_Internal.TrackActive := FALSE;
		ELSIF PV_Internal.StallTimer.Q THEN
			PV_Output.FaultActive := TRUE;
			PV_Internal.FaultReasonText := 'FAULT_STALL';
			PV_Internal.TrackActive := FALSE;
		ELSIF PV_Internal.TrackTimer.Q THEN
			PV_Output.FaultActive := TRUE;
			PV_Output.DeviationTimeout := TRUE;
			PV_Internal.FaultReasonText := 'FAULT_TIMEOUT_SLOW';
			PV_Internal.TrackActive := FALSE;
		ELSIF PV_Output.InTolerance THEN
			PV_Internal.ActualTravelSec := TIME_TO_REAL(PV_Internal.TrackTimer.ET) / 1000.0;
			IF PV_Internal.EnableTooFastFault AND (PV_Internal.ActualTravelSec < PV_Internal.TminSec) THEN
				PV_Output.FaultActive := TRUE;
				PV_Internal.FaultReasonText := 'FAULT_TOO_FAST';
			ELSE
				PV_Internal.FaultReasonText := 'TRACK_OK';
			END_IF;
			PV_Internal.TrackActive := FALSE;
		END_IF;
	END_IF;

	PV_Output.InDeviation := PV_Internal.TrackActive;
END_IF;

PV_Output.DeviationElapsed := PV_Internal.TrackTimer.ET;

(* -------------------------------------------------------------------------- *)
(* 8) Izbor stvarno primenjene izlazne komande                                  *)
(* -------------------------------------------------------------------------- *)
(* Immediate command (bez rampe), sa istom fault politikom kao FAST. *)
IF NOT PV_Input.Enable THEN
	PV_Output.AppliedOutput_Limited := PV_Constant.PCT_MIN;
	PV_Output.FrozenOutput_Percent := PV_Constant.PCT_MIN;
	PV_Output.CommandPermitted := FALSE;
	PV_Output.ForceActive := FALSE;

ELSIF PV_Output.FaultActive THEN
	IF PV_Input.ForceCmd THEN
		PV_Output.AppliedOutput_Limited := PV_Output.ActiveSP_Limited;
		PV_Output.CommandPermitted := TRUE;
		PV_Output.ForceActive := TRUE;
	ELSE
		PV_Output.CommandPermitted := FALSE;
		PV_Output.ForceActive := FALSE;
		IF PV_Param.HoldOutputOnFault THEN
			PV_Output.AppliedOutput_Limited := PV_Output.FrozenOutput_Percent;
		ELSE
			PV_Output.AppliedOutput_Limited := PV_Constant.PCT_MIN;
		END_IF;
	END_IF;

ELSE
	PV_Output.AppliedOutput_Limited := PV_Output.ActiveSP_Limited;
	PV_Output.CommandPermitted := TRUE;
	PV_Output.ForceActive := FALSE;
	PV_Output.FrozenOutput_Percent := PV_Output.AppliedOutput_Limited;
END_IF;

(* -------------------------------------------------------------------------- *)
(* 9) Zavrsno ogranicenje i AO skaliranje                                      *)
(* -------------------------------------------------------------------------- *)
IF PV_Output.AppliedOutput_Limited < PV_Constant.PCT_MIN THEN
	PV_Output.AppliedOutput_Limited := PV_Constant.PCT_MIN;
ELSIF PV_Output.AppliedOutput_Limited > PV_Constant.PCT_MAX THEN
	PV_Output.AppliedOutput_Limited := PV_Constant.PCT_MAX;
END_IF;

PV_Output.AppliedOutput_Percent := PV_Output.AppliedOutput_Limited;
PV_Internal.rAo := (PV_Output.AppliedOutput_Limited * INT_TO_REAL(PV_Constant.RAW_MAX)) / PV_Constant.PCT_MAX;
PV_Internal.AO_Raw_Calc := REAL_TO_INT(PV_Internal.rAo);
IF PV_Internal.AO_Raw_Calc < PV_Constant.RAW_MIN THEN
	PV_Internal.AO_Raw_Calc := PV_Constant.RAW_MIN;
ELSIF PV_Internal.AO_Raw_Calc > PV_Constant.RAW_MAX THEN
	PV_Internal.AO_Raw_Calc := PV_Constant.RAW_MAX;
END_IF;
PV_Output.AO_Raw := PV_Internal.AO_Raw_Calc;

(* -------------------------------------------------------------------------- *)
(* 10) Standardni izlazi stanja za HMI/SCADA                                    *)
(* -------------------------------------------------------------------------- *)
IF NOT PV_Input.Enable THEN
	PV_Output.Status := FALSE;
	PV_Output.State := PV_Constant.ST_DISABLED;
	PV_Output.State_comment := 'ST_DISABLED - blok nije omogucen';
ELSIF PV_Output.FaultActive THEN
	PV_Output.Status := FALSE;
	IF PV_Output.ForceActive THEN
		PV_Output.State := PV_Constant.ST_FAULT_FORCE;
		PV_Output.State_comment := CONCAT('ST_FAULT_FORCE - ', PV_Internal.FaultReasonText);
	ELSE
		PV_Output.State := PV_Constant.ST_FAULT_HOLD;
		PV_Output.State_comment := CONCAT('ST_FAULT_HOLD - ', PV_Internal.FaultReasonText);
	END_IF;
ELSIF PV_Output.InDeviation THEN
	PV_Output.Status := TRUE;
	PV_Output.State := PV_Constant.ST_DEVIATION_ACTIVE;
	PV_Output.State_comment := 'ST_DEVIATION_ACTIVE - tracking travel time';
ELSIF PV_Output.ManualActive THEN
	PV_Output.Status := TRUE;
	PV_Output.State := PV_Constant.ST_MANUAL_ACTIVE;
	PV_Output.State_comment := 'ST_MANUAL_ACTIVE - aktivan manuelni rezim';
ELSE
	PV_Output.Status := TRUE;
	PV_Output.State := PV_Constant.ST_AUTO_ACTIVE;
	PV_Output.State_comment := 'ST_AUTO_ACTIVE - aktivan automatski rezim';
END_IF;

(* -------------------------------------------------------------------------- *)
(* 11) Memorija prethodnog ciklusa za detekciju koraka i trenda                 *)
(* -------------------------------------------------------------------------- *)
PV_Internal.PrevSP := PV_Output.ActiveSP_Limited;
PV_Internal.PrevPV := PV_Output.PV_Percent;

END_FUNCTION_BLOCK

