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
