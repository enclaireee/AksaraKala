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
| Slow-mo balance | Drawing requires 15 sakti to initiate, with a 1 s cooldown lockout after a cancel or fizzle |
| Glyph weaknesses | Each normal enemy has one designated glyph that breaks its gimmick for 1.5–3.0 s ([bestiary.md](bestiary.md)) |
| Contact damage | None. Only direct attacks deal damage; colliding with enemy bodies is harmless |
| Damage numbers | Small, quick damage numbers above targets, toggleable in Settings |

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

Stamina check (start stats, regen 35/s after 0.4 s): Warrior can combo nonstop for about 17 s, Rogue about 6 s (14 hits). Archer and Mage never run out from attacking alone. Dodging is what really spends stamina, as intended.

### 2.3 Weapon shapes
Weapons of one archetype share timing ([balance.md](balance.md) section 3) and differ in shape.

| Weapon | Hit shape |
|--------|-----------|
| Dagger | Arc 90°, reach 20 |
| Short Sword | Arc 100°, reach 22 (**TUNE**) |
| Kujang | Arc 110°, reach 20. Its curved blade sweeps wider |
| Keris Luk 7 | Arc 90°, reach 22. The finisher hits twice (x0.75 each) |
| Keris Mpu Gandring | Arc 90°, reach 22. Each hit costs the wielder 1 HP (**TUNE**) |
| Broadsword | Arc 150°, reach 24 |
| Axe | Arc 130°, reach 24 (**TUNE**) |
| Golok | Arc 120°, reach 26 |
| Spear | Arc 40°, reach 44. Long thrust, finisher is a 2-tile lunge instead of a slam |
| Hunting Bow | Arrow 300 px/s, range 220 |
| Longbow | Arrow 280 px/s, range 280, slower draw (**TUNE**) |
| Crossbow | Bolt 360 px/s, range 240, 0.5 s wind-up (**TUNE**) |
| Panah Pasopati | Arrow 340 px/s, range 260, every hit pierces one enemy |
| Oak Staff | Bolt 200 px/s, range 160 |
| Iron Staff | Bolt 210 px/s, range 170 (**TUNE**) |

- **Cutting projectiles:** a melee hit destroys normal enemy projectiles it touches. Boss heavy projectiles cannot be cut. This gives melee classes an answer to shooters without a parry.

### 2.3b Attack animation and FX (Phase 6c, 2026-11-07, **ASSUMED**, frames **TUNE**)
Visual only: timings, hitboxes and damage stay as in 2.2 and 2.3. The goal is fluid, readable, weighty attacks in the manner of Hyper Light Drifter, Death's Door and CrossCode.
- **Directional attack frames.** Each combo hit has its own pose in 3 views (down, side and up; the side view is flipped for left). It runs 6 frames, mapped onto the phases:
  - wind-up: anticipation, then a coil
  - active: the strike, then the smear
  - recovery: the follow-through, then settle
  Hits 1, 2 and 3 differ: hit 1 is a forehand slash, hit 2 a backhand slash, hit 3 the finisher (thrust, slam or lunge, per 2.2). Bow and staff have draw, release and recoil poses.
- **Weapon smear.** A separate sprite rotates to the swing direction and is sized to the weapon's arc and reach (2.3). It is a 4-frame crescent with the archetype's shape:
  - light: a thin, fast arc
  - heavy: a wide, thick arc with dust at the end
  - spear: a straight thrust streak
  - finishers: a bigger arc and a white core
  Its colour comes from the class: warrior steel and ember, rogue indigo and violet, archer and mage use draw and cast glows.
- **Impact.** On a hit there is a 3-4 frame spark star at the contact point, plus a small ink splash in the hit direction. A finisher or heavy hit adds an impact ring and a 2-frame white flash on the target. A kill leaves an ink-puff burst (3.2).
- **Movement.** The lunge leaves 1-2 afterimages (alpha 0.35, 0.12 s). A dodge shows a dust puff at the start, 3 afterimages and a dust puff on landing. Footstep dust appears every 4th walk frame on dirt and path.
- **Bow and staff.** A string-draw glow and a muzzle flash on the shot. The arrow has a 2-frame trail, and the bolt has an orb glow with sparks.
- All of this respects "Reduce flashing" ([controls.md](controls.md) 6): the white flashes are off, and the sparks are kept.

