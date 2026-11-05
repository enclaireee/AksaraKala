# Combat

How a fight plays moment to moment: attacks, dodging, hits, enemies, statuses and feedback. Stats, damage formulas and enemy numbers live in [rpg.md](rpg.md) and [balance.md](balance.md). Spellcasting lives in [spells.md](spells.md). Every timing is a starting value (**TUNE**). Times are in seconds, distances in pixels (16 px = 1 tile, viewport 480x270).

Research note: the numbers come from common practice in top-down action games (Hades, Enter the Gungeon, Hyper Light Drifter, Souls-likes) and the "juice" talks (Vlambeer, "The Art of Screenshake"; Jonasson and Purho, "Juice it or lose it"). No primary frame data was found, so every value is a starting point to tune in playtests, not a citation.

## 1. Decisions
| Topic | Decision |
|-------|----------|
| Attack input | One button. Clicking (or holding) left mouse chains a **3-hit combo**: two normal hits and a stronger finisher |
| Defense | Dodge with i-frames, plus a **perfect dodge** (timed just before a hit) that refunds stamina and fills the sakti gauge. No parry button |
| Martial art flavor | None. Generic action combat, with the culture carried by weapons, enemies, spells and sound |
| Statuses | 4 readable statuses: Burn, Slow (Bound on enemies), Stagger, Curse |
| Aim | Mouse aim, soft snap for melee, no lock-on (the mouse is also the drawing tool) |
| Slow-mo abuse | Closed: drawing needs 15 sakti to start, 1 s lockout after a cancel or fizzle (confirmed) |
| Glyph weaknesses | Each normal enemy has one glyph that breaks its gimmick for 1.5-3 s. A shortcut, never required ([bestiary.md](bestiary.md)) (confirmed) |
| Contact damage | None. Only attacks hurt, never bumping into an enemy (forgiving) |
| Damage numbers | Shown, small and short, with a toggle in Settings (**ASSUMED**) |

## 2. Player moves
### 2.1 Movement
- Walk speed 90 px/s (about 5.5 tiles/s). Selendang adds +8%.
- 8-way movement on WASD. The character faces the mouse, not the walk direction.
- The camera follows the player and leans up to 16 px toward the mouse.

### 2.2 The 3-hit combo
Every weapon uses the same rule: **the finisher deals x1.5 damage, gives x1.5 sakti and takes x1.5 as long**. Damage per second therefore matches the attack intervals that [balance.md](balance.md) is built on, and the finisher only changes the rhythm and adds its special effect.

| Archetype | Hit 1 and 2 interval | Finisher interval | Wind-up / active / recovery (hit 1-2) | Finisher effect |
|-----------|----------------------|-------------------|----------------------------------------|-----------------|
| Light melee | 0.35 | 0.525 | 0.08 / 0.07 / 0.20 | Forward thrust, reach x1.5 |
| Heavy melee | 0.8 | 1.2 | 0.30 / 0.10 / 0.40 | Ground slam, 32 px radius, strong knockback |
| Ranged | 0.45 | 0.675 | 0.15 draw / shot / 0.30 | Arrow pierces |
| Staff | 0.5 | 0.75 | 0.15 / shot / 0.35 | Bolt pops in a 16 px blast |

- Intervals shrink 1% per Dexterity point and by 30% under Rally ([spells.md](spells.md)).
- Holding left mouse keeps the combo going, so nobody has to click fast.
- The combo resets if no attack starts within 0.5 s after a recovery ends, or after a dodge, cast or hit taken.
- Stamina per hit is the archetype cost in [rpg.md](rpg.md). The finisher costs the same.
- Melee hits lunge 8 px forward (light 10 px, heavy 4 px), which pulls the player into range.
- **Soft snap (melee only):** if an enemy is within reach and within 30 degrees of the cursor, the swing turns to face it. Ranged shots go exactly where the mouse points.

Stamina check (start stats, regen 35/s after 0.4 s): Warrior can combo nonstop for about 17 s, Assassin about 6 s (14 hits). Archer and Mage never run out from attacking alone. Dodging is what really spends stamina, as intended.

### 2.3 Weapon shapes
Weapons of one archetype share timing ([balance.md](balance.md) section 3) and differ in shape.

| Weapon | Hit shape |
|--------|-----------|
| Keris | Arc 90°, reach 20 |
| Kujang | Arc 110°, reach 20. Its curved blade sweeps wider |
| Keris Luk 7 | Arc 90°, reach 22. The finisher hits twice (x0.75 each) |
| Gada | Arc 150°, reach 24 |
| Golok | Arc 120°, reach 26 |
| Tombak | Arc 40°, reach 44. Long thrust, finisher is a 2-tile lunge instead of a slam |
| Busur | Arrow 300 px/s, range 220 |
| Panah Pasopati | Arrow 340 px/s, range 260, every hit pierces one enemy |
| Tongkat | Bolt 200 px/s, range 160 |

- **Cutting projectiles:** a melee hit destroys normal enemy projectiles it touches. Boss heavy projectiles cannot be cut. This gives melee classes an answer to shooters without a parry.

