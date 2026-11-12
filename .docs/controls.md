# Controls

Every input, what it does in each situation, and the options around it. Combat timings (combo, dodge, buffer) live in [combat.md](combat.md). The drawing itself lives in [spells.md](spells.md). Values marked **TUNE** are starting points, **ASSUMED** are my calls, not yet confirmed.

## 1. Decisions
| Topic | Decision |
|-------|----------|
| Devices | Keyboard and mouse only. A trackpad works through the options in section 6. Gamepad stays P2 (confirmed 2026-11-05) |
| Hand layout | Left hand on WASD and nearby keys, right hand on the mouse. Every combat action is reachable without moving the left hand off WASD |
| Mouse buttons | Left attacks, right casts. Swappable in settings |
| Hold vs tap | Attack and cast are holds. Everything else is a tap |
| Rebinding | P0: two presets (Default, Left-handed) and the mouse-button swap. P1: free rebinding of every key |

## 2. Default bindings
| Action | Default | Left-handed preset | Type | Godot action |
|--------|---------|--------------------|------|--------------|
| Move | W A S D | Arrow keys | Hold | `move_up`, `move_down`, `move_left`, `move_right` |
| Aim | Mouse | Mouse | - | (cursor position) |
| Attack | Left mouse | Left mouse | Click, or hold for the 3-hit combo | `attack` |
| Cast (draw aksara) | Right mouse | Right mouse | Hold, draw, release | `cast` |
| Dodge | Space | Right Ctrl | Tap | `dodge` |
| Healing flask | Q | Right Shift | Tap | `heal_jamu` |
| Interact | E | Enter | Tap | `interact` |
| Menu | Tab | Backspace | Tap | `menu` |
| Map | M | M | Tap | `map` |
| Pause / back / cancel cast | Esc | Esc | Tap | `pause` |

- Arrow keys also move in the Default preset, so menus and one-handed testing work without setup.
- No weapon-swap key: weapons are swapped in the menu, instantly ([items.md](items.md)). Map key M opens directly to the map tab.
- No sprint and no block. Dodge is the only defensive button.

## 3. What each input does in each state
"Buffer" means the input is held for 0.15 s and fires as soon as the state allows ([combat.md](combat.md) 2.6). "Ignored" means it is dropped.

| State | Move | Attack | Dodge | Cast | Flask | Interact |
|-------|------|--------|-------|------|------|----------|
| Free | Yes | Starts combo | Yes | Starts drawing (if the gate allows, 4.4) | Yes | Yes |
| Melee wind-up and hit | No (the lunge moves you) | Buffer (next combo hit) | Buffer | Buffer | Ignored | Ignored |
| Ranged or staff wind-up and shot | 50% speed | Buffer | Buffer | Buffer | Ignored | Ignored |
| Attack recovery | Melee no, ranged 50% | Buffer | Cancels the recovery | Cancels the recovery | Ignored | Ignored |
| Dodging | No (dodge path is fixed) | Buffer | Buffer | Buffer | Ignored | Ignored |
| Dodge recovery (0.1 s) | Yes | Buffer | Buffer | Buffer | Ignored | Ignored |
| Hurt stagger (0.25 s) | No | Buffer | Allowed after 0.1 s | Buffer | Ignored | Ignored |
| Drawing (cast held) | Yes, slowed with the world | Ignored | Cancels the cast (no cost), then dodges | Release fires the glyph | Ignored | Ignored |
| Drinking the flask (0.6 s) | 50% speed | Ignored | Cancels the drink (charge kept) | Ignored | Ignored | Ignored |
| Dialogue, menu, pause | World paused | Advance or select | Ignored | Ignored | Ignored | Advance or select |

Rules behind the table:
- If two inputs are buffered, the order is dodge, cast, attack ([combat.md](combat.md) 2.6).
- Ranged and staff keep 50% movement while shooting so Archer and Mage can kite. Melee commits the body (confirmed 2026-11-05).
- Dodge always works except during the first 0.1 s of a stagger, so the player always has an escape.
- A button that is still held when a menu, dialogue or cutscene closes is ignored until it is released, so closing a dialogue with a click never swings the weapon.

## 4. Input details
### 4.1 Aim and cursor
- The character faces the cursor. Attacks, shots and spell targets go toward the cursor ([combat.md](combat.md) 2.1-2.2).
- Cursor: a small brush-tip crosshair, drawn as the hardware cursor at the game's integer scale so it has no extra lag. Re-set the cursor image when the window scale changes.
- In fullscreen the mouse is confined to the window. In windowed mode it is free, with a setting to confine it.
- The camera lean toward the mouse (16 px) freezes while drawing, so the screen does not slide under the stroke.

### 4.2 Attack
- Click for one hit, hold to chain the full combo and keep looping it. Releasing ends the combo after the current hit.
- An attack starts whenever stamina is above 0, even if it costs more than what is left; the bar just empties ([rpg.md](rpg.md) 3). At exactly 0 it does not start: the stamina bar flashes and a dull click plays (confirmed 2026-11-05).

