# Mataram (region `mataram`, area prefix `mt_`), Act 2

Region area graph on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5), graph level plus, since Phase 5, the tile map of each area (sections `## Area n: <id>` after the Quest step locations; `python3 .docs/gen_zones.py .docs/zones/mataram.md` writes `zones/mt_*.gd/.tscn`). Sources: [world.md](../world.md) (Technical frame, World structure with interlock rules 1-8 and the inter-region link table, Mataram, Checkpoints, Points of interest), [bestiary.md](../bestiary.md) (Zone 2: Mataram, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ2, SQ-M1 to SQ-M4, 3.4, 7.5). Tatar Sunda ([tatar_sunda.md](tatar_sunda.md)) is the format example. Change the layout here first, then the code.

Tags used: **ASSUMED** (a decision, change freely), **VERIFY** (culture fact to check before it ships), **TUNE**. Ids marked (Q) already exist in quests.md or world.md.

## Look and landmark
Warm stone, rice terraces, dry fields and volcano foothills. Temple ruins in sandstone grey, orange roof tiles in the village, green padi. The tone stays cartoonish and gentle: the spirit builders are cheeky, not grim. The boss site, the unfinished "thousand temples" (in-game name **Candi Seribu**, an invented place, **VERIFY** before using any real site name), shows as a spiky silhouette of many small spires against the volcano from the very first screen of `mt_gapura`. It looks bigger and more crowded in `mt_sawah`, peeks over the roofs in `mt_pasar`, and stands behind broken walls in `mt_reruntuhan`. A road of paving stones (the causeway) runs straight from the gapura to the temples and is walled off at first: it is the second shortcut. Spirit builders carry stones along the skyline all game long, so the player sees where the boss is. The Durga statue is never shown or named (quests.md sensitivity note).

## Area table
Sizes are in screens (30x17 tiles each). Exit sides are ASSUMED and only fix the graph (W/E/N/S).

| Id | Size | Look | Purpose |
|----|------|------|---------|
| `mt_gapura` | 2x2 = 60x34 | Stone split gateway, dusty road, banyan, the temple silhouette in the east | Entry from the Pamali ford (Keraton Galuh). First teach fight (Tuyul with Burst). Road branches to the rice fields. Far end of the causeway shortcut |
| `mt_sawah` | 3x2 = 90x34 | Stepped rice paddies, a lumbung, a farm yard with a lesung, irrigation channels | Rest hub: petilasan `mataram_1`. SQ-M1 and the lesung women (2.5). Safe area, no fight near the petilasan |
| `mt_pasar` | 2x3 = 60x51 | Village: roofed market lanes, gamelan pavilion, blacksmith stall, dalang's house | Story and quest hub (dalang, SQ-M2 and SQ-M3 givers). Village lanes fight. First Pocong teach on the east road |
| `mt_reruntuhan` | 3x3 = 90x51 | Broken candi walls, courtyards, fallen carved stones, a small site museum | Arca fight (`mataram_ruins`), Pak Karto, codex-rich ruin, gong nook, the far side of the `sc:mt_ruin_sawah` gate. Hub of the loops |
| `mt_kuburan` | 2x2 = 60x34 | Old graveyard with frangipani, a bare hill with one tree, mist | Optional: graveyard fight, Wewe Gombel hill (elite, SQ-M2), crypt secret |
| `mt_wetan` | 3x2 = 90x34 | Rocky foothill field, dry grass, boulders, a cliff ledge, the juru kunci's hut | Rock thrower fight. Mbah Marto (2.6). East exit to Tanah Timur. Start of the drop. Stairs up to the temples |
| `mt_candi` | 3x3 = 90x51 | The unfinished temples: spires, spirit builders, scaffolds, temple gate, the boss court | Front yard with the temple gate fight, petilasan `mataram_2`, boss arena (>= 1 screen, 30x17 **ASSUMED**), the far side of the causeway gate |
| `mt_tegal` | 2x2 = 60x34 | Dry field, a tuyul-haunted well, old brick kiln | Landing of the drop. End of the back road `sc:mt_tt`. SQ-M3 hideout. Secret well chamber. One link from petilasan `mataram_1` |

### Contents (encounters, NPCs, chests, petilasans, codex, secrets, markers)
Encounter ids are proposed `mataram_*` (**ASSUMED**) except `mataram_ruins` (Q, 2.4). Enemy mixes are from bestiary.md "Encounters, Mataram" unless marked new.

| Id | Encounters | NPCs | Chests, petilasan, codex, secrets |
|----|------------|------|-----------------------------------|
| `mt_gapura` | `mataram_gerbang`: 3 Tuyul, one wave (new, teach: Burst clears a swarm; Ca learned in MQ1 1.7) | none (a guard post with a sign only) | Chest `mataram_chest_gapura` (55 Ilmu). Codex spot `codex:gapura` (stone gate) |
| `mt_sawah` | none (safe) | `nawang_wulan` (SQ-M1 giver), `lesung_women` (2.5, teaches Ca), a farmer for flavor | Petilasan **`mataram_1`** (Q). Chest `mataram_chest_sawah`. Codex `codex:gejog_lesung`. Lumbung: SQ-M1 search spot `lumbung`. Barred north gate of `sc:mt_ruin_sawah` |
| `mt_pasar` | `mataram_pasar`: 5 Tuyul (Village thieves), one wave. `mataram_pocong`: 1 Pocong alone on the east road (new, teach: Bind mid-hop, 8-tile lane) | `mataram_dalang` = Ki Sumarto (Q, 2.2, SQ-M4 giver), `pande_besi` (SQ-M3 giver), `wewe_neighbor` (SQ-M2 giver), `wewe_parents` (SQ-M2 alt, later `wewe_parents_2` at the hill) | Chest `mataram_chest_pasar`. Codex `codex:gamelan` |
| `mt_reruntuhan` | `mataram_ruins` (Q): 3 Arca on the edges, 2 Tuyul, courtyard. Wakes when passed (Ruins wake) | `pak_karto` = Pak Karto (2.3), in the safe outer yard before the courtyard | **Codex-rich ruin**: site museum with `codex:candi_seribu`, `codex:roro_jonggrang`, `codex:arca`. Secret 1: sealed nook behind a cracked wall holding the gong ageng (SQ-M4) and a gear chest `mataram_secret_gong`. Far side of `sc:mt_ruin_sawah` |
| `mt_kuburan` | `mataram_kuburan`: 2 Pocong, 3 Tuyul (Graveyard, open ground). `mataram_wewe`: elite Wewe Gombel (only if SQ-M2 is fought, HP 780) | `wewe_parents_2` arrive at the hill if SQ-M2 is peaceful | Secret 2: crypt under the hill, chest **Panah Pasopati** (`mataram_secret_pasopati`, Q reward source "Mataram secret"). Marker `wewe_hill` (Q) |
| `mt_wetan` | `mataram_batu`: 1 Genderuwo, 2 Pocong (Rock thrower, rocky field) | `juru_kunci` = Mbah Marto (2.6, teaches Ra) | Chest `mataram_chest_wetan`. Codex `codex:genderuwo`. Kabut `K3` to `tt_kulon` on the east edge. Drop ledge on the south cliff |
| `mt_candi` | `mataram_candi`: Temple gate, wave 1: 1 Genderuwo, 2 Arca; wave 2: 3 Tuyul rising from a heap of dropped stones with a 0.5 s warning (2 waves). Then no fight to the petilasan | none; the lesung women stand at the arena edge after 2.5 (visual timer, non-interactive) | Petilasan **`mataram_2`** (Q) right before the boss arena. Boss **Bandung Bondowoso** (`bandung_bondowoso`). Chest `mataram_chest_candi`. Batu bintang (SQ-T3 meteorite fragment) in the front yard (**ASSUMED**). Far side of `sc:mt_candi_gapura` |
| `mt_tegal` | `mataram_tuyul`: elite tuyul leader + 3 Tuyul (SQ-M3 fight, new). Peaceful ending has no fight | none | Secret 3: dry well chamber, gear chest `mataram_secret_sumur`. Marker `tuyul_hideout` |

