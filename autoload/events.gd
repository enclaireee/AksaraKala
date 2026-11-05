extends Node
## Global signals (architecture.md 3). Emitters and listeners never reference each other.

signal enemy_killed(enemy: Node2D, ilmu: int)   # EnemyBase already added the Ilmu; for listeners (codex, quests)
signal player_died                              # death screen, then Zones.respawn()
signal rested(petilasan: Node2D)                # petilasan activated: menu opens with level-up enabled