### 2.4 Dodge
| Value | Number |
|-------|--------|
| Duration | 0.35 |
| Distance | 48 (3 tiles), in the movement direction, or toward the mouse if standing still |
| Invincible | From the first frame to 0.25 |
| Recovery | 0.1. An attack or cast can be buffered into it |
| Cost | 20 stamina (Assassin 14). No cooldown |

- A dodge can cancel the recovery of any attack, so a player who over-commits can always escape.
- A dodge passes through enemies but not walls or pits.

### 2.5 Perfect dodge
- **Trigger:** an enemy attack touches the player during the first 0.15 s of a dodge.
- **Reward:** the dodge's stamina is refunded and +10 sakti gauge (Mage x1.2), with a bright flash, a short chime and a 0.05 s pause.
- At most once per second, so rolling through a multi-hit attack cannot farm gauge.
- It is a skill bonus on top of the balance: boss HP in [balance.md](balance.md) assumes no perfect dodges. A player who lands one every 5 s gets about 25-50% more spells.

### 2.6 Input buffer and cancels
The full state-by-input table is in [controls.md](controls.md) 3.
- Attack, dodge and cast inputs are buffered for 0.15 s and fire as soon as the current action allows.
- Order of priority if two are buffered: dodge, cast, attack.
- Casting (hold right mouse) can start during attack recovery, which cancels it. During a dodge it is buffered.
- Using jamu takes 0.6 and can be cancelled by a dodge (the charge is not spent).

### 2.7 Taking a hit
| Value | Number |
|-------|--------|
| Invincible after a hit | 0.8, with the sprite blinking |
| Hurt stagger | 0.25. Dodge is allowed after 0.1 |
| Knockback | 12 px from a light hit, 28 px from a heavy hit |

- **Light hit:** any normal enemy attack and a boss light attack. **Heavy hit:** elite and boss heavy attacks (listed in [balance.md](balance.md) section 7).
- Warrior's Otot Kawat ignores the stagger and knockback of light hits.
- Assassin's backstab (x2): a hit that lands within 60 degrees of the enemy's back. Bosses have no back. The reliable setup is to dodge through the enemy during its wind-up, then hit before it turns (5.1, confirmed 2026-11-05).

## 3. Hitting enemies
### 3.1 Flinch and poise
| Role | Reaction to player hits |
|------|-------------------------|
| Chaser, shooter | Flinch on every hit (0.15). A hit during wind-up cancels the attack |
| Charger | Flinches, except during its dash (super armor) |
| Tank | Poise 60% of HP. No flinch until poise breaks, then staggered for 1.5 s |
| Elite | Poise 30% of HP, staggered for 2.0 s |
| Boss | Poise 12% of HP, staggered for 2.0 s, never during a phase change |

- Poise damage = damage dealt. Finishers deal x2 poise damage.
- Poise refills fully 3 s after the last hit, and right after a break. After a break the enemy cannot be broken again for 5 s, so nothing gets stunlocked.
- Check (Tatar Sunda, start stats): Warrior breaks a tank (poise 90) with one combo, Assassin needs about two. Sangkuriang (poise 252) breaks about every 9-10 s of steady hitting, so a stagger takes up about 20% of the fight.
- Knockback on enemies: light 6 px, heavy 14 px, finisher 24 px. Tanks, elites and bosses take none.

### 3.2 Hit feedback
| Event | Hitstop | Shake | Other |
|-------|---------|-------|-------|
| Light, ranged or staff hit | 0.03 (2 frames) | none | White flash 0.08 on the enemy |
| Heavy hit or finisher | 0.08 (5 frames) | 2 px, 0.15 | |
| Kill | 0.1 | 2 px, 0.2 | Small puff of ink |
| Poise break | 0.1 | 3 px, 0.25 | Ring flash |
| Player hit | 0.06 | 3 px, 0.2 | Red edge vignette |