NPC count is 9 ids because of the side quests (world.md says 3-5, Tatar Sunda has 10 for the same reason, **ASSUMED**).

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
kg_pamali   ---  mt_gapura (L, Story v2: always open; kg_alun to kg_pamali is behind kabut `mqg_7`)
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
| `kg_pamali` (E) | `mt_gapura` (W) | link, open (Story v2; the gate is kabut `mqg_7` between kg_alun and kg_pamali) | - | `from_kg_pamali` in gapura; `from_mt_gapura` in kg_pamali |
| `mt_gapura` (E) | `mt_sawah` (W) | link | none | `from_mt_gapura` in sawah; `from_mt_sawah` in gapura |
| `mt_sawah` (S) | `mt_pasar` (N) | link | none | `from_mt_sawah` in pasar; `from_mt_pasar` in sawah |
| `mt_pasar` (S) | `mt_reruntuhan` (N) | link | none | `from_mt_pasar` in reruntuhan; `from_mt_reruntuhan` in pasar |
| `mt_reruntuhan` (E) | `mt_wetan` (W) | link | none | `from_mt_reruntuhan` in wetan; `from_mt_wetan` in reruntuhan |
| `mt_reruntuhan` (S) | `mt_kuburan` (N) | link | none | `from_mt_reruntuhan` in kuburan; `from_mt_kuburan` in reruntuhan |
| `mt_kuburan` (E) | `mt_wetan` (S) | link | none | `from_mt_kuburan` in wetan; `from_mt_wetan` in kuburan |
| `mt_wetan` (S ledge) | `mt_tegal` (N) | **drop**, one way | none | `from_mt_wetan` in tegal (no return exit) |
| `mt_tegal` (W) | `mt_sawah` (E) | link | none | `from_mt_tegal` in sawah; `from_mt_sawah` in tegal |
| `mt_wetan` (N) | `mt_candi` (S) | link, kabut `K2` | `mq2_6` (**ASSUMED**, set when 2.6 completes) | `from_mt_wetan` in candi; `from_mt_candi` in wetan |
| `mt_wetan` (E) | `tt_kulon` | link, kabut `K3` | `mq2_9` (Story v2: set when Hariang Banga yields, quests.md 2.9) | `from_mt_wetan` in tt_kulon; `from_tt_kulon` in wetan |
| `mt_candi` (W) | `mt_gapura` (NE) | shortcut `sc:mt_candi_gapura` | `sc:mt_candi_gapura` | `from_mt_candi` in gapura; `from_mt_gapura` in candi |
| `mt_sawah` (N gate) | `mt_reruntuhan` (SW) | shortcut `sc:mt_ruin_sawah` | `sc:mt_ruin_sawah` | `from_mt_reruntuhan` in sawah; `from_mt_sawah` in reruntuhan |
| `mt_tegal` (E) | `tt_sabana` | shortcut `sc:mt_tt` (Q) | `sc:mt_tt` | `from_tt_sabana` in tegal; `from_mt_tegal` in tt_sabana |

Arrival from a shortcut places the player on the near side with the gate already open. Once open, a shortcut works in both directions for good. The drop is the only edge with a single exit.

### Shortcut table
| Id | Gate area (where the barred door stands) | Open side (where it is opened) | Leads back to |
|----|------------------------------------------|--------------------------------|---------------|
| `sc:mt_ruin_sawah` | `mt_sawah`, barred wooden gate in the north wall | `mt_reruntuhan`: the exit behind the gate starts in the courtyard side yard, past the Ruins wake fight; you arrive in sawah behind the gate and open it | Petilasan `mataram_1` (arrive in sawah, a few tiles away) |
| `sc:mt_candi_gapura` | `mt_gapura`, a walled end of the causeway | `mt_candi`: the exit behind the gate starts in the front yard next to petilasan 2; you arrive in gapura behind the wall and open it | `mt_gapura`, one link from `mataram_1` (and the road west to the Pamali ford for 2.8-2.9) |
| `sc:mt_tt` (Q world.md) | `mt_tegal`, a boulder-blocked back road | `tt_sabana` (Tanah Timur side) | `mt_tegal`, one link from `mataram_1` |

## Loops, drop, critical path, optional areas
**Loops** (every first trip is long, later trips are short):
- **A (big):** `mt_sawah` > `mt_pasar` > `mt_reruntuhan` > `mt_wetan` > drop > `mt_tegal` > `mt_sawah`. The drop closes it: the fall lands near petilasan 1.
- **B (village):** `mt_sawah` > `mt_pasar` > `mt_reruntuhan` > `sc:mt_ruin_sawah` > `mt_sawah`. After the ruins, the way back to the lesung and the petilasan is one gate.
- **C (graveyard):** `mt_reruntuhan` > `mt_kuburan` > `mt_wetan` > `mt_reruntuhan`. A plain loop with the optional graveyard in its middle.
- **D (causeway):** `mt_gapura` > `mt_sawah` > `mt_pasar` > `mt_reruntuhan` > `mt_wetan` > `mt_candi` > `sc:mt_candi_gapura` > `mt_gapura`. The player first sees the walled causeway at the very start, then opens it at the very end.

**Drop:** `mt_wetan` south ledge to `mt_tegal` (one way, no fall damage, **ASSUMED** for the forgiving tone). A railing with a gap and a worn path make it readable.

