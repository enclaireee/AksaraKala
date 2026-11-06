# Tanah Timur (region id `tanah_timur`), Act 3

Region graph on paper (graph level only, no tile maps until Phase 5). Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5). Area id prefix: `tt_`. Sources: [world.md](../world.md) (Technical frame, World structure, Tanah Timur, Checkpoints, Points of interest), [bestiary.md](../bestiary.md) (Zone 3, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ3, Tanah Timur side quests, 3.4, 7.5), [tatar_sunda.md](tatar_sunda.md) (format). Change the layout here first, then in code.

**Look and landmark.** Dry gold savanna, a dry riverbed and a narrow canyon, a banyan grove with old shrine ruins and a forge, and a pale sea-sand plain under a ridge. The Bromo/Tengger landscape is scenery only (no quest, no mechanic, no enemy event). The landmark is **Candi Gandring**, the boss site (`tt_candi`): a tall stepped shrine with a giant banyan crown and a thin keris-blade spire, always drawn as a dark silhouette on the east horizon. It shows from the first screen of `tt_kulon` (behind a haze), stands clearer over the savanna in `tt_sabana`, sits above the canyon wall in `tt_kali`, and fills the sky over `tt_pasir`. Tone stays warm and cartoonish: the wraith is spooky but sad, the dead are cheerful ghosts, nothing is lost on death.

## Areas
Sizes: 1 screen = 30x17 tiles. 2x2 = 60x34, 3x2 = 90x34, 3x3 = 90x51. Total 8 areas, 43 screens.

