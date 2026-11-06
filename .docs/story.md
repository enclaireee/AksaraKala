# Story

All legends and details are summarized from common retellings. They were fact-checked once (Nov 2026), against secondary sources only (Wikipedia, news, travel sites). Primary texts (the Pararaton and others) and expert review are still open. Items still marked **VERIFY** were not confirmed. Sources are in [assets.md](assets.md).

Story v3 (user call 2026-11-06, holes closed the same day), with the v3.1 pacing pass (2026-11-06: the Interlude, regional characters, earned glyphs, camp talks, choice consequences, Segara Kidul on the main path). This file is the canon. [quests.md](quests.md) 4 has the step tables, [script.md](script.md) has every line, and the zone docs place everything. [story_brainstorm.md](story_brainstorm.md) and [story_ciung_wanara.md](story_ciung_wanara.md) are history; where they disagree with this file, this file wins.

## Spine: "Aksara yang Terlupa: Gerhana Kala & Jejak Laras" (The Forgotten Script: The Eclipse of Kala & Laras's Trail)
In this world, magic is written in *aksara*, and a written name anchors a soul in the world. What nobody writes down, Batara Kala eats.

Desa Purwa is the old Geger Sunten, where Aki and Nini Balangantrang raised a foundling boy, **Ciung Wanara**. The false king of Galuh wants that boy dead. At the village *wayang ruwatan* the dalang reads the children's names aloud to ward them, Ciung's among them (**VERIFY** the name-reading in a ruwatan). The **Nameless Hunter** (*Si Tanpa Ngaran*) hears names spoken aloud, and that night he and his **Faceless** (*Pajang Teken*) raid the village for the boy. Ciung has already run west. In the crowd, your younger sister **Laras** (`La-Ra-Sa`) looks at the masked Hunter and whispers "Aria", a name nobody has said to him in years. Laras can hear True Names. The Hunter takes her instead: "Wrong child. A better one." In the struggle her palm-leaf *lontar* tears in two. You keep the half with her name on it; she keeps the half with yours.

By morning nobody in Desa Purwa remembers Laras, not even Ibu. Only you, Semar and your half of the *lontar* still remember. Whatever Laras writes on her half shows faintly on yours. She keeps writing *Ka*, for *kakak*, so she won't lose you, and while she writes it you can't forget her. Her letters fading is the clock. You are a player-named hero; your lines use `@NPC_HERO_NAME`. Across six regions you follow Laras's trail. Meanwhile the Hunter uses her gift, and the war between Galuh and Mataram, to break the **Four Great Seals** and wake the **Eclipse of Batara Kala**.

The game explains every plot thread in-game: in talks, in story beats and in the codex.

## The Four Great Seals
The ancestors wrote four dangerous stories down so they would stay *finished*. A written ending binds its curse. Those four writings are the Great Seals, and together they keep Kala asleep under the land.
- A seal can only be **unread** by someone who hears True Names. The Faceless have no names, so they can't read it. That is why the Hunter needs Laras.
- When a seal breaks, its legend **replays** (the old curse walks again) and Kala eats what people forget.
- A reading **cracks** a seal. After that any hand can break it.
- A reading can't be taken back. Each one is a step of Kala's waking.
- The hero never breaks a seal. You **end the story again**, the way the legend ended. That stops the rampage but doesn't undo the reading. Seal 2 is the exception: it was a *name*, and a name can be written again. Whatever Kala has already eaten stays eaten until Kala is calmed in the finale.

| # | Seal | Who breaks it, where | How you end it again |
|---|------|----------------------|----------------------|
| 1 | The Crater (Sangkuriang) | Laras is made to read it at Tangkuban Perahu. The Faceless Captain guards it until it cracks (Act I) | The false dawn: hang the *Boeh Rarang* on the eastern post and cast Ca |
| 2 | The Royal Name of Galuh | Barma Wijaya himself, years ago. He gave Kala his own name and scraped King Nagawiru's name off the Batu Tulis. This was the first crack and the reason the forgetting began | Write Nagawiru's true name (`Na-Ga`) on the Pamali stone (Act III). Caging the false king does not do it: "the cage holds the man, not the name" |
| 3 | The Thousand Temples (Bandung Bondowoso) | Laras is made to read it at the Hunter's camp in Candi Seribu (Act III) | The lesung women's false-dawn rhythm and Jawa Ca, as Roro Jonggrang's women did |
| 4 | The Keris (Mpu Gandring) | Laras is made to read it at the eastern shrine, and the Hunter draws the blade (Act IV) | Lay the keris to rest, then decide its fate (Choice 3) |

