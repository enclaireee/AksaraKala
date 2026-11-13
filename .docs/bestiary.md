# Bestiary

Enemy stats, archetypes, behaviors, weaknesses, and boss encounter designs across all seven regions. Stats reflect role bases scaled by zone tier ([balance.md](balance.md) 6). Ilmu drops on defeat.

---

## 1. Design Rules & Standards
- **Telegraphs:** Every attack features a distinct visual wind-up (0.3–0.6 s) with a flash, line, or ground marker.
- **Roles & Archetypes:** Built from core role templates (Chaser, Shooter, Charger, Tank, Elite) with customized folklore behaviors, poise, attack tokens, and statuses ([combat.md](combat.md)).
- **Tone:** Stylized pixel art, evocative folklore design, no gore.
- **Mixes:** Each region blends mundane antagonists (bandits, palace guards, wildlife) with folklore spirits and ancient curses.
- **Glyph Weaknesses:** Normal enemies feature a designated aksara counter that disrupts their core gimmick for 1.5–3.0 s ([spells.md](spells.md)).
- **Boss Structure:** Every boss encounter features multi-phase mechanics, telegraphed attacks, and narrative resolution (yielding, confession, unmasking, or calming).

---

## 2. Universal Faction: The Faceless (Wong Tanpa Rupa)
Forgotten individuals bound by their names in the lontar roll at the Nameless Hunter's belt. They obey whoever holds their names ([story.md](story.md)).
- **Visual:** Blank white masks, plain grey attire. On death, the mask cracks and a name-strip dissipates into motes.
- **Mechanics:** Mundane enemies beaten via combo and dodge; no specific glyph weakness. Scale with the regional tier:
  - `desa_`, `ts_` (Tier 0): HP 40, Dmg 8, Ilmu 6.
  - `kg_`, `mt_` (Tier 1): HP 52, Dmg 9, Ilmu 9.
  - `tt_` (Tier 2): HP 64, Dmg 10, Ilmu 14.
  - `sk_` (Tier 3): HP 76, Dmg 12, Ilmu 20.
  - `gk_` (Tier 4): HP 88, Dmg 13, Ilmu 31.
- **Variants:**
  - `faceless`: Chaser, rushes with a short blade.
  - `faceless_archer`: Shooter, fires telegraphed arrows from range.

---

## 3. Regional Rosters & Boss Encounters

### 3.0 Hub: Desa Purwa (Prologue & Outskirts)
The peaceful starting village and training grounds.
- **Enemies:** Minimal threat during opening training; wild boars in outer brush, tutorial chasers during the prologue raid.

---

### 3.1 Act I: Tatar Sunda (Tier 0)
Lush sawah, bamboo forests, tea terraces, and the Tangkuban Perahu volcanic crater.

| Enemy | Role | HP | Dmg | Ilmu | Behavior | Weakness |
|---|---|---|---|---|---|---|
| **Bandit** | Chaser | 40 | 8 | 6 | Rushes and swings a short blade | Sunda `Ka` (Bolt staggers) |
| **Bandit Archer** | Shooter | 40 | 8 | 6 | Fires telegraphed arrows at range | Sunda `Ga` (Ward reflects arrow) |
| **Wild Boar** | Charger | 60 | 12 | 9 | Straight-line dash after ground line marker | Sunda `Nga` (Bind roots dash) |
| **Kuntilanak** | Shooter | 40 | 8 | 6 | Floats, shrieks in a forward cone | Sunda `Ka` (Bolt interrupts shriek) |
| **Jurig Leuweung** | Tank | 150 | 12 | 15 | Slow, heavy sweeping swings | Sunda `Nga` (Bind immobilizes for 3 s) |

#### Elites & Minibosses
- **Elite: Kuntilanak** (SQ-S2, bamboo grove night, `kuntilanak_elite`): HP 160, Dmg 10, Ilmu 24. Wider shriek cone, longer wind-up. Restricted from crossing illuminated beaten path patches.
- **Miniboss: Sandekala** (Main Path Step 1.10, river gorge at dusk): HP 1100, Dmg 14, Ilmu 100.
  - Sundanese dusk spirit who takes those caught outside after sunset. Tall shadow figure with no lantern face.
  - *Arena:* Ringed by 4 unlit oncor torches. Arena darkens dynamically; in shadow, Sandekala fades and ambushes from behind.
  - *Mechanic:* Striking torches illuminates the gorge. When all 4 are lit, Sandekala cannot fade and remains vulnerable.

