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
- **Boss revamp v9 (2026-11-27, ASSUMED):** each boss now has one rule with a visible set piece and countdown, its old answer glyph, 4-6 moves plus 2 signature moves, and a phase-2 sprite form. The per-boss rules in [combat.md](combat.md) "Boss revamp v9" win over the older gimmick text below where they differ. HP and damage below are design values: code applies x0.85 and retry mercy ([balance.md](balance.md) 7.3).

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
  - *v9 (2026-11-27):* One rule, the hint line: "He cannot enter light. Light all four oncor and he has nowhere to hide." Set piece: darkness closing in, four oncor with visible light pools that shrink as the flame dies (a lit oncor burns about 16 s, TUNE). He keeps out of lit pools; when the 4th lights he is pinned in the open, stunned 3 s with TERBUKA, every time. Moves: claws, grab, lantern void, umbral pillars, dusk pulse; nightfall (50%) adds the Eclipse (flurry cut). Signature rows: `sig1` melt into shadow (the fade), `sig2` rise-and-grab. Heavy wind-ups x1.15 (early boss). The torches stay lit once he falls.

#### Main Bosses
- Boss fights v7 (2026-11-13): each boss's phase-2 floor change, kneel glyph and rehearsal object are listed in [combat.md](combat.md) 5.3 and [quests.md](quests.md) §10. Sandekala's zone tick is 3 and Buto Ijo's 7.
- **Boss: Faceless Captain** (`ts_kawah`, lair entrance): HP 1800, Dmg 16/36, Ilmu 150.
  - Spear sweeps (120° arc, 16 dmg) and charging lunges (6-tile line, 36 dmg).
  - *Muster (66% and 33% HP):* Raises spear to summon 2 Faceless reinforcements. Casting Sunda `Ca` (Burst) during the 1.2 s muster disrupts the call and stuns the Captain for 2.0 s.
  - Defeat triggers the cracking of the Crater Seal.
  - *v9 (2026-11-27), replaces the muster:* One rule, the hint line: "He plants his banner and ghost ranks fade in on the squares over 3 s. Burn the banner and the ranks scatter." Set piece: his war banner (`arena_banner`, 4-frame cloth wave) with rank squares fading in round it (4, 6, 8 by phase). Sunda `Ca` cast near the banner burns it: ranks gone, stun 3.5 s with TERBUKA. Missed, the ranks strike once (one heavy hit if you stand on a square) and the banner furls. Moves: sweep, volley, whirlwind and chain (phase 2), `sig1` plant the banner, `sig2` long spear lunge. Muster adds, rally and Edict are cut. Heavy wind-ups x1.15 (early boss). VERIFY: banner and rank ghosts as Faceless legion imagery.
