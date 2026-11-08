class_name SpellUtil extends RefCounted
## Shared spell scaling: Spirit (player.spell_mult) times the class damage modifier (classes.md).
## Reads the caster loosely so test dummies without these members still work (factor 1.0).

const CLASS_DAMAGE := {"warrior": 0.9, "mage": 1.1}   # classes.md spell modifiers

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


## Radius multiplier from choices (not class): Tell Ciung widens Sunda Ca.
static func radius_mult(spell: SpellData) -> float:
	return TELL_CIUNG_BURST_RADIUS if spell.glyph_id == "sunda_ca" and has_flag("choice_tell_ciung") else 1.0


## Poise damage multiplier from choices: Offer Memory's Ombak in Act VI.
static func poise_mult(spell: SpellData) -> float:
	return OFFER_MEMORY_OMBAK_POISE if spell.glyph_id == "jawa_ka" and has_flag("choice_offer_memory") and in_act6() else 1.0


static func class_id(caster: Node) -> String:
	return str(caster.get("class_id")) if caster.get("class_id") != null else ""


static func spirit(caster: Node) -> float:
	return caster.spell_mult() if caster.has_method("spell_mult") else 1.0


## Damage multiplier: Spirit x class.
static func damage(caster: Node) -> float:
	return spirit(caster) * CLASS_DAMAGE.get(class_id(caster), 1.0)


## Gauge cost after class modifiers: Mage x0.9 on everything, Rogue x0.7 on Dash-strike.
static func cost(caster: Node, spell: SpellData) -> float:
	var c := spell.cost
	if spell.glyph_id == "jawa_ka" and has_flag("choice_offer_memory"):
		c = maxf(0.0, c - OFFER_MEMORY_OMBAK_COST_CUT)
	match class_id(caster):
		"mage": c *= 0.9
		"rogue": c *= 0.7 if spell.glyph_id == "jawa_na" else 1.0
	return c
