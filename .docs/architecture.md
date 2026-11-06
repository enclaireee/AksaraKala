# Architecture (Godot)

Project: Godot 4.7 (`config/features` in `project.godot`), GDScript. Related: [rpg.md](rpg.md), [spells.md](spells.md), [world.md](world.md).

## 1. Project settings for pixel art
Current `project.godot` has the defaults: renderer Forward Plus, stretch mode `canvas_items`, aspect `expand`. Change to:

| Setting | Value | Why |
|---------|-------|-----|
| `display/window/size/viewport_width` x `viewport_height` | 480 x 270 | Soul Knight-like low-res, 30x17 tiles of 16 px |
| `display/window/size/window_width_override` x `height` | 1440 x 810 | Starting window size: exactly 3x. 1280 x 720 is not a whole multiple, so integer scaling would show 2x with borders (changed 2026-11-05) |
| `display/window/stretch/mode` | `canvas_items` | Layout is 480x270, drawn at window resolution: smooth, non-pixel UI text (user call, 2026-11-05). Art stays crisp through Nearest filtering. Cost: sprites can sit between game pixels. If that shimmers in play, move the world into a 480x270 SubViewport and keep only the UI at full resolution |
| `display/window/stretch/scale_mode` | `integer` | No blurry fractional scales |
| `display/window/stretch/aspect` | `keep` | Letterbox instead of stretching |
| `rendering/textures/canvas_textures/default_texture_filter` | `Nearest` | Sharp pixels |
| `rendering/2d/snap/snap_2d_transforms_to_pixel` and `snap_2d_vertices_to_pixel` | on | No sub-pixel shimmer |
| `gui/theme/default_font_antialiasing` and `default_font_subpixel_positioning` | defaults (Grayscale, Auto) | Text is smooth at full resolution under `canvas_items`. The earlier None setting was only needed for `viewport` stretch |
| Renderer | **Compatibility** | Forward Plus is overkill for 2D, and Compatibility is required for web export (confirmed 2026-11-05) |

Also: remove the 3D Jolt physics setting if no 3D is used (harmless).

## 2. Folder structure
```
res://
  main.tscn        Phase 0 crispness check, no longer the main scene (zones/test_room.tscn is, Phase 1a)
  autoload/        game.gd, events.gd, zones.gd, audio.gd
  components/      health, stamina, sakti_gauge, hitbox, hurtbox, hit_flash, status
  data/            combat_tuning.gd/.tres (every combat timing, combat.md 7)
    classes/       ClassData .tres
    items/         ItemData .tres
    enemies/       EnemyData .tres
    glyphs/        GlyphData .tres (templates + guide art)
    spells/        SpellData .tres
    codex/         CodexEntry .tres
    quests/        QuestData .tres (see quests.md)
    dialogue/      per-NPC dialogue entries with quest/flag conditions
    text/          CSV string tables (keys,id,en): quests, dialogue, codex, items, ui
  entities/
    player/        player.tscn, player.gd, states
    enemies/       enemy_base.tscn, one scene per type
    bosses/        one scene per boss
    npc/           npc.tscn
  zones/           one scene per zone, plus shared room pieces
  ui/              hud, menus, dialogue box, codex, level-up, cast overlay
  spells/          spell scenes (projectile, burst, ward, summon)
  tools/           glyph_recorder.tscn (developer-only)
  tests/           headless test scripts (section 12)
  assets/          art/, audio/, fonts/
  .docs/           design docs
```

