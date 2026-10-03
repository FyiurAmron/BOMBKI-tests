program test_przedm;
{Unit tests for PRZEDM: the deterministic, terminal-free
procedures (state machines, stat arithmetic, item
handling). Each test sets up the PRZEDM globals it
reads, so the tests are order-independent and safe to
run one per process.}
uses bkitest, MONSTRA, PRZEDM;

procedure TestMode;
begin
  MIECHO := 42;
  MODE;
  CheckEqual(42, MIECHO2, 'MODE saves MIECHO into MIECHO2');
  CheckEqual(1000, MIECHO, 'MODE switches MIECHO to 1000');
end;

procedure TestKomendy;
begin
  wpisz := 'PN'; KOMENDY;
  CheckStrEqual('POLNOC', wpisz, 'PN expands to POLNOC');
  wpisz := 'PD'; KOMENDY;
  CheckStrEqual('POLODNIE', wpisz, 'PD expands to POLODNIE');
  wpisz := 'W'; KOMENDY;
  CheckStrEqual('WSCHOD', wpisz, 'W expands to WSCHOD');
  wpisz := 'Z'; KOMENDY;
  CheckStrEqual('ZACHOD', wpisz, 'Z expands to ZACHOD');
  wpisz := 'G'; KOMENDY;
  CheckStrEqual('GORA', wpisz, 'G expands to GORA');
  wpisz := 'D'; KOMENDY;
  CheckStrEqual('DOL', wpisz, 'D expands to DOL');
  wpisz := 'E'; KOMENDY;
  CheckStrEqual('EXIT', wpisz, 'E expands to EXIT');
  wpisz := 'M'; KOMENDY;
  CheckStrEqual('MODE', wpisz, 'M expands to MODE');
  wpisz := 'POLNOC'; KOMENDY;
  CheckStrEqual('POLNOC', wpisz, 'full command passes through KOMENDY');
end;

procedure TestTrainSila;
begin
  SIL := 10; MAXSIL := 20; PRA := 10; wpisz := 'TRENUJ SILA';
  TRAIN;
  CheckEqual(11, SIL, 'TRENUJ SILA raises SIL by one');
  CheckEqual(7, PRA, 'TRENUJ SILA spends three PRA');
end;

procedure TestTrainZrecznosc;
begin
  ZRE := 10; MAXZRE := 20; PRA := 10; wpisz := 'TRENUJ ZRECZNOSC';
  TRAIN;
  CheckEqual(11, ZRE, 'TRENUJ ZRECZNOSC raises ZRE by one');
  CheckEqual(8, PRA, 'TRENUJ ZRECZNOSC spends two PRA');
end;

procedure TestTrainMadrosc;
begin
  MAD := 10; MAXMAD := 20; PRA := 10; wpisz := 'TRENUJ MADROSC';
  TRAIN;
  CheckEqual(11, MAD, 'TRENUJ MADROSC raises MAD by one');
  CheckEqual(7, PRA, 'TRENUJ MADROSC spends three PRA');
end;

procedure TestTrainNeedsPracticePoints;
begin
  SIL := 10; MAXSIL := 20; PRA := 2; wpisz := 'TRENUJ SILA';
  TRAIN;
  CheckEqual(10, SIL, 'TRENUJ SILA refuses with two PRA');
  CheckEqual(2, PRA, 'TRENUJ SILA spends nothing with two PRA');
end;

procedure TestTrainCapsAtMaximum;
begin
  SIL := 20; MAXSIL := 20; PRA := 10; wpisz := 'TRENUJ SILA';
  TRAIN;
  CheckEqual(20, SIL, 'TRENUJ SILA stops at MAXSIL');
  CheckEqual(10, PRA, 'TRENUJ SILA spends nothing at MAXSIL');
end;

