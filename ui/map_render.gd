class_name MapRender extends RefCounted
## One pixel per game tile, coloured by tile char. Shared by the HUD minimap and the menu's Peta tab.

const COLORS := {
	".": Color("55703a"), ",": Color("b59a62"), "t": Color("2f5a38"), "_": Color("8a7658"),
	"#": Color("1b1512"), "~": Color("3f7aa0"), "b": Color("5a3f30"), "r": Color("6e6e6e"),
	"[": Color("a0623f"), "-": Color("7c6448"), "'": Color("4a3c30"), "{": Color("2a211c"),
}
const FALLBACK := Color("2a211c")


## The zone's `grid` as an image; null when the node is not a built Zone.
static func image(zone: Node) -> Image:
	if zone == null or not (zone is Zone) or zone.grid.is_empty():
		return null
	var w: int = zone.size.x
	var h: int = zone.size.y
	var img := Image.create(maxi(w, 1), maxi(h, 1), false, Image.FORMAT_RGBA8)
	img.fill(FALLBACK)
	for y in mini(h, zone.grid.size()):
		var row: String = zone.grid[y]
		for x in mini(w, row.length()):
			img.set_pixel(x, y, COLORS.get(row[x], FALLBACK))
	return img


## Zone pixel position -> tile cell as a float point (sub-tile precision for dots).
static func to_tile(p: Vector2) -> Vector2:
	return p / float(Zone.TILE)


## Painted scale: PAINT px per tile in the Peta tab's area map.
const PAINT := 3
## char -> [light, base, dark]: the same tiles as COLORS with a lit and a shaded tone, so the area map reads as pixel art.
const TONES := {
	".": [Color("6E8E4A"), Color("55703a"), Color("46602F")],
	",": [Color("CDB278"), Color("b59a62"), Color("9A8250")],
	"t": [Color("3E7048"), Color("2f5a38"), Color("1F4228")],
	"_": [Color("9C8868"), Color("8a7658"), Color("76644A")],
	"#": [Color("4A3E36"), Color("1b1512"), Color("0E0A08")],
	"~": [Color("6CAACE"), Color("3f7aa0"), Color("336C92")],
	"b": [Color("7A5644"), Color("5a3f30"), Color("40291E")],
	"r": [Color("8A8A8A"), Color("6e6e6e"), Color("565656")],
	"[": [Color("C27A52"), Color("a0623f"), Color("7E4A30")],
	"-": [Color("8E7656"), Color("7c6448"), Color("665038")],
	"'": [Color("5C4A3C"), Color("4a3c30"), Color("3A2E24")],
	"{": [Color("3A2D26"), Color("2a211c"), Color("1E1612")],
}


static func _h(x: int, y: int) -> int:
	var n := (x * 73856093) ^ (y * 19349663)
	n = (n ^ (n >> 13)) * 1274126177
	return (n ^ (n >> 16)) & 0x7FFFFFFF


## The zone as pixel art: PAINT x PAINT px per tile with speckle, a lit rim on walls, foam on shores, a drop shadow
## under walls and buildings. Same grid as image(); null when the node is not a built Zone.
static func painted(zone: Node) -> Image:
	if zone == null or not (zone is Zone) or zone.grid.is_empty():
		return null
	var w: int = zone.size.x
	var h: int = zone.size.y
	var g: Array = zone.grid
	var img := Image.create(maxi(w, 1) * PAINT, maxi(h, 1) * PAINT, false, Image.FORMAT_RGBA8)
	img.fill(FALLBACK)
	for y in mini(h, g.size()):
		var row: String = g[y]
		for x in mini(w, row.length()):
			var c := row[x]
			var tone: Array = TONES.get(c, [FALLBACK, FALLBACK, FALLBACK])
			var hv := _h(x, y)
			var up := _at(g, x, y - 1)
			var dn := _at(g, x, y + 1)
			var lf := _at(g, x - 1, y)
			var rt := _at(g, x + 1, y)
			for oy in PAINT:
				for ox in PAINT:
					img.set_pixel(x * PAINT + ox, y * PAINT + oy, tone[1])
			var spot := Vector2i(hv % PAINT, (hv >> 3) % PAINT)
			match c:
				".", ",", "_", "-":   # speckle: a light and a dark pixel on some tiles
					if hv % 3 == 0:
						img.set_pixel(x * PAINT + spot.x, y * PAINT + spot.y, tone[0])
					elif hv % 5 == 0:
						img.set_pixel(x * PAINT + spot.x, y * PAINT + spot.y, tone[2])
				"t":   # a canopy: lit crown, shaded foot
					img.set_pixel(x * PAINT + 1, y * PAINT, tone[0])
					img.set_pixel(x * PAINT, y * PAINT + 2, tone[2])
					img.set_pixel(x * PAINT + 2, y * PAINT + 2, tone[2])
				"~":   # ripples, foam where land meets water
					var wy := (x + y) % 2
					img.set_pixel(x * PAINT + wy, y * PAINT + 1, tone[0])
					if up != "~" and up != "":
						for ox in PAINT:
							img.set_pixel(x * PAINT + ox, y * PAINT, Color("DCE8F0"))
					if dn != "~" and dn != "":
						for ox in PAINT:
							img.set_pixel(x * PAINT + ox, y * PAINT + 2, tone[2])
				"#", "b", "r", "'", "{":   # a lit rim on the sides facing open ground, a dark foot
					if up != c:
						for ox in PAINT:
							img.set_pixel(x * PAINT + ox, y * PAINT, tone[0])
					if lf != c:
						img.set_pixel(x * PAINT, y * PAINT + 1, tone[0])
					if dn != c:
						for ox in PAINT:
							img.set_pixel(x * PAINT + ox, y * PAINT + 2, tone[2])
					if rt != c:
						img.set_pixel(x * PAINT + 2, y * PAINT + 1, tone[2])
				"[":   # roofs: ridge line
					for ox in PAINT:
						img.set_pixel(x * PAINT + ox, y * PAINT + 1, tone[0])
					img.set_pixel(x * PAINT + 1, y * PAINT + 2, tone[2])
			# a soft shadow on open ground under a wall or building to the north
			if c in [".", ",", "_", "-"] and up in ["#", "b", "[", "r"]:
				for ox in PAINT:
					img.set_pixel(x * PAINT + ox, y * PAINT, tone[2])
	return img


static func _at(g: Array, x: int, y: int) -> String:
	if y < 0 or y >= g.size() or x < 0 or x >= g[y].length():
		return ""
	return g[y][x]
