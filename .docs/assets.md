# Assets

Log every third-party asset here the moment it is added. Check the license before shipping.

## Art direction
- Pixel art in the Soul Knight style: 16x16 characters and tiles, clean dark outlines, 3-4 shades per color, bright readable colors.
- Base viewport 480x270, integer-scaled. See [architecture.md](architecture.md).
- One shared palette across the game (target 32 colors, **TUNE**), with a regional tint per zone (cool greens for Sunda, warm stone for Mataram, dry gold for Tanah Timur, deep blue-green for Segara Kidul, pale-gold marble for Keraton Galuh, ash and violet for Gua Kala). Kelir memories use a separate warm paper look and Laras chapters a cool blue one ([architecture.md](architecture.md) 9b).
- Culture-forward visual motifs: batik patterns for UI frames, wayang shadow silhouettes for cutscenes, candi stone for ruins.

## Sources and plan
| Need | Source | Notes |
|------|--------|-------|
| Characters, enemies, tiles (bulk) | Free pixel pack(s), chosen first | Pick the pack before making custom assets. Match palette and size |
| Culture items, icons, UI, effects | Custom (generated/coded by Claude, drawn by the developer) | Keris, kujang, batik tiles, aksara glyph art, HUD |
| Player base sprite | Custom, see sample | A 16x16 sample with a 4-frame walk exists as a quality reference (scratchpad, not in the repo) |
| Sound effects | Synthesized with a script, or sfxr/jsfxr | Hit, dodge, pickup, cast, checkpoint, UI |
| Music | Free tracks, plus any gamelan/angklung samples with a clear license | **VERIFY** licenses. Do not use unlicensed gamelan recordings |
| Fonts (aksara) | Noto Sans Javanese, Noto Sans Sundanese (SIL OFL), Latin text uses a clean smooth sans, chosen in the art pass (the m5x7 pixel font plan was dropped, [ui.md](ui.md) 1) | Test rendering in Godot early |
| Wayang prologue | Custom silhouettes | Simple shapes, high impact |

## Asset checklist (to be filled as work progresses)
- [ ] Player base + 4 class variants (idle, walk, attack, hurt, dodge, death)
- [ ] 6 region tilesets (Sunda, Galuh, Mataram, Timur, Kidul, Gua Kala) plus Desa Purwa, for 49 areas ([world.md](world.md)); only `sunda_tiles.png` and a placeholder sheet exist
- [ ] ~12 enemy types, 11 main-path boss sprites (Sandekala, Faceless Captain, Sangkuriang, Barma Wijaya, Bondowoso, Hariang Banga, Buto Ijo, Keris Mpu Gandring, the Nameless Hunter, the Sea Trial set pieces, Batara Kala)
- [ ] NPCs (Semar, Cepot, elders, dalang, empu; Story v5 adds Nyai Sekar, Nyai Gendhis, Ratna, Sari and Ranga, [quests.md](quests.md) 8)
- [ ] Weapons, armor and accessories icons (about 32, the number of `data/items/*.tres`)
- [ ] HUD, menus, codex frame, dialogue box
- [ ] Glyph art (stylized and true form) for each glyph
- [ ] Kelir memory silhouettes, Laras stand-in and Faceless patrol sprites (flat near-black, [architecture.md](architecture.md) 9b)
- [ ] Effects: ink trail, spell effects, hit flash, particles
- [ ] SFX (about 30) and music (about 6 tracks)

## Third-party log
| Asset | Source URL | License | Used for | Attribution needed? |
|-------|-----------|---------|----------|---------------------|
| Cinzel | https://github.com/google/fonts/tree/main/ofl/cinzel | OFL 1.1 | title, headings | license text shipped (`assets/fonts/OFL_Cinzel.txt`) |
| Alegreya Sans | https://github.com/google/fonts/tree/main/ofl/alegreyasans | OFL 1.1 | body, dialogue, HUD | license text shipped |
| Noto Sans Sundanese, Noto Sans Javanese | https://github.com/google/fonts/tree/main/ofl | OFL 1.1 | aksara | license text shipped |
| _example: 0x72 Dungeon Tileset II_ | https://0x72.itch.io/dungeontileset-ii | CC0 | tiles, characters | no |

## Reference sources for cultural content (to be filled)
Keep a list of the books, museum pages, official sites and expert reviews used for the legends and script details, so the codex can cite them.

### Audio sources (checked 2026-11-05)
- Kendang hits: "Kendang, Kendhang or Gendang" by redafs, Freesound 348234, **CC BY 4.0** (credit redafs). A 5 s take, cut into single hits.
- Gamelan tones: CC0 demung hits by duniapanggung on Freesound. Skip "demung 6" (flagged on the site).
- No CC0 or CC-BY degung or Sundanese gamelan found: compose or commission the zone music. CC0 Balinese gamelan loops exist (qubodup) but are Balinese, so do not use them for Sunda or Java.
- Re-check each license page when downloading.

### Fact-check log (Nov 2026, secondary sources only)
- Aksara: Wikipedia "Javanese script", "Sundanese script", "Aji Saka"; Sono Budoyo page on Aji Saka; Noto fonts SIL OFL 1.1.
- Legends: Wikipedia "Sangkuriang", "Mpu Gandring", "Ken Arok", "Timun Mas", "Batara Kala", "Nyai Roro Kidul", "Cepot", "Panakawan", "Semar", "Wewe Gombel", "Kujang"; indonesia.travel (Prambanan, UNESCO list); detik.com on ruwatan.
- UNESCO: keris 2008, wayang 2008, batik 2009, angklung 2010, gamelan 2021, pencak silat 2019, reog and kebaya 2024.
- Still open: Pararaton primary text, a school curriculum check on Sangkuriang, glyph shape references, expert review.
