class_name Snd extends RefCounted
## Static front door to the Audio autoload (autoload/audio.gd). Any script can call Snd.play("hit_light") without a
## node reference, and it is a silent no-op when the autoload is absent (tests that run a bare scene).

static func _audio() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("Audio")


static func play(id: String, vol_db := 0.0, pitch := 1.0, jitter := 0.0) -> void:
	var a := _audio()
	if a != null:
		a.play_sfx(id, vol_db, pitch, jitter)


static func music(id: String, fade := 1.5) -> void:
	var a := _audio()
	if a != null:
		a.play_music(id, fade)


static func jingle(id: String, vol_db := 0.0) -> void:
	var a := _audio()
	if a != null:
		a.play_jingle(id, vol_db)


static func blip(speaker_key: String) -> void:
	var a := _audio()
	if a != null:
		a.blip(speaker_key)


static func ink(speed := 150.0) -> void:
	var a := _audio()
	if a != null:
		a.ink_draw(speed)


static func cast(on: bool) -> void:
	var a := _audio()
	if a != null:
		a.cast_mode(on)


static func step() -> void:
	var a := _audio()
	if a != null:
		a.step()
