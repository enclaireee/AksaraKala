# Scope

There is no fixed deadline, so scope is ordered by priority, not cut by time. Build everything in P0 first, then P1, then P2. Never start a tier before the one above it is playable.

## P0: must have (the game does not exist without these)
- Player: move, aim, 3-hit combo, dodge and perfect dodge, stamina, HP, 4 statuses ([combat.md](combat.md))
- Aksara casting: cast mode, recognizer, 8 glyphs (4 Sunda + 4 Jawa), sakti gauge, 8 spells, sanggar practice
- 4 classes with the stats, weapons, passives and spell modifiers in [classes.md](classes.md)
- Stats, Ilmu, level-up at petilasan, death and respawn
- Open map: Desa Purwa + 3 zones (Sunda, Jawa, Timur) with zone loading and fog gates
- Enemies for those zones (about 10 types) and 3 bosses + 1 miniboss
- Final zone: Gua Kala and Batara Kala (at least a basic version)
- Gear: about 10 weapons, 5 armors, 4 accessories as data
- Dialogue, NPCs, the story spine in [story.md](story.md)
- Quest system (journal, soft marker, NPC indicators) and the main quest ([quests.md](quests.md)), plus the Cepot side quest on the demo path
- Bilingual text (Indonesian + English) for everything, via CSV string tables
- Codex with entries for enemies, items, glyphs
- Pixel art, sfx, music, screenshake, hit flash
- Main menu, pause, death, win screen
- Autosave, one slot, Continue from the title screen ([rpg.md](rpg.md) 11, moved from P1 on 2026-11-05)

## P1: should have
- Segara Kidul zone with the Nyi Roro Kidul trial
- Miniboss in each zone
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
- Dialogue branching with consequences
- Open-world seamless streaming (zones load at edges instead)
- Regions outside Java and Sunda

## Risk list
1. **Glyph recognition tuning.** Biggest technical risk. Mitigation: build and test it before anything else after the combat basics. Fallback: reduce to fewer, more distinct glyphs.
2. **Art volume.** 4 classes + about 12 enemies + 5 bosses is a lot. Mitigation: shared base sprite re-tinted, packs for bulk, custom only for culture items.
3. **Cultural accuracy.** Mitigation: VERIFY pass per doc, source list, expert review.
4. **Aksara font rendering in Godot.** Test early. Fallback: pre-rendered images.
5. **Scope creep.** Mitigation: this document. New ideas go to P2 first.
