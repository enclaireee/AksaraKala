# Revamp plan: Kelir, tutorial, sprites, map, quest audit (2026-11-10, DRAFT for approval)

Nothing below is built yet. Written after reading the code; findings are facts, the rest is proposal.

## 0. What I found (research)

**Kelir (K0 and the other ~38 memories)**
- K0 (`zones/kelir/k0_ruwatan.gd`) is a bare 480x272 strip. Everything is `draw_rect`/`draw_circle`: a flat cloth rectangle, a green bar for the banana log, circles for lamp light, a black rect plus 10 px circles for Kala's shadow. The "light sequence" and "shadows" have no sprites.
- Teaching is one hint ("Stay in the light") and six one-line Semar lines that fire as lamps are lit. Nothing says what you control, what the shadow is, why it matters, or that you must walk right and press interact at lamps. The player is a 14 px silhouette on a cream strip.
- The other memories share `KelirDecor` (tiled cloth, beam, posts, puppets in the margins) with the same one-hint pattern, and they are generated from `script.md` by `gen_memories.py`.
- Kinds: K0-K10, K-II, K-III, H1-H4, LC1-LC6, 3 gap memories, 12 side-quest memories (about 41 in total).

**Tutorial**
- There are two systems that overlap. (1) `zones/prologue_tutorial.gd`, a standalone room (Semar, a dummy, a gate) that `Zones.start_new_game()` sends you to right after class select, before the story starts. It teaches dodge, attack and jamu behind a "Practice / Skip" choice. (2) The in-story ladder in `tutorial.md` / `ui/tutorial.gd` / `data/lessons.gd`, which teaches the same verbs again (dodge at the tag game, attack at the sanggar, and so on).
- Latest commits removed the quest-step hint toasts and HUD panel, so the story path now has no on-screen guidance except the ladder cards.
- Suspected bugs: the standalone room resolves choices through a single `_waiting_dialogue` string that is cleared on any pick; `prologue_tutorial_done` is only set by leaving through the gate or skipping; the player enters Desa Purwa knowing combat before the story has made them care.

**Sprites still code-drawn or polygon**
- Player facing pointer (`Aim/Pointer`, a 3-vertex Polygon2D), player arrow projectile (`arrow.tscn` Polygon2D), spirit shot, thrown rock, kabut fog (2 Polygon2Ds), oncor, pillar, curse stake, pouch field, arena posts, chest (12 `draw_rect`), K0 lamp glow / Kala shadow band / tendrils / goal beacon / cloth / beam / log, MemorySpot unlit-lamp pulse ring, boss telegraphs in `boss_kit.gd` (40 `draw_` calls), NPC markers, ambient fx (20 `draw_`). Enemies and bosses are already skinned through `EnemyArt` and are fine.
- Full list will come from a scripted audit (see 3) so nothing is missed.

**Map**
- Peta tab = `MapView`: one flat pixel per tile coloured by tile character (`MapRender.COLORS`), then vector `draw_circle`/`draw_colored_polygon` markers and a text legend. The hand-inked world map promised in `ui.md` 4.3 was never made: `tools/gen_map_art.py` does not exist.

**Environment constraint**
- There is no Godot in this box and I cannot get one (github.com/godotengine releases return 403; conda-forge has no godot). I cannot run `--import` or any `tests/*.gd` here. The repo already works this way (HANDOFF is full of "untested, no Godot"). I will verify with Python static checkers and by reading the GDScript carefully, and I will not claim Godot-level verification.

## 1. Kelir v2: the experience

Principle: a Kelir is a shadow-puppet *show*, not a corridor. Every memory has a clear structure the player can feel:

