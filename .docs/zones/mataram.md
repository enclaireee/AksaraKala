# Mataram (region `mataram`, area prefix `mt_`), Act 3 (Story v5)

Region area graph on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5), graph level plus, since Phase 5, the tile map of each area (sections `## Area n: <id>` after the Quest step locations; `python3 .docs/gen_zones.py .docs/zones/mataram.md` writes `zones/mt_*.gd/.tscn`). Sources: [world.md](../world.md) (Technical frame, World structure with interlock rules 1-8 and the inter-region link table, Mataram, Checkpoints, Points of interest), [bestiary.md](../bestiary.md) (Zone 2: Mataram, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ2 of Story v5 with 24 steps 2.1–2.24 and its `Play` column, SQ-M1 to SQ-M4, SQ-C2 to SQ-C4, 3.4, 7.1, 7.2), [architecture.md](../architecture.md) 9b (Clue, Kelir memory), [story.md](../story.md) (Pacing, Act III). Tatar Sunda ([tatar_sunda.md](tatar_sunda.md)) is the format example. Change the layout here first, then the code.

Regional character: **Ki Sumarto** (dalang, `mt_pasar`). His son Sapto appears at the ford in the `truce` beat, which is in `kg_pamali` ([keraton_galuh.md](keraton_galuh.md)), not here. Pak Karto is off the main path and stays in `mt_reruntuhan` as a side-quest NPC (no quest assigned yet). Na is read off the inscribed object `arca_base`. Story v4/v4b/v4c additions (2026-11-06): the **arrival slice** (two recruiters, one per bank, at the border market in `mt_gapura`), the **K3 Bondowoso Hunt** (clues `rubble`, `lesung_mid`, `ka_strip`, memory `k3_lesung`), **H3** (`hunter_mask_3`, memory `h3`), **LC3** (Laras chapter), and **K-III** (Ki Sumarto's show; its clue and the Hariang Banga letters stand in `kg_pamali`, [keraton_galuh.md](keraton_galuh.md)). Cut names: the juru kunci is NPC `juru_kunci` (no longer called Mbah Marto in dialogue; only this comment keeps the old name), the lesung women are unnamed. The memory scenes are in the section "Memory scenes" below. Side stories v4d additions (2026-11-06; [quests.md](../quests.md) 5): clues, givers, arenas and memories for SQ-M1 to SQ-M4, the Companion clue `c3_camp_scrap` (C3, fragment 1, in `mt_candi`) and C4 part 2 (`c4_roll_a`, `c4_roll_b`, stealth area `c4_market_clear`, in `mt_gapura`); the placements are in "Side stories v4d spots" after the area maps, the legend rows that changed are marked v4d, and three memories (`sq_m1_selendang`, `sq_m2_child`, `sq_m3_tuyul`) are in "Memory scenes". NPC ids follow the cards: `m2_neighbour`, `m2_parents_1`, `m3_smith` replace `wewe_neighbor`, `wewe_parents`, `pande_besi`.

**Puzzle convention (ASSUMED).** No puzzle entity exists yet. A puzzle is a `trigger.tscn` with `trigger_id` `puzzle_<id>` (the builder attaches the puzzle script, tests solve it by setting `flag:puzzle_<id>`). When a puzzle must gate the path it also sets that flag, and a `kabut.tscn` with `{flag:"puzzle_<id>"}` stands where it opens (a kabut lifts on a flag, never on a glyph). Miniboss pieces are encounters whose first enemy carries `unique_id` and elite stats (HP x4, Ilmu x4, **TUNE**, the bestiary elite rule); the wave list takes only scene and offset, so the builder either lets a wave entry carry `unique_id` or adds an elite scene (format question in the report). Setpiece pieces are encounters with a scripted frame (stated per area).

Tags used: **ASSUMED** (a decision, change freely), **VERIFY** (culture fact to check before it ships), **TUNE**. Ids marked (Q) already exist in quests.md or world.md.

## Look and landmark
Warm stone, rice terraces, dry fields and volcano foothills. Temple ruins in sandstone grey, orange roof tiles in the village, green padi. The tone stays cartoonish and gentle: the spirit builders are cheeky, not grim. The boss site, the unfinished "thousand temples" (in-game name **Candi Seribu**, an invented place, **VERIFY** before using any real site name), shows as a spiky silhouette of many small spires against the volcano from the very first screen of `mt_gapura`. It looks bigger and more crowded in `mt_sawah`, peeks over the roofs in `mt_pasar`, and stands behind broken walls in `mt_reruntuhan`. A road of paving stones (the causeway) runs straight from the gapura to the temples and is walled off at first: it is the second shortcut. Spirit builders carry stones along the skyline all game long, so the player sees where the boss is. The Durga statue is never shown or named (quests.md sensitivity note).

## Area table
Sizes are in screens (30x17 tiles each). Exit sides are ASSUMED and only fix the graph (W/E/N/S).

| Id | Size | Look | Purpose |
|----|------|------|---------|
| `mt_gapura` | 2x2 = 60x34 | Stone split gateway, dusty road, banyan, the temple silhouette in the east. The border market stalls stand in the entry yard | Entry from the Pamali ford (Keraton Galuh). **Arrival slice:** two recruiters, one per bank, tell the same war the other way round (2.1). First teach fight (Tuyul with Burst), a second road ambush, the K3 hook beat. Road branches to the rice fields. Far end of the causeway shortcut; the Faceless remnants after Bondowoso (2.11) |
| `mt_sawah` | 3x2 = 90x34 | Stepped rice paddies, a lumbung, a farm yard with a lesung, irrigation channels | Rest hub: petilasan `mataram_1`. SQ-M1, a farmer for flavor, the lesung codex. Safe area, no fight near the petilasan |
| `mt_pasar` | 2x3 = 60x51 | Village: roofed market lanes, gamelan pavilion, blacksmith stall, dalang's house | Story and quest hub (lead 1: the setpiece that defends Ki Sumarto's stage, then he teaches Ha, 2.2/2.3; SQ-M2, SQ-M3, SQ-M4 givers). First Pocong teach on the east road |
| `mt_reruntuhan` | 3x3 = 90x51 | Broken candi walls, courtyards, fallen carved stones, a small site museum | Lead 2: Arca fight (`mataram_ruins`), the `arca_base` inscription (Na, 2.3), Pak Karto (side-quest NPC), codex-rich ruin, gong nook, the far side of the `sc:mt_ruin_sawah` gate. Hub of the loops |
| `mt_kuburan` | 2x2 = 60x34 | Old graveyard with frangipani, a bare hill with one tree, mist | Lead 3 (required since v3.1): graveyard fight `mataram_kuburan`, the Hunter beat `hunter_war`. Optional: Wewe Gombel hill (elite, SQ-M2), crypt secret |
| `mt_wetan` | 3x2 = 90x34 | Rocky foothill field, dry grass, boulders, a cliff ledge, the juru kunci's hut, a lesung yard of the foothill hamlet | The lesung women (Ca once `lead_kuburan`, 2.3: moved here from `mt_sawah` so the glyph step is on the way, Pacing rule 5). Rock thrower fight (2.5). The juru kunci (2.5, lamp puzzle at his hut). East exit to Tanah Timur. Start of the drop. Stairs up to the temples |
| `mt_candi` | 3x3 = 90x51 | The unfinished temples: spires, spirit builders, scaffolds, temple gate, the boss court | Front yard with the temple gate fight and the K3 clues, the camp sequence in the court (gate fight, captain miniboss, setpiece), petilasan `mataram_2` with Laras's lontar (LC3), boss arena (>= 1 screen, 30x17 **ASSUMED**), the far side of the causeway gate |
| `mt_tegal` | 2x2 = 60x34 | Dry field, a tuyul-haunted well, old brick kiln | Landing of the drop. End of the back road `sc:mt_tt`. SQ-M3 hideout. Secret well chamber. One link from petilasan `mataram_1` |

### Contents (encounters, NPCs, chests, petilasans, codex, secrets, markers)
Encounter ids are proposed `mataram_*` (**ASSUMED**) except `mataram_ruins`, `mataram_pasar`, `mataram_kuburan`, `mataram_batu`, `mataram_candi`, `mataram_camp` (Q, MQ2 v3.1 step triggers). Enemy mixes are from bestiary.md "Encounters, Mataram" unless marked new.

| Id | Encounters | NPCs | Chests, petilasan, codex, secrets |
|----|------------|------|-----------------------------------|
| `mt_gapura` | `mataram_gerbang`: 3 Tuyul, one wave (new, teach: Burst clears a swarm; Ca learned in MQ1 1.7). `mataram_jalan`: 4 Tuyul on the east road (2.1, second fight). After 2.10 (`flag:mq2_7b`): `mataram_tepi` (2 Faceless, 1 archer, west road) and `mataram_causeway` (3 Faceless, in front of the opened causeway gate), the 2.11 return fights | `recruiter_a`, `recruiter_b` (2.1, the two banks; unnamed) | Chest `mataram_chest_gapura` (55 Ilmu). Codex spot `codex:gapura` (stone gate). Beat spot `beat_haulers` (K3 hook) |
| `mt_sawah` | none (safe) | `nawang_wulan` (SQ-M1 giver), `sawah_farmer` (flavor), no lesung women since v4c | Petilasan **`mataram_1`** (Q). Chest `mataram_chest_sawah`. Codex `codex:gejog_lesung` (the lesung that the women later pound in `mt_wetan`). Lumbung: SQ-M1 clues `m1_pot_lid`, `m1_rice_gone` (v4d). Barred north gate of `sc:mt_ruin_sawah` |
| `mt_pasar` | `mataram_pasar` (**setpiece**, 2.2): 5 Tuyul (Village thieves) come for Ki Sumarto's stage, 2 waves (5 then 3, **ASSUMED**), the stage prop must not fall. `mataram_pocong`: 1 Pocong alone on the east road (new, teach: Bind mid-hop, 8-tile lane) | `mataram_dalang` = Ki Sumarto (Q, 2.3 teaches Ha once `lead_pasar`; regional character; SQ-M4 giver), `m3_smith` (SQ-M3 giver), `m2_neighbour` (SQ-M2 giver), `m2_parents_1` (SQ-M2 alt, later `wewe_parents_2` at the hill) | Chest `mataram_chest_pasar`. Codex `codex:gamelan` |
| `mt_reruntuhan` | `mataram_ruins` (Q, **miniboss**, 2.2): 3 Arca on the edges (the middle one is the elite `mt_arca_penjaga`), 2 Tuyul, courtyard. Wakes when passed (Ruins wake) | `pak_karto` = Pak Karto (side-quest NPC, off the main path), in the safe outer yard before the courtyard. `arca_base` = inscribed base of an Arca (2.3, cond `flag:lead_ruins`), in the courtyard beside the central path | **Codex-rich ruin**: site museum with `codex:candi_seribu`, `codex:roro_jonggrang`, `codex:arca`. Secret 1: sealed nook behind a cracked wall holding the gong ageng (SQ-M4) and a gear chest `mataram_secret_gong`. Far side of `sc:mt_ruin_sawah` |
| `mt_kuburan` | `mataram_kuburan_gate` (2.2, fight 1): 3 Tuyul, 1 Pocong on the north field. `mataram_kuburan`: 2 Pocong, 3 Tuyul (Graveyard, open ground; lead 3, required). `mataram_pemanen` (**miniboss**, 2.4, cond `flag:memory_h3`): the harvest captain, an elite Faceless with 2 Pocong, on the east road. `mataram_wewe`: elite Wewe Gombel (only if SQ-M2 is fought, HP 780) | `wewe_parents_2` arrive at the hill if SQ-M2 is peaceful | Secret 2: crypt under the hill, chest **Panah Pasopati** (`mataram_secret_pasopati`, Q reward source "Mataram secret"). Marker `wewe_hill` (Q) |
| `mt_wetan` | `mataram_batu`: 1 Genderuwo, 2 Pocong (Rock thrower, rocky field). `mataram_batu_2` (2.5, fight 1): 3 Tuyul on the junction field. Puzzle `puzzle_wetan_lamps` (2.5) | `juru_kunci` (comment: was Mbah Marto; 2.5, teaches Ra after the blockade falls), `lesung_women` (2.3, teaches Ca once `lead_kuburan`; lesung yard, moved from `mt_sawah`) | Chest `mataram_chest_wetan`. Codex `codex:genderuwo`. Kabut `K3` to `tt_kulon` on the east edge. Drop ledge on the south cliff |
| `mt_candi` | `mataram_candi`: Temple gate, wave 1: 1 Genderuwo, 2 Arca; wave 2: 3 Tuyul rising from a heap of dropped stones with a 0.5 s warning (2 waves). Then, in the court (2.6, cond `flag:mq2_6`): `mataram_camp_gate` (3 Faceless), `mataram_camp_captain` (**miniboss**, elite Faceless), `mataram_camp` (**setpiece**, the Pamali stone wakes). The petilasan sits after them, no fight between it and the boss | `hauler` (2.6, a bound hauler at the temple gate, unnamed); the lesung women do not stand at the arena edge (see ASSUMED 9) | Petilasan **`mataram_2`** (Q) right before the boss arena. Boss **Bandung Bondowoso** (`bandung_bondowoso`). Chest `mataram_chest_candi`. Batu bintang (SQ-T3 meteorite fragment) in the front yard (**ASSUMED**). Far side of `sc:mt_candi_gapura`. K3 clues `rubble`, `lesung_mid`, `ka_strip`; Laras's lontar `lc3_lontar` at the petilasan |
| `mt_tegal` | `mataram_tuyul`: elite tuyul leader (`unique_id` `tuyul_leader`) + 3 Tuyul swarm (SQ-M3 fight, new). Peaceful ending has no fight (puzzle `puzzle_m3_trap_sprung`) | none | Secret 3: dry well chamber, gear chest `mataram_secret_sumur`. Marker `tuyul_hideout` |

NPC count is 10 ids (the 9 NPC ids plus `arca_base`, a read-in-place object) because of the side quests (world.md says 3-5, Tatar Sunda has 10 for the same reason, **ASSUMED**).

## Region graph
Gates: `K1` = kabut `mq1_10` (Q), `K2` = kabut `mq2_6` (**ASSUMED**), `K3` = kabut `mq2_9` (**ASSUMED**, see Doc conflicts). `sc` = shortcut, opened from the far side named. `===>` is a one-way drop. P1 = `mataram_1`, P2 = `mataram_2`, B = boss.

```
                         (bridge of paving stones, walled at the gapura end)
   kg_pamali            ..........  sc:mt_candi_gapura (opens from mt_candi)  ..........
       |                :                                                             :
      K1                :                                                             :
       |                :                                                             :
   [ mt_gapura ] -------+                                     [ mt_candi ] P2 + B
       |                                                          |
       |  link                                                    | link, K2
       |                                                          |
   [ mt_sawah ] P1 --link-- [ mt_tegal ] <=sc:mt_tt= tt_sabana   [ mt_wetan ] ==K3== tt_kulon
       |   ^                      ^                                |   |  \
       |   |                      |                                |   |   \___ drop (one way)
       |   +---sc:mt_ruin_sawah---+ (gate in sawah,                |   |            |
       |       opens from reruntuhan)                              |   |            v
   [ mt_pasar ]                                                    |   |       [ mt_tegal ]
       |                                                           |   |
       | link                                                      |   | link
       |                                                           |   |
   [ mt_reruntuhan ] ---------------------- link ------------------+   |
       |                                                               |
       +-- link -- [ mt_kuburan ] ------------------ link ------------+
```

