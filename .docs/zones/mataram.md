# Mataram (region `mataram`, area prefix `mt_`), Act 2

Region area graph on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5), graph level only: **no tile maps until Phase 5**. Sources: [world.md](../world.md) (Technical frame, World structure with interlock rules 1-8 and the inter-region link table, Mataram, Checkpoints, Points of interest), [bestiary.md](../bestiary.md) (Zone 2: Mataram, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ2, SQ-M1 to SQ-M4, 3.4, 7.5). Tatar Sunda ([tatar_sunda.md](tatar_sunda.md)) is the format example. Change the layout here first, then the code.

Tags used: **ASSUMED** (a decision, change freely), **VERIFY** (culture fact to check before it ships), **TUNE**. Ids marked (Q) already exist in quests.md or world.md.

## Look and landmark
Warm stone, rice terraces, dry fields and volcano foothills. Temple ruins in sandstone grey, orange roof tiles in the village, green padi. The tone stays cartoonish and gentle: the spirit builders are cheeky, not grim. The boss site, the unfinished "thousand temples" (in-game name **Candi Seribu**, an invented place, **VERIFY** before using any real site name), shows as a spiky silhouette of many small spires against the volcano from the very first screen of `mt_gapura`. It looks bigger and more crowded in `mt_sawah`, peeks over the roofs in `mt_pasar`, and stands behind broken walls in `mt_reruntuhan`. A road of paving stones (the causeway) runs straight from the gapura to the temples and is walled off at first: it is the second shortcut. Spirit builders carry stones along the skyline all game long, so the player sees where the boss is. The Durga statue is never shown or named (quests.md sensitivity note).

## Area table
Sizes are in screens (30x17 tiles each). Exit sides are ASSUMED and only fix the graph (W/E/N/S).

| Id | Size | Look | Purpose |
|----|------|------|---------|
| `mt_gapura` | 2x2 = 60x34 | Stone split gateway, dusty road, banyan, the temple silhouette in the east | Entry from Desa Purwa. First teach fight (Tuyul with Burst). Road branches to the rice fields. Far end of the causeway shortcut |
| `mt_sawah` | 3x2 = 90x34 | Stepped rice paddies, a lumbung, a farm yard with a lesung, irrigation channels | Rest hub: petilasan `mataram_1`. SQ-M1 and the lesung women (2.5). Safe area, no fight near the petilasan |
| `mt_pasar` | 2x3 = 60x51 | Village: roofed market lanes, gamelan pavilion, blacksmith stall, dalang's house | Story and quest hub (dalang, SQ-M2 and SQ-M3 givers). Village lanes fight. First Pocong teach on the east road |
| `mt_reruntuhan` | 3x3 = 90x51 | Broken candi walls, courtyards, fallen carved stones, a small site museum | Arca fight (`mataram_ruins`), Pak Karto, codex-rich ruin, gong nook, lever for `sc:mt_ruin_sawah`. Hub of the loops |
| `mt_kuburan` | 2x2 = 60x34 | Old graveyard with frangipani, a bare hill with one tree, mist | Optional: graveyard fight, Wewe Gombel hill (elite, SQ-M2), crypt secret |
| `mt_wetan` | 3x2 = 90x34 | Rocky foothill field, dry grass, boulders, a cliff ledge, the juru kunci's hut | Rock thrower fight. Mbah Marto (2.6). East exit to Tanah Timur. Start of the drop. Stairs up to the temples |
| `mt_candi` | 3x3 = 90x51 | The unfinished temples: spires, spirit builders, scaffolds, temple gate, the boss court | Front yard with the temple gate fight, petilasan `mataram_2`, boss arena (>= 1 screen, 30x17 **ASSUMED**), causeway lever |
| `mt_tegal` | 2x2 = 60x34 | Dry field, a tuyul-haunted well, old brick kiln | Landing of the drop. End of the back road `sc:mt_tt`. SQ-M3 hideout. Secret well chamber. One link from petilasan `mataram_1` |

### Contents (encounters, NPCs, chests, petilasans, codex, secrets, markers)
Encounter ids are proposed `mataram_*` (**ASSUMED**) except `mataram_ruins` (Q, 2.3). Enemy mixes are from bestiary.md "Encounters, Mataram" unless marked new.