1. **Curtain-up (3-4 s).** The screen goes dark, the dalang's oil lamp (blencong) flares, cloth and frame fade in, title card "Wayang Ruwatan" in the kelir's own lettering. Gamelan sting.
2. **Dalang prologue (2-3 lines, short).** Semar says what the story is, in plain words, one idea per line.
3. **One-verb teach.** A single diegetic prompt on the stand-in ("walk", then "press E at a lamp") using the keycap pill, plus a world cue (a pulsing unlit lamp, an arrow-shaped wayang hand). No wall of text.
4. **Play with readable stakes.** The shadow is a drawn creature with a front you can read (Kala's hands and teeth on the wave edge), a distance meter at the bottom ("Kala is 12 m away") and warning flashes.
5. **Curtain-down.** The lit cloth shows the whole tale as a finished painted tableau, the dalang's closing lines, fade back.

K0 specifics (the one that must be perfect):
- New layout: a real kelir (cloth with sewn edge, bamboo frame, gedebog log, hanging blencong, gamelan silhouettes in the dark below, Semar and the dalang's hand cut into the foreground).
- Light sequence: each lamp lights with a 4-frame ignition sprite, a glow sprite (not a circle), a ring pulse, and the cloth around it warms up. The lit region is shown as a warm gradient sprite.
- Kala's shadow: a big wayang-style Batara Kala with sprite frames (idle, reach, lunge), claws along the shadow edge as the leading tendril sprites, a dark tide texture instead of a rectangle.
- A 3-beat story: (a) Semar introduces the kelir and Kala, (b) you light lamps while Kala creeps, each lamp gets a one-line teaching of a seal (so the Four Great Seals are introduced here, one per lamp, which matches `quests.md` 0.8 "teaches Batara Kala and the Four Great Seals"), (c) tableau at the end.
- Fair rules: checkpoint at each lit lamp, shadow slows 25% after 3 fails (already designed), a visible safe zone.

Later memories (K1-K10, K-II/III, H1-H4, LC1-LC6, gaps, SQ memories):
- All get the same 5-part structure through one shared `KelirStage` presenter (curtain-up card, objective strip, tableau), rather than 41 hand edits.
- Each gets its own set piece art (the thing the stand-in acts on: lesung, forge, oncor, boat) and a rewritten script: Indonesian first, English alongside, same CSV keys.
- LC chapters keep the cool moonlight look and gain Laras's perspective in the narration (first person).

## 2. Tutorial v2: taught inside the story

Decision proposed: **remove the standalone `prologue_tutorial` room** from the start-of-game path and teach everything with the story characters that already exist (the ladder in `tutorial.md`), with a bit more story:

| Beat | Where | Who | Teaches |
|------|-------|-----|---------|
| Wake-up | Desa Purwa, dawn, after the name/class screens | Ibu calls from the house | move (WASD), interact (E) |
| Tag | 0.1 | Laras dares you | dodge (Space), stamina |
| Market | 0.4 | stall-keeper, Cepot | interact on objects, the journal (Tab) for "what do I do now" |
| Sanggar sparring | 0.5 | Cepot with straw dummies, "show me what you can do" | attack, 3-hit combo, stamina |
| Write | 0.6 | Semar | draw the name with the mouse |
| Kelir | 0.8 | Semar | K0 (above) |
| The raid | 0.9 | story | nothing new: the player applies dodge + attack |
| Rest | 0.10 | Ibu | petilasan, jamu flask |
| Cast | 0.11 | Semar | cast glyph with a clearer 3-step card |
| First fight | 0.12 | | perfect dodge pops in on the first real hurt |

Also:
- Ladder cards get a "why" line from the character, a small icon sprite for each input, and a gentle in-world pointer (objective arrow already exists) instead of a text-only pill.
- The pre-story Semar room is kept only as an optional "Training yard" the player can revisit at the sanggar (a dummy next to Cepot) so nothing is lost; no forced detour and no Skip/Practice choice.
- Fix the bug class around it: one source of truth for "lesson done" (`tut_<id>` flags), `start_new_game()` always lands in Desa Purwa, tests updated (`prologue_tutorial_test` replaced, `prologue_test` and `loop_test` re-read).

## 3. Sprites: a full pass

- Scripted audit (`tools/audit_art.py`): scans `.tscn`/`.gd` for visible `Polygon2D`, `ColorRect`, `draw_*` and generic icons, and outputs a checklist (file, node, what it is, region).
- New generators in `tools/` in the style of the existing ones (`pixlib.py` palette, same outline rules), one PNG sheet per family, each with a `*_preview.png`:
  - **Player/combat:** facing pointer set (4 weapon archetypes: spear, bow, keris/blade, staff), arrow and bolt projectiles with trail, spirit shot, thrown rock, hit sparks if code-drawn.
  - **Kelir:** cloth, frame, log, blencong ignition and glow, Kala (big, 3 poses), shadow tide and claws, goal gate, per-memory set pieces, tableau frames.
  - **World:** chest (closed/open/locked), kabut fog banks, petilasan per region (check all 6), oncor, pillar, curse stake, pouch field, arena posts.
  - **Boss telegraphs:** ground decals as tiled sprites instead of `draw_*` where it is a static shape.
  - **UI-in-world:** NPC markers, quest diamond, interact glyphs.
- Style guide kept: 16 px tiles, no anti-aliasing, dusk palette for UI, warm paper for Kelir, cool for Laras.

## 4. Map: a proper illustrated RPG map

- New `tools/gen_map_art.py` (as `ui.md` 4.3 promised): hand-composed pixel world map for the Peta tab, drawn in the same pixel style as the tiles: sea with wave hatching, Java island silhouette across 6 regions + hub, mountain ranges, rivers, forests, candi, volcanoes, a compass rose and a banner cartouche, a border in the dusk set.
- Legend redesigned as a framed key with pixel icons (not text-and-vector): you / quest / NPC / petilasan / chest / clue / exit, each a small sprite from one generator.
- Current-area view: tile-textured render (use each region's real tileset instead of flat colours) with the same sprite icons and soft edge.
- `tab_map.gd` shows World / Area toggle; unlocked regions are inked, locked regions are fogged.

## 5. Quest order and indexing audit (after 1-4)

Static checker `tools/quest_audit.py` (Python, reads `data/quests/*.tres`, `data/dialogue/*.tres`, `data/text/*.csv`, `.docs/zones/*.md`, `zones/*.tscn`):
- Step numbers contiguous and match the doc tables; `recap`/`objective` keys exist in both ID and EN.
- Every `on` event has an emitter in a built zone; every `marker` id exists in its zone; every `set_flag` that a later step or a dialogue `cond` reads is set earlier.
- Dialogue gates (`step:mqN=K`, `flag:...`) and glyph grants line up with step indices.
- Kelir/memory ids in steps match scenes in `zones/kelir/` and `data/memories/`.
- Side-quest unlock conditions reachable; no step that needs a later step's flag.
Every finding fixed at the source (doc first, then `gen_quests.py` / `.tres` / dialogue), then re-run until clean.

## 6. Order of work and checkpoints

1. Docs first (this plan once approved, then `tutorial.md`, `ui.md` 4.3, `architecture.md` 9b updated).
2. Art generators (sprites, Kelir set, map), previews checked by eye as PNGs.
3. Kelir v2 code + K0, then shared stage, then rewrite memory scripts + regenerate scenes.
4. Tutorial v2 code and data.
5. Map code.
6. Quest audit and fixes.
7. Python checks (`know_check`, `glyph_strokes`, `balance_model`, new audits), read-through of every changed GDScript, commit, push.

Commits: no Co-authored-by / AI trailers (CLAUDE.md), per the user's "push to master" instruction I would push the work to `master` as well as the session branch.

---

## 7. Status (2026-11-10, end of pass)

Approved choices: verify with Python checkers and careful reading; remove the practice room; full Kelir depth; push to the session branch and master with no co-author trailers.

Done: Kelir v2 stage and K0 rebuild; mute Laras chapters fixed; missing spot lines written; tutorial ladder wired (and its dead practice room removed); sprites for the player pointer, arrow, projectiles, chest, kabut, boss props; illustrated world map, fog, icons, painted area map; `tools/quest_audit.py` (Q1-Q12, 0 problems; it found the `sq_s3` missing step and the mute chapters).
Not done, by choice or limit: unique set-piece sprites for every one of the ~40 memories (they share the stage, lamp/oncor/stake props, text and the decor cast; only K0 has bespoke art); boss telegraph decals stay `draw_*` (runtime-sized); Godot never ran, so every GDScript change is unexecuted: run the NEXT list in HANDOFF.
