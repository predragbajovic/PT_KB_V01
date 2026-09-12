# Poslednje mikro-nejasnoće pre finalnog dijagrama

> Popuni pored svakog, snimi, javi "spremno" — pa krećem sa flow chartom.

---

## ISPRAVLJENO RAZUMEVANJE (posle korisnikovih korekcija)

- **PG_PV05** = proporcionalni ventil DIREKTNO na drenažnoj grani (nema ON/OFF ventila pre njega). Uloge:
  - početno **ispiranje** cevi (dok voda ne postigne 60°C na drenaži)
  - **zaštita od hidrauličkih udara** / rasterećenje visokog pritiska (prag ~6.5 bar)
- **PG_V05** = ON/OFF ventil na potpuno posebnoj **bypass grani** za IEBKB1 mod (zaobilazi PG_PV01/PV02, pušta direktno u tank). NEMA VEZE sa PG_PV05.

Topologija:
```
                          ┌── PG_PV05 ──> DRENAŽA
BRB2 ulaz ──> PG_V02 ─────┼── PG_V06 ──> PG_PV01 ──> tank
                          └── PG_V07 ──> PG_PV02 ──> tank
                                                       ▲
IEBKB1 ulaz ──> PG_V01 ────────────> PG_V05 ───────────┘  (bypass)
```pg PV05 se odvaja pre dolaka BRB2 do PG_V02 pogledaj PID !!! ipravi to

---

## PZ1. Anti-udar prag za PG_PV05

Rekao si "6.5 bar". Interpretiram kao: kada pritisak u dolaznoj magistrali (posle PG_V02) pređe 6.5 bar, PG_PV05 se automatski otvara na drenažu radi rasterećenja.

Odgovor: 6.5 Bara

---

## PZ2. PG_V05 — ON/OFF ventil (iz IEBKB1 odgovora)

U odgovoru za IEBKB1 granu si rekao: "otvaraš PG_V01 i PG_V05".

Na PID-u vidim `PG_V05` blizu tanka. Da li je to:
- ON/OFF ventil iza PG_PV05 (posle proporcionalnog, pre ulaska u tank drugim putem)?
- ON/OFF ventil na bypass liniji koja u IEBKB1 modu zaobilazi PG_PV01/PV02?
- Nešto treće?

Kada se otvara PG_V05? U kom modu (samo IEBKB1? i BRB2 nekad?)

Odgovor: - ON/OFF ventil na bypass liniji koja u IEBKB1 modu zaobilazi PG_PV01/PV02?

---

## PZ3. Temperatura drenaže (60°C uslov)

Kada prelaziš sa IEBKB1 na BRB2, BRB2 bunar startuje i "izbacuje" hladnu vodu kroz drenažu dok ne postigne 60°C.

Pitanja:
- Gde je senzor temperature? Koje je ime PG_TT_XX?
- Kroz koji put ide drenaža — kroz PG_PV05 pa gde?
- Koji ventil se otvara na drenažu za vreme grejanja? (Da li je to `PG_V22` sa tanka? Ili nešto drugo?)
- Da li BRB2 pumpa radi u konstantnoj frekvenci tokom ove faze (npr. 20-30 Hz) ili prati neki cilj?

Odgovor: treba das e ugradi objasnio ranije gde se ugradjuje - nbegde na drenaznu cev gde moze da meri temperaturu bode u drenaznoj cevi
Kroz PV05 pa and renzani kanal ucrtano u PID-u i ta temperatura trba da bude SP koji se moze menjati