| Id | Encounters | NPCs | Chests, petilasan, codex, secrets |
|----|------------|------|-----------------------------------|
| `mt_gapura` | `mataram_gerbang`: 3 Tuyul, one wave (new, teach: Burst clears a swarm; Ca learned in MQ1 1.7) | none (a guard post with a sign only) | Chest `mataram_chest_gapura` (consumable). Codex spot `codex:gapura` (stone gate) |
| `mt_sawah` | none (safe) | `nawang_wulan` (SQ-M1 giver), `lesung_women` (2.5, teaches Ca), a farmer for flavor | Petilasan **`mataram_1`** (Q). Chest `mataram_chest_sawah`. Codex `codex:gejog_lesung`. Lumbung: SQ-M1 search spot `lumbung`. Barred north gate of `sc:mt_ruin_sawah` |
| `mt_pasar` | `mataram_pasar`: 5 Tuyul (Village thieves), one wave. `mataram_pocong`: 1 Pocong alone on the east road (new, teach: Bind mid-hop, 8-tile lane) | `mataram_dalang` = Ki Sumarto (Q, 2.2, SQ-M4 giver), `pande_besi` (SQ-M3 giver), `wewe_neighbor` (SQ-M2 giver), `wewe_parents` (SQ-M2 alt, later `wewe_parents_2` at the hill) | Chest `mataram_chest_pasar`. Codex `codex:gamelan` |
| `mt_reruntuhan` | `mataram_ruins` (Q): 3 Arca on the edges, 2 Tuyul, courtyard. Wakes when passed (Ruins wake) | `pak_karto` = Pak Karto (2.4), in the safe outer yard before the courtyard | **Codex-rich ruin**: site museum with `codex:candi_seribu`, `codex:roro_jonggrang`, `codex:arca`. Secret 1: sealed nook behind a cracked wall holding the gong ageng (SQ-M4) and a gear chest `mataram_secret_gong`. Lever for `sc:mt_ruin_sawah` |
| `mt_kuburan` | `mataram_kuburan`: 2 Pocong, 3 Tuyul (Graveyard, open ground). `mataram_wewe`: elite Wewe Gombel (only if SQ-M2 is fought, HP 780) | `wewe_parents_2` arrive at the hill if SQ-M2 is peaceful | Secret 2: crypt under the hill, chest **Panah Pasopati** (`mataram_secret_pasopati`, Q reward source "Mataram secret"). Marker `wewe_hill` (Q) |
| `mt_wetan` | `mataram_batu`: 1 Genderuwo, 2 Pocong (Rock thrower, rocky field) | `juru_kunci` = Mbah Marto (2.6, teaches Ra) | Chest `mataram_chest_wetan`. Codex `codex:genderuwo`. Kabut `K3` to `tt_kulon` on the east edge. Drop ledge on the south cliff |
| `mt_candi` | `mataram_candi`: Temple gate, wave 1: 1 Genderuwo, 2 Arca; wave 2: 3 Tuyul rising from a heap of dropped stones with a 0.5 s warning (2 waves). Then no fight to the petilasan | none; the lesung women stand at the arena edge after 2.5 (visual timer, non-interactive) | Petilasan **`mataram_2`** (Q) right before the boss arena. Boss **Bandung Bondowoso** (`bandung_bondowoso`). Chest `mataram_chest_candi`. Batu bintang (SQ-T3 meteorite fragment) in the front yard (**ASSUMED**). Lever for `sc:mt_candi_gapura` |
| `mt_tegal` | `mataram_tuyul`: elite tuyul leader + 3 Tuyul (SQ-M3 fight, new). Peaceful ending has no fight | none | Secret 3: dry well chamber, gear chest `mataram_secret_sumur`. Marker `tuyul_hideout` |

NPC count is 9 ids because of the side quests (world.md says 3-5, Tatar Sunda has 10 for the same reason, **ASSUMED**).