## 3. Autoloads
| Name | Responsibility |
|------|----------------|
| `Game` | Run state: class, stats, Ilmu, glyphs learned, equipment, healing flask (charges, Flask Shards, Herb Pouches), last petilasan, story flags, quest state, codex unlocks. Advances quest steps on `Events` signals. Autosave and load, one slot (JSON in `user://`, [rpg.md](rpg.md) 11) |
| `Events` | Global signals, decouples systems. Phase 4 list (**ASSUMED** 2026-11-05): `enemy_killed(enemy, ilmu)`, `player_died`, `rested(petilasan)`, `talked_to(npc_id)`, `item_picked(item_id)`, `boss_defeated(boss_id)`, `area_cleared(area_id)`, `area_entered(trigger_id)`, `zone_entered(zone_id)`, `petilasan_activated(id)`, `glyph_learned(id)`, `spell_cast(glyph_id, score)`, `class_chosen(class_id)`, `weakness_triggered(kind)`, `quest_started/updated/completed(id)`, `dialogue_requested(speaker_key, lines)`, `dialogue_finished`. Quest steps match `"<signal>:<arg>"`; for `enemy_killed` the arg is the enemy's `kind` ([quests.md](quests.md) 7.2) |
| `Zones` | Zone loading, fade transitions, spawn points, tracking killed minibosses/bosses and opened gates (the lists live in `Game` so they are saved) |
| `Audio` | Music crossfade, sfx pool, volume buses |

Keep the list short (4). No further autoloads without a reason.

## 4. Data-driven resources
Custom `Resource` types so adding content is data entry:
- `ClassData`: name, starting stats, starting weapon, passive id, spell modifiers, sprite tint
- `ItemData`: name key, slot, archetype, damage/defense, stat bonuses, description key, source note, icon
- `EnemyData`: name, archetype, hp, damage, speed, attack pattern, drops, codex entry
- `GlyphData`: id, script (sunda/jawa), latin name, templates (array of point arrays), guide texture, true-form texture
- `SpellData`: glyph id, name, gauge cost, base power, scene to spawn, class modifier table
- `CodexEntry`: id, category, source; text keys `CODEX_<ID>_TITLE/_BODY/_WEAK` ([quests.md](quests.md) 7.1)
- `QuestData` and `QuestStep`: fields in [quests.md](quests.md) section 7.1. `QuestData.zone` is the region id (`tatar_sunda`, for Ilmu tiers); a step `marker.zone` is an area id (`ts_situ`).
- `DialogueData`: npc id, name key, condition/line/action entries ([quests.md](quests.md) 7.1)

**Text:** all player-facing text is a translation key. Strings live in CSV tables in `data/text/` with `keys,id,en` columns; Godot imports CSV as translations and `tr()` looks them up. Tables: `ui`, `items`, `quests`, `dialogue`, `codex`. Key prefixes: `UI_`, `ITEM_<ID>_NAME/_DESC`, `CLASS_<ID>_NAME/_DESC/_PASSIVE`, `Q_<QUEST>_TITLE`, `Q_<QUEST>_S<n>`, `NPC_<npc>_NAME`, `NPC_<npc>_<n>`, `PROLOGUE_<n>`, `CODEX_<ID>_*`. Language: first launch follows the OS locale (`id` -> Indonesian, else English); the title-screen toggle saves it in `user://settings.cfg`, not in the run save.

## 5. Scene composition
- **Player:** `CharacterBody2D` with child components (Health, Stamina, SaktiGauge, Hurtbox, weapon slot, sprite, `CastController`). A small state machine (idle, move, attack, dodge, hurt, cast, dead).
- **Enemy base:** `CharacterBody2D` + Health + Hurtbox + `Hitbox` + state machine (idle, chase, windup, attack, recover, dead). Specific enemies set `EnemyData` and override patterns.
- **Boss:** an enemy with phases defined by HP thresholds, plus an arena script.
- **Components over inheritance.** Reuse Health, Stamina, Hitbox, Hurtbox, HitFlash on both player and enemies.
- **Weapons:** a weapon scene per archetype that spawns hitboxes or projectiles. Parameters from `ItemData`.
- **Zones:** one scene per area (a region is several areas, [world.md](world.md) World structure; the scene id is the area id, e.g. `ts_kebun`) containing `TileMapLayer`s, enemy spawners (markers), petilasans, NPCs, chests and edge `Area2D` exits (target zone + spawn id).

