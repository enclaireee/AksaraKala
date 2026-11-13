# Classes

The player is a custom hero. At the start of their journey, they choose one of eight classes: four schools (Warrior, Archer, Rogue, Mage), each with a second path (Lancer, Herder, Dancer, Dalang; user call 2026-11-12). Cultural lore lives in the setting, bosses, mythic pusaka weapons, and aksara scripts.

---

## Identity (redesign 2026-11-08)
Code ids stay `warrior`, `archer`, `rogue`, `mage`; mechanics below are unchanged. Display names, art and FX colours change so the heroes read as Sundanese/Javanese, not European. Both languages show the Indonesian title; English adds a role word.

| id | Title (ID / EN) | Look | Weapon (display) | Palette |
|----|-----------------|------|------------------|---------|
| warrior | Hulubalang / Hulubalang, Vanguard | red udeng with a front knot, bare chest with selempang, kain with wiru pleats and tumpal hem, round tameng on the back | Kelewang (the heavy sweep) | wax red, leather, brass |
| archer | Pamanah / Pamanah, Bowman | brown iket with one front peak and a feather, dark-green kampret jacket, brown pangsi, bamboo quiver | Gendewa | verdigris, bamboo, brown |
| rogue | Pendekar / Pendekar, Silat Fighter | dark headwrap, black pangsi, wide red sabuk, open-palm silat guard, low stance | Kujang (a plain working one, reverse grip) | ink black, wax red |
| mage | Wiku / Wiku, Scribe-Sage | topknot with sumping, cream robe over batik kain, lontar at the hip that gives off teal ink-light | Tongkat with a ring top | paper cream, verdigris |

| lancer | Prajurit / Prajurit, Palace Spearman | tall black kuluk with a brass band, red-and-white lurik jacket, white trousers under a short indigo wrap | Tombak with a red tassel | lurik red, white, brass |
| herder | Pangangon / Pangangon, Herder | wide straw caping, sleeveless pale kutang, indigo sarong slung over one shoulder, short trousers, suling in the belt | Bandring (sling) | straw, indigo |
| dancer | Penari Topeng / Penari Topeng, Mask Dancer | gold sobrah headdress with tassels, the topeng pushed up at the temple, kace collar, batik kain, teal selendang | Kipas (twin fans) | gold, magenta, teal |
| dalang | Dalang / Dalang, Shadow Puppeteer | batik blangkon, indigo beskap with brass buttons, parang kain, keris behind | Kayon (a gunungan on a staff) | indigo, batik brown, lamp gold |

- All eight go barefoot in-world. The starting rogue weapon is a kujang, not a keris: a keris is a pusaka. ASSUMED.
- VERIFY: Sundanese iket styles (the single front peak replaced the two-corner style, which read as horns at 96x128); Majapahit-era soldier dress on the Hulubalang; wayang costume terms on the Wiku; "Pendekar" chosen over "Jawara" (local-strongman connotation).
- VERIFY (second paths): keraton prajurit dress (kuluk, lurik) on the Prajurit; "Pangangon" and the bandring as a Sundanese herder's sling; Cirebon topeng dress terms (sobrah, kace, ronce) on the Penari Topeng; dalang dress (blangkon, beskap) and the kayon as a held focus (ASSUMED: in wayang it is planted, not carried).
- Art (redesign 2026-11-12): `tools/gen_hero_sprites.py` draws the in-world sprites as a posed rig in 32x32 cells; `tools/gen_portraits.py` paints the 96x128 class figures (6-frame idle) and the hero's 48x48 dialogue busts `p_hero_<id>[_mood].png` from one figure, so the dialogue face is the class you picked ([assets.md](assets.md) 1).

## Schools (ASSUMED, 2026-11-12, narrowed the same day, independent 2026-11-13)
`ClassData.school` maps each second path to its first-path school for sibling item swaps (`Game.SIBLING_ITEM`). In combat (`SpellUtil`), each second path uses its own spell damage multiplier, cost rule, and poise modifier: look, stats, starting weapon, mechanic, all eight class spells, signature aksara and favoured gear are all distinct.

| School | First path | Second path |
|---|---|---|
| warrior | Hulubalang | Prajurit (lancer) |
| archer | Pamanah | Pangangon (herder) |
| rogue | Pendekar | Penari Topeng (dancer) |
| mage | Wiku | Dalang |

