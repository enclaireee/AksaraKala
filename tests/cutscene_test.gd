extends SceneTree
## Cutscene staging: every speaker and #cam target in a beat or talk must stand in the scene within
## SceneDirector.MAX_SPEAKER_DIST of the hero (or be an allowlisted off-screen voice, scene_director.gd AUDIT_VOICES).
## Runs each play test in a child Godot with BEAT_AUDIT=1 and fails on every BEATAUDIT line it prints.
## By hand: BEAT_AUDIT=1 $GODOT --headless --path . -s tests/<name>_test.gd 2>&1 | grep BEATAUDIT

const TESTS := ["prologue", "galuh_play", "mataram_play", "timur_play", "kidul_play", "kala_play", "quest_reach", "story_beat"]


func _initialize() -> void:
	OS.set_environment("BEAT_AUDIT", "1")   # inherited by the children
	var fails := 0
	for t in TESTS:
		var out: Array = []
		OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "-s", "tests/%s_test.gd" % t], out, true)
		for l in "\n".join(PackedStringArray(out)).split("\n"):
			if l.begins_with("BEATAUDIT"):
				printerr("FAIL %s: %s" % [t, l])
				fails += 1
	quit(1 if fails > 0 else 0)
