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

**Boss: Sandekala** (main path, Act I; the dusk fight in the river gorge, not a P1 optional). HP 1100, Dmg 14, Ilmu 100 (**TUNE**, [balance.md](balance.md) 7). Sundanese dusk spirit said to take children who stay outside after sunset (verified, 2 sources). Its form is not fixed in the belief, so the look is ours: a tall shadow with a lantern-less face.
- The arena darkens over the fight. In shadow it fades out and reappears behind the player with a grab (0.6 s wind-up, ground marker).
- Four oncor (torches) ring the arena. A hit lights one and shrinks the shadow. With all four lit it cannot fade.
- Teaches: reading wind-ups and using the room, before Sangkuriang.

**Boss: Sangkuriang.** HP 2100. Ilmu 150.
- Phase 1: throws logs and boat fragments in arcs (ground-marked), slams the ground.
- Phase 2: builds toward "dawn" (a visible progress bar). If the player draws the light glyph (the "fake dawn", from the legend where cloth to the east and crowing roosters trick him; cloth color varies by retelling, red or boeh rarang), the boss is stunned for a few seconds. Fail to do it and he gets enraged.
- Teaches: casting under pressure.

## Zone 2: Mataram
Mundane enemies: none are planned; the zone uses its three folklore enemies (zones/segara_kidul.md, an accepted exception to the mix rule).

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
- Build spec (2026-11-05, all numbers **TUNE**, mechanics **ASSUMED**):
  - Attacks (balance.md 7): stone throw, light 18, ground marker, 0.9 s wind-up, 96-200 px; stomp, heavy 41, ground marker, 0.8 s wind-up, at 48 px or closer. Same telegraph style as Sangkuriang.
  - Pillars: the fight opens with 1 pillar. He raises one every 12 s (max 3) in a ring 80-128 px around his start spot and at least 32 px from the player. A rising pillar shows its ground mark for 1.5 s first. Spirit builders are a visual only (no extra enemies). A pillar has 150 HP and is hit by weapons and spells, so area spells hit several.
  - Shield: while any pillar stands he takes no damage (a hit shows a shield flash, no hit-stop). With no pillars he takes full damage.
  - Dawn beats: the lesung women at the arena edge pound a beat every 20 s, shown as the HUD dawn bar filling. On the beat every pillar is exposed for 3 s: one hit breaks it. Casting Jawa Ca (the lesung rhythm, taught at 2.5) triggers a beat at once, 8 s cooldown.
  - Phase 2 at 50% HP, after a 1 s pause: a pillar every 6 s, and every 5 s debris falls on 3 ground marks near the player (light 18, 0.8 s marks).
  - Defeat: he stops building and kneels (a release, like Sangkuriang). `boss_defeated:bandung_bondowoso`; Baju Batik comes from MQ2 (2.11).

## Zone 3: Tanah Timur
Mundane enemies to be added when the zone is built (Phase 5), per the mix rule.

| Enemy | Archetype | HP | Dmg | Ilmu | Behavior | Folklore note |
|-------|-----------|----|-----|------|----------|---------------|
| Banaspati | Chaser | 64 | 10 | 14 | Flaming head, hits and its ground trail apply Burn | Fire spirit |
| Prajurit Terkutuk | Tank | 240 | 16 | 34 | Cursed soldier. Its shield blocks 75% of damage from the front, so hit it from behind | Theme tie-in to Singasari |
| Kemamang | Shooter | 64 | 10 | 14 | Floating teal flame, keeps distance, spits 3 slow wisps in a spread. Melee cuts the wisps | Javanese floating fireball (single source). Teal so it never reads as Banaspati |
| Keris Hantu | Charger | 96 | 16 | 20 | Flying keris spirit, darts in lines, hits apply Curse (teaches it before the Keris boss) | Ties to Mpu Gandring |

