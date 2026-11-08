# Classes

The player is a custom hero. At the start of their journey, they choose one of four core archetypes: Warrior, Archer, Rogue, or Mage. Cultural lore lives in the setting, bosses, mythic pusaka weapons, and aksara scripts.

---

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
- **Spell Modifiers:** Ward x1.3 absorb, Burst +25% radius, spell damage x0.9.
- **Playstyle:** Close combat, high poise defense, utilizing spells for radial crowd control and shielding.

### Archer
- **Fantasy:** Nimble ranged marksman controlling distance.
- **Starting Weapon:** Hunting Bow (ranged projectile, 4 stamina per shot, 8 base damage).
- **Passive:** **Eagle Eye** — +15% damage at long range (>120 px); arrows pierce initial targets.
- **Spell Modifiers:** Bolt fires as a 3-arrow fan, Dash cost x1.0, spell damage x1.0.
- **Playstyle:** Kiting, positioning, zone control with fan-shaped spell bursts.

### Rogue
- **Fantasy:** Agile skirmisher thriving on mobility and lethal backstabs.
- **Starting Weapon:** Dagger (light melee, rapid strikes, 10 stamina).
- **Passive:** **Light Step** — Dodge stamina cost reduced from 20 to 14; deals 2x damage on attacks from behind (within 60 degrees of enemy's rear arc).
- **Spell Modifiers:** Dash-strike cost x0.7, Bind duration +30%, spell damage x1.0.
- **Playstyle:** Flanking, hit-and-run tactics, capitalizing on dodge i-frames and binding enemies.

### Mage
- **Fantasy:** Scholar of the sacred script with unmatched casting prowess.
- **Starting Weapon:** Oak Staff (ranged mystical projectile, 5 stamina).
- **Passive:** **Keen Mind** — Sakti gauge capacity expanded from 100 to 120; gauge fills 1.2x faster from combat actions.
- **Spell Modifiers:** Spell damage x1.1, all spell costs x0.9, Heal effectiveness x1.2.
- **Playstyle:** Frequent spellcaster, fragile in melee, relies on rapid aksara execution.

---

## Balance Goals
- Any class can complete the full campaign and defeat every boss. No class is mandatory.
- Warrior offers the highest baseline survivability; Mage boasts the highest damage ceiling tied to drawing precision.
- Melee-only completion is viable, but drawn spells significantly enhance combat efficiency.

---

## Class Selection Presentation (`ui/class_select.gd`)
Presented after the opening prologue events:
- **Left Column:** Class roster (Almendra Display 10) with gold lozenge navigation cursor.
- **Center Pedestal:** 96x128 animated character sprite standing on a stone pedestal illuminated by lantern light with gentle floor mist. Switching classes dissolves the character into rising ink particles.
- **Right Panel:** Detailed panel showing archetype title, narrative description, animated stat bars, starting equipment icon, and passive ability.
- **Confirmation:** Framed confirmation prompt prevents accidental selection before saving.
