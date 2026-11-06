# World

An open map of connected zones on the island of Java (Sunda and Javanese lands). Zones join at their edges and load when crossed. Legend details fact-checked Nov 2026 (secondary sources).

## Layout (west to east)
```
 [Tatar Sunda]---[Desa Purwa]---[Keraton Galuh]---[Mataram]===[Tanah Timur]
      :               |    |                                        |
      :               |    +-------------[Segara Kidul]-------------+
      :               |                       |
      :            [Gua Kala]  (from Segara Kidul, or from the hub; both open on quest:mq4=done)
      :.......................................:
 --- link   === link plus a back-road shortcut   ... back-route shortcut
 Each box is a region of several areas; see World structure.
 Main path (story v3.1): Prologue Desa Purwa -> I Tatar Sunda -> II Keraton Galuh -> III Mataram
 -> IV Tanah Timur -> Interlude Desa Purwa -> V Segara Kidul -> VI Gua Kala.
 Segara Kidul has two ways in: the hub's south exit (opens on flag mq4_2, the Interlude talk with Ibu) and the Tanah Timur coast (a back route that opens on mq4_9, once MQ4 is done).
```
- Desa Purwa (village) is the start and the hub. Zones are first reached in the order of the main path above, but the map is connected so the player can backtrack.
- Segara Kidul unlocks when you talk to Ibu in the Interlude (flag `mq4_2`, MQ4 step 4.2), after Act IV. It is on the main path and is **P0**. Gua Kala unlocks when Ombak is earned at the sea pavilion (`quest:mq4=done`, MQ4 step 4.9); the hub gate to Gua Kala opens on the same flag.
- Between Act IV and the Interlude the only open route is the one the riders carry you on (a `goto`, [quests.md](quests.md) 4).

## Technical frame
- Viewport 480x270, 16 px tiles (30x17 tiles per screen), integer-scaled. See [architecture.md](architecture.md).
- A region is split into areas (see World structure). Each area is one zone scene of 2x2 to 3x3 screens. The camera follows the player and is clamped to the area bounds.
- Edges between areas are doors/paths that load the next area scene.

## World structure (interlocking, user call 2026-11-05)
The world should feel like one tangled place, not a corridor of rooms: paths fold back on themselves, and opening a shortcut to a petilasan you rested at an hour ago is a reward in itself. Inspired by Bloodborne's level design only. Tone and difficulty stay as [concept.md](concept.md) says (warm, forgiving, nothing lost on death).

**Terms**
- **Region:** one act (Tatar Sunda, Keraton Galuh, Mataram, Tanah Timur, Segara Kidul, Gua Kala). Desa Purwa is the hub, not a region (it holds the Prologue and the Interlude). Quests, Ilmu tiers and enemy tiers use the region id (`QuestData.zone`).
- **Area:** one zone scene, 2x2 to 3x3 screens (60x34 to 90x51 tiles). Id `<prefix>_<name>`: `ts_` Tatar Sunda, `mt_` Mataram, `tt_` Tanah Timur, `sk_` Segara Kidul, `gk_` Gua Kala. A region has 5-8 areas (Segara Kidul and Gua Kala may have 3-4).
- **Link:** a two-way edge exit between two areas.
- **Shortcut:** a gate (`shortcut`, flag `sc:<id>`) that opens only from one side, the far side, and then stays open for good. It always leads back toward a petilasan.
- **Drop:** a one-way exit (a ledge, a slide, a river current). No exit leads back the same way.

**Interlock rules (every region)**
1. At least 2 loops in the area graph. A loop closes with a shortcut or a drop, so the first trip around is long and later trips are short.
2. At least 2 shortcuts. Each one ends in an area with a petilasan or one link away from it.
3. At least 1 drop.
4. Optional areas (miniboss, secret, codex ruin) branch off a loop, never off the end of a dead-end chain, so turning back is never a long walk.
5. The boss site is a landmark: its silhouette shows in the background of the region's first area and grows nearer on the way.
6. A petilasan sits right before the boss area, with no fight between them (AGENTS.md 5 checklist).
7. Petilasans are few on purpose (2 per region, 3 in the largest, or in a full act such as Segara Kidul, **ASSUMED** 2026-11-06): shortcuts, not lamps, shorten the way back.
8. The critical path visits most areas, and the gates (kabut) still follow the story flags. Glyphs stay rewards, not keys.