## 6. Physics layers
1 world, 2 player, 3 enemy, 4 player_hitbox, 5 enemy_hitbox, 6 interactable, 7 trigger/exit. Name them in the project settings.

## 7. Casting system
- `CastController` (on the player or UI layer) handles input: on `cast` pressed, set `Engine.time_scale = 0.2` (settings-driven), show the overlay.
- While casting, collect mouse positions as a `PackedVector2Array`.
- Time must be measured in **real time**: use `Time.get_ticks_usec()` or `get_tree().create_timer(t, true, false, true)` (4th arg ignores time scale). Do not rely on scaled `delta` for the draw time limit.
- On release, call `Recognizer.match(points, learned_glyphs)` and get `{glyph_id, score}`.
- `Recognizer`: pure static GDScript class, no scene dependency, so it can be unit-tested headlessly. Steps: resample to N points (about 32-64), scale to a unit box, translate to the origin, then compare with each template (point-cloud distance), take the best score, apply the thresholds and tie rule in [spells.md](spells.md).
- On success: `Events.spell_cast(glyph_id, score)` -> spell factory instantiates the spell scene with class modifiers -> gauge deducted -> codex unlock if first cast.
- **Restore `Engine.time_scale = 1.0`** in every exit path (cancel, pause, death, scene change). Guard with a single `_exit_cast_mode()`.
- The cast is the only code that sets `Engine.time_scale`. Hitstop and the perfect-dodge pause freeze only the nodes involved ([combat.md](combat.md) 7). Combat timings live in one `CombatTuning` resource.

## 8. Glyph recorder tool
- A dev-only scene: pick a glyph, draw it, save as a new template into the `GlyphData` resource. Record 3-5 variants per glyph.
- Shows the existing templates as faint overlays and warns when two glyphs' templates are too close in score (disambiguation check).

## 9. Zone loading
- Edge `Area2D` exits call `Zones.go_to(zone_id, spawn_id)`, which fades out, swaps the scene, places the player at the spawn marker and fades in. The new player starts with full HP, stamina and sakti; this is intended (user call, 2026-11-05).
- Zone scripts extend `zones/zone.gd` (**ASSUMED** 2026-11-05): `zone_id`, an ASCII `MAP` (any size, in 30x17 screens), and a `SPOTS` dict mapping a map char to `{scene, props, tile}`. The base paints the tiles, places the spots, sets the camera limits from the map size and emits `Events.zone_entered`. Tile chars: `#` wall/cliff, `.` grass, `,` path, `~` water, `b` bamboo, `t` tea, `r` rock, `_` floor. `Zones.ZONES` maps area id to scene path and `Zones.ADJ` lists where you can walk from each area (two-way links; a one-way drop only from its top end; a shortcut only from the side that opens it, listed in `Zones.SHORTCUTS`, drops in `Zones.DROPS`) for the objective arrow's breadth-first search. Area scripts are generated from the region doc by `.docs/gen_zones.py`. Hand-written area code goes in `zones/<area>_base.gd` (extends `Zone`); the generated script extends it when it exists, so a re-run keeps it (desa_purwa: the sanggar practice mode and draw guide).
- Boss and elite scenes are referenced by path and loaded at runtime, so a zone imports cleanly before its boss exists.
- Persistent state (killed bosses, opened fog gates, chests) lives in `Game`, not in the scene.
- Normal enemies respawn by reloading the zone scene (state is intentionally not persisted for them).

## 9b. Kelir memory, Clue and lontar shimmer (Story v4, **ASSUMED**, all numbers **TUNE**)
No new autoload. `Zones` gets two methods; `Game` keeps the return point so it is saved. Spec for [story.md](story.md) "Hunts".