procedure TestPotworyRanges;
begin
  POTWORY;
  { Random(38) + 20 redrawn until above 32: [33, 57]. }
  CheckRange('BAKTERIA', BAKTERIA, 33, 57);
  CheckRange('SLIMAK', SLIMAK, 33, 57);
  CheckRange('ZUK', ZUK, 33, 57);
  CheckRange('KARALUCH', KARALUCH, 33, 57);
  CheckRange('MROWKA', MROWKA, 33, 57);
  CheckRange('PAJAK', PAJAK, 33, 57);
  CheckRange('DZIK', DZIK, 33, 57);
  CheckRange('LIS', LIS, 33, 57);
  CheckRange('SZCZUR', SZCZUR, 33, 57);
  CheckRange('KUROPATWA', KUROPATWA, 33, 57);
  CheckRange('SARNA', SARNA, 33, 57);
  CheckRange('ORZEL', ORZEL, 33, 57);
  CheckRange('ZAJAC', ZAJAC, 33, 57);
  CheckRange('WILCZUR', WILCZUR, 33, 57);
  CheckRange('KORNIK', KORNIK, 33, 57);
  CheckRange('MUCHA', MUCHA, 33, 57);
  CheckRange('SLON', SLON, 33, 57);
  CheckRange('LEW', LEW, 33, 57);
  CheckRange('ZYRAFA', ZYRAFA, 33, 57);
  CheckRange('WIELBLAD', WIELBLAD, 33, 57);
  CheckRange('STRUS', STRUS, 33, 57);
  CheckRange('BOA', BOA, 33, 57);
  CheckRange('WILK', WILK, 33, 57);
  CheckRange('BIZON', BIZON, 33, 57);
  CheckRange('PANTERA', PANTERA, 33, 57);
  CheckRange('GLADIATOR', GLADIATOR, 33, 57);
  CheckRange('WOJOWNIK', WOJOWNIK, 33, 57);
  CheckRange('TRENER', TRENER, 33, 57);
  { Random(7) + 60 redrawn until above 60: [61, 66]. }
  CheckRange('DZIECKO', DZIECKO, 61, 66);
  CheckRange('REPORTER', REPORTER, 61, 66);
  { Random(8) + 60 redrawn until above 60: [61, 67]. }
  CheckRange('WARIAT', WARIAT, 61, 67);
  CheckRange('SLUCHACZ', SLUCHACZ, 61, 67);
  CheckRange('FAN', FAN, 61, 67);
  CheckRange('CZLOWIEK', CZLOWIEK, 61, 67);
  CheckRange('DZIADEK', DZIADEK, 61, 67);
  { Random(9) + 60 redrawn until above 60: [61, 68]. }
  CheckRange('POLICJANT', POLICJANT, 61, 68);
  CheckRange('OCHRONIARZ', OCHRONIARZ, 61, 68);
  CheckRange('GORYL', GORYL, 61, 68);
  { Random(3) + 70, drawn once: [70, 72]. }
  CheckRange('GITARZYSTA', GITARZYSTA, 70, 72);
  CheckRange('PERKUSISTA', PERKUSISTA, 70, 72);
  CheckRange('ORGANISTA', ORGANISTA, 70, 72);
  CheckRange('LIROY', LIROY, 70, 72);
  { Fixed constants from POTWORY. }
  CheckEqual(67, MONSTRA.MINIBARMAN, 'MINIBARMAN is 67');
  CheckEqual(67, MONSTRA.GRUBAS, 'GRUBAS is 67');
  CheckEqual(69, MONSTRA.DJ, 'DJ is 69');
  CheckEqual(76, MONSTRA.PEDAL, 'PEDAL is 76');
  CheckEqual(76, MONSTRA.PARA, 'PARA is 76');
  CheckEqual(76, MONSTRA.MACIEK, 'MACIEK is 76');
  CheckEqual(1, MONSTRA.DRZWI, 'DRZWI is 1');
  CheckEqual(1, MONSTRA.STARUCH, 'STARUCH is 1');
  { Random(7) + 20, condition always true: [20, 26]. }
  CheckRange('JAMNIK', MONSTRA.JAMNIK, 20, 26);
  CheckRange('OWCZAREK', MONSTRA.OWCZAREK, 20, 26);
  CheckRange('PIESEK', MONSTRA.PIESEK, 20, 26);
  CheckRange('SPANIEL', MONSTRA.SPANIEL, 20, 26);
  CheckRange('PUDEL', MONSTRA.PUDEL, 20, 26);
  CheckRange('TAKSOWKARZ', MONSTRA.TAKSOWKARZ, 20, 26);
  CheckRange('SPRZEDAWCA', MONSTRA.SPRZEDAWCA, 20, 26);
  CheckRange('ZAMIATACZ', MONSTRA.ZAMIATACZ, 20, 26);
  CheckRange('PIJAK', MONSTRA.PIJAK, 20, 26);
  CheckRange('ZEBRAK', MONSTRA.ZEBRAK, 20, 26);
  { Random(8) + 77 redrawn until below 84: [77, 83]. }
  CheckRange('SZCZAW', SZCZAW, 77, 83);
  CheckRange('STOKROTKA', STOKROTKA, 77, 83);
  CheckRange('KONICZYNKA', KONICZYNKA, 77, 83);
  CheckRange('MLECZ', MLECZ, 77, 83);
  CheckRange('DMUCHAWIEC', DMUCHAWIEC, 77, 83);
  CheckRange('ROZA', ROZA, 77, 83);
  CheckRange('OSET', OSET, 77, 83);
  CheckRange('MALINA', MALINA, 77, 83);
  { Random(8) + 77, not in the until condition: [77, 84]. }
  CheckRange('AGREST', AGREST, 77, 84);
  CheckRange('JEZYNA', JEZYNA, 77, 84);
  CheckRange('TRAWA', TRAWA, 77, 84);
  CheckRange('DUNCAN', DUNCAN, 77, 84);
