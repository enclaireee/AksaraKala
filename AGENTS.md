# Agent workflow

How the main session splits Budayago work across subagents while using as few tokens as it can. [CLAUDE.md](CLAUDE.md) holds the always-on rules. This file is for the main session when it plans or delegates.

## 1. Token rules
- **CRITICAL: NEVER use arbitrary time delays** like `sleep`, `time.sleep` or fixed timeouts to wait for other processes, background jobs or file creations. Always use deterministic blocking checks (`wait-on`, IPC readiness flags), or explicit retry loops with backoff only upon explicit failure. Every brief carries this line (section 3).
- **Do it yourself** when the change is 1-2 files and you could describe the diff in one sentence. A brief costs more than the edit.
- **Delegate** when there are 3 or more independent pieces, edits across 4 or more files, research that needs 5 or more reads, or output that would be long (test runs, imports, wide searches).
- The main session reads doc sections, not whole docs. Agents get section pointers (`world.md` "Tatar Sunda"), not pasted text.
- Send long output to a Haiku agent. Get back failures only, never full logs.
- Run at most 4 agents at once and at most 8 per task. Never put two agents on the same file.
- To follow up, use SendMessage to the same agent. A new agent starts cold and costs more.
- Never trust an agent's summary. Run the verify command and read `git diff --stat`, then only the hunks that matter.
- An agent that fails verification twice moves up one tier. Tell the user when that happens.

## 2. Who does what
| Work | Agent | Tier |
|------|-------|------|
| "Where is X", listing files, finding a doc section | `scout` | Haiku |
| Running Godot imports and tests and the design scripts, returning failures | `triage` | Haiku |
| Routine GDScript: components, enemies, spells, UI scenes, data `.tres` files | `implementer` | Sonnet |
| Tests from acceptance criteria | `test-writer` | Sonnet |
| HUD and menus, following `ui.md` | `ui-implementer` | Sonnet |
| Zone layouts, encounter placement, dialogue and codex text (sections 5 and 6) | `general-purpose` on Sonnet | Sonnet |
| VERIFY items (folklore, script, licenses) | `researcher` | Sonnet |
| Reviewing a diff for correctness | `reviewer` | Sonnet |
| Recognizer, cast slow-mo and `time_scale`, save and load, the zone loader, the quest engine | `deep-implementer` | Opus |
| Phase planning, integration, design calls, final checks | main session | Opus |

The save system is the only data-loss risk. It goes to `deep-implementer`, and its round-trip test must pass before you accept it ([architecture.md](.docs/architecture.md) 12).

## 3. Brief template
An agent sees none of the conversation. Every brief has these parts:
```
Goal: one sentence, the result and not the steps.
Read: doc sections by heading, e.g. .docs/combat.md "3.2", .docs/bestiary.md "Encounters". Nothing else.
Own: files you may create or edit. Touch nothing outside this list.
Do not: commit, add plugins or autoloads, or change .docs/ (report doc conflicts instead).
**CRITICAL: NEVER use arbitrary time delays** like `sleep`, `time.sleep` or fixed timeouts to wait for other processes, background jobs or file creations. Always use deterministic blocking checks (`wait-on`, IPC readiness flags), or explicit retry loops with backoff only upon explicit failure.
Done when: checkable criteria, e.g. "the chaser flinches on hit 1-2 and not on hit 3".
Verify: exact commands, e.g. $GODOT --headless --path . -s tests/combat_test.gd
Report: at most 10 lines: files changed, verify result, open questions, and any doc conflict found.
```
`$GODOT` is `/Applications/Godot.app/Contents/MacOS/Godot`. Write it out in full in briefs.

## 4. Code workflow per phase
Phases and exit criteria are in [schedule.md](.docs/schedule.md). The split below is the default.

| Phase | Main session does | Delegated |
|-------|-------------------|-----------|
| 0 Setup | All of it: project settings, folders, autoloads, input map, physics layers | `triage` runs the import check |
| 1a Combat core | Player state machine and `CombatTuning` | `implementer`: health and stamina components, then the chaser enemy and the test room in parallel. Feel is tuned by the user playing, not by agents |
| 1b Combat depth | Attack tokens | `implementer`: statuses component, then the shooter enemy, then poise. Then one encounter mix |
| 2 Aksara | Plans the recognizer API | `deep-implementer`: recognizer and its test. `implementer`: glyph recorder tool, then the sanggar scene. `triage` runs the confusability check |
| 3 RPG loop | Designs the `Game` data | `deep-implementer`: save and load plus round-trip test. `implementer`: petilasan, death and respawn. `ui-implementer`: level-up and Tab menu |
| 4 First region | Zone loader (or `deep-implementer`), quest engine | World design (section 5) for Desa Purwa and Tatar Sunda, then `implementer` builds the scenes. Dialogue (section 6) |
| 5 Other regions | Integration and boss tuning | The section 5 and 6 pipeline, one zone at a time. At most 2 zones in flight |
| 6-8 | Checks, release | `researcher` for VERIFY items, `triage` for full test runs |

Bosses: the main session writes the phase list from `bestiary.md` and `balance.md`. Then `implementer` builds it, and `reviewer` checks the diff against the phase list.

## 5. World design workflow (one zone at a time)
The docs give the targets: [world.md](.docs/world.md) zone section and "Points of interest", [bestiary.md](.docs/bestiary.md) zone roster, "Encounters" and "Glyph weaknesses", [quests.md](.docs/quests.md) main and side quests for the zone. A zone is designed on paper first, checked, and only then built.

