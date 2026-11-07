# Quest system v6: research and migration plan

Status: plan written and implemented 2026-11-07 (not run in Godot, see HANDOFF). Replaces the HUD part of
[quests.md](quests.md) 7.5/7.6 and the compass in [ui.md](ui.md) 2. The quest data (`data/quests/*.tres`, 30 quests, 219
steps) and its text are kept as they are: the engine reads the same fields.

## 1. What proper RPGs do (from memory of The Witcher 3, Skyrim, Divinity; not re-checked online)

| Habit | The Witcher 3 | What it gives the player |
|---|---|---|
| One tracked quest, chosen by the player | Log has "Track"; starting a quest tracks it | Never asks "what am I doing?" |
| Tracker panel, not one line | Quest title, then every objective of the quest, done ones struck | The whole current task is visible at once |
| Objectives in any order | Parallel objectives all listed, all pointed at | No hidden order |
| Big update banner | "Quest updated" with the new objective text | Every change is felt |
| In-world marker with distance | Diamond over the target, metres | No compass needed |
| Cross-region guidance | Marker points to the next gate/road and the map names the region | Know which region to go to |
| Quest log by type | Main / Side / Contract, with region and a longer story text | Orientation and choice |
| Giver marker | "!" over the giver | Quests are found, not guessed |

## 2. Gaps in Budayago before this change (see the analysis in the 2026-11-07 session)

1. A new side quest was invisible on the HUD until pinned in the menu.
2. Sub-goal counter showed the sub-goal index, not progress; the toast never said what changed.
3. Cross-zone arrow pointed at an exit with no zone name; the compass distance read as distance to the goal.
4. One objective line and one hint line; no list of objectives; a compass that duplicated the arrow.

## 3. Target design

1. **Tracker** (HUD, top left): tracked quest title (gold, with a main marker), then each objective line. In a
   multi-goal step every sub-goal is a line: `[x]` done (dim), `>` current (gold), `[ ]` open. Counted steps show
   `n/count`. A hint line (cream) follows when the step has a `_HINT` key.
2. **Tracking**: starting a side quest tracks it (`Game.pinned`, the old name is kept so saves stay valid). Finishing
   it hands tracking back to the main quest. The Journal button is "Track / Untrack". Main quests are always the
   fallback.
3. **Banner** (HUD, top centre, replaces the three quest toasts): small gold caption (`NEW QUEST`, `QUEST UPDATED`,
   `QUEST COMPLETE`) over the quest title or the new objective. Queued, one at a time. Item and glyph toasts stay.
4. **World guidance**: the screen-edge arrow stays. It gains a distance in metres (1 tile = 1 m). When the target is on
   screen a gold diamond floats over it with the distance. When the target is in another zone the label reads
   `-> <zone name>` instead of a distance. The compass is deleted.
5. **Sub-goal focus**: with several open sub-goals, the arrow and the HUD text prefer one whose marker is in the zone
   the player is in (then the first open one). Progress is "done/total".
6. **Journal and map** read the same helpers (`quest_objective_text`, `step_checklist`); no second source of truth.

## 4. Migration steps (all done)

1. Docs: this file, quests.md 7.5/7.6 pointer, ui.md, HANDOFF.
2. `Game`: auto-track side quests, `quest_objective_text(id)`, `focus_sub(id)`, `step_progress(id)`.
3. HUD: tracker, banner, arrow distance and zone label, on-screen diamond; remove `Compass`.
4. Delete `ui/compass.gd`.
5. Menu: Track/Untrack wording, `_set_hud` comment.
6. Text: `ui.csv` (`UI_PIN` family reworded, `UI_Q_*` keys added). `.translation` files need `--import` on the Mac.
7. Tests: `quest_test`, `quest_engine_test`, `ui_test` updated for auto-track and done/total.

## 5. Not in this change (next candidates, in value order)

- Quest give/turn-in markers ("!" and "?") for every NPC state, and a list of available quests in the Journal.
- Fail and branch states (a quest that can be lost), optional objectives, level hints on quests.
- Search-area circles for vague targets instead of a pin.
- Merging runs of same-shaped steps (talk, go, clear) in the 24-step quests, and new step types (timer, escort).
- `_catch_up` for `talked_to`, `clue_examined`, `memory_done` fired before the step is current (needs a history set in
  the save).
