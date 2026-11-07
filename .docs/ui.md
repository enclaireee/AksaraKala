# UI: HUD and Menus

Canvas 480x270, integer-scaled (`canvas_items` stretch mode, `Nearest` texture filtering). Layout follows genre standards (Hyper Light Drifter, Death's Door, Elden Ring UI conventions): vitals top-left, center clear, immersive and quiet presentation.

---

## 1. Typography and Text
- **Latin text: smooth vector fonts.**
  - `AlegreyaSans-Regular` / `Bold` / `Italic`: Body text, dialogue, HUD elements, menu descriptions, 7–8 px. Semar's narration uses `Italic` in pale cream (#F2E6C4).
  - `Cinzel-Regular` / `Bold`: Headings, area and quest titles, boss names (10–16 px), quest title cards, title logo (20–28 px).
  - Font antialiasing and sub-pixel positioning use Godot defaults (Grayscale, Auto), rendering smoothly at window resolution.
  - Text rendered over the world features a 1 px dark outline (#0E0B0A).
- **Aksara fonts:**
  - `Noto Sans Sundanese` and `Noto Sans Javanese` (SIL OFL) for Sundanese and Javanese scripts.

---

## 2. In-Game HUD

Safe margins: 6 px from window borders. The central 240x140 px play space remains unobstructed.

### 2.1 Elements
| Element | Location | Dimensions | Description |
|---|---|---|---|
| **Vitals (HP)** | Top-left (6, 6) | 96x9 | Vermillion bar (#D55E00) with internal "HP/Max" text. Pulses below 25% HP. Lag-chunk drain animation. |
| **Stamina** | Below HP, 2 px gap | 64x3 | Yellow bar (#F0E442). Hidden when full for >2 s; reveals immediately on consumption. |
| **Sakti Gauge** | Below stamina, 2 px gap | 50x3 (Mage: 60x3) | Sky blue bar (#56B4E9). Tick mark at 15 (14 for Mage/Rogue) indicates minimum cast requirement. |
| **Tracker Card** | Top-left (6, 44) | 156 px wide | Framed panel (`panel.png`). Shows tracked quest title in Cinzel, gold rule, followed by objective rows: `bullet_now` (active, gold), `bullet_check` (completed, dim), `bullet_open` (uncompleted). At most 4 lines then `+N more`. Displays `n/count` for counted objectives, followed by `_HINT` tutorial text when applicable. |
| **Quest Banner** | Top-center, y=24 | Centered text | Queued notifications for `NEW QUEST`, `QUEST UPDATED`, `QUEST COMPLETE`, and `UI_Q_REMEMBER` consequence alerts. Item and glyph toasts queue alongside. |
| **Flask** | Bottom-left | 6 slots, 7x9 each | Bluish green. Full = bright (`flask_full.png`), empty = dim outline (`flask_empty.png`). Locked slots hidden. |
| **Weapon Well** | Right of Flask | 16x16 | Current equipped weapon icon in a recessed slot (`slot.png`). |
| **Ilmu Counter** | Top-right (6 px margin) | 8 px icon + number | Lacquer plate with pale gold counter. Animates upward on pickup. Accompanied by quiet `[Esc] Menu` indicator. |
| **Boss Bar** | Bottom-center, 18 px from bottom | 240x5 | Boss name in Cinzel 10 above bar. 50% phase tick. When `laras_sabotage:*` flag is set, displays cracked glyph icon at bar edge indicating vulnerable state. |
| **World Guidance** | Screen-edge / World | Variable | Screen-edge arrow with distance in meters (1 tile = 1 m). If target is in another region/zone, displays `-> <zone name>`. When target is on-screen, a floating gold diamond appears 46 px above target with distance pill. |
| **World Prompts** | World space above interactable | 10x10 keycap + text | 10x10 pixel keycap sprite with key letter + 10 px verb. Shown only for the nearest overlapping interactable. |
| **Save Icon** | Bottom-right | 8x8 brush | "Tersimpan / Saved" indicator displayed for 1.0 s on autosave. |

### 2.2 Dynamic States
- **Dialogue Focus:** While dialogue is active, the Tracker card, Flasks, Weapon well, Ilmu counter, and screen hints fade out to 0% alpha over 0.2 s. Vitals dim to 40%.
- **Cast Mode Overlay:** Vignette, ink drawing cursor, dynamic ink trail, and ghost guide in sanggar practice. Main HUD dims to 50%.
- **Blocked Feedback:** Attempting actions without stamina, without sakti, or using empty flask flashes the respective gauge red for 0.25 s.

---

## 3. Dialogue & Scene Staging

### 3.1 Dialogue Box
- **Dimensions & Anchor:** 424 px wide, anchored 6 px above screen bottom, auto-sizing in height (min 40 px, max 3 lines of dialogue plus choice options).
- **Speaker Plate:** Sits on top edge of dialogue frame. First encounter with a named NPC displays their descriptor tag (`NPC_<ID>_WHO`) beside their name plate (e.g., "Cepot. Anak Semar. Riuh.").
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

### 4.1 Title Screen
- Parallax layers (`title_sky`, `title_mountains`, `title_gunungan`) drifting slowly.
- Blencong lamp flickering lighting, rising ember particles.
- BUDAYAGO title in Cinzel 28 with ink-reveal shader.
- Menu entries: Continue (enabled when save exists), New Game, Settings, Quit.

### 4.2 Class Selection (Elden Style)
- **Left Column:** List of 4 classes (Warrior, Archer, Rogue, Mage) in Cinzel 10 with gold lozenge selector.
- **Center Pedestal:** 96x128 animated character sprite standing on stone pedestal in lamp light with floor mist particles. Switching classes dissolves figure into rising ink motes.
- **Right Panel:** Framed panel detailing class title, archetype description, segmented animated stat bars (Vit, End, Str, Dex, Spi), starting weapon icon, and unique passive.
- **Bottom:** Confirm / Back prompts.

### 4.3 Pause & Tab Menu (Esc / Tab)
460x250 panel on 62% dim background with a dedicated left rail navigation:
- **Left Rail Tabs (Q/E or click):**
  1. **Status:** Character stats, current level, Ingatan rank. Level-up confirmation available when at a Petilasan.
  2. **Perlengkapan (Equipment):** 20x20 slot inventory grid for Weapon, Armor, and Accessory slots with comparison tooltips (green stat increase, red decrease).
  3. **Catatan (Journal):**
     - Track / Untrack button for selected quest.
     - **Story Log:** Growing narrative paragraph summarizing completed steps (`_DONE` entries) and active objective.
     - **Choices:** Log of all major story choices made (`remember_*`).
     - **Clues:** Examined clues grouped by hunt with notes and unlocked memories.
  4. **Peta (Map):** Regional map view with discovered landmarks and connections.
  5. **Pustaka (Codex):** Cultural lore, enemy dossiers, discovered glyphs with animated stroke guides, and unlocked weaknesses.
  6. **Sistem (Settings):** Audio master/music/SFX sliders, display resolution/fullscreen, accessibility controls, and Indonesian/English language toggle.

---

## 5. Visual Styling and Art Direction

The UI evokes an illuminated Wayang Kelir shadow play at night—lacquered teak, prada gold gilding, and warm paper tones.
- **Palette:**
  - Lacquer Black (`#0E0B0A`, 92% alpha): Panel backdrops.
  - Sogan Brown (`#3A2618`): Recessed wells and inner frames.
  - Prada Gold (`#C9A24A`, Highlight `#F2D488`, Shadow `#7A5A22`): Borders, active tabs, heading accents.
  - Cream (`#EDE3CC`): Body text.
  - Dim Sepia (`#9C8F78`): Secondary text and uncompleted objectives.
  - Indigo (`#1F2A44`): Selection focus and cast mode tint.
- **Frames (`NinePatchRect` / `StyleBoxTexture`):**
  - Crisp 1 px borders with stepped corners and traditional Kawung motif accents (`panel.png`, `panel_dialogue.png`, `button_*.png`, `tab_*.png`, `slot.png`).
