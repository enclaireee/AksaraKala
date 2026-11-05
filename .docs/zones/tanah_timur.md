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
`==K==` kabut, `--` link, `~~sc~~` shortcut gate (opens from the tagged side), `--v` drop. Flags: `K1` mq2_9, `K2` mq3_4, `K3` mq3_8 (all ASSUMED).
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
| 1 | `mt_wetan` | `tt_kulon` | link, kabut `K1` | `mq2_9` (set by MQ2 2.9, Semar; same pattern as `mq1_10`) | `from_mt_wetan` (in kulon), `from_tt_kulon` (in mt_wetan) |
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
| 13 | `tt_pesisir` | `sk_karang` | link, kabut `K3` | `mq3_8` (set by MQ3 3.8, Semar; same pattern as `mq1_10`) | `from_tt_pesisir` (sk_karang), `from_sk_karang` (pesisir) |

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

**Critical path (MQ3 order):** `mt_wetan` -> `tt_kulon` (E `timur_kulon`, E `timur_gerbang`) -> `tt_sabana` (`timur_1`, 3.1; E `timur_embers`) -> `tt_beringin` (empu, 3.2; opens SQ-T3) -> `tt_sabana` -> `tt_kali` (E `timur_wisps`, Mbok Srini and the pouches, 3.3; E `timur_ngarai`) -> `tt_ladang` (E `timur_ladang`, open `sc:tt_ladang`, Buto Ijo, 3.4) -> `sc:tt_ladang` -> `tt_beringin` (empu, practice marks, 3.5) -> `sc:tt_ladang` back -> `tt_ladang` -> `tt_pasir` (E `timur_pasir`, `timur_2`, 3.6) -> `tt_candi` (keris, 3.7) -> `tt_pasir` -> `sc:tt_pasir` -> `tt_sabana` -> `sc:mt_tt` -> Mataram -> Semar (3.8).

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
| 3.1 rest at the savanna petilasan | `timur_1` (Q) | `tt_sabana` | `petilasan_activated:timur_1` (Q) |
| 3.2 find the empu | `timur_empu` (Q) | `tt_beringin` | `talked_to:timur_empu` (Q). Makes SQ-T3 available |
| 3.3 help Mbok Srini | `mbok_srini` (Q) | `tt_kali` | `talked_to:mbok_srini` (Q), gives 4 pouches (`give:pouch_cucumber`, `pouch_needles`, `pouch_salt`, `pouch_terasi`) |
| 3.4 defeat Buto Ijo | `buto_ijo` | `tt_ladang` | `boss_defeated:buto_ijo` (Q); sets `mq3_4` (opens `K2`) |
| 3.5 learn to break curse marks | `timur_empu`, `timur_praktik` | `tt_beringin` | `talked_to:timur_empu` (Q) then `spell_cast` on a practice mark x2 (Q); marker `timur_praktik` at the stakes |
| 3.6 rest before the shrine | `timur_2` (Q) | `tt_pasir` | `petilasan_activated:timur_2` (Q) |
| 3.7 lay the keris to rest | `keris_gandring` | `tt_candi` | `boss_defeated:keris_gandring` (Q); sets `mq3_7` |
| 3.8 speak with Semar | `semar` | `desa_purwa` (see conflicts) | `talked_to:semar` (Q); sets `mq3_8` (opens `K3`) |

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
| | 2 find the meteorite in Mataram | `batu_bintang` | `mt_tegal` (ASSUMED, near the temple plain) | `item_picked:batu_bintang`; walk is short via `sc:mt_tt` |
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
- Flags `mq2_9`, `mq3_4`, `mq3_7`, `mq3_8`. Region gates lift on the return to Semar (quests.md 2.9 and 3.8), like `mq1_10`; world.md link table updated to match.
- Mbok Srini lives in `tt_kali` and Klething Kuning at the river crossing in the same area (the river is a trickle in a dry riverbed).
- The sodo lanang is a pickup in the banyan shrine (the source for the legend is VERIFY).
- Drop `drop_pesisir` is a dune slide; sizes 3x2 are allowed by the 60/90 x 34/51 rule.
- Semar stands in `desa_purwa` for 3.8; `sc:mt_tt` and `sc:tt_pasir` make the walk home short.
- The meteorite fragment `batu_bintang` lies in `mt_tegal` (Mataram area not yet written).
- The `timur_wisps` encounter has no tank or chaser, as the bestiary mix lists only 2 Kemamang.

## Open questions
1. Mataram: confirm `mt_wetan`/`mt_tegal` exist in the Mataram doc, and where `batu_bintang` lies.
2. Resolved by the main session: `K3` lifts at 3.8 (`mq3_8`, Semar), matching quests.md.
3. Where does Semar stand for 3.8 (Desa Purwa only, or also at `timur_2`)?
4. Should the practice stakes in step 3.5 be removed from the critical path if a glyph-free build is wanted?
5. Who gave Klething Kuning the sodo lanang (VERIFY), and should the peaceful route start in the shrine?
6. Should the elite Banaspati be added to the bestiary as a named elite?

## Doc conflicts found (not fixed)
- bestiary.md Encounters "Embers" (4 Banaspati) would be the first Banaspati encounter if met alone in the savanna. Here `timur_kulon` (2 Banaspati) teaches first and `timur_embers` comes second.
- world.md says the Mataram kabut lifts when the Mataram boss is beaten; quests.md 2.9 says the fog lifts on talking to Semar.
- world.md link table: `tt_pesisir` kabut lifts on the third boss; quests.md MQ3 says the Segara Kidul path opens after 3.8 (Semar).
- quests.md 3.5 completes on `spell_cast` (a cast), while the checklist says glyphs are rewards, not keys. Treated as a quest action, not a gate.
- quests.md SQ-T2 needs an elite Banaspati; bestiary.md lists no elite Banaspati.
- quests.md SQ-T1 needs a river with a crab; bestiary.md puts Kemamang in a dry riverbed. Resolved with a dry bed plus one trickle channel.
- world.md "Points of interest" asks for 1 miniboss or elite room; MQ3 3.4 makes Buto Ijo mandatory, so the miniboss is on the critical path rather than off a loop (rule 4 only applies to optional areas).