**Critical path** (MQ2 order, 6 of 8 areas): `kg_pamali` > `mt_gapura` (E gerbang) > `mt_sawah` (2.1 `mataram_1`) > `mt_pasar` (2.2 dalang) > east road (`mataram_pocong`) > `mt_reruntuhan` (2.3 Pak Karto, 2.4 ruins) > open `sc:mt_ruin_sawah` > `mt_sawah` (2.5 lesung) > back through the shortcut > `mt_wetan` (E batu, 2.6 Mbah Marto, sets `mq2_6`) > `K2` > `mt_candi` (E candi, Laras beat at `mataram_2`, 2.7 `mataram_camp`) > open `sc:mt_candi_gapura` > `mt_gapura` > west to `kg_pamali` (2.8 the stone, 2.9 Hariang Banga, sets `mq2_9`) > back through `mt_gapura` to `mt_wetan` > `K3` > `tt_kulon`. Story v2: the player enters at `mt_gapura` from `kg_pamali`, so the critical path starts there.

**Main-path kills (balance.md 2.1):** before roaming packs 23 (gapura 3, pasar 6, ruins 5, wetan 3, candi 6); after 40 (+17: gapura 3, sawah 3, pasar 3, ruins 5, wetan 3; candi gets none, so nothing sits between `mataram_2` and the boss). `mt_tegal` adds 3 optional kills. Gate: Tuyul anywhere after Burst (MQ1), but only east of `mataram_gerbang`; Pocong only from `mt_reruntuhan` on (Bind taught at `mataram_pocong`) and in `mt_tegal` (drop is after the ruins); no loose Arca or Genderuwo.

**Optional areas and the loop they branch off:**
| Area | Branches off | Why it is worth it |
|------|--------------|--------------------|
| `mt_kuburan` | Loop C (between reruntuhan and wetan) | Wewe Gombel hill (SQ-M2), graveyard fight, Panah Pasopati crypt |
| `mt_tegal` | Loop A (drop landing and link to sawah) | SQ-M3 hideout, well secret, the road to Tanah Timur later |

No optional area hangs off the end of a dead-end chain.

## Quest step locations
Marker form `{zone: "<area id>", id: ...}` (the area in the Area column; `QuestData.zone` stays `mataram` for the Ilmu tiers). Ids from quests.md or world.md are marked (Q). Everything else is **ASSUMED**.

| Step | Marker id | Area | Event string |
|------|-----------|------|--------------|
| Unlock: from Keraton Galuh | none | `mt_gapura` entry | `zone_entered:mataram` |
| 2.1 rest at the petilasan | `mataram_1` (Q) | `mt_sawah` | `petilasan_activated:mataram_1` (Q) |
| 2.2 hear the dalang | `mataram_dalang` (Q) | `mt_pasar` | `talked_to:mataram_dalang` (Q), teaches Ha |
| 2.3 learn Na | `pak_karto` | `mt_reruntuhan` (outer yard) | `glyph_learned:jawa_na` (Q) |
| 2.4 wake the guardians | `mataram_ruins` (Q) | `mt_reruntuhan` | `area_cleared:mataram_ruins` (Q), the encounter id |
| 2.5 join the lesung women | `lesung_women` (Q) | `mt_sawah` | `talked_to:lesung_women` (Q), teaches Ca (Jawa) |
| 2.6 juru kunci's blessing | `juru_kunci` | `mt_wetan` | `glyph_learned:jawa_ra` (Q); sets flag `mq2_6` (opens `K2`) |
| 2.7 break the faceless camp | `mataram_camp` (Q) | `mt_candi` (temple court, F) | `area_cleared:mataram_camp` (Q); sets flag `mq2_7` |
| 2.8 write Nagawiru's name on the Pamali stone | `pamali_stone` (Q) | `kg_pamali` | `name_written:nagawiru` (Q); sets flag `mq2_8` |
| 2.9 the duel at the Pamali | `hariang_banga` (Q) | `kg_pamali` | `boss_defeated:hariang_banga` (Q); sets flag `mq2_9` (opens `K3`) |
| SQ-M5 Gema: Seribu Candi | `bandung_bondowoso` | `mt_candi` (boss arena, cond `quest:sq_m5=active`) | `boss_defeated:bandung_bondowoso` |
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

## Area maps (Phase 5)
The 8 sections below follow the format of [tatar_sunda.md](tatar_sunda.md) (tile chars, legend, rooms, encounters). Coordinates are (x, y) from the top-left tile (0,0). Shortcut gates have their pocket (exit, spawn) on the open side. Both elites (`wewe_gombel`, `tuyul_leader`) are plain spots, inert until their quest step, and not encounters.

## Area 1: mt_gapura

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Stone split gateway, dusty road, banyan trees, the Candi Seribu silhouette far in the east sky. A paved causeway wall runs along the north-east.
- Purpose: Entry from `kg_pamali` (Story v2; the gate is kabut `mqg_7` in Keraton Galuh), first teach fight `mataram_gerbang`, road to the rice fields. Holds the gate of shortcut `sc:mt_candi_gapura` (walled causeway end).

### Map
```
############################################################
#.........##.....................................###########
#.........##.....................................=,,,,,,,,zZ
#.........##.....................................=,,,,,,,,,Z
#...bbb...##.....................................###########
#...bbb...##..................bbb..........................#
#...bbb...##..................bbb..........................#
#.........##..................bbb..........................#
#.........##...............................................#
#.........##...............................................#
#.........##...............................................#
#.........##...............................................#
#.........##.g.............................................#
#.........##...............................................#
#..........................................................#
#..........................................................#
Xe,,,,,,,,,,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,,,,,,,,,,,,,,,yY
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#..........................................................#
#..........................................................#
#.........##...............................................#
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

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| entry yard | (1,14)-(9,19) 9x6 | Arrival from the Pamali ford | exit `X` (0,16..17), spawn `e` (1,16) | gate is on the Galuh side |
| gateway | (10,14)-(11,19) 2x6 | Split stone gate, 6 tiles wide, silhouette view | codex `g` (13,12) just east | none |
| gerbang field | (19,11)-(41,21) 23x11 | First teach fight, open road | E (30,16) `mataram_gerbang`, chest `c` (46,28) in the banyan corner | area_cleared:mataram_gerbang (flavour) |
| east road | (42,16)-(58,17) 17x2 | Road to mt_sawah | exit `Y` (59,16..17), spawn `y` (58,16) | none |
| causeway pocket | (50,2)-(58,3) 9x2 | Walled paved causeway, 9x2, open side east of the gate | gate `=` (49,2..3) `sc:mt_candi_gapura` (open_side `e`), exit `Z` (59,2..3), spawn `z` (58,2) | none |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_gerbang` | `E (30,16)` | 22x11 | W1: Tuyul (-4,-3), Tuyul (+2,+3), Tuyul (+6,-2) | Burst (Ca learned in MQ1 1.7) clears the swarm |

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Tuyul (46,23), Tuyul (48,24), Tuyul (47,26). 3 kills, skirtable.

