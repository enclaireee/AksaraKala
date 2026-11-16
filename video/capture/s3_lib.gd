extends "res://video/capture/shot.gd"
## Segment 3 helper: a HUD-less, linear-pan scenic shot with the hero walking through. Shots extend this file.
##
## scenic({
##   demo: int (checkpoint index; omit for a new game), flags: [..] (set after start), zone, spawn,
##   cam: Vector2 (screen centre at the start), vel: Vector2 (camera px/s: whole px per frame at 60 fps, i.e. 30/60/120),
##   secs: 7.0, hero: [Vector2 start, Vector2 end] (optional walk, speed hero_speed 0-1 of 90 px/s),
##   keep_enemies: false, settle: 1.5, hold_pre: 0.0, setup: Callable (called after the zone loads)
## })
## Checks the camera stays inside the map for the whole pan; fails the shot otherwise.

var _p := {}

func config() -> Dictionary:
	return {"music": false, "sfx": true, "ambience": true, "max_seconds": 900}


func scenic(p: Dictionary) -> void:
	_p = p
	if p.has("demo"):
		await start_demo({"index": int(p.demo)})
	else:
		new_game("mage")
	for f: String in p.get("flags", []):
		flag(f)
	if p.has("zone") and (not p.has("demo") or Z.current_zone != p.zone or p.get("reload", false)):
		await go(p.zone, p.get("spawn", ""))
	make_strong(int(p.get("level", 20)))
	god = true
	infinite_sakti = true
	hide_hud()
	hide_cursor()
	if not p.get("keep_enemies", false):
		clear_enemies()
	if p.has("tint"):
		grade(p.tint)
	var secs: float = p.get("secs", 7.0)
	var vel: Vector2 = p.get("vel", Vector2.ZERO)
	var c0: Vector2 = p.cam
	var c1: Vector2 = c0 + vel * secs
	var r := map_rect()
	var half := NATIVE / 2.0
	for c: Vector2 in [c0, c1]:
		if c.x - half.x < r.position.x - 0.5 or c.x + half.x > r.end.x + 0.5 or c.y - half.y < r.position.y - 0.5 or c.y + half.y > r.end.y + 0.5:
			fail("camera %s leaves the map %s" % [c, r])
			return
	var hp: Array = p.get("hero", [])
	if hp.size() >= 1:
		teleport(hp[0])
		var dir: Vector2 = (hp[hp.size() - 1] - hp[0]).normalized() if hp.size() > 1 else Vector2.DOWN
		aim_at(hero().global_position + dir * 4000.0)
	if p.has("setup"):
		await (p.setup as Callable).call()
	cam_snap = 1.0
	cam_detach(c0)
	await wait_seconds(float(p.get("settle", 1.5)))
	rec_start()
	if hp.size() > 1:
		_walk_bg(hp, float(p.get("hero_speed", 0.667)))
	await cam_pan(c0, c1, secs, "linear")
	rec_stop()
	stop()


func _walk_bg(pts: Array, speed: float) -> void:
	for i in range(1, pts.size()):
		await walk_to(pts[i], speed)
		if failed:
			return
	stop()


## Re-grades the zone's ambient light (the game's CanvasModulate "Mood"). Color(1,1,1) = no change.
func grade(c: Color) -> void:
	var m := zone().get_node_or_null("Mood")
	if m == null:
		print("s3: no Mood node in ", Z.current_zone)
		return
	print("s3: Mood was ", m.color)
	m.color = c
