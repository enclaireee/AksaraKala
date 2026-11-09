# Aksara Kala (The Script of Time)

A top-down 2D pixel-art action RPG set in the mythical folklore and landscapes of Java and Sunda, built with **Godot 4.7** (native 480×270 viewport, scaled with integer integer scaling).

Combine real-time melee and ranged combat with an authentic spellcasting system: hold to enter slow-motion, draw strokes of **Aksara Sunda** and **Aksara Jawa** with your cursor, and release to cast powerful ancient spells.

---

## Features

- **Gesture-Based Spellcasting**: Real-time point-cloud recognizer interprets drawn Aksara glyphs to unleash spells (burst, bolt, ward, heal, and more).
- **Folklore-Inspired World**: Explore interconnected regions spanning Desa Purwa, Tatar Sunda, Gunung Padang, Alas Roban, Dieng, and beyond.
- **Dynamic Combat System**: 3-hit combos, directional dodge i-frames, perfect-dodge rewards, and poise/stagger mechanics.
- **Layered Audio System**: Procedural and gamelan-inspired dynamic soundtracks that adapt across exploration, tension, and boss encounters.

---

## Requirements

- **[Godot Engine 4.7+](https://godotengine.org/)** (GL Compatibility renderer)
- **Python 3.10+** (optional, for design verification scripts and audio synthesis tools)

---

## Quick Start

### Running the Game

To launch the project using the Godot binary:

```bash
# Set Godot path (macOS example):
export GODOT=/Applications/Godot.app/Contents/MacOS/Godot

# Run the game
$GODOT --path .
```

To run a specific scene directly (such as the title screen or test room):

```bash
# Title screen
$GODOT --path . res://ui/title.tscn

# Test room
$GODOT --path . res://scenes/test_room.tscn
```

### Running Tests

Run headless verification tests:

```bash
# Run combat test
$GODOT --headless --path . -s tests/combat_test.gd

# Run audio test
$GODOT --headless --path . -s tests/audio_test.gd

# Run save/load roundtrip test
$GODOT --headless --path . -s tests/save_test.gd
```

---

## Controls

| Action | Key / Input | Details |
|---|---|---|
| **Move** | `W`, `A`, `S`, `D` / Arrow keys | 8-directional movement |
| **Aim** | Mouse Cursor | Characters and spells face the cursor |
| **Attack** | `Left Mouse Button` | Click for single attack, hold for 3-hit combo |
| **Cast** | `Right Mouse Button` | Hold to slow time & draw aksara glyphs; release to cast |
| **Dodge** | `Space` | Directional roll with invulnerability frames |
| **Healing Flask** | `Q` | Consume Jamu charge |
| **Interact** | `E` | Talk to NPCs, open chests, activate Petilasan shrines |
| **Menu / Journal** | `Tab` | Inspect inventory, stats, quest tracker, and Aksara grimoire |
| **Pause / Cancel** | `Esc` | Pause game, close menu, or cancel active spell drawing |

*(Left-handed presets and custom bindings are configurable in settings.)*

---

## Repository Structure

```text
budayago/
├── .docs/         # Complete design bible, lore, balance models, and architecture docs
├── assets/        # Audio tracks/sfx, pixel-art spritesheets, fonts, and shaders
├── autoload/      # Core singletons: Game.gd, Events.gd, Zones.gd, Audio.gd
├── components/    # Modular gameplay nodes (Hitbox, Hurtbox, Poise, Health, etc.)
├── entities/      # Player, enemies, bosses, and NPC controllers
├── scenes/        # Gameplay rooms and arenas (including test_room)
├── ui/            # HUD, title screen, menus, dialogues, and Aksara overlay
├── zones/         # Generated world area scenes and transitions
├── tests/         # Headless Godot test scripts
└── tools/         # Audio synthesis, zone generators, and design modeling scripts
```

---

## Design Check & Audio Tools

Helper scripts located in `.docs/` and `tools/`:

```bash
# Verify stroke confusability and recognizer datasets:
python3 .docs/glyph_strokes.py

# Check damage curves, TTK, and boss scaling:
python3 .docs/balance_model.py

# Generate/synthesize game audio assets:
python3 tools/gen_audio.py
```

---

## Documentation

Full game design specifications, lore sources, and architectural decisions are documented in detail under [`.docs/`](.docs/):
- [`.docs/concept.md`](.docs/concept.md): Core vision, gameplay pillars, cultural principles
- [`.docs/combat.md`](.docs/combat.md): Frame timings, combo chains, poise mechanics
- [`.docs/spells.md`](.docs/spells.md): Aksara drawing recognizer and spell catalogue
- [`.docs/world.md`](.docs/world.md): Regions, points of interest, and zone layouts
- [`.docs/audio.md`](.docs/audio.md): Gamelan scale theory and layered audio architecture
