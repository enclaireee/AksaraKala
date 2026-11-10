# Tutorial: teaching the prologue

How the game teaches its own verbs. The prologue (MQ0) is the classroom: it is calm, it has four characters who
already want things from you, and every verb it teaches is needed again in the raid and in Act I. [controls.md](controls.md)
is the reference; this document is the *teaching order*.

## 1. Why this exists (2026-11-10)

The prologue only explained itself through `Q_MQ0_Sn_HINT` toasts: one line of text at the top of the screen when a step
starts. That covered movement and `interact`, but nothing taught the 3-hit combo, stamina, the flask, the petilasan, the
perfect dodge, or the cast controls. The first real fight (step 0.12) arrived with the player knowing none of it.

### 1b. Follow-up (2026-11-10): the ladder had no rungs

The first fix was a separate Semar practice room in front of the story, which taught dodge, attack and jamu a second time. The ladder
itself never ran: no dialogue entry ran `lesson:<id>` and the six `UI_TUT_*` texts did not exist, so a lesson card could never appear
(and the hurt lessons showed a raw key). Now: the practice room is deleted and `Zones.start_new_game()` always lands in Desa Purwa; the
lessons are offered by the characters (Laras beat `tag_cat` with `BEAT_TAG_CAT_8`, Cepot after Semar with `DLG_CEPOT_T1/T2`, Ibu with
`DLG_IBU_T1/T2`, Semar's Ka entry with `DLG_SEMAR_T1`); `when` is a window of flags (`flag:mq0_d4,!flag:mq0_d7` and so on) so a card does
not vanish the moment the talk that offered it ends the step. `tests/tutorial_test.gd` and `tools/quest_audit.py` (Q8) guard both holes.

## 2. Principles

1. **One verb per moment.** A lesson teaches a single input. Two at once is a manual, not a game.
2. **The story says why first.** Every lesson is motivated by the character in front of you: Laras races you, Cepot is
   showing off, Ibu is packing your bag, Semar hands you a glyph. The card names the buttons; the dialogue names the reason.
3. **Learn by doing, not by reading.** A lesson ends when the player performs the input (`Events.player_struck`,
   `spell_cast`, `petilasan_activated`…). There is no "OK" button.
4. **Never block.** No pause, no dimming, no failed state. A lesson that is not finished simply stays quiet and waits.
5. **Say it once.** Finishing a lesson sets `tut_<id>`, which is saved with the rest of `Game.flags`. Returning players
   never see a card they already know, and a lesson only shows while its `when` condition holds.
6. **Quiet voice.** The card is one ink pill at the bottom of the screen in `UIFx` type, the same vocabulary as the
   interact prompt and the HUD toast. It hides during dialogue, the menu, a write card and death.

## 3. The ladder

| # | Lesson | When (step) | Told by | Completes on | Teaches |
|---|--------|-------------|---------|--------------|---------|
| 1 | `dodge` | 0.1 tag | Laras (beat `tag_cat`) | first dodge | WASD to run, `dodge` to slip past obstacles, stamina cost |
| 2 | `attack` | 0.5 sanggar | Cepot | 3 landed blows | `attack`, holding for the 3-hit combo, stamina |
| 3 | `rest` | 0.10 morning | Ibu | `petilasan_activated` | `interact` at a petilasan: save, respawn point, one stat |
| 4 | `cast` | 0.11 sanggar | Semar | first `spell_cast` | hold `cast`, draw the glyph, release; the sakti gate |
| 5 | `flask` | first time hurt | Ibu's jamu line (0.10) | first drink | `heal_jamu`, three charges, only when hurt |
| 6 | `perfect` | first hurt after the flask | — (combat) | first perfect dodge | rolling *into* a blow refunds stamina and fills sakti |

Order is fixed by the story: dodge before the raid, attack before the Ka lesson uses the same dummies, rest before the
first fight after the raid, cast when the glyph exists, flask and perfect dodge at the first real danger.

Steps 0.6 (write card) and 0.8 (Kelir memory) already teach themselves (`ui/glyph_lesson.gd`, the memory's own hint).

## 4. How a lesson is offered

* **`on: "talk"` / `"beat"`** — the NPC entry or beat runs the dialogue action `lesson:<id>` (an entry `do` in
  `data/dialogue/<npc>.tres`, or a `; do` in the beat heading in [script.md](script.md)). `Game.run` emits
  `Events.lesson_offered`, and `ui/tutorial.gd` picks it up when `when` holds.
* **`on: "hurt"`** — auto: `ui/tutorial.gd` offers it from `Events.player_hurt` when HP is under `hp_below`
  (`flask` also needs a charge left). `perfect` waits for `!flag:tut_flask`, so the two never stack.

## 5. The card (`ui/tutorial.gd`)

Bottom centre, `Y = 224`, a 15 px `ink_panel` pill: a `keycap` with the action's key, then one body line from
`data/text/ui.csv`, then `n/m` in the same parenthesis style as the quest tracker when a lesson needs more than one hit.
It fades in over 0.16 s, and on completion it holds 0.55 s and fades out. It is `mouse_filter = ignore`.

`UIFx` only: body 8, no other sizes, no new art. Text must fit one line (about 44 characters).

## 6. Data (`data/lessons.gd`)

| Field | Meaning |
|-------|---------|
| `text` | `ui.csv` key; `{attack}`, `{dodge}`, `{move}`, `{cast}`, `{interact}`, `{heal_jamu}` are filled with the live keys |
| `key` | InputMap action whose keycap sits at the left (`""` for no keycap) |
| `when` | `Game.check` condition the lesson lives in; `""` = anywhere |
| `on` | `"talk"` / `"beat"` / `"hurt"` (section 4) |
| `steps` | `[{event, n}]`; event is `struck`, `dodged`, `perfect`, `cast`, `rest` or `drink` |
| `hp_below` | auto lessons: only offer under this HP fraction |
| `needs_flask` | auto lessons: only offer with a charge left |
| `ttl` | seconds before the pill goes quiet again (the lesson stays unfinished and returns on the next `hurt`) |

Adding a lesson: add a row to `LESSONS`, its `UI_TUT_*` key to `data/text/ui.csv` (id and en), a `lesson:<id>` in the
entry that motivates it, and a line to this document's ladder.

## 7. Verification

* `$GODOT --headless --path . --import`
* `$GODOT --headless --path . -s tests/tutorial_test.gd` — data keys resolve, `when` gates, the three strikes finish
  `attack`, a finished lesson never returns, dialogue hides the pill.
* `$GODOT --headless --path . -s tests/i18n_test.gd` and `key_ref_test.gd` — every key still has id and en.
* Play: New Game → tag (`dodge`), sanggar (`attack`), morning (`rest`, `flask`), Ka (`cast`), the raid (`perfect`).