When the fourth seal opens, the Eclipse begins. The Eclipse eats first the name of whoever read the seals open. The Hunter believed it would eat whoever *commanded* the reading, him.

**Two kinds of forgetting.** The Faceless are forgotten people. Their names are bound in the lontar bundle at the Hunter's belt, and they obey whoever holds them. Names in the bundle are *held*; names Kala ate are *gone*. When the Hunter falls, the bundle opens and every held name flies home, all but Laras's, which the Eclipse eats first. What Kala ate comes back only when Kala is calmed.

Codex: the seals are a game invention built on the real legends. The codex marks each line "legend" or "game".

## Laras's trail
Laras isn't a sack on someone's back. She fights back, runs when she can, and keeps writing *Ka* on her half of the lontar so she won't lose you. Each act has one **trace** (something of hers you find) and one **Laras beat** (her voice in the dark at a petilasan, 2-3 lines).

| Act | Trace | Laras beat |
|-----|-------|------------|
| Prologue | Her half-lontar, torn in the raid and dropped on the wayang stage | None (the prologue cards show her) |
| I Tatar Sunda | Her ribbon at the bamboo edge, where she broke free. Elder Abah Karna saw her with "a wild boy". In the river gorge at dusk, Sandekala cornered them and their tracks split. Her warning is carved under the Batu Tulis: "They need me to read." The Weaver hid her for a night, before the Faceless took her back on the terraces | `laras_1`, at the crater road: a man with no face keeps asking her to read; she reads slowly on purpose |
| II Keraton Galuh | Her message scratched on the cell wall: "The thousand temples. Don't stop." The Deserter guarded her and let her keep her half of the lontar. You reach the cell yard as her wagon leaves: you fight the escort, a lontar strip comes over the wall, and the wagon is gone east | `laras_2`, in the palace courtyard: under the wagon cloth she heard you fighting in the yard |
| III Mataram | A strip torn from her half in the Candi Seribu camp, covered with *Ka* written again and again | `laras_3`, at the temple petilasan: she read the seal because they hurt the prisoners when she didn't |
| IV Tanah Timur | **You see her**, across the eastern shrine, made to read the keris seal. When the Hunter falls, the Eclipse takes her | `laras_4`, at the desert petilasan: she can't remember your face; only one letter is left, *Ka* |
| Interlude | Her empty cup at Ibu's table | None: the house is quiet on purpose |
| V Segara Kidul | Her voice comes off the water | `laras_kidul`, at the cliff shrine: she can hear the sea, and the sea still says her name |
| VI Gua Kala | The three letters of her name (*huruf nama*), held by Kala | `laras_5`, at the last petilasan: "Who's there?" She has forgotten you, but she is still writing *Ka* |

