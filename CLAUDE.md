# The Last Aksara (code name Budayago)

Godot 4.7 top-down pixel-art action RPG (480x270, 16 px tiles). The player draws Aksara Sunda and Aksara Jawa with the mouse to cast spells. The goal is a good game. There is no competition brief to design for.

If you are a subagent with a brief, do only the brief and skip the rest of this file.

## Start of every session
1. Read `.docs/HANDOFF.md` §7 (next step) and §8 (standing rules). Read the rest only if needed.
2. Find your phase in `.docs/schedule.md` and work only on that phase. Do not start the next phase until the exit criteria hold.
3. Delegate the way [AGENTS.md](AGENTS.md) says.
4. Follow the Autonomous Execution & Token-Efficiency Protocol in [AGENTS.md](AGENTS.md) §8 at all times.

## Docs are the source of truth
- `.docs/README.md` maps the docs. Read only the section you need: `grep -n "^#" .docs/x.md`, then read with `sed -n`. Never read a whole doc.
- If code needs a design change, change the doc first, then add a line to HANDOFF.md.
- Tags: ASSUMED (a decision, change it freely), VERIFY (a culture fact to check before it ships), TUNE (a starting number). Never remove a VERIFY tag without a source.

## Commands
- Godot is not on PATH. Set `GODOT=/Applications/Godot.app/Contents/MacOS/Godot`.
- Import and parse check: `$GODOT --headless --path . --import`
- Run a test script: `$GODOT --headless --path . -s tests/<name>.gd`. A test exits 0 on pass and prints only failures.
- Run a test script: a parse error still exits 0, so also treat any `SCRIPT ERROR` in the output as a failure.
- Design checks: `python3 .docs/glyph_strokes.py` and `python3 .docs/balance_model.py`
- Area scenes: `python3 .docs/gen_zones.py .docs/zones/<region>.md` writes `zones/<area>.gd/.tscn` from the doc's area maps and legends.
- Pixel-art settings, folders, autoloads, the input map and physics layers are in `.docs/architecture.md`. Follow them and do not invent new ones.

## Git
- This folder needs its own repo. If `git rev-parse --show-toplevel` is not this folder, run `git init` here first.
- Never commit, push, delete files or install anything unless the user asks.
