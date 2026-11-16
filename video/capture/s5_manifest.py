#!/usr/bin/env python3
"""Writes video/out/raw/shots_s5.json from the segment 5 finals: durations by ffprobe, key moments from the
@@SHOT mark lines in each log (frames after rec_start / 60), descriptions and ratings below."""
import json, os, re, subprocess

RAW = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "out", "raw"))
# file stem: (kind, rating, description, {mark: label}, best_in, best_out or None (= end), notes)
S = {
 "s5_boss_sangkuriang": ("boss", 4, "Tangkuban Perahu crater: hero walks through the arena gate, gate seals, name card 'Sangkuriang - He who repeats one night for ever'. Dawn breaks (warm flash), he throws the Dawn Wrath: two rings of 27 burning shards with one gap; the hero stands in the gap, rolls to the next. Hero writes Sunda CA beside the hung cloth: the fake dawn stuns him.",
   {"engaged": "gate threshold, entrance starts", "card_done": "name card ends", "wrath_windup": "Dawn Wrath wind-up", "ring1": "first shard ring", "ring2": "second ring (hero rolled to the gap)", "cast_ca": "Sunda CA released: fake dawn, stun"}, 0.0, None,
   "Boss sprite is modest in size; the 130 px wrath telegraph circle is faint. Seep pools and gimmick hint on screen."),
 "s5_boss_bondowoso": ("boss", 3, "Mataram thousand temples: gate, name card 'Bandung Bondowoso - Builder of a thousand temples'. Pillars rise around him (shield). Thousand Temples: stone-spike lanes sweep twice, the hero rolls into the safe lane each time. Hero writes Jawa CA (dawn beat exposes pillars), runs in and strikes a pillar.",
   {"engaged": "gate threshold", "card_done": "name card ends", "temples": "Thousand Temples telegraph", "sweep1": "first spike sweep", "sweep2": "second sweep", "cast_ca": "Jawa CA released", "pillar_hit": "pillar struck"}, 0.0, 12.0,
   "Arena is a bare open field; lane telegraphs are thin. Strongest: the card and the spike-lane sweep (7-9 s). Pillar break is small."),
 "s5_boss_buto_ijo": ("boss", 4, "Tanah Timur field: gate, name card 'Buto Ijo - The giant who collects a promise' with his line. He spits a double fan of green seeds (hero rolls clear), then the Famine Maw: the hero rolls in under his belly, the only safe spot, as the ring erupts. Hero writes Jawa RA: a spirit tiger pounces on him.",
   {"engaged": "gate threshold", "card_done": "name card ends", "seeds": "seed volley wind-up", "maw": "Famine Maw wind-up", "maw_erupt": "maw erupts (hero hugging him)", "cast": "Jawa RA released: tiger"}, 0.0, None,
   "Famine Maw ring telegraph does not draw during its wind-up (only the eruption ring shows). Tiger summon has a white puff frame."),
 "s5_boss_kala": ("boss", 3, "Gua Kala chamber: gate, name card 'Batara Kala - Time, the hungry one' and 'The ruwatan was never finished. You have been mine since birth.' Phase 3: eclipse shield with its glyph sequence on the boss bar, the Ruwatan Eclipse (gold safe-spot rings, then eight violet slashes and a white flash) while the hero stands in the safe wedge. He kneels; the hero writes Jawa KA and he is calmed and fades (released, never killed).",
   {"engaged": "gate threshold", "card_done": "name card ends", "eclipse": "Ruwatan Eclipse wind-up", "eclipse_fall": "eclipse falls (violet wedges, flash)", "kneel": "Kala kneels", "calmed": "Jawa KA released: calmed, fades"}, 0.0, None,
   "The eight wedge telegraphs do not draw during the wind-up (only the gold safe-spot pulses); the fall itself reads. Kala's sprite is not much bigger than the other bosses."),
 "s5_class_select": ("class", 5, "The real class-select screen: cursor steps down all eight classes, each figure takes the pedestal with role, stats, weapon and path (Hulubalang, Prajurit, Pamanah, Pangangon, Pendekar, Penari Topeng, Wiku, Dalang).",
   {f"class_{i}": n for i, n in enumerate(["Hulubalang (warrior)", "Prajurit (lancer)", "Pamanah (archer)", "Pangangon (herder)", "Pendekar (rogue)", "Penari Topeng (dancer)", "Wiku (mage)", "Dalang"])}, 0.0, None, "About 1 s per class."),
 "s5_class_warrior": ("class", 4, "Hulubalang in the Tatar Sunda tea field: kelewang swings, then signature Sunda HA 'Panji Hulubalang': a banner and a burning war-ring around him.", {"cast_sunda_ha": "Sunda HA released"}, 0.0, None, "Hero takes a hit before the cast (red vignette)."),
 "s5_class_archer": ("class", 3, "Pamanah in the Mataram temple field: bow shots, then Sunda KA 'Hujan Panah' (arrow rain).", {"cast_sunda_ka": "Sunda KA released"}, 0.0, None, "Signature Panah Sakti was a single arrow in preview, swapped for Arrow Rain."),
 "s5_class_dancer": ("class", 3, "Penari Topeng in the Tanah Timur field: fan strikes, then signature Sunda TA 'Panca Wanda'.", {"cast_sunda_ta": "Sunda TA released"}, 0.0, None, "Signature effect is small after the banner."),
 "s5_class_dalang": ("class", 4, "Dalang in Batara Kala's chamber: kayon strikes, then signature Jawa LA 'Tancep Kayon': a huge rotating ring of wayang light pinning the ghosts.", {"cast_jawa_la": "Jawa LA released"}, 0.0, None, "Best class spell visually."),
 "s5_class_lancer": ("class", 3, "Prajurit in the Tangkuban Perahu crater: tombak thrusts, then signature Jawa GA 'Supit Urang'.", {"cast_jawa_ga": "Jawa GA released"}, 0.0, None, "Effect lands to one side; banner dominates."),
 "s5_class_rogue": ("class", 3, "Pendekar on the misty Pamali road (Galuh): kujang strikes, then Sunda KA 'Petir Berantai' (chain lightning).", {"cast_sunda_ka": "Sunda KA released"}, 0.0, None, "Signature Seribu Bayangan (Jawa PA) read as a teleport only; swapped."),
 "s5_choice": ("feature", 4, "Moral choice 3, Judgment at the Pamali: Ciung Wanara (portrait) - 'I won't be a king thirsty for revenge. But I won't be a king who forgets either. Tell me what you think.' Options: 'Give them a lit cell in the courtyard, and pardon the eastern soldiers.' / 'Let Galuh's law run its course, and fortify the river watch.' Cursor moves to law, back to mercy, mercy chosen.",
   {"choices": "options appear", "law": "cursor on law", "mercy": "cursor on mercy", "chosen": "mercy chosen"}, 0.0, None, "Backdrop is a dark empty road; Ciung is portrait only."),
 "s5_codex": ("feature", 3, "Pause menu, Culture Codex at 100%: the left page scrolls through the legends (Sangkuriang '...The Crater Seal is the game's.', the ancestors' stone '...It is the game's.', Bandung Bondowoso '...In the game his night-curse is calmed'), the right page through the aksara (Hanacaraka, Ca, Ga, Ka, Nga).", {}, 0.0, None,
   "Text-dense book pages; the codex has no separate 'open entry' view, the legend-vs-game line is the last sentence of each body."),
 "s5_dialogue": ("feature", 4, "Semar (happy portrait) to the hero on the Desa Purwa stage: 'Hehe, you look like a wet cat. Before I say a word, fetch your half of the lontar from the stage. The scorched one.' types out.", {}, 0.0, None, ""),
}


def dur(p):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", p]).strip())


out = []
for stem, (kind, rating, desc, labels, bi, bo, notes) in S.items():
    mp4 = os.path.join(RAW, stem + ".mp4")
    if not os.path.exists(mp4):
        print("missing", stem)
        continue
    d = round(dur(mp4), 2)
    km = []
    log = open(os.path.join(RAW, stem + ".log"), errors="replace").read()
    for f, name in re.findall(r"@@SHOT mark (\d+) (\S+)", log):
        if name in labels:
            km.append({"t": round(int(f) / 60.0, 2), "what": labels[name]})
    out.append({"file": stem + ".mp4", "seconds": d, "kind": kind, "description": desc, "key_moments": km,
                "best_in": bi, "best_out": bo if bo is not None else d, "rating": rating, "notes": notes})
json.dump(out, open(os.path.join(RAW, "shots_s5.json"), "w"), indent=1)
print(len(out), "shots")
