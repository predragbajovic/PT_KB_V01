# FB_V_EMV Debug Check-In (Brza Provera)

Namena: brza dijagnostika kada ventil mehanicki radi, a FB ulazi u alarm, timeout ili ne zavrsava sekvencu.

## 1) Potvrda Komandnog Smera
- Za test OTVARANJA: Open = TRUE, CmdOpen treba da bude TRUE, CmdClose FALSE.
- Za test ZATVARANJA: Open = FALSE, CmdClose treba da bude TRUE, CmdOpen FALSE.
- Ako su obe komande FALSE tokom tranzicije: proveriti Stop, Enable, ManualAlarm, FaultLatched.

## 2) Provera 1:1 Mapiranja Signala (najcesci uzrok)
- OpenFb mora da odgovara fizickom otvorenom polozaju.
- CloseFb mora da odgovara fizickom zatvorenom polozaju.
- LampOpen i LampClose ne smeju biti ukrsteni.
- OverTorque mora biti mapiran samo ako signal stvarno postoji.

Tipicna greska:
- Ukrseni LampOpen/LampClose -> FB ne prepoznaje kraj hoda i ide u timeout.

## 3) Stabilnost Signala (ne samo trenutni impuls)
Tokom testa pratiti istovremeno:
- V_Input.LampOpen
- V_Input.LampClose
- Internal.LampOpenStable
- Internal.LampCloseStable
- V_Input.OpenFb
- V_Input.CloseFb
- Internal.OpenFbStable
- Internal.CloseFbStable

Ocekivanje:
- Stable signali moraju pratiti ulazne signale posle filter vremena.
- Ako ulaz postane TRUE, a Stable ostane FALSE, proveriti filter parametre i oscilacije signala.

## 4) Parametri Koji Direktno Uticu Na Ishod
- EndLimitFilterTime
- PositionFbFilterTime
- OpenMaxTime
- CloseMaxTime
- PositionConfirmTime
- LampOpenExists / LampCloseExists
- OpenFbExists / CloseFbExists

Prakticno pravilo:
- Ako lamp signali nisu trajna krajnja potvrda, koristiti ih kao pomocne, a potvrdu kraja hoda bazirati na OpenFb/CloseFb.

## 5) Brza Dijagnoza Po FaultCode
- FLT_OPEN_TIMEOUT: otvoreno nije prepoznato pre OpenMaxTime.
- FLT_CLOSE_TIMEOUT: zatvoreno nije prepoznato pre CloseMaxTime.
- FLT_OPEN_CONFIRM_TIMEOUT: LampOpen detektovan, ali trajni OpenFb nije potvrdjen u PositionConfirmTime.
- FLT_CLOSE_CONFIRM_TIMEOUT: LampClose detektovan, ali trajni CloseFb nije potvrdjen u PositionConfirmTime.

## 6) Minimalni Watch Set Za Terensku Probu
- V_Input: Enable, Stop, Open, LampOpen, LampClose, OpenFb, CloseFb, OverTorque
- V_Output: State, State_comment, CmdOpen, CmdClose, FaultLatched, FaultCode, FaultText
- Internal: Step, LampOpenStable, LampCloseStable, OpenFbStable, CloseFbStable, OpenEndReached, CloseEndReached

## 7) Check-Out Kriterijum (test prolazi)
- Komanda otvori/zatvori dovede FB u odgovarajuci idle state bez timeout alarma.
- FaultLatched ostaje FALSE u regularnom ciklusu rada.
- Position i PositionText prate realan fizicki polozaj ventila.