**Links between regions**
Each region has its main link toward the hub and, later, at least one back route to a neighbour. A back route is a shortcut opened from the later region's side, so it never lets the player skip ahead. Planned back routes: Tatar Sunda lake to the Segara Kidul coast, and a Mataram back road to Tanah Timur. Each region doc names its own.

Endpoint area ids are fixed here so the region docs agree (**ASSUMED** 2026-11-05). Spawn ids follow `from_<other area id>`. Gate flags are named in [quests.md](quests.md) 4 (Gating); the region docs follow them.

| Link | Area A | Area B | Kind | Opens |
|------|--------|--------|------|-------|
| Hub to Tatar Sunda | `desa_purwa` (W) | `ts_kebun` | link | always |
| Hub to Keraton Galuh | `desa_purwa` (E) | `kg_alun` | link, kabut | `mq1_10` (v3.1, 2026-11-06; was the Mataram link) |
| Galuh to Mataram | `kg_pamali` (E) | `mt_gapura` (W) | link | always (`kg_alun` to `kg_pamali` is behind kabut `mqg_7`) |
| Hub to Gua Kala | `desa_purwa` (N) | `gk_mulut` | link, kabut | `quest:mq4=done` (kabut flag `mq4_9`) |
| Mataram to Tanah Timur | `mt_wetan` | `tt_kulon` | link, kabut | `mq2_9` (MQ2 2.9) |
| Mataram back road | `mt_tegal` | `tt_sabana` | shortcut `sc:mt_tt` | from `tt_sabana` |
| Hub to Segara Kidul | `desa_purwa` (S) | `sk_pantai` | link, kabut | `flag:mq4_i5` (MQ4 4.5, the Interlude talk with Semar) |
| Tanah Timur to Segara Kidul | `tt_pesisir` | `sk_karang` | link, kabut | `quest:mq4=done` (flag `mq4_9`); a back route only, so Act V always starts from Desa Purwa after the Interlude |
| Tanah Timur coast road (L14) | `tt_pesisir` (east pocket) | `tt_pasir` (south corridor) | link, kabut | `mq3_h4` (set when step 3.6 completes); spawns `from_tt_pesisir` (in pasir), `from_tt_pasir` (in pesisir) |
| Tatar Sunda back route | `ts_situ` | `sk_tebing` | shortcut `sc:ts_sk` | from `sk_tebing` |
| Segara Kidul to Gua Kala | `sk_keraton` | `gk_mulut` | link, kabut | `quest:mq4=done` (kabut flag `mq4_9`, set by step 4.9 when Ombak is earned) |

Inside Segara Kidul the critical path runs `sk_pantai` -> `sk_karang` -> `sk_tebing` (link `sk_karang` to `sk_tebing`, **ASSUMED** 2026-11-06) -> drop onto `sk_keraton`; the causeway `sk_karang` to `sk_keraton` is behind a kabut (`mq4_8`) until the trial is passed. See [zones/segara_kidul.md](zones/segara_kidul.md).

Region area graphs live in `.docs/zones/<region>.md`. Tatar Sunda has full tile maps (built in Phase 4); the other regions have their maps from Phase 5.

## Gating
Soft and story-driven:
- Zone exits are blocked by "kabut" (fog/curse barriers) that clear on a story flag: a boss defeated or a talk done (the link table above names each flag).
- Enemy level rises per zone, so rushing ahead is possible but hard.
- Glyph unlocks are tied to zones, so skipping around never breaks progression.

## Zones

