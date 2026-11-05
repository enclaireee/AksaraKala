# Bestiary

Stats are starting values (**TUNE**), derived as role base x zone tier ([balance.md](balance.md) section 6). Ilmu is dropped per kill. Folklore checked Nov 2026. Kuntilanak is pan-Indonesian, not Sunda-specific. Wewe Gombel is Javanese (Bukit Gombel, Semarang): moved to Mataram as a quest figure (decided 2026-11-05). Tuyul: describe only as a money-stealing child spirit, never the stillborn-fetus origin. Genderuwo's rock-throwing echoes a belief that it throws stones onto roofs at night (Geertz, single source). Kemamang's spit, Sandekala's look and the Segara Kidul attacks are game inventions (sources checked 2026-11-05). Maung Bodas (Siliwangi's white tiger) is folk belief.

Design rules:
- Every attack has a visible wind-up (0.3-0.6 s) with a flash or a ground marker.
- Role behavior (speed, wind-up, punish window), poise, attack tokens and statuses: [combat.md](combat.md).
- 3 archetypes (chaser, shooter, charger) plus 1 tank per zone, re-skinned and re-tuned across zones.
- Cartoonish look, no gore.
- Each enemy has a codex entry.
- Each zone mixes 2-3 mundane enemies (bandits, soldiers, beasts) with 1-2 folklore spirits. Minibosses and bosses stay legendary (decided 2026-11-05, **ASSUMED**).