#### Main Bosses
- Boss fights v7 (2026-11-13): each boss's phase-2 floor change, kneel glyph and rehearsal object are listed in [combat.md](combat.md) 5.3 and [quests.md](quests.md) §10. Sandekala's zone tick is 3 and Buto Ijo's 7.
- **Boss: Faceless Captain** (`ts_kawah`, lair entrance): HP 1800, Dmg 16/36, Ilmu 150.
  - Spear sweeps (120° arc, 16 dmg) and charging lunges (6-tile line, 36 dmg).
  - *Muster (66% and 33% HP):* Raises spear to summon 2 Faceless reinforcements. Casting Sunda `Ca` (Burst) during the 1.2 s muster disrupts the call and stuns the Captain for 2.0 s.
  - Defeat triggers the cracking of the Crater Seal.
- **Boss: Sangkuriang** (`ts_kawah`, crater rim): HP 2100, Dmg 16/36, Ilmu 150.
  - *Buildup & Sabotage (`laras_sabotage:crater_seal`):* In `LC1`, Laras wedged a river stone into the dawn groove and marked the eastern post.
  - Phase 1: Throws heavy logs and boat timbers in marked arcs; slams ground.
  - Phase 2: Sangkuriang builds toward dawn on a visible progress bar. Hanging the *Boeh Rarang* cloth on Laras's marked post and casting Sunda `Ca` (Burst) creates the legendary false dawn, stunning him for 4.0 s.

---

### 3.2 Act II: Keraton Galuh (Tier 1)
Ancient palace halls, archives, alun-alun, and royal gardens.

| Enemy | Role | HP | Dmg | Ilmu | Behavior | Weakness |
|---|---|---|---|---|---|---|
| **Prajurit Galuh** | Tank | 195 | 14 | 22 | Royal palace guards with shields; frontal defense | Sunda `Nga` (Bind enables flanking) |
| **Faceless Infiltrator** | Chaser | 52 | 9 | 9 | Agile masked intruders in palace shadows | Sunda `Ca` (Burst exposes stealth) |

#### Elites & Bosses
- **Elite: Ririwa** (SQ-G2, `kg_keraton` Kaputren corridors): HP 312, Dmg 16, Ilmu 56. Charger archetype. Sweeps broad broom arc, then rushes corridor. Weakness: Bind.
- **Boss: Prabu Barma Wijaya (The False King)** (`kg_keraton`, throne room): HP 2400, Dmg 18/40, Ilmu 220.
  - *Buildup & Sabotage (`laras_sabotage:glamour_seal`):* In `LC2`, Laras stole his royal signet wax.
  - Phase 1: Rapid kris thrusts and fan of 3 thrown kris-darts.
  - *Glamour Phase (70% and 35% HP):* Splits into 4 identical illusionary copies. Thanks to Laras's sabotage, hitting any decoy with any aksara spell shatters it instantly in one hit. Destroying all decoys stuns Barma Wijaya for 3.0 s.
  - At 0 HP, his glamour slips and he confesses the royal secret.

---

### 3.3 Act III: Mataram (Tier 1)
Temples, dry savannah, night sieges, and the Pamali boundary river.

| Enemy | Role | HP | Dmg | Ilmu | Behavior | Weakness |
|---|---|---|---|---|---|---|
| **Tuyul** | Chaser (Swarm) | 31 | 9 | 4 | Fast swarming spirits, low HP, groups of 3–5 | Jawa `Ca` (Rally shockwave) |
| **Pocong** | Charger | 78 | 14 | 14 | Hops forward, high slam shockwave | Jawa `Na` (Dash-strike through leap) |
| **Arca** | Shooter (Stationary) | 78 | 9 | 14 | Dormant stone statue that wakes and fires energy bolts | Jawa `Ha` (Heal pulse pacifies) |
| **Genderuwo** | Tank | 195 | 14 | 22 | Towering hairy giant, throws heavy boulders | Jawa `Na` (Dash-strike backstab) |

