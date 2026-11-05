# Gua Kala (region id `gua_kala`), the finale

Area graph on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5), graph level only: no tile maps until Phase 5. Prefix `gk_`. Sources: [world.md](../world.md) (World structure, link table, Gua Kala, Checkpoints), [bestiary.md](../bestiary.md) (Final: Gua Kala, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ5, 7.5, 9), [story.md](../story.md) (Batara Kala). Format follows [tatar_sunda.md](tatar_sunda.md).

Look: a dark cavern of wet black rock, hourglass and clock-like motifs carved into the walls, and the forgotten letters floating about, faded and dim. Sand trickles in thin streams from the ceiling in the deeper halls. The landmark is Kala's chamber. From the first area (`gk_mulut`), across a wide chasm, the player sees an enormous hourglass and a round clock-face set in the far wall, glowing faintly. It grows nearer in each area, and its ticking gets louder. Batara Kala is a deity figure and is not killed: he is calmed and turned back (a respectful ruwatan note is in the codex, per story.md). Tone stays warm and a bit cartoonish.

Areas: 4. Critical path: `gk_mulut` -> `gk_pasir` -> (drop) `gk_lupa` -> `gk_ruang_kala`. A P0 build can reach Gua Kala directly (see conflicts).

## Area table
| id | size (screens, tiles) | look | purpose | contents |
|----|-----------------------|------|---------|----------|
| `gk_mulut` | 3x2, 90x34 | The cave mouth. Wet black rock, carved clock gears, drifting faded letters, the chasm with the far hourglass in view | Entry, first rest, landmark view | Spawns `from_sk_keraton` (W), `from_gk_pasir` (link L1), `from_gk_lupa` (shortcut landing). Petilasan `kala_2` (near the entry). Encounter `kala_mulut`. Shortcut landing `sc:gk_lorong`. Quest marker `kala_mulut` |
| `gk_pasir` | 3x3, 90x51 | The sand halls. Giant hourglass shapes in the walls, thin sand streams that only look pretty, rocky floors and pillars | The long way in, two fights, a secret | Spawns `from_gk_mulut` (W). Encounters `kala_pasir_1`, `kala_pasir_2`. Chest `kala_chest_1` (hidden sand cave, gap between pillars). Drop `D1` (high gallery, sand-slide) onto `gk_lupa`. Quest marker none |
| `gk_lupa` | 2x3, 60x51 | The hall of faded letters. Aksara float like dim motes: Sunda, Jawa, forgotten scripts. Shelves of stone tablets | Rest before the boss, codex, the shortcut, the boss door | Spawns `from_gk_pasir` (drop landing, N), `from_gk_ruang_kala` (S door). Encounter `kala_lupa`. Chest `kala_chest_2` (behind tablets). Petilasan `kala_1` (south end, 10 tiles from the door, no fight between). NPC `semar` at `kala_1`. Codex spot `kala_aksara_pudar`. Shortcut gate `sc:gk_lorong` (opens from here). Quest markers `kala_1`, `kala_boss` (door) |
| `gk_ruang_kala` | 2x2, 60x34 | A round chamber. A clock face on the floor, the great hourglass overhead. Four quadrants, each with a motif of an earlier region (phase 3 uses them all) | Boss arena, Batara Kala | Spawn `from_gk_lupa`. Boss `batara_kala` (marker `kala_boss`). After the fight a lit door leads to the epilogue (`kala_exit`, **ASSUMED**). No other enemies |

## Region graph
`--` link, `=sc=` shortcut, `~D~>` drop (one way), `==K==` kabut.
```
 [sk_keraton] ==K mq4_3== [gk_mulut] --L1-- [gk_pasir]
                           (kala_2)   ^           |
                                      |           ~D1~> (one way)
                                      |                 |
                                      +==sc:gk_lorong== [gk_lupa] --L2-- [gk_ruang_kala]
                                                         (kala_1)         (Batara Kala)
                                                  codex, Semar
```
Critical path: `sk_keraton` -> `gk_mulut` (rest `kala_2`) -> `gk_pasir` -> D1 -> `gk_lupa` (rest `kala_1`) -> `gk_ruang_kala`.

### Link table
| id | from area | to area | kind | gate flag | spawn ids |
|----|-----------|---------|------|-----------|-----------|
| X1 | `sk_keraton` | `gk_mulut` | link, kabut | `mq4_3` | `from_sk_keraton` (in `gk_mulut`), `from_gk_mulut` (in `sk_keraton`). In a P0 build the kabut is already open (see conflicts) |
| L1 | `gk_mulut` | `gk_pasir` | link | none | `from_gk_pasir` (in mulut), `from_gk_mulut` (in pasir) |
| D1 | `gk_pasir` | `gk_lupa` | drop (one way) | none | `from_gk_pasir` (landing in lupa). No exit leads back up |
| S1 | `gk_lupa` | `gk_mulut` | shortcut `sc:gk_lorong` | `sc:gk_lorong` | `from_gk_lupa` (in mulut), `from_gk_mulut` (in lupa) |
| L2 | `gk_lupa` | `gk_ruang_kala` | link | none (the door is a plain door, closed during the fight) | `from_gk_lupa` (in ruang), `from_gk_ruang_kala` (in lupa) |

