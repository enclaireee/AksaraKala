# Budayago — New RPG Storyline & Campaign Brainstorm

> **Superseded (2026-11-06).** History only. The canon is [story.md](story.md) (v3.1) and the step tables are in [quests.md](quests.md) 4. Where this file disagrees with them, they win.


## 1. Diagnosis: Why the Current Campaign Still Feels Short & Disjointed

Even with better dialogue, the underlying **campaign structure** (`mq0`–`mq5`) has four structural issues that keep it from feeling like *The Witcher 3*, *Bloodborne*, *Elden Ring*, or *Assassin's Creed*:

1. **You Are a Sidekick in Someone Else's Folktale:**
   - In Chapters 1–3, the plot suddenly pivots to *Ciung Wanara's egg and cockfighting tournament*, while your sister **Laras** is pushed off-screen into 2-line dream popups.
2. **The Best Folklore Bosses Were Demoted to Optional 1-Step Errands:**
   - The codebase has **10 fully built boss/mini-boss fights** (`Sandekala`, `Faceless Captain`, `Sangkuriang`, `Prabu Barma Wijaya`, `Bandung Bondowoso`, `Hariang Banga`, `Buto Ijo`, `Keris Mpu Gandring`, `Nameless Hunter`, `Batara Kala`), yet the current Main Quest skips `Sangkuriang`, `Bandung Bondowoso`, and `Sandekala` completely!
3. **Half the Map Is Skipped on the Main Path:**
   - Each region has 8 interconnected zones, but the current Main Quest sprints through 4–5 rooms per region (skipping `ts_leuwi`, `mt_kuburan`, `mt_tegal`, `tt_pesisir`, and rushing through `kg_*` and `gk_*` in 4 minutes).
4. **Learning Aksara Still Happens by Talking to Stationary Villagers:**
   - Instead of earning Aksara by investigating ancient seals, defeating guardians, or solving quests, you still receive most glyphs just by clicking on an NPC (`sunda_elder`, `mataram_dalang`, `pak_karto`, `lesung_women`, `juru_kunci`).

---

## 2. Three New Storyline Directions

Below are three ways we can restructure the entire storyline and campaign.

### Option A: "The Eclipse of Kala" (*The Witcher 3* × *Bloodborne* — Dark Folklore Hunter)
> **Core Pitch:** You are the last apprentice of the **Pujangga** (an ancient order of scroll-blade hunters who bind rampaging folklore curses with Aksara). Your sister **Laras** was taken not by mistake, but because she is a **Living Vessel** whose voice the **Nameless Hunter** is using to break the **Four Great Seals** across the archipelago—unleashing the ancient titans and kings (**Sangkuriang**, **Barma Wijaya**, **Bandung Bondowoso**, **Mpu Gandring's Keris**) to feed the waking god **Batara Kala**.

* **Why It Works Like a Real RPG:**
  * **Laras is 100% central to the plot** from start to finish—no "wrong child, we came for the boy with the egg" detour.
  * **Every major folklore boss is on the Main Path:** In each region, the Nameless Hunter has forced Laras to crack that region's seal, waking its legendary curse (**Sangkuriang** in Sunda, **Barma Wijaya**'s blood-pact in Galuh, **Bandung Bondowoso** & the brothers' war in Mataram, **Buto Ijo** & **Keris Mpu Gandring** in Tanah Timur).
  * **Ciung Wanara & Hariang Banga are your RPG Companions/Allies** whose kingdom is being torn apart by the same conspiracy—so helping Ciung overthrow the False King is directly tied to stopping the Second Seal!

---

### Option B: "The Order of the Blank Mask" (*Assassin's Creed* × *Elden Ring* — Royal Conspiracy & Hunting the Cabal)
> **Core Pitch:** A secret cabal of usurpers across Sunda and Java (**The Pajang Teken**) sold their true names to **Batara Kala** in exchange for stolen thrones, immortality, and power—erasing the old scripts (`Aksara`) so no one can expose their true faces. When your sister **Laras** accidentally uncovers the **First Royal Ledger** in Desa Purwa, the cabal's executioner (**The Nameless Hunter**) abducts her. You must hunt down the cabal's four regional lords one by one, dismantle their networks, and reclaim the 8 Aksara of Truth.

* **Why It Works Like a Real RPG:**
  * Plays like *Assassin's Creed II / Origins*: Each region has a **Target Investigation Loop** (gather 3 clues across the region → disrupt the target's lieutenants → learn the counter-Aksara → assassinate/defeat the regional boss and unmask their true name).
  * Deep political intrigue connecting **Desa Purwa → Tatar Sunda → Keraton Galuh → Mataram → Tanah Timur → Gua Kala**.

