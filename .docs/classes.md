# Classes

The player is a custom hero. At the start they choose one of four plain archetypes: Warrior, Archer, Rogue, Mage (decided 2026-11-05). Culture lives in the setting, bosses, mythic gear and aksara, not in the class names.

## Shared rules
- Every class can cast aksara spells ([spells.md](spells.md)).
- Everyone has the same 5 stats ([rpg.md](rpg.md)) and the same 3 gear slots.
- Classes differ in starting stats, starting weapon, one passive and spell modifiers.
- Visual: one shared base sprite, re-tinted, with class headgear and weapon (cheap art).
- Class is chosen once. No respec in v1 (**ASSUMED**). A respec at a petilasan is a stretch goal.

## Starting stats (Vitality, Endurance, Strength, Dexterity, Spirit)
| Class | Vit | End | Str | Dex | Spi | Total |
|-------|-----|-----|-----|-----|-----|-------|
| Warrior | 8 | 6 | 8 | 4 | 3 | 29 |
| Archer | 5 | 6 | 4 | 9 | 4 | 28 |
| Rogue | 5 | 7 | 6 | 7 | 3 | 28 |
| Mage | 4 | 5 | 3 | 4 | 10 | 26 |

Level is shown as `1 + points spent`, so classes with a lower total are not penalized (see [rpg.md](rpg.md)).

## Warrior
- Fantasy: unbreakable frontliner.
- Starting weapon: Broadsword: heavy melee, 25 stamina.
- Passive **Iron Skin**: light hits do not stagger or knock you back ([combat.md](combat.md) 2.7).
- Spell modifiers: Ward x1.3 absorb, Burst +25% radius, spell damage x0.9.
- Playstyle: close range, tanky, spells as shockwaves.

## Archer
- Fantasy: precise ranged fighter.
- Starting weapon: Hunting Bow: ranged, 4 stamina per shot.
- Passive **Eagle Eye**: +15% damage at long range (over 120 px), Bolt pierces.
- Spell modifiers: Bolt fires as a 3-arrow fan, Dash cost x1.0, spell damage x1.0.
- Playstyle: kiting, positioning.

## Rogue
- Fantasy: fast and deadly.
- Starting weapon: Dagger: light melee, 10 stamina.
- Passive **Light Step**: dodge costs 14 instead of 20 stamina, x2 damage on hits from behind (within 60 degrees of the enemy's back, not on bosses). Set it up by dodging through an enemy during its wind-up: enemies cannot turn while attacking ([combat.md](combat.md) 5.1).
- Spell modifiers: Dash-strike cost x0.7, Bind lasts +30%, spell damage x1.0.
- Playstyle: hit-and-run, backstabs.

## Mage
- Fantasy: master of the written word, the class closest to the aksara theme.
- Starting weapon: Oak Staff: weak ranged bolt, 5 stamina.
- Passive **Keen Mind**: spell gauge fills 1.2x faster and holds 120 instead of 100 ([balance.md](balance.md)).
- Spell modifiers: spell damage x1.1, all spell costs x0.9, Heal x1.2.
- Playstyle: casts constantly, fragile.

## Balance goals
- Any class can finish the game. No class is required.
- Warrior is the easiest, Mage the most active, Archer and Rogue in the middle (**TUNE**).
- Spells should feel strong enough that melee-only play is slower, not impossible.

## Class selection UX
- After New Game, a screen of 4 class cards: name, 2-line description, stats, start weapon, passive.
- A final confirm step prevents accidental picks.
- No altars. (**ASSUMED**; the Desa Purwa prologue may stage it later.)