### Shortcut table
| id | gate area | opens from | leads back to |
|----|-----------|------------|---------------|
| `sc:gk_lorong` | `gk_lupa` (west wall near the drop landing, a door choked with packed sand) | `gk_lupa` only. From `gk_mulut` it is a sand-blocked arch with no handle | `gk_mulut`, petilasan `kala_2`. After it is open the trip from `kala_2` to the boss is mulut -> lorong -> lupa -> `kala_1`, about a minute |

## Loops, drop, critical path, optional areas
Loop: `gk_mulut` -> L1 -> `gk_pasir` -> D1 (drop) -> `gk_lupa` -> `sc:gk_lorong` -> `gk_mulut`. First trip: the long walk through two fights and a high gallery. Later trips: from `kala_2` through the shortcut to the boss door, skipping the sand halls.

Drop: D1, a sand-slide from the high gallery of `gk_pasir` (hourglass motif: the sand carries the player down). The landing is a few tiles from the `sc:gk_lorong` door, so the way back to `kala_2` opens early.

Critical path (MQ5): 5.1 enter `gk_mulut`; fight `kala_mulut`; rest `kala_2`; `gk_pasir` fights; drop to `gk_lupa`; fight `kala_lupa`; 5.2 rest at `kala_1` (no fight between it and the door); 5.3 `gk_ruang_kala`, Batara Kala; 5.4 the lit door after the fight.

Optional areas: none. With 4 areas all lie on the loop, and nothing dead-ends, so rule 4 is met by having no optional dead-end area. Optional content is inside areas: `kala_chest_1` in the hidden sand cave and `kala_chest_2` behind the tablets.

## Encounters
Bestiary: about 10 kills in Gua Kala, one mix from each earlier zone at tier 4. All four are from [bestiary.md](../bestiary.md) Encounters and Zone 4. Every enemy is already known by then, so the weakness is usable. Offsets are Phase 5.

| encounter id | area | zone mix reused | enemy mix | clean answer |
|--------------|------|-----------------|-----------|--------------|
| `kala_mulut` | mulut | Tatar Sunda (`sunda_batutulis`) | 2 Bandit, 1 Kuntilanak | Ka Bolt on the shriek |
| `kala_pasir_1` | pasir | Mataram rock thrower | 1 Genderuwo, 2 Pocong | Ka Bolt on the rock, Nga Bind on a hopping Pocong |
| `kala_pasir_2` | pasir | Tanah Timur wisps (dry riverbed with rock cover) | 2 Kemamang | Na Dash-strike |
| `kala_lupa` | lupa | Segara Kidul trial W3 | 1 Bajul Putih, 2 Lampor | Ga Ward on the lunge, Ca Burst on the line. Ombak pushes back both. One tank |

Total 11 kills (about 10). Four encounters, no room with 4 or more enemies, so the 15x9 rule is met by default; the Bajul lane in `gk_lupa` is 8+ tiles. No second tank right before the boss (the pre-boss exception is not used). The newest glyph, Ombak, answers Kala's time-sand in the boss fight; its other uses here are on Lampor and projectiles.

## Points of interest
| Thing | Count | Where |
|-------|-------|-------|
| Boss arena | 1 | `gk_ruang_kala` |
| Elite room | 0 (smaller: short finale) | none |
| NPCs | 1 | `semar` at `kala_1` |
| Secrets | 2 | `kala_chest_1`, `kala_chest_2` |
| Codex spot | 1 | `kala_aksara_pudar` in `gk_lupa` (faded letters, Kala, ruwatan note) |
| Petilasans | 2 | `kala_2` (mulut), `kala_1` (lupa, the last one) |

## Quest step locations
Marker form `{zone: "gua_kala", id: ...}`. Ids from quests.md are marked (Q). Everything else is **ASSUMED**.

| Step | Marker id | Area | Event string |
|------|-----------|------|--------------|
| MQ5 5.1 enter Gua Kala | `kala_mulut` | `gk_mulut` | `zone_entered:gua_kala` (Q) |
| 5.2 rest at the last petilasan | `kala_1` | `gk_lupa` | `petilasan_activated:kala_1` (Q) |
| 5.3 face Batara Kala | `kala_boss` | `gk_ruang_kala` | `boss_defeated:batara_kala` (Q) |
| 5.4 return to the wayang stage | `kala_exit` | `gk_ruang_kala` (the lit door after the fight) | `zone_entered:desa_purwa` (Q). The door leads to Desa Purwa (spawn `from_gua_kala`), epilogue and credits |
| Petilasan | `kala_2` | `gk_mulut` | `petilasan_activated:kala_2` (not a quest step) |
| Codex | `kala_aksara_pudar` | `gk_lupa` | `codex:batara_kala`, `codex:ruwatan` (ASSUMED) |
| Semar line | `semar` | `gk_lupa` | `talked_to:semar` (optional, not a step) |

