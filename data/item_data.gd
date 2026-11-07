class_name ItemData extends Resource
## One item (items.md). File: data/items/<id>.tres. Weapons fill the attack fields; armor fills defense;
## accessories fill bonus. A field an item does not use keeps its default.

@export var id := ""
@export var title := ""
@export_enum("weapon", "armor", "accessory") var slot := "weapon"
@export_enum("light", "heavy", "ranged", "staff") var archetype := "light"
@export var mythic := false              # pusaka: gold name and a lore line (items.md 1)
@export_multiline var description := ""
@export_multiline var lore := ""         # mythic only
@export var icon: Texture2D              # 16x16, assets/art/items/<id>.png (tools/gen_items.py)

@export_group("Weapon")
@export var damage := 10
@export var cost := 10.0                 # stamina per swing or shot
@export var windup := 0.08
@export var active := 0.07               # melee only
@export var recovery := 0.20
@export var reach := 20.0                # melee px
@export var arc := 90.0                  # melee degrees
@export var lunge := 10.0                # melee px
@export var projectile_speed := 300.0    # ranged and staff
@export var projectile_range := 220.0
@export var sakti_per_hit := 4.0         # heavy 10 (rpg.md 4)
@export var self_damage := 0             # HP the wielder loses per landed hit, never lethal (Keris Mpu Gandring)

@export_group("Armor and accessory")
@export var defense := 0                 # 5% less damage per point (rpg.md 5)
## Keys: vit, end, str, dex, spi (stat points) and max_hp, move_speed, stamina_regen (flat or fraction).
@export var bonus := {}


func is_melee() -> bool:
	return archetype == "light" or archetype == "heavy"


static func by_id(item_id: String) -> ItemData:
	var path := "res://data/items/%s.tres" % item_id
	return load(path) if item_id != "" and ResourceLoader.exists(path) else null
