# Capture harness (real in-game footage with Godot Movie Maker)

One command per shot. A shot is a GDScript file in `video/capture/shots/<name>.gd` that extends `shot.gd`.

```
video/capture/shoot.sh <shot> --preview      # 480x270 render, upscaled 4x nearest -> out/raw/<shot>_preview.mp4  (~50% real time)
video/capture/shoot.sh <shot>                # 1920x1080 direct render                -> out/raw/<shot>.mp4          (~14% real time)
video/capture/shoot.sh <shot> --native       # 480x270 render, upscaled 4x nearest   -> out/raw/<shot>.mp4          (~50% real time)
   options: --half (960x540), --res WxH, --keep (keep PNG+WAV in out/tmp/<shot>_<mode>/), --out PATH,
            --set key=value (read in the shot with arg("key", default)); env GODOT=... to change the binary
python3 video/capture/frames.py out/raw/<shot>.mp4 6    # 6 stills + contact sheet into out/preview/
```

Output: H.264 crf 10 yuv420p 60 fps, AAC 320k 48 kHz, only the frames between `rec_start()` and `rec_stop()`
(audio trimmed to match). Temporary PNGs are deleted unless `--keep`. The log is next to the mp4 (`.log`).
A shot **fails loudly** (exit 1, last log lines printed) on `fail()`, a timed-out wait, a stuck walk, a
mis-read cast, any `SCRIPT ERROR`/parse error, a missing `@@SHOT done`, or Movie Maker not recording at the
asked size. A watchdog stops shots that run past `max_seconds` (config, default 600).

## How it works (read once)
- `xvfb-run` + `--write-movie f.png` (lossless PNG sequence + WAV) + `--fixed-fps 60`, run as
  `-s res://video/capture/runner.gd -- --shot=<name>`. The runner adds the shot node under `/root` (it
  survives zone changes), calls `run()`, quits. Everything is frame-counted: no wall-clock sleeps.
- **The 1440x810 trap:** Movie Maker sizes the movie from `project.godot`'s `window_*_override` (1440x810)
  and resamples every frame to it, whatever `--resolution` says. `shoot.sh` therefore runs the game from a
  *shadow project* `out/shadow/<WxH>/` (symlinks to every repo entry + an `override.cfg` with the size).
  Nothing in the repo changes. `shoot.sh` checks the log says `recording movie in 1920×1080`.
- Game user data goes to `out/tmp/<shot>_<mode>/userdata` (`XDG_DATA_HOME`): the real save is never touched.
- `video/capture/.gdignore` keeps Godot's importer out of here; scripts still load by `res://` path. Do not
  add `class_name` to capture scripts.
- Locale `en`, the Music bus muted (per shot: `config()`), global RNG seeded (same shot = same play at any
  resolution), story beats (auto dialogues) blocked, tutorial pills marked done.
- **Game bug worked around:** NPC/villager shadows and some ambient FX `load()` a texture inside `_draw()` and
  keep no reference, so it is freed and the canvas draws an opaque white/cream box under every character.
  `shot.gd` pins every texture in `assets/art/{world_fx,fx,ambient,telegraph,props}` (config `pin_dirs`).
- Wall-clock bits the game has (cast draw time limit, ink brush speed) are fed footage time by the harness.
  Others still run on the wall clock and so animate ~3-7x too fast in captures: shooter enemies' hover bob,
  boss `oncor` flames, Kelir memory walk cycles, `path_dancer`, dialogue `#wait` holds and the
  "next" cue blink. Avoid lingering on those.

## Writing a shot
```gdscript
extends "res://video/capture/shot.gd"

func config() -> Dictionary:
	return {"music": false, "sfx": true, "ambience": true}   # also: locale, seed, max_seconds, hero_name, pin_dirs

func run() -> void:
	await start_demo({"index": 11})        # story state via the game's Demo route (list: list_checkpoints.gd)
	await go("ts_kebun", "from_ts_kampung")
	make_strong(18)
	clear_enemies(); god = true; infinite_sakti = true
	show_hud()
	teleport(cell(42, 18))
	var foes := spawn_ring("faceless", hero().global_position, 3, 90.0, true)
	await wait_seconds(1.0)                # let fades/area titles pass before recording
	rec_start()
	for f in foes: wake(f)
	await wait_seconds(1.0)
	await cast_glyph("sunda_ca", {"center": Vector2(240, 100), "size": 100.0})
	await wait_seconds(3.0)
	rec_stop()
```
Explore a zone first: `shoot.sh _explore --set zone=desa_purwa --set demo=11 --set zoom=0.25 --keep` prints
spawns/NPCs and writes an overview frame (`--set x=.. --set y=.. --set zoom=1` for a close look).
`$GODOT --headless --path . -s res://video/capture/list_checkpoints.gd` lists the 54 demo checkpoints.

## API (`shot.gd`)
Coordinates: *world px* (zone space, 16 px tiles) unless "screen", which is the native 480x270 screen.