**Miniboss: Buto Ijo.** HP 3400. Ilmu 300. Based on the Timun Mas legend. Each phase the hero's "pouch" changes the arena, mirroring the legend's four items: cucumber seeds, needles, salt, shrimp paste (terasi). **VERIFY** the legend's items. Arena effects: bramble field, bamboo forest, saltwater, mud.
- Build spec (2026-11-05, all numbers **TUNE**, mechanics **ASSUMED**). The pouches help the player against Buto, as in the legend, and they never hurt the player.
  - Attacks (balance.md 7): charge, heavy 41, a line marker 0.8 s, from 64-200 px, runs 220 px or until a wall; ground pound, heavy 41, a ring marker (r 48) 0.8 s, at 56 px or closer. Same telegraph style as Sangkuriang.
  - Pouch phases: 4 phases at 100/75/50/25% HP. At each phase start he roars (1 s pause) and Timun Mas (a visual off-arena, no node) throws the next pouch. The pouch makes 3 fields (r 32) at set spots in the arena, between his start spot and the arena centre. The fields stay until the fight ends, so the arena gets kinder each phase. Fields only affect Buto:
    1. Cucumber seeds, **bramble field**: Slow 50% while he stands in one.
    2. Needles, **bamboo forest**: a charge that enters one ends at once and stuns him 1.5 s (heavy hits land free).
    3. Salt, **saltwater**: Slow 60% and he cannot start a charge while in one.
    4. Terasi, **mud**: entering one Binds him 2 s, then that field rests 4 s.
  - Teaches: luring a big enemy through terrain.
  - Defeat: he sinks to his knees in the mud and Timun Mas is safe (off screen). `boss_defeated:buto_ijo`, sets `mq3_4`.

**Boss: Mpu Gandring's Keris (cursed wraith).** HP 4200. Ilmu 500.
- Legend: Mpu Gandring's dying curse is that Ken Arok and seven descendants die by the keris (retellings differ on the count). The 7 marks are game design, not cited as legend.
- Mechanic: the boss accumulates up to 7 curse marks on the arena. Fill all 7 and it triggers a big attack. The player removes marks with the right glyph.
- Teaches: using the spell system proactively.
- Build spec (2026-11-05, all numbers **TUNE**, mechanics **ASSUMED**):
  - Attacks (balance.md 7): dart, light 18, a line marker 0.7 s, it flies 200 px in a straight line, hit applies Curse; blade fan, 3 spirit shots in a 30 degree spread, light 18 each, 0.6 s wind-up, hit applies Curse. It floats (no knockback, poise as a boss).
  - Curse stakes: 7 stakes stand at the arena edge (`curse_stake`, ids 1 to 7). Every 8 s the keris lights one unlit stake (it glows red, 1 s mark first).
  - Cleansing: any glyph cast while the player stands within 40 px of a lit stake puts it out ("glyphs are rewards, not keys": any glyph works). Jawa Ha (Heal, cures Curse) puts out every lit stake within 80 px.
  - Seven marks: when all 7 are lit it stops, a red ring fills the whole arena for 2 s, then a curse wave hits everyone in the arena (heavy 60, applies Curse). Only dash i-frames avoid it. All stakes then go out.
  - Phase 2 at 50% HP, after a 1 s pause: a stake every 5 s, and it darts twice in a row.
  - Defeat: the keris falls point-down into the earth and goes quiet (laid to rest). `boss_defeated:keris_gandring`, sets `mq3_7`.
- Practice marks (MQ3 3.6): the same `curse_stake` with `practice` on, in the forge yard. It is always lit. Cleansing it emits `area_entered:timur_praktik_mark` (not `timur_praktik`, which the marker trigger emits on walk-in) and it relights after 2 s. Step 3.6 counts 2.

**Elites** (elite = x4 HP and x4 Ilmu of the base, as Wewe Gombel and Bajul Putih Tua; numbers **TUNE**). Both are plain spots, inert until their quest step, and not encounters.
- **Yuyu Kangkang** (SQ-T1): giant river crab, elite charger. HP 384, Dmg 18, Ilmu 80. Charges sideways along the 12-tile crossing, pinches twice at close range. Weakness: Bind, as Keris Hantu. Leaves on the peaceful route (the river dries up).
- **Banaspati elite** (SQ-T2): HP 256, Dmg 12, Ilmu 56. A larger flaming head, faster, its burn trail lasts twice as long. Weakness: Ward, as Banaspati.

## Zone 4: Segara Kidul
Main path and P0 since story v3.1 (Act V).
Mundane enemies to be added when the zone is built (Phase 5), per the mix rule.

