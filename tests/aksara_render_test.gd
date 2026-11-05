extends SceneTree
## Aksara render test (spells.md 10). Headless: asserts shaping, exits 0 on pass.
## With a window (no --headless): also shows the glyphs at 16/24/32 px.
# ponytail: fonts load from macOS system paths; switch to res://assets/fonts/ once the fonts (with OFL.txt) are copied in.

const JAWA := "/System/Library/Fonts/Supplemental/NotoSansJavanese-Regular.otf"
const SUNDA := "/System/Library/Fonts/Supplemental/NotoSansSundanese-Regular.ttf"
const SIZE := 16

# The 8 MVP glyphs plus the final Jawa Ka.
const SUNDA_GLYPHS := "ᮊᮌᮍᮎ"       # ka ga nga ca
const JAWA_GLYPHS := "ꦲꦤꦕꦫꦏ"      # ha na ca ra ka

var fails := 0


func _initialize() -> void:
	var ts := TextServerManager.get_primary_interface()
	check(ts.has_feature(TextServer.FEATURE_SHAPING), "text server '%s' has no shaping (fallback server?)" % ts.get_name())

	var jawa := load_font(JAWA)
	var sunda := load_font(SUNDA)
	if jawa and sunda:
		for c in SUNDA_GLYPHS:
			check(cmap(sunda, c) != 0, "Sunda font missing U+%X" % c.unicode_at(0))
		for c in JAWA_GLYPHS:
			check(cmap(jawa, c) != 0, "Jawa font missing U+%X" % c.unicode_at(0))
		# Pre-base vowels are typed after the consonant but must be drawn before it.
		check_prebase(jawa, "ꦏ", "ꦺ", "Jawa taling")
		check_prebase(sunda, "ᮊ", "ᮦ", "Sunda panaelaeng")
		# na + pangkon + ka must become na + pasangan ka: plain ka and pangkon glyphs disappear.
		var g := glyph_ids(jawa, "ꦤ꧀ꦏ")
		check(not g.has(cmap(jawa, "ꦏ")) and not g.has(cmap(jawa, "꧀")), "Jawa pasangan not formed: %s" % [g])

	if DisplayServer.get_name() == "headless" or fails > 0:
		quit(1 if fails > 0 else 0)
	elif jawa and sunda:
		show(jawa, sunda)


func load_font(path: String) -> FontFile:
	var f := FontFile.new()
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE  # match the project font setting
	if f.load_dynamic_font(path) != OK:
		check(false, "cannot load " + path)
		return null
	return f


func cmap(font: FontFile, c: String) -> int:
	return TextServerManager.get_primary_interface().font_get_glyph_index(font.get_rids()[0], SIZE, c.unicode_at(0), 0)


func glyph_ids(font: FontFile, text: String) -> Array:
	var line := TextLine.new()
	line.add_string(text, font, SIZE)
	var ids := []
	for g in TextServerManager.get_primary_interface().shaped_text_get_glyphs(line.get_rid()):
		ids.append(g["index"])
	return ids


func check_prebase(font: FontFile, base: String, vowel: String, name: String) -> void:
	var g := glyph_ids(font, base + vowel)
	var v := g.find(cmap(font, vowel))
	var b := g.find(cmap(font, base))
	check(v != -1 and b != -1 and v < b, "%s not reordered before base: %s" % [name, g])


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func show(jawa: FontFile, sunda: FontFile) -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(4, 2)
	root.add_child(box)
	for size in [16, 24, 32]:
		for row in [[sunda, SUNDA_GLYPHS + "  ᮊᮦ ᮊᮥ ᮊᮢ"], [jawa, JAWA_GLYPHS + "  ꦏꦺ ꦏꦺꦴ ꦤ꧀ꦏ"]]:
			var l := Label.new()
			l.text = row[1]
			l.add_theme_font_override("font", row[0])
			l.add_theme_font_size_override("font_size", size)
			box.add_child(l)
