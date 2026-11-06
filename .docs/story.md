# Story

All legends and details are summarized from common retellings. They were fact-checked once (Nov 2026), against secondary sources only (Wikipedia, news, travel sites). Primary texts (the Pararaton and others) and expert review are still open. Items still marked **VERIFY** were not confirmed. Sources are in [assets.md](assets.md).

**Story v4 telling pass (user call 2026-11-06, after playtest: "I don't know a lot of the stuff").** The plot is v3.1, unchanged. What changed is how and when things are introduced: the rule "Know before you meet", a playable normal day before the raid, Witcher-style **Hunts** for every legend boss with a playable **Kelir memory**, name tags, the journal's "Story so far", and a smaller cast. Assume the player knows no Sunda or Java lore. See Pacing rules 10-14 and "Hunts".

Story v3 (user call 2026-11-06, holes closed the same day), with the v3.1 pacing pass (2026-11-06: the Interlude, regional characters, earned glyphs, camp talks, choice consequences, Segara Kidul on the main path). This file is the canon. [quests.md](quests.md) 4 has the step tables, [script.md](script.md) has every line, and the zone docs place everything. [story_brainstorm.md](story_brainstorm.md) and [story_ciung_wanara.md](story_ciung_wanara.md) are history; where they disagree with this file, this file wins.

## Spine: "Aksara yang Terlupa: Gerhana Kala & Jejak Laras" (The Forgotten Script: The Eclipse of Kala & Laras's Trail)
In this world, magic is written in *aksara*, and a written name anchors a soul in the world. What nobody writes down, Batara Kala eats.

Desa Purwa is the old Geger Sunten, where an old couple (Aki and Nini Balangantrang in the legend; in play just "the old couple next door") raised a foundling boy, **Ciung Wanara**. The false king of Galuh wants that boy dead. At the village *wayang ruwatan* the dalang reads the children's names aloud to ward them, Ciung's among them (**VERIFY** the name-reading in a ruwatan). The **Nameless Hunter** (*Si Tanpa Ngaran*) hears names spoken aloud, and that night he and his **Faceless** (*Pajang Teken*) raid the village for the boy. Ciung has already run west. In the crowd, your younger sister **Laras** (`La-Ra-Sa`) looks at the masked Hunter and whispers "Aria", a name nobody has said to him in years. Laras can hear True Names. The Hunter takes her instead: "Wrong child. A better one." In the struggle her palm-leaf *lontar* tears in two. You keep the half with her name on it; she keeps the half with yours.

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

| Act | Trace | Laras beat (v4b: the frame of a playable Laras chapter, LC1-LC6) |
|-----|-------|------------|
| Prologue | Her half-lontar, torn in the raid and dropped on the wayang stage | None (the prologue cards show her) |
| I Tatar Sunda | Her ribbon at the bamboo edge, where she broke free. The kampung elder saw her with "a wild boy". In the river gorge at dusk, Sandekala cornered them and their tracks split. Her warning is carved under the Batu Tulis: "They need me to read." The Weaver hid her for a night, before the Faceless took her back on the terraces | `laras_1`, at the crater road: a man with no face keeps asking her to read; she reads slowly on purpose |
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
| **Ciung Wanara** | The hidden heir of Galuh, raised in Desa Purwa. Your ally in Acts I-II. A wild, angry boy who becomes a just king. His rooster is his, not yours. Arc in side stories (v4d): anger (camp talk I, by the lake where his unknown mother lives) → justice (camp talk II, SQ-C1 his rooster) |
| **Hariang Banga** | Son of the false king's queen. A rival, then a brother-king. Never a villain. Arc in side stories (v4d): rival → brother (camp talk III after the truce, SQ-C2 the letters, camp talk IV, the Interlude table) |
| **Uwa Lengser** | The old chamberlain of Galuh and your inside man. Warm, funny, brave (**VERIFY** Lengser as a ceremonial figure) |
| **Nagawiru** | The rightful old king, cursed into a naga when his name was scraped away. Freed in Act I, his name restored in Act III |
| **Dewi Naganingrum** | Ciung Wanara's mother, exiled by the lake. Act I regional character: the player learns who she is at the lake; Ciung doesn't, until the epilogue. Shows you Ca |
| **Prabu Barma Wijaya / Aria Kebonan** | The false king: a servant who borrowed the king's face and then sold his own name to Kala to keep it. Charming in public, frightened in private |
| **The queen** (Dewi Pangrenyep in the codex) | The false king's queen, Hariang Banga's mother. Caged with him in Act II. Unnamed in play (v4); her name is in her codex entry and Hariang Banga says "my mother" |
| **The Nameless Hunter** | Aria Kebonan's true name, given to Kala and hollowed out. Commands the Faceless through the bundle of their names at his belt. His motive: "If no one has a name, no one is missing one" |
| **The Faceless** | Forgotten people whose names the Hunter holds. Blank masks; they obey whoever holds their names. Freed when he falls ([bestiary.md](bestiary.md)) |
| **The Faceless Captain** | Leads the raid on the crater. Act I boss |
| **The Faceless Deserter** | A Faceless who is starting to remember a name. He guarded Laras in Galuh. Hints at the truth, never tells it. Choice 1. SQ-C3 (v4d) carries Choice 1 to Act VI: you gather his name and write it at the cave mouth |
| **Batara Kala** | The god of time who eats the forgotten. Calmed and turned back by ruwatan, never killed |
| **Nyi Roro Kidul** | Queen of the Southern Sea. Sets the Trial of the Waves. Speaks once, from a distance. Neither friend nor enemy, never fought or touched |
| **Ki Sumarto** | Act III regional character. A dalang who performs for both banks; his son marches with Hariang Banga. His son comes home at the truce |
| **Mpu Wirasana** | Act IV regional character. A smith who believes every blade remembers what it was made for. Choice 3 is decided with him |
| **Mbah Wiryo** | Act V regional character. The juru kunci of the coast, who says his late wife's name to the sea each dusk. Takes Act V's camp-talk slot, since no ally travels in V (v4d) |
| **Cepot** | Semar's son, loud and cowardly-brave (wayang golek comic figure). Met in the prologue day at the sanggar, pestering Semar. Gives SQ-S4 in Act I, which becomes part 1 of his chain SQ-C4 (I, III, V, epilogue): he keeps turning up to prove himself, and stays when it matters |
| **Helpers (unnamed in v4)** | The old couple next door (Ciung's grandparents), the kampung elder (was Abah Karna), the Weaver, the lesung women, the juru kunci (was Mbah Marto), the widow (was Mbok Srini, Timun Mas's mother), the stall-keeper. Ki Wangsa is cut: Semar is the village dalang. Pak Karto stays in side quests |
| **Kelir figures** | Played, never met: the child at maghrib, Dayang Sumbi, Lengser's younger self, a woman of Roro Jonggrang's court, Timun Mas, Mpu Gandring's apprentice, young Aria Kebonan; the side-story figures of v4d (Purbasari's lutung, Nawang Wulan, Klething Kuning, the Kaputren servant and others). They exist only inside Kelir memories (see Hunts and Side stories) |

