# Classes

The player is a custom hero. At the start of their journey, they choose one of four core archetypes: Warrior, Archer, Rogue, or Mage. Cultural lore lives in the setting, bosses, mythic pusaka weapons, and aksara scripts.

---

## Identity (redesign 2026-11-08)
Code ids stay `warrior`, `archer`, `rogue`, `mage`; mechanics below are unchanged. Display names, art and FX colours change so the heroes read as Sundanese/Javanese, not European. Both languages show the Indonesian title; English adds a role word.

| id | Title (ID / EN) | Look | Weapon (display) | Palette |
|----|-----------------|------|------------------|---------|
| warrior | Hulubalang / Hulubalang, Vanguard | red udeng with a front knot, bare chest with selempang, kain with wiru pleats and tumpal hem, round tameng on the back | Kelewang (the heavy sweep) | wax red, leather, brass |
| archer | Pamanah / Pamanah, Bowman | brown iket with one front peak and a feather, dark-green kampret jacket, brown pangsi, bamboo quiver | Gendewa | verdigris, bamboo, brown |
| rogue | Pendekar / Pendekar, Silat Fighter | dark headwrap, black pangsi, wide red sabuk, open-palm silat guard, low stance | Kujang (a plain working one, reverse grip) | ink black, wax red |
| mage | Wiku / Wiku, Scribe-Sage | topknot with sumping, cream robe over batik kain, lontar at the hip that gives off teal ink-light | Tongkat with a ring top | paper cream, verdigris |

- All four go barefoot in-world. The starting rogue weapon is a kujang, not a keris: a keris is a pusaka. ASSUMED.
- VERIFY: Sundanese iket styles (the single front peak replaced the two-corner style, which read as horns at 96x128); Majapahit-era soldier dress on the Hulubalang; wayang costume terms on the Wiku; "Pendekar" chosen over "Jawara" (local-strongman connotation).
- Art: `tools/gen_portraits.py` (96x128 class figures, 6-frame idle) and `tools/gen_hero_sprites.py` (in-world sprites) share the skin ramps and top-left light of the speaker portraits (ui.md 3.1).

## Shared Rules
- Every class can draw and cast aksara spells ([spells.md](spells.md)).
- All classes share the same 5 core stats ([rpg.md](rpg.md)) and 3 equipment slots (weapon, armor, accessory).
- Classes differ in starting stat allocation, starting weapon, one distinctive passive, and spell affinity modifiers.
- Visuals: Dedicated class sprites with custom headgear, attire, and starting weapons.
- Class selection occurs in the Prologue (`MQ0` Step 0.2) in the Desa Purwa Sanggar.

---

## Starting Stats
Stats: Vitality (Vit), Endurance (End), Strength (Str), Dexterity (Dex), Spirit (Spi / Batin).

| Class | Vit | End | Str | Dex | Spi | Total | Starting Weapon | Base Dmg |
|---|---|---|---|---|---|---|---|---|
| **Warrior** | 8 | 6 | 8 | 4 | 3 | 29 | Broadsword (Heavy Melee) | 22 |
| **Archer** | 5 | 6 | 4 | 9 | 4 | 28 | Hunting Bow (Ranged) | 8 |
| **Rogue** | 5 | 7 | 6 | 7 | 3 | 28 | Dagger (Light Melee) | 8 |
| **Mage** | 4 | 5 | 3 | 4 | 10 | 26 | Oak Staff (Staff Bolt) | 8 |

Displayed level is calculated as `1 + points spent`, ensuring classes with lower initial totals are not penalized.

---

## Class Profiles

### Warrior
- **Fantasy:** Resilient frontliner who shrugs off blows.
- **Starting Weapon:** Broadsword (heavy melee, sweeping arc, 25 stamina).
- **Passive:** **Iron Skin** — Light enemy hits do not stagger or knock you back ([combat.md](combat.md) 2.7).
- **Spell Modifiers:** spell damage x0.9. Every glyph except Ga casts a Hulubalang spell: thrown spear, thorn wall, fissure, shield-prayer, bull charge, war cry, guardian tiger, wall of water ([spells.md](spells.md) 3).
- **Playstyle:** Close combat, high poise defense, utilizing spells for radial crowd control and shielding.

### Archer
- **Fantasy:** Nimble ranged marksman controlling distance.
- **Starting Weapon:** Hunting Bow (ranged projectile, 4 stamina per shot, 8 base damage).
- **Passive:** **Eagle Eye** — +15% damage at long range (>120 px); arrows pierce initial targets.
- **Spell Modifiers:** spell damage x1.0. Pamanah spells: arrow rain, snare trap, flare with homing sparks, wind heal, backward leap volley, hunter focus, two hawks, boomerang tide.
- **Playstyle:** Kiting, positioning, zone control with fan-shaped spell bursts.

### Rogue
- **Fantasy:** Agile skirmisher thriving on mobility and lethal backstabs.
- **Starting Weapon:** Dagger (light melee, rapid strikes, 10 stamina).
- **Passive:** **Light Step** — Dodge stamina cost reduced from 20 to 14; deals 2x damage on attacks from behind (within 60 degrees of enemy's rear arc).
- **Spell Modifiers:** Dash-strike cost x0.7, spell damage x1.0. Pendekar spells: chain lightning, vacuum, silat spin, untouchable breath, teleport stab, free-dodge footwork, shadow tigers, undertow.
- **Playstyle:** Flanking, hit-and-run tactics, capitalizing on dodge i-frames and binding enemies.

### Mage
- **Fantasy:** Scholar of the sacred script with unmatched casting prowess.
- **Starting Weapon:** Oak Staff (ranged mystical projectile, 5 stamina).
- **Passive:** **Keen Mind** — Sakti gauge capacity expanded from 100 to 120; gauge fills 1.2x faster from combat actions.
- **Spell Modifiers:** spell damage x1.1, all spell costs x0.9. Wiku spells: storm orb, draining vines, rune circle, healing spring, blink bomb, focus (cheaper spells), fire tiger, flood of waves.
- **Playstyle:** Frequent spellcaster, fragile in melee, relies on rapid aksara execution.

---

## Balance Goals
- Any class can complete the full campaign and defeat every boss. No class is mandatory.
- Warrior offers the highest baseline survivability; Mage boasts the highest damage ceiling tied to drawing precision.
- Melee-only completion is viable, but drawn spells significantly enhance combat efficiency.

---

## Class Selection Presentation (`ui/class_select.gd`)
Presented after the opening prologue events:
- **Left Column:** Class roster (Jersey 10 at 19) with the cyan diamond cursor.
- **Center Pedestal:** 96x128 animated character sprite standing on a stone pedestal illuminated by lantern light with gentle floor mist. Switching classes dissolves the character into rising ink particles.
- **Right Panel:** Detailed panel showing archetype title, narrative description, animated stat bars, starting equipment icon, and passive ability.
- **Confirmation:** Framed confirmation prompt prevents accidental selection before saving.