Cleaner reading, one edge per line (L = link, S = shortcut, D = drop):
```
kg_pamali   ---  mt_gapura (L, always open; kg_alun to kg_pamali is behind kabut `mqg_7`)
mt_gapura   --   mt_sawah  (L)
mt_sawah    --   mt_pasar  (L)
mt_pasar    --   mt_reruntuhan (L)
mt_sawah    ..   mt_reruntuhan (S sc:mt_ruin_sawah, opens from reruntuhan)
mt_reruntuhan -- mt_wetan  (L)
mt_reruntuhan -- mt_kuburan (L)
mt_kuburan  --   mt_wetan  (L)
mt_wetan    -->  mt_tegal  (D, one way)
mt_tegal    --   mt_sawah  (L)
mt_wetan    =K2= mt_candi  (L)
mt_candi    ..   mt_gapura (S sc:mt_candi_gapura, opens from mt_candi)
mt_wetan    =K3= tt_kulon  (L)
mt_tegal    ..   tt_sabana (S sc:mt_tt, opens from tt_sabana)
```
(The first ASCII picture shows `mt_tegal` twice, once for the link to `mt_sawah` and once as the drop's landing. It is one area.)

### Link table
Spawn ids follow `from_<other area id>` and name where the player arrives.

| From | To | Kind | Gate flag | Spawn ids (in the arrival area) |
|------|----|------|-----------|-----|
| `kg_pamali` (E) | `mt_gapura` (W) | link, open (the gate is kabut `mqg_7` between kg_alun and kg_pamali) | - | `from_kg_pamali` in gapura; `from_mt_gapura` in kg_pamali |
| `mt_gapura` (E) | `mt_sawah` (W) | link | none | `from_mt_gapura` in sawah; `from_mt_sawah` in gapura |
| `mt_sawah` (S) | `mt_pasar` (N) | link | none | `from_mt_sawah` in pasar; `from_mt_pasar` in sawah |
| `mt_pasar` (S) | `mt_reruntuhan` (N) | link | none | `from_mt_pasar` in reruntuhan; `from_mt_reruntuhan` in pasar |
| `mt_reruntuhan` (E) | `mt_wetan` (W) | link | none | `from_mt_reruntuhan` in wetan; `from_mt_wetan` in reruntuhan |
| `mt_reruntuhan` (S) | `mt_kuburan` (N) | link | none | `from_mt_reruntuhan` in kuburan; `from_mt_kuburan` in reruntuhan |
| `mt_kuburan` (E) | `mt_wetan` (S) | link | none | `from_mt_kuburan` in wetan; `from_mt_wetan` in kuburan |
| `mt_wetan` (S ledge) | `mt_tegal` (N) | **drop**, one way | none | `from_mt_wetan` in tegal (no return exit) |
| `mt_tegal` (W) | `mt_sawah` (E) | link | none | `from_mt_tegal` in sawah; `from_mt_sawah` in tegal |
| `mt_wetan` (N) | `mt_candi` (S) | link, kabut `K2` | `mq2_6` (set when 2.5 completes, the juru kunci) | `from_mt_wetan` in candi; `from_mt_candi` in wetan |
| `mt_wetan` (E) | `tt_kulon` | link, kabut `K3` | `mq2_9` (set when 2.13 completes, the Hariang Banga duel) | `from_mt_wetan` in tt_kulon; `from_tt_kulon` in wetan |
| `mt_candi` (W) | `mt_gapura` (NE) | shortcut `sc:mt_candi_gapura` | `sc:mt_candi_gapura` | `from_mt_candi` in gapura; `from_mt_gapura` in candi |
| `mt_sawah` (N gate) | `mt_reruntuhan` (SW) | shortcut `sc:mt_ruin_sawah` | `sc:mt_ruin_sawah` | `from_mt_reruntuhan` in sawah; `from_mt_sawah` in reruntuhan |
| `mt_tegal` (E) | `tt_sabana` | shortcut `sc:mt_tt` (Q) | `sc:mt_tt` | `from_tt_sabana` in tegal; `from_mt_tegal` in tt_sabana |

Arrival from a shortcut places the player on the near side with the gate already open. Once open, a shortcut works in both directions for good. The drop is the only edge with a single exit.

### Shortcut table
| Id | Gate area (where the barred door stands) | Open side (where it is opened) | Leads back to |
|----|------------------------------------------|--------------------------------|---------------|
| `sc:mt_ruin_sawah` | `mt_sawah`, barred wooden gate in the north wall | `mt_reruntuhan`: the exit behind the gate starts in the courtyard side yard, past the Ruins wake fight; you arrive in sawah behind the gate and open it | Petilasan `mataram_1` (arrive in sawah, a few tiles away) |
| `sc:mt_candi_gapura` | `mt_gapura`, a walled end of the causeway | `mt_candi`: the exit behind the gate starts in the front yard next to petilasan 2; you arrive in gapura behind the wall and open it | `mt_gapura`, one link from `mataram_1` (and the road west to the Pamali ford for 2.5-2.6) |
| `sc:mt_tt` (Q world.md) | `mt_tegal`, a boulder-blocked back road | `tt_sabana` (Tanah Timur side) | `mt_tegal`, one link from `mataram_1` |

## Loops, drop, critical path, optional areas
**Loops** (every first trip is long, later trips are short):
- **A (big):** `mt_sawah` > `mt_pasar` > `mt_reruntuhan` > `mt_wetan` > drop > `mt_tegal` > `mt_sawah`. The drop closes it: the fall lands near petilasan 1.
- **B (village):** `mt_sawah` > `mt_pasar` > `mt_reruntuhan` > `sc:mt_ruin_sawah` > `mt_sawah`. After the ruins, the way back to the lesung and the petilasan is one gate.
- **C (graveyard):** `mt_reruntuhan` > `mt_kuburan` > `mt_wetan` > `mt_reruntuhan`. A plain loop with the graveyard (lead 3) in its middle.
- **D (causeway):** `mt_gapura` > `mt_sawah` > `mt_pasar` > `mt_reruntuhan` > `mt_wetan` > `mt_candi` > `sc:mt_candi_gapura` > `mt_gapura`. The player first sees the walled causeway at the very start, then opens it at the very end.

**Drop:** `mt_wetan` south ledge to `mt_tegal` (one way, no fall damage, **ASSUMED** for the forgiving tone). A railing with a gap and a worn path make it readable.

**Three leads (step 2.2, `all`, any order).** After `mataram_1` nothing is gated, so the player can take the leads in any order. Each lead is an encounter id that sets its own flag on `area_cleared`. The arrow shows the nearest open lead (**ASSUMED**).

| Lead | Area | Completes on, sets | Route from `mataram_1` (`mt_sawah`) | Notes |
|------|------|--------------------|--------------------------------------|-------|
| Market | `mt_pasar` | `area_cleared:mataram_pasar`, `lead_pasar` | `mt_sawah` S exit > `mt_pasar` N spawn > plaza `E (28,36)`. 1 link | Ki Sumarto's house is at the north end, so Ha can be learned at once (2.3). The lone Pocong (`mataram_pocong`) is on the side road and is not on this route |
| Ruins | `mt_reruntuhan` | `area_cleared:mataram_ruins`, `lead_ruins` | `mt_sawah` > `mt_pasar` > `mt_reruntuhan` N spawn > courtyard `E (44,26)` on the central path. 2 links | `arca_base` stands beside the path 5 tiles north of the Arca fight, so Na can be read at once (2.3). Pak Karto is in the outer yard (side quest) |
| Graveyard | `mt_kuburan` | `area_cleared:mataram_kuburan`, `lead_kuburan` | `mt_reruntuhan` S exit (44..45,50) > `mt_kuburan` N spawn > graveyard `E (22,18)`. Or `mt_reruntuhan` E road > `mt_wetan` > its S exit (14..15,33) > `mt_kuburan` E spawn. 3 links | The only way to `mt_kuburan` is through `mt_reruntuhan`, and the central path crosses the Arca fight. The Arca wake when passed but there are no arena doors, so a player can run past and finish the fight on the way back (**ASSUMED**). The Hunter beat `hunter_war` plays after the clear. Ca can be learned at once (2.3) at the lesung in `mt_sawah`; `sc:mt_ruin_sawah` (opened from the ruins) is the short way back |

Possible orders: market first (natural), ruins first, or graveyard first (the ruins fight is crossed on the way). The market can also be last: from the ruins, `sc:mt_ruin_sawah` leads to `mt_sawah` and the market is one link. All three leads are required for 2.2, so every route must reach all three areas, and they do. Lead rooms are ordered by distance from `mataram_1` (1, 2, 3 links), so the natural order is market, ruins, graveyard, as the Act III text lists them.

**Critical path** (MQ2 v4c order, 7 of 8 areas): `kg_pamali` > `mt_gapura` (2.1: the two recruiters in the entry yard, E gerbang, the `haulers` beat, E jalan) > `mt_sawah` (petilasan `mataram_1`, sets `mq2_1`) > the three leads in any order (2.2): `mt_pasar` (the stage setpiece, then Ki Sumarto), `mt_reruntuhan` (clue `ka_chalk`, the Arca miniboss), `mt_kuburan` (two fights, beat `hunter_war`) > the glyphs as each lead opens its source (2.3): Ha from Ki Sumarto in `mt_pasar`, Na read off `arca_base` in `mt_reruntuhan` (the stones puzzle), Ca from the lesung women in the `mt_wetan` lesung yard (moved from `mt_sawah`) > H3 (2.4): the mask fragment in `mt_kuburan` (clue `hunter_mask_3`), memory `h3`, then the harvest-captain miniboss on the east road > `mt_wetan` (2.5: E batu_2, E batu, the lamp puzzle, the juru kunci and Ra, sets `mq2_6`; beat `lengser_word` if `choice_handed`) > `K2` > `mt_candi` (2.6: E candi, the hauler, E camp_gate, the captain miniboss, the camp setpiece, beat `camp`; 2.7: clues `rubble`, `lesung_mid`, `ka_strip`; 2.8: memory `k3_lesung`; rest at `mataram_2` and take `lc3_lontar`; 2.9: chapter `lc3`; 2.10: Bandung Bondowoso) > open `sc:mt_candi_gapura` > `mt_gapura` (2.11: E causeway, E tepi) > west to `kg_pamali` (2.11 the stone; 2.12 K-III; 2.13 the letters and Hariang Banga, sets `mq2_9`; beats `ford` and `truce`) > back east.

**Return trips (Pacing rule 5).** After 2.10 the way home is the opened causeway (0 minutes; `sc:mt_candi_gapura`), and the gapura it lands in is a changed area: the Faceless remnants fight there (`mataram_causeway`, `mataram_tepi`, counted as the `travel` and `fight x2` of 2.11). After 2.13 the Tanah Timur gate `K3` is two areas from `kg_pamali` by the causeway, not five: `mt_gapura` (east road) > causeway pocket > `mt_candi` (west road, the builders gone: scaffolds down, the lesung women's beat now plays in the court, **ASSUMED**) > south gate > `mt_wetan` (stairs corridor) > east road > `K3`. No plain backtrack through sawah, pasar and ruins is needed. The lesung women moved to `mt_wetan` for the same reason: with Ca at `mt_sawah` the graveyard-to-wetan trip would have gone kuburan > ruins > `sc:mt_ruin_sawah` > sawah and back, four empty areas.

**Main-path kills (balance.md 2.1):** before roaming packs about 55 after v4c (v3.1 was 36; added: jalan 4, tepi 3, causeway 3, kuburan_gate 4, pemanen 3, batu_2 3, camp_gate 3, camp_captain 1+2, pasar wave 2 +3, minus nothing; **TUNE** and recount with `tests/zone_build_test.gd`); v3.1 breakdown (gapura 3, pasar 6, ruins 5, kuburan 5, wetan 3, candi 6, camp 8; the graveyard is a required lead and the camp encounter was missing from the old count, **ASSUMED** recount, **TUNE**); after 53 (+17: gapura 3, sawah 3, pasar 3, ruins 5, wetan 3; candi gets none, so nothing sits between `mataram_2` and the boss). `mt_tegal` adds 3 optional kills. Gate: Tuyul anywhere after Burst (MQ1), but only east of `mataram_gerbang`; Pocong only from `mt_reruntuhan` on (Bind taught at `mataram_pocong`, a side road in `mt_pasar` that a graveyard-first player can skip; see Open questions 9) and in `mt_tegal` (drop is after the ruins); no loose Arca or Genderuwo.

**Rule 7 (every critical-path area holds an optional find).** `mt_gapura`: chest `mataram_chest_gapura` + codex `gapura`. `mt_sawah`: chest + codex `gejog_lesung` + SQ-M1. `mt_pasar`: chest, codex `gamelan`, three side quests. `mt_reruntuhan`: the museum (3 codex), the gong nook secret, Pak Karto. `mt_kuburan`: Wewe hill (SQ-M2) and the crypt secret. `mt_wetan`: chest, codex `genderuwo`, the drop ledge. `mt_candi`: chest, batu bintang (SQ-T3). All met; no new find needed.

**Optional areas and the loop they branch off:**
| Area | Branches off | Why it is worth it |
|------|--------------|--------------------|
| `mt_tegal` | Loop A (drop landing and link to sawah) | SQ-M3 hideout, well secret, the road to Tanah Timur later |

`mt_kuburan` (Loop C) is no longer optional: it is lead 3 of step 2.2. Its Wewe Gombel hill (SQ-M2) and the Panah Pasopati crypt stay optional rooms inside it.

No optional area hangs off the end of a dead-end chain.

## Quest step locations
Marker form `{zone: "<area id>", id: ...}` (the area in the Area column; `QuestData.zone` stays `mataram`). Ids from quests.md or world.md are marked (Q). Everything else is **ASSUMED**. Step numbers are the MQ2 Story v5 ones (24 steps 2.1–2.24, [quests.md](../quests.md) 4, `Play` column). Every piece of the `Play` column has a place below: `travel` = crossing that area with its fights and one find; `fight` = one encounter; `clue`, `puzzle`, `miniboss`, `setpiece`, `memory`, `chapter` as named.

| Step | Pieces (Play) | Marker id | Area | Event string |
|------|---------------|-----------|------|--------------|
| Unlock: from Keraton Galuh | | none | `mt_gapura` entry | `zone_entered:mataram` |
| 2.1 (`all`) hear both recruiters | `travel, talk x2, beat` | `recruiter_a` (Q), `recruiter_b` (Q) | `mt_gapura` entry yard, the two banks of the lane (the north stall and the south stall) | `talked_to:recruiter_a`, `talked_to:recruiter_b`; sets `mq2_a1` |
| 2.2 break the blockade at the border gate and rest at `mataram_1` | `fight x2, travel, talk` | `mataram_gerbang` (Q), `mataram_jalan`, `mataram_1` (Q) | `mt_gapura` (gerbang field, east road), `mt_sawah` | `area_cleared:mataram_gerbang`; then `petilasan_activated:mataram_1` (Q); sets `mq2_1` |
| 2.3 defend Ki Sumarto's wayang stage | `setpiece, fight x2` | `mataram_pasar` (Q), `pasar_stage` | `mt_pasar` (plaza `E`) | `area_cleared:mataram_pasar`; sets `lead_pasar` |
| 2.4 speak with Ki Sumarto, learn Jawa Ha, map the three leads | `talk, lesson, clue, fight` | `mataram_dalang` (Q) | `mt_pasar` (dalang house) | `glyph_learned:jawa_ha` (Q); sets `mq2_2` |
| 2.5 escort displaced market families across the flooded paddies | `travel, fight x2, talk` | `mataram_sawah_road` (Q) | `mt_sawah` (east road) | `area_cleared:mataram_sawah_road`; sets `mq2_2b` |
| 2.6 Lead 1 (The Ruins): defeat the awakened Arca guardians and read Jawa Na | `travel, clue, fight, miniboss, lesson` | `ka_chalk`, `mataram_ruins` (Q), `arca_base` (Q) | `mt_reruntuhan` (courtyard) | `area_cleared:mataram_ruins`, sets `lead_ruins`; then `glyph_learned:jawa_na`, sets `mq2_3` |
| 2.7 Lead 2 (The Graveyard): cleanse `mt_kuburan` | `travel, clue, fight x2, beat` | `mataram_kuburan_gate`, `mataram_kuburan` (Q) | `mt_kuburan` (north field, graveyard `E`) | `area_cleared:mataram_kuburan`; sets `lead_kuburan` (plays beat `hunter_war`) |
| 2.8 claim the third mask fragment and witness H3 | `clue, memory, fight` | `hunter_mask_3` (Q; `memory_id: h3`), `mataram_pemanen` | `mt_kuburan` (north grave rows, east road) | `memory_done:h3`, sets `mq2_h4` |
| 2.9 Lead 3 (The Lesung Yard): help Nyai Gendhis clear the haunted mill yard | `travel, fight, talk, puzzle, beat` | `mataram_lesung_yard` (Q) | `mt_wetan` (lesung yard) | `area_cleared:mataram_lesung_yard`, sets `mq2_4` |
| 2.10 learn the dawn rhythm and Jawa Ca from Nyai Gendhis | `talk, lesson, fight x2` | `lesung_women` (Q) | `mt_wetan` (lesung yard) | `glyph_learned:jawa_ca` (Q); sets `mq2_5` |
| 2.11 break the spirit-builder siege on the foothill shrine | `travel, clue, fight x2, miniboss` | `mataram_batu_2`, `mataram_batu` (Q) | `mt_wetan` | `area_cleared:mataram_batu` (Q); sets `mq2_5b` |
| 2.12 align the foothill shrine braziers and receive Jawa Ra | `puzzle, talk, lesson` | `puzzle_wetan_lamps` (Q), `juru_kunci` (Q) | `mt_wetan` (hut yard and hut) | `puzzle_solved:puzzle_wetan_lamps`; then `glyph_learned:jawa_ra` (Q), sets `mq2_6` (opens `K2`) |
| 2.13 fight across the plain of rising stones (`mt_tegal`) | `travel, clue, fight x2, setpiece` | `mataram_tegal_pillars` (Q) | `mt_tegal` | `area_cleared:mataram_tegal_pillars`, sets `mq2_6b` |
| 2.14 breach the outer temple gate of `mt_candi` and storm the Faceless reading-camp | `fight, talk, fight, miniboss, beat` | `mataram_candi` (Q), `hauler`, `mataram_camp_gate`, `mataram_camp_captain`, `mataram_camp` (Q) | `mt_candi` (front yard, temple court) | `area_cleared:mataram_candi`; then `area_cleared:mataram_camp` (Q), sets `mq2_7` (Beat `camp`) |
| 2.15 K3 clues | `clue x3, talk` | `rubble`, `lesung_mid`, `ka_strip` (Q; `ka_strip` has `memory_id: k3_lesung`) | `mt_candi` (front yard east side, petilasan court, the court) | `all`: `clue_examined:rubble`, `clue_examined:lesung_mid`, `clue_examined:ka_strip`; sets `mq2_h1` |
| 2.16 LC3 Cross-Time Chapter: Laras in Candi Seribu | `chapter, puzzle` | `lc3_lontar` (`memory_id: lc3`) | `mt_candi` (petilasan court) and `zones/kelir/lc3.tscn` | `memory_done:lc3`, sets `mq2_lc`, `laras_key:candi_crypt`, `laras_sabotage:bondowoso_pillar` |
| 2.17 descend through Laras's unlocked crypt to the central temple sanctum | `travel, puzzle, fight` | `candi_crypt_hall` (Q) | `mt_candi` (crypt corridor) | `area_cleared:candi_crypt_hall`, sets `mq2_7a` |
| 2.18 K3 Memory: Roro Jonggrang's women pounding the false-dawn rhythm | `memory, beat` | `k3_lesung` | `zones/kelir/k3_lesung.tscn` | `memory_done:k3_lesung`, sets `mq2_h2` |
| 2.19 end Bandung Bondowoso's night | `boss, setpiece, beat` | `bandung_bondowoso` (Q) | `mt_candi` (boss arena `B`, cond `flag:mq2_lc`) | `boss_defeated:bandung_bondowoso` (Q); sets `mq2_7b` |
| 2.20 take the temple shortcut back toward the western border and reach `kg_pamali` | `travel, fight x2, talk` | `mataram_causeway`, `mataram_tepi` | `mt_gapura` (causeway, west road) to `kg_pamali` | `zone_entered:kg_pamali`, sets `mq2_7c` |
| 2.21 clear the river-bank skirmish and write Nagawiru's name (`Na-Ga`) on the Pamali Stone | `fight x2, write, beat` | `pamali_stone` (Q) | `kg_pamali` | `name_written:nagawiru` (Q); sets `mq2_8` |
| 2.22 K-III Memory: Ki Sumarto's shadow play at the river camp | `memory, talk` | `sumarto_show` (Q; `memory_id: k_iii`, cond `flag:mq2_8`) | `kg_pamali` (ford camp), scene `zones/kelir/k_iii.tscn` | `memory_done:k_iii`, sets `mq2_h5` |
| 2.23 read Hariang Banga's unsent letters at the eastern camp | `travel, clue, beat` | `hariang_letters` (Q) | `kg_pamali` | `clue_examined:hariang_letters`, sets `mq2_h3` (plays beat `ford`) |
| 2.24 duel Prince Hariang Banga in the Pamali ford | `boss, setpiece, beat, talk` | `hariang_banga` (Q) | `kg_pamali` | `boss_defeated:hariang_banga`, sets `mq2_9` (opens `K3`, Choice 3 `choice_mercy` / `choice_judgment`) |

**Beat spots.** Beats are played by the GameUI listener from `beats.tres` ([quests.md](../quests.md) section 4), not by a map node. Each spot below is a `trigger.tscn` that marks the place the beat is staged (**ASSUMED**; the `zone:` part of each `if` is also **ASSUMED**, so a beat does not play in the wrong area).

| Beat | `if` | Area | Spot | Notes |
|------|------|------|------|-------|
| `hunter_war` | `flag:lead_kuburan`, `zone:mt_kuburan` | `mt_kuburan` | `H` (23,8), trigger `beat_hunter_war` | Moved from the old graveyard-optional placement to the lead flag. The Hunter's servants harvest the fallen among the graves; he stands at the north grave rows |
| `lengser_word` | `flag:choice_handed`, `flag:mq2_6`, `zone:mt_wetan` | `mt_wetan` | `L` (44,10), trigger `beat_lengser_word` | One line, in the stairs corridor just below `K2`, before the camp |
| `camp` | `flag:mq2_7`, `zone:mt_candi` | `mt_candi` | `T` (30,15), trigger `beat_camp` | Staged in the cleared camp: Laras's lontar strip with your name. Seal 3 breaks and Bandung Bondowoso wakes |
| `haulers` | `step:mq2=0`, `zone:mt_gapura`, `flag:mq2_a1` | `mt_gapura` | trigger `beat_haulers` (see the legend) | K3 hook: villagers haul stone in the night, temples stand where yesterday there was a field. Plays after `mataram_gerbang` is cleared |
| LC3 (was `laras_3`) | none: the chapter is step 2.9 | `mt_candi` | clue `lc3_lontar` beside petilasan `P` (30,25) `mataram_2` | Replaces the old beat. `do: flag:beat_laras_3` is set by `memory_done:lc3` |
| `ford`, `truce` | `flag:mq2_8`; `quest:mq2=done` | `kg_pamali` | not in this doc | Staged in [keraton_galuh.md](keraton_galuh.md) (Sapto `s`, Ciung `c`, the boss `B`). Ki Sumarto's son Sapto (**ASSUMED**) wades back across the ford in `truce` |

Ki Sumarto stays at his house in `mt_pasar` all act (his show K-III is staged at the ford camp in `kg_pamali`, with him). The cast budget is met: Ki Sumarto, the juru kunci and the lesung women are the only named or recurring speakers on the path; the two recruiters, the hauler and the sawah farmer are unnamed one-scene locals (Pak Karto is a side-quest NPC, Sapto is in `kg_pamali`).

**Side quests (unlock steps as in quests.md section 5: SQ-M1 and SQ-M3 at 2.1, SQ-M2 and SQ-M4 at 2.3).**

| Step | Marker id | Area | Event string |
|------|-----------|------|--------------|
| Side NPC (no quest yet) | `pak_karto` | `mt_reruntuhan` (outer yard) | none |
| SQ-M1 (1) hear Nawang Wulan | `nawang_wulan` | `mt_sawah` | `talked_to:nawang_wulan`. Unlock: `petilasan_activated:mataram_1` (2.1, `mq2_1`) |
| SQ-M1 (2) `all`: the pot's lid, the rice gone | `m1_pot_lid`, `m1_rice_gone` | `mt_sawah` (lumbung) | `clue_examined:m1_pot_lid`, `clue_examined:m1_rice_gone` |
| SQ-M1 (3) the selendang | `m1_rice_gone` (`memory_id: sq_m1_selendang`) | `zones/kelir/sq_m1_selendang.tscn` | `memory_done:sq_m1_selendang` |
| SQ-M1 (4) return | `nawang_wulan` | `mt_sawah` | `talked_to:nawang_wulan` (ends the quest, **VERIFY** all beats). She leaves her weaving scarf as the thanks; the old pickup `selendang_nawang` is retired (v4d) |
| SQ-M2 (1) worried neighbour | `m2_neighbour` | `mt_pasar` | `talked_to:m2_neighbour`. Unlock: `glyph_learned:jawa_ha` (2.3, `mq2_2`) |
| SQ-M2 (2) `all`: the toy, the parents | `m2_toy`, `m2_parents_1` | `mt_kuburan` (hill path), `mt_pasar` (parents' house) | `clue_examined:m2_toy`, `talked_to:m2_parents_1` |
| SQ-M2 (3) the child's memory | `m2_toy` (`memory_id: sq_m2_child`) | `zones/kelir/sq_m2_child.tscn` | `memory_done:sq_m2_child` |
| SQ-M2 (4) peaceful | `wewe_parents_2` | `mt_kuburan` (wewe hill) | `talked_to:wewe_parents_2` (Q alt "peaceful") |
| SQ-M2 (4) fight | `wewe_elite` | `mt_kuburan` (wewe hill) | `enemy_killed:wewe_elite` (Q alt "fight"), encounter `mataram_wewe`; trigger `wewe_hill` stays as the arena entrance |
| SQ-M2 (5) bring the child home | `m2_parents_1` | `mt_pasar` | `talked_to:m2_parents_1` (ASSUMED: the neighbour `m2_neighbour` takes the turn-in if the parents are still at the hill) |
| SQ-M3 (1) the blacksmith | `m3_smith` | `mt_pasar` | `talked_to:m3_smith`. Unlock: 2.1 (`mq2_1`) |
| SQ-M3 (2) `all`: the footprints, the beans | `m3_footprints`, `m3_beans` | `mt_pasar` (smithy hearth), `mt_tegal` (kiln path) | `clue_examined:m3_footprints`, `clue_examined:m3_beans` |
| SQ-M3 (3) the tuyul's memory | `m3_beans` (`memory_id: sq_m3_tuyul`) | `zones/kelir/sq_m3_tuyul.tscn` | `memory_done:sq_m3_tuyul` |
| SQ-M3 (4) peaceful | `puzzle_m3_trap_sprung` (trigger `L`) | `mt_tegal` (kiln hideout) | `area_entered:m3_trap_sprung` (fires when the puzzle is solved, sets `flag:puzzle_m3_trap_sprung`) |
| SQ-M3 (4) fight | `tuyul_leader` | `mt_tegal` | `enemy_killed:tuyul_leader` (the leader and its swarm), encounter `mataram_tuyul` |
| SQ-M3 (5) tell the smith | `m3_smith` | `mt_pasar` | `talked_to:m3_smith` |
| SQ-M4 (1) Ki Sumarto asks | `mataram_dalang` | `mt_pasar` | `talked_to:mataram_dalang`. Unlock: 2.3 (`mq2_2`). The giver is Ki Sumarto (was "Ki Dalang"); matches its card |
| SQ-M4 (2) find the gong | `gong_ageng` (sparkle only) | `mt_reruntuhan` (sealed nook) | `item_picked:gong_ageng` |
| SQ-M4 (3) bring it back | `mataram_dalang` | `mt_pasar` | `talked_to:mataram_dalang` (zone music gains the gong layer, **VERIFY** wording) |
| C3 fragment 1 (Act III) | `c3_camp_scrap` | `mt_candi` (petilasan court, the camp is the court above) | `clue_examined:c3_camp_scrap`, cond `flag:mq2_7` |
| C4 part 2 (1) Cepot at the river market | `cepot` | `mt_gapura` (border market) | `talked_to:cepot`. Unlock: `flag:c4_1`, `flag:mq2_a1` |
| C4 part 2 (2) `all`: his name on both rolls | `c4_roll_a`, `c4_roll_b` | `mt_gapura` (the two stalls) | `clue_examined:c4_roll_a`, `clue_examined:c4_roll_b` |
| C4 part 2 (3) get him out unseen | `puzzle_c4_market_clear` | `mt_gapura` (border market) | `area_entered:c4_market_clear` (fires when the stealth puzzle is solved) |
| C4 part 2 (4) | `cepot` | `mt_gapura` | `talked_to:cepot`; sets `c4_2` |
| Codex (rich ruin) | `candi_seribu` | `mt_reruntuhan` | `codex:candi_seribu` |
| Cross-zone SQ-T3 fragment | `batu_bintang` | `mt_candi` front yard | `item_picked:batu_bintang` |

Flags set or read in this region: `mq1_10` (Q), `mq2_1` to `mq2_9` and `mq2_7b` (Q; `mq2_6` opens `K2`, `mq2_9` opens `K3`), `mq2_a1`, `mq2_h1`-`mq2_h5`, `mq2_lc` (v4/v4b), `puzzle_wetan_lamps` (ASSUMED, opens the hut kabut), `memory_h3`, `memory_k3_lesung`, `memory_lc3` (set by `memory_done`), `clue_*` flags, `lead_pasar`, `lead_ruins`, `lead_kuburan` (Q, new), `choice_handed` (read), `beat_*` flags, `sc:mt_ruin_sawah`, `sc:mt_candi_gapura`, `sc:mt_tt` (Q).

## Area maps (Phase 5)
The 8 sections below follow the format of [tatar_sunda.md](tatar_sunda.md) (tile chars, legend, rooms, encounters). Coordinates are (x, y) from the top-left tile (0,0). Shortcut gates have their pocket (exit, spawn) on the open side. Both elites (`wewe_gombel`, `tuyul_leader`) are plain spots, inert until their quest step, and not encounters.

## Area 1: mt_gapura

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Stone split gateway, dusty road, banyan trees, the Candi Seribu silhouette far in the east sky. A paved causeway wall runs along the north-east.
- Purpose: Entry from `kg_pamali` (the gate is kabut `mqg_7` in Keraton Galuh), first fight `mataram_gerbang` (step 2.1; Tuyul teach), road to the rice fields. Holds the gate of shortcut `sc:mt_candi_gapura` (walled causeway end).

### Map
```
############################################################
#.........##.....................................###########
#.........##.....................................=,,,,,,,,zZ
#.........##.....................................=,,,,,,,,,Z
#...bbb...##................................G....###########
#...bbb...##..................bbb..........................#
#...bbb...##..................bbb..........................#
#.........##..................bbb..........................#
#.........##...............................................#
#.........##...............................................#
#.........##...............................................#
#.........##...............................................#
#.........##.g.............................................#
#...A.I...##...............................................#
#..........................................................#
#..........................................................#
Xe,,,,H,,,K,,,F,,,,,,,,,,,,,,,E,,,,,,,,,C,,,,,,,,,D,,,,,,,yY
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#..........................................................#
#..........................................................#
#...B.J...##...............................................#
#.........##...............................................#
#.........##......................................bbbb.....#
#.........##..................................u...bbbb.....#
#.........##....................................u.bbbb.....#
#.........##......................................bbbb.....#
#.........##........bbb........................u...........#
#...bbb...##........bbb....................................#
#...bbb...##........bbb.................bbb...c............#
#...bbb...##............................bbb................#
#.........##............................bbb................#
#.........##...............................................#
#.........##...............................................#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to Keraton Galuh, the Pamali ford (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"kg_pamali", spawn_id:"from_mt_gapura"}` | path | 2 |
| `e` | spawn, arrival from the Pamali ford | `res://entities/world/spawn.tscn` | `{id:"from_kg_pamali"}` | path | 1 |
| `Y` | exit to mt_sawah (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_sawah", spawn_id:"from_mt_gapura"}` | path | 2 |
| `y` | spawn, arrival from mt_sawah | `res://entities/world/spawn.tscn` | `{id:"from_mt_sawah"}` | path | 1 |
| `Z` | exit to mt_candi (east edge, in the causeway pocket, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_candi", spawn_id:"from_mt_gapura"}` | path | 2 |
| `z` | spawn, arrival from mt_candi (in the pocket on the open side of `=`) | `res://entities/world/spawn.tscn` | `{id:"from_mt_candi"}` | path | 1 |
| `=` | shortcut gate, walled causeway end (opens from the east pocket, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:mt_candi_gapura", open_side:"e"}` | path | 2 |
| `E` | encounter mataram_gerbang | `res://entities/world/encounter.tscn` | `{area_id:"mataram_gerbang", size:Vector2i(22,11), waves:[[[res://entities/enemies/tuyul.tscn, Vector2i(-4,-3)], [res://entities/enemies/tuyul.tscn, Vector2i(2,3)], [res://entities/enemies/tuyul.tscn, Vector2i(6,-2)]]]}` | path | 1 |
| `c` | chest: 55 Ilmu (Ilmu S, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_chest_gapura", item_id:"ilmu:55"}` | grass | 1 |
| `g` | codex spot, stone gate | `res://entities/world/pickup.tscn` | `{codex_id:"gapura"}` | grass | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 3 |
| `A` | NPC recruiter of the north bank at the border market (2.1, `all` with recruiter_b; tells the war one way) | `res://entities/npc/npc.tscn` | `{npc_id:"recruiter_a"}` | grass | 1 |
| `B` | NPC recruiter of the south bank at the border market (2.1; tells the same war the other way round) | `res://entities/npc/npc.tscn` | `{npc_id:"recruiter_b"}` | grass | 1 |
| `C` | trigger, beat `haulers` staging (K3 hook; plays when `step:mq2=0`, `flag:mq2_a1`, after `mataram_gerbang` is cleared; villagers haul stone in the night) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_haulers", size:Vector2i(10,4)}` | path | 1 |
| `D` | encounter mataram_jalan (2.1, second ambush on the east road) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_jalan", size:Vector2i(18,9), waves:[[[res://entities/enemies/tuyul.tscn, Vector2i(-5,-2)], [res://entities/enemies/tuyul.tscn, Vector2i(-1,3)], [res://entities/enemies/tuyul.tscn, Vector2i(3,-3)], [res://entities/enemies/tuyul.tscn, Vector2i(6,2)]]]}` | path | 1 |
| `F` | encounter mataram_tepi (2.11 return fight: Faceless remnants on the west road; cond `flag:mq2_7b`) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_tepi", cond:"flag:mq2_7b", size:Vector2i(18,9), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-3,-2)], [res://entities/enemies/faceless.tscn, Vector2i(3,2)], [res://entities/enemies/faceless_archer.tscn, Vector2i(7,-1)]]]}` | path | 1 |
| `G` | encounter mataram_causeway (2.11 return fight in front of the opened causeway gate; cond `flag:mq2_7b`) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_causeway", cond:"flag:mq2_7b", size:Vector2i(16,9), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-4,0)], [res://entities/enemies/faceless.tscn, Vector2i(0,3)], [res://entities/enemies/faceless_archer.tscn, Vector2i(5,-1)]]]}` | grass | 1 |
| `H` | NPC Cepot at the border market (SQ-C4 part 2) | `res://entities/npc/npc.tscn` | `{npc_id:"cepot"}` | path | 1 |
| `I` | clue, north muster roll with Cepot's name (SQ-C4 part 2, 1 of 2) | `res://entities/world/clue.tscn` | `{clue_id:"c4_roll_a"}` | grass | 1 |
| `J` | clue, south muster roll with Cepot's name (SQ-C4 part 2, 2 of 2) | `res://entities/world/clue.tscn` | `{clue_id:"c4_roll_b"}` | grass | 1 |
| `K` | trigger, distraction puzzle to sneak Cepot out of the border market (SQ-C4 part 2) | `res://entities/world/trigger.tscn` | `{trigger_id:"c4_market_clear", size:Vector2i(4,4)}` | path | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| entry yard | (1,14)-(9,19) 9x6 | Arrival from the Pamali ford | exit `X` (0,16..17), spawn `e` (1,16) | gate is on the Galuh side |
| gateway | (10,14)-(11,19) 2x6 | Split stone gate, 6 tiles wide, silhouette view | codex `g` (13,12) just east | none |
| gerbang field | (19,11)-(41,21) 23x11 | First teach fight, open road | E (30,16) `mataram_gerbang`, chest `c` (46,28) in the banyan corner | 2.1 `area_cleared:mataram_gerbang` |
| east road | (42,16)-(58,17) 17x2 | Road to mt_sawah | exit `Y` (59,16..17), spawn `y` (58,16) | none |
| causeway pocket | (50,2)-(58,3) 9x2 | Walled paved causeway, 9x2, open side east of the gate | gate `=` (49,2..3) `sc:mt_candi_gapura` (open_side `e`), exit `Z` (59,2..3), spawn `z` (58,2) | none |
| border market | (1,12)-(9,22) 9x11 | The arrival slice: two stalls on the two banks of the lane, a recruiter each | `A` recruiter_a (4,13), `B` recruiter_b (4,20) | 2.1 `talked_to:recruiter_a`, `talked_to:recruiter_b` (`all`, sets `mq2_a1`) |
| east road ambush | (41,12)-(59,20) 19x9 | Second fight, and the K3 hook staging at (40,16) | E `D` (50,16) `mataram_jalan`, trigger `C` (40,16) | 2.1 beat `haulers` |
| return fights | west road (5..23,12..20) and the causeway gate (36..52,0..8) | Faceless remnants after Bondowoso, cond `flag:mq2_7b` | E `F` (14,16) `mataram_tepi`, E `G` (44,4) `mataram_causeway` | 2.11 (two `fight`) |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_gerbang` | `E (30,16)` | 22x11 | W1: Tuyul (-4,-3), Tuyul (+2,+3), Tuyul (+6,-2) | Burst (Ca learned in MQ1 1.7) clears the swarm |

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Tuyul (46,23), Tuyul (48,24), Tuyul (47,26). 3 kills, skirtable.
| `mataram_jalan` | `E (50,16)` | 18x9 | W1: Tuyul (-5,-2), Tuyul (-1,+3), Tuyul (+3,-3), Tuyul (+6,+2) | Burst; four Tuyul in 18x9 meets the 15x9 rule |
| `mataram_tepi` | `E (14,16)` | 18x9 | W1: Faceless (-3,-2), Faceless (+3,+2), Faceless archer (+7,-1); cond `flag:mq2_7b` | Dash-strike the archer; known enemies (Faceless from Act I) |
| `mataram_causeway` | `E (44,4)` | 16x9 | W1: Faceless (-4,0), Faceless (0,+3), Faceless archer (+5,-1); cond `flag:mq2_7b` | as above |
## Area 2: mt_sawah

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: Stepped green padi terraces, irrigation channels, a lumbung, a farm yard with a lesung. The temple spires stand larger in the east sky.
- Purpose: Rest hub: petilasan `mataram_1` (2.1). SQ-M1 (Nawang Wulan, lumbung), a farmer, the lesung codex. No enemies; the lesung women now teach Ca in `mt_wetan`.  Holds the gate of shortcut `sc:mt_ruin_sawah` in the north wall.

### Map
```
####################QQ####################################################################
#..................#q,#..................................................................#
#..................#,,#..................................................................#
#..............#####==#####.......................ttttttttttttttttttttttttttttttttttttt..#
#...................,,..ttttttttttttttttt.........ttttttttttttttttttttttttttttttttttttt..#
#..tttttttttttt.....,,..ttttttttttttttttt.........ttttttttttttttttttttttttttttttttttttt..#
#..tttttttttttt.....,,..ttttttttttttttttt.........ttttttttttttttttttttttttttttttttttttt..#
#..tttttttttttt.....,,..ttttttttttttttttt.........ttttttttttttttttttttttttttttttttttttt..#
#..tttttttttttt.....,,..ttttttttttttttttt.........ttttttttttttttttttttttttttttttttttttt..#
#..tttttttttttt.....,,..ttttttttttttttttt.........ttttttttttttttttttttttttttttttttttttt..#
#..tttttttttttt.....,,..ttttttttttttttttt.........ttttttttttttttttttttttttttttttttttttt..#
#..tttttttttttt.....,,..ttttttttttttttttt.........ttttttttttttttttttttttttttttttttttttt..#
#..tttttttttttt.....,,..ttttttttttttttttt.........ttttttttttttttttttttttttttttttttttttt..#
#..tttttttttttt.....,,...................................................................#
#...................,,..............N...............~~~~~~~~~~~.....~~~~~~~~~~~.....c....#
#...................,,...................................................................#
Xe,,,,,,,,,,,,,,,,,,,,,,,,,,,,P,,,,,,,,,,,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,,,,,,,,,,,,,,,zZ
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Z
#...........................................,,...........................................#
#...........................................,,..........bbbbbb,,bbbbbbbbb................#
#...........................................,,..........b,,,,,,,,,,,,,,,b................#
#...####,####...ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...#_______#...ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...#______s#...ttttttttttttttttttttttttt...,,.....u....b,,,g,,,,,,,,,,,b.ttttttttttttt..#
#...#__ULV__#...ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...#_______#...ttttttttttttttttttttttttt...,,.......u..b,,,,,,,W,,,,,,,b.ttttttttttttt..#
#...#_______#...ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...#########...ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...............ttttttttttttttttttttttttt...,,......u...b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...............ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...............ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...............ttttttttttttttttttttttttt...,,..........bbbbbbbbbbbbbbbbb.ttttttttttttt..#
#...........................................y,...........................................#
############################################YY############################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to mt_gapura (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_gapura", spawn_id:"from_mt_sawah"}` | path | 2 |
| `e` | spawn, arrival from mt_gapura | `res://entities/world/spawn.tscn` | `{id:"from_mt_gapura"}` | path | 1 |
| `Y` | exit to mt_pasar (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_pasar", spawn_id:"from_mt_sawah"}` | path | 2 |
| `y` | spawn, arrival from mt_pasar | `res://entities/world/spawn.tscn` | `{id:"from_mt_pasar"}` | path | 1 |
| `Z` | exit to mt_tegal (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_tegal", spawn_id:"from_mt_sawah"}` | path | 2 |
| `z` | spawn, arrival from mt_tegal | `res://entities/world/spawn.tscn` | `{id:"from_mt_tegal"}` | path | 1 |
| `Q` | exit to mt_reruntuhan (north edge, behind the gate, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_reruntuhan", spawn_id:"from_mt_sawah"}` | path | 2 |
| `q` | spawn, arrival from mt_reruntuhan (in the pocket on the open side of `=`) | `res://entities/world/spawn.tscn` | `{id:"from_mt_reruntuhan"}` | path | 1 |
| `=` | shortcut gate, barred wooden gate in the north wall (opens from the north pocket, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:mt_ruin_sawah", open_side:"n"}` | path | 2 |
| `P` | petilasan 1 | `res://entities/petilasan/petilasan.tscn` | `{id:"mataram_1"}` | path | 1 |
| `N` | NPC Nawang Wulan (SQ-M1 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"nawang_wulan"}` | grass | 1 |
| `W` | NPC lesung women (2.6, teaches Ca) | `res://entities/npc/npc.tscn` | `{npc_id:"lesung_women"}` | path | 1 |
| `g` | codex spot, gejog lesung | `res://entities/world/pickup.tscn` | `{codex_id:"gejog_lesung"}` | path | 1 |
| `c` | chest: Axe (items.md Zone 2 chest) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_chest_sawah", item_id:"axe"}` | grass | 1 |
| `L` | clue, a cooking pot's lifted lid on the barn floor (SQ-M1 clue 1 of 2; v4d, replaces the `lumbung` trigger; cond `quest:sq_m1=active`) | `res://entities/world/clue.tscn` | `{clue_id:"m1_pot_lid", cond:"quest:sq_m1=active"}` | floor | 1 |
| `U` | trigger, lumbung barn entered (SQ-M1 step 2) | `res://entities/world/trigger.tscn` | `{trigger_id:"lumbung", size:Vector2i(7,5)}` | floor | 1 |
| `V` | pickup, selendang Nawang Wulan (SQ-M1 step 3) | `res://entities/world/pickup.tscn` | `{item_id:"selendang_nawang"}` | floor | 1 |
| `s` | clue, the rice gone down in the lumbung all at once (SQ-M1 clue 2 of 2; v4d, replaces the selendang pickup; opens memory `sq_m1_selendang` once the lid is also examined) | `res://entities/world/clue.tscn` | `{clue_id:"m1_rice_gone", memory_id:"sq_m1_selendang", cond:"quest:sq_m1=active"}` | floor | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 3 |
| `E` | encounter mataram_sawah_road (2.5 escort displaced market families across the flooded paddies) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_sawah_road", size:Vector2i(14,8), waves:[[[res://entities/enemies/tuyul.tscn, Vector2i(-3,0)], [res://entities/enemies/tuyul.tscn, Vector2i(3,0)], [res://entities/enemies/pocong.tscn, Vector2i(0,2)]]]}` | path | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| west road | (1,16)-(29,17) 29x2 | Arrival from mt_gapura | exit `X` (0,16..17), spawn `e` (1,16) | none |
| rest area | (26,14)-(38,19) 13x6 | Petilasan and Nawang Wulan, safe | P (30,16), Nawang Wulan `N` (36,14) | 2.1 `mataram_1`, SQ-M1 `nawang_wulan` |
| north gate pocket | (20,1)-(21,3) 2x3 | Pocket and gate of `sc:mt_ruin_sawah`, corridor (20..21,4..15) down to the road | gate `=` (20..21,3) open_side `n`, exit `Q` (20..21,0), spawn `q` (20,1) | none |
| lumbung | (4,21)-(12,27) 9x7 | Barn, door (8,21) | clue `L` `m1_pot_lid` (8,24), clue `s` `m1_rice_gone` (11,23) | SQ-M1 (2) `all` of two, then memory `sq_m1_selendang` |
| farm yard | (57,20)-(71,30) 15x11 | Lesung yard, fence gate (62..63,19) | farmer `W` (64,25), codex `g` (60,23) | none |
| east terraces | (50,3)-(86,12) 37x10 | Padi, chest behind the channel | chest `c` (84,14) | none |
| south road | (44,18)-(45,32) 2x15 | Road to mt_pasar | exit `Y` (44..45,33), spawn `y` (44,32) | none |
| east road | (46,16)-(88,17) 43x2 | Road to mt_tegal | exit `Z` (89,16..17), spawn `z` (88,16) | none |

### Encounters
None.

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Tuyul (51,23), Tuyul (53,25), Tuyul (52,28). 3 kills, skirtable.

## Area 3: mt_pasar

- Size: 60 x 51 tiles = 2 x 3 screens (30 x 17 each).
- Look: Orange roofed village: market lanes, a gamelan pavilion, a blacksmith stall, the dalang's house. Spires peek over the roofs.
- Purpose: Story and quest hub (Ki Sumarto, SQ-M2, SQ-M3, SQ-M4 givers). Lead 1: the thieves fight in the market plaza (`mataram_pasar`, step 2.2, now a setpiece), which saves Ki Sumarto's show; he teaches Ha at 2.3. His son Sapto is not here (he is at the ford, `kg_pamali`). First Pocong teach on the east road (`mataram_pocong`).

### Map
```
############################XX##############################
#...........................e,.............................#
#...........................,,.............................#
#.....###########...........,,..........#############......#
#.....#_________#...........,,..........#___________#......#
#.....#_________#...........,,..........#___________#......#
#.....#____D____#...........,,..........#___B___M___#......#
#.....#_________#...........,,..........#___F___H___#......#
#.....#_________#...........,,..........#___________#......#
#.....#_________#...........,,..........#___________#......#
#.....#####,#####...........,,..........######,######......#
#..........,................,,................,............#
#..........,................,,................,............#
#..........,................,,................,............#
#..........,................,,................,............#
#..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..#
#..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..#
#...........................,,.............................#
#.............I...J.W.......,,.............................#
#....####,####..............,,........_____________........#
#....#_______#..............,,........_____________........#
#....#_______#..............,,........_____________........#
#....#_______#..............,,........______G______........#
#....#__P_K__#..............,,........_____________........#
#....#_______#..............,,........_____________........#
#....#########..............,,........_____________........#
#...........................,,........_____________........#
#...........................,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#..............bb...........,,..........bb.................#
#.......u......bb...........,,..........bb..bbbbbbbbbbbbbbb#
#...........................,,.............................#
#.........u.................A,.............................#
#......u....................,,.............................#
#...........................,,.............................#
#...........................E,,,,,,,,,,,,,,,,,,,,,O,,,,,,,.#
#...........................,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.#
#...........................,,.............................#
#...........................,,.............................#
#..............bb...........,,..........bb.................#
#..............bb...........,,..........bb..............c..#
#...........................,,.............................#
#...........................,,..............bbbbbbbbbbbbbbb#
#...........................,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#...........................y,.............................#
############################YY##############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to mt_sawah (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_sawah", spawn_id:"from_mt_pasar"}` | path | 2 |
| `e` | spawn, arrival from mt_sawah | `res://entities/world/spawn.tscn` | `{id:"from_mt_sawah"}` | path | 1 |
| `Y` | exit to mt_reruntuhan (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_reruntuhan", spawn_id:"from_mt_pasar"}` | path | 2 |
| `y` | spawn, arrival from mt_reruntuhan | `res://entities/world/spawn.tscn` | `{id:"from_mt_reruntuhan"}` | path | 1 |
| `D` | NPC Ki Sumarto, the dalang (2.3, teaches Ha once `lead_pasar`; regional character; SQ-M4 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"mataram_dalang"}` | floor | 1 |
| `B` | NPC pande besi, blacksmith (SQ-M3 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"pande_besi"}` | floor | 1 |
| `M` | NPC smith assistant (SQ-M3 v4d) | `res://entities/npc/npc.tscn` | `{npc_id:"m3_smith"}` | floor | 1 |
| `W` | NPC worried neighbor (SQ-M2 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"wewe_neighbor"}` | grass | 1 |
| `J` | NPC neighbor (SQ-M2 v4d) | `res://entities/npc/npc.tscn` | `{npc_id:"m2_neighbour"}` | grass | 1 |
| `P` | NPC Wewe's parents (SQ-M2 alt) | `res://entities/npc/npc.tscn` | `{npc_id:"wewe_parents"}` | floor | 1 |
| `K` | NPC parents (SQ-M2 v4d) | `res://entities/npc/npc.tscn` | `{npc_id:"m2_parents_1"}` | floor | 1 |
| `G` | codex spot, gamelan (pavilion) | `res://entities/world/pickup.tscn` | `{codex_id:"gamelan"}` | floor | 1 |
| `E` | encounter mataram_pasar (**setpiece**, 2.2: defend Ki Sumarto's stage; the show goes on if it holds) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_pasar", size:Vector2i(22,12), waves:[[[res://entities/enemies/tuyul.tscn, Vector2i(-8,-3)], [res://entities/enemies/tuyul.tscn, Vector2i(-4,3)], [res://entities/enemies/tuyul.tscn, Vector2i(0,-4)], [res://entities/enemies/tuyul.tscn, Vector2i(5,2)], [res://entities/enemies/tuyul.tscn, Vector2i(9,-2)]], [[res://entities/enemies/tuyul.tscn, Vector2i(-6,0)], [res://entities/enemies/tuyul.tscn, Vector2i(0,5)], [res://entities/enemies/tuyul.tscn, Vector2i(6,1)]]]}` | path | 1 |
| `O` | encounter mataram_pocong | `res://entities/world/encounter.tscn` | `{area_id:"mataram_pocong", size:Vector2i(16,7), waves:[[[res://entities/enemies/pocong.tscn, Vector2i(4,0)]]]}` | path | 1 |
| `c` | chest: 55 Ilmu (Ilmu S, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_chest_pasar", item_id:"ilmu:55"}` | grass | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 3 |
| `A` | trigger, Ki Sumarto's stage in the plaza: anchor of the `mataram_pasar` setpiece (the stage prop has a 'hold' meter; thieves that reach it drain it; it must not empty) | `res://entities/world/trigger.tscn` | `{trigger_id:"pasar_stage", size:Vector2i(12,6)}` | path | 1 |
| `F` | clue, tiny ash footprints in the smithy hearth (SQ-M3 clue 1 of 2) | `res://entities/world/clue.tscn` | `{clue_id:"m3_footprints", cond:"quest:sq_m3=active"}` | floor | 1 |
| `H` | clue, half-counted green beans spilled by the stall (SQ-M3 clue 2 of 2; opens memory `sq_m3_tuyul`) | `res://entities/world/clue.tscn` | `{clue_id:"m3_beans", memory_id:"sq_m3_tuyul", cond:"quest:sq_m3=active"}` | floor | 1 |
| `I` | clue, dropped wooden toy on the lane (SQ-M2 clue; opens memory `sq_m2_child`) | `res://entities/world/clue.tscn` | `{clue_id:"m2_toy", memory_id:"sq_m2_child", cond:"quest:sq_m2=active"}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| north gate | (28,1)-(29,3) 2x3 | Arrival from mt_sawah | exit `X` (28..29,0), spawn `e` (28,1) | none |
| dalang house | (6,3)-(16,10) 11x8 | Ki Sumarto, door (11,10) | D (11,6) | 2.3 `mataram_dalang`, SQ-M4 steps 1 and 3 |
| smithy | (40,3)-(52,10) 13x8 | Blacksmith stall, door (46,10) | B (46,6) | SQ-M3 `m3_smith` |
| cross lane | (3,15)-(56,16) 54x2 | East-west lane, no enemies | neighbor `W` (20,18) | SQ-M2 `m2_neighbour` |
| parents' house | (5,19)-(13,25) 9x7 | Door (9,19) | P (9,23) | SQ-M2 alt `m2_parents_1` |
| gamelan pavilion | (38,19)-(50,26) 13x8 | Open pavilion | codex `G` (44,22) | codex:gamelan |
| market plaza | (17,30)-(39,41) 23x12 | Thieves fight, 22x12 | E (28,36) `mataram_pasar` | 2.2 lead 1 `area_cleared:mataram_pasar` |
| east road and yard | (30,36)-(58,37) 29x2 lane, yard (44,32)-(58,42) | Straight lane 28 tiles into a yard | O (50,36) `mataram_pocong` (Pocong at +4), chest `c` (56,41) | none |
| south gate | (28,44)-(29,49) 2x6 | To mt_reruntuhan | exit `Y` (28..29,50), spawn `y` (28,49) | none |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_pasar` | `E (28,36)` | 22x12 | **Setpiece.** W1: Tuyul (-8,-3), Tuyul (-4,+3), Tuyul (+0,-4), Tuyul (+5,+2), Tuyul (+9,-2); W2: Tuyul (-6,0), Tuyul (0,+5), Tuyul (+6,+1). The stage trigger `A` (28,33) holds the 'hold' meter | Burst (swarm); Bind a runner |
| `mataram_pocong` | `O (50,36)` | 16x7 | W1: Pocong (+4,+0) | Bind mid-hop (Pocong charger lane 10+ tiles) |

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Tuyul (8,31), Tuyul (10,33), Tuyul (7,34). 3 kills, skirtable.

## Area 4: mt_reruntuhan

- Size: 90 x 51 tiles = 3 x 3 screens (30 x 17 each).
- Look: Sandstone-grey broken candi walls, courtyards, fallen carved stones, a small site museum. Spires stand behind the broken wall.
- Purpose: Lead 2: Arca fight `mataram_ruins` (step 2.2) and the `arca_base` inscription beside it (Na, step 2.3). Pak Karto stays in the safe outer yard as a side-quest NPC. The codex-rich site museum, the gong nook, the far side of the `sc:mt_ruin_sawah` gate (exit `W` in the side yard past the fight). Hub of loops B and C.

### Map
```
############################################XX############################################
#...........................................e,...........................................#
#...........................................,,...........................................#
#...........................................,,................#####################......#
#...........................................,,................#___________________#......#
#...........................................,,................#___________________#......#
#...........................................,,................#___________________#......#
#...........................................,,................#___m_____n_____o___#......#
#.......................................K...,,................#___________________#......#
#...........................................,,................#___________________#......#
#...........................................,,................#___________________#......#
#...........................................,,................##########,##########......#
#...........................................,,..........................,................#
#...........................................,,..........................,................#
###########################################,,,,###########################################
#........................#..................,,..................#........................#
#........................#.rr...............,,...............rr.#........................#
#........................#.rr...............,,...............rr.#........................#
#........................#..................,,..................#........................#
#........................#................B.,,..................#........................#
#.......k................#..................,,..................#........................#
#........................#..................,,.A......rr........#........................#
#..........k.............#..................,,........rr........#........................#
#........................#..................,,..................#........................#
#........................#..................,,..................#........................#
#.........u..............#..................,,..................#........................#
#........................#,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,yY
#........................#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#........................#..................,,..................#........................#
#........................#..................,,..................#........................#
#........................#........rr........,,..................#........................#
#,,,,,,,,,,,,,,,,,,,,,,,,,........rr........,,..................#........................#
#,,,,,,,,,,,,,,,,,,,,,,,,,..................,,..................#...........k............#
#........................#..................,,..................#.............u..........#
#........................#..................,,..................#........................#
#........................#..................,,..................#........................#
#........................#.rr...............,,...............rr.#........................#
#........................#.rr...............,,...............rr.#........................#
#........................#..................,,..................#........................#
#........................###################,,###################..............r.r.......#
Ww,,,,,,,,,.................................,,.............................#####,#####...#
W,,,,,,,,,,.................................,,.............................#_________#...#
#...........................................,,.............................#_________#...#
#...........................................,,.............................#____g____#...#
#...........................................,,.............................#_______c_#...#
#...........................................,,.............................#_________#...#
#...........................................,,.............................###########...#
#...........................................,,...........................................#
#...........................................,,...........................................#
#...........................................z,...........................................#
############################################ZZ############################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to mt_pasar (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_pasar", spawn_id:"from_mt_reruntuhan"}` | path | 2 |
| `e` | spawn, arrival from mt_pasar | `res://entities/world/spawn.tscn` | `{id:"from_mt_pasar"}` | path | 1 |
| `Y` | exit to mt_wetan (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_wetan", spawn_id:"from_mt_reruntuhan"}` | path | 2 |
| `y` | spawn, arrival from mt_wetan | `res://entities/world/spawn.tscn` | `{id:"from_mt_wetan"}` | path | 1 |
| `Z` | exit to mt_kuburan (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_kuburan", spawn_id:"from_mt_reruntuhan"}` | path | 2 |
| `z` | spawn, arrival from mt_kuburan | `res://entities/world/spawn.tscn` | `{id:"from_mt_kuburan"}` | path | 1 |
| `W` | exit to mt_sawah (west edge, side yard, the `sc:mt_ruin_sawah` pocket, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_sawah", spawn_id:"from_mt_reruntuhan"}` | path | 2 |
| `w` | spawn, arrival from mt_sawah (through the gate) | `res://entities/world/spawn.tscn` | `{id:"from_mt_sawah"}` | path | 1 |
| `K` | NPC Pak Karto (side-quest NPC since v3.1, no quest assigned yet; no longer teaches Na) | `res://entities/npc/npc.tscn` | `{npc_id:"pak_karto"}` | grass | 1 |
| `A` | inscribed base of an Arca, read in place (2.3, teaches Na; cond `flag:lead_ruins`, set by clearing `mataram_ruins`) | `res://entities/npc/npc.tscn` | `{npc_id:"arca_base", cond:"flag:lead_ruins"}` | grass | 1 |
| `E` | encounter mataram_ruins (**miniboss**, 2.2: the first Arca at (-11,-5) is the elite `mt_arca_penjaga`) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_ruins", size:Vector2i(24,14), waves:[[[res://entities/enemies/arca.tscn, Vector2i(-11,-5)], [res://entities/enemies/arca.tscn, Vector2i(11,5)], [res://entities/enemies/arca.tscn, Vector2i(0,-6)], [res://entities/enemies/tuyul.tscn, Vector2i(-4,2)], [res://entities/enemies/tuyul.tscn, Vector2i(5,-1)]]]}` | path | 1 |
| `m` | codex spot, Candi Seribu (museum) | `res://entities/world/pickup.tscn` | `{codex_id:"candi_seribu"}` | floor | 1 |
| `n` | codex spot, Roro Jonggrang (museum) | `res://entities/world/pickup.tscn` | `{codex_id:"roro_jonggrang"}` | floor | 1 |
| `o` | codex spot, Arca (museum) | `res://entities/world/pickup.tscn` | `{codex_id:"arca"}` | floor | 1 |
| `g` | pickup, gong ageng (sparkle, SQ-M4, secret 1 nook) | `res://entities/world/pickup.tscn` | `{item_id:"gong_ageng"}` | floor | 1 |
| `c` | chest: Longbow (secret 1, items.md Zone 2 chest) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_secret_gong", item_id:"longbow"}` | floor | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 2 |
| `k` | loose Pocong, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/pocong.tscn` | `{}` | grass | 3 |
| `B` | clue, Laras's chalked *Ka* on the courtyard wall (2.2 `clue` piece; journal note only, no quest trigger; ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"ka_chalk"}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| entry and outer yard | (1,1)-(88,13) 88x13 | Safe yard before the courtyard | exit `X` (44..45,0), spawn `e` (44,1), Pak Karto `K` (40,8) | side-quest NPC `pak_karto` (none yet) |
| site museum | (62,3)-(82,11) 21x9 | Codex-rich room, door (72,11) | `m` (66,7), `n` (72,7), `o` (78,7) | codex:candi_seribu, roro_jonggrang, arca |
| courtyard | (26,15)-(63,38) 38x24 | Ruins wake fight, 24x14 room in the middle | E (44,26) `mataram_ruins`, 3 Arca on the edges, 2 Tuyul; `arca_base` `A` (47,21), 3 tiles east of the central path and 5 north of the fight spot | 2.2 lead 2 `mataram_ruins` (sets `lead_ruins`), 2.3 `arca_base` |
| side yard (west) | (1,15)-(24,49) 24x35 | Past the fight, reached by the west gap (25,31..32) | exit `W` (0,40..41), spawn `w` (1,40) | `sc:mt_ruin_sawah` far side |
| east road | (65,26)-(88,27) 24x2 | Road to mt_wetan | exit `Y` (89,26..27), spawn `y` (88,26) | none |
| south yard | (44,40)-(45,49) 2x10 | Road to mt_kuburan | exit `Z` (44..45,50), spawn `z` (44,49) | none |
| gong nook | (75,40)-(85,46) 11x7 | Secret 1, door (80,40) between two rocks (ASSUMED: open gap, no breakable wall) | gong `g` (80,43), chest `c` (83,44) | SQ-M4 `gong_ageng` |
| chalk wall | (40,17)-(43,21) | The `clue` piece of lead 2, west of the central path just before the fight | clue `B` (42,19) | 2.2 journal note |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_ruins` | `E (44,26)` | 24x14 | **Miniboss.** W1: Arca (-11,-5) elite `mt_arca_penjaga` (HP x4, Ilmu x4, **TUNE**; builder: `unique_id` on this wave entry or an `arca_elite.tscn`), Arca (+11,+5), Arca (+0,-6), Tuyul (-4,+2), Tuyul (+5,-1) | Combo and dodge (Na is read after the fight, by design); Burst on the Tuyul |

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Pocong (8,20), Pocong (11,22), Tuyul (10,25), Pocong (76,32), Tuyul (78,33). 5 kills, skirtable.

## Area 5: mt_kuburan

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Old graveyard under frangipani, a bare hill with one tree, a low mist.
- Purpose: Lead 3 (step 2.2, required): graveyard fight `mataram_kuburan` and the `hunter_war` beat. Optional rooms: Wewe Gombel hill (SQ-M2 elite or peaceful end), crypt secret with Panah Pasopati. Branches off loop C.

### Map
```
##########XX################################################
#.........e,...............................................#
#.........,,...............................................#
#.........,,......B........................................#
#.........,,...............................................#
#.........,,..r.r.r.r.r.r.r.r.r.r..........................#
#.........,,........................................b......#
#.........,,..r.r.r.r.r.r.r.r.r.r..........................#
#.........,,...........H......A............................#
#.........,,...............................................#
#.........,,....................................T..........#
#.........,,..................................q............#
#.........,,...............................................#
#.....b...........................b...............p........#
#..........................................................#
#..........................................................#
#..........................................................#
#..........................................................#
#.....................E..............,,,,,,,,,,,,,C,,,,,,,yY
#....................................,,,,,,,,,,,,,,,,,,,,,,Y
#.............................................,............#
#.............................................,............#
#.....b.................................######,######......#
#.......................................#___________#......#
#.................................b.....#___________#......#
#.......................................#___________#......#
#.......................................#___________#......#
#.......................................#_____c_____#......#
#.......b.....r..r..r..r..r..r..r.......#___________#......#
#.......................................#___________#......#
#.......................................#############......#
#.............................b............................#
#..........................................................#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to mt_reruntuhan (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_reruntuhan", spawn_id:"from_mt_kuburan"}` | path | 2 |
| `e` | spawn, arrival from mt_reruntuhan | `res://entities/world/spawn.tscn` | `{id:"from_mt_reruntuhan"}` | path | 1 |
| `Y` | exit to mt_wetan (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_wetan", spawn_id:"from_mt_kuburan"}` | path | 2 |
| `y` | spawn, arrival from mt_wetan | `res://entities/world/spawn.tscn` | `{id:"from_mt_wetan"}` | path | 1 |
| `E` | encounter mataram_kuburan | `res://entities/world/encounter.tscn` | `{area_id:"mataram_kuburan", size:Vector2i(26,15), waves:[[[res://entities/enemies/pocong.tscn, Vector2i(8,-4)], [res://entities/enemies/pocong.tscn, Vector2i(8,4)], [res://entities/enemies/tuyul.tscn, Vector2i(-6,-5)], [res://entities/enemies/tuyul.tscn, Vector2i(-3,5)], [res://entities/enemies/tuyul.tscn, Vector2i(2,0)]]]}` | grass | 1 |
| `T` | trigger, Wewe hill entered (SQ-M2) | `res://entities/world/trigger.tscn` | `{trigger_id:"wewe_hill", size:Vector2i(17,12)}` | grass | 1 |
| `q` | elite Wewe Gombel (SQ-M2, inert until step 4; `unique_id` `wewe_elite`, elite stats HP 780, Ilmu x4, **TUNE**) | `res://entities/enemies/wewe_gombel.tscn` | `{unique_id:"wewe_elite"}` | grass | 1 |
| `p` | NPC Wewe's parents at the hill (SQ-M2 peaceful) | `res://entities/npc/npc.tscn` | `{npc_id:"wewe_parents_2"}` | grass | 1 |
| `c` | chest: Panah Pasopati (secret 2, crypt) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_secret_pasopati", item_id:"panah_pasopati"}` | floor | 1 |
| `H` | trigger, beat `hunter_war` staging (the Hunter among the graves; plays when `flag:lead_kuburan`, `zone:mt_kuburan`) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_hunter_war", size:Vector2i(19,6)}` | grass | 1 |
| `A` | clue, the Hunter's third mask fragment among the graves (2.4 H3; opens memory `h3`; appears when `flag:lead_kuburan`) | `res://entities/world/clue.tscn` | `{clue_id:"hunter_mask_3", memory_id:"h3", cond:"flag:lead_kuburan"}` | grass | 1 |
| `B` | encounter mataram_kuburan_gate (2.2, fight 1 of the graveyard lead, north field) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_kuburan_gate", size:Vector2i(20,9), waves:[[[res://entities/enemies/tuyul.tscn, Vector2i(-6,-1)], [res://entities/enemies/tuyul.tscn, Vector2i(-3,3)], [res://entities/enemies/tuyul.tscn, Vector2i(5,0)], [res://entities/enemies/pocong.tscn, Vector2i(8,2)]]]}` | grass | 1 |
| `C` | encounter mataram_pemanen (**miniboss**, 2.4: the harvest captain on the east road; cond `flag:memory_h3`) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_pemanen", cond:"flag:memory_h3", size:Vector2i(18,9), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(0,0)], [res://entities/enemies/pocong.tscn, Vector2i(6,-3)], [res://entities/enemies/pocong.tscn, Vector2i(6,3)]]]}` | path | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| north gate | (10,1)-(11,12) 2x12 | Arrival from mt_reruntuhan, path into the graveyard | exit `X` (10..11,0), spawn `e` (10,1) | none |
| graveyard | (9,11)-(35,25) 27x15 | Lead 3 fight, 26x15, open ground, lane 10+; the beat spot `H` (23,8) is 3 rows above its rect | E (22,18) `mataram_kuburan`, trigger `H` (23,8) | 2.2 lead 3 `area_cleared:mataram_kuburan` (sets `lead_kuburan`); beat `hunter_war` |
| wewe hill | (40,3)-(56,16) 17x14 | Bare hill, one tree (52,6) | trigger `T` (48,10), elite `q` (46,11), parents `p` (50,13) | SQ-M2 `wewe_hill`, `wewe_parents_2`, `wewe_elite` |
| east road | (37,18)-(58,19) 22x2 | Road to mt_wetan | exit `Y` (59,18..19), spawn `y` (58,18) | none |
| crypt | (40,22)-(52,30) 13x9 | Secret 2, door (46,22), stairs (46,20..21) | chest `c` (46,27) | Panah Pasopati source |
| north field | (12,1)-(28,8) 17x8 | Fight 1 of lead 3 before the graveyard, and the mask fragment | E `B` (18,3) `mataram_kuburan_gate`, clue `A` (30,8) | 2.2 fight, 2.4 `clue_examined:hunter_mask_3` |
| harvest road | (41,14)-(58,22) 18x9 | The captain waits on the east road once the memory is done | E `C` (50,18) `mataram_pemanen` | 2.4 miniboss |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_kuburan` | `E (22,18)` | 26x15 | W1: Pocong (+8,-4), Pocong (+8,+4), Tuyul (-6,-5), Tuyul (-3,+5), Tuyul (+2,+0) | Bind a Pocong mid-hop; Burst the Tuyul |
| `mataram_kuburan_gate` | `E (18,3)` | 20x9 | W1: Tuyul (-6,-1), Tuyul (-3,+3), Tuyul (+5,+0), Pocong (+8,+2) | Burst the Tuyul, Bind the Pocong mid-hop |
| `mataram_pemanen` | `E (50,18)` | 18x9 | **Miniboss.** W1: Faceless captain (0,0) elite `mt_harvest_captain` (HP x4, **TUNE**), Pocong (+6,-3), Pocong (+6,+3); cond `flag:memory_h3` | Bind the Pocong first, then Dash-strike the captain |
## Area 6: mt_wetan

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: Rocky foothill field, dry grass, boulders, a cliff ledge in the south, the juru kunci's hut.
- Purpose: Rock thrower fight `mataram_batu` (2.5), the juru kunci (2.5, teaches Ra), the lesung women (2.3, Ca), the `lengser_word` beat spot, K2 north to the temples, K3 east to Tanah Timur, the drop ledge south, link to mt_kuburan.

### Map
```
############################################NN############################################
#..........................................#n,#..........................................#
#..........................................#,,#..........................................#
#...................##########.............#KK#..........................................#
#.......rr..........#________#.............#,,#..........................................#
#.......rr..........#________#......A.......,,...........................................#
#...................#___M____#..............,,....................rrr....................#
#...................#________#......G.......,,....................rrr....................#
#...................#________#..............,,................g...rrr...........c........#
#...................####,#####..............,,...........................................#
#.......................,...................L,...........................................#
#.......................,...................,,...........................................#
Xe,,,,,,,,,,,,,,,,,,,,,,C,,,,,,,,,,,,,,,,,,,,,...........................................#
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,...........................................#
#.............,,.........................................................................#
#.............,,..................B.............................................##########
#.............,,..............................................,,,,,,,,,,,,,,,,,,,,,,J,,,tT
#.............,,..............................................,,,,,,,,,,,,,,,,,,,,,,J,,,,T
#.............,,....k...........................................................##########
#.............,,......u..................................................................#
#.............,,..............rr..................E......................................#
#.............,,..............rr.........................................................#
#.............,,.....u................................................,,.................#
#.............,,......................................................,,.................#
#.............,,......................................................,,....rrr..........#
#.............,,......................................................,,....rrr..........#
#.............,,......................................................,,....rrr..........#
#.............,,......................................................,,.................#
#.............,,...................rr...................rr............,,.................#
#.............,,...................rr...................rr............,,.................#
#.............,,..................................................bbbb,,bbbb.............#
#.............,,............................................##########,,#########........#
#.............y,............................................##########,,#########........#
##############YY######################################################DD##################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to mt_reruntuhan (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_reruntuhan", spawn_id:"from_mt_wetan"}` | path | 2 |
| `e` | spawn, arrival from mt_reruntuhan | `res://entities/world/spawn.tscn` | `{id:"from_mt_reruntuhan"}` | path | 1 |
| `N` | exit to mt_candi (north edge, behind K2, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_candi", spawn_id:"from_mt_wetan"}` | path | 2 |
| `n` | spawn, arrival from mt_candi | `res://entities/world/spawn.tscn` | `{id:"from_mt_candi"}` | path | 1 |
| `K` | kabut K2, the stairs up to the temples (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq2_6"}` | path | 2 |
| `Y` | exit to mt_kuburan (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_kuburan", spawn_id:"from_mt_wetan"}` | path | 2 |
| `y` | spawn, arrival from mt_kuburan | `res://entities/world/spawn.tscn` | `{id:"from_mt_kuburan"}` | path | 1 |
| `D` | exit, the drop to mt_tegal (south cliff ledge, 2 tiles, one way, no spawn back) | `res://entities/world/exit.tscn` | `{target_zone:"mt_tegal", spawn_id:"from_mt_wetan"}` | path | 2 |
| `T` | exit to tt_kulon (east edge, not built yet, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_kulon", spawn_id:"from_mt_wetan"}` | path | 2 |
| `t` | spawn, arrival from tt_kulon | `res://entities/world/spawn.tscn` | `{id:"from_tt_kulon"}` | path | 1 |
| `J` | kabut K3, east gate to Tanah Timur (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq2_9"}` | path | 2 |
| `M` | NPC juru kunci the juru kunci (2.5, teaches Ra after `mataram_batu`) | `res://entities/npc/npc.tscn` | `{npc_id:"juru_kunci"}` | floor | 1 |
| `E` | encounter mataram_batu | `res://entities/world/encounter.tscn` | `{area_id:"mataram_batu", size:Vector2i(24,14), waves:[[[res://entities/enemies/genderuwo.tscn, Vector2i(9,0)], [res://entities/enemies/pocong.tscn, Vector2i(4,-4)], [res://entities/enemies/pocong.tscn, Vector2i(4,4)]]]}` | grass | 1 |
| `c` | chest: Iron Staff (items.md Zone 2, no drops yet) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_chest_wetan", item_id:"iron_staff"}` | grass | 1 |
| `g` | codex spot, Genderuwo | `res://entities/world/pickup.tscn` | `{codex_id:"genderuwo"}` | grass | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 2 |
| `k` | loose Pocong, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/pocong.tscn` | `{}` | grass | 1 |
| `L` | trigger, beat `lengser_word` staging (plays when `flag:choice_handed`, `flag:mq2_6`, `zone:mt_wetan`; one line, in the stairs corridor below K2) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_lengser_word", size:Vector2i(2,3)}` | path | 1 |
| `A` | NPC Nyai Gendhis and the lesung women of the foothill hamlet (2.10, teaches Ca once `mataram_lesung_yard` is cleared) | `res://entities/npc/npc.tscn` | `{npc_id:"lesung_women"}` | grass | 1 |
| `B` | encounter mataram_batu_2 (2.5, fight 1 on the junction field) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_batu_2", size:Vector2i(18,9), waves:[[[res://entities/enemies/tuyul.tscn, Vector2i(-5,-1)], [res://entities/enemies/tuyul.tscn, Vector2i(0,3)], [res://entities/enemies/tuyul.tscn, Vector2i(5,0)]]]}` | grass | 1 |
| `C` | trigger, puzzle `puzzle_wetan_lamps` (2.12: align the foothill shrine braziers; sets `flag:puzzle_wetan_lamps`) | `res://entities/world/trigger.tscn` | `{trigger_id:"puzzle_wetan_lamps", size:Vector2i(4,4)}` | path | 1 |
| `G` | encounter mataram_lesung_yard (2.9 Lead 3: clear the haunted mill yard for Nyai Gendhis) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_lesung_yard", size:Vector2i(14,8), waves:[[[res://entities/enemies/pocong.tscn, Vector2i(-3,0)], [res://entities/enemies/tuyul.tscn, Vector2i(3,-2)], [res://entities/enemies/tuyul.tscn, Vector2i(3,2)]]]}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| west road | (1,12)-(43,13) 43x2 | Arrival from mt_reruntuhan | exit `X` (0,12..13), spawn `e` (1,12) | none |
| juru kunci hut | (20,3)-(29,9) 10x7 | Door (24,9) | M (24,6) | 2.5 `juru_kunci`, sets `mq2_6` |
| north stairs | (44,1)-(45,13) 2x13 | Corridor to the temples; K2 at (44..45,3) | K `K`, exit `N` (44..45,0), spawn `n` (44,1), trigger `L` (44,10) | 2.5 flag `mq2_6` opens K2; beat `lengser_word` |
| rocky field | (38,13)-(62,27) 25x15 | Rock thrower fight, 24x14, lane 16 | E (50,20) `mataram_batu` | 2.5 `area_cleared:mataram_batu` |
| kuburan road | (14,14)-(15,32) 2x19 | Road to mt_kuburan | exit `Y` (14..15,33), spawn `y` (14,32) | none |
| drop ledge | (70,22)-(71,32) 2x11 | Worn path and railing gaps, south cliff | exit `D` (70..71,33), no spawn back | none |
| east road | (62,16)-(88,17) 27x2 | Walled road to tt_kulon; K3 at (84,16..17) | J, exit `T` (89,16..17), spawn `t` (88,16) | mq2_9 opens K3 |
| boulder corner | (60,3)-(86,10) 27x8 | Chest and codex | chest `c` (80,8), codex `g` (62,8) | codex:genderuwo |
| lesung yard | (32,2)-(41,9) 10x8 | Foothill hamlet yard east of the hut | lesung women `A` (36,5) | 2.3 `lesung_women` (Ca) |
| hut path | (14,10)-(34,16) | Lamp puzzle in front of the hut, door kabut `F` (24,9), fight 1 of 2.5 | trigger `C` (24,12), E `B` (34,15) `mataram_batu_2` | 2.5 puzzle, fight |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_batu` | `E (50,20)` | 24x14 | W1: Genderuwo (+9,+0), Pocong (+4,-4), Pocong (+4,+4) | Bind the Pocong, close in on the Genderuwo; dodge rocks |

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Pocong (20,18), Tuyul (22,19), Tuyul (21,22). 3 kills, skirtable.
| `mataram_batu_2` | `E (34,15)` | 18x9 | W1: Tuyul (-5,-1), Tuyul (0,+3), Tuyul (+5,0) | Burst |
## Area 7: mt_candi

- Size: 90 x 51 tiles = 3 x 3 screens (30 x 17 each).
- Look: The unfinished Candi Seribu: spires, scaffolds, spirit builders at work, a temple gate wall, the boss court in the north.
- Purpose: Front yard with the temple gate fight, batu bintang, petilasan `mataram_2` next to the arena gate, boss arena Bandung Bondowoso (34x20 open floor), the far side of the `sc:mt_candi_gapura` gate (west exit).

### Map
```
##########################################################################################
#............####################################........................................#
#............#rr,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,rr#........................................#
#............#rr,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,rr#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,J,,,,,,,,,B,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,F,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,T,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,G,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,I,,,,,,,,,,,,,,,,,#........................................#
#............#rr,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,rr#........................................#
#............#rr,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,rr#........................................#
#............################,,,#################........................................#
#............................,,,..................,,.....................................#
#............................,,,H.................,,.....................................#
#............................,P,.L................,,.....................................#
Yy,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.D................,,.....................................#
Y,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..................,,.....................................#
#.............................,,,,,,,,,,K,,,,,,,,,,,..................rr.................#
#.............................,,,,,,,,,,,,,,,,,,,,,,..................rr.................#
#.................................................,,............................c........#
#.......rr........................................,,.....................................#
#.......rr........................................,,.....................................#
#.................................................,,.....................................#
#...................rr............................,,....A................................#
#...................rr............................,,.....................................#
#.................................................,,....................s................#
#.................................................,,.....................................#
#.................................................E,.....................................#
#.................................................,,.....................................#
#.....rr..........................................,,..................rr.................#
#.....rr..........................................,,........C.........rr.................#
#.................................................,,.....................................#
#.................................................,,.....................................#
#.................................................,,.....................................#
#.................................................,,............................rr.......#
#.................................................,,............................rr.......#
#.................................................,,.....................................#
#.................................................,,.....................................#
#.................................................e,.....................................#
##################################################XX######################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to mt_wetan (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_wetan", spawn_id:"from_mt_candi"}` | path | 2 |
| `e` | spawn, arrival from mt_wetan | `res://entities/world/spawn.tscn` | `{id:"from_mt_wetan"}` | path | 1 |
| `Y` | exit to mt_gapura (west edge, front yard, the `sc:mt_candi_gapura` pocket, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_gapura", spawn_id:"from_mt_candi"}` | path | 2 |
| `y` | spawn, arrival from mt_gapura (through the gate) | `res://entities/world/spawn.tscn` | `{id:"from_mt_gapura"}` | path | 1 |
| `P` | petilasan 2 | `res://entities/petilasan/petilasan.tscn` | `{id:"mataram_2"}` | path | 1 |
| `B` | boss Bandung Bondowoso (2.10), awakened after the camp turn, the K3 memory and the LC3 chapter (`flag:mq2_lc`) | `res://entities/bosses/bandung_bondowoso.tscn` | `{cond:"flag:mq2_lc"}` | path | 1 |
| `F` | encounter mataram_camp (**setpiece**, 2.6: the Pamali stone wakes; hold the court until the seal cracks, MQ2 2.6) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_camp", cond:"flag:mq2_6", size:Vector2i(30,16), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-6,-3)], [res://entities/enemies/faceless.tscn, Vector2i(6,-3)], [res://entities/enemies/faceless.tscn, Vector2i(0,4)], [res://entities/enemies/faceless_archer.tscn, Vector2i(0,-6)]], [[res://entities/enemies/faceless.tscn, Vector2i(-8,2)], [res://entities/enemies/faceless.tscn, Vector2i(8,2)], [res://entities/enemies/faceless_archer.tscn, Vector2i(-4,-6)], [res://entities/enemies/faceless_archer.tscn, Vector2i(4,-6)]]]}` | path | 1 |
| `E` | encounter mataram_candi | `res://entities/world/encounter.tscn` | `{area_id:"mataram_candi", size:Vector2i(28,16), waves:[[[res://entities/enemies/genderuwo.tscn, Vector2i(8,-4)], [res://entities/enemies/arca.tscn, Vector2i(-12,-5)], [res://entities/enemies/arca.tscn, Vector2i(12,-5)]], [[res://entities/enemies/tuyul.tscn, Vector2i(0,-3)], [res://entities/enemies/tuyul.tscn, Vector2i(-4,0)], [res://entities/enemies/tuyul.tscn, Vector2i(4,0)]]]}` | path | 1 |
| `s` | pickup, batu bintang (SQ-T3 meteorite fragment) | `res://entities/world/pickup.tscn` | `{item_id:"batu_bintang"}` | grass | 1 |
| `c` | chest: 110 Ilmu (Ilmu M, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_chest_candi", item_id:"ilmu:110"}` | grass | 1 |
| `T` | trigger, beat `camp` staging (plays when `flag:mq2_7`, `zone:mt_candi`; the cleared camp, Laras's lontar strip) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_camp", size:Vector2i(12,6)}` | path | 1 |
| `A` | NPC bound hauler at the temple gate (2.6 `talk`; unnamed, says where the prisoners are held) | `res://entities/npc/npc.tscn` | `{npc_id:"hauler"}` | grass | 1 |
| `C` | clue, rubble with fresh chisel marks and spirit hand-prints (2.7 K3, 1 of 3) | `res://entities/world/clue.tscn` | `{clue_id:"rubble"}` | grass | 1 |
| `D` | clue, a lesung left in the middle of its rhythm (2.7 K3, 2 of 3) | `res://entities/world/clue.tscn` | `{clue_id:"lesung_mid"}` | grass | 1 |
| `G` | clue, Laras's *Ka* strip in the cleared camp (2.7 K3, 3 of 3; opens memory `k3_lesung`) | `res://entities/world/clue.tscn` | `{clue_id:"ka_strip", memory_id:"k3_lesung"}` | path | 1 |
| `H` | clue, Laras's lontar fragment at the petilasan (2.9, opens chapter `lc3`; ASSUMED id, cond `flag:memory_k3_lesung`) | `res://entities/world/clue.tscn` | `{clue_id:"lc3_lontar", memory_id:"lc3", cond:"flag:memory_k3_lesung"}` | grass | 1 |
| `I` | encounter mataram_camp_gate (2.6, fight at the arena gate; cond `flag:mq2_6`) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_camp_gate", cond:"flag:mq2_6", size:Vector2i(16,6), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-3,0)], [res://entities/enemies/faceless.tscn, Vector2i(3,0)], [res://entities/enemies/faceless_archer.tscn, Vector2i(0,-3)]]]}` | path | 1 |
| `J` | encounter mataram_camp_captain (**miniboss**, 2.6: the camp captain; cond `flag:mq2_6`) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_camp_captain", cond:"flag:mq2_6", size:Vector2i(12,10), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(0,0)], [res://entities/enemies/faceless_archer.tscn, Vector2i(4,-2)], [res://entities/enemies/faceless.tscn, Vector2i(-4,2)]]]}` | path | 1 |
| `K` | encounter candi_crypt_hall (2.17 descend through Laras's unlocked crypt to the central temple sanctum) | `res://entities/world/encounter.tscn` | `{area_id:"candi_crypt_hall", size:Vector2i(14,8), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-3,0)], [res://entities/enemies/arca_penjaga.tscn, Vector2i(3,0)]]]}` | path | 1 |
| `L` | clue, stitched syllable scrap / Lengser's note at the camp stake (SQ-C3 fragment 1) | `res://entities/world/clue.tscn` | `{clue_id:"c3_camp_scrap", cond:"flag:mq2_7"}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| south gate | (50,47)-(51,49) 2x3 | Arrival from mt_wetan | exit `X` (50..51,50), spawn `e` (50,49) | none |
| front yard fight | (36,30)-(64,46) 29x17 | Temple gate fight, 28x16, two waves | E (50,38) `mataram_candi` | 2.6 `area_cleared:mataram_candi` |
| east yard | (66,28)-(88,48) 23x21 | Side yard | batu bintang `s` (72,36), chest `c` (80,30) | item_picked:batu_bintang |
| west road | (1,26)-(28,27) 28x2 | Road to the petilasan, 30 tiles from the exit | exit `Y` (0,26..27), spawn `y` (1,26) | `sc:mt_candi_gapura` far side |
| petilasan court | (29,23)-(31,27) 3x5 | Rest right before the arena, no fight | P (30,25) | LC3 clue `lc3_lontar` (32,24) at `mataram_2` |
| boss arena | (14,2)-(47,21) 34x20 | 34x20 open floor, gate gap (29..31,22), pillars spawn 5-8 tiles around B | camp F (30,12), B (30,9), beat trigger `T` (30,15) | 2.6 `mataram_camp` (sets `mq2_7`), beat `camp`; 2.10 `bandung_bondowoso` |
| clue spots | rubble (60,41) east side of the front yard; `lesung_mid` (33,26) beside the petilasan court; `ka_strip` (28,16) in the court by the `camp` beat spot | The K3 Hunt clues, walked in this order | clues `C` `D` `G`, hauler `A` (56,34), `lc3_lontar` `H` (32,24) | 2.7 `all` of three, 2.6 talk, 2.9 |
| camp sequence | the arena, gate (30,19), captain (20,9), camp (30,12) | In order: gate fight, captain miniboss, camp setpiece | E `I` (30,19), E `J` (20,9), `F` (30,12) | 2.6 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_candi` | `E (50,38)` | 28x16 | W1: Genderuwo (+8,-4), Arca (-12,-5), Arca (+12,-5); W2: Tuyul (+0,-3), Tuyul (-4,+0), Tuyul (+4,+0) | Na (Dash-strike) on the Arca; Bind then Burst for wave 2 |
| `mataram_camp_gate` | `E (30,19)` | 16x6 | W1: Faceless (-3,0), Faceless (+3,0), Faceless archer (0,-3); cond `flag:mq2_6` | Dash-strike the archer; Faceless are known |
| `mataram_camp_captain` | `E (20,9)` | 12x10 | **Miniboss.** W1: Faceless captain (0,0) elite `mt_camp_captain` (HP x4, **TUNE**), Faceless archer (+4,-2), Faceless (-4,+2); cond `flag:mq2_6` | Dash-strike the archer, then the captain |
| `mataram_camp` | `F (30,12)` | 30x16 | **Setpiece** (as before, W1/W2, 2.6): while it runs, the Pamali stone `T` (30,15) glows; the encounter ends when the stone cracks (the turn) | as before |
## Area 8: mt_tegal

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Dry field, an old brick kiln where the tuyul hide, a dry well. Quiet and a little funny.
- Purpose: Landing of the drop. SQ-M3 hideout (kiln). Secret 3 well chamber. Link to mt_sawah. Holds the gate of shortcut `sc:mt_tt` (boulder-blocked back road, opens from tt_sabana).

### Map
```
############################################################
#..........................................................#
#..........................................................#
#..........................................................#
#.......................l..................................#
#.......................,...........................rr.....#
#.......................,...........#############...rr.....#
#.......................,...........#___________#..........#
#.......................,...........#___________#..........#
#.......................,...........#___L_M_q___#..........#
#.......................,...........#_____T_____#..........#
#.......................,...........#___________#..........#
#.......................,...........#___________#..........#
#.......................,...........######,######..........#
#.......................,.................,.........#......#
#.......................,.................,.........########
Xe,,,,,,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,,,,,,,,,,,,,=,,,,,yY
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,=,,,,,,Y
#...................................................########
#...................................................#......#
#..........rr...............s..............................#
#..........rr..............................................#
#............,..........................u..................#
#............,.............................................#
#.......#####,#####.......................u................#
#.......#_________#........................................#
#.......#_________#......................k.................#
#.......#_________#........................................#
#.......#____c____#........................................#
#.......#_________#........................................#
#.......###########........................................#
#..........................................................#
#..........................................................#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to mt_sawah (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_sawah", spawn_id:"from_mt_tegal"}` | path | 2 |
| `e` | spawn, arrival from mt_sawah | `res://entities/world/spawn.tscn` | `{id:"from_mt_sawah"}` | path | 1 |
| `l` | spawn, landing of the drop from mt_wetan (no exit back) | `res://entities/world/spawn.tscn` | `{id:"from_mt_wetan"}` | path | 1 |
| `Y` | exit to tt_sabana (east edge, pocket, not built yet, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_sabana", spawn_id:"from_mt_tegal"}` | path | 2 |
| `y` | spawn, arrival from tt_sabana (in the pocket on the open side of `=`) | `res://entities/world/spawn.tscn` | `{id:"from_tt_sabana"}` | path | 1 |
| `=` | shortcut gate, boulder-blocked back road (opens from the east pocket, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:mt_tt", open_side:"e"}` | path | 2 |
| `T` | trigger, tuyul hideout entered (SQ-M3) | `res://entities/world/trigger.tscn` | `{trigger_id:"tuyul_hideout", size:Vector2i(11,6)}` | floor | 1 |
| `L` | NPC tuyul leader (SQ-M3, talk for the peaceful end) | `res://entities/npc/npc.tscn` | `{npc_id:"tuyul_leader"}` | floor | 1 |
| `M` | trigger, green-bean counting trap in the kiln (SQ-M3 peaceful end; fires `area_entered:m3_trap_sprung`) | `res://entities/world/trigger.tscn` | `{trigger_id:"m3_trap_sprung", size:Vector2i(4,4)}` | floor | 1 |
| `q` | elite tuyul leader (SQ-M3, inert until step 4; `unique_id` `tuyul_leader`, elite stats HP x4, Ilmu x4, **TUNE**; in the peaceful end it is the one caught while counting, in the fight end the swarm of `mataram_tuyul` wakes with it) | `res://entities/enemies/tuyul_leader.tscn` | `{unique_id:"tuyul_leader"}` | floor | 1 |
| `c` | chest: Amulet (secret 3, well chamber, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_secret_sumur", item_id:"amulet"}` | floor | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 2 |
| `k` | loose Pocong, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/pocong.tscn` | `{}` | grass | 1 |
| `E` | encounter mataram_tegal_pillars (2.13 fight across the plain of rising stones) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_tegal_pillars", size:Vector2i(15,9), waves:[[[res://entities/enemies/arca_penjaga.tscn, Vector2i(-4,0)], [res://entities/enemies/genderuwo.tscn, Vector2i(4,0)]]]}` | path | 1 |
| `s` | pickup, batu bintang (SQ-T3 fallen meteorite fragment) | `res://entities/world/pickup.tscn` | `{item_id:"batu_bintang"}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| west road | (1,16)-(51,17) 51x2 | Link to mt_sawah | exit `X` (0,16..17), spawn `e` (1,16) | none |
| landing path | (24,4)-(24,15) 1x12 | One-way drop landing | spawn `l` (24,4), no exit back | none |
| kiln hideout | (36,6)-(48,13) 13x8 | Brick kiln, door (42,13) | trigger `T` (42,10), puzzle trigger `L` (40,9), elite `q` (44,9) | SQ-M3 `tuyul_hideout`, `m3_trap_sprung`, `tuyul_leader` |
| well chamber | (8,24)-(18,30) 11x7 | Secret 3, door (13,24), dry well rocks above | chest `c` (13,28) | none |
| back road pocket | (53,16)-(58,17) 6x2 | Boulder-blocked back road, gate (52,16..17), open side east | gate `=` `sc:mt_tt`, exit `Y` (59,16..17), spawn `y` (58,16) | none |

### Encounters
None.

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Tuyul (40,22), Tuyul (42,24), Pocong (41,26). 3 kills, skirtable.

## Side stories v4d spots (2026-11-06, [quests.md](../quests.md) 5)
Spots that are not new map characters are listed here, not drawn into the maps (**ASSUMED**: the builder adds them as plain spots at these coordinates, on floor tiles inside the stated rooms; `gen_zones.py` does not read this section). Clue legend rows that changed in the maps (`mt_sawah` `L` and `s`, `mt_tegal` `L`, `q`, `mt_kuburan` `q`) are marked v4d in their legend. Props follow the clue convention `{clue_id, memory_id?, cond?}`; where a step is an `all` of clues and a memory follows, the memory id sits on the clue examined last (as `ka_strip` does, **ASSUMED**: the builder opens the memory only when the step's other pieces are already done). `cond` uses `quest:<id>=active` (the quest-state form in [quests.md](../quests.md) 7).

| Area | Spot | Scene and props | At | Card | Notes |
|------|------|-----------------|----|------|-------|
| `mt_sawah` | pot lid, rice gone | clues `L`, `s` (see its legend) | (8,24), (11,23) | SQ-M1 | Both in the lumbung; memory `sq_m1_selendang` follows. `nawang_wulan` `N` (36,14) is the giver and the turn-in |
| `mt_pasar` | `m2_neighbour`, `m2_parents_1`, `m3_smith` | NPCs `W`, `P`, `B` (legend, ids renamed v4d) | (20,18), (9,23), (46,6) | SQ-M2, SQ-M3 | `m2_parents_1` says "nobody called him" (step 2) and takes the child home (step 5, **ASSUMED**) |
| `mt_pasar` | `m3_footprints` | `clue.tscn` `{clue_id:"m3_footprints", cond:"quest:sq_m3=active"}` | (48,8) | SQ-M3 | Tiny footprints in the smithy hearth ash |
| `mt_tegal` | `m3_beans` | `clue.tscn` `{clue_id:"m3_beans", memory_id:"sq_m3_tuyul", cond:"quest:sq_m3=active"}` | (38,11) | SQ-M3 | Spilled green beans, half counted. Names the tuyul. Opens `sq_m3_tuyul` once the footprints are also done |
| `mt_tegal` | `m3_trap_sprung` | trigger `L` (legend), `trigger_id` `puzzle_m3_trap_sprung` | (40,9) | SQ-M3 peaceful | Puzzle: the player sets out the beans (a 3-bean pile, **VERIFY** beans or crabs) at three marked spots along the leader's path; it stops to count each pile (4 s, **TUNE**); when the third is counted the net drops. The elite `q` (44,9) is caught, not fought; kills nothing |
| `mt_kuburan` | `m2_toy` | `clue.tscn` `{clue_id:"m2_toy", memory_id:"sq_m2_child", cond:"quest:sq_m2=active"}` | (44,14) | SQ-M2 | The boy's toy on the hill path (inside the hill room (40,3)-(56,16)), south of the tree. Its note names the Wewe Gombel. Opens `sq_m2_child` once the parents have been talked to |
| `mt_kuburan` | hill-path arena | trigger `T` (48,10) `wewe_hill`, elite `q` (46,11) `wewe_elite`, parents `p` (50,13) `wewe_parents_2` | see legend | SQ-M2 | Fight branch: the elite alone in the hill room (no wave), HP 780, **TUNE**. Peaceful branch: `wewe_parents_2` arrive at (50,13) after the memory, call kindly and bang pots (**VERIFY**), and the elite `q` is not spawned (cond `!flag:sq_m2_peaceful`, **ASSUMED**); the child is at the parents' feet |
| `mt_candi` | `c3_camp_scrap` | `clue.tscn` `{clue_id:"c3_camp_scrap", cond:"flag:mq2_7"}` | (31,26) | SQ-C3 fragment 1 | The Mataram camp of step 2.6 (`mq2_7`) is the court of `mt_candi`; the scrap hangs on a stake in the petilasan court, a few tiles from the cleared camp, so it is still reachable after the boss. Freed variant: a scrap of cloth with a stitched sound. Handed variant: Uwa Lengser's note. Not in `kg_pamali` |
| `mt_gapura` | `cepot` | NPC `{npc_id:"cepot", cond:"flag:c4_1,flag:mq2_a1,!flag:c4_2"}` | (7,17) | SQ-C4 part 2 | In the border market lane between the two stalls. `quiet` entries (**ASSUMED**); he sets `c4_2` at the end |
| `mt_gapura` | `c4_roll_a`, `c4_roll_b` | `clue.tscn` `{clue_id:"c4_roll_a", cond:"flag:c4_1,flag:mq2_a1"}` and `{clue_id:"c4_roll_b", ...}` | (6,13), (6,20) | SQ-C4 part 2 | The two recruiters' rolls, beside `recruiter_a` (4,13) and `recruiter_b` (4,20): his name on both |
| `mt_gapura` | `c4_market_clear` | trigger, `trigger_id` `puzzle_c4_market_clear`, `size:Vector2i(9,10)` | rect (1,13)-(9,22), goal (10,16) | SQ-C4 part 2 | Stealth puzzle, no combat: Cepot follows two tiles behind. Each recruiter looks down the lane in turns (3 s each, **TUNE**); the player moves him along the crates and the stall shade, two crate hides at (3,16) and (7,19), to the gateway (10..11,14..19). If a recruiter sees him, he walks back to (7,17) and it restarts, no counter. Solving fires `area_entered:c4_market_clear` |

## Memory scenes (Story v4/v4b, [architecture.md](../architecture.md) 9b)
Small own scenes under `zones/kelir/`, not areas: they have no `## Area n:` heading, so `gen_zones.py` skips them and the builder makes them on `memory.gd` (a `Stand` marker, `Checkpoint` markers in group `checkpoint`, no exits, no enemies except Laras-chapter patrols). Chars here are only this section's (`_` lit floor, `#` dark wall, `~` water). The clues that open them are in the area legends above. Semar narrates 1-2 lines at the start and end (`MEM_<ID>_START_<n>`, `MEM_<ID>_END_<n>`); Laras chapters use Laras's own lines. All numbers **TUNE**.

### Memory `k3_lesung`: the princess's women (K3)

- Scene `res://zones/kelir/k3_lesung.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `play`. Size 30x17 (one screen).
- Stand-in: one of Roro Jonggrang's women (`entities/player/stand_in.tscn`, speed 70).
- The one action: `interact` = pound the lesung (`action_kind: pound`) on the beat.
- Goal: Keep the rice-pounding beat for 3 short bars (one station each); each finished bar makes a rooster crow early and brightens the lamp; the third bar ends the memory at the dawn post `G`. Teaches the Jawa Ca beat (expose the pillars).
- Checkpoints: `C` at each bar start (7,8), (13,8), (19,8). A missed beat is `fail()`: the night's shadow `K` steps closer, the bar restarts at its `C`, no counter; after 3 fails the beat hint shows again and the shadow slows 25%.

```
##############################
#____________________________#
#K___________________________#
#________________________R___#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#__S___C_L___C_L___C_L_____G_#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#________________________R___#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (3,8) | the dayang |
| `L` | lesung station | 3 stations, one bar each: (9,8), (15,8), (21,8) |
| `C` | checkpoint | bar starts |
| `R` | rooster coop | decor, 2; each crows when a bar is done |
| `G` | dawn post | goal; `finish()` on touch after bar 3 |
| `K` | the night's shadow origin | a tall silhouette advancing from the west wall |

### Memory `k_iii`: the brothers who split the land (K-III)

- Scene `res://zones/kelir/k_iii.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `walk`. Size 30x17.
- Stand-in: the younger brother, crossing back over the river (silhouette with a spear).
- The one action: none (walk only); at the middle stone `T` he lays the spear down by himself.
- Goal: Reach the older brother `E` on the west bank. Teaches *pamali*: brothers do not fight each other, so the ford duel and Choice 2 land. Triggered by the clue `sumarto_show` at the ford camp in `kg_pamali`.
- Checkpoints: none (no fail state). Resume from the clue on quit.

```
##############################
#___________~~~~~~___________#
#___________~~~~~~___________#
#___________~~~~~~___________#
#___________~~~~~~________N__#
#___________~~~~~~___________#
#___________~~~~~~___________#
#___________~~~~~~___________#
#__E________oooToo________S__#
#___________oooooo___________#
#___________~~~~~~___________#
#___________~~~~~~___________#
#__N________~~~~~~___________#
#___________~~~~~~___________#
#___________~~~~~~___________#
#___________~~~~~~___________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (26,8) | east bank |
| `o` | stepping stones | 2 rows, walkable; the river `~` is not |
| `T` | trigger (15,8) | he lays the spear down, the lamp dims once |
| `E` | the older brother (3,8) | silhouette NPC; goal |
| `N` | narration points | Ki Sumarto's voice, 2 lines each |

### Memory `h3`: the price (H3)

- Scene `res://zones/kelir/h3.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `walk`. Size 30x17.
- Stand-in: young Aria Kebonan, alone at night (silhouette).
- The one action: none (walk only).
- Goal: Follow the grave path to Kala's shadow `K`; at the end he gives his own name and a glyph of light lifts away from him (`n`). About 1 minute. Teaches the *why* of the borrowed face; no mechanic. Triggered by the mask fragment `hunter_mask_3` in `mt_kuburan`.
- Checkpoints: none (no fail state).

```
##############################
##############################
########################_____#
########################__K__#
########################_ng__#
################_____________#
################_____g_______#
################_T___________#
################___###########
#########__________###########
#########_____g____###########
#########_T________###########
#########___##################
#__g________##################
#_S__g______##################
#___________##################
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (2,14) | start |
| `g` | grave markers | decor, 5 |
| `T` | narration trigger | (10,11) and (17,7), Semar 1 line each |
| `K` | Kala's shadow (26,3) | goal; the memory ends when he stops in front of it |
| `n` | the name (25,4) | decor; a small light that lifts off |

### Memory `lc3`: the reading room (LC3)

- Scene `res://zones/kelir/lc3.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `chapter`. Size 30x34 (two screens, vertical).
- Stand-in: Laras (`entities/player/stand_in_laras.tscn`); cooler blue tint, no Semar.
- The one action: `interact` = say a Faceless's true name: it freezes for 3 s (6 s cooldown). Faceless see her inside a 72 px, 90 degree cone unless she is behind a `h` prop.
- Goal: Reach the reading desk `D` past two patrols. At the desk the game offers *read* or *refuse*; refusing shows the prisoners (behind the grill `P`) hurt, then the choice returns and she reads. The chapter ends with the *Ka* write card, then `memory_done:lc3`.
- Checkpoints: `C` (3,31), (14,18), (14,6). Seen by a Faceless = `fail()`: fade, back to the last `C`, no HP loss.

```
##############################
#____________________________#
#____________________________#
#___PPPPP_____D______________#
#____________________________#
#____________________________#
#_____________C______________#
#____________________________#
#____________________h_______#
#____________________________#
#_____________f______________#
#____________________________#
#_______h____________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#_____________C______________#
#____________________________#
#_____________________h______#
#____________________________#
#___fffffffffffffffffffff____#
#____________________________#
#_____h______________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#__S_________________________#
#__C_________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (3,30) | start |
| `f` | Faceless patrol | 2 patrols: row y=22 from x=4 to 24; column x=14 from y=6 to 16 (marker `f` at (14,10) is the patrol midpoint) |
| `h` | hide shelves | 4: (6,24), (22,20), (8,12), (21,8) |
| `P` | prisoners' grill | decor, (4..8,3); the *refuse* consequence is shown here |
| `D` | reading desk (14,3) | goal; the read / refuse choice, then the Ka write card |
| `C` | checkpoint | 3 |

### Memory `sq_m1_selendang`: the selendang under the rice (SQ-M1)

- Scene `res://zones/kelir/sq_m1_selendang.tscn` (not a Zone; generated by `gen_memories.py` on `memory.gd`). Kind `walk`. Size 30x17. Opened by clue `m1_rice_gone` in the lumbung of `mt_sawah`.
- Stand-in: Nawang Wulan (a robed silhouette, shown with respect; **VERIFY** the legend, she is a bidadari).
- The one action: none (walk only); at the last pile `R` she lifts the rice and finds the selendang under it.
- Goal: Cross a lumbung lit by one lamp, past three emptying rice piles `R`, to the last pile at `G`; the selendang lies under it. Nothing to fight. Semar's closing line: she knew it was there all along, **ASSUMED**.
- Checkpoints: none (no fail state).
- Layout: a plain 30x17 floor room, Stand (3,8), piles `R` at (10,8), (17,8), (24,8), goal `G` (27,8), all **TUNE**.

### Memory `sq_m2_child`: the voice on the hill (SQ-M2)

- Scene `res://zones/kelir/sq_m2_child.tscn` (not a Zone; generated by `gen_memories.py` on `memory.gd`). Kind `walk`. Size 30x17. Opened by clue `m2_toy` on the hill path of `mt_kuburan`.
- Stand-in: the neglected boy (a small silhouette).
- The one action: none; he follows a kind voice up the hill (the voice is a moving light), and stops when nobody answers his calls.
- Goal: Follow the voice to the hill's tree `G`. Teaches calling kindly and banging pots, **VERIFY** the folk practice. The ending shows no harm.
- Checkpoints: none (no fail state).
- Layout: a plain 30x17 floor room with a path rising west to east, Stand (3,13), voice light moving along (8,11), (14,9), (20,7), goal `G` (26,5), all **TUNE**.

### Memory `sq_m3_tuyul`: the one who stopped to count (SQ-M3)

- Scene `res://zones/kelir/sq_m3_tuyul.tscn` (not a Zone; generated by `gen_memories.py` on `memory.gd`). Kind `play`. Size 30x17. Opened by clue `m3_beans` in the kiln of `mt_tegal`.
- Stand-in: a tuyul (a small silhouette, speed 60, **TUNE**), sent out by a greedy master.
- The one action: `interact` = take a coin from a stall; it must stop and count any spill it passes (an automatic 3 s pause, **VERIFY** beans or crabs).
- Goal: Take three coins from three stalls `C` and return to the door `G`. The spills `b` (green beans) lie on the way; the master's lamp `K` sweeps and catches the tuyul while it counts. Teaches that it cannot pass a spill without counting it, which is the trap set in `m3_trap_sprung`. Light comedy.
- Checkpoints: a `C` at each stall; getting caught restarts at the last stall, no counter.
- Layout: a plain 30x17 floor room, Stand (3,13), first stall at (10,4), second stall at (17,4), third stall at (24,4), decor spills at (10,9), (17,12), (24,9), the master's lamp `K` at (14,8), door `G` (3,3), all **TUNE**.

## Flow
Gapura entry, the two recruiters in the border market (the same war told both ways), `mataram_gerbang` and the road ambush `mataram_jalan` with the `haulers` beat > petilasan `mataram_1` (2.1) > **three leads in any order (2.2)**: the market plaza (the stage setpiece; Ki Sumarto teaches Ha, 2.3), the ruins courtyard (chalk clue, the Arca miniboss, Na read off `arca_base` as a puzzle, 2.3; Pak Karto waits in the yard as a side NPC), the graveyard (two fights, `hunter_war`) > the mask fragment and the H3 memory, the harvest captain (2.4) > the foothill: lesung women (Ca, 2.3), `mataram_batu_2`, `mataram_batu`, the lamp puzzle, the juru kunci and Ra (2.5) > `K2` > `mt_candi`: the temple gate fight, the hauler, the camp gate, the captain, the camp setpiece and the `camp` beat (2.6) > three K3 clues (2.7) > the K3 memory (2.8) > rest at `mataram_2`, Laras's chapter LC3 (2.9) > Bandung Bondowoso (2.10) > `sc:mt_candi_gapura` > the Faceless remnants in the gapura (2.11) > `kg_pamali`: the Pamali stone (2.11), K-III (2.12), the letters and the ford duel (2.13, beats `ford`, `truce`) > the causeway and `mt_wetan` > `K3`.

## Encounter list (18)
| Id | Area | Mix | Notes |
|----|------|-----|-------|
| `mataram_gerbang` | gapura | 3 Tuyul | Step 2.1. First sight of Tuyul, alone. Burst teach |
| `mataram_pasar` | pasar | 5 Tuyul, then 3 Tuyul | Lead 1 (2.2). **Setpiece** (defend the stage), 2 waves. Room 22x12 planned |
| `mataram_pocong` | pasar east road | 1 Pocong | New. Lane 10 tiles. Bind teach. Not a step and not on the lead route (skippable) |
| `mataram_ruins` | reruntuhan | 3 Arca (one elite), 2 Tuyul | Lead 2 (2.2), **miniboss**. Room 24x14 planned. Arca wake when passed |
| `mataram_kuburan` | kuburan | 2 Pocong, 3 Tuyul | Lead 3 (2.2), required since v3.1. Room 26x15, lane 10 |
| `mataram_batu` | wetan | 1 Genderuwo, 2 Pocong | Step 2.5. Room 24x14, lane 10 |
| `mataram_candi` | candi | W1: 1 Genderuwo, 2 Arca. W2: 3 Tuyul | Step 2.6. Room 28x16 planned. Last open-field fight before `mataram_2` |
| `mataram_camp` | candi arena | W1: 3 Faceless, 1 archer. W2: 2 Faceless, 2 archers | Step 2.6 (cond `flag:mq2_6`). Was built in Phase 5 but missing from this list. Inside the boss arena, so a petilasan visit sits between it and the boss |
| `mataram_jalan` | gapura east road | 4 Tuyul | New (v4c). Step 2.1 second fight. 18x9 |
| `mataram_kuburan_gate` | kuburan north field | 3 Tuyul, 1 Pocong | New (v4c). Step 2.2 fight 1. 20x9 |
| `mataram_pemanen` | kuburan east road | elite Faceless, 2 Pocong | New (v4c). **Miniboss** of 2.4, cond `flag:memory_h3`. 18x9 |
| `mataram_batu_2` | wetan junction | 3 Tuyul | New (v4c). Step 2.5 fight 1. 18x9 |
| `mataram_camp_gate` | candi arena gate | 2 Faceless, 1 archer | New (v4c). Step 2.6, cond `flag:mq2_6`. 16x6 |
| `mataram_camp_captain` | candi arena | elite Faceless, 1 archer, 1 Faceless | New (v4c). **Miniboss** of 2.6, cond `flag:mq2_6`. 12x10 |
| `mataram_tepi`, `mataram_causeway` | gapura west road, causeway gate | 2 Faceless + archer; 2 Faceless + archer | New (v4c). The two 2.11 fights, cond `flag:mq2_7b` |
| `mataram_wewe` | kuburan hill | elite Wewe Gombel | Optional (SQ-M2 fight). Slow wide swing. Placed as a plain spot `q` on the hill (no encounter node, like the Kuntilanak elite) |
| `mataram_tuyul` | tegal | elite tuyul leader (+ 3 Tuyul not placed) | Optional (SQ-M3 fight). Leader alone as a plain spot `q` in the kiln; the 3 Tuyul are left out so the peaceful ending stays peaceful (open question 7) |

First appearance check: Tuyul (gerbang, alone), Pocong (pocong or the graveyard), Arca and Genderuwo appear with known enemies. The Arca at `mataram_ruins` are the first Arca and Na is read only after they fall (the glyph is earned by the deed, story.md Pacing 4), so the first Arca fight is combo and dodge only (Doc conflicts 2). Na (Dash-strike) is the clean answer to the Arca in `mataram_candi`.

## Self-check (AGENTS.md section 5 Step 2, and interlock rules 1-8)
Step 2 checklist (re-run for v4c, 2026-11-06):
- [~] POI counts: 1 boss arena (`mt_candi`); miniboss or elite rooms: the Arca elite, the harvest captain, the camp captain on the path plus the Wewe hill and the tuyul hideout (world.md wants 1; accepted, the v4c pacing model counts a `miniboss` piece in 2.2, 2.4 and 2.6); NPC ids are well over 3-5 (side quests, the two recruiters, the hauler); 3 secrets (gong nook, crypt with Panah Pasopati, well); codex-rich ruin 1; encounters 18 (6-10 asked; every extra one is a piece the step tables count: `fight`, `miniboss`, `setpiece`); petilasans 2.
- [x] Petilasan before the boss with no fight between: `mataram_2` sits in the court strip south of the arena gate. The camp sequence (gate fight, captain, setpiece, 2.6) runs inside the arena before it; the K3 clues, the memory and the chapter (2.7-2.9) happen around the petilasan and are not fights; the boss wakes on `flag:mq2_lc` (was `mq2_7`).
- [x] Each enemy first appears alone or with known enemies, weakness usable: unchanged for Tuyul, Pocong, Arca, Genderuwo. New fights use Tuyul, Pocong and Faceless only (Faceless are known from Act I). Doc conflict 2 (the first Arca fight has no Na) stands.
- [~] One tank per encounter, at most one shooter, at most two waves: `mataram_camp_captain` and the two return fights have one archer; `mataram_pasar` is a two-wave setpiece (5 then 3); `mataram_candi` and `mataram_camp` keep two waves. Arca exception (Doc conflict 3) stands.
- [x] Rooms with 4+ enemies are at least 15x9: pasar 22x12 (5, then 3), ruins 24x14, kuburan 26x15, kuburan_gate 20x9 (4), jalan 18x9 (4), candi 28x16, camp 30x16. Charger lanes 10 (pocong, kuburan, batu).
- [x] Newest glyph (Ra at 2.5) is the clean answer in `mataram_candi` and the camp fights (Summon).
- [x] Every quest marker and flag in quests.md for this region has a place: steps 2.1-2.10 above, 2.11-2.13 and the `ford` and `truce` beats in `kg_pamali`; all Act III clue ids (`rubble`, `lesung_mid`, `ka_strip` here, `hunter_mask_3` here, `hariang_letters` and `sumarto_show` in `kg_pamali`); memory ids `k3_lesung`, `lc3`, `h3` (this doc) and `k_iii` (scene here, clue in `kg_pamali`); beats `haulers`, `hunter_war`, `lengser_word`, `camp`.
- [x] The critical path needs no Jawa glyph: `K2` needs `mq2_6`, the hut kabut needs `flag:puzzle_wetan_lamps` (a puzzle, not a glyph); `arca_base` and the lesung women are glyph sources, not doors.
- [x] Pacing rule 5: no empty backtracking (see Return trips): Ca moved to `mt_wetan`, the causeway and the return fights in the gapura replace the plain walk back, the way to `K3` is two areas from `kg_pamali`.
- [x] Pacing rule 7: every critical-path area has an optional find (Rule 7 table above).
- [x] The three leads can be reached in any order after `mataram_1`.

Interlock rules:
1. [x] >= 2 loops closed by shortcut or drop: A (drop), B (`sc:mt_ruin_sawah`), D (`sc:mt_candi_gapura`); C is a plain extra loop.
2. [x] >= 2 shortcuts, each ending at or one link from a petilasan: `sc:mt_ruin_sawah` into the petilasan 1 area; `sc:mt_candi_gapura` and `sc:mt_tt` end one link from `mataram_1`.
3. [x] >= 1 drop: `mt_wetan` > `mt_tegal`.
4. [x] Optional areas branch off loops: tegal off A. Kuburan is now a required lead on loop C. No dead-end chains.
5. [x] Boss landmark visible from `mt_gapura`, nearer in sawah, pasar, reruntuhan.
6. [x] Petilasan `mataram_2` right before the boss arena, no fight between.
7. [x] 2 petilasans (`mataram_1`, `mataram_2`).
8. [x] The critical path visits 7 of 8 areas; gates follow story flags (`mq1_10`, `mq2_6`, `mq2_9`) and one puzzle flag (`puzzle_wetan_lamps`); glyphs are rewards, not keys.

## ASSUMED (every decision made here)
1. 8 areas with the names and sizes in the Area table. Exit sides (W/E/N/S) only fix the graph.
2. Gate flags `mq2_6` (kabut `K2` before the temples, set by the juru kunci at 2.5) and `mq2_9` (kabut `K3` to Tanah Timur, set when Hariang Banga is beaten at 2.13).
3. Shortcut ids `sc:mt_ruin_sawah` and `sc:mt_candi_gapura`. Both are the Tatar Sunda shortcut gate (`entities/world/shortcut.tscn`): it stands in the gate area and opens from the side the opener area's exit arrives on. No levers (2026-11-05).
4. The drop from `mt_wetan` to `mt_tegal` does no damage.
5. Encounter ids `mataram_gerbang`, `mataram_pasar`, `mataram_pocong`, `mataram_kuburan`, `mataram_batu`, `mataram_candi`, `mataram_wewe`, `mataram_tuyul`. New small encounters: `mataram_gerbang` (3 Tuyul), `mataram_pocong` (1 Pocong), `mataram_tuyul` (elite leader + 3 Tuyul). Wave 2 in `mataram_candi` rises from a heap of dropped stones.
6. NPC ids: `nawang_wulan`, `lesung_women`, `m3_smith`, `m2_neighbour`, `m2_parents_1`, `pak_karto`, `juru_kunci`; `wewe_parents_2` and `mataram_dalang` come from quests.md.
7. Marker ids not in quests.md: `pak_karto`, `juru_kunci`, `lumbung`, `tuyul_hideout`, `gong_ageng`, `batu_bintang`, `candi_seribu`, and the event strings marked above.
8. Pak Karto stands in the safe outer yard of `mt_reruntuhan`, before the courtyard fight.
9. Boss arena is at least one screen (30x17); the lesung women stay in the `mt_sawah` farm yard (see 15).
10. The meteorite fragment for SQ-T3 lies in the `mt_candi` front yard.
11. Secret chests: gong nook gear chest, Panah Pasopati crypt, well gear chest. Gear: Longbow (gong nook), Panah Pasopati (crypt), Amulet (well).
12. The in-game name "Candi Seribu" for the boss site (invented; the real Prambanan is never named as the arena).
13. The Arca are a stationary-shooter exception to "at most one shooter".
14. Chest items (existing ids, ASSUMED): gapura `stone_ring`, sawah `padded_tunic`, pasar `silver_bangle`, wetan `short_sword`, candi `chainmail`, gong nook `feather_charm`, well `amulet`; crypt `panah_pasopati` (Q). The quest pickups `selendang_nawang`, `gong_ageng`, `batu_bintang` have no `data/items/` file yet.
15. Map layout (Phase 5; v3.1 additions are items 16-24): the causeway pocket is on the east edge of `mt_gapura`; the gong nook is an open one-tile gap between two rocks (no breakable-wall mechanic); the lesung women stay in the farm yard of `mt_sawah` (an NPC at the arena edge would be interactive); the tuyul leader NPC and the inert elite stand side by side in the kiln; `mt_kuburan` has its north entry and east exit.
16. v3.1 numbering: MQ2 has 13 steps ([quests.md](../quests.md) section 4). Lead flags `lead_pasar`, `lead_ruins`, `lead_kuburan` and step flag `mq2_4` come from quests.md; `mq2_5` (Ca), `mq2_7b` (Bandung Bondowoso) too.
17. The three leads are free-order. The journal arrow points at the nearest open lead (**ASSUMED**). A player can run past the Arca and finish `mataram_ruins` later because the courtyard has no doors.
18. `arca_base` is an inscribed object with an `npc.tscn` scene (like `batu_tulis` in Tatar Sunda), `npc_id` `arca_base`, cond `flag:lead_ruins`, at (47,21) in the courtyard, 3 tiles east of the central path. Pak Karto stays at `K` (40,8) in the outer yard as a side-quest NPC with no quest yet.
19. Ki Sumarto stays at his house in `mt_pasar` (one NPC spot, `D`). Sapto is placed in `kg_pamali` for the `truce` beat, not here.
20. Glyph sources open as soon as their lead is cleared: Ha (`mataram_dalang`, `lead_pasar`), Na (`arca_base`, `lead_ruins`), Ca (`lesung_women`, `lead_kuburan`). the juru kunci's entry needs `area_cleared:mataram_batu` (deed first, Pacing 4).
21. Beat spots are trigger nodes (`beat_hunter_war` `H` in `mt_kuburan`, `beat_lengser_word` `L` in `mt_wetan`, `beat_camp` `T` in `mt_candi`). They only stage the beat. The listener plays it from `beats.tres`; each beat's `if` also carries a `zone:` part (`zone:` is not built yet, quests.md 7.1).
22. `hunter_war` moved from the graveyard-optional placement to `flag:lead_kuburan`.
23. `lengser_word` is staged in the stairs corridor of `mt_wetan`, just below `K2`, so it plays after the juru kunci and before the camp.
24. The camp encounter `mataram_camp` is counted as an encounter and in the kill counts (it was built but not listed before).

25. v4c (2026-11-06): the recruiters stand in `mt_gapura` (the border market on the Pamali bank) so the arrival slice comes before the first fight; the lesung women moved from `mt_sawah` to a foothill lesung yard in `mt_wetan` (Pacing rule 5); the sawah farmer replaces them. Pieces without a quest id get unnamed ids (`ka_chalk`, `lc3_lontar`, `pasar_stage`, `hauler`) and `mataram_*` encounter ids; `ka_chalk` is a journal-note clue only.
26. Miniboss elites (`mt_arca_penjaga`, `mt_harvest_captain`, `mt_camp_captain`) reuse existing scenes (Arca, Faceless) with `unique_id` and HP x4 / Ilmu x4 (**TUNE**); no new bestiary entry.
27. Clue legend props follow the brief `{clue_id, memory_id?}`; `cond` is added only where quests.md names one (`hunter_mask_3`, `lc3_lontar`).
28. Memory scene ids: `k3_lesung`, `lc3`, `h3`, `k_iii` under `zones/kelir/`. `k_iii` is entered from a clue in `kg_pamali`, so its scene is specified here but its clue legend row belongs to keraton_galuh.md.

## Open questions
1. Should the kabut `K2` before the temples exist at all, or should the critical path be open from wetan to candi? (Kept: it follows the story flags and makes the juru kunci a stop, not a detour.)
2. Resolved: `K3` opens on the Pamali duel (2.13), and `sc:mt_candi_gapura` makes the walk to `kg_pamali` short.
3. SQ-M3 peaceful method (crabs or green beans) and SQ-M4's gong wording stay **VERIFY**.
4. Wewe Gombel is rooted in Bukit Gombel, Semarang (**VERIFY** how much to show); the hill here is a generic graveyard hill.
5. ~~Which gear for the three secret chests~~ Done 2026-11-05: Longbow, Panah Pasopati, Amulet.
6. Names Ki Sumarto and Pak Karto: native speaker check (quests.md section 11).
7. (v4d: the card says "leader plus swarm", so the swarm is `mataram_tuyul`.) The 3 Tuyul of `mataram_tuyul` are not placed: an encounter spawns them whatever the quest choice. Add them only if the encounter can be gated on `step:sq_m3=2` and the fight choice.
8. Resolved (v3.1): SQ-M5 is retired. The lesung women stay in the `mt_sawah` farm yard; the false dawn at the arena is told by the Bondowoso fight, not by a standing NPC.
9. A graveyard-first player (see Three leads) meets Pocong in `mt_kuburan` or as a loose pack in `mt_reruntuhan` before the lone-Pocong Bind teach on the `mt_pasar` east road. Fix options: put a lone-Pocong teach spot on the `mt_reruntuhan` to `mt_kuburan` road, or accept it. Left open.
10. The Hunter's graveyard appearance (`hunter_war`) plays after the lead clears. If the player has not entered `mt_kuburan` since, the beat waits for the `zone:` part of its `if`.

Resolved 2026-11-05: 1 (world.md already uses `mq2_9`), 3 (Arca exempt, bestiary.md Encounters). Question 2 of that day (2.2 and 2.3 swapped) is superseded by v3.1: the deed now comes first, so the Arca fall before Na is read.

## Doc conflicts found (not fixed)
1. **Resolved, was the gate flag for `mt_wetan` to `tt_kulon`:** `K3` opens on `mq2_9`, set by the Hariang Banga duel (2.13). world.md's link table says `mq2_9`.
2. **Arca weakness not usable at first sight (accepted by v3.1):** bestiary.md says the Arca's weakness is Na, but Na is read off `arca_base` only after `mataram_ruins` is cleared (story.md Pacing 4: glyphs are earned by a deed first). The first Arca fight is combo and dodge. The bestiary "Glyph weaknesses" and the Step 2 checklist ("each enemy's weakness is usable at first sight") should note the exception.
3. **Shooter rule:** Encounters say at most one far role (shooter) per encounter, yet `mataram_ruins` has 3 Arca, `mataram_candi` has 2 Arca and the camp has up to 2 archers per wave. The doc keeps the bestiary mixes.
4. **NPC count:** world.md asks for 3-5 NPCs per region; MQ2 plus five side quests need 10. Tatar Sunda set the precedent (10).
5. **`area_cleared:mataram_ruins`:** quests.md uses it as the encounter id (as `area_cleared:sunda_batutulis` does), not the area id `mt_reruntuhan`. The same holds for the other five encounter-based steps and leads. This doc follows that.
6. **SQ-T3 fragment location:** quests.md says "near the temple plain" without a place. Built in the `mt_candi` east yard.
7. **Unlock steps:** quests.md section 5 unlocks SQ-M1 and SQ-M3 at 2.1 (petilasan) and SQ-M2 and SQ-M4 at 2.3 (Ki Sumarto, Ha). This doc follows that.
8. **Resolved 2026-11-06:** keraton_galuh.md now has Sapto `s` and Ciung `c` in `kg_pamali` and marker rows for 2.11, `ford`, 2.13 and `truce`.
9. **Resolved (SQ-M5 retired in v3.1):** the boss cond stays `flag:mq2_7`; quests.md section 5 no longer has an echo quest, and its lakon and codex come with MQ2 completion (`truce` beat).
10. **Resolved:** the lesung women stay in the `mt_sawah` farm yard (no arena-edge women).
11. **Resolved 2026-11-06 (consistency pass):** world.md and bestiary.md now use the v3.1 Mataram step numbers (Na at 2.3 off the Arca base, Ra at 2.5, the Pamali duel at 2.13).