## Characters
| Character | Role |
|-----------|------|
| **The hero** | Player-named, with a pronoun choice. An apprentice who repeats stories, and becomes one who writes them |
| **Laras** | The younger sister. Hears True Names. Taken in the prologue, home in the epilogue |
| **Semar** | Mentor and wayang narrator, beyond forgetting. Speaks at petilasans and in a few beats. Never hostile |
| **Ibu** | Your mother. Forgets Laras, yet pours her a cup of tea every morning and doesn't know why she weeps |
| **Ciung Wanara** | The hidden heir of Galuh, raised in Desa Purwa. Your ally in Acts I-II. A wild, angry boy who becomes a just king. His rooster is his, not yours |
| **Hariang Banga** | Son of the false king's queen. A rival, then a brother-king. Never a villain |
| **Uwa Lengser** | The old chamberlain of Galuh and your inside man. Warm, funny, brave (**VERIFY** Lengser as a ceremonial figure) |
| **Nagawiru** | The rightful old king, cursed into a naga when his name was scraped away. Freed in Act I, his name restored in Act III |
| **Dewi Naganingrum** | Ciung Wanara's mother, exiled by the lake. Act I regional character: the player learns who she is at the lake; Ciung doesn't, until the epilogue. Shows you Ca |
| **Prabu Barma Wijaya / Aria Kebonan** | The false king: a servant who borrowed the king's face and then sold his own name to Kala to keep it. Charming in public, frightened in private |
| **Dewi Pangrenyep** | The false king's queen, Hariang Banga's mother. Caged with him in Act II. Codex entry and one line in the `cage` beat |
| **The Nameless Hunter** | Aria Kebonan's true name, given to Kala and hollowed out. Commands the Faceless through the bundle of their names at his belt. His motive: "If no one has a name, no one is missing one" |
| **The Faceless** | Forgotten people whose names the Hunter holds. Blank masks; they obey whoever holds their names. Freed when he falls ([bestiary.md](bestiary.md)) |
| **The Faceless Captain** | Leads the raid on the crater. Act I boss |
| **The Faceless Deserter** | A Faceless who is starting to remember a name. He guarded Laras in Galuh. Hints at the truth, never tells it. Choice 1 |
| **Batara Kala** | The god of time who eats the forgotten. Calmed and turned back by ruwatan, never killed |
| **Nyi Roro Kidul** | Queen of the Southern Sea. Sets the Trial of the Waves. Speaks once, from a distance. Neither friend nor enemy, never fought or touched |
| **Ki Sumarto** | Act III regional character. A dalang who performs for both banks; his son marches with Hariang Banga. His son comes home at the truce |
| **Mpu Wirasana** | Act IV regional character. A smith who believes every blade remembers what it was made for. Choice 3 is decided with him |
| **Mbah Wiryo** | Act V regional character. The juru kunci of the coast, who says his late wife's name to the sea each dusk |
| **Helpers** | Cepot, Aki and Nini Balangantrang, Abah Karna, the Weaver, the lesung women, Mbah Marto, Mbok Srini. Pak Karto moves to side quests (Na is read off the Arca, Pacing rule 4) |

## Pacing (v3.1, 2026-11-06)
The story should play like a road, not a museum. Culture is the spice. Each region tells **one** human story, and the folklore lives inside it. Patterns come from The Witcher 3 (one trail and one morally grey local story per region; the villain shows up in every region), Assassin's Creed (leads, then a lieutenant, then the target, then a confession) and FromSoftware (lore lives in places and items; every boss is a person with a stake). Research notes are in HANDOFF §5u.

**Rules (TUNE, check them in the playtest)**
1. **Regional shape.** Every act runs: arrival hook (first fight within 3 minutes) → Laras's trace → the regional story → the turn (a reveal that changes the goal) → petilasan and the Laras beat → the climax boss → an aftermath beat that hands you the next act. No act ends on a talk you have to walk back to.
2. **Cast budget.** At most 3 *new* named speaking characters per act on the main path, not counting bosses. Everyone else stays unnamed ("the Weaver", "the lesung women") or moves to a side quest.
3. **One regional character per act.** Their personal problem mirrors yours (someone lost, a name at risk). Their arc closes in that act's aftermath beat or in a later callback.
4. **Glyphs are earned, never handed over.** Each glyph comes after a deed: a fight, a rescue, an inscription read in place. A teacher may name it or show it, but the deed comes first. The glyph lesson card ([spells.md](spells.md) 5) follows right after.
5. **Rhythm.** A story beat about every 10 minutes. A miniboss, elite or set piece about every 20 minutes. A petilasan every 15-20 minutes of walking. No more than 2 plain steps (walk, talk, collect) before something new happens.
6. **Quiet after every boss.** Each climax boss is followed by 2-4 minutes with no combat: an aftermath beat, and in Acts II and IV an optional **camp talk** with the travelling ally at a petilasan after a boss (Act II: `galuh_1`, after the tournament; Act IV: `timur_2`, after Buto Ijo; 2-4 lines, never required).
7. **The Hunter in every act.** He is seen or felt once per act: the west gate (Prologue), the far rim (I), the throne shadow (II), the graves (III), the duel (IV), his empty mask in the Interlude.
8. **Double bosses.** Where two bosses come back to back (I: Captain then Sangkuriang; IV: the Keris then the Hunter), the beat between them restores health and flask charges (**ASSUMED**).
9. **Talks.** At most 4 lines per NPC talk and 6 per story beat (§5t playtest fix), hero and NPC taking turns; each talk ends on a lead. Lore goes to the codex (1-3 lines per entry, optional reading).

