# World

An open map of connected zones on the island of Java (Sunda and Javanese lands). Zones join at their edges and load when crossed. Legend details fact-checked Nov 2026 (secondary sources).

## Layout (west to east)
```
 [Tatar Sunda]---[Desa Purwa]---[Mataram]===[Tanah Timur]
      :               |                          |
      :               +-------[Segara Kidul]-----+
      :.......................:     |
                               [Gua Kala]
 --- link   === link plus a back-road shortcut   ... back-route shortcut
 Each box is a region of several areas; see World structure.
```
- Desa Purwa (village) is the start and the hub. Zones are first reached in the order shown, but the map is connected so the player can backtrack.
- Segara Kidul unlocks after the third boss. Gua Kala unlocks after the Nyi Roro Kidul trial.

## Technical frame
- Viewport 480x270, 16 px tiles (30x17 tiles per screen), integer-scaled. See [architecture.md](architecture.md).
- A region is split into areas (see World structure). Each area is one zone scene of 2x2 to 3x3 screens. The camera follows the player and is clamped to the area bounds.
- Edges between areas are doors/paths that load the next area scene.

## World structure (interlocking, user call 2026-11-05)
The world should feel like one tangled place, not a corridor of rooms: paths fold back on themselves, and opening a shortcut to a petilasan you rested at an hour ago is a reward in itself. Inspired by Bloodborne's level design only. Tone and difficulty stay as [concept.md](concept.md) says (warm, forgiving, nothing lost on death).

**Terms**
- **Region:** one act (Tatar Sunda, Mataram, Tanah Timur, Segara Kidul, Gua Kala). Desa Purwa is the hub, not a region. Quests, Ilmu tiers and enemy tiers use the region id (`QuestData.zone`).
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
7. Petilasans are few on purpose (2 per region, 3 in the largest): shortcuts, not lamps, shorten the way back.
8. The critical path visits most areas, and the gates (kabut) still follow the story flags. Glyphs stay rewards, not keys.

**Links between regions**
Each region has its main link toward the hub and, later, at least one back route to a neighbour. A back route is a shortcut opened from the later region's side, so it never lets the player skip ahead. Planned back routes: Tatar Sunda lake to the Segara Kidul coast, and a Mataram back road to Tanah Timur. Each region doc names its own.

Endpoint area ids are fixed here so the region docs agree (**ASSUMED** 2026-11-05). Spawn ids follow `from_<other area id>`. Gate flags for acts 2-4 are proposed by the region docs until quests.md names them.

| Link | Area A | Area B | Kind | Opens |
|------|--------|--------|------|-------|
| Hub to Tatar Sunda | `desa_purwa` (W) | `ts_kebun` | link | always |
| Hub to Mataram | `desa_purwa` (E) | `mt_gapura` | link, kabut | `mq1_10` |
| Mataram to Tanah Timur | `mt_wetan` | `tt_kulon` | link, kabut | `mq2_9` (MQ2 2.9, back at Semar) |
| Mataram back road | `mt_tegal` | `tt_sabana` | shortcut `sc:mt_tt` | from `tt_sabana` |
| Hub to Segara Kidul | `desa_purwa` (S, new) | `sk_pantai` | link, kabut | `mq3_8` (MQ3 3.8, back at Semar) |
| Tanah Timur to Segara Kidul | `tt_pesisir` | `sk_karang` | link, kabut | `mq3_8` (MQ3 3.8, back at Semar) |
| Tatar Sunda back route | `ts_situ` | `sk_tebing` | shortcut `sc:ts_sk` | from `sk_tebing` |
| Segara Kidul to Gua Kala | `sk_keraton` | `gk_mulut` | link, kabut | Nyi Roro Kidul trial passed |

Region area graphs live in `.docs/zones/<region>.md`. Tatar Sunda has full tile maps (built in Phase 4); the other regions have graphs only until Phase 5 adds their maps.

## Gating
Soft and story-driven:
- Zone exits are blocked by "kabut" (fog/curse barriers) that clear when the zone boss is defeated.
- Enemy level rises per zone, so rushing ahead is possible but hard.
- Glyph unlocks are tied to zones, so skipping around never breaks progression.

## Zones

### Desa Purwa (start village)
- Purpose: prologue, class choice, tutorial, shop-free hub with the first petilasan.
- Features: the sanggar (practice hall) where you draw glyphs with a guide, the wayang stage, Semar.
- No hostile enemies except tutorial dummies.

