extends SceneTree
## Writes assets/art/sunda_tiles.png: one 16x16 placeholder per zone tile char, in the atlas order
## Zone.LEGEND uses (. , t _ # ~ b r). Run: $GODOT --headless --path . -s tools/gen_sunda_tiles.gd

const S := 16
const OUT := "res://assets/art/sunda_tiles.png"

var rng := RandomNumberGenerator.new()


func _initialize() -> void:
	rng.seed = 7   # same PNG every run
	var img := Image.create(S * 8, S, false, Image.FORMAT_RGBA8)
	var painters := [_grass, _path, _tea, _floor, _wall, _water, _bamboo, _rock]
	for i in painters.size():
		for y in S:
			for x in S:
				var c: Color = painters[i].call(x, y)
				img.set_pixel(i * S + x, y, c)
	var err := img.save_png(ProjectSettings.globalize_path(OUT))
	if err != OK:
		printerr("save failed: %s" % error_string(err))
	quit(0 if err == OK else 1)


func _n(c: Color, amount := 0.04) -> Color:
	var d := rng.randf_range(-amount, amount)
	return Color(c.r + d, c.g + d, c.b + d)


func _grass(x: int, y: int) -> Color:
	if (x * 7 + y * 3) % 23 == 0:
		return Color(0.25, 0.48, 0.2)   # blade
	return _n(Color(0.36, 0.62, 0.28))


func _path(x: int, y: int) -> Color:
	if (x * 5 + y * 11) % 29 == 0:
		return Color(0.6, 0.5, 0.36)   # pebble
	return _n(Color(0.78, 0.66, 0.46), 0.03)


func _tea(x: int, y: int) -> Color:
	var row := y % 8
	if row >= 1 and row <= 5 and (x + (y / 8) * 4) % 8 != 0:
		return _n(Color(0.55, 0.8, 0.4) if row == 1 else Color(0.45, 0.72, 0.34), 0.03)
	return _n(Color(0.42, 0.32, 0.2), 0.03)   # soil between rows


func _floor(x: int, y: int) -> Color:
	if y % 4 == 3 or x == (y / 4 * 5 + 3) % S:
		return Color(0.4, 0.27, 0.16)   # plank seams
	return _n(Color(0.62, 0.44, 0.27), 0.03)


func _wall(x: int, y: int) -> Color:
	if y < 2:
		return Color(0.42, 0.3, 0.2)   # lit top edge
	if (x + y * 2) % 13 == 0:
		return Color(0.18, 0.12, 0.08)   # crack
	return _n(Color(0.3, 0.2, 0.13), 0.03)


func _water(x: int, y: int) -> Color:
	if (y % 6 == 2 and x % 8 < 3) or (y % 6 == 5 and (x + 4) % 8 < 3):
		return Color(0.55, 0.75, 0.95)   # ripple
	return _n(Color(0.2, 0.45, 0.75), 0.02)


func _bamboo(x: int, y: int) -> Color:
	var stalk := x % 5 == 1 or x % 5 == 2
	if stalk:
		if (y + x * 3) % 7 == 0:
			return Color(0.2, 0.4, 0.18)   # node ring
		return Color(0.42, 0.66, 0.32) if x % 5 == 1 else Color(0.34, 0.56, 0.26)
	return _n(Color(0.1, 0.26, 0.13), 0.02)


func _rock(x: int, y: int) -> Color:
	var d := Vector2(x - 7.5, y - 8.5).length()
	if d > 7.5:
		return _n(Color(0.36, 0.62, 0.28))   # grass around the boulder
	if d > 6.5:
		return Color(0.28, 0.28, 0.3)   # outline
	if x < 7 and y < 7:
		return Color(0.7, 0.7, 0.72)   # highlight
	return _n(Color(0.5, 0.5, 0.53), 0.03)