## Pacing (v3.1, 2026-11-06)
The story should play like a road, not a museum. Culture is the spice. Each region tells **one** human story, and the folklore lives inside it. Patterns come from The Witcher 3 (one trail and one morally grey local story per region; the villain shows up in every region), Assassin's Creed (leads, then a lieutenant, then the target, then a confession) and FromSoftware (lore lives in places and items; every boss is a person with a stake). Research notes are in HANDOFF §5u.

**Rules (TUNE, check them in the playtest)**
1. **Regional shape.** Every act runs: arrival slice and hook (first fight within 5 minutes, v4b) → Laras's trace → the regional story → the turn (a reveal that changes the goal) → petilasan and the Laras beat → the climax boss → an aftermath beat that hands you the next act. No act ends on a talk you have to walk back to.
2. **Cast budget.** At most 2 *new* named speaking characters per act on the main path, not counting bosses and the regional character (v4; was 3). Everyone else stays unnamed ("the Weaver", "the lesung women") or moves to a side quest.
3. **One regional character per act.** Their personal problem mirrors yours (someone lost, a name at risk). Their arc closes in that act's aftermath beat or in a later callback.
4. **Glyphs are earned, never handed over.** Each glyph comes after a deed: a fight, a rescue, an inscription read in place. A teacher may name it or show it, but the deed comes first. The glyph lesson card ([spells.md](spells.md) 5) follows right after.
5. **Rhythm.** A story beat about every 10 minutes. A miniboss, elite or set piece about every 20 minutes. A petilasan every 15-20 minutes of walking. No more than 2 plain steps (walk, talk, collect) before something new happens.
6. **Quiet after every boss.** Each climax boss is followed by 2-4 minutes with no combat: an aftermath beat, and in Acts I-V an optional **camp talk** after a boss (2-4 lines, never required). Act I `camp_sunda` (Ciung, the lake, after Sangkuriang); Act II `camp_galuh` (Ciung, `galuh_1`, after the tournament); Act III `camp_mataram` (Hariang Banga, the ford, after the truce); Act IV `camp_timur` (Hariang Banga, `timur_2`, after Buto Ijo); Act V `camp_kidul` (Mbah Wiryo, `kidul_1`, after the trial). None in the Interlude (the table is its quiet) or Act VI (no filler). v4d added I, III and V.
7. **The Hunter in every act.** He is seen or felt once per act: the west gate (Prologue), the far rim (I), the throne shadow (II), the graves (III), the duel (IV), his empty mask in the Interlude.
8. **Double bosses.** Where two bosses come back to back (I: Captain then Sangkuriang; IV: the Keris then the Hunter), the beat between them restores health and flask charges (**ASSUMED**).
9. **Talks.** At most 4 lines per NPC talk and 6 per story beat (§5t playtest fix), hero and NPC taking turns; each talk ends on a lead. Lore goes to the codex (1-3 lines per entry, optional reading).
10. **Know before you meet (v4).** No name is spoken on the main path before the player has seen that person, place or thing, or it is explained in the same line ("Sandekala, the dusk spirit"). A legend is shown before it is fought. The check: in script.md order, every name's first use comes at or after its introduction (Verification in HANDOFF §5z).
11. **Name tags (v4).** The first time a named character speaks, the dialogue box shows their name with a one-line "who" under it ("Cepot. Semar's son. Loud."). Shown once per save ([ui.md](ui.md) 3).
12. **Hunts (v4).** Every legend boss (not the person bosses) is a Hunt: hook, 2-3 clues, a Kelir memory, the fight, the aftermath. See "Hunts" below. Clues are on the critical path; the lontar shimmers within 48 px of an unexamined one.
13. **The fight is the memory (v4).** The Kelir memory makes the player *do* the thing that wins the fight (light the torches, spread the cloth, keep the lesung beat). No boss mechanic is first explained during the fight.
14. **Story so far (v4).** The journal keeps 1-2 lines per finished main step and a list of found clues ([ui.md](ui.md) 4), so a returning player is never lost.

**Runtime target (main path, TUNE; measured in the playtest, not promised).**

| Part | Quest | Steps | Minutes | Running % | Shape |
|------|-------|-------|---------|-----------|-------|
| Prologue | MQ0 | 9 | 35 | 6% | A normal day, then Laras taken |
| Act I Tatar Sunda | MQ1 | 15 | 105 | 23% | First win: Sangkuriang |
| Act II Keraton Galuh | MQG | 9 | 70 | 34% | Midpoint reveal: the Hunter is the king's name |
| Act III Mataram | MQ2 | 13 | 110 | 52% | The war; Seal 2 restored |
| Act IV Tanah Timur | MQ3 | 11 | 105 | 69% | False victory: the Hunter falls, Laras is lost |
| Interlude Desa Purwa | MQ4 4.1-4.5 | 5 | 25 | 73% | **Low point**: home under the Eclipse |
| Act V Segara Kidul | MQ4 4.6-4.12 | 7 | 60 | 83% | Hope: the sea remembers |
| Act VI Gua Kala | MQ5 | 9 | 65 | 98% | Finale: write her name |
| Epilogue | | | 10 | 100% | A day again |
| **Total** | | **78** | **about 585 target; the model sums 572 (about 9.5 h)** | | Side quests and exploring add about 6 h after v4d (about 16 h at 100%, TUNE; was 13 h) |

