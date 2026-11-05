class_name SpellUtil extends RefCounted
## Shared spell scaling: Spirit (player.spell_mult) times the class damage modifier (classes.md).
## Reads the caster loosely so test dummies without these members still work (factor 1.0).

const CLASS_DAMAGE := {"warrior": 0.9, "mage": 1.1}   # classes.md spell modifiers


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
	match class_id(caster):
		"mage": c *= 0.9
		"rogue": c *= 0.7 if spell.glyph_id == "jawa_na" else 1.0
	return c