- Hitstop freezes only the attacker and the target, never the whole game, and is skipped while casting (the cast's slow-mo owns `Engine.time_scale`).
- Shake is at most 3 px at 480x270. Settings has a screenshake slider (0-100%).
- **Kendang hits (ASSUMED):** combo hits 1, 2 and the finisher play three different kendang strokes, finisher loudest, with small random pitch. That is 3 short samples, no beat-sync.
- Damage numbers float up 12 px over 0.5 s. Finishers, backstabs, spells and the Archer's long-range hits use a bigger font.

## 4. Statuses
Each status has one tint, one icon by the HP bar and a short sound when it starts.

| Status | Tint | Effect | Lasts | Applied by | Ends early |
|--------|------|--------|-------|------------|------------|
| **Burn** | Orange flicker | Takes 30% of the burning hit's damage again, over 3 ticks | 1.5 | Banaspati, fire-ground trails | Dodge roll |
| **Slow** | Blue | Move speed -40%. Dodge distance is unchanged, so a dodge still escapes | 2.0 | Mud and saltwater (Buto Ijo arena), Kala's time-sand. On enemies: Bind on elites and bosses (-60%, 4 s) | |
| **Bound** (enemies only) | Glowing script ring | Cannot move, can still attack in reach | 2.0 (Assassin +30%) | Bind glyph on normal enemies | |
| **Stagger** | Shake + stars | Cannot act | Player 0.25; enemies per 3.1 | Hits and poise breaks | |
| **Curse** | Purple marks | Sakti gauge cannot fill | 4.0 | Keris Hantu, Mpu Gandring's Keris, Batara Kala | Heal glyph, petilasan |

- A status never stacks. A new one refreshes the timer.
- A hit absorbed by Ward applies no status.
- Bosses ignore Bound and Stagger from statuses (only poise breaks stagger them).
- Keris Hantu's curse teaches the mechanic in Tanah Timur before the Keris boss.

## 5. Enemy behavior
### 5.1 Role templates
Every enemy is a role plus its zone tier ([balance.md](balance.md) section 6). The role sets its behavior.

| Role | Move speed | Engage | Wind-up | Attack | Recovery (punish window) |
|------|-----------|--------|---------|--------|--------------------------|
| Chaser | 70 | Runs at the player | 0.35 | Short lunge, 16 px | 0.6 |
| Shooter | 50 | Keeps 100-160 px away | 0.5 | One projectile at 110 px/s (tier 2+: 3-shot spread) | 1.5 between shots |
| Charger | 55, dash 220 | Lines up at 60-140 px | 0.6, line marker on the ground | Dash up to 120 px, super armor | 1.0, or 1.5 if it hits a wall |
| Tank | 40 | Walks in | 0.6 | 150° swing, reach 28 | 0.8 |
| Elite | varies | Mix of 2-3 attacks | 0.5 light, 0.9 heavy with ground marker | | 0.8 |

- Enemies notice the player at 160 px or when hit, and give up 320 px from their spawn. Returning to spawn heals them fully.
- Enemies off screen never attack.
- **Turning:** enemies turn at most 360 degrees per second (tanks 180), and not at all during their wind-up and attack. Dodging through an enemy (dodges pass through, 2.4) therefore opens a short window at its back: about 0.3 s against most enemies, 0.8 s against a tank. Bosses follow the same no-turn-during-wind-up rule.
- Every wind-up has a flash or a ground marker ([bestiary.md](bestiary.md)).

### 5.2 Attack tokens
Only a few enemies attack at once, so crowds stay readable.
- At most **2 melee** and **2 ranged** enemies may be in wind-up or attack at the same time. The rest circle at 48-80 px or reposition.
- A token is returned when the attack's recovery ends. An enemy waits at least 0.5 s before asking again.
- Elites and bosses always have a token and do not count toward the limit.
- Implementation: a static counter on the enemy base script, no new autoload.

### 5.3 Bosses
- Light attacks: 0.5 wind-up. Heavy attacks: 0.8-1.0 wind-up with a ground marker. Damage per [balance.md](balance.md) section 7.
- Phase 2 at 50% HP with a 1.5 s invulnerable pause and a line of dialogue or a roar, so the player gets a beat to breathe.
- Each boss has at least one 2-3 s punish window per attack cycle (after a heavy attack or a poise break).
- Mechanics that use spells (the Keris's curse marks, Sangkuriang's fake dawn, Kala's shield) are in [bestiary.md](bestiary.md).

## 6. Spells in combat
Casting rules are in [spells.md](spells.md). Combat-specific rules:
- While drawing, the world runs at 20% speed. The player can still be hit, and hits taken during a cast do not cancel it.
- Slow-mo is not free: drawing needs 15 sakti to start and has a 1 s lockout after a cancel or fizzle ([spells.md](spells.md) 9).
- Hitstop, perfect-dodge pauses and the cast's slow-mo never stack: only one system sets `Engine.time_scale` (the cast). Others pause only the nodes involved.
- Spell hits flinch normal enemies and deal poise damage at x1.5.

## 7. Implementation notes (Godot)
- Reuse the components in [architecture.md](architecture.md): Hitbox and Hurtbox (`Area2D`), Health, Stamina, SaktiGauge, HitFlash. Add one `Status` component that holds at most one status per type with a timer.
- All timings in this doc live in one `CombatTuning` resource (`.tres`) so a playtest tweak needs no code change.
- Perfect dodge check: when the player's Hurtbox is touched during dodge i-frames and less than 0.15 s has passed since the dodge started.
- Hitstop: set `speed_scale` to 0 on the attacker's and target's `AnimationPlayer` and skip their `_physics_process` for the duration.

## 8. Playtest checks
| Check | Target |
|-------|--------|
| A new player lands a perfect dodge by accident in the first zone | Yes, within 5 minutes |
| Deaths to an attack the player says they "did not see" | None. Otherwise lengthen the wind-up or strengthen its marker |
| Enemies attacking at once in a 6-enemy fight | Never more than 4 |
| Average time to kill and boss tries | [balance.md](balance.md) section 11 |

## 9. Open questions
1. ~~Kendang samples~~: redafs on Freesound, CC BY 4.0 ([assets.md](assets.md)). Record a kendang if one take gives too few hits.
2. ~~UI hints~~: no hint for the soft snap; the Archer's long-range hits use the big damage font ([ui.md](ui.md) 2).
