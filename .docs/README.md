# Budayago: design docs

Top-down 2D pixel-art action RPG set in Java and Sunda folklore. Real-time combat plus a gimmick: draw aksara (Sundanese and Javanese script) with the mouse to cast spells.

| Doc | What is in it |
|-----|---------------|
| [concept.md](concept.md) | Vision, pillars, tone, audience, cultural sensitivity |
| [story.md](story.md) | **Canon (v3.1).** Story spine, the Four Seals, Laras's trail, characters, pacing rules and runtime, acts, ending |
| [world.md](world.md) | Map, zones, legends, gating, checkpoints, NPCs |
| [quests.md](quests.md) | Main quest, side quests, rewards, quest system |
| [script.md](script.md) | Every main-path line (EN and ID), dialogue entries and story beats, keyed |
| [bestiary.md](bestiary.md) | Enemies, minibosses, bosses |
| [classes.md](classes.md) | The 4 classes |
| [rpg.md](rpg.md) | Stats, stamina, damage, currency, checkpoints, controls |
| [controls.md](controls.md) | Key bindings, what each input does per state, accessibility options |
| [combat.md](combat.md) | Combo, dodge, perfect dodge, hit feel, poise, statuses, enemy behavior |
| [balance.md](balance.md) | Progression, level targets, Ilmu economy, enemy and boss numbers |
| [spells.md](spells.md) | Aksara drawing system and spell list (the gimmick) |
| [glyph_strokes.py](glyph_strokes.py) | Single-stroke designs of the 8 MVP glyphs, Ombak and the 3 write-only name glyphs, plus a confusability check (`python3 glyph_strokes.py`) |
| [pacing_model.py](pacing_model.py) | Minutes per act from the typed pieces in quests.md 4 (the `Play` column), checked against story.md "Pacing model (v4c)" (`python3 pacing_model.py`) |
| [ui.md](ui.md) | HUD layout and sizes, fonts, menus |
| [items.md](items.md) | Weapons, armor, accessories, consumables |
| [assets.md](assets.md) | Art direction, asset needs, licenses |
| [architecture.md](architecture.md) | Godot project structure and technical design |
| [story_brainstorm.md](story_brainstorm.md), [story_ciung_wanara.md](story_ciung_wanara.md) | History only, superseded by story.md |
| [scope.md](scope.md) | Priorities: must, should, stretch, out |
| [schedule.md](schedule.md) | Phased roadmap with exit criteria (no fixed dates) |

## Conventions
- **ASSUMED**: a decision I made without confirmation. Change freely.
- **VERIFY**: a cultural fact or script detail that must be checked against a reliable source before it ships. The game teaches real culture, so accuracy matters.
- **TUNE**: a number that is a starting value, to be adjusted in playtests.
- Names in Indonesian are draft names. Gloss in English the first time.
