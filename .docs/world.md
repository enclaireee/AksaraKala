# World

An open map of connected zones on the island of Java (Sunda and Javanese lands). Zones join at their edges and load when crossed. Legend details fact-checked Nov 2026 (secondary sources).

## Layout (west to east)
```
 [Tatar Sunda]---[Desa Purwa]---[Mataram]---[Tanah Timur]
                      |                          |
                      +-------[Segara Kidul]-----+
                                    |
                               [Gua Kala]
```
- Desa Purwa (village) is the start and the hub. Zones are first reached in the order shown, but the map is connected so the player can backtrack.
- Segara Kidul unlocks after the third boss. Gua Kala unlocks after the Nyi Roro Kidul trial.

## Technical frame
- Viewport 480x270, 16 px tiles (30x17 tiles per screen), integer-scaled. See [architecture.md](architecture.md).
- A zone is a grid of "screens" (rooms), roughly 4x4. The camera follows the player and is clamped to zone bounds.
- Edges between zones are doors/paths that load the next zone scene.

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
- 6-8 in total across the map. At least one before each boss.

## Points of interest per zone (target)
- 1 boss arena, 1 miniboss or elite room, 3-5 NPCs (Tatar Sunda has 10 because it teaches the quest loop, **ASSUMED** 2026-11-05), 2-3 secret rooms (chests with gear), 1 codex-rich location (e.g. a museum-like ruin), 6-10 enemy encounters.

## Codex
Fed by: first meeting an enemy, first picking an item, first learning a glyph, talking to key NPCs, visiting landmarks. Each entry has a title, 1-3 sentences, a source line and (for glyphs) the character and its Latin transliteration.
