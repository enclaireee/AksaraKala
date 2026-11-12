# Tutorial: Teaching the Prologue

How the game organically teaches its core verbs through narrative moments. The Prologue (`MQ0`) is the classroom: calm, purposeful, with four central characters who introduce each action in context. Every verb taught here is essential for the night raid and subsequent journeys through the regions.

Related: [controls.md](controls.md) (input reference), [combat.md](combat.md) (combat timing), [quests.md](quests.md) (`MQ0` steps).

---

## 1. Principles

1. **One Verb per Moment:** A lesson teaches a single input. Teaching two verbs at once feels like a manual rather than a game.
2. **Motivated by Story:** Every lesson is grounded in character interaction:
   - Laras challenges you to tag -> teaches movement and dodging.
   - Cepot shows off at the sanggar -> teaches attacks and combo chaining.
   - Ibu sets out tea and packs your bag -> teaches Petilasan resting and jamu healing.
   - Semar interprets the broken lontar -> teaches drawing and casting aksara.
3. **Learn by Doing:** A lesson completes when the player performs the specified input (`Events.player_struck`, `spell_cast`, `petilasan_activated`, etc.). There is no passive "OK" button.
4. **Never Block:** Gameplay is never paused or frozen. A lesson waits quietly until the player performs the action.
5. **Quiet Visual Voice:** Lessons appear as a single ink pill at the bottom of the screen (`Y = 224`), using the same `UIFx` typography as interact prompts and HUD elements.
6. **Persistence:** Completing a lesson sets `tut_<id>` in `Game.flags`, ensuring returning players or completed lessons never repeat.

---

## 2. The In-Story Ladder

| # | Lesson | Step & Timing | Motivator | Completion Trigger | Core Concept Taught |
|---|---|---|---|---|---|
| 1 | `dodge` | Step 0.1 (Village tag) | Laras (`beat:tag_cat`) | First successful dodge roll | WASD movement, `dodge` (Space) to slip past obstacles, stamina cost. |
| 2 | `attack` | Step 0.5 (Sanggar) | Cepot (`DLG_CEPOT_T1/T2`) | 3 landed attacks | `attack` (LMB), holding LMB for the 3-hit combo, stamina management. |
| 3 | `rest` | Step 0.10 (Morning) | Ibu (`DLG_IBU_T1/T2`) | `petilasan_activated` | `interact` (E) at a Petilasan: checkpointing, saving, stat upgrades. |
| 4 | `cast` | Step 0.11 (Sanggar) | Semar (`DLG_SEMAR_T1`) | First `spell_cast` | Hold `cast` (RMB) to slow time, draw aksara with mouse, release to cast. |
| 5 | `flask` | First time player HP drops | Ibu's Jamu line (0.10+) | First jamu drink | `heal_jamu` (Q), drinking a flask charge to restore HP. |
| 6 | `perfect` | First hurt after flask | Combat situation | First perfect dodge | Timing a roll into an incoming blow refunds stamina and generates sakti. |

*Note:* Step 0.6 (writing names on the lontar leaf) and Step 0.8 (`K0` wayang ruwatan) are self-teaching cinematic sequences managed by `ui/glyph_lesson.gd` and `zones/kelir/k0_ruwatan.gd`.

---

## 3. Lesson Triggers & Data (`data/lessons.gd`)

Lessons are defined as data entries in `data/lessons.gd`:

```gdscript
const LESSONS := {
    "dodge": {
        "text": "UI_TUT_DODGE",
        "key": "dodge",
        "when": "step:mq0=0",
        "on": "talk",
        "steps": [{"event": "dodged", "n": 1}],
    },
    ...
}
```

### Trigger Types (`on`)
- **`on: "talk"` or `"beat"`:** An NPC dialogue entry or story beat executes the dialogue action `lesson:<id>` (e.g. `do: ["lesson:attack"]`). `Game` emits `Events.lesson_offered`, and `ui/tutorial.gd` displays the card if its `when` condition holds.
- **`on: "hurt"`:** Automatically triggered from `Events.player_hurt` when player HP is below `hp_below`. `flask` triggers if a charge is available; `perfect` triggers once `tut_flask` is already completed, preventing overlapping cards.

### Condition Gating (`when`)
Lessons use flag windows (e.g., `when: "flag:mq0_d4,!flag:mq0_d7"`) so that a lesson card remains active across dialogue transitions until the required action is performed.

---

## 4. UI Presentation (`ui/tutorial.gd`)

- **Placement:** Bottom-center (`Y = 224`), 15 px height ink panel pill.
- **Layout:** Displays an input keycap showing the live action binding, followed by localized body text (`data/text/ui.csv`), and a counter `(n/m)` for multi-hit lessons (such as the 3-hit combo).
- **Behavior:** Fades in over 0.16 s. On completion, holds for 0.55 s and fades out. Completely ignores mouse clicks (`mouse_filter = Control.MOUSE_FILTER_IGNORE`).
- **Suppression:** The pill automatically hides during dialogue, menu screens, write cards, and player death.

---

## 5. Verification & Testing

- `$GODOT --headless --path . -s tests/tutorial_test.gd` — Verifies that all lesson keys resolve, `when` gates function, multi-strike counts complete lessons, completed lessons never repeat, and dialogue hides active pills.
- `python3 tools/quest_audit.py` — Confirms tutorial dialogue actions and text key presence across both languages.
