# Pitanja za flow chart obe strane (BRB2 + PT_KB_V01)

> Upiši odgovore direktno ispod svakog pitanja (na liniji `Odgovor:`).
> Ono što još nisi odlučio ostavi prazno — o tome ćemo posle razgovarati.
> Kad završiš, samo javi "spremno".

---

## FAZA 3: PT_KB_V01 STRANA, GRANA BRB2

### 3.1 `PG_01_Priprema_BRB2`

Šta se sve mora desiti pre nego što Podstanica "objavi" da je spremna za BRB2 (dozvola BRB2 startu)?

**a) Koji ventili se otvaraju/zatvaraju u pripremi?**
(npr. PG_V01 dolazni od BRB2, PG_V02 ka tanku, PG_V03/PG_V04 na izlazu iz tanka — koji od ovih se dira ovde?)

Odgovor: pojsanio u drugom fajlu

**b) Koja pumpa izlaza iz tanka (Pu_PG_01 ili Pu_PG_02) se startuje u pripremi ili tek u fazi Rad_BRB2?**

Odgovor: sve pojasnjeno kada je tank u rau pupa se pali kad nivo predje preko 1.5 metara a gasi kada nivo padne ispod 0.9 metara - ako odrzava nivo ako odzava pritisak ne interesuje je nivo dok ne padne ispod miniumam onda krece da odrzava taj minimalni nivo 

**c) Ima li provera pritiska/temperature pre nego što se izađe iz Priprema?**

Odgovor:odgovrio u drugom fajlu

**d) Koji "OK" signal Podstanica šalje BRB2 strani preko IMA (npr. `PG.Status.SpremanZaBrb2 : BOOL`) — i šta znači?**

Odgovor:odgovreno ranije

---

### 3.2 `PG_02_Rad_BRB2`

Šta radi Podstanica dok BRB2 aktivno gura vodu?

**a) Koja pumpa izlaza iz tanka radi (Pu_PG_01 default? auto rotacija? manual?)**

Odgovor:odogovreno vec

**b) Za trenutno aktivnu Varijantu 2 (BRB2 vodi, PG samo prazni tank do nivoa):**
Koji je "nivo" za regulaciju? Nivo tanka (LT_ senzor)? Pritisak potisa PG pumpe? Nešto treće?

Odgovor:odgovoreno

**c) Šta se dešava sa Varijantom 1 (PG vodi, prati pritisak):**
Ako je aktivna, da li PG šalje "traži više/manje" komandu BRB2 strani preko IMA?

Odgovor:odgovoreno - salje samo nivo i status

**d) Da li se PG_V03/PG_V04 preključuju u toku rada (rotacija pumpe za istrošivost)?**

Odgovor: verovatnio resavacemo kasnije

---

### 3.3 `PG_03_Zaustavljanje_BRB2`

Šta radi Podstanica kada operater (ili sistem) povuče izvor (`SelektovaniIzvor = _00_`)?

**a) Da li Podstanica prvo zaustavlja svoju izlaznu pumpu, pa BRB2 pumpu? Ili obratno? Ili paralelno?**

Odgovor:odgovoreno

**b) Ventili koji se zatvaraju u ovoj fazi — redosled?**

Odgovor: odgovreno ranije

**c) Kada je Zaustavljanje "završeno" — koji su uslovi za povratak u Stand_By?**
(svi ventili zatvoreni? pumpe stopped? pritisak spao ispod X bar?)

Odgovor:odgovreno ranije

---

## FAZA 3.5: PRELAZ Pu_PG_01 ↔ Pu_PG_02

**3.5.a Kako se odlučuje koja pumpa je aktivna?**
Označi ono što važi (obriši ostalo, ili kombinuj):
- [ ] manual (operater sa HMI)
- [ ] auto rotacija po vremenu rada
- [ ] auto rotacija po broju startovanja
- [ ] fallback na drugu ako prva ima alarm
- [ ] kombinacija (dopiši kakva)

Odgovor:odgovreno ranije

**3.5.b Prelaz mora imati "overlap" (obe pumpe rade kratko) ili "hard switch" (jedna se ugasi pre nego druga krene)?**

Odgovor:odgovreno ranije

**3.5.c Ventili PG_V03/PG_V04 — da li se ikad obe drže zatvorene (npr. dok pumpe stoje) ili je barem jedan uvek otvoren?**

Odgovor:odgovreno ranije

---

## FAZA 2: BRB2 STRANA, IEBKB1 GRANA (B25 / B35 / B45)

**2.a Da li je logika ista kao Hotel grana (isti ramp, isti pritisci) samo drugi ventili (RB1_V01 vs RB1_V02, RB2_V01 vs RB2_V02)?**

Odgovor:odgovreno ranije

**2.b Ako je različita — šta se razlikuje?**
(npr. drugi `P_Target`, drugi flush režim, drugi `FR_RampUp`)

Odgovor:nista

**2.c Ispiranje (`IspiranjeAktivno` + PG_PV05) — da li se izvodi za obe grane isto ili samo za Hotel?**

Odgovor:odgovreno ranije

---

## FAZA 4: PT_KB_V01 STRANA, GRANA IEBKB1

**4.a Postoji li već legacy kod (u nekom projektu koji nam nije trenutno otvoren) koji rukuje IEBKB1 stranom sa PT_KB_V01 tačke?**

Odgovor:odgovreno ranije

**4.b Ako ne, samo skiciraj u par rečenica šta se treba desiti (u kojoj se meri razlikuje od BRB2 grane).**

Odgovor:odgovreno ranije

---

## FAULT / PREKIDNE PUTANJE

**F.a Ako se javi kritični fault (npr. LT tanka izgubljen, flow meter izgubljen) u toku `Rad_BRB2` — da li:**
- [ ] sistem preskače direktno u `Zaustavljanje_BRB2` sa normalnom sekvencom
- [ ] postoji zaseban Fault step (`PG_99_Fault`) sa agresivnim gašenjem
- [ ] operater mora ručno da povuče izvor pa da krene normalno gašenje

Odgovor:odgovreno ranije

**F.b Ista pitanja za BRB2 stranu (fault tokom `B30_RadBrb2Hotel`):**

Odgovor:odgovreno ranije

---

## BONUS PITANJE ZA MAPIRANJE

**M.a Da li već imaš fizički nacrtan PID/PFD dijagram procesa (PDF/DWG/scan) koji ti mogu pogledati radi validacije naziva ventila i tokova?**
Ako da, gde ga mogu naći?

Odgovor:odgovreno ranije