### 4.3 Dodge
- Direction: the held movement direction. With no movement held, toward the cursor ([combat.md](combat.md) 2.4).
- Same rule as attacks: a dodge works while stamina is above 0. At exactly 0: no dodge, the stamina bar flashes. The input is not buffered, so the dodge never fires late by surprise.

### 4.4 Cast
- Hold right mouse: slow-mo starts, draw with the mouse, release to fire ([spells.md](spells.md) 1).
- Cancel, all at no cost: Esc, dodge, a stroke that is too short, or the draw time running out.
- **Gate:** drawing needs 15 sakti to start (14 for Mage and Rogue) and is locked for 1 s after a cancel or fizzle, so slow-mo cannot be spammed ([spells.md](spells.md) 9). When blocked, the gauge flashes and a dull sound plays. The sanggar is exempt.
- Enough to start but not enough for the drawn glyph: the glyph is recognized, shows its cost and fizzles with no gauge loss ([spells.md](spells.md) 9).
- Hits taken while drawing do not cancel the cast ([combat.md](combat.md) 6).
- The draw time limit counts real time, not slowed game time.

### 4.5 Healing flask
- One tap drinks one charge (0.6 s). With no charges left: a short "empty" sound, nothing else happens.
- Drinking at full HP is blocked: a "HP full" hint shows and the charge is kept (confirmed 2026-11-05).

### 4.6 Interact
- Acts on the nearest interactable within 24 px that the player faces. Priority when several are close: NPC, petilasan, chest or door, item.
- A prompt above the target shows the current key ("[E] Talk").
- Ilmu and leaf pickups are collected by walking over them (16 px magnet), no button.
- Resting at a petilasan is blocked while an enemy is chasing the player ("Enemies are near").

### 4.7 Menu, pause and dialogue
- Tab opens the menu on the last tab used. Q and E switch tabs inside it; mouse works everywhere.
- M opens or toggles directly to the Peta (Map) tab, closing it if already open.
- Esc closes the open menu, or opens pause if none is open. While drawing, Esc only cancels the cast.
- Dialogue: E, Enter or left mouse advances. Pressing it during the typewriter shows the whole line first. No skip-all button for story scenes in P0.
- The game pauses when the window loses focus.

## 5. Menus and UI navigation
- Mouse: point and click. Keyboard: arrows or WASD move the focus, E or Enter confirms, Esc goes back.
- Every screen has a visible focus highlight, so the keyboard path is always clear.
- Confirmation is required only where a mistake is permanent: class choice and spending Ilmu at level-up.

## 6. Accessibility and comfort settings
| Setting | Default | Notes |
|---------|---------|-------|
| Swap mouse buttons | Off | Cast on left, attack on right. For players who draw better with the index finger |
| Toggle cast | Off | Tap cast to enter slow-mo, then draw while holding left mouse (or a trackpad press), release to fire. Tap cast or Esc to leave. Made for trackpads, where holding a second button while dragging is hard |
| Control preset | Default | Default or Left-handed (section 2). Free rebinding in P1 |
| Slow-mo strength, guide always on, draw time | 20%, off, 2.5 s | From [spells.md](spells.md) 8 |
| Trackpad assist | Off | Lower glyph thresholds, [spells.md](spells.md) 8 |
| Screenshake | 100% | Slider 0-100% ([combat.md](combat.md) 3.2) |
| Damage numbers | On | Toggle ([combat.md](combat.md) 3.2) |
| Reduce flashes | Off | Halves hit and perfect-dodge flash brightness |
| Cursor size | 1x | 1x or 2x, plus a high-contrast outline |

## 7. Implementation notes (Godot)
- Input map actions are the names in section 2. Esc is one `pause` action, and the current state decides whether it cancels a cast, closes a menu or pauses.
- Read gameplay input in `_unhandled_input` so open UI consumes clicks first. Read the stroke from `InputEventMouseMotion` in the `CastController`.
- Input events arrive in real time even under `Engine.time_scale = 0.2`. Movement uses the scaled `delta`, which is what slows the player while drawing. Time the draw limit with `Time.get_ticks_msec()`.
- The buffer is one small queue on the player: an action name and a timestamp, dropped after 0.15 s. Prompts read the key from `InputMap.action_get_events()`, so they always show the current binding.
- Presets and the mouse swap are a dictionary applied to `InputMap` at startup, saved in `user://settings.cfg` with `ConfigFile`. Free rebinding (P1) reuses the same save.

## 8. Playtest checks
- New players find attack, dodge and cast without reading anything beyond the first prompts.
- No input feels lost: log every dropped input during a fight and look for ones that should have been buffered.
- Closing dialogue with a click never triggers an attack.
- A trackpad player can cast every glyph with toggle cast and assist on.
- A left-handed player can finish the Sangkuriang fight on the Left-handed preset.