| id | screens / tiles | look | purpose | contents |
|----|-----------------|------|---------|----------|
| `tt_kulon` | 2x2 / 60x34 | Burnt-gold grass, a broken stone gate, Mataram kabut on the west edge | Entry, gentle first fights, first view of the landmark | Spawn `from_mt_wetan`. E `timur_kulon` (west half). E `timur_gerbang` at the ruined gate (east end, leads to `tt_sabana`). Kabut `K1` at the west exit. Landmark silhouette on the east horizon. No NPC, no petilasan. |
| `tt_sabana` | 3x3 / 90x51 | Open savanna, termite mounds, acacia, a dry pond, a wooden back-road door in the west wall | Hub of the region. Petilasan, side-quest givers, door to Mataram | Petilasan `timur_1` (west-centre, 6 tiles from the kulon link). E `timur_embers` (open centre). Herder `timur_herder` (SQ-T2 giver) near `timur_1`. Secret chest `chest_tt_sabana` in a mound ring (south-west). Kuda kepang pickup `kuda_kepang_1`. Burn-trail path (SQ-T2) to the south, ends at `tt_pesisir`. Gate `sc:mt_tt` in the west wall (north end) to `mt_tegal`. Gate `sc:tt_pasir` in the east wall (north end). Exits: kulon (W), kali (N), beringin (E), pesisir (S). |
| `tt_kali` | 3x2 / 90x34 | West half: dry riverbed with rocks and one trickle channel. East half: a narrow canyon with red walls | Teach Kemamang and Keris Hantu, two NPCs, the long way to Buto Ijo | E `timur_wisps` (riverbed, west half). E `timur_ngarai` (canyon, east half, straight 12-tile lanes). Mbok Srini `mbok_srini` at her hut (middle, between the two halves). Klething Kuning `klething_kuning` at the river crossing (riverbed) with elite Yuyu Kangkang `yuyu_kangkang` (SQ-T1). Kuda kepang pickup `kuda_kepang_2` (riverbed). Exits: sabana (S-W), ladang (E). |
| `tt_beringin` | 3x2 / 90x34 | Giant banyan grove, hanging roots, cracked shrine ruins, a forge under a banyan, a troupe camp | Empu forge, codex ruin, performance, drop to the coast | Mpu Wirasana `timur_empu` at the forge. Practice marks (3 stakes) in the forge yard. Kuda lumping leader `kepang_leader` at the camp and stage `kepang_stage`. Sodo lanang pickup `sodo_lanang` (SQ-T1) in the shrine. Codex ruin `codex_ruin` (2 inscribed stones, 1 statue plinth). Secret chest `chest_tt_beringin` in a hollow banyan (north-east). Drop ledge `drop_pesisir` (south rim). Gate `sc:tt_ladang` (north wall, seen from the inside as a root-choked door). Exits: sabana (W). No fight room: a quiet area. |
| `tt_ladang` | 2x2 / 60x34 | Dry field of dead cucumber vines, a dark lair of hanging bones and a lamp | Buto Ijo's field and miniboss arena | E `timur_ladang` (field, west half). Root-gate `sc:tt_ladang` (south wall of the field, opens from this side). Miniboss `buto_ijo` in the arena (east half, 28x16). Kabut `K2` at the east exit, lifts when Buto Ijo is beaten. Exits: kali (W), beringin (sc), pasir (E, kabut). |
| `tt_pasir` | 3x2 / 90x34 | Pale sea-sand plain, a wide crater rim, black stones, the landmark huge in the east | The last fight, petilasan 2, then the boss gate | E `timur_pasir` (centre, two waves). Petilasan `timur_2` (east end, in a sand alcove, no enemy inside). Stone sentries (decor) at the candi gate. Gate `sc:tt_pasir` (south-west wall) to sabana. Overlook with the Tengger sign (scenery, optional text in the codex ruin). Exits: ladang (W, kabut), candi (E), sabana (sc). |
| `tt_candi` | 2x2 / 60x34 | Banyan courtyard in front of Candi Gandring, seven curse stakes | Boss arena | Boss `keris_gandring` (Mpu Gandring's Keris). 7 curse-mark stakes at the arena edge. Entered only from the `timur_2` alcove side of `tt_pasir`. Exits: pasir (W) only. |
| `tt_pesisir` | 2x2 / 60x34 | Dunes, a dry shore, driftwood, a pale sea fog on the south edge | Optional coast with elite and secret, back door to Segara Kidul | E `timur_pesisir`. Elite Banaspati `banaspati_elite` (SQ-T2). Kuda kepang pickup `kuda_kepang_3`. Secret chest `chest_tt_pesisir` (wreck in the dunes, east). Kabut `K3` at the south edge to `sk_karang`. Drop landing from `tt_beringin`. Exits: sabana (N), sk_karang (S, kabut). |

Quest NPCs: 5 (Mpu Wirasana, Mbok Srini, Klething Kuning, the herder, the kuda lumping leader). Elites: Yuyu Kangkang, Banaspati elite. Miniboss: Buto Ijo. Secrets: 3 chests. Codex: 1 location (`tt_beringin`). Petilasans: `timur_1` (`tt_sabana`), `timur_2` (`tt_pasir`).

## Region graph
`==K==` kabut, `--` link, `~~sc~~` shortcut gate (opens from the tagged side), `--v` drop. Flags: `K1` mq2_9 (Hariang Banga yields), `K2` mq3_4, `K3` mq3_8 (the Hunter beaten); Story v2.
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
| 1 | `mt_wetan` | `tt_kulon` | link, kabut `K1` | `mq2_9` (set by MQ2 2.9, the Pamali duel) | `from_mt_wetan` (in kulon), `from_tt_kulon` (in mt_wetan) |
| 2 | `tt_kulon` | `tt_sabana` | link | none | `from_tt_kulon` (in sabana), `from_tt_sabana` (in kulon) |
| 3 | `tt_sabana` | `tt_kali` | link | none | `from_tt_sabana` (kali), `from_tt_kali` (sabana) |
| 4 | `tt_sabana` | `tt_beringin` | link | none | `from_tt_sabana` (beringin), `from_tt_beringin` (sabana) |
| 5 | `tt_sabana` | `tt_pesisir` | link | none | `from_tt_sabana` (pesisir), `from_tt_pesisir` (sabana) |
| 6 | `tt_kali` | `tt_ladang` | link | none | `from_tt_kali` (ladang), `from_tt_ladang` (kali) |
| 7 | `tt_ladang` | `tt_pasir` | link, kabut `K2` | `mq3_4` (Buto Ijo beaten, ASSUMED) | `from_tt_ladang` (pasir), `from_tt_pasir` (ladang) |
| 8 | `tt_pasir` | `tt_candi` | link (starts at the `timur_2` alcove) | none | `from_tt_pasir` (candi), `from_tt_candi` (pasir) |
| 9 | `tt_sabana` | `mt_tegal` | shortcut `sc:mt_tt` | `sc:mt_tt` (opened from sabana) | `from_mt_tegal` (sabana), `from_tt_sabana` (mt_tegal) |
| 10 | `tt_ladang` | `tt_beringin` | shortcut `sc:tt_ladang` | `sc:tt_ladang` (opened from ladang) | `from_tt_beringin` (ladang), `from_tt_ladang` (beringin) |
| 11 | `tt_pasir` | `tt_sabana` | shortcut `sc:tt_pasir` | `sc:tt_pasir` (opened from pasir) | `from_tt_pasir` (sabana), `from_tt_sabana` (pasir; second spawn on the shortcut side) |
| 12 | `tt_beringin` | `tt_pesisir` | drop | none | `from_tt_beringin` (pesisir); nothing leads back up the ledge |
| 13 | `tt_pesisir` | `sk_karang` | link, kabut `K3` | `mq3_8` (set by MQ3 3.8, the Hunter) | `from_tt_pesisir` (sk_karang), `from_sk_karang` (pesisir) |

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

**Drop:** `drop_pesisir`, `tt_beringin` south rim to `tt_pesisir` north dunes (a dune slide). No exit leads up. The player is never stuck: `tt_pesisir` has a normal link back to `tt_sabana`.

**Critical path (MQ3 order):** `mt_wetan` -> `tt_kulon` (E `timur_kulon`, E `timur_gerbang`) -> `tt_sabana` (`timur_1`, 3.1; E `timur_embers`) -> `tt_beringin` (empu, 3.2; opens SQ-T3) -> `tt_sabana` -> `tt_kali` (E `timur_wisps`, Mbok Srini and the pouches, 3.3; E `timur_ngarai`) -> `tt_ladang` (E `timur_ladang`, open `sc:tt_ladang`, Buto Ijo, 3.4) -> `sc:tt_ladang` -> `tt_beringin` (empu, practice marks, 3.5) -> `sc:tt_ladang` back -> `tt_ladang` -> `tt_pasir` (E `timur_pasir`, `timur_2`, 3.6) -> `tt_candi` (keris, 3.7; the Hunter, 3.8). Story v2: no walk home to Semar; the Gua Kala gate in Desa Purwa opens on `mq3_8`.

**Optional areas:** `tt_pesisir` only (Loop C): elite Banaspati, secret chest, kuda kepang, back door to Segara Kidul. Optional rooms inside areas: the sabana mound ring (secret), the hollow banyan (secret), the codex ruin, the performance stage.

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
| `timur_pesisir` | `tt_pesisir` | dune hollow | 20x11 | W1: Prajurit Terkutuk, 2 Banaspati | Old guard repeat (optional) | Ra Summon |
| `timur_pasir` | `tt_pasir` | sand plain before `timur_2` | 36x16 | W1: 2 Prajurit Terkutuk, Banaspati, Kemamang ; W2: 2 Keris Hantu | Before the keris (two-tank exception) | Ra Summon, Na Dash-strike, Bind on wave 2, Heal for Curse |

8 encounters (6-10). Extra fights: Yuyu Kangkang (elite charger, riverbed crossing, 12-tile lane), Banaspati elite (SQ-T2, `tt_pesisir` east dunes), Buto Ijo (miniboss), Keris (boss). Tank rule: gerbang, ladang, pesisir have 1 tank, pasir has 2 (allowed before the boss). Shooters: ladang 1, pasir 1, wisps 2 (a pure shooter room, no tank, per bestiary). Waves: pasir has 2, all others 1.

**Main-path kills (balance.md 2.1 target ~40):** 24 before (fixed encounters only: kulon 2, gerbang 3, embers 4, wisps 2, ngarai 3, ladang 4, pasir 6; no loose enemies on the path; bosses, Yuyu, Banaspati elite and `tt_pesisir` not counted), 40 after 16 loose roaming-pack enemies (kulon 2 Banaspati, sabana 3, beringin 3, kali 2 Kemamang, ladang 3, pasir 3; Prajurit at most 1 per pack, Kemamang only after `timur_wisps`, Keris Hantu only in ladang and pasir, after `timur_ngarai`).

First appearances (teach, then test):
| Enemy | First seen | Player glyphs there | Weakness usable |
|-------|-----------|--------------------|-----------------|
| Banaspati | `timur_kulon` (2, alone) | Ka, Ga, Nga, Ca (Sunda), Ha, Na, Ra | Ward, yes |
| Prajurit Terkutuk | `timur_gerbang` (1 with 2 known Banaspati) | same | Summon, yes (newest glyph with a weakness) |
| Kemamang | `timur_wisps` (2 alone, rocks for cover) | same | Dash-strike, yes |
| Keris Hantu | `timur_ngarai` (3 alone, after wisps) | same | Bind, yes |

Order is guaranteed: `timur_wisps` and `timur_ngarai` are in `tt_kali`, which is only reachable from `tt_sabana` before `sc:tt_ladang` is opened; `timur_ladang` is only reachable through `tt_kali` the first time. `timur_pesisir` and the sabana fights use only Banaspati and Prajurit.

## Buto Ijo (miniboss room)
Arena in `tt_ladang`, east half, 28x16, with the lamp-lit lair. Four phases, one pouch per phase (cucumber seeds: bramble field, needles: bamboo forest, salt: saltwater, terasi: mud). **VERIFY** the legend's items (bestiary.md). Mbok Srini hands over the pouches in `tt_kali` before the fight. Timun Mas runs off as in the legend. HP 3400. Kabut `K2` lifts on the death (`mq3_4`), the field gate `sc:tt_ladang` must be opened before the arena to give a short retry path.

## Quest steps and markers
Marker form `{zone: "tanah_timur", id: ...}`. Ids from quests.md marked (Q); others are **ASSUMED**.

### Main quest MQ3
| Step | Marker id | Area | Event string |
|------|-----------|------|--------------|
| (entry) | `timur_edge` | `tt_kulon` | `zone_entered:tanah_timur` |
| 3.1 rest at the savanna petilasan | `timur_1` (Q) | `tt_sabana` | `petilasan_activated:timur_1` (Q); sets `mq3_1` |
| 3.2 find the empu | `timur_empu` (Q) | `tt_beringin` | `talked_to:timur_empu` (Q); sets `mq3_2`. Makes SQ-T3 available |
| 3.3 help Mbok Srini | `mbok_srini` (Q) | `tt_kali` | `talked_to:mbok_srini` (Q); sets `mq3_3`, gives the 4 pouches |
| 3.4 defeat Buto Ijo | `buto_ijo` | `tt_ladang` | `boss_defeated:buto_ijo` (Q); sets `mq3_4` (opens `K2`) |
| 3.5 break two practice curse marks | `timur_praktik` | `tt_beringin` | `area_entered:timur_praktik_mark` x2 (the empu taught it at 3.2, Story v2) |
| 3.6 rest before the shrine | `timur_2` (Q) | `tt_pasir` | `petilasan_activated:timur_2` (Q); Laras beat 4 |
| 3.7 lay the keris to rest | `keris_gandring` | `tt_candi` | `boss_defeated:keris_gandring` (Q); sets `mq3_7`; beat `keris` (choice 3) |
| 3.8 face the Nameless Hunter | `nameless_hunter` | `tt_candi` (`H`, cond `flag:beat_keris`) | `boss_defeated:nameless_hunter` (Q); sets `mq3_8` (opens `K3` and the Gua Kala gate) |

### Side quests
| Quest | Step | Marker id | Area | Event string |
|-------|------|-----------|------|--------------|
| SQ-T1 (giver `klething_kuning`, unlock 3.1) | 1 talk, crab blocks | `klething_kuning` | `tt_kali` | `talked_to:klething_kuning` |
| | 2a peaceful: fetch the stick | `sodo_lanang` | `tt_beringin` | `item_picked:sodo_lanang` |
| | 2b fight | `yuyu_kangkang` | `tt_kali` | `enemy_killed:yuyu_kangkang` |
| | 3 resolve | `klething_kuning` | `tt_kali` | `talked_to:klething_kuning` |
| SQ-T2 (giver `timur_herder`, unlock 3.1) | 1 grass fires | `timur_herder` | `tt_sabana` | `talked_to:timur_herder` |
| | 2 follow the burn trail | `burn_trail` | `tt_sabana` to `tt_pesisir` | `area_entered:burn_trail` (trigger at the dune hollow) |
| | 3 defeat the elite | `banaspati_elite` | `tt_pesisir` | `enemy_killed:banaspati_elite`; then `talked_to:timur_herder` |
| SQ-T3 (giver `timur_empu`, unlock 3.2) | 1 the empu asks | `timur_empu` | `tt_beringin` | `talked_to:timur_empu` |
| | 2 find the meteorite in Mataram | `batu_bintang` | `mt_candi` (east yard, see mataram.md) | `item_picked:batu_bintang`; walk is short via `sc:mt_tt` |
| | 3 bring it back | `timur_empu` | `tt_beringin` | `talked_to:timur_empu` (reward: Keris Luk 7) |
| SQ-T4 (giver `kepang_leader`, unlock 3.1) | 1 talk | `kepang_leader` | `tt_beringin` | `talked_to:kepang_leader` |
| | 2 find 3 kuda kepang | sparkle only (no marker) | `tt_sabana`, `tt_kali`, `tt_pesisir` | `item_picked:kuda_kepang_1` to `kuda_kepang_3` |
| | 3 return and watch | `kepang_stage` | `tt_beringin` | `talked_to:kepang_leader` then `area_entered:kepang_stage` (performance only, no trance) |
| Codex | | `codex_ruin` | `tt_beringin` | `codex:keris`, `codex:mpu_gandring`, `codex:tengger_lautan_pasir` (short, factual, **VERIFY**) |

Flags set or read: `mq2_9` (read, `K1`), `mq3_4` (set, `K2`), `mq3_7` (set), `mq3_8` (set, `K3`). Shortcut flags: `sc:mt_tt`, `sc:tt_ladang`, `sc:tt_pasir`.

## Flow
Enter `tt_kulon` (landmark on the horizon) -> `timur_kulon` (Ward teach) -> `timur_gerbang` (Prajurit, Summon) -> `tt_sabana` and petilasan **`timur_1`** -> forge in `tt_beringin` (empu) -> `tt_kali` wisps (Dash) and canyon (Bind), Mbok Srini -> `tt_ladang` patrol, open the root gate, **Buto Ijo (miniboss)** -> `sc:tt_ladang` to the forge (curse practice) -> `tt_pasir` before-the-keris fight -> petilasan **`timur_2`** -> **Mpu Gandring's Keris (boss)** in `tt_candi`. Branch: drop to `tt_pesisir`, back door `sc:mt_tt`, shortcuts `sc:tt_ladang` and `sc:tt_pasir`.

## Step 2 self-check ([AGENTS.md](../../AGENTS.md) section 5)
- [x] POI counts: 1 boss arena (`tt_candi`), 1 miniboss (Buto Ijo) plus 2 elites, 5 NPCs, 3 secrets (sabana mound ring, hollow banyan, pesisir wreck), 1 codex spot (`codex_ruin`), 8 encounters, 2 petilasans.
- [x] Petilasan before the boss, no fight between: `timur_2` is in the east alcove of `tt_pasir`, next to the link to `tt_candi`. `timur_pasir` is in the west and centre of the plain, before the alcove. The alcove and the link hold no enemies.
- [x] Each enemy first appears alone or with known enemies with a usable weakness: table above.
- [x] One tank per encounter (2 only in `timur_pasir`), at most one shooter (wisps is the shooters-only room by the bestiary mix), at most two waves (pasir only).
- [x] Rooms with 4+ enemies are at least 15x9: `timur_embers` 26x14, `timur_ladang` 30x14, `timur_pasir` 36x16. Charger lanes 8 tiles: `timur_ngarai` lanes 12, Yuyu Kangkang crossing 12, `timur_pasir` east lane for wave 2 Keris Hantu 14, `timur_ladang` east lane 10.
- [~] Newest glyph: the zone's stretch/diacritic marks are rewards without enemy weakness (spells.md). The newest glyph with a weakness is Ra Summon (Prajurit): the clean answer in `timur_gerbang`, `timur_ladang`, `timur_pasir`. See conflicts.
- [x] Every quest marker and flag in quests.md for this zone has a room (table above).
- [x] The critical path needs no glyph for any door. Kabut open on flags set by fights and talks. Step 3.5 asks for two `spell_cast` on practice marks with any glyph (a quest action, not a door).

**Interlock rules ([world.md](../world.md))**
1. [x] 3 loops (A, B closed by shortcuts, C by the drop).
2. [x] 3 shortcuts. Each ends in `tt_sabana` (has `timur_1`) or `tt_beringin` (one link from it).
3. [x] 1 drop (`drop_pesisir`).
4. [x] The only optional area, `tt_pesisir`, sits on Loop C and has a link back to `tt_sabana`.
5. [x] Landmark visible from `tt_kulon`, nearer in `tt_sabana`, `tt_kali`, `tt_pasir`.
6. [x] `timur_2` right before `tt_candi`, no fight between.
7. [x] 2 petilasans; shortcuts do the work of lamps.
8. [x] The critical path visits 7 of 8 areas. Gates: `K1` Mataram boss, `K2` Buto Ijo, `K3` Keris boss. Glyphs are rewards, not keys.

## ASSUMED
- All area ids beyond the three fixed ones (`tt_kulon`, `tt_sabana`, `tt_pesisir`), the `timur_*` encounter ids, the npc_ids, marker ids, chest ids and the `kuda_kepang_*` ids.
- Flags `mq2_9`, `mq3_4`, `mq3_7`, `mq3_8`. Region gates lift on boss fights (Story v2: 2.9 Hariang Banga, 3.8 the Hunter).
- Mbok Srini lives in `tt_kali` and Klething Kuning at the river crossing in the same area (the river is a trickle in a dry riverbed).
- The sodo lanang is a pickup in the banyan shrine (the source for the legend is VERIFY).
- Drop `drop_pesisir` is a dune slide; sizes 3x2 are allowed by the 60/90 x 34/51 rule.
- Story v2: 3.8 is the Hunter in `tt_candi`, so there is no walk home; `sc:mt_tt` and `sc:tt_pasir` stay as loops.
- The meteorite fragment `batu_bintang` lies in `mt_candi` (east yard).
- The `timur_wisps` encounter has no tank or chaser, as the bestiary mix lists only 2 Kemamang.

## Open questions
1. Mataram: confirm `mt_wetan`/`mt_tegal` exist in the Mataram doc, and where `batu_bintang` lies.
2. Resolved by the main session: `K3` lifts at 3.8 (`mq3_8`, Semar), matching quests.md.
3. Resolved 2026-11-05 (ASSUMED): Semar stands in `desa_purwa` only, as for 2.9.
4. Resolved 2026-11-05 (ASSUMED): the practice stakes stay. Any glyph counts, so this is a quest action, not a lock (bestiary.md, practice marks).
5. Resolved 2026-11-05 (ASSUMED): the peaceful route starts in the shrine (`sodo_lanang` pickup). Who gave it stays **VERIFY**; game text does not name the giver.
6. Resolved 2026-11-05: Banaspati elite and Yuyu Kangkang are named elites in bestiary.md.
7. Resolved 2026-11-05: `batu_bintang` lies in `mt_candi` (east yard), as built in mataram.md. The SQ-T3 marker uses `mt_candi`.

## Doc conflicts found (not fixed)
- bestiary.md Encounters "Embers" (4 Banaspati) would be the first Banaspati encounter if met alone in the savanna. Here `timur_kulon` (2 Banaspati) teaches first and `timur_embers` comes second.
- world.md says the Mataram kabut lifts when the Mataram boss is beaten; quests.md 2.9 says the fog lifts on talking to Semar.
- world.md link table: `tt_pesisir` kabut lifts on the third boss; quests.md MQ3 says the Segara Kidul path opens after 3.8 (Semar).
- quests.md 3.5 completes on `spell_cast` (a cast), while the checklist says glyphs are rewards, not keys. Treated as a quest action, not a gate.
- quests.md SQ-T2 needs an elite Banaspati: added to bestiary.md (fixed 2026-11-05).
- quests.md SQ-T1 needs a river with a crab; bestiary.md puts Kemamang in a dry riverbed. Resolved with a dry bed plus one trickle channel.
- world.md "Points of interest" asks for 1 miniboss or elite room; MQ3 3.4 makes Buto Ijo mandatory, so the miniboss is on the critical path rather than off a loop (rule 4 only applies to optional areas).

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
#...........................................##.............#
#...........................................##.............#
#...........................................##.............#
#...........................................rr.............#
#...........................................rr.............#
#######....................................................#
Xe,,K,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,,,,,,,,,,,,,G,,,,,,,,,yY
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

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_kulon` | `E (22,16)` | 20x11 | W1: Banaspati (+6,-3), Banaspati (+6,+3) | Ga Ward snuffs the Banaspati |
| `timur_gerbang` | `G (48,16)` | 18x10 | W1: Prajurit Terkutuk (+7,+0), Banaspati (+3,-3), Banaspati (+3,+3) | Ra Summon turns the shield; Ward on Banaspati |

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
#.........H...................,,.........................................................#
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
#...rr..............................~~........,..........................................#
#...rr..............................~~........,..........................................#
#.............................................,..........................................#
#.............................................,..........................................#
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,u,,,,,,,,,,,,,,,,,,,,,,,,,,,,,G,,,,,,,,,,,,,,,,,yY
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,K,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#.......,,...............................................................................#
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
| `M` | NPC Mbok Srini (3.3, pouches) | `res://entities/npc/npc.tscn` | `{npc_id:"mbok_srini"}` | floor | 1 |
| `K` | NPC Klething Kuning (SQ-T1 giver, river crossing) | `res://entities/npc/npc.tscn` | `{npc_id:"klething_kuning"}` | grass | 1 |
| `u` | elite Yuyu Kangkang (SQ-T1, charger lane x 38..49 on row 16) | `res://entities/enemies/yuyu_kangkang.tscn` | `{}` | path | 1 |
| `k` | pickup, kuda kepang 2 (SQ-T4, riverbed) | `res://entities/world/pickup.tscn` | `{item_id:"kuda_kepang_2"}` | grass | 1 |
| `E` | encounter timur_wisps | `res://entities/world/encounter.tscn` | `{area_id:"timur_wisps", size:Vector2i(28,12), waves:[[[res://entities/enemies/kemamang.tscn, Vector2i(6,-3)], [res://entities/enemies/kemamang.tscn, Vector2i(6,3)]]]}` | grass | 1 |
| `G` | encounter timur_ngarai | `res://entities/world/encounter.tscn` | `{area_id:"timur_ngarai", size:Vector2i(30,9), waves:[[[res://entities/enemies/keris_hantu.tscn, Vector2i(10,-3)], [res://entities/enemies/keris_hantu.tscn, Vector2i(10,0)], [res://entities/enemies/keris_hantu.tscn, Vector2i(10,3)]]]}` | path | 1 |
| `v` | loose kemamang, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/kemamang.tscn` | `{}` | grass | 2 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_wisps` | `E (18,24)` | 28x12 | W1: Kemamang (+6,-3), Kemamang (+6,+3) | Na Dash-strike; melee cuts wisps |
| `timur_ngarai` | `G (70,16)` | 30x9 | W1: Keris Hantu (+10,-3), Keris Hantu (+10,+0), Keris Hantu (+10,+3) | Nga Bind; Ha Heal cures Curse |

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
#.......#___________#.........rr........#___________#.......,,..............#____c____#..#
#.......#___________#.........rr........#___________#.......,,..............#_________#..#
#.......#_____E_____#...................#_____h_____#.......,,..............#_________#..#
#.......#___________#...................#___________#.......,,..............#_________#..#
#.......#___________#...................#___________#.......,,..............#####,#####..#
#.......#___________#...................#___________#.......,,...................,.......#
#.......######,######....rr.............######,######.......,,...................,.......#
#.............,..........rr...................,.............,,...................,.......#
#.............,...............................,.............,,...................,.......#
#..........S..S..S............................,.............,,...................,.......#
#.............M...............................,.............,,...................,.......#
#.............,...............................,.............,,...................,.......#
Xe,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..........#
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
| `E` | NPC Mpu Wirasana (3.2, 3.5, SQ-T3 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"timur_empu"}` | floor | 1 |
| `S` | practice stake (3.5, one per tile) | `res://entities/bosses/curse_stake.tscn` | `{practice:true}` | grass | 3 |
| `M` | trigger, practice marks marker `timur_praktik` (3.5) | `res://entities/world/trigger.tscn` | `{trigger_id:"timur_praktik", size:Vector2i(10,5)}` | grass | 1 |
| `L` | NPC kuda lumping leader (SQ-T4 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"kepang_leader"}` | grass | 1 |
| `T` | trigger, kepang stage (SQ-T4 step 3) | `res://entities/world/trigger.tscn` | `{trigger_id:"kepang_stage", size:Vector2i(8,4)}` | grass | 1 |
| `h` | pickup, sodo lanang (SQ-T1, shrine) | `res://entities/world/pickup.tscn` | `{item_id:"sodo_lanang"}` | floor | 1 |
| `g` | codex ruin, inscribed stone 1 (Keris) | `res://entities/world/pickup.tscn` | `{codex_id:"keris"}` | grass | 1 |
| `i` | codex ruin, inscribed stone 2 (Mpu Gandring) | `res://entities/world/pickup.tscn` | `{codex_id:"mpu_gandring"}` | grass | 1 |
| `o` | codex ruin, statue plinth (Tengger, scenery text) | `res://entities/world/pickup.tscn` | `{codex_id:"tengger_lautan_pasir"}` | grass | 1 |
| `c` | chest: Chainmail (secret, hollow banyan) | `res://entities/world/chest.tscn` | `{chest_id:"chest_tt_beringin", item_id:"chainmail"}` | floor | 1 |
| `b` | loose banaspati, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/banaspati.tscn` | `{}` | grass | 2 |
| `j` | loose prajurit terkutuk, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/prajurit_terkutuk.tscn` | `{}` | grass | 1 |

## Area 5: tt_ladang

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Dry field of dead cucumber vines (west), a dark lair of hanging bones and a lamp (east).
- Purpose: Buto Ijo field fight `timur_ladang`, plain exit to the `sc:tt_ladang` gate in beringin, miniboss arena 28x16 (east half), kabut K2 `mq3_4` before tt_pasir.

### Map
```
############################################################
#...........................################################
#...........................################################
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
#...........................#____________________________###
#...........................,____________________________###
#.............,,,,,,,,,,,,,,,,,,,,,,,,,,,,,B,,,,,,,,,,,,,KzZ
#.............,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,K,Z
#...rr........,,............,____________________________###
#...rr........,,............#____________________________###
#.............,,....rr......#____________________________###
#.............,,....rr......#____________________________###
#.............,,............#__rr_____________________rr_###
#.............,,............#__rr_____________________rr_###
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

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_ladang` | `E (15,13)` | 30x14 | W1: Prajurit Terkutuk (+8,+0), Keris Hantu (+4,-4), Banaspati (+4,+4), Kemamang (-6,-3) | Ra Summon on Prajurit, Bind on Keris Hantu |

## Area 6: tt_pasir

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: Pale sea-sand plain (floor tiles), a wide crater rim of black stones, the candi huge in the east, a sand alcove with petilasan 2.
- Purpose: Last fight `timur_pasir` (2 waves), petilasan `timur_2` in the east alcove beside the link to tt_candi, plain exit to sabana (`sc:tt_pasir`).

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
#_______________________________________________________________________________#________#
#_______________________________________________________________________________#________#
#_______________________________________________________________________________,_____P__#
Yy,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cC
Y,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,C
#_________,,____________________________________________________________________,________#
#_________,,____________________________________________________________________#________#
#____rr___,,____________________________________________________________________#________#
#____rr___,,____________________________________________________________________#______r_#
#_________,,______________________________________________________rr____________##########
#_________,,____________________________rr________________________rr_____________________#
#_________,,____________________________rr_______________________________________________#
#_________,,_____________________________________________________________________________#
#_________,,_____________________________________________________________________________#
##########,,##############################################################################
##########,,##############################################################################
##########,,##############################################################################
##########,,##############################################################################
##########,,##############################################################################
##########q,##############################################################################
##########XX##############################################################################
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

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_pasir` | `E (35,17)` | 36x16 | W1: Prajurit Terkutuk (+10,-3), Prajurit Terkutuk (+10,+3), Banaspati (+4,-5), Kemamang (-6,+0); W2: Keris Hantu (+12,-3), Keris Hantu (+12,+3) | Ra Summon, Na Dash-strike; Bind on wave 2; Heal for Curse |

## Area 7: tt_candi

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Banyan courtyard in front of Candi Gandring (stepped shrine, keris spire), seven curse stakes at the arena edge.
- Purpose: Boss arena Mpu Gandring's Keris, then the Nameless Hunter in the same court once the `keris` beat has played (interior x 19..52, y 5..28). Only exit: west, back to tt_pasir.

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
#.................#__________________________________#.....#
#.................#__________________________________#.....#
#.................#__________________________________#.....#
#.................#__________________________________#.....#
#.................,__________________________________#.....#
Xe,,,,,,,,,,,,,,,,,_________________B________________#.....#
X,,,,,,,,,,,,,,,,,,________________________________4_#.....#
#.................,__________________________________#.....#
#.................#__________________________________#.....#
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
| `B` | boss Mpu Gandring's Keris (arena centre) | `res://entities/bosses/keris_gandring.tscn` | `{}` | floor | 1 |
| `H` | boss the Nameless Hunter, after the keris (MQ3 3.8, Story v2) | `res://entities/bosses/nameless_hunter.tscn` | `{cond:"flag:beat_keris"}` | floor | 1 |
| `1` | curse stake 1 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:1}` | floor | 1 |
| `2` | curse stake 2 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:2}` | floor | 1 |
| `3` | curse stake 3 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:3}` | floor | 1 |
| `4` | curse stake 4 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:4}` | floor | 1 |
| `5` | curse stake 5 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:5}` | floor | 1 |
| `6` | curse stake 6 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:6}` | floor | 1 |
| `7` | curse stake 7 (arena edge) | `res://entities/bosses/curse_stake.tscn` | `{stake_id:7}` | floor | 1 |