## Area 2: mt_sawah

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: Stepped green padi terraces, irrigation channels, a lumbung, a farm yard with a lesung. The temple spires stand larger in the east sky.
- Purpose: Rest hub: petilasan `mataram_1`. SQ-M1 (Nawang Wulan, lumbung) and the lesung women (2.5). No enemies. Holds the gate of shortcut `sc:mt_ruin_sawah` in the north wall.

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
Xe,,,,,,,,,,,,,,,,,,,,,,,,,,,,P,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,zZ
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Z
#...........................................,,...........................................#
#...........................................,,..........bbbbbb,,bbbbbbbbb................#
#...........................................,,..........b,,,,,,,,,,,,,,,b................#
#...####,####...ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...#_______#...ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
#...#______s#...ttttttttttttttttttttttttt...,,.....u....b,,,g,,,,,,,,,,,b.ttttttttttttt..#
#...#___L___#...ttttttttttttttttttttttttt...,,..........b,,,,,,,,,,,,,,,b.ttttttttttttt..#
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
| `W` | NPC lesung women (2.5, teaches Ca) | `res://entities/npc/npc.tscn` | `{npc_id:"lesung_women"}` | path | 1 |
| `g` | codex spot, gejog lesung | `res://entities/world/pickup.tscn` | `{codex_id:"gejog_lesung"}` | path | 1 |
| `c` | chest: Axe (items.md Zone 2 chest) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_chest_sawah", item_id:"axe"}` | grass | 1 |
| `L` | trigger, lumbung entered (SQ-M1 search) | `res://entities/world/trigger.tscn` | `{trigger_id:"lumbung", size:Vector2i(7,5)}` | floor | 1 |
| `s` | pickup, selendang Nawang Wulan (sparkle, SQ-M1) | `res://entities/world/pickup.tscn` | `{item_id:"selendang_nawang"}` | floor | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 3 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| west road | (1,16)-(29,17) 29x2 | Arrival from mt_gapura | exit `X` (0,16..17), spawn `e` (1,16) | none |
| rest area | (26,14)-(38,19) 13x6 | Petilasan and Nawang Wulan, safe | P (30,16), Nawang Wulan `N` (36,14) | 2.1 `mataram_1`, SQ-M1 `nawang_wulan` |
| north gate pocket | (20,1)-(21,3) 2x3 | Pocket and gate of `sc:mt_ruin_sawah`, corridor (20..21,4..15) down to the road | gate `=` (20..21,3) open_side `n`, exit `Q` (20..21,0), spawn `q` (20,1) | none |
| lumbung | (4,21)-(12,27) 9x7 | Barn, door (8,21) | trigger `L` (8,24), selendang `s` (11,23) | SQ-M1 `lumbung`, item_picked:selendang_nawang |
| farm yard | (57,20)-(71,30) 15x11 | Lesung yard, fence gate (62..63,19) | lesung women `W` (64,25), codex `g` (60,23) | 2.5 `lesung_women` |
| east terraces | (50,3)-(86,12) 37x10 | Padi, chest behind the channel | chest `c` (84,14) | none |
| south road | (44,18)-(45,32) 2x15 | Road to mt_pasar | exit `Y` (44..45,33), spawn `y` (44,32) | none |
| east road | (46,16)-(88,17) 43x2 | Road to mt_tegal | exit `Z` (89,16..17), spawn `z` (88,16) | none |

### Encounters
None.

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Tuyul (51,23), Tuyul (53,25), Tuyul (52,28). 3 kills, skirtable.

## Area 3: mt_pasar

- Size: 60 x 51 tiles = 2 x 3 screens (30 x 17 each).
- Look: Orange roofed village: market lanes, a gamelan pavilion, a blacksmith stall, the dalang's house. Spires peek over the roofs.
- Purpose: Story and quest hub (dalang, SQ-M2, SQ-M3, SQ-M4 givers). Thieves fight in the market plaza (`mataram_pasar`). First Pocong teach on the east road (`mataram_pocong`).

