# UI: HUD and Menus

Canvas 480x270, integer-scaled (`canvas_items` stretch mode, `Nearest` texture filtering). Layout follows genre standards (Hyper Light Drifter, Death's Door, Elden Ring UI conventions): vitals top-left, center clear, immersive and quiet presentation. Theme (v3 "Senja", 2026-11-09): twilight indigo surfaces, a banded dusk sky, cyan glyph glow, warm amber secondary (section 0.1). Older parchment / ink notes below are history where they conflict.

---

## 0. Design Principles

### 0.1 v3 "Senja" (dusk), 2026-11-09: current
Rebrand from the key-art poster: a twilight sky over candi ruins, the logo in blocky distressed pixel letters, cyan aksara glowing in the air. The parchment, leather, wax and candle language is retired everywhere (menus included). v2's type scale, grid and quiet-HUD rules below still hold; only surfaces, colours, the title and the menu frame change.
1. **One surface, dusk.** Night-indigo fill `#141026` at ~90%, 1 px outline `#0A0814` with chamfered corners, 1 px inner hairline `#3A2F5C`. Focus variant: cyan hairline. Wells (slots, portrait) are a darker `#0C0A18` with a top inner shadow. All art: `tools/gen_ui_dusk.py`.
2. **Sky backdrop.** Full-screen screens (title, menu, class select, name entry, death) sit on the banded dusk gradient (`title_sky`: indigo `#1B1433` -> violet `#3A2456` -> plum `#6B3A5E` -> rose `#B5566A` -> peach `#E8946A`), drawn as hard 1-2 px steps with ordered dither between them, never a smooth blend, plus sparse twinkling stars.
3. **Accents.** Cyan `#7FE8E0` (halo `#3FB8C0`) = focus, selection, magic, new. Warm amber `#F2B27A` = quests, loot, Ilmu, secondary emphasis. Rose `#E0566A` = danger only (damage, low HP, destructive). Green `#8FD9A0` = done/gained. Gameplay bars keep Okabe-Ito.
4. **Text on dusk.** Body `#ECE6F2` (cool cream), headings `#FFF4E6`, caps labels `#A99BC8` (lavender), dim `#8C83A6`; Semar's narration warm dim `#D9B48F`. 1 px outline `#0A0814` over the world.
5. **Logo is art.** `logo.png` (two lines, Aksara / Kala): chunky 4x pixel letters, off-white `#EEE8DC`, distressed chips, aksara-style bars and dots above and below, 1 px drop shadow. Generated, original lettering.
6. **Motion.** v2 rules. Ambient loops allowed only on full-screen backdrops: star twinkle, floating glyphs bobbing (2-3 px, 3-5 s), drifting cyan motes.

### 0.2 v2 (2026-11-09): type, grid and HUD rules (surfaces and colours superseded by 0.1)
Audit of the v1 UI found the "slop" came from a few root causes, not from any one screen: (1) the Jersey pixel fonts were drawn at 10 / 15 px while their pixel grids sit at 18.67 / 27 px, so every glyph was resampled to about half a pixel and broke up; (2) eight different font sizes (7, 8, 9, 10, 12, 13, 15, 28) with no scale; (3) four surface languages over the world at once (parchment panels with iron studs, stitched leather plates, wax seals, gold lacquer); (4) banner and toast shared one screen spot and overlapped; (5) spacing was 6 px here, 5 there, 4 elsewhere. Genre references: Hyper Light Drifter and Death's Door (bare edge-anchored vitals, nothing in the centre), Elden Ring (boss name over a long thin bottom bar, minimal frames), Sea of Stars / Octopath (one dark translucent box family for all in-world text, caps speaker label, diamond cursor).
1. **One type scale, pixel-true.** Four steps only (section 1). A font is never drawn at any other size and text is never scaled.
2. **Two surfaces.** *Ink* (dark lacquer at ~90%, 1 px near-black outline with chamfered corners, one warm hairline inset 1 px: `ink_panel.png`, `tools/gen_ui_ink.py`) for everything over the world: HUD cards, banner, toasts, prompts, dialogue, the prologue card, the glyph lesson, class select and name entry. *Paper* (the field book) only for full-screen menus and the title desk. No studs, stitches, leather plates or wax seals over the world.
3. **One accent.** Gold `#E0B35A` marks focus, selection, the quest and new things. Wax red `#C9473B` is reserved for danger (damage, low HP, destructive). Gameplay bar colours (Okabe-Ito) are unchanged.
4. **One grid.** 4 px base: screen-safe margin 8, panel padding 6, gaps 2 / 4 / 8 / 16 (`UIFx.MARGIN`, `PAD`, `GAP_*`). Whole-pixel positions.
5. **Quiet HUD.** Edge-anchored, the centre stays clear, everything fades for dialogue; one thing per screen spot (banner top centre, toasts top right under Ilmu).
6. **Copy.** Sentence case in data; small labels are set in tracked caps by the font (`Label.uppercase`), never typed in caps. Keys are shown as keycaps or as the bare key name ("E  Continue"), never in square brackets. Verbs on buttons and prompts, one word where possible.
7. **Motion.** 120-250 ms ease-out slides and fades; no idle shimmer or sweeps; the only loop is the blinking continue mark.

## 1. Typography and Text
All constants live in `ui/fx/ui_fx.gd` (`UIFx.text(t, kind, colour)`); `ui/theme.tres` matches them.
| Step | Face | Size | Cap / line | Use |
|---|---|---|---|---|
| Body | Tiny5 (`Tiny5-Regular.woff`, OFL) | 8 | 5 / 10 (9 + 1 spacing) | all body text, dialogue, lists, numbers, hints, prompts |
| Label | Tiny5, CAPS, +1 px tracking | 8 | 5 / 10 | small section labels, kickers ("QUEST UPDATED"), speaker names, quest name in the tracker |
| Heading | Jersey 10 | 19 | 10 / 13 (FontVariation trims 4 top, 3 bottom) | panel and page titles, menu entries, banner quest name, boss name, class name |
| Display | Jersey 15 | 27 (logo 54) | 15 / 20 | area and region titles, quest title cards, "Fallen", the logo |
- Big numbers may use Tiny5 at 16. The aksara scripts keep Noto Sans Javanese / Sundanese at their own sizes.
- Text over the world has a 1 px dark outline; text on ink or paper has none. On paper: ink `#2A1C12`, headings ink red `#7A2A1E`, secondary `#6B5A44`. On ink: cream `#EADFC4`, headings `#F3E3B8`, labels `#B8A27A`, dim `#A59A82`, accent gold `#E0B35A`; Semar's narration is warm dim gold `#C9B48A` (the pixel face has no italic).
- Crimson Pro and Almendra were removed with the v3 rebrand.

---

## 2. In-Game HUD

Safe margins: 8 px from window borders. The central 240x140 px play space remains unobstructed. v2 layout (2026-11-09) below; every card is the ink surface.

### 2.1 Elements
| Element | Location | Dimensions | Description |
|---|---|---|---|
| **Vitals** | Top-left (8, 8) | HP 100x6, stamina 72x3, sakti 60x3 (+1 px outline each), 2-3 px apart | Bare bars, no badges: ink outline, dark well, fill with a lit top row (HP also a shade row and ticks every 10 px). HP number ("86/120", body) 4 px right of the bar. Lag chunk, low-HP pulse, stamina hides when full, sakti 60 px for the Wiku's 120 gauge. |
| **Tracker** | Top-left (8, 36) | 124 px wide | Translucent ink strip with a 1 px gold left edge. Quest name as a caps label (gold for main, sand for side), then the active objective in body text after a 5 px gold diamond, `(n/m)` for checklists. Flashes on change, dims to 50% after 5 s. |
| **Quest Banner** | Top-centre, y 8 | auto x 15 (max 300) | Small ink pill on one line: gold caps kicker ("QUEST UPDATED") then the quest name in cream body text, both 8 px. A long "remembered" sentence wraps under the kicker on a 260 px card. Slides down, holds 3.6 s, fades. |
| **Toasts** | Top-right, y 32 | auto width 60-220 x 15 | Ink pill with a gold tick on its leading edge, right-aligned under Ilmu; item, glyph and hint toasts queue, 3 s each, slide in from the right. Never shares the banner's spot. |
| **Ilmu** | Top-right (8 px margin) | 8x8 gem + number | Gold cut-gem icon and a rolling gold number, no plate. "Esc  Menu" hint under it for the first 25 s. |
| **Weapon + Flasks** | Bottom-left (8, 242) | 20x20 well + 7x9 flasks | Ink well holding the equipped weapon; flasks on its baseline 4 px to the right, 9 px pitch. |
| **Boss Bar** | Bottom-centre, 8 px from bottom | 240x4 | Boss name in the heading face, left-aligned over the bar (Souls convention); 50% phase tick; dawn bar 2 px under it; cracked-glyph mark at the right end when `sabotage_flag` is set. |
| **World Guidance** | Screen-edge / World | Variable | 9x9 gold chevron at the screen edge with the distance on a small ink pill; on screen, a gold diamond floats 46 px over the target. `-> <zone>` when the target is in another zone. |
| **World Prompts** | Above the interactable | 14 px ink pill | Light 10 px keycap with the key name + one cream verb (body). Only the nearest interactable shows one. |
| **Save Icon** | Bottom-right | 8x8 + text | "Saved" in dim body text beside the icon for 1 s. |

### 2.2 Dynamic States
- **Dialogue Focus:** While dialogue is active, the Tracker card, Flasks, Weapon well, Ilmu counter, the vitals plaque, the Saved badge and screen hints all fade out to 0% alpha over 0.2 s.
- **Cast Mode Overlay:** Vignette, ink drawing cursor, dynamic ink trail, and ghost guide in sanggar practice. Main HUD dims to 50%.
- **Blocked Feedback:** Attempting actions without stamina, without sakti, or using empty flask flashes the respective gauge red for 0.25 s.

---

## 3. Dialogue & Scene Staging

### 3.1 Dialogue Box
- **Box (v2, 2026-11-09):** ink panel, 400 px wide, centred, 8 px above the screen bottom; height fits the content on whole 10 px lines (min 40, 68 with a face). Text is pinned to the top so lines never jump as the box grows.
- **Speaker:** the name is a gold caps label inside the box at the top of the text column (no plate sticking out of the frame). On a first meeting the descriptor tag (`NPC_<ID>_WHO`) follows it in dim body text on the same row. Body text cream; Semar (Dalang) narration in warm dim gold.
- **Choices:** listed under the last line; the chosen row gets a soft gold wash and a 5 px gold diamond.
- **Speaker Portrait (redesign 2026-11-08, v2 frame):** a 56x56 `frame_portrait` (an ink well since v2) holding a 48x48 bust (`assets/art/portraits/p_<name>.png`, from `tools/gen_speaker_portraits.py`) sits inside the box 6 px from its left edge, centred on its height; the text column starts 70 px in. Busts are 3/4 view facing right (toward the text), one top-left light, outline on the outside only, warm hue-shifted skin ramps (shadows go red-violet, never grey), eyes with white, iris and a highlight, brows separate from lids. Indonesian headwear only (iket, blangkon, kerudung, konde, siger, kuluk); no European crowns. Spirits: Kala a red wayang giant, the faceless spirit a shaded featureless head, Semar and Cepot shaded like wayang golek. Each bust has expression variants `p_<name>_<mood>.png` for happy / angry / sad (neutral is the base file); a dialogue line tag `#face:<mood>` picks one and falls back to neutral. 22 archetype busts; `ui/portraits.gd` maps speaker ids to them (ASSUMED picks for minor NPCs); speakers with no entry show no face and the plate keeps its old position.
- **Advancement:** Typewriter text progression, instant complete on press; a blinking gold triangle bottom right, with "E  Continue" beside it until the player has used it once.

### 3.2 Scene Director (`ui/scene_director.gd`)
Story beats and cinematic conversations feature automated and scripted scene direction without pausing gameplay logic:
- **Cue Lines in Dialogue:**
  - `#cam:<node_id>`: Smooth camera pan to NPC node, entity, or `#cam:hero`.
  - `#bars:on` / `#bars:off`: Cinematic widescreen letterbox bars ease in/out.
  - `#shake:<0-3>`: Screen shake intensity (0: none to 3: heavy).
  - `#wait:<seconds>`: Timed dramatic pause (up to 3.0 s).
- **Auto-Direction:** Automatically applies cinematic bars for story beats. Matches speaker tags (`@NPC_<ID>_NAME`) to visible NPCs within 160 px and smoothly pans camera up to an 80 px offset.
- **Choices & Consequences:**
  - Dialogue choices execute actions including `remember:<key>`, setting `remember_<key>` flag and emitting `Events.consequence_noted`.
  - Triggers the `UI_Q_REMEMBER` banner ("<Character> will remember that you...") and logs the choice permanently in the Journal's "Choices" section.

### 3.3 Quest Title & Summary Cards (`ui/quest_card.gd`)
- **Main Quest Start:** Full-width cinematic title card displaying act name, quest title, and first-line stakes narrative.
- **Quest Completion:** Summary reward card detailing quest title, Ilmu earned, equipment, flask shards, and codex entries unlocked.

---

## 4. Menus

All menus pause world processing (`process_mode = PROCESS_MODE_ALWAYS` on UI). `Esc` navigates back one level.

### 4.1 Title Screen (Aksara Kala), v3
Same world and palette as the key-art poster, its own composition (not a copy of the poster's gate-and-path shot).
- **Left column:** the logo (`logo.png`) at (36, 32), "The script of time" centred under it in body text, then the menu (Continue when a save exists, New Game, Settings, About, Quit) as heading-face entries with the cyan diamond cursor; the overwrite question replaces the menu in place. ID | EN toggle top right.
- **Settings card** (dusk panel 240x176 at (20, 22); the logo column fades out under it): Audio (Master, Music, Sound effects, Ambience sliders 0-100 in steps of 5 with the value; the name turns cyan while its slider has focus), Display (Fullscreen on/off, Language). Same `user://settings.cfg` keys as the pause menu's Sistem tab, through `ui/game_settings.gd` (`GameSettings`). The saved fullscreen choice is applied at boot by the title screen.
- **About card** (240x226): "Aksara Kala · The script of time"; Made by: Muhammad Fatih Zamzami, Muhammad Nafis Yusa', Fahmi Milan Amyar; Made for: BUDAYA GO! 2026, Kompetisi Inovasi Digital Budaya Indonesia, Kementerian Kebudayaan Republik Indonesia; Built with: Godot Engine, Tiny5, Jersey 10 / 15, Noto Sans (SIL OFL). Names and the competition title are not translated.
- Both cards: Back at the foot, Esc (`ui_cancel`) closes them and focus returns to the menu entry that opened them.
- **Right two thirds, back to front:** the banded dusk sky with twinkling stars (`title_sky`, `Twinkle`); an aksara written in stars (`title_constellation`: Sundanese Ka thinned to a dotted line with stars on its joints, breathing slowly); layered ridges into the peach haze with a far candi on the middle hill (`title_far`); a dark outcrop on the right with palms (`title_near`). The Wiku (`hero_mage.png` back view) stands on the cliff looking out, a faint cyan pool at the staff.
- **Motion:** aksara (`title_glyph_ka/ja/la/ra`) rise from the staff every ~1.7 s, sway and fade over 6 s, whole-pixel positions; cyan motes drift up off the cliff. Intro: up from night, logo rises in, its line, then the menu.
- The window title is set to "Aksara Kala" at runtime, matching the Godot project name.

### 4.2 Class Selection (Elden Style)
- **Left Column:** List of 4 classes (Hulubalang, Pamanah, Pendekar, Wiku; see classes.md "Identity") as heading-face menu entries with the gold diamond cursor.
- **Center Pedestal:** 96x128 animated character sprite standing on stone pedestal in lamp light with floor mist particles. Switching classes dissolves figure into rising ink motes.
- **Right Panel (v2):** ink card 176x214: class name (heading), role (caps label), hairline, description (body, 3 lines), 5 stats as 10 gold pips with the number, weapon well with caps label and name beside it, passive (gold caps label + body).
- **Bottom:** Confirm / Back prompts.

### 4.3 Pause & Tab Menu (Esc / Tab): the field book (redesign 2026-11-08)
Research: scratchpad brief summarised here; sources in ui.md 0 plus Hollow Knight journal/map, Tunic manual, Hades codex, Sea of Stars menus (mostly design practice, thin teardowns).

**Frame (shared by every tab, `ui/menu/menu_book.gd`):**
- **v3 dusk star chart (2026-11-09).** The world dims to night (indigo at ~74%). The "book" fills ~464x248: a dusk cover with a 1 px hairline and cyan corner glints, two indigo pages (`#1A1530`, faint star speckle, ~228 px each) and a dark spine gutter. No parchment, leather, carved corners or kawung tile. Parang Rusak is never used (restricted Yogyakarta court motif).
- **Tabs** stick up from the top edge as dusk pills: icon only, except the open tab, which is taller, cyan-rimmed and named in cyan caps. Closed icons are dim lavender, brighter on hover. Q / E keycaps at the strip ends; click works too.
- **Footer:** a thin night band of context hints: keycaps plus lavender words; hints change per tab and per focus.
- **Grid:** 8 px grid, sizes in multiples of 4, at most 2 type sizes per page: Jersey 10 / 19 headings in `#FFF4E6`, Tiny5 8 body in cool cream, lavender tracked caps for labels and buttons (ui.md 1). Left page = list or figure, right page = detail.
- **Motion:** tab change is a 140 ms page turn (slide + fade of the page contents); the cyan diamond cursor eases 70 ms to its target and snaps to whole pixels; rows highlight with a faint cyan wash and a cyan left edge. All tweens use the pause-safe process mode. TUNE.

**Tabs (7):**
1. **Diri (Status):** left page = the hero's 96x128 class figure (idle frames from `class_<id>.png`) on a painted ground disc, name, class title, level wax seal and Ilmu bar. Right page = the 5 attributes with icon, value, pips and a + right beside each when points can be spent (plus a "points to spend" seal; level-up still only at a Petilasan); a 2-column derived-stat table with icons (Max HP, Stamina, Sakti, ATK, DEF, Jamu); a row of learned glyph tiles.
2. **Perlengkapan (Equipment):** left page = paper-doll outline with Weapon / Armor / Accessory slots around it; right page = iron-rimmed inventory grid and an item card that always shows something (the focused or equipped item) with compare arrows (verdigris up, wax red down).
3. **Catatan (Journal):** left page = quests grouped Utama / Sampingan / Selesai with seal icons and a tracked marker (Track / Untrack on confirm). Right page = title, region, objective checklist using the bullet/check assets (no ASCII markers), story-log paragraph (`_DONE` entries), choices (`remember_*`) and clues grouped by hunt. Long pages scroll inside the page; scroll and selection survive `Game.changed`.
4. **Peta (Map):** a hand-inked pixel world map across both pages (`assets/art/ui/map_world.png` from `tools/gen_map_art.py`): coastline hatching, mountain peaks, rivers, forest stamps, compass rose, legend strip. Undiscovered regions sit under a dithered ink wash. Discovered areas get 8x8 stamps; player and tracked-goal markers. Confirm on an area zooms to the area map: the zone re-rendered in a 4-6 colour ink-on-paper palette (not raw tile colours), framed on the page, with stamp markers (you, goal, person, shrine, chest, clue, exit) and exit labels that never overlap the frame. Back returns to the world map.
5. **Pustaka (Codex):** left page = category ribbons Lore / Makhluk / Aksara, a progress counter (found/total) and a list of lontar-strip rows; undiscovered rows show a silhouette and "???", newly found rows a wax NEW dot (cleared once viewed). Right page = 96x96 illustration frame (enemy sprite, portrait or prop), title, type line, body, weakness line for creatures and a "Sumber" source line when present. The Aksara category shows the glyph large with an animated, replayable stroke-order guide.
6. **Penuntun (Controls, new):** left page = every action with its keycap / mouse glyph, read live from `InputMap`; confirm on an action waits for a new key and swaps on conflict; "Kembalikan bawaan" resets. Bindings save with the settings. Right page = looping diagram of drawing an aksara with the mouse (mouse icon, dotted stroke, start dot, arrow) plus a short how-to.
7. **Sistem (Settings):** grouped Audio (master / music / SFX segmented sliders with a numeric value), Tampilan (fullscreen, window scale x2/x3/x4, screen shake on/off), Aksesibilitas (text speed), Bahasa (ID | EN). "Simpan & Keluar" is a distinct wax-red button.

---

## 5. Visual Styling and Art Direction

v3 "Senja" (section 0.1). The UI is the poster's dusk: indigo night surfaces, a banded twilight sky, cyan glyph light, warm amber for the quest. Cultural touches stay small and true: floating aksara on the title, the Javanese / Sundanese letters where the game teaches them.
- **Palette** (constants in `ui/fx/ui_fx.gd`, art in `tools/gen_ui_dusk.py`):
  - Night surfaces: `#0A0814` outline, `#0C0A18` well, `#141026` fill, `#1A1530` page, `#241C40` raised, `#3A2F5C` hairline.
  - Sky: `#1B1433`, `#2A1D47`, `#3A2456`, `#52305E`, `#6B3A5E`, `#8E4763`, `#B5566A`, `#D27268`, `#E8946A`, `#F2B27A`.
  - Text: `#FFF4E6` head, `#ECE6F2` body, `#A99BC8` label, `#8C83A6` dim.
  - Accent: cyan `#7FE8E0` / halo `#3FB8C0` / deep `#1F6E78`; amber `#F2B27A` / `#C98A52`; rose danger `#E0566A`; green `#8FD9A0`.
  - Gameplay colours (Okabe-Ito HP/stamina/sakti) unchanged.
- **Surfaces:** `ink_panel`, `ink_slot`, `frame_portrait`, `keycap` (lavender-white key, night letter), `continue_arrow` (cyan), `ink_cursor` (5 px cyan diamond), `arrow_objective` (amber chevron), `icon_ilmu` (amber gem); the menu set keeps its `book_*` names but is dusk; `panel`, `button_*`, `slot*`, `lozenge` are dusk too. File names are unchanged from v2 so layouts did not move.
- **Regenerate:** `python3 tools/gen_ui_dusk.py` is the one UI art generator: every file in `assets/art/ui/` (surfaces, menu set, stat and tab icons, HUD flasks, NPC quest/talk markers, cursor, title scene, logo, glyph sprites), `icon.svg` and `tools/ui_dusk_preview.png`. Story props such as `lontar_card.png` (the write card's leaf) are not UI chrome and keep their own generator. The parchment-era generators and art were deleted in v3.
- **App icon:** `icon.svg`, generated as 32x32 pixel art at 4x (SVG rects, crisp edges): banded dusk sky, stars, the ridge on the horizon and Javanese Ka in the cyan glyph light. The boot splash background is the night fill `#141026`.