### Tatar Sunda (West Java), Act 1
- Look: misty highlands, tea terraces, bamboo, volcanic crater rim.
- Legend: **Sangkuriang and Tangkuban Perahu** (the upturned boat mountain). The crater is the boss arena.
- Glyphs learned: Aksara Sunda (4).
- NPCs: Cepot (comic relief), Abah Karna, the elder who teaches a glyph, side-quest givers ([quests.md](quests.md)).
- Culture: rumah panggung (stilt house), iket (cloth head wrap), angklung (verified: Sundanese, UNESCO 2010), kujang weapon.
- Petilasans: 2 (entrance, before the crater).
- Boss: Sangkuriang ([bestiary.md](bestiary.md)). Miniboss: Sandekala. Elite: the bamboo-grove Kuntilanak (SQ-S2, a locally darkened arena, no day/night cycle).
- Gates (**ASSUMED** 2026-11-05): a kabut on the crater path lifts with flag `mq1_7` (Dayang Sumbi teaches Ca). The Desa Purwa east gate to Mataram stays fogged until flag `mq1_10`.
- Room layout: [zones/tatar_sunda.md](zones/tatar_sunda.md). Desa Purwa: [zones/desa_purwa.md](zones/desa_purwa.md). The sanggar is a room inside Desa Purwa.

### Mataram (Central Java), Act 2
- Look: temple ruins, rice fields, volcano silhouette, stone gateways.
- Legend: **Roro Jonggrang and the thousand temples (Prambanan)**.
- Glyphs learned: Aksara Jawa / Hanacaraka (4).
- NPCs: Ki Sumarto, a dalang (wayang puppeteer) who tells Hanacaraka lore, Pak Karto the stone-carver, side-quest givers ([quests.md](quests.md)).
- Culture: batik, blangkon, gamelan (zone music hook), candi architecture, keris.
- Petilasans: 2.
- Boss: Bandung Bondowoso.

### Tanah Timur (East Java), Act 3
- Look: dry savanna, sea-sand crater plain, banyan and ancient shrines.
- Legends: **Timun Mas and Buto Ijo** (miniboss), **Ken Arok and the keris of Mpu Gandring** (boss). Bromo/Tengger as visual motif (Yadnya Kasada is a living Hindu Tengger ritual: use the landscape as scenery only, never as a quest, mechanic or enemy event; at most a short factual codex entry).
- Glyphs: diacritic/modifier marks (stretch, see [spells.md](spells.md)).
- NPCs: Mpu Wirasana, a keris-smith (empu), side-quest givers ([quests.md](quests.md)).
- Culture: keris making, reog? (skip, not in scope), kuda lumping (verified as a trance dance with disputed origin: show it as performance only, no glass-eating or fire mechanics, no horror trance).
- Petilasans: 2.

### Segara Kidul (Southern Sea), Act 4
- Look: black-sand cliffs, green sea, a palace beneath waves.
- Figure: **Nyi Roro Kidul**, shown with respect. The green association is verified as a belief (wearing green on the south coast is said to attract her). Present it as belief, not a punishment.
- Trial instead of boss: three waves of Lampor, Ula Segara and Bajul Putih ([bestiary.md](bestiary.md)).
- Reward: the final glyph, Jawa Ka (Ombak).
- Petilasans: 1-2.

### Gua Kala (finale)
- Look: dark cavern, hourglass and clock-like motifs, the forgotten letters floating faded.
- Boss: Batara Kala.

## Checkpoints (petilasan)
- A petilasan is a place where a revered figure once rested or meditated (verified usage). Shown as a small shrine with incense and a lit lamp.
- On interact: heal fully, refill flask charges, set respawn, respawn normal enemies, open the menu (level up, equip, codex).
- 2 per region (3 in the largest), plus Desa Purwa. At least one before each boss (World structure rule 7).

## Points of interest per region (target)
- Spread over the region's areas: 1 boss arena, 1 miniboss or elite room, 3-5 NPCs (Tatar Sunda has 10 because it teaches the quest loop, **ASSUMED** 2026-11-05), 2-3 secret rooms (chests with gear), 1 codex-rich location (e.g. a museum-like ruin), 6-10 enemy encounters.

## Codex
Fed by: first meeting an enemy, first picking an item, first learning a glyph, talking to key NPCs, visiting landmarks. Each entry has a title, 1-3 sentences, a source line and (for glyphs) the character and its Latin transliteration.
