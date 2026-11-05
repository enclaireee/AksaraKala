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

@export_group("Light melee (keris)")
@export var melee_damage := 10                 # TUNE: 4 hits kill a tier-0 chaser (40 HP) in ~1.4 s
@export var melee_cost := 10.0
@export var melee_windup := 0.08
@export var melee_active := 0.07
@export var melee_recovery := 0.20
@export var melee_lunge := 10.0
@export var melee_arc := 90.0
@export var melee_reach := 20.0
@export var melee_finisher_reach_mult := 1.5   # forward thrust

@export_group("Ranged (busur)")
@export var ranged_damage := 8                 # TUNE
@export var ranged_cost := 4.0
@export var ranged_windup := 0.15
@export var ranged_recovery := 0.30
@export var arrow_speed := 300.0
@export var arrow_range := 220.0               # finisher arrow pierces

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