#### Elites & Bosses
- **Elite: Tuyul Leader** (SQ-M3, `tuyul_leader`): HP 124, Dmg 11, Ilmu 16. Fast swarm leader distracted by scattered drops.
- **Quest Figure: Wewe Gombel** (SQ-M2, `wewe_elite`): HP 780, Dmg 16, Ilmu 90. Can be resolved peacefully via Kelir memory teaching.
- **Boss: Bandung Bondowoso** (`mt_candi`, Candi Seribu): HP 3100, Dmg 18/41, Ilmu 300.
  - *Buildup & Sabotage (`laras_sabotage:bondowoso_pillar`):* In `LC3`, Laras hid the master chisel under the altar.
  - Stone throws and seismic stomps. Summons spirit builders to erect defensive pillars. Bondowoso is invulnerable while any pillar stands.
  - *Lesung Rhythm:* The lesung women pound a rhythm every 20 s. Casting Jawa `Ca` (Rally) synchronizes with the beat, immediately exposing all standing pillars to a one-hit shatter.
- **Boss: Hariang Banga** (`kg_pamali`, river boundary): HP 3200, Dmg 21/45, Ilmu 320.
  - Honorable prince and master swordsman. Holds front guard (80% damage reduction from front).
  - *Mechanic:* Jawa `Na` (Dash-strike) through him breaks guard, applying 2.0 s stagger and +50% damage taken for 3.0 s.
  - Yields with honor at 15% HP; neither brother dies.

---

### 3.4 Act IV: Tanah Timur (Tier 2)
Volcanic ash plains, dry riverbeds, banyan groves, and ancient Singasari ruins.

| Enemy | Role | HP | Dmg | Ilmu | Behavior | Weakness |
|---|---|---|---|---|---|---|
| **Banaspati** | Chaser | 64 | 10 | 14 | Flaming skull; leaves burning ground trails | Sunda `Ga` (Ward douses fire trail) |
| **Prajurit Terkutuk** | Tank | 240 | 16 | 34 | Cursed warrior with heavy shield (75% frontal reduction) | Jawa `Na` (Dash behind) |
| **Kemamang** | Shooter | 64 | 10 | 14 | Teal fireball spitting 3 slow homing wisps | Melee cuts wisps / Sunda `Ka` |
| **Keris Hantu** | Charger | 96 | 16 | 20 | Floating blade that darts in straight lines; inflicts Curse | Sunda `Nga` (Bind halts flight) |

#### Elites & Bosses
- **Elites:** Yuyu Kangkang (SQ-T1 river crab charger, HP 384); Banaspati Elite (SQ-T2 flaming spirit, HP 256).
- **Miniboss: Buto Ijo (3-Zone Stalking Ambushes & Lair):** HP 3400, Dmg 23/51, Ilmu 300.
  - *Ambush 1 (`tt_kulon`):* 90% armor hide; lured into savanna fire braziers (retreats at 80% HP).
  - *Ambush 2 (`tt_kali`):* Trapped with cucumber-seed bramble pouch (retreats at 65% HP).
  - *Ambush 3 (`tt_beringin`):* Stunned with needle bamboo wall (retreats at 50% HP).
  - *Final Lair (`tt_ladang`):* 4-phase arena battle utilizing the 4 pouches (Brambles slow 50%, Needles stun charge 1.5 s, Salt slows 60%, Terasi binds 2.0 s).
