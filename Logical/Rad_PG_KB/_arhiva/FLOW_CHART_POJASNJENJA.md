# Pojašnjenja pre finalnih flow chart-ova

> 6 kratkih pitanja koja su izronila iz tvojih odgovora.
> Popuni pored svakog, snimi, i javi „spremno".

---

## P1. PG_V06 / PG_V07 — potvrda semantike

Iz odgovora zaključujem:
- **PG_V06** = ON/OFF ventil PRE proporcionalnog **PG_PV01**
- **PG_V07** = ON/OFF ventil PRE proporcionalnog **PG_PV02**

Da li je to tačno? Ako nije, kako se zovu i za šta služe?

Odgovor: da tacno je

---

## P2. PG_PV05 — dvostruka uloga?

Do sada je `PG_PV05` bio pomenut kao proporcionalni ventil za **ispiranje/drenažu** (na BRB2 strani, `IspiranjeAktivno`).

Ali sada u odgovoru za pripremu BRB2 kažeš: „pušta se bunar dok voda **na drenaži iza PG_PV05** ne dođe do ~60°C".

Da li je to isti PG_PV05, ili postoji poseban drenažni put? Da li se u pripremi otvara `PG_PV05` na drenažu prema kojem procenatu?

Odgovor:da to je isti venti i on radi isto sto i ventili na ulaz u tank odrzava poritisak na potisu iz BRB2 preko 5 bara uvek ... osim kad su aktivni vetili na ulazu u tank tada on odrzava pritisak na 6 ilio 7 bara i cuva iouzmenjivace i celu liniju od velikog pritiska

---

## P3. Signal PG → BRB2 preko IMA

Šta sve konkretno PG šalje BRB2 strani preko IMA (i obratno)?

Trenutno pretpostavljam PG → BRB2:
- `SpremanZaBrb2 : BOOL`
- `NivoTanka : REAL`
- `RegulacionaVarijanta : E_RegulacionaVarijanta`
- `SelektovaniIzvor : E_SelektovaniIzvor` (ogledalo)

BRB2 → PG:
- `Pt_6_Pressure : REAL` (pritisak dolazne cevi, čita se lokalno u BRB2)
- `Pu_Aktivna : BOOL` (BRB2 pumpa aktivna)
- `FR_Actual : REAL` (trenutna frekvencija BRB2 pumpe)
dodaj i protok ka hotelu
mada je meni ovde biola ideja da se salje sve na obe strane takod a mozes da pridjes izuelizaciji i da ividis i jednu i drugu stranu ....
jer ima protokol je mocan a mi imamo optiku nista necemo ugroziti a dacemo lepu komciju u radu na terenu 

Fali/suvišno/preimenovati?

Odgovor: dat gore

---

## P4. Aktivna pumpa BRB2

Rekao si: "postoji logika u kodu kako pumpa radi kada je sistem aktivan, pogledaj, jednostavno je i imaš već i parametre unutra — javi šta si našao".

Našao sam ove parametre u `BRB2_1/Logical/Project/BRB2_rad/Types.typ`:

```
FR_Start        : REAL := 20.0;  (* startna frekvenca [Hz] *)
FR_RampUp       : REAL := 0.5;   (* ramp up [Hz/s] *)
FR_RampDown     : REAL := 0.25;  (* ramp down [Hz/s] *)
T_Zaletanje     : TIME := T#10s; (* pre pocetka podizanja *)
P_Target        : REAL := 5.0;   (* ciljni pritisak Pt_RB2_2 [bar] *)
P_TargetStop    : REAL := 5.2;   (* stop pritisak [bar] *)
FR_MinZeroFlow  : REAL := 0.0;   (* TODO eksperimentalno *)
MinProtok       : REAL;          (* Var1 donja granica *)
MaxProtok       : REAL;          (* Var1 gornja granica *)
SetProtok       : REAL := 6.0;   (* Var2 zadati protok [l/s] *)
```

**Ali gore si u odgovoru 3.1.b rekao "samo treba da se pali selektovana pumpa, sad radi logika samo na pumpu koja je povezana"** — ovo se odnosi na **BRB2 pumpu** (jedna pumpa) ili na **PG izlaz pumpu** (Pu_PG_01/Pu_PG_02)?

Odgovor: odnosi se na PG 01/02

---

## P5. Auto-restart posle nestanka struje

Ovo je važno za dizajn. Predlog:

Kada se PLC probudi:
- `State := PG_00_Stand_By` (uvek?)
- Ili: pročitaj RETAIN `SelektovaniIzvor` i idi u odgovarajući step ako je bio aktivan?

Ako je bio aktivan (npr. `SelektovaniIzvor = _01_BRB2` pre nestanka struje), da li:

- [ ] auto-vrati sistem u `PG_02_Rad_BRB2` bez ponovne pripreme (rizik: ventili u nepoznatom stanju)
- [ ] prođi kroz `PG_01_Priprema_BRB2` sa svim proverama pa u `PG_02_Rad_BRB2`
- [ ] uđi u posebno **Recovery** stanje koje polako obnavlja proces sa proverama pritisaka

Odgovor: vracas se us tanje stand By i pokreces sistem sa preselektovanim ocijama 
ne zatvaras PG_PV02 jer se nemanja izvor npr ...

---

## P6. PID dijagram — ponovo pošalji

Rekao si da si mi već poslao PID dijagram. Ako je bio u prethodnoj sesiji, nemam ga trenutno pri ruci.

Molim te:
1. Ubaci ga u chat **kao attachment (slika)** — direktno ću ga pročitati i validirati imena ventila
2. ILI ga stavi u fajl u projektu i reci mi putanju

Odgovor / putanja:

---dodao u prilog

## Šta ću uraditi paralelno (bez čekanja)

Dok odgovaraš, ja radim ovo:

1. **Dodajem `E_AktivniPropVentilUlazTanka` u `typCtrlPG_KB`** (analogno `AktivnaPumpaIzlazTanka`).
2. **Dodajem `SetPointNivoTanka : REAL := 1.5` u `typParPG_KB`**.
3. Pravim **`FLOW_CHART_MASTER.md`** sa mermaid dijagramima:
   - Nadgradnja PG_KB state masine (isti tvoj E_PG_KB_State ali sada sa svim substepima)
   - Isto za BRB2_rad (E_BRB2_State — proširenje trenutnog SFC-a u ST logiku)
   - Sekvenca komunikacije PG↔BRB2 preko IMA
   - Fault putanja + Recovery putanja

Kada odgovoriš na P1–P6, dopunjujem sve rupe i dobijamo finalni dokument koji je „ground truth" za dalju implementaciju.