### 2.4 Dodge
| Value | Number |
|-------|--------|
| Duration | 0.35 |
| Distance | 48 (3 tiles), in the movement direction, or toward the mouse if standing still |
| Invincible | From the first frame to 0.25 |
| Recovery | 0.1. An attack or cast can be buffered into it |
| Cost | 20 stamina (Rogue 14). No cooldown |

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
- Using the flask takes 0.6 and can be cancelled by a dodge (the charge is not spent).

### 2.7 Taking a hit
| Value | Number |
|-------|--------|
| Invincible after a hit | 0.8, with the sprite blinking |
| Hurt stagger | 0.25. Dodge is allowed after 0.1 |
| Knockback | 12 px from a light hit, 28 px from a heavy hit |

- **Light hit:** any normal enemy attack and a boss light attack. **Heavy hit:** elite and boss heavy attacks (listed in [balance.md](balance.md) section 7).
- Warrior's Iron Skin ignores the stagger and knockback of light hits.
- Rogue's backstab (x2): a hit that lands within 60 degrees of the enemy's back. Bosses have no back. The reliable setup is to dodge through the enemy during its wind-up, then hit before it turns (5.1, confirmed 2026-11-05).

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
- Check (Tatar Sunda, start stats): Warrior breaks a tank (poise 90) with one combo, Rogue needs about two. Sangkuriang (poise 252) breaks about every 9-10 s of steady hitting, so a stagger takes up about 20% of the fight.
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
| **Bound** (enemies only) | Glowing script ring | Cannot move, can still attack in reach | 2.0 (Rogue +30%) | Bind glyph on normal enemies | |
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
- Implementation: token holders join a scene-tree group (`token_melee` or `token_ranged`), so freed enemies return their token by themselves. No new autoload. (Changed from a static counter, which leaked at exit.)