---

### Option C: "Where the Lontar Burns" (*The Witcher 3: Wild Hunt* Ciri Structure — Tracking Laras's Escape Trail)
> **Core Pitch:** Modeled directly on Geralt's search for Ciri across Velen, Novigrad, and Skellige. **Laras isn't a helpless prisoner in a sack**—she stole the Nameless Hunter's seal-scroll during her capture and is **actively fleeing and fighting back** across Tatar Sunda, Galuh, Mataram, and Tanah Timur! Everywhere she runs, the Hunter's hounds corner her, and in desperation she breaks local shrine seals to cover her escape—waking **Sangkuriang**, getting caught in **Ciung Wanara's coup in Galuh**, crossing the **Mataram war**, and making her last stand at **Tanah Timur** before being dragged into **Gua Kala**.

* **Why It Works Like a Real RPG:**
  * In every zone, you find **physical traces of Laras** (scorched Aksara marks she drew on walls, NPCs who sheltered her or saw her fight off the Faceless, items she dropped).
  * Gives the player an immediate, emotional *Witcher*-style detective trail in every single chapter: *"Laras was here two days ago—what happened to her at the lake, and how did she escape the palace?"*

---

## 3. Recommended Best Design: The Hybrid ("The Eclipse of Kala + Laras's Trail")

