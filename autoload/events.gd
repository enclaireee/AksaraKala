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

# outgoing
signal quest_started(id: String)
signal quest_updated(id: String)
signal quest_completed(id: String)

# dialogue box (ui/dialogue_box)
signal dialogue_requested(speaker_key: String, lines: PackedStringArray)
signal dialogue_finished
