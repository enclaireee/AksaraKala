# Progression and balance

How the player grows, how enemies scale, and the numbers behind both. Every number is a starting value (**TUNE**). The numbers come from [balance_model.py](balance_model.py), so change a knob there, re-run it and copy the tables back here.

Related: [rpg.md](rpg.md) (base formulas), [classes.md](classes.md), [bestiary.md](bestiary.md), [items.md](items.md), [spells.md](spells.md), [quests.md](quests.md) (rewards).

## 1. Decisions
| Topic | Decision |
|-------|----------|
| Length | Main quest alone is about **21–22 hours** (Story v5: 138 steps, 1,285 min modeled, 49 areas, **TUNE**). Side quests (20 quests, ~454 min modeled) and exploring add about 12–14 hours (**~35 hours for 100%**) |
| Enemy scaling | Fixed per zone. Overleveling makes a zone easier, which rewards side quests and exploration |
| Difficulty | One balanced mode plus opt-in assist toggles (section 9) |
| Bosses | An average player at the target level wins in 1-3 tries |
| Reference player | Main quest only, starting weapon, no side-quest gear. Balance is tuned so this player can finish. Anyone who does more has an easier time |

## 2. Pacing
### 2.1 Time budget (main quest only)
Runtime target from [story.md](story.md) Pacing (Story v5, 2026-11-06; checked by `python3 .docs/pacing_model.py`). Every number is **TUNE**; measure real minutes per act in the playtest.

| Part | Quest | Areas | Steps | Minutes | Running % |
|------|-------|-------|-------|---------|-----------|
| Prologue | MQ0 | 1 | 12 | 80 | 6% |
| Act I Tatar Sunda | MQ1 | 8 | 24 | 210 | 23% |
| Act II Keraton Galuh | MQG | 7 | 20 | 175 | 37% |
| Act III Mataram | MQ2 | 8 | 24 | 220 | 54% |
| Act IV Tanah Timur | MQ3 | 8 | 22 | 205 | 70% |
| Interlude Desa Purwa | MQ4 4.1-4.8 | 1 | 8 | 45 | 74% |
| Act V Segara Kidul | MQ4 4.9-4.22 | 7 | 14 | 160 | 86% |
| Act VI Gua Kala | MQ5 | 7 | 14 | 160 | 99% |
| Epilogue | Playable | 1 | — | 15 | 100% |
| **Total** | | **49** | **138** | **1,270 target (1,285 modeled, ~21.4 h)** | **Side quests (~454 min) and exploring add ~13 h (~35 h at 100%)** |

Glyphs known at the end of each part: Prologue 1, Act I 4, Act III 8, Act V 9 (Ombak). Acts II and IV teach none.

Measured main-path kills (notes, from the earlier chapter budget): MQ1 about 40 (2026-11-06 after the roaming packs: 43, of which 21 in fixed encounters, 19 in loose packs, 3 in the `sunda_terraces` wave 2). MQ2 40 (23 fixed, 17 loose). MQ3 40 (24 fixed, 16 loose). MQ5 about 12. **Estimates, not measured:** MQ4 now includes the Interlude (no combat) and the main-path Segara Kidul (about 30 kills in the trial waves plus the reef and cliff packs), about 45 min for Act V (**ASSUMED**, **TUNE**). The Galuh act (MQG) has no measured count yet.

MQ1 grows with the interlocking rebuild (8 areas, user call 2026-11-05); shortcuts cut the walk back, so measure it in the playtest before changing the later rows.
`balance_model.py` does not read the zone maps, so real levels at the boss doors run a little above its numbers. Check this in the playtest. TUNE

Side quests take 3-8 minutes each ([quests.md](quests.md)). 14 of them, plus the hub quests and exploration, add about 80-100 minutes.

Encounter rule: 3-6 enemies, 20-40 seconds of fighting, then a breather (composition rules and named mixes: [bestiary.md](bestiary.md) Encounters). Zones alternate: encounter, NPC or puzzle, encounter, petilasan.

### 2.2 Level targets
Level = 1 + points spent ([rpg.md](rpg.md)). These are the levels at each boss door, from the income model in section 8.