## Area 8: tt_pesisir

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Dunes, a dry shore, driftwood, a wreck in the east dunes, a pale sea fog (kabut K3) on the south edge.
- Purpose: Optional coast: dune hollow fight `timur_pesisir`, burn-trail trigger, Banaspati elite, chest, kuda kepang 3, drop landing from beringin, back link to sabana, kabut K3 `mq3_8` to sk_karang.

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
#...........................,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#.............rr............,,....................q........#
#.............rr............,,.............................#
#.....rr....................,,.............................#
#.....rr....................,,.............................#
#...........................,,.............................#
#.....................T.....,,..E..........................#
#...........................,,.............................#
#...........................,,.............................#
#.........rr................,,......................rrrrrr.#
#.........rr................,,......................r....r.#
#...........................,,.........................c.r.#
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
| `K` | kabut K3, south edge (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq3_8"}` | path | 2 |
| `S` | exit to sk_karang (south edge, not built yet, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_karang", spawn_id:"from_tt_pesisir"}` | path | 2 |
| `g` | spawn, arrival from sk_karang | `res://entities/world/spawn.tscn` | `{id:"from_sk_karang"}` | path | 1 |
| `q` | elite Banaspati (SQ-T2, east dunes) | `res://entities/enemies/banaspati_elite.tscn` | `{}` | grass | 1 |
| `T` | trigger, burn trail reached (SQ-T2) | `res://entities/world/trigger.tscn` | `{trigger_id:"burn_trail", size:Vector2i(6,6)}` | grass | 1 |
| `c` | chest: 220 Ilmu (wreck, secret) | `res://entities/world/chest.tscn` | `{chest_id:"chest_tt_pesisir", item_id:"ilmu:220"}` | grass | 1 |
| `k` | pickup, kuda kepang 3 (SQ-T4) | `res://entities/world/pickup.tscn` | `{item_id:"kuda_kepang_3"}` | grass | 1 |
| `E` | encounter timur_pesisir | `res://entities/world/encounter.tscn` | `{area_id:"timur_pesisir", size:Vector2i(20,11), waves:[[[res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(7,0)], [res://entities/enemies/banaspati.tscn, Vector2i(3,-3)], [res://entities/enemies/banaspati.tscn, Vector2i(3,3)]]]}` | grass | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `timur_pesisir` | `E (32,17)` | 20x11 | W1: Prajurit Terkutuk (+7,+0), Banaspati (+3,-3), Banaspati (+3,+3) | Ra Summon |