## Pacing model (v4c, user call 2026-11-06: "redesign the pacing of the whole game")
**Why.** Playtest: MQ1 1.4 and 1.5 (a talk and the Sandekala gorge) took the user about 5 minutes together, against a design rate of about 6 minutes per step. Most v3.1 steps are a single talk or a single fight, joined by empty walking and backtracking. The minute targets were wishes, not a model. v4c replaces them with a **content model**: each step is built from typed pieces of play with measured times, and a script adds them up (`python3 .docs/pacing_model.py`).

**Piece types and minutes** (TUNE, calibrated from the 2026-11-06 playtest; re-measure every playtest and change the numbers in the script, not here):

| Type | Min | What it is |
|------|-----|------------|
| `talk` | 0.5 | One NPC talk (at most 4 lines) |
| `beat` | 1 | One story beat (at most 6 lines) |
| `lesson` | 1 | A glyph lesson card |
| `write` | 1 | A write card (a name, a doorpost) |
| `clue` | 1.5 | Find and examine a clue, with the walk to it |
| `fight` | 1.5 | One encounter room (one or two waves) |
| `travel` | 3 | Cross one area on the critical path: 2 encounters and one thing to find (a secret, a codex spot, a vista) |
| `puzzle` | 3 | An environment puzzle (light the path, move the water, read the stones) |
| `memory` | 3 | A Kelir memory (walk or play kind) |
| `chapter` | 4 | A Laras chapter |
| `miniboss` | 3 | An elite or miniboss |
| `boss` | 5 | A boss fight, including one retry |
| `setpiece` | 4 | A scripted moment with play (the tournament, the escort, the rhythm game) |

**Rules** (checked by the script; TUNE):
1. **No thin steps.** Every main step adds up to at least 3 minutes. A talk is never a step on its own: it is the end of a step that has play in it ("Reach the kampung through the ambush and ask the elder"). Exception: the Interlude.
2. **Chapters.** Each act is 3-4 chapters of about 20-30 minutes. A chapter is a journey (`travel`, `fight`, `puzzle`), a story moment (`clue`, `talk`, `memory`, `chapter`) and a payoff (`miniboss`, `boss`, `setpiece` or `beat`). Chapters are marked in quests.md 4.
3. **Play share.** At least 55% of each act's minutes are hands-on play (`fight`, `travel`, `puzzle`, `miniboss`, `boss`, `setpiece`, `chapter`, and the `play`-kind memories). At most 25% are reading (`talk`, `beat`, `lesson`).
4. **Rhythm.** A story piece at least every 10 minutes; a `miniboss`, `boss` or `setpiece` at least every 25 minutes; never more than 3 reading pieces in a row.
5. **No empty backtracking.** A return trip on the main path is either a shortcut that opens (0 minutes, a door) or a changed area with new content (counted as `travel`). v3.1's back-and-forth through ts_kampung is replaced by shortcuts.
6. **Act targets.** Each act lands within 15% of its row in the runtime table above. Step counts are whatever the merges give (78 in v4c); minutes are what matter. The table is now an output of the model, not a promise.
7. **Every area earns its place.** An area on the critical path holds at least one optional find (a secret, a side-quest hook, a codex spot) so exploring pays (world.md "Points of interest").

**Curve.** Acts grow and slow toward the middle and breathe at the end: short Prologue (learn and love), longer Acts I-IV (each a little harder and a little longer), the quiet Interlude (the shortest, all story), a fast Act V (hope, momentum) and a dense Act VI (no travel filler, only memories and the finale).

## Acts (78 main steps after the v4c merges, about 9.5 hours, TUNE; v4/v4b targets, quests.md 4 is the source; see also "Depth pass (v4b)")
**Prologue: Desa Purwa, "A Day in Desa Purwa" (MQ0, 9 steps after v4c, v4).** Regional character: **Ibu**. Order: name entry → class choice → 2 cards (the village at dawn; "today is the ruwatan") → play.
The day is calm and has no combat before the raid. Each step plants one thing the rest of the game needs, and the planted thing is *shown*, then named:
1. **Morning.** Laras wakes you, then dares you to catch her: a game of tag through the village (teaches movement and dodge). Her gift is shown before it is named: she calls a stray cat by "its real name" and it comes; she says the old banyan's name and its leaves shiver. Planted: *Laras hears true names.*
2. **Ibu** pours **two cups of tea**, one for each of you, and tells you to have Laras home before the show. Planted: the two cups (the Interlude and the epilogue pay this off).
3. **Ciung Wanara**, the wild boy next door, is up a tree guarding a strange egg. The old couple who raised him ask you to fetch him home. Laras: "Ciung isn't his whole name, you know. He doesn't know the rest." Planted: *the boy, the egg, a secret about him.*
4. **The sanggar.** **Semar**, the old village dalang (puppeteer), with his son **Cepot** pestering him. Semar shows how aksara work: a letter drawn with heart becomes power, and **a written name keeps a person in the world**. Laras writes her name at one end of her lontar strip and yours at the other. Planted: *aksara, names, the lontar.*
5. **The market.** A stall-keeper: "A tall man in a blank mask was asking children's names today. I didn't tell him." Planted: *the Hunter is coming.*
6. **Evening: the wayang ruwatan.** Semar performs on the kelir (the shadow screen) and you play part of it (the first Kelir memory, a tutorial): **Batara Kala**, the god of time, who eats whatever is left unprotected and forgotten; and how the ancestors **wrote four dangerous stories shut** so they stay finished, the Four Seals. He ends on the first story, Sangkuriang, who tried to beat the dawn and was fooled by a false one. Then he reads the children's names aloud to ward them, Ciung's among them. Planted: *Kala, the Seals, the first boss, why names are read.*
7. **The raid.** The shadows step off the screen: blank masks, reaching hands. They want Ciung, who is already gone into the dark. Laras looks at the tallest and whispers "Aria". He takes her: "Wrong child. A better one." The lontar tears between you.
8. **The morning after** runs as v3.1: Ibu has no daughter, yet two cups are set out; pull the lontar from the burned stage; Semar remembers her, and teaches `Ka` ("for *kakak*, what she called you") after the deed; drive the second raid out of the square; the Hunter at the west gate; the old couple: their Ciung ran west in the night, and the masks went the same way.

