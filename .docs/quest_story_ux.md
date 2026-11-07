# Quest story UX: making the story play like a proper RPG

Written 2026-11-07. Companion to [quest_system.md](quest_system.md) (HUD and tracking). Goal: the story is *directed*, the
player *takes part*, choices *echo*, and quests have a felt start and end. Nothing here changes step order or step
count of any quest, so every `step:<quest>=N` and `flag:` condition in zones and dialogue stays valid.

## 1. Diagnosis (from reading the code and data)

1. 119 story beats are "flag set -> dialogue box", with no staging: no camera, no bars, no movement, no portraits.
2. Only 6 of 90 dialogue files have choices; hero lines are fixed; the 6 Major Choices have no visible echo.
3. MQ1 has 24 steps and none is `talked_to`: the loop is clear area -> beat -> clear area -> beat.
4. Objectives name actions ("Clear the scout camp"), not intent.
5. Quests start silently (`start:` inside a beat) and end with a small banner.
6. The Journal lists recap sentences, not a story.

## 2. Scene direction (workstream A: ui/scene_director.gd, ui/dialogue_box.gd, ui/story_beat.gd)

**Cue lines.** Any string in a dialogue `lines` array that starts with `#` is a cue, not text:
`#name` or `#name:arg`. `DialogueBox._next()` skips it like an `@speaker` line and calls
`Events.scene_cue.emit(name, arg)` when it is reached. Cues:

| Cue | Effect |
|---|---|
| `#cam:<npc_id>` | camera eases to that node (matched like the HUD arrow: npc_id / id / name); `#cam:hero` returns |
| `#bars:on` / `#bars:off` | cinematic letterbox bars slide in / out |
| `#shake:<0-3>` | camera shake, strength 0 (none) to 3 |
| `#wait:<seconds>` | the box holds on a beat of silence (max 3 s), then continues |

**Auto-direction (no data change needed).** `story_beat.gd` wraps every beat: bars on before the first line, and
whenever the speaker tag (`@NPC_<ID>_NAME`) names a visible, condition-active NPC within `160 px` of the hero (`find_node_by_id` skips hidden and unmet-`cond` nodes, supports `npc_id` prefixes like `laras_tag`, and picks the node nearest the hero), the camera eases toward that NPC (clamped to `80 px` offset; hero speaker, narration `@`, or distant off-screen voice = back to the hero). At the end of the beat bars off and the camera is released. Explicit cues override the auto camera. Normal NPC talks (`Npc.interact`) get no bars, only the existing box.

The tree is paused while the box is open, so the director runs with `process_mode` always (GameUI already is).

## 3. Choices with consequences (workstream B + D)

- Action `remember:<key>` (in `Game.run`) sets flag `remember_<key>` and emits `Events.consequence_noted(key)`.
- Text lives in `data/text/dialogue.csv`: `REMEMBER_<KEY>` is the sentence ("Nyai Sekar will remember that you...").
- HUD shows a banner "<sentence>" with caption `UI_Q_REMEMBER`; Journal gets a "Choices" section listing every set
  `remember_*` flag as its `REMEMBER_<KEY>` sentence.

## 4. Quest start and end (workstream C: ui/quest_card.gd)

- Main quest start: full-width title card (act number/name, quest title, one stakes line = first sentence of `Q_<ID>_DESC`).
- Quest end (main and side): a summary card listing the title, Ilmu gained and every reward (items, flask shard, codex, lakon).
- Cards queue behind dialogue and never open while the tree is paused by the box or menu.

## 5. Journal as a story log (workstream D: ui/menu.gd)

Per quest the Journal shows a growing narrative paragraph: description, then the `_DONE` recap of each finished step in
order (the hook), then the current objective as the open question. Choices section (see 3).

## 6. Objectives as intent (workstream E: data/text/quests.csv)

Objective (`Q_*_S<n>_OBJ`, sub-goal `_P<n>`) text states what the hero wants to find out or achieve, then the concrete
place or person. Recaps and descriptions stay.

## 7. Pilot (workstream F: MQ1 chapter 1, steps 1.1 to 1.5)

Uses every tool above on the first chapter of Act I: cues in the beats, a conversation with a choice that is
remembered, and a quest title card. Same step count and flags as before.