Flags: `mq4_3` (read, Segara Kidul trial passed), `sc:gk_lorong`. Post-game: after the credits the player wakes in Desa Purwa with every zone open.

## Flow
Enter `gk_mulut` (the far hourglass in view) -> Sunda mix `kala_mulut` -> petilasan `kala_2` -> `gk_pasir` -> Mataram mix `kala_pasir_1` -> Timur mix `kala_pasir_2` -> high gallery, sand-slide drop -> `gk_lupa` -> open `sc:gk_lorong` (short way back to `kala_2`) -> Segara mix `kala_lupa` -> codex and Semar at petilasan `kala_1` -> door -> `gk_ruang_kala`, Batara Kala -> the lit door home.

## Self-check ([AGENTS.md](../../AGENTS.md) section 5 Step 2)
- [~] POI counts: 1 boss arena, 0 elite rooms, 1 NPC (3-5), 2 secrets (2-3), 1 codex spot, 4 encounters (6-10), 2 petilasans. Smaller than usual: a 4-area finale with about 10 kills (bestiary), and Semar is the only talker.
- [x] Petilasan before the boss, no fight between: `kala_1` is 10 tiles from the door; `kala_lupa` is at the north end of `gk_lupa`, 20+ tiles away, and `gk_ruang_kala` has no other enemies.
- [x] First appearances: every enemy was met in an earlier zone, and each encounter has its weakness glyph (table above).
- [x] One tank per encounter: only `kala_lupa` has a tank (1 Bajul Putih). At most one shooter (`kala_pasir_1`: Genderuwo). At most 2 waves: all single wave.
- [x] Rooms with 4 or more enemies: none. Bajul lane 8+ tiles.
- [x] Newest glyph: Ombak answers time-sand and projectiles (boss), no weakness enemy here; Lampor can be pushed back with it.
- [x] Every MQ5 step has a marker (table above).
- [x] Critical path without any one glyph: no kabut inside Gua Kala; `mq4_3` opens on the trial flag (story), not on a glyph.
- [x] Rule: at least 1 loop or 1 shortcut: loop `mulut-pasir-(D1)-lupa-(sc)-mulut` plus `sc:gk_lorong` back to `kala_2`.
- [x] At least 1 drop: D1.
- [x] Landmark: the hourglass chamber shows from `gk_mulut`.
- [x] Petilasan right before Batara Kala with no fight between: `kala_1`.
- [~] Rule 7, 2 petilasans: `kala_2` then `kala_1`. The ids run backwards (the first rest is `kala_2`) because quests.md 5.2 fixes `kala_1` as the last one.

## ASSUMED
- Area names `gk_pasir`, `gk_lupa`, `gk_ruang_kala` (only `gk_mulut` is fixed), their sizes, the loop layout, D1 and `sc:gk_lorong`.
- `kala_2` is in `gk_mulut`; `kala_1` in `gk_lupa`.
- Encounter ids, chest ids, `kala_aksara_pudar`, `kala_exit`, codex ids, spawn `from_gua_kala` in Desa Purwa.
- The four mixes (one per earlier zone) and the one-wave rule; 11 kills is "about 10".
- Semar at `kala_1`, with an optional line.
- The lit door after the fight leads to Desa Purwa; it is not a graph edge.

## Open questions
1. VERIFY (ruwatan): the codex note on ruwatan, and the claim that Kala is "turned back", not killed, need sources ([story.md](../story.md) says verified with nuance). Any new culture claim about hourglass or clock motifs for Kala is a design invention, not folklore.
2. Should the arena be bigger than 2x2 for phase 3 "all arenas combined"? Here 60x34 with four quadrant motifs.
3. P0 build without Segara Kidul has no Lampor or Bajul Putih. Swap `kala_lupa` to the Timur "Old guard" mix (1 Prajurit Terkutuk, 2 Banaspati)? No Jawa Ka then either.
4. How does the player return to Desa Purwa after the boss? A lit door (ASSUMED) or a cutscene.
5. Is Semar at `kala_1` wanted, or does story.md want him silent in the finale?

## Doc conflicts found (not fixed)
- world.md and quests.md say Gua Kala may be reached directly in a P0 build, but the only link to `gk_mulut` is from `sk_keraton`. A P0 fallback entry is needed (for example a temporary link from Desa Purwa, spawn `from_desa_purwa`). Not decided.
- bestiary.md says Kala HP 9300 / 3 phases for a full build and 8400 for P0, with no arena size. world.md says 2x2 to 3x3 screens per area.
- quests.md fixes `kala_1` as "the last petilasan", so a two-petilasan region numbers its first rest `kala_2`.
- quests.md 5.4 `zone_entered:desa_purwa` has no graph edge from Gua Kala in world.md.
- world.md Points of interest asks 6-10 encounters and 3-5 NPCs per region; bestiary.md fixes about 10 kills for Gua Kala, which gives 4 encounters.
