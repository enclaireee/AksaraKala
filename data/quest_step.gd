class_name QuestStep extends Resource
## One quest step (quests.md 7.1). `on` is "<signal>:<arg>", or "<signal>" alone to match any arg.

@export var objective := ""   # translation key, e.g. Q_SQ_S4_S1
@export var on := ""          # e.g. "enemy_killed:wild_boar"
@export var count := 1
@export var alt := {}         # two-way step: {"enemy_killed:wewe_elite": "fight", "talked_to:x": "peaceful"}; any key completes it
@export var marker := {}      # {zone, id}
@export var set_flag := ""
## Several triggers, any order: [{"on": "area_cleared:x", "set_flag": "lead_x", "objective": "Q_MQ2_S3_A"}, ...].
## Each sets its own flag and bit i of Game.quests[id].all; the step completes, setting `set_flag`, when all are
## done. `on` stays empty. `objective` is the journal line struck through (the journal does not read it yet).
@export var all: Array = []