**Clue** (`entities/world/clue.gd`, `class_name Clue extends Interactable`; scene `entities/world/clue.tscn`, placed by zone `SPOTS` like `laras_lontar`):
- Exports: `clue_id: String`, `lines: PackedStringArray` (dialogue keys `CLUE_<ID>_<n>`, 1-2 lines, the hero's own thought, shown as speaker `NPC_hero_NAME`), `journal_key: String` (`CLUE_<ID>_NOTE`, one line), `memory_id: String = ""`, `cond: String = ""` (hidden and not usable while `Game.check(cond)` is false, as `npc.gd`; zone legends need it), `verb = "UI_VERB_EXAMINE"`.
- `interact()`: sets `usable = false` while the lines run. Calls `Game.play`-style dialogue (`Events.dialogue_requested`), and on `dialogue_finished`: `Game.set_flag("clue_" + clue_id)`, `Events.clue_examined.emit(clue_id)`, then if `memory_id != ""` calls `Zones.enter_memory(memory_id)`. A memory clue with no `CLUE_<ID>_<n>` text plays no lines and pulls you straight in (K0 `kelir_lamp`, `lc1_voice`). Examined clues stay examinable (lines replay, no new flag, no memory re-entry unless `flag:memory_<id>` is unset).
- On `_ready`, if `flag:clue_<id>` is set the clue stays in the group but never shimmers. Journal notes are read from the flags: no clue list is stored apart from the flags.
- New signals in `Events` (**ASSUMED**): `clue_examined(clue_id)`, `memory_started(memory_id)`, `memory_done(memory_id)`. Quest steps match `clue_examined:<id>` and `memory_done:<id>` like the other signals ([quests.md](quests.md) 7.2). `memory_done` also sets `flag:memory_<id>`.

**Kelir memory** (`zones/kelir/<id>.tscn`, script `zones/kelir/memory.gd`, `class_name KelirMemory`; the scene ids are the `memory_done:<id>` ids in [quests.md](quests.md) 4, e.g. `k1_maghrib`, `h1`, `lc1`, `la`; short ids like `k1` below are labels only):
- It is a small zone scene (one screen up to 2x2 screens, no exits, no enemies, no petilasan). Base script `memory.gd` is not a `Zone` subclass: it needs no `MAP`. Art is built from the same `TileMapLayer`s but tinted, plus sprites of black silhouettes.
- **Look (cheap).** A `CanvasModulate` sets the scene to warm paper (#F2D9A0 lit). A full-screen `ColorRect` overlay with a small shader darkens everything by distance from the lamp node (a `PointLight`-free radial gradient, one uniform `lamp_pos`, `lamp_radius` 120 px **TUNE**); outside it the screen is dim brown (#3A2616). Characters and props are drawn as flat near-black sprites (modulate #1A1008), no outlines. A thin cloth-texture overlay at 6% alpha. No real `Light2D` (cost). Frame: ui.md 3 "Kelir memory frame".
- **Enter.** `Zones.enter_memory(id)`: stores `Game.memory_return = {zone, pos}` (the current zone id and player global position, saved in `Game.to_dict()` so a quit during a memory resumes at the clue), emits `memory_started`, fade, `change_scene_to_file("res://zones/kelir/<id>.tscn")`, fade in. Reuses `go_to`'s `_busy` guard and fade helpers.
- **Stand-in.** The memory scene has a `Stand` marker. `memory.gd` frees the normal Player node (group `player` is kept: the stand-in is `entities/player/stand_in.tscn`, a `CharacterBody2D` in group `player` with a `Sprite2D` silhouette, speed 70 **TUNE**, 8 directions, collision layer as the player). It has `move_*` plus ONE context action on `interact` (`action_kind` set per memory: `light`, `spread`, `pound`, `throw`, `douse`, `read`). No attack, dodge, flask or casting. Exception: K7 sets `allow_cast = true` and shows the cast overlay for the Sunda/Jawa letters. Hero HP, stamina and sakti are not touched.
- **Cannot be failed hard.** `memory.gd` has `fail()`: a fade-to-lamp of 0.5 s, then reset the memory scene state in place (`reload_current_scene()` is not used; the script resets its props and the stand-in position). No HP loss, no death screen, no counter. After 3 fails the action hint line shows its text again and the threat slows 25% (**TUNE**, **ASSUMED**).
- **Finish.** `memory.gd.finish()`: Semar's end line, fade, `Game.set_flag("memory_" + id)`, `Events.memory_done.emit(id)`, then `Zones.exit_memory()`: `go_to(Game.memory_return.zone, "")` and then sets the player position to `Game.memory_return.pos` (`go_to` only supports spawn markers; add an optional third argument `pos: Vector2 = Vector2.INF` that overrides the spawn). Clears `memory_return`. Replaying an old memory is possible from the clue only if `flag:memory_<id>` is unset; there is no replay menu (stretch).
- **Narration.** Semar, 1-2 lines at start and end, as story-beat style lines with speaker `NPC_semar_NAME`, keys `MEM_<ID>_IN`, `MEM_<ID>_IN_2`, `MEM_<ID>_OUT` and `MEM_<ID>_OUT_2` (the CSV and `memory.gd` use IN/OUT). Uses the dialogue box with the speaker tag set to "Semar (Dalang)". Memories never show a kill on screen: the end is a fade to the lamp.
- **Rule.** A memory teaches by doing the thing that wins the fight ([story.md](story.md) Pacing 13); the mapping per boss is in [bestiary.md](bestiary.md) "Hunt:" lines. A memory lasts 2-4 minutes (K6 2 minutes, **TUNE**).
- **Saving.** Autosave is off inside a memory. A save made at the clue before entering is enough; `memory_return` in the save lets Continue resume at the clue.

**Memory types and table (v4b, **ASSUMED**, **TUNE**).** `memory.gd` has an exported `kind`: `play` (the K memories above; built from two generic nodes, `MemorySpot` (`zones/kelir/memory_spot.gd`, an Area2D with `action_kind`, `order` and an optional line key: `interact` there counts as progress, all spots done calls `finish()`) and `MemoryThreat` (`memory_threat.gd`, a shadow moving along a path; touching the stand-in calls `fail()`); only K0 (the shadow eats the unlit side) and K7 (`allow_cast`) get a small subclass), `walk` (movement only, no action, no fail state; H1-H4, K-II, K-III, K8, K9, K10 are mostly this, plain scenes with a path of marker triggers and narration), `chapter` (Laras, below) and `gap` (Act VI, below). No new system beyond these two. **Scenes are generated, not hand-built:** `python3 .docs/gen_memories.py .docs/zones/<region>.md` reads each `### Memory` section (scene path, `Kind`, fenced map, legend) and writes `zones/kelir/<id>.tscn`: a `KelirMemory` root, tiles (`_` lit floor, `#` dark wall, `~` water), `Stand`, `Checkpoint` markers, the goal, `faceless_patrol`, hide spots, narration triggers, and every other legend char as a `MemorySpot`. Roles come from a keyword table over the legend's What column; any char it cannot place is printed, and that legend row is fixed in the doc. A row whose What or Notes says `decor`, `NPC`, `does not move`, `closed` or `narrator` becomes a plain marker that does not count; `hide` rows become `Marker2D` in group `hide`. In a `walk` memory only the goal and the narration triggers are live (the rest are markers). Every memory needs a goal row or at least one action, or it never finishes. Gap memories are not generated (one `gap.tscn` plus data). A row whose Notes say `` `interact` `` is an interact `MemorySpot`; an order is a lone digit in the row (so "120 px" is not an order). If `zones/kelir/<id>.gd` exists, the generator uses it as the root script instead of `memory.gd` (K0: `k0_ruwatan.gd`, tested by `tests/k0_test.gd`).

| Id | Kind | Stand-in | Where it fires | Notes |
|----|------|----------|----------------|-------|
| k0-k7 | play | per Hunts table | clue or beat | as above |
| k_ii, k_iii | walk | Lengser's servant; the younger brother | Act II, Act III (Ki Sumarto's show) | K-III teaches pamali |
| h1-h4 | walk | young Aria Kebonan | mask fragments (far rim, throne shadow, graves, before the duel) | about 1 minute each; the mask fragment is a Clue with `memory_id` |
| k8, k9 | walk | Mbah Wiryo's wife; the sea queen in Ki Sumarto's telling | Act V | no death shown, fade to light |
| k10 | walk | young Kala / Semar's tale (Murwakala) | Act VI | **VERIFY** |
| lc1-lc6 | chapter | Laras | one per act | below |
| gap_la, gap_ra, gap_sa | gap | the hero, on the prologue day | Act VI | below |

**Laras chapter** (`kind = "chapter"`, scene `zones/kelir/lc<n>.tscn`, stand-in `entities/player/stand_in_laras.tscn`). Same kelir look but a cooler, bluish tint: CanvasModulate #D5E2F0 lit, dim #1E2A3A outside the lamp. This marks it as her side, not a legend. Her one action is `interact` = "say the true name": it picks the nearest node in group `faceless` within 48 px and calls `freeze(3.0)` (3 s, **TUNE**); 6 s cooldown shown as a small ring on the hint glyph. No attack, no dodge, no casting. A Faceless "sees" her when she is inside its cone (r 72 px, 90 degrees, **TUNE**) and not behind a `hide` prop: `fail()` fades and restarts at the last `Checkpoint` marker (an `Marker2D` group `checkpoint`, last one entered wins), with no HP loss. Faceless in chapters are not `EnemyBase`: simple `Node2D` patrols (`faceless_patrol.gd`) with `freeze()`. Each chapter ends on a `write` of *Ka* (one glyph, ui.md 3 write card) then `memory_done:lc<n>`. Tone: the hero's HUD is hidden. Frame as ui.md "Kelir memory frame" with the bluish tint and no Semar narration (Laras's own 1-2 lines, speaker `NPC_laras_NAME`).

**Gap memory** (`kind = "gap"`, `zones/kelir/gap.tscn` plus data, one per letter). A replay of a prologue-day spot (La: the tag game in the lane; Ra: Ibu's table with the two cups; Sa: the sanggar and the lontar) shown in the warm kelir look. Grey gaps (`ColorRect` with a noise shader, 24x24 px **TUNE**) hide details. Data is a `GapMemoryData` resource (`data/memories/gap_<la|ra|sa>.tres`): `memory_id`, `scene_spot`, `gaps: Array[{gap_id, pos, prompt_key, options: Array[{key, icon}], correct: key}]`. Options are 3 per gap (text key `GAP_<ID>_<n>`, icon optional). The player walks to a gap and presses `interact`; it plays a dialogue entry made at runtime, prompt `GAP_<ID>_P` with the 3 options as dialogue choices (no new list UI); the right choice runs the action `flag:gap_<gap_id>`. A wrong pick flashes the gap grey for 0.5 s, plays a soft thud, stays open, nothing is lost and no counter is kept. A right pick fills the gap with the detail and sets `flag:gap_<gap_id>`. Three right picks (**TUNE**, 3 gaps per memory) call `finish()`, then `memory_done:gap_<letter>` and the letter is added to the `write` card in the finale. After 2 wrong picks on one gap the right option pulses faintly (**ASSUMED**). Tests: every `correct` is among `options`; every key exists in both languages.

**Doorposts (Interlude 4.1).** Not a memory. Reuses the existing `write:<seq_id>:<glyph_ids>` step and the `ui/glyph_lesson` write card. Three seq ids: `door_a`, `door_b`, `door_c` (as quests.md 4.2 and desa_purwa.md; **ASSUMED**; glyph ids are set by quests.md).

**Lontar shimmer.** Done by the player, not a new node tree: `entities/player/lontar_shimmer.gd` (child of Player, `Node2D`) polls every 0.25 s the `interactable` group for `Clue` nodes with `not has_flag("clue_" + id)` within `SHIMMER_RANGE = 48` px, and drives a `GPUParticles2D`-free effect: a small sprite glow on the player's belt lontar (6 flickering `ColorRect` 1x1 motes) whose alpha follows `1 - dist/48`. Also plays a soft chime `sfx_lontar` once when it first fires for a clue. The effect is off inside a memory, in cast mode, and while a dialogue is open. Visual and accessibility details: [ui.md](ui.md) 3 "Lontar shimmer". Shimmer is only a hint: clue prompts use the normal interact prompt.

**Name tag data.** `Game.flag("seen_name_<npc_id>")` set the first time `dialogue_box` opens for a named NPC; the tag text key is `NPC_<id>_WHO` and is looked up with `tr()`, shown only if the key resolves. No new autoload. [ui.md](ui.md) 3.

**Journal data.** "Story so far" reads `QuestData` steps whose index is below the current step, using a new optional step field `recap: String` (key `Q_<QUEST>_S<n>_DONE`, 1 line); clues read from `flag:clue_*` and `CLUE_<ID>_NOTE`. Both are read-only views over `Game`.

**Tests.** `tests/clue_test.gd` (a Clue sets the flag, emits the signal, enters its memory), `tests/memory_test.gd` (every `zones/kelir/*.tscn` loads, has a `Stand` marker and calls `finish`; fail resets; return restores zone and position), and a key check that every `CLUE_*`, `MEM_*` and `NPC_*_WHO` key exists in both languages.

## 10. UI
- `CanvasLayer` HUD: bars (HP, stamina, sakti), flask, weapon, Ilmu.
- Dialogue box with typewriter text and a speaker name. Optional portraits (stretch).
- Menus: pause, equipment and stats, level-up (at petilasan), codex, journal, glyph viewer, settings (incl. language).
- Sizes and layout: [ui.md](ui.md).
- Quest UI: soft edge-of-screen objective arrow, NPC quest icons, toasts ([quests.md](quests.md) section 7.4-7.6).
- Use theme resources and a pixel font. Aksara text needs Noto Sans Javanese / Sundanese. **Test complex-script rendering early.** If Godot's text server does not shape them correctly, fall back to pre-rendered glyph images.

## 11. Input map
`move_up/down/left/right`, `attack`, `dodge`, `cast`, `heal_jamu`, `interact`, `menu`, `pause`. P0: two presets and a mouse-button swap; P1: free rebinding. Details and notes: [controls.md](controls.md).

## 12. Testing
- `Recognizer` unit test: a headless GDScript (run with `godot --headless -s tests/recognizer_test.gd`) that feeds recorded templates (with noise) and asserts the right glyph is returned and a wrong one is never returned above the threshold.
- Quest data check: a headless script that validates every `QuestData` (flags, markers, items, keys present in both languages). See [quests.md](quests.md) section 7.8.
- Save round-trip: a headless script that fills `Game` with sample state, saves, loads into a fresh `Game`, and asserts the two `to_dict()` results are equal. Also loads a save with a missing field and a broken file to check the default merge and the `save.bak` fallback.
- Playtest checklists per phase in [schedule.md](schedule.md).
- No big test framework unless it is needed later.

## 13. Build and export
- Export presets for Windows and macOS (user's machine is a Mac), Web if Compatibility renderer is used.
- Keep `.docs/` out of the exported build.
- Remember `.gitignore` for `.godot/` and export artifacts.

## 14. Technical risks
| Risk | Mitigation |
|------|------------|
| Recognizer false positives | Tie rule, learned-only candidates, unit test, per-glyph template review |
| Slow-mo breaking timers | Use real-time APIs, single exit path restores time scale |
| Aksara font shaping | Early test, pre-rendered fallback |
| Pixel shimmer with camera movement | Snap camera to whole pixels, integer scaling |
| Zone transitions losing state | State in `Game`, not scenes |
