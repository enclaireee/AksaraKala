class_name QuestStep extends Resource
## One quest step (quests.md 7.1). `on` is "<signal>:<arg>", or "<signal>" alone to match any arg.

@export var objective := ""   # translation key, e.g. Q_SQ_S4_S1
@export var on := ""          # e.g. "enemy_killed:wild_boar"
@export var count := 1
@export var marker := {}      # {zone, id}
@export var set_flag := ""
