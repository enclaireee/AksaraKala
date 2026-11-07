# Budayago: Design Documentation

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
| [script.md](script.md) | Complete dialogue script (Indonesian & English), story beats, NPC interactions, and director cues |
| [bestiary.md](bestiary.md) | Enemy archetypes, boss mechanics, cross-time Laras sabotage, Sacred Sea Trials, and complete glyph counter weaknesses |
| [classes.md](classes.md) | The 4 core classes (Warrior, Archer, Rogue, Mage), starting equipment, passives, and spell modifiers |
| [rpg.md](rpg.md) | Character stats, stamina economy, damage calculations, Ilmu currency, Petilasan shrines, death flow, and autosave |
| [controls.md](controls.md) | Key bindings, input buffering, mouse aiming, and accessibility/comfort settings |
| [combat.md](combat.md) | 3-hit combo, dodge i-frames, perfect-dodge rewards, poise/stagger, statuses, and audiovisual hit feedback |
| [balance.md](balance.md) | Level targets, Ingatan rank progression, damage curves, enemy tier scaling, and boss HP numbers |
| [spells.md](spells.md) | Aksara drawing system, point-cloud gesture recognizer, and spell effects (8 MVP glyphs + Ombak + 3 name glyphs) |
| [ui.md](ui.md) | In-game HUD (tracker card, banners, vitals), Esc menu with left rail, Elden-style class select, and smooth typography |
| [items.md](items.md) | Weapons (common & mythic pusaka), armors, accessories, and consumables |
| [assets.md](assets.md) | Visual art standards, tilesets, spritesheets, font licensing (Alegreya Sans, Cinzel, Noto Sans), and audio sources |
| [architecture.md](architecture.md) | Godot 4 project architecture, autoloads, scene composition, physics layers, and technical systems |
| [scope.md](scope.md) | Priority tiers: P0 (must-have), P1 (should-have), P2 (stretch), and explicit cuts |
| [schedule.md](schedule.md) | Phased roadmap and completion milestones with exit criteria |
| [HANDOFF.md](HANDOFF.md) | Session handoff notes, active progress status, verified cultural findings, and next development steps |

---

## Design Check Scripts
- `python3 .docs/glyph_strokes.py`: Stroke designs and confusability simulation for the 8 core glyphs, Ombak, and name glyphs.
- `python3 .docs/balance_model.py`: Validates class DPS, time-to-kill curves, and enemy/boss scaling.
- `python3 .docs/pacing_model.py`: Checks runtime minutes per act and side quest pacing targets against `quests.md`.
- `python3 .docs/know_check.py`: Verifies narrative introduction order so characters are introduced before being referenced.
- `python3 .docs/gen_zones.py .docs/zones/<region>.md`: Generates `zones/<area>.gd/.tscn` scenes from zone doc ASCII maps and legends.

---

## Documentation Conventions
- **ASSUMED**: Design choices made by pair programming that can be tuned.
- **VERIFY**: Cultural facts, folkloric details, or script orthography to be corroborated against authoritative sources.
- **TUNE**: Numerical balance values, timings, or parameters subject to playtest refinement.
