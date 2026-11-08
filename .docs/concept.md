# Concept: Aksara Kala

**Title:** Aksara Kala (The Script of Time)  
**Genre:** Top-down 2D action RPG featuring real-time combat, responsive movement, and classic RPG depth (connected world, character stats, equipment, checkpoints, NPCs, quests).  
**Engine:** Godot 4.7. **Platform:** PC (macOS, Windows, Linux), with Web export planned.  
**Setting:** The mythical lands of Sunda and Java, rooted in classical folklore, architecture, and living heritage.

---

## Deskripsi Singkat & Pitch
Aksara Kala (The Script of Time) adalah game RPG petualangan berbasis legenda Nusantara. Pelajari dan tulis aksara tradisional Jawa dan Sunda yang hilang, merapalkannya sebagai mantra dinamis untuk memecahkan kutukan lupa kuno dan menyelamatkan adikmu, Laras.

---

## Akar Budaya & Makna Judul (Bobot Budaya 25%)
Nama **Aksara Kala** berakar langsung pada mitologi dan tradisi Nusantara:
- ***Aksara*** adalah tulisan tradisional (Aksara Sunda dan Aksara Jawa) yang di dalam game menjadi sumber sihir dan penjaga nama. Setiap goresan yang dipelajari dan digambar pemain berfungsi memulihkan jati diri serta ingatan dunia yang terhapus oleh kutukan.
- ***Kala*** merujuk kepada Batara Kala, figur mitologis penjaga waktu dan takdir, sekaligus secara harfiah berarti "waktu".

Penjelasan ini menunjukkan judul karya memiliki akar budaya yang kokoh dan menyatu dengan inti mekanik serta narasi, bukan sekadar label estetika.

---

## Pillars
1. **Learn the Script by Using It:** Drawing aksara characters with the mouse is the central combat gimmick and progression system.
2. **Folklore is the World, Not Mere Decoration:** Regions, enemies, bosses, legendary pusaka heirlooms, and NPCs are deeply rooted in classical tales.
3. **Responsive, Readable, Satisfying Action:** Crisp real-time combat featuring attack combos, dodging with i-frames, perfect-dodge rewards, and impactful audio-visual feedback.
4. **Cultural Accuracy & Respect:** Every folklore element, legend retelling, and script stroke is verified against authentic sources and documented in the in-game Codex.

---

## Core Loop
Explore interconnected regions -> Fight folklore-inspired enemies using weapons and drawn aksara spells -> Earn Ilmu and discover gear -> Rest at Petilasan shrines (heal, replenish flask, level up, equip gear) -> Master new glyphs -> Confront regional bosses -> Progress the story.

---

## The Gimmick: Aksara Casting
Hold the cast key/button to enter slow-motion time dilation, then draw an Aksara Sunda or Aksara Jawa character with the mouse. An in-engine point-cloud gesture recognizer classifies the stroke and executes the corresponding spell. Full design: [spells.md](spells.md).

---

## Character & Archetypes
The player names their custom hero. During the prologue, they select one of four core classes ([classes.md](classes.md)):
- **Warrior:** High durability, heavy melee broadswords, crowd-clearing radial shockwaves.
- **Archer:** Precision kiting, long-range bows, piercing multi-arrow spell fans.
- **Rogue:** Lethal flanking, agile daggers, backstab damage bonuses, binding spells.
- **Mage:** Expanded sakti capacity, rapid gauge recharge, powerful staff-boosted spellcraft.

---

## Victory & Defeat
- **Victory:** Defeat Batara Kala in the depths of Gua Kala, restore the forgotten scripts, and bring Laras home. Six Major Choices (one per Act) shape alliances, regional outcomes, boss phases, and the Epilogue ([story.md](story.md)).
- **Defeat:** Forgiving design. Dying returns the hero to the last rested Petilasan with full health and flask charges; no currency or progress is lost ([rpg.md](rpg.md)).

---

## Tone & Narrative Depth
Respectful, grounded, and human, enriched by dry wit and wisdom from Semar and Cepot. Enemies are stylized and clear rather than gory.
- **Folklore in Service of Story:** Each region presents a compelling personal drama first, with folklore traditions forming the natural fabric of the world.
- **Anti-Repetitive Structure:** Across 138 main steps (~21.5 hours) and 20 side quests, no two acts share the same template—ranging from environmental flood navigation and palace faction intrigue to siege warfare and multi-zone predator hunts.

---

## Cultural Sensitivity Guidelines
- Sacred figures (Batara Kala, Nyi Roro Kidul, Semar) are portrayed with dignity and cultural resonance. Deities and revered guardians are never framed as petty monsters.
- Traditional rituals (Ruwatan, sedekah laut, labuhan) and performances (wayang kulit, angklung, gamelan) reflect authentic community life.
- Classical spirits (Pocong, Wewe Gombel, Tuyul) are stylized respectfully within folklore bounds.

---

Related documents: [story.md](story.md), [world.md](world.md), [rpg.md](rpg.md), [spells.md](spells.md), [quests.md](quests.md).