**Act I: Tatar Sunda, "The Crater Seal" (MQ1, 15 steps after v4c).** Regional character: **Dewi Naganingrum**, a mother looking for a son, as you look for a sister. Glyphs: `Ga` (earned by breaking the ambush at the elder's kampung), `Nga` (read in place on the defaced Batu Tulis), `Ca` (Naganingrum shows it after you clear the lake shore).
- Follow Laras's trail: the ribbon at the bamboo edge, the kampung elder, the **Sandekala Hunt** (see Hunts) in the river gorge where her tracks and the wild boy's split, her warning under the Batu Tulis ("They need me to read"), and the Weaver who hid her and gives you the *Boeh Rarang*.
- **The turn:** Naganingrum by the lake knows the boy's face without being told. She is his mother. The Faceless aren't hunting a thief, they're hunting an heir. She points you to the crater.
- At the crater road, Laras's voice. At the rim, defeat the **Faceless Captain**. Laras's reading cracked the seal, so any hand can finish it: with his last strength he smashes the seal-stone, and **Sangkuriang** wakes (Seal 1). On the far rim, the Hunter watches and leaves.
- End the legend again with the false dawn. Free **Ciung Wanara** and the naga-king **Nagawiru**. Ciung was caught with the egg; Nagawiru rose from the lake for it and was chained too. Ciung was bait for the naga, not for you.
- **Aftermath:** Nagawiru: "The man on the throne wears my face. They took the girl to Galuh." Naganingrum reaches the rim, too late to be recognised: Ciung doesn't know her. (She stays by the lake. Her arc closes in the epilogue.) The egg Ciung carried hatches. He wants his throne, and you want your sister. You go east together.

**Act II: Keraton Galuh, "The Borrowed Face" (MQG, 9 steps).** Regional characters: **Uwa Lengser**, who has kept the queen's secret for fifteen years, and the **Faceless Deserter**, a Faceless who is starting to remember his own name (the Hunter's mirror). No new glyphs; rewards are gear and pusaka. Ally: **Ciung Wanara** (camp talk at `galuh_1`).
- Plan with Ciung at the square gates. Win the king's tournament (the rooster fights off-screen; you fight the king's riggers). Old chamberlain Uwa Lengser sees the queen's eyes in Ciung and opens the inner palace.
- **Near miss:** you reach the cell yard as her wagon pulls out. Fight the escort (`galuh_escort`); she throws a lontar strip over the wall, and the wagon is gone east.
- Search the cells: her message is on the wall.
- The Deserter guarded her and let her keep her lontar. He only hints: "our master speaks with the king's voice". **Choice 1:** free him or hand him to Lengser.
- **The turn (the midpoint):** unmask **Prabu Barma Wijaya** in the throne room. Ciung cages him and the queen, as in the legend. In his confession, Barma Wijaya admits Seal 2: he scraped the old king's name to keep the face and gave Kala his own. The Hunter *is* that name. This is the only place the game says so. From the shadows: "The cage holds the man, not the name."
- **Aftermath:** Prince **Hariang Banga** escapes east to raise an army and free his mother. He turns on Ciung only now: "you caged my mother". Ciung stays to hold Galuh. You go on alone.

**Act III: Mataram, "Blood on the Pamali" (MQ2, 13 steps).** Regional character: **Ki Sumarto**, a dalang who still performs for both banks because his son marches in Hariang Banga's army. Glyphs: `Ha` (after you save his show from looters at the market), `Na` (read off the Arca's base once the stone guardians fall), `Ca` (the lesung women teach their rhythm once you've cleared the graveyard that kept them silent), `Ra` (the juru kunci's blessing once you break the blockade on his hill).
- **Three leads** on where the Faceless took Laras: the market, the ruins, the graveyard. In the graveyard, the Hunter's servants harvest the fallen. The Hunter: "Two armies make twice the forgetting."
- **The turn:** all three leads point to Candi Seribu. The camp is not a prison, it's a reading room. Storm it and find a strip of Laras's half covered with *Ka*. She is gone east. **Bandung Bondowoso** wakes (Seal 3). End his night with the lesung rhythm and Jawa Ca.
- Write Nagawiru's name on the Pamali stone (Seal 2 restored): the first time you *write* a name, not copy one. Duel Hariang Banga alone at the ford: you helped cage his mother, so it is a duel, not a battle.
- **Aftermath:** he yields. Nagawiru's voice from the water, Ciung Wanara on the far bank: fighting your brother is *pamali*. The land splits at the river, as in the legend. Ki Sumarto's son wades back across the ford. **Choice 2:** ask Ciung to show the caged king mercy, or say nothing.