end;

procedure TestTarczaAppliesShield;
begin
  { PRO at 100 forces the Random(100) roll to succeed. }
  WPYSK := 50; ILOSC := 30; PRO := 100;
  TARCZA;
  CheckEqual(20, WPYSK, 'TARCZA subtracts ILOSC from WPYSK');
end;

procedure TestTarczaClampsAtZero;
begin
  WPYSK := 10; ILOSC := 30; PRO := 100;
  TARCZA;
  CheckEqual(0, WPYSK, 'TARCZA clamps WPYSK at zero');
end;

procedure TestBraniePicksUpSword;
begin
  MIECHO2 := 7; MMIECZ := 7; PRZED := 0; wpisz := 'BIERZ STARY';
  BRANIE;
  CheckEqual(-10, MMIECZ, 'BIERZ STARY stores the sword as -10');
  CheckEqual(1, PRZED, 'BIERZ STARY counts one item');
end;

procedure TestBranieDropsSword;
begin
  MIECHO2 := 7; MMIECZ := -10; PRZED := 1; wpisz := 'ODRZUC STARY';
  BRANIE;
  CheckEqual(7, MMIECZ, 'ODRZUC STARY restores the sword marker');
  CheckEqual(0, PRZED, 'ODRZUC STARY uncounts the item');
end;

procedure TestBranieIgnoresMissingSword;
begin
  MIECHO2 := 7; MMIECZ := 0; PRZED := 0; wpisz := 'BIERZ STARY';
  BRANIE;
  CheckEqual(0, MMIECZ, 'BIERZ STARY needs the sword marker');
  CheckEqual(0, PRZED, 'BIERZ STARY counts nothing without the sword');
end;

procedure TestUzywaSerce;
begin
  SERCE := -10; ENERGIA := 10; MONSTRA.MAXE := 50; PRZED := 1;
  wpisz := 'UZYJ SERCE';
  UZYWANIE;
  CheckEqual(0, SERCE, 'UZYJ SERCE consumes the heart');
  CheckEqual(15, ENERGIA, 'UZYJ SERCE restores five energy');
  CheckEqual(0, PRZED, 'UZYJ SERCE uncounts the item');
end;

procedure TestUzywaSerceClampsAtMaxE;
begin
  SERCE := -10; ENERGIA := 48; MONSTRA.MAXE := 50; PRZED := 1;
  wpisz := 'UZYJ SERCE';
  UZYWANIE;
  CheckEqual(50, ENERGIA, 'UZYJ SERCE clamps energy at MONSTRA.MAXE');
end;