**Step 1, layout (Sonnet `general-purpose`).** It writes `.docs/zones/<zone>.md`, the only file it owns:
- A screen grid in ASCII (about 4x4 screens of 30x17 tiles), with exits, kabut gates and the critical path marked.
- A room table with columns id, size in tiles, purpose, contents (enemy mix by its bestiary name, NPC, chest, petilasan, codex spot, quest marker id).
- Where each side-quest step happens, using the marker ids that `QuestData` will use.
- A one-line flow: entry, first teach encounter, mid petilasan, miniboss, petilasan, boss.

**Step 2, check (main session).** Check the doc against this list and send fixes back with SendMessage:
- [ ] Points-of-interest counts match world.md: 1 boss arena, 1 miniboss or elite room, 3-5 NPCs, 2-3 secrets, 1 codex spot, 6-10 encounters, 1-2 petilasans
- [ ] A petilasan comes before the boss, with no fight between the two
- [ ] Each enemy first appears alone or with known enemies, and its weakness is usable there
- [ ] One tank per encounter (two only right before the boss), at most one shooter, at most two waves
- [ ] Rooms with 4 or more enemies are at least 15x9 tiles. Chargers have an 8-tile lane
- [ ] The zone's newest glyph is the clean answer in at least one encounter
- [ ] Every quest marker and flag in quests.md for this zone has a room
- [ ] The whole critical path can be walked without the zone's own glyph (glyphs are rewards, not keys)

**Step 3, build (`implementer`).** It turns the zone doc into the zone scene, TileMap rooms with placeholder tiles, spawners and markers, and does not redesign. Verify with the import check, then the user walks it. Changes to layout go into the zone doc first.

## 6. Dialogue and codex workflow
- Text lives in `data/text/*.csv` with columns `keys,id,en`, per [quests.md](.docs/quests.md) 7.7. The budget is about 450 lines per language for the whole game. Give each zone a share in its brief (hub about 80, each zone about 70, finale about 40). These shares are ASSUMED; adjust them as zones are written.
- One Sonnet agent writes one zone's text and owns only that zone's rows. Its brief gives the NPC names (quests.md §11 item 3), the quest steps, the tone (concept.md) and the line budget.
- Key format: `NPC_<npc>_<n>`, `Q_<quest>_S<n>`, `CODEX_<id>_TITLE/_BODY`. Indonesian is written first, then English. Each line fits 3 lines of the dialogue box at m5x7.
- Cultural claims in codex text keep a source line. Anything the agent is unsure of gets VERIFY and goes to `researcher`, not into the game as fact.
- Check: the quest data test ([quests.md](.docs/quests.md) 7.8) fails if a key is missing from either language. `triage` runs it.

## 7. Review
- `reviewer` checks diffs of 3 or more files, and all save, recognizer and quest-engine code. It reports correctness bugs and gaps against the brief only. Run at most 2 review loops.
- A runnable check beats a review. Each system leaves one headless test in `tests/` that exits 0 on pass.
- Game feel (timings, hit-stop, readability) is judged by the user playing, not by agents. Ask for a playtest at each phase's exit.

## 8. Autonomous Execution & Token-Efficiency Protocol
Applies to every session and every subagent. These rules protect context tokens and prevent races and stray edits.

**8.1 No blind sleeps or polling loops**
- Never use `sleep <N>`, `time.sleep()` or fixed timeouts to wait for servers, daemons, builds or subtasks.
- Block on readiness instead: `npx wait-on http://localhost:<PORT> -t 20000`, an inline `until curl -s ... ; do sleep 0.2; done` retry, explicit exit codes, or IPC status files.
- Subagents return control only at an explicit terminal state. Do not poll for file existence across turns.

**8.2 No phantom-bug spirals**
- If a port or endpoint fails on the first try right after a process start, do not assume the code is broken. Check the PID is alive (`ps aux`, `lsof -i :<PORT>`) and read stdout/stderr first.
- Do not read unrelated config files to diagnose a connection error unless the logs show a crash or fatal syntax error.

**8.3 Context conservation**
- Read line ranges (`sed -n 'a,bp'`) or `grep`, never whole files over 200 lines.
- Pipe noisy output through `tail`, or send it to a temp file (`> /tmp/x.log 2>&1; tail -n 30 /tmp/x.log`).
- Make small, atomic edits. Never rewrite a whole file to change a few lines. Keep surrounding comments and logic.

**8.4 Dependency discipline**
- Never install a package to fix an import error before checking typos, path aliases and what the manifest or lockfile already declares.

**8.5 Loop breaker and clean verification**
- Two strikes: if a command, test or patch fails twice with the same error, stop. State the error and your hypothesis to the user.
- Before calling a task done, run `git status` and `git diff --stat`. Only the intended files may change. Leave no scratch scripts, `.log` files or debug prints.

**8.6 Scope**
- Change only what was asked. Do not refactor or reformat untouched files. Match existing patterns and add no new libraries.

**8.7 Search and port hygiene**
- Never search `.git/`, `.godot/` or build output. Scope `grep`/`find` to source folders.
- Free a stale port (`lsof -ti :<PORT> | xargs kill -9`) before launching a server. Never change the default port to dodge `EADDRINUSE`.
- Iterate with the one relevant test file. Run the full suite once at the end.
- Never print `.env` files or secret keys.