### Map
```
############################XX##############################
#...........................e,.............................#
#...........................,,.............................#
#.....###########...........,,..........#############......#
#.....#_________#...........,,..........#___________#......#
#.....#_________#...........,,..........#___________#......#
#.....#____D____#...........,,..........#_____B_____#......#
#.....#_________#...........,,..........#___________#......#
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
#...................W.......,,.............................#
#....####,####..............,,........_____________........#
#....#_______#..............,,........_____________........#
#....#_______#..............,,........_____________........#
#....#_______#..............,,........______G______........#
#....#___P___#..............,,........_____________........#
#....#_______#..............,,........_____________........#
#....#########..............,,........_____________........#
#...........................,,........_____________........#
#...........................,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#..............bb...........,,..........bb.................#
#.......u......bb...........,,..........bb..bbbbbbbbbbbbbbb#
#...........................,,.............................#
#.........u.................,,.............................#
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
| `D` | NPC Ki Sumarto, the dalang (2.2, SQ-M4 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"mataram_dalang"}` | floor | 1 |
| `B` | NPC pande besi, blacksmith (SQ-M3 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"pande_besi"}` | floor | 1 |
| `W` | NPC worried neighbor (SQ-M2 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"wewe_neighbor"}` | grass | 1 |
| `P` | NPC Wewe's parents (SQ-M2 alt) | `res://entities/npc/npc.tscn` | `{npc_id:"wewe_parents"}` | floor | 1 |
| `G` | codex spot, gamelan (pavilion) | `res://entities/world/pickup.tscn` | `{codex_id:"gamelan"}` | floor | 1 |
| `E` | encounter mataram_pasar | `res://entities/world/encounter.tscn` | `{area_id:"mataram_pasar", size:Vector2i(22,12), waves:[[[res://entities/enemies/tuyul.tscn, Vector2i(-8,-3)], [res://entities/enemies/tuyul.tscn, Vector2i(-4,3)], [res://entities/enemies/tuyul.tscn, Vector2i(0,-4)], [res://entities/enemies/tuyul.tscn, Vector2i(5,2)], [res://entities/enemies/tuyul.tscn, Vector2i(9,-2)]]]}` | path | 1 |
| `O` | encounter mataram_pocong | `res://entities/world/encounter.tscn` | `{area_id:"mataram_pocong", size:Vector2i(16,7), waves:[[[res://entities/enemies/pocong.tscn, Vector2i(4,0)]]]}` | path | 1 |
| `c` | chest: 55 Ilmu (Ilmu S, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_chest_pasar", item_id:"ilmu:55"}` | grass | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 3 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| north gate | (28,1)-(29,3) 2x3 | Arrival from mt_sawah | exit `X` (28..29,0), spawn `e` (28,1) | none |
| dalang house | (6,3)-(16,10) 11x8 | Ki Sumarto, door (11,10) | D (11,6) | 2.2 `mataram_dalang`, SQ-M4 steps 1 and 3 |
| smithy | (40,3)-(52,10) 13x8 | Blacksmith stall, door (46,10) | B (46,6) | SQ-M3 `pande_besi` |
| cross lane | (3,15)-(56,16) 54x2 | East-west lane, no enemies | neighbor `W` (20,18) | SQ-M2 `wewe_neighbor` |
| parents' house | (5,19)-(13,25) 9x7 | Door (9,19) | P (9,23) | SQ-M2 alt `wewe_parents` |
| gamelan pavilion | (38,19)-(50,26) 13x8 | Open pavilion | codex `G` (44,22) | codex:gamelan |
| market plaza | (17,30)-(39,41) 23x12 | Thieves fight, 22x12 | E (28,36) `mataram_pasar` | fight (flavour) |
| east road and yard | (30,36)-(58,37) 29x2 lane, yard (44,32)-(58,42) | Straight lane 28 tiles into a yard | O (50,36) `mataram_pocong` (Pocong at +4), chest `c` (56,41) | none |
| south gate | (28,44)-(29,49) 2x6 | To mt_reruntuhan | exit `Y` (28..29,50), spawn `y` (28,49) | none |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_pasar` | `E (28,36)` | 22x12 | W1: Tuyul (-8,-3), Tuyul (-4,+3), Tuyul (+0,-4), Tuyul (+5,+2), Tuyul (+9,-2) | Burst (swarm); Bind a runner |
| `mataram_pocong` | `O (50,36)` | 16x7 | W1: Pocong (+4,+0) | Bind mid-hop (Pocong charger lane 10+ tiles) |

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Tuyul (8,31), Tuyul (10,33), Tuyul (7,34). 3 kills, skirtable.

## Area 4: mt_reruntuhan

- Size: 90 x 51 tiles = 3 x 3 screens (30 x 17 each).
- Look: Sandstone-grey broken candi walls, courtyards, fallen carved stones, a small site museum. Spires stand behind the broken wall.
- Purpose: Arca fight `mataram_ruins`, Pak Karto in the safe outer yard, the codex-rich site museum, the gong nook, the far side of the `sc:mt_ruin_sawah` gate (exit `W` in the side yard past the fight). Hub of loops B and C.

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
#........................#..................,,..................#........................#
#.......k................#..................,,..................#........................#
#........................#..................,,........rr........#........................#
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
| `K` | NPC Pak Karto (2.3, teaches Na) | `res://entities/npc/npc.tscn` | `{npc_id:"pak_karto"}` | grass | 1 |
| `E` | encounter mataram_ruins | `res://entities/world/encounter.tscn` | `{area_id:"mataram_ruins", size:Vector2i(24,14), waves:[[[res://entities/enemies/arca.tscn, Vector2i(-11,-5)], [res://entities/enemies/arca.tscn, Vector2i(11,5)], [res://entities/enemies/arca.tscn, Vector2i(0,-6)], [res://entities/enemies/tuyul.tscn, Vector2i(-4,2)], [res://entities/enemies/tuyul.tscn, Vector2i(5,-1)]]]}` | path | 1 |
| `m` | codex spot, Candi Seribu (museum) | `res://entities/world/pickup.tscn` | `{codex_id:"candi_seribu"}` | floor | 1 |
| `n` | codex spot, Roro Jonggrang (museum) | `res://entities/world/pickup.tscn` | `{codex_id:"roro_jonggrang"}` | floor | 1 |
| `o` | codex spot, Arca (museum) | `res://entities/world/pickup.tscn` | `{codex_id:"arca"}` | floor | 1 |
| `g` | pickup, gong ageng (sparkle, SQ-M4, secret 1 nook) | `res://entities/world/pickup.tscn` | `{item_id:"gong_ageng"}` | floor | 1 |
| `c` | chest: Longbow (secret 1, items.md Zone 2 chest) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_secret_gong", item_id:"longbow"}` | floor | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 2 |
| `k` | loose Pocong, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/pocong.tscn` | `{}` | grass | 3 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| entry and outer yard | (1,1)-(88,13) 88x13 | Safe yard before the courtyard | exit `X` (44..45,0), spawn `e` (44,1), Pak Karto `K` (40,8) | 2.3 `pak_karto` |
| site museum | (62,3)-(82,11) 21x9 | Codex-rich room, door (72,11) | `m` (66,7), `n` (72,7), `o` (78,7) | codex:candi_seribu, roro_jonggrang, arca |
| courtyard | (26,15)-(63,38) 38x24 | Ruins wake fight, 24x14 room in the middle | E (44,26) `mataram_ruins`, 3 Arca on the edges, 2 Tuyul | 2.4 `mataram_ruins` |
| side yard (west) | (1,15)-(24,49) 24x35 | Past the fight, reached by the west gap (25,31..32) | exit `W` (0,40..41), spawn `w` (1,40) | `sc:mt_ruin_sawah` far side |
| east road | (65,26)-(88,27) 24x2 | Road to mt_wetan | exit `Y` (89,26..27), spawn `y` (88,26) | none |
| south yard | (44,40)-(45,49) 2x10 | Road to mt_kuburan | exit `Z` (44..45,50), spawn `z` (44,49) | none |
| gong nook | (75,40)-(85,46) 11x7 | Secret 1, door (80,40) between two rocks (ASSUMED: open gap, no breakable wall) | gong `g` (80,43), chest `c` (83,44) | SQ-M4 `gong_ageng` |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_ruins` | `E (44,26)` | 24x14 | W1: Arca (-11,-5), Arca (+11,+5), Arca (+0,-6), Tuyul (-4,+2), Tuyul (+5,-1) | Na (Dash-strike) on the Arca; Burst on the Tuyul |

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Pocong (8,20), Pocong (11,22), Tuyul (10,25), Pocong (76,32), Tuyul (78,33). 5 kills, skirtable.

## Area 5: mt_kuburan

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Old graveyard under frangipani, a bare hill with one tree, a low mist.
- Purpose: Optional: graveyard fight, Wewe Gombel hill (SQ-M2 elite or peaceful end), crypt secret with Panah Pasopati. Branches off loop C.

### Map
```
##########XX################################################
#.........e,...............................................#
#.........,,...............................................#
#.........,,...............................................#
#.........,,...............................................#
#.........,,..r.r.r.r.r.r.r.r.r.r..........................#
#.........,,........................................b......#
#.........,,..r.r.r.r.r.r.r.r.r.r..........................#
#.........,,...............................................#
#.........,,...............................................#
#.........,,....................................T..........#
#.........,,..................................q............#
#.........,,...............................................#
#.....b...........................b...............p........#
#..........................................................#
#..........................................................#
#..........................................................#
#..........................................................#
#.....................E..............,,,,,,,,,,,,,,,,,,,,,yY
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
| `q` | elite Wewe Gombel (SQ-M2, inert until step 3) | `res://entities/enemies/wewe_gombel.tscn` | `{}` | grass | 1 |
| `p` | NPC Wewe's parents at the hill (SQ-M2 peaceful) | `res://entities/npc/npc.tscn` | `{npc_id:"wewe_parents_2"}` | grass | 1 |
| `c` | chest: Panah Pasopati (secret 2, crypt) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_secret_pasopati", item_id:"panah_pasopati"}` | floor | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| north gate | (10,1)-(11,12) 2x12 | Arrival from mt_reruntuhan, path into the graveyard | exit `X` (10..11,0), spawn `e` (10,1) | none |
| graveyard | (9,11)-(35,25) 27x15 | Optional fight, 26x15, open ground, lane 10+ | E (22,18) `mataram_kuburan` | fight (flavour) |
| wewe hill | (40,3)-(56,16) 17x14 | Bare hill, one tree (52,6) | trigger `T` (48,10), elite `q` (46,11), parents `p` (50,13) | SQ-M2 `wewe_hill`, `wewe_parents_2`, `wewe_elite` |
| east road | (37,18)-(58,19) 22x2 | Road to mt_wetan | exit `Y` (59,18..19), spawn `y` (58,18) | none |
| crypt | (40,22)-(52,30) 13x9 | Secret 2, door (46,22), stairs (46,20..21) | chest `c` (46,27) | Panah Pasopati source |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_kuburan` | `E (22,18)` | 26x15 | W1: Pocong (+8,-4), Pocong (+8,+4), Tuyul (-6,-5), Tuyul (-3,+5), Tuyul (+2,+0) | Bind a Pocong mid-hop; Burst the Tuyul |

## Area 6: mt_wetan

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: Rocky foothill field, dry grass, boulders, a cliff ledge in the south, the juru kunci's hut.
- Purpose: Rock thrower fight `mataram_batu`, Mbah Marto (2.6, teaches Ra), K2 north to the temples, K3 east to Tanah Timur, the drop ledge south, link to mt_kuburan.

### Map
```
############################################NN############################################
#..........................................#n,#..........................................#
#..........................................#,,#..........................................#
#...................##########.............#KK#..........................................#
#.......rr..........#________#.............#,,#..........................................#
#.......rr..........#________#..............,,...........................................#
#...................#___M____#..............,,....................rrr....................#
#...................#________#..............,,....................rrr....................#
#...................#________#..............,,................g...rrr...........c........#
#...................####,#####..............,,...........................................#
#.......................,...................,,...........................................#
#.......................,...................,,...........................................#
Xe,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,...........................................#
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,...........................................#
#.............,,.........................................................................#
#.............,,................................................................##########
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
| `M` | NPC juru kunci Mbah Marto (2.6, teaches Ra) | `res://entities/npc/npc.tscn` | `{npc_id:"juru_kunci"}` | floor | 1 |
| `E` | encounter mataram_batu | `res://entities/world/encounter.tscn` | `{area_id:"mataram_batu", size:Vector2i(24,14), waves:[[[res://entities/enemies/genderuwo.tscn, Vector2i(9,0)], [res://entities/enemies/pocong.tscn, Vector2i(4,-4)], [res://entities/enemies/pocong.tscn, Vector2i(4,4)]]]}` | grass | 1 |
| `c` | chest: Iron Staff (items.md Zone 2, no drops yet) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_chest_wetan", item_id:"iron_staff"}` | grass | 1 |
| `g` | codex spot, Genderuwo | `res://entities/world/pickup.tscn` | `{codex_id:"genderuwo"}` | grass | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 2 |
| `k` | loose Pocong, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/pocong.tscn` | `{}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| west road | (1,12)-(43,13) 43x2 | Arrival from mt_reruntuhan | exit `X` (0,12..13), spawn `e` (1,12) | none |
| juru kunci hut | (20,3)-(29,9) 10x7 | Door (24,9) | M (24,6) | 2.6 `juru_kunci`, sets `mq2_6` |
| north stairs | (44,1)-(45,13) 2x13 | Corridor to the temples; K2 at (44..45,3) | K `K`, exit `N` (44..45,0), spawn `n` (44,1) | 2.6 flag `mq2_6` opens K2 |
| rocky field | (38,13)-(62,27) 25x15 | Rock thrower fight, 24x14, lane 16 | E (50,20) `mataram_batu` | 2.6 fight (flavour) |
| kuburan road | (14,14)-(15,32) 2x19 | Road to mt_kuburan | exit `Y` (14..15,33), spawn `y` (14,32) | none |
| drop ledge | (70,22)-(71,32) 2x11 | Worn path and railing gaps, south cliff | exit `D` (70..71,33), no spawn back | none |
| east road | (62,16)-(88,17) 27x2 | Walled road to tt_kulon; K3 at (84,16..17) | J, exit `T` (89,16..17), spawn `t` (88,16) | mq2_9 opens K3 |
| boulder corner | (60,3)-(86,10) 27x8 | Chest and codex | chest `c` (80,8), codex `g` (62,8) | codex:genderuwo |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_batu` | `E (50,20)` | 24x14 | W1: Genderuwo (+9,+0), Pocong (+4,-4), Pocong (+4,+4) | Bind the Pocong, close in on the Genderuwo; dodge rocks |

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Pocong (20,18), Tuyul (22,19), Tuyul (21,22). 3 kills, skirtable.

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
#............#,,,,,,,,,,,,,,,,B,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,F,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#........................................#
#............#rr,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,rr#........................................#
#............#rr,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,rr#........................................#
#............################,,,#################........................................#
#............................,,,..................,,.....................................#
#............................,,,..................,,.....................................#
#............................,P,..................,,.....................................#
Yy,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..................,,.....................................#
Y,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..................,,.....................................#
#.............................,,,,,,,,,,,,,,,,,,,,,,..................rr.................#
#.............................,,,,,,,,,,,,,,,,,,,,,,..................rr.................#
#.................................................,,............................c........#
#.......rr........................................,,.....................................#
#.......rr........................................,,.....................................#
#.................................................,,.....................................#
#...................rr............................,,.....................................#
#...................rr............................,,.....................................#
#.................................................,,....................s................#
#.................................................,,.....................................#
#.................................................E,.....................................#
#.................................................,,.....................................#
#.....rr..........................................,,..................rr.................#
#.....rr..........................................,,..................rr.................#
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
| `B` | boss Bandung Bondowoso, awakened after Faceless camp breaks the Temple Seal | `res://entities/bosses/bandung_bondowoso.tscn` | `{cond:"flag:mq2_7"}` | path | 1 |
| `F` | encounter mataram_camp, the faceless camp in the temple court (MQ2 2.7) | `res://entities/world/encounter.tscn` | `{area_id:"mataram_camp", cond:"flag:mq2_6", size:Vector2i(30,16), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-6,-3)], [res://entities/enemies/faceless.tscn, Vector2i(6,-3)], [res://entities/enemies/faceless.tscn, Vector2i(0,4)], [res://entities/enemies/faceless_archer.tscn, Vector2i(0,-6)]], [[res://entities/enemies/faceless.tscn, Vector2i(-8,2)], [res://entities/enemies/faceless.tscn, Vector2i(8,2)], [res://entities/enemies/faceless_archer.tscn, Vector2i(-4,-6)], [res://entities/enemies/faceless_archer.tscn, Vector2i(4,-6)]]]}` | path | 1 |
| `E` | encounter mataram_candi | `res://entities/world/encounter.tscn` | `{area_id:"mataram_candi", size:Vector2i(28,16), waves:[[[res://entities/enemies/genderuwo.tscn, Vector2i(8,-4)], [res://entities/enemies/arca.tscn, Vector2i(-12,-5)], [res://entities/enemies/arca.tscn, Vector2i(12,-5)]], [[res://entities/enemies/tuyul.tscn, Vector2i(0,-3)], [res://entities/enemies/tuyul.tscn, Vector2i(-4,0)], [res://entities/enemies/tuyul.tscn, Vector2i(4,0)]]]}` | path | 1 |
| `s` | pickup, batu bintang (SQ-T3 meteorite fragment) | `res://entities/world/pickup.tscn` | `{item_id:"batu_bintang"}` | grass | 1 |
| `c` | chest: 110 Ilmu (Ilmu M, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_chest_candi", item_id:"ilmu:110"}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| south gate | (50,47)-(51,49) 2x3 | Arrival from mt_wetan | exit `X` (50..51,50), spawn `e` (50,49) | none |
| front yard fight | (36,30)-(64,46) 29x17 | Temple gate fight, 28x16, two waves | E (50,38) `mataram_candi` | none |
| east yard | (66,28)-(88,48) 23x21 | Side yard | batu bintang `s` (72,36), chest `c` (80,30) | item_picked:batu_bintang |
| west road | (1,26)-(28,27) 28x2 | Road to the petilasan, 30 tiles from the exit | exit `Y` (0,26..27), spawn `y` (1,26) | `sc:mt_candi_gapura` far side |
| petilasan court | (29,23)-(31,27) 3x5 | Rest right before the arena, no fight | P (30,25) | Laras beat 3 at `mataram_2` |
| boss arena | (14,2)-(47,21) 34x20 | 34x20 open floor, gate gap (29..31,22), pillars spawn 5-8 tiles around B | camp F (30,12), B (30,9) | 2.7 `mataram_camp`; SQ-M5 `bandung_bondowoso` |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `mataram_candi` | `E (50,38)` | 28x16 | W1: Genderuwo (+8,-4), Arca (-12,-5), Arca (+12,-5); W2: Tuyul (+0,-3), Tuyul (-4,+0), Tuyul (+4,+0) | Na (Dash-strike) on the Arca; Bind then Burst for wave 2 |

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
#.......................,...........#___L___q___#..........#
#.......................,...........#_____T_____#..........#
#.......................,...........#___________#..........#
#.......................,...........#___________#..........#
#.......................,...........######,######..........#
#.......................,.................,.........#......#
#.......................,.................,.........########
Xe,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,=,,,,,yY
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,=,,,,,,Y
#...................................................########
#...................................................#......#
#..........rr..............................................#
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
| `q` | elite tuyul leader (SQ-M3, inert until step 2) | `res://entities/enemies/tuyul_leader.tscn` | `{}` | floor | 1 |
| `c` | chest: Amulet (secret 3, well chamber, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"mataram_secret_sumur", item_id:"amulet"}` | floor | 1 |
| `u` | loose Tuyul, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/tuyul.tscn` | `{}` | grass | 2 |
| `k` | loose Pocong, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/pocong.tscn` | `{}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| west road | (1,16)-(51,17) 51x2 | Link to mt_sawah | exit `X` (0,16..17), spawn `e` (1,16) | none |
| landing path | (24,4)-(24,15) 1x12 | One-way drop landing | spawn `l` (24,4), no exit back | none |
| kiln hideout | (36,6)-(48,13) 13x8 | Brick kiln, door (42,13) | trigger `T` (42,10), leader NPC `L` (40,9), elite `q` (44,9) | SQ-M3 `tuyul_hideout`, `tuyul_leader` |
| well chamber | (8,24)-(18,30) 11x7 | Secret 3, door (13,24), dry well rocks above | chest `c` (13,28) | none |
| back road pocket | (53,16)-(58,17) 6x2 | Boulder-blocked back road, gate (52,16..17), open side east | gate `=` `sc:mt_tt`, exit `Y` (59,16..17), spawn `y` (58,16) | none |

### Encounters
None.

Roaming packs (loose, `u` Tuyul, `k` Pocong, 6+ tiles from every spawn, exit and petilasan, outside the encounter rects): Tuyul (40,22), Tuyul (42,24), Pocong (41,26). 3 kills, skirtable.

## Flow
Gapura entry and the silhouette > `mataram_gerbang` (3 Tuyul, Burst teach) > petilasan `mataram_1` in the rice fields > dalang, village thieves, lone Pocong (Bind teach) > Pak Karto (Na) > Ruins wake > open `sc:mt_ruin_sawah` from the ruins side > lesung women > rock thrower in `mt_wetan` > Mbah Marto > temple gate fight > petilasan `mataram_2` > Bandung Bondowoso. Optional elite between the petilasans (a branch of loop C): Wewe Gombel on the hill, or the tuyul leader in `mt_tegal`.

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
| `mataram_wewe` | kuburan hill | elite Wewe Gombel | Optional (SQ-M2 fight). Slow wide swing. Placed as a plain spot `q` on the hill (no encounter node, like the Kuntilanak elite) |
| `mataram_tuyul` | tegal | elite tuyul leader (+ 3 Tuyul not placed) | Optional (SQ-M3 fight). Leader alone as a plain spot `q` in the kiln; the 3 Tuyul are left out so the peaceful ending stays peaceful (open question 7) |

First appearance check: Tuyul (gerbang, alone), Pocong (pocong, alone), Arca and Genderuwo appear with known enemies. Newest glyph (Na, Dash-strike) is the clean answer to Arca in `mataram_ruins` and `mataram_candi`.

## Self-check (AGENTS.md section 5 Step 2, and interlock rules 1-8)
Step 2 checklist:
- [x] POI counts: 1 boss arena (`mt_candi`), elite rooms: Wewe hill and the tuyul hideout (world.md wants 1), 9 NPC ids (over the 3-5 target because of side quests, flagged), 3 secrets (gong nook, crypt with Panah Pasopati, well), 1 codex-rich ruin (`mt_reruntuhan`), 9 encounters (6-10; built as 7 encounter nodes plus the 2 elites as plain spots), 2 petilasans.
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
2. Gate flags `mq2_6` (kabut `K2` before the temples) and `mq2_9` (kabut `K3` to Tanah Timur). `mq2_9` is set when Hariang Banga yields at the Pamali (Story v2).
3. Shortcut ids `sc:mt_ruin_sawah` and `sc:mt_candi_gapura`. Both are the Tatar Sunda shortcut gate (`entities/world/shortcut.tscn`): it stands in the gate area and opens from the side the opener area's exit arrives on. No levers (2026-11-05).
4. The drop from `mt_wetan` to `mt_tegal` does no damage.
5. Encounter ids `mataram_gerbang`, `mataram_pasar`, `mataram_pocong`, `mataram_kuburan`, `mataram_batu`, `mataram_candi`, `mataram_wewe`, `mataram_tuyul`. New small encounters: `mataram_gerbang` (3 Tuyul), `mataram_pocong` (1 Pocong), `mataram_tuyul` (elite leader + 3 Tuyul). Wave 2 in `mataram_candi` rises from a heap of dropped stones.
6. NPC ids: `nawang_wulan`, `lesung_women`, `pande_besi`, `wewe_neighbor`, `wewe_parents`, `pak_karto`, `juru_kunci`; `wewe_parents_2` and `mataram_dalang` come from quests.md.
7. Marker ids not in quests.md: `pak_karto`, `juru_kunci`, `lumbung`, `tuyul_hideout`, `gong_ageng`, `batu_bintang`, `candi_seribu`, and the event strings marked above.
8. Pak Karto stands in the safe outer yard of `mt_reruntuhan`, before the courtyard fight.
9. Boss arena is at least one screen (30x17); the lesung women stand at its edge after 2.5 (from quests.md Boss link).
10. The meteorite fragment for SQ-T3 lies in the `mt_candi` front yard.
11. Secret chests: gong nook gear chest, Panah Pasopati crypt, well gear chest. Gear: Longbow (gong nook), Panah Pasopati (crypt), Amulet (well).
12. The in-game name "Candi Seribu" for the boss site (invented; the real Prambanan is never named as the arena).
13. The Arca are a stationary-shooter exception to "at most one shooter".
14. Chest items (existing ids, ASSUMED): gapura `stone_ring`, sawah `padded_tunic`, pasar `silver_bangle`, wetan `short_sword`, candi `chainmail`, gong nook `feather_charm`, well `amulet`; crypt `panah_pasopati` (Q). The quest pickups `selendang_nawang`, `gong_ageng`, `batu_bintang` have no `data/items/` file yet.
15. Map layout (Phase 5): the causeway pocket is on the east edge of `mt_gapura`; the gong nook is an open one-tile gap between two rocks (no breakable-wall mechanic); the lesung women stay in the farm yard of `mt_sawah` (an NPC at the arena edge would be interactive); the tuyul leader NPC and the inert elite stand side by side in the kiln; `mt_kuburan` has its north entry and east exit.

## Open questions
1. Should the kabut `K2` before the temples exist at all, or should the critical path be open from wetan to candi? (Kept: it follows the story flags and makes the juru kunci a stop, not a detour.)
2. Resolved (Story v2): `K3` opens on the Pamali duel, and `sc:mt_candi_gapura` makes the walk to `kg_pamali` short.
3. SQ-M3 peaceful method (crabs or green beans) and SQ-M4's gong wording stay **VERIFY**.
4. Wewe Gombel is rooted in Bukit Gombel, Semarang (**VERIFY** how much to show); the hill here is a generic graveyard hill.
5. ~~Which gear for the three secret chests~~ Done 2026-11-05: Longbow, Panah Pasopati, Amulet.
6. Names Ki Sumarto, Pak Karto, Mbah Marto: native speaker check (quests.md section 11).
7. The 3 Tuyul of `mataram_tuyul` are not placed: an encounter spawns them whatever the quest choice. Add them only if the encounter can be gated on `step:sq_m3=2` and the fight choice.
8. The arena-edge lesung women (quests.md Boss link) are not placed.

Resolved 2026-11-05: 1 (world.md already uses `mq2_9`), 2 (2.3 and 2.4 swapped: Na before the Ruins wake), 3 (Arca exempt, bestiary.md Encounters).

## Doc conflicts found (not fixed)
1. **Resolved (Story v2), was the gate flag for `mt_wetan` to `tt_kulon`:** world.md says it lifts when the Mataram boss is beaten; quests.md 2.9 says the fog lifts when the player talks to Semar. This doc uses `mq2_9` (Semar). One of the two needs a fix.
2. **Arca weakness not usable at first sight:** bestiary says Arca's weakness is Na (learned at 2.4), but the "Ruins wake" fight is step 2.3, which comes first. Teach-then-test breaks. Fix options: swap 2.3 and 2.4 (Pak Karto is in the outer yard, so it works in the graph), or accept the combo-only first fight.
3. **Shooter rule:** Encounters say at most one far role (shooter) per encounter, yet Ruins wake has 3 Arca and Temple gate has 2 Arca. The doc keeps the bestiary mixes.
4. **NPC count:** world.md asks for 3-5 NPCs per region; MQ2 plus four side quests need 9. Tatar Sunda set the precedent (10).
5. **`area_cleared:mataram_ruins`:** quests.md uses it as the encounter id (as `area_cleared:sunda_batutulis` does), not the area id `mt_reruntuhan`. This doc follows that.
6. **SQ-T3 fragment location:** quests.md says "near the temple plain" without a place.
7. **Respawn of respawn:** SQ-M2 and SQ-M4 unlock at step 2.2 (Ki Sumarto in `mt_pasar`), SQ-M1 and SQ-M3 at 2.1 (the petilasan in `mt_sawah`). The pande besi and Nawang Wulan can be met before the dalang; no conflict, just noted.