procedure TestUzywaKomplet;
begin
  KOMPLET := -10; JAKIEUB := ''; PRO := 0; CIALO := 0;
  wpisz := 'UZYJ KOMPLET';
  UZYWANIE;
  CheckEqual(7, PRO, 'UZYJ KOMPLET adds seven defense');
  CheckEqual(1, CIALO, 'UZYJ KOMPLET marks the body dressed');
  CheckStrEqual('SYF', JAKIEUB, 'UZYJ KOMPLET remembers the suit');
  wpisz := 'ODLORZ KOMPLET';
  UZYWANIE;
  CheckEqual(0, PRO, 'ODLORZ KOMPLET removes the defense');
  CheckEqual(0, CIALO, 'ODLORZ KOMPLET marks the body bare');
  CheckStrEqual('', JAKIEUB, 'ODLORZ KOMPLET forgets the suit');
end;

procedure TestUzywaKompletWorn;
begin
  KOMPLET := -10; JAKIEUB := 'SYF'; PRO := 0; CIALO := 1;
  wpisz := 'UZYJ KOMPLET';
  UZYWANIE;
  CheckEqual(0, PRO, 'UZYJ KOMPLET refuses while a suit is worn');
  CheckEqual(1, CIALO, 'UZYJ KOMPLET keeps the body dressed');
  CheckStrEqual('SYF', JAKIEUB, 'UZYJ KOMPLET keeps the worn suit');
end;

procedure TestUzywaGarnitur;
begin
  GARNITUR := -10; JAKIEUB := ''; ILOSC := 0; PRO := 0; FUKSROLL := 0;
  wpisz := 'UZYJ GARNITUR';
  UZYWANIE;
  CheckEqual(10, PRO, 'UZYJ GARNITUR adds ten defense');
  CheckEqual(1, ILOSC, 'UZYJ GARNITUR counts one armor layer');
  CheckEqual(15, FUKSROLL, 'UZYJ GARNITUR adds fifteen resistance');
  CheckStrEqual('GARNITUR', JAKIEUB, 'UZYJ GARNITUR remembers the suit');
  wpisz := 'ODLORZ GARNITUR';
  UZYWANIE;
  CheckEqual(0, PRO, 'ODLORZ GARNITUR removes the defense');
  CheckEqual(0, ILOSC, 'ODLORZ GARNITUR uncounts the armor layer');
  CheckEqual(0, FUKSROLL, 'ODLORZ GARNITUR removes the resistance');
  CheckStrEqual('', JAKIEUB, 'ODLORZ GARNITUR forgets the suit');
end;

procedure TestUzywaButelkaMany;
begin
  MBUTELKA := -10; MANA := 10; MAXMANA := 50; PRZED := 1;
  wpisz := 'UZYJ MALA BUTELKA MANY';
  UZYWANIE;
  CheckEqual(40, MANA, 'UZYJ MALA BUTELKA MANY restores thirty mana');
  CheckEqual(0, PRZED, 'UZYJ MALA BUTELKA MANY uncounts the item');
end;

procedure TestUzywaButelkaManyClampsAtMaxMana;
begin
  MBUTELKA := -10; MANA := 45; MAXMANA := 50; PRZED := 1;
  wpisz := 'UZYJ MALA BUTELKA MANY';
  UZYWANIE;
  CheckEqual(50, MANA, 'UZYJ MALA BUTELKA MANY clamps mana at MAXMANA');
end;

procedure TestNiszczyPrzepustke;
begin
  PRZEPUSTKA := -10; PRZED := 0; wpisz := 'ZNISZCZ PRZEPUSTKA';
  UZYWANIE;
  CheckEqual(0, PRZEPUSTKA, 'ZNISZCZ PRZEPUSTKA burns the pass');
  CheckEqual(1, PRZED, 'ZNISZCZ PRZEPUSTKA counts one item');
end;

procedure TestPatrzPrzepustke;
begin
  PRZEPUSTKA := -10; PRZED := 0; wpisz := 'PATRZ PRZEPUSTKA';
  UZYWANIE;
  CheckEqual(-10, PRZEPUSTKA, 'PATRZ PRZEPUSTKA keeps the pass');
  CheckEqual(0, PRZED, 'PATRZ PRZEPUSTKA counts nothing');
end;

