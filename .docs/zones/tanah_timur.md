# Tanah Timur (region id `tanah_timur`), Act 4 (Story v5)

Region graph on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5). Area id prefix: `tt_`. Sources: [world.md](../world.md) (Technical frame, World structure, Tanah Timur, Checkpoints, Points of interest), [bestiary.md](../bestiary.md) (Zone 3, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ3 of Story v5 with 22 steps 3.1–3.22, Tanah Timur side quests SQ-T1..T4, SQ-C2..C3, 3.4, 7.5), [story.md](../story.md) (Pacing, Act IV), [tatar_sunda.md](tatar_sunda.md) (format). Change the layout here first, then in code.

Story v4/v4b/v4c additions (2026-11-06): the **arrival slice** (the smiths' street and Ratna), the **K4 Buto Ijo Hunt** (clues `seeds`, `needle_case`, `salt_terasi`, memory `k4_timun_mas`), the **K5 Keris Hunt** (clues `scabbard`, `forge_records`, `forge_stone`, memory `k5_forge`), **LC4** (Laras chapter), **H4 and K6** (`hunter_mask_4`, `mask_joined`, memories `h4`, `k6_servant`), plus a coastal link `tt_pesisir` > `tt_pasir` (Pacing rule 5). Names (v5): the widow is Mbok Srini (`mbok_srini`), the smith's daughter is Ratna (`timur_daughter`). The memory scenes are in "Memory scenes" below. Side stories v4d additions (2026-11-06; [quests.md](../quests.md) 5): clues, givers, arenas and memories for SQ-T1 (`t1_claw_marks`, `t1_sodo`, `sq_t1_klething`, the river crossing with `yuyu_kangkang`, peaceful area `t1_crossing_dry`) and SQ-T2 (`t2_burn_trail`, `t2_campfire`, `sq_t2_herder`, `t2_herder`, the spring arena with `banaspati_elite`), plus the Companion clue `c3_road_mark` (C3, fragment 2, in `tt_pasir`); SQ-T3 and SQ-T4 were checked against their cards and stand as written. The placements are in "Side stories v4d spots" after the side-quest table; the herder npc id is now `t2_herder` (was `timur_herder`). **Puzzle convention (ASSUMED):** a puzzle is a `trigger.tscn` with `trigger_id` `puzzle_<id>`; a gating puzzle sets `flag:puzzle_<id>` and a `kabut.tscn` with that flag lifts. Miniboss pieces are encounters or spots whose enemy carries `unique_id` and elite stats (HP x4, Ilmu x4, **TUNE**); setpieces are encounters with a scripted frame.

Regional character: **Mpu Wirasana** (the smith at the forge in `tt_beringin`). Ally: **Hariang Banga**, who shows you the road east in an optional camp talk at `timur_2`. No new glyphs: you learn to break curse marks. The act ends in an aftermath where his riders carry you home.

**Look and landmark.** Dry gold savanna, a dry riverbed and a narrow canyon, a banyan grove with old shrine ruins and a forge, and a pale sea-sand plain under a ridge. The Bromo/Tengger landscape is scenery only (no quest, no mechanic, no enemy event). The landmark is **Candi Gandring**, the boss site (`tt_candi`): a tall stepped shrine with a giant banyan crown and a thin keris-blade spire, always drawn as a dark silhouette on the east horizon. It shows from the first screen of `tt_kulon` (behind a haze), stands clearer over the savanna in `tt_sabana`, sits above the canyon wall in `tt_kali`, and fills the sky over `tt_pasir`. Tone stays warm and cartoonish: the wraith is spooky but sad, the dead are cheerful ghosts, nothing is lost on death.

## Areas
Sizes: 1 screen = 30x17 tiles. 2x2 = 60x34, 3x2 = 90x34, 3x3 = 90x51. Total 8 areas, 43 screens.

| id | screens / tiles | look | purpose | contents |
|----|-----------------|------|---------|----------|
| `tt_kulon` | 2x2 / 60x34 | Burnt-gold grass, a broken stone gate, Mataram kabut on the west edge | Entry, gentle first fights, first view of the landmark | Spawn `from_mt_wetan`. E `timur_kulon` (west half). E `timur_gerbang` at the ruined gate (east end, leads to `tt_sabana`). Kabut `K1` at the west exit. Landmark silhouette on the east horizon. **Smiths' street** along the road (art): Ratna (`timur_daughter`) (3.1, codex pamor), clue `doorpost_mark` (3.1), a small chest in the north-east hollow. No petilasan. |
| `tt_sabana` | 3x3 / 90x51 | Open savanna, termite mounds, acacia, a dry pond, a wooden back-road door in the west wall | Hub of the region. Petilasan, side-quest givers, door to Mataram | Petilasan `timur_1` (west-centre, 6 tiles from the kulon link). E `timur_embers` (open centre). Herder `t2_herder` (SQ-T2 giver) near `timur_1`. Secret chest `chest_tt_sabana` in a mound ring (south-west). Kuda kepang pickup `kuda_kepang_1`. Burn-trail path (SQ-T2) to the south, ends at `tt_pesisir`. Gate `sc:mt_tt` in the west wall (north end) to `mt_tegal`. Gate `sc:tt_pasir` in the east wall (north end). Exits: kulon (W), kali (N), beringin (E), pesisir (S). |
| `tt_kali` | 3x2 / 90x34 | West half: dry riverbed with rocks and one trickle channel. East half: a narrow canyon with red walls | Teach Kemamang and Keris Hantu, two NPCs, the long way to Buto Ijo | E `timur_wisps` (riverbed, west half). E `timur_ngarai` (canyon, east half, straight 12-tile lanes). Mbok Srini `mbok_srini` at her hut (middle, between the two halves). Klething Kuning `klething_kuning` at the river crossing (riverbed) with elite Yuyu Kangkang `yuyu_kangkang` (SQ-T1). Kuda kepang pickup `kuda_kepang_2` (riverbed). Clues `seeds`, `needle_case`, `salt_terasi` around Mbok Srini's hut (3.5, journal notes only; `salt_terasi` no longer opens the K4 memory), Buto Ambush #2 `buto_ambush_2` (3.6). Exits: sabana (S-W), ladang (E). |
| `tt_beringin` | 3x2 / 90x34 | Giant banyan grove, hanging roots, cracked shrine ruins, a forge under a banyan, a troupe camp | Empu forge, codex ruin, performance, drop to the coast | Mpu Wirasana `timur_empu` at the forge. Practice marks (3 stakes) in the forge yard. Kuda lumping leader `kepang_leader` at the camp and stage `kepang_stage`. (The old `sodo_lanang` pickup is dropped in v4d: the sodo lanang is in Klething Kuning's bundle, clue `t1_sodo` in `tt_kali`.) Codex ruin `codex_ruin` (2 inscribed stones, 1 statue plinth). Secret chest `chest_tt_beringin` in a hollow banyan (north-east). Drop ledge `drop_pesisir` (south rim). Gate `sc:tt_ladang` (north wall, seen from the inside as a root-choked door). Trigger `timur_marks` at the village mouth (3.3), forge-mark puzzle and practice stakes (3.4), clue `banyan_altar` at the ancient banyan with Buto Ambush #3 `buto_ambush_3` (3.7, opens K4), forge defence `timur_forge_defense` (3.11), clues `scabbard` and `forge_records` and the old anvil `forge_stone` in Wirasana's vault (3.12-3.13, opens K5). Exits: sabana (W). No fight room: a quiet area. |
| `tt_ladang` | 2x2 / 60x34 | Dry field of dead cucumber vines, a dark lair of hanging bones and a lamp | Buto Ijo's field and miniboss arena | E `timur_ladang` (field, west half). Root-gate `sc:tt_ladang` (south wall of the field, opens from this side). Miniboss `buto_ijo` in the arena (east half, 28x16). Kabut `K2` at the east exit, lifts when Buto Ijo is beaten. Optional chest `chest_tt_ladang` in the north-west nook (rule 7). Exits: kali (W), beringin (sc), pasir (E, kabut). |
| `tt_pasir` | 3x2 / 90x34 | Pale sea-sand plain, a wide crater rim, black stones, the landmark huge in the east | The last fight, petilasan 2, then the boss gate | E `timur_pasir` (centre, two waves). Petilasan `timur_2` (east end, in a sand alcove, no enemy inside). Hariang Banga stands in the alcove after `timur_2` (camp talk). Stone sentries (decor) at the candi gate. Gate `sc:tt_pasir` (south-west wall) to sabana. Overlook with the Tengger sign (scenery, optional text in the codex ruin). The gatekeeper miniboss `timur_penjaga` and the south-coast link from `tt_pesisir` (3.15), the dune puzzle (3.15), waymarkers puzzle `pasir_waymarkers` (3.15), clue `lc4_lontar` in the alcove (3.17). Exits: ladang (W, kabut), candi (E), sabana (sc), pesisir (S, kabut `K4`). |
| `tt_candi` | 2x2 / 60x34 | Banyan courtyard in front of Candi Gandring, seven curse stakes | Boss arena | Boss `keris_gandring` (Mpu Gandring's Keris, wakes after the `shrine_sight` beat), then the Nameless Hunter. 7 curse-mark stakes at the arena edge. Five beat spots (see Quest steps and markers). Mpu Wirasana stands in the court for the `keris` beat. Entered only from the `timur_2` alcove side of `tt_pasir`. Clues `hunter_mask_4` and `mask_joined` (3.21); `forge_stone` is no longer here (it is in Wirasana's vault in `tt_beringin`). Exits: pasir (W) only. |
| `tt_pesisir` | 2x2 / 60x34 | Dunes, a dry shore, driftwood, a pale sea fog on the south edge | Main-path coast since v3.1 (step 3.14, the Hunter's ash trail), with an elite and a secret, and the later back door to Segara Kidul | E `timur_pesisir`. Elite Banaspati `banaspati_elite` (SQ-T2). Kuda kepang pickup `kuda_kepang_3`. Secret chest `chest_tt_pesisir` (wreck in the dunes, east). Kabut `K3` at the south edge to `sk_karang` (opens on `quest:mq4=done`, flag `mq4_9`; a back route only). Drop landing from `tt_beringin`. Clue `ash_trail` and the second fight `timur_dune` (3.14); new east pocket to `tt_pasir` (kabut `K4`, flag `mq3_h4`). Exits: sabana (N), pasir (E, kabut `K4`), sk_karang (S, kabut). |

Quest NPCs: 6 (Mpu Wirasana, Mbok Srini, Klething Kuning, the herder, the kuda lumping leader, Hariang Banga at `timur_2`). Elites: Yuyu Kangkang, Banaspati elite. Miniboss: Buto Ijo. Secrets: 3 chests. Codex: 1 location (`tt_beringin`). Petilasans: `timur_1` (`tt_sabana`), `timur_2` (`tt_pasir`).

## Region graph
`==K==` kabut, `--` link, `~~sc~~` shortcut gate (opens from the tagged side), `--v` drop. Flags: `K1` mq2_9 (Hariang Banga beaten, 2.13), `K2` mq3_4 (Buto Ijo, 3.9), `K3` mq4_9 (`quest:mq4=done`, a back route only), `K4` mq3_h4 (the practice marks, scabbard and records done, 3.12; opens the coast road to `tt_pasir`).
```
 row N:               tt_kali ------ tt_ladang ==K2== tt_pasir[P2] ---- tt_candi (boss)
                        |              ^   .             .
                        |       sc:tt_ladang .        sc:tt_pasir
                        |              .   .             .
 row M: mt_wetan ==K1== tt_kulon ---- tt_sabana[P1] ---- tt_beringin
                                      |  .  (sc:mt_tt to mt_tegal)   |
                                      |                              v drop
 row S:                            tt_pesisir <----------------------'
                                      ||K3
                                  sk_karang
```
(`tt_kali`, `tt_ladang` and `tt_pasir` sit north of the middle row; dotted lines are shortcut gates, drawn in the edge list below.) Edge list (the link table is the source of truth):
```
mt_wetan ==K1== tt_kulon -- tt_sabana[P1] -- tt_kali -- tt_ladang ==K2== tt_pasir[P2] -- tt_candi
tt_sabana -- tt_beringin            tt_sabana -- tt_pesisir ==K3== sk_karang
tt_sabana ~sc:mt_tt~ mt_tegal       (opens from sabana)
tt_ladang ~sc:tt_ladang~ tt_beringin (opens from ladang)
tt_pasir  ~sc:tt_pasir~  tt_sabana   (opens from pasir)
tt_beringin --v--> tt_pesisir        (drop, one way)
tt_pesisir ==K4== tt_pasir          (3.14-3.15, flag mq3_h4: the coast road into the Sea of Sand)
```
Grid for the builder (cols W to E, rows N to S):
```
            c0         c1          c2            c3        c4
row N:                tt_kali --- tt_ladang ==== tt_pasir -- tt_candi
row M:   tt_kulon --- tt_sabana -- tt_beringin
row S:                tt_pesisir
```

## Link table
| # | From | To | Kind | Gate flag | Spawn ids |
|---|------|----|------|-----------|-----------|
| 1 | `mt_wetan` | `tt_kulon` | link, kabut `K1` | `mq2_9` (set by MQ2 2.13, the Hariang Banga duel) | `from_mt_wetan` (in kulon), `from_tt_kulon` (in mt_wetan) |
| 2 | `tt_kulon` | `tt_sabana` | link | none | `from_tt_kulon` (in sabana), `from_tt_sabana` (in kulon) |
| 3 | `tt_sabana` | `tt_kali` | link | none | `from_tt_sabana` (kali), `from_tt_kali` (sabana) |
| 4 | `tt_sabana` | `tt_beringin` | link | none | `from_tt_sabana` (beringin), `from_tt_beringin` (sabana) |
| 5 | `tt_sabana` | `tt_pesisir` | link | none | `from_tt_sabana` (pesisir), `from_tt_pesisir` (sabana) |
| 6 | `tt_kali` | `tt_ladang` | link | none | `from_tt_kali` (ladang), `from_tt_ladang` (kali) |
| 7 | `tt_ladang` | `tt_pasir` | link, kabut `K2` | `mq3_4` (Buto Ijo beaten, step 3.9) | `from_tt_ladang` (pasir), `from_tt_pasir` (ladang) |
| 8 | `tt_pasir` | `tt_candi` | link (starts at the `timur_2` alcove) | none | `from_tt_pasir` (candi), `from_tt_candi` (pasir) |
| 9 | `tt_sabana` | `mt_tegal` | shortcut `sc:mt_tt` | `sc:mt_tt` (opened from sabana) | `from_mt_tegal` (sabana), `from_tt_sabana` (mt_tegal) |
| 10 | `tt_ladang` | `tt_beringin` | shortcut `sc:tt_ladang` | `sc:tt_ladang` (opened from ladang) | `from_tt_beringin` (ladang), `from_tt_ladang` (beringin) |
| 11 | `tt_pasir` | `tt_sabana` | shortcut `sc:tt_pasir` | `sc:tt_pasir` (opened from pasir) | `from_tt_pasir` (sabana), `from_tt_sabana` (pasir; second spawn on the shortcut side) |
| 12 | `tt_beringin` | `tt_pesisir` | drop | none | `from_tt_beringin` (pesisir); nothing leads back up the ledge |
| 14 | `tt_pesisir` | `tt_pasir` | link, kabut `K4` (east pocket of pesisir to the south corridor of pasir; the coast leads into the Sea of Sand, so the walk after 3.14 is forward only) | `mq3_h4` (set when step 3.12 completes) | `from_tt_pesisir` (in pasir), `from_tt_pasir` (in pesisir) |
| 13 | `tt_pesisir` | `sk_karang` | link, kabut `K3` | `mq4_9` (kabut flag, set when `quest:mq4=done`; a back route only, Act V starts from Desa Purwa; no longer `mq3_8`) | `from_tt_pesisir` (sk_karang), `from_sk_karang` (pesisir) |

## Shortcut table
| Id | Gate area | Open side | Leads to | Back to which petilasan |
|----|-----------|-----------|----------|-------------------------|
| `sc:mt_tt` | `tt_sabana` (west wall, north end) | `tt_sabana` only (a latched back-road door) | `mt_tegal` in Mataram | `timur_1` (the gate is 14 tiles from it); the return walk to Semar and the SQ-T3 errand |
| `sc:tt_ladang` | `tt_ladang` (south wall of the field) | `tt_ladang` only (a root-choked door that the player pulls open) | `tt_beringin` (forge), one link from `tt_sabana` | `timur_1` via `tt_beringin` then `tt_sabana`. Later trips timur_1 to Buto skip `tt_kali` entirely |
| `sc:tt_pasir` | `tt_pasir` (south-west wall) | `tt_pasir` only (a sand-choked slab) | `tt_sabana` | `timur_1` (directly) |

## Loops, drop, paths
**Loops** (first trip around is long, later trips are short):
- **A:** `tt_sabana` -> `tt_kali` -> `tt_ladang` -> (`sc:tt_ladang`) -> `tt_beringin` -> `tt_sabana`. Closed by `sc:tt_ladang`.
- **B:** `tt_sabana` -> `tt_kali` -> `tt_ladang` -> `tt_pasir` -> (`sc:tt_pasir`) -> `tt_sabana`. Closed by `sc:tt_pasir`.
- **C:** `tt_sabana` -> `tt_beringin` -> (drop) -> `tt_pesisir` -> `tt_sabana`. Closed by the drop.

**Coast link (v4c, Pacing rule 5):** `tt_pesisir` east pocket > `tt_pasir` south corridor, kabut `K4` (`mq3_h4`). After 3.13 the drop lands in pesisir, 3.14-3.15 run forward through the dunes and the Sea of Sand without the old sabana > beringin > ladang > pasir walk (four areas of nothing).

**Drop:** `drop_pesisir`, `tt_beringin` south rim to `tt_pesisir` north dunes (a dune slide). No exit leads up. The player is never stuck: `tt_pesisir` has a normal link back to `tt_sabana`.

**Critical path (MQ3 Story v5 order, 8 of 8 areas):** `mt_wetan` -> `tt_kulon` (3.1: Ratna on the smiths' street, E `timur_kulon`, clue `doorpost_mark`, E `timur_gerbang`; 3.2: Buto Ambush #1 `buto_ambush_1`) -> `tt_sabana` (petilasan `timur_1`, sets `mq3_1`; E `timur_embers` on the way) -> `tt_beringin` (3.3: `timur_marks`, the empu; 3.4: the forge-mark puzzle and the practice stakes; opens SQ-T3) -> `tt_sabana` -> `tt_kali` (3.5: E `timur_wisps` first, Mbok Srini, clues `seeds`, `needle_case`, `salt_terasi`; E `timur_ngarai` on the way; 3.6: Buto Ambush #2 `buto_ambush_2`) -> `tt_beringin` (3.7: clue `banyan_altar`, Buto Ambush #3 `buto_ambush_3`; 3.8: memory `k4_timun_mas`, opened from `banyan_altar`) -> `tt_ladang` (open `sc:tt_ladang`, 3.9 Buto Ijo; 3.10: clue `ladang_stake`, E `timur_ladang_stakes`) -> `sc:tt_ladang` -> `tt_beringin` (3.11: `timur_forge_defense`; 3.12: the vault clues `scabbard` and `forge_records`, sets `mq3_h4`; 3.13: `forge_stone` and memory `k5_forge`) -> `drop_pesisir` -> `tt_pesisir` (3.14: E `timur_pesisir`, E `timur_dune`, clue `ash_trail`) -> `K4` -> `tt_pasir` (3.15: the gatekeeper miniboss, the waymarkers puzzle `pasir_waymarkers`, E `timur_pasir`, beat `pasir_sight`; 3.16: `timur_2`, the camp talk; 3.17: chapter `lc4`) -> `tt_candi` (3.18: `candi_inner_sanctum` and beat `shrine_sight`; 3.19: the keris; 3.20: beat `keris`; 3.21: `hunter_mask_4`, memory `h4`, `mask_joined`, memory `k6_servant`, beat `hunter_shrine`; 3.22: the Hunter, beat `hunter_name`, then `goto` Desa Purwa). The walk after 3.14 needs no backtracking: the coast leads into the sand (K4). `sc:tt_pasir` still shortens every later trip. There is no walk home to Semar: the riders carry you to `desa_purwa` (`goto`, spawn `from_riders`), and the Gua Kala gate in Desa Purwa opens on `quest:mq4=done`, not on `mq3_8`.

**Rule 7 (every critical-path area holds an optional find).** `tt_kulon`: the north-east hollow chest `chest_tt_kulon` (new). `tt_sabana`: mound-ring secret, SQ-T2/T4 hooks. `tt_kali`: Klething Kuning (SQ-T1), kuda kepang 2. `tt_beringin`: hollow banyan chest, codex ruin, kepang stage. `tt_ladang`: `chest_tt_ladang` (new). `tt_pasir`: Tengger overlook text. `tt_candi`: none needed (the boss court; the finale). `tt_pesisir`: wreck chest, elite Banaspati (SQ-T2).

**Optional areas:** none since v3.1. `tt_pesisir` (Loop C) is step 3.14; its elite Banaspati, secret chest and kuda kepang stay optional, and its south link to Segara Kidul opens only after MQ4 is done (`mq4_9`, a back route). Optional rooms inside areas: the sabana mound ring (secret), the hollow banyan (secret), the codex ruin, the performance stage.

## Encounters
Trigger rects are centered on the spot, as in Tatar Sunda. Wave 2 (pasir only) rises from marked stone circles with a 0.5 s warning, in view of the player.

| area_id | area | room | size | waves | Tests | clean answer |
|---------|------|------|------|-------|-------|--------------|
| `timur_kulon` | `tt_kulon` | west half field | 20x11 | W1: 2 Banaspati | Burn, first Banaspati (teach) | Ga Ward (snuffs) |
| `timur_gerbang` | `tt_kulon` | ruined gate | 18x10 | W1: Prajurit Terkutuk, 2 Banaspati | Old guard | Ra Summon (turns shield away); Ward on Banaspati |
| `timur_embers` | `tt_sabana` | open centre | 26x14 | W1: 4 Banaspati | Embers | Ga Ward |
| `timur_wisps` | `tt_kali` | dry riverbed with rocks | 28x12 | W1: 2 Kemamang (on rock ledges) | Wisps | Na Dash-strike; melee cuts wisps |
| `timur_ngarai` | `tt_kali` | canyon | 30x9, lanes 12 | W1: 3 Keris Hantu | Flying blades | Nga Bind; Ha Heal cures Curse |
| `timur_ladang` | `tt_ladang` | dead field | 30x14 | W1: Prajurit Terkutuk, Keris Hantu, Banaspati, Kemamang | Savanna patrol (priorities) | Ra Summon on Prajurit, Bind on Keris Hantu |
| `timur_pesisir` | `tt_pesisir` | dune hollow | 20x11 | W1: Prajurit Terkutuk, 2 Banaspati | Old guard repeat (step 3.14) | Ra Summon |
| `timur_dune` | `tt_pesisir` | north dunes | 16x9 | W1: 3 Banaspati | Second fight of 3.14 (v4c) | Ga Ward |
| `timur_penjaga` | `tt_pasir` | south corridor mouth | 10x6 | **Miniboss**, W1: elite Prajurit Terkutuk `timur_penjaga` (HP x4, **TUNE**), no escorts | The gatekeeper of the Sea of Sand (3.15, v4c) | Ra Summon turns his shield, Dash-strike behind it |
| `timur_pasir` | `tt_pasir` | sand plain before `timur_2` | 36x16 | W1: 2 Prajurit Terkutuk, Banaspati, Kemamang ; W2: 2 Keris Hantu | Before the keris (two-tank exception) | Ra Summon, Na Dash-strike, Bind on wave 2, Heal for Curse |
| `buto_ambush_1` | `tt_kulon` | western savanna | 16x9 | W1: Buto Ijo, 2 Banaspati, Prajurit Terkutuk (Buto Ijo's rampage is the setpiece; the area clears when he retreats at 80% HP) | Stalking Ambush #1 (3.2) | Ga Ward, fire-wards |
| `buto_ambush_2` | `tt_kali` | dry riverbed | 16x9 | W1: Buto Ijo, 2 Kemamang, Prajurit Terkutuk (Buto retreats at 65% HP) | Stalking Ambush #2 (3.6) | Na Dash-strike; the bramble-seed pouch slows him |
| `buto_ambush_3` | `tt_beringin` | ancient banyan | 16x9 | W1: Buto Ijo, Prajurit Terkutuk, 2 Keris Hantu (Buto retreats at 50% HP) | Stalking Ambush #3 (3.7) | Nga Bind; hold him off while the pouches are laid |
| `timur_ladang_stakes` | `tt_ladang` | dry field | 15x9 | W1: Keris Hantu, Banaspati | Curse stakes (3.10) | Bind, Ward |
| `timur_forge_defense` | `tt_beringin` | forge quarter | 15x9 | W1: 2 Keris Hantu, Prajurit Terkutuk (see the legend) | Forge defence (3.11) | Nga Bind |

10 encounters (6-10), plus the Buto Ijo miniboss room (the five step-bound fights in the last rows, added in v5, are counted separately: they are quest setpieces with their own tuning). **Step-bound** (v5): `timur_gerbang` (3.1), `buto_ambush_1..3` (3.2, 3.6, 3.7), `timur_ladang_stakes` (3.10), `timur_forge_defense` (3.11), `timur_pesisir` (3.14) and `timur_pasir` (3.15). Fights without an own step event: `timur_dune` (3.14), `timur_penjaga` (3.15 miniboss). **No longer steps**, kept as roaming or fixed fights: `timur_kulon`, `timur_embers`, `timur_wisps` (a deed before 3.5: Mbok Srini's entry needs `area_cleared:timur_wisps`, **ASSUMED**), `timur_ngarai`, `timur_ladang`. There is no `timur_candi` encounter: `tt_candi` holds the two bosses only (Doc conflicts). Extra fights: Yuyu Kangkang (elite charger, riverbed crossing, 12-tile lane), Banaspati elite (SQ-T2, `tt_pesisir` east dunes), Buto Ijo (miniboss), Keris (boss). Tank rule: gerbang, ladang, pesisir have 1 tank, pasir has 2 (allowed before the boss). Shooters: ladang 1, pasir 1, wisps 2 (a pure shooter room, no tank, per bestiary). Waves: pasir has 2, all others 1.

**Main-path kills (balance.md 2.1 target ~40):** about 40 before after v4c (v3.1 below plus dune 3, penjaga 1+2 escorts counted as the gatekeeper, the ladang chest none; **TUNE**, recount with `tests/zone_build_test.gd`); v3.1 breakdown: 27 before (fixed encounters only: kulon 2, gerbang 3, embers 4, wisps 2, ngarai 3, ladang 4, pesisir 3, pasir 6; no loose enemies on the path; bosses, Yuyu and the Banaspati elite not counted; `timur_pesisir` joined the count when it became step 3.14, **TUNE**), 43 after 16 loose roaming-pack enemies (kulon 2 Banaspati, sabana 3, beringin 3, kali 2 Kemamang, ladang 3, pasir 3; Prajurit at most 1 per pack, Kemamang only after `timur_wisps`, Keris Hantu only in ladang and pasir, after `timur_ngarai`).

First appearances (teach, then test):
| Enemy | First seen | Player glyphs there | Weakness usable |
|-------|-----------|--------------------|-----------------|
| Banaspati | `timur_kulon` (2, alone) | Ka, Ga, Nga, Ca (Sunda), Ha, Na, Ra | Ward, yes |
| Prajurit Terkutuk | `timur_gerbang` (1 with 2 known Banaspati) | same | Summon, yes (newest glyph with a weakness) |
| Kemamang | `timur_wisps` (2 alone, rocks for cover) | same | Dash-strike, yes |
| Keris Hantu | `timur_ngarai` (3 alone, after wisps) | same | Bind, yes |

`timur_pesisir` (Prajurit with 2 known Banaspati) is the step-3.14 repeat fight; Ra Summon is known by then. Order is guaranteed: `timur_wisps` and `timur_ngarai` are in `tt_kali`, which is only reachable from `tt_sabana` before `sc:tt_ladang` is opened; `timur_ladang` is only reachable through `tt_kali` the first time. `timur_pesisir` and the sabana fights use only Banaspati and Prajurit.

## Buto Ijo (miniboss room)
Arena in `tt_ladang`, east half, 28x16, with the lamp-lit lair. Four phases, one pouch per phase (cucumber seeds: bramble field, needles: bamboo forest, salt: saltwater, terasi: mud). **VERIFY** the legend's items (bestiary.md). Mbok Srini hands over the pouches in `tt_kali` before the fight (step 3.5; the river wisps `timur_wisps` fall first). Timun Mas runs off as in the legend. HP 3400. Kabut `K2` lifts on the death (step 3.9, `mq3_4`), the field gate `sc:tt_ladang` must be opened before the arena to give a short retry path.

## Quest steps and markers
Marker form `{zone: "tanah_timur", id: ...}`. Ids from quests.md marked (Q); others are **ASSUMED**.

### Main quest MQ3
Step numbers are the MQ3 Story v5 ones (22 steps 3.1–3.22, [quests.md](../quests.md) 4, `Play` column). Every piece has a place: `travel` = crossing that area with its fights and one find; `fight` = one encounter; `clue`, `puzzle`, `miniboss`, `setpiece`, `memory`, `chapter` as named.

| Step | Pieces (Play) | Marker id | Area | Event string |
|------|---------------|-----------|------|--------------|
| (entry) | | `timur_edge` | `tt_kulon` | `zone_entered:tanah_timur` |
| 3.1 Arrival: meet Ratna (`timur_daughter`) and rest at `timur_1` | `travel, talk x2, fight` | `timur_daughter` (Q), `timur_kulon`, `timur_gerbang` (Q), `timur_1` (Q) | `tt_kulon`, `tt_sabana` | `talked_to:timur_daughter`, sets `mq3_a1`; then `petilasan_activated:timur_1` (Q), sets `mq3_1` |
| 3.2 Stalking Ambush #1: survive Buto Ijo's sudden rampage across the western savanna | `setpiece, miniboss, beat` | `buto_ambush_1` (Q) | `tt_kulon` | `area_cleared:buto_ambush_1`, sets `mq3_b1` |
| 3.3 follow the burning red curse marks to Mpu Wirasana's forge | `travel, clue, talk` | `timur_marks` (Q), `timur_empu` (Q) | `tt_beringin` | `area_entered:timur_marks`, sets `mq3_h1`; then `talked_to:timur_empu` (Q), sets `mq3_2` |
| 3.4 learn Mpu Wirasana's technique to extinguish blood-curse stakes | `lesson, puzzle, fight` | `timur_praktik_mark` (two marks), `puzzle_timur_forgemark` | `tt_beringin` (forge yard stakes `S`) | `area_entered:timur_praktik_mark` x2, sets `flag:clue_practice_marks` |
| 3.5 reach Mbok Srini's smashed hut and examine the spilled relics | `travel, talk, clue x3` | `mbok_srini` (Q), `seeds`, `needle_case`, `salt_terasi` | `tt_kali` (riverbed, hut; three journal-note clues, none opens a memory) | `talked_to:mbok_srini` (Q), sets `mq3_3`; then `all`: `clue_examined:seeds`, `clue_examined:needle_case`, `clue_examined:salt_terasi`; sets `mq3_h2` |
| 3.6 Stalking Ambush #2: test the bramble-seed pouch to slow Buto Ijo's charge | `setpiece, puzzle, fight, beat` | `buto_ambush_2` (Q) | `tt_kali` | `area_cleared:buto_ambush_2`, sets `mq3_b2` |
| 3.7 Stalking Ambush #3: consecrate the needle, salt, and terasi pouches at the ancient banyan | `travel, clue, puzzle, miniboss` | `banyan_altar` (ASSUMED), `buto_ambush_3` (Q) | `tt_beringin` (banyan, `V` clue beside the ambush `H`) | `area_cleared:buto_ambush_3`, sets `mq3_b3`; the clue `banyan_altar` (`memory_id: k4_timun_mas`) is examined after it |
| 3.8 K4 Memory: Timun Mas's flight | `memory, beat` | `banyan_altar` (`memory_id: k4_timun_mas`) | `tt_beringin` and `zones/kelir/k4_timun_mas.tscn` | `memory_done:k4_timun_mas`, sets `mq3_h3` |
| 3.9 lure Buto Ijo into his canyon lair and defeat him | `boss, beat, talk` | `buto_ijo` (Q) | `tt_ladang` | `boss_defeated:buto_ijo` (Q); sets `mq3_4` (opens `K2`) |
| 3.10 return to `tt_ladang` as the waking Keris ignites curse stakes across the dry fields | `travel, clue, fight x2, puzzle` | `ladang_stake` (ASSUMED), `timur_ladang_stakes` (Q) | `tt_ladang` | `area_cleared:timur_ladang_stakes`, sets `mq3_5a` |
| 3.11 help Mpu Wirasana and Ratna defend the forge quarter from flying Keris Hantu packs | `fight, talk, fight, miniboss` | `timur_forge_defense` (Q) | `tt_beringin` | `area_cleared:timur_forge_defense`, sets `mq3_5b` |
| 3.12 inspect the broken scabbard and seven-generation forge ledger | `clue x2, puzzle, talk` | `scabbard` (Q), `forge_records` (Q) | `tt_beringin` (forge interior) | `all`: `clue_examined:scabbard`, `clue_examined:forge_records`; sets `mq3_h4` (opens `K4`) |
| 3.13 K5 Memory: night of Mpu Gandring's apprentice | `memory, beat` | `forge_stone` (Q; `memory_id: k5_forge`, cond `flag:mq3_h4`) | `tt_beringin` (Wirasana's vault) and `zones/kelir/k5_forge.tscn` | `memory_done:k5_forge`, sets `mq3_h5` |
| 3.14 follow the Hunter's ash-trail down the volcanic coast (`tt_pesisir`) | `travel, fight x2, talk` | `timur_pesisir` (Q), `timur_dune`, `ash_trail` | `tt_pesisir` | `area_cleared:timur_pesisir`, sets `mq3_5c` |
| 3.15 cross the Sea of Sand (`tt_pasir`), using the ancient stone waymarkers | `travel, puzzle, fight, miniboss` | `timur_pasir` (Q), `pasir_waymarkers` (Q; clue and puzzle share the id, staged by the trigger `J`), `timur_penjaga` | `tt_pasir` | `area_cleared:timur_pasir`; then `puzzle_solved:pasir_waymarkers`, sets `mq3_5d` |
| 3.16 rest at the desert petilasan (`timur_2`) and speak with Hariang Banga | `talk x2, clue, fight` | `timur_2` (Q), `hariang_banga` | `tt_pasir` (alcove) | `petilasan_activated:timur_2` (Q); sets `mq3_6` |
| 3.17 LC4 Cross-Time Chapter: Laras across the dunes & shrine | `chapter, puzzle, beat` | `lc4_lontar` (`memory_id: lc4`) | `tt_pasir` (alcove) and `zones/kelir/lc4.tscn` | `memory_done:lc4`, sets `mq3_lc`, `laras_key:sand_tunnel`, `laras_sabotage:keris_seventh_stake` |
| 3.18 use Laras's wind-tunnel shortcut to breach `tt_candi` | `travel, fight x2, beat` | `candi_inner_sanctum` (Q) | `tt_candi` | `area_entered:candi_inner_sanctum`, sets `mq3_6b` (plays beat `shrine_sight`) |
| 3.19 lay the awakened Keris Mpu Gandring to rest | `boss, beat` | `keris_gandring` (Q) | `tt_candi` (`B`, cond `flag:beat_shrine_sight`) | `boss_defeated:keris_gandring` (Q); sets `mq3_7` (Seal 4) |
| 3.20 decide the fate of Mpu Gandring's blade (Choice 4) | `talk, beat, puzzle` | `beat_keris` | `tt_candi` (`K`, `W`) | `flag:beat_keris` (`choice_reforge` / `choice_sink`) |
| 3.21 claim the fourth mask fragment (`H4`) and join the full mask (`K6`) | `clue, memory x2, beat` | `hunter_mask_4` (Q; `memory_id: h4`), `mask_joined` (Q; `memory_id: k6_servant`) | `tt_candi` and `zones/kelir/h4.tscn`, `zones/kelir/k6_servant.tscn` | `memory_done:h4`, sets `mq3_h7`; then `memory_done:k6_servant`, sets `mq3_h6` (plays beat `hunter_shrine`, `restore`) |
| 3.22 defeat the Nameless Hunter | `boss, setpiece, beat` | `nameless_hunter` (Q) | `tt_candi` (`H`, cond `flag:mq3_h6`) | `boss_defeated:nameless_hunter` (Q); sets `mq3_8` (beat `hunter_name` starts `mq4` and `goto:desa_purwa:from_riders`) |

**Beat spots.** Beats are played by the GameUI listener from `beats.tres` ([quests.md](../quests.md) section 4), not by a map node. Each trigger spot below only stages the beat (**ASSUMED**); the `zone:` part of each `if` is in quests.md and `zone:` is not built yet.

| Beat | `if` | Area | Spot | Notes |
|------|------|------|------|-------|
| `marks_hook` | `flag:mq3_h1`'s area `timur_marks` (`!flag:beat_marks_hook`, `flag:mq3_h1`) | `tt_beringin` | trigger `timur_marks` (see the legend) | K5 hook: the red curse marks on the doorposts. `do: flag:beat_marks_hook` |
| `widow_hook` | not a beat: part of Mbok Srini's talk (3.3) | `tt_kali` | NPC `mbok_srini` in the hut | K4 hook: hut smashed open, footprints as long as you are tall |
| `pasir_sight` | optional, ASSUMED | `tt_pasir` | trigger `beat_pasir_sight` | The `beat` piece of 3.15: Candi Gandring comes into view across the sand, Semar's note on the road; no quest effect |
| LC4 (was `laras_4`) | none: the chapter is step 3.17 | `tt_pasir` | clue `lc4_lontar` in the alcove beside `timur_2` | She cannot remember your face; one letter is left on her half, *Ka*. Replaces the retired v4 Laras beat |
| camp talk `camp_timur` | NPC entry, cond `flag:mq3_6`, `"quiet": true` | `tt_pasir` | NPC `H` (83,13) `hariang_banga` in the alcove | Optional, 2-4 lines, never completes a step. Hariang Banga shows the road east. Sets `camp_timur`. Placed at `timur_2` (rule: after Buto Ijo, Pacing 6) |
| `shrine_sight` | `flag:mq3_h5`, `flag:mq3_lc`, `zone:tt_candi` | `tt_candi` | `S` (24,16), trigger `beat_shrine_sight` | The turn: Laras across the shrine, made to read the last seal. The Keris wakes. `B` has cond `flag:beat_shrine_sight`. Laras is a staged figure, not a spot |
| `keris` | `flag:mq3_7`, `zone:tt_candi` | `tt_candi` | `K` (36,19), trigger `beat_keris`; Mpu Wirasana `W` (32,19) | Choice 3. Reforge: Wirasana hands over the tamed Keris Mpu Gandring (`choice_reforge`, `give:keris_gandring`). Sink: the Batu Kali accessory (`choice_sink`, `give:batu_kali`) |
| `hunter_shrine` | `flag:mq3_h6`, `zone:tt_candi` | `tt_candi` | `R` (36,13), trigger `beat_hunter_shrine` | The restore beat between the Keris and the Hunter: `do` `restore` (health and flask charges, **ASSUMED**). `H` has cond `flag:beat_keris` |
| `hunter_name` | `quest:mq3=done`, `zone:tt_candi` | `tt_candi` | `N` (30,11), trigger `beat_hunter_name` | The aftermath: the mask cracks, *Aria Kebonan*, the Eclipse takes Laras. Hariang Banga's riders carry you home: `goto:desa_purwa:from_riders` (spawn `z` in desa_purwa.md; no exit spot needed; the riders are staged in the beat). `start:mq4`, `codex:nameless_hunter` |

Mpu Wirasana: the forge instance `timur_empu` (`tt_beringin`) teaches at 3.2. A second instance with the same `npc_id` stands in the `tt_candi` court (`W`, cond `flag:mq3_7,!flag:beat_keris`, **ASSUMED**): he came after the sound of the keris dying, so the `keris` beat can show him handing over the reforged blade. His shrine entry is a beat staging, not a talk.

### Side quests
| Quest | Step | Marker id | Area | Event string |
|-------|------|-----------|------|--------------|
| SQ-T1 (giver `klething_kuning`, unlock 3.1) | 1 talk, the ferry rope is cut | `klething_kuning` | `tt_kali` | `talked_to:klething_kuning` |
| | 2 `all`: claw marks, the sodo lanang | `t1_claw_marks`, `t1_sodo` | `tt_kali` (jetty, her bundle) | `clue_examined:t1_claw_marks`, `clue_examined:t1_sodo` |
| | 3 her memory | `t1_sodo` (`memory_id: sq_t1_klething`) | `zones/kelir/sq_t1_klething.tscn` | `memory_done:sq_t1_klething` |
| | 4a peaceful (the legend's way) | `puzzle_t1_crossing_dry` | `tt_kali` (crossing) | `area_entered:t1_crossing_dry` (she strikes the water with the sodo lanang, the river dries) |
| | 4b fight | `yuyu_kangkang` | `tt_kali` | `enemy_killed:yuyu_kangkang` |
| | 5 she crosses | `klething_kuning` | `tt_kali` | `talked_to:klething_kuning` |
| SQ-T2 (giver `t2_herder`, unlock 3.1) | 1 grass fires | `t2_herder` | `tt_sabana` | `talked_to:t2_herder` |
| | 2 `all`: burn trail, campfire | `t2_burn_trail`, `t2_campfire` | `tt_sabana` (south path), `tt_pesisir` (dune hollow) | `clue_examined:t2_burn_trail`, `clue_examined:t2_campfire` |
| | 3 the herder boy's memory | `t2_campfire` (`memory_id: sq_t2_herder`) | `zones/kelir/sq_t2_herder.tscn` | `memory_done:sq_t2_herder` |
| | 4 defeat the elite at the spring | `banaspati_elite` | `tt_pesisir` (spring arena) | `enemy_killed:banaspati_elite` |
| | 5 report | `t2_herder` | `tt_sabana` | `talked_to:t2_herder` |
| SQ-T3 (giver `timur_empu`, unlock 3.2) | 1 the empu asks | `timur_empu` | `tt_beringin` | `talked_to:timur_empu` |
| | 2 find the meteorite in Mataram | `batu_bintang` | `mt_candi` (east yard, see mataram.md) | `item_picked:batu_bintang`; walk is short via `sc:mt_tt` |
| | 3 bring it back | `timur_empu` | `tt_beringin` | `talked_to:timur_empu` (reward: Keris Luk 7) |
| SQ-T4 (giver `kepang_leader`, unlock 3.1) | 1 talk | `kepang_leader` | `tt_beringin` | `talked_to:kepang_leader` |
| | 2 find 3 kuda kepang | sparkle only (no marker) | `tt_sabana`, `tt_kali`, `tt_pesisir` | `item_picked:kuda_kepang_1` to `kuda_kepang_3` |
| | 3 return and watch | `kepang_stage` | `tt_beringin` | `talked_to:kepang_leader` then `area_entered:kepang_stage` (performance only, no trance) |
| C3 fragment 2 (Act IV) | | `c3_road_mark` | `tt_pasir` | `clue_examined:c3_road_mark`, cond `flag:mq3_6` |
| Codex | | `codex_ruin` | `tt_beringin` | `codex:keris`, `codex:mpu_gandring`, `codex:tengger_lautan_pasir` (short, factual, **VERIFY**) |

### Side stories v4d spots (2026-11-06)
Not drawn into the maps (**ASSUMED**: the builder adds them as plain spots at these coordinates, on floor tiles; `gen_zones.py` reads only the legends). SQ-T3 (empu `timur_empu` in `tt_beringin`, fragment `batu_bintang` in `mt_candi`, unlock `mq3_2`) and SQ-T4 (leader `kepang_leader`, three `kuda_kepang_*` pickups in `tt_sabana`, `tt_kali`, `tt_pesisir`, stage `kepang_stage`, unlock `mq3_1`) match their cards; the three kuda kepang sparkles play as the card's `clue x3`. Clue props follow `{clue_id, memory_id?, cond?}`; the memory id sits on the clue examined last (as `ka_strip` does, **ASSUMED**), and `cond` uses `quest:<id>=active`.

| Area | Spot | Scene and props | At | Card | Notes |
|------|------|-----------------|----|------|-------|
| `tt_kali` | `t1_claw_marks` | `clue.tscn` `{clue_id:"t1_claw_marks", cond:"quest:sq_t1=active"}` | (35,19) | SQ-T1 | Claw marks on the jetty planks beside the crossing; names the crab as Yuyu Kangkang |
| `tt_kali` | `t1_sodo` | `clue.tscn` `{clue_id:"t1_sodo", memory_id:"sq_t1_klething", cond:"quest:sq_t1=active"}` | (32,18) | SQ-T1 | The sodo lanang in Klething Kuning's bundle (she is at `K` (33,17)). Opens `sq_t1_klething` once the claw marks are also done |
| `tt_kali` | `t1_crossing_dry` | trigger, `trigger_id` `puzzle_t1_crossing_dry`, `size:Vector2i(8,6)` | (36,18), the river bank at the crossing | SQ-T1 peaceful | Puzzle: the player walks Klething Kuning to the water and has her strike it with the sodo lanang; the trickle at (36..37,19..) runs dry for 60 s and the crab's lane (row 16) is skipped (**TUNE**, **VERIFY** what the sodo lanang does). Solving fires `area_entered:t1_crossing_dry`; the elite `u` stays inert and is not spawned (cond `!flag:sq_t1_peaceful`, **ASSUMED**) |
| `tt_kali` | river crossing with `yuyu_kangkang` | NPC `K` (33,17), elite `u` (legend) | `u` (40,16) | SQ-T1 fight | Fight branch: the elite charger on its 12-tile lane (x 38..49, row 16) |
| `tt_sabana` | `t2_burn_trail` | `clue.tscn` `{clue_id:"t2_burn_trail", cond:"quest:sq_t2=active"}` | (46,40) | SQ-T2 | A scorched trail in the grass that circles back, on the south path to `tt_pesisir` |
| `tt_sabana` | `t2_herder` | NPC `H` (legend, renamed from `timur_herder`) | see legend | SQ-T2 | Giver and turn-in. A herder, unnamed |
| `tt_pesisir` | `t2_campfire` | `clue.tscn` `{clue_id:"t2_campfire", memory_id:"sq_t2_herder", cond:"quest:sq_t2=active"}` | (26,20) | SQ-T2 | A campfire nobody lit in the dune hollow, near the old burn-trail trigger `T`; names the banaspati. Opens `sq_t2_herder` once the trail is also examined |
| `tt_pesisir` | the spring arena | a seep spring `(47,10)`, arena rect (42,5)-(54,12) 13x8, elite `q` (50,12) `banaspati_elite` | spring (47,10) | SQ-T2 | **ASSUMED**: a small spring in the east dunes is the arena (the memory teaches that fire will not cross running water). The elite is the only enemy; standing in the spring's wet ring (radius 2, **TUNE**) halves its fire trail. The trigger `T` `burn_trail` (22,17) is no longer a step and stays as a decoration trigger |
| `tt_pasir` | `c3_road_mark` | `clue.tscn` `{clue_id:"c3_road_mark", cond:"flag:mq3_6"}` | (52,22) | SQ-C3 fragment 2 | On the desert road, a mark scratched on a boundary stone beside the road in the dune field, west of the puzzle trigger `F` (62,20). Freed variant: a stitched sound on a scrap tied to the stone. Handed variant: Uwa Lengser's note |

Flags set or read: `mq2_9` (read, `K1`), `mq3_1` to `mq3_4` and `mq3_6` to `mq3_8` (set; `mq3_4` opens `K2`), `mq4_9` (read, `K3`), `beat_laras_4`, `beat_shrine_sight`, `beat_keris`, `beat_hunter_shrine`, `beat_hunter_name`, `camp_timur`, `choice_reforge`, `choice_sink`. Shortcut flags: `sc:mt_tt`, `sc:tt_ladang`, `sc:tt_pasir`.

## Memory scenes (Story v4/v4b, [architecture.md](../architecture.md) 9b)
Small own scenes under `zones/kelir/`, not areas (no `## Area n:` heading, so `gen_zones.py` skips them). Built on `memory.gd` with a `Stand` marker and `Checkpoint` markers (group `checkpoint`). Chars are this section's own (`_` lit floor, `#` dark wall). Semar narrates 1-2 lines at the start and end (`MEM_<ID>_START_<n>`, `MEM_<ID>_END_<n>`); Laras chapters have her own lines. All numbers **TUNE**.

### Memory `k4_timun_mas`: Timun Mas (K4)

- Scene `res://zones/kelir/k4_timun_mas.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `play`. Size 60x17 (two screens, horizontal).
- Stand-in: the girl, Timun Mas (`entities/player/stand_in.tscn`).
- The one action: `interact` = throw the pouch (`action_kind: throw`) when the giant is within 3 tiles of a pouch field.
- Goal: Run east ahead of the giant `B`. Four pouch points `p`: seeds make brambles, needles a bamboo wall, salt a sea, terasi mud. Throw each in order as he closes in; the fourth lets you reach the far gate `G`. Teaches luring Buto Ijo through the pouch fields (**VERIFY** the legend's items).
- Checkpoints: `C` 4 tiles before each pouch point. Caught = `fail()`: fade, back to the last `C`, no counter; after 3 fails the throw hint shows again and the giant slows 25%.

```
############################################################
############################################################
############################################################
############################################################
############################################################
#############_______#####_______#####_______#####_______####
#__________________________________________________________#
#__________________________________________________________#
#BS_____C___p_______C___p_______C___p_______C___p________G_#
#__________________________________________________________#
#__________________________________________________________#
#############_______#####_______#####_______#####_______####
############################################################
############################################################
############################################################
############################################################
############################################################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (2,8) | start |
| `B` | Buto Ijo's shadow (1,8) | a giant silhouette that follows |
| `p` | pouch point | 4, at x=12, 24, 36, 48; each opens a 7x7 widened field `_` for the effect |
| `C` | checkpoint | 4 |
| `G` | gate (57,8) | goal |

### Memory `k5_forge`: the old forge (K5)

- Scene `res://zones/kelir/k5_forge.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `play`. Size 30x17.
- Stand-in: the smith's apprentice (silhouette).
- The one action: `interact` = douse (`action_kind: douse`) a curse mark with water from the trough `W` (carry one bucket at a time, refill at `W`).
- Goal: After the smith's dying curse (off-screen, a fade), five curse marks `m` spread across the forge floor and creep toward each other. Douse all five before they join into one line. Teaches putting out curse marks.
- Checkpoints: `C` (14,14) after the fade. Marks join = `fail()`: fade, marks reset, no counter; after 3 fails the marks creep 25% slower.

```
##############################
#____________________________#
#____________________________#
#____________________________#
#_____________A______________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#_______m_______m_______m____#
#____________________________#
#___________m_______m________#
#____________________________#
#___W_________S______________#
#_____________C______________#
#______________D_____________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (14,13) | start |
| `A` | anvil (14,4) | the smith's anvil; the cursed keris lies on it |
| `W` | water trough (4,13) | refill point |
| `m` | curse mark | 5, at (8,9), (12,11), (16,9), (20,11), (24,9) |
| `C` | checkpoint (14,14) |  |
| `D` | door (15,15) | closed |

### Memory `k6_servant`: the servant (K6)

- Scene `res://zones/kelir/k6_servant.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `walk`. Size 60x17 (two screens, horizontal).
- Stand-in: young Aria Kebonan with a broom (silhouette).
- The one action: none (walk only; the broom sweeps as he walks).
- Goal: Walk the three palace lanes `_` (sweeping) while the king speaks kindly to him by name `N`, then the face he will borrow, then nobody says his name again; end at `G`. About 2 minutes with the stops. No mechanic: the *why*, not a skill. Entered from `mask_joined`.
- Checkpoints: none (no fail state).

```
############################################################
#__________________________________________________________#
#_S_________________T___________________N__________________#
#__________________________________________________________#
#######################################################____#
#######################################################____#
#######################################################____#
#__________________________________________________________#
#_________________________________________________T________#
#__________________________________________________________#
#____#######################################################
#____#######################################################
#____#######################################################
#__________________________________________________________#
#_____________________________T__________________________G_#
#__________________________________________________________#
############################################################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (2,2) | start |
| `T` | narration stops | 3: (20,2) the king's kindness, (50,8) the borrowed face, (30,14) the silence |
| `N` | the king's voice (40,2) | King Nagawiru in the tale's frame; speaks his name |
| `G` | goal (57,14) | the memory ends in the lamp |

### Memory `h4`: wrong child (H4)

- Scene `res://zones/kelir/h4.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `walk`. Size 30x17.
- Stand-in: young Aria Kebonan at the raid (silhouette).
- The one action: none (walk only).
- Goal: The prologue raid from his eyes: walk to the west gate `g`; a small girl `g` says his name, the first time in fifteen years (the Hunter does not answer). About 1 minute. Reuses the Desa Purwa west gate rect (0,13)-(14,19) of [desa_purwa.md](desa_purwa.md).
- Checkpoints: none (no fail state).

```
##############################
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#_____________g_T_________G__#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#___S________________________#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (4,13) | start, west road side |
| `g` | the small girl (14,8) | the gate where she stands |
| `T` | narration trigger (16,8) | her line; Semar's one line |
| `G` | goal (26,8) | fade to the lamp |

### Memory `lc4`: whose face (LC4)

- Scene `res://zones/kelir/lc4.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `chapter`. Size 30x17.
- Stand-in: Laras (`entities/player/stand_in_laras.tscn`), cooler blue tint.
- The one action: `interact` = rewrite *Ka* at a sand sign `k` (hold) before the wind wipes it; also say a Faceless's true name to freeze it for 3 s.
- Goal: Walk the desert road east; at each of the 3 signs `k` the *Ka* she drew in the sand starts to fade: rewrite it in time. One Faceless rider `f` crosses the road between the second and third sign (hide behind a dune `h`). Ends with the *Ka* write card, then `memory_done:lc4`. She tries to draw your face and cannot; she remembers only the tag game and *kakak*.
- Checkpoints: `C` (2,9) and (14,9). Seen by a Faceless or a sign fading out = `fail()`: fade to the last `C`, no HP loss.

```
##############################
#____________________________#
#____________________________#
#_____________f______________#
#___________________h________#
#____________________________#
#____________________________#
#____________________________#
#_S_____k______k______k___G__#
#_C___________C______________#
#____________________________#
#____________________________#
#____________________________#
#_________h__________________#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (2,8) | start |
| `k` | sand sign | 3, at x=8, 15, 22 on row 8 |
| `f` | Faceless rider patrol | column x=14, rows 3..12 |
| `h` | dune (hide prop) | 2 |
| `C` | checkpoint | 2 |
| `G` | goal (26,8) |  |

### Memory `sq_t1_klething`: the girl and the stick (SQ-T1)

- Scene `res://zones/kelir/sq_t1_klething.tscn` (not a Zone; generated by `gen_memories.py` on `memory.gd`). Kind `play`. Size 30x17. Opened by clue `t1_sodo` in `tt_kali`.
- Stand-in: Klething Kuning (a small silhouette with a bundle).
- The one action: `interact` = strike the water with the sodo lanang (`action_kind: strike`).
- Goal: She is given the sodo lanang by a figure in the dark (**VERIFY** by whom; shown only as a hand), walks to the river `~` and strikes the water; the river parts and she crosses to the far bank `G`. Teaches: strike the water. No fight.
- Checkpoints: none (a missed strike just waits).
- Layout: a plain 30x17 room, Stand (3,8), first the hand at (6,8), second the strike point at (12,8), a river `~` across x 13..16, goal `G` (27,8), all **TUNE**.

### Memory `sq_t2_herder`: the herder boy and the fire (SQ-T2)

- Scene `res://zones/kelir/sq_t2_herder.tscn` (not a Zone; generated by `gen_memories.py` on `memory.gd`). Kind `walk`. Size 30x17. Opened by clue `t2_campfire` in `tt_pesisir`.
- Stand-in: a herder boy (a small silhouette; **ASSUMED**, game retelling, not a Tengger or Bromo tale).
- The one action: none; a line of fire runs behind him along the grass and stops dead at a stream `~`.
- Goal: Lead the goats across the stream to `G`; the fire does not cross running water. Teaches the spring arena. No fight.
- Checkpoints: none (no fail state).
- Layout: a plain 30x17 room, Stand (3,12), stream `~` across x 14..16, fire origin `F` (1,12) moving east, goal `G` (27,6), all **TUNE**.

## Flow
Enter `tt_kulon` (landmark on the horizon): the smiths' street and Ratna, `doorpost_mark`, `timur_kulon` (Ward teach), `timur_gerbang` (3.1, Prajurit, Summon), Buto Ambush #1 (3.2) > `tt_sabana` and petilasan **`timur_1`** > the village mouth with the red marks, the forge in `tt_beringin`, Mpu Wirasana (3.3), the forge-mark puzzle and practice stakes (3.4) > `tt_kali`: wisps (Dash), Mbok Srini, three pouch clues, canyon (Bind) (3.5), Buto Ambush #2 (3.6) > the banyan in `tt_beringin`: `banyan_altar`, Buto Ambush #3 (3.7), the K4 memory (3.8) > `tt_ladang`: **Buto Ijo (3.9)**, the curse stakes (3.10) > `sc:tt_ladang` to the forge: the forge defence (3.11), scabbard and forge records in the vault (3.12), `forge_stone` and the K5 memory (3.13) > drop to `tt_pesisir`: ash trail, two fights (3.14) > the east pocket (K4) > `tt_pasir`: the gatekeeper, the waymarkers, the sand-plain fight (3.15) > petilasan **`timur_2`**, camp talk (3.16), LC4 (3.17) > `tt_candi`: `shrine_sight` (3.18), **Mpu Gandring's Keris (3.19)**, beat `keris` (choice 4, 3.20) > H4 and K6, `hunter_shrine` (restore) (3.21) > **the Nameless Hunter (3.22)**, beat `hunter_name` (riders take you home). Branch: back door `sc:mt_tt`, shortcuts `sc:tt_ladang` and `sc:tt_pasir`.

## Step 2 self-check ([AGENTS.md](../../AGENTS.md) section 5), re-run for v4c 2026-11-06
- [~] POI counts: 1 boss arena (`tt_candi`), 1 miniboss room (Buto Ijo) plus the gatekeeper miniboss, 2 elites, 7 NPCs (daughter added), 5 secrets or finds (sabana mound ring, hollow banyan, pesisir wreck, kulon hollow, ladang nook), 1 codex ruin, 10 encounters, 2 petilasans. The extra encounters, the second miniboss and the extra chests exist because the v4c step tables count the pieces and rule 7 asks for a find in every area.
- [x] Petilasan before the boss, no fight between: `timur_2` is in the east alcove of `tt_pasir`; `timur_pasir` and the gatekeeper are before it; the camp talk, LC4, and the K5 memory (inside `tt_candi`) are not fights.
- [x] Each enemy first appears alone or with known enemies with a usable weakness: unchanged; `timur_dune` (Banaspati only) and the gatekeeper (Prajurit, known) are repeats.
- [x] One tank per encounter (2 only in `timur_pasir`), at most one shooter, at most two waves (pasir only): unchanged; the new fights have one wave and no shooter.
- [x] Rooms with 4+ enemies are at least 15x9: unchanged; `timur_dune` has 3, the gatekeeper 1.
- [~] Newest glyph: unchanged (see conflicts); Ra Summon is the clean answer in the gatekeeper fight.
- [x] Every MQ3 step 3.1-3.22, clue id (`doorpost_mark`, `seeds`, `needle_case`, `salt_terasi`, `banyan_altar`, `ladang_stake`, `scabbard`, `forge_records`, `forge_stone`, `ash_trail`, `pasir_waymarkers`, `hunter_mask_4`, `mask_joined`), memory id (`k4_timun_mas`, `k5_forge`, `k6_servant`, `lc4`, `h4`) and beat has a place in the table above or a legend row.
- [x] The alcove is still free of enemies.
- [x] The critical path needs no glyph for any door. K1, K2, K4 open on story flags (K4 on `mq3_h4`, set by the practice marks, the scabbard and the records). The puzzles `puzzle_timur_forgemark` and `puzzle_pasir_dunes` gate nothing.
- [x] Pacing rule 5: after 3.14 the walk is forward only (the coast road K4), no sabana > beringin > ladang > pasir trip; 3.9 to 3.11 uses `sc:tt_ladang`; the later trips use `sc:tt_pasir`.
- [x] Pacing rule 7: every area has an optional find (see Rule 7 above).

**Interlock rules ([world.md](../world.md))**
1. [x] 3 loops (A, B closed by shortcuts, C by the drop).
2. [x] 3 shortcuts. Each ends in `tt_sabana` (has `timur_1`) or `tt_beringin` (one link from it).
3. [x] 1 drop (`drop_pesisir`).
4. [x] No optional area remains: `tt_pesisir` is step 3.14 and sits on Loop C with a link back to `tt_sabana`.
5. [x] Landmark visible from `tt_kulon`, nearer in `tt_sabana`, `tt_kali`, `tt_pasir`.
6. [x] `timur_2` right before `tt_candi`, no fight between.
7. [x] 2 petilasans; shortcuts do the work of lamps.
8. [x] The critical path visits 8 of 8 areas. Gates: `K1` Hariang Banga duel (`mq2_9`), `K2` Buto Ijo (`mq3_4`); `K3` (to `sk_karang`) is a back route on `mq4_9`, off the MQ3 path. Glyphs are rewards, not keys.

## ASSUMED
- All area ids beyond the three fixed ones (`tt_kulon`, `tt_sabana`, `tt_pesisir`), the `timur_*` encounter ids, the npc_ids, marker ids, chest ids and the `kuda_kepang_*` ids.
- Flags `mq2_9` (2.13 Hariang Banga), `mq3_4` (3.9 Buto Ijo), `mq3_6`, `mq3_7`, `mq3_8` (from quests.md). `K3` uses `mq4_9` (`quest:mq4=done`), a back route only (coordinator, 2026-11-06).
- Mbok Srini lives in `tt_kali` and Klething Kuning at the river crossing in the same area (the river is a trickle in a dry riverbed).
- The sodo lanang is in Klething Kuning's bundle (v4d, clue `t1_sodo` in `tt_kali`); who gave it to her is **VERIFY**. The old shrine pickup `h` in `tt_beringin` is no longer a quest source.
- Drop `drop_pesisir` is a dune slide; sizes 3x2 are allowed by the 60/90 x 34/51 rule.
- v3.1: 3.22 is the Hunter in `tt_candi`, and the aftermath `goto` takes you home (no walk to Semar); `sc:mt_tt` and `sc:tt_pasir` stay as loops.
- v3.1 additions: the route back from the coast after 3.14 is sabana > beringin > ladang > pasir (or via kali). Hariang Banga NPC `H` (83,13) in the `tt_pasir` alcove, cond `flag:mq3_6`. A second Mpu Wirasana instance `W` (32,19) in the `tt_candi` court, cond `flag:mq3_7,!flag:beat_keris`. Beat spots are trigger nodes (`S`, `K`, `R`, `N` in `tt_candi`) that only stage beats. Mbok Srini's entry needs `area_cleared:timur_wisps`. Keris `B` cond `flag:beat_shrine_sight`. The riders are staged in the beat, with no map spot.
- The meteorite fragment `batu_bintang` lies in `mt_candi` (east yard).
- The `timur_wisps` encounter has no tank or chaser, as the bestiary mix lists only 2 Kemamang.

- v4c (2026-11-06): link L14 `tt_pesisir` > `tt_pasir` (east pocket to south corridor, kabut `K4`, `mq3_h4`) added so 3.14-3.15 run forward; `tt_pasir` got a south corridor and `tt_pesisir` an east pocket (map edits). Steps 3.14-3.17 pieces get unnamed ids (`doorpost_mark`, `ash_trail`, `lc4_lontar`, `timur_penjaga`, `timur_dune`, `puzzle_*`, `pasir_sight`); Ratna is `timur_daughter`. New chests `chest_tt_kulon` (150 Ilmu) and `chest_tt_ladang` (160 Ilmu) are rule 7 finds. Shrine door for `mask_joined` is the east wall of the court.

- Story v5 pass (**ASSUMED** 2026-11-06): step numbers follow the 22-step MQ3 (quests.md section 4). `salt_terasi` lost its `memory_id`; the K4 memory opens from the new clue `banyan_altar` (`V` (50,14) in `tt_beringin`, cond `flag:mq3_b3`). `forge_stone` moved from `tt_candi` to Wirasana's vault (`Q` (19,4) in `tt_beringin`, cond `flag:mq3_h4`, K5 = 3.13). New clue `ladang_stake` (`L` (23,14) in `tt_ladang`). `ash_trail` and `doorpost_mark` were already placed. `pasir_waymarkers` stays the trigger `J`: the clue and the puzzle share the id. The beat `marks_hook` now reads `flag:mq3_h1` instead of `step:mq3=1`. There is no `tt_pasar`: Ratna's street is `tt_kulon`, the savanna `tt_sabana`, the forge and banyan `tt_beringin`.

## Open questions
1. Mataram: confirm `mt_wetan`/`mt_tegal` exist in the Mataram doc, and where `batu_bintang` lies.
2. Resolved by the main session (2026-11-06): `K3` opens on `quest:mq4=done` (`mq4_9`), a back route only.
3. Resolved 2026-11-05 (ASSUMED): Semar stands in `desa_purwa` only, as for 2.9.
4. Resolved 2026-11-05 (ASSUMED): the practice stakes stay. Any glyph counts, so this is a quest action, not a lock (bestiary.md, practice marks).
5. Resolved 2026-11-05 (ASSUMED), superseded by v4d: the peaceful route no longer starts in the shrine; Klething Kuning carries the sodo lanang (clue `t1_sodo`) and strikes the water herself (`t1_crossing_dry`). Who gave it stays **VERIFY**; game text does not name the giver.
6. Resolved 2026-11-05: Banaspati elite and Yuyu Kangkang are named elites in bestiary.md.
7. Resolved 2026-11-05: `batu_bintang` lies in `mt_candi` (east yard), as built in mataram.md. The SQ-T3 marker uses `mt_candi`.

## Doc conflicts found
- bestiary.md Encounters "Embers" (4 Banaspati) would be the first Banaspati encounter if met alone in the savanna. Here `timur_kulon` (2 Banaspati) teaches first and `timur_embers` comes second.
- quests.md SQ-T2 needs an elite Banaspati (added to bestiary.md 2026-11-05); SQ-T1 needs a river with a crab (a dry bed plus one trickle channel).
- world.md "Points of interest" asks for 1 miniboss or elite room; MQ3 3.9 makes Buto Ijo mandatory, so the miniboss is on the critical path (rule 4 only applies to optional areas).
- Resolved 2026-11-06 (consistency pass): world.md now gates the Mataram kabut on `mq2_9` and `tt_pesisir` to `sk_karang` on `mq4_9`; `tt_pesisir` is main path (step 3.14); the `goto` spawn is `from_riders`; step 3.4 counts `area_entered:timur_praktik_mark`; the caged king's face at `hunter_name` is narration only.
- quests.md mentions an encounter `timur_candi`. This zone has no such encounter (the court holds the two bosses). Add one only if a guard fight before `shrine_sight` is wanted.
- `goto`, `restore` and the `zone:` condition are not built yet (quests.md 7.1/7.2); the beats here need them.
- Hariang Banga is a boss in `kg_pamali` and an NPC here under the same id `hariang_banga`; the dialogue file needs the `camp_timur` entry (cond `flag:mq3_6`) and the zone must pick the NPC scene, not the boss scene.

## Area maps (Phase 5)
The 8 sections below follow the format of [mataram.md](mataram.md) (tile chars as in tatar_sunda.md, legend, encounters). Coordinates are (x, y) from the top-left tile (0,0). Sand and burnt grass are floor choices only (pasir plain uses `_`). A shortcut gate (2-tile `shortcut.tscn`) sits only in the area behind it, with its pocket (spawn, exit) on the open side; the opener area has a plain exit into that pocket: `sc:mt_tt` gate is in mt_tegal, `sc:tt_ladang` gate in tt_beringin (north wall), `sc:tt_pasir` gate in tt_sabana (east wall, north end). Elites are plain spots. Curse stakes: the 7 boss stakes are chars `1`..`7` (`{stake_id:n}`); the 3 practice stakes share char `S` (`{practice:true}`). Marker `timur_praktik` is a trigger node.

## Area 1: tt_kulon

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Burnt-gold grass, a broken stone gate, Mataram kabut on the west edge, the Candi Gandring silhouette on the east horizon (art layer).
- Purpose: Entry from mt_wetan (kabut K1 `mq2_9`), gentle first fights `timur_kulon` and `timur_gerbang`, link to tt_sabana.

### Map
```
############################################################
#...........................................##.............#
#...........................................##.............#
#...........................................##.............#
#...........................................##.............#
#.............................rr..b.........##......rr.....#
#.........rr..................rr............##......rr.....#
#.........rr.........................b......##.............#
#...........................................##.............#
#...........................................##.............#
#...........................................##.........C...#
#...........................................##.............#
#...........................................##.............#
#...........................................rr.............#
#...........A...............B...............rr.............#
#######....................................................#
Xe,,K,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,D,,,,,,,,,,,,G,,,,,,,,,yY
X,,,K,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#######....................................................#
#...........................................rr.............#
#...........................................rr.............#
#...........................................##.............#
#...........................................##.............#
#...........................................##.............#
#..................................rr.......##.............#
#..................................rr.......##.............#
#...........................................##.............#
#...................rr......................##.............#
#...................rr......................##........rr...#
#...........................................##........rr...#
#...........................................##.............#
#...........................................##.............#
#...........................................##.............#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to mt_wetan (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_wetan", spawn_id:"from_tt_kulon"}` | path | 2 |
| `e` | spawn, arrival from mt_wetan | `res://entities/world/spawn.tscn` | `{id:"from_mt_wetan"}` | path | 1 |
| `K` | kabut K1, west edge (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq2_9"}` | path | 2 |
| `Y` | exit to tt_sabana (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_sabana", spawn_id:"from_tt_kulon"}` | path | 2 |
| `y` | spawn, arrival from tt_sabana | `res://entities/world/spawn.tscn` | `{id:"from_tt_sabana"}` | path | 1 |
| `E` | encounter timur_kulon | `res://entities/world/encounter.tscn` | `{area_id:"timur_kulon", size:Vector2i(20,11), waves:[[[res://entities/enemies/banaspati.tscn, Vector2i(6,-3)], [res://entities/enemies/banaspati.tscn, Vector2i(6,3)]]]}` | path | 1 |
| `G` | encounter timur_gerbang | `res://entities/world/encounter.tscn` | `{area_id:"timur_gerbang", size:Vector2i(18,10), waves:[[[res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(7,0)], [res://entities/enemies/banaspati.tscn, Vector2i(3,-3)], [res://entities/enemies/banaspati.tscn, Vector2i(3,3)]]]}` | path | 1 |
| `b` | loose banaspati, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/banaspati.tscn` | `{}` | grass | 2 |
| `A` | NPC Ratna on the smiths' street (3.1 arrival slice; shows how a keris is folded, `codex:pamor`; the curse marks follow) | `res://entities/npc/npc.tscn` | `{npc_id:"timur_daughter"}` | grass | 1 |
| `B` | clue, the first red curse mark on a stall doorpost (3.1 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"doorpost_mark"}` | grass | 1 |
| `C` | chest: 150 Ilmu (north-east hollow, rule 7 optional find, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"chest_tt_kulon", item_id:"ilmu:150"}` | grass | 1 |
| `D` | encounter buto_ambush_1 (3.2 Stalking Ambush #1: Buto Ijo's sudden rampage across the western savanna) | `res://entities/world/encounter.tscn` | `{area_id:"buto_ambush_1", size:Vector2i(16,9), waves:[[[res://entities/bosses/buto_ijo.tscn, Vector2i(0,-4)], [res://entities/enemies/banaspati.tscn, Vector2i(-4,-2)], [res://entities/enemies/banaspati.tscn, Vector2i(4,-2)], [res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(0,2)]]]}` | path | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_kulon` | `E (22,16)` | 20x11 | W1: Banaspati (+6,-3), Banaspati (+6,+3) | Ga Ward snuffs the Banaspati |
| `timur_gerbang` | `G (48,16)` | 18x10 | W1: Prajurit Terkutuk (+7,+0), Banaspati (+3,-3), Banaspati (+3,+3) | Ra Summon turns the shield; Ward on Banaspati |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| smiths' street | (7,13)-(43,18) | The arrival slice: stalls along the road (art), the daughter, the first mark | NPC `A` (12,14), clue `B` (28,14) | 3.1 `talked_to:timur_daughter` |
| hollow | (50,9)-(58,11) | North-east hollow behind the rocks | chest `C` (55,10) | rule 7 |
## Area 2: tt_sabana

- Size: 90 x 51 tiles = 3 x 3 screens (30 x 17 each).
- Look: Open gold savanna, termite mounds, a mound ring in the south-west, the candi silhouette clearer on the horizon.
- Purpose: Hub: petilasan `timur_1`, herder, embers fight, chest, kuda kepang, links to kulon, kali, beringin, pesisir, plain exit to mt_tegal (`sc:mt_tt`) and the gate of `sc:tt_pasir`.

### Map
```
##############################NN##########################################################
#.............................n,.........................................................#
#.............................,,.........................................................#
#.............................,,.........................................................#
#.............................,,.........................................................#
#.............................,,.........................................................#
#.............................,,.........................................................#
#.............................,,.........................................................#
#.............................,,............................rr...........................#
#.............................,,............................rr...........................#
#######.............rr........,,.....................................................#####
Mm,,,,,.............rr........,,.....................................................+,,zZ
M,,,,,,.......................,,..................................j..................+,,,Z
#######.......................,,.....................................................#####
#.............................,,.......................rr.......b........................#
#.............................,,.......................rr................................#
#..............rr.............,,...................................b.....................#
#..............rr.............,,.........................................................#
#.............................,,...........................................rr............#
#.............................,,...........................................rr............#
#.............................,,.........................................................#
#.............................,,.........................................................#
#.........H..T................,,.........................................................#
#.............................,,.........................................................#
Xe,,,,,P,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,yY
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#...........................................,,...........................................#
#...........................................,,...........................................#
#...........................................,,...........................................#
#...........................................,,...........................................#
#...........................................,,...........................................#
#...........................................,,...........................................#
#...........................................,,...........................................#
#...........................................,,...........................................#
#........................rr.................,,...........................................#
#........................rr.................,,........................rr.................#
#...........................................,,........................rr.................#
#.......rrrr..rrr...........................,,...........................................#
#.......r.......r...........................,,...........................................#
#.......r.......r...........................,,...........................................#
#.......r...c...r...........................,,..............k............................#
#.......r.......r...........................,,...........................................#
#.......r.......r.....................rr....,,...........................................#
#.......rrrrrrrrr.....................rr....,,...........................................#
#...........................................,,...................rr......................#
#...........................................,,...................rr......................#
#...........................................,,...........................................#
#...........................................,,...........................................#
#...........................................,,...........................................#
#...........................................s,...........................................#
############################################SS############################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to tt_kulon (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_kulon", spawn_id:"from_tt_sabana"}` | path | 2 |
| `e` | spawn, arrival from tt_kulon | `res://entities/world/spawn.tscn` | `{id:"from_tt_kulon"}` | path | 1 |
| `N` | exit to tt_kali (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_kali", spawn_id:"from_tt_sabana"}` | path | 2 |
| `n` | spawn, arrival from tt_kali | `res://entities/world/spawn.tscn` | `{id:"from_tt_kali"}` | path | 1 |
| `Y` | exit to tt_beringin (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_beringin", spawn_id:"from_tt_sabana"}` | path | 2 |
| `y` | spawn, arrival from tt_beringin | `res://entities/world/spawn.tscn` | `{id:"from_tt_beringin"}` | path | 1 |
| `S` | exit to tt_pesisir (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_pesisir", spawn_id:"from_tt_sabana"}` | path | 2 |
| `s` | spawn, arrival from tt_pesisir | `res://entities/world/spawn.tscn` | `{id:"from_tt_pesisir"}` | path | 1 |
| `M` | exit to mt_tegal (west wall, north end, plain exit into the `sc:mt_tt` pocket, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_tegal", spawn_id:"from_tt_sabana"}` | path | 2 |
| `m` | spawn, arrival from mt_tegal | `res://entities/world/spawn.tscn` | `{id:"from_mt_tegal"}` | path | 1 |
| `Z` | exit to tt_pasir (east wall, north end, through the gate, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_pasir", spawn_id:"from_tt_sabana"}` | path | 2 |
| `z` | spawn, arrival from tt_pasir (on the open side of the gate) | `res://entities/world/spawn.tscn` | `{id:"from_tt_pasir"}` | path | 1 |
| `+` | shortcut gate sc:tt_pasir, sand-choked slab (opens from the east pocket, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:tt_pasir", open_side:"e"}` | path | 2 |
| `P` | petilasan 1 | `res://entities/petilasan/petilasan.tscn` | `{id:"timur_1"}` | path | 1 |
| `H` | NPC herder (SQ-T2 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"timur_herder"}` | grass | 1 |
| `T` | NPC herder v4d (SQ-T2) | `res://entities/npc/npc.tscn` | `{npc_id:"t2_herder"}` | grass | 1 |
| `c` | chest: Crossbow (secret, mound ring) | `res://entities/world/chest.tscn` | `{chest_id:"chest_tt_sabana", item_id:"crossbow"}` | grass | 1 |
| `k` | pickup, kuda kepang 1 (SQ-T4) | `res://entities/world/pickup.tscn` | `{item_id:"kuda_kepang_1"}` | grass | 1 |
| `E` | encounter timur_embers | `res://entities/world/encounter.tscn` | `{area_id:"timur_embers", size:Vector2i(26,14), waves:[[[res://entities/enemies/banaspati.tscn, Vector2i(8,-4)], [res://entities/enemies/banaspati.tscn, Vector2i(8,4)], [res://entities/enemies/banaspati.tscn, Vector2i(4,-5)], [res://entities/enemies/banaspati.tscn, Vector2i(4,5)]]]}` | path | 1 |
| `b` | loose banaspati, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/banaspati.tscn` | `{}` | grass | 2 |
| `j` | loose prajurit terkutuk, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/prajurit_terkutuk.tscn` | `{}` | grass | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_embers` | `E (50,25)` | 26x14 | W1: Banaspati (+8,-4), Banaspati (+8,+4), Banaspati (+4,-5), Banaspati (+4,+5) | Ga Ward |

## Area 3: tt_kali

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: West half: dry riverbed with rocks and a trickle channel. East half: a narrow red canyon. Mbok Srini hut in the middle.
- Purpose: Teach Kemamang (`timur_wisps`) and Keris Hantu (`timur_ngarai`), Mbok Srini, Klething Kuning and the Yuyu Kangkang crossing (lane 12), kuda kepang 2.

### Map
```
##########################################################################################
#...................................~~...............#####################################
#...................................~~...............#####################################
#...................................~~....#########..#####################################
#...................................~~....#_______#..#####################################
#.................rr................~~....#_______#..#####################################
#...........k.....rr...........v....~~....#___M___#..#####################################
#...................................~~....#_______#..#####################################
#...........................rr......~~....#_______#..#####################################
#...........................rr...v..~~....#_______#..#####################################
#...................................~~....####,####..#####################################
#...................................~~........,......#####################################
#...rr..............................~~........C..........................................#
#...rr..............................~~..B.....,..........................................#
#.............................................,..........................................#
#.............................................,..........................................#
#,,,,,,,,,,,,,,,,,,,D,,,,,,,,,,,,,,,,,,,u,,,,,,,,,,,,,,,,,,,,,,,,,,,,,G,,,,,,,,,,,,,,,,,yY
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,K,I,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#.......,,..................A...H.F......................................................#
#.......,,................rr.............................................................#
#.......,,................rr........~~...................................................#
#.......,,....rr....................~~...............#####################################
#.......,,....rr....................~~...............#####################################
#.......,,..........................~~...............#####################################
#.......,,........E.................~~..........rr...#####################################
#.......,,..........................~~..........rr...#####################################
#.......,,..........................~~......rr.......#####################################
#.......,,..........................~~......rr.......#####################################
#.......,,................rr........~~...............#####################################
#.......,,................rr........~~...............#####################################
#.......,,....................rr....~~...............#####################################
#.......,,....................rr....~~...............#####################################
#.......s,..........................~~...............#####################################
########XX################################################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to tt_sabana (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_sabana", spawn_id:"from_tt_kali"}` | path | 2 |
| `s` | spawn, arrival from tt_sabana | `res://entities/world/spawn.tscn` | `{id:"from_tt_sabana"}` | path | 1 |
| `Y` | exit to tt_ladang (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_ladang", spawn_id:"from_tt_kali"}` | path | 2 |
| `y` | spawn, arrival from tt_ladang | `res://entities/world/spawn.tscn` | `{id:"from_tt_ladang"}` | path | 1 |
| `M` | NPC Mbok Srini (npc id `mbok_srini` kept; 3.5, the four pouches; her entry needs `area_cleared:timur_wisps`) | `res://entities/npc/npc.tscn` | `{npc_id:"mbok_srini"}` | floor | 1 |
| `K` | NPC Klething Kuning (SQ-T1 giver, river crossing) | `res://entities/npc/npc.tscn` | `{npc_id:"klething_kuning"}` | grass | 1 |
| `u` | elite Yuyu Kangkang (SQ-T1 fight branch, charger lane x 38..49 on row 16; first and only enemy, `unique_id` `yuyu_kangkang`, elite stats HP x4, Ilmu x4, **TUNE**; inert until step 4) | `res://entities/enemies/yuyu_kangkang.tscn` | `{unique_id:"yuyu_kangkang"}` | path | 1 |
| `k` | pickup, kuda kepang 2 (SQ-T4, riverbed) | `res://entities/world/pickup.tscn` | `{item_id:"kuda_kepang_2"}` | grass | 1 |
| `E` | encounter timur_wisps | `res://entities/world/encounter.tscn` | `{area_id:"timur_wisps", size:Vector2i(28,12), waves:[[[res://entities/enemies/kemamang.tscn, Vector2i(6,-3)], [res://entities/enemies/kemamang.tscn, Vector2i(6,3)]]]}` | grass | 1 |
| `G` | encounter timur_ngarai | `res://entities/world/encounter.tscn` | `{area_id:"timur_ngarai", size:Vector2i(30,9), waves:[[[res://entities/enemies/keris_hantu.tscn, Vector2i(10,-3)], [res://entities/enemies/keris_hantu.tscn, Vector2i(10,0)], [res://entities/enemies/keris_hantu.tscn, Vector2i(10,3)]]]}` | path | 1 |
| `v` | loose kemamang, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/kemamang.tscn` | `{}` | grass | 2 |
| `A` | clue, cucumber seeds spilled on the path (3.5, K4 clue 1 of 3; journal note only) | `res://entities/world/clue.tscn` | `{clue_id:"seeds"}` | grass | 1 |
| `B` | clue, a needle case on the riverbed rocks (3.5, K4 clue 2 of 3; journal note only) | `res://entities/world/clue.tscn` | `{clue_id:"needle_case"}` | grass | 1 |
| `C` | clue, a salt jar and a pot of terasi at the hut door (3.5, K4 clue 3 of 3; journal note only, the memory now opens from `banyan_altar`) | `res://entities/world/clue.tscn` | `{clue_id:"salt_terasi"}` | path | 1 |
| `D` | encounter buto_ambush_2 (3.6 Stalking Ambush #2: test the bramble-seed pouch across the dry riverbed) | `res://entities/world/encounter.tscn` | `{area_id:"buto_ambush_2", size:Vector2i(16,9), waves:[[[res://entities/bosses/buto_ijo.tscn, Vector2i(0,-4)], [res://entities/enemies/kemamang.tscn, Vector2i(-4,0)], [res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(0,0)], [res://entities/enemies/kemamang.tscn, Vector2i(4,0)]]]}` | path | 1 |
| `F` | clue, giant claw marks on the broken ferry jetty (SQ-T1 clue 1 of 2) | `res://entities/world/clue.tscn` | `{clue_id:"t1_claw_marks", cond:"quest:sq_t1=active"}` | grass | 1 |
| `H` | clue, the sodo lanang palm rib in Klething Kuning's bundle (SQ-T1 clue 2 of 2; opens memory `sq_t1_klething`) | `res://entities/world/clue.tscn` | `{clue_id:"t1_sodo", memory_id:"sq_t1_klething", cond:"quest:sq_t1=active"}` | grass | 1 |
| `I` | trigger, strike the river with the sodo lanang to dry the crossing (SQ-T1 peaceful end; fires `area_entered:t1_crossing_dry`) | `res://entities/world/trigger.tscn` | `{trigger_id:"t1_crossing_dry", size:Vector2i(4,4)}` | path | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_wisps` | `E (18,24)` | 28x12 | W1: Kemamang (+6,-3), Kemamang (+6,+3) | Na Dash-strike; melee cuts wisps |
| `timur_ngarai` | `G (70,16)` | 30x9 | W1: Keris Hantu (+10,-3), Keris Hantu (+10,+0), Keris Hantu (+10,+3) | Nga Bind; Ha Heal cures Curse |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| K4 clues | seeds (28,18), needle case (40,13), salt jar (46,12) | Walked in this order from the riverbed to Mbok Srini's hut | clues `A` `B` `C` | 3.5 `all` of three; sets `mq3_h2` |
## Area 4: tt_beringin

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: Giant banyan grove, hanging roots, a forge under a banyan, shrine ruins, a troupe camp. Quiet around the forge and camp; one roaming pack in the south-east (2026-11-06).
- Purpose: Empu forge with 3 practice stakes, codex ruin, kuda lumping camp and stage, sodo lanang shrine, hollow banyan chest, drop ledge south, far side of `sc:tt_ladang`.

### Map
```
############################################################NN############################
#..........................................................#n,#..........................#
#..........................................................#,,#.............###########..#
#.......#############...................#############......#++#.............#_________#..#
#.......#__________Q#.........rr........#___________#.......,,..............#____c____#..#
#.......#___________#.........rr........#___________#.......,,..............#_________#..#
#.......#_____E_____#...................#_____R_____#.......,,..............#_________#..#
#.......#___________#...................#___________#.......,,..............#_________#..#
#.......#___C____F__#...................#___________#.......,,..............#####,#####..#
#.......#___________#...................#___________#.......,,...................,.......#
#.......######,######....rr.............######,######.......,,...................,.......#
#.............,..........rr...................,.............,,...................,.......#
#.............B...............................,.............,,...................,.......#
#..........S..S..S............................,.............,,...................,.......#
#.............M...............................,...V.........,,...................,.......#
#.............,...............................,.............,,...................,.......#
Xe,,,,A,,,,,,,,,,,,,,,G,,,,,,,,,,,,,,,,,,,,,,,,,,,H,,,,,,,,,,,,,,,,,,,,,,,,,,,,..........#
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..........#
#.................................................,,.....................................#
#.................................................,,.....................................#
#.................................................,,..................rr..rr.............#
#.................................................,,..................rr..rr.............#
#.................................................,,....b...........g...i...o............#
#.................................................,,.....................................#
#.............................L...................,,......b..............................#
#....rr...........................................,,..................rr..rr.............#
#....rr...........................................,,....j.............rr..rr.............#
#.................................................,,.....................................#
#.............................T...................,,........rr...........................#
#.................................................,,........rr...........................#
#.................................................,,.....................................#
#.................................................,,.....................................#
#.................................................,,.....................................#
##################################################DD######################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to tt_sabana (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_sabana", spawn_id:"from_tt_beringin"}` | path | 2 |
| `e` | spawn, arrival from tt_sabana | `res://entities/world/spawn.tscn` | `{id:"from_tt_sabana"}` | path | 1 |
| `N` | exit to tt_ladang (north edge, through the gate, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_ladang", spawn_id:"from_tt_beringin"}` | path | 2 |
| `n` | spawn, arrival from tt_ladang (on the open side of the gate) | `res://entities/world/spawn.tscn` | `{id:"from_tt_ladang"}` | path | 1 |
| `+` | shortcut gate sc:tt_ladang, root-choked door (opens from the north pocket, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:tt_ladang", open_side:"n"}` | path | 2 |
| `D` | exit, the drop to tt_pesisir (south rim, 2 tiles, one way, no spawn back) | `res://entities/world/exit.tscn` | `{target_zone:"tt_pesisir", spawn_id:"from_tt_beringin"}` | path | 2 |
| `E` | NPC Mpu Wirasana (3.3, SQ-T3 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"timur_empu"}` | floor | 1 |
| `R` | pickup, sodo lanang (SQ-T1 step 2) | `res://entities/world/pickup.tscn` | `{item_id:"sodo_lanang"}` | floor | 1 |
| `S` | practice stake (3.4, one per tile) | `res://entities/bosses/curse_stake.tscn` | `{practice:true}` | grass | 3 |
| `M` | trigger, practice marks (3.4; id `timur_praktik_mark` so entering fires both the area and its puzzle alias, which is the step's `x2`) | `res://entities/world/trigger.tscn` | `{trigger_id:"timur_praktik_mark", size:Vector2i(10,5)}` | grass | 1 |
| `L` | NPC kuda lumping leader (SQ-T4 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"kepang_leader"}` | grass | 1 |
| `T` | trigger, kepang stage (SQ-T4 step 3) | `res://entities/world/trigger.tscn` | `{trigger_id:"kepang_stage", size:Vector2i(8,4)}` | grass | 1 |
| `g` | codex ruin, inscribed stone 1 (Keris) | `res://entities/world/pickup.tscn` | `{codex_id:"keris"}` | grass | 1 |
| `i` | codex ruin, inscribed stone 2 (Mpu Gandring) | `res://entities/world/pickup.tscn` | `{codex_id:"mpu_gandring"}` | grass | 1 |
| `o` | codex ruin, statue plinth (Tengger, scenery text) | `res://entities/world/pickup.tscn` | `{codex_id:"tengger_lautan_pasir"}` | grass | 1 |
| `c` | chest: Chainmail (secret, hollow banyan) | `res://entities/world/chest.tscn` | `{chest_id:"chest_tt_beringin", item_id:"chainmail"}` | floor | 1 |
| `b` | loose banaspati, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/banaspati.tscn` | `{}` | grass | 2 |
| `j` | loose prajurit terkutuk, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/prajurit_terkutuk.tscn` | `{}` | grass | 1 |
| `A` | trigger, `timur_marks` entered: the village mouth with the red marks on the doorposts (3.3; beat `marks_hook`, sets `mq3_h1`) | `res://entities/world/trigger.tscn` | `{trigger_id:"timur_marks", size:Vector2i(8,6)}` | path | 1 |
| `B` | trigger, puzzle `puzzle_timur_forgemark` (3.4: break the curse mark on the forge door with the empu's technique; sets `flag:puzzle_timur_forgemark`, no gate) | `res://entities/world/trigger.tscn` | `{trigger_id:"puzzle_timur_forgemark", size:Vector2i(6,4)}` | path | 1 |
| `C` | clue, the broken scabbard in Wirasana's vault, the forge interior (3.12, K5 clue 1 of 3 is the practice marks; sits with `forge_records` and `forge_stone`) | `res://entities/world/clue.tscn` | `{clue_id:"scabbard"}` | floor | 1 |
| `F` | clue, Wirasana's forge records, "seven generations" (3.12, K5) | `res://entities/world/clue.tscn` | `{clue_id:"forge_records"}` | floor | 1 |
| `G` | encounter timur_forge_defense (3.11 defend the forge quarter from flying Keris Hantu packs) | `res://entities/world/encounter.tscn` | `{area_id:"timur_forge_defense", size:Vector2i(15,9), waves:[[[res://entities/enemies/keris_hantu.tscn, Vector2i(-4,-2)], [res://entities/enemies/keris_hantu.tscn, Vector2i(4,-2)], [res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(0,2)]]]}` | path | 1 |
| `H` | encounter buto_ambush_3 (3.7 Stalking Ambush #3: consecrate the pouches at the ancient banyan while holding off Buto Ijo) | `res://entities/world/encounter.tscn` | `{area_id:"buto_ambush_3", size:Vector2i(16,9), waves:[[[res://entities/bosses/buto_ijo.tscn, Vector2i(0,-4)], [res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(-4,0)], [res://entities/enemies/keris_hantu.tscn, Vector2i(0,-2)], [res://entities/enemies/keris_hantu.tscn, Vector2i(4,2)]]]}` | path | 1 |
| `V` | clue, the flat stone with small handprints in the hollow of the ancient banyan, beside Buto Ambush #3 (3.7 `clue_examined:banyan_altar`; shows after the ambush is cleared, then opens memory `k4_timun_mas` at 3.8; ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"banyan_altar", memory_id:"k4_timun_mas", cond:"flag:mq3_b3"}` | grass | 1 |
| `Q` | clue, the old anvil stone in the corner of Wirasana's vault (3.13 K5; opens memory `k5_forge`; appears once the vault clues are done; moved here from `tt_candi`) | `res://entities/world/clue.tscn` | `{clue_id:"forge_stone", memory_id:"k5_forge", cond:"flag:mq3_h4"}` | floor | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| forge house vault | (9,4)-(19,9) forge interior | Wirasana's vault: the three K5 clues | `C` scabbard (12,8), `F` forge_records (17,8), `Q` forge_stone (19,4), the old anvil in the corner | 3.12 `all` of `clue_examined:scabbard`, `clue_examined:forge_records`; 3.13 `forge_stone` |
| ancient banyan | (42,12)-(58,20) | The banyan on the road east of the forge, Buto Ambush #3 `H` (50,16) | `V` banyan_altar (50,14) | 3.7 `buto_ambush_3`, `banyan_altar`; 3.8 `k4_timun_mas` |
| village mouth and forge door | marks trigger `A` (6,16), puzzle `B` (14,12) | Hook and the forge-door puzzle | `timur_marks`, `puzzle_timur_forgemark` | 3.3 `timur_marks`; 3.4 `puzzle_timur_forgemark` |
## Area 5: tt_ladang

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Dry field of dead cucumber vines (west), a dark lair of hanging bones and a lamp (east).
- Purpose: Buto Ijo field fight `timur_ladang`, plain exit to the `sc:tt_ladang` gate in beringin, miniboss arena 28x16 (east half), kabut K2 `mq3_4` before tt_pasir.

### Map
```
############################################################
#...........................################################
#.........................A.################################
#.......x.......v...........################################
#...........b.........rr....################################
#....rr...............rr....################################
#....rr.....................################################
#...........................################################
#...........................################################
#...........................#____________________________###
#...........................#____________________________###
#...........................#__rr_____________________rr_###
#.......rr..............rr..#__rr_____________________rr_###
#.......rr.....E........rr..#____________________________###
#......................L....#____________________________###
#...........................,____________________________###
#.............,,,,,,,,C,,,,,,,,,,,,,,,,,,,,B,,,,,,,,,,,,,KzZ
#.............,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,K,Z
#...rr........,,............,____________________________###
#...rr........,,............#____________________________###
#.............,,....rr..D...#____________________________###
#.............,,....rr......#____________________________###
#.............,,............#__rr_____________________rr_###
#.............,,........F...#__rr_____________________rr_###
Yy,,,,,,,,,,,,,,............#____________________________###
Y,,,,,,,,,,,,,,,............################################
#...........................################################
##############,,############################################
##############,,############################################
##############,,############################################
##############,,############################################
##############,,############################################
##############p,############################################
##############XX############################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `Y` | exit to tt_kali (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_kali", spawn_id:"from_tt_ladang"}` | path | 2 |
| `y` | spawn, arrival from tt_kali | `res://entities/world/spawn.tscn` | `{id:"from_tt_kali"}` | path | 1 |
| `X` | exit to tt_beringin (field south wall, into the `sc:tt_ladang` gate, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_beringin", spawn_id:"from_tt_ladang"}` | path | 2 |
| `p` | spawn, arrival from tt_beringin | `res://entities/world/spawn.tscn` | `{id:"from_tt_beringin"}` | path | 1 |
| `K` | kabut K2, east exit of the arena (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq3_4"}` | path | 2 |
| `Z` | exit to tt_pasir (east edge, behind K2, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_pasir", spawn_id:"from_tt_ladang"}` | path | 2 |
| `z` | spawn, arrival from tt_pasir | `res://entities/world/spawn.tscn` | `{id:"from_tt_pasir"}` | path | 1 |
| `B` | boss Buto Ijo (arena 28x16: x 29..56, y 9..24) | `res://entities/bosses/buto_ijo.tscn` | `{}` | floor | 1 |
| `E` | encounter timur_ladang | `res://entities/world/encounter.tscn` | `{area_id:"timur_ladang", size:Vector2i(30,14), waves:[[[res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(8,0)], [res://entities/enemies/keris_hantu.tscn, Vector2i(4,-4)], [res://entities/enemies/banaspati.tscn, Vector2i(4,4)], [res://entities/enemies/kemamang.tscn, Vector2i(-6,-3)]]]}` | grass | 1 |
| `x` | loose keris hantu, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/keris_hantu.tscn` | `{}` | grass | 1 |
| `b` | loose banaspati, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/banaspati.tscn` | `{}` | grass | 1 |
| `v` | loose kemamang, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/kemamang.tscn` | `{}` | grass | 1 |
| `A` | chest: 160 Ilmu (north-west nook, rule 7 optional find, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"chest_tt_ladang", item_id:"ilmu:160"}` | grass | 1 |
| `C` | encounter timur_ladang_stakes (3.10 waking Keris ignites seven-generation curse stakes across the dry fields) | `res://entities/world/encounter.tscn` | `{area_id:"timur_ladang_stakes", size:Vector2i(15,9), waves:[[[res://entities/enemies/keris_hantu.tscn, Vector2i(-3,0)], [res://entities/enemies/banaspati.tscn, Vector2i(3,0)]]]}` | path | 1 |
| `L` | clue, the first red curse stake in the dry field, a name charring on it (3.10 `clue_examined:ladang_stake`; journal note only; ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"ladang_stake"}` | grass | 1 |
| `D` | clue, circular scorched grass trail in the dry field (SQ-T2 clue 1 of 2) | `res://entities/world/clue.tscn` | `{clue_id:"t2_burn_trail", cond:"quest:sq_t2=active"}` | grass | 1 |
| `F` | clue, unlit campsite in the field (SQ-T2 clue 2 of 2; opens memory `sq_t2_herder`) | `res://entities/world/clue.tscn` | `{clue_id:"t2_campfire", memory_id:"sq_t2_herder", cond:"quest:sq_t2=active"}` | grass | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_ladang` | `E (15,13)` | 30x14 | W1: Prajurit Terkutuk (+8,+0), Keris Hantu (+4,-4), Banaspati (+4,+4), Kemamang (-6,-3) | Ra Summon on Prajurit, Bind on Keris Hantu |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| north-west nook | (20,1)-(27,3) | Optional find, off the Buto Ijo road | chest `A` (26,2) | rule 7 |
| curse stake | (23,14) | The first stake of the waking Keris in the dry field, near the stakes fight `C` (21,16) | clue `L` (23,14) | 3.10 `ladang_stake`, `timur_ladang_stakes` |
## Area 6: tt_pasir

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: Pale sea-sand plain (floor tiles), a wide crater rim of black stones, the candi huge in the east, a sand alcove with petilasan 2.
- Purpose: Step 3.15 fight `timur_pasir` (2 waves), petilasan `timur_2` (3.16-3.17) with Hariang Banga's camp talk in the east alcove beside the link to tt_candi, plain exit to sabana (`sc:tt_pasir`).

### Map
```
##########################################################################################
#________________________________________________________________________________________#
#________________________________________________________________________________________#
#________________________________________________________________________________________#
#_______rr__________b_______________________________________rr___________________________#
#_______rr______j_________rr________________________________rr___________________________#
#_________________________rr__________________________rr_________________________________#
#_____________________________________________________rr_________________________________#
#___________x____________________________________________________________________________#
#________________________________________________________________________________________#
#________________________________________________________________________________________#
#_______________________________________________________________________________##########
#_______________________________________________________________________________#______r_#
#_______________________________________________________________________________#__H_____#
#_______________________________________________________________________________#________#
#_______________________________________________________________________________,_____P__#
Yy,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,G,,,,,,,,,,,,,,,,,,,,,cC
Y,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,C
#_________,,____________________________________________________________________,________#
#_________,,____________________________________________________________________#___I____#
#____rr___,,________________________________________K_____J___F_________________#________#
#____rr___,,____________________________________________________________________#______r_#
#_________,,______________________________________________________rr____________##########
#_________,,____________________________rr________________________rr_____________________#
#_________,,____________________________rr_______________________________________________#
#_________,,_____________________________________________________________________________#
#_________,,_____________________________________________________________________________#
##########,,##########################______##############################################
##########,,##########################______##############################################
##########,,##########################__D___##############################################
##########,,##########################______##############################################
##########,,##########################______##############################################
##########q,##########################__A___##############################################
##########XX############################BB################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `Y` | exit to tt_ladang (west edge, behind K2 on the ladang side, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_ladang", spawn_id:"from_tt_pasir"}` | path | 2 |
| `y` | spawn, arrival from tt_ladang | `res://entities/world/spawn.tscn` | `{id:"from_tt_ladang"}` | path | 1 |
| `X` | exit to tt_sabana (south-west wall, into the `sc:tt_pasir` gate pocket, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_sabana", spawn_id:"from_tt_pasir"}` | path | 2 |
| `q` | spawn, arrival from tt_sabana | `res://entities/world/spawn.tscn` | `{id:"from_tt_sabana"}` | path | 1 |
| `C` | exit to tt_candi (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_candi", spawn_id:"from_tt_pasir"}` | path | 2 |
| `c` | spawn, arrival from tt_candi | `res://entities/world/spawn.tscn` | `{id:"from_tt_candi"}` | path | 1 |
| `P` | petilasan 2 (sand alcove, no enemy inside) | `res://entities/petilasan/petilasan.tscn` | `{id:"timur_2"}` | floor | 1 |
| `E` | encounter timur_pasir | `res://entities/world/encounter.tscn` | `{area_id:"timur_pasir", size:Vector2i(36,16), waves:[[[res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(10,-3)], [res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(10,3)], [res://entities/enemies/banaspati.tscn, Vector2i(4,-5)], [res://entities/enemies/kemamang.tscn, Vector2i(-6,0)]],[[res://entities/enemies/keris_hantu.tscn, Vector2i(12,-3)], [res://entities/enemies/keris_hantu.tscn, Vector2i(12,3)]]]}` | path | 1 |
| `j` | loose prajurit terkutuk, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/prajurit_terkutuk.tscn` | `{}` | floor | 1 |
| `b` | loose banaspati, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/banaspati.tscn` | `{}` | floor | 1 |
| `x` | loose keris hantu, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/keris_hantu.tscn` | `{}` | floor | 1 |
| `H` | NPC Hariang Banga, camp talk at `timur_2` (optional, quiet; cond `flag:mq3_6`) | `res://entities/npc/npc.tscn` | `{npc_id:"hariang_banga", cond:"flag:mq3_6"}` | floor | 1 |
| `A` | spawn, arrival from tt_pesisir (south corridor, link L14) | `res://entities/world/spawn.tscn` | `{id:"from_tt_pesisir"}` | floor | 1 |
| `B` | exit to tt_pesisir (south edge, bottom of the south corridor, 2 tiles; link L14, the K4 kabut is on the pesisir side) | `res://entities/world/exit.tscn` | `{target_zone:"tt_pesisir", spawn_id:"from_tt_pasir"}` | floor | 2 |
| `D` | encounter timur_penjaga (**miniboss**, 3.15: the gatekeeper of the Sea of Sand, an elite Prajurit Terkutuk `timur_penjaga`) | `res://entities/world/encounter.tscn` | `{area_id:"timur_penjaga", size:Vector2i(10,6), waves:[[[res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(0,0)]]]}` | floor | 1 |
| `F` | trigger, puzzle `puzzle_pasir_dunes` (3.15: line up the three cairns with the Hunter's ash so the wind shows the safe way across the loose sand; sets `flag:puzzle_pasir_dunes`, no gate) | `res://entities/world/trigger.tscn` | `{trigger_id:"puzzle_pasir_dunes", size:Vector2i(16,8)}` | floor | 1 |
| `G` | trigger, beat `pasir_sight` staging (3.15: Candi Gandring across the sand; ASSUMED, no quest effect) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_pasir_sight", size:Vector2i(10,4)}` | path | 1 |
| `I` | clue, Laras's lontar fragment in the alcove (3.17, opens chapter `lc4`; ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"lc4_lontar", memory_id:"lc4", cond:"flag:mq3_6"}` | floor | 1 |
| `J` | trigger, ancient stone waymarkers in the Sea of Sand (3.15 puzzle `pasir_waymarkers`; its clue text is shown on `puzzle_solved:pasir_waymarkers`, the clue and the puzzle share the id, so no separate clue spot) | `res://entities/world/trigger.tscn` | `{trigger_id:"pasir_waymarkers", size:Vector2i(4,4)}` | floor | 1 |
| `K` | clue, Ranga's old shield mark / Lengser's note on the desert boundary stone (SQ-C3 fragment 2) | `res://entities/world/clue.tscn` | `{clue_id:"c3_road_mark", cond:"flag:mq3_6"}` | floor | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_pasir` | `E (35,17)` | 36x16 | W1: Prajurit Terkutuk (+10,-3), Prajurit Terkutuk (+10,+3), Banaspati (+4,-5), Kemamang (-6,+0); W2: Keris Hantu (+12,-3), Keris Hantu (+12,+3) | Ra Summon, Na Dash-strike; Bind on wave 2; Heal for Curse |
| `timur_penjaga` | `E (40,29)` | 10x6 | **Miniboss.** W1: Prajurit Terkutuk (0,0) elite `timur_penjaga` (HP x4, **TUNE**); the narrow corridor makes it a duel | Ra Summon turns the shield, then Dash-strike |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| south corridor (new, v4c) | (38,27)-(43,33) 6x7 | The coast road from `tt_pesisir`: spawn `A` (40,32), exit `B` (40..41,33), the gatekeeper at the mouth | E `D` (40,29) `timur_penjaga` | 3.15 miniboss |
| dune field | (55,12)-(75,24) | Puzzle and sight | trigger `F` (62,20), trigger `G` (66,16) | 3.15 puzzle, beat |
| alcove | (81,12)-(88,21) | Petilasan `timur_2`, camp talk, Laras's fragment | clue `I` (84,19) | 3.17 chapter |
## Area 7: tt_candi

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Banyan courtyard in front of Candi Gandring (stepped shrine, keris spire), seven curse stakes at the arena edge.
- Purpose: Boss arena: beat `shrine_sight`, Mpu Gandring's Keris (3.19), beats `keris` and `hunter_shrine`, then the Nameless Hunter (3.22) in the same court, then beat `hunter_name` (interior x 19..52, y 5..28). Only exit: west, back to tt_pasir.

### Map
```
############################################################
#..........................................................#
#..........................................................#
#..........................................................#
#.....rr..........####################################.....#
#.....rr..........#__________________________________#.....#
#...........rr....#__1______________2______________3_#.....#
#...........rr....#__________________________________#.....#
#.................#__________________________________#..rr.#
#.................#__________________________________#..rr.#
#.................#_________________H________________#.....#
#.................#___________N______________________#.....#
#.................#__________________________________#.....#
#.................#_________________R________________#.....#
#.................#__________________________________#.....#
#.................,__________________________________#.....#
Xe,,,,,,,,,,,,,,,,,__E__S___________B___C________D___#.....#
X,,,,,,,,,,,,,,,,,,________________________________4_#.....#
#.................,__________________________________#.....#
#.................#_____________W___K________________#.....#
#.................#__________________________________#.....#
#.................#__________________________________#.....#
#.................#__________________________________#..rr.#
#.................#__________________________________#..rr.#
#.................#__________________________________#.....#
#.................#__________________________________#.....#
#...........rr....#__________________________________#.....#
#...........rr....#__7______________6______________5_#.....#
#.......rr........#__________________________________#.....#
#.......rr........####################################.....#
#..........................................................#
#..........................................................#
#..........................................................#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to tt_pasir (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_pasir", spawn_id:"from_tt_candi"}` | path | 2 |
| `e` | spawn, arrival from tt_pasir | `res://entities/world/spawn.tscn` | `{id:"from_tt_pasir"}` | path | 1 |
| `B` | boss Mpu Gandring's Keris (3.19, arena centre; wakes after the `shrine_sight` beat) | `res://entities/bosses/keris_gandring.tscn` | `{cond:"flag:beat_shrine_sight"}` | floor | 1 |
| `H` | boss the Nameless Hunter, after the keris (MQ3 3.22) | `res://entities/bosses/nameless_hunter.tscn` | `{cond:"flag:mq3_h6"}` | floor | 1 |
| `1` | curse stake 1 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:1}` | floor | 1 |
| `2` | curse stake 2 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:2}` | floor | 1 |
| `3` | curse stake 3 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:3}` | floor | 1 |
| `4` | curse stake 4 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:4}` | floor | 1 |
| `5` | curse stake 5 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:5}` | floor | 1 |
| `6` | curse stake 6 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:6}` | floor | 1 |
| `7` | curse stake 7 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:7}` | floor | 1 |
| `S` | trigger, beat `shrine_sight` staging (Laras across the shrine; `flag:mq3_6`, `flag:beat_laras_4`, `zone:tt_candi`) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_shrine_sight", size:Vector2i(6,6)}` | floor | 1 |
| `K` | trigger, beat `keris` staging (choice 3; `flag:mq3_7`) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_keris", size:Vector2i(10,6)}` | floor | 1 |
| `W` | NPC Mpu Wirasana, hands over the reforged keris in the `keris` beat | `res://entities/npc/npc.tscn` | `{npc_id:"timur_empu", cond:"flag:mq3_7,!flag:beat_keris"}` | floor | 1 |
| `R` | trigger, beat `hunter_shrine` staging (the restore beat; `flag:beat_keris`) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_hunter_shrine", size:Vector2i(10,4)}` | floor | 1 |
| `N` | trigger, beat `hunter_name` staging (aftermath, then `goto:desa_purwa:from_riders`; `quest:mq3=done`) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_hunter_name", size:Vector2i(12,8)}` | floor | 1 |
| `C` | clue, the last mask fragment where the keris lay (3.21 H4; opens memory `h4`; appears when `flag:beat_keris`) | `res://entities/world/clue.tscn` | `{clue_id:"hunter_mask_4", memory_id:"h4", cond:"flag:beat_keris"}` | floor | 1 |
| `D` | clue, the joined mask at the shrine door (3.21 K6; opens memory `k6_servant`; appears when `flag:mq3_h7`) | `res://entities/world/clue.tscn` | `{clue_id:"mask_joined", memory_id:"k6_servant", cond:"flag:mq3_h7"}` | floor | 1 |
| `E` | trigger, inner sanctum entry via Laras's wind-tunnel shortcut (3.18 `candi_inner_sanctum`) | `res://entities/world/trigger.tscn` | `{trigger_id:"candi_inner_sanctum", size:Vector2i(5,4)}` | floor | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| clue spots | `hunter_mask_4` (40,16) east of the keris `B` (37,16); `mask_joined` (49,16) at the east shrine door (`forge_stone` is no longer here: it is in Wirasana's vault in `tt_beringin`) | Walked in this order | clues `C` `D` | 3.21 |
## Area 8: tt_pesisir

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Dunes, a dry shore, driftwood, a wreck in the east dunes, a pale sea fog (kabut K3) on the south edge.
- Purpose: Main-path coast (step 3.14): dune hollow fight `timur_pesisir`, burn-trail trigger, Banaspati elite, chest, kuda kepang 3, drop landing from beringin, back link to sabana, kabut K3 `mq4_9` (back route, opens on `quest:mq4=done`) to sk_karang.

### Map
```
############################NN##############################
#...........................n,.............................#
#...........................,,.............................#
#...........................,,.............................#
#...........................,,................l............#
#...........................,,.............................#
#.......rr..................,,..........rr.................#
#.......rr..................,,..........rr.................#
#.............B.............,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#.............rr............,,....................q....#####
#.............rr............,,.........................@.C.D
#.....rr....................,,.........................@...D
#.....rr....................,,.........................#####
#...........................,,.............................#
#.....................T.....,,..E..........................#
#...........................,,.............................#
#...........................,,.............................#
#.........rr................,,......................rrrrrr.#
#.........rr................,,......................r....r.#
#.............A.............,,.........................c.r.#
#...........................,,......................r....r.#
#.......k...................,,......................r....r.#
#...........................,,......................rrrrrr.#
#...........................,,..............rr.............#
#.................rr........,,..............rr.............#
#.................rr........,,.............................#
############################KK##############################
############################,,##############################
############################,,##############################
############################g,##############################
############################SS##############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `N` | exit to tt_sabana (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_sabana", spawn_id:"from_tt_pesisir"}` | path | 2 |
| `n` | spawn, arrival from tt_sabana | `res://entities/world/spawn.tscn` | `{id:"from_tt_sabana"}` | path | 1 |
| `l` | spawn, landing of the drop from tt_beringin (no exit back) | `res://entities/world/spawn.tscn` | `{id:"from_tt_beringin"}` | path | 1 |
| `K` | kabut K3, south edge (one per tile; opens on `quest:mq4=done`) | `res://entities/world/kabut.tscn` | `{flag:"mq4_9"}` | path | 2 |
| `S` | exit to sk_karang (south edge, not built yet, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_karang", spawn_id:"from_tt_pesisir"}` | path | 2 |
| `g` | spawn, arrival from sk_karang | `res://entities/world/spawn.tscn` | `{id:"from_sk_karang"}` | path | 1 |
| `q` | elite Banaspati (SQ-T2, at the spring in the east dunes, `unique_id` `banaspati_elite`, elite stats HP x4, Ilmu x4, **TUNE**; inert until step 4) | `res://entities/enemies/banaspati_elite.tscn` | `{unique_id:"banaspati_elite"}` | grass | 1 |
| `T` | trigger, burn trail reached (SQ-T2) | `res://entities/world/trigger.tscn` | `{trigger_id:"burn_trail", size:Vector2i(6,6)}` | grass | 1 |
| `c` | chest: 220 Ilmu (wreck, secret) | `res://entities/world/chest.tscn` | `{chest_id:"chest_tt_pesisir", item_id:"ilmu:220"}` | grass | 1 |
| `k` | pickup, kuda kepang 3 (SQ-T4) | `res://entities/world/pickup.tscn` | `{item_id:"kuda_kepang_3"}` | grass | 1 |
| `E` | encounter timur_pesisir | `res://entities/world/encounter.tscn` | `{area_id:"timur_pesisir", size:Vector2i(20,11), waves:[[[res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(7,0)], [res://entities/enemies/banaspati.tscn, Vector2i(3,-3)], [res://entities/enemies/banaspati.tscn, Vector2i(3,3)]]]}` | grass | 1 |
| `A` | clue, the Hunter's cold ash trail (3.14 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"ash_trail"}` | grass | 1 |
| `B` | encounter timur_dune (3.14, second fight, north dunes) | `res://entities/world/encounter.tscn` | `{area_id:"timur_dune", size:Vector2i(16,9), waves:[[[res://entities/enemies/banaspati.tscn, Vector2i(-4,-1)], [res://entities/enemies/banaspati.tscn, Vector2i(3,2)], [res://entities/enemies/banaspati.tscn, Vector2i(6,-2)]]]}` | grass | 1 |
| `@` | kabut K4, the coast road to `tt_pasir` (one per tile; lifts on `mq3_h4`, step 3.12) | `res://entities/world/kabut.tscn` | `{flag:"mq3_h4"}` | grass | 2 |
| `C` | spawn, arrival from tt_pasir (inside the east pocket) | `res://entities/world/spawn.tscn` | `{id:"from_tt_pasir"}` | grass | 1 |
| `D` | exit to tt_pasir (east edge, east pocket behind K4, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_pasir", spawn_id:"from_tt_pesisir"}` | path | 2 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_pesisir` | `E (32,17)` | 20x11 | W1: Prajurit Terkutuk (+7,+0), Banaspati (+3,-3), Banaspati (+3,+3) | Ra Summon |
| `timur_dune` | `E (14,8)` | 16x9 | W1: Banaspati (-4,-1), Banaspati (+3,+2), Banaspati (+6,-2) | Ga Ward |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| north dunes | (6,4)-(22,12) | Second fight of 3.14 | E `B` (14,8) `timur_dune` | 3.14 fight |
| ash trail | clue `A` (14,22) | The trail runs west to east along the dunes | `ash_trail` | 3.14 `clue` |
| east pocket (new, v4c) | (55,13)-(59,14) 5x2, walls (55..59,12) and (55..59,15) | The coast road into the Sea of Sand: kabut `@` (55,13..14) lifts on `mq3_h4`, spawn `C` (57,13), exit `D` (59,13..14) | link L14 to `tt_pasir` | 3.7 |
