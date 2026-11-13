class_name SpellUtil extends RefCounted
## Shared spell scaling: Spirit (player.spell_mult) times the class damage modifier (classes.md).
## Reads the caster loosely so test dummies without these members still work (factor 1.0).

const CLASS_DAMAGE := {"warrior": 0.9, "mage": 1.1, "lancer": 1.0, "herder": 0.95, "dancer": 1.0, "dalang": 1.05}   # classes.md spell modifiers

## A clean cast (recognizer score at or above this) is a Perfect cast: +12% power and a gold flourish (spells.md 7).
const PERFECT_SCORE := 0.92
const PERFECT_BONUS := 1.12

## Element colour per glyph: tints the stroke, the FX sheets and the result label (spells.md 7).
const ELEMENT := {
	"sunda_ka": Color("56B4E9"), "sunda_ga": Color("9FD8F5"), "sunda_nga": Color("7BC96F"), "sunda_ca": Color("F2B84B"),
	"jawa_ha": Color("7EE2A0"), "jawa_na": Color("F26B5B"), "jawa_ca": Color("F5C242"), "jawa_ra": Color("FF9D3C"),
	"jawa_ka": Color("4FD1C5"),
	"sunda_ha": Color("E8C15A"), "sunda_pa": Color("B8E986"), "jawa_pa": Color("B48CF2"), "jawa_wa": Color("8FD3FF"),
	"jawa_ga": Color("D9B36A"), "sunda_ba": Color("A8D672"), "sunda_ta": Color("F27BB0"), "jawa_la": Color("9FA8FF"),
}

# Story v5 Major Choice effects on spells (spells.md "Choice effects on spells"). All TUNE.
const TELL_CIUNG_BURST_RADIUS := 1.10   # choice_tell_ciung: Sunda Ca radius x1.10
const OFFER_MEMORY_OMBAK_COST_CUT := 3.0   # choice_offer_memory: Ombak costs 3 less Sakti
const OFFER_MEMORY_OMBAK_POISE := 1.20     # choice_offer_memory: +20% poise damage in Act VI


static func _game() -> Node:
	var loop := Engine.get_main_loop()
	return (loop as SceneTree).root.get_node_or_null("Game") if loop is SceneTree else null


static func has_flag(f: String) -> bool:
	var g := _game()
	return g != null and g.has_flag(f)


## True in an Act VI area (zone ids start with gk_). Zones.current_zone is "" outside a Zone.
static func in_act6() -> bool:
	var loop := Engine.get_main_loop()
	var z: Node = (loop as SceneTree).root.get_node_or_null("Zones") if loop is SceneTree else null
	return z != null and str(z.get("current_zone")).begins_with("gk_")


## Radius multiplier from choices and gear: Tell Ciung widens Sunda Ca; Blencong widens zones/blasts.
static func radius_mult(spell: SpellData) -> float:
	var m := TELL_CIUNG_BURST_RADIUS if spell.glyph_id == "sunda_ca" and has_flag("choice_tell_ciung") else 1.0
	var g := _game()
	return m * (1.0 + (g.bonus("spell_radius") if g else 0.0))


## Zone/summon duration multiplier from gear (Suling Bambu, Kayon Gapuran).
static func zone_life_mult() -> float:
	var g := _game()
	return 1.0 + (g.bonus("zone_life") if g else 0.0)


## Poise damage multiplier from choices and class: Offer Memory's Ombak in Act VI; Pangangon +25%.
static func poise_mult(spell: SpellData, caster: Node = null) -> float:
	var m := OFFER_MEMORY_OMBAK_POISE if spell.glyph_id == "jawa_ka" and has_flag("choice_offer_memory") and in_act6() else 1.0
	if caster != null and class_id(caster) == "herder":
		m *= 1.25
	return m


## The caster's real class: picks the spell kit (SpellVariants, PathSpells) and the glow.
static func class_id(caster: Node) -> String:
	return str(caster.get("class_id")) if caster.get("class_id") != null else ""


## The caster's school (classes.md "Schools"): only the damage multiplier and the cost rule read this.
static func school(caster: Node) -> String:
	return ClassData.school(class_id(caster))


static func spirit(caster: Node) -> float:
	return caster.spell_mult() if caster.has_method("spell_mult") else 1.0


