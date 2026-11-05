class_name CombatTuning
extends Resource
## Every combat timing in one place (combat.md 7). Edit data/combat_tuning.tres to tune; no code change.
## All values are TUNE starting points from combat.md, controls.md and rpg.md. Times in seconds, distances in px.

@export_group("Player movement")
@export var walk_speed := 90.0
@export var ranged_move_factor := 0.5          # ranged keeps 50% speed while shooting (controls.md 3)
@export var camera_lean := 16.0

@export_group("Input")
@export var buffer_time := 0.15
@export var combo_reset := 0.5                 # combo resets if no attack starts this long after a recovery

@export_group("Dodge")
@export var dodge_duration := 0.35
@export var dodge_distance := 48.0
@export var dodge_iframes := 0.25
@export var dodge_recovery := 0.1
@export var dodge_cost := 20.0

@export_group("Taking a hit (player)")
@export var hurt_iframes := 0.8
@export var hurt_stagger := 0.25
@export var hurt_dodge_after := 0.1
@export var player_knockback_light := 12.0
@export var player_knockback_heavy := 28.0

@export_group("Combo")
@export var finisher_mult := 1.5               # damage, sakti and duration of hit 3
@export var soft_snap_angle := 30.0

@export_group("Weapons (numbers live in data/items)")
@export var melee_finisher_reach_mult := 1.5   # forward thrust

@export_group("Stats and passives (rpg.md 2, classes.md)")
@export var stat_hp_base := 80                 # + 10 per Vitality
@export var stat_hp_per := 10
@export var stat_stamina_base := 80.0          # + 6 per Endurance
@export var stat_stamina_per := 6.0
@export var stat_damage_per := 0.05            # Str (melee), Dex (ranged, staff), Spi (spells)
@export var stat_speed_per := 0.01             # attack speed per Dex, stamina regen per End
@export var stat_sakti_per := 0.02             # sakti gain per Spi
@export var rogue_dodge_cost := 14.0
@export var backstab_mult := 2.0
@export var backstab_angle := 60.0             # degrees around the enemy's back
@export var eagle_range := 120.0
@export var eagle_mult := 1.15
@export var keen_mind_max := 120.0
@export var keen_mind_gain := 1.2
@export var flask_time := 0.6
@export var flask_base_heal := 0.4
@export var flask_pouch_heal := 0.05

@export_group("Hit feedback")
@export var flash_time := 0.08
@export var hitstop_light := 0.03
@export var hitstop_heavy := 0.08
@export var hitstop_kill := 0.1
@export var hitstop_player_hit := 0.06
@export var shake_heavy := Vector2(2, 0.15)    # (px, seconds)
@export var shake_kill := Vector2(2, 0.2)
@export var shake_player_hit := Vector2(3, 0.2)
@export var enemy_knockback_light := 6.0
@export var enemy_knockback_heavy := 14.0
@export var enemy_knockback_finisher := 24.0

@export_group("Chaser")
@export var chaser_speed := 70.0
@export var chaser_windup := 0.35
@export var chaser_lunge := 16.0
@export var chaser_lunge_time := 0.12          # ASSUMED: how long the lunge movement lasts
@export var chaser_recovery := 0.6
@export var chaser_attack_range := 24.0        # ASSUMED: starts the wind-up inside this distance
@export var enemy_flinch := 0.15
@export var enemy_notice := 160.0
@export var enemy_leash := 320.0
@export var enemy_turn_rate := 360.0           # degrees per second, frozen during wind-up and attack

@export_group("Perfect dodge")
@export var perfect_window := 0.15             # first part of the dodge (combat.md 2.5)
@export var perfect_sakti := 10.0
@export var perfect_pause := 0.05
@export var perfect_cooldown := 1.0

@export_group("Poise")
@export var poise_refill := 3.0                # full refill this long after the last hit
@export var poise_finisher_mult := 2.0
@export var poise_immunity := 5.0              # no second break this long after a break
@export var tank_stagger := 1.5

@export_group("Tank")
@export var tank_speed := 40.0
@export var tank_windup := 0.6
@export var tank_lunge := 4.0                  # ASSUMED: a small step into the swing
@export var tank_lunge_time := 0.15            # ASSUMED
@export var tank_recovery := 0.8
@export var tank_attack_range := 28.0
@export var tank_turn_rate := 180.0
@export var tank_arc := 150.0
@export var tank_reach := 28.0

@export_group("Shooter")
@export var shooter_speed := 50.0
@export var shooter_near := 100.0              # keeps between near and far
@export var shooter_far := 160.0
@export var shooter_windup := 0.5
@export var shooter_recovery := 1.5
@export var shot_speed := 110.0
@export var shot_range := 240.0                # ASSUMED

@export_group("Charger (Wild Boar)")
@export var charger_speed := 60.0              # approach
@export var charger_attack_range := 110.0      # TUNE: starts the telegraph inside this distance
@export var charger_windup := 0.6              # TUNE: line marker shown, no turning
@export var charger_dash_speed := 200.0        # TUNE
@export var charger_dash_max := 160.0          # TUNE: dash length when nothing blocks it
@export var charger_recovery := 0.8            # TUNE: punishable
@export var charger_wall_stun := 0.8           # TUNE: self-stun on a wall hit

@export_group("Kuntilanak (shooter variant, shriek cone)")
@export var kuntilanak_speed := 50.0
@export var kuntilanak_near := 40.0            # TUNE: short cone, so she keeps a close band
@export var kuntilanak_far := 60.0
@export var kuntilanak_windup := 0.7           # TUNE: the Bolt window
@export var kuntilanak_recovery := 1.5
@export var kuntilanak_arc := 70.0             # TUNE
@export var kuntilanak_reach := 72.0           # TUNE
@export var kuntilanak_shriek_time := 0.15     # TUNE: how long the cone hits

@export_group("Glyph weaknesses (bestiary.md)")
@export var weak_ground_time := 2.0            # Kuntilanak grounded by Bolt in the wind-up
@export var weak_ward_stagger := 1.5           # Wild Boar dashing into Ward
@export var weak_ward_reach := 28.0            # ASSUMED: dash counts as "into the Ward" inside this distance of its centre
@export var weak_bind_poise_mult := 2.0        # Jurig Leuweung while Bound

@export_group("Attack tokens")
@export var tokens_melee := 2
@export var tokens_ranged := 2
@export var token_retry := 0.5
@export var circle_min := 48.0
@export var circle_max := 80.0

@export_group("Statuses")
@export var burn_time := 1.5
@export var burn_share := 0.3                  # of the burning hit, over burn_ticks
@export var burn_ticks := 3
@export var slow_time := 2.0
@export var slow_mult := 0.6                   # -40%
@export var bind_slow_mult := 0.4              # Bind on elites and bosses, -60%
@export var bind_slow_time := 4.0
@export var bound_time := 2.0
@export var curse_time := 4.0
@export var sakti_max := 100.0                 # base; Mage 120 is keen_mind_max

@export_group("Casting")
@export var cast_time_scale := 0.2             # world speed while drawing (spells.md 1)
@export var cast_min_sakti := 15.0             # slow-mo gate (spells.md 9)
@export var cast_lockout := 1.0                # after a cancel or fizzle
@export var cast_draw_limit := 2.5             # real seconds
@export var cast_min_length := 24.0            # ASSUMED: shorter strokes (viewport px) cancel
@export var spell_poise_mult := 1.5            # combat.md 6
