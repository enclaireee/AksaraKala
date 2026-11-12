# Assets

Third-party and custom asset manifest, license records, and cultural source documentation.

---

## 1. Art Direction & Visual Standards
- **Pixel Art Standards:** 16x16 characters and tiles, clean outlines, rich palette shading, clear silhouettes.
- **Resolution:** Native viewport 480x270 with integer scaling and Nearest texture filtering ([architecture.md](architecture.md) 1).
- **Color Identity:**
  - Regional color casts: cool greens for Tatar Sunda, regal red-gold teak for Keraton Galuh, warm stone for Mataram, dry volcanic amber for Tanah Timur, deep turquoise for Segara Kidul, ash-violet for Gua Kala.
  - Kelir memories use illuminated warm paper styling (#F2D9A0) and Laras chapters use cool bluish moonlight (#D5E2F0).
- **Cultural Motifs:** Traditional Kawung and batik motifs for UI framing, wayang shadow silhouettes for memory scenes, authentic candi and vernacular architectural roof styles (julang ngapak, joglo, limasan).

---

## 2. Asset Roster & Current Implementation Status
- [x] **Character & Class Sprites:** Hero base + 4 class archetypes with unique gear, idle, walk, attack, hurt, dodge, and death frames.
- [x] **Class Selection Portraits:** 96x128 animated portrait figures for Warrior, Archer, Rogue, and Mage standing on stone pedestals.
- [x] **Regional Tilesets:** 7 full regional 128x256 tilesets (896 tiles across 21 sub-biomes) for Desa Purwa, Sunda, Galuh, Mataram, Timur, Kidul, and Gua Kala.
- [x] **Bestiary Sprites:** 34 enemy spritesheets (Chasers, Shooters, Chargers, Tanks, Elites) and 10 multi-phase boss sheets.
- [x] **Vernacular Architecture:** Composed building kits (`zones/buildings.gd`, `tools/gen_buildings.py`) for Sunda, Galuh, Mataram, and Kidul houses and warung stalls.
- [x] **Living Towns & Ambient Sprites:** Ambient villagers with varied attire, children, domestic animals (cats, goats, chickens, kerbau), and atmospheric smoke/goods.
- [x] **Items & Equipment:** 32 dedicated 16x16 item icons (`tools/gen_item_icons.py`) covering all weapons, armors, accessories, and mythic pusaka.
- [x] **UI Theme & Frames (v3 "Senja"):** dusk panels, menu star-chart set, stat and tab icons, HUD flasks, NPC markers, objective arrow, title scene, logo and app icon, all from `tools/gen_ui_dusk.py` ([ui.md](ui.md) 0.1, 5).
- [x] **Revamp art (2026-11-10, `tools/gen_revamp_art.py` v2 house-style redraw, `tools/gen_map_art.py`):** K0 screen, Kala (3 poses), shadow tide, lamp glow/burst/hint, pointing hand; player facing pointer per archetype, arrow, spirit shot, thrown rock, chest, kabut, pillar, oncor, curse stake, pouch fields, arena post; world map, fog, map icons. Still code-drawn on purpose: boss telegraph shapes (they are sized at runtime), NPC quest markers and villager emotes (pixel rects), generic pickup/clue fallbacks.
- [x] **Wayang & Memory Scenes:** Silhouetted stand-ins for the hero and Laras, Faceless patrols, memory spots, and blencong lighting overlays.
- [x] **SFX & Music (first pass):** recorded sfx and ambience, downloaded set-piece music, sampled region music (`tools/build_audio.py`, `tools/gen_music.py`, [audio.md](audio.md)); [ ] tune by ear in the engine, final mastering.

---

## 3. Third-Party Licenses & Font Attribution
All fonts and assets adhere to open-source or permissive licenses:

| Asset | Source URL | License | Usage in Budayago | Attribution Status |
|---|---|---|---|---|
| **Tiny5** | https://github.com/google/fonts/tree/main/ofl/tiny5 | SIL OFL 1.1 | Body text, labels, dialogue, HUD, menus (8 px) | Shipped (`assets/fonts/OFL_Tiny5.txt`) |
| **Jersey 10 / Jersey 15** | https://github.com/google/fonts/tree/main/ofl/jersey10 | SIL OFL 1.1 | Headings (10 at 19), display titles (15 at 27) | Shipped (`assets/fonts/OFL_Jersey.txt`) |
| **Noto Sans Sundanese** | https://github.com/google/fonts/tree/main/ofl | SIL OFL 1.1 | Aksara Sunda character rendering | Shipped |
| **Noto Sans Javanese** | https://github.com/google/fonts/tree/main/ofl | SIL OFL 1.1 | Aksara Jawa character rendering | Shipped |
| **Dungeon Tileset II** | https://0x72.itch.io/dungeontileset-ii | CC0 | Prototyping reference | CC0 Public Domain |

*(Note: UI type is pixel fonts only, at their grid sizes ([ui.md](ui.md) 1). Almendra and Crimson Pro were removed in UI v3; the game logo is pixel art, not a font.)*

---

## 4. Cultural & Audio References

### 4.1 Audio Sources & Recording
- **Sources and credits per sound are in `tools/audio/sources/{sfx,amb,music}.json`** (`credits` keys; set-piece music is Kevin MacLeod, incompetech.com, CC BY 4.0; instrument multisamples are VSCO-2 CE and VCSL, CC0). They are not cleared for release: check every licence before the game goes public. See [audio.md](audio.md).
- **Not used yet (candidates if recordings replace the generator):** "Kendang, Kendhang or Gendang" by redafs (Freesound 348234), **CC BY 4.0** (attribution required); Demung hits by duniapanggung (Freesound), CC0. Original recordings or commissioned degung and gamelan would replace files one by one; ids and code stay the same.

### 4.2 Verified Folklore Sources (Secondary Research)
- **Aksara & Epigraphy:**
  - Javanese Hanacaraka script and Aji Saka tradition (Museum Sonobudoyo records).
  - Sundanese Kaganga script and historical manuscripts (Kairaga epigraphy documentation).
- **Folklore & Oral Traditions:**
  - *Sangkuriang & Dayang Sumbi* (Tangkuban Perahu legends, West Java).
  - *Ciung Wanara & Hariang Banga* (Keraton Galuh traditions, Ciamis).
  - *Roro Jonggrang & Bandung Bondowoso* (Candi Prambanan oral history).
  - *Timun Mas & Buto Ijo* (Javanese moral folktales).
  - *Ken Arok & Keris Mpu Gandring* (Pararaton chronicle summaries).
  - *Nyi Roro Kidul & The Southern Sea* (Javanese coastal maritime heritage).
  - *Murwakala & Wayang Ruwatan* (Batara Kala purification performance traditions).
- **UNESCO Intangible Cultural Heritage Records:**
  - Wayang Puppet Theatre (2008), Indonesian Kris (2008), Indonesian Batik (2009), Angklung (2010), Gamelan (2021), Jamu Wellness Culture (2023).
