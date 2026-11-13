class_name Dummy extends EnemyBase
## Sanggar training target: never attacks, is never freed, gives no Ilmu. Shows the flash and damage numbers.
## At 0 HP it emits enemy_killed(self, 0) (quests count it), stays down briefly, then refills.

const REFILL := 1.5   # TUNE: seconds down before it can be defeated again
var _down := false


func _ready() -> void:
	super()
	health.damaged.connect(_on_damaged)


## Runs before Health checks for death, so keeping hp above 0 means no died signal (no Ilmu, no free, no Game.killed).
func _on_damaged(_amount: int, _source: Node) -> void:
	if health.hp <= 0:
		health.hp = 1
		if not _down:
			_down = true
			get_node("/root/Events").enemy_killed.emit(self, 0)
			get_tree().create_timer(REFILL).timeout.connect(func() -> void:
				_down = false
				health.hp = health.max_hp
				health.changed.emit(health.hp, health.max_hp))
