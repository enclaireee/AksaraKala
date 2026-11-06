# UI: HUD and menus

Canvas 480x270, integer-scaled, no sub-pixel UI. All sizes in native pixels and **TUNE** until seen on the real canvas. Layout follows the genre norm (Hyper Light Drifter, Death's Door, Hollow Knight): vitals small in the top-left, the center empty. Decided 2026-11-05, Claude's calls (**ASSUMED**) unless noted.

## 1. Fonts and text
- **Latin text:** smooth, not pixel (user call, 2026-11-05). It is drawn at window resolution under `canvas_items` stretch ([architecture.md](architecture.md) 1). For now it uses Godot's default font. ASSUMED: pick one clean sans for body, HUD and dialogue in the Phase 6 art pass. The m5x7 pixel-font plan is dropped.
- **VERIFY** the chosen font has the characters the text needs. Indonesian is plain Latin, but Sundanese romanization uses é and eu (Cépot, leuweung).
- Aksara: Noto Sans Javanese and Noto Sans Sundanese (OFL), see [spells.md](spells.md) 10 for the render test.
- Smallest text 7 px tall, always with a 1 px dark outline or shadow over the game world.

## 2. HUD (in play)
Safe margin 6 px from every edge. Nothing in the central 240x140 px.

| Element | Where | Size | Notes |
|---------|-------|------|-------|
| HP bar | Top left | 80x5 | Vermillion. Flashes and pulses below 25% |
| Stamina bar | Under HP, 2 px gap | 64x3 | Yellow. Hidden when full for 2 s (shows on use) |
| Sakti gauge | Under stamina, 2 px gap | 50x3 (Mage 60x3 for 120) | Sky blue. A tick at 15 (14 for Mage and Rogue) marks "can draw" ([combat.md](combat.md) slow-mo gate) |
| Bar icons | Left of each bar | 7x7 | Heart, bolt, brush. Color is never the only cue |
| Flask | Bottom left | 6 flask slots, 7x9 each | Bluish green. Full = bright, empty = dim outline, locked slots not drawn |
| Weapon | Right of flask | 16x16 | Current weapon icon |
| Ilmu | Top right | 8 px icon + number | Pale gold. Counts up on pickup |
| Boss bar | Bottom center, 18 px from bottom | 240x5 | Name above it. Phase 2 tick at 50% |
| Toasts | Top center | 1 line | Quest start, update, done ([quests.md](quests.md) 7.6). 3 s, queue, never more than one at once |
| Objective arrow | Screen edge | 7x7 | Main objective or the pinned side quest only ([quests.md](quests.md) 7.5) |
| Save icon | Bottom right | 8x8 brush | "Tersimpan / Saved" for 1 s ([rpg.md](rpg.md) 11) |
| Interact prompt | Above the NPC or object | key glyph + 1 word | Only within interact range |
| Objective line | Top left, under the bars | 1 line | Current step of the main quest or the pinned side quest, plus "n/count" when the step counts (user call, 2026-11-05) |
| Hint line | Under the objective | 1 line | Key hints for tutorial steps (`Q_<ID>_S<n>_HINT`, keys from the input map). Hidden when the step has no hint |

Blocked actions (no stamina, no sakti or cast lockout, flask empty or HP full) flash the matching bar or the flask slots red for 0.25 s.

Colors are the Okabe-Ito colorblind-safe set: HP #D55E00, stamina #F0E442, sakti #56B4E9, flask #009E73 (**VERIFY** on the final palette, keep the hues apart). No red HP next to a green bar.

Damage numbers: [combat.md](combat.md) 3.2. The Archer's long-range bonus hits use the bigger number font, which teaches Eagle Eye without extra UI. The soft snap gets no hint (aim assist stays invisible). This answers [combat.md](combat.md) 9 Q2.

Cast mode ([spells.md](spells.md) 7): vignette, cursor circle, ink trail, ghost guide in practice. The HUD stays visible but dims to 50%.

## 3. Menus
All menus pause the world ([controls.md](controls.md) 4.7). Esc backs out one level.

- **Title:** Continue (only with a save), New Game, Settings, Quit ([rpg.md](rpg.md) 11).
- **Pause (Esc):** Resume, Settings, Quit to Title, Quit Game.
- **Tab menu**, Q and E switch tabs, opens on the last tab used:
  1. **Status:** stats, level, Ingatan rank. Level-up only works at a petilasan ([rpg.md](rpg.md)).
  2. **Perlengkapan / Equipment:** weapon, armor, accessory slots; swapping is instant ([items.md](items.md)).
  3. **Aksara:** learned glyphs with the animated stroke order and the spell's numbers ([spells.md](spells.md) 5).
  4. **Catatan / Journal:** [quests.md](quests.md) 7.4.
  5. **Codex:** enemies, legends, items, with "Kelemahan / Weakness" lines ([bestiary.md](bestiary.md)).
- **Settings:** audio (master, music, SFX), display (window scale, fullscreen), controls and accessibility ([controls.md](controls.md) 6), language (Indonesian / English).
- **Dialogue box:** bottom, full width minus margins, 3 lines of text, speaker name tag. Typewriter text, interact shows all, then advances. Portraits 32x32 are a stretch ([architecture.md](architecture.md) 10).
- **Name entry** (Story v3.1, 2026-11-06): after New Game, before the prologue. One screen: a text field (max 12 characters, letters, digits, space, `'` and `-`; anything else is dropped as you type), a default name `Jaka` (**ASSUMED**) so Enter alone works and a gamepad player can just confirm, a pronoun row he / she / they (left and right, default they), and a confirm. Empty or blank names fall back to the default. Saved as `hero_name` and `hero_pronoun`. Text uses `{name}`, `{they}`, `{them}`, `{their}`, `{They}` (capitalised), filled by `Game.fmt()` after `tr()`. Indonesian has one pronoun (`dia`, `-nya`), so the ID strings never need the pronoun tokens.
- **Dialogue choices & `"Ask about..."` topic hubs (Story v5):** a talk may end in 2-4 choices, listed under the last line in the dialogue box. Up and down move, interact picks, Esc does nothing (a choice is never skipped). Each choice runs its own actions. **The game has 6 Major Choices in all (one per Act, [quests.md](quests.md) 4)**, each recorded as a flag that ripples across acts and the Epilogue. In addition, major NPCs and companions at petilasans/hubs may offer optional **"Ask about..."** topic choices (`"quiet": true` sub-entries that return to the topic menu until the player picks `"Leave"`). Main-path and camp talks are up to **8–12 lines**; story beats are up to **8–10 lines**.
- **Writing the name** (the finale): after Kala, a full-screen ink card. It shows Laras's name as 3 Sunda glyphs, La, Ra, Sa (Laras; the final s takes a pamaéh, the vowel killer, which the game leaves out: **VERIFY** whether it should be a 4th stroke), one at a time with the ghost guide, and the player draws each. A stroke is scored only against the glyph asked for, with the practice threshold, and a miss just clears it to try again (no fail state). Each written glyph stays on the card in ink. After the third, the card fades to the epilogue.
- **Class choice:** after the prologue, 4 class cards (name, description, stats, start weapon, passive), then a confirm ([classes.md](classes.md)).
- **Death:** fade to black, "Gugur / Fallen", one-line folklore tip (stretch), back at the petilasan ([rpg.md](rpg.md) 7).
- **Ending:** the epilogue at the wayang stage, then credits ([quests.md](quests.md) MQ5).

**Story-flow UI (v3.1, all **ASSUMED**; no new screens).**
- **Camp talk:** an optional NPC entry at a petilasan (Act II `galuh_1`, Act IV `timur_2`). It is the ordinary dialogue box with a `"quiet": true` entry, so no new UI; it never completes a step.
- **`all` step in the journal:** the step shows its sub-objectives as an indented list under the main line; each is struck through as its trigger fires, in any order, and the step completes when all are struck (quests.md 7.1; used for the three leads in MQ2 2.3).
- **Interlude (MQ4 4.1-4.2):** no HUD change. The journal shows the Act V title; the usual HUD, marker and petilasan stay as they are.

**Name tag (Story v4, **ASSUMED**).** The first time a named character speaks in a save, the dialogue box shows under the speaker name a second line: a one-line "who" in smaller text, key `NPC_<id>_WHO` ("Cepot. Semar's son. Loud."). Name 8 px gold #E8D9A0 as now; "who" 7 px, light grey #BDB59A, 1 px outline, at y 193, so the body text moves down 4 px (**TUNE**) for that first line only. Max 40 characters (**TUNE**). It is skipped for bosses mid-fight and for NPCs without the key. Shown once per save (flag `seen_name_<id>`); it stays up for the whole first talk, not just the first line. The tag is also used for the hero ("{name}. You." is not shown). Bosses get their tag in their first speech.

**Lontar shimmer (Story v4, **ASSUMED**).** When an unexamined clue is within 48 px the half-lontar on the hero's belt glows: 6 motes, 1x1 px, pale gold #F6E7A8, drifting up 8 px and fading, alpha 0.2 to 0.9 as you get closer. A soft chime on first trigger. A matching 1 px gold sparkle (2 frames, 0.5 s loop) sits on the clue object itself so the player can find it. It never shows an arrow or a name. Colour is never the only cue: the clue's interact prompt reads "Periksa / Examine". The "Reduce flashing" setting ([controls.md](controls.md) 6) turns the motes into a static 3 px glow.

**Kelir memory frame (Story v4, **ASSUMED**).** A black letterbox, 24 px top and bottom (**TUNE**), slides in over 0.4 s on entering a memory and out on leaving. The HUD is hidden except a 1-line hint (key glyph + action, same place as the interact prompt, shown for the first 5 s). The screen is warm paper lit and dim brown outside the lamp ([architecture.md](architecture.md) 9b). Semar's narration uses the dialogue box with the speaker "Semar (Dalang)" and italic-style text in pale cream #F2E6C4; 2 lines at most, shown in the bottom letterbox band if they fit (7 px), else the normal box. Memory titles show for 2 s centred in the top band: "Ingatan: <title>" (key `MEM_<ID>_TITLE`). No toast, no objective line, no boss bar.

**Laras chapter frame (v4b, **ASSUMED**).** As the Kelir memory frame, but the screen tint is cool blue (#D5E2F0 lit, #1E2A3A dim) and the title reads "Laras: <title>" (`LC_<n>_TITLE`). The hint line shows "say the true name" with its cooldown ring (12 px, **TUNE**). No Semar line. **Gap memory UI:** the 3-option list uses the dialogue choice list under a one-line prompt; a gap is a grey 24x24 square with a "?" and the interact prompt. A wrong pick flashes it grey for 0.5 s; no text.

**Journal: "Story so far" and clues** (the Catatan tab, [quests.md](quests.md) 7.4; Story v4, **ASSUMED**). Two new sections at the top of the Journal tab, above the active quests:
- **Cerita sejauh ini / Story so far:** a header (key `UI_JOURNAL_STORY`) and the recap lines of finished main steps, newest at the bottom, 1-2 lines each (key `Q_<QUEST>_S<n>_DONE`), in the dim colour; the last 6 are shown and the rest scroll. Never lists side quests. Gold marker on the line for the current act.
- **Petunjuk / Clues:** a list of examined clues grouped by hunt (hunt title in gold, key `HUNT_<ID>_TITLE`), each with its one-line note (`CLUE_<ID>_NOTE`, 8 px). Unexamined clues are not listed (no spoilers). A finished memory shows as a last gold line "Ingatan: <title>".
- Uses the existing scroll list and button focus; no new tab. Empty state: `UI_JOURNAL_EMPTY` as now.

**Glyph lesson card.** Top-left card (`ui/glyph_lesson`, child of GameUI, does not pause) shown after each newly learned glyph: Latin name and spell name, the aksara character, the codex line, a tip (`LESSON_*`), "Cast n/3" with power, and the hold-to-skip hint. The ghost guide sits top-right. See [spells.md](spells.md) section 5.

## 4. Open
- Test the HUD sizes on the real canvas in Phase 1 and tune.
- Font characters (é) and the m6x11 license, above.