procedure TestUzywaDyplom;
begin
  DYPLOM := -10; wpisz := 'UZYJ DYPLOM';
  UZYWANIE;
  CheckEqual(-10, DYPLOM, 'UZYJ DYPLOM keeps the diploma');
end;

procedure TestGarniturZyskInvariant;
begin
  GARNITUR := 50; PRZED := 0;
  GARNITURZYSK;
  CheckTrue((GARNITUR = 50) or (GARNITUR = 40),
    'GARNITURZYSK drops GARNITUR by ten or not at all');
  CheckTrue((PRZED = 0) or (PRZED = 1),
    'GARNITURZYSK counts at most one item');
end;

procedure TestPigulkaZyskInvariant;
begin
  PIGULKA := 50; PRZED := 0;
  PIGULKAZYSK;
  CheckTrue((PIGULKA = 50) or (PIGULKA = 40),
    'PIGULKAZYSK drops PIGULKA by ten or not at all');
  CheckTrue((PRZED = 0) or (PRZED = 1),
    'PIGULKAZYSK counts at most one item');
end;

procedure TestKasetaZyskInvariant;
begin
  kaseta := 50; MAXE := 0; PRO := 0; PRZED := 0; ZRE := 0;
  MIECHO := 20;
  KASETAZYSK;
  CheckTrue((kaseta = 50) or (kaseta = 40),
    'KASETAZYSK drops the cassette by ten or not at all');
  CheckTrue((MAXE = 0) or (MAXE = 5),
    'KASETAZYSK raises MAXE by five or not at all');
  CheckTrue((PRO = 0) or (PRO = -8),
    'KASETAZYSK lowers PRO by eight or not at all');
  CheckTrue((PRZED = 0) or (PRZED = 1),
    'KASETAZYSK counts at most one item');
  CheckTrue((ZRE = 0) or (ZRE = 1),
    'KASETAZYSK raises ZRE by one or not at all');
end;

procedure TestListekZyskInvariant;
begin
  LISTEK := 50; PRZED := 0; MAXMANA := 0; MIECHO := 20;
  LISTEKZYSK;
  CheckTrue((LISTEK = 50) or (LISTEK = 40),
    'LISTEKZYSK drops the leaf by ten or not at all');
  CheckTrue((PRZED = 0) or (PRZED = 1),
    'LISTEKZYSK counts at most one item');
  CheckTrue((MAXMANA = 0) or (MAXMANA = 40),
    'LISTEKZYSK raises MAXMANA by forty or not at all');
end;

procedure TestScrollPorZyskInvariant;
begin
  SCROLLPOR := 50; PRZED := 0; MIECHO := 20;
  SCROLLPORZYSK;
  CheckTrue((SCROLLPOR = 50) or (SCROLLPOR = 40),
    'SCROLLPORZYSK drops the scroll by ten or not at all');
  CheckTrue((PRZED = 0) or (PRZED = 1),
    'SCROLLPORZYSK counts at most one item');
end;

procedure TestScenaMessages;
begin
  MIECHO := 1;
  GITARZYSTA := 1; PERKUSISTA := 1; ORGANISTA := 1; LIROY := 1;
  SCENA;
  CheckEqual(1, MIECHO, 'SCENA leaves MIECHO unchanged');
end;

procedure TestTlumMessages;
begin
  MIECHO := 1;
  DZIECKO := 1; WARIAT := 1; SLUCHACZ := 1; FAN := 1;
  CZLOWIEK := 1; POLICJANT := 1; OCHRONIARZ := 1; GORYL := 1;
  DZIADEK := 1; REPORTER := 1;
  TLUM;
  CheckEqual(1, MIECHO, 'TLUM leaves MIECHO unchanged');
end;

procedure TestKtoMessages;
begin
  MIECHO := 1;
  KORNIK := 1; MUCHA := 1; BAKTERIA := 1; SLIMAK := 1; ZUK := 1;
  KARALUCH := 1; MROWKA := 1; PAJAK := 1; DZIK := 1; SZCZUR := 1;
  LIS := 1; KUROPATWA := 1; ZAJAC := 1; WILCZUR := 1; ORZEL := 1;
  SARNA := 1; SLON := 1; LEW := 1; ZYRAFA := 1; WIELBLAD := 1;
  STRUS := 1; BOA := 1; WILK := 1; BIZON := 1; PANTERA := 1;
  GLADIATOR := 1; WOJOWNIK := 1; TRENER := 1;
  KTO;
  CheckEqual(1, MIECHO, 'KTO leaves MIECHO unchanged');