## Region graph
Gates: `K1` = kabut `mq1_10` (Q), `K2` = kabut `mq2_6` (**ASSUMED**), `K3` = kabut `mq2_9` (**ASSUMED**, see Doc conflicts). `sc` = shortcut, opened from the far side named. `===>` is a one-way drop. P1 = `mataram_1`, P2 = `mataram_2`, B = boss.

```
                         (bridge of paving stones, walled at the gapura end)
   Desa Purwa           ..........  sc:mt_candi_gapura (opens from mt_candi)  ..........
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
desa_purwa  =K1= mt_gapura (L)
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
| `desa_purwa` (E) | `mt_gapura` (W) | link, kabut `K1` | `mq1_10` (Q) | `from_desa_purwa` in gapura; `from_mt_gapura` in desa_purwa |
| `mt_gapura` (E) | `mt_sawah` (W) | link | none | `from_mt_gapura` in sawah; `from_mt_sawah` in gapura |
| `mt_sawah` (S) | `mt_pasar` (N) | link | none | `from_mt_sawah` in pasar; `from_mt_pasar` in sawah |
| `mt_pasar` (S) | `mt_reruntuhan` (N) | link | none | `from_mt_pasar` in reruntuhan; `from_mt_reruntuhan` in pasar |
| `mt_reruntuhan` (E) | `mt_wetan` (W) | link | none | `from_mt_reruntuhan` in wetan; `from_mt_wetan` in reruntuhan |
| `mt_reruntuhan` (S) | `mt_kuburan` (N) | link | none | `from_mt_reruntuhan` in kuburan; `from_mt_kuburan` in reruntuhan |
| `mt_kuburan` (E) | `mt_wetan` (S) | link | none | `from_mt_kuburan` in wetan; `from_mt_wetan` in kuburan |
| `mt_wetan` (S ledge) | `mt_tegal` (N) | **drop**, one way | none | `from_mt_wetan` in tegal (no return exit) |
| `mt_tegal` (W) | `mt_sawah` (E) | link | none | `from_mt_tegal` in sawah; `from_mt_sawah` in tegal |
| `mt_wetan` (N) | `mt_candi` (S) | link, kabut `K2` | `mq2_6` (**ASSUMED**, set when 2.6 completes) | `from_mt_wetan` in candi; `from_mt_candi` in wetan |
| `mt_wetan` (E) | `tt_kulon` | link, kabut `K3` | `mq2_9` (**ASSUMED**; world.md says "boss beaten", quests.md 2.9 says on Semar's talk) | `from_mt_wetan` in tt_kulon; `from_tt_kulon` in wetan |
| `mt_candi` (W) | `mt_gapura` (NE) | shortcut `sc:mt_candi_gapura` | `sc:mt_candi_gapura` | `from_mt_candi` in gapura; `from_mt_gapura` in candi |
| `mt_sawah` (N gate) | `mt_reruntuhan` (SW) | shortcut `sc:mt_ruin_sawah` | `sc:mt_ruin_sawah` | `from_mt_reruntuhan` in sawah; `from_mt_sawah` in reruntuhan |
| `mt_tegal` (E) | `tt_sabana` | shortcut `sc:mt_tt` (Q) | `sc:mt_tt` | `from_tt_sabana` in tegal; `from_mt_tegal` in tt_sabana |

Arrival from a shortcut places the player on the near side with the gate already open. Once open, a shortcut works in both directions for good. The drop is the only edge with a single exit.

### Shortcut table
| Id | Gate area (where the barred door stands) | Open side (where it is opened) | Leads back to |
|----|------------------------------------------|--------------------------------|---------------|
| `sc:mt_ruin_sawah` | `mt_sawah`, barred wooden gate in the north wall | `mt_reruntuhan`, a lever in the courtyard side yard, reached after the Ruins wake fight | Petilasan `mataram_1` (arrive in sawah, a few tiles away) |
| `sc:mt_candi_gapura` | `mt_gapura`, a walled end of the causeway | `mt_candi`, a lever in the front yard next to petilasan 2 | `mt_gapura`, one link from `mataram_1` (and the road home to Desa Purwa and Semar for 2.9) |
| `sc:mt_tt` (Q world.md) | `mt_tegal`, a boulder-blocked back road | `tt_sabana` (Tanah Timur side) | `mt_tegal`, one link from `mataram_1` |

## Loops, drop, critical path, optional areas
**Loops** (every first trip is long, later trips are short):
- **A (big):** `mt_sawah` > `mt_pasar` > `mt_reruntuhan` > `mt_wetan` > drop > `mt_tegal` > `mt_sawah`. The drop closes it: the fall lands near petilasan 1.
- **B (village):** `mt_sawah` > `mt_pasar` > `mt_reruntuhan` > `sc:mt_ruin_sawah` > `mt_sawah`. After the ruins, the way back to the lesung and the petilasan is one gate.
- **C (graveyard):** `mt_reruntuhan` > `mt_kuburan` > `mt_wetan` > `mt_reruntuhan`. A plain loop with the optional graveyard in its middle.
- **D (causeway):** `mt_gapura` > `mt_sawah` > `mt_pasar` > `mt_reruntuhan` > `mt_wetan` > `mt_candi` > `sc:mt_candi_gapura` > `mt_gapura`. The player first sees the walled causeway at the very start, then opens it at the very end.

**Drop:** `mt_wetan` south ledge to `mt_tegal` (one way, no fall damage, **ASSUMED** for the forgiving tone). A railing with a gap and a worn path make it readable.

**Critical path** (MQ2 order, 6 of 8 areas): `desa_purwa` > `K1` > `mt_gapura` (E gerbang) > `mt_sawah` (2.1 `mataram_1`) > `mt_pasar` (2.2 dalang) > east road (`mataram_pocong`) > `mt_reruntuhan` (2.3 ruins, 2.4 Pak Karto) > open `sc:mt_ruin_sawah` > `mt_sawah` (2.5 lesung) > back through the shortcut > `mt_wetan` (E batu, 2.6 Mbah Marto, sets `mq2_6`) > `K2` > `mt_candi` (E candi, 2.7 `mataram_2`, 2.8 boss) > open `sc:mt_candi_gapura` > `mt_gapura` > Desa Purwa (2.9 Semar, sets `mq2_9`) > back to `mt_wetan` > `K3` > `tt_kulon`.

**Optional areas and the loop they branch off:**
| Area | Branches off | Why it is worth it |
|------|--------------|--------------------|
| `mt_kuburan` | Loop C (between reruntuhan and wetan) | Wewe Gombel hill (SQ-M2), graveyard fight, Panah Pasopati crypt |
| `mt_tegal` | Loop A (drop landing and link to sawah) | SQ-M3 hideout, well secret, the road to Tanah Timur later |

No optional area hangs off the end of a dead-end chain.

## Quest step locations
Marker form `{zone: "mataram", id: ...}`. Ids from quests.md or world.md are marked (Q). Everything else is **ASSUMED**.

| Step | Marker id | Area | Event string |
|------|-----------|------|--------------|
| Unlock: from Desa Purwa | none | `mt_gapura` entry | `zone_entered:mataram` |
| 2.1 rest at the petilasan | `mataram_1` (Q) | `mt_sawah` | `petilasan_activated:mataram_1` (Q) |
| 2.2 hear the dalang | `mataram_dalang` (Q) | `mt_pasar` | `talked_to:mataram_dalang` (Q), teaches Ha |
| 2.3 wake the guardians | `mataram_ruins` (Q) | `mt_reruntuhan` | `area_cleared:mataram_ruins` (Q), the encounter id |
| 2.4 learn Na | `pak_karto` | `mt_reruntuhan` (outer yard) | `glyph_learned:jawa_na` (Q) |
| 2.5 join the lesung women | `lesung_women` (Q) | `mt_sawah` | `talked_to:lesung_women` (Q), teaches Ca (Jawa) |
| 2.6 juru kunci's blessing | `juru_kunci` | `mt_wetan` | `glyph_learned:jawa_ra` (Q); sets flag `mq2_6` (opens `K2`) |
| 2.7 enter the temple courtyard | `mataram_2` (Q) | `mt_candi` | `petilasan_activated:mataram_2` (Q) |
| 2.8 stop the building | `bandung_bondowoso` | `mt_candi` (boss arena) | `boss_defeated:bandung_bondowoso` (Q) |
| 2.9 return to Semar | `semar` in `desa_purwa` | `desa_purwa` | `talked_to:semar` (Q); sets flag `mq2_9` (opens `K3`) |
| SQ-M1 (1) hear Nawang Wulan | `nawang_wulan` | `mt_sawah` | `talked_to:nawang_wulan`. Unlock: `petilasan_activated:mataram_1` (2.1) |
| SQ-M1 (2) search the lumbung | `lumbung` | `mt_sawah` | `area_entered:lumbung` |
| SQ-M1 (3) find the selendang | `lumbung` (sparkle) | `mt_sawah` | `item_picked:selendang_nawang` |
| SQ-M1 (4) return it | `nawang_wulan` | `mt_sawah` | `talked_to:nawang_wulan` (ends the quest, **VERIFY** all beats) |
| SQ-M2 (1) worried neighbor | `wewe_neighbor` | `mt_pasar` | `talked_to:wewe_neighbor`. Unlock: `talked_to:mataram_dalang` (2.2) |
| SQ-M2 (2) find the hill | `wewe_hill` (Q) | `mt_kuburan` | `area_entered:wewe_hill` |
| SQ-M2 peaceful | `wewe_parents` then the hill | `mt_pasar`, `mt_kuburan` | `talked_to:wewe_parents` then `talked_to:wewe_parents_2` (Q alt "peaceful") |
| SQ-M2 fight | `wewe_hill` | `mt_kuburan` | `enemy_killed:wewe_elite` (Q alt "fight"), encounter `mataram_wewe` |
| SQ-M3 (1) the blacksmith | `pande_besi` | `mt_pasar` | `talked_to:pande_besi`. Unlock: 2.1 |
| SQ-M3 (2) the hideout | `tuyul_hideout` | `mt_tegal` | `area_entered:tuyul_hideout` |
| SQ-M3 peaceful | `tuyul_hideout` | `mt_tegal` | `item_used:distraction` then `talked_to:tuyul_leader` (**VERIFY** crabs or green beans) |
| SQ-M3 fight | `tuyul_hideout` | `mt_tegal` | `enemy_killed:tuyul_leader`, encounter `mataram_tuyul` |
| SQ-M4 (1) Ki Dalang asks | `mataram_dalang` | `mt_pasar` | `talked_to:mataram_dalang`. Unlock: 2.2 |
| SQ-M4 (2) find the gong | `gong_ageng` (sparkle only) | `mt_reruntuhan` (sealed nook) | `item_picked:gong_ageng` |
| SQ-M4 (3) bring it back | `mataram_dalang` | `mt_pasar` | `talked_to:mataram_dalang` (zone music gains the gong layer, **VERIFY** wording) |
| Codex (rich ruin) | `candi_seribu` | `mt_reruntuhan` | `codex:candi_seribu` |
| Cross-zone SQ-T3 fragment | `batu_bintang` | `mt_candi` front yard | `item_picked:batu_bintang` |

Flags set or read in this region: `mq1_10` (Q), `mq2_6` (**ASSUMED**), `mq2_9` (**ASSUMED**), `sc:mt_ruin_sawah`, `sc:mt_candi_gapura`, `sc:mt_tt` (Q).

## Flow
Gapura entry and the silhouette > `mataram_gerbang` (3 Tuyul, Burst teach) > petilasan `mataram_1` in the rice fields > dalang, village thieves, lone Pocong (Bind teach) > Ruins wake > Pak Karto > lever opens `sc:mt_ruin_sawah` > lesung women > rock thrower in `mt_wetan` > Mbah Marto > temple gate fight > petilasan `mataram_2` > Bandung Bondowoso. Optional elite between the petilasans (a branch of loop C): Wewe Gombel on the hill, or the tuyul leader in `mt_tegal`.

## Encounter list (9)
| Id | Area | Mix | Notes |
|----|------|-----|-------|
| `mataram_gerbang` | gapura | 3 Tuyul | First sight of Tuyul, alone. Burst teach |
| `mataram_pasar` | pasar | 5 Tuyul | Village lanes. Room 22x12 planned |
| `mataram_pocong` | pasar east road | 1 Pocong | New. Lane 10 tiles. Bind teach |
| `mataram_ruins` | reruntuhan | 3 Arca, 2 Tuyul | Room 24x14 planned. Arca wake when passed |
| `mataram_kuburan` | kuburan | 2 Pocong, 3 Tuyul | Optional. Room 26x15, lane 10 |
| `mataram_batu` | wetan | 1 Genderuwo, 2 Pocong | Room 24x14, lane 10 |
| `mataram_candi` | candi | W1: 1 Genderuwo, 2 Arca. W2: 3 Tuyul | Room 28x16 planned. Last fight before `mataram_2` |
| `mataram_wewe` | kuburan hill | elite Wewe Gombel | Optional (SQ-M2 fight). Slow wide swing. Room 20x12 |
| `mataram_tuyul` | tegal | elite tuyul leader + 3 Tuyul | Optional (SQ-M3 fight). Room 18x10 |

First appearance check: Tuyul (gerbang, alone), Pocong (pocong, alone), Arca and Genderuwo appear with known enemies. Newest glyph (Na, Dash-strike) is the clean answer to Arca in `mataram_ruins` and `mataram_candi`.

## Self-check (AGENTS.md section 5 Step 2, and interlock rules 1-8)
Step 2 checklist:
- [x] POI counts: 1 boss arena (`mt_candi`), elite rooms: Wewe hill and the tuyul hideout (world.md wants 1), 9 NPC ids (over the 3-5 target because of side quests, flagged), 3 secrets (gong nook, crypt with Panah Pasopati, well), 1 codex-rich ruin (`mt_reruntuhan`), 9 encounters (6-10), 2 petilasans.
- [x] Petilasan before the boss with no fight between: `mataram_2` sits at the end of `mataram_candi` and the boss arena door is next to it.
- [~] Each enemy first appears alone or with known enemies, weakness usable: Tuyul alone with Burst known; Pocong alone with Bind known; Arca with known Tuyul, but Na is learned after (see Doc conflicts 2).
- [~] One tank per encounter, at most one shooter, at most two waves: one tank everywhere (Genderuwo), two waves only in `mataram_candi`. Shooter rule broken by the bestiary mixes (3 Arca, 2 Arca), see Doc conflicts 3. Arca are stationary (**ASSUMED** exception).
- [x] Rooms with 4+ enemies planned >= 15x9: pasar 22x12, ruins 24x14, kuburan 26x15, candi 28x16, tuyul 18x10. Charger lanes planned 10 tiles (rule: 8), in pocong, kuburan, batu.
- [x] Newest glyph (Na) is the clean answer in two encounters (ruins, candi).
- [x] Every MQ2 and SQ-M step in quests.md has an area and event (table above).
- [x] The critical path needs no Jawa glyph: no gate asks for a glyph; `K2` needs the story flag `mq2_6`, set by the talk, and every enemy dies to the combo and dodge.

Interlock rules:
1. [x] >= 2 loops closed by shortcut or drop: A (drop), B (`sc:mt_ruin_sawah`), D (`sc:mt_candi_gapura`); C is a plain extra loop.
2. [x] >= 2 shortcuts, each ending at or one link from a petilasan: `sc:mt_ruin_sawah` into the petilasan 1 area; `sc:mt_candi_gapura` and `sc:mt_tt` end one link from `mataram_1`.
3. [x] >= 1 drop: `mt_wetan` > `mt_tegal`.
4. [x] Optional areas branch off loops: kuburan off C, tegal off A. No dead-end chains.
5. [x] Boss landmark visible from `mt_gapura`, nearer in sawah, pasar, reruntuhan.
6. [x] Petilasan `mataram_2` right before the boss arena, no fight between.
7. [x] 2 petilasans (`mataram_1`, `mataram_2`).
8. [x] The critical path visits 6 of 8 areas; gates follow story flags (`mq1_10`, `mq2_6`, `mq2_9`); glyphs are rewards, not keys.

## ASSUMED (every decision made here)
1. 8 areas with the names and sizes in the Area table. Exit sides (W/E/N/S) only fix the graph.
2. Gate flags `mq2_6` (kabut `K2` before the temples) and `mq2_9` (kabut `K3` to Tanah Timur). `mq2_9` follows the existing `mq1_10` pattern: set by Semar's talk in Desa Purwa.
3. Shortcut ids `sc:mt_ruin_sawah` and `sc:mt_candi_gapura`; levers and gates as described.
4. The drop from `mt_wetan` to `mt_tegal` does no damage.
5. Encounter ids `mataram_gerbang`, `mataram_pasar`, `mataram_pocong`, `mataram_kuburan`, `mataram_batu`, `mataram_candi`, `mataram_wewe`, `mataram_tuyul`. New small encounters: `mataram_gerbang` (3 Tuyul), `mataram_pocong` (1 Pocong), `mataram_tuyul` (elite leader + 3 Tuyul). Wave 2 in `mataram_candi` rises from a heap of dropped stones.
6. NPC ids: `nawang_wulan`, `lesung_women`, `pande_besi`, `wewe_neighbor`, `wewe_parents`, `pak_karto`, `juru_kunci`; `wewe_parents_2` and `mataram_dalang` come from quests.md.
7. Marker ids not in quests.md: `pak_karto`, `juru_kunci`, `lumbung`, `tuyul_hideout`, `gong_ageng`, `batu_bintang`, `candi_seribu`, and the event strings marked above.
8. Pak Karto stands in the safe outer yard of `mt_reruntuhan`, before the courtyard fight.
9. Boss arena is at least one screen (30x17); the lesung women stand at its edge after 2.5 (from quests.md Boss link).
10. The meteorite fragment for SQ-T3 lies in the `mt_candi` front yard.
11. Secret chests: gong nook gear chest, Panah Pasopati crypt, well gear chest. Item ids for gear chests are for Phase 5.
12. The in-game name "Candi Seribu" for the boss site (invented; the real Prambanan is never named as the arena).
13. The Arca are a stationary-shooter exception to "at most one shooter".

## Open questions
1. Should the kabut `K2` before the temples exist at all, or should the critical path be open from wetan to candi? (Kept: it follows the story flags and makes the juru kunci a stop, not a detour.)
2. Is the quest gate on `K3` meant to need the walk back to Semar? Yes per quests.md 2.9; `sc:mt_candi_gapura` makes it short.
3. SQ-M3 peaceful method (crabs or green beans) and SQ-M4's gong wording stay **VERIFY**.
4. Wewe Gombel is rooted in Bukit Gombel, Semarang (**VERIFY** how much to show); the hill here is a generic graveyard hill.
5. Which gear for the three secret chests (items.md has to name them).
6. Names Ki Sumarto, Pak Karto, Mbah Marto: native speaker check (quests.md section 11).

## Doc conflicts found (not fixed)
1. **Gate flag for `mt_wetan` to `tt_kulon`:** world.md says it lifts when the Mataram boss is beaten; quests.md 2.9 says the fog lifts when the player talks to Semar. This doc uses `mq2_9` (Semar). One of the two needs a fix.
2. **Arca weakness not usable at first sight:** bestiary says Arca's weakness is Na (learned at 2.4), but the "Ruins wake" fight is step 2.3, which comes first. Teach-then-test breaks. Fix options: swap 2.3 and 2.4 (Pak Karto is in the outer yard, so it works in the graph), or accept the combo-only first fight.
3. **Shooter rule:** Encounters say at most one far role (shooter) per encounter, yet Ruins wake has 3 Arca and Temple gate has 2 Arca. The doc keeps the bestiary mixes.
4. **NPC count:** world.md asks for 3-5 NPCs per region; MQ2 plus four side quests need 9. Tatar Sunda set the precedent (10).
5. **`area_cleared:mataram_ruins`:** quests.md uses it as the encounter id (as `area_cleared:sunda_batutulis` does), not the area id `mt_reruntuhan`. This doc follows that.
6. **SQ-T3 fragment location:** quests.md says "near the temple plain" without a place.
7. **Respawn of respawn:** SQ-M2 and SQ-M4 unlock at step 2.2 (Ki Sumarto in `mt_pasar`), SQ-M1 and SQ-M3 at 2.1 (the petilasan in `mt_sawah`). The pande besi and Nawang Wulan can be met before the dalang; no conflict, just noted.