- **Boss: Cursed Keris Mpu Gandring** (`tt_candi`, shrine altar): HP 4200, Dmg 18/60, Ilmu 500.
  - *Buildup & Sabotage (`laras_sabotage:keris_seventh_stake`):* In `LC4`, Laras bound *Ka* onto the seventh stake, doubling its ignition delay.
  - Floating cursed blade darting across arena and firing blade fans. Lights 7 curse stakes around perimeter. If all 7 light, an arena-wide shockwave triggers.
  - *Cleansing:* Any aksara spell cast near a lit stake douses it. Casting Jawa `Ha` (Heal) cleanses all lit stakes within 80 px (120 px near Stake #7).
- **Boss: The Nameless Hunter (Si Tanpa Ngaran)** (`tt_candi` inner court): HP 4600, Dmg 24/54, Ilmu 480.
  - Tall cloaked stalker wielding shadow-step teleports, chain hooks, and the pale cone Forget strike.
  - *Mechanic:* Ga Ward deflects Forget; dodging evades shadow-step slashes. At 0 HP, his mask disintegrates, revealing Aria Kebonan.

---

### 3.5 Act V: Segara Kidul (Tier 3)
Coastal villages, mangrove mazes, sea caves, and the sunken pavilion.

| Enemy | Role | HP | Dmg | Ilmu | Behavior | Weakness |
|---|---|---|---|---|---|---|
| **Lampor** | Chaser (Swarm) | 46 | 12 | 10 | Torch-bearing ghost soldiers rushing in formation | Sunda `Ca` (Burst extinguishes torches) |
| **Ula Segara** | Shooter | 76 | 12 | 20 | Sea serpent rising from water to spit tidal arcs | Sunda `Ka` (Bolt interrupts spit) |
| **Bajul Putih** | Tank | 285 | 17 | 51 | Massive white crocodile with tail sweeps and lunges | Sunda `Ga` (Ward deflects lunge) |

#### Elites & Sea Trials
- **Elite: Bajul Putih Tua** (SQ-K2 bounty): HP 1140, Dmg 20, Ilmu 204. Ancient crocodile driven back into deep waters.
- **Three Sacred Sea Trials:**
  1. *Trial of the Torch-Lines (`sk_karang`):* 2 waves of Lampor lines broken with Sunda `Ca` Burst.
  2. *Trial of the Abyssal Current (`sk_gua`):* Sunken cavern navigation unlocked by `laras_key:tidal_gate`.
  3. *Trial of the Waves (`sk_keraton`):* 3 waves culminating in Bajul Putih + Lampor.
- **Audience with Nyi Roro Kidul:** Revered sea guardian speaks from across the water and bestows `jawa_ka` (*Ombak*). Never fought.

---

### 3.6 Act VI: Gua Kala (Tier 4)
The subterranean realm of devouring time beneath Mount Merapi.

| Enemy | Role | HP | Dmg | Ilmu | Behavior | Weakness |
|---|---|---|---|---|---|---|
| **Faceless Elite** | Elite Chaser | 1320 | 22 | 306 | High-tier masked warriors protecting the inner sanctum | Combo + perfect dodge |

#### Final Boss: Batara Kala
`gk_ruang_kala`, HP 9300 (3 phases of 3100 HP), Ilmu 1000.
- **Lore:** Devouring deity of time. Reclaiming `La`, `Ra`, `Sa` and Laras Chapter `LC6` establishes `laras_sabotage:kala_eclipse`. Kala is calmed and guided back, never killed.
- **Dual-Perspective Combat (`laras_sabotage:kala_eclipse`):**
  - In Phase 2 and 3 shield sequences, Laras calls out the stolen letters from inside Kala's shadow.
  - Casting `Sunda glyph -> Jawa glyph -> Ombak` shatters his Eclipse Shield from within, stunning him for 4.0 s.
- **Choice 6 Integration:**
  - If `choice_redeem_aria` was chosen: Aria Kebonan's spirit slows Kala's hourglass (+6 s to Ruwatan timer).
  - If `choice_release_aria` was chosen: Hero gains **Keteguhan Sunyi** (+15% stamina and sakti regeneration).

---

## 4. Complete Glyph Weakness Reference
| Glyph | Countered Enemies | Effect |
|---|---|---|
| **Sunda Ka (Bolt)** | Kuntilanak, Ula Segara, Bandit | Interrupts shriek/spit wind-ups; staggers light enemies |
| **Sunda Ga (Ward)** | Bandit Archer, Banaspati, Bajul Putih, Hunter | Reflects arrows, extinguishes fire trails, deflects heavy lunges, blocks Forget |
| **Sunda Nga (Bind)** | Wild Boar, Jurig Leuweung, Keris Hantu | Roots charges, binds tanks for 3.0 s |
| **Sunda Ca (Burst)** | Faceless Captain, Sangkuriang, Lampor | Disrupts muster calls, triggers false dawn, snuffs torch lines |
| **Jawa Ha (Heal)** | Arca, Cursed Stakes | Pacifies stone sentinels, cleanses curse marks in 80 px radius |
| **Jawa Na (Dash)** | Pocong, Prajurit Terkutuk, Genderuwo, Hariang Banga | Dashes through shockwaves, pierces heavy armor, breaks royal guard |
| **Jawa Ca (Rally)** | Tuyul, Bandung Bondowoso | Disperses swarms, synchronizes with lesung rhythm to shatter pillars |
| **Jawa Ka (Ombak)** | Batara Kala | Cracks Eclipse Shield in final battle sequence |