end;

procedure TestUlSklepMessages;
begin
  MIECHO := 1;
  MONSTRA.JAMNIK := 1; MONSTRA.OWCZAREK := 1; MONSTRA.PIESEK := 1;
  MONSTRA.SPANIEL := 1; MONSTRA.PUDEL := 1;
  MONSTRA.TAKSOWKARZ := 1; MONSTRA.SPRZEDAWCA := 1;
  MONSTRA.ZAMIATACZ := 1; MONSTRA.PIJAK := 1; MONSTRA.ZEBRAK := 1;
  ULSKLEPIKOWA;
  CheckEqual(1, MIECHO, 'ULSKLEPIKOWA leaves MIECHO unchanged');
end;

procedure TestBluszczMessages;
begin
  MIECHO := 1;
  SZCZAW := 1; STOKROTKA := 1; KONICZYNKA := 1; MLECZ := 1;
  DMUCHAWIEC := 1; ROZA := 1; OSET := 1; JEZYNA := 1;
  AGREST := 1; MALINA := 1; TRAWA := 1; DUNCAN := 1;
  BLUSZCZ;
  CheckEqual(1, MIECHO, 'BLUSZCZ leaves MIECHO unchanged');
end;

begin
  RegisterTest('mode', TestMode);
  RegisterTest('komendy', TestKomendy);
  RegisterTest('train-sila', TestTrainSila);
  RegisterTest('train-zrecznosc', TestTrainZrecznosc);
  RegisterTest('train-madrosc', TestTrainMadrosc);
  RegisterTest('train-needs-pra', TestTrainNeedsPracticePoints);
  RegisterTest('train-caps-at-max', TestTrainCapsAtMaximum);
  RegisterTest('potwory-ranges', TestPotworyRanges);
  RegisterTest('tarcza-shield', TestTarczaAppliesShield);
  RegisterTest('tarcza-clamp', TestTarczaClampsAtZero);
  RegisterTest('branie-pickup', TestBraniePicksUpSword);
  RegisterTest('branie-drop', TestBranieDropsSword);
  RegisterTest('branie-ignores-missing', TestBranieIgnoresMissingSword);
  RegisterTest('uzywa-serce', TestUzywaSerce);
  RegisterTest('uzywa-serce-clamp', TestUzywaSerceClampsAtMaxE);
  RegisterTest('uzywa-komplet', TestUzywaKomplet);
  RegisterTest('uzywa-komplet-worn', TestUzywaKompletWorn);
  RegisterTest('uzywa-garnitur', TestUzywaGarnitur);
  RegisterTest('uzywa-butelka-many', TestUzywaButelkaMany);
  RegisterTest('uzywa-butelka-many-clamp',
    TestUzywaButelkaManyClampsAtMaxMana);
  RegisterTest('niszczy-przepustke', TestNiszczyPrzepustke);
  RegisterTest('patrz-przepustke', TestPatrzPrzepustke);
  RegisterTest('uzywa-dyplom', TestUzywaDyplom);
  RegisterTest('zysk-garnitur', TestGarniturZyskInvariant);
  RegisterTest('zysk-pigulka', TestPigulkaZyskInvariant);
  RegisterTest('zysk-kaseta', TestKasetaZyskInvariant);
  RegisterTest('zysk-listek', TestListekZyskInvariant);
  RegisterTest('zysk-scrollpor', TestScrollPorZyskInvariant);
  RegisterTest('scena-messages', TestScenaMessages);
  RegisterTest('tlum-messages', TestTlumMessages);
  RegisterTest('kto-messages', TestKtoMessages);
  RegisterTest('ulsklep-messages', TestUlSklepMessages);
  RegisterTest('bluszcz-messages', TestBluszczMessages);
  RunTests;
end.