## Shared Rules
- Every class can draw and cast aksara spells ([spells.md](spells.md)).
- All classes share the same 5 core stats ([rpg.md](rpg.md)) and 3 equipment slots (weapon, armor, accessory).
- Classes differ in starting stat allocation, starting weapon, one distinctive passive, and spell affinity modifiers.
- Visuals: Dedicated class sprites with custom headgear, attire, and starting weapons.
- Class selection occurs when starting a New Game (Title -> Elden-style Class Select pedestal -> Name Entry -> Desa Purwa).

---

## Starting Stats
Stats: Vitality (Vit), Endurance (End), Strength (Str), Dexterity (Dex), Spirit (Spi / Batin).

| Class | Vit | End | Str | Dex | Spi | Total | Starting Weapon | Base Dmg |
|---|---|---|---|---|---|---|---|---|
| **Warrior** | 8 | 6 | 8 | 4 | 3 | 29 | Broadsword (Heavy Melee) | 22 |
| **Archer** | 5 | 6 | 4 | 9 | 4 | 28 | Hunting Bow (Ranged) | 8 |
| **Rogue** | 5 | 7 | 6 | 7 | 3 | 28 | Dagger (Light Melee) | 8 |
| **Mage** | 4 | 5 | 3 | 4 | 10 | 26 | Oak Staff (Staff Bolt) | 8 |
| **Lancer** | 7 | 7 | 8 | 4 | 3 | 29 | Tombak Prajurit (Heavy Melee, reach 40, arc 40) | 20 |
| **Herder** | 5 | 8 | 4 | 8 | 3 | 28 | Bandring (Ranged, 260 px/s, range 200) | 10 |
| **Dancer** | 5 | 6 | 5 | 8 | 4 | 28 | Kipas Besi (Light Melee, arc 120) | 7 |
| **Dalang** | 5 | 5 | 3 | 4 | 9 | 26 | Kayon (Staff Bolt, 190 px/s, range 170) | 8 |

Second-path numbers are **TUNE**: they are not in `balance_model.py` yet.

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

### Second paths (redesign 2026-11-12, **ASSUMED**, numbers **TUNE** in `data/combat_tuning.gd`)
Each has a mechanic you play around, not a flat bonus, and its own spell for every glyph but Ga ([spells.md](spells.md) 3).

- **Prajurit (lancer).** Fantasy: the palace spearman who holds the line. Mechanic **Kuda-kuda**: stand still 0.5 s to brace. Braced, you take 25% less damage, light hits do not stagger you, and your next thrust deals +30% (lingers 0.4 s when stepping in). Hits past 60% spear reach trigger a **tip sweet-spot** (+25% damage). Spell damage x1.0; formation spells (`sunda_nga`, `jawa_ca`) cost 15% less. Spells are lines, walls and formations: javelin, spear fence, front sweep, soldier's oath, spear charge, battle array, flanking spearmen, wave lance.
- **Pangangon (herder).** Fantasy: the herder of the open field, sling, flute and buffalo. Mechanic **Batu Pantul**: a sling stone bounces to one more foe within 70 px (60% damage, or 2 bounces on combo finisher) and deals double poise damage; poise-breaking a foe restores 4 Sakti. Moves 10% faster; spell damage x0.95 with +25% spell poise damage. Spells are stones, pens and animals: thunder boulder, bamboo pen, spiral sling, flute song, buffalo ride, field breath, charging spirit buffalo, paddy flood.
- **Penari Topeng (dancer).** Fantasy: the mask dancer who must not miss a beat. Mechanic **Wirama**: each hit (or +2 on Perfect Dodge) gives one stack (max 8), each worth +3% attack speed and +2% move speed. Being hurt drops all of them. At 8 stacks the finisher fires a piercing fan wave 80 px ahead. Dance spells (`jawa_na`, `jawa_ka`, `sunda_ta`) cost 15% less. Spells are fans, scarf and masks: fan blades, scarf bind, Klana mask (spends up to 4 Wirama), Panji dance, flower steps, gamelan, orbiting masks, wave dance.
- **Dalang.** Fantasy: the puppeteer; his shadows act and he does not. Mechanic **Lakon**: a spell different from your last two casts gets +15% power, stacking to +30%; at max Lakon, casts refund 20% Sakti and trigger a 35% shadow echo; repeating a glyph resets it. Passive **Suluk** stays: Sakti fills 1.35x faster, capacity 100; spell damage x1.05. Spells are puppets and the screen: Pasopati arrow (2 converging at max Lakon), puppet strings, Gara-gara (pulls inward), Suluk Pangruwat, Cakil's charge, Suluk chant, Punakawan (Semar aura + Gareng/Petruk), screen wave.
- **VERIFY**: "Kuda-kuda" as a spear stance word; "Wirama" as the rhythm term in Cirebon topeng; "Lakon" and "Suluk" as used here; every culture term in the spell names ([spells.md](spells.md) 3).