| Boss door | Main quest only | 100% (all side quests) |
|-----------|-----------------|------------------------|
| Sangkuriang | L6-7 | about L12 |
| Bandung Bondowoso | L12-13 | about L19 |
| Buto Ijo / Mpu Gandring's Keris | L17-19 | about L25 |
| Nyi Roro Kidul's trial (main path, Act V, before Batara Kala; **ASSUMED**) | L22 | about L28 |
| Batara Kala | L24-25 | about L29 |

The gap is 4-7 levels, which is about 15-25% more power. A completionist finds bosses easier, never trivial. With no cost cap, farming respawned enemies also works, but the exponential level cost (section 8) makes it slow.

## 3. Where power comes from
The player gets about 2x damage and 1.3x HP over the game. Each source has a ceiling, so no single one can break the curve.

| Source | How much | Guaranteed on the main path? |
|--------|----------|------------------------------|
| **Stats** | +5% damage per point in the matching stat, +10 HP per Vitality | Yes (Ilmu from enemies and bosses) |
| **Ingatan** (the Kujang Pusaka, Phase 7c) | +10% to **all** player damage, weapons and spells, per tier, and +1 Daya. 4 tiers, max +40% | Yes, 1 jamasan per main boss, done at a petilasan |
| **Weapons** | At most 1.25x the class or archetype starter after `damage_mult` (Keris Mpu Gandring excepted, it costs HP). Mostly a change of behavior (reach, arc, speed, a twist key) | No, from side quests, chests and secrets |
| **Armor** | 5% damage reduction per Defense point, 5-25% | Batik and Kain Hijau are on the main path |
| **Jimat** (replaces accessories) | A Daya budget of 2 + tier (2-6). Worn jimat add at most +10% weapon and +10% spell damage (Rajah's +20% below 30% HP aside); the rest is HP, speed, Sakti, flask and utility ([items.md](items.md) 4) | Amulet at MQ0; rest from chests & side quests |
| **Healing Flask** | 3-6 charges, 40-60% heal each | Base only. Upgrades are side-quest rewards |
| **Major Choices** (Story v5) | One of two small rewards per Act, each inside the ceilings above: Sunda `Ca` radius +10%, Sabuk Galuh (+1 Vit, +8% damage reduction), Keris Mpu Gandring or Batu Kali, *Ombak* -3 Sakti and +20% poise damage on Eclipse enemies or the Berkah Pesisir revive/ward, Keteguhan Sunyi (+15% stamina and Sakti recovery in the Kala fight) or +6 s on the Phase 3 countdown ([items.md](items.md), [spells.md](spells.md)). Every choice is a side-grade, so neither branch changes the target levels in section 2.2 (**TUNE**, **ASSUMED**) | No, but one branch per choice is always taken |

### 3.1 Ingatan Progression (the Kujang Pusaka, Phase 7c)
Ibu's kujang remembers what the world forgets. Washing it (jamasan) after each great deed is what keeps a main-quest-only player on the curve. It was designed at +15% per rank in v1 and never built; v1.3.0 ran flat, which is why Kala's model fight was 176 s against a 150 s target.
- A jamasan becomes available after each main boss: Sangkuriang, Bandung Bondowoso, Mpu Gandring's Keris, Nyi Roro Kidul's trial (main path). `Game.jamasan_pending()` = main bosses in `killed` - `Game.ingatan`.
- The player performs it from the Status tab at a petilasan. It raises the tier by 1 (max 4) with a short ritual card and one memory line.
- All damage the player deals (weapon, spell, Summon, Ward absorb) is multiplied by `Game.power_mult()` = `1 + 0.10 x tier` (**TUNE**). Each tier also adds 1 Daya ([items.md](items.md) 4).
- State: `ingatan` (int) is saved (save v4, [rpg.md](rpg.md) 11). Pending is derived, so a v3 save just shows its earned jamasan as pending.
- Buto Ijo is a miniboss and gives no jamasan. The Captain, Barma Wijaya, Hariang Banga and the Hunter give none either (**ASSUMED**).
- Segara Kidul is on the main path, so tier 4 is always within reach before Batara Kala. The model assumes the jamasan is done at the petilasan before each door; a player who skips it is weaker, and the Status tab and the petilasan prompt remind them.
- Why +10%: `balance_model.py` 7.4 puts every main-path fight at 0.70-0.84 of its target time (band asserted 0.65-0.95). +15% overshoots (the Hunter falls to 0.68 and keeps falling); none climbs to 1.17 at Kala.

## 4. Player formulas
| Item | Baseline | Formula / Value | Rationale |
|------|----------|-----------------|-----------|
| Attack interval | - | light melee 0.35 s, heavy 0.8 s, ranged 0.45 s, staff 0.5 s. Dex: +1% attack speed per point | Average timings of 3-hit combo ([combat.md](combat.md) 2.2) |
| Sakti gain per hit | - | heavy 10, light 4, ranged 4, staff 4 | Balances gauge gain rate across weapon attack speeds |
| Spirit gauge bonus | - | +2% per point | Smooth scaling without over-saturating spell frequency |
| Armor | - | `max(1, round(dmg x (1 - 0.05 x defense)))` | Percentage reduction scaling across all zone tiers |
| Spell power | - | Spirit x `power_mult()` x (1 + `damage_mult` + `spell_mult`) | Keeps spell effectiveness aligned with escalating enemy HP |

Unchanged: stamina costs and regen, dodge, Vitality and Endurance formulas, flask, level cost.

## 5. Class balance
Goal from [classes.md](classes.md): any class can finish, Warrior is the easiest and Mage the most active.

### 5.1 Class Balance Parameters
| Class / Weapon | Property | Value | Rationale |
|---|---|---|---|
| Hunting Bow | Base damage | 8 | Balances ranged safety with damage output |
| Mage Keen Mind | Gauge gain multiplier | x1.2 (gauge capacity 120) | Active casting focus without excessive saturation |
| Mage Spell Damage | Modifier | x1.1 | High damage ceiling tied to cast accuracy |

### 5.2 Result (main quest only, middle of each zone, perfect casting)
Damage per second including uptime (melee 45-50%, ranged 60%). Spell share is the part of the damage that comes from spells.

| Zone | Warrior | Archer | Rogue | Mage |
|------|---------|--------|----------|------|
| Tatar Sunda | 28 (31% spells) | 29 (36%) | 27 (37%) | 35 (55%) |
| Mataram | 34 | 35 | 33 | 44 |
| Tanah Timur | 41 | 44 | 40 | 58 |
| Gua Kala | 55 (25%) | 60 (30%) | 53 (30%) | 81 (58%) |

- The other three classes stay within 10% of each other. Warrior has the most HP (about 15 hits from a charger), Mage the least (about 12).
- Mage is about 30% ahead **with perfect casting only**. Real players smudge and fizzle: at about 75% casting efficiency Mage is level with the others. Mage has the highest ceiling, and it is tied to drawing skill, which is the game's gimmick. **TUNE** after playtests.
- Perfect dodges ([combat.md](combat.md) 2.5) are not in the model either. They are a skill bonus.
- Rogue's x2 backstab is not in the model. It makes up for the lowest number above.
- Stat allocation in the model: half to the main stat, 30% Vitality, the rest Endurance. Other builds land within about 10%.

## 6. Enemy scaling
Enemies are authored as **role + zone tier + modifiers**, not hand-picked numbers. A new enemy is one row.

### 6.1 Role base (tier 0, Tatar Sunda)
| Role | HP | Damage | Ilmu | Time to kill (target) |
|------|----|--------|------|-----------------------|
| Chaser | 40 | 8 | 6 | 1-2 s |
| Shooter | 40 | 8 | 6 | 1-2 s |
| Charger | 60 | 12 | 9 | 2-3 s |
| Tank | 150 | 12 | 15 | 5-6 s |
| Elite | 600 | 14 | 60 | 15-20 s |

### 6.2 Zone tier multipliers
| Tier | Zone | HP | Damage | Ilmu |
|------|------|----|--------|------|
| 0 | Tatar Sunda | x1.0 | x1.0 | x1.0 |
| 1 | Mataram | x1.3 | x1.15 | x1.5 |
| 2 | Tanah Timur | x1.6 | x1.3 | x2.25 |
| 3 | Segara Kidul | x1.9 | x1.45 | x3.4 |
| 4 | Gua Kala | x2.2 | x1.6 | x5.1 |

Keraton Galuh (`kg_`, Act II) uses tier 1 with Mataram, Desa Purwa tier 0 (bestiary.md Story v3.1). The old rule "x1.5 per zone" for HP is replaced. HP rising x1.3 per zone keeps time to kill flat for the reference player (chaser about 1.5 s, tank about 5.5 s in every zone). New enemy behaviors, not bigger numbers, make later zones harder. Damage grows with player HP and armor, so a normal hit stays at about 6-10% of max HP. Ilmu grows faster than HP, matching the rising level cost.

### 6.3 Modifiers
| Modifier | Effect | Used by |
|----------|--------|---------|
| Swarm | HP x0.6, Ilmu x0.5, comes in groups of 3-5 | Tuyul |
| Stationary | HP x1.5, Ilmu x1.5 | Arca |

### 6.4 Current enemy stats
| Enemy | Zone (tier) | Role | HP | Dmg | Ilmu |
|-------|-------------|------|----|-----|------|
| Kuntilanak | Sunda (0) | Shooter | 40 | 8 | 6 |
| Bandit | Sunda (0) | Chaser | 40 | 8 | 6 |
| Bandit Archer | Sunda (0) | Shooter | 40 | 8 | 6 |
| Wild Boar | Sunda (0) | Charger | 60 | 12 | 9 |
| Jurig Leuweung | Sunda (0) | Tank | 150 | 12 | 15 |
| Genderuwo | Mataram (1) | Tank | 195 | 14 | 22 |
| Tuyul | Mataram (1) | Chaser, swarm | 31 | 9 | 4 |
| Pocong | Mataram (1) | Charger | 78 | 14 | 14 |
| Arca | Mataram (1) | Shooter, stationary | 78 | 9 | 14 |
| Wewe Gombel | Mataram (1) | Elite (SQ-M2) | 780 | 16 | 90 |
| Banaspati | Timur (2) | Chaser | 64 | 10 | 14 |
| Prajurit Terkutuk | Timur (2) | Tank (was Chaser: it has a shield and fills the zone's tank slot) | 240 | 16 | 34 |
| Keris Hantu | Timur (2) | Charger (was Shooter: it darts in lines) | 96 | 16 | 20 |
| Kemamang | Timur (2) | Shooter | 64 | 10 | 14 |
| Lampor | Kidul (3) | Chaser, swarm | 46 | 12 | 10 |
| Ula Segara | Kidul (3) | Shooter | 76 | 12 | 20 |
| Bajul Putih | Kidul (3) | Tank | 285 | 17 | 51 |
| Bajul Putih Tua | Kidul (3) | Elite (SQ-K2) | 1140 | 20 | 204 |

## 7. Bosses
Boss HP = mean class damage per second for the reference player x target fight time. Fight time already includes uptime (dodging, phases, mechanics).

| Boss | Level, Ingatan rank | Target fight | HP (was) | Light hit | Heavy hit | Ilmu drop |
|------|---------------------|--------------|----------|-----------|-----------|-----------|
| Faceless Captain (Act I) | L6, 0 | 50-65 s | **1800** | 16 | 36 | 150 |
| Sangkuriang | L7, 0 | 60-75 s | **2100** (600) | 16 | 36 | 150 |
| Prabu Barma Wijaya (Act II, Mataram tier) | L10, 1 | 55-75 s | **2400** | 18 | 40 | 220 |
| Bandung Bondowoso | L13, 1 | 65-90 s | **3100** (1000) | 18 | 41 | 300 |
| Hariang Banga (Act III duel, yields at 15% HP) | L16, 2 | 55-80 s | **2800** (3200) | 21 | 45 | 320 |
| Buto Ijo (miniboss) | L17, 2 | 60-85 s | **3400** (800) | 23 | 51 | 300 |
| Mpu Gandring's Keris | L19, 2 | 70-100 s | **4200** (1400) | 23 | 51 | 500 |
| The Nameless Hunter (Act IV) | L20, 3 | 65-100 s | **4200** (4600) | 24 | 54 | 480 |
| Batara Kala | L25, 4 | 115-175 s, 3 phases | **9300** (2500), 3100 per phase | 27 | 60 | none (ending) |
| Nyi Roro Kidul's trial (main path) | L22, 3 | waves of tier 3 enemies | no HP | | | 700 |

- Light hit = about 10% of the reference player's HP after armor. Heavy hit = about 22% (4-5 heavy hits kill). Every heavy attack has a ground marker or a 0.5 s+ wind-up ([bestiary.md](bestiary.md)).
- The old boss HP assumed about 10 damage per hit. With the real formulas a starting Warrior hits for about 30, so the old values gave 15-20 second fights.
- Fight times are with all 4 classes. Fastest is Mage, slowest is Rogue without backstabs. A completionist finishes in about 75% of the time.
- The four story bosses (Captain, Barma Wijaya, Hariang Banga, the Hunter) use the same formula as the rows above (`balance_model.py`, section 7; points spent 5, 9, 15, 19, Ingatan rank 0, 1, 2, 3). All numbers are **TUNE**. Their Ilmu drops (bestiary.md) add 1,170 to the main-path income and are **not** in the section 2.2 and 8.2 income model yet: either halve them or accept about +1 level at Mataram and +3 at Timur, then re-run the model. Decision for the playtest.
- Other minibosses: HP = about 40 s at that zone's damage per second, about 1100 in Sunda (Sandekala) and 1400 in Mataram.

### 7.2 Floor hazards and the kneel (boss fights v7, 2026-11-13, **TUNE**)
Phase-2 floor zones tick every 0.5 s. The model (`balance_model.py` 7.2) assumes a blunder costs 3 ticks and happens twice a fight, and asserts: one blunder costs no more than that boss's light hit, a fight's blunders no more than 25% of the reference HP (about one heavy hit). Ticks: Captain 5, Sangkuriang 4, Sandekala 3 (was 5), Barma 6, Bondowoso 6, Hariang Banga 6, Buto Ijo 7 (was 8), Keris 7, Hunter 6, Kala 8. Boss HP and hit damage are unchanged: the kneel adds at most 4 s with no risk, and the retry at the gate removes the walk back, so the target fight times and the "median 2 tries" target stand until a playtest says otherwise.

### 7.1 Making "1-3 tries" true
- A petilasan sits at most about 20 seconds' walk from every boss door ([world.md](world.md) already puts one before each boss).
- Boss phase 2 starts at 50% HP and is telegraphed with a short pause, so the player learns the second half on try 2.
- Bosses never one-shot: no attack deals more than 35% of the reference HP.
- Retry mercy (boss revamp v9, 7.3) replaces the old "Semar offers the assist toggles after 3 deaths" idea, which was never built.
- Playtest target: median 2 tries per boss, no boss over 4 for the reference player.

### 7.3 Boss revamp v9 scaling (user call 2026-11-27, **TUNE**)
The table above stays the design HP. Code applies, for scene bosses only (`entities/bosses/` with a `unique_id`; pillars, oncor and Barma's copies are left alone):
- **HP x0.85** at spawn (`BossKit.scale_boss`, called from `EnemyBase._ready`).
- **Damage x0.85** on every hit whose source is in the `boss` group (`Hurtbox.receive` -> `BossKit.boss_damage`, at least 1). This covers strikes, floor zones and direct hits.
- **Retry mercy:** each death inside a sealed arena adds 1 to `Game.boss_deaths[unique_id]` (`Zones.respawn`, from the ids `arena_gate` stores in `boss_retry`). Each death takes another 7% off that boss's HP, capped at 20% (x0.85 x0.80 = x0.68 at worst). Not saved: a reload starts fresh.
- **Early wind-ups:** Captain, Sangkuriang and Sandekala heavy wind-ups are 15% longer (combat.md, boss revamp v9).
- The Hunter's scene HP was 3600 against 4600 here. Phase 7c sets both to 4200, so its tiered fight lands at 0.76 of target like its neighbours.
- Effective HP and hits: `balance_model.py` 7.3.

### 7.4 Fight time with Ingatan tiers (Phase 7c, `balance_model.py` 7.4 and 7.5)
Scene HP x0.85 over the mean class dps at the door, as a share of the target fight time. The 100% column adds 3 stat points and the jimat damage cap (+10%).

| Boss | Tier | Main path | 100% |
|------|------|-----------|------|
| Captain | 0 | 0.74 | 0.63 |
| Sangkuriang | 0 | 0.72 | 0.63 |
| Barma Wijaya | 1 | 0.78 | 0.67 |
| Bandung Bondowoso | 1 | 0.78 | 0.67 |
| Hariang Banga | 2 | 0.70 | 0.62 |
| Buto Ijo | 2 | 0.79 | 0.68 |
| Keris | 2 | 0.79 | 0.70 |
| Hunter | 3 | 0.76 | 0.67 |
| Batara Kala | 4 | 0.84 | 0.73 |

Asserts: every main-path share is 0.65-0.95; every 100% share is at least 0.5; no jimat set within a budget of 6 passes the +10% damage cap. The v9 retry mercy and death drop still sit on top for the struggling player.

## 8. Ilmu economy
### 8.1 Level cost
Unchanged: `cost(n) = round(40 x 1.12^n)`. Total to reach L25 is about 4,700 Ilmu, and about 9,600 for L31. Level cost grows about x1.9 per zone and enemy Ilmu x1.5, so later levels need slightly more fighting. That is the intended soft brake.

| Level | Cost of the next point | Total spent |
|-------|------------------------|-------------|
| L7 | 79 | 324 |
| L13 | 156 | 964 |
| L19 | 308 | 2,229 |
| L25 | 607 | 4,726 |
| L31 | 1,198 | 9,653 |

### 8.2 Sources
| Source | Amount |
|--------|--------|
| Normal enemies | Section 6 table. Average about 8 x tier multiplier per kill |
| Bosses | Section 7 table |
| Side quests | Section 8.3 |
| Death | Ilmu is never lost ([rpg.md](rpg.md)) |

Main path: about 4,600 Ilmu, all from enemies and bosses. 100%: about 8,300, of which side quests are about 34%. That matches the 25-35% target in [quests.md](quests.md).

### 8.3 Quest Ilmu
Quest Ilmu follows the level cost curve, so **S = half a level, M = one level, L = 1.5 levels** at that zone's target level.

| Zone | S | M | L |
|------|---|---|---|
| Tatar Sunda | 30 | 60 | 90 |
| Keraton Galuh (same row as Tatar Sunda, **ASSUMED**) | 30 | 60 | 90 |
| Mataram | 55 | 110 | 165 |
| Tanah Timur | 110 | 220 | 330 |
| Segara Kidul | 190 | 380 | 570 |
| Desa Purwa (hub quests) | uses the zone of the current main-quest chapter | | |

The fight path of a two-way quest still gives +50%.

## 9. Difficulty and assists
One mode. Assist toggles live in Settings, can change at any time, and have no penalty or label in the credits.

| Toggle | Effect |
|--------|--------|
| Gentle combat | Damage taken x0.5 |
| Drawing assist | Cast thresholds -0.10 (exists in [spells.md](spells.md)) |
| Slow-mo strength | 10-40% world speed while drawing (exists) |
| Draw time | 2.5-5 s (exists) |

## 10. Adding content without breaking balance
- **Enemy:** pick a role, a zone tier and any modifier, then read the stats off section 6. Do not hand-tune numbers before a playtest.
- **Boss:** pick a target fight time and use the model to get HP and hit damage.
- **Weapon:** at most 1.25x its class or archetype starter after `damage_mult` (`items_test` checks it). Give it a twist: a shape, speed or bonus key. Never the starter plus 1.
- **Jimat:** a Daya cost of 1-3 that matches its strength. A damage jimat must keep `balance_model.py` 7.5 passing. Every bonus key it sets must be read in code.
- **Quest:** Ilmu from section 8.3 by size. Key rewards from [quests.md](quests.md) section 3.2.
- **Zone:** give it the next tier. If it sits between two tiers, use the lower one.

## 11. Playtest checks
| Metric | Target |
|--------|--------|
| Main quest time | 6.5-7 hours (section 2.1) |
| Time to kill (reference player) | Chaser 1-2 s, tank 5-6 s, every zone |
| Normal enemy hit | 6-10% of max HP |
| Boss tries | Median 2, max 4 |
| Spell share of damage | 25-40% (Warrior, Archer, Rogue), 50-60% (Mage) |
| Flasks used per zone | About 3-5 by the reference player |
| Level at boss doors | Section 2.2, within 1-2 levels |

## 12. Balancing Notes
1. **Damage numbers on screen:** enabled by default, toggleable in Settings ([combat.md](combat.md)).
2. **Staff and bow upgrades:** found staffs are side-grades (Tongkat Genta, Cendana, Teken Galih Asem's spell bonus) and bows are Panah Pasopati and the Crossbow. The Kujang Pusaka's Ingatan tiers carry the power curve; weapons carry the play style.
3. **Pacing validation:** `python3 .docs/pacing_model.py` validates the minutes-per-act target curve across all acts and side quests.
