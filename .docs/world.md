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
| Hub to Segara Kidul | `desa_purwa` (S) | `sk_pantai` | link, kabut | `flag:mq4_2` (MQ4 4.2, the Interlude talk with Ibu) |
| Tanah Timur to Segara Kidul | `tt_pesisir` | `sk_karang` | link, kabut | `quest:mq4=done` (flag `mq4_9`); a back route only, so Act V always starts from Desa Purwa after the Interlude |
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
- Regional character: **Ibu**, who sets out two cups for a daughter she cannot remember. Story: the Prologue "The Night of the Wayang" (the Faceless take Laras) and the Interlude "The Quiet House" (the low point, no combat, ends with the south gate opening). See [story.md](story.md) Acts.
- Purpose: prologue, class choice, tutorial, shop-free hub with the first petilasan.
- Features: the sanggar (practice hall) where you draw glyphs with a guide, the wayang stage, Semar.
- No hostile enemies except tutorial dummies.

### Tatar Sunda (West Java), Act I
- Regional character: **Dewi Naganingrum**, a mother looking for a son as you look for a sister. Story: "The Crater Seal", the hunt ends in the crater where Sangkuriang wakes (Seal 1). [story.md](story.md) Acts.
- Look: misty highlands, tea terraces, bamboo, volcanic crater rim.
- Legend: **Sangkuriang and Tangkuban Perahu** (the upturned boat mountain). The crater is the boss arena.
- Glyphs learned: Aksara Sunda (4).
- NPCs: Cepot (comic relief), Abah Karna, the elder who teaches a glyph, side-quest givers ([quests.md](quests.md)).
- Culture: rumah panggung (stilt house), iket (cloth head wrap), angklung (verified: Sundanese, UNESCO 2010), kujang weapon.
- Petilasans: 2 (entrance, before the crater).
- Bosses ([bestiary.md](bestiary.md)): Sandekala (the dusk fight, step 1.5), the Faceless Captain (1.12) and Sangkuriang (1.13). Elite: the bamboo-grove Kuntilanak (SQ-S2, a locally darkened arena, no day/night cycle).
- Gates (**ASSUMED** 2026-11-05): a kabut on the crater path lifts with flag `mq1_7` (set when Naganingrum teaches Ca, step 1.10). The Desa Purwa east gate to Mataram stays fogged until flag `mq1_10`.
- Room layout: [zones/tatar_sunda.md](zones/tatar_sunda.md). Desa Purwa: [zones/desa_purwa.md](zones/desa_purwa.md). The sanggar is a room inside Desa Purwa.

