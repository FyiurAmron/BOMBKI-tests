#!/usr/bin/env python3
"""Generate the level-up scenario for BOMBKI.PAS's ZdobadzPoziom.

ZdobadzPoziom runs once per main-loop pass, at the top of the
repeat block, before the room handlers. A room handler loops on
ReadLn until MIECHO changes, so commands typed inside one room
never start a new pass. MODE then UNMODE is enough to force
exactly one more pass without leaving the room: MODE sets
MIECHO2 to the current room and MIECHO to 1000, which ends the
room's loop and drops into the ground block; UNMODE restores
MIECHO from MIECHO2, so the ground block ends, the loop
restarts, ZdobadzPoziom runs, and the room dispatches again.

DAWAJ KUNSZT lives only in room 86, which sits behind the
DRZWI, so the prefix has to cross that door once. It escapes
rather than fights them: WALKA waits two seconds per round, so
winning costs about eighty rounds while fleeing costs a
handful. UFOK is used because CWICZ UCIEKAC needs MAD > 10 and
ZRE > 10, and UFOK reaches both cheaply; ZWIEJ sets WIMP, which
the flee check needs (ENERGIA < WIMP) and which defaults to
zero.

The thresholds are read from the reconstructed source rather
than hard-coded, so the route always matches the code.
"""
import json
import re
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[1]
OUT = PROJECT / "tests" / "scenarios"
PROMPT = r"[0-9]+%\.-?[0-9]+>"

DOOR = "DO DOBRA WYGLADA TO NA JAKIS DOM"
DARK = "DOBRA JESTES W SRODKU BRAK OSWIETLENIA"
BANNER = "ZDOBYLES LEVEL"
TWELFTH = "HURRRA TO JUZ DWUNASTY POZIOM"


def thresholds() -> dict[int, int]:
    """KUNSZT needed to advance from each level, read from source.

    These come from the gate at the top of ZdobadzPoziom, not
    from the KUNSZT subtraction in the body: the two differ (level
    one gates at 700 but subtracts 725).
    """
    src = (PROJECT / "_reconstructed" / "BOMBKI.PAS").read_text()
    gate = re.search(
        r"if \(KUNSZT < (\d+)\) or \(POZIOM <> 1\) then\s*"
        r"if \(KUNSZT < (\d+)\) or \(POZIOM <> 2\) then\s*"
        r"if \(KUNSZT < (\d+)\) or \(POZIOM <> 3\) then\s*"
        r"if \(\(735 \+ POZIOM\) > KUNSZT\) or \(POZIOM <= 3\) "
        r"or \(POZIOM >= 9\) then begin\s*"
        r"if POZIOM <= 8 then Exit;\s*"
        r"if \(735 \+ POZIOM \+ POZIOM\) > KUNSZT then Exit;", src)
    if gate is None:
        raise RuntimeError("level-up gate not found in BOMBKI.PAS")
    one, two, three = (int(gate.group(i)) for i in (1, 2, 3))

    def need(level: int) -> int:
        if level == 1:
            return one
        if level == 2:
            return two
        if level == 3:
            return three
        if level < 9:
            return 735 + level
        return 735 + level + level
    return {n: need(n) for n in range(1, 30)}


