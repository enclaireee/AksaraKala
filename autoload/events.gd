extends Node
## Global signals (architecture.md 3). Emitters and listeners never reference each other.
## Quest steps match "<signal>:<arg>" on the quest-trigger signals below (quests.md 7.2).

signal enemy_killed(enemy: Node2D, ilmu: int)   # EnemyBase already added the Ilmu; quests read enemy.kind
signal player_died                              # death screen, then Zones.respawn()
signal rested(petilasan: Node2D)                # petilasan activated: menu opens with level-up enabled

# quest triggers
signal talked_to(npc_id: String)                # dialogue box closed after this NPC's entry
signal item_picked(item_id: String)             # chest, pickup or quest item collected
signal boss_defeated(boss_id: String)
signal area_cleared(area_id: String)            # an encounter's last wave died
signal area_entered(trigger_id: String)
signal zone_entered(zone_id: String)
signal petilasan_activated(id: String)
signal glyph_learned(id: String)
signal spell_cast(glyph_id: String, score: float)
signal class_chosen(class_id: String)
signal weakness_triggered(kind: String)         # an enemy reacted to its glyph weakness (bestiary.md)
signal clue_examined(clue_id: String)           # Clue lines done, or the `clue:<id>` action (architecture.md 9b)
signal memory_done(memory_id: String)           # KelirMemory.finish(); flag memory_<id> is already set
signal puzzle_solved(puzzle_id: String)         # environmental puzzle solved (quests.md 7.1)
signal trial_completed(trial_id: String)        # trial / defense completed (quests.md 7.1)

# Kelir memory (architecture.md 9b)
signal memory_started(memory_id: String)        # Zones.enter_memory, before the fade

# outgoing
signal quest_started(id: String)
signal quest_updated(id: String)
signal quest_completed(id: String)

# dialogue box (ui/dialogue_box)
signal dialogue_requested(speaker_key: String, lines: PackedStringArray)
signal dialogue_finished
signal dialogue_choices(keys: PackedStringArray)   # Game.play emits this just before dialogue_requested; the box shows them after the last line
signal dialogue_picked(index: int)                  # the box emits this just before dialogue_finished when choices were shown

# scene direction (docs/quest_story_ux.md 2): a dialogue line "#name" or "#name:arg" is not shown; when the box reaches it
# it emits this. Cues: cam:<npc_id|hero>, bars:on|off, shake:<0-3>, wait:<seconds>. ui/scene_director.gd listens.
signal scene_cue(cue: String, arg: String)
# the `remember:<key>` dialogue action (sets flag remember_<key>); HUD banner "X will remember this", Journal "Choices" page
signal consequence_noted(key: String)

# write mode (ui/glyph_lesson): the player draws these glyphs in order
signal write_requested(seq_id: String, glyphs: PackedStringArray)
signal name_written(seq_id: String)

# tutorial cues (docs/tutorial.md 4): the player's own inputs, listened to by ui/tutorial.gd
signal lesson_offered(id: String)               # a dialogue or beat ran `lesson:<id>`
signal player_struck(combo: int)                # a blow of mine landed (combo index; ranged cycles too)
signal player_dodged                            # any dodge started
signal perfect_dodge                            # a dodge through a blow
signal player_drank                             # a jamu charge was spent
signal player_hurt(hp_ratio: float)             # after a hit lands: hp / max hp
