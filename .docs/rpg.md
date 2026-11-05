# RPG Core Systems

Top-down real-time 2D combat (Soul Knight-style visuals and gameplay) with Souls-lite RPG layers. Not a hardcore game: every number leans forgiving. All numbers are starting values (**TUNE**). Items marked **ASSUMED** were not confirmed.

Related: [combat.md](combat.md) (moves, timings, enemies, statuses), [balance.md](balance.md), [classes.md](classes.md), [spells.md](spells.md), [items.md](items.md), [world.md](world.md).

## 1. Controls
Keyboard and mouse: WASD to move, mouse to aim, left mouse to attack, hold right mouse to draw aksara, Space to dodge, Q for the healing flask, E to interact. Full bindings, per-state rules and accessibility options: [controls.md](controls.md).

## 2. Stats
Five stats, no skill trees. Starting values come from the class ([classes.md](classes.md)).

| Stat | Effect |
|------|--------|
| Vitality | Max HP = 80 + 10 x Vitality |
| Endurance | Max stamina = 80 + 6 x Endurance, plus +1% stamina regen per point |
| Strength | Melee damage multiplier = 1 + 0.05 x Strength |
| Dexterity | Ranged damage multiplier = 1 + 0.05 x Dexterity, plus +1% attack speed per point |
| Spirit (Batin) | Spell damage multiplier = 1 + 0.05 x Spirit, plus +2% sakti gauge gain per point |

- Level shown to the player = 1 + points spent since the start. This keeps classes with different totals fair.
- Level-up cost (Ilmu): `cost(n) = round(40 x 1.12^n)`, where n = points spent so far.
- Target levels per zone, Ilmu income and enemy scaling: [balance.md](balance.md).
- Stats are raised only at a petilasan.
- No respec in v1.

## 3. Stamina (forgiving, Souls-style)
- Spent by: dodge, melee attack, ranged shot. Not by walking, not by spells (spells use the sakti gauge).
- Costs: dodge 20, light melee 10, heavy melee 25, ranged shot 4, staff shot 5.
- Regen: 35/s, starting 0.4 s after the last spend.
- You can always act while stamina is above 0, even if the cost is higher than what is left. The bar just empties.
- If emptied to 0: the regen delay becomes 0.8 s. No stun, no exhaustion lockout.
- Dodge: 0.25 s of invincibility, 48 px, no cooldown (stamina is the limit). A perfect dodge refunds its stamina ([combat.md](combat.md) 2.4-2.5).

## 4. Sakti gauge (spell resource)
- Range 0-100 (Mage 120). Spells cost from it.
- Fills by hitting enemies, per hit landed: heavy weapon +10, light, ranged and staff +4. Multiplied by (1 + 0.02 x Spirit), x1.2 for Mage.
- Also slow passive fill when out of combat is **not** included, so spellcasting rewards fighting.
- Spell costs are listed in [spells.md](spells.md).

