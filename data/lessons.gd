class_name Lessons
## Pelajaran Desa Purwa — Prologue tutorial registry (`.docs/tutorial.md`).
##
## Every lesson teaches one core loop in story context and completes on real player action:
##   title     : short caps header key in ui.csv
##   text      : 1-line instruction key in ui.csv ({move} {attack} {cast} {dodge} {interact} {heal_jamu} {menu} {map})
##   key       : InputMap action for keycap badge ("" = none or uses icon instead)
##   icon      : optional sprite cue ("mouse_lmb" | "mouse_rmb" | "wasd" | "")
##   spotlight : optional HUD spotlight target ("st" | "sk" | "hp" | "flask" | "menu" | "")
##   when      : Game.check condition the lesson lives in; "" = anywhere
##   on        : "auto" | "zone" | "talk" | "windup" | "hurt"
##   steps     : [{event, n, combo_finisher?}] — player actions that complete the lesson
##   hp_below / needs_flask: extra gates for "hurt" lessons
##   slow_mo   : optional [time_scale, real_seconds] brief tactical slow-mo on first trigger
##   ttl       : optional seconds before going quiet (stays unfinished so it can return)

## Tutorial events -> Events signal names wired by ui/tutorial.gd.
const EVENT := {
	"move_interact": "talked_to",       # also satisfied by clue_examined once moved
	"struck": "player_struck",          # weapon blow landed (combo 0..2)
	"combo": "player_struck",           # true 3-hit combo finisher (combo == 2)
	"dummy": "enemy_killed",            # straw dummy knocked down
	"dodged": "player_dodged",          # any dodge roll
	"perfect": "perfect_dodge",         # dodge through an incoming blow
	"cast": "spell_cast",               # live Sakti-funded glyph cast
	"rest": "petilasan_activated",      # rested at a shrine
	"drink": "player_drank",            # drank a jamu charge
	"menu": "menu_opened",              # opened field book or map
}

## Auto-offered when wounded, in order.
const ON_HURT := ["flask"]

## Auto-offered when a melee enemy winds up near the player.
const ON_WINDUP := ["perfect"]

## Per-class Sanggar trait spotlight shown by Cepot after the 3-hit combo (tutorial.md 3).
const CLASS_TIPS := {
	"warrior": "UI_TUT_CLASS_WARRIOR",
	"lancer": "UI_TUT_CLASS_LANCER",
	"archer": "UI_TUT_CLASS_ARCHER",
	"herder": "UI_TUT_CLASS_HERDER",
	"rogue": "UI_TUT_CLASS_ROGUE",
	"dancer": "UI_TUT_CLASS_DANCER",
	"mage": "UI_TUT_CLASS_MAGE",
	"dalang": "UI_TUT_CLASS_DALANG",
}

const LESSONS := {
	"move": {
		"title": "UI_TUT_MOVE_TITLE",
		"text": "UI_TUT_MOVE",
		"key": "interact",
		"icon": "wasd",
		"spotlight": "",
		"when": "step:mq0=0",
		"on": "auto",
		"steps": [{"event": "move_interact", "n": 1}],
	},
	"dodge": {
		"title": "UI_TUT_DODGE_TITLE",
		"text": "UI_TUT_DODGE",
		"key": "dodge",
		"icon": "",
		"spotlight": "st",
		"when": "!flag:mq0_d2",
		"on": "zone",
		"steps": [{"event": "dodged", "n": 1}],
	},
	"menu": {
		"title": "UI_TUT_MENU_TITLE",
		"text": "UI_TUT_MENU",
		"key": "menu",
		"icon": "",
		"spotlight": "menu",
		"when": "flag:mq0_d1,!flag:mq0_d4",
		"on": "zone",
		"steps": [{"event": "menu", "n": 1}],
		"ttl": 22.0,
	},
	"combo": {
		"title": "UI_TUT_COMBO_TITLE",
		"text": "UI_TUT_COMBO",
		"key": "",
		"icon": "mouse_lmb",
		"spotlight": "st",
		"when": "flag:mq0_d4,!flag:mq0_d5",
		"on": "talk",
		"steps": [
			{"event": "combo", "n": 1},
			{"event": "dummy", "n": 1},
		],
	},
	"cast": {
		"title": "UI_TUT_CAST_TITLE",
		"text": "UI_TUT_SAKTI_CAST",
		"key": "",
		"icon": "mouse_rmb",
		"spotlight": "sk",
		"when": "glyph:sunda_ka,!flag:mq0_7",
		"on": "zone",
		"steps": [{"event": "cast", "n": 1}],
	},
	"perfect": {
		"title": "UI_TUT_PERFECT_TITLE",
		"text": "UI_TUT_PERFECT",
		"key": "dodge",
		"icon": "",
		"spotlight": "st",
		"when": "flag:mq0_5",
		"on": "windup",
		"slow_mo": [0.22, 1.4],
		"steps": [{"event": "perfect", "n": 1}],
		"fallback_dodges": 2,
		"ttl": 16.0,
	},
	"flask": {
		"title": "UI_TUT_FLASK_TITLE",
		"text": "UI_TUT_FLASK",
		"key": "heal_jamu",
		"icon": "",
		"spotlight": "flask",
		"when": "",
		"on": "hurt",
		"hp_below": 0.75,
		"needs_flask": true,
		"slow_mo": [0.30, 1.1],
		"steps": [{"event": "drink", "n": 1}],
		"ttl": 14.0,
	},
	"rest": {
		"title": "UI_TUT_REST_TITLE",
		"text": "UI_TUT_REST",
		"key": "interact",
		"icon": "",
		"spotlight": "",
		"when": "flag:mq0_7",
		"on": "zone",
		"steps": [{"event": "rest", "n": 1}],
	},
}


static func by_id(id: String) -> Dictionary:
	return LESSONS.get(id, {})


static func ids() -> Array:
	return LESSONS.keys()


static func class_tip_key(class_id: String) -> String:
	return CLASS_TIPS.get(class_id, "UI_TUT_CLASS_WARRIOR")


## The Game flag that keeps a finished lesson from ever coming back.
static func flag(id: String) -> String:
	return "tut_" + id
