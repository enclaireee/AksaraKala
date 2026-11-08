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
- [x] **UI Theme & Frames:** Flat lacquer frames, Kawung corners, lozenge buttons, dialogue panels, quest markers, and objective indicators (`tools/gen_ui.py`).
- [x] **Wayang & Memory Scenes:** Silhouetted stand-ins for the hero and Laras, Faceless patrols, memory spots, and blencong lighting overlays.
- [ ] **SFX & Music:** Final audio composition and mastering pass.

---

## 3. Third-Party Licenses & Font Attribution
All fonts and assets adhere to open-source or permissive licenses:

| Asset | Source URL | License | Usage in Budayago | Attribution Status |
|---|---|---|---|---|
| **Almendra Display** | https://github.com/google/fonts/tree/main/ofl/cinzel | SIL OFL 1.1 | Title screen, headings, quest cards, boss titles | Shipped (`assets/fonts/OFL_Almendra Display.txt`) |
| **Alegreya Sans** | https://github.com/google/fonts/tree/main/ofl/alegreyasans | SIL OFL 1.1 | Body text, dialogue, HUD labels, item descriptions, menus | Shipped |
| **Noto Sans Sundanese** | https://github.com/google/fonts/tree/main/ofl | SIL OFL 1.1 | Aksara Sunda character rendering | Shipped |
| **Noto Sans Javanese** | https://github.com/google/fonts/tree/main/ofl | SIL OFL 1.1 | Aksara Jawa character rendering | Shipped |
| **Dungeon Tileset II** | https://0x72.itch.io/dungeontileset-ii | CC0 | Prototyping reference | CC0 Public Domain |

*(Note: The experimental Jersey 10/15 pixel fonts were reverted in favor of Alegreya Sans and Almendra Display for smooth text rendering at all resolutions.)*

---

## 4. Cultural & Audio References

### 4.1 Audio Sources & Recording
- **Kendang Hits:** "Kendang, Kendhang or Gendang" by redafs (Freesound 348234), **CC BY 4.0**.
- **Gamelan Tones:** Demung hits by duniapanggung (Freesound), CC0.
- **Traditional Instruments:** Original recordings and commissioned Sundanese degung and Javanese gamelan motifs.

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