## 5. Damage and health
- Damage dealt = weapon base x stat multiplier (melee: Strength, ranged: Dexterity, spells: Spirit and spell base) x Ingatan (`1 + 0.15 x` main bosses cleared, [balance.md](balance.md) 3.1).
- Attack interval: light melee 0.35 s, heavy 0.8 s, ranged 0.45 s, staff 0.5 s (**TUNE**), faster with Dexterity.
- Damage taken = `max(1, round(enemy damage x (1 - 0.05 x armor defense)))`, so each defense point is 5% reduction.
- Assist toggle "Gentle combat" halves damage taken ([balance.md](balance.md) 9).
- After taking a hit: 0.8 s of invincibility and a 0.25 s stagger (Warrior's passive removes the stagger from light hits). No contact damage ([combat.md](combat.md) 2.7).
- Healing: **Healing Flask**: 3 charges, each heals 40% of max HP, all refilled at a petilasan. Quest rewards raise it: each **Flask Shard** +1 charge (max 6), each **Herb Pouch** +5% heal (max 60%) ([quests.md](quests.md)).
- The Heal glyph is a separate, spell-based heal.

## 6. Currency and leveling
- Currency: **Ilmu** (knowledge). Drops from enemies, bosses drop more.
- Spent at a petilasan to raise a stat.
- Never lost on death.

## 7. Petilasan (checkpoints) and death
- Interact to activate: sets respawn, saves ([section 11](#11-save-confirmed-2026-11-05)), fully heals, refills the flask, respawns normal enemies, opens the menu.
- Menu: level up, equip, codex.
- **Death:** respawn at the last activated petilasan. Keep Ilmu, stats, gear and glyphs. No other penalty.
- **Enemy respawn: ASSUMED.** Normal enemies respawn on rest or death. Minibosses and bosses stay dead.
- Death screen is short, with a one-line folklore quote or tip (stretch).

## 8. Gear
Three slots: weapon, armor, accessory. No crafting, no upgrading. Items are found in chests, dropped by enemies, or given by NPCs. Full list: [items.md](items.md).

Weapons differ in behavior, not only numbers (hit shapes per weapon: [combat.md](combat.md) 2.3):

| Archetype | Stamina | Speed | Notes |
|-----------|---------|-------|-------|
| Light melee | 10 | fast | short reach, scales with Strength |
| Heavy melee | 25 | slow | wide arc, big damage, scales with Strength |
| Ranged | 4 | medium | projectile, scales with Dexterity |
| Staff | 5 | medium | weak projectile, scales with Spirit |

## 9. Progression flow
1. Choose a class.
2. Learn glyphs by zone through the main quest ([spells.md](spells.md), [quests.md](quests.md)).
3. Spend Ilmu on stats.
4. Find and equip gear, mostly from side quests.
5. Beat zone bosses to open the next region. Each main boss also raises Ingatan (+15% damage).

## 10. HUD
Layout, sizes, colors, fonts and menus: [ui.md](ui.md).

## 11. Save (confirmed 2026-11-05)
P0. One slot, saved automatically. No manual save, no save menu.

**When it saves**
- Resting at a petilasan (including the first time one is activated).
- Right after a milestone: class chosen (this creates the save), glyph learned, boss or miniboss defeated, quest started, advanced or completed, chest opened, key item picked up, level-up confirmed, gear changed.
- On quitting: Quit to Title, Quit Game, and closing the window (`NOTIFICATION_WM_CLOSE_REQUEST`).
- Not on death: death changes nothing that needs saving ([section 7](#7-petilasan-checkpoints-and-death)).
- A small brush icon with "Tersimpan / Saved" shows in the bottom right for 1 s.

**Loading**
- Title screen: Continue (only if a save exists), New Game, Settings, Quit.
- Continue puts the player at the last activated petilasan with full HP and flask, the same as after a rest. Position is never saved, so zone state is always clean: normal enemies respawn, bosses stay dead.
- New Game with a save present asks "Mulai baru? Perjalanan lama akan terhapus / Start over? Your old journey will be erased". The old save is replaced only when the new game saves for the first time (at class choice), so backing out before that loses nothing.
- Before the first save there is no Continue. The prologue up to class choice is about 3 minutes.

**What is saved:** everything in `Game`: class, stats, Ilmu, Ingatan, glyphs learned (and mastery, if built), equipment and inventory, flask charges, Flask Shards, Herb Pouches, last petilasan, quests, flags, codex unlocks, killed bosses and minibosses, opened fog gates, opened chests, picked-up unique items, play time. **Not saved:** normal enemies, player position, dropped Ilmu, settings (those live in `user://settings.cfg`, [controls.md](controls.md) 7).

**File and safety**
- `user://save.json`, written with `JSON.stringify` from `Game.to_dict()`.
- Write to `save.tmp`, copy the current `save.json` to `save.bak`, then rename `save.tmp` over `save.json`. A crash mid-write never leaves a broken save.
- On load, if `save.json` does not parse, try `save.bak`. If both fail, the title screen says the save could not be read and offers New Game. Never delete a save that failed to load.
- The file has `"version": 1`. Loading merges the saved dictionary onto a fresh default `Game` state, so a field added later just gets its default and old saves keep working. Bump the version only when a field changes meaning.
- A web export (P2) maps `user://` to browser storage; check `OS.is_userfs_persistent()` there (**VERIFY** when the web export is built).