**Runtime target (main path, TUNE; measured in the playtest, not promised).**

| Part | Quest | Steps | Minutes | Running % | Shape |
|------|-------|-------|---------|-----------|-------|
| Prologue | MQ0 | 8 | 20 | 5% | Hook: Laras taken |
| Act I Tatar Sunda | MQ1 | 13 | 75 | 23% | First win: Sangkuriang |
| Act II Keraton Galuh | MQG | 9 | 55 | 36% | Midpoint reveal: the Hunter is the king's name |
| Act III Mataram | MQ2 | 13 | 85 | 57% | The war; Seal 2 restored |
| Act IV Tanah Timur | MQ3 | 11 | 75 | 75% | False victory: the Hunter falls, Laras is lost |
| Interlude Desa Purwa | MQ4 4.1-4.2 | 2 | 10 | 77% | **Low point**: home under the Eclipse |
| Act V Segara Kidul | MQ4 4.3-4.9 | 7 | 45 | 88% | Hope: the sea remembers |
| Act VI Gua Kala | MQ5 | 8 | 45 | 99% | Finale: write her name |
| Epilogue | | | 5 | 100% | |
| **Total** | | **71** | **about 415 (about 7 h)** | | Side quests and exploring add about 3 h (about 10 h at 100%) |

## Acts (71 main steps, about 7 hours, TUNE)
**Prologue: Desa Purwa, "The Night of the Wayang" (MQ0, 8 steps).** Regional character: **Ibu**.
- The wayang night. The Faceless come for Ciung Wanara, but Laras whispers "Aria" and is taken.
- At dawn Ibu doesn't remember Laras, yet she has set out two cups. Semar does remember: he explains the Curse of Forgetting and shows you `Ka` after you pull Laras's lontar from the burned stage (the deed).
- You drive a second Faceless raid out of the village square. At the west gate, the Hunter says the words that frame the whole game: "Wrong child. A better one."
- Nini Balangantrang tells you her Ciung ran west in the night, and the Faceless went the same way.

**Act I: Tatar Sunda, "The Crater Seal" (MQ1, 13 steps).** Regional character: **Dewi Naganingrum**, a mother looking for a son, as you look for a sister. Glyphs: `Ga` (earned by breaking the ambush at Abah Karna's kampung), `Nga` (read in place on the defaced Batu Tulis), `Ca` (Naganingrum shows it after you clear the lake shore).
- Follow Laras's trail: the ribbon at the bamboo edge, Abah Karna, the dusk fight with **Sandekala** in the river gorge where her tracks and the wild boy's split, her warning under the Batu Tulis ("They need me to read"), and the Weaver who hid her and gives you the *Boeh Rarang*.
- **The turn:** Naganingrum by the lake knows the boy's face without being told. She is his mother. The Faceless aren't hunting a thief, they're hunting an heir. She points you to the crater.
- At the crater road, Laras's voice. At the rim, defeat the **Faceless Captain**. Laras's reading cracked the seal, so any hand can finish it: with his last strength he smashes the seal-stone, and **Sangkuriang** wakes (Seal 1). On the far rim, the Hunter watches and leaves.
- End the legend again with the false dawn. Free **Ciung Wanara** and the naga-king **Nagawiru**. Ciung was caught with the egg; Nagawiru rose from the lake for it and was chained too. Ciung was bait for the naga, not for you.
- **Aftermath:** Nagawiru: "The man on the throne wears my face. They took the girl to Galuh." Naganingrum reaches the rim, too late to be recognised: Ciung doesn't know her. (She stays by the lake. Her arc closes in the epilogue.) The egg Ciung carried hatches. He wants his throne, and you want your sister. You go east together.

**Act II: Keraton Galuh, "The Borrowed Face" (MQG, 9 steps).** Regional characters: **Uwa Lengser**, who has kept the queen's secret for fifteen years, and the **Faceless Deserter**, a Faceless who is starting to remember his own name (the Hunter's mirror). No new glyphs; rewards are gear and pusaka. Ally: **Ciung Wanara** (camp talk at `galuh_1`).
- Plan with Ciung at the square gates. Win the king's tournament (the rooster fights off-screen; you fight the king's riggers). Old chamberlain Uwa Lengser sees the queen's eyes in Ciung and opens the inner palace.
- **Near miss:** you reach the cell yard as her wagon pulls out. Fight the escort (`galuh_escort`); she throws a lontar strip over the wall, and the wagon is gone east.
- Search the cells: her message is on the wall.
- The Deserter guarded her and let her keep her lontar. He only hints: "our master speaks with the king's voice". **Choice 1:** free him or hand him to Lengser.
- **The turn (the midpoint):** unmask **Prabu Barma Wijaya** in the throne room. Ciung cages him and Queen Pangrenyep, as in the legend. In his confession, Barma Wijaya admits Seal 2: he scraped the old king's name to keep the face and gave Kala his own. The Hunter *is* that name. This is the only place the game says so. From the shadows: "The cage holds the man, not the name."
- **Aftermath:** Prince **Hariang Banga** escapes east to raise an army and free his mother. He turns on Ciung only now: "you caged my mother". Ciung stays to hold Galuh. You go on alone.