## Damage multiplier: Spirit x class (second paths use their own rules, not their first-path school).
static func damage(caster: Node) -> float:
	var g := _game()
	return spirit(caster) * CLASS_DAMAGE.get(class_id(caster), 1.0) * (1.0 + (g.bonus("damage_mult") if g else 0.0))


## Gauge cost after class modifiers: Mage x0.9, Rogue x0.7 on Dash-strike, Lancer x0.85 on formations, Dancer x0.85 on dances.
static func cost(caster: Node, spell: SpellData) -> float:
	var c := spell.cost
	if spell.glyph_id == "jawa_ka" and has_flag("choice_offer_memory"):
		c = maxf(0.0, c - OFFER_MEMORY_OMBAK_COST_CUT)
	var loop := Engine.get_main_loop()
	if loop is SceneTree and not (loop as SceneTree).get_nodes_in_group("focus").is_empty():
		c *= 0.75   # Wiku's Fokus Batin (Jawa Ca)
	if loop is SceneTree and not (loop as SceneTree).get_nodes_in_group("kayon").is_empty():
		c *= 0.5   # Dalang's Tancep Kayon
	match class_id(caster):
		"mage": c *= 0.9
		"rogue": c *= 0.7 if spell.glyph_id == "jawa_na" else 1.0
		"lancer": c *= 0.85 if spell.glyph_id in ["sunda_nga", "jawa_ca"] else 1.0
		"dancer": c *= 0.85 if spell.glyph_id in ["jawa_na", "jawa_ka", "sunda_ta"] else 1.0
	return c


## Multiplier for a Perfect cast (CastController sets `perfect` on the spell; every spell applies this to its power).
static func perfect_mult(perfect: bool) -> float:
	return PERFECT_BONUS if perfect else 1.0


## Glyph element colour, nudged toward the class glow so each class reads a little different.
static func tint(glyph_id: String, caster: Node) -> Color:
	var c: Color = ELEMENT.get(glyph_id, Color.WHITE)
	var glow: Array = AttackFX.TINTS.get(class_id(caster), AttackFX.TINTS[""])
	return c.lerp(glow[2], 0.18)


## Translation with a fallback, for strings whose keys are not in the compiled translation yet.
static func tr_or(key: String, fallback: String) -> String:
	var s := TranslationServer.translate(key)
	return fallback if s == key or s == "" else str(s)


## A throwaway SpellData for echo effects (ward pulse, dash blast, rogue echo). Not a file; never saved.
static func sub_data(glyph_id: String, power: float, radius := 0.0, scene: PackedScene = null) -> SpellData:
	var d := SpellData.new()
	d.glyph_id = glyph_id
	d.power = power
	d.radius = radius
	d.scene = scene
	return d


## Enemies inside `radius` of `pos`. Loose: test dummies and bosses both sit in the "enemy" group.
static func enemies_near(tree: SceneTree, pos: Vector2, radius: float) -> Array:
	var out := []
	for e in tree.get_nodes_in_group("enemy"):
		if e is Node2D and (e as Node2D).global_position.distance_to(pos) <= radius:
			out.append(e)
	return out


## Nearest enemy within `max_dist`, optionally only inside a cone (`half_angle` radians around `dir`).
static func nearest_enemy(tree: SceneTree, pos: Vector2, max_dist: float, dir := Vector2.ZERO, half_angle := PI) -> Node2D:
	var best: Node2D = null
	var best_d := max_dist
	for e in tree.get_nodes_in_group("enemy"):
		if not e is Node2D:
			continue
		var to: Vector2 = (e as Node2D).global_position - pos
		var d := to.length()
		if d < best_d and (dir == Vector2.ZERO or absf(dir.angle_to(to)) <= half_angle):
			best = e
			best_d = d
	return best


## Burn an enemy for a share of `amount` (Status turns it into ticks). Does nothing for things without a Status.
static func burn(e: Node, amount: float) -> void:
	if e != null and e.get("status") != null:
		e.status.apply(Status.Type.BURN, -1.0, amount)


## Slow an enemy. Does nothing for things without a Status.
static func slow(e: Node, seconds: float, mult: float) -> void:
	if e != null and e.get("status") != null:
		e.status.apply(Status.Type.SLOW, seconds, mult)


## Direct spell damage that skips i-frames, like a burn tick. Does nothing for things without Health.
static func strike(e: Node, amount: int) -> void:
	if e != null and e.get("health") != null and amount > 0:
		e.health.take_damage(amount, null, true)