**Setup**
- `start_demo(query: Dictionary, cls := "mage")` – Demo route to a checkpoint (`{index}` or any of `kind/zone/boss/quest`), hero placed there.
- `start_new(cls := "mage", zone := "desa_purwa", spawn := "")` – plain new game (story start) straight into a zone.
- `new_game(cls)` – new game, no zone load.
- `go(zone, spawn := "", pos := Vector2.INF)` – real `Zones.go_to`, waits for the fade-in. Resets the shot camera.
- `make_strong(level := 20, glyphs := GLYPHS)` – levels (class build), learns glyphs (all 20 by default), best weapon of the class kind + heaviest armor.
- `god` / `infinite_sakti` / `infinite_stamina` (vars) – HP refilled every frame (hits still flinch), sakti/stamina full.
- `no_beats` (var, default true) – story-beat dialogues never start. `skip_tutorials()`, `flag(name)`.
- `set_bus("Music"|"SFX"|"Ambience", on)`; `arg(key, default)` for `--set` values.

**Recording, waiting, time**
- `rec_start()` / `rec_stop()` – the cut. `mark(label)` – prints `[mark] frame N label` for the edit.
- `wait_frames(n)`, `wait_seconds(s)` (footage seconds), `wait_until(callable, timeout_frames := 600, msg)` – fails the shot on timeout.
- `time_scale(scale, ramp_seconds := 0.0)` – slow motion via `Engine.time_scale` (casting resets it to 1 when it ends).
- `fail(msg)`.

**Scene access**
- `zone()`, `hero()`, `game_ui()`, `hud()`, `map_rect()`, `cell(x, y)` (doc-map cell -> world px, as the zone docs count), `spot(id)` (spawn/petilasan/NPC id/node name -> world px), `enemies(p, radius)`.

**UI**
- `hide_hud()` – HUD, area titles, quest cards, tutorial pills, dialogue box, "[E] Talk" prompts.
- `show_hud(clean := true)` – HUD back; clean keeps tracker, objective arrow, [Esc] hint, toasts, save icon, banners, prompts hidden.
- `hide_ui(parts)` / `show_ui(parts)` – parts: hud tracker arrow menu_hint banner toast boss_bar saved area_title quest_card tutorial vignette dialogue prompts.
- `show_cursor(on := true)` / `hide_cursor()` – the game's cursor art drawn into the footage (the OS cursor is never recorded).
- `show_lesson(glyph_id)` / `close_lesson()` – the glyph lesson card (aksara in its Noto font, stroke guide).

**Camera** (shot camera; the game camera stays on the hero)
- `cam_detach(at = null)` – take over at a world point (default: current view). `cam_attach()` – back to the game camera.
- `cam_pan(from, to, seconds, ease := "in_out")`, `cam_move_to(to, seconds, ease)`; ease: linear in out in_out smooth.
- `cam_zoom(z, seconds := 0, ease)` – whole numbers keep the pixel grid.
- `cam_follow(node = hero, offset := Vector2.ZERO, lerp := 1.0)`, `cam_limits(on)` (clamp to the map), `cam_center()`.
- `cam_snap` (var, native px grid, default 1). Note: the project snaps 2D transforms to the native pixel grid,
  so the world always moves in whole game pixels (4 screen px at 1080p) whatever this is. For an even pan use
  a linear ease at a whole number of px per frame (60 px/s = 1 px/frame); eased pans step 0/1/2 px.
- `world_to_screen(p)`, `screen_to_world(p)`.

**Hero** (real input: move actions held with analog strength, actions sent with `Input.parse_input_event`, the mouse moved with `Input.warp_mouse` so the game receives real motion events)
- `walk_to(p, speed := 1.0, arrive := 3.0)`, `walk_path(points, speed)` – speed = fraction of the 90 px/s walk; fails if the hero stops making progress (wall).
- `hold_move(dir)` (length = speed fraction) / `stop()`, `teleport(p)`.
- `dodge(dir)`, `attack(times := 1, target = null, gap := 16)` (target: world point or node), `press(action, pressed := true)`.
- `aim_at(world point or node)` (mouse tracks it; the hero aims there), `face(dir)`, `mouse_screen(p)`.

**Casting**
- `cast_glyph(glyph_id, o := {})` -> `{glyph, score, power}` – holds `cast` (slow-mo, overlay), moves the mouse
  along the glyph's stroke template (`data/glyphs/<id>.tres`) frame by frame with an eased speed and slight
  jitter, the real ink trail draws, releases; the real `Recognizer` picks the spell. Options: `center` (screen,
  default 40 px above the hero), `size` (96), `seconds` (1.3 draw time in footage), `ease`, `jitter` (0.6 px),
  `template` (0), `aim_at` (world point/node the spell flies at), `hold_frames` (3), `expect` (true: fail unless
  read as this glyph at full power), `debug`. Works for all 20 ids; a glyph not yet learned is learned first.
  Class signature glyphs only do something for their own class (mage: `jawa_wa`). Exact template strokes read
  at ~0.99.

**Enemies**
- `spawn_enemy(kind, p, asleep := false)` (`entities/enemies/<kind>.tscn` or a res:// path), `spawn_ring(kind, center, count, radius := 48, asleep, phase)`.
- `freeze(e, on)` / `wake(e)`, `clear_enemies(encounters := true)` (also removes encounter areas, which would spawn waves when the hero steps in).

## Files
`shoot.sh` (CLI), `runner.gd` (entry), `shot.gd` (API), `shots/*.gd` (shots; `_`-prefixed = dev tools:
`_explore`, `_compare`, `_calib`), `frames.py` (stills), `compare.py` (1080p vs 4x-upscale diff),
`list_checkpoints.gd`.
