# UI: HUD and Menus

Canvas 480x270, integer-scaled (`canvas_items` stretch mode, `Nearest` texture filtering). Layout follows genre standards (Hyper Light Drifter, Death's Door, Elden Ring UI conventions): vitals top-left, center clear, immersive and quiet presentation. Theme: parchment and ink, stitched leather, riveted iron, wax-red accents (retheme 2026-11; the gold wayang set is gone).

---

## 0. Design Principles (researched 2026-11)
Sources: [diegetic interfaces](https://www.wayline.io/blog/diegetic-interfaces-game-design), [Game UI Design guide](https://madegooddesigns.com/?p=5485), [pixel-art GUI at 480x270 x4](https://forum.defold.com/t/gui-for-pixel-art-games-heres-how/77704), [Persona 5 UI study](https://itch.io/blog/533534/making-ui-come-to-life-study-of-persona-5), [Hyper Light Drifter guidance review](https://medium.com/cortes-studio/hyper-light-drifter-guidance-design-review-and-analysis-5fb69f8ed786). Evidence was thin and mostly general guidance.
1. The HUD is read peripherally: quiet, edge-anchored, and faded when not needed (already true: dialogue focus, stamina auto-hide).
2. Style is identity but never costs readability (Persona 5 caution): one gold-lacquer wayang language, strong silhouettes for icons.
3. Stay on the 480x270 grid: sizes in multiples of 4 or 8, whole-pixel positions, nine-patch frames.
4. Dialogue gives the speaker a face. Portraits are the one big addition of the redesign.
5. Bars carry shading and rhythm (lit top row, dark bottom row, ticks) so they read as objects, not flat rectangles.

## 1. Typography and Text
- **Latin text: smooth vector fonts (OFL, `assets/fonts/OFL_CrimsonPro.txt`, `OFL_Almendra.txt`).**
  - `CrimsonPro` (variable font) and `CrimsonPro-Italic`: body text, dialogue, HUD, menus, 7-8 px; bold is the same file at weight 700 (`FontVariation` in `theme.tres` and `UIFx.cinzel()`), used for headings, tabs, buttons and menu entries up to 16 px. Semar's narration uses the italic in soft ink (#5A4430) on paper.
  - `Almendra-Bold` (`UIFx.display()`): big titles only (logo, area and quest titles, "Fallen"). It is quirky and faint below about 20 px, so it is never used for small text.
  - Text on paper is plain ink with no outline. Text on dark scenes or over the world keeps a dark outline (#140E0A).
- **Aksara fonts:** `Noto Sans Sundanese` and `Noto Sans Javanese` (SIL OFL) for the scripts.
- The old Alegreya Sans and Cinzel files were deleted. `Jersey10/15` remain unused (the pixel-font pass was reverted).

---

## 2. In-Game HUD

Safe margins: 6 px from window borders. The central 240x140 px play space remains unobstructed.

### 2.1 Elements
| Element | Location | Dimensions | Description |
|---|---|---|---|
| **Vitals (HP)** | Top-left (6, 6) | 96x9 | Vermillion bar (#D55E00), shaded (lit top row, dark bottom row) with ruler ticks every 12 px, internal "HP/Max" text. Pulses below 25% HP. Lag-chunk drain animation. |
| **Stamina** | Below HP, 2 px gap | 64x3 | Yellow bar (#F0E442). Hidden when full for >2 s; reveals immediately on consumption. |
| **Sakti Gauge** | Below stamina, 2 px gap | 50x3 (Mage: 60x3) | Sky blue bar (#56B4E9). Tick mark at 15 (14 for Mage/Rogue) indicates minimum cast requirement. |
| **Tracker Strip** | Top-left (6, 58) | 118 px wide | Slim dark strip (55% black, 1 px gold left edge), no frame art, so it hides little of the world. Quest title in 7 px gold caps (main) or cream (side), then one objective row with the `bullet_now` icon in 8 px cream with a 1 px outline. Shows only the active objective, with `n/m` for checklists. Flashes gold and goes full opacity on any change, then dims to 50% after 5 s. |
| **Quest Banner** | Top-center, y=24 | Centered text | Queued notifications for `NEW QUEST`, `QUEST UPDATED`, `QUEST COMPLETE`, and `UI_Q_REMEMBER` consequence alerts. Item and glyph toasts queue alongside. |
| **Flask** | Bottom-left | 6 slots, 7x9 each | Bluish green. Full = bright (`flask_full.png`), empty = dim outline (`flask_empty.png`). Locked slots hidden. |
| **Weapon Well** | Right of Flask | 16x16 | Current equipped weapon icon in a recessed slot (`slot.png`). |
| **Ilmu Counter** | Top-right (6 px margin) | 8 px icon + number | Lacquer plate with pale gold counter. Animates upward on pickup. Accompanied by quiet `[Esc] Menu` indicator. |
| **Boss Bar** | Bottom-center, 18 px from bottom | 240x5 | Boss name in Almendra Display 10 above bar. 50% phase tick. When `laras_sabotage:*` flag is set, displays cracked glyph icon at bar edge indicating vulnerable state. |
| **World Guidance** | Screen-edge / World | Variable | Screen-edge arrow with distance in meters (1 tile = 1 m). If target is in another region/zone, displays `-> <zone name>`. When target is on-screen, a floating gold diamond appears 46 px above target with distance pill. |
| **World Prompts** | World space above interactable | 10x10 keycap + text | 10x10 pixel keycap sprite with key letter + 10 px verb. Shown only for the nearest overlapping interactable. |
| **Save Icon** | Bottom-right | 8x8 brush | "Tersimpan / Saved" indicator displayed for 1.0 s on autosave. |

### 2.2 Dynamic States
- **Dialogue Focus:** While dialogue is active, the Tracker card, Flasks, Weapon well, Ilmu counter, the vitals plaque, the Saved badge and screen hints all fade out to 0% alpha over 0.2 s.
- **Cast Mode Overlay:** Vignette, ink drawing cursor, dynamic ink trail, and ghost guide in sanggar practice. Main HUD dims to 50%.
- **Blocked Feedback:** Attempting actions without stamina, without sakti, or using empty flask flashes the respective gauge red for 0.25 s.

---

## 3. Dialogue & Scene Staging

### 3.1 Dialogue Box
- **Dimensions & Anchor:** 424 px wide, anchored 6 px above screen bottom, auto-sizing in height (min 40 px, max 3 lines of dialogue plus choice options).
- **Speaker Plate:** Sits on top edge of dialogue frame. First encounter with a named NPC displays their descriptor tag (`NPC_<ID>_WHO`) beside their name plate (e.g., "Cepot. Anak Semar. Riuh.").
- **Speaker Portrait (redesign 2026-11-08):** a 56x56 `frame_portrait` holding a 48x48 bust (`assets/art/portraits/p_<name>.png`, from `tools/gen_speaker_portraits.py`) sits over the box's top-left corner, overlapping it by 8 px; the name plate steps right of it (x+66). Busts are 3/4 view facing right (toward the text), one top-left light, outline on the outside only, warm hue-shifted skin ramps (shadows go red-violet, never grey), eyes with white, iris and a highlight, brows separate from lids. Indonesian headwear only (iket, blangkon, kerudung, konde, siger, kuluk); no European crowns. Spirits: Kala a red wayang giant, the faceless spirit a shaded featureless head, Semar and Cepot shaded like wayang golek. Each bust has expression variants `p_<name>_<mood>.png` for happy / angry / sad (neutral is the base file); a dialogue line tag `#face:<mood>` picks one and falls back to neutral. 22 archetype busts; `ui/portraits.gd` maps speaker ids to them (ASSUMED picks for minor NPCs); speakers with no entry show no face and the plate keeps its old position.
- **Advancement:** Typewriter text progression, instant complete on press, `[E] Continue` blinking cursor.

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

### 4.1 Title Screen (Aksara Kala)
- An open leather-bound book on a dark wooden desk, lit by a flickering candle at the right; a quill and ink pot, a rolled scroll and a wax seal lie on the desk; dust motes drift up through the candlelight. Art: `title_desk`, `title_book`, `title_candle`, `title_inkpot`, `title_scroll`, `title_seal` (`tools/gen_title_book.py`).
- Left page: the logo "AKSARA KALA" inked in with a left-to-right wipe, subtitle "The Script of Time", a divider, and the word "aksara" in Javanese and Sundanese script.
- Left page also has an ink sketch (hills, sun, river). Right page: menu entries (Continue when a save exists, New Game, Quit) in bold ink with a wax-red diamond cursor; the overwrite question replaces the menu on the same page. Below the menu the 20 Javanese hanacaraka letters appear one by one and one glows wax red at a time.
- ID | EN language toggle on the desk, top right. The window title is set to "Aksara Kala" at runtime, matching the Godot project name.

### 4.2 Class Selection (Elden Style)
- **Left Column:** List of 4 classes (Hulubalang, Pamanah, Pendekar, Wiku; see classes.md "Identity") in Almendra Display 10 with wax-red lozenge selector.
- **Center Pedestal:** 96x128 animated character sprite standing on stone pedestal in lamp light with floor mist particles. Switching classes dissolves figure into rising ink motes.
- **Right Panel:** Framed panel detailing class title, archetype description, segmented animated stat bars (Vit, End, Str, Dex, Spi), starting weapon icon, and unique passive.
- **Bottom:** Confirm / Back prompts.

### 4.3 Pause & Tab Menu (Esc / Tab): the field book (redesign 2026-11-08)
Research: scratchpad brief summarised here; sources in ui.md 0 plus Hollow Knight journal/map, Tunic manual, Hades codex, Sea of Stars menus (mostly design practice, thin teardowns).

**Frame (shared by every tab, `ui/menu/menu_book.gd`):**
- The game dims to ~60% with a vignette. An open book fills ~464x246: a 4 px stitched leather cover edge, two parchment pages (~216 px each) and a centre spine gutter shadow. Ornament only on the outer frame: small carved (ukiran) corner pieces and a very faint kawung paper tile. Parang Rusak is never used (restricted Yogyakarta court motif).
- **Tab ribbons** stick up from the book's top edge: icon only, except the open tab, which is taller, paper coloured and labelled. Q / E keycaps at the strip ends; click works too.
- **Footer:** a thin leather band of context hints drawn with the keycap assets plus words; hints change per tab and per focus.
- **Grid:** 8 px grid, sizes in multiples of 4, at most 2 type sizes per page (Almendra headings in ink red, Crimson Pro body, Jersey10 for numbers). Left page = list or figure, right page = detail.
- **Motion:** tab change is a 140 ms page turn (slide + fade of the page contents) with a paper SFX if one exists; the wax-red diamond cursor eases 70 ms to its target and snaps to whole pixels; new text inks in. All tweens use the pause-safe process mode. TUNE.

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

The UI is a fantasy field book: ink on parchment, stitched leather, riveted iron, wax seals. Cultural touches in the UI are deliberately tiny (the Javanese and Sundanese "aksara" line on the title page, the Ka wax seal).
- **Palette** (generated in `tools/gen_ui_rpg.py`, constants in `ui/fx/ui_fx.gd`):
  - Paper: `#F1E4BE` hi, `#E3D0A0` base, `#D2BC88`, `#B89F6C` burnt edge, `#8F7648`.
  - Ink: `#2A1C12` text, `#7A2A1E` headings (ink red), `#6B5A44` secondary, `#8A7656` faded.
  - Leather: `#7C5333` hi, `#5A3A22`, `#3A2314`, `#22140C`; stitch thread `#D8B878`.
  - Iron: `#B4B9BE`, `#7A7F86`, `#40444A`, `#24272B`.
  - Wax red: `#C9473B` hi, `#9E2B25`, `#5E1814`. Verdigris `#3F7A66` for "done".
  - On dark scenes: bright paper `#F3E3B8` headings, cream `#EADFC4` body, dim `#A59A82`.
  - Gameplay colours (Okabe-Ito HP/stamina/sakti) are unchanged for readability.
- **Surfaces:** paper panels (`panel.png` 6 px, `panel_dialogue.png` 8 px margins) with a stitched leather band and iron studs; leather buttons (`button_*`, 5 px); the open menu tab is paper, closed tabs are leather; item slots are iron-rimmed wells (`slot*.png`), selected = wax-red rim; `inset.png` is the sunken paper well of the menu; `hud_plate.png` is the dark leather plaque behind the vitals; portraits sit in `frame_portrait.png`.
- **Vitals:** a leather plaque holds the HP bar (wax-seal heart badge, shaded fill, ticks every 12 px) and the thin stamina and sakti bars in iron frames.
- Regenerate: `python3 tools/gen_ui.py` (scenery, old set) then `python3 tools/gen_ui_rpg.py` (the theme; run it last) and `python3 tools/gen_title_book.py` (main screen).