### Desa Purwa (start village), the Prologue and the Interlude
- Regional character: **Ibu**, who sets out two cups for a daughter she cannot remember. Story (v4c): the Prologue "A Day in Desa Purwa" (a normal day: the tag game with Laras, tea with Ibu, Ciung's tree, Semar and Cepot at the sanggar, the market stall, the ruwatan show as the first Kelir memory K0, then the raid) and the Interlude "The Quiet House" (no combat: three doorposts, Ibu's shelf and cups, the brothers' table, Aria by the burned stage, Semar; the south gate opens on `mq4_i5`). The epilogue (after `mq5_4`) fills the village with people from every act. See [story.md](story.md) Acts.
- Purpose: prologue, class choice, tutorial, shop-free hub with the first petilasan.
- Features: the sanggar (practice hall) where you draw glyphs with a guide and write names, the wayang stage, Semar (the village dalang; Ki Wangsa is cut), the market stall, the old couple's house, Ciung's tree, Ibu's house, the pustaka.
- No hostile enemies except tutorial dummies and the raid skirmishes (step 0.8). Optional finds: the banyan shrine codex, the pustaka, the stage lakon (SQ-D1).

### Tatar Sunda (West Java), Act I
- Regional character: **Dewi Naganingrum**, a mother looking for a son as you look for a sister. Story: "The Crater Seal", the hunt ends in the crater where Sangkuriang wakes (Seal 1). [story.md](story.md) Acts.
- Look: misty highlands, tea terraces, bamboo, volcanic crater rim.
- Legend: **Sangkuriang and Tangkuban Perahu** (the upturned boat mountain). The crater is the boss arena.
- Glyphs learned: Aksara Sunda (4).
- NPCs: Cepot (comic relief), Abah Karna, the elder who teaches a glyph, side-quest givers ([quests.md](quests.md)).
- Culture: rumah panggung (stilt house), iket (cloth head wrap), angklung (verified: Sundanese, UNESCO 2010), kujang weapon.
- Petilasans: 2 (entrance, before the crater).
- Bosses ([bestiary.md](bestiary.md)): Sandekala (the dusk fight, step 1.6, after the K1 hook, clues and memory), the Faceless Captain (1.13) and Sangkuriang (1.15, after the K2 clue and memory). Elites: the bamboo-grove Kuntilanak (SQ-S2, a locally darkened arena, no day/night cycle) and three `miniboss` elites on the path (the kampung boar 1.2, the terrace Jurig 1.8, the lakeshore Kuntilanak 1.10).
- Story v4c content: the arrival slice (pickers, the elder's grandson), the K1 hamlet and the gorge tunnel shortcut, two puzzles (the three name-stones 1.7, the sluice wheels 1.9), the Hunt clues and memories (K1, K2), LC1 at the crater-road petilasan, H1 on the far rim. Every `Play` piece of 1.1-1.15 has a place in [zones/tatar_sunda.md](zones/tatar_sunda.md).
- Gates (**ASSUMED** 2026-11-05): a kabut on the crater path lifts with flag `mq1_7` (set when Naganingrum teaches Ca, step 1.11). The Desa Purwa east gate to Mataram stays fogged until flag `mq1_10`.
- Room layout: [zones/tatar_sunda.md](zones/tatar_sunda.md). Desa Purwa: [zones/desa_purwa.md](zones/desa_purwa.md). The sanggar is a room inside Desa Purwa.

### Keraton Galuh (the Galuh capital), Act II
- Regional characters: **Uwa Lengser** (keeps the queen's secret) and the **Faceless Deserter**. Story: "The Borrowed Face", the tournament, the cells, the unmasking of Prabu Barma Wijaya (the midpoint). [story.md](story.md) Acts.
- Look: a Sundanese royal capital, stone terraces and walls, a square with a tournament ring, banyan trees. Loosely Karang Kamulyan, Ciamis (**VERIFY**).
- Legend: **Ciung Wanara** ([story_ciung_wanara.md](story_ciung_wanara.md)). Areas `kg_alun`, `kg_keraton`, `kg_penjara`, `kg_pamali` ([zones/keraton_galuh.md](zones/keraton_galuh.md)). Enemy tier 1 (Mataram numbers).
- No new glyph: the region tests the four Sunda glyphs. Boss: Prabu Barma Wijaya. The Pamali crossing holds the Hariang Banga duel later (Act III).
- Story v4c content: the arrival slice (the crowd, the rooster seller), the champion miniboss at the end of the bouts, the lamp puzzle that opens the inner garden (`galuh_1`), the wagon setpiece, Laras's wall message and LC2, the portrait gallery with the K-II clue, the mask fragment and H2, the throne-room guards. Every `Play` piece of g.1-g.9 has a place in [zones/keraton_galuh.md](zones/keraton_galuh.md).
- Petilasans: 1 (`galuh_1`, inside the inner garden).

### Mataram (Central Java), Act III
- Regional character: **Ki Sumarto**, a dalang who performs for both banks while his son marches in Hariang Banga's army. Story: "Blood on the Pamali", three leads to Candi Seribu, Seal 3 and Seal 2 restored, the duel at the ford. [story.md](story.md) Acts.
- Look: temple ruins, rice fields, volcano silhouette, stone gateways.
- Legend: **Roro Jonggrang and the thousand temples (Prambanan)**.
- Glyphs learned: Aksara Jawa / Hanacaraka (4).
- NPCs: Ki Sumarto, a dalang (wayang puppeteer) who tells Hanacaraka lore, the juru kunci (was Mbah Marto), the lesung women (foothill lesung yard in `mt_wetan`), two unnamed recruiters at the border market (arrival slice), a hauler, and side-quest givers including Pak Karto the stone-carver (off the main path since v3.1; Na is read off the Arca's base) ([quests.md](quests.md)).
- Culture: batik, blangkon, gamelan (zone music hook), candi architecture, keris.
- Story v4c: clues `rubble`, `lesung_mid`, `ka_strip`, `hunter_mask_3`; memories K3, H3, LC3 (and K-III in `kg_pamali`); miniboss pieces and a puzzle (`puzzle_wetan_lamps`) in [zones/mataram.md](zones/mataram.md). Every area holds an optional find.
- Petilasans: 2.
- Bosses: Bandung Bondowoso (Seal 3). The Hariang Banga duel is in `kg_pamali` (Keraton Galuh), the Pamali ford.

### Tanah Timur (East Java), Act IV
- Regional character: **Mpu Wirasana**, a smith who fears the keris he could not refuse to sharpen. Story: "The Seven-Generation Blade", Buto Ijo, the Keris Mpu Gandring (Seal 4), the Hunter's false victory and the Eclipse that takes Laras. [story.md](story.md) Acts.
- Look: dry savanna, sea-sand crater plain, banyan and ancient shrines.
- Legends: **Timun Mas and Buto Ijo** (miniboss), **Ken Arok and the keris of Mpu Gandring** (boss). Bromo/Tengger as visual motif (Yadnya Kasada is a living Hindu Tengger ritual: use the landscape as scenery only, never as a quest, mechanic or enemy event; at most a short factual codex entry).
- Glyphs: no new letters. You learn to break curse marks (a technique) and the diacritic/modifier marks (stretch, see [spells.md](spells.md)).
- NPCs: Mpu Wirasana, a keris-smith (empu), his daughter (arrival slice, unnamed), the widow (npc id `mbok_srini`), side-quest givers ([quests.md](quests.md)).
- Story v4c: clues for K4 and K5 (`seeds`, `needle_case`, `salt_terasi`, `scabbard`, `forge_records`, `forge_stone`), H4 and K6 (`hunter_mask_4`, `mask_joined`), LC4; new link `tt_pesisir` > `tt_pasir` (kabut `mq3_h4`) so step 3.7 runs forward ([zones/tanah_timur.md](zones/tanah_timur.md)).
- Culture: keris making, reog? (skip, not in scope), kuda lumping (verified as a trance dance with disputed origin: show it as performance only, no glass-eating or fire mechanics, no horror trance).
- Petilasans: 2.

### Segara Kidul (Southern Sea), Act V
- Regional character: **Mbah Wiryo**, the juru kunci of the coast, who says his late wife's name to the sea every dusk because the sea says it back. Story: "The Sea Does Not Forget" (MQ4 4.6-4.12), after the Interlude at home (4.1-4.5): the fishing village (arrival slice), three song verses and the K8 memory, K9 at the cliff shrine, LC5, respect for the coast, the reef, the cliff shrine where you hear Laras on the water, the Trial of the Waves, and Ombak, the one letter the Eclipse cannot eat. [story.md](story.md) Acts.
- Look: black-sand cliffs, green sea, a palace beneath waves.
- Figure: **Nyi Roro Kidul**, shown with respect, speaks once from a distance, never fought or touched. The green association is verified as a belief (wearing green on the south coast is said to attract her). Present it as belief, not a punishment.
- Trial instead of boss: three waves of Lampor, Ula Segara and Bajul Putih ([bestiary.md](bestiary.md)), held in the sea pavilion court (`sk_keraton`).
- Reward: the final glyph, Jawa Ka (Ombak), and the Kain Hijau, at the Sea Altar.
- Main path, **P0**. Areas: `sk_pantai`, `sk_karang`, `sk_tebing`, `sk_keraton`, all on the critical path.
- Petilasans: 3 (`kidul_1`, `kidul_3` at the cliff shrine, `kidul_2`), allowed because the region is a full act (**ASSUMED** 2026-11-06).
- Room layout and v4c clue, memory and puzzle places: [zones/segara_kidul.md](zones/segara_kidul.md).

### Gua Kala (finale), Act VI
- Regional character: none (Semar waits at the last petilasan; Ciung Wanara and Hariang Banga hold the mouth). Story: "Into the Maw of Time" (MQ5, 5.1-5.9): reclaim the three letters of her name (La, Ra, Sa) in three gap memories of the prologue day (one per area: `gk_mulut`, `gk_lupa`, the last petilasan), K10, LC6, K7, calm Batara Kala in the Ruwatan of Dawn, then write Laras's name. [story.md](story.md) Acts.
- Look: dark cavern, hourglass and clock-like motifs, the forgotten letters floating faded.
- Entered from the sea pavilion (or the hub) once `quest:mq4=done`.
- Boss: Batara Kala.
- Room layout and memory scenes: [zones/gua_kala.md](zones/gua_kala.md).

## Checkpoints (petilasan)
- A petilasan is a place where a revered figure once rested or meditated (verified usage). Shown as a small shrine with incense and a lit lamp.
- On interact: heal fully, refill flask charges, set respawn, respawn normal enemies, open the menu (level up, equip, codex).
- 2 per region (3 in the largest, or in a full act such as Segara Kidul), plus Desa Purwa. At least one before each boss (World structure rule 7).

## Points of interest per region (target)
- Spread over the region's areas: 1 boss arena, 1 miniboss or elite room, 3-5 NPCs (Tatar Sunda has 10 because it teaches the quest loop, **ASSUMED** 2026-11-05), 2-3 secret rooms (chests with gear), 1 codex-rich location (e.g. a museum-like ruin), 6-10 enemy encounters. Story v4c adds: every area on the critical path holds at least one optional find (a secret, a side-quest hook or a codex spot; Pacing rule 7), and the clue spots, puzzles and `miniboss` waves named in quests.md step tables are placed on top of these counts (the zone docs list them under "Piece placement per step").

## Codex
Fed by: first meeting an enemy, first picking an item, first learning a glyph, talking to key NPCs, visiting landmarks. Each entry has a title, 1-3 sentences, a source line and (for glyphs) the character and its Latin transliteration.
