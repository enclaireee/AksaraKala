# Performance & Memory

Status: P1 (zone build), the quest-lookup fix and P3 (audio memory) are DONE (2026-11-12). The rest is measured and left
alone on purpose (§4). Measure with `tests/perf_probe.gd` (§2) before and after any change to zone building, deco, town
life, quest data or Audio.

## 1. Results (Godot 4.7-stable, headless, Linux cloud container; a desktop is faster, the ratios hold)

| What | Before | After |
|---|---|---|
| Build every one of the 46 zones once (cold) | 22.3 s | 12.1 s (1.8x) |
| Same, second build (a respawn reloads the scene) | 20.6 s | 10.7 s (1.9x) |
| Slowest zone (desa_purwa) | 1140 ms | 557 ms |
| tt_sabana / mt_reruntuhan / gk_pasir | 926 / 927 / 791 ms | ~470 / ~410 / ~370 ms |
| One `quest_updated` event in desa_purwa (49 NPCs recompute) | 176–204 ms freeze | 2 ms |
| One `Game.check("step:..")` / `("quest:..")` | 1286 / 806 µs | 8 / 5 µs |
| Memory growth after walking all zones' music and ambience | +105 MB (46 tracks kept) | +10 MB (current zone's tracks only) |
| Script time per frame in desa_purwa (`_process` + `_physics_process`) | 0.33 + 0.10 ms | 0.33 + 0.10 ms (already small) |

Output is unchanged. The probe fingerprints each zone: every TileMapLayer cell, the grid, every deco prop, and the
name, class and position of every node under Entities, including villagers, animals and buildings. All 46
fingerprints match the old code. The test suite fails the same 8 tests before and after (aksara_render, cast,
chaser, hunter (a script error, then a timeout), loop, room_smoke, ui, weakness). None of them read the changed
code paths' output differently.

## 2. The probe
`$GODOT --headless --path . -s tests/perf_probe.gd` reports, and always exits 0:
- per zone: cold and warm build time, node count, and the 4-part fingerprint. `PROBE_ONLY=a,b` limits it to some zones.
- audio: the music and ambience streams still cached, and static memory, after the probe requests every zone's plan
  and lets 5 s of fades run.
- runtime: script time per frame in desa_purwa, measured by marker nodes that process first and last (wall clock is
  useless headless, because it sleeps 6.9 ms between frames), and the cost of one quest event.

## 3. What changed
- **Zone grid read as bytes** (`zones/zone.gd`, `zones/deco.gd`). In GDScript, indexing a String makes a new
  one-char String each time, and the build did this hundreds of thousands of times per zone. `Zone.rows_bytes`,
  `char_set` and `mask_of` turn the grid into byte arrays once. `dist_field`, the flood fill, the tile painter and
  every deco pass read bytes. Constants `Zone.C_HASH`, `C_WATER`, `C_PATH`, `C_GRASS`, `C_T` and `C_FLOOR` name the
  chars.
- **Erosion labeling in one pass** (`_erode`). Before, it ran a full flood fill and then a full-grid scan for each
  walkable region. Now one BFS labels everything, in the same scan order, so the labels are identical. The noise is
  only computed for cells that can change.
- **Deco ground edges** (`deco.gd _ground/_edge/_decal`). Each edge kind has a bordered neighbour mask, so `_edge`
  reads 8 bytes instead of making 8 calls plus an engine `get_cell_source_id` call. That call was always -1: each cell
  is visited once per layer. `_decal` works out each hash or noise only on the branch that uses it.
- **Town life** (`zones/town_life.gd _near_char`). Placement asked "is a fence, stall or crop within 3 cells?" for
  every walkable cell, which meant 49 String reads each. Now one `Zone.dist_field` is built per query kind and each
  question is a single lookup. Off-map cells and queries that include `#` still use the old loop.
- **QuestData.by_id cache** (`data/quest_data.gd`). Nothing held a loaded quest, so Godot freed it, and every
  condition check parsed the .tres from disk again. Every NPC re-checks its entries on each quest and talk event.
  `res://` quests are now cached. `user://` test fixtures still load fresh.
- **Audio** (`autoload/audio.gd`). `_on_zone` calls `_trim_cache`, which drops the music and ambience the new zone
  does not use. A voice that fades out to silence clears its player's stream. A stopped AudioStreamPlayer otherwise
  keeps its last track alive, and an Ogg stream holds its whole file in memory.

## 4. Measured and left alone
- **Per-frame logic**: 0.4 ms of script per frame in the busiest town, out of a 16.6 ms budget. The cleanups planned
  here (HUD lookups, LPF bus lookups, NPC culling, hit-flash material, boss shot trails, recognizer template cache)
  would save microseconds and could cause bugs. They were not done.
- **Respawn cache** (restoring a built zone from memory): a warm build now takes 100–550 ms, behind the black fade.
  A cache would have to capture every deco node, building texture and villager. Revisit only if playtests show a
  hitch.
- **Threaded scene load** (P2): the .tscn files are tiny, and the cost is `_build` in `_ready`, which has to run on
  the main thread. There is nothing to gain.
- **Still the largest per-zone costs, if more is needed**: in `deco._landmarks`, the candidate scan reads a 3x3
  block per cell (40–65 ms). Game UI instantiation is 40–110 ms per zone. Buildings image compositing is about
  55 ms per town. The ground variant loop is about 40 ms.
- **Build size (P4)**: audio is 115 MB of about 125 MB. If a web export is made, add an export filter for `tools/*`
  (the preview PNGs) and `tests/*`, and consider Vorbis q3 for the music, which is VERIFY by ear (audio.md §7).