- **Boss: Sangkuriang** (`ts_kawah`, crater rim): HP 2100, Dmg 16/36, Ilmu 150.
  - *Buildup & Sabotage (`laras_sabotage:crater_seal`):* In `LC1`, Laras wedged a river stone into the dawn groove and marked the eastern post.
  - Phase 1: Throws heavy logs and boat timbers in marked arcs; slams ground.
  - *v9 (2026-11-27):* One rule, the hint line: "The sundial fills as the boat rises. Light the cloth post for a false dawn." Set piece: a sundial inlay (fill drawn by code) and the boat hull `arena_boat` rising mid-arena, filling over the whole fight (25 s, 35 s with Laras's sabotage). Sunda `Ca` at the hung cloth post (dial at least half full): false dawn, the boat crumbles, stun 4 s (+2 s sabotaged) with TERBUKA. Missed, the boat completes and the Dawn Wrath fires once (a ring with a gap), then the dial restarts. Moves: log throw, timber rain, log roll, earthshaker (phase 2), `sig1` adze chop (chip cone), `sig2` boulder heave; slam and cleave are cut. Heavy wind-ups x1.15 (early boss).
  - (Superseded by v9 above) Phase 2: Sangkuriang builds toward dawn on a visible progress bar. Hanging the *Boeh Rarang* cloth on Laras's marked post and casting Sunda `Ca` (Burst) creates the legendary false dawn, stunning him for 4.0 s.

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
  - *Boss revamp v9 (ASSUMED, TUNE):* set piece = 4 wall mirrors (`arena_mirror`). Rule (hint): "Copies step out of the mirrors. Only the real king casts a shadow." Answer: hit the king (the one with a shadow) and every copy shatters; he is stunned 3 s with TERBUKA. Sunda `Nga` stays his finisher.
  - Moves: kris thrust, fan of 3 kris-darts, royal decree and mirror volley (phase 2), sig1 mirror step (steps into one mirror and out of another; a copy steps out of a third; at most 3 copies), sig2 royal cleave (heavy cone, wind-up x1.15 as an early boss). Cut: teleport flurry, Coronation.
  - *Glamour Phase (70% and 35% HP):* up to 3 copies step out of the mirrors; the king is untouchable for 1 s while they shuffle. Thanks to Laras's sabotage, hitting any decoy with any aksara spell shatters it instantly in one hit; breaking the last one stuns him (longer with the flag).
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
  - Summons spirit builders to erect defensive pillars. Bondowoso is invulnerable while any pillar stands.
  - *Boss revamp v9 (ASSUMED, TUNE):* set piece = 4 drum stones (`arena_drum`) in a square, plus the pillars. Rule (hint): "The drum stones light in a beat. Cast Jawa Ca on the gong flash." The drums light one after another; the 4th beat is the gong (all drums flash, 0.8 s window). Answer: Jawa `Ca` in the window cracks every pillar and stuns him 3 s with TERBUKA. An unanswered gong sends a heavy wave out. With Laras's sabotage the pillars also break open on every gong. Debris rain stays (phase 2).
  - Moves: boulder throw, golem fist, pillar crush, leap slam, sig1 summon pillar, sig2 beat stomp. Cut: seismic quake, Thousand Temples.
- **Boss: Hariang Banga** (`kg_pamali`, river boundary): HP 3200, Dmg 21/45, Ilmu 320.
  - Honorable prince and master swordsman. Holds front guard (80% damage reduction from front for weapons).
  - *Boss revamp v9 (ASSUMED, TUNE):* set piece = a cyan guard arc drawn by code in front of him. Rule (hint): "His guard is the cyan arc. Cast Jawa Na through it." Answer: Jawa `Na` (Dash-strike) through the arc breaks the guard: 3.0 s stun with TERBUKA and +50% damage taken.
  - Moves: 3-cut combo, lunge, rising crescent, river lunge and flood (phase 2), sig1 guard stance (the arc blazes, any hit is countered; waiting it out leaves him open), sig2 riposte flurry (three stepping cuts). Cut: iaido, Tsunami.
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
  - *Final Lair (`tt_ladang`), boss revamp v9 (2026-11-27, TUNE):* 4 phases (75/50/25%), one glowing pouch per phase (bramble, needle, salt, terasi art; Mbok Srini's consecrated pouches). **Rule (hint):** "One pouch glows. Stand behind it and let him charge through it." His head-down charge (sig1) crossing the lit pouch stuns him 4 s with TERBUKA and lights the next pouch further round the arena. Moves: ground pound, devour, seed volley, bramble stomp, quake (phase 2+), plus sig1 head-down rush (comes round every third move) and sig2 famine maw (phase 3+: an inhale that drags the player in; safe direction is in, hugging him inside the inner ring). Cut: hunger leap, rampage, the four field effects. Ambushes unchanged. Arena: cover pairs on the north and south walls, open floor round the centre, painted floor `tt_ladang.png`.
- **Boss: Cursed Keris Mpu Gandring** (`tt_candi`, shrine altar): HP 4200, Dmg 18/60, Ilmu 500.
  - *Buildup & Sabotage (`laras_sabotage:keris_seventh_stake`):* In `LC4`, Laras bound *Ka* onto the seventh stake, doubling its ignition delay.
  - *Boss revamp v9 (2026-11-27, TUNE):* the 7 stakes are a floor clock (ring of radius 9 tiles round the keris, 12 o'clock then clockwise). They light in stake order every 6 s (4 s in phase 2); the next stake reddens, marks 1 s, then lights. **Rule (hint):** "The stakes light in order like a clock. Cleanse with Jawa Ha before the seventh." Jawa Ha within 80 px of a lit stake (120 px with the Laras flag) before the 7th lights resets the clock and stuns him 3 s with TERBUKA. If the 7th lights: 2 s red ring, then a curse burst (heavy, curses). With the flag the 7th stake takes twice as long to light and Ha reaches 120 px. Other glyphs no longer douse boss stakes. Moves: dart, fan, teleport flurry, orbit blades, curse mark, plus sig1 blade drill (heavy line dash) and sig2 split into seven (the old seven swords; a hit on the first volley skips the second). Cut: crimson cross. Phase 2: double dart, curse pools. Arena shared with the Hunter, painted floor `tt_candi.png`, four cover blocks at the corners.
- **Boss: The Nameless Hunter (Si Tanpa Ngaran)** (`tt_candi` inner court): HP 4600, Dmg 24/54, Ilmu 480.
  - Tall cloaked stalker wielding shadow-step teleports, chain hooks, and the pale cone Forget strike.
  - *Boss revamp v9 (2026-11-27, TUNE):* set piece is his mask (sprite row). **Rule (hint):** "He raises his mask before Forget. Reflect it with Sunda Ga." The mask raise (sig1) is the 1.2 s tell before every Forget; Sunda Ga cast in that window turns Forget back on him: unmasked (sig2 reel), stunned 4 s with TERBUKA. A Ga Ward still blocks a Forget that lands. Moves: shadow-step, hook, twin slash, void lance, decoys, erasure (phase 2 limit break), plus sig1 mask raise (Forget) and sig2 unmasked reel. Same arena as the Keris.
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
  - Casting `Sunda glyph -> Jawa glyph -> Ombak` shatters his Eclipse Shield from within, stunning him for 5.0 s (4 s + 1 s sabotage bonus), and the first socket starts already answered.
- **Choice 6 Integration:**
  - If `choice_redeem_aria` was chosen: Aria Kebonan's spirit slows Kala's hourglass (+6 s to Ruwatan timer).
  - If `choice_release_aria` was chosen: Hero gains **Keteguhan Sunyi** (+15% stamina and sakti regeneration).
- *Boss revamp v9 (2026-11-27, TUNE):* **Rule (hint):** "The shield names its glyphs. The hourglass drains each phase." Set piece: the eclipse shield on his body with 3 sockets, each drawing the glyph it wants (the next one pulses gold), and the great hourglass prop (`props/arena_hourglass.png`) just north of him, its sand level drawn by code. From phase 2 the shield rises at each phase change and 6 s after each stun. Cast the 3 named glyphs in order (Sunda, Jawa, Ombak); a wrong glyph resets the order, no damage. The third breaks the shield: stun 4 s with TERBUKA, the sand refills. The hourglass drains 30 s (phase 1, 2) and 20 s (phase 3, +6 s with `choice_redeem_aria`); it stands still while the shield is down in phases 2-3. Empty: the glass flashes red for 2 s (marked), then one heavy pulse across the arena, then it refills and a new sequence is named. A miss is one heavy hit, never a wipe. Moves: phase 1 pulse, sand circles, sweep, chime, devour; phase 2 sand, sweep, chime, hands, time skip, devour; phase 3 sand, sweep, skip, meteor, beams, devour, plus the Ruwatan every 5th move (the four quadrants are floor art). `sig1` devour lunge (a 0.8 s line telegraph, then a heavy bite along it); `sig2` the shield raised (held while shielded). Cut: the time stop. HP and damage come from BossKit (x0.85), no wind-up stretch (final boss). Arena: painted floor `gk_ruang_kala.png`, six 2x2 rock stubs (two flank the hourglass, one per quadrant).

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
