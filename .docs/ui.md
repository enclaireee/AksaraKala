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
- **Class choice:** after New Game, 4 class cards (name, description, stats, start weapon, passive), then a confirm ([classes.md](classes.md)).
- **Death:** fade to black, "Gugur / Fallen", one-line folklore tip (stretch), back at the petilasan ([rpg.md](rpg.md) 7).
- **Ending:** the epilogue at the wayang stage, then credits ([quests.md](quests.md) MQ5).

## 4. Open
- Test the HUD sizes on the real canvas in Phase 1 and tune.
- Font characters (é) and the m6x11 license, above.