### Keraton Galuh (the Galuh capital), Act II
- Regional characters: **Uwa Lengser** (keeps the queen's secret) and the **Faceless Deserter**. Story: "The Borrowed Face", the tournament, the cells, the unmasking of Prabu Barma Wijaya (the midpoint). [story.md](story.md) Acts.
- Look: a Sundanese royal capital, stone terraces and walls, a square with a tournament ring, banyan trees. Loosely Karang Kamulyan, Ciamis (**VERIFY**).
- Legend: **Ciung Wanara** ([story_ciung_wanara.md](story_ciung_wanara.md)). Areas `kg_alun`, `kg_keraton`, `kg_penjara`, `kg_pamali` ([zones/keraton_galuh.md](zones/keraton_galuh.md)). Enemy tier 1 (Mataram numbers).
- No new glyph: the region tests the four Sunda glyphs. Boss: Prabu Barma Wijaya. The Pamali crossing holds the Hariang Banga duel later (Act III).
- Petilasans: 1 (`galuh_1`).

### Mataram (Central Java), Act III
- Regional character: **Ki Sumarto**, a dalang who performs for both banks while his son marches in Hariang Banga's army. Story: "Blood on the Pamali", three leads to Candi Seribu, Seal 3 and Seal 2 restored, the duel at the ford. [story.md](story.md) Acts.
- Look: temple ruins, rice fields, volcano silhouette, stone gateways.
- Legend: **Roro Jonggrang and the thousand temples (Prambanan)**.
- Glyphs learned: Aksara Jawa / Hanacaraka (4).
- NPCs: Ki Sumarto, a dalang (wayang puppeteer) who tells Hanacaraka lore, Mbah Marto the juru kunci, the lesung women, and side-quest givers including Pak Karto the stone-carver (off the main path since v3.1; Na is read off the Arca's base) ([quests.md](quests.md)).
- Culture: batik, blangkon, gamelan (zone music hook), candi architecture, keris.
- Petilasans: 2.
- Bosses: Bandung Bondowoso (Seal 3). The Hariang Banga duel is in `kg_pamali` (Keraton Galuh), the Pamali ford.

### Tanah Timur (East Java), Act IV
- Regional character: **Mpu Wirasana**, a smith who fears the keris he could not refuse to sharpen. Story: "The Seven-Generation Blade", Buto Ijo, the Keris Mpu Gandring (Seal 4), the Hunter's false victory and the Eclipse that takes Laras. [story.md](story.md) Acts.
- Look: dry savanna, sea-sand crater plain, banyan and ancient shrines.
- Legends: **Timun Mas and Buto Ijo** (miniboss), **Ken Arok and the keris of Mpu Gandring** (boss). Bromo/Tengger as visual motif (Yadnya Kasada is a living Hindu Tengger ritual: use the landscape as scenery only, never as a quest, mechanic or enemy event; at most a short factual codex entry).
- Glyphs: no new letters. You learn to break curse marks (a technique) and the diacritic/modifier marks (stretch, see [spells.md](spells.md)).
- NPCs: Mpu Wirasana, a keris-smith (empu), side-quest givers ([quests.md](quests.md)).
- Culture: keris making, reog? (skip, not in scope), kuda lumping (verified as a trance dance with disputed origin: show it as performance only, no glass-eating or fire mechanics, no horror trance).
- Petilasans: 2.

### Segara Kidul (Southern Sea), Act V
- Regional character: **Mbah Wiryo**, the juru kunci of the coast, who says his late wife's name to the sea every dusk because the sea says it back. Story: "The Sea Does Not Forget" (MQ4 4.3-4.9), after the Interlude at home: respect for the coast, the reef, the cliff shrine where you hear Laras on the water, the Trial of the Waves, and Ombak, the one letter the Eclipse cannot eat. [story.md](story.md) Acts.
- Look: black-sand cliffs, green sea, a palace beneath waves.
- Figure: **Nyi Roro Kidul**, shown with respect, speaks once from a distance, never fought or touched. The green association is verified as a belief (wearing green on the south coast is said to attract her). Present it as belief, not a punishment.
- Trial instead of boss: three waves of Lampor, Ula Segara and Bajul Putih ([bestiary.md](bestiary.md)), held in the sea pavilion court (`sk_keraton`).
- Reward: the final glyph, Jawa Ka (Ombak), and the Kain Hijau, at the Sea Altar.
- Main path, **P0**. Areas: `sk_pantai`, `sk_karang`, `sk_tebing`, `sk_keraton`, all on the critical path.
- Petilasans: 3 (`kidul_1`, `kidul_3` at the cliff shrine, `kidul_2`), allowed because the region is a full act (**ASSUMED** 2026-11-06).
- Room layout: [zones/segara_kidul.md](zones/segara_kidul.md).

### Gua Kala (finale), Act VI
- Regional character: none (Semar waits at the last petilasan; Ciung Wanara and Hariang Banga hold the mouth). Story: "Into the Maw of Time" (MQ5): reclaim the three letters of her name (La, Ra, Sa), calm Batara Kala in the Ruwatan of Dawn, then write Laras's name. [story.md](story.md) Acts.
- Look: dark cavern, hourglass and clock-like motifs, the forgotten letters floating faded.
- Entered from the sea pavilion (or the hub) once `quest:mq4=done`.
- Boss: Batara Kala.
- Room layout: [zones/gua_kala.md](zones/gua_kala.md).

## Checkpoints (petilasan)
- A petilasan is a place where a revered figure once rested or meditated (verified usage). Shown as a small shrine with incense and a lit lamp.
- On interact: heal fully, refill flask charges, set respawn, respawn normal enemies, open the menu (level up, equip, codex).
- 2 per region (3 in the largest, or in a full act such as Segara Kidul), plus Desa Purwa. At least one before each boss (World structure rule 7).

## Points of interest per region (target)
- Spread over the region's areas: 1 boss arena, 1 miniboss or elite room, 3-5 NPCs (Tatar Sunda has 10 because it teaches the quest loop, **ASSUMED** 2026-11-05), 2-3 secret rooms (chests with gear), 1 codex-rich location (e.g. a museum-like ruin), 6-10 enemy encounters.

## Codex
Fed by: first meeting an enemy, first picking an item, first learning a glyph, talking to key NPCs, visiting landmarks. Each entry has a title, 1-3 sentences, a source line and (for glyphs) the character and its Latin transliteration.
