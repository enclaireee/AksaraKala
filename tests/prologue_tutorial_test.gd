extends SceneTree
## Headless test for Prologue Combat & Gameplay Tutorial Scene.

func _initialize() -> void:
	var scn: PackedScene = load("res://zones/prologue_tutorial.tscn")
	assert(scn != null, "prologue_tutorial.tscn should load")
	
	var tut: Node2D = scn.instantiate()
	assert(tut != null, "prologue_tutorial instance should not be null")
	
	root.add_child(tut)
	await process_frame
	
	# Verify essential nodes exist
	assert(tut.get_node_or_null("Tiles") != null, "Tiles node should exist")
	assert(tut.get_node_or_null("Entities/Player") != null, "Player node should exist")
	assert(tut.get_node_or_null("Entities/Semar") != null, "Semar node should exist")
	assert(tut.get_node_or_null("Entities/Cepot") != null, "Cepot node should exist")
	assert(tut.get_node_or_null("Entities/Dummy") != null, "Dummy node should exist")
	assert(tut.get_node_or_null("ExitGate") != null, "ExitGate node should exist")
	assert(tut.get_node_or_null("GateBarrier") != null, "GateBarrier node should exist")
	
	var barrier: CollisionShape2D = tut.get_node("GateBarrier/CollisionShape2D")
	assert(not barrier.disabled, "Barrier should initially be solid/blocking")
	
	# Start intro directly for test
	tut._start_intro()
	assert(tut._waiting_dialogue == "intro", "Waiting dialogue should be intro")
	
	# Test choice 0 (Practice)
	tut._on_dialogue_picked(0)
	assert(tut._stage == tut.Stage.DODGE, "Stage should advance to DODGE after choosing practice")
	
	# Test Dodge completion
	tut._on_player_dodged()
	assert(tut._stage == tut.Stage.ATTACK, "Stage should advance to ATTACK after dodge")
	
	# Test Attack hits
	tut._on_player_struck(1)
	assert(tut._hits == 1, "First strike counted")
	tut._on_player_struck(2)
	assert(tut._hits == 2, "Second strike counted")
	tut._on_player_struck(3)
	assert(tut._stage == tut.Stage.JAMU, "Stage should advance to JAMU after 3 strikes")
	
	# Test Jamu drink
	tut._on_player_drank()
	assert(tut._stage == tut.Stage.COMPLETE, "Stage should advance to COMPLETE after drinking jamu")
	assert(barrier.disabled, "Barrier should be disabled once tutorial is complete")
	
	tut.queue_free()
	print("prologue_tutorial_test passed!")
	quit(0)
