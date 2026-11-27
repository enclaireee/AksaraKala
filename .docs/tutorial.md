# Tutorial: Pelajaran Desa Purwa (Prologue Onboarding)

How AksaraKala teaches its core verbs, Aksara casting, class mechanics, and RPG loop directly inside the Desa Purwa Prologue (`MQ0`, *Hari Biasa Terakhir*) through tactile, diegetic story moments.

Related: [controls.md](controls.md) (input reference), [combat.md](combat.md) (combat timing), [spells.md](spells.md) (casting & Sakti), [classes.md](classes.md) (class passives), [quests.md](quests.md) (`MQ0` steps), [ui.md](ui.md) (dusk palette & HUD).

---

## 1. Design Principles

1. **One Unified Onboarding System:** All prologue teaching flows through one coordinated system (`data/lessons.gd`, `ui/tutorial.gd`, `ui/world_bark.gd`, `ui/world_beacon.gd`, `ui/hud.gd` spotlights, `ui/glyph_lesson.gd`, and `zones/desa_purwa_base.gd`) — no overlapping ghost guides, no duplicate pills, no buried one-off toasts.
2. **Required Story Beats with Replay Skip:** Key hands-on drills (Cepot's sanggar combo & class warm-up, Semar's Aksara-to-Sakti cast, and post-raid Petilasan rest) are genuine `MQ0` sub-goals so first-time players feel every loop before Tatar Sunda. Returning players can skip via an in-character dialogue choice on Cepot/Semar or the **Skip Tutorials** toggle (`GameSettings.skip_tutorials()`).
3. **Show in the World:** Every cue combines diegetic world signifiers (pulsing ground beacons `tut_ring.png`, real-time mentor floating barks above Laras/Cepot/Semar/Ibu) with crisp HUD bar spotlights (`tut_spotlight.png`) and animated pixel mouse/keycap icons (`tut_mouse_lmb.png`, `tut_mouse_rmb.png`).
4. **Brief Tactical Slow-Mo on First Combat Beats:** On the player's very first Faceless windup (Perfect Dodge) and first low-HP wound (Jamu heal), time slows briefly (`0.22x` / `0.30x` for ~1.1–1.4 s real time) so the player can read the telegraph and react without pausing the flow. Strictly guarded: disabled in headless runs, yields immediately to `CastController`, and resets cleanly on action completion, pause, death, or scene change.
5. **Never Collide on 480×270:** The tutorial cue card sits clear of the bottom weapon well and boss name bar (`Y = 204` or lifted when a boss bar is visible), suppresses while dialogue, pause menu, or Write Mode is open, and never stacks on top of `GlyphLesson`.
6. **Persistence:** Completing (or skipping) a lesson sets `tut_<id>` in `Game.flags`, ensuring finished cues never repeat.

---

## 2. The 8-Beat Prologue Arc (`MQ0`)

`MQ0` keeps its 12 steps (`s1..s12`, indices `0..11`). Each verb is earned at the exact story moment that motivates it:

| # | Lesson ID | `MQ0` Step | Story Moment & Mentor | Completion Trigger | Diegetic & HUD Presentation |
|---|---|---|---|---|---|
| 1 | `move` | `s1` (0.1 Dawn Tag) | Waking at dawn as Laras calls you to tag | Move (`WASD`) **and** real `talked_to` / `clue_examined` (pressing `E` in empty air does not count) | `WASD` + `E` keycaps, pulsing gold ground ring on the nearest tag target |
| 2 | `dodge` | `s1` (0.1 Tag) | Triggered reliably after touching **any 1st** tag target (Si Belang, well, or banyan root) | `player_dodged` (1 roll) | `[Space]` keycap, **HUD Stamina spotlight**, Laras floating world bark |
| 3 | `menu` | `s2–s3` (0.2–0.3 Errands) | After Ibu's tea / village errands | `menu_opened` (`Tab`/`Esc`/`M`) or gracefully retires at `s5` | `[Tab] / [M]` keycaps, **HUD top-right menu spotlight** |
| 4 | `combo` | `s5` (0.5 Sanggar Warm-Up) | Cepot beside the 4 straw dummies **inside the sanggar** (with replay-skip choice) | **Stage A:** True 3-hit combo finisher (`player_struck` with `combo == 2`). **Stage B:** Class mechanic spotlight (all 8 classes) + knock down 1 straw dummy (`enemy_killed:dummy`, required `s5` sub-goal) | Animated **LMB mouse icon**, 3-pip combo meter (`○ ○ ★`), **HUD Stamina spotlight**, ground rings on dummies, live Cepot barks |
| 5 | `cast` | `s11` (0.11 Sanggar with Semar) | Semar reveals `Ka` on Laras's torn lontar (with replay-skip choice) | **Phase A (Form):** 2 free-practice draws in unified `GlyphLesson` (suppressing overlapping sanggar guide & bottom pill). **Phase B (Sakti Flow):** Practice mode turns OFF; strike dummy to fill Sakti ≥ 15, then cast 1 live Sakti-funded `Ka` (`spell_cast:sunda_ka`, required `s11` sub-goal) | Animated **RMB mouse icon** (adapts to `toggle_cast`), moving stroke-order ink bead, **HUD Sakti spotlight**, dummy rings, Semar barks |
| 6 | `perfect` | `s12` (0.12 First Skirmish) | First Faceless attack windup (`enemy_windup`) in range | `perfect_dodge` (or 2 dodges during combat so players never stall) | Brief **tactical slow-mo** (`0.22x`), crimson ring on swinging Faceless, `[Space]` cue, Stamina/Sakti flash |
| 7 | `flask` | `s12` (0.12 First Wound) | First time HP ≤ 75% with Jamu charges (`player_hurt`) | `player_drank` (`Q`) | Brief **tactical slow-mo** (`0.30x`), **HUD Flasks + HP spotlight**, `[Q]` + jamu cue |
| 8 | `rest` | `s12` (0.12 Post-Raid) | **Moved after `purwa_raid` clears:** now wounded, down Jamu, and holding fresh Ilmu, 3 tiles from the plaza Petilasan | `petilasan_activated:desa_purwa` (required `s12` sub-goal before Ibu at the west gate) | Pulsing gold ground beacon on Desa Purwa Petilasan + one-time **Level-Up highlight** in `tab_status.gd` |