**Act IV: Tanah Timur, "The Seven-Generation Blade" (MQ3, 11 steps).** Regional character: **Mpu Wirasana**, a smith who believes every blade remembers what it was made for, and fears the keris he could not refuse to sharpen. Ally: **Hariang Banga** shows you the road east (camp talk at `timur_2`). No new glyphs; you learn to break curse marks (a technique, not a letter).
- Wirasana teaches you to break curse marks. The **Buto Ijo Hunt**: help the widow (Timun Mas's mother) and defeat the curse-maddened **Buto Ijo** with Timun Mas's four pouches.
- Follow the Hunter's ash-trail down the volcanic coast and across the Sea of Sand.
- **The turn:** at the shrine you finally **see Laras**. She is made to read the last seal, and the **Keris Mpu Gandring** wakes (Seal 4). Lay it to rest. **Choice 3:** take it to Wirasana to reforge, or give it to the river.
- **False victory:** defeat **the Nameless Hunter** and carve his name, *Aria Kebonan*, back onto his split mask. In Galuh, the caged man gets his own face back. His bundle opens and the held names fly home; across six regions, the Faceless remember who they were.
- **Aftermath:** then the Eclipse begins, and it takes Laras first. The Hunter, emptied: "She's gone where I was going." Hariang Banga's riders carry you home.

**Interlude: Desa Purwa, "The Quiet House" (MQ4 4.1-4.5, 5 steps; deepened in v4b, see "Depth pass").** The low point, about 25 minutes, no combat.
- The Eclipse hangs over the village. The fog at Gua Kala's mouth eats every glyph you throw at it.
- Ibu has set out two cups and can't say why. Talk to her.
- Ciung Wanara and Hariang Banga meet for the first time as brothers, at your mother's table. The Hunter's empty mask lies in the fire.
- Semar: "The sea does not forget." Go south.

**Act V: Segara Kidul, "The Sea Does Not Forget" (MQ4 4.6-4.12, 7 steps after v4c; deepened in v4b).** Regional character: **Mbah Wiryo**, the juru kunci of the coast, who says his late wife's name to the sea every dusk because the sea says it back.
- Mbah Wiryo teaches respect for the coast and the green belief (told as belief). Cross the reef and the cliff path, and hear Laras on the water at the cliff shrine (petilasan `kidul_3` in `sk_tebing`, now on the main path). The trial is held at the sea pavilion (`sk_keraton`).
- Pass Nyi Roro Kidul's **Trial of the Waves** (three waves) and receive the ninth letter, `jawa_ka` *Ombak* (Tide), and the *Kain Hijau*. The deed is the trial; she speaks once, from a distance.
- Ombak is the one letter the Eclipse can't eat. It opens the cave from the sea pavilion and breaks Kala's eclipse shield. (The sea remembering is a game invention.)

**Act VI: Gua Kala, "Into the Maw of Time" (MQ5, 9 steps after v4c; deepened in v4b).**
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

## Depth pass (v4b, user call 2026-11-06: "the new pacing for the whole story, and more depth in the later sections")
v4 applies to every act, not only the prologue. v4b adds five threads that run the whole game, then deepens the second half. All new numbers are **TUNE**, all new decisions **ASSUMED**. Culture claims added here carry **VERIFY** until a researcher checks them.

### Five threads across every act
1. **Arrival slice** (every act, 3-5 min). Each region opens on ordinary life *before* you see its trouble: the tea pickers singing (I), the tournament crowd (II), the two-bank market (III), the smiths' street ringing (IV), the fishing village mending nets (V). A local shows you one thing they love. Then the trouble arrives and you know what it is breaking. Pacing rule 1's "first fight within 3 minutes" becomes "within 5".
2. **Laras chapters** (LC1-LC6, one per act, 3-5 min each). Her Laras beat (2-3 lines) becomes the frame of a short **playable** chapter where you *are* Laras. She can't fight. Her one power is her gift: she says a Faceless's true name and it freezes for 3 s, remembering. Each chapter ends with her writing *Ka* on her half of the lontar. She is a person with her own story, not a prize.
3. **The Hunter's memories** (H1-H4). The mask fragments (Hunts K6) each open a 1-minute Kelir memory from Aria Kebonan's side, so by Act IV you know him. Then K6 is the last piece.
4. **Who's who, through play.** Every political fact is shown before it is said. Why Galuh and Mataram fight (III) is shown by recruiters from both banks at the market, each telling the same story the other way round. Why Hariang Banga hates Ciung (II) is shown: you are in the yard when his mother is caged.
5. **Callbacks to the prologue day.** The day's small things come back: the tag game, the two cups, the stray cat, the banyan, Laras's handwriting. The finale is built from them (Act VI).

### Per act
**Prologue** as v4. LC0 is not needed: you spend the day with her.

**Act I.** Arrival: the tea terraces at dawn, pickers singing; the kampung elder's grandson shows you the bamboo he is learning to play (angklung, codex). LC1 *"Reading slowly"*: at the crater, Laras is put before the seal-stone. You play her stalling: read one letter at a time while a Faceless guard paces; when he turns, slip a stone into the reading groove. You (the hero) hear her voice at the petilasan. H1 *"The kind king"*: the first fragment (the far rim). Young Aria sweeps a palace floor; King Nagawiru stops and calls him by name. (You met Nagawiru as the naga minutes before.)

**Act II.** Arrival: tournament day, a crowd, a rooster seller (no fight shown). LC2 *"Under the wagon cloth"*: Laras scratches her message into a board of the wagon floor while the Deserter drives; she hears you fighting the escort and throws the lontar strip. H2 *"The borrowed face"*: the throne shadow fragment. Aria wears the king's face for the first time, and no one says his own name again. Lengser's memory K-II stays: two sides of one night.

**Act III.** Arrival: the market on the river with traders from both banks. Two recruiters, one from each prince, tell the same story of the war, each the other way round (**who's who**). **Ki Sumarto's show** is a Kelir memory (K-III): the legend of the brothers who split the land at the river; you play the younger brother crossing back; it teaches *pamali*: brothers don't fight. This sets up the ford duel and Choice 2. LC3 *"The reading room"*: at Candi Seribu, Laras is told the prisoners will be hurt if she doesn't read. You play her choosing: read, or refuse and watch. The game makes her read (she reads; the chapter shows why). H3 *"The price"*: the graves fragment. Aria, alone at night, gives his own name to Kala to keep the borrowed face.

**Act IV.** Arrival: the smiths' street; Wirasana's daughter shows you how a keris is folded (codex: pamor). LC4 *"Whose face"*: on the desert road Laras tries to draw your face in the sand and can't; she remembers only the tag game and the word *kakak*. You play her keeping *Ka* written as the sand wipes it. H4 *"Wrong child"*: the last fragment, before the duel. The prologue raid from Aria's eyes: a small girl says his name, the first time in fifteen years. Now "A better one" means something else. Then K6.

**Interlude, deepened** (MQ4 4.1-4.5, about 25 min, no combat). The Eclipse makes the whole village forget each other's names. 4.1 *"Doorposts"*: go house to house and **write each family's name on their doorpost** with aksara, the first time you write for someone else (a small write card per house, three houses; this trains the finale). 4.2 *"Ibu"*: bring Ibu three of Laras's things (the ribbon from Act I, her wagon-board message from II, the *Ka* strip from III). She doesn't remember, but she sets the second cup straight. 4.3 *"The brothers' table"*: Ciung Wanara and Hariang Banga at your mother's table; a short playable dinner where you pass dishes and choose who you sit beside (no stakes, flavour). 4.4 *"The empty man"*: Aria Kebonan, his face back and his name nearly gone, sits by the burned stage. Optional talk: he tells you how to find Kala's sleeping place, and asks you to say his name once. 4.5 *"Why Semar remembers"*: Semar tells you what he is in the wayang tales, a god who chose to live as a servant (**VERIFY** Semar as Batara Ismaya in Javanese and Sundanese wayang), and why the sea is the one thing older than Kala. Go south.

**Act V, deepened** (MQ4 4.6-4.12, about 60 min). Arrival: the fishing village mending nets for the sea offering, but no one remembers the songs (**VERIFY** the sea offering, *sedekah laut* / *labuhan*, and how it is described). Mbah Wiryo still says his late wife's name to the sea at dusk, and the sea says it back. **Hunt K8 "The sea's name"**: clues are the forgotten songs (three verses, found with three families); the Kelir memory is **Mbah Wiryo's wife's last evening on the shore**: you play her teaching him to call a name to the water (no death shown; she walks into the evening light). Teaches: calling a name to the sea, the opening of the trial. Then a second memory, **K9 "The queen of the south"**, Ki Sumarto's version of Nyi Roro Kidul as one retelling among several, told with respect (**VERIFY**, present as belief, no fight). LC5 *"The voice on the water"*: in Kala's dark, Laras follows a voice that says her name; you play her walking toward the sound. The Trial of the Waves (v3.1) follows. The village sings again in the aftermath.

**Act VI, deepened** (MQ5, 9 steps, 65 min). The three letters of her name are held in three of **your own memories of the prologue day**, partly eaten by Kala: `La` is the tag game, `Ra` is the two cups, `Sa` is her writing your names on the lontar. In each you replay the moment and fill the gaps Kala ate by choosing the right detail (what did she call the cat? which cup was hers?). It can't be failed, but a wrong pick shows a grey gap and you look again. This rewards the player who paid attention in the first 30 minutes. Then **K10 "Murwakala"**: Semar's ruwatan tale of how Kala was born hungry and why the dalang's words turn him back (**VERIFY** the Murwakala lakon as the ruwatan story). LC6 *"Who's there?"*: Laras at the bottom of the dark, forgetting you, still writing *Ka*; you play her hand writing it once more, and you hear your own voice reply. Then K7 (you read the names as dalang), the Ruwatan of Dawn, and you write `La-Ra-Sa`.

**Epilogue, deepened** (about 10 min, playable). It mirrors the prologue day. Laras wakes you; she dares you to tag; Ibu pours two cups. You walk the village while the ruwatan stage is built, and people from every act have come for the show: the elder's grandson with his angklung, Lengser, Ki Sumarto and his son, Wirasana's daughter, Mbah Wiryo; the Deserter if freed. The three choice cards stay, and each choice also changes who is there. The show is your story. Laras asks you to tell her the part she missed, and the credits roll over the kelir.

### Cast check for v4b
New named speakers: none. The new people are unnamed (the grandson, Wirasana's daughter, the recruiters, the three families). Figures played in memories (the younger brother, Mbah Wiryo's wife, the sea queen in Ki Sumarto's telling) are Kelir figures.

### Memory and chapter count
Kelir memories: K0-K10 plus K-II and K-III (13). Hunter memories: H1-H4. Laras chapters: LC1-LC6. Every one is 1-5 minutes.

## Hunts (v4)
The Witcher 3 contract shape, adapted. A legend boss is never just "someone tells you a story, then the boss". You walk into its harm, find its traces, live a piece of its legend, and then fight it with what that piece taught you. Pacing rules 10-13.

**The shape (TUNE):**
1. **Hook** (step 1): you see the harm before you hear the name. Within 1 minute of entering the area.
2. **Investigate** (2-3 clue steps): clues are objects you examine (`clue_examined:<id>`; [quests.md](quests.md) 7). Laras's half-lontar **shimmers** when an unexamined clue is within 48 px; it is her trail, made visible. Each clue gives 1-2 lines of the hero's own thought and a journal note. Local people may add one line each, never a lecture.
3. **Kelir memory** (1 step): the last clue pulls you into the lontar. A **Kelir memory** is a small playable scene in shadow-puppet style (silhouettes on a lit screen, [architecture.md](architecture.md) "Kelir memory"). You play a figure from the legend for 2-4 minutes, with only movement and one action. It ends by teaching, through doing, the thing that wins the fight. Semar narrates 1-2 lines at the start and end, as the dalang.
4. **Fight**: the boss's key mechanic is the one the memory taught. A first-time hint repeats it in 4 words at most ("Light the oncor").
5. **Aftermath** (a beat): the cost to a person and the lead onward.

**The legends are game retellings.** Each memory keeps to the common retelling; the codex marks what is "legend" and what is "game". Memories never show killing on screen (a fade to the kelir lamp).

| # | Boss (act) | Hook | Clues | Kelir memory: you play / you do / it teaches | Aftermath |
|---|-----------|------|-------|-----------------------------------------------|-----------|
| K0 | Tutorial (Prologue) | The ruwatan show | None | **Semar's show**: you move a wayang figure across the kelir while Kala's shadow swallows the unlit side; stand in the lamp's light to stay safe. Teaches the kelir controls; plants Kala and the Seals | The raid |
| K1 | **Sandekala** (I) | A gorge-side hamlet at dusk; a mother calls her son's name into the trees, and nobody answers | (1) the boy's sandal at the river's edge; (2) a row of **oncor** (bamboo torches) that nobody lit, because the hamlet forgot its own maghrib custom when the forgetting began; (3) Laras's and Ciung's prints going down into the gorge, a child's prints behind them | **A child at maghrib.** You are a village child hurrying home at sunset as the mothers light oncor along the path. A tall shadow follows, but it cannot cross lit ground; you run from torch to torch and light the last ones yourself. Teaches: **light the four oncor** (the Sandekala fight) | The children are found asleep in the gorge. The mother lights her oncor again. Laras's and Ciung's tracks split: hers go up to the Batu Tulis |
| K2 | **Sangkuriang** (I) | The river has been dammed overnight; the ribs of a half-built boat stand on the lake | (1) a hillside of freshly felled trees; (2) every rooster coop in the hamlet empty; (3) the Weaver's loom and the **Boeh Rarang** cloth (step 1.8 already) | **Dayang Sumbi's night.** You are the woman from Semar's show. A giant must finish a lake and a boat before dawn; she cannot let him. You spread the white cloth on the eastern post and pound the lesung so the roosters crow early. Teaches: **the false dawn** (hang the Boeh Rarang, cast Ca) | Seal 1's legend ends again. Ciung and the naga are freed (v3.1 `naga` beat) |
| K3 | **Bandung Bondowoso** (III) | Villagers haul stone in the night; temples stand where yesterday there was a field | (1) rubble with fresh chisel marks and spirit hand-prints; (2) a lesung left in the middle of its rhythm; (3) Laras's *Ka* strip at the camp (v3.1 trace) | **The princess's women.** You are one of Roro Jonggrang's women. A man has sworn to build a thousand temples in one night; you keep the rice-pounding beat on the lesung so the roosters think it is dawn. A rhythm game of 3 short bars. Teaches: **the Jawa Ca beat** (expose the pillars) | The building stops. The lesung women play again in the market |
| K4 | **Buto Ijo** (IV) | A widow's hut smashed open; footprints as long as you are tall | (1) cucumber seeds spilled on the path; (2) a needle case; (3) a salt jar and a pot of terasi | **Timun Mas.** You are the girl the giant was promised. You run, and each time he gets close you throw a pouch: seeds become brambles, needles a bamboo wall, salt a sea, terasi mud. Teaches: **lure him through the pouch fields** | The widow and her daughter are safe. Buto Ijo was cursed mad by the keris (v3.1) |
| K5 | **Keris Mpu Gandring** (IV) | Red curse marks burned on doorposts in Mpu Wirasana's village | (1) a broken scabbard; (2) Wirasana's forge records ("seven generations"); (3) the practice marks (v3.1 step 3.6, now a clue) | **The old forge.** You are the smith's apprentice. A young man comes for a keris before it is finished; you hear the smith's dying curse (off-screen, a fade). Then you douse the curse marks it leaves on the forge floor before they join. Teaches: **put out the curse marks** | Choice 3 (v3.1) |
| K6 | **The Nameless Hunter** (IV) | Seen once per act (Pacing rule 7) | His mask fragments, one per act: the west gate (Prologue), the far rim (I), the throne shadow (II), the graves (III) | **The servant.** You are young Aria Kebonan, a palace servant, sweeping while a king speaks your name kindly; then the face you will borrow; then nobody says your name again. 2 minutes, no action but walking. Teaches the *why*, not a mechanic (this is a person boss; Pacing rule 13 does not apply) | False victory (v3.1) |
| K7 | **Batara Kala** (VI) | Set up in the prologue show | The three name letters (v3.1 steps) | **The ruwatan again.** Semar's show from the prologue, but you are the dalang now, reading the names aloud. Teaches: the Ruwatan of Dawn alternates Sunda and Jawa letters, as you read them | Write her name (v3.1) |

**v4b memories** (detail in "Depth pass (v4b)"): K-III Ki Sumarto's show, the brothers who split the land (III, teaches *pamali* before the ford); K8 Mbah Wiryo's wife, calling a name to the sea (V, opens the trial); K9 the queen of the south as one retelling (V); K10 Murwakala, why the ruwatan turns Kala back (VI). Laras chapters LC1-LC6 and the Hunter memories H1-H4 are in the same section.

**Person bosses** (Faceless Captain, Barma Wijaya, Hariang Banga) are not Hunts, but Pacing rule 10 still applies:
- **Faceless Captain** (I): on the lake shore a fallen Faceless drops a carved toy with a name scratched on it (a clue: the masks were *people*). The Captain is seen on the crater road before the rim.
- **Barma Wijaya** (II): Lengser's investigation already works this way; add a clue, the court portrait with its face scraped off, and Lengser's short memory (K-II, 1 minute: the night a servant put on the king's face). Sets up the confession.
- **Hariang Banga** (III): met in Act II; in Act III his camp letters to his mother are a clue before the ford.

## Side stories (v4d, user call 2026-11-06: "side quests as Hunts" plus "deeper characters", "as big as it needs")
The side quests get the main path's v4 telling. The main path itself (78 steps, 572 min) is not touched. **No new systems:** side stories reuse Clue (`clue_examined`), Kelir memory (`memory_done`), the write card (`name_written`) and `quiet` NPC entries. Card detail, ids and rewards are in [quests.md](quests.md) 5; lines in [script.md](script.md). Sizes (TUNE): **S** 5-10 min, **M** 10-20, **L** 20-30.

### Side Hunt shape
A small main Hunt: **hook** (the harm before the name) → **2 clues** → a **1-2 min Kelir memory** → fight *or* peaceful ending → **aftermath** with a person's cost. Pacing rules 10 and 13 apply: the creature is shown or explained before its name is spoken, and the memory teaches what ends it. **For two-way quests the memory teaches the peaceful way** (the legend's own solution), so a player who paid attention can end it without a fight; the fight stays as the other branch (+50% Ilmu, as before). Retellings (no fight) become a memory you play instead of a list of fetches. Errands keep their shape and only get a rule-10 pass.

| Quest (size) | Hook | Clues | Kelir memory: you play / it teaches | Ending |
|---|---|---|---|---|
| SQ-S1 Lutung Kasarung (M, retelling) | A black langur that won't leave a girl with spotted skin alone at the edge of the forest | the lutung's offerings left at her door; a spring choked with spirits | **The lutung** (Guruminda under a borrowed face) leading Purbasari to the hidden spring. Teaches nothing to fight: you clear the spring, she bathes, her skin heals (**VERIFY** the cure) | A face seen for what it is: the theme of Act I |
| SQ-S2 Kuntilanak (L) | A baby crying at night in the bamboo grove, where no house stands | cempaka scent at an unmarked grave; a torn white cloth on the bamboo | **A grandmother** walking the grove at night, keeping to the ground she can't follow onto (**VERIFY** the motif, or mark it **ASSUMED** as a game rule). Teaches the fight's safe ground | Fight. The grove is cut back; the kepala desa carves a name for the grave |
| SQ-M1 Jaka Tarub (M, retelling) | A rice pot that used to fill from one grain is empty | the pot's lifted lid; rice gone down in the lumbung all at once | **Nawang Wulan** finding her selendang under the last of the rice. Teaches nothing to fight | She goes back to the sky and leaves her weaving scarf |
| SQ-M2 Wewe Gombel (L, two-way) | A mother who didn't notice her son was gone until evening | the boy's toy on the hill path; a neighbour: "nobody called him" | **The neglected child** following a kind voice up the hill. Teaches **calling kindly and banging pots** (**VERIFY**) | Peaceful: the parents call. Fight: the elite |
| SQ-M3 Tuyul (M, two-way) | Coins vanish from a stall while its keeper watches | tiny footprints in the hearth ash; spilled green beans, half counted | **The tuyul**, sent out by a greedy master, who can't pass a spill without counting it. Teaches **it must stop to count** (**VERIFY** beans or crabs) | Peaceful: set the beans, catch the leader. Fight: the leader and swarm |
| SQ-T1 Ande-Ande Lumut (M, two-way) | A girl stopped at the river; the ferry rope cut | claw marks on the jetty; the sodo lanang in her bundle | **Klething Kuning** being given the sodo lanang (**VERIFY** by whom). Teaches **strike the water** | Peaceful: the river dries. Fight: Yuyu Kangkang |
| SQ-T2 Banaspati (L) | The herder's grass burning in a line with no wind | a scorched trail that circles back; a campfire nobody lit | **A herder boy** who learns the fire won't cross running water (**ASSUMED**, game retelling). Teaches the spring arena | Fight at the spring |
| SQ-K2 Bajul Putih Tua (L) | Nets torn from the inside | a white scale; Mbah Wiryo on "the old one who keeps the river mouth" | **A fisher** leaving an offering at the river mouth (**VERIFY**, belief with respect). Teaches **the tide tell** before its charge | Fight; the old one is driven back into the deep, not killed (a fade) |
| SQ-G2 Ririwa of the Kaputren (L, two-way) | Someone sweeps the women's quarters every night; the broom is found worn to the handle | the worn broom; a servants' roll with one name scraped out | **The servant's last day**: sweeping while nobody says his name. Teaches **his name is in the roll's ink** | Peaceful: write his name (`name_written`). Fight: elite ririwa (**VERIFY** the term) |

### New Keraton Galuh stories (Act II had none)
- **SQ-G1 Si Kabayan** (M, retelling, comic): the lazy, clever Sundanese trickster outwits a pompous official at the alun-alun during the tournament. The memory is one short Kabayan tale you play (**VERIFY** which tale). Adds a lakon.
- **SQ-G2 Ririwa of the Kaputren** (above): a forgotten palace servant. It foreshadows the borrowed-name theme before the confession, without naming it.
- **SQ-C1** (below) is also here. Gua Kala keeps **no** side stories (Act VI is dense, no filler).

### Companion stories (no new named speakers)
- **SQ-C1 Ciung's rooster** (Act II, M): his rooster has run off before the tournament. Clues through the alun-alun. Memory: the baby in a basket on the river, holding the egg that became his rooster (**VERIFY** the Ciung Wanara motif). No bout is shown (Sensitivity). Ciung: the rooster is the only family he knew he had.
- **SQ-C2 Letters to Mother** (Acts III-IV, M, cross-zone): after the truce, carry Hariang Banga's letters (the clue `hariang_letters`) to his mother in Galuh. She writes back; her reply lies on the Interlude table.
- **SQ-C3 The Deserter's Name** (Acts III-VI, L, chain): one name fragment per act (III camp, IV desert road, V shore), each a clue. At the Gua Kala mouth you write his name on a write card. Two variants by Choice 1: *freed*, he walks at the edge of each camp and asks; *handed*, Uwa Lengser's note says he keeps saying one sound in his cell. Freed adds a line on his epilogue card. His name is **ASSUMED** (quests.md picks it; its glyphs must pass `glyph_strokes.py`).
- **SQ-C4 Brave Cepot** (chain, S each): part 1 is SQ-S4 (Act I). Part 2 (Act III): he has signed up with both recruiters at the river market; get him out before either side notices. Part 3 (Act V): he followed you to the coast, terrified of the sea, and holds the lamp over the hatchlings' beach through one wave. Payoff: one line on the epilogue card, Cepot telling the village children the story, wrong but brave.

### Camp talks (Pacing rule 6)
Optional `quiet` NPC entries, 2-4 lines, each closed by a `zone:` cond so it never replays in a later act (the `camp_galuh`/`camp_timur` pattern).
- **`camp_sunda`** (I): Ciung by the lake after Sangkuriang. His anger, and the mother he doesn't know; the player knows she is the woman by the lake, he doesn't (the epilogue keeps that reveal).
- **`camp_mataram`** (III): Hariang Banga at the ford after the truce. The first time you two talk as brothers, not rivals.
- **`camp_kidul`** (V): Mbah Wiryo at the black-sand petilasan after the trial. What he'll say to the sea now.

## Delivery
- Name tags on first speech (Pacing rule 11), Hunts with Kelir memories (Hunts), the journal's "Story so far" (Pacing rule 14).
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
Main quest steps, side quests (folklore retellings, side Hunts, errands and companion stories; see "Side stories (v4d)"), rewards and the quest system are in [quests.md](quests.md).

## Ending conditions
There is a single ending. Each of the 3 choices changes one epilogue card, and codex completion changes the credits text only (**ASSUMED**).