## Zone 1: Tatar Sunda
| Enemy | Archetype | HP | Dmg | Ilmu | Behavior | Folklore note |
|-------|-----------|----|-----|------|----------|---------------|
| Bandit | Chaser | 40 | 8 | 6 | Rushes and swings a short blade | Mundane. Plain fantasy-RPG enemy (**ASSUMED**) |
| Bandit Archer | Shooter | 40 | 8 | 6 | Keeps distance, fires a telegraphed arrow | Mundane (**ASSUMED**) |
| Wild Boar | Charger | 60 | 12 | 9 | Telegraphs, then dashes in a straight line | Mundane beast. Replaces Maung (the tiger spirit is dropped; Maung Bodas, Siliwangi's white tiger, may return as a legendary encounter later) |
| Kuntilanak | Shooter | 40 | 8 | 6 | Floats, keeps distance, shrieks in a short cone | Female ghost of Indonesian and Malay folklore |
| Jurig Leuweung | Tank | 150 | 12 | 15 | Slow, wide swing. Bind roots it (see Glyph weaknesses) | Descriptive name: a "jurig" (ghost, verified) of the "leuweung" (forest, **VERIFY** spelling). No named Sundanese figure fits a slow giant without reusing Genderuwo, and a generic spirit claims no legend (decided 2026-11-05, **ASSUMED**) |

**Miniboss: Sandekala** (P1, optional, in the bamboo forest at dusk). HP 1100, Dmg 14, Ilmu 100 (**TUNE**, [balance.md](balance.md) 7). Sundanese dusk spirit said to take children who stay outside after sunset (verified, 2 sources). Its form is not fixed in the belief, so the look is ours: a tall shadow with a lantern-less face.
- The arena darkens over the fight. In shadow it fades out and reappears behind the player with a grab (0.6 s wind-up, ground marker).
- Four oncor (torches) ring the arena. A hit lights one and shrinks the shadow. With all four lit it cannot fade.
- Teaches: reading wind-ups and using the room, before Sangkuriang.

**Boss: Sangkuriang.** HP 2100. Ilmu 150.
- Phase 1: throws logs and boat fragments in arcs (ground-marked), slams the ground.
- Phase 2: builds toward "dawn" (a visible progress bar). If the player draws the light glyph (the "fake dawn", from the legend where cloth to the east and crowing roosters trick him; cloth color varies by retelling, red or boeh rarang), the boss is stunned for a few seconds. Fail to do it and he gets enraged.
- Teaches: casting under pressure.

## Zone 2: Mataram
Mundane enemies to be added when the zone is built (Phase 5), per the mix rule.

| Enemy | Archetype | HP | Dmg | Ilmu | Behavior | Folklore note |
|-------|-----------|----|-----|------|----------|---------------|
| Genderuwo | Tank | 195 | 14 | 22 | Big melee, throws rocks | Hairy giant spirit |
| Tuyul | Chaser (swarm) | 31 | 9 | 4 | Fast swarm, low HP, comes in groups of 3-5 | Small child spirit in folklore |
| Pocong | Charger | 78 | 14 | 14 | Hops forward, slams down | Shrouded ghost |
| Arca (statue) | Shooter (stationary) | 78 | 9 | 14 | Stationary, fires a bolt, wakes when you pass | Ties to the temple legend |

**Quest figure: Wewe Gombel** (SQ-M2 in [quests.md](quests.md)). Not a regular enemy, since the quest can end peacefully with her returning the child. Elite if fought: HP 780, Dmg 16, Ilmu 90, slow wide swing, grabs and pulls the player in. Javanese ogress who takes neglected children (Bukit Gombel, Semarang).

**Boss: Bandung Bondowoso.** HP 3100. Ilmu 300.
- Summons spirit builders to raise "pillars". Each pillar must be broken to damage the boss (or he is shielded).
- Phase 2: pillars rise faster and rain debris.
- Teaches: crowd control and area spells.

## Zone 3: Tanah Timur
Mundane enemies to be added when the zone is built (Phase 5), per the mix rule.

| Enemy | Archetype | HP | Dmg | Ilmu | Behavior | Folklore note |
|-------|-----------|----|-----|------|----------|---------------|
| Banaspati | Chaser | 64 | 10 | 14 | Flaming head, hits and its ground trail apply Burn | Fire spirit |
| Prajurit Terkutuk | Tank | 240 | 16 | 34 | Cursed soldier. Its shield blocks 75% of damage from the front, so hit it from behind | Theme tie-in to Singasari |
| Kemamang | Shooter | 64 | 10 | 14 | Floating teal flame, keeps distance, spits 3 slow wisps in a spread. Melee cuts the wisps | Javanese floating fireball (single source). Teal so it never reads as Banaspati |
| Keris Hantu | Charger | 96 | 16 | 20 | Flying keris spirit, darts in lines, hits apply Curse (teaches it before the Keris boss) | Ties to Mpu Gandring |

**Miniboss: Buto Ijo.** HP 3400. Ilmu 300. Based on the Timun Mas legend. Each phase the hero's "pouch" changes the arena, mirroring the legend's four items: cucumber seeds, needles, salt, shrimp paste (terasi). **VERIFY** the legend's items. Arena effects: bramble field, bamboo forest, saltwater, mud.

**Boss: Mpu Gandring's Keris (cursed wraith).** HP 4200. Ilmu 500.
- Legend: Mpu Gandring's dying curse is that Ken Arok and seven descendants die by the keris (retellings differ on the count). The 7 marks are game design, not cited as legend.
- Mechanic: the boss accumulates up to 7 curse marks on the arena. Fill all 7 and it triggers a big attack. The player removes marks with the right glyph.
- Teaches: using the spell system proactively.

## Zone 4: Segara Kidul
Mundane enemies to be added when the zone is built (Phase 5), per the mix rule.

| Enemy | Archetype | HP | Dmg | Ilmu | Behavior | Note |
|-------|-----------|----|-----|------|----------|------|
| Lampor | Chaser (swarm) | 46 | 12 | 10 | A line of 3-5 torch-bearing spirit soldiers that drifts, then rushes | Folk spirits called "obor setan" (devil torch), verified 2 sources. Some tellings call them the Queen's army: never say so in game text |
| Ula Segara | Shooter | 76 | 12 | 20 | Sea snake that rises from the shallows, spits a water arc, sinks again | Generic sea snake ("ula" is Javanese for snake, **VERIFY**), not a named figure. Nyi Blorong is avoided on purpose (tied to living pesugihan belief) |
| Bajul Putih | Tank | 285 | 17 | 51 | Snaps in a wide arc, tail-sweeps behind, lunges in a straight line from the water | White crocodile. In the Aji Saka legend the giant king Dewata Cengkar is driven into the southern sea and becomes one (single source, **VERIFY**), which ties the zone to the Hanacaraka |

**Elite: Bajul Putih Tua** (old white crocodile, SQ-K2 bounty). HP 1140, Dmg 20, Ilmu 204 (elite x tier 3). Same moves, faster lunges, a second lunge in phase 2.

**Trial of the waves** (MQ4 4.3, P1). Three waves on the beach at low tide, each with a clean glyph answer. As everywhere, the glyph is a shortcut, not a lock.
1. 5 Lampor in two lines: Ca Burst (Sunda).
2. 2 Ula Segara, 3 Lampor: Ka Bolt during the spit wind-up.
3. 1 Bajul Putih, 2 Lampor: Ga Ward bounces the lunge.

Then the sea goes still and Nyi Roro Kidul speaks once (MQ4). She is not fought, and no enemy here is shown as her servant. Decided 2026-11-05 (**ASSUMED**, numbers **TUNE**).

## Final: Gua Kala
**Boss: Batara Kala.** HP 9300, 3 phases of 3100 (P0 build without Segara Kidul: 8400).
- Phase 1: devouring pulses and falling time-sand attacks.
- Phase 2: the countdown starts. A shield is broken by drawing 3 glyphs in the shown order (stretch).
- Phase 3: all arenas combined, every class mechanic matters.

## Encounters (confirmed 2026-11-05)
Level design builds each zone's 6-10 encounters ([world.md](world.md)) from the rules and named mixes below. Size: 3-6 enemies, 20-40 s of fighting, then a breather ([balance.md](balance.md) 2.1).

Rules:
- **Teach, then test.** An enemy's first appearance is 1-3 of it, alone or with enemies the player already knows, with a clean chance to use its glyph weakness. Mixes come after.
- **One tank** per encounter. The last encounter before a boss may have two.
- **A front and a back.** Mix close roles (chaser, tank, charger) with at most one far role (shooter), so the player always has a clear first target.
- **Room fits the role.** Chargers need a straight lane of 8+ tiles. Shooters get a raised or far spot. Four or more enemies need a room of at least 15 x 9 tiles (240 x 144 px).
- **At most two waves.** Wave 2 appears from a visible place (mist, a grave, a statue) with a 0.5 s warning, never behind the player off screen.
- **The newest glyph earns its place.** Each zone has at least one encounter where its newest glyph weakness is the clean answer.
- Attack tokens and leashing apply as usual ([combat.md](combat.md) 5).

### Tatar Sunda
| Mix | Enemies | Where | Tests |
|-----|---------|-------|-------|
| Bamboo edge | 2 Bandit, 2 Kuntilanak | Open field with bamboo cover | Closing distance, Bolt interrupts |
| Boar lane | 2 Wild Boar | Long straight path | Reading the dash, Ward bounce |
| Batu tulis grove (MQ1 1.4) | 1 Jurig Leuweung, 2 Kuntilanak | Grove clearing | Tank in front, shooters behind, Bind |
| Hunting party | 1 Wild Boar, 1 Jurig Leuweung, 1 Bandit Archer, 1 Kuntilanak | Tea terraces, lane plus cover | Priorities |
| Crater path | 1 Jurig Leuweung, 2 Wild Boar, 1 Bandit, 1 Bandit Archer, 1 Kuntilanak (2 waves) | Before the crater petilasan | Everything in the zone |

### Mataram
| Mix | Enemies | Where | Tests |
|-----|---------|-------|-------|
| Village thieves | 5 Tuyul | Village lanes | Swarm control, Burst |
| Ruins wake (MQ2 2.3) | 3 Arca, 2 Tuyul | Courtyard, statues on the edges | Shooters that do not move, crossfire |
| Graveyard | 2 Pocong, 3 Tuyul | Graveyard, open ground | Hop timing, Bind mid-hop |
| Rock thrower | 1 Genderuwo, 2 Pocong | Rocky field | Bolt on the rock, two threats at once |
| Temple gate | 1 Genderuwo, 2 Arca, 3 Tuyul (2 waves) | Before the temple petilasan | Everything in the zone, Dash-strike on Arca |

### Tanah Timur
| Mix | Enemies | Where | Tests |
|-----|---------|-------|-------|
| Embers | 4 Banaspati | Dry savanna | Burn, Ward snuff |
| Wisps | 2 Kemamang | Dry riverbed with rocks for cover | Closing distance, Na Dash-strike |
| Old guard | 1 Prajurit Terkutuk, 2 Banaspati | Ruined gate | Getting behind the shield, Summon |
| Flying blades | 3 Keris Hantu | Narrow canyon | Dart lanes, Bind, Curse and Heal |
| Savanna patrol | 1 Prajurit Terkutuk, 1 Keris Hantu, 1 Banaspati, 1 Kemamang | Open savanna | Priorities |
| Before the keris | 2 Prajurit Terkutuk, 2 Keris Hantu, 1 Banaspati, 1 Kemamang (2 waves) | Before the boss petilasan | Everything in the zone (two-tank exception) |

Segara Kidul uses its trial waves (below). Gua Kala (about 10 kills) reuses one mix from each earlier zone at tier 4.

## Glyph weaknesses (confirmed 2026-11-05)
Every normal enemy has one glyph that breaks its gimmick. It is a strong shortcut, never a requirement: every enemy can still be beaten with the combo and dodge. This is what makes drawing worth it outside boss fights. Elites and bosses use their own mechanics instead. Numbers are **TUNE**.

| Enemy | Glyph (learned) | Trigger | Effect |
|-------|-----------------|---------|--------|
| Kuntilanak | Ka Bolt (MQ0) | Bolt hits her during the shriek wind-up | Shriek cancelled, she drops to the ground for 2 s and can be hit by melee |
| Wild Boar | Ga Ward (MQ1 1.3) | It dashes into the player while Ward is up | Bounces off as if it hit a wall: 1.5 s stagger |
| Jurig Leuweung | Nga Bind (MQ1 1.5) | Bound | Cannot swing while Bound, takes x2 poise damage |
| Bandit, Bandit Archer | None | Mundane | Beaten with the combo and dodge (**ASSUMED**) |
| Tuyul | Ca Burst (MQ1 1.7) | Burst hits the group | 40 base damage beats their 31 HP: one cast clears a swarm |
| Genderuwo | Ka Bolt | Bolt hits the rock it holds during the throw wind-up | The rock shatters on its head: its own rock damage plus a 1.5 s stagger |
| Pocong | Nga Bind | Bound mid-hop | Falls flat for 2 s and takes x1.5 damage |
| Arca | Na Dash-strike (MQ2 2.4) | Dash-strike passes through it | The stone cracks: x3 damage, usually a kill |
| Banaspati | Ga Ward | It touches the Ward | Flame snuffed for 3 s: no Burn, x1.5 damage taken |
| Prajurit Terkutuk | Ra Summon (MQ2 2.6) | The tiger attacks it | It turns to face the tiger, which exposes its unshielded back to the player |
| Keris Hantu | Nga Bind | Bound mid-dart | Drops to the ground for 2.5 s |
| Kemamang | Na Dash-strike | Dash-strike passes through it while it charges a spit | Snuffed: drops for 2 s and takes x2 damage |
| Lampor | Ca Burst (Sunda) | Burst hits the line | The torches go out: the line staggers 1.5 s. One cast usually clears it |
| Ula Segara | Ka Bolt | Bolt hits it during the spit wind-up | Knocked under: stunned 2 s in the shallows, x1.5 damage |
| Bajul Putih | Ga Ward | It lunges into the Ward | Flips belly up: 2 s stagger, x1.5 damage |

Spread: Ka x3, Ga x3, Nga x3, Ca (Sunda) x2, Na x2, Ra x1. Ha Heal and Ca (Jawa) Rally are self-buffs and have no enemy weakness. Ka (Jawa) Ombak, the final glyph, has none either: it is the answer to projectiles and Kala's time-sand. Heal answers Keris Hantu's Curse.

Discovery:
- **Hint:** each weakness gets one spoken line. The glyph's teacher gives it when the enemy lives in that zone (the elder on Ga: "Ga turns back the boar's charge"). Otherwise the first NPC of the enemy's zone gives it. Lines go in the string tables in both languages.
- **Codex:** the enemy's entry gains a "Kelemahan / Weakness" line the first time the player triggers it.
- **Teach then test:** the first room where an enemy appears has a clean chance to use its weakness (see Encounters).

## Respawn
Normal enemies respawn on rest or death. Minibosses and bosses stay dead.