---

## 3. Class Mechanic Spotlight (`data/lessons.gd` `CLASS_TIPS`)

During Cepot's sanggar drill (Stage B), after the player lands their 3-hit combo finisher, Cepot calls out a tailored tip for the player's chosen class (`Game.class_id`):

| Class | Trait | Sanggar Tip |
|---|---|---|
| `warrior` | Iron Skin (*Kulit Besi*) | Press through light hits without staggering; punish with heavy finishers. |
| `lancer` | Kuda-kuda | Stand still briefly to brace (-25% dmg, +30% next thrust) and strike at spear tip. |
| `archer` | Eagle Eye (*Mata Elang*) | Keep distance (> 120 px) for +15% damage and piercing finishers. |
| `herder` | Skipping Stone (*Batu Pantul*) | Sling stones bounce between nearby targets and break poise quickly. |
| `rogue` | Light Step (*Langkah Ringan*) | Cheap dodges let you slip behind foes for double backstab damage. |
| `dancer` | Wirama | Chain hits without taking damage to stack Wirama up to 8 for a fan wave finisher. |
| `mage` | Keen Mind (*Pikiran Tajam*) | Staff bolts charge a deeper Sakti pool 1.2x faster for frequent casting. |
| `dalang` | Lakon | Rotate different aksara without repeating to boost spell power up to +30%. |

---

## 4. Assets (`tools/gen_tutorial_art.py`)

Generated using `tools/pixlib.py` in the Senja dusk palette (`assets/art/ui/`):
- `tut_mouse_lmb.png` (24×16, 2 frames) — pixel mouse highlighting Left Mouse Button
- `tut_mouse_rmb.png` (24×16, 2 frames) — pixel mouse highlighting Right Mouse Button
- `tut_ring.png` (112×28, 4 frames) — pulsing ground beacon ring
- `tut_spotlight.png` (16×16 9-patch) — pulsing HUD bracket highlight
- `tut_check.png` (9×9) — green tick with a dark outline, no disc
- Card geometry: 6 px padding, a 12 px kicker row, a 2 px gap and a 1–2 line wrapped body (38 or 50 px tall, `MAX_W` 280); its bottom stays at or above Y 236 (boss name bar). Class tips do not repeat the class name; the kicker carries it.
- World barks hold for their full duration before fading (sequential tween). The beacon is its target's first child, so the ring draws under the sprite and above the ground (never `z_index -1`, which falls under the tiles); the gem floats at Y −34, clear of the head.

---

## 5. Verification

- `python3 tools/quest_audit.py` — 0 problems across quests, dialogue, flags, and lessons.
- `python3 .docs/know_check.py` & `python3 .docs/pacing_model.py` — canon & pacing aligned.
- `$GODOT --headless --path . -s tests/tutorial_test.gd` — static key/lesson coverage + live runtime tests (real interact, true 3-hit combo check, any-order dodge trigger, 2-phase Ka/Sakti flow, windup slow-mo & flask triggers, skip toggle, UI suppression, boss-bar clearance).
- `$GODOT --headless --path . -s tests/glyph_lesson_test.gd`, `tests/puzzle_test.gd`, `tests/playthrough_test.gd`, `tests/demo_test.gd`, `tests/zone_build_test.gd`, `tests/ui_test.gd`.
