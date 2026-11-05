# Roadmap

No fixed dates. Phases run in order. Each phase has **exit criteria**: do not start the next phase until they hold. Tick boxes as you go. Priority tiers are in [scope.md](scope.md).

## Phase 0: Project setup
- [x] Project settings for pixel art (see [architecture.md](architecture.md))
- [x] Folder structure, autoloads, input map, physics layers
- [x] Version control and `.gitignore` check
- Exit: an empty scene runs at 480x270, scaled with crisp pixels. **Done 2026-11-05** (user confirmed). Aksara render test passes: HarfBuzz shapes pre-base vowels and pasangan (`tests/aksara_render_test.gd`).

## Phase 1a: Combat core (feel first)
**Done 2026-11-05**: the user playtested one chaser in the test room and confirmed the feel.
- [x] Player scene: move, aim, state machine, input buffer ([controls.md](controls.md) 3)
- [x] Stamina and health components
- [x] 3-hit combo for melee and ranged, dodge with i-frames ([combat.md](combat.md))
- [x] One chaser enemy with chase, a telegraphed attack and flinch
- [x] Hit flash, hit-stop, screenshake, `CombatTuning` resource
- [x] One test room with tilemap and walls
- Exit: fighting one chaser in one room feels good with placeholder art. Do not start 1b until it does.

## Phase 1b: Combat depth
- [ ] Perfect dodge
- [ ] Poise and the tank role, enemy turn speed (backstab window)
- [ ] Statuses component (Burn, Slow/Bound, Stagger, Curse)
- [ ] Attack tokens, a shooter enemy, one 3-4 enemy mix from [bestiary.md](bestiary.md) Encounters
- Exit: the mix is readable, and the combat.md section 8 checks pass.

## Phase 2: Aksara casting (the gimmick)
- [ ] Cast mode: slow-mo, vignette, ink trail
- [ ] Recognizer ($P or $1) and glyph data resource
- [ ] Glyph recorder tool and the first 3 glyph templates (start from the designs in `glyph_strokes.py`)
- [ ] Re-run the confusability check on real recorded templates, all 8 glyphs ([spells.md](spells.md) 10)
- [ ] Sakti gauge and the first 3 spells
- [ ] Sanggar practice scene with ghost guide
- Exit: a new player can learn to draw a glyph in the sanggar and cast it in combat with at least 90% success on a clean stroke, and the wrong spell is never cast by accident. Ga/Nga and Na/Ca fizzle under 10% on honest drawings, otherwise swap Nga.

## Phase 3: RPG loop
- [ ] `Game` autoload: class, stats, Ilmu, glyphs, gear, last petilasan
- [ ] Autosave and Continue: `Game.to_dict()`/`from_dict()`, safe write, round-trip test ([rpg.md](rpg.md) 11)
- [ ] Classes and class selection altars
- [ ] Petilasan: heal, jamu, level-up UI, respawn
- [ ] Death and respawn, enemy respawn
- [ ] Remaining 5 glyphs and spells
- Exit: a full loop works: fight, earn Ilmu, rest, level up, die, respawn, quit, Continue with nothing lost.

## Phase 4: First region (Desa Purwa + Tatar Sunda)
- [ ] Zone loader and edge transitions, camera bounds
- [ ] Desa Purwa with the wayang prologue, Semar, class choice
- [ ] Tatar Sunda: tileset, enemies, NPCs, petilasans, boss Sangkuriang
- [ ] Dialogue system, quest system (QuestData, journal, marker), CSV string tables (ID/EN), codex v1
- [ ] Main quest MQ0-MQ1 and the Cepot side quest ([quests.md](quests.md))
- Exit: the first 15 minutes are playable start to boss, with real structure. This is the **demo path** for judges.

## Phase 5: Remaining regions
- [ ] Mataram zone and boss
- [ ] Tanah Timur zone, miniboss and boss
- [ ] Gua Kala and the final boss
- [ ] Segara Kidul (P1)
- [ ] All gear as data, drops and chests
- Exit: the game can be played start to finish with placeholder or pack art.

## Phase 6: Art and audio pass
- [ ] Final tilesets, character and enemy sprites, UI
- [ ] Culture-item icons and glyph art
- [ ] SFX and music
- [ ] Particles and effects
- Exit: the game looks and sounds consistent and complete.

## Phase 7: Culture and polish
- [ ] VERIFY pass on every doc, source list filled in
- [ ] Codex entries written and cited
- [ ] Expert review of text and cultural content, if possible
- [ ] Balance pass: run [balance.md](balance.md) section 11 checks, re-run `balance_model.py` after any change; stamina, costs, glyph thresholds
- [ ] Accessibility settings, assist mode
- [ ] Bug sweep and full-run playtests with several people
- Exit: someone unfamiliar with the game can finish it without help.

## Phase 8: Release
- [ ] Export builds (PC, web if possible)
- [ ] Title and credits, asset attributions
- [ ] Submission materials for the competition
- Exit: build runs on a clean machine.