### 5.3 Bosses
- Light attacks: 0.5 wind-up. Heavy attacks: 0.8-1.0 wind-up with a ground marker. Damage per [balance.md](balance.md) section 7.
- Phase 2 at 50% HP with a 1.5 s invulnerable pause and a line of dialogue or a roar, so the player gets a beat to breathe.
- Each boss has at least one 2-3 s punish window per attack cycle (after a heavy attack or a poise break).
- Mechanics that use spells (the Keris's curse marks, Sangkuriang's fake dawn, Kala's shield) are in [bestiary.md](bestiary.md).
- **Staging (2026-11-12, ASSUMED, timings TUNE; `ui/boss_stage.gd`).** Visual only: no HP, damage or timing changes. It reads the boss-bar contract (`health`, `engaged`, `boss_name_key`, optional `phase`), so it covers every boss with no per-boss code.
  - Entrance: when the boss engages, letterbox bars close in (0.35 s) and a name card opens between two brass rules for 1.5 s.
  - Phase change: a warm flash, 0.3 s of slow motion at 35% speed, a 3 px camera shake, the bars pinch in for a beat.
  - Finishing blow: a white flash, 0.7 s of slow motion at 25% speed, a 4 px shake.
  - "Reduce flashing" dims the flashes to a quarter. Slow motion is skipped while a cast holds the time scale.
  - Telegraphs keep their shapes and sizes (they are the hitboxes) and gain a bright closing edge, an inner rim, turning tick marks on circles and running chevrons on lines (`BossKit.Telegraph`).
  - The boss bar has a brass rule with end studs and a pale ghost bar that trails the fill at 45 px/s.
  - Not built yet: phase-2 sprite forms.
- **Boss fights v7 (user call 2026-11-13, ASSUMED, numbers TUNE).** The player must know who, why here, what harm and the trick before the door ([quests.md](quests.md) §10), and cannot leave once inside.
  - **Arena gate** (`entities/world/arena_gate.tscn`): stands at each arena mouth, open. Two tiles inside it is the threshold. Crossing the threshold starts the fight: the gate turns solid (a wall of burning aksara), `Zones.sealed` is set so no exit or memory works, and every active boss in the zone engages. It opens when no boss is engaged or the boss is at 0 HP. Where a zone has a gate, a boss cannot engage or be hurt before the threshold is crossed (`BossKit.may_engage`). Zones without a gate (tests, Buto Ijo's ambushes) keep engage-by-range.
  - **Entrance** (`ui/boss_stage.gd`): the game pauses, the bars close, the camera travels to the boss, the name card opens with an epithet line under the name (`<BOSS_KEY>_EPITHET`) and one spoken line (`<BOSS_KEY>_INTRO`), then the camera returns and the boss roars. 3.6 s; any of dodge / interact / attack skips it. On a retry it is 0.9 s with no line.
  - **Retry at the door**: crossing the threshold stores `Game.boss_retry = {zone, pos}`. `pos` is just inside the open gate, short of the threshold (inside, because a gate on a map edge has only the zone exit behind it). Death respawns there once (full restore as at a petilasan); resting at a petilasan clears it.
  - **Hints** (`BossKit.hint(host, key)`): one line above the boss bar the first time a gimmick state comes up in an attempt, and again every 12 s while the state lasts and the player has not answered it. **Marks** (`BossKit.mark(host, node, glyph_id)`): a pulsing gold ring and the aksara to draw over the object that answers the gimmick.
  - **Open window**: while a boss is stunned or in a heavy recovery it sets `open_time` > 0; the bar edge glows and shows "TERBUKA".
  - **Phase ticks**: a boss lists `phase_marks` (HP fractions); the bar draws one tick per mark. Default `[0.5]`.
  - **Aksara finisher**: at 0 HP a boss kneels for up to 4 s (`finish_glyph`, its weakness glyph, shown over it). Casting that glyph ends it with a flourish; otherwise the timer does (blows do nothing to a kneeling boss). Then the death animation and `boss_defeated`. Bosses that yield (Hariang Banga, Barma Wijaya) skip it.
- **Laras sabotage phases (Story v5):** Bosses read their designated `sabotage_flag` (`Game.has_flag("laras_sabotage...")`) set by the cross-time chapters `LC1`–`LC6`. When set, the boss HUD bar displays a cracked-glyph flaw marker and unlocks specific phase vulnerabilities: Sangkuriang's cracked dawn groove, Barma Wijaya's copies that shatter in one glyph hit, Bondowoso's pillars that break on every lesung beat, the Keris's seventh stake, and Kala's Eclipse shield. Without the flag, encounters remain beatable with stricter timing. Details per boss: [bestiary.md](bestiary.md).
- **Stalking ambush (Buto Ijo, Story v5):** Three open-field ambushes in `tt_kulon`, `tt_kali`, and `tt_beringin`. Buto Ijo retreats upon reaching HP damage thresholds, each encounter concluding with `area_cleared:buto_ambush_<n>`. The canyon lair in `tt_ladang` hosts the climactic 4-phase showdown utilizing Mbok Srini's four consecrated pouches.
- **Choice effects in combat:** `choice_offer_memory` gives *Ombak* `+20%` poise damage to Eclipse enemies in Act VI ([spells.md](spells.md)). `choice_keep_secret` gives Ciung `+15%` ally damage in Galuh bouts. `choice_redeem_aria` adds `+6 s` to the Kala Phase 3 countdown (`batara_kala.gd` reads this flag). `choice_release_aria` grants Keteguhan Sunyi (+15% stamina and Sakti recovery in `gk_ruang_kala`).

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
- Stagger (hurt stagger, poise break) is a state in the player's and enemies' state machines, not a `Status` type. `Status` holds only Burn, Slow, Bound and Curse. ASSUMED.

## 8. Playtest checks
| Check | Target |
|-------|--------|
| A new player lands a perfect dodge by accident in the first zone | Yes, within 5 minutes |
| Deaths to an attack the player says they "did not see" | None. Otherwise lengthen the wind-up or strengthen its marker |
| Enemies attacking at once in a 6-enemy fight | Never more than 4 |
| Average time to kill and boss tries | [balance.md](balance.md) section 11 |