**Act III: Mataram, "Blood on the Pamali" (MQ2, 13 steps).** Regional character: **Ki Sumarto**, a dalang who still performs for both banks because his son marches in Hariang Banga's army. Glyphs: `Ha` (after you save his show from looters at the market), `Na` (read off the Arca's base once the stone guardians fall), `Ca` (the lesung women teach their rhythm once you've cleared the graveyard that kept them silent), `Ra` (the juru kunci Mbah Marto's blessing once you break the blockade on his hill).
- **Three leads** on where the Faceless took Laras: the market, the ruins, the graveyard. In the graveyard, the Hunter's servants harvest the fallen. The Hunter: "Two armies make twice the forgetting."
- **The turn:** all three leads point to Candi Seribu. The camp is not a prison, it's a reading room. Storm it and find a strip of Laras's half covered with *Ka*. She is gone east. **Bandung Bondowoso** wakes (Seal 3). End his night with the lesung rhythm and Jawa Ca.
- Write Nagawiru's name on the Pamali stone (Seal 2 restored): the first time you *write* a name, not copy one. Duel Hariang Banga alone at the ford: you helped cage his mother, so it is a duel, not a battle.
- **Aftermath:** he yields. Nagawiru's voice from the water, Ciung Wanara on the far bank: fighting your brother is *pamali*. The land splits at the river, as in the legend. Ki Sumarto's son wades back across the ford. **Choice 2:** ask Ciung to show the caged king mercy, or say nothing.

**Act IV: Tanah Timur, "The Seven-Generation Blade" (MQ3, 11 steps).** Regional character: **Mpu Wirasana**, a smith who believes every blade remembers what it was made for, and fears the keris he could not refuse to sharpen. Ally: **Hariang Banga** shows you the road east (camp talk at `timur_2`). No new glyphs; you learn to break curse marks (a technique, not a letter).
- Wirasana teaches you to break curse marks. Help Mbok Srini and defeat the curse-maddened **Buto Ijo** with Timun Mas's four pouches.
- Follow the Hunter's ash-trail down the volcanic coast and across the Sea of Sand.
- **The turn:** at the shrine you finally **see Laras**. She is made to read the last seal, and the **Keris Mpu Gandring** wakes (Seal 4). Lay it to rest. **Choice 3:** take it to Wirasana to reforge, or give it to the river.
- **False victory:** defeat **the Nameless Hunter** and carve his name, *Aria Kebonan*, back onto his split mask. In Galuh, the caged man gets his own face back. His bundle opens and the held names fly home; across six regions, the Faceless remember who they were.
- **Aftermath:** then the Eclipse begins, and it takes Laras first. The Hunter, emptied: "She's gone where I was going." Hariang Banga's riders carry you home.

**Interlude: Desa Purwa, "The Quiet House" (MQ4 4.1-4.2, 2 steps).** The low point, about 10 minutes, no combat.
- The Eclipse hangs over the village. The fog at Gua Kala's mouth eats every glyph you throw at it.
- Ibu has set out two cups and can't say why. Talk to her.
- Ciung Wanara and Hariang Banga meet for the first time as brothers, at your mother's table. The Hunter's empty mask lies in the fire.
- Semar: "The sea does not forget." Go south.