Combining **Option A (Dark Pujangga Hunter & The 4 Broken Seals)** with **Option C (Tracking Laras's Active Trail Across All 8 Zones per Region)** gives us the strongest possible RPG campaign without needing new art assets:

### How the New 6-Act Campaign Flows (Longer, Cohesive, Every Boss Matters)

| Act & Region | Story Hook & Investigation Trail | Main Quest Gameplay Loop (Expanded) | Bosses Fought on Main Path |
|---|---|---|---|
| **Prologue & Act 0: Desa Purwa** (*The Night the Screen Tore*) | You (`{name}`) and **Laras** are the last descendants of the village's **Pujangga** scribes. During the Wayang Ruwatan, the **Nameless Hunter** and his dusk-fiends raid the village to capture Laras and steal the **Seal of Purwa**. Laras fights back, burning your name onto her lontar before being dragged west. | 1. Watch the Wayang & talk to Semar.<br>2. Wake after the raid; investigate your home & the burned stage.<br>3. Unlock the ancestral Sanggar with Semar & learn `Ka`.<br>4. Defend the village square from the Faceless raid.<br>5. Confront the Nameless Hunter & Nini Balangantrang at the West Gate. | **Faceless Raid Pack** (Tutorial Climax) |
| **Act I: Tatar Sunda** (*The Drowned Crater*) | Tracking the Hunter west, you learn Laras escaped her captors near the river gorge (`ts_leuwi`) with the help of a fugitive youth (**Ciung Wanara**). To flush them out, the **Faceless Captain** broke the crater seal—waking the cursed titan **Sangkuriang** to flood the valley! | 1. Rest at `ts_kebun` & question Elder Abah Karna.<br>2. Track Laras & Ciung's ambush site into the gorge (`ts_leuwi`) and earn `Ga`.<br>3. Clear the Faceless at `Batu Tulis` (`ts_leuweung`) & decipher `Nga` from King Nagawiru's defaced stele.<br>4. Fight through the rice terraces (`ts_sawah`) to exiled Queen **Naganingrum** at Lake Situ (`ts_situ`).<br>5. Retrieve the sacred *Boeh Rarang* cloth from the Weaver (`ts_kampung`) & learn `Ca` from Naganingrum.<br>6. Defeat the **Faceless Captain** at the crater pass (`ts_kawah_jalan` / `ts_kawah`) with Ciung Wanara.<br>7. Use the *Boeh Rarang* + `Ca` (False Dawn) to calm the rampaging titan **Sangkuriang** at the crater rim and free chained **King Nagawiru**! | **1. Faceless Captain** (Mid-Boss)<br>**2. Sangkuriang** (Act I Climax Boss) |
| **Act II: Keraton Galuh** (*The Court of Borrowed Faces*) | King Nagawiru reveals that the man who ordered Laras's abduction is the usurper on Galuh's throne: **Aria Kebonan**, who sold his own name to Batara Kala (birthing the **Nameless Hunter**) to wear King Barma Wijaya's face. Laras is being held in the palace dungeons before the next seal is broken. | 1. Enter `kg_alun` with **Ciung Wanara**; win Bout 1 & Bout 2 of the Royal Tournament against the King's riggers.<br>2. Meet royal spymaster **Uwa Lengser**; unlock the inner palace (`kg_keraton`).<br>3. Fight through the dungeon cells (`kg_penjara`), find Laras's carved message on the cell wall, and interrogate the **Faceless Deserter**.<br>4. Storm the throne room (`kg_keraton`) and defeat **False King Barma Wijaya**, shattering his stolen face! | **3. Prabu Barma Wijaya / Aria Kebonan** (Act II Climax Boss) |
| **Act III: Mataram** (*The Thousand-Temple War*) | Laras was moved east just before the palace fell! Worse, Queen Pangrenyep's son **Prince Hariang Banga** has marched his army to the Pamali River to avenge his parents. The **Nameless Hunter** is in Mataram, waking the cursed warlord **Bandung Bondowoso** at `mt_candi` to turn the brothers' war into a blood-feast for Kala. | 1. Cross the Pamali front to `mt_sawah` & meet **Ki Sumarto** at the refugee market (`mt_pasar`) to learn `Ha`.<br>2. Scout the contested ruins (`mt_reruntuhan`) with **Pak Karto**, learn `Na`, and smash the awakened `Arca` vanguard.<br>3. Track the Faceless soul-collectors through the haunted graveyard (`mt_kuburan`) and dry fields (`mt_tegal`).<br>4. Rally the women at the `lesung` (`mt_sawah`) for `Ca` (the False Dawn rhythm) and get the temple key + `Ra` from **Mbah Marto** (`mt_wetan`).<br>5. Storm `mt_candi`: crush the Faceless war-camp AND defeat the awakened warlord **Bandung Bondowoso**!<br>6. Inscribe **Nagawiru**'s true name (`Na` + `Ga`) on the **Pamali Stone** (`kg_pamali`) and defeat **Prince Hariang Banga** at the ford to unite West and East! | **4. Bandung Bondowoso** (Temple Boss)<br>**5. Prince Hariang Banga** (Act III Climax Duel) |
| **Act IV: Tanah Timur** (*The Blood-Forged Shrine*) | Cornered in the east, the **Nameless Hunter** drags Laras to the ancient shrine of Tanah Timur (`tt_candi`), sealing the road behind two awakened eastern legends: the devouring giant **Buto Ijo** and the seven-kings blood curse of **Keris Mpu Gandring**. | 1. Enter `tt_sabana` & meet bladesmith **Mpu Wirasana** at the banyan forge (`tt_beringin`).<br>2. Track the Hunter's scorched trail to the southern coast (`tt_pesisir`) and river (`tt_kali`) to meet **Mbok Srini**.<br>3. Slay the rampaging giant **Buto Ijo** in the eastern fields (`tt_ladang`) to open the southern desert pass.<br>4. Master curse-breaking on the forge stakes (`tt_beringin`) and rest at the desert shrine (`tt_pasir`).<br>5. Enter `tt_candi`: break the 7 curse stakes and defeat **Keris Mpu Gandring**.<br>6. Fight **The Nameless Hunter** in a 1v1 showdown and carve his discarded name (**Aria Kebonan**) back onto his mask! | **6. Buto Ijo** (Field Boss)<br>**7. Keris Mpu Gandring** (Shrine Guardian)<br>**8. The Nameless Hunter** (Act IV Climax Boss) |
| **Act V: Gua Kala** (*Into the Maw of Time*) | With the Hunter unmasked, Laras's fading soul is pulled into **Gua Kala** north of Desa Purwa. While Kings **Ciung Wanara** and **Hariang Banga** hold the cave mouth, you descend into the abyss of time. | 1. Enter `gk_mulut` past the two kings' banners and clear the Maw's threshold.<br>2. Fight through the hourglass sands (`gk_pasir`) and the abyss of forgetting (`gk_lupa`), recovering Laras's 3 fading syllables (`La`, `Ra`, `Sa`) with **Semar**.<br>3. Defeat **Batara Kala** by countering his eclipse shields with all 8 Aksara glyphs.<br>4. Draw **Laras**'s true name (`La-Ra-Sa`) on her blank lontar and walk home to Desa Purwa. | **9. Batara Kala** (Final Boss) |

---

## 4. Key Improvements This Brings to Gameplay & Pacing
1. **Campaign Length Nearly Doubles (From 39 Steps → ~55+ Rich RPG Steps):**
   - Every single region uses its full map and culminates in **both** a narrative investigation AND a major folklore boss + main villain confrontation.
2. **All 9 Bosses Are Now Part of the Main Campaign:**
   - Players no longer miss **Sangkuriang** (Act I) or **Bandung Bondowoso** (Act III)—they are woven directly into the main plot as the regional seals broken by the Faceless!
3. **Every Quest Step Has Real Narrative Purpose:**
   - No more "Talk to NPC → Get free spell." Every glyph is learned to solve an immediate tactical or environmental obstacle on your hunt for Laras and the Nameless Hunter.

---

## 7. 8-Hour Main Campaign Architecture (7 Acts, 61 Main Steps, 39 Areas, 11 Bosses/Trials)

To push the **Main Story** from ~3 hours to a true **~8-hour Main Campaign** (**11–12+ hours** for 100% completion), we expand the campaign in three ways:
1. **Woven Regional Investigations (All 8 Areas per Region Used on the Main Path):** Instead of skipping half the map in each region, the hunt for Laras and the Nameless Hunter routes through the atmospheric sub-dungeons (`ts_leuwi` River Gorge & **Sandekala**, `ts_leuweung` Boar Lane & Grove, `mt_kuburan` Misty Graveyard, `tt_pesisir` Volcanic Ash Coast, and `gk_pasir` Hourglass Desert).
2. **Full Act V — `Segara Kidul` (`MQ4`, 6 Interlocking Areas `sk_*`):** Build the Southern Sea region (`sk_pantai`, `sk_karang`, `sk_desa`, `sk_hutan`, `sk_tebing`, `sk_keraton`) between `Tanah Timur` (`MQ3`) and `Gua Kala` (`MQ5`), unlocking the `sc:ts_sk` cliff shortcut back to `Tatar Sunda`, the **Trial of the Southern Waves**, the **9th Glyph (`jawa_ka` — *Ombak / Tide*)**, and the **Kain Hijau** armor.
3. **61 Main Quest Steps + Multi-Encounter Dungeon Pacing:** Every Act has 8–13 steps mixing clue investigations, combat encounters, shortcut unlocks, NPC conversations, and multi-boss climaxes.

### Runtime & Content Breakdown (8-Hour Main Campaign)

| Act | Region | Areas | Main Steps | Main-Path Bosses & Trials | Target Main Runtime |
| :--- | :--- | :---: | :---: | :--- | :---: |
| **Prologue (`MQ0`)** | `Desa Purwa` | 1 | **8 steps** | Village Raid + Nameless Hunter Encounter | **~25–30 mins** |
| **Act I (`MQ1`)** | `Tatar Sunda` | 8 | **13 steps** | **1. Sandekala** (River Gorge)<br>**2. Faceless Captain** (Crater)<br>**3. Sangkuriang** (Crater Seal) | **~85–95 mins** |
| **Act II (`MQG`)** | `Keraton Galuh` | 4 | **8 steps** | Royal Tournament Bouts 1 & 2<br>Dungeon Cells Siege<br>**4. Prabu Barma Wijaya** (Throne) | **~55–65 mins** |
| **Act III (`MQ2`)** | `Mataram` | 8 | **13 steps** | Ruins Guardians + Graveyard Harvest<br>**5. Bandung Bondowoso** (Temple Seal)<br>**6. Prince Hariang Banga** (Pamali Duel) | **~95–105 mins** |
| **Act IV (`MQ3`)** | `Tanah Timur` | 8 | **11 steps** | **7. Buto Ijo** (Eastern Fields)<br>Ash Coast Siege<br>**8. Keris Mpu Gandring** (Shrine Seal)<br>**9. The Nameless Hunter** (Altar) | **~85–95 mins** |
| **Act V (`MQ4`)** | `Segara Kidul` *(New)* | 6 | **8 steps** | **10. Trial of the Southern Waves** (`Lampor`, `Ula Segara`, `Bajul Putih`) + `jawa_ka` (*Ombak*) | **~60–70 mins** |
| **Act VI (`MQ5`)** | `Gua Kala` | 4 | **8 steps** | Three Memory Seal Battles (`La`, `Ra`, `Sa`)<br>**11. Batara Kala** (Ruwatan Finale) | **~50–60 mins** |
| **TOTAL** | **6 Regions + Hub** | **39 Areas** | **69 Main Steps** | **11 Main-Path Bosses / Major Trials** | **~8.0 – 8.5 Hours** |

---

### Detailed Step-by-Step Expansion Per Act

#### Act I — `Tatar Sunda` (`MQ1`: 13 Steps, ~90 mins)
1. **`s1` (`ts_kebun`):** Clear the bamboo-edge ambush (`area_cleared:sunda_edge`) where Laras dropped her ribbon.
2. **`s2` (`ts_kebun`):** Rest at the tea-terrace petilasan (`petilasan_activated:sunda_1`, sets `mq1_1`).
3. **`s3` (`ts_kampung`):** Question Elder Abah Karna about Laras and the hunted prince, and learn `Ga` (`glyph_learned:sunda_ga`, sets `mq1_3`).
4. **`s4` (`ts_leuwi`):** Descend into the dark River Gorge where Ciung Wanara was cornered at dusk, light the four *oncor* torches, and defeat the dusk-terror **Sandekala** (`boss_defeated:sandekala`, sets `mq1_3b`) to find Ciung's trail toward the forest.
5. **`s5` (`ts_leuweung`):** Defeat the Faceless scouts at the royal `Batu Tulis` stele (`area_cleared:sunda_batutulis`).
6. **`s6` (`ts_leuweung`):** Decipher `Nga` and Laras's carved warning on King Nagawiru's defaced stele (`glyph_learned:sunda_nga`, sets `mq1_5`).
7. **`s7` (`ts_sawah`):** Break through the Jurig vanguard in the stone clearing (`area_cleared:sunda_clearing`).
8. **`s8` (`ts_sawah`):** Defeat the Faceless hunting party on the tea terraces (`area_cleared:sunda_terraces`).
9. **`s9` (`ts_sawah`):** Speak with the Weaver who sheltered Laras and obtain the sacred *Boeh Rarang* cloth (`talked_to:sunda_weaver`, sets `mq1_6`).
10. **`s10` (`ts_situ`):** Speak with exiled Queen Naganingrum by the lake and learn `Ca` (`glyph_learned:sunda_ca`, sets `mq1_7`).
11. **`s11` (`ts_kawah_jalan`):** Break the final Faceless blockade on the volcanic crater floor (`area_cleared:sunda_crater`) and rest at the crater-road petilasan (`petilasan_activated:sunda_2`, triggers `beat_laras_1`).
12. **`s12` (`ts_kawah`):** Defeat the **Faceless Captain** at the crater rim (`boss_defeated:faceless_captain`, sets `mq1_8`, triggers `beat_crater_seal`).
13. **`s13` (`ts_kawah`):** Hang the *Boeh Rarang* on the eastern post, cast `Ca`, and quell the awakened titan **Sangkuriang** (`boss_defeated:sangkuriang`, sets `mq1_9`, triggers `beat_naga`).

#### Act II — `Keraton Galuh` (`MQG`: 8 Steps, ~60 mins)
1. **`s1` (`kg_alun`):** Speak with Prince Ciung Wanara at the royal square gates to plan your infiltration (`talked_to:ciung_wanara`).
2. **`s2` (`kg_alun`):** Win the first tournament bout and defeat the King's riggers (`area_cleared:galuh_bout_1`, sets `mqg_1`).
3. **`s3` (`kg_alun`):** Win the second tournament bout (`area_cleared:galuh_bout_2`, sets `mqg_2`, triggers `beat_galuh_bout`).
4. **`s4` (`kg_alun`):** Conspire secretly with chamberlain Uwa Lengser (`talked_to:lengser`, sets `mqg_3`).
5. **`s5` (`kg_keraton`):** Rest at the inner courtyard petilasan (`petilasan_activated:galuh_1`, sets `mqg_4`) and fight past the courtyard guard (`area_cleared:galuh_courtyard`).
6. **`s6` (`kg_penjara`):** Clear the dungeon cells searching for Laras (`area_cleared:galuh_cells`, sets `mqg_5`).
7. **`s7` (`kg_penjara`):** Interrogate the Faceless Deserter and decide his fate (`talked_to:faceless_deserter`, sets `mqg_6`, Choice 1).
8. **`s8` (`kg_keraton`):** Unmask the False King **Prabu Barma Wijaya** in the throne room (`boss_defeated:barma_wijaya`, sets `mqg_7`, triggers `beat_cage`).

#### Act III — `Mataram` (`MQ2`: 13 Steps, ~100 mins)
1. **`s1` (`mt_gapura`):** Clear the border gateway ambush after crossing the Pamali River (`area_cleared:mataram_gerbang`).
2. **`s2` (`mt_sawah`):** Rest at the rice-field petilasan on the Mataram war front (`petilasan_activated:mataram_1`, sets `mq2_1`).
3. **`s3` (`mt_pasar`):** Drive the looters out of the refugee market plaza (`area_cleared:mataram_pasar`) and speak with Dalang Ki Sumarto to learn `Ha` (`glyph_learned:jawa_ha`, sets `mq2_2`).
4. **`s4` (`mt_reruntuhan`):** Meet scout Pak Karto at the contested ruins and learn `Na` (`glyph_learned:jawa_na`, sets `mq2_3`).
5. **`s5` (`mt_reruntuhan`):** Destroy the awakened stone Arca guardians in the ruins (`area_cleared:mataram_ruins`).
6. **`s6` (`mt_sawah`):** Rally the *gejog lesung* women and learn `Ca` (`glyph_learned:jawa_ca`, sets `mq2_5`).
7. **`s7` (`mt_kuburan`):** Purge the misty graveyard where the Nameless Hunter's servants harvest fallen soldiers (`area_cleared:mataram_kuburan`).
8. **`s8` (`mt_wetan`):** Clear the rocky foothill blockade (`area_cleared:mataram_batu`) and obtain the temple gate key and `Ra` from Mbah Marto (`glyph_learned:jawa_ra`, sets `mq2_6`, triggers `beat_hunter_war`).
9. **`s9` (`mt_candi`):** Fight through the outer temple gate guardians (`area_cleared:mataram_candi`).
10. **`s10` (`mt_candi`):** Storm the Nameless Hunter's war-camp in Candi Seribu (`area_cleared:mataram_camp`, sets `mq2_7`).
11. **`s11` (`mt_candi`):** Quell the awakened warlord **Bandung Bondowoso** after the Temple Seal is shattered (`boss_defeated:bandung_bondowoso`, sets `mq2_7b`).
12. **`s12` (`kg_pamali`):** Inscribe King Nagawiru's true name (`Na-Ga`) onto the Pamali boundary stone (`name_written:nagawiru`, sets `mq2_8`, triggers `beat_ford`).
13. **`s13` (`kg_pamali`):** Duel **Prince Hariang Banga** at the Pamali Ford to forge the royal truce (`boss_defeated:hariang_banga`, sets `mq2_9`, triggers `beat_truce`, Choice 2).

#### Act IV — `Tanah Timur` (`MQ3`: 11 Steps, ~90 mins)
1. **`s1` (`tt_kulon`):** Break the Faceless border ambush in the western gorge (`area_cleared:timur_perbatasan`).
2. **`s2` (`tt_sabana`):** Rest at the savanna petilasan (`petilasan_activated:timur_1`, sets `mq3_1`).
3. **`s3` (`tt_beringin`):** Question bladesmith Mpu Wirasana at the banyan forge (`talked_to:timur_empu`, sets `mq3_2`).
4. **`s4` (`tt_kali`):** Clear the river crossing (`area_cleared:timur_kali`) and speak with Mbok Srini (`talked_to:mbok_srini`, sets `mq3_3`).
5. **`s5` (`tt_ladang`):** Defeat the curse-maddened giant **Buto Ijo** using Timun Mas's four warding pouches (`boss_defeated:buto_ijo`, sets `mq3_4`).
6. **`s6` (`tt_beringin`):** Shatter two practice death-curse stakes in the forge yard (`area_entered:timur_praktik_mark` x2).
7. **`s7` (`tt_pesisir`):** Track the Nameless Hunter's ash-trail to the southern volcanic shore and defeat the coastal vanguard (`area_cleared:timur_pesisir`).
8. **`s8` (`tt_pasir`):** Cross the Sea of Sand (`area_cleared:timur_pasir_1`) and rest at the desert petilasan (`petilasan_activated:timur_2`, triggers `beat_laras_4`).
9. **`s9` (`tt_candi`):** Breach the outer shrine guard (`area_cleared:timur_candi`).
10. **`s10` (`tt_candi`):** Break the Fourth Great Seal: **Keris Mpu Gandring** (`boss_defeated:keris_gandring`, sets `mq3_7`, triggers `beat_keris`, Choice 3).
11. **`s11` (`tt_candi`):** Defeat **The Nameless Hunter** and carve his discarded true name (`Aria Kebonan`) back onto his mask (`boss_defeated:nameless_hunter`, sets `mq3_8`, triggers `beat_hunter_name`).

#### Act V — `Segara Kidul` (`MQ4`: 7 Steps, 6 New Areas `sk_*`, ~65 mins)
1. **`s1` (`sk_pantai`):** Enter the black-sand coast of Segara Kidul (`zone_entered:sk_pantai`, sets `mq4_1`) and rest at the coastal petilasan (`petilasan_activated:kidul_1`).
2. **`s2` (`sk_desa`):** Speak with coastal keeper Mbah Wiryo (`talked_to:kidul_jurukunci`, sets `mq4_2`) about the Tides of Time and Nyi Roro Kidul's law.
3. **`s3` (`sk_karang`):** Clear the Lampor cavalry pack along the reef causeway (`area_cleared:kidul_karang`).
4. **`s4` (`sk_hutan`):** Purge the sea-mist pandanus grove (`area_cleared:kidul_hutan`) and open the cliffside shortcut back to Tatar Sunda (`sc:ts_sk` in `sk_tebing`).
5. **`s5` (`sk_tebing`):** Rest at the cliff-shrine petilasan (`petilasan_activated:kidul_2`, sets `mq4_5`, triggers `beat_laras_kidul`).
6. **`s6` (`sk_keraton`):** Complete the **Trial of the Southern Waves** (`area_cleared:kidul_trial` — 3 waves of `Lampor`, `Ula Segara`, and `Bajul Putih`, sets `mq4_6`).
7. **`s7` (`sk_keraton`):** Receive the 9th glyph **`jawa_ka` (*Ombak / Tide*)** and the **Kain Hijau** from the Sea Pavilion (`glyph_learned:jawa_ka`, sets `mq4_7`, triggers `beat_kidul`).

#### Act VI — `Gua Kala` (`MQ5`: 8 Steps, ~55 mins)
1. **`s1` (`gk_mulut`):** Enter the Maw of Time while brother-kings Ciung Wanara and Hariang Banga hold the gate (`zone_entered:gk_mulut`, sets `mq5_1`, triggers `beat_mouth`).
2. **`s2` (`gk_mulut`):** Break the threshold guard to reclaim the First Memory Seal `La` (`area_cleared:kala_mulut`, sets `mq5_1b`).
3. **`s3` (`gk_pasir`):** Cross the Hourglass Sands and shatter the western time-ward (`area_cleared:kala_pasir_1`).
4. **`s4` (`gk_pasir`):** Shatter the eastern time-ward (`area_cleared:kala_pasir_2`, sets `mq5_1c`) to unlock the descent into the Abyss.
5. **`s5` (`gk_lupa`):** Clear the Abyss of Forgetting to reclaim the Second Memory Seal `Ra` (`area_cleared:kala_lupa`, sets `mq5_1d`).
6. **`s6` (`gk_lupa`):** Speak with Semar and rest at the final petilasan to anchor the Third Memory Seal `Sa` (`petilasan_activated:kala_1`, sets `mq5_2`, triggers `beat_laras_5`).
7. **`s7` (`gk_ruang_kala`):** Calm **Batara Kala** in the Ruwatan of Dawn (`boss_defeated:batara_kala`, sets `mq5_3`, triggers `beat_write`).
8. **`s8` (`gk_ruang_kala`):** Inscribe Laras's true name (`La-Ra-Sa`) onto her blank *lontar* (`name_written:laras`, sets `mq5_4`).
