extends SceneTree
## Accessibility, comfort, and assist settings (controls.md 6, balance.md 9).

const TitleScript := preload("res://ui/title.gd")
const TEST_CFG := "user://settings_test_tmp.cfg"

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_CFG))
	GameSettings.apply_input()
	quit(1 if fails > 0 else 0)


func run() -> void:
	var orig := TitleScript.settings_path
	TitleScript.settings_path = TEST_CFG
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_CFG))

	# Defaults
	check(GameSettings.screenshake() == 100, "default screenshake 100")
	check(not GameSettings.reduce_flashes(), "default reduce_flashes false")
	check(GameSettings.damage_numbers(), "default damage_numbers true")
	check(GameSettings.cursor_size() == 1, "default cursor_size 1")
	check(not GameSettings.swap_mouse(), "default swap_mouse false")
	check(not GameSettings.toggle_cast(), "default toggle_cast false")
	check(GameSettings.control_preset() == "default", "default preset")
	check(GameSettings.slow_mo_strength() == 20, "default slow_mo 20")
	check(is_equal_approx(GameSettings.draw_time(), 2.5), "default draw_time 2.5")
	check(not GameSettings.guide_always_on(), "default guide_always_on false")
	check(not GameSettings.gentle_combat(), "default gentle_combat false")
	check(not GameSettings.drawing_assist(), "default drawing_assist false")

	# Persistence + clamps
	GameSettings.set_screenshake(40)
	GameSettings.set_reduce_flashes(true)
	GameSettings.set_damage_numbers(false)
	GameSettings.set_cursor_size(2)
	GameSettings.set_toggle_cast(true)
	GameSettings.set_slow_mo_strength(35)
	GameSettings.set_draw_time(4.0)
	GameSettings.set_guide_always_on(true)
	GameSettings.set_gentle_combat(true)
	GameSettings.set_drawing_assist(true)
	check(GameSettings.screenshake() == 40, "saved screenshake 40")
	check(GameSettings.reduce_flashes(), "saved reduce_flashes")
	check(not GameSettings.damage_numbers(), "saved damage_numbers false")
	check(GameSettings.cursor_size() == 2, "saved cursor_size 2")
	check(GameSettings.toggle_cast(), "saved toggle_cast")
	check(GameSettings.slow_mo_strength() == 35, "saved slow_mo 35")
	check(is_equal_approx(GameSettings.draw_time(), 4.0), "saved draw_time 4.0")
	check(GameSettings.guide_always_on(), "saved guide_always_on")
	check(GameSettings.gentle_combat(), "saved gentle_combat")
	check(GameSettings.drawing_assist(), "saved drawing_assist")

	# InputMap swap_mouse + left_handed preset
	GameSettings.set_swap_mouse(true)
	var cast_ev := InputMap.action_get_events("cast")
	var atk_ev := InputMap.action_get_events("attack")
	check(cast_ev.size() == 1 and (cast_ev[0] as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT, "swap_mouse cast=left")
	check(atk_ev.size() == 1 and (atk_ev[0] as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT, "swap_mouse attack=right")

	GameSettings.set_control_preset("left_handed")
	var dodge_ev := InputMap.action_get_events("dodge")
	check(dodge_ev.size() == 1 and (dodge_ev[0] as InputEventKey).physical_keycode == KEY_CTRL, "left_handed dodge=Ctrl")

	# Gentle combat halves player damage + Drawing assist lowers CastController smudge threshold by 0.10
	var p: Player = (load("res://entities/player/player.tscn") as PackedScene).instantiate()
	root.add_child(p)
	await process_frame
	var start_hp := p.health.hp
	p.health.take_damage(20)
	check(p.health.hp == start_hp - 10, "gentle_combat halves 20 -> 10 (got %d)" % (start_hp - p.health.hp))
	GameSettings.set_gentle_combat(false)
	p.health.take_damage(20)
	check(p.health.hp == start_hp - 30, "normal combat full 20 (got %d)" % (start_hp - p.health.hp))

	GameSettings.set_drawing_assist(false)
	var base_th := p.cast.smudge_threshold()
	GameSettings.set_drawing_assist(true)
	var assist_th := p.cast.smudge_threshold()
	check(is_equal_approx(base_th - assist_th, 0.10), "drawing_assist lowers threshold by 0.10")
	p.queue_free()

	TitleScript.settings_path = orig