| Enemy | Archetype | HP | Dmg | Ilmu | Behavior | Note |
|-------|-----------|----|-----|------|----------|------|
| Lampor | Chaser (swarm) | 46 | 12 | 10 | A line of 3-5 torch-bearing spirit soldiers that drifts, then rushes | Folk spirits called "obor setan" (devil torch), verified 2 sources. Some tellings call them the Queen's army: never say so in game text |
| Ula Segara | Shooter | 76 | 12 | 20 | Sea snake that rises from the shallows, spits a water arc, sinks again | Generic sea snake ("ula" is Javanese for snake, **VERIFY**), not a named figure. Nyi Blorong is avoided on purpose (tied to living pesugihan belief) |
| Bajul Putih | Tank | 285 | 17 | 51 | Snaps in a wide arc, tail-sweeps behind, lunges in a straight line from the water | White crocodile. In the Aji Saka legend the giant king Dewata Cengkar is driven into the southern sea and becomes one (single source, **VERIFY**), which ties the zone to the Hanacaraka |

**Elite: Bajul Putih Tua** (old white crocodile, SQ-K2 bounty). HP 1140, Dmg 20, Ilmu 204 (elite x tier 3). Same moves, faster lunges, a second lunge in phase 2.

**Trial of the waves** (MQ4 4.8, main path, held at the `sk_keraton` sea pavilion, not on the beach; **ASSUMED**). Three waves at low tide, each with a clean glyph answer. As everywhere, the glyph is a shortcut, not a lock.
1. 5 Lampor in two lines: Ca Burst (Sunda).
2. 2 Ula Segara, 3 Lampor: Ka Bolt during the spit wind-up.
3. 1 Bajul Putih, 2 Lampor: Ga Ward bounces the lunge.

Then the sea goes still and Nyi Roro Kidul speaks once (MQ4). She is not fought, and no enemy here is shown as her servant. Decided 2026-11-05 (**ASSUMED**, numbers **TUNE**).

## Story v3.1 (Phase 4c, 2026-11-06)
The story ([story.md](story.md)) adds one faction seen in every region and four bosses. All numbers are **TUNE**, all looks and moves are game inventions (**ASSUMED**). Galuh uses the Mataram tier (x1.3 HP, balance.md 6.2): it is the second region now.

**The Faceless (Wong Tanpa Rupa).** Forgotten people, bound by their names in the lontar bundle at the Hunter's belt; they obey whoever holds those names ([story.md](story.md) "Two kinds of forgetting"). Look: blank white masks, grey cloth, no gore. When one dies its mask cracks and a name-strip floats up for 1 s (art only). Mundane rules apply: no glyph weakness, beaten with combo and dodge.

| Enemy | Archetype | HP (tier 0) | Dmg | Ilmu | Behavior | Scene |
|-------|-----------|-------------|-----|------|----------|-------|
| Faceless | Chaser | 40 | 8 | 6 | The bandit's moves, a short blade | `entities/enemies/faceless.tscn` |
| Faceless Archer | Shooter | 40 | 8 | 6 | The bandit archer's moves | `entities/enemies/faceless_archer.tscn` |

They scale by the zone they spawn in, read from the zone id prefix on ready: `desa_`, `ts_` tier 0; `kg_`, `mt_` tier 1; `tt_` tier 2; `gk_` tier 4 (balance.md 6.2). One scene per role, so encounter waves can use them. They replace the bandits in Tatar Sunda and some Tuyul and Pocong packs in later zones (zone docs).