---

## Signature aksara (Phase 4g, user call 2026-11-12, **ASSUMED**, numbers **TUNE**)
Each class learns one aksara no other class can learn. For the first paths it is the first letter of the title. Three second-path titles start with P and both Pa are taken, so a second path takes the first letter of what it carries or is (Galah, Bandring, Topeng, Lakon; Jawa Ta and Jawa Da were tried first and failed the stroke check against Jawa Ha and Jawa Na). It is the class's tenth glyph and its strongest spell (cost 45). A player only ever holds their own, so the eight never compete in the recognizer ([spells.md](spells.md) 10).

| Class | Glyph (id) | Spell | Effect |
|---|---|---|---|
| Hulubalang | Sunda Ha (`sunda_ha`) | **Panji Hulubalang** | Plants a war banner (radius 76, 9 s). Inside it you take 30% less damage and are not staggered, and every melee hit adds a shock (14, radius 40) |
| Pamanah | Sunda Pa (`sunda_pa`) | **Panah Sakti** | One charged arrow across the screen, 90 damage, pierces everything. Eagle Eye applies |
| Pendekar | Jawa Pa (`jawa_pa`) | **Seribu Bayangan** | Marks up to 5 foes within 130 px and stabs each in turn (22 each, bleeds). Untouchable throughout |
| Wiku | Jawa Wa (`jawa_wa`) | **Gema Aksara** | For 10 s every other spell you cast echoes once at 50% power after 0.6 s |
| Prajurit | Jawa Ga (`jawa_ga`) | **Supit Urang** | Two lines of spirit spears close on the aim point (8 blasts of 20), then everything in the centre is pinned 2 s. **VERIFY**: supit urang as a battle formation |
| Pangangon | Sunda Ba (`sunda_ba`) | **Giring Kawanan** | A spirit herd crosses the screen in 5 lanes: 60 damage, carries foes 100 px |
| Penari Topeng | Sunda Ta (`sunda_ta`) | **Panca Wanda** | Five masks over 5 s, one a second: heal 8%, speed, burst 24, stagger r80, burst 60 r90. **VERIFY**: the five Cirebon masks and the term |
| Dalang | Jawa La (`jawa_la`) | **Tancep Kayon** | Plants the kayon: every foe within 240 px is frozen 3 s (bosses slowed 60%) and your spells cost half meanwhile. **VERIFY**: tancep kayon |

- Learned from side quest `SQ-X1` "Aksara Pusaka" ([quests.md](quests.md) 6.3). The spell is a gameplay assignment, and the codex says so.
- Batara Kala's cast-sequence phase never asks for a signature glyph.

## Favoured gear (Phase 4g, **ASSUMED**)
Thirty-two common items, four per class ([items.md](items.md) "Class-favoured gear"). Anyone can equip them. The favoured class also gets one small extra bonus (`ItemData.favoured`, `favoured_bonus`). No gear is class-locked. A class chest or `SQ-X1` gives a second path its own piece in place of its school's (`Game.SIBLING_ITEM`).

---

## Balance Goals
- Any class can complete the full campaign and defeat every boss. No class is mandatory.
- Warrior offers the highest baseline survivability; Mage boasts the highest damage ceiling tied to drawing precision.
- Melee-only completion is viable, but drawn spells significantly enhance combat efficiency.

---

## Class Selection Presentation (`ui/class_select.gd`)
Presented when starting a New Game from the title screen:
- **Left Column:** Class roster of 8 (Jersey 10 at 19) with the cyan diamond cursor, in school order.
- **Center Pedestal:** 96x128 animated character sprite standing on a stone pedestal illuminated by lantern light with gentle floor mist. Switching classes dissolves the character into rising ink particles.
- **Right Panel:** Detailed panel showing archetype title, narrative description, animated stat bars, starting equipment icon, and passive ability.
- **Confirmation:** Framed confirmation prompt prevents accidental selection before saving.
