# Architecture (Godot)

Project: Godot 4.7 (`config/features` in `project.godot`), GDScript. Related: [rpg.md](rpg.md), [spells.md](spells.md), [world.md](world.md).

## 1. Project settings for pixel art
Current `project.godot` has the defaults: renderer Forward Plus, stretch mode `canvas_items`, aspect `expand`. Change to:

| Setting | Value | Why |
|---------|-------|-----|
| `display/window/size/viewport_width` x `viewport_height` | 480 x 270 | Soul Knight-like low-res, 30x17 tiles of 16 px |
| `display/window/size/window_width_override` x `height` | 1440 x 810 | Starting window size: exactly 3x. 1280 x 720 is not a whole multiple, so integer scaling would show 2x with borders (changed 2026-11-05) |
| `display/window/stretch/mode` | `viewport` | Render at 480x270 then scale, keeps pixels crisp |
| `display/window/stretch/scale_mode` | `integer` | No blurry fractional scales |
| `display/window/stretch/aspect` | `keep` | Letterbox instead of stretching |
| `rendering/textures/canvas_textures/default_texture_filter` | `Nearest` | Sharp pixels |
| `rendering/2d/snap/snap_2d_transforms_to_pixel` and `snap_2d_vertices_to_pixel` | on | No sub-pixel shimmer |
| `gui/theme/default_font_antialiasing` and `default_font_subpixel_positioning` | None, Disabled | Anti-aliased text turns into soft grey blocks when scaled up (found 2026-11-05) |
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
| `Game` | Run state: class, stats, Ilmu, glyphs learned, equipment, jamu (charges, Kendi, Rempah), last petilasan, story flags, quest state, codex unlocks. Advances quest steps on `Events` signals. Autosave and load, one slot (JSON in `user://`, [rpg.md](rpg.md) 11) |
| `Events` | Global signals: `player_died`, `enemy_killed`, `glyph_learned`, `petilasan_activated`, `dialogue_started`, the quest triggers and `quest_started/updated/completed` ([quests.md](quests.md) section 7.2), etc. Decouples systems |
| `Zones` | Zone loading, fade transitions, spawn points, tracking killed minibosses/bosses and opened gates (the lists live in `Game` so they are saved) |
| `Audio` | Music crossfade, sfx pool, volume buses |

Keep the list short (4). No further autoloads without a reason.

## 4. Data-driven resources
Custom `Resource` types so adding content is data entry:
- `ClassData`: name, lineage, starting stats, starting weapon, passive id, spell modifiers, sprite tint
- `ItemData`: name key, slot, archetype, damage/defense, stat bonuses, description key, source note, icon
- `EnemyData`: name, archetype, hp, damage, speed, attack pattern, drops, codex entry
- `GlyphData`: id, script (sunda/jawa), latin name, templates (array of point arrays), guide texture, true-form texture
- `SpellData`: glyph id, name, gauge cost, base power, scene to spawn, class modifier table
- `CodexEntry`: id, title key, text key, source
- `QuestData` and `QuestStep`: fields in [quests.md](quests.md) section 7.1

**Text:** all player-facing text is a translation key. Strings live in CSV tables in `data/text/` with `keys,id,en` columns; Godot imports CSV as translations and `tr()` looks them up. Language picked at first launch, changeable in settings.

## 5. Scene composition
- **Player:** `CharacterBody2D` with child components (Health, Stamina, SaktiGauge, Hurtbox, weapon slot, sprite, `CastController`). A small state machine (idle, move, attack, dodge, hurt, cast, dead).
- **Enemy base:** `CharacterBody2D` + Health + Hurtbox + `Hitbox` + state machine (idle, chase, windup, attack, recover, dead). Specific enemies set `EnemyData` and override patterns.
- **Boss:** an enemy with phases defined by HP thresholds, plus an arena script.
- **Components over inheritance.** Reuse Health, Stamina, Hitbox, Hurtbox, HitFlash on both player and enemies.
- **Weapons:** a weapon scene per archetype that spawns hitboxes or projectiles. Parameters from `ItemData`.
- **Zones:** one scene per zone containing `TileMapLayer`s, enemy spawners (markers), petilasans, NPCs, chests and edge `Area2D` exits (target zone + spawn id).

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
- Edge `Area2D` exits call `Zones.go_to(zone_id, spawn_id)`, which fades out, swaps the scene, places the player at the spawn marker and fades in.
- Persistent state (killed bosses, opened fog gates, chests) lives in `Game`, not in the scene.
- Normal enemies respawn by reloading the zone scene (state is intentionally not persisted for them).

## 10. UI
- `CanvasLayer` HUD: bars (HP, stamina, sakti), jamu, weapon, Ilmu.
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
