# Aksara Kala (The Script of Time): Design Documentation

Top-down 2D pixel-art action RPG set in the mythical folklore and landscapes of Java and Sunda. Real-time action combat combined with an authentic spellcasting mechanic: drawing Aksara Sunda and Aksara Jawa script with the mouse to unleash spells.

---

## Documentation Map

| Document | Purpose & Contents |
|---|---|
| [concept.md](concept.md) | Vision, gameplay pillars, tone, core loop, and cultural sensitivity principles |
| [story.md](story.md) | **Canon (v5).** Story spine, the Four Seals, cross-time Laras chapters (`LC1`–`LC6`), characters, 6 Major Choices, anti-repetition regional structures, runtime budget (~21.5 h main story, 138 steps), and ending |
| [world.md](world.md) | World layout, 49 interconnected areas across 6 regions + Desa Purwa hub, environmental gating, checkpoints, and NPCs |
| [quests.md](quests.md) | Main quest (138 steps), 20 side & companion quests, reward economy, scene direction, and technical quest architecture |
| [quest_guide.md](quest_guide.md) | Step-by-step quest walkthrough and objective guide generated from quest data |
| [tutorial.md](tutorial.md) | In-story tutorial ladder, quiet bottom-screen lesson cards, motivators, and completion events |
| [script.md](script.md) | Complete dialogue script (Indonesian & English), story beats, NPC interactions, and director cues |
| [bestiary.md](bestiary.md) | Enemy archetypes, boss mechanics, cross-time Laras sabotage, Sacred Sea Trials, and complete glyph counter weaknesses |
| [classes.md](classes.md) | The 4 core classes (Warrior, Archer, Rogue, Mage), starting equipment, passives, and spell modifiers |
| [rpg.md](rpg.md) | Character stats, stamina economy, damage calculations, Ilmu currency, Petilasan shrines, death flow, and autosave |
| [controls.md](controls.md) | Key bindings, input buffering, mouse aiming, and accessibility/comfort settings |
| [combat.md](combat.md) | 3-hit combo, dodge i-frames, perfect-dodge rewards, poise/stagger, statuses, and audiovisual hit feedback |
| [balance.md](balance.md) | Level targets, Ingatan rank progression, damage curves, enemy tier scaling, and boss HP numbers |
| [spells.md](spells.md) | Aksara drawing system, point-cloud gesture recognizer, and spell effects (8 MVP glyphs + Ombak + 3 name glyphs) |
| [ui.md](ui.md) | In-game HUD (tracker card, banners, vitals), Esc menu with left rail, Elden-style class select, and smooth typography |
| [audio.md](audio.md) | Music map per region (explore, dark, combat, boss), towns, ambience beds, sfx and stingers, how the Audio autoload layers them, the pipeline (`tools/build_audio.py`, `tools/gen_music.py`) and tuning guide |
| [items.md](items.md) | Weapons (common & mythic pusaka), armors, accessories, and consumables |
| [assets.md](assets.md) | Visual art standards, tilesets, spritesheets, font licensing (Tiny5, Jersey 10/15, Noto Sans), and audio sources |
| [architecture.md](architecture.md) | Godot 4 project architecture, autoloads, scene composition, physics layers, and technical systems |
| [performance.md](performance.md) | Measured zone-build, quest-lookup, audio-memory and per-frame costs (before/after), what was optimized, what was left and why; `tests/perf_probe.gd` |
| [scope.md](scope.md) | Priority tiers: P0 (must-have), P1 (should-have), P2 (stretch), and explicit cuts |
| [schedule.md](schedule.md) | Phased roadmap and completion milestones with exit criteria |
| [HANDOFF.md](HANDOFF.md) | Session handoff notes, active progress status, verified cultural findings, and next development steps |

---

## Design Check & Validation Scripts
- `python3 tools/quest_audit.py`: Validates all 30 quests, 90 dialogue resources, 4,755 text keys, step alignments, and exit markers (must exit with 0 problems).
- `python3 .docs/know_check.py`: Verifies narrative introduction order so characters are introduced before being referenced.
- `python3 .docs/pacing_model.py`: Checks runtime minutes per act and side quest pacing targets against `quests.md`.
- `python3 .docs/glyph_strokes.py`: Stroke designs and confusability simulation for the 8 core glyphs, Ombak, and name glyphs.
- `python3 .docs/balance_model.py`: Validates class DPS, time-to-kill curves, and enemy/boss scaling.
- `python3 .docs/gen_quest_guide.py`: Regenerates `quest_guide.md` directly from shipped quest resources.
- `/usr/bin/python3 tools/build_audio.py [--only sfx/hit] [--check] [--audition]`: builds recorded sfx, ambience and downloaded music from `tools/audio/sources/*.json` into `assets/audio/`; `/usr/bin/python3 tools/gen_music.py [--only explore_sunda]` renders the composed region music and stingers ([audio.md](audio.md)).
- `python3 .docs/gen_zones.py .docs/zones/<region>.md`: Generates `zones/<area>.gd/.tscn` scenes from zone doc ASCII maps and legends.

---

## Documentation Conventions
- **ASSUMED**: Design choices made by pair programming that can be tuned.
- **VERIFY**: Cultural facts, folkloric details, or script orthography to be corroborated against authoritative sources.
- **TUNE**: Numerical balance values, timings, or parameters subject to playtest refinement.
