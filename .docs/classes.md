# Classes (lineages)

The player is a custom hero. At the start they choose one of four **lineages**. Each is a class inspired by a folklore figure, not the figure themselves. Figures checked Nov 2026 (see notes per class). Class names decided 2026-11-05 (**ASSUMED**): Satria, Pemanah, Bayangan, Pujangga.

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
| Assassin | 5 | 7 | 6 | 7 | 3 | 28 |
| Mage | 4 | 5 | 3 | 4 | 10 | 26 |

Level is shown as `1 + points spent`, so classes with a lower total are not penalized (see [rpg.md](rpg.md)).

## Warrior: "Satria", lineage of Gatotkaca
- Fantasy: unbreakable frontliner. Gatotkaca of wayang is known for his strength (the phrase "otot kawat, tulang besi": muscles of wire, bones of iron) and flying. Verified. Do NOT give him the Konta spear (that is Karna's weapon, which kills Gatotkaca). His heirlooms are Caping Basunanda, Kotang Antakusuma and Padakacarma sandals. Gada as a Gatotkaca link is unverified (club is more Bima's): keep it as gameplay, not lore. **VERIFY**
- Starting weapon: Gada (club): heavy melee, 25 stamina.
- Passive **Otot Kawat**: light hits do not stagger or knock you back ([combat.md](combat.md) 2.7).
- Spell modifiers: Ward x1.3 absorb, Burst +25% radius, spell damage x0.9.
- Playstyle: close range, tanky, spells as shockwaves.

## Archer: "Pemanah", lineage of Arjuna / Srikandi
- Fantasy: precise ranged fighter. Arjuna is the famous archer of wayang, and the arrow Pasopati is associated with him. Verified (Srikandi, also an archer, is Arjuna's pupil and wife in the Javanese version). Who gave Pasopati is unconfirmed.
- Starting weapon: Busur (bow): ranged, 4 stamina per shot.
- Passive **Mata Elang**: +15% damage at long range (over 120 px), Bolt pierces.
- Spell modifiers: Bolt fires as a 3-arrow fan, Dash cost x1.0, spell damage x1.0.
- Playstyle: kiting, positioning.

## Assassin: "Bayangan", lineage of Ken Arok
- Fantasy: fast and deadly. Ken Arok's story is tied to the cursed keris of Mpu Gandring (legend from the Pararaton, label it legend). The curse fell on Ken Arok too.
- Starting weapon: Keris: fast melee, 10 stamina.
- Passive **Langkah Senyap**: dodge costs 14 instead of 20 stamina, x2 damage on hits from behind (within 60 degrees of the enemy's back, not on bosses). Set it up by dodging through an enemy during its wind-up: enemies cannot turn while attacking ([combat.md](combat.md) 5.1).
- Spell modifiers: Dash-strike cost x0.7, Bind lasts +30%, spell damage x1.0.
- Playstyle: hit-and-run, backstabs.

## Mage: "Pujangga", lineage of Nyi Roro Kidul
- Fantasy: master of the written word. Pujangga (KBBI): a poet or man of letters, like the court pujangga of Surakarta. Use the title only, never a real pujangga's name. Chosen over Pawang (rain and animals, not writing), Resi (a religious sage), Juru Tulis (a clerk) and Dukun (avoid).
- Starting weapon: Tongkat (staff): weak ranged bolt, 5 stamina.
- Passive **Batin Tajam**: spell gauge fills 1.2x faster and holds 120 instead of 100 ([balance.md](balance.md)).
- Spell modifiers: spell damage x1.1, all spell costs x0.9, Heal x1.2.
- Playstyle: casts constantly, fragile.

## Balance goals
- Any class can finish the game. No class is required.
- Warrior is the easiest, Mage the most active, Archer and Assassin in the middle (**TUNE**).
- Spells should feel strong enough that melee-only play is slower, not impossible.

## Class selection UX
- Done at the first petilasan in Desa Purwa, as an interaction with four ancestral altars.
- Each altar shows the folklore figure, a 2-line description, stats and a preview of the playstyle.
- A final confirm step prevents accidental picks.
