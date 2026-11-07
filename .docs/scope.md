# Scope

There is no fixed deadline, so scope is ordered by priority, not cut by time. Build everything in P0 first, then P1, then P2. Never start a tier before the one above it is playable.

## P0: must have (the game does not exist without these)
- Player: move, aim, 3-hit combo, dodge and perfect dodge, stamina, HP, 4 statuses ([combat.md](combat.md))
- Aksara casting: cast mode, recognizer, 9 glyphs (4 Sunda + 4 Jawa + Ombak) and 3 write-only name glyphs (La, Ra, Sa), sakti gauge, 9 spells, sanggar practice
- 4 classes with the stats, weapons, passives and spell modifiers in [classes.md](classes.md)
- Stats, Ilmu, level-up at petilasan, death and respawn
- Open map (Story v5, 49 areas): Desa Purwa + Tatar Sunda, Keraton Galuh, Mataram, Tanah Timur, Segara Kidul with zone loading and fog gates ([world.md](world.md))
- Enemies for those zones (about 10 types) and the main-path bosses ([bestiary.md](bestiary.md))
- Final zone: Gua Kala (7 areas) and Batara Kala (at least a basic version)
- Story v5 main path: 138 steps, 6 Major Choices as flags, 6 cross-time Laras chapters (`LC1`-`LC6`) with `laras_key:*` and `laras_sabotage:*` flags, "Ask about..." topic hubs, 8-12 line talks ([story.md](story.md), [quests.md](quests.md) 7.1)
- Gear: about 10 weapons, 5 armors, 4 accessories as data (the data folder already holds more, including the choice rewards Sabuk Galuh, Keris Mpu Gandring and Batu Kali, [items.md](items.md))
- Dialogue, NPCs, the story spine in [story.md](story.md)
- Quest system (journal, soft marker, NPC indicators) and the main quest ([quests.md](quests.md)), plus the Cepot side quest on the demo path
- Bilingual text (Indonesian + English) for everything, via CSV string tables
- Codex with entries for enemies, items, glyphs
- Pixel art, sfx, music, screenshake, hit flash
- Main menu, pause, death, win screen
- Autosave, one slot, Continue from the title screen ([rpg.md](rpg.md) 11, moved from P1 on 2026-11-05)
- Segara Kidul with the Trial of the Waves, MQ4 and the Interlude (main path since story v3.1, moved from P1; **ASSUMED**). Ombak is the ninth glyph
- Core quest engine features: multi-goal `all` steps, `goto:<area>:<spawn>` and `restore` dialogue actions, and the `zone:<area_id>` condition ([quests.md](quests.md) 7)

## P1: should have
- A miniboss or elite in each zone beyond the main-path ones (Sandekala in Act I and Buto Ijo in Act IV are on the main path)
- Side quests (3-4 per zone) and the hub meta quests ([quests.md](quests.md))
- Glyph mastery and always-on guide setting
- Accessibility settings (assist toggles in [balance.md](balance.md) 9: gentle combat, drawing assist, slow-mo strength, draw time)
- Quick-start option (skip prologue)

## P2: stretch
- Diacritic modifiers and glyph combos (the Kala shield mechanic)
- Thrown weapon archetype
- Class respec
- Web export
- Wayang kulit shadow-puppet cutscenes with animation
- Gamepad support (keyboard and mouse only, confirmed 2026-11-05)
- Free key rebinding is P1; presets and mouse swap are P0 ([controls.md](controls.md))

## Out (cut on purpose)
- Skill trees, crafting, gear upgrading
- Shops and trading
- Procedural generation
- Multiplayer
- Free-form dialogue branching. Only the six Major Choices and the optional "Ask about..." topic hubs branch; every choice leaves the canon ending open
- Open-world seamless streaming (zones load at edges instead)
- Regions outside Java and Sunda

## Risk list
1. **Glyph recognition tuning.** Biggest technical risk. Mitigation: build and test it before anything else after the combat basics. Fallback: reduce to fewer, more distinct glyphs.
2. **Art volume.** 4 classes + about 12 enemies + 11 main-path bosses is a lot. Mitigation: shared base sprite re-tinted, packs for bulk, custom only for culture items.
3. **Cultural accuracy.** Mitigation: VERIFY pass per doc, source list, expert review.
4. **Aksara font rendering in Godot.** Test early. Fallback: pre-rendered images.
5. **Scope creep.** Mitigation: this document. New ideas go to P2 first.