**Boss: Faceless Captain** (Act I, ts_kawah, at Nagawiru's lair). HP 1800, Ilmu 150, speed 40, boss poise (balance.md 7).
- Spear sweep: 0.5 s wind-up with an arc marker (r 40, 120 degrees), light 16.
- Lunge: 0.6 s wind-up, a line marker 6 tiles long, then a dash along it, heavy 36.
- Muster at 66% and 33% HP: he raises the spear (1.2 s) and calls 2 Faceless from the lair's edges with the usual 0.5 s ground warning. **Ca Burst** hitting him during the muster breaks it: no adds and a 2 s stun (the newest Sunda glyph earns its place).
- Defeat: the mask cracks, `boss_defeated:faceless_captain`. The `crater_seal` beat follows (he smashes the seal-stone and Sangkuriang wakes), then the Sangkuriang fight.

**Boss: Prabu Barma Wijaya, the false king** (Act II, kg_keraton, the throne room). HP 2400, Ilmu 220, speed 45 (balance.md 7).
- Phase 1: a kris thrust (0.4 s wind-up, line marker 3 tiles, heavy 40) and a fan of 3 thrown kris-darts (0.6 s wind-up, light 18 each).
- **Glamour** at 70% and 35% HP: he steps back and becomes 4 identical figures (3 copies and him), shuffled over 1 s. Copies take no damage from weapons (hits flicker through). **Any cast glyph that hits a copy breaks it** (aksara reveal true faces). Copies attack with the phase 1 moves at half damage. While any copy stands, the real one also takes no damage. When the last copy breaks he is stunned 3 s and open. A new glamour comes only at the next HP mark.
- Defeat: at 0 HP he does not die. He drops to one knee, his face slips, `boss_defeated:barma_wijaya`. The `confession` beat follows, then `cage`.

**Boss: Hariang Banga** (Act III, kg_pamali, the river duel). HP 3200, Ilmu 320, speed 60 (balance.md 7). An honourable swordsman, never a villain.
- Guard: he faces the player with a raised blade. Weapon hits from the front do x0.2 damage. A **Jawa Na Dash-strike** through him breaks the guard: 2 s stagger, x1.5 damage taken for 3 s. Hits from behind always land.
- Moves: a 3-cut combo (0.4 s wind-up each, light 21), a lunge (0.5 s, line 6 tiles, heavy 45), a ground cut that sends a wave along the floor (0.6 s, line 10 tiles, light 21).
- Yield at 15% HP: he stops, sheathes, `boss_defeated:hariang_banga`. He never dies (the legend: neither brother wins). The `truce` beat follows (the `ford` beat came before the duel).

**Boss: the Nameless Hunter (Si Tanpa Ngaran)** (Act IV, tt_candi after the keris). HP 4600, Ilmu 480, speed 55 (balance.md 7). A tall shape in a hunter's cloak with no face at all.
- Shadow-step: he fades out (0.3 s), a ground marker shows behind the player for 0.6 s, he reappears there with a cut (heavy 54). Rolling out of the marker dodges it.
- Chain hook: 0.6 s wind-up, line marker 8 tiles, light 24, pulls the player 3 tiles toward him.
- **Forget**: 0.8 s wind-up with a pale cone marker (r 64, 90 degrees). Hit by it, the player's sakti empties and casting is locked for 4 s (the existing cast lockout). **Ga Ward** up when it lands blocks it completely.
- Phase 2 at 50%: shadow-steps come in pairs and Forget follows the second.
- Defeat: he comes apart into name-strips, `boss_defeated:nameless_hunter`. The `hunter_name` beat reveals him as Aria Kebonan's true self.

## Main-path bosses in act order (story v3.1, **ASSUMED**)
Sandekala (I), Faceless Captain (I), Sangkuriang (I), Barma Wijaya (II), Bandung Bondowoso (III), Hariang Banga (III), Buto Ijo (IV), Keris Mpu Gandring (IV), the Nameless Hunter (IV), the Trial of the Waves (V, waves, no boss HP), Batara Kala (VI).

Each boss is a person with a stake in the plot (FromSoftware rule, [story.md](story.md) Pacing): a fight ends in a release, a yield, a confession or a calming, not just a death bar.

## Final: Gua Kala
**Boss: Batara Kala.** HP 9300, 3 phases of 3100.
- Phase 1: devouring pulses and falling time-sand attacks.
- Phase 2: the countdown starts. A shield is broken by drawing 3 glyphs in the shown order (stretch).
- Phase 3: all arenas combined, every class mechanic matters.
- Build spec (P0, 2026-11-05, all numbers **TUNE**, mechanics **ASSUMED**). Kala is a deity: he is calmed and turned back, never killed (story.md, codex `ruwatan`, **VERIFY**). Ombak is earned at the Trial of the Waves before this fight, and breaks the eclipse shield (story.md Act V): it is always the last glyph of the shield sequence, so it cannot skip the sequence (fixed 2026-11-06; an Ombak cast out of order resets it like any wrong glyph). Every attack can still be dodged without it.
  - HP 9300 (3 phases of 3100; Segara Kidul is on the main path, so Ingatan rank 4 always applies), Ilmu 1000 (**TUNE**, post-game only). Phases at 100 / 66 / 33% HP, with a 1 s pause at each phase start. He walks slowly (speed 22) and floats (no knockback, poise as a boss).
  - Attacks (balance.md 7): devouring pulse, a ring that grows from him to r 96 over 1.2 s after a 0.8 s wind-up, heavy 41 to a player the ring edge crosses (stand inside it close, or outside it, or dash through); time-sand, 3 ground-marked circles (r 20) at and around the player, 0.9 s mark, light 18 each, the same style as Sangkuriang's logs.
  - Phase 2, the countdown: he raises a shield (takes no damage) and shows a sequence of 3 glyphs: a Sunda glyph and a Jawa glyph chosen at random from `Game.glyphs_learned` ("Sunda and Jawa letters in turn"), then `jawa_ka` Ombak ("and Ombak against the eclipse"). Without Ombak learned (tests only) all 3 come from the learned glyphs, no repeats when 3 or more are learned. The HUD shows the sequence under his bar and the countdown in the thin bar. Every `Events.spell_cast` is checked: the next glyph in the order moves the sequence on, any other glyph resets it to the first. The third one breaks the shield: he is stunned 3 s and open for 10 s, then shields again with a new sequence. The countdown is 30 s; if it runs out he "devours time": a red ring fills the arena 2 s, then heavy 60 to the player (only dash i-frames avoid it), then a new sequence and a full countdown. Pulses and time-sand go on during the shield.
  - Phase 3: both together and faster: wind-ups x0.7, a countdown of 20 s, 5 time-sand circles. The four floor quadrants show the earlier regions (art only, no extra hazards: ponytail, add them if the fight plays thin).
  - Defeat: the hourglass turns over, he lowers his hands and fades back into the clock face. `boss_defeated:batara_kala` (MQ5 5.7); the `write` beat follows and the `kala_exit` door lights.

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
The built mixes are the encounter table in [zones/tatar_sunda.md](zones/tatar_sunda.md): 7 encounters, at most one shooter each, Jurig first at the clearing after Bind is learned (2026-11-05, replaces the earlier mixes that broke the one-shooter rule).

### Mataram
| Mix | Enemies | Where | Tests |
|-----|---------|-------|-------|
| Village thieves | 5 Tuyul | Village lanes | Swarm control, Burst |
| Ruins wake (MQ2 2.3, the ruins lead) | 3 Arca, 2 Tuyul | Courtyard, statues on the edges | Shooters that do not move, crossfire |
| Graveyard | 2 Pocong, 3 Tuyul | Graveyard, open ground | Hop timing, Bind mid-hop |
| Rock thrower | 1 Genderuwo, 2 Pocong | Rocky field | Bolt on the rock, two threats at once |
| Temple gate | 1 Genderuwo, 2 Arca, 3 Tuyul (2 waves) | Before the temple petilasan | Everything in the zone, Dash-strike on Arca |

Arca are stationary shooters: the one-shooter rule does not count them, since they never chase and the player picks the angle (2026-11-05, **ASSUMED**).

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
| Wild Boar | Ga Ward (MQ1 1.4) | It dashes into the player while Ward is up | Bounces off as if it hit a wall: 1.5 s stagger |
| Jurig Leuweung | Nga Bind (MQ1 1.6) | Bound | Cannot swing while Bound, takes x2 poise damage |
| Bandit, Bandit Archer | None | Mundane | Beaten with the combo and dodge (**ASSUMED**) |
| Tuyul | Ca Burst (MQ1 1.10) | Burst hits the group | 40 base damage beats their 31 HP: one cast clears a swarm |
| Genderuwo | Ka Bolt | Bolt hits the rock it holds during the throw wind-up | The rock shatters on its head: its own rock damage plus a 1.5 s stagger |
| Pocong | Nga Bind | Bound mid-hop | Falls flat for 2 s and takes x1.5 damage |
| Arca | Na Dash-strike (MQ2 2.5) | Dash-strike passes through it | The stone cracks: x3 damage, usually a kill |
| Banaspati | Ga Ward | It touches the Ward | Flame snuffed for 3 s: no Burn, x1.5 damage taken |
| Prajurit Terkutuk | Ra Summon (MQ2 2.8) | The tiger attacks it | It turns to face the tiger, which exposes its unshielded back to the player |
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

## Drops
Transient floor pickups spawned at the death spot by EnemyBase; collected by walking over them, never saved, gone on zone reload. Flask Shard and Herb Pouch stay quest-only, so drops are the "Herb" and a flask refill (items.md).
- **Common enemies:** 15% (**TUNE**) chance of one drop. Table (**TUNE**): Herb 70% (heals 20% max HP), Flask refill 30% (+1 charge, up to the max).
- **Elites and minibosses** (any enemy with a `unique_id`): always drop, same table.
- **Bosses:** no drops (their rewards are unchanged). Training dummies never die, so never drop.

## Respawn
Normal enemies respawn on rest or death. Minibosses and bosses stay dead.
