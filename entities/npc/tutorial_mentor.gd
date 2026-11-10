extends Npc
## Tutorial mentor NPC: intercepts interact() and emits a signal so the tutorial scene script drives the dialogue.

signal talked


func interact() -> void:
	if _busy:
		return
	talked.emit()
