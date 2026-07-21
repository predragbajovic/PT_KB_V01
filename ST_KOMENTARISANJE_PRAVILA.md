# ST Komentarisanje - Projektni Dodatak (PT_KB_V01)

Poslednje azuriranje: 21.07.2026.

## 1) Svrha i vazenje

Ovaj dokument je projektni dodatak za PT_KB_V01 i nasledjuje workspace standard:
- [ST_KOMENTARISANJE_WORKSPACE_PRAVILA.md](../ST_KOMENTARISANJE_WORKSPACE_PRAVILA.md)

Projektni dokument definise samo lokalne specifičnosti koje dopunjuju workspace pravila.

## 2) Obavezna projektna pravila

1. Sve opste norme, format sekcija i kontrolne liste vaze iz workspace standarda.
2. Komentar mora opisivati implementirano ponasanje PT_KB_V01 logike (ne planirano ponasanje).
3. Za fizicki bitne sekcije navesti oznaku objekta (Pt, Tt, MP, LS, AV, RV, PV, Pu) i jedinicu.
4. U komentarima za clamp/fallback navesti realan opseg iz koda (npr. razliciti clamp opsezi Pu._1 i Pu._2).
5. Ako se menja mapiranje FB tipova (npr. AV._1/_2), komentari i sekcijski naslovi se azuriraju u istoj izmeni.

## 3) Lokalni kontekst projekta

1. PT_KB_V01 koristi taskove:
- [PT_KB_V01/Logical/IO/Init.st](PT_KB_V01/Logical/IO/Init.st)
- [PT_KB_V01/Logical/IO/Cyclic.st](PT_KB_V01/Logical/IO/Cyclic.st)
- [PT_KB_V01/Logical/IO/Exit.st](PT_KB_V01/Logical/IO/Exit.st)
- [PT_KB_V01/Logical/PID_Pu_01/Init.st](PT_KB_V01/Logical/PID_Pu_01/Init.st)
- [PT_KB_V01/Logical/PID_Pu_01/Cyclic.st](PT_KB_V01/Logical/PID_Pu_01/Cyclic.st)
- [PT_KB_V01/Logical/PID_Pu_01/Exit.st](PT_KB_V01/Logical/PID_Pu_01/Exit.st)

2. Dokument je namenjen kao lokalni dodatak; za nove projekte prvo se koristi workspace standard, pa se dodaju samo potrebna lokalna pravila.