def main() -> None:
    need = thresholds()
    target = 14
    # One grant per visit is not enough for the 700+ thresholds,
    # so give each visit enough grants to clear that level, then
    # leave and come back to force the next pass.
    steps: list[dict] = [
        {"label": "intro tick", "expect": "TICK !!!", "send": ""},
        {"label": "race prompt", "expect": "NAPISZ SWA RASE", "send": "UFOK"},
        {"label": "player-name prompt", "expect": "PODAJE SWE IMIE",
         "send": "TESTER"},
        {"label": "startup key read",
         "expect": "ABY SIE PATRZEC UZYJ KOMENDY PATRZ", "send": ""},
        {"label": "first room", "expect": f"TU ZACZYNA SIE GRE[\\s\\S]*?{PROMPT}",
         "send": "POLNOC"},
        {"label": "round salon", "expect": f"JESTES W OKROGLYM SALONIE[\\s\\S]*?{PROMPT}",
         "send": "WSCHOD"},
        {"label": "strength room", "expect": f"JESTES W POKOJU GDZIE RAMBO TRENUJE[\\s\\S]*?{PROMPT}",
         "send": "TRENUJ ZRECZNOSC"},
        {"label": "train agility to 10", "expect": f"TRENUJESZ ZRECZNOSC I MASZ 10 ZRECZNOSCI[\\s\\S]*?{PROMPT}",
         "send": "TRENUJ ZRECZNOSC"},
        {"label": "train agility to 11, past the ZRE > 10 gate",
         "expect": f"TRENUJESZ ZRECZNOSC I MASZ 11 ZRECZNOSCI[\\s\\S]*?{PROMPT}",
         "send": "ZACHOD"},
        {"label": "back to the salon", "expect": f"JESTES W OKROGLYM SALONIE[\\s\\S]*?{PROMPT}",
         "send": "DOL"},
        {"label": "meditation room", "expect": f"ZSZEDLES NA DOL GDZIE TRENUJE[\\s\\S]*?{PROMPT}",
         "send": "CWICZ UCIEKAC"},
        {"label": "learn fleeing", "expect": f"CWICZYSZ UCIEKANIE[\\s\\S]*?{PROMPT}",
         "send": "GORA"},
        {"label": "back at the salon", "expect": f"JESTES W OKROGLYM SALONIE[\\s\\S]*?{PROMPT}",
         "send": "POLNOC"},
        {"label": "city centre", "expect": f"JESTES W CENTRUM MIASTA[\\s\\S]*?{PROMPT}",
         "send": "WSCHOD"},
        {"label": "dark street", "expect": f"JESTES NA ULICY CIEMNEJ[\\s\\S]*?{PROMPT}",
         "send": "POLODNIE"},
        {"label": "bluszcz", "expect": f"ZNALAZLES SIE WSROD BLUSZCZU[\\s\\S]*?{PROMPT}",
         "send": "POLODNIE"},
        {"label": "flower thicket", "expect": f"CHOC TO MALO PRAWDOPODOBNE[\\s\\S]*?{PROMPT}",
         "send": "POLODNIE"},
        {"label": "bluszcz clearing", "expect": f"\\.\\.\\.\\.\\.\\.\\. PIERDUT[\\s\\S]*?{PROMPT}",
         "send": "ZACHOD"},
        {"label": "cave entrance", "expect": f"TO CIEKAWE ZE WCZESNIEJ[\\s\\S]*?{PROMPT}",
         "send": "ZACHOD"},
        {"label": "living door, DRZWI bar the way",
         "expect": f"{DOOR}[\\s\\S]*?TE DRZWI ZYJA[\\s\\S]*?NIE WPUSZCZE[\\s\\S]*?{PROMPT}",
         "send": "MODE"},
        {"label": "ground prompt in the living-door room",
         "expect": PROMPT, "send": "ZWIEJ"},
        {"label": "flee threshold prompt",
         "expect": r"PONIZEJ ILU ENERGII CHCESZ UCIEKAC\?", "send": "500"},
        {"label": "threshold set above current energy", "expect": PROMPT,
         "send": "DAWAJ EN"},
        {"label": "energy topped to keep ENERGIA < WIMP", "expect": PROMPT,
         "send": "DAWAJ EN"},
        {"label": "energy 450", "expect": PROMPT, "send": "UNMODE"},
        {"label": "back at the living door",
         "expect": f"{DOOR}[\\s\\S]*?TE DRZWI ZYJA[\\s\\S]*?{PROMPT}",
         "send": "ZABIJ DRZWI"},
        {"label": "escape the fight",
         "expect": f"[\\s\\S]*?WSTYD !!! UCIEKLES Z POLA BITWY[\\s\\S]*?{PROMPT}",
         "send": "ZACHOD"},
        {"label": "past the DRZWI into the dark room",
         "expect": f"{DARK}[\\s\\S]*?STARUCHA[\\s\\S]*?{PROMPT}",
         "send": "DAWAJ KUNSZT"},
    ]

    level = 1
    visit = 0
    twelfth_step = None
    while level < target:
        visit += 1
        threshold = need[level]
        grants = -(-threshold // 500)
        # Every visit's first grant is the previous visit's trailing
        # banner step (or the room entry for visit 1), so only the
        # remaining grants - 1 are emitted here.
        for index in range(1, grants):
            steps.append({"label": f"visit {visit}: grant {index + 1}/{grants}",
                          "expect": PROMPT, "send": "DAWAJ KUNSZT"})
        # MODE then UNMODE: one extra main-loop pass, so
        # ZdobadzPoziom re-reads the gate without leaving the room.
        #
        # The harness matches each step's expect against the output
        # of the *previous* step's send, so an expect lags its own
        # send by one. MODE's output is just the ground prompt, and
        # UNMODE's output is where the banner lands, so the banner
        # belongs on the step after UNMODE - which is the next
        # visit's first grant.
        steps.append({"label": f"visit {visit}: MODE to leave the room",
                      "expect": PROMPT, "send": "MODE"})
        steps.append({"label": f"visit {visit}: UNMODE to force the pass",
                      "expect": PROMPT, "send": "UNMODE"})
        banner_step = {
            "label": f"visit {visit}: level-up banner, "
                     f"then grant 1/{grants} for level {level + 1}",
            "expect": BANNER, "send": "DAWAJ KUNSZT"}
        # This pass takes the character from level 11 to 12, which
        # is where the level-12 block prints.
        if level == 11:
            twelfth_step = banner_step
        steps.append(banner_step)
        level += 1

    # The level-12 block prints inside the banner of the pass that
    # reaches level 12 (visit 12 levels 11 -> 12), so that step
    # asserts both. WYJSCIE ends the game, so it is the last send
    # and nothing follows it.
    if twelfth_step is not None:
        twelfth_step["label"] = ("visit 12: level-up banner with the "
                                 "twelfth-level block")
        twelfth_step["expect"] = f"{BANNER}[\\s\\S]*?{TWELFTH}[\\s\\S]*?MASZ TERAZ"
    steps.append({"label": "leave the room at the end",
                  "expect": PROMPT, "send": "WYJSCIE"})

    path = OUT / "level-up-smoke.json"
    path.write_text(json.dumps({"steps": steps}, indent=2) + "\n",
                    encoding="utf-8")
    print(f"{path.name}: {len(steps)} steps, {visit} visits, "
          f"levels 1..{target}, thresholds "
          f"{[need[n] for n in range(1, target)]}")


if __name__ == "__main__":
    main()