**Act V: Segara Kidul, "The Sea Does Not Forget" (MQ4 4.3-4.9, 7 steps).** Regional character: **Mbah Wiryo**, the juru kunci of the coast, who says his late wife's name to the sea every dusk because the sea says it back.
- Mbah Wiryo teaches respect for the coast and the green belief (told as belief). Cross the reef and the cliff path, and hear Laras on the water at the cliff shrine (petilasan `kidul_3` in `sk_tebing`, now on the main path). The trial is held at the sea pavilion (`sk_keraton`).
- Pass Nyi Roro Kidul's **Trial of the Waves** (three waves) and receive the ninth letter, `jawa_ka` *Ombak* (Tide), and the *Kain Hijau*. The deed is the trial; she speaks once, from a distance.
- Ombak is the one letter the Eclipse can't eat. It opens the cave from the sea pavilion and breaks Kala's eclipse shield. (The sea remembering is a game invention.)

**Act VI: Gua Kala, "Into the Maw of Time" (MQ5, 8 steps).**
- Ciung Wanara and Hariang Banga hold the cave mouth side by side, one king from each bank (with the Deserter beside them if you freed him). You go in alone.
- Reclaim the three letters of her name (*huruf nama*: `La`, `Ra`, `Sa`), across the Maw, the Hourglass Sands and the Abyss of Forgetting.
- Rest with Semar at the last petilasan. Calm **Batara Kala** in the Ruwatan of Dawn with Sunda and Jawa letters in turn, and Ombak against the eclipse.
- Your half of the lontar is blank. Semar: "Then write it." You draw `La-Ra-Sa` stroke by stroke, and she comes home.

**Epilogue.**
- 7 cards. Three of them change with your choices (`choice_freed`/`choice_handed`, `choice_mercy`/`choice_silent`, `choice_reforge`/`choice_sink`).
- Everything Kala ate comes back. Ibu pours two cups and nobody thinks Laras ever left. Naganingrum is called back to court by her son, and Nagawiru finally sleeps in the lake. Only you remember the road.
- The village wayang plays your story. The credits show codex completion.

**Choices change more than a card (ASSUMED).** Each choice also changes one thing you can see in play:
- Choice 1: freed, the Deserter stands at the cave mouth in Act VI; handed, Lengser sends word in Act III that the Deserter drew him the camp's layout (a one-line hint at the Mataram camp).
- Choice 2: mercy, Ciung mentions in the Interlude that the cage now has a lamp; silent, he says nothing and looks away.
- Choice 3: reforge, Wirasana gives you the tamed **Keris Mpu Gandring** (weapon, [items.md](items.md)); sink, the river gives you a river-stone accessory (**ASSUMED**, items.md names it).

## Delivery
- NPC dialogue in short boxes: at most 4 lines per NPC talk and 6 per story beat (TUNE). The hero and the NPC take turns. Every talk ends on a lead, and lore goes to the codex. See Pacing above.
- Story beats ([quests.md](quests.md) 4) carry the plot between steps, so there are no "return to Semar" steps.
- The wayang kulit prologue and epilogue use simple shadow-puppet silhouettes: cheap in pixel art and strongly cultural.
- Each zone has 3-5 NPCs. On the main path they name or show glyphs you have earned by a deed (Pacing rule 4); others give side quests.
- All text is in Indonesian and English.

## Sensitivity
- **Cockfighting** is in the legend. The hero never bets or handles a rooster, and the bouts happen off-screen. The codex says the legend tells it and the game doesn't endorse it (**VERIFY** the law before any codex line).
- **Sunda and Java:** the legend's message is that brothers don't fight. Neither side is the bad side.
- **Kala and ruwatan:** Kala is calmed and turned back, never killed. The codex explains ruwatan as a living tradition.
- **Nyi Roro Kidul** is presented as belief, with respect, and is never fought.
- **The Majapahit claim** (Hariang Banga as founder) only ever appears as "some tellings say".

## Quests
Main quest steps, 3-4 side quests per zone (folklore retellings, spirit bounties, errands), rewards and the quest system are in [quests.md](quests.md).

## Ending conditions
There is a single ending. Each of the 3 choices changes one epilogue card, and codex completion changes the credits text only (**ASSUMED**).
