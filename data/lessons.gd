class_name Lessons
## Tutorial lessons (`.docs/tutorial.md`): one verb each, offered at the moment the prologue uses it and
## finished by the input itself, so a returning player never reads a card twice.
##
## text  : ui.csv key; {attack} {dodge} {move} {cast} {interact} {heal_jamu} are filled with the live keys
## key   : InputMap action whose keycap sits at the left of the pill ("" = no keycap)
## when  : Game.check condition the lesson lives in; "" = anywhere (the auto lessons)
## on    : "talk" / "beat" = a dialogue or beat ran `lesson:<id>`; "hurt" = the player was hit
## steps : [{event, n}]; event is one of EVENT below, n = how many times it must happen
## hp_below / needs_flask: extra gates for the auto ("hurt") lessons
## ttl   : seconds the pill stays before it goes quiet again; the lesson stays unfinished and returns on the next hurt

## Tutorial events -> the Events signal that feeds them (ui/tutorial.gd wires them).
const EVENT := {
	"struck": "player_struck",      # a blow of mine landed
	"dodged": "player_dodged",      # any dodge
	"perfect": "perfect_dodge",     # a dodge through a blow
	"cast": "spell_cast",           # a glyph was cast
	"rest": "petilasan_activated",  # rested at a shrine
	"drink": "player_drank",        # drank a jamu charge
}

## Lessons auto-offered when the player is hit, in this order.
const ON_HURT := ["flask", "perfect"]

const LESSONS := {
	"dodge": {
		"text": "UI_TUT_DODGE", "key": "dodge", "when": "step:mq0=0", "on": "beat",
		"steps": [{"event": "dodged", "n": 1}],
	},
	"attack": {
		"text": "UI_TUT_ATTACK", "key": "attack", "when": "step:mq0=4", "on": "talk",
		"steps": [{"event": "struck", "n": 3}],
	},
	"rest": {
		"text": "UI_TUT_REST", "key": "interact", "when": "step:mq0=9", "on": "talk",
		"steps": [{"event": "rest", "n": 1}],
	},
	"cast": {
		"text": "UI_TUT_CAST", "key": "cast", "when": "step:mq0=10", "on": "talk",
		"steps": [{"event": "cast", "n": 1}],
	},
	"flask": {
		"text": "UI_TUT_FLASK", "key": "heal_jamu", "when": "", "on": "hurt",
		"hp_below": 0.8, "needs_flask": true,
		"steps": [{"event": "drink", "n": 1}],
	},
	"perfect": {
		"text": "UI_TUT_PERFECT", "key": "dodge", "when": "!flag:tut_flask", "on": "hurt",
		"steps": [{"event": "perfect", "n": 1}], "ttl": 14.0,
	},
}


static func by_id(id: String) -> Dictionary:
	return LESSONS.get(id, {})


static func ids() -> Array:
	return LESSONS.keys()


## The Game flag that keeps a finished lesson from ever coming back.
static func flag(id: String) -> String:
	return "tut_" + id
