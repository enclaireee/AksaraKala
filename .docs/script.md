# Script: Story v4/v4b/v4c main path (ID and EN)

Every main-path line, keyed, Indonesian first. Canon: [story.md](story.md). Steps, beats and flags: [quests.md](quests.md) 4. Rewritten 2026-11-06 (Claude) for Story v4, v4b and v4c, all **ASSUMED** until the user's playtest; culture facts keep their **VERIFY** tags.

**Line budget (ASSUMED, TUNE).** The v3.1 budget was 450 lines. v4 adds a playable prologue day, 31 clues, 26 memories and chapters and 78 recaps, so the new budget is 870 lines for sections 3-11 (now 786). Each section below states its own count. Keep new lines short; trim before adding.

## 1. Rules
- **Talks:** at most 4 lines per NPC talk and 6 per story beat, hero lines (`@NPC_HERO_NAME`) included; choice labels don't count. Every talk ends on a lead (what to do or where to go next).
- **Lines:** one idea per line, about 100 EN characters (**TUNE** against the dialogue box, 3 lines). At most one "!" per talk. No parenthesised stage directions: narration uses the bare `@` speaker. No em dashes.
- **Villains don't explain the plot;** a beat shows it. The hero speaks plainly and doesn't shout names.
- **Show, don't explain.** A character wants something, says it in a concrete detail, and moves on. Lore goes to the codex (section 13: 1-3 sentences, labelled "legend" or "game").
- **Know before you meet (v4, Pacing 10).** In reading order (the order of this file), a name's first use comes at or after the moment the player saw that person, place or thing, or it is explained in the same line ("Sandekala, the dusk spirit"). A name tag counts as seeing. Exceptions are listed in the check note at the end of section 3.
- **Cast cuts (v4).** The cut names listed in section 3 never appear in a main-path line; helpers use their display names. Codex bodies may name the legend figures.
- **Tone:** grounded, specific, a little wry (The Witcher 3). Warm humour comes from Semar and the punakawan; the world is never mocked ([concept.md](concept.md) Tone).
- **Regional arcs:** each act's regional character gets an intro line that shows their want, a turn, and a closing line in the aftermath (Ibu, Naganingrum, Lengser and the Deserter, Ki Sumarto, Wirasana, Wiryo).
- **The Hunter** speaks rarely: the raid, the west gate, the throne shadow, the graves, the duel's end. Silent at the crater, the shrine and in the Interlude. **Laras** (a beat or a chapter) speaks in her own voice: brave, funny, never a victim. The Interlude is quiet and short.
- **Glyphs are earned** by a deed first ([quests.md](quests.md) 4). A teacher names or shows the glyph; nobody hands it over.
- **Hunts (v4).** A clue has 1-2 lines of the hero's own thought and a one-line journal note. A Kelir memory has a title, Semar's line in and out (Laras chapters have no Semar), the few lines shown inside it, and for play memories a hint of at most 4 words. Memories never show a kill: they end on the lamp.
- Semar is warm and wry ("hehe"). Lengser is sharp and loyal. Ciung Wanara is fierce and brotherly. Hariang Banga is honourable. The Hunter is cold. Laras is quick, funny and brave.
- **Sensitivity:** the rooster fights off-screen and the hero never bets or handles it. Kala is calmed, never killed. Nyi Roro Kidul is belief, speaks once from a distance, is never fought, and in K9 is one retelling among several. The Majapahit claim is only ever "some tellings say". Culture facts keep their **VERIFY** tags; every new cultural claim below carries one.
- Indonesian is natural spoken Indonesian; Sundanese or Javanese address terms (`Abah`, `Mbah`, `Uwa`, `Nyi`, `Mbok`, `Ki`) appear only where the speaker would use them. EN strings may use `{they}` `{them}` `{their}` `{They}` and `{name}`; ID strings never need the pronoun tokens (`dia`, `-nya`).

## 2. Format (for the data wiring)
- Each NPC section is one `data/dialogue/<npc_id>.tres` (`DialogueData`, `npc_id`, `name_key`, `entries`). Entries are listed in order; the first whose `if` holds wins. An entry with `"quiet": true` never completes a `talked_to` step.
- An entry's `lines` are its keys in table order. A row `@NPC_X_NAME` (no text) is a speaker switch: put the string `"@NPC_X_NAME"` in `lines` ([ui.md](ui.md) 3, `ui/dialogue_box.gd`). A bare `@` row clears the tag (narration), as `beats.tres` already does.
- `choices` is `[{"text": KEY, "do": [...]}, ...]`, shown under the last line.
- Beats live in `data/dialogue/beats.tres` (npc_id `beats`, name_key `""`). Lines with no speaker row are narration. Every beat's `if` starts with `!flag:beat_<id>` and its `do` starts with `flag:beat_<id>`, so it plays once.
- Keys: NPC talks `DLG_<NPC>_V<n>` (NPC lines) and `DLG_<NPC>_H<n>` (hero lines). Beats `BEAT_<ID>_<n>`, hero lines `BEAT_<ID>_H<n>`. Choices `CHOICE_<ID>_<n>`. All go in `data/text/dialogue.csv` (columns `keys,id,en`). Tables below list **ID first, then EN**.
- **v4 keys** (all `dialogue.csv`): clue examine lines `CLUE_<ID>_1`, `_2` (the hero's thought, spoken as `NPC_HERO_NAME`), journal note `CLUE_<ID>_NOTE`; Hunt title `HUNT_<ID>_TITLE`; memory title `MEM_<ID>_TITLE`, Semar in `MEM_<ID>_IN` (and `_IN_2` if two lines), Semar out `MEM_<ID>_OUT` (and `_OUT_2`), lines shown inside `MEM_<ID>_1..n`, hint `MEM_<ID>_HINT`; Laras chapters `LC_<n>_TITLE` and `LC<n>_<m>` (speaker `NPC_LARAS_NAME`); gap prompts `GAP_<GAP>_P` and options `GAP_<GAP>_1..3`; recap `Q_<QUEST>_S<n>_DONE`; name tag `NPC_<ID>_WHO`. `<ID>` is the id upper-cased (`k1_maghrib` is `K1_MAGHRIB`).
- "Keep" means the entry stays as it is in the current `.tres`. Old keys leave the CSV only when nothing else references them (section 14).
- Step indices are 0-based and follow [quests.md](quests.md) 4: `step:mq1=2` is step 1.3. Where a step has several triggers, an entry names the flag its trigger sets.
- Lakon and codex grants use `lakon:<id>` and `codex:<id>` in a `do`; `clue:<id>` sets a clue (quests.md 7.1).
- **Area triggers marked ASSUMED** (`purwa_tag_cat` and the like) set the flag named in the beat's `if`; the zone docs place them.

## 3. Names (`dialogue.csv`, next to the existing `NPC_*_NAME` rows)
**Lines in this section: 69** (ASSUMED budget: at most 80).
Display names only; NPC ids and files are unchanged (quests.md 4, cast cuts). `Key` rows below replace the existing text.

| Key | ID | EN |
|-----|----|----|
| NPC_IBU_NAME | Ibu | Ibu |
| NPC_LARAS_NAME | Laras | Laras |
| NPC_PURWA_OLD_COUPLE_NAME (new) | Pasangan tua | The old couple |
| NPC_NINI_NAME (text changes) | Nenek tetangga | The old woman next door |
| NPC_CEPOT_NAME | Cepot | Cepot |
| NPC_PURWA_STALL_NAME (new) | Penjaga lapak | The stall-keeper |
| NPC_HUNTER_NAME | Si Tanpa Ngaran | The Nameless Hunter |
| NPC_SUNDA_ELDER_NAME (text changes) | Sesepuh Kampung | The kampung elder |
| NPC_SUNDA_GRANDSON_NAME (new) | Cucu sesepuh | The elder's grandson |
| NPC_SUNDA_MOTHER_NAME (new) | Seorang ibu | A mother |
| NPC_SUNDA_WEAVER_NAME | Penenun | The Weaver |
| NPC_NAGANINGRUM_NAME | Perempuan di tepi danau | Woman by the lake |
| NPC_NAGAWIRU_NAME | Nagawiru | Nagawiru |
| NPC_CIUNG_WANARA_NAME | Ciung Wanara | Ciung Wanara |
| NPC_GALUH_SELLER_NAME (new) | Penjual ayam jago | The rooster seller |
| NPC_LENGSER_NAME | Uwa Lengser | Uwa Lengser |
| NPC_FACELESS_DESERTER_NAME | Si pembelot | The deserter |
| NPC_BARMA_WIJAYA_NAME | Prabu Barma Wijaya | Prabu Barma Wijaya |
| NPC_PANGRENYEP_NAME (text changes) | Sang permaisuri | The queen |
| NPC_HARIANG_BANGA_NAME | Hariang Banga | Hariang Banga |
| NPC_RECRUITER_A_NAME (new) | Perekrut tepi barat | The west-bank recruiter |
| NPC_RECRUITER_B_NAME (new) | Perekrut tepi timur | The east-bank recruiter |
| NPC_MATARAM_DALANG_NAME | Ki Sumarto | Ki Sumarto |
| NPC_SAPTO_NAME | Sapto | Sapto |
| NPC_ARCA_BASE_NAME | Tulisan di dasar Arca | Inscription on the Arca |
| NPC_LESUNG_WOMEN_NAME | Perempuan lesung | The lesung women |
| NPC_JURU_KUNCI_NAME (text changes) | Juru kunci | The juru kunci |
| NPC_PAMALI_STONE_NAME | Batu Pamali | Pamali stone |
| NPC_TIMUR_DAUGHTER_NAME (new) | Putri sang empu | The smith's daughter |
| NPC_TIMUR_EMPU_NAME | Mpu Wirasana | Mpu Wirasana |
| NPC_MBOK_SRINI_NAME (text changes) | Sang janda | The widow |
| NPC_ARIA_KEBONAN_NAME (new) | Aria Kebonan | Aria Kebonan |
| NPC_WIRYO_NAME | Mbah Wiryo | Mbah Wiryo |
| NPC_RATU_KIDUL_NAME | Nyi Roro Kidul | Nyi Roro Kidul |
| NPC_KIDUL_ALTAR_NAME | Altar Laut | Sea Altar |
| NPC_SEMAR_NAME | Semar | Semar |

`NPC_SEMAR_NAME` is unchanged. The `kidul_jurukunci.tres` `name_key` stays `NPC_WIRYO_NAME`.

**Cast note (v4).** The kampung elder was Abah Karna, the juru kunci was Mbah Marto, the widow was Mbok Srini, the queen was Dewi Pangrenyep, and the old couple were Aki and Nini Balangantrang; those names stay only in codex bodies. Ki Wangsa is cut: `NPC_KI_WANGSA_NAME` is retired (section 14) and Semar is the village dalang.

**Name tags (`NPC_<ID>_WHO`, ui.md 3).** One line, 40 characters at most, shown once at a character's first speech. The name comes first, as in the tag example.

| Key | ID | EN |
|-----|----|----|
| NPC_LARAS_WHO | Laras. Adikmu, cepat dan nekat. | Laras. Your sister. Quick and bold. |
| NPC_IBU_WHO | Ibu. Ibumu, selalu cemas. | Ibu. Your mother. Always worried. |
| NPC_PURWA_OLD_COUPLE_WHO | Pasangan tua. Pengasuh Ciung. | The old couple. Ciung's keepers. |
| NPC_NINI_WHO | Nenek tetangga. Pengasuh Ciung. | The old woman next door. |
| NPC_CIUNG_WANARA_WHO | Ciung. Bocah liar sebelah rumah. | Ciung. The wild boy next door. |
| NPC_SEMAR_WHO | Semar. Dalang desa. | Semar. The village dalang. |
| NPC_CEPOT_WHO | Cepot. Putra Semar. Berisik. | Cepot. Semar's son. Loud. |
| NPC_PURWA_STALL_WHO | Penjaga lapak. Tahu semua gosip. | The stall-keeper. Hears it all. |
| NPC_HUNTER_WHO | Si Tanpa Ngaran. Memimpin para topeng. | The Nameless Hunter. Leads the masks. |
| NPC_SUNDA_GRANDSON_WHO | Cucu sesepuh. Belajar angklung. | The elder's grandson. Learns angklung. |
| NPC_SUNDA_MOTHER_WHO | Seorang ibu. Putranya hilang. | A mother. Her son is missing. |
| NPC_SUNDA_ELDER_WHO | Sesepuh Kampung. Kenal semua orang. | The kampung elder. Knows everyone. |
| NPC_SUNDA_WEAVER_WHO | Penenun. Tahu kain kuno. | The Weaver. Knows the old cloth. |
| NPC_NAGANINGRUM_WHO | Perempuan di tepi danau. Menunggu. | A woman by the lake. Waiting. |
| NPC_NAGAWIRU_WHO | Nagawiru. Raja tua, kini naga. | Nagawiru. The old king, now a naga. |
| NPC_GALUH_SELLER_WHO | Penjual ayam jago. Suka keramaian. | The rooster seller. Loves a crowd. |
| NPC_LENGSER_WHO | Uwa Lengser. Abdi tua istana. | Uwa Lengser. The palace's old servant. |
| NPC_FACELESS_DESERTER_WHO | Si pembelot. Topeng yang mengingat. | The deserter. A mask, remembering. |
| NPC_BARMA_WIJAYA_WHO | Barma Wijaya. Raja Galuh. | Barma Wijaya. King of Galuh. |
| NPC_PANGRENYEP_WHO | Sang permaisuri. Ibu Hariang Banga. | The queen. Hariang Banga's mother. |
| NPC_HARIANG_BANGA_WHO | Hariang Banga. Pangeran Galuh. | Hariang Banga. A prince of Galuh. |
| NPC_RECRUITER_A_WHO | Perekrut tepi barat. | The west-bank recruiter. |
| NPC_RECRUITER_B_WHO | Perekrut tepi timur. | The east-bank recruiter. |
| NPC_MATARAM_DALANG_WHO | Ki Sumarto. Dalang dua tepi. | Ki Sumarto. A dalang for both banks. |
| NPC_SAPTO_WHO | Sapto. Putra Ki Sumarto. | Sapto. Ki Sumarto's son. |
| NPC_LESUNG_WOMEN_WHO | Perempuan lesung. Penumbuk padi. | The lesung women. Rice pounders. |
| NPC_JURU_KUNCI_WHO | Juru kunci. Penjaga bukit keramat. | The juru kunci. Keeper of a holy hill. |
| NPC_TIMUR_DAUGHTER_WHO | Putri sang empu. Melipat keris. | The smith's daughter. Folds keris. |
| NPC_TIMUR_EMPU_WHO | Mpu Wirasana. Pembuat keris. | Mpu Wirasana. A keris smith. |
| NPC_MBOK_SRINI_WHO | Sang janda. Pondoknya hancur. | The widow. Her hut was smashed. |
| NPC_ARIA_KEBONAN_WHO | Aria Kebonan. Nama si Pemburu. | Aria Kebonan. The Hunter's own name. |
| NPC_WIRYO_WHO | Mbah Wiryo. Penjaga pantai. | Mbah Wiryo. Keeper of the coast. |
| NPC_RATU_KIDUL_WHO | Nyi Roro Kidul. Ratu laut selatan. | Nyi Roro Kidul. Queen of the south sea. |

Boss bar names (`ui.csv`, next to the existing `BOSS_*`): BOSS_FACELESS_CAPTAIN "Faceless Captain" / "Kapten Tanpa Rupa"; BOSS_NAMELESS_HUNTER "The Nameless Hunter" / "Si Tanpa Ngaran"; BOSS_BARMA_WIJAYA "Prabu Barma Wijaya" / "Prabu Barma Wijaya"; BOSS_HARIANG_BANGA "Hariang Banga" / "Hariang Banga".


**Side-story names (v4d).** New or re-keyed speakers for section 15. Display names only; the `.tres` ids are in the headings of section 15. Existing ids keep their files; `m2_neighbour`, `m3_smith`, `t2_herder`, `k2_fisher` and `galuh_queen` are new ids (the old `wewe_neighbor`, `pande_besi`, `timur_herder` files are replaced, and `NPC_KI_DARSA_NAME`, `NPC_KEPALA_DESA_NAME` and the like only need their text confirmed). **Lines in this block: 34** (ASSUMED budget: at most 40).

| Key | ID | EN |
|-----|----|----|
| NPC_KI_DARSA_NAME | Ki Darsa | Ki Darsa |
| NPC_KEPALA_DESA_NAME (text changes) | Kepala desa | The village head |
| NPC_PURBASARI_NAME | Purbasari | Purbasari |
| NPC_KABAYAN_NAME (new) | Si Kabayan | Si Kabayan |
| NPC_GALUH_OFFICIAL_NAME (new) | Pejabat alun-alun | The square's official |
| NPC_KAPUTREN_MAID_NAME (new) | Pelayan kaputren | The kaputren maid |
| NPC_NAWANG_WULAN_NAME | Nawang Wulan | Nawang Wulan |
| NPC_M2_NEIGHBOUR_NAME (new) | Tetangga yang cemas | A worried neighbour |
| NPC_M2_PARENTS_NAME (new) | Orang tua si anak | The boy's parents |
| NPC_M3_SMITH_NAME (new) | Pande besi | The blacksmith |
| NPC_KLETHING_KUNING_NAME | Klething Kuning | Klething Kuning |
| NPC_T2_HERDER_NAME (new) | Penggembala | The herder |
| NPC_K2_FISHER_NAME (new) | Nelayan muara | The river-mouth fisher |
| NPC_GALUH_QUEEN_NAME (new; same text as `NPC_PANGRENYEP_NAME`) | Sang permaisuri | The queen |
| NPC_ANGKLUNG_LEADER_NAME | Pemimpin angklung | The angklung leader |
| NPC_KEPANG_LEADER_NAME | Pemimpin kuda lumping | The kuda lumping leader |
| NPC_KIDUL_NELAYAN_ANAK_NAME | Anak nelayan | The fisher's child |
| NPC_KI_DARSA_WHO | Ki Darsa. Penyanyi kisah lama. | Ki Darsa. Sings the old tales. |
| NPC_KEPALA_DESA_WHO | Kepala desa. Takut pada rumpun bambu. | The village head. Fears the bamboo. |
| NPC_PURBASARI_WHO | Purbasari. Gadis berkulit belang. | Purbasari. A girl with spotted skin. |
| NPC_KABAYAN_WHO | Si Kabayan. Malas, tapi cerdik. | Si Kabayan. Lazy, but clever. |
| NPC_GALUH_OFFICIAL_WHO | Pejabat. Suka berteriak. | An official. Likes to shout. |
| NPC_KAPUTREN_MAID_WHO | Pelayan kaputren. Menjaga lorong. | The kaputren maid. Keeps the hall. |
| NPC_NAWANG_WULAN_WHO | Nawang Wulan. Menatap periuk. | Nawang Wulan. Eyes on a pot. |
| NPC_M2_NEIGHBOUR_WHO | Tetangga. Anak sebelah hilang. | A neighbour. A boy next door is lost. |
| NPC_M2_PARENTS_WHO | Orang tua si anak. Terlalu sibuk. | The boy's parents. Too busy. |
| NPC_M3_SMITH_WHO | Pande besi. Koinnya raib. | The blacksmith. His coins vanish. |
| NPC_KLETHING_KUNING_WHO | Klething Kuning. Ingin menyeberang. | Klething Kuning. Must cross. |
| NPC_T2_HERDER_WHO | Penggembala. Rumputnya terbakar. | The herder. His grass burns. |
| NPC_K2_FISHER_WHO | Nelayan muara. Jaringnya robek. | River-mouth fisher. Torn nets. |
| NPC_GALUH_QUEEN_WHO | Sang permaisuri. Ibu Hariang Banga. | The queen. Hariang Banga's mother. |
| NPC_ANGKLUNG_LEADER_WHO | Pemimpin angklung. Kehilangan nada. | Angklung leader. Missing notes. |
| NPC_KEPANG_LEADER_WHO | Pemimpin kuda lumping. Kudanya hilang. | Kuda lumping leader. Lost horses. |
| NPC_KIDUL_NELAYAN_ANAK_WHO | Anak nelayan. Menjaga pantai. | A fisher's child. Watches the beach. |

Name check: `python3 .docs/know_check.py` (Pacing 10) runs over sections 4-11 and 15. Name check exceptions: (none)

## 4. Prologue cards (`PROLOGUE_1`-`_2`, `ui/prologue.tscn`: lines 2, `semar_from = 0`, `semar_to = 0`)
**Lines in this section: 2** (ASSUMED budget: at most 10).
Two cards before the class choice and the first step. They show a normal day: no shadows, no raid. `PROLOGUE_3`-`_5` are retired (section 14); their moments are the `raid` beat and its morning card (section 5).

| Key | ID | EN |
|-----|----|----|
| PROLOGUE_1 | Desa Purwa, fajar. Sebuah desa kecil di tepi kerajaan-kerajaan tua, tempat semua orang tahu nama semua orang. | Desa Purwa, dawn. A small village at the edge of the old kingdoms, where everyone knows everyone's name. |
| PROLOGUE_2 | Malam ini wayang ruwatan: sang dalang membacakan nama anak-anak desa agar mereka terlindung. Sampai malam, hari ini biasa saja. Adikmu, Laras, sudah mengetuk pintu. | Tonight is the wayang ruwatan: the dalang reads the children's names aloud to ward them. Until then, an ordinary day. Your little sister Laras is already knocking. |

The dalang reading the children's names aloud at a ruwatan (PROLOGUE_2) is **VERIFY** (story.md Spine). "Dalang" is explained by Semar's name tag in the first talk and by this card ("the dalang reads").


## 5. Prologue: A Day in Desa Purwa (MQ0)
**Lines in this section: 87** (ASSUMED budget: at most 100).
Regional character: Ibu (want: two cups she cannot explain; turn: the Interlude; close: the epilogue). The day is calm: tag, tea, a walk with talks, the sanggar, the Kelir show. Everything the game needs later is shown first and named second. The details here are what the Act VI gap memories test, so they must not change: the stray cat is **Kunyit**; the banyan is **Ki Waringin**; the tag ends at **the well**; Laras takes **the chipped cup** (jasmine tea); Ibu says "home before **the show**"; Laras writes with **Semar's bamboo pen**, **your name first**; Semar says a written name **keeps a person in the world**.

### Chapter 1: Morning and Market (0.1-0.3)

### laras (Desa Purwa, name NPC_LARAS_NAME; new `.tres`)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=0`, `!flag:tag_started` (0.1) | `flag:tag_started` |
| 2 | `step:mq0=0` | |
| 3 | `step:mq0=1` (0.2, tea) | |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_LARAS_V1 | Kak! Bangun! Ruwatan malam ini, dan aku mau pamer larinya jago. Tangkap aku kalau bisa! | Kak! Wake up! The ruwatan is tonight, and I want to show off how fast I run. Catch me if you can! |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LARAS_H1 | Laras, ini masih subuh. | Laras, it's barely dawn. |
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_LARAS_V2 | Takut kalah, ya? Satu, dua... sampai sumur, Kak! Yang kalah cuci piring! | Scared to lose? One, two... to the well, Kak! Loser washes the dishes! |
| 2 | DLG_LARAS_V3 | Lambat banget! Sumurnya di sana, Kak! | So slow! The well's over there, Kak! |
| 3 | DLG_LARAS_V4 | Kena aku! Hehe. Ibu sudah menyeduh teh, cepat, sebelum dingin. | You got me! Hehe. Ibu's brewed the tea, quick, before it goes cold. |
| 4 | DLG_LARAS_V5 | Kak, kalau aku hilang di keramaian, cari saja yang paling berisik. Itu aku. | Kak, if I get lost in the crowd, just find the loudest one. That's me. |

### Beat `tag_cat` (if `!flag:beat_tag_cat`, `flag:tag_cat`, `step:mq0=0`; do `flag:beat_tag_cat`). Area `purwa_tag_cat` sets `tag_cat` (ASSUMED). The gift is shown, then named.
| Key | ID | EN |
|-----|----|----|
| BEAT_TAG_CAT_1 | Seekor kucing jingga duduk di atas tembok dan menatap kalian. Laras berhenti mendadak. | An orange stray sits on a wall and watches you both. Laras skids to a stop. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_CAT_2 | Namamu bukan Meong, kan? Kunyit. Sini, Kunyit. | Your name isn't Puss, is it? Kunyit. Here, Kunyit. |
| @ | | |
| BEAT_TAG_CAT_3 | Kucing itu melompat turun dan menggosokkan kepalanya ke kaki Laras, seperti dipanggil oleh kenalan lama. | The cat hops down and rubs its head on Laras's ankle, like it was called by an old friend. |
| @NPC_HERO_NAME | | |
| BEAT_TAG_CAT_H1 | Kau tahu namanya dari mana? | How did you know its name? |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_CAT_4 | Dia sendiri yang bilang. Semua punya nama sendiri, Kak. Ayo, sumur! | It told me. Everything has a name of its own, Kak. Come on, the well! |

### Beat `tag_banyan` (if `!flag:beat_tag_banyan`, `flag:tag_banyan`, `step:mq0=0`; do `flag:beat_tag_banyan`). Area `purwa_tag_banyan` sets `tag_banyan` (ASSUMED).
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_TAG_BANYAN_1 | Di bawah beringin tua, Laras menepuk batangnya seperti menyapa seorang kakek. | Under the old banyan Laras pats the trunk like she's greeting a grandfather. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_BANYAN_2 | Permisi, Ki Waringin. Kami cuma lewat. | Excuse us, Ki Waringin. We're only passing through. |
| @ | | |
| BEAT_TAG_BANYAN_3 | Daun-daun di atas kalian bergetar, padahal tak ada angin. | The leaves above you shiver, though there is no wind. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_BANYAN_4 | Dia suka disapa pakai namanya. Kamu juga, kan, Kak? | He likes being greeted by his name. So do you, Kak. |

### ibu (name NPC_IBU_NAME). Entry order for the whole game (the Interlude and epilogue lines are in sections 10 and 11)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=1`, `!flag:mq0_d2` (0.2, tea) | |
| 2 | `step:mq4=2`, `item:laras_ribbon,item:laras_board,item:laras_strip_ka` (4.3, section 10) | |
| 3 | `step:mq4=2` (4.3, no items yet, `"quiet": true`, section 10) | |
| 4 | `step:mq0=5` (0.6, the morning after) | |
| 5 | `flag:mq5_4` (epilogue, section 11) | |
| 6 | `quest:mq0=active` | |
| 7 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_IBU_NAME | | |
| 1 | DLG_IBU_V20 | Duduk, minum dulu. Teh melati, dua cangkir: satu untuk Laras, satu untukmu. | Sit, drink. Jasmine tea, two cups: one for Laras, one for you. |
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_IBU_L1 | Aku yang gompal! Kalau tak ada yang pakai, dia sedih. | I get the chipped one! If nobody uses it, it gets sad. |
| 1 | @NPC_IBU_NAME | | |
| 1 | DLG_IBU_V21 | Pulang sebelum pertunjukan, berdua. Dan tolong jemput Ciung, anak tetangga kita. Sejak subuh dia di pohon. | Home before the show, both of you. And fetch Ciung, our neighbours' boy. He's been up a tree since dawn. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_IBU_H20 | Ciung dan pohonnya. Beres, Bu. | Ciung and his tree. Leave it to me, Ibu. |

### purwa_old_couple (the neighbours' lane; name NPC_PURWA_OLD_COUPLE_NAME; new). The couple who raised Ciung. Ibu's line "our neighbours' boy" came first.
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=1`, `!flag:mq0_d3` (0.2) | |
| 2 | `quest:mq0=active` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_PURWA_OLD_COUPLE_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_V1 | Nak, tolong. Cucu kami, Ciung, memanjat pohon sejak subuh dan tak mau turun. | Child, please. Our boy Ciung has been up that tree since dawn and won't come down. |
| 1 | DLG_PURWA_OLD_COUPLE_V2 | Ia memeluk sebutir telur aneh. Katanya bukan miliknya, hanya titipan. | He's hugging a strange egg. He says it isn't his, only left in his keeping. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_H1 | Akan kubawa dia turun. | I'll bring him down. |
| 1 | @NPC_PURWA_OLD_COUPLE_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_V3 | Terima kasih. Pohonnya di ujung lorong, dekat pagar kami. | Bless you. The tree is at the end of the lane, by our fence. |
| 2 | DLG_PURWA_OLD_COUPLE_V4 | Ciung anak baik. Hanya keras kepala. | Ciung is a good boy. Only stubborn. |

### ciung_wanara, prologue entries (put first in the file; the Act II to VI entries follow unchanged, section 7)
| Entry | if | do |
|-------|----|----|
| P1 | `quest:mq0=active`, `flag:mq0_d2`, `!flag:mq0_d3` (0.2) | |
| P2 | `quest:mq0=active`, `flag:mq0_d3` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| P1 | @NPC_HERO_NAME | | |
| P1 | DLG_CIUNG_WANARA_H10 | Ciung! Turunlah. Kakek-nenekmu cemas. | Ciung! Come down. Your grandparents are worried. |
| P1 | @NPC_CIUNG_WANARA_NAME | | |
| P1 | DLG_CIUNG_WANARA_V20 | Tidak mau. Telur ini hangat kalau kupeluk, dingin kalau kutaruh. | No. This egg stays warm if I hold it and goes cold if I put it down. |
| P1 | @NPC_LARAS_NAME | | |
| P1 | DLG_CIUNG_WANARA_L1 | Ciung itu bukan seluruh namamu, tahu. Kau cuma belum kenal sisanya. | Ciung isn't your whole name, you know. You just haven't met the rest. |
| P1 | @NPC_CIUNG_WANARA_NAME | | |
| P1 | DLG_CIUNG_WANARA_V21 | Bicaramu aneh. Ya sudah, aku turun. Telurnya ikut. | You talk strange. Fine, I'm coming down. The egg comes too. |
| P2 | DLG_CIUNG_WANARA_V22 | Aku pulang dulu, lalu ke ruwatan. Jangan bilang siapa-siapa soal telur ini. | I'm going home, then to the ruwatan. Don't tell anyone about this egg. |

### semar (sanggar; drop every old main-path entry). Entry order for the whole game
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=2`, `!flag:mq0_d4` (0.3) | |
| 2 | `step:mq0=2`, `flag:mq0_d4` | |
| 3 | `step:mq0=3` (0.4, the show; the kelir spot starts K0, ASSUMED) | |
| 4 | `step:mq0=5` (0.6) | |
| 5 | `step:mq0=6`, `!glyph:sunda_ka`, `flag:mq0_5` (0.7) | `learn:sunda_ka` |
| 6 | `step:mq0=6` | |
| 7 | `step:mq0=7` (0.8) | |
| 8 | `step:mq0=8` (0.9) | |
| 9 | `step:mq4=4` (4.5, section 10) | |
| 10 | `quest:mq4=active` | |
| 11 | `quest:mq5=active` | |
| 12 | `flag:mq5_4` | |
| 13 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_V30 | Hehe, murid yang tak pernah tepat waktu. Lihat: aksara, tulisan kuno kita, bukan sekadar huruf. Digambar dengan hati, ia jadi tenaga. | Hehe, the apprentice who's never on time. Look: aksara, our old script, aren't just letters. Drawn with heart, they become power. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SEMAR_H30 | Dan nama? | And names? |
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_V31 | Nama yang ditulis menahan seseorang tetap ada di dunia. Itu sebabnya malam ini nama anak-anak dibacakan. | A written name keeps a person in the world. That's why the children's names are read tonight. |
| 1 | DLG_SEMAR_V32 | Laras, bawa lontarmu ke meja itu dan tulis namamu. Lalu tanyakan ke pasar, hehe. Gosip kadang berguna. | Laras, bring your lontar to that table and write. Then try the market, hehe. Gossip is sometimes useful. |
| 2 | DLG_SEMAR_V33 | Lontar di meja dekat jendela, lalu ke pasar. | The lontar's on the table by the window, then the market. |
| 3 | DLG_SEMAR_V34 | Waktunya. Duduklah di balik layar, Nak. Kau yang memegang wayang pertama, hehe. | It's time. Sit behind the screen, child. You hold the first puppet, hehe. |
| 10 | DLG_SEMAR_V10 | Laut selatan. Orang pesisir bilang laut tak pernah lupa. Semoga mereka benar, hehe. | The south sea. The coast folk say the sea never forgets. I hope they're right, hehe. |
| 11 | DLG_SEMAR_V14 | Gua itu lewat kabut di belakang desa. Aku sampai duluan, hehe. | The cave is through the fog behind the village. I'll get there first, hehe. |
| 12 | DLG_SEMAR_V15 | Ssst, pertunjukannya mulai. Tebak lakon siapa. | Shh, the show's starting. Guess whose lakon it is. |
| 13 | DLG_SEMAR_V16 | Setiap kisah dimulai dari orang yang mengingatnya. | Every story starts with someone who remembers it. |

### cepot (the sanggar, 0.3; entry added first in `cepot.tres`, `"quiet": true`; name NPC_CEPOT_NAME)
The Act I Cepot entries (SQ-S4) follow; see section 6.
| Entry | if | do |
|-------|----|----|
| P1 | `step:mq0=2` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| P1 | @NPC_CEPOT_NAME | | |
| P1 | DLG_CEPOT_P1 | Ayah! Ceritakan lagi yang ada raksasanya! Ayah? Ayah dengar tidak? | Father! Tell the one with the giant again! Father? Are you even listening? |
| P1 | DLG_CEPOT_P2 | Katanya aksara dulu, raksasa belakangan. Membosankan. | He says aksara first, giants later. Boring. |

### Beat `lontar_names` (if `!flag:beat_lontar_names`, `flag:mq0_d5`; do `flag:beat_lontar_names`). Area `sanggar_lontar` sets `mq0_d5`. The plant for the tear.
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_LONTAR_NAMES_1 | Laras menulis dengan pena bambu Semar. Namamu dulu, rapi, di satu ujung. Namanya sendiri di ujung lain, lebih kecil. | Laras writes with Semar's bamboo pen. Your name first, neat, at one end. Her own at the other end, smaller. |
| @NPC_LARAS_NAME | | |
| BEAT_LONTAR_NAMES_2 | Sekarang tukar! Kau pegang ujung yang bernamaku, aku yang bernamamu. | Now swap! You hold the end with my name, I hold the end with yours. |
| @NPC_HERO_NAME | | |
| BEAT_LONTAR_NAMES_H1 | Kenapa begitu? | Why like that? |
| @NPC_LARAS_NAME | | |
| BEAT_LONTAR_NAMES_3 | Supaya kita tak bisa saling lupa. Satu lontar, dua pegangan. | So we can't forget each other. One lontar, two hands. |
| @NPC_SEMAR_NAME | | |
| BEAT_LONTAR_NAMES_4 | Hehe, ditulis dengan benar. Simpan baik-baik. Sekarang pasar. | Hehe, written properly. Keep it safe. Now the market. |

### purwa_stall (the market; name NPC_PURWA_STALL_NAME; new)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=2`, `flag:mq0_d5`, `!flag:mq0_d6` (0.3) | |
| 2 | `quest:mq0=active` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_PURWA_STALL_NAME | | |
| 1 | DLG_PURWA_STALL_V1 | Kau murid Semar, kan? Dengar, tadi pagi ada lelaki jangkung bertopeng polos menanyai nama anak-anak. | You're Semar's apprentice, aren't you? Listen, this morning a tall man in a blank mask was asking children's names. |
| 1 | DLG_PURWA_STALL_V2 | Aku tak bilang apa-apa. Lapakku tutup sejam lebih awal hari ini. | I told him nothing. I'm shutting my stall an hour early today. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PURWA_STALL_H1 | Topeng polos? Ke arah mana dia? | A blank mask? Which way did he go? |
| 1 | @NPC_PURWA_STALL_NAME | | |
| 1 | DLG_PURWA_STALL_V3 | Ke barat. Nanti malam kau ikut ruwatan, kan? Duduklah dekat Semar. | West. You're going to the ruwatan tonight? Sit near Semar. |
| 2 | DLG_PURWA_STALL_V4 | Cabai segar, kemiri baru. Dan jangan tanya soal lelaki bertopeng. | Fresh chilli, new candlenut. And don't ask about the masked man. |

### Chapter 2: The Ruwatan Night (0.4-0.5)

### Memory `k0_ruwatan` (play; K0, step 0.4; the first Kelir memory, a tutorial). You move a wayang figure on the kelir; Kala's shadow eats the unlit side
| Key | ID | EN |
|-----|----|----|
| MEM_K0_RUWATAN_TITLE | Wayang Ruwatan | The Ruwatan Show |
| MEM_K0_RUWATAN_IN | Ini kelir, layar bayangan. Tetaplah di terang lampuku, Nak. Di luar terang, Kala, pemakan bayangan, menunggu. | This is the kelir, the shadow screen. Stay in my lamp's light, child. Outside it, Kala, the shadow-eater, waits. |
| MEM_K0_RUWATAN_HINT | Tetap di cahaya | Stay in the light |
| MEM_K0_RUWATAN_1 | Batara Kala, dewa waktu. Ia memakan apa saja yang tak dijaga dan tak diingat. | Batara Kala, the god of time. He eats whatever is left unguarded and unremembered. |
| MEM_K0_RUWATAN_2 | Maka leluhur menulis empat kisah berbahaya sampai tamat, supaya tetap selesai: Empat Segel. | So the ancestors wrote four dangerous stories to their end, to keep them finished: the Four Seals. |
| MEM_K0_RUWATAN_3 | Yang pertama Sangkuriang, yang ingin mengalahkan fajar dan tertipu fajar palsu. | The first is Sangkuriang, who tried to beat the dawn and was fooled by a false one. |
| MEM_K0_RUWATAN_OUT | Sekarang nama anak-anak desa kubacakan, agar Kala melewati pintu mereka. Ciung. Laras. Dan kau, {name}. | Now the village children's names, so Kala passes their doors. Ciung. Laras. And you, {name}. |
| MEM_K0_RUWATAN_OUT_2 | Dengan nama terjaga, tidurlah tenang malam ini. | With the names kept, sleep easy tonight. |

### Beat `raid` (if `!flag:beat_raid`, `flag:mq0_d8`; do `flag:beat_raid`). The Hunter's first appearance (Pacing 7). The hero does not speak
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_RAID_1 | Bayangan-bayangan turun dari kelir. Topeng kosong, tangan yang menggapai. Orang menjerit; lampu bergoyang. | The shadows step off the screen. Blank masks, reaching hands. People scream; the lamp swings. |
| @NPC_HUNTER_NAME | | |
| BEAT_RAID_2 | Mana bocah dengan telur itu? | Where is the boy with the egg? |
| @ | | |
| BEAT_RAID_3 | Ciung sudah menghilang ke dalam gelap. Laras menatap yang paling jangkung dan membisikkan sebuah nama: "Aria." | Ciung has already vanished into the dark. Laras looks at the tallest and whispers a name: "Aria." |
| @NPC_HUNTER_NAME | | |
| BEAT_RAID_4 | Anak yang salah. Tapi yang lebih baik. | Wrong child. A better one. |
| @NPC_LARAS_NAME | | |
| BEAT_RAID_5 | Kak! | Kak! |
| @ | | |
| BEAT_RAID_6 | Lontar itu robek di antara tanganmu dan tangan mereka. Mereka menyeretnya ke dalam gelap. Lampu padam. | The lontar tears between your hands and theirs. They drag her into the dark. The lamp goes out. |

### Beat `raid_morning` (if `!flag:beat_raid_morning`, `flag:beat_raid`; do `flag:beat_raid_morning`). A one-line fade card, the old `PROLOGUE_5`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_RAID_MORNING | Pagi. Separuh lontarmu hilang, jatuh entah di mana di panggung yang hangus. Nama Laras di sana mulai memudar. | Morning. Your half of the lontar is gone, dropped somewhere on the burned stage. Her name on it is fading. |

### Chapter 3: The Morning After (0.6-0.9)
The lontar on the stage is `item_picked:laras_lontar`: it needs no lines.

### ibu, the morning after (entries 4, 6 and 7 of the table above)
| Entry | Key | ID | EN |
|-------|-----|----|----|
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_IBU_H1 | Bu, Laras di mana? Semalam dia tidak pulang. | Ibu, where's Laras? She never came home last night. |
| 4 | @NPC_IBU_NAME | | |
| 4 | DLG_IBU_V2 | Laras? Siapa Laras, Nak? Dari dulu cuma kita berdua. | Laras? Who's Laras, child? It's always been the two of us. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_IBU_H2 | Lalu kenapa ada dua cangkir di meja? | Then why are there two cups on the table? |
| 4 | @NPC_IBU_NAME | | |
| 4 | DLG_IBU_V4 | Dua... Satunya gompal, entah kenapa Ibu simpan. Sudahlah. Semar semalaman di sanggar, tanyalah dia. | Two... One is chipped, and I couldn't say why I kept it. Never mind. Semar was up all night at the sanggar. Ask him. |
| 6 | DLG_IBU_V7 | Hati-hati. Sejak semalam seisi desa gelisah. | Be careful. The whole village is jumpy since last night. |
| 7 | DLG_IBU_V8 | Pulanglah kalau sempat. Nasimu Ibu hangatkan. | Come home when you can. I'll keep your rice warm. |

### semar, the morning after (entries 4 to 8 of the table above)
| Entry | Key | ID | EN |
|-------|-----|----|----|
| 4 | DLG_SEMAR_V1 | Hehe, mukamu kusut seperti kucing basah. Sebelum aku bicara, ambil dulu lontar yang tertinggal di panggung wayang. Yang gosong itu. | Hehe, you look like a wet cat. Before I say anything, fetch the lontar off the wayang stage. The scorched one. |
| 5 | @NPC_HERO_NAME | | |
| 5 | DLG_SEMAR_H2 | Hurufnya memudar dari ujung. Siapa yang melakukan ini? | The letters are fading from the edges. Who did this? |
| 5 | @NPC_SEMAR_NAME | | |
| 5 | DLG_SEMAR_V4 | Para tanpa rupa: orang-orang terlupa yang mengangkut nama bagi yang memegangnya. Ibumu sudah lupa Laras. Aku belum. | The faceless: forgotten folk who carry names to whoever holds them. Your mother has forgotten Laras. I haven't. |
| 5 | DLG_SEMAR_V5 | Laras masih memegang separuh yang bernamamu, dan ia menulis di situ. Lihat? Ka, untuk "kakak". Gambar tiga kali. | Laras still holds the half with your name, and she's writing on it. See? Ka, for "kakak". Draw it three times. |
| 6 | DLG_SEMAR_V7 | Lagi. Tiga kali, sampai tanganmu tak perlu menunggu kepalamu. | Again. Three times, until your hand stops waiting for your head. |
| 7 | DLG_SEMAR_V8 | Dengar itu? Mereka kembali mencari sesuatu. Alun-alun, cepat! | Hear that? They came back for something. The plaza, go! |
| 8 | DLG_SEMAR_V9 | Mereka lari ke barat, ke gerbang. Pergilah, dan simpan lontarnya dekat jantung. | They ran west, to the gate. Go, and keep the lontar close to your heart. |

### Beat `hunter_raid` (if `!flag:beat_hunter_raid`, `flag:mq0_7`; do `flag:beat_hunter_raid`, `clue:mask_gate`, `codex:faceless`, `start:mq1`). The west gate (0.9)
| Key | ID | EN |
|-----|----|----|
| BEAT_HUNTER_RAID_1 | Di gerbang barat, sosok jangkung berdiri membelakangi fajar. Topeng kosong, seperti yang lain. Sikapnya tidak. | At the west gate a tall figure stands against the dawn. A blank mask, like the others. The bearing is not. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_RAID_H1 | Kembalikan dia! | Give her back! |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_RAID_2 | Pulanglah. Kau bukan bagian lakon ini. | Go home. You're not part of this lakon. |
| @ | | |
| BEAT_HUNTER_RAID_3 | Ia tidak menoleh. Pasukannya mengalir lewat gerbang seperti asap, ke barat, lalu gerbang itu kosong lagi. | He doesn't turn. His men pour through the gate like smoke, west, and then the gate is empty again. |
| @NPC_NINI_NAME | | |
| BEAT_HUNTER_RAID_4 | Mereka mencari Ciung kami, bocah dengan telur itu. Ia lari ke barat semalam. Susul dia dulu, Nak, sebelum mereka. | It was our Ciung they came for, the boy with the egg. He ran west in the night. Reach him first, child, before they do. |
| @ | | |
| BEAT_HUNTER_RAID_5 | Di rumput dekat gerbang tergeletak serpihan topeng putih. Lontarmu bergetar saat kau memungutnya. | A white mask fragment lies in the grass by the gate. Your lontar hums as you pick it up. |

### Clue `mask_gate` (given by the `hunter_raid` beat; no examine lines)
| Key | ID | EN |
|-----|----|----|
| HUNT_MASK_TITLE | Pecahan Topeng | The Mask Fragments |
| CLUE_MASK_GATE_NOTE | Serpihan topeng putih di gerbang barat. Milik si Pemburu. | A white mask fragment at the west gate. The Hunter's. |



## 6. Act I: Tatar Sunda (MQ1, "Segel Kawah")
**Lines in this section: 111** (ASSUMED budget: at most 130).
Regional character: Dewi Naganingrum (want: a son she held for one night; turn: the lake; close: the rim). Order of play: arrival slice, the elder, the Sandekala Hunt, the Batu Tulis and the Weaver, the Sangkuriang clues, the lake, the crater (Laras chapter 1, the Captain, the first Hunter memory), the Sangkuriang memory and fight, the naga.

### Chapter 1: Tea and the Trail (1.1-1.3)

### sunda_grandson (tea terraces; name NPC_SUNDA_GRANDSON_NAME; new). The arrival slice (1.1)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq1=active`, `!flag:mq1_a1` | `codex:angklung` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_SUNDA_GRANDSON_NAME | | |
| 1 | DLG_SUNDA_GRANDSON_V1 | Dengar para pemetik teh? Mereka bernyanyi supaya daun tak merasa sepi. | Hear the pickers? They sing so the leaves don't feel lonely. |
| 1 | DLG_SUNDA_GRANDSON_V2 | Aku belajar angklung. Satu ruas bambu, satu nada. Sendirian hambar, ramai-ramai merdu. | I'm learning the angklung. One bamboo, one note. Alone it's dull, together it sings. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_GRANDSON_H1 | Kau lihat gadis kecil membawa lontar? | Did you see a little girl with a lontar? |
| 1 | @NPC_SUNDA_GRANDSON_NAME | | |
| 1 | DLG_SUNDA_GRANDSON_V3 | Tidak. Tapi pagi tadi ribut di rumpun bambu. Kakekku, sesepuh kampung, mungkin tahu. | No. But there was a racket in the bamboo this morning. My grandfather, the kampung elder, may know. |
| 2 | DLG_SUNDA_GRANDSON_V4 | Nanti kuajari satu nada, kalau kau kembali utuh. | I'll teach you a note, if you come back in one piece. |

| Key | ID | EN |
|-----|----|----|
| DLG_RIBBON_H1 | Pita Laras, tersangkut di bambu. Dia lolos dari sini, dan melawan. | Laras's ribbon, caught on the bamboo. She broke free here, and fought. |

### cepot (SQ-S4, petilasan `sunda_1`, 1.2). He knows the hero from the prologue day now: replace `DLG_CEPOT_11`, keep the other Cepot keys and entries
His Ga hint (`DLG_CEPOT_15`) plays only after Ga is learned, as the data already gates it (`step:sq_s4=0`, `glyph:sunda_ga`, `!flag:cepot_ga_hint`).
| Key | ID | EN |
|-----|----|----|
| DLG_CEPOT_11 | Hei, {name}! Kau yang dari sanggar! Masih ingat aku, Cepot? | Hey, {name}! You from the sanggar! Remember me, Cepot? |

### sunda_elder (the kampung elder; replace the main-path entries, keep the SQ-S1/S2 entries after them, then the idle entry last)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=2`, `!glyph:sunda_ga` (1.3) | `flag:mq1_2`, `learn:sunda_ga` |
| 2 | `step:mq1=2`, `glyph:sunda_ga` | |
| (keep) | SQ-S1 / SQ-S2 entries, in their current order | |
| 3 | `quest:mq1=active` | |
| (keep) | the current fallback | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_ELDER_H1 | Adikku, Laras. Kecil, membawa lontar. Abah lihat? | My sister, Laras. Small, carrying a lontar. Did you see her? |
| 1 | @NPC_SUNDA_ELDER_NAME | | |
| 1 | DLG_SUNDA_ELDER_V2 | Lihat. Kemarin subuh, lari dari rumpun bambu bersama bocah liar yang menggendong telur. Bocah itu menariknya seperti menarik layangan. | I did. Yesterday at dawn, running from the bamboo with a wild boy hugging an egg. He towed her like a kite. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_ELDER_H2 | Ke mana mereka? | Where did they go? |
| 1 | @NPC_SUNDA_ELDER_NAME | | |
| 1 | DLG_SUNDA_ELDER_V3 | Hilir, ke ngarai sungai. Orang tua bilang di sana Sandekala, roh senja, menjemput anak yang masih di luar saat maghrib. Bawa Ga: angkat, dan cahaya jadi dinding. | Downstream, to the river gorge. The old folk say Sandekala, the dusk spirit, collects any child still outside at maghrib. Take Ga: raise it, and the light becomes a wall. |
| 2 | DLG_SUNDA_ELDER_V4 | Ikuti sungai ke hilir, ke dusun di tepi ngarai. Kau akan tahu saat langit mulai jingga. | Follow the river down to the hamlet by the gorge. You'll know it when the sky turns orange. |
| 3 | DLG_SUNDA_ELDER_V6 | Batu tulis, batu berukir itu, ada di atas jalan setapak. Teras sawah di baliknya. | The batu tulis, the carved stone, is up the path. The terraces are past it. |

VERIFY: Sandekala as a dusk spirit that takes children who stay out at maghrib.

### Hunt K1: Sandekala (Chapter 2, 1.3-1.6)
| Key | ID | EN |
|-----|----|----|
| HUNT_K1_TITLE | Sandekala | Sandekala |

### Beat `hamlet_hook` (if `!flag:beat_hamlet_hook`, `glyph:sunda_ga`, `flag:mq1_h1`; do `flag:beat_hamlet_hook`, `codex:sandekala`). K1 hook. Area `sunda_hamlet` sets `mq1_h1`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_HAMLET_HOOK_1 | Senja di dusun tepi ngarai. Tak ada lampu di jalan setapak. Seorang ibu berdiri di tepi hutan. | Dusk at the hamlet by the gorge. No lamps on the path. A mother stands at the edge of the trees. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_HAMLET_HOOK_2 | Asep! Asep, pulang, Nak! | Asep! Asep, come home, child! |
| @ | | |
| BEAT_HAMLET_HOOK_3 | Tak ada yang menjawab. Pepohonan hanya bergoyang. | Nobody answers. The trees only sway. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_HAMLET_HOOK_4 | Mereka bilang ini ulah Sandekala, roh senja yang mengambil anak di luar saat maghrib. | They say it's Sandekala, the dusk spirit who takes children out at maghrib. |
| BEAT_HAMLET_HOOK_5 | Dulu kami menyalakan oncor, obor bambu, di jalan setiap sore. Entah kenapa kami berhenti. | We used to light oncor, bamboo torches, along the path every evening. I don't know why we stopped. |
| @NPC_HERO_NAME | | |
| BEAT_HAMLET_HOOK_H1 | Aku akan mencari anak-anak itu. | I'll find the children. |

### Clues K1 (step 1.4; objects in the dusun and the gorge; `gorge_prints` starts `k1_maghrib`)
| Key | ID | EN |
|-----|----|----|
| CLUE_SANDAL_1 | Sandal anak kecil, sebelah saja, di tepi sungai. Masih basah. | A child's sandal, just the one, at the river's edge. Still wet. |
| CLUE_SANDAL_2 | Talinya putus, seperti ditarik dari belakang. | The strap is snapped, as if pulled from behind. |
| CLUE_SANDAL_NOTE | Sandal anak di tepi sungai, talinya putus. | A child's sandal at the river, strap snapped. |
| CLUE_ONCOR_1 | Deretan oncor di sepanjang jalan, semuanya dingin. Tak ada yang menyalakannya hari ini. | A row of oncor along the path, all cold. Nobody lit them today. |
| CLUE_ONCOR_2 | Sumbunya kering. Dusun ini lupa kebiasaannya sendiri. | The wicks are dry. The hamlet forgot its own custom. |
| CLUE_ONCOR_NOTE | Oncor di jalan dusun tak dinyalakan; kebiasaan maghrib terlupa. | The hamlet's oncor stand unlit; the maghrib custom is forgotten. |
| CLUE_GORGE_PRINTS_1 | Jejak sepatu kain turun ke ngarai, dan jejak kaki telanjang bocah di sampingnya. Laras dan si bocah liar. | Cloth-shoe prints go down into the gorge, with a barefoot boy's beside them. Laras and the wild boy. |
| CLUE_GORGE_PRINTS_2 | Di belakang mereka, jejak anak-anak kecil yang banyak, menuju ke bawah. Lontarku bergetar. | Behind them, many small children's prints, going down. My lontar hums. |
| CLUE_GORGE_PRINTS_NOTE | Jejak Laras, si bocah liar dan anak-anak dusun menuju ngarai. | Prints of Laras, the wild boy and the hamlet's children lead into the gorge. |

### Memory `k1_maghrib` (play; K1, step 1.5; kelir figure: a village child at maghrib; the action lights an oncor)
| Key | ID | EN |
|-----|----|----|
| MEM_K1_MAGHRIB_TITLE | Anak saat Maghrib | A Child at Maghrib |
| MEM_K1_MAGHRIB_IN | Dengarkan kisah ini, Nak: seorang anak yang berlari pulang saat maghrib. Larilah dari oncor ke oncor. | Hear this tale, child: a village child running home at maghrib. Run from torch to torch. |
| MEM_K1_MAGHRIB_HINT | Nyalakan oncor | Light the oncor |
| MEM_K1_MAGHRIB_1 | Pulang, Nak! Matahari hampir tenggelam! | Home, child! The sun is nearly down! |
| MEM_K1_MAGHRIB_2 | Sesuatu yang tinggi mengikuti di belakangmu. Ia tak bisa melewati tanah yang terang. | Something tall follows behind you. It cannot cross lit ground. |
| MEM_K1_MAGHRIB_3 | Oncor terakhir menyala. Bayangan itu mundur. | The last oncor catches. The shadow draws back. |
| MEM_K1_MAGHRIB_OUT | Begitulah ceritanya: terang menjaga anak-anak. Nyalakan empat oncor, dan Sandekala tak bisa lewat. | So the tale goes: light keeps the children. Light the four oncor, and Sandekala cannot pass. |

| Key | ID | EN |
|-----|----|----|
| HINT_SANDEKALA | Nyalakan oncor | Light the oncor |

### Beat `sandekala_after` (if `!flag:beat_sandekala_after`, `flag:mq1_3b`; do `flag:beat_sandekala_after`). K1 aftermath
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SANDEKALA_AFTER_1 | Sosok tinggi itu lenyap bersama bayangannya. Di pasir ngarai, anak-anak ditemukan tertidur, utuh. | The tall shape is gone with its shadow. On the gorge sand the children are found asleep, whole. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_SANDEKALA_AFTER_2 | Asep! Dia hangat. Dia hangat! | Asep! He's warm. He's warm! |
| @ | | |
| BEAT_SANDEKALA_AFTER_3 | Ibu itu menyalakan oncor pertama sambil menangis dan tertawa. Satu per satu jalan setapak menyala. | The mother lights the first oncor, crying and laughing. One by one the path lights up. |
| BEAT_SANDEKALA_AFTER_4 | Di lumpur, jejak Laras dan jejak si bocah liar bercabang. Jejak Laras naik ke Batu Tulis, batu berukir di bukit. | In the mud, Laras's prints and the wild boy's part ways. Hers climb to the Batu Tulis, the carved stone on the hill. |

### Chapter 3: The Batu Tulis and the Weaver (1.7-1.9)
### batu_tulis (replace the `step:mq1=3` entry; keep the fallback)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=6` (1.7) | `learn:sunda_nga` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_BATU_TULIS_V1 | Wajah seorang raja terpahat di batu ini, digores habis dalam-dalam. Debunya masih putih. | A king's face is carved into this stone, scraped out deep. The dust is still white. |
| 1 | @NPC_BATU_TULIS_NAME | | |
| 1 | DLG_BATU_TULIS_V2 | Di bawahnya, goresan kasar tangan kecil: "Mereka butuh aku membaca." | Under it, rough scratches from a small hand: "They need me to read." |
| 1 | DLG_BATU_TULIS_V3 | Di atasnya aksara lama masih bertahan: Ga, lalu Nga, Ga dengan kotak terbuka. Tanganmu membacanya sebelum kau mengerti. Nga mengikat. | Above it the old letters hold: Ga, then Nga, Ga with its box open. Your hand reads it before you understand. Nga binds. |
| 1 | DLG_BATU_TULIS_V4 | Jejak sepatu kain turun ke teras sawah. | Cloth-shoe prints lead down to the rice terraces. |

(`NPC_BATU_TULIS_NAME` is the existing name key of `batu_tulis.tres`.)

### sunda_weaver (step 1.8; replace the `step:mq1=7` entry, keep the idle entries; drop the SQ-S5 entry, SQ-S5 is retired)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=7` | `give:boeh_rarang` |
| (keep) | the idle entries | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_SUNDA_WEAVER_1 | Kau yang membebaskan terasku? Duduk. Aku sudah tahu kau mencari siapa. | You cleared my terraces? Sit. I already know who you're looking for. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_WEAVER_H1 | Gadis kecil dengan lontar. Dia lewat sini? | A little girl with a lontar. Did she come through here? |
| 1 | @NPC_SUNDA_WEAVER_NAME | | |
| 1 | DLG_SUNDA_WEAVER_V1 | Semalam. Kusembunyikan di bawah bakul benang. Subuh mereka mengetuk, dan dia keluar sendiri supaya aku tak disakiti. | One night. I hid her under the thread baskets. At dawn they knocked, and she walked out herself so I wouldn't be hurt. |
| 1 | DLG_SUNDA_WEAVER_V2 | Bahwa lelaki tanpa wajah butuh dia membaca sesuatu di kawah. Maka ambil ini, boeh rarang. Kain ini pernah menipu Sangkuriang. Gantung di tiang timur, lalu rapalkan Ca, aksara yang akan kaupelajari di danau. | That the faceless man needs her to read something at the crater. So take this, boeh rarang. It fooled Sangkuriang once. Hang it on the east post, then cast Ca, the letter you'll learn at the lake. |

### Beat `lake_hook` (if `!flag:beat_lake_hook`, `flag:lake_road`, `step:mq1=8`; do `flag:beat_lake_hook`). K2 hook. Area `sunda_lakeroad` sets `lake_road` (ASSUMED)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_LAKE_HOOK_1 | Hulu sungai tersumbat bendungan baru, seolah dibuat semalam. Di tengah danau berdiri rusuk-rusuk perahu yang belum jadi. | The river's head is choked by a new dam, as if built overnight. In the lake stand the ribs of a half-built boat. |
| @NPC_HERO_NAME | | |
| BEAT_LAKE_HOOK_H1 | Siapa membangun perahu di tengah danau? | Who builds a boat in the middle of a lake? |

### Hunt K2: Sangkuriang (1.9, 1.14, 1.15)
| Key | ID | EN |
|-----|----|----|
| HUNT_K2_TITLE | Sangkuriang | Sangkuriang |

### Clues K2 (step 1.9; `loom` is in the Weaver's house; `boat_ribs` is on the crater rim and starts `k2_dayang_sumbi`)
| Key | ID | EN |
|-----|----|----|
| CLUE_FELLED_TREES_1 | Satu lereng penuh pohon baru ditebang, batangnya rapi seperti bahan perahu. | A whole hillside of freshly felled trees, trunks trimmed neat as boat timber. |
| CLUE_FELLED_TREES_2 | Kerja satu malam. Dan bukan kerja manusia. | A night's work. And not human work. |
| CLUE_FELLED_TREES_NOTE | Lereng pohon baru ditebang, siap jadi perahu. | A hillside of fresh-felled trees, ready to be a boat. |
| CLUE_EMPTY_COOPS_1 | Semua kandang ayam jantan di dusun ini kosong. Tak ada satu jago pun. | Every rooster coop in the hamlet is empty. Not one cock left. |
| CLUE_EMPTY_COOPS_2 | Seseorang tak mau ada yang berkokok sebelum fajar yang ia kehendaki. | Someone didn't want a crow before the dawn they chose. |
| CLUE_EMPTY_COOPS_NOTE | Semua kandang ayam jantan di dusun kosong. | Every rooster coop in the hamlet is empty. |
| CLUE_LOOM_1 | Alat tenun sang Penenun, kain putih setengah jadi di atasnya. Persis seperti boeh rarang. | The Weaver's loom, a half-done white cloth on it. Just like the boeh rarang. |
| CLUE_LOOM_2 | Kain ini dirancang untuk berpura-pura jadi cahaya. | This cloth was made to pretend to be light. |
| CLUE_LOOM_NOTE | Boeh rarang ditenun untuk menipu fajar. | The boeh rarang was woven to fool the dawn. |

### Chapter 4: The Lake and the Crater (1.10-1.15)

### Clue `faceless_toy` (step 1.10; the Captain clue: the masks were people)
| Key | ID | EN |
|-----|----|----|
| CLUE_FACELESS_TOY_1 | Kuda kayu kecil yang dijatuhkan seorang tanpa rupa. Ada nama digores di perutnya: Dasim. | A small wooden horse a faceless one dropped. A name is scratched on its belly: Dasim. |
| CLUE_FACELESS_TOY_2 | Mereka dulu orang. Seseorang pernah mengukir mainan untuk seorang anak. | They were people once. Somebody carved a child a toy. |
| CLUE_FACELESS_TOY_NOTE | Mainan berukir nama "Dasim". Para tanpa rupa dulunya manusia. | A toy marked "Dasim". The faceless were people. |

### naganingrum (ts_situ, cond `flag:mq1_6b`, stays after MQ1; name NPC_NAGANINGRUM_NAME). The turn.
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq1_6b`, `step:mq1=10` (1.11) | `learn:sunda_ca` |
| 2 | `flag:mq1_7` | |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_NAGANINGRUM_H1 | Adikku, dan seorang bocah liar dengan telur. Alisnya bertaut, matanya baik. Dia lewat sini? | My sister, and a wild boy with an egg. Scowling brows, kind eyes. Did he pass this way? |
| 1 | @NPC_NAGANINGRUM_NAME | | |
| 1 | DLG_NAGANINGRUM_V2 | Aku kenal wajah itu. Semalam saja kutimang, lima belas tahun lalu, sebelum sungai membawanya pergi. | I know that face. I held it for one night, fifteen years ago, before the river took him. |
| 1 | DLG_NAGANINGRUM_V3 | Dan yang memburunya bukan pencuri, Nak, melainkan pewaris. Ambil Ca. Ia meledak seperti fajar; kapten yang sedang memanggil pasukannya tak akan selesai berseru. | And what hunts him isn't after a thief, child, it's after an heir. Take Ca. It bursts like dawn, and a captain calling his men won't finish the call. |
| 1 | DLG_NAGANINGRUM_V4 | Dia naik ke kawah. Aku menyusul secepat kakiku mau. Kau lebih cepat. | He went up to the crater. I'll follow as fast as my legs allow. You're faster. |
| 2 | DLG_NAGANINGRUM_V5 | Ke kawah. Pergilah, kumohon. | The crater. Go, please. |
| 3 | DLG_NAGANINGRUM_V6 | Airnya tenang hari ini. Pergilah, aku tak ke mana-mana. | The water's quiet today. Go on, I'm not going anywhere. |

### Laras chapter LC1 `lc1` (step 1.12; kind chapter; Laras is put before the seal-stone at the crater)
Her one action: say a true name. Generic lines for every chapter first (`LC_HINT` shows on the first chapter only).
| Key | ID | EN |
|-----|----|----|
| LC_HINT | Ucapkan nama sejati | Say the true name |
| LC_FREEZE_1 | Namamu di ujung lidahmu, kan? Biar kubantu. | Your name's on the tip of your tongue, isn't it? Let me help. |
| LC_FREEZE_2 | Pssst. Kau pernah punya nama. Ingat? | Psst. You had a name once. Remember? |
| LC_FREEZE_3 | Jangan pura-pura lupa. Aku dengar kok. | Don't pretend. I can hear it. |
| LC_1_TITLE | Membaca Pelan-pelan | Reading Slowly |
| @NPC_LARAS_NAME | | |
| LC1_1 | Satu huruf. Diam. Satu huruf lagi. Aku tak mau ini cepat selesai. | One letter. A pause. One more. I don't want this finished soon. |
| LC1_2 | Penjaganya mondar-mandir seperti kambing pamanku. Tunggu dia berbalik... | The guard paces like my uncle's goat. Wait until he turns... |
| LC1_3 | Satu kerikil di alur baca. Sekarang bacanya macet. Hehe. | One pebble in the reading groove. Now the reading sticks. Hehe. |
| LC1_4 | Kak? Di sini gelap. Aku membaca pelan-pelan. Kalau kau dengar ini, jangan lama-lama. | Kak? It's dark here. I'm reading slowly. If you can hear this, don't take long. |

### Beat `crater_seal` (if `!flag:beat_crater_seal`, `flag:mq1_8`; do `flag:beat_crater_seal`, `restore`)
| Key | ID | EN |
|-----|----|----|
| BEAT_CRATER_SEAL_1 | Sang kapten berlutut. Dengan sisa tenaganya ia menghantam batu segel yang sudah retak dengan gagang tombak. | The Captain drops to a knee. With the last of his strength he drives his spear butt into the cracked seal-stone. |
| BEAT_CRATER_SEAL_2 | Batu itu pecah. Di dasar kawah, sesuatu sebesar bukit menarik napas. | The stone splits. Down in the crater, something the size of a hill takes a breath. |
| BEAT_CRATER_SEAL_3 | Di bibir seberang, sosok jangkung bertopeng menonton sebentar, lalu pergi. Di bawahnya, Ciung Wanara tergantung dalam rantai, seperti umpan. | On the far rim a tall masked figure watches a moment, then leaves. Below him Ciung Wanara hangs in chains like bait. |
| @NPC_HERO_NAME | | |
| BEAT_CRATER_SEAL_H1 | Ciung! Bertahanlah! | Ciung! Hold on! |

### Clue `hunter_mask_1` and memory `h1` (step 1.13; H1, kind walk; young Aria sweeps a palace floor)
| Key | ID | EN |
|-----|----|----|
| HUNT_H_TITLE | Pecahan Topeng | The Mask Fragments |
| CLUE_HUNTER_MASK_1_1 | Pecahan topeng kedua tergeletak di bibir kawah. Lontarku berdengung lebih keras dari sebelumnya. | A second mask fragment lies on the rim. My lontar hums louder than before. |
| CLUE_HUNTER_MASK_1_2 | Terasa hangat, seperti baru dilepas seseorang. | It feels warm, like someone just let go of it. |
| CLUE_HUNTER_MASK_1_NOTE | Pecahan topeng kedua, di bibir kawah. | The second mask fragment, on the crater rim. |
| MEM_H1_TITLE | Raja yang Baik | The Kind King |
| MEM_H1_IN | Bukan kisahku, Nak. Seseorang menyapu lantai istana. Lihat saja. | Not my tale, child. Someone sweeping a palace floor. Just watch. |
| MEM_H1_1 | Seorang pelayan muda menyapu balairung. Namanya Aria. | A young servant sweeps the great hall. His name is Aria. |
| MEM_H1_2 | Sang raja tua: "Aria, kau melewatkan sudut itu. Tak apa, jadi aku punya alasan menyapamu." | The old king: "Aria, you missed that corner. No matter, it gives me a reason to greet you." |
| MEM_H1_3 | Aria menunduk, malu dan senang. Tak ada yang pernah menyebut namanya sebaik itu. | Aria ducks his head, shy and glad. Nobody ever said his name so kindly. |
| MEM_H1_OUT | Ingat nama itu, Nak. Ada yang pernah menyebutnya dengan baik. | Remember that name, child. Someone once said it kindly. |
| MEM_H1_H1 | Aria. Nama yang dibisikkan Laras malam itu. | Aria. The name Laras whispered that night. |

### Clue `boat_ribs` and memory `k2_dayang_sumbi` (step 1.14; K2, kind play; kelir figure: the woman from Semar's show; the action spreads cloth and pounds the lesung)
| Key | ID | EN |
|-----|----|----|
| CLUE_BOAT_RIBS_1 | Rusuk-rusuk perahu raksasa menjulang dari lumpur danau. Lontarku menarikku ke arahnya. | The ribs of a giant boat rise from the lake mud. My lontar pulls me toward them. |
| CLUE_BOAT_RIBS_2 | Perahu ini tak akan pernah selesai. Ceritanya yang menolak. | This boat will never be finished. The tale won't allow it. |
| CLUE_BOAT_RIBS_NOTE | Rusuk perahu yang tak pernah selesai di danau. | The ribs of a boat that never gets finished, in the lake. |
| MEM_K2_DAYANG_SUMBI_TITLE | Malam Dayang Sumbi | Dayang Sumbi's Night |
| MEM_K2_DAYANG_SUMBI_IN | Kau Dayang Sumbi, perempuan dalam pertunjukanku, Nak. Seorang raksasa harus menyelesaikan danau dan perahu sebelum fajar. Jangan biarkan. | You are Dayang Sumbi, the woman from my show, child. A giant must finish a lake and a boat before dawn. Don't let him. |
| MEM_K2_DAYANG_SUMBI_HINT | Bentang kain, tumbuk lesung | Spread cloth, pound the mortar |
| MEM_K2_DAYANG_SUMBI_1 | Ia membentangkan kain putih di tiang timur. Dari jauh, tampak seperti cahaya subuh. | She spreads the white cloth on the east post. From far off it looks like first light. |
| MEM_K2_DAYANG_SUMBI_2 | Ia menumbuk lesung, lumpang padi, keras-keras. Ayam-ayam terbangun dan mengira hari sudah pagi. | She pounds the lesung, the rice mortar, hard. The roosters wake and think morning has come. |
| MEM_K2_DAYANG_SUMBI_3 | Sang raksasa berhenti. Perahu tak pernah selesai sebelum fajar. Ia duduk, bingung, lalu tertidur. | The giant stops. No boat is finished before dawn. He sits down, bewildered, and sleeps. |
| MEM_K2_DAYANG_SUMBI_OUT | Gantung kain di tiang timur, rapalkan Ca, dan fajar palsu menang. Begitu kisah ini berakhir. | Hang the cloth on the east post, cast Ca, and the false dawn wins. That is how this tale ends. |
| HINT_SANGKURIANG | Gantung kain, rapal Ca | Hang cloth, cast Ca |

### Beat `naga` (if `!flag:beat_naga`, `quest:mq1=done`; do `flag:beat_naga`, `flag:mq1_10`, `codex:nagawiru`, `codex:sangkuriang`, `lakon:sangkuriang`, `start:mqg`)
| Key | ID | EN |
|-----|----|----|
| BEAT_NAGA_1 | Fajar palsu padam. Sangkuriang duduk di antara perahunya yang tak pernah jadi dan tertidur. Rantai mengendur, dan seekor naga besar bangkit dari lumpur, sisiknya kusam seperti perunggu tua. | The false dawn fades. Sangkuriang sits down among his never-finished boats and sleeps. The chains slacken, and a great naga rises from the mud, scales dull as old bronze. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_2 | Kau mengikutiku sampai sini? Berani atau bodoh, aku belum tahu. | You followed me all the way here? Brave or stupid, I haven't decided. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_NAGA_3 | Orang di singgasana Galuh, kerajaan di timur, memakai wajahku, Nak. Mereka membawa gadis kecil itu ke sana. | The man on the throne of Galuh, the kingdom east of here, wears my face, child. They took the little girl there. |
| @ | | |
| BEAT_NAGA_4 | Telur di dekapan Ciung retak. Seekor anak ayam jantan menggelinding keluar, sudah galak. | The egg in Ciung's arms cracks. A rooster chick tumbles out, already angry. |
| @NPC_NAGANINGRUM_NAME | | |
| BEAT_NAGA_5 | Nak...? | Child...? |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_6 | Hati-hati, Bu, licin di sini. Nah, kau. Galuh. Ikut? Gerbang timur desamu jalan pintasnya. | Careful, ma'am, it's slippery here. Now you. Galuh. Coming? Your village's east gate is the short way. |



### Camp talk `camp_sunda` (ciung_wanara entry; cond `flag:mq1_9`, `zone:ts_situ`, `"quiet": true`; do `flag:camp_sunda`; at the lake after Sangkuriang)
| Key | ID | EN |
|-----|----|----|
| DLG_CIUNG_WANARA_V35 | Marahku belum reda. Ada yang kuambil kembali, tapi bukan semuanya. | My anger hasn't faded. I took something back, but not everything. |
| DLG_CIUNG_WANARA_V36 | Perempuan di tepi danau itu menatapku tadi. Aku tak tahu kenapa aku merasa harus menunduk. | The woman by the lake looked at me just now. I don't know why I felt I should bow my head. |
| @NPC_HERO_NAME | | |
| DLG_CIUNG_WANARA_H4 | Kau akan tahu pada waktunya. | You'll know in time. |
| @NPC_CIUNG_WANARA_NAME | | |
| DLG_CIUNG_WANARA_V37 | Kau tahu sesuatu, kan? Baiklah. Aku bisa menunggu. | You know something, don't you? Fine. I can wait. |

## 7. Act II: Keraton Galuh (MQG, "Wajah Pinjaman")
**Lines in this section: 80** (ASSUMED budget: at most 90).
Regional characters: Uwa Lengser (want: to say a secret aloud; turn: the queen's eyes; close: relief) and the Deserter (want: his wife's face; turn: the choice; close: epilogue and the cave mouth). Order of play: the tournament crowd, the bouts, Lengser, the wagon, the cells, Laras chapter 2, the Deserter and the portrait, Lengser's memory, the second mask fragment, the unmasking.

### Chapter 1: Tournament Day (g.1-g.3)

### galuh_seller (kg_alun, the arrival slice; name NPC_GALUH_SELLER_NAME; new)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mqg=active`, `!flag:mqg_a1` | |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_GALUH_SELLER_NAME | | |
| 1 | DLG_GALUH_SELLER_V1 | Jago merah, jago hitam, jago putih! Hari sayembara raja: semua orang jadi kaya atau miskin dalam sehari. Aku cuma jual, tak pernah bertaruh. | Red cocks, black cocks, white cocks! Tournament day: everyone gets rich or poor by nightfall. I only sell, I never bet. |
| 1 | DLG_GALUH_SELLER_V2 | Lihat kerumunan itu. Raja mengundang semua orang, karena raja suka dipandang. | Look at that crowd. The king invites everyone, because the king likes being looked at. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_GALUH_SELLER_H1 | Aku mencari temanku, Ciung. Anak ayam jantan di bahunya. | I'm looking for my friend Ciung. A young rooster on his shoulder. |
| 1 | @NPC_GALUH_SELLER_NAME | | |
| 1 | DLG_GALUH_SELLER_V3 | Pemuda galak itu? Di gerbang alun-alun, sedang berdebat dengan penjaga. | The scowling one? At the plaza gate, arguing with a guard. |
| 2 | DLG_GALUH_SELLER_V4 | Jago terbaik hari ini bukan daganganku. Itu milik pemuda galak itu. | The best bird today isn't mine. It belongs to that scowling young man. |

### ciung_wanara (kg_alun; name NPC_CIUNG_WANARA_NAME). Entry order for the whole game; the prologue entries P1 and P2 (section 5) come first
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq4_9` (holding the Gua Kala mouth, Act VI) | |
| 2 | `quest:mq4=active` (the Interlude table in Desa Purwa) | |
| 3 | `quest:mq2=active` | |
| 4 | `step:mqg=0`, `flag:mqg_a1` (g.1) | |
| 5 | `flag:mqg_1`, `!flag:mqg_2` (g.2, after bout 1) | |
| 6 | `flag:mqg_4`, `!flag:mqg_7`, `zone:kg_keraton` (camp talk at `galuh_1`, `"quiet": true`; closes once the king is unmasked, and the zone keeps it out of later acts) | `flag:camp_galuh` |
| 7 | `quest:mqg=active` | |
| 8 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_CIUNG_WANARA_V10 | Masuklah. Tak ada yang lewat dua raja dan satu pintu. | Go in. Nothing gets past two kings and one door. |
| 2 | DLG_CIUNG_WANARA_V11 | Ibumu menuangkan teh untukku tanpa bertanya siapa aku. Pergilah ke selatan, Penulis. | Your mother poured me tea without asking who I was. Go south, writer. |
| 3 | DLG_CIUNG_WANARA_V1 | Katanya putra sang permaisuri yang kita kurung sedang mengumpulkan pasukan. Saudaraku, rupanya. | They say the caged queen's son is raising an army. My brother, apparently. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_CIUNG_WANARA_H1 | Lewat mana kita masuk? Gerbang istana dijaga ketat. | How do we get in? The palace gate is watched. |
| 4 | @NPC_CIUNG_WANARA_NAME | | |
| 4 | DLG_CIUNG_WANARA_V3 | Lewat sayembara raja. Ayamku bertarung di gelanggang, kau hajar siapa pun yang curang. | Through the king's tournament. My rooster fights in the ring, you thrash whoever cheats. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_CIUNG_WANARA_H2 | Aku tak menyentuh ayam. Dan aku tak bertaruh. | I don't touch roosters. And I don't bet. |
| 4 | @NPC_CIUNG_WANARA_NAME | | |
| 4 | DLG_CIUNG_WANARA_V7 | Siapa yang menyuruh? Ayam itu urusanku. Menangkan dua babak, dan raja terpaksa menemui kita. | Who asked you to? The bird's my business. Win two bouts and the king has to see us. |
| 5 | DLG_CIUNG_WANARA_V4 | Satu babak lagi. Mereka di panggung kehormatan mulai gelisah. | One more bout. They're getting nervous up on the dais. |
| 6 | DLG_CIUNG_WANARA_V8 | Kupikir singgasana itu akan terasa seperti pulang. Nyatanya seperti baju kakak: kebesaran, dan bukan milikku. | I thought the throne would feel like coming home. It feels like a big brother's coat: too large, and not mine. |
| 6 | @NPC_HERO_NAME | | |
| 6 | DLG_CIUNG_WANARA_H3 | Lalu kenapa kau mau? | Then why take it? |
| 6 | @NPC_CIUNG_WANARA_NAME | | |
| 6 | DLG_CIUNG_WANARA_V9 | Kau mau adikmu, aku mau yang dicuri dariku. Sama saja. Tidur. Besok kita buka topeng raja. | You want your sister, I want what was stolen from me. Same thing. Sleep. Tomorrow we lift the king's mask. |
| 7 | DLG_CIUNG_WANARA_V5 | Istana ini bau dupa tua dan dusta. | This palace smells of old incense and lies. |
| 8 | DLG_CIUNG_WANARA_V6 | Galuh akan punya raja yang adil. Suatu hari. | Galuh will have a fair king. Someday. |

### Beat `galuh_bout` (if `!flag:beat_galuh_bout`, `flag:mqg_2`; do `flag:beat_galuh_bout`, `codex:ciung_wanara`). Lengser's hint stays unnamed: Ciung must not learn who the queen was
| Key | ID | EN |
|-----|----|----|
| BEAT_GALUH_BOUT_1 | Sorak membahana dari gelanggang di balik tembok. Ayam Ciung Wanara menang. Kau tak melihatnya, hanya mendengar. Tugasmu cuma menghajar yang curang. | A roar goes up from the ring behind the wall. Ciung Wanara's rooster has won. You didn't see it, only heard it. Your job was the cheats. |
| @NPC_LENGSER_NAME | | |
| BEAT_GALUH_BOUT_2 | Mata itu... mata seorang ratu yang pernah kukenal. Temui aku, kalian berdua, diam-diam. Dan jangan tersenyum. | Those eyes... the eyes of a queen I used to know. Come and see me, both of you, quietly. And don't smile. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_GALUH_BOUT_3 | Kakek itu menatapku seperti melihat hantu. | The old man looked at me like he'd seen a ghost. |

The rooster stays off-screen ([quests.md](quests.md) MQG sensitivity).

### lengser (kg_alun, cond `flag:mqg_2`; name NPC_LENGSER_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mqg=2` (g.3) | `codex:lengser` |
| 2 | `flag:choice_freed` | |
| 3 | `flag:choice_handed` | |
| 4 | `quest:mqg=active` | |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_LENGSER_V1 | Jangan menoleh. Aku Uwa Lengser, abdi di sini sejak raja yang sah masih bujang. Lima belas tahun kusimpan satu rahasia, dan lututku sudah tak sanggup menanggungnya. | Don't turn around. I'm Uwa Lengser, I've served here since the true king was a bachelor. Fifteen years I've kept one secret, and my knees can't carry it anymore. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LENGSER_H1 | Orang-orang yang diculik, Uwa. Dibawa ke mana? | The taken, Uwa. Where are they kept? |
| 1 | @NPC_LENGSER_NAME | | |
| 1 | DLG_LENGSER_V2 | Lewat gerbang sel, malam hari. Tak pernah keluar lagi. Kubukakan pelataran: istirahatlah, lalu geledah selnya. | In through the cell gate at night. Never out again. I'll open the courtyard: rest, then search the cells. |
| 2 | DLG_LENGSER_V5 | Pembelot itu kau lepaskan? Hm. Ampun itu kebiasaan raja. Hati-hati, menular. | You let that deserter go? Hm. Mercy is a king's habit. Careful, it's catching. |
| 3 | DLG_LENGSER_V6 | Pembelotmu sudah kenyang dan terkunci. Galuh akan mengadilinya dengan adil. Aku yang jamin. | Your deserter is fed and locked up. Galuh will judge him fairly. I'll see to it. |
| 4 | DLG_LENGSER_V7 | Pelan-pelan. Penjaga di sini menghitung jarinya sendiri pun salah, tapi tetap saja. | Quietly. The guards here can't count their own fingers, but still. |
| 5 | DLG_LENGSER_V8 | Galuh bernapas lega. Lututku juga. | Galuh breathes easier. So do my knees. |

### Beat `galuh_escort` (if `!flag:beat_galuh_escort`, `flag:mqg_4b`; do `flag:beat_galuh_escort`). The near miss.
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_GALUH_ESCORT_1 | Penjaga terakhir tumbang tepat saat pedati itu lolos dari gerbang. Sesuatu melayang dari balik tembok. | The last guard falls just as the wagon clears the gate. Something comes over the wall. |
| BEAT_GALUH_ESCORT_2 | Secarik lontar, dengan satu huruf goyah: Ka. Saat kau mendongak, pedati itu sudah hilang ke timur. | A strip of lontar, one shaky letter on it: Ka. When you look up, the wagon is gone east. |

| Key | ID | EN |
|-----|----|----|
| DLG_LARAS_WALL_H1 | Di dinding sel, tulisan tangan Laras: "Seribu candi. Jangan berhenti." | On the cell wall, Laras's handwriting: "The thousand temples. Don't stop." |

### Laras chapter LC2 `lc2` (step g.6; kind chapter; Laras in the wagon, the Deserter driving)
| Key | ID | EN |
|-----|----|----|
| LC_2_TITLE | Di Bawah Kain Kereta | Under the Wagon Cloth |
| @NPC_LARAS_NAME | | |
| LC2_1 | Pedati ini bau jerami dan sedih. Pengemudinya bersenandung. Penjaga yang aneh. | This wagon smells of straw and sadness. The driver hums. Strange guard. |
| LC2_2 | Papan lantainya longgar. Kalau kugores pesan di baliknya, mungkin Kak menemukannya. | The floorboard is loose. If I scratch a message under it, maybe Kak will find it. |
| LC2_3 | Itu suara Kak! Di halaman, bertarung seperti banteng. Aku harus melempar sesuatu! | That's Kak! In the yard, fighting like a bull. I have to throw something! |
| LC2_4 | Kak, aku baik-baik saja. Bilang ke Ibu: jangan buang cangkirku yang gompal. | Kak, I'm fine. Tell Ibu: don't throw out my chipped cup. |
| LC2_5 | Pengemudiku ikut bersenandung waktu aku mengeja Ka. Dia pasti pernah punya nama bagus. | My driver hums along when I spell Ka. He must have had a good name once. |
(The board pickup: item `laras_board` is given when the chapter ends, ASSUMED.)
| Key | ID | EN |
|-----|----|----|
| DLG_BOARD_H1 | Papan lantai kereta, tergores tulisan Laras: "Bilang ke Ibu, jangan buang cangkirku yang gompal." | A wagon floorboard, scratched in Laras's hand: "Tell Ibu, don't throw out my chipped cup." |

### Chapter 3: The Borrowed Face (g.7-g.9)

### faceless_deserter (kg_penjara; name NPC_FACELESS_DESERTER_NAME): Choice 1
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `step:mqg=6` (g.7) | | CHOICE_DESERTER_1 to `flag:choice_freed`; CHOICE_DESERTER_2 to `flag:choice_handed` |
| 2 | `flag:choice_freed` | | |
| 3 | `flag:choice_handed` | | |
| 4 | (none) | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_FACELESS_DESERTER_V1 | Jangan! Aku bukan... dulu aku tukang gerabah, rasanya. Aku lupa wajah istriku. | Don't! I'm not... I was a potter, I think. I can't remember my wife's face. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_FACELESS_DESERTER_H1 | Kau yang menjaga adikku. Katanya kau membiarkannya menyimpan separuh lontarnya. | You guarded my sister. She says you let her keep her half. |
| 1 | @NPC_FACELESS_DESERTER_NAME | | |
| 1 | DLG_FACELESS_DESERTER_V2 | Tiap malam dia mengeja Ka keras-keras, berulang-ulang. Aku ikut menggumam, dan suatu pagi aku punya satu suku kata namaku sendiri. | Every night she spelled Ka aloud, over and over. I hummed along, and one morning I had one syllable of my own. |
| 1 | DLG_FACELESS_DESERTER_V3 | Tuan kami bicara dengan suara raja. Aku tak pernah bertanya. Aku cuma mengangkut yang sudah tanpa nama. Mau kau apakan aku? | Our master speaks with the king's voice. I never asked why. I only carried those already nameless. What will you do with me? |
| 2 | DLG_FACELESS_DESERTER_V4 | Aku pergi saat penjaga lengah. Terima kasih. | I'll go when the guards look away. Thank you. |
| 3 | DLG_FACELESS_DESERTER_V5 | Lengser, kalau begitu. Lebih baik daripada gelap. | Lengser, then. Better than the dark. |
| 4 | DLG_FACELESS_DESERTER_V6 | Singkirkan mereka dulu! | Get them off me first! |

| Key | ID | EN |
|-----|----|----|
| CHOICE_DESERTER_1 | Pergilah. Carilah wajah istrimu. | Go. Find your wife's face. |
| CHOICE_DESERTER_2 | Lengser akan menjagamu, dan mengadilimu. | Lengser will keep you safe, and judge you. |

### Clue `court_portrait` (step g.7; starts `k_ii`; the person-boss clue)
| Key | ID | EN |
|-----|----|----|
| HUNT_KII_TITLE | Wajah Sang Raja | The King's Face |
| CLUE_COURT_PORTRAIT_1 | Potret raja di galeri, wajahnya dikikis sampai kayu putih. Hanya mahkota yang tersisa. | The king's portrait in the gallery, its face scraped down to pale wood. Only the crown is left. |
| CLUE_COURT_PORTRAIT_2 | Siapa pun yang memakai wajah ini, ia menghapus pemiliknya lebih dulu. | Whoever wears this face scraped off its owner first. |
| CLUE_COURT_PORTRAIT_NOTE | Potret raja di galeri, wajahnya dikikis. | The king's portrait in the gallery, its face scraped away. |

### Memory `k_ii` (walk; K-II, step g.8; Lengser's younger self, one night in this gallery)
| Key | ID | EN |
|-----|----|----|
| MEM_K_II_TITLE | Malam Uwa Lengser | Uwa Lengser's Night |
| MEM_K_II_IN | Ingatan Uwa Lengser, Nak: satu malam, lima belas tahun lalu, di lorong yang sama. | Uwa Lengser's memory, child: one night, fifteen years ago, in this same gallery. |
| MEM_K_II_1 | Lengser muda membawa baki teh ke kamar raja. Pintunya setengah terbuka. | Young Lengser carries a tea tray to the king's chamber. The door stands ajar. |
| MEM_K_II_2 | Di dalam, seorang lelaki berdiri di depan cermin, mencoba wajah sang raja seperti mencoba baju. | Inside, a man stands before a mirror, trying on the king's face like a coat. |
| MEM_K_II_3 | Lengser menjatuhkan baki. Lelaki itu menoleh dengan wajah raja, dan tersenyum. | Lengser drops the tray. The man turns, wearing the king's face, and smiles. |
| MEM_K_II_OUT | Lengser memegang rahasia itu sejak malam itu, Nak. Sekarang kau ikut memegangnya. | Lengser has held that secret since that night, child. Now you hold it too. |

### Clue `hunter_mask_2` and memory `h2` (step g.8; H2, kind walk; Aria wears the king's face)
| Key | ID | EN |
|-----|----|----|
| CLUE_HUNTER_MASK_2_1 | Pecahan topeng ketiga di kaki takhta. Dingin, kali ini. | A third mask fragment at the foot of the throne. Cold, this time. |
| CLUE_HUNTER_MASK_2_2 | Seperti wajah yang dipinjam terlalu lama. | Like a face borrowed too long. |
| CLUE_HUNTER_MASK_2_NOTE | Pecahan topeng ketiga, di dekat takhta. | The third mask fragment, by the throne. |
| MEM_H2_TITLE | Wajah Pinjaman | The Borrowed Face |
| MEM_H2_IN | Aria lagi, Nak. Lihat apa yang ia lakukan malam itu. | Aria again, child. Watch what he did that night. |
| MEM_H2_1 | Aria menatap cermin. Wajah raja menatap balik, ramah, dan tak bernama. | Aria looks in the mirror. The king's face looks back, kind, and nameless. |
| MEM_H2_2 | Paginya para pelayan memanggilnya "Gusti Prabu". Tak ada yang menyebut Aria lagi. | By morning the servants call him "Gusti Prabu". Nobody says Aria again. |
| MEM_H2_3 | Aria mencoba menyebut namanya sendiri di kamar kosong. Tak ada suara yang keluar. | Aria tries to say his own name in the empty room. No sound comes out. |
| MEM_H2_OUT | Wajah pinjaman itu mahal, Nak. Hampir selalu harganya nama sendiri. | A borrowed face is costly, child. Nearly always the price is your own name. |

### Beat `throne_shadow` (if `!flag:beat_throne_shadow`, `flag:mqg_h3`; do `flag:beat_throne_shadow`). The Hunter is felt, not heard
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_THRONE_SHADOW_1 | Di belakang takhta, bayangan jangkung berdiri sebentar, memandangi cermin kosong. Lalu ia pergi. | Behind the throne a tall shadow stands a moment, staring at an empty mirror. Then it is gone. |

### Beat `confession` (if `!flag:beat_confession`, `flag:mqg_7`; do `flag:beat_confession`). The turn.
| Key | ID | EN |
|-----|----|----|
| BEAT_CONFESSION_1 | Topeng raja jatuh berdentang. Di baliknya, seorang tua kurus yang lama tak melihat wajahnya sendiri. | The king's mask clatters down. Under it, a thin old man who hasn't seen his own face in years. |
| @NPC_BARMA_WIJAYA_NAME | | |
| BEAT_CONFESSION_2 | Aria Kebonan. Dulu aku patih. Raja itu punya wajah yang kuinginkan, jadi kukikis namanya dari batu dan kupinjam wajahnya. | Aria Kebonan. I was a minister once. The king had a face I wanted, so I scraped his name off the stone and borrowed it. |
| BEAT_CONFESSION_3 | Goresan pertama itu retakan pertama. Dan untuk menjaga wajahnya, kuberikan namaku sendiri pada Kala. | That first scrape was the first crack. And to keep his face, I gave my own name to Kala. |
| @NPC_HERO_NAME | | |
| BEAT_CONFESSION_H1 | Nama itu sekarang memburu adikku. | That name is hunting my sister now. |
| @NPC_BARMA_WIJAYA_NAME | | |
| BEAT_CONFESSION_4 | Ia memburu siapa pun yang bisa menuliskannya kembali. Aku bukan lagi dia. Aku hanya bayangannya. | It hunts whoever can write it back. I'm not it anymore. I'm only its shadow. |

### Beat `cage` (if `!flag:beat_cage`, `flag:beat_confession`; do `flag:beat_cage`, `codex:barma_wijaya`, `codex:pangrenyep`)
| Key | ID | EN |
|-----|----|----|
| BEAT_CAGE_1 | Ciung Wanara menyeret mereka ke kandang besi di pelataran, seperti dalam kisah: sang raja palsu, dan sang permaisuri bersamanya. | Ciung Wanara drags them to the iron cage in the courtyard, as in the legend: the false king, and the queen with him. |
| @NPC_PANGRENYEP_NAME | | |
| BEAT_CAGE_2 | Putraku akan datang, Nak. Yang dikurung selalu ditebus. | My son will come, child. What is caged is always ransomed. |
| @NPC_HUNTER_NAME | | |
| BEAT_CAGE_3 | Kandang menahan orangnya, bukan namanya. | The cage holds the man, not the name. |
| @ | | |
| BEAT_CAGE_4 | Suara itu datang dari balik singgasana. Saat kau menoleh, hanya bayangan yang tersisa. | The voice comes from behind the throne. When you turn, only shadow is left. |

### Beat `escape` (if `!flag:beat_escape`, `quest:mqg=done`, `flag:beat_cage`; do `flag:beat_escape`, `start:mq2`)
| Key | ID | EN |
|-----|----|----|
| BEAT_ESCAPE_1 | Dalam kekacauan, seorang pemuda berbaju sutra melompati pagar pelataran, putra sang ratu, Hariang Banga. | In the chaos a young man in silk vaults the courtyard wall: the queen's son, Hariang Banga. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_ESCAPE_2 | Kalian mengurung dua orang yang belum diadili. Aku akan kembali dengan pasukan. | You've caged two who were never tried. I'll be back with an army. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_ESCAPE_3 | Biarkan. Dia saudaraku, aku tak mau mengejarnya. Galuh harus kujaga. Kau cari adikmu, ke timur, ke arah dia lari. | Let him go. He's my brother, I won't chase him. I have to hold Galuh. You go find your sister, east, the way he ran. |
| @NPC_LENGSER_NAME | | |
| BEAT_ESCAPE_4 | Lima belas tahun kupegang rahasia itu. Ringan juga setelah dilepas. | Fifteen years I held that secret. Light, once it's let go. |


## 8. Act III: Mataram (MQ2, "Darah di Pamali")
**Lines in this section: 107** (ASSUMED budget: at most 120).
Regional character: Ki Sumarto (want: a stage no army will burn; turn: his son marches east; close: Sapto wades home). Order of play: the two recruiters (who's who), the haulers (K3 hook), the three leads, the glyph teachers, the graves and the third mask fragment, the juru kunci, Candi Seribu, the Bondowoso clues and memory, Laras chapter 3, the Pamali stone, Ki Sumarto's show, the letters, the ford.

### Chapter 1: The Two-Bank Market (2.1-2.4)

### recruiter_a (mt_pasar, the west bank; name NPC_RECRUITER_A_NAME; new). Step 2.1 `all`, any order
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq2=active`, `!flag:mq2_a1` | |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_RECRUITER_A_NAME | | |
| 1 | DLG_RECRUITER_A_V1 | Prajurit untuk Ciung Wanara! Raja palsu sudah dikurung, dan kini putra sang ratu membawa tentara untuk membebaskan seorang lalim. | Soldiers for Ciung Wanara! The false king is caged, and now the queen's son brings an army to free a tyrant. |
| 1 | DLG_RECRUITER_A_V2 | Tepi timur bercerita sebaliknya. Jangan percaya mereka. Gerbang perbatasan ke arah sungai, kalau mau lewat. | The east bank tells it the other way round. Don't believe them. The border gate is toward the river, if you want to pass. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_RECRUITER_A_H1 | Ceritamu lancar sekali. | You tell it smoothly. |
| 2 | DLG_RECRUITER_A_V3 | Tombak atau telinga yang baik. Aku terima keduanya. | A spear or a good ear. I'll take either. |

### recruiter_b (mt_pasar, the east bank; name NPC_RECRUITER_B_NAME; new). Step 2.1 `all`, any order
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq2=active`, `!flag:mq2_a1` | |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_RECRUITER_B_NAME | | |
| 1 | DLG_RECRUITER_B_V1 | Prajurit untuk Hariang Banga! Seorang anak pungut mengurung seorang ratu dan suaminya, dan pangeran sejati bergerak membebaskan ibunya. | Soldiers for Hariang Banga! A foundling caged a queen and her husband, and the true prince marches to free his mother. |
| 1 | DLG_RECRUITER_B_V2 | Tepi barat bercerita terbalik. Kasihan yang percaya mereka. Gerbang perbatasan di sana, kalau mau lewat. | The west bank tells it backwards. Pity whoever believes them. The border gate is over there, if you want to pass. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_RECRUITER_B_H1 | Ceritamu lancar sekali. | You tell it smoothly. |
| 2 | DLG_RECRUITER_B_V3 | Tombak atau telinga yang baik. Aku terima keduanya. | A spear or a good ear. I'll take either. |

### Beat `two_stories` (if `!flag:beat_two_stories`, `flag:mq2_a1`; do `flag:beat_two_stories`). Who's who, in one thought
| Key | ID | EN |
|-----|----|----|
| @NPC_HERO_NAME | | |
| BEAT_TWO_STORIES_H1 | Satu cerita, dua penjahat berbeda. Masing-masing yakin dirinya benar. | One story, two different villains. Each is sure they're in the right. |
| BEAT_TWO_STORIES_H2 | Dan Kala makan dari keduanya. Gerbang perbatasan, lalu petilasan. | And Kala eats from both. The border gate, then the petilasan. |

### Beat `haulers` (if `!flag:beat_haulers`, `step:mq2=0`, `zone:mt_gerbang`; do `flag:beat_haulers`). K3 hook
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_HAULERS_1 | Di luar gerbang, penduduk desa menyeret batu besar dalam gelap. Mereka tak bicara; mata mereka kosong. | Beyond the gate villagers haul great stones through the dark. They don't speak; their eyes are empty. |
| BEAT_HAULERS_2 | Di ladang yang kemarin kosong, berdiri tembok candi setinggi dada. | In a field that was empty yesterday stands a temple wall chest-high. |
| @NPC_HERO_NAME | | |
| BEAT_HAULERS_H1 | Siapa menyuruh mereka? | Who ordered this? |

### Hunt K3: Bandung Bondowoso (2.1, 2.7, 2.8, 2.10)
| Key | ID | EN |
|-----|----|----|
| HUNT_K3_TITLE | Seribu Candi | The Thousand Temples |

### mataram_dalang (Ki Sumarto; replace the main-path entries, keep the SQ-M4 entries)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq2=done` | |
| 2 | `flag:lead_pasar`, `!flag:mq2_2` (2.4) | `learn:jawa_ha` |
| (keep) | SQ-M4 entries | |
| 3 | `flag:lead_pasar` | |
| 4 | `quest:mq2=active` | |
| (keep) | the current fallback | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_MATARAM_DALANG_V7 | Anakku pulang menyeberang kali itu. Lakon berikutnya kumainkan untuk satu tepi saja: rumahku. | My son waded home across that river. The next lakon I play for one bank only: my house. |
| 2 | DLG_MATARAM_DALANG_V1 | Kelirku selamat, dan kau yang menyelamatkannya. Aku Ki Sumarto, dalang. Pagi untuk tepi barat, malam untuk tepi timur. | My screen survived, and you saved it. I'm Ki Sumarto, dalang. Mornings for the west bank, evenings for the east. |
| 2 | @NPC_MATARAM_DALANG_NAME | | |
| 2 | DLG_MATARAM_DALANG_V2 | Anakku Sapto berbaris dengan pasukan Hariang Banga. Selama dua tepi mau menonton, tak ada yang memanah panggungku. Ini Ha, penyembuh; di timur katanya juga mengangkat kutukan. | My son Sapto marches with Hariang Banga's army. As long as both banks want a show, nobody shoots my stage. This is Ha, it heals; out east they say it lifts curses too. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_MATARAM_DALANG_H2 | Gadis kecil dengan lontar. Anda lihat dia? | A little girl with a lontar. Did you see her? |
| 2 | @NPC_MATARAM_DALANG_NAME | | |
| 2 | DLG_MATARAM_DALANG_V3 | Digiring lewat pasar, ke arah Candi Seribu, seribu candi yang sedang didirikan para pengangkut batu. Ada tiga jalan ke sana: reruntuhan, kuburan, dan pasar ini. Tempuh semuanya. | Marched through this market toward Candi Seribu, the Thousand Temples the haulers are raising. Three roads lead there: the ruins, the graveyard, and this market. Walk them all. |
| 3 | DLG_MATARAM_DALANG_V6 | Hariang Banga bukan orang kejam. Ia ingin ibunya kembali. Aku pun begitu, dengan anakku. | Hariang Banga isn't cruel. He wants his mother back. So would I, with my boy. |
| 4 | DLG_MATARAM_DALANG_V4 | Tolong, Nak! Mereka menjarah kelirku! Hajar mereka, nanti kubayar dengan cerita! | Help, child! They're looting my screen! Thrash them, and I'll pay you in stories! |

### pak_karto (side NPC in `mt_reruntuhan`'s outer yard, off the main path since v3.1; no quest yet)
| Entry | if | do |
|-------|----|----|
| 1 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_PAK_KARTO_IDLE | Batu-batu ini dulu bicara. Kini hanya lumut yang mendengarkan. Lihatlah dasar Arca itu kalau kau berani lewat halaman. | These stones used to speak. Now only the moss listens. Look at the Arca's base, if you dare the courtyard. |

### arca_base (object, `flag:lead_ruins`, cond `!flag:mq2_3`; name NPC_ARCA_BASE_NAME). Pak Karto leaves the main path.
| Entry | if | do |
|-------|----|----|
| 1 | `flag:lead_ruins`, `!flag:mq2_3` (2.5) | `learn:jawa_na` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_ARCA_BASE_V1 | Di dasar Arca terpahat aksara Jawa lama, halus, dimakan lumut. Satu goresan lurus tanpa ragu: Na. | At the Arca's base, old Javanese letters, fine and mossed over. One straight stroke with no doubt in it: Na. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_ARCA_BASE_H1 | Tanganku mengikutinya sebelum aku sempat berpikir. | My hand followed it before I could think. |
| 1 | @NPC_ARCA_BASE_NAME | | |
| 1 | DLG_ARCA_BASE_V2 | Na menerjang lurus menembus apa pun. Penjaga batu itu retak di dalam, dan huruf ini membelahnya. | Na dashes straight through whatever stands there. The stone guardians are cracked inside, and this letter splits them. |
| 1 | DLG_ARCA_BASE_V3 | Tanah di kaki Arca masih basah oleh jejak sepatu kain, menuju timur. | The earth at the Arca's foot is still wet with cloth-shoe prints, heading east. |
| 2 | DLG_ARCA_BASE_V4 | Lumut dan satu huruf. Na. | Moss, and one letter. Na. |

### lesung_women (replace all entries; main-path only, the SQ-M5 giver entries are dropped)
| Entry | if | do |
|-------|----|----|
| 1 | `flag:lead_kuburan`, `!flag:mq2_5` (2.6) | `learn:jawa_ca` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_LESUNG_WOMEN_V1 | Dengar? Tuk, tuk, tuk. Setahun kami tak berani menumbuk. Kuburan itu membuat kami bisu. | Hear that? Tuk, tuk, tuk. A year we haven't dared to pound. That graveyard struck us dumb. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LESUNG_WOMEN_H1 | Sudah kubersihkan. Irama apa itu? | I cleared it. What rhythm is that? |
| 1 | @NPC_LESUNG_WOMEN_NAME | | |
| 1 | DLG_LESUNG_WOMEN_V2 | Irama fajar palsu. Konon dayang Roro Jonggrang, putri kisah seribu candi, menumbuk begini agar ayam berkokok lebih awal. Ini Ca: gambarlah mengikuti irama, dan tanganmu lebih cepat dari amarah. | The false-dawn rhythm. They say the women of Roro Jonggrang, princess of the thousand-temples tale, pounded like this to fake the dawn. This is Ca: draw to the beat, and your hand outruns anger. |
| 1 | DLG_LESUNG_WOMEN_V3 | Batu-batunya bergerak lagi tiap malam. Juru kunci, penjaga kunci bukit, memegang kuncinya. Tembus blokade, dan dia akan menemuimu. | The stones move again every night. The juru kunci, the hill's key-keeper, holds the key. Break the blockade and he'll receive you. |
| 2 | DLG_LESUNG_WOMEN_V10 | Kami menumbuk padi dan bernyanyi. Ikutlah kapan saja. | We pound rice and sing. Join us anytime. |

VERIFY: Roro Jonggrang's women pounding rice to fake the dawn.

### Beat `hunter_war` (if `!flag:beat_hunter_war`, `flag:lead_kuburan`; do `flag:beat_hunter_war`)
| Key | ID | EN |
|-----|----|----|
| BEAT_HUNTER_WAR_1 | Di antara nisan-nisan baru, para tanpa rupa menunduk dan mengangkat sesuatu dari tubuh prajurit: selembar nama, diremas seperti kertas. | Among the new graves the faceless stoop and lift something from the fallen soldiers: a name, crumpled like paper. |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_WAR_2 | Dua pasukan membuat dua kali lupa. | Two armies make twice the forgetting. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_WAR_H1 | Di mana adikku? | Where is my sister? |
| @ | | |
| BEAT_HUNTER_WAR_3 | Ia berbalik ke arah candi. Hanya jelaga tertinggal di rumput. | He turns toward the temples. Only soot is left on the grass. |

### Clue `hunter_mask_3` and memory `h3` (step 2.4; H3, kind walk; Aria gives his own name to Kala)
| Key | ID | EN |
|-----|----|----|
| CLUE_HUNTER_MASK_3_1 | Pecahan topeng keempat di antara nisan baru. Berat, seperti menahan sesuatu. | A fourth mask fragment among the new graves. Heavy, like it's holding something. |
| CLUE_HUNTER_MASK_3_2 | Lontarku menarik, seolah ingin menunjukkan harganya. | My lontar tugs, as if it wants to show me the price. |
| CLUE_HUNTER_MASK_3_NOTE | Pecahan topeng keempat, di antara nisan. | The fourth mask fragment, among the graves. |
| MEM_H3_TITLE | Harga | The Price |
| MEM_H3_IN | Satu malam sendirian, Nak. Jangan berpaling. | A night alone, child. Don't look away. |
| MEM_H3_1 | Aria duduk sendiri di kamar, dengan wajah raja di wajahnya. Sebuah bayangan besar menunggu di sudut. | Aria sits alone in the chamber, the king's face on his own. A great shadow waits in the corner. |
| MEM_H3_2 | "Aku bisa menjaga wajah ini," katanya. "Harganya?" Bayangan itu: "Namamu." | "I can keep this face," he says. "The price?" The shadow: "Your name." |
| MEM_H3_3 | Aria diam lama. Lalu ia menyerahkannya, seperti menyerahkan sehelai daun. | Aria is silent a long while. Then he gives it up, like handing over a leaf. |
| MEM_H3_OUT | Kala memakan nama dengan sopan, Nak. Ia bahkan menghapus rasa kehilangannya. | Kala eats names politely, child. He even eats the grief for them. |

### juru_kunci (Mbah Marto; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=4` (2.5) | `learn:jawa_ra` |
| 2 | `quest:mq2=active`, `flag:mq2_6` | |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_JURU_KUNCI_V1 | Blokade itu runtuh? Dua hari aku tak bisa turun menyalakan dupa. Aku juru kunci bukit ini, penjaga kunci candi. | The blockade fell? Two days I couldn't come down to light incense. I'm the juru kunci of this hill, keeper of the temple keys. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_JURU_KUNCI_H1 | Kata orang, Mbah memegang kunci Candi Seribu. | They say you hold the keys to Candi Seribu. |
| 1 | @NPC_JURU_KUNCI_NAME | | |
| 1 | DLG_JURU_KUNCI_V2 | Kunci, ya. Tapi para tanpa rupa berkemah di dalamnya dan membangunkan kutukan prajurit lama. Kunci tak berguna lagi. | The keys, yes. But the faceless have camped inside and woken the old soldiers' curse. Keys are no use now. |
| 1 | DLG_JURU_KUNCI_V3 | Ra. Roh macan berjalan di sisimu, dan yang terkutuk berbalik menghadapinya. Saat itu, pukul punggungnya. Tangga candi kubuka. | Ra. A tiger spirit walks beside you, and the cursed turn to face it. That's when you strike their backs. The temple stairs are open. |
| 2 | DLG_JURU_KUNCI_V5 | Hancurkan perkemahan itu. Arwah di sini berhak tidur tenang. | Break that camp. The dead here deserve their sleep. |
| 3 | DLG_JURU_KUNCI_V6 | Hati-hati di gerbang candi. Batunya bisa runtuh. | Mind the temple gate. Stones can fall. |

### Chapter 2: The Thousand Temples (2.5-2.10)

### Beat `lengser_word` (if `!flag:beat_lengser_word`, `flag:choice_handed`, `flag:mq2_6`; do `flag:beat_lengser_word`)
| Key | ID | EN |
|-----|----|----|
| @NPC_LENGSER_NAME | | |
| BEAT_LENGSER_WORD_1 | Titipan dari Uwa: si pembelot menggambar denah kemah itu di tanah. Gerbang barat penjaganya lengah. | A word from Uwa: the deserter drew the camp's layout in the dirt. The west gate is poorly watched. |

### Beat `camp` (if `!flag:beat_camp`, `flag:mq2_7`; do `flag:beat_camp`). The turn.
| Key | ID | EN |
|-----|----|----|
| BEAT_CAMP_1 | Perkemahan itu bukan penjara. Meja panjang, lontar terbentang, batu-batu tersusun: sebuah ruang baca. | The camp is no prison. Long tables, lontar spread open, stones stacked: a reading room. |
| BEAT_CAMP_2 | Di lantai, secarik lontar yang robek dari separuh miliknya, penuh satu huruf yang ditulis berulang-ulang: Ka. Makin lama makin goyah. | On the floor, a strip torn from her half of the lontar, covered with one letter written again and again: Ka. Shakier each time. |
| @NPC_HERO_NAME | | |
| BEAT_CAMP_H1 | Dia di sini. Dia menulis Ka sampai tangannya gemetar. | She was here. She wrote Ka until her hand shook. |
| @ | | |
| BEAT_CAMP_2B | Para tanpa rupa sudah membawanya ke timur. Di bawah tanah, seribu candi berderak, dan Bandung Bondowoso bangun, sang pangeran pembangun seribu candi. | The faceless have taken her east. Underground, a thousand temples creak, and Bandung Bondowoso wakes, the prince who builds a thousand temples. |

### Clues K3 (step 2.7; `ka_strip` starts `k3_lesung`)
| Key | ID | EN |
|-----|----|----|
| CLUE_RUBBLE_1 | Puing berbekas pahat baru, dan cap tangan seperti bayangan yang mencengkeram batu. | Rubble with fresh chisel marks, and hand-prints like shadows gripping stone. |
| CLUE_RUBBLE_2 | Tak ada tukang yang membangun candi-candi ini. Ada yang mempekerjakan arwah. | No mason built these temples. Someone put spirits to work. |
| CLUE_RUBBLE_NOTE | Puing berbekas pahat baru dan cap tangan arwah. | Rubble with fresh chisel marks and spirit hand-prints. |
| CLUE_LESUNG_MID_1 | Sebuah lesung ditinggalkan di tengah irama, alunya masih di dalam. | A lesung left mid-rhythm, the pestle still in it. |
| CLUE_LESUNG_MID_2 | Seseorang menumbuk di sini sampai bunyinya dihentikan. | Someone pounded here until the sound was stopped. |
| CLUE_LESUNG_MID_NOTE | Lesung ditinggalkan di tengah irama. | A lesung abandoned mid-rhythm. |
| CLUE_KA_STRIP_1 | Tulisan Laras. Tangannya gemetar, tapi hurufnya tak berubah: Ka. | Laras's writing. Her hand shakes, but the letter never changes: Ka. |
| CLUE_KA_STRIP_2 | Dia tak berhenti menulis. Aku juga tak akan berhenti. | She didn't stop writing. Neither will I. |
| CLUE_KA_STRIP_NOTE | Helai lontar Laras, penuh Ka yang goyah. | Laras's lontar strip, full of shaky Ka. |

### Memory `k3_lesung` (play; K3, step 2.8; kelir figure: one of Roro Jonggrang's women; the action pounds the lesung to a 3-bar beat)
| Key | ID | EN |
|-----|----|----|
| MEM_K3_LESUNG_TITLE | Para Dayang Sang Putri | The Princess's Women |
| MEM_K3_LESUNG_IN | Malam ini kau melayani seorang putri, Nak. Seorang pangeran bersumpah membangun seribu candi sebelum fajar. Jaga irama lesung. | Tonight you serve a princess, child. A prince has sworn to raise a thousand temples before dawn. Keep the lesung beat. |
| MEM_K3_LESUNG_HINT | Ikuti irama | Keep the beat |
| MEM_K3_LESUNG_1 | Tuk, tuk, tuk. Para dayang menumbuk padi di bawah bulan. | Tuk, tuk, tuk. The women pound rice beneath the moon. |
| MEM_K3_LESUNG_2 | Di kejauhan batu-batu berderet naik ke langit. Satu candi lagi, dan sumpah itu terpenuhi. | Far off, stones climb in rows. One more temple and the oath is kept. |
| MEM_K3_LESUNG_3 | Ayam-ayam terkecoh dan berkokok. Sang pangeran kurang satu candi, dan kurang satu malam. | The roosters are fooled and crow. The prince falls one temple short, and a night short. |
| MEM_K3_LESUNG_OUT | Irama itu menghentikan batu-batu, Nak. Gambar Ca mengikuti ketukannya, dan tiang-tiang terbuka. | That beat stops the stones, child. Draw Ca to its count, and the pillars lay themselves open. |
| HINT_BANDUNG | Ikuti irama | Keep the beat |

### Laras chapter LC3 `lc3` (step 2.9; kind chapter; the reading room at Candi Seribu). The game makes her read; the chapter shows why
| Key | ID | EN |
|-----|----|----|
| LC_3_TITLE | Ruang Baca | The Reading Room |
| @NPC_LARAS_NAME | | |
| LC3_1 | Mereka bilang: baca, atau tawanan yang menanggung. Tangan mereka tidak bohong. | They say: read, or the prisoners pay. Their hands don't lie. |
| LC3_2 | Aku menolak sekali. Seorang tawanan berteriak. Aku tak akan mencoba itu lagi. | I refuse once. A prisoner cries out. I won't try that again. |
| LC3_3 | Aku membaca, dan salah satu huruf sengaja kubalik. Segelnya tetap retak. Maaf. | I read, and I flip one letter on purpose. The seal cracks anyway. Sorry. |
| LC3_4 | Kak, aku membaca karena mereka menyakiti tawanan kalau aku diam. Aku tahu itu salah. Tetap saja. Kutulis Ka lagi malam ini. | Kak, I read because they hurt the prisoners when I don't. I know it's wrong. I did it anyway. I wrote Ka again tonight. |

### Chapter 3: The Pamali River (2.11-2.13)

### pamali_stone (kg_pamali, cond `flag:mq2_7`; name NPC_PAMALI_STONE_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=10` (2.11) | `write:nagawiru:jawa_na,sunda_ga` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_PAMALI_STONE_V1 | Batu batas tua di Sungai Pamali, sungai "yang tak boleh dilanggar". Dulu sebuah nama dipahat di sini, lalu dikikis. | An old boundary stone on the Pamali, the river of "what must not be done". A name was cut here once, then scraped away. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PAMALI_STONE_H1 | Nagawiru. | Nagawiru. |
| 1 | @NPC_PAMALI_STONE_NAME | | |
| 1 | DLG_PAMALI_STONE_V2 | Tuliskan kembali: Na dari timur, Ga dari barat. Kandang hanya menahan orang. Nama harus ditulis. | Write it back: Na from the east, Ga from the west. A cage only holds a man. A name has to be written. |
| 2 | DLG_PAMALI_STONE_V3 | Nama itu bertahan. Suara sungai kini terdengar lain. | The name holds. The river sounds different now. |

### Clue `sumarto_show` and memory `k_iii` (step 2.12; K-III, kind walk; Ki Sumarto's show at the ford camp, cond `flag:mq2_8`)
| Key | ID | EN |
|-----|----|----|
| HUNT_KIII_TITLE | Dua Saudara | Two Brothers |
| CLUE_SUMARTO_SHOW_1 | Ki Sumarto menggelar kelirnya di dekat kemah Hariang Banga, dan kedua tepi menonton. | Ki Sumarto has set up his screen near Hariang Banga's camp, and both banks are watching. |
| CLUE_SUMARTO_SHOW_2 | Lakon malam ini katanya tentang dua saudara. Lontarku bergetar. | Tonight's lakon, he says, is about two brothers. My lontar hums. |
| CLUE_SUMARTO_SHOW_NOTE | Ki Sumarto memainkan lakon dua saudara di tepi penyeberangan. | Ki Sumarto plays the lakon of two brothers at the ford. |
| MEM_K_III_TITLE | Dua Saudara | Two Brothers |
| MEM_K_III_IN | Lakon Ki Sumarto malam ini, Nak, dan aku menonton bersamamu: dua saudara dan satu sungai. | Ki Sumarto's lakon tonight, child, and I watch with you: two brothers and one river. |
| MEM_K_III_1 | Dua saudara berebut satu tanah. Yang sulung ke timur, yang bungsu ke barat, masing-masing membawa pasukan. | Two brothers quarrel over one land. The elder goes east, the younger west, each with an army. |
| MEM_K_III_2 | Si bungsu berdiri di tengah sungai. Dari seberang, kakaknya mengangkat tombak. | The younger stands mid-river. From the far bank his brother raises a spear. |
| MEM_K_III_3 | Si bungsu meletakkan senjatanya di air dan melangkah mundur. Tanah di antara mereka merekah. | The younger lays his weapon in the water and steps back. The land between them splits. |
| MEM_K_III_OUT | Itu pamali, Nak: saudara tak boleh saling menyerang. Sungai ini dinamai dari larangan itu. | That is pamali, child: brothers must not strike each other. This river is named for that rule. |

VERIFY: pamali as a rule among brothers, and the river named for it (codex `pamali`); the lesung women's false-dawn beat.

### Clue `hariang_letters` (step 2.13; the person-boss clue)
| Key | ID | EN |
|-----|----|----|
| CLUE_HARIANG_LETTERS_1 | Surat bertumpuk di meja kemah, semua untuk "Ibu", semua tak terkirim. | Letters pile on the camp table, all addressed to "Mother", none sent. |
| CLUE_HARIANG_LETTERS_2 | Ia menulis tiap malam kepada ibu yang dikurung. Aku tahu rasanya. | He writes every night to a caged mother. I know how that feels. |
| CLUE_HARIANG_LETTERS_NOTE | Surat Hariang Banga untuk ibunya, tak terkirim. | Hariang Banga's letters to his mother, unsent. |

### Beat `ford` (if `!flag:beat_ford`, `flag:mq2_h3`; do `flag:beat_ford`)
| Key | ID | EN |
|-----|----|----|
| BEAT_FORD_1 | Panji-panji di tepi timur. Seorang pemuda mengarungi penyeberangan seorang diri. | Banners on the east bank. A young man wades into the ford alone. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_FORD_2 | Kau ikut mengurung ibuku. Tak akan kukorbankan pasukanku untuk itu. Cukup kau dan aku. | You helped cage my mother. I won't spend my men on that. Just you and me. |
| @NPC_HERO_NAME | | |
| BEAT_FORD_H1 | Aku tak ingin melawanmu. | I don't want to fight you. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_FORD_3 | Aku tahu. Itu yang membuatnya lebih sulit. | I know. That's what makes it harder. |

### Beat `truce` (if `!flag:beat_truce`, `quest:mq2=done`; do `flag:beat_truce`, `codex:pamali`, `codex:roro_jonggrang`, `lakon:roro_jonggrang`, `start:mq3`). Choice 2.
| Key | ID | EN |
|-----|----|----|
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_TRUCE_1 | Cukup. Aku menyerah. | Enough. I yield. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_TRUCE_2 | Hariang Banga. Ciung Wanara. Melawan saudara sendiri itu pamali. Biarlah sungai ini jadi batas kalian: barat, dan timur. | Hariang Banga. Ciung Wanara. To fight your brother is pamali. Let this river be the line between you: west, and east. |
| @ | | |
| BEAT_TRUCE_6 | Tanah di tepi sungai merekah dan bergeser pelan, seperti dalam kisah. Arus memisahkan dua tepi. Seorang prajurit muda berlari menyeberangi dangkalan, menuju pasar. | The bank splits and shifts slowly, as in the legend. The current parts the two sides. A young soldier splashes across the shallows toward the market. |
| @NPC_SAPTO_NAME | | |
| BEAT_TRUCE_7 | Bapak! Aku pulang! | Bapak! I'm home! |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_TRUCE_4 | Timur, kalau begitu. Penulis, jalan ke gua tempat Kala tidur melewati tanahku. Akan kutunjukkan. | East, then. Writer, the road to the cave where Kala sleeps runs through my land. I'll show you. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_TRUCE_5 | Dan orang di kandang itu? Kau yang membawa kami sampai sini. Kau yang bilang. | And the man in the cage? You got us here. You tell me. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_MERCY_1 | Ampuni dia. Ia pun pernah dirampas sesuatu. | Show him mercy. Even he was robbed of something. | `flag:choice_mercy` |
| CHOICE_MERCY_2 | (Diam saja.) | (Say nothing.) | `flag:choice_silent` |

Nagawiru speaks from the water and Ciung Wanara stands on the west bank. Pangrenyep stays caged.


### Camp talk `camp_mataram` (hariang_banga entry; cond `flag:beat_truce`, `zone:kg_pamali`, `!flag:mq3_1`, `"quiet": true`; do `flag:camp_mataram`)
| Key | ID | EN |
|-----|----|----|
| DLG_HARIANG_BANGA_V14 | Ciung memanggilku "kakak" tadi. Pertama kalinya, dan tak ada tombak dalam kalimatnya. | Ciung called me "brother" just now. The first time, and no spear in the sentence. |
| DLG_HARIANG_BANGA_V15 | Rasanya aneh. Hangat, tapi aneh. | It feels odd. Warm, but odd. |
| @NPC_HERO_NAME | | |
| DLG_HARIANG_BANGA_H5 | Lalu, apa selanjutnya? | So, what's next? |
| @NPC_HARIANG_BANGA_NAME | | |
| DLG_HARIANG_BANGA_V16 | Timur menunggu. Ayo. | The East waits. Let's go. |

## 9. Act IV: Tanah Timur (MQ3, "Bilah Tujuh Turunan")
**Lines in this section: 106** (ASSUMED budget: at most 120).
Regional character: Mpu Wirasana (want: to never again forge a blade that eats; turn: the keris he once sharpened; close: the choice). Ally: Hariang Banga. Order of play: the smiths' street, the curse marks, the forge, the widow and the Buto Ijo Hunt, the practice marks and the keris clues, the ash trail, Laras chapter 4, the shrine and the forge memory, the keris, the last fragment and the servant, the Hunter.

### Chapter 1: The Smiths' Road (3.1-3.2)

### timur_daughter (the smiths' street; name NPC_TIMUR_DAUGHTER_NAME; new). The arrival slice (3.1)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq3=active`, `!flag:mq3_a1` | `codex:pamor` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_TIMUR_DAUGHTER_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_V1 | Lihat bilah ini? Besi dan baja dilipat puluhan kali, sampai pola seperti awan muncul. Itu pamor. | See this blade? Iron and steel folded dozens of times, until a cloud-like pattern shows. That's pamor. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_H1 | Ayahmu seorang empu, pembuat keris? | Is your father an empu, a keris maker? |
| 1 | @NPC_TIMUR_DAUGHTER_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_V2 | Pembuat keris, ya. Mpu Wirasana, di bengkel ujung jalan. Ayah bilang tiap bilah ingat untuk apa ia ditempa. | A keris maker, yes. Mpu Wirasana, at the forge down the road. Father says every blade remembers what it was made for. |
| 1 | DLG_TIMUR_DAUGHTER_V3 | Tapi tanda merah di pintu-pintu itu baru muncul pagi ini, dan Ayah tak suka. | But those red marks on the doors appeared this morning, and Father doesn't like them. |
| 2 | DLG_TIMUR_DAUGHTER_V4 | Hati-hati dengan tanda merah itu. Jangan disentuh. | Careful with those red marks. Don't touch them. |

VERIFY: pamor (the layered pattern of a keris blade), empu as keris master.

### Beat `marks_hook` (if `!flag:beat_marks_hook`, `flag:mq3_h1`; do `flag:beat_marks_hook`). K5 hook. Area `timur_marks` sets `mq3_h1`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_MARKS_HOOK_1 | Di tiang-tiang pintu, tanda merah terbakar seperti luka. Tiap tanda berdenyut pelan. | On the doorposts, red marks burn like wounds. Each one pulses slowly. |
| BEAT_MARKS_HOOK_2 | Di bawah tiap tanda, penghuni rumah duduk diam, menatap lantai. | Under each mark, the household sits still, staring at the floor. |
| @NPC_HERO_NAME | | |
| BEAT_MARKS_HOOK_H1 | Tanda kutukan. Siapa yang membakar ini? | Curse marks. Who burned these? |

### timur_empu (Mpu Wirasana; replace the main-path entries, keep the SQ-T3 entries)
| Entry | if | do |
|-------|----|----|
| 3 | `step:mq3=1` (3.2) | |
| (keep) | the SQ-T3 offer (`quest:sq_t3=available`) and turn-in (`step:sq_t3=2`) | |
| 1 | `flag:choice_reforge` | |
| 2 | `flag:choice_sink` | |
| 4 | `step:mq3=2` | |
| 5 | `step:mq3=5` | |
| (keep) | the SQ-T3 reminder (`quest:sq_t3=active`) and the current fallback | |

Runtime order is the row order above (fixed 2026-11-06): the SQ-T3 offer and turn-in come before the main-path nudges and the choice lines, so they are never hidden behind them. Entry numbers name the text rows below.

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_TIMUR_EMPU_V8 | Kau membawanya kembali. Kali ini kutempa jadi bilah yang melindungi. | You brought it back. This time I'll forge it into a blade that protects. |
| 2 | DLG_TIMUR_EMPU_V9 | Sungai yang menyimpannya. Mungkin itu lebih baik. | The river has it. Maybe that's kinder. |
| 3 | DLG_TIMUR_EMPU_V1 | Berhenti di ambang. Panas bengkel ini membuat orang jujur, jadi katakan: kau pandai, atau cuma nekat? | Stop at the door. This forge heat makes men honest, so tell me: clever, or just stubborn? |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_TIMUR_EMPU_H1 | Aku mencari pemburu bertopeng, dan keris yang katanya bangun lagi. | I'm after a masked hunter, and a keris they say has woken. |
| 3 | @NPC_TIMUR_EMPU_NAME | | |
| 3 | DLG_TIMUR_EMPU_V2 | Keris itu... aku sendiri yang mengasahnya, tujuh turunan lalu, atas perintah yang tak bisa kutolak. Setiap bilah ingat untuk apa ia ditempa. Yang itu ditempa untuk menelan. | That keris... I sharpened it myself, seven generations ago, on an order I couldn't refuse. Every blade remembers what it was made for. That one was made to swallow. |
| 3 | DLG_TIMUR_EMPU_V3 | Ditenangkan, bukan dikalahkan. Ia menandai korbannya dengan kutukan, dan aksara mematahkannya. Berlatihlah di tonggakku. Tapi temui dulu sang janda di sungai; putrinya dikejar sesuatu yang lebih nyata. | Calmed, not beaten. It marks its victims with curses, and aksara break them. Practise on my stakes. But see the widow by the river first; her girl is being chased by something more urgent. |
| 4 | DLG_TIMUR_EMPU_V6 | Sang janda, di tepi sungai. Pergilah. | The widow, by the river. Go on. |
| 5 | DLG_TIMUR_EMPU_V7 | Dua tanda. Patahkan, dan kau siap ke candi. | Two marks. Break them, and you're ready for the shrine. |

### Chapter 2: Timun Mas (3.3-3.6)

### mbok_srini (the widow; replace the entries' text, keep their `if` and `do`; name NPC_MBOK_SRINI_NAME)
| Entry (`if`) | Key | ID | EN |
|-------|-----|----|----|
| `step:mq3=2` (3.3) | DLG_MBOK_SRINI_V1 | Timun Masku, putriku! Raksasa itu, Buto Ijo, menghancurkan pondokku dan mengejarnya ke ladang timur. Kakiku sudah tak sanggup. | My Timun Mas, my daughter! That giant, Buto Ijo, smashed my hut and chased her to the eastern field. My legs have given out. |
| `step:mq3=2` | @NPC_HERO_NAME | | |
| `step:mq3=2` | DLG_MBOK_SRINI_H1 | Sejak kapan, Mbok? | Since when, Mbok? |
| `step:mq3=2` | @NPC_MBOK_SRINI_NAME | | |
| `step:mq3=2` | DLG_MBOK_SRINI_2 (keep) | Bawalah empat kantong ini: biji timun, jarum, garam, dan terasi. | Take these four pouches: cucumber seeds, needles, salt and terasi, the shrimp paste. |
| `step:mq3=2` | @NPC_HERO_NAME | | |
| `step:mq3=2` | DLG_MBOK_SRINI_H2 | Seperti dongeng. | Like the tale. |
| `step:mq3=2` | @NPC_MBOK_SRINI_NAME | | |
| `step:mq3=2` | DLG_MBOK_SRINI_V2 | Dongeng ditulis oleh yang berhasil lolos. Lempar satu per satu saat ia dekat. Ladang timur, Nak, cepat! | Tales are written by the ones who got away. Throw them one by one when he's close. The eastern field, child, quickly! |
| `flag:mq3_4` | DLG_MBOK_SRINI_5 (keep), DLG_MBOK_SRINI_6 (keep) | | |
| `step:mq3=1` | DLG_MBOK_SRINI_7 (keep) | | |
| `quest:mq3=active` | DLG_MBOK_SRINI_V4 | Ladang timur, Nak! Sebelum ia tertangkap! | The eastern field, child! Before he catches her! |
| (none) | DLG_MBOK_SRINI_8 (keep) | | |

The four pouches are what the clues below confirm; the widow's talk is the K4 hook (her hut smashed open, footprints as long as you are tall).

### Hunt K4: Buto Ijo (3.3-3.5)
| Key | ID | EN |
|-----|----|----|
| HUNT_K4_TITLE | Buto Ijo | Buto Ijo |
| CLUE_SEEDS_1 | Biji timun tumpah sepanjang jalan setapak dari pondok yang hancur. | Cucumber seeds spilled along the path from the smashed hut. |
| CLUE_SEEDS_2 | Seseorang menaburnya sambil berlari. | Someone scattered them while running. |
| CLUE_SEEDS_NOTE | Biji timun tumpah di jalan dari pondok. | Cucumber seeds spilled on the path from the hut. |
| CLUE_NEEDLE_CASE_1 | Tempat jarum dari bambu, kosong. Jarumnya hilang. | A bamboo needle case, empty. The needles are gone. |
| CLUE_NEEDLE_CASE_2 | Si pelari membawa bekal. Siapa pun dia, dia bersiap. | The runner carried supplies. Whoever she is, she was ready. |
| CLUE_NEEDLE_CASE_NOTE | Tempat jarum bambu yang kosong. | An empty bamboo needle case. |
| CLUE_SALT_TERASI_1 | Toples garam dan periuk terasi, pasta udang, tutupnya terbuka, di batu pinggir sungai. | A salt jar and a pot of terasi, shrimp paste, lids off, on a stone by the river. |
| CLUE_SALT_TERASI_2 | Empat bekal: biji, jarum, garam, terasi. Persis seperti dalam dongeng. | Four supplies: seeds, needles, salt, terasi. Just like the tale. |
| CLUE_SALT_TERASI_NOTE | Bekal Timun Mas: biji, jarum, garam, terasi. | Timun Mas's supplies: seeds, needles, salt, terasi. |

### Memory `k4_timun_mas` (play; K4, step 3.4; kelir figure: Timun Mas; the action throws a pouch as the giant closes in)
| Key | ID | EN |
|-----|----|----|
| MEM_K4_TIMUN_MAS_TITLE | Timun Mas | Timun Mas |
| MEM_K4_TIMUN_MAS_IN | Kau Timun Mas sekarang, Nak: gadis yang dijanjikan pada seorang raksasa. Lari, dan lempar kantongmu. | You are Timun Mas now, child: the girl promised to a giant. Run, and throw your pouches. |
| MEM_K4_TIMUN_MAS_HINT | Lempar saat dekat | Throw when close |
| MEM_K4_TIMUN_MAS_1 | Biji timun menjadi semak berduri. Sang raksasa merobek jalannya. | The seeds become brambles. The giant tears his way through. |
| MEM_K4_TIMUN_MAS_2 | Jarum menjadi rimbun bambu. Garam menjadi laut. Ia terus mendekat. | The needles become a bamboo thicket. The salt becomes a sea. He keeps coming. |
| MEM_K4_TIMUN_MAS_3 | Terasi menjadi lumpur. Sang raksasa terperosok, dan gadis itu berlari ke arah fajar. | The terasi becomes mud. The giant sinks, and the girl runs toward the dawn. |
| MEM_K4_TIMUN_MAS_OUT | Pancing dia lewat ladang kantongmu, Nak. Jangan melempar sembarangan: lempar saat dia dekat. | Lure him through your pouch fields, child. Don't throw wildly: throw when he's close. |
| HINT_BUTO_IJO | Pancing lewat kantong | Lure through pouches |

### Beat `buto_after` (if `!flag:beat_buto_after`, `flag:mq3_4`; do `flag:beat_buto_after`). K4 aftermath
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_BUTO_AFTER_1 | Buto Ijo roboh. Di matanya, merah kutukan seperti tanda di tiang pintu perlahan padam. | Buto Ijo goes down. In his eyes the red of the curse, like the marks on the doorposts, slowly fades. |
| BEAT_BUTO_AFTER_2 | Sang janda memeluk putrinya, Timun Mas, yang berlumur lumpur dan tertawa. | The widow holds her daughter Timun Mas, muddy and laughing. |
| @NPC_HERO_NAME | | |
| BEAT_BUTO_AFTER_H1 | Kutukan yang sama. Seseorang membuat yang besar jadi buas. Aku harus belajar mematahkannya, di tempat Mpu Wirasana. | The same curse. Someone made a big thing wild. I need to learn to break it, at Mpu Wirasana's. |

### Clues K5 (step 3.6; `forge_stone` is at the desert shrine, step 3.9, and starts `k5_forge`)
The two practice marks Wirasana's stakes hold set `flag:clue_practice_marks` (no lines).
| Key | ID | EN |
|-----|----|----|
| HUNT_K5_TITLE | Keris Terkutuk | The Cursed Keris |
| CLUE_SCABBARD_1 | Sarung keris yang patah, kayunya hangus dan tergores. Sesuatu dicabut darinya dengan marah. | A broken keris scabbard, the wood charred and gouged. Something was drawn from it in anger. |
| CLUE_SCABBARD_2 | Apa pun isinya, kini ia berjalan sendiri. | Whatever it held now walks on its own. |
| CLUE_SCABBARD_NOTE | Sarung keris patah, hangus dan tergores. | A broken keris scabbard, charred and gouged. |
| CLUE_FORGE_RECORDS_1 | Catatan tempa Mpu Wirasana: tujuh nama berderet, tujuh turunan, semua mengasah satu bilah. | Mpu Wirasana's forge records: seven names in a row, seven generations, all sharpening one blade. |
| CLUE_FORGE_RECORDS_2 | Yang terakhir: Wirasana. Di sampingnya tertulis: "tak bisa menolak". | The last: Wirasana. Beside it: "could not refuse". |
| CLUE_FORGE_RECORDS_NOTE | Tujuh turunan empu mengasah satu keris; yang terakhir Wirasana. | Seven generations of smiths sharpened one keris; the last was Wirasana. |
| CLUE_PRACTICE_MARKS_NOTE | Tanda latihan di tonggak Wirasana meniru kutukan sang keris. | The practice marks on Wirasana's stakes copy the keris's curse. |

### Chapter 3: Sand and Shrine (3.7-3.9)
| Key | ID | EN |
|-----|----|----|
| DLG_ASH_TRAIL_H1 | Jejak abu di pasir, hitam seperti api yang padam. Si Pemburu lewat sini. | Ash on the sand, black as a burnt-out fire. The Hunter came this way. |

### Camp talk `camp_timur` (hariang_banga entry 3; cond `flag:mq3_6`, `zone:tt_pasir`, `"quiet": true`; do `flag:camp_timur`; at `timur_2`. The zone keeps it from replaying in Desa Purwa and Gua Kala; his other entries are in section 10, "Staging NPCs")
| Key | ID | EN |
|-----|----|----|
| DLG_HARIANG_BANGA_V1 | Ini jalan para pedagang garam. Jangan ikuti jejak abu, Penulis. Abu menuntun, tapi tak pernah ke tempat baik. | This is the salt traders' road. Don't follow the ash trail, writer. Ash leads, but never anywhere good. |
| @NPC_HERO_NAME | | |
| DLG_HARIANG_BANGA_H1 | Kenapa kau membantuku? | Why help me? |
| @NPC_HARIANG_BANGA_NAME | | |
| DLG_HARIANG_BANGA_V2 | Ciung dan aku sepakat satu hal: kami tak mau jadi lakon yang diulang. Tidurlah. Candinya di balik bukit itu. | Ciung and I agree on one thing: we won't be a lakon that gets replayed. Sleep. The shrine is behind that hill. |

### Laras chapter LC4 `lc4` (step 3.8; kind chapter; the desert road)
| Key | ID | EN |
|-----|----|----|
| LC_4_TITLE | Wajah Siapa | Whose Face |
| @NPC_LARAS_NAME | | |
| LC4_1 | Aku mencoba menggambar wajah Kak di pasir. Matanya kuingat, mulutnya tidak. | I try to draw Kak's face in the sand. I remember the eyes, not the mouth. |
| LC4_2 | Aku ingat kejar-kejaran dan kata "kakak". Dan Kak kalah. Itu juga kuingat, hehe. | I remember the tag game and the word "kakak". And that you lost. I remember that too, hehe. |
| LC4_3 | Angin menghapus Ka-ku. Tidak boleh. Kutulis lagi, lebih dalam. | The wind wipes out my Ka. No way. I write it again, deeper. |
| LC4_4 | Kak... wajahmu tak bisa kulihat lagi, hanya bayangan. Di lontarku tinggal satu huruf: Ka. Kugenggam erat-erat. Jangan terlambat. | Kak... I can't see your face anymore, only a shape. One letter is left on my half: Ka. I'm holding it tight. Don't be late. |

### Clue `forge_stone` and memory `k5_forge` (step 3.9; K5, kind play; kelir figure: the smith's apprentice; the action douses a curse mark)
| Key | ID | EN |
|-----|----|----|
| CLUE_FORGE_STONE_1 | Batu landasan tua di pelataran candi, retak dan hitam. Di sini keris itu ditempa. | An old anvil stone in the shrine court, cracked and black. The keris was forged here. |
| CLUE_FORGE_STONE_2 | Lontarku menarikku kembali ke masa ketika bengkel ini masih berdentang. | My lontar pulls me back to when this forge still rang. |
| CLUE_FORGE_STONE_NOTE | Batu landasan tua di candi gurun, tempat keris ditempa. | The old anvil stone at the desert shrine, where the keris was forged. |
| MEM_K5_FORGE_TITLE | Bengkel Tua | The Old Forge |
| MEM_K5_FORGE_IN | Ini bengkel Mpu Gandring, empu yang membuat keris itu, Nak. Kau muridnya. Jangan sampai terbakar. | This is Mpu Gandring's forge, the smith who made that keris, child. You are his apprentice. Don't get burned. |
| MEM_K5_FORGE_HINT | Padamkan tanda kutuk | Douse the curse marks |
| MEM_K5_FORGE_1 | Seorang pemuda datang meminta keris itu sebelum selesai. Sang empu menolak: sedikit lagi. | A young man comes for the keris before it is finished. The smith refuses: a little longer. |
| MEM_K5_FORGE_2 | Pemuda itu merebutnya. Sang empu mengucap kutuk yang lebih terasa daripada terdengar. Lampu bengkel meredup. | The young man snatches it. The smith speaks a curse you feel more than hear. The forge light dims. |
| MEM_K5_FORGE_3 | Tanda merah menyebar di lantai bengkel. Padamkan sebelum bertemu satu sama lain. | Red marks spread across the forge floor. Douse them before they join. |
| MEM_K5_FORGE_OUT | Begitulah kutuk itu lahir, Nak. Padamkan tandanya sebelum menyatu, dan kerisnya tenang. | That is how the curse was born, child. Douse the marks before they join, and the keris quiets. |
| HINT_KERIS | Padamkan tanda kutuk | Douse the curse marks |

VERIFY: the Mpu Gandring tale (an unfinished keris and the smith's curse) as told here; the legend's figures are named only in the codex and in the memory's Semar line.

### Beat `shrine_sight` (if `!flag:beat_shrine_sight`, `flag:mq3_h5`, `flag:mq3_lc`, `zone:tt_candi`; do `flag:beat_shrine_sight`). The turn.
| Key | ID | EN |
|-----|----|----|
| BEAT_SHRINE_SIGHT_1 | Di seberang pelataran candi, kecil sekali di bawah arca-arca: Laras. | Across the shrine court, small beneath the statues: Laras. |
| @NPC_HERO_NAME | | |
| BEAT_SHRINE_SIGHT_H1 | Laras! | Laras! |
| @ | | |
| BEAT_SHRINE_SIGHT_2 | Ia tidak menoleh. Ia membaca dari lontar yang sangat tua, pelan, dan Si Tanpa Ngaran menarik keris dari sarungnya. | She doesn't turn. She reads from a very old lontar, slowly, and the Nameless Hunter draws a keris from its sheath. |
| BEAT_SHRINE_SIGHT_3 | Keris itu bangun, dan seluruh candi berdengung seperti lonceng yang dipukul dari dalam. | The keris wakes, and the whole shrine hums like a bell struck from inside. |

### Beat `keris` (if `!flag:beat_keris`, `flag:mq3_7`; do `flag:beat_keris`). Choice 3.
| Key | ID | EN |
|-----|----|----|
| BEAT_KERIS_1 | Keris itu terdiam di tanganmu. Kutukannya habis terbakar, tinggal besi hangat yang masih ingat untuk apa ia ditempa. | The keris falls quiet in your hand. The curse has burned itself out, leaving warm iron that remembers what it was made for. |
| BEAT_KERIS_2 | Besi bisa ditempa ulang, atau direlakan. | Iron can be forged again, or let go. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_KERIS_1 | Bawa ke sang empu untuk ditempa ulang. | Take it to the empu to reforge. | `flag:choice_reforge`, `give:keris_gandring` |
| CHOICE_KERIS_2 | Serahkan pada sungai. | Give it to the river. | `flag:choice_sink`, `give:batu_kali` |

### Chapter 4: The Nameless One (3.10-3.11)

### Clue `hunter_mask_4` and memory `h4` (step 3.10; H4, kind walk; the prologue raid from Aria's eyes)
| Key | ID | EN |
|-----|----|----|
| CLUE_HUNTER_MASK_4_1 | Pecahan topeng terakhir di ambang candi. Yang paling hangat. | The last mask fragment on the shrine threshold. The warmest one. |
| CLUE_HUNTER_MASK_4_2 | Kali ini aku tahu apa yang akan kulihat: malam penyerbuan. | This time I think I know what I'll see: the night of the raid. |
| CLUE_HUNTER_MASK_4_NOTE | Pecahan topeng terakhir, di ambang candi. | The last mask fragment, on the shrine threshold. |
| MEM_H4_TITLE | Anak yang Salah | Wrong Child |
| MEM_H4_IN | Malam yang sudah kau kenal, Nak, dilihat dari mata yang lain. | A night you already know, child, seen through other eyes. |
| MEM_H4_1 | Lampu padam di Desa Purwa. Aria menggenggam tangan seorang gadis kecil yang meronta. | The lamp goes out in Desa Purwa. Aria holds the hand of a small girl who struggles. |
| MEM_H4_2 | Gadis itu menatap topengnya dan berbisik, "Aria." Lima belas tahun, dan tak seorang pun menyebutnya. | The girl looks at his mask and whispers, "Aria." Fifteen years, and nobody has said it. |
| MEM_H4_3 | Tangannya gemetar. Ia berkata "anak yang salah, tapi yang lebih baik", dan tak tahu apakah ia sungguh bermaksud begitu. | His hand shakes. He says "wrong child, a better one", and doesn't know if he means it. |
| MEM_H4_OUT | Sekarang kau tahu apa arti "yang lebih baik", Nak. | Now you know what "a better one" meant, child. |

### Clue `mask_joined` and memory `k6_servant` (step 3.10; K6, kind walk, about 2 minutes, no mechanic; the joined mask at the shrine door, cond `flag:mq3_h7`)
| Key | ID | EN |
|-----|----|----|
| HUNT_K6_TITLE | Si Tanpa Ngaran | The Nameless One |
| CLUE_MASK_JOINED_1 | Semua pecahan menyatu di tanganku menjadi satu topeng, retak di tengah. | All the fragments join in my hands into one mask, cracked down the middle. |
| CLUE_MASK_JOINED_2 | Topengnya kosong. Tapi lontarku menarik, seperti ingin dipakai. | The mask is empty. But my lontar pulls, as if it wants to be worn. |
| CLUE_MASK_JOINED_NOTE | Pecahan-pecahan menyatu menjadi satu topeng retak. | The fragments join into one cracked mask. |
| MEM_K6_SERVANT_TITLE | Sang Abdi | The Servant |
| MEM_K6_SERVANT_IN | Kisah utuhnya, Nak, dari awal sampai topeng. Jangan ada yang terlewat. | The whole tale, child, from the start to the mask. Don't miss a piece. |
| MEM_K6_SERVANT_1 | Aria kecil menyapu balairung, dan sang raja menyebut namanya dengan baik. | Young Aria sweeps the hall, and the king says his name kindly. |
| MEM_K6_SERVANT_2 | Aria dewasa menatap cermin, dan wajah raja menatap balik. | Grown Aria stares into the mirror, and the king's face stares back. |
| MEM_K6_SERVANT_3 | Aria menyerahkan namanya pada bayangan di sudut. Tak ada yang menyebutnya lagi. | Aria gives his name to the shadow in the corner. Nobody says it again. |
| MEM_K6_SERVANT_4 | Bertahun-tahun topeng itu berjalan tanpa nama, sampai seorang gadis berbisik "Aria". | For years the mask walks without a name, until a girl whispers "Aria". |
| MEM_K6_SERVANT_OUT | Begitulah dia, Nak. Bukan hantu. Seorang pelayan yang ingin dipanggil namanya. | That is him, child. Not a ghost. A servant who wanted to be called by his name. |

### Beat `hunter_shrine` (if `!flag:beat_hunter_shrine`, `flag:mq3_h6`; do `flag:beat_hunter_shrine`, `restore`)
The Hunter boss's cond is `flag:mq3_h6`. He says nothing here.
| Key | ID | EN |
|-----|----|----|
| BEAT_HUNTER_SHRINE_1 | Di belakangmu, bayangan candi berdiri. Ia tidak berkata apa-apa. Ia sudah tak punya apa-apa untuk dikatakan. | Behind you, the shrine's shadow stands up. He says nothing. He has nothing left to say. |

### Beat `hunter_name` (if `!flag:beat_hunter_name`, `quest:mq3=done`; do `flag:beat_hunter_name`, `codex:nameless_hunter`, `start:mq4`, `goto:desa_purwa:from_riders`)
| Key | ID | EN |
|-----|----|----|
| BEAT_HUNTER_NAME_1 | Topeng itu retak di tengah. Di baliknya, wajah seorang pemuda: wajah yang dulu dipakai raja palsu. | The mask cracks down the middle. Under it, a young man's face: the face the false king once wore. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_NAME_H1 | Aria Kebonan. Itu namamu. Ambil kembali. | Aria Kebonan. That is your name. Take it back. |
| @ | | |
| BEAT_HUNTER_NAME_3 | Lalu langit padam. Tepi matahari menghitam, dan Laras, di ujung pelataran, lenyap di tengah satu kata. | Then the sky goes out. The sun's rim turns black, and Laras, at the far end of the court, vanishes mid-word. |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_NAME_5 | Aria. Dulu aku tahu nama itu. Dia pergi ke tempat yang kutuju. | Aria. I knew that name, once. She's gone where I was going. |
| @ | | |
| BEAT_HUNTER_NAME_6 | Ia luntur seperti tinta kena hujan. Ikatan lontarnya pecah, nama-nama terbang pulang, kecuali namanya. Di kandang Galuh, seorang tua mendapat wajahnya kembali. | He runs like ink in rain. His bundle bursts and the names fly home, all but hers. In Galuh's cage, an old man gets his face back. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_HUNTER_NAME_4 | Naik. Kuda kami membawamu pulang sebelum kabut menutup jalan. Gua Kala ada di belakang desamu. | Up. Our horses carry you home before the fog closes the road. Kala's cave is behind your village. |


## 10. Interlude, Act V and Act VI (MQ4, MQ5)
**Lines in this section: 191** (ASSUMED budget: at most 220).
The Interlude is quiet and has no combat: the village forgets its own names, you write them back, Ibu sees three of Laras's things, the brothers eat at one table, and Semar says why he remembers. Act V is the sea: the forgotten song, the cliff, Laras on the water, the Trial. Act VI is the cave: three memories of the prologue day, Murwakala, Laras at the bottom of the dark, the Ruwatan of Dawn and the name.

### Interlude "Rumah yang Sunyi" (4.1-4.5, about 25 minutes, no combat)

### Beat `eclipse_home` (if `!flag:beat_eclipse_home`, `step:mq4=0`, `zone:desa_purwa`; do `flag:beat_eclipse_home`). 4.1
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_ECLIPSE_HOME_1 | Gerhana menggantung di atas Desa Purwa. Tak ada bayangan, dan tak ada yang menyapa sesama dengan nama. | The Eclipse hangs over Desa Purwa. No shadows, and nobody greets a neighbour by name. |
| BEAT_ECLIPSE_HOME_2 | Di belakang desa, kabut di mulut gua memakan setiap huruf yang kau lempar kepadanya. | Behind the village, the fog at the cave mouth eats every glyph you throw at it. |

### door_a, door_b, door_c (three houses; name NPC_DOOR_NEIGHBOUR_NAME; new). Step 4.2: a write card each
Each entry 1 runs the write card (glyph ids **ASSUMED**: door_a `sunda_ka,sunda_ga`, door_b `sunda_nga,sunda_ca`, door_c `jawa_ha,jawa_na`). The hero knows his neighbours; they have lost their own names.
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq4=1`, `!flag:name_door_x` | `write:door_x:...`, `flag:name_door_x` (x is a, b or c) |
| 2 | (none) | |

| Key | ID | EN |
|-----|----|----|
| NPC_DOOR_NEIGHBOUR_NAME | Tetangga | A neighbour |
| NPC_DOOR_NEIGHBOUR_WHO | Tetangga. Lupa namanya sendiri. | A neighbour. Forgot their own name. |
| @NPC_DOOR_NEIGHBOUR_NAME | | |
| DLG_DOOR_A_V1 | Kami... keluarga siapa, ya? Pintu ini tak mau mengenal kami. | We're... whose family, again? This door won't know us. |
| @NPC_HERO_NAME | | |
| DLG_DOOR_A_H1 | Keluarga Eman. Kau menjual gula merah dan selalu menambahkan satu bonus. | The Eman family. You sell palm sugar and always add one extra. |
| @NPC_DOOR_NEIGHBOUR_NAME | | |
| DLG_DOOR_A_V2 | Eman! Ya! Tolong tuliskan di tiang pintu, supaya rumah ini ingat. | Eman! Yes! Please write it on the doorpost, so the house remembers. |
| DLG_DOOR_A_V3 | Namaku kembali, Nak. Terima kasih. | My name's back, child. Thank you. |
| @NPC_DOOR_NEIGHBOUR_NAME | | |
| DLG_DOOR_B_V1 | Ada nama di ujung lidahku, tapi ia lari setiap kali kukejar. | There's a name on the tip of my tongue, but it runs every time I chase it. |
| @NPC_HERO_NAME | | |
| DLG_DOOR_B_H1 | Keluarga Karsih. Kau selalu menjemur ikan asin paling wangi di desa. | The Karsih family. You dry the best-smelling salt fish in the village. |
| @NPC_DOOR_NEIGHBOUR_NAME | | |
| DLG_DOOR_B_V2 | Karsih! Ikan asinku! Tuliskan, tolong, sebelum lupa lagi. | Karsih! My salt fish! Write it, please, before I forget again. |
| DLG_DOOR_B_V3 | Karsih. Rasanya seperti pulang ke tubuh sendiri. | Karsih. It feels like coming back into my own body. |
| @NPC_DOOR_NEIGHBOUR_NAME | | |
| DLG_DOOR_C_V1 | Anak-anakku bertanya siapa kami. Aku tak bisa menjawab. | My children ask who we are. I can't answer. |
| @NPC_HERO_NAME | | |
| DLG_DOOR_C_H1 | Keluarga Dulah. Anak-anakmu yang paling berisik di desa ini. | The Dulah family. Your children are the loudest in the village. |
| @NPC_DOOR_NEIGHBOUR_NAME | | |
| DLG_DOOR_C_V2 | Dulah! Ya, ya. Tuliskan di pintu, supaya mereka tahu mereka punya rumah. | Dulah! Yes, yes. Write it on the door, so they know they have a home. |
| DLG_DOOR_C_V3 | Dulah. Anak-anak, kita punya nama lagi! | Dulah. Children, we have a name again! |

### ibu, the Interlude (entries 2 and 3 of the table in section 5)
| Entry | if | do |
|-------|----|----|
| 2 | `step:mq4=2`, `item:laras_ribbon,item:laras_board,item:laras_strip_ka` (4.3; sets `mq4_2`) | |
| 3 | `step:mq4=2` (`"quiet": true`; no items yet) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_IBU_H5 | Bu, lihat. Pita, sebuah papan, dan selembar lontar. Semuanya milik seseorang. | Ibu, look. A ribbon, a board, a strip of lontar. They all belong to someone. |
| 2 | @NPC_IBU_NAME | | |
| 2 | DLG_IBU_V12 | Pita ini... Ibu pernah mengikatnya di rambut seseorang. | This ribbon... I once tied it in someone's hair. |
| 2 | DLG_IBU_V13 | Papan ini tertulis: "Jangan buang cangkirku yang gompal." Ibu tidak membuangnya, kan? | This board says: "Don't throw out my chipped cup." I never threw it out, did I? |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_IBU_H6 | Tidak, Bu. Ibu tidak pernah membuangnya. | No, Ibu. You never did. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_IBU_H3 | Ibu menangis. | Ibu, you're crying. |
| 3 | @NPC_IBU_NAME | | |
| 3 | DLG_IBU_V10 | Masa? Asap dapur, mungkin. Tiap pagi begini, Nak, dan Ibu tak tahu kenapa. | Am I? Kitchen smoke, maybe. Every morning like this, child, and I don't know why. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_IBU_H4 | Aku tahu kenapa. Akan kuceritakan setelah dia pulang. | I know why. I'll tell you once she's home. |
| 3 | @NPC_IBU_NAME | | |
| 3 | DLG_IBU_V11 | Siapa pun dia, bawa pulang. Bawa sesuatu yang pernah ia sentuh, Ibu ingin melihatnya. | Whoever she is, bring her home. Bring something she touched, I'd like to see it. |

### Beat `ibu_cups` (if `!flag:beat_ibu_cups`, `flag:mq4_2`; do `flag:beat_ibu_cups`). 4.3, the second beat
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_IBU_CUPS_1 | Ibu menuang teh ke cangkir yang gompal, lalu menunggu seseorang duduk. Tak ada yang duduk. Ia tersenyum juga. | Ibu pours tea into the chipped cup, then waits for someone to sit. Nobody sits. She smiles anyway. |
| @NPC_HERO_NAME | | |
| BEAT_IBU_CUPS_H1 | Dia akan duduk di situ lagi, Bu. Aku janji. | She'll sit there again, Ibu. I promise. |

### Beat `table_dishes` (if `!flag:beat_table_dishes`, `flag:mq4_i3`; do `flag:beat_table_dishes`; listed before `quiet_house`). 4.4, the playable dinner: pass dishes, choose a seat (flavour only)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_TABLE_DISHES_1 | Ibu menghidangkan nasi dan sambal. Ciung Wanara dan Hariang Banga masing-masing menunggu yang lain duduk dulu. | Ibu serves rice and sambal. Ciung Wanara and Hariang Banga each wait for the other to sit first. |
| BEAT_TABLE_DISHES_2 | Dua kursi tersisa: satu di samping Ciung, satu di samping Hariang. | Two seats are left: one beside Ciung, one beside Hariang. |
| CHOICE_SEAT_1 | Duduk di samping Ciung. | Sit beside Ciung. |
| CHOICE_SEAT_2 | Duduk di samping Hariang. | Sit beside Hariang. |

Choices: CHOICE_SEAT_1 does `flag:seat_ciung`, CHOICE_SEAT_2 does `flag:seat_hariang`. Neither is a stake; the `quiet_house` beat plays right after either.

### Beat `quiet_house` (if `!flag:beat_quiet_house`, `flag:beat_table_dishes`, `flag:choice_mercy`; do `flag:beat_quiet_house`). Semar's closing line moved to step 4.5
| Key | ID | EN |
|-----|----|----|
| BEAT_QUIET_HOUSE_1 | Di meja ibumu, dua cangkir dan dua pemuda yang menolak duduk di kursi yang sama. Ciung Wanara dari tepi barat, Hariang Banga dari timur, bertemu sebagai saudara untuk pertama kali. | At your mother's table, two cups and two young men who refuse the same chair. Ciung Wanara from the west bank, Hariang Banga from the east, meeting as brothers for the first time. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_QUIET_HOUSE_2 | Kandangnya sekarang punya lampu. Kecil. Dia tak minta lebih. | The cage has a lamp now. A small one. He doesn't ask for more. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_QUIET_HOUSE_3 | Terima kasih. | Thank you. |
| @ | | |
| BEAT_QUIET_HOUSE_4 | Di perapian, topeng kosong tergeletak di antara bara. Tak ada yang menyentuhnya. | In the hearth, an empty mask lies among the embers. Nobody touches it. |

### Beat `quiet_house_silent` (if `!flag:beat_quiet_house`, `flag:beat_table_dishes`, `flag:choice_silent`; do `flag:beat_quiet_house`)
| Key | ID | EN |
|-----|----|----|
| BEAT_QUIET_HOUSE_1 | (same as above) | (same as above) |
| BEAT_QUIET_HOUSE_S2 | Ciung menatap api, bukan kau. Kandang di Galuh tak disebut siapa pun. | Ciung watches the fire, not you. Nobody mentions the cage in Galuh. |
| BEAT_QUIET_HOUSE_4 | (same as above) | (same as above) |

### semar, the Interlude talk (entry 9 of the table in section 5; step 4.5, sets `mq4_i5`, opens the south exit)
| Entry | Key | ID | EN |
|-------|-----|----|----|
| 9 | @NPC_SEMAR_NAME | | |
| 9 | DLG_SEMAR_V35 | Kau heran kenapa aku masih ingat, hehe. Aku bukan dari desa ini, Nak. | You wonder why I still remember, hehe. I'm not from this village, child. |
| 9 | @NPC_HERO_NAME | | |
| 9 | DLG_SEMAR_H35 | Lalu kau siapa sebenarnya? | Then who are you, really? |
| 9 | @NPC_SEMAR_NAME | | |
| 9 | DLG_SEMAR_V36 | Dalam kisah wayang, aku dewa yang memilih hidup sebagai abdi. Dewa sulit dibuat lupa, dan aku keras kepala. | In the wayang tales, I'm a god who chose to live as a servant. Gods are hard to make forget, and I'm stubborn. |
| 9 | DLG_SEMAR_V37 | Ada yang lebih tua dari Kala: laut. Laut tak pernah lupa. Pergilah ke selatan. | Something is older than Kala: the sea. The sea does not forget. Go south. |

VERIFY: Semar as a god who chose to live as a servant (Batara Ismaya in Javanese and Sundanese wayang).

### aria_kebonan (by the burned stage; name NPC_ARIA_KEBONAN_NAME; new; optional, `"quiet": true`, never a step)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq4=4`, `!flag:aria_talk` (4.5) | `flag:aria_talk` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_ARIA_KEBONAN_NAME | | |
| 1 | DLG_ARIA_KEBONAN_V1 | Wajahku kembali, tapi namaku tinggal bunyi tanpa arti. Kala tidur di jantung gua, di balik Jurang Lupa. | My face is back, but my name is a sound without meaning. Kala sleeps at the cave's heart, past the Abyss of Forgetting. |
| 1 | DLG_ARIA_KEBONAN_V2 | Sebutlah namaku sekali saja, kalau kau bersedia. | Say my name once, if you will. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_ARIA_KEBONAN_H1 | Aria Kebonan. | Aria Kebonan. |
| 1 | @NPC_ARIA_KEBONAN_NAME | | |
| 1 | DLG_ARIA_KEBONAN_V3 | Terima kasih. Sudah lama sekali. | Thank you. It has been so long. |
| 2 | DLG_ARIA_KEBONAN_V4 | Pergilah. Aku akan duduk di sini dan berusaha mengingat. | Go. I'll sit here and try to remember. |

### Act V "Laut Tak Pernah Lupa" (4.6-4.12). Regional character: Mbah Wiryo (want: the sea to say her name; turn: the sea answers; close: a louder answer).

### Chapter 2: The Fishing Village (4.6-4.8)

### kidul_jurukunci (Mbah Wiryo; name NPC_WIRYO_NAME; replace the main-path entries, keep any SQ entries)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq4=done` | |
| 2 | `step:mq4=5` (4.6, after the petilasan `kidul_1`) | `codex:nyi_roro_kidul` |
| 3 | `step:mq4=6` (4.7) | |
| 4 | `quest:mq4=active` | |
| (keep) | SQ entries and the current fallback | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_WIRYO_V6 | Senja tadi kusebut namanya lagi. Hari ini ombak menjawab lebih keras. Mungkin Sumi-ku senang. | I said her name again at dusk. Today the surf answered louder. Maybe my Sumi is glad. |
| 2 | @NPC_WIRYO_NAME | | |
| 2 | DLG_WIRYO_V1 | Berhenti di garis pasang, Nak. Laut ini punya tata krama, dan dia menilai tamu dari cara melangkah. | Stop at the tide line, child. This sea has manners, and it judges a guest by how they walk. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_WIRYO_H1 | Aku mencari suara adikku. Orang di desaku bilang laut tak pernah lupa. | I'm looking for my sister's voice. They say in my village the sea never forgets. |
| 2 | @NPC_WIRYO_NAME | | |
| 2 | DLG_WIRYO_V2 | Laut tak mengembalikan siapa pun. Ia hanya mengingat. Tiap senja kubisikkan nama istriku, Sumi, ke ombak, dan ombak membisikkannya kembali. Empat puluh tahun. | The sea gives nobody back. It only remembers. Every dusk I whisper my wife's name, Sumi, to the surf, and the surf whispers it back. Forty years. |
| 2 | DLG_WIRYO_V3 | Kata orang, Nyi Roro Kidul, ratu laut selatan, menguasai laut ini. Jangan memakai hijau di pantai, jangan menunjuk ombak. Yang pantas boleh lewat karang dan tebing. | They say Nyi Roro Kidul, queen of the southern sea, rules these waters. Don't wear green on the shore, don't point at the waves. The worthy may pass the reef and the cliff. |
| 3 | DLG_WIRYO_V7 | Tiga keluarga, tiga bait. Tanyakan pelan-pelan, Nak. Lupa itu pemalu. | Three families, three verses. Ask gently, child. Forgetting is shy. |
| 4 | DLG_WIRYO_V4 | Karang dulu, lalu tebing. Dan jangan hijau. | The reef first, then the cliff. And no green. |

VERIFY: the green taboo on the southern coast; the juru kunci's role; Nyi Roro Kidul as belief. Told as belief throughout.

### Beat `song_hook` (if `!flag:beat_song_hook`, `flag:mq4_4`; do `flag:beat_song_hook`, `codex:sedekah_laut`). K8 hook and the arrival slice
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SONG_HOOK_1 | Di pantai, para nelayan menambal jala untuk sedekah laut. Mereka mulai bernyanyi, lalu hanya bergumam. Kata-katanya hilang. | On the shore the fishers mend nets for the sea offering. They start to sing, then only hum. The words are gone. |
| @NPC_HERO_NAME | | |
| BEAT_SONG_HOOK_H1 | Lagu itu hilang? Dari siapa aku bisa mendapatkannya? | The song is lost? Who can I get it from? |
| @NPC_WIRYO_NAME | | |
| BEAT_SONG_HOOK_2 | Tiga keluarga memegang tiga bait, tapi lupa bait sendiri. Tanyalah satu per satu, Nak. | Three families hold three verses, but forget their own. Ask them one by one, child. |

VERIFY: the sea offering (sedekah laut, labuhan) and how the village keeps it; the song is the game's.

### Hunt K8: The sea's name (4.7-4.8)
| Key | ID | EN |
|-----|----|----|
| HUNT_K8_TITLE | Nama dari Laut | The Sea's Name |
| CLUE_SONG_1_1 | Keluarga pertama bergumam: "Ombak datang, ombak pergi, nama kami ikut pasang." | The first family hums: "Waves come, waves go, our names ride the tide." |
| CLUE_SONG_1_2 | Bait pertama. Nadanya mereka ingat; katanya kembali setelah kuulangi. | The first verse. They remember the tune; the words came back when I repeated them. |
| CLUE_SONG_1_NOTE | Bait pertama lagu laut. | The first verse of the sea song. |
| CLUE_SONG_2_1 | Keluarga kedua: "Perahu pulang, jala penuh, laut tak lupa siapa kami." | The second family: "Boats come home, nets full, the sea forgets not who we are." |
| CLUE_SONG_2_2 | Seorang nenek menangis di tengah bait. Ia ingat suaminya menyanyikannya. | An old woman cries mid-verse. She remembers her husband singing it. |
| CLUE_SONG_2_NOTE | Bait kedua lagu laut. | The second verse of the sea song. |
| CLUE_SONG_3_1 | Keluarga ketiga, bait terakhir: "Panggil nama ke dalam air, dan air memanggil balik." | The third family, the last verse: "Call a name into the water, and the water calls back." |
| CLUE_SONG_3_2 | Bait terakhir menyebut cara memanggil nama. Mbah Wiryo melakukannya tiap senja. | The last verse tells how to call a name. Mbah Wiryo does it every dusk. |
| CLUE_SONG_3_NOTE | Bait terakhir: memanggil nama ke dalam air. | The last verse: calling a name into the water. |

### Memory `k8_wiryo_wife` (walk; K8, step 4.8; kelir figure: Sumi, Mbah Wiryo's wife; no death shown, the screen fades to light)
| Key | ID | EN |
|-----|----|----|
| MEM_K8_WIRYO_WIFE_TITLE | Istri Mbah Wiryo | Mbah Wiryo's Wife |
| MEM_K8_WIRYO_WIFE_IN | Senja di pantai ini juga, Nak, puluhan tahun lalu. Dengarkan perempuan itu. | Dusk on this same shore, child, long years ago. Listen to the woman. |
| MEM_K8_WIRYO_WIFE_1 | Sumi menuntun suaminya, Wiryo, ke garis pasang di senja yang jingga. | Sumi leads her husband Wiryo to the tide line in an orange dusk. |
| MEM_K8_WIRYO_WIFE_2 | Ia mengajarinya: panggil sebuah nama ke dalam air, pelan, dan air memanggil balik. | She teaches him: call a name into the water, softly, and the water calls back. |
| MEM_K8_WIRYO_WIFE_3 | Ia memanggil namanya sendiri, dan ombak menjawab. Lalu ia melangkah ke cahaya senja, tersenyum, dan layar memutih. | She calls her own name, and the surf answers. Then she steps into the dusk light, smiling, and the screen goes white. |
| MEM_K8_WIRYO_WIFE_OUT | Begitulah Wiryo belajar memanggil, Nak. Sekarang kau pun tahu: panggil nama ke dalam air. | That is how Wiryo learned to call, child. Now you know it too: call a name into the water. |

### Chapter 3: Reef and Cliff (4.9-4.11)

### Memory `k9_queen_south` (walk; K9, step 4.10 at the cliff shrine; one retelling among several, told as belief, no fight, no appearance)
| Key | ID | EN |
|-----|----|----|
| HUNT_K9_TITLE | Ratu di Selatan | The Queen of the South |
| MEM_K9_QUEEN_SOUTH_TITLE | Ratu di Selatan | The Queen of the South |
| MEM_K9_QUEEN_SOUTH_IN | Satu penuturan di antara banyak, Nak. Ki Sumarto menceritakannya begini, dan orang pesisir menceritakannya lain. | One telling among many, child. Ki Sumarto tells it like this, and the coast folk tell it otherwise. |
| MEM_K9_QUEEN_SOUTH_1 | Konon seorang putri disingkirkan dari istananya, berjalan ke laut, dan menjadi ratunya. | They say a princess was cast out of her palace, walked into the sea, and became its queen. |
| MEM_K9_QUEEN_SOUTH_2 | Orang pesisir menghormatinya dan menjauhi warna hijau. Mereka tak takut; mereka tahu tata krama. | The coast folk honour her and keep off green. They aren't afraid; they know manners. |
| MEM_K9_QUEEN_SOUTH_3 | Ada yang bilang ia bukan putri, melainkan laut itu sendiri. Tak ada yang bisa memastikan. | Some say she was never a princess, only the sea itself. Nobody can be sure. |
| MEM_K9_QUEEN_SOUTH_OUT | Percaya atau tidak, Nak, hormatilah. Laut tak butuh pembela, hanya tata krama. | Believe it or not, child, be respectful. The sea needs no defender, only manners. |

VERIFY: Nyi Roro Kidul retellings (a cast-out princess, the sea itself); told as belief, never as fact, never fought.

### Laras chapter LC5 `lc5` (step 4.11; kind chapter; the voice on the water)
| Key | ID | EN |
|-----|----|----|
| LC_5_TITLE | Suara di Atas Air | The Voice on the Water |
| @NPC_LARAS_NAME | | |
| LC5_1 | Gelap sekali di sini. Tapi ada yang memanggil namaku dari air, pelan. | It's so dark here. But something is calling my name from the water, softly. |
| LC5_2 | Bukan orang bertopeng. Bukan Kak. Ini lebih tua, dan baik hati. | Not a masked man. Not Kak. This is older, and kind. |
| LC5_3 | Aku berjalan ke arah suaranya. Kalau ini jebakan, jebakannya sopan sekali. | I walk toward the sound. If it's a trap, it's a very polite one. |
| LC5_4 | Kak? Ini bukan gua. Ini air. Laut masih menyebut namaku. Laut tak lupa, jadi aku tak takut. Datanglah. | Kak? This isn't a cave. It's water. The sea still says my name. The sea doesn't forget, so I'm not afraid. Come. |

### Chapter 4: The Trial of the Waves (4.12)

### Beat `kidul_trial` (if `!flag:beat_kidul_trial`, `flag:mq4_8`; do `flag:beat_kidul_trial`)
| Key | ID | EN |
|-----|----|----|
| BEAT_KIDUL_TRIAL_1 | Ombak ketiga surut, dan air di paviliun berhenti bergerak. Tak ada yang naik dari laut. Hanya hijau, jauh sekali, di seberang batas pasang. | The third wave ebbs, and the water in the pavilion stills. Nothing climbs out of the sea. Only green, very far, beyond the tide line. |
| @NPC_RATU_KIDUL_NAME | | |
| BEAT_KIDUL_TRIAL_2 | Kau tidak melawanku. Ambil aksara Ombak, sang gelombang, dan kainku. Laut mengingat apa yang diberikan kepadanya. | You did not fight me. Take the letter Ombak, the wave, and my cloth. The sea remembers what is given to it. |
| @ | | |
| BEAT_KIDUL_TRIAL_3 | Hijau itu surut seperti napas dihembuskan. Kau membungkuk. Tak ada yang melihat. | The green recedes like a breath let go. You bow. Nobody sees. |

Told as belief; she is never fought or touched. VERIFY the tradition of her trial as portrayed.

### kidul_altar (4.12; name NPC_KIDUL_ALTAR_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq4=11` | `write:ombak:jawa_ka`, `learn:jawa_ka`, `give:kain_hijau` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KIDUL_ALTAR_V1 | Di altar paviliun, sehelai kain hijau terlipat, basah oleh ombak yang tak ada. | On the pavilion altar, a green cloth lies folded, wet from a wave that isn't there. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_KIDUL_ALTAR_H1 | Satu goresan, naik dan turun. Ombak. | One stroke, rising and falling. Ombak. |
| 2 | DLG_KIDUL_ALTAR_V2 | Air masih berbisik di sini. | The water still whispers here. |

### Beat `kidul` (if `!flag:beat_kidul`, `quest:mq4=done`; do `flag:beat_kidul`, `start:mq5`)
| Key | ID | EN |
|-----|----|----|
| @NPC_SEMAR_NAME | | |
| BEAT_KIDUL_1 | Ombak. Satu-satunya huruf yang tak bisa dimakan Gerhana, karena laut menulisnya setiap saat. | Ombak. The one letter the Eclipse can't eat, because the sea writes it every moment. |
| @NPC_HERO_NAME | | |
| BEAT_KIDUL_H1 | Kau bilang laut tak pernah lupa. Kau tahu dari awal? | You said the sea never forgets. Did you know all along? |
| @NPC_SEMAR_NAME | | |
| BEAT_KIDUL_2 | Setengahnya tahu, setengahnya berharap. Pintu gua terbuka dari paviliun ini, dan perisai gerhana Kala retak. Pergilah. | Half knew, half hoped. The cave opens from this pavilion, and Kala's eclipse shield cracks. Go. |



### Camp talk `camp_kidul` (kidul_jurukunci entry; cond `flag:mq4_8`, `zone:sk_pantai`, `!flag:mq5_1`, `"quiet": true`; do `flag:camp_kidul`)
| Key | ID | EN |
|-----|----|----|
| DLG_WIRYO_V21 | Sekarang aku akan mengatakan sesuatu yang lain pada laut, bukan namanya. | Now I'll tell the sea something other than her name. |
| DLG_WIRYO_V22 | Terima kasih. Itu saja. Ia sudah menunggu lama untuk mendengarnya. | Thank you. That's all. It has waited a long time to hear it. |
| DLG_WIRYO_V23 | Pergilah. Di balik paviliun itu, gua menunggumu. | Go. Past the pavilion, the cave waits for you. |

### Act VI: Gua Kala (MQ5, "Ke Rahang Sang Waktu")
The Hunter does not appear in this act. The three letters of her name are held in three memories of the prologue day (section 5), eaten in part by Kala. The player replays each and fills the grey gaps by choosing the right detail (3 gaps per memory, 3 options per gap, **ASSUMED**). A wrong pick flashes the gap grey and changes nothing; no text. The correct detail is the one the prologue day showed. Memory ids `la`, `ra`, `sa`; gap ids as below; each memory starts from a lontar-lit spot at the place named in the step (zone docs place them).

### Chapter 1: The Cave Mouth (5.1-5.2)

### Beat `mouth_freed` (if `!flag:beat_mouth`, `flag:mq5_1`, `flag:choice_freed`; listed first; do `flag:beat_mouth`)
| Key | ID | EN |
|-----|----|----|
| BEAT_MOUTH_1 | Dua panji di mulut gua, satu dari tiap tepi Pamali. Di antaranya, seorang lelaki tanpa topeng, wajahnya baru dan canggung. | Two banners at the cave mouth, one from each bank of the Pamali. Between them a man without a mask, his face new and awkward. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_MOUTH_2 | Masuklah. Apa pun yang keluar dari sana harus lewat kami dulu. | Go on. Whatever comes out of there goes through us first. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_MOUTH_3 | Bawa dia pulang, Penulis. | Bring her home, writer. |
| @NPC_FACELESS_DESERTER_NAME | | |
| BEAT_MOUTH_4 | Namaku belum utuh. Tapi pintu ini bisa kujaga utuh. | My name isn't whole yet. This door I can guard whole. |

### Beat `mouth` (if `!flag:beat_mouth`, `flag:mq5_1`; do `flag:beat_mouth`). Same keys 1-3, no Deserter.

### Gap memory `la` (step 5.1; gap kind; the tag game in the lane)
| Key | ID | EN |
|-----|----|----|
| HUNT_GAP_TITLE | Tiga Huruf Namanya | The Letters of Her Name |
| MEM_GAP_LA_TITLE | Kejar-kejaran | The Tag Game |
| MEM_GAP_LA_IN | Hari itu, Nak, dalam ingatanmu sendiri. Kabut sudah memakan sebagiannya. Isi yang hilang dengan yang kau ingat. | That day, child, in your own memory. The fog has eaten some of it. Fill what's missing with what you remember. |
| MEM_GAP_LA_1 | Kau berlari di lorong, Laras selangkah di depan, tertawa. | You run down the lane, Laras a step ahead, laughing. |
| GAP_LA_CAT_P | Siapa nama kucing yang dipanggil Laras? | What did Laras call the cat? |
| GAP_LA_CAT_1 | Jahe | Jahe |
| GAP_LA_CAT_2 | Kunyit | Kunyit |
| GAP_LA_CAT_3 | Pandan | Pandan |
| GAP_LA_TREE_P | Siapa nama beringin tua yang disapa Laras? | What was the old banyan's name, the one Laras greeted? |
| GAP_LA_TREE_1 | Ki Waringin | Ki Waringin |
| GAP_LA_TREE_2 | Ki Jati | Ki Jati |
| GAP_LA_TREE_3 | Nyai Beringin | Nyai Beringin |
| GAP_LA_END_P | Di mana kau menangkap Laras? | Where did you catch Laras? |
| GAP_LA_END_1 | Di bawah beringin | Under the banyan |
| GAP_LA_END_2 | Di pintu sanggar | At the sanggar door |
| GAP_LA_END_3 | Di dekat sumur | By the well |
| MEM_GAP_LA_OUT | Satu huruf kembali: La, yang pertama dari namanya. | One letter back: La, the first of her name. |

Correct answers (a gap's `correct` key): `GAP_LA_CAT_2` (Kunyit), `GAP_LA_TREE_1` (Ki Waringin), `GAP_LA_END_3` (the well). Gap ids `la_cat`, `la_tree`, `la_end`.

### Chapter 2: The Abyss of Forgetting (5.3-5.4)

### Gap memory `ra` (step 5.3; Ibu's table, two cups)
| Key | ID | EN |
|-----|----|----|
| MEM_GAP_RA_TITLE | Dua Cangkir | Two Cups |
| MEM_GAP_RA_IN | Meja Ibu pagi itu. Kabut menyentuh cangkir-cangkirnya. Ingat baik-baik, Nak. | Ibu's table that morning. The fog has touched the cups. Remember well, child. |
| MEM_GAP_RA_1 | Dua cangkir mengepul di meja, dan tawa Laras terdengar dari halaman. | Two cups steam on the table, and Laras's laugh drifts in from the yard. |
| GAP_RA_CUP_P | Cangkir mana milik Laras? | Which cup was Laras's? |
| GAP_RA_CUP_1 | Yang polos tanpa cacat | The plain, flawless one |
| GAP_RA_CUP_2 | Yang bergambar ikan | The one painted with a fish |
| GAP_RA_CUP_3 | Yang gompal di bibirnya | The one chipped at the rim |
| GAP_RA_TEA_P | Teh apa yang dituang Ibu? | What tea did Ibu pour? |
| GAP_RA_TEA_1 | Teh sereh | Lemongrass tea |
| GAP_RA_TEA_2 | Teh melati | Jasmine tea |
| GAP_RA_TEA_3 | Teh kayu manis | Cinnamon tea |
| GAP_RA_SAY_P | Apa pesan Ibu sebelum kalian pergi? | What did Ibu tell you before you left? |
| GAP_RA_SAY_1 | Pulang sebelum gelap | Home before dark |
| GAP_RA_SAY_2 | Pulang sebelum hujan | Home before the rain |
| GAP_RA_SAY_3 | Pulang sebelum pertunjukan | Home before the show |
| MEM_GAP_RA_OUT | Huruf kedua kembali: Ra. Dua cangkir, dua orang yang dicintai. | The second letter is back: Ra. Two cups, two people loved. |

Correct answers: `GAP_RA_CUP_3` (the chipped one), `GAP_RA_TEA_2` (jasmine), `GAP_RA_SAY_3` (before the show). Gap ids `ra_cup`, `ra_tea`, `ra_say`.

### semar_kala (at `kala_1`; replace both entries' text, keep their `if`)
| Entry | Key | ID | EN |
|-------|-----|----|----|
| `!flag:mq5_3` | DLG_SEMAR_KALA_V1 | Sudah kubilang aku sampai duluan, hehe. Jangan tanya bagaimana. | Told you I'd get here first, hehe. Don't ask how. |
| `!flag:mq5_3` | @NPC_HERO_NAME | | |
| `!flag:mq5_3` | DLG_SEMAR_KALA_H1 | Dua suku kata sudah kembali. Tinggal Sa, dan dia. | Two syllables back. Only Sa left, and him. |
| `!flag:mq5_3` | @NPC_SEMAR_NAME | | |
| `!flag:mq5_3` | DLG_SEMAR_KALA_V2 | Kala tidak jahat, Nak. Dia lapar. Dia memakan yang tak lagi digenggam siapa pun. Maka genggam erat. | Kala isn't wicked, child. He's hungry. He eats what nobody holds on to. So hold on. |
| `!flag:mq5_3` | @NPC_HERO_NAME | | |
| `!flag:mq5_3` | DLG_SEMAR_KALA_H2 | Bagaimana kalau aku yang lupa? | And if I'm the one who forgets? |
| `!flag:mq5_3` | @NPC_SEMAR_NAME | | |
| `!flag:mq5_3` | DLG_SEMAR_KALA_V3 | Kau menulis. Itu bedanya manusia dengan kabut. Tenangkan dia dengan ruwatan fajar: aksara Sunda, lalu Jawa, dan Ombak untuk gerhananya. | You write. That's what separates a person from fog. Calm him with the dawn ruwatan: Sunda letters, then Jawa, and Ombak for the eclipse. |
| (none) | DLG_SEMAR_KALA_V4 | Nah? Tuliskanlah, Nak. | Well? Write it, child. |

### Gap memory `sa` (step 5.4; the sanggar and the lontar)
| Key | ID | EN |
|-----|----|----|
| MEM_GAP_SA_TITLE | Nama-nama yang Ditulis | The Written Names |
| MEM_GAP_SA_IN | Sanggarku hari itu, dan lontar kecil di meja. Isi bagian yang dimakan kabut. | My sanggar that day, and the small lontar on the table. Fill in what the fog ate. |
| MEM_GAP_SA_1 | Laras mencelupkan pena, lidahnya terjulur sedikit, tekun. | Laras dips the pen, tongue poking out a little, careful. |
| GAP_SA_PEN_P | Apa yang dipakai Laras untuk menulis? | What did Laras write with? |
| GAP_SA_PEN_1 | Sebatang arang | A stick of charcoal |
| GAP_SA_PEN_2 | Pena bambu Semar | Semar's bamboo pen |
| GAP_SA_PEN_3 | Sebuah duri | A thorn |
| GAP_SA_FIRST_P | Nama siapa yang ia tulis lebih dulu? | Whose name did she write first? |
| GAP_SA_FIRST_1 | Namanya sendiri | Her own |
| GAP_SA_FIRST_2 | Nama Ibu | Ibu's |
| GAP_SA_FIRST_3 | Namamu | Yours |
| GAP_SA_SAID_P | Kata Semar, apa yang dilakukan nama yang ditulis? | What did Semar say a written name does? |
| GAP_SA_SAID_1 | Menahan seseorang tetap ada di dunia | Keeps a person in the world |
| GAP_SA_SAID_2 | Membuat seseorang terkenal | Makes a person famous |
| GAP_SA_SAID_3 | Mengirim seseorang pergi jauh | Sends a person far away |
| MEM_GAP_SA_OUT | Huruf terakhir kembali: Sa. Tiga huruf, dan tinggal kau yang menulisnya. | The last letter is back: Sa. Three letters, and all that's left is for you to write them. |

Correct answers: `GAP_SA_PEN_2` (Semar's bamboo pen), `GAP_SA_FIRST_3` (yours), `GAP_SA_SAID_1` (keeps a person in the world). Gap ids `sa_pen`, `sa_first`, `sa_said`. Tests: every `correct` is among its options, and every key exists in both languages.

### Chapter 3: The Maw of Time (5.5-5.9)

### Clue `semar_tale` and memory `k10_murwakala` (step 5.5; K10, kind walk; Semar's tale at `kala_1`)
| Key | ID | EN |
|-----|----|----|
| HUNT_K10_TITLE | Murwakala | Murwakala |
| CLUE_SEMAR_TALE_1 | Semar duduk dekat apinya, matanya jauh. "Ada satu kisah lagi," katanya, "yang membuat dalang berani." | Semar sits near his fire, eyes far away. "One more tale," he says, "the one that makes a dalang brave." |
| CLUE_SEMAR_TALE_2 | Lontarku diam, menunggu. | My lontar is still, waiting. |
| CLUE_SEMAR_TALE_NOTE | Semar menceritakan kisah Murwakala, kisah lahirnya Kala, di petilasan terakhir. | Semar tells the tale of Murwakala, how Kala was born, at the last petilasan. |
| MEM_K10_MURWAKALA_TITLE | Murwakala | Murwakala |
| MEM_K10_MURWAKALA_IN | Kisah yang dituturkan di setiap ruwatan, Nak. Dengarkan siapa Kala sebenarnya. | The tale told at every ruwatan, child. Listen to who Kala really is. |
| MEM_K10_MURWAKALA_1 | Kala lahir dalam keadaan lapar, dan meminta makanan pada ayahnya, seorang dewa. | Kala is born hungry, and asks his father, a god, for food. |
| MEM_K10_MURWAKALA_2 | Sang dewa berkata: kau boleh memakan yang tak dijaga, yang dilahirkan pada hari yang tak baik. | The god says: you may eat those left unguarded, born on an unlucky day. |
| MEM_K10_MURWAKALA_3 | Tapi seorang dalang membacakan kisah dan nama si anak, dan Kala berhenti. Ia tak bisa menelan yang sudah dituliskan. | But a dalang speaks the tale and the child's name, and Kala stops. He cannot swallow what is written. |
| MEM_K10_MURWAKALA_OUT | Itu sebabnya kata-kata dalang membalikkan Kala, Nak. Ia lapar, bukan jahat. | That is why a dalang's words turn Kala back, child. He is hungry, not wicked. |

VERIFY: the Murwakala lakon as the ruwatan story, and the details of Kala's birth and the dalang's part, as told here (kept gentle, no names for the god).

### Laras chapter LC6 `lc6` (step 5.6; kind chapter; the bottom of the dark; replaces the old `laras_5` beat)
| Key | ID | EN |
|-----|----|----|
| LC_6_TITLE | Siapa di Sana? | Who's There? |
| @NPC_LARAS_NAME | | |
| LC6_1 | Gelap sekali. Tanganku masih menulis Ka, tapi aku lupa untuk siapa. | So dark. My hand still writes Ka, but I forgot who it's for. |
| LC6_2 | Siapa di sana? Maaf. Aku tak ingat kamu. | Who's there? I'm sorry. I don't remember you. |
| LC6_3 | Anehnya, aku tak takut. Suaramu seperti rumah. | Funny, I'm not scared. Your voice sounds like home. |
| LC6_4 | Aku masih menulis Ka. Tanganku bilang, jangan berhenti. | I'm still writing Ka. My hand says don't stop. |
| @NPC_HERO_NAME | | |
| LC6_H1 | Untukku, Laras. Itu untukku. | For me, Laras. It's for me. |

### Clue `semar_kelir` and memory `k7_ruwatan` (step 5.7; K7, kind play, `allow_cast`; the prologue show again, but you are the dalang)
| Key | ID | EN |
|-----|----|----|
| HUNT_K7_TITLE | Ruwatan Fajar | The Dawn Ruwatan |
| CLUE_SEMAR_KELIR_1 | Kelir Semar berdiri di petilasan terakhir, sama seperti malam itu di Desa Purwa. Tapi kali ini lampunya menungguku. | Semar's kelir stands at the last petilasan, like that night in Desa Purwa. But this time the lamp waits for me. |
| CLUE_SEMAR_KELIR_2 | Semar menyerahkan wayang pertama kepadaku. "Kau dalangnya sekarang." | Semar hands me the first puppet. "You're the dalang now." |
| CLUE_SEMAR_KELIR_NOTE | Kelir Semar di petilasan terakhir; aku jadi dalang. | Semar's kelir at the last petilasan; I am the dalang. |
| MEM_K7_RUWATAN_TITLE | Ruwatan Fajar | The Dawn Ruwatan |
| MEM_K7_RUWATAN_IN | Pertunjukan malam itu lagi, Nak, tapi kali ini kau dalangnya. Bacakan nama-nama, bergantian Sunda dan Jawa. | That night's show again, child, but this time you're the dalang. Read the names, Sunda and Jawa in turn. |
| MEM_K7_RUWATAN_HINT | Sunda lalu Jawa | Sunda, then Jawa |
| MEM_K7_RUWATAN_1 | Kau membacakan nama-nama anak desa. Tiap nama satu huruf, dan bayangan Kala menunduk. | You read the village children's names. One letter for each name, and Kala's shadow bows. |
| MEM_K7_RUWATAN_2 | Sunda, Jawa, Sunda, Jawa. Iramanya seperti lesung dan oncor sekaligus. | Sunda, Jawa, Sunda, Jawa. The rhythm is lesung and oncor together. |
| MEM_K7_RUWATAN_3 | Di kelir, bayangan Kala melunak seperti lilin dekat api. | On the kelir Kala's shadow softens like wax near a flame. |
| MEM_K7_RUWATAN_OUT | Begitulah ruwatan fajar, Nak: bergantian, sabar, dan dengan nama. | That is the dawn ruwatan, child: in turn, patient, and with names. |
| HINT_BATARA_KALA | Sunda lalu Jawa | Sunda, then Jawa |

### Beat `write` (if `!flag:beat_write`, `flag:mq5_3`; do `flag:beat_write`). Then entry `write_card` (if `!flag:mq5_4`, `flag:beat_write`; no lines; do `write:laras:sunda_la,sunda_ra,sunda_sa`): split so a save or quit during the card replays the card, not the talk
| Key | ID | EN |
|-----|----|----|
| BEAT_WRITE_1 | Kala berhenti. Laparnya surut seperti ombak, dan ia berbalik ke dalam gelap, tenang, tidak mati. | Kala stops. The hunger goes out of him like a tide, and he turns back into the dark, calm, not dead. |
| BEAT_WRITE_2 | Separuh lontarmu tergeletak di batu. Kosong. | Your half of the lontar lies on the stone. It's blank. |
| @NPC_SEMAR_NAME | | |
| BEAT_WRITE_3 | Tak ada lagi yang ingat bagaimana namanya ditulis. Kecuali kau. Tuliskanlah, Nak. | Nobody else remembers how her name goes. Except you. Write it, child. |

### Staging NPCs (fixed 2026-11-06)
These NPCs stand in a scene for a beat or a later act. Each gets one line so a talk is never empty. Hariang Banga's file runs, in order: entry 1 `flag:mq4_9` (V3, the Gua Kala mouth), entry 2 `quest:mq4=active` (V4, the Interlude table), entry 3 the `camp_timur` talk (section 9), entry 4 no cond (V5, the throne room before his escape). The Deserter at the mouth has entry 1 `flag:deserter_named` (V1) and entry 2 no cond (V2), so "I remembered my name" comes only after SQ-C3 writes it. The others have a single entry with no cond.

| Key | ID | EN |
|-----|----|----|
| DLG_HARIANG_BANGA_V3 | Satu raja dari tiap tepi, dan kali ini kami berdiri di tepi yang sama. Pergilah. | One king from each bank, and for once we stand on the same one. Go. |
| DLG_HARIANG_BANGA_V4 | Ibumu menyiapkan cangkir untukku. Tak ada yang melakukannya sejak kurungan itu. | Your mother set out a cup for me. Nobody has done that since the cage. |
| DLG_HARIANG_BANGA_V5 | Jangan sekarang. Ada ibu yang harus kubebaskan. | Not now. I have a mother to free. |
| DLG_NAMELESS_HUNTER_V1 | Bukan kau. Belum. | Not you. Not yet. |
| DLG_NINI_V1 | Ciung-ku lari ke barat semalam. Susul dia, Nak, sebelum para topeng itu. | My Ciung ran west in the night. Find him, child, before the masks do. |
| DLG_SAPTO_V1 | Bilang pada ayahku aku pulang. Ia boleh berhenti main untuk dua tepi. | Tell my father I'm walking home. He can stop playing for both banks. |
| DLG_NAGAWIRU_V1 | Patahkan dulu fajar palsu itu, Penulis kecil. Baru rantainya. | Break the false dawn first, little writer. Then the chains. |
| DLG_PANGRENYEP_V1 | Puaskan matamu, Nak. Anakku sudah di jalan. | Look your fill, child. My son is already on the road. |
| DLG_SEAL_STONE_V1 | Retakan menjalar di aksara tua itu. Seseorang membaca batu ini separuh jalan, pelan-pelan. | Cracks run through the old letters. Someone read this stone halfway, slowly. |
| DLG_DESERTER_MOUTH_V1 | Aku ingat namaku. Dengan itu aku jaga pintu ini. | I remembered my name. I'll hold the door with it. |
| DLG_DESERTER_MOUTH_V2 | Dulu aku punya nama. Batu itu yang menyimpannya. | I had a name once. That stone keeps it. |


## 11. Epilogue (`ui/epilogue.tscn`: lines 7, `semar_from = 6`, `semar_to = 6`, variants `{3: "choice_handed", 4: "choice_silent", 5: "choice_sink"}`, extras `{1: ["EPILOGUE_C4", "flag:c4_done"], 3: ["EPILOGUE_C3_FREED", "flag:choice_freed,flag:deserter_named"]}`; the playable day follows the cards)
**Lines in this section: 35** (ASSUMED budget: at most 40).
The base card is the first choice of each pair; `_ALT` is the second. An `extras` line (side-story rows at the end of section 15) is added under its card, after a blank line, when its cond holds (ASSUMED).

| Key | ID | EN |
|-----|----|----|
| EPILOGUE_1 | Laras pulang. Ibu menuang dua cangkir teh, dan tak ada yang ingat ia pernah hilang. | Laras comes home. Ibu pours two cups of tea, and nobody remembers that she was ever gone. |
| EPILOGUE_2 | Di barat Pamali, Ciung Wanara memerintah Sunda dengan adil, dan memanggil ibunya dari danau ke istana. Di danau itu, Nagawiru akhirnya tidur. Di timur sungai, Hariang Banga memerintah Jawa. Mereka saling berkirim surat. | West of the Pamali, Ciung Wanara rules a fair Sunda and calls his mother from the lake to court. In the lake, Nagawiru sleeps at last. East of the river, Hariang Banga rules Java. They write to each other. |
| EPILOGUE_3 | Si pembelot menemukan jalan pulang. Ia masih lupa wajah istrinya, tapi istrinya ingat wajahnya. | The deserter found his way home. He still can't recall his wife's face, but she remembers his. |
| EPILOGUE_3_ALT | Lengser mengadili si pembelot dengan adil. Kini ia memperbaiki tempayan istana, dan Galuh memberinya makan. | Lengser judged the deserter fairly. He mends the palace pots now, and Galuh feeds him. |
| EPILOGUE_4 | Setahun sekali, Ciung Wanara membuka kandang itu agar lelaki tua itu bisa melihat langit. Ia tak pernah meminta lebih. | Once a year, Ciung Wanara opens the cage so the old man can see the sky. He never asks for more. |
| EPILOGUE_4_ALT | Kandang itu tetap terkunci. Dalam legenda, memang selalu begitu. | The cage stays shut. In the legend, it always does. |
| EPILOGUE_5 | Mpu Wirasana menempa ulang keris itu. Kini ia menjaga gerbang sebuah desa di timur, dan tak ada yang takut padanya. | Mpu Wirasana reforged the keris. It guards a village gate in the east, and nobody fears it. |
| EPILOGUE_5_ALT | Sungai menyimpan keris itu. Kata para nelayan, kadang di malam hari airnya bersenandung. | The river keeps the keris. Some nights, the fishermen say, the water hums. |
| EPILOGUE_6 | Dan malam ini wayang desa memainkan lakon baru. Duduk, duduk. Ini tentang seseorang yang kau kenal, hehe. | And tonight the village wayang plays a new lakon. Sit, sit. It's about someone you know, hehe. |
| EPILOGUE_7 | `{name} & Laras\n\n` followed by the old EPILOGUE_6 ID text, unchanged | `{name} & Laras\n\n` followed by the old EPILOGUE_6 EN text, unchanged (BUDAYAGO, made by fatih, Codex %d%%) |


### The playable epilogue (about 10 minutes; beats and quiet talks, not quest steps; starts after the cards, `from_gua_kala`, `flag:mq5_4`)
It mirrors the prologue day: Laras wakes you, Ibu pours two cups, you walk the village while the ruwatan stage is built, and the show tells your story. Order: `epi_wake`, Ibu's tea (entry 5), the village talks, `epi_show`. A card still frames it (the cards above); the credits roll at the end of `epi_show`. Whether the 7 cards play before the day or around it is **ASSUMED**: before, then the day, then the credits.

### Beat `epi_wake` (if `!flag:beat_epi_wake`, `flag:mq5_4`, `zone:desa_purwa`; do `flag:beat_epi_wake`)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_EPI_WAKE_1 | Pagi di Desa Purwa. Seseorang melompat ke atas ranjangmu. | Morning in Desa Purwa. Someone jumps onto your bed. |
| @NPC_LARAS_NAME | | |
| BEAT_EPI_WAKE_2 | Kak! Bangun! Ruwatan malam ini, panggungnya sedang dibangun. Tangkap aku kalau bisa! | Kak! Up! The ruwatan's tonight, they're building the stage. Catch me if you can! |
| @NPC_HERO_NAME | | |
| BEAT_EPI_WAKE_H1 | Laras. Kau benar-benar di sini. | Laras. You're really here. |
| @NPC_LARAS_NAME | | |
| BEAT_EPI_WAKE_3 | Ya iyalah. Kau mengigau semalam, tahu. Menyebut-nyebut "Ka". Aneh. | Of course I am. You were talking in your sleep, you know. Saying "Ka". Weird. |
| BEAT_EPI_WAKE_4 | Sampai sumur, Kak! Yang kalah cuci piring! | To the well, Kak! Loser washes the dishes! |

### ibu, the epilogue (entry 5 of the table in section 5)
| Entry | Key | ID | EN |
|-------|-----|----|----|
| 5 | @NPC_IBU_NAME | | |
| 5 | DLG_IBU_V5 | Laras, siapkan piring, kakakmu pulang! | Laras, set the table, your kakak's home! |
| 5 | @NPC_LARAS_NAME | | |
| 5 | DLG_IBU_L2 | Aku di sini, Bu! Yang gompal punyaku, ya! | I'm here, Ibu! The chipped one's mine, right! |
| 5 | @NPC_IBU_NAME | | |
| 5 | DLG_IBU_V6 | Aneh. Tadi Ibu kira rumah ini terlalu sepi. | Funny. For a moment I thought this house was too quiet. |
| 5 | DLG_IBU_V23 | Teh melati, dua cangkir, seperti biasa. Pulang sebelum pertunjukan, berdua. | Jasmine tea, two cups, as ever. Home before the show, both of you. |

### Epilogue village talks (one entry each, first in the NPC's file, cond `flag:mq5_4` plus the cond shown; `"quiet": true`). Who is there depends on the journey and the three choices
| Entry (NPC id) | Cond | Key | ID | EN |
|----------------|------|-----|----|----|
| sunda_grandson | `flag:mq5_4` | DLG_SUNDA_GRANDSON_V5 | Aku bawa angklungku! Kau ingat janji satu nada? | I brought my angklung! Remember the note you were owed? |
| lengser | `flag:mq5_4` | DLG_LENGSER_V9 | Panggung wayang desa ini lebih rendah dari singgasana Galuh, tapi kursinya lebih empuk. Lututku setuju. | This village's wayang stage is lower than Galuh's throne, but the seats are softer. My knees agree. |
| mataram_dalang | `flag:mq5_4` | DLG_MATARAM_DALANG_V8 | Semar menyuruhku menonton saja malam ini. Pertama kalinya kelirku tak perlu dibela. | Semar told me to just watch tonight. The first time my screen needs no defending. |
| sapto | `flag:mq5_4` | DLG_SAPTO_V2 | Bapak menangis di barisan depan. Katanya debu. | Bapak is crying in the front row. He says it's dust. |
| kidul_jurukunci | `flag:mq5_4` | DLG_WIRYO_V8 | Senja tadi ombak menyebut nama Sumi sebelum kuminta. Aku datang untuk bilang terima kasih. | At dusk the surf said Sumi's name before I asked. I came to say thank you. |
| timur_daughter | `flag:mq5_4`, `flag:choice_reforge` | DLG_TIMUR_DAUGHTER_V5 | Ayah ikut datang. Katanya bilah yang kau bawa akhirnya tidur nyenyak. | Father came too. He says the blade you carry finally sleeps well. |
| timur_daughter | `flag:mq5_4`, `flag:choice_sink` | DLG_TIMUR_DAUGHTER_V6 | Ayah tinggal di bengkel. Katanya sungai pasti menjaga keris itu lebih baik darinya. | Father stayed at the forge. He says the river will keep that keris better than he could. |
| faceless_deserter | `flag:mq5_4`, `flag:choice_freed` | DLG_FACELESS_DESERTER_V7 | Wajah istriku masih kabur. Tapi ia memegang tanganku di depan panggung. Cukup. | My wife's face is still a blur. But she's holding my hand at the front of the stage. That's enough. |
| ciung_wanara | `flag:mq5_4`, `flag:choice_mercy` | DLG_CIUNG_WANARA_V12 | Dia titip salam. Lampunya masih menyala. | He sends his greetings. The lamp is still lit. |
| ciung_wanara | `flag:mq5_4`, `flag:choice_silent` | DLG_CIUNG_WANARA_V13 | Aku datang karena Laras mengundangku. Soal kandang itu... lain kali. | I came because Laras invited me. About the cage... another time. |

Each row is one line, so the talk is one box. The Deserter, Wirasana's daughter and Ciung change with the choices; Ciung's two entries and every `flag:mq5_4` entry come before the file's older entries.

### Beat `epi_show` (if `!flag:beat_epi_show`, `flag:beat_epi_wake`, `flag:epi_show_ready`; do `flag:beat_epi_show`, `credits`). Area `wayang_stage` in the evening sets `epi_show_ready` (ASSUMED); `credits` is a new action (ASSUMED)
| Key | ID | EN |
|-----|----|----|
| @NPC_SEMAR_NAME | | |
| BEAT_EPI_SHOW_1 | Duduk, duduk. Pada suatu masa ada seorang murid yang hanya mengulang cerita orang lain... | Sit, sit. Once there was an apprentice who only repeated other people's stories... |
| @NPC_LARAS_NAME | | |
| BEAT_EPI_SHOW_2 | Kak, ini tentang kamu, kan? Bagian mana yang kulewatkan? | Kak, this is about you, isn't it? Which part did I miss? |
| @NPC_HERO_NAME | | |
| BEAT_EPI_SHOW_H1 | Banyak. Akan kuceritakan, dari kejar-kejaran sampai nama. | A lot. I'll tell you, from the tag game to the name. |
| @ | | |
| BEAT_EPI_SHOW_3 | Di kelir, bayanganmu dan bayangan Laras duduk berdampingan. Lampu blencong bergoyang. Kredit mulai bergulir. | On the kelir your shadow and Laras's sit side by side. The blencong lamp sways. The credits begin to roll. |


## 12. Quest text (`quests.csv`)
**Lines in this section: 192** (ASSUMED budget: at most 200).
- `Q_<ID>_TITLE`, quest id upper-cased. The journal shows the act title; MQ4 shows the Act V title for the whole quest.

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_TITLE | A Day in Desa Purwa | Sehari di Desa Purwa |
| Q_MQ1_TITLE | The Crater Seal | Segel Kawah |
| Q_MQG_TITLE | The Borrowed Face | Wajah Pinjaman |
| Q_MQ2_TITLE | Blood on the Pamali | Darah di Pamali |
| Q_MQ3_TITLE | The Seven-Generation Blade | Bilah Tujuh Turunan |
| Q_MQ4_TITLE | The Sea Does Not Forget (steps 4.1-4.5: "The Quiet House" / "Rumah yang Sunyi") | Laut Tak Pernah Lupa |
| Q_MQ5_TITLE | Into the Maw of Time | Ke Rahang Sang Waktu |

- `Q_<ID>_S<n>_OBJ`: the Objective columns of [quests.md](quests.md) 4, `n` 1-based in table order (0.1 is S1, g.1 is S1). Identical to quests.md; the 78 steps:

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_S1_OBJ | Catch Laras: she dares you to a game of tag | Tangkap Laras: dia menantangmu bermain kejar-kejaran |
| Q_MQ0_S2_OBJ | Have tea with Ibu, then fetch Ciung and his egg from the tree | Minum teh bersama Ibu, lalu jemput Ciung dan telurnya dari pohon |
| Q_MQ0_S3_OBJ | Meet Semar and Cepot at the sanggar, write your names on the lontar, then ask around the market | Temui Semar dan Cepot di sanggar, tulis namamu di lontar, lalu bertanya di pasar |
| Q_MQ0_S4_OBJ | Watch Semar's wayang ruwatan from behind the kelir | Saksikan wayang ruwatan Semar dari balik kelir |
| Q_MQ0_S5_OBJ | Find Laras in the crowd as the shadows step off the screen | Temukan Laras di tengah kerumunan saat bayangan melangkah turun dari layar |
| Q_MQ0_S6_OBJ | Ask Ibu where Laras is, then pull her lontar from the burned stage | Tanya Ibu di mana Laras berada, lalu ambil lontarnya dari panggung yang terbakar |
| Q_MQ0_S7_OBJ | Show the lontar to Semar, learn Ka and cast it three times | Tunjukkan lontar kepada Semar, pelajari Ka dan rapalkan tiga kali |
| Q_MQ0_S8_OBJ | Drive the faceless out of the village square | Usir para tanpa rupa dari alun-alun desa |
| Q_MQ0_S9_OBJ | Follow the raiders to the west gate and see the Hunter | Ikuti para penyerbu ke gerbang barat dan lihat sang Pemburu |
| Q_MQ1_S1_OBJ | Arrival. Walk the tea terraces at dawn, meet the elder's grandson, break the ambush at the bamboo edge and find Laras's ribbon | Jalani kebun teh saat fajar, temui cucu sesepuh, patahkan penyergapan di rumpun bambu dan temukan pita Laras |
| Q_MQ1_S2_OBJ | Rest at the petilasan by the tea terraces (Cepot), then break the ambush at the kampung | Beristirahat di petilasan dekat kebun teh (Cepot), lalu patahkan penyergapan di kampung |
| Q_MQ1_S3_OBJ | Ask the kampung elder about Laras, learn Ga, then follow a mother's calling to the hamlet by the gorge | Tanya sesepuh kampung tentang Laras, pelajari Ga, lalu ikuti suara seorang ibu ke dusun di tepi ngarai |
| Q_MQ1_S4_OBJ | K1 clues. Find out what took the children: the sandal, the unlit torches, the prints | Cari tahu apa yang membawa anak-anak: sandal, obor yang padam, jejak kaki |
| Q_MQ1_S5_OBJ | K1 memory. Follow the lontar's pull: a child at maghrib | Ikuti tarikan lontar: seorang anak saat maghrib |
| Q_MQ1_S6_OBJ | Defeat Sandekala in the river gorge at dusk | Kalahkan Sandekala di ngarai sungai saat senja |
| Q_MQ1_S7_OBJ | Read the defaced Batu Tulis and learn Nga | Baca Batu Tulis yang dirusak dan pelajari Nga |
| Q_MQ1_S8_OBJ | Drive the faceless off the rice terraces and take the Boeh Rarang from the Weaver | Usir para tanpa rupa dari teras sawah dan terimalah Boeh Rarang dari Penenun |
| Q_MQ1_S9_OBJ | K2 clues. Follow the dammed river and find out why: felled trees, empty coops, the Weaver's loom | Ikuti sungai yang dibendung dan cari tahu sebabnya: pohon tumbang, kandang kosong, alat tenun |
| Q_MQ1_S10_OBJ | Clear the lake shore and look at what the fallen Faceless dropped | Bersihkan tepi danau dan lihat apa yang dijatuhkan seorang Tanpa Rupa yang tumbang |
| Q_MQ1_S11_OBJ | Speak with the woman by the lake and learn Ca, then climb the crater road to the petilasan | Bicara dengan perempuan di tepi danau dan pelajari Ca, lalu daki jalan kawah ke petilasan |
| Q_MQ1_S12_OBJ | LC1. Play Laras: reading slowly at the crater | Mainkan Laras: membaca pelan-pelan di kawah |
| Q_MQ1_S13_OBJ | Defeat the Faceless Captain on the crater rim and take the mask fragment | Kalahkan Kapten Tanpa Rupa di bibir kawah dan ambil pecahan topeng |
| Q_MQ1_S14_OBJ | K2 memory. Follow the lontar's pull: Dayang Sumbi's night | Ikuti tarikan lontar: malam Dayang Sumbi |
| Q_MQ1_S15_OBJ | End the legend again: the false dawn | Akhiri legenda itu sekali lagi: fajar palsu |
| Q_MQG_S1_OBJ | Arrival. Join the tournament crowd, talk to the rooster seller and plan the infiltration with Ciung Wanara | Berbaur dengan kerumunan sayembara, bicara dengan penjual ayam jago dan susun rencana bersama Ciung Wanara |
| Q_MQG_S2_OBJ | Win both bouts of the king's tournament | Menangkan kedua babak sayembara raja |
| Q_MQG_S3_OBJ | Speak with the old chamberlain, Uwa Lengser, and enter the inner palace | Bicara dengan Uwa Lengser, abdi tua istana, dan masuki istana dalam |
| Q_MQG_S4_OBJ | Stop the wagon in the cell yard | Hadang kereta di halaman penjara |
| Q_MQG_S5_OBJ | Search the cells for Laras | Geledah sel tahanan, cari Laras |
| Q_MQG_S6_OBJ | LC2. Play Laras: under the wagon cloth | Mainkan Laras: di bawah kain kereta |
| Q_MQG_S7_OBJ | Decide the deserter's fate and look at the court portrait of the king | Putuskan nasib si pembelot dan perhatikan lukisan potret sang raja |
| Q_MQG_S8_OBJ | Hear Lengser's memory, then take the mask fragment by the throne | Dengarkan kenangan Lengser, lalu ambil pecahan topeng di dekat takhta |
| Q_MQG_S9_OBJ | Unmask the king | Buka topeng sang raja |
| Q_MQ2_S1_OBJ | Arrival. Hear both recruiters at the river market, break the ambush at the border gate and rest at the petilasan | Dengarkan kedua perekrut di pasar sungai, patahkan penyergapan di gerbang perbatasan dan beristirahat di petilasan |
| Q_MQ2_S2_OBJ | Follow the three leads on Laras: the market, the ruins, the graveyard | Telusuri tiga petunjuk tentang Laras: pasar, reruntuhan, dan kuburan |
| Q_MQ2_S3_OBJ | Learn Ha from Ki Sumarto, read Na off the Arca's base and learn Ca from the lesung women | Pelajari Ha dari Ki Sumarto, baca Na dari dasar Arca dan pelajari Ca dari para perempuan di lesung |
| Q_MQ2_S4_OBJ | H3. Take the mask fragment in the graveyard and see the price | Ambil pecahan topeng di kuburan dan lihat harganya |
| Q_MQ2_S5_OBJ | Break the blockade on the foothill and receive the juru kunci's blessing and Ra | Hancurkan blokade di kaki bukit dan terimalah restu juru kunci dan Ra |
| Q_MQ2_S6_OBJ | Fight through the temple gate and storm the Faceless camp at Candi Seribu | Tembus gerbang candi dan serbu perkemahan tanpa rupa di Candi Seribu |
| Q_MQ2_S7_OBJ | K3 clues. Examine the chisel-marked rubble, the abandoned lesung and Laras's strip | Periksa puing berbekas pahat, lesung yang ditinggalkan, dan helai lontar Laras |
| Q_MQ2_S8_OBJ | K3 memory. Follow the lontar's pull: the princess's women | Ikuti tarikan lontar: para dayang sang putri |
| Q_MQ2_S9_OBJ | LC3. Play Laras: the reading room | Mainkan Laras: ruang baca |
| Q_MQ2_S10_OBJ | End Bandung Bondowoso's night | Akhiri malam Bandung Bondowoso |
| Q_MQ2_S11_OBJ | Cross to the Pamali stone and write Nagawiru's true name on it | Seberangi ke batu Pamali dan tuliskan nama sejati Nagawiru di atasnya |
| Q_MQ2_S12_OBJ | K-III. Watch Ki Sumarto's show: the brothers who split the land | Saksikan pertunjukan Ki Sumarto: dua saudara yang membelah tanah |
| Q_MQ2_S13_OBJ | Read Hariang Banga's letters to his mother, then duel him at the ford | Baca surat-surat Hariang Banga untuk ibunya, lalu berduel dengannya di tepi penyeberangan |
| Q_MQ3_S1_OBJ | Arrival. Walk the smiths' street, break the ambush at the eastern border and rest at the savanna petilasan | Jalani jalan para pandai besi, patahkan penyergapan di perbatasan timur dan beristirahat di petilasan sabana |
| Q_MQ3_S2_OBJ | Follow the red curse marks to Mpu Wirasana's forge and learn to break them | Ikuti tanda kutukan merah ke bengkel Mpu Wirasana dan belajar mematahkannya |
| Q_MQ3_S3_OBJ | Help the widow whose hut was smashed, and examine the seeds, needle case, salt jar and terasi pot | Bantu janda yang pondoknya hancur, dan periksa biji timun, tempat jarum, toples garam dan terasi |
| Q_MQ3_S4_OBJ | K4 memory. Follow the lontar's pull: Timun Mas | Ikuti tarikan lontar: Timun Mas |
| Q_MQ3_S5_OBJ | Defeat Buto Ijo | Kalahkan Buto Ijo |
| Q_MQ3_S6_OBJ | Break two practice curse marks, then examine the broken scabbard and the forge records | Patahkan dua tanda kutukan latihan, lalu periksa sarung keris yang patah dan catatan tempa |
| Q_MQ3_S7_OBJ | Follow the Hunter's ash trail down the coast and cross the Sea of Sand | Ikuti jejak abu Si Tanpa Ngaran menyusuri pesisir dan seberangi Lautan Pasir |
| Q_MQ3_S8_OBJ | Rest at the desert petilasan, then play Laras on the desert road | Beristirahat di petilasan gurun, lalu mainkan Laras di jalan gurun |
| Q_MQ3_S9_OBJ | Reach the shrine, see the old forge, and lay the cursed keris to rest | Capai kuil, lihat bengkel tua, dan tenangkan keris terkutuk |
| Q_MQ3_S10_OBJ | Take the last mask fragment, join the mask and see the servant | Ambil pecahan topeng terakhir, satukan topeng dan lihat sang abdi |
| Q_MQ3_S11_OBJ | Face the Nameless Hunter | Hadapi Si Tanpa Ngaran |
| Q_MQ4_S1_OBJ | Go home to Desa Purwa under the Eclipse | Pulanglah ke Desa Purwa di bawah Gerhana |
| Q_MQ4_S2_OBJ | Write each family's name on their doorpost | Tuliskan nama setiap keluarga di tiang pintu mereka |
| Q_MQ4_S3_OBJ | Bring Ibu three of Laras's things: the ribbon, the wagon-board message and the Ka strip | Bawakan Ibu tiga benda milik Laras: pita, pesan papan kereta, dan helai Ka |
| Q_MQ4_S4_OBJ | Sit at your mother's table with the two brothers | Duduk di meja ibumu bersama kedua saudara raja |
| Q_MQ4_S5_OBJ | Talk to Semar about the sea, and (optional) hear Aria Kebonan by the burned stage | Bicara dengan Semar tentang laut, dan (opsional) dengarkan Aria Kebonan di dekat panggung terbakar |
| Q_MQ4_S6_OBJ | Arrival. Rest at the black-sand petilasan, see the village mend its nets and speak with Mbah Wiryo | Beristirahat di petilasan pantai pasir hitam, lihat desa menambal jala, dan bicara dengan Mbah Wiryo |
| Q_MQ4_S7_OBJ | K8 clues. Find the three forgotten verses of the sea song with three families | Temukan tiga bait lagu laut yang terlupa pada tiga keluarga |
| Q_MQ4_S8_OBJ | K8 memory. Follow the lontar's pull: Mbah Wiryo's wife on the shore | Ikuti tarikan lontar: istri Mbah Wiryo di pantai |
| Q_MQ4_S9_OBJ | Cross the reef | Seberangi karang |
| Q_MQ4_S10_OBJ | Climb the cliff path, rest at the cliff shrine and hear the queen of the south as one retelling (K9) | Daki jalan setapak tebing, beristirahat di kuil tebing dan dengarkan ratu selatan sebagai satu penceritaan (K9) |
| Q_MQ4_S11_OBJ | LC5. Play Laras: the voice on the water | Mainkan Laras: suara di atas air |
| Q_MQ4_S12_OBJ | Pass the Trial of the Waves and receive Ombak and the Kain Hijau | Jalani Ujian Ombak dan terimalah Ombak dan Kain Hijau |
| Q_MQ5_S1_OBJ | Enter Gua Kala and reclaim La in the memory of the tag game | Masuki Gua Kala dan rebut La dalam kenangan permainan kejar-kejaran |
| Q_MQ5_S2_OBJ | Shatter the western and eastern time-wards on the Hourglass Sands | Hancurkan penangkal waktu barat dan timur di Pasir Jam Pasir |
| Q_MQ5_S3_OBJ | Cross the Abyss of Forgetting and reclaim Ra in the memory of the two cups | Seberangi Jurang Lupa dan rebut Ra dalam kenangan dua cangkir teh |
| Q_MQ5_S4_OBJ | Rest at the last petilasan and reclaim Sa in the memory of the written names | Beristirahat di petilasan terakhir dan rebut Sa dalam kenangan nama-nama yang ditulis |
| Q_MQ5_S5_OBJ | K10. Hear Semar's tale of Murwakala: why the ruwatan turns Kala back | Dengarkan kisah Murwakala dari Semar: mengapa ruwatan membalikkan Kala |
| Q_MQ5_S6_OBJ | LC6. Play Laras: who's there? | Mainkan Laras: siapa di sana? |
| Q_MQ5_S7_OBJ | K7 memory. Read the names aloud at Semar's kelir | Bacakan nama-nama di kelir Semar |
| Q_MQ5_S8_OBJ | Calm Batara Kala | Tenangkan Batara Kala |
| Q_MQ5_S9_OBJ | Write Laras's name | Tuliskan nama Laras |

- `Q_<ID>_S<n>_<A|B|C>`: the sub-objective lines of the `all` steps that are not clues (the journal strikes each through). The clue steps use `CLUE_<ID>_NOTE` instead.

| Key | EN | ID |
|-----|----|----|
| Q_MQ2_S1_A | Hear the west-bank recruiter | Dengarkan perekrut tepi barat |
| Q_MQ2_S1_B | Hear the east-bank recruiter | Dengarkan perekrut tepi timur |
| Q_MQ2_S2_A | The market lead | Petunjuk pasar |
| Q_MQ2_S2_B | The ruins lead | Petunjuk reruntuhan |
| Q_MQ2_S2_C | The graveyard lead | Petunjuk kuburan |
| Q_MQ2_S3_A | Learn Ha from Ki Sumarto | Pelajari Ha dari Ki Sumarto |
| Q_MQ2_S3_B | Read Na from the Arca's base | Baca Na dari dasar Arca |
| Q_MQ2_S3_C | Learn Ca from the lesung women | Pelajari Ca dari perempuan lesung |
| Q_MQ4_S2_A | The first doorpost | Tiang pintu pertama |
| Q_MQ4_S2_B | The second doorpost | Tiang pintu kedua |
| Q_MQ4_S2_C | The third doorpost | Tiang pintu ketiga |

- Hints, MQ0 only (input-map keys in braces). The step numbers follow the v4 table; the old S5 hint is retired.

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_S1_HINT | Chase Laras, and press {dodge} to dash past obstacles | Kejar Laras, dan tekan {dodge} untuk menerobos rintangan |
| Q_MQ0_S2_HINT | Press {interact} near Ibu, then the old couple, then Ciung | Tekan {interact} di dekat Ibu, lalu pasangan tua, lalu Ciung |
| Q_MQ0_S3_HINT | Talk to Semar in the sanggar, then ask at the market | Bicara dengan Semar di sanggar, lalu bertanya di pasar |
| Q_MQ0_S4_HINT | Sit behind the kelir and stay in the lamp's light | Duduk di balik kelir dan tetap di cahaya lampu |
| Q_MQ0_S6_HINT | Ask Ibu, then walk to the burned wayang stage | Tanya Ibu, lalu jalan ke panggung wayang yang terbakar |
| Q_MQ0_S7_HINT | Hold {cast}, trace Ka over the guide, then release | Tahan {cast}, gambar Ka mengikuti bayangan, lalu lepas |
| Q_MQ0_S8_HINT | {attack} attacks · {dodge} dodges | {attack} menyerang · {dodge} menghindar |

- SQ-S5 and SQ-M5 are retired ([quests.md](quests.md) 5): drop `Q_SQ_S5_*` and `Q_SQ_M5_*`.

- Side Hunts rebuilt in v4d ([quests.md](quests.md) 5), Act I. They replace the v3.1 rows; S2's title no longer names the creature before its clue does (Pacing 10). Purbasari is "the girl" until her name tag (step 4).

| Key | EN | ID |
|-----|----|----|
| Q_SQ_S1_S1_OBJ | Talk to Ki Darsa, the juru pantun | Bicara dengan Ki Darsa, sang juru pantun |
| Q_SQ_S1_S2_OBJ | Look at the langur's offerings, and find the hidden spring | Periksa persembahan si lutung, dan temukan mata air tersembunyi |
| Q_SQ_S1_S3_OBJ | Memory. As the langur, lead the girl to the spring | Ingatan. Sebagai lutung, tuntun gadis itu ke mata air |
| Q_SQ_S1_S4_OBJ | Speak with the girl at the spring | Bicara dengan gadis itu di mata air |
| Q_SQ_S1_S5_OBJ | Return to Ki Darsa | Kembali kepada Ki Darsa |
| Q_SQ_S2_TITLE | Crying in the Bamboo | Tangis di Rumpun Bambu |
| Q_SQ_S2_S1_OBJ | Hear out the village head | Dengarkan kepala desa |
| Q_SQ_S2_S2_OBJ | Search the bamboo grove for where the crying comes from | Telusuri rumpun bambu, dari mana tangisan itu datang |
| Q_SQ_S2_S3_OBJ | Memory. Walk the grove at night as the grandmother did | Ingatan. Susuri rumpun bambu di malam hari seperti sang nenek |
| Q_SQ_S2_S4_OBJ | Defeat the kuntilanak in the grove | Kalahkan kuntilanak di rumpun bambu |
| Q_SQ_S2_S5_OBJ | Report to the village head | Lapor kepada kepala desa |

### Recap lines ("Story so far", ui.md 3, quests.md 7.4)
One short past-tense line per main step, key `Q_<QUEST>_S<n>_DONE`, `n` as above. They are read in the journal in order, so each only uses names the player has met by then (Pacing 10).

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_S1_DONE | I chased Laras to the well. She called a stray cat by its real name, and it came. | Kukejar Laras sampai sumur. Ia memanggil seekor kucing dengan nama aslinya, dan kucing itu datang. |
| Q_MQ0_S2_DONE | We had jasmine tea with Ibu, then I fetched Ciung and his egg down from the tree. | Kami minum teh melati bersama Ibu, lalu kujemput Ciung dan telurnya dari pohon. |
| Q_MQ0_S3_DONE | At the sanggar Laras wrote our names on one lontar. The market warned of a man in a blank mask. | Di sanggar Laras menulis nama kami di satu lontar. Pasar memperingatkan tentang lelaki bertopeng polos. |
| Q_MQ0_S4_DONE | Semar played the ruwatan: Batara Kala, the Four Seals, and the children's names read aloud. | Semar mementaskan ruwatan: Batara Kala, Empat Segel, dan nama anak-anak yang dibacakan. |
| Q_MQ0_S5_DONE | The shadows stepped off the screen. The Hunter took Laras, and our lontar tore. | Bayangan turun dari kelir. Si Pemburu membawa Laras, dan lontar kami robek. |
| Q_MQ0_S6_DONE | Ibu doesn't remember Laras, yet two cups were set out. I took my lontar from the burned stage. | Ibu tak ingat Laras, tapi dua cangkir terhidang. Kuambil lontarku dari panggung yang hangus. |
| Q_MQ0_S7_DONE | Semar still remembers Laras. He taught me Ka, and I cast it three times. | Semar masih ingat Laras. Ia mengajariku Ka, dan kurapalkan tiga kali. |
| Q_MQ0_S8_DONE | I drove the faceless out of the square. | Kuusir para tanpa rupa dari alun-alun. |
| Q_MQ0_S9_DONE | The Hunter stood at the west gate. Ciung had run west, and the masks followed. | Si Pemburu berdiri di gerbang barat. Ciung lari ke barat, dan para topeng mengikutinya. |
| Q_MQ1_S1_DONE | On the tea terraces I broke an ambush and found Laras's ribbon in the bamboo. | Di kebun teh kupatahkan penyergapan dan kutemukan pita Laras di rumpun bambu. |
| Q_MQ1_S2_DONE | Cepot was at the petilasan. Then I broke the ambush in the kampung. | Cepot ada di petilasan. Lalu kupatahkan penyergapan di kampung. |
| Q_MQ1_S3_DONE | The kampung elder saw Laras running with a wild boy. He taught me Ga. | Sesepuh kampung melihat Laras berlari bersama bocah liar. Ia mengajariku Ga. |
| Q_MQ1_S4_DONE | I found a sandal, cold torches and children's prints leading into the gorge. | Kutemukan sandal, obor padam, dan jejak anak-anak menuju ngarai. |
| Q_MQ1_S5_DONE | The lontar pulled me into a child's maghrib, and I learned to light the oncor. | Lontar menarikku ke maghrib seorang anak, dan aku belajar menyalakan oncor. |
| Q_MQ1_S6_DONE | I beat Sandekala in the gorge. Laras's and Ciung's tracks split there. | Kukalahkan Sandekala di ngarai. Jejak Laras dan Ciung berpisah di sana. |
| Q_MQ1_S7_DONE | On the defaced Batu Tulis Laras scratched: "They need me to read." I learned Nga. | Di Batu Tulis yang dirusak Laras menggores: "Mereka butuh aku membaca." Kupelajari Nga. |
| Q_MQ1_S8_DONE | The Weaver hid Laras for a night and gave me the Boeh Rarang. | Penenun menyembunyikan Laras semalam dan memberiku Boeh Rarang. |
| Q_MQ1_S9_DONE | A dammed river, empty coops, felled trees: someone is building a boat on the lake. | Sungai dibendung, kandang kosong, pohon tumbang: seseorang membangun perahu di danau. |
| Q_MQ1_S10_DONE | A faceless one dropped a named toy. They were people once. | Seorang tanpa rupa menjatuhkan mainan bernama. Mereka dulu manusia. |
| Q_MQ1_S11_DONE | The woman at the lake knew Ciung's face. She taught me Ca and pointed to the crater. | Perempuan di danau mengenali wajah Ciung. Ia mengajariku Ca dan menunjuk kawah. |
| Q_MQ1_S12_DONE | At the crater Laras was made to read. She read slowly on purpose, and I heard her voice. | Di kawah Laras dipaksa membaca. Ia sengaja membaca pelan, dan aku mendengar suaranya. |
| Q_MQ1_S13_DONE | I beat the Faceless Captain, but he cracked the seal first. I found a second mask fragment. | Kukalahkan Kapten Tanpa Rupa, tapi ia sempat memecahkan segel. Kutemukan pecahan topeng kedua. |
| Q_MQ1_S14_DONE | The lontar pulled me into Dayang Sumbi's night: white cloth, lesung, a false dawn. | Lontar menarikku ke malam Dayang Sumbi: kain putih, lesung, fajar palsu. |
| Q_MQ1_S15_DONE | A false dawn ended Sangkuriang again. Ciung and Nagawiru are free, and the egg hatched. | Fajar palsu mengakhiri Sangkuriang sekali lagi. Ciung dan Nagawiru bebas, dan telur menetas. |
| Q_MQG_S1_DONE | In Galuh's tournament crowd, Ciung and I made a plan. | Di keramaian sayembara Galuh, Ciung dan aku menyusun rencana. |
| Q_MQG_S2_DONE | I won both bouts; Ciung's rooster won behind the wall. | Kumenangkan kedua babak; ayam Ciung menang di balik tembok. |
| Q_MQG_S3_DONE | Uwa Lengser opened the inner palace. He saw a queen's eyes in Ciung. | Uwa Lengser membuka istana dalam. Ia melihat mata seorang ratu pada Ciung. |
| Q_MQG_S4_DONE | I was too late: Laras's wagon escaped east, but she threw me a strip marked Ka. | Aku terlambat: kereta Laras lolos ke timur, tapi ia melempar helai bertanda Ka. |
| Q_MQG_S5_DONE | On the cell wall Laras wrote: "The thousand temples. Don't stop." | Di dinding sel Laras menulis: "Seribu candi. Jangan berhenti." |
| Q_MQG_S6_DONE | I heard Laras under the wagon cloth; she left a message for Ibu about the cup. | Kudengar Laras di bawah kain kereta; ia menitip pesan untuk Ibu soal cangkir. |
| Q_MQG_S7_DONE | The deserter's fate was decided, and the king's portrait in the gallery was scraped bare. | Nasib si pembelot diputuskan, dan potret raja di galeri sudah dikikis habis. |
| Q_MQG_S8_DONE | Lengser's memory: a man trying on the king's face. A third mask fragment lay by the throne. | Ingatan Lengser: seorang lelaki mencoba wajah raja. Pecahan topeng ketiga di dekat takhta. |
| Q_MQG_S9_DONE | I unmasked Barma Wijaya. He confessed he gave his old name to Kala, and that name is the Hunter. | Kubuka topeng Barma Wijaya. Ia mengaku memberikan namanya yang dulu pada Kala, dan nama itu si Pemburu. |
| Q_MQ2_S1_DONE | At the river market two recruiters told the same war backwards. I passed the border gate. | Di pasar sungai dua perekrut menceritakan perang yang sama secara terbalik. Kulewati gerbang perbatasan. |
| Q_MQ2_S2_DONE | Three leads on Laras: the market, the ruins, the graveyard. | Tiga petunjuk tentang Laras: pasar, reruntuhan, kuburan. |
| Q_MQ2_S3_DONE | I learned Ha from Ki Sumarto, Na from the Arca's base and Ca from the lesung women. | Kupelajari Ha dari Ki Sumarto, Na dari dasar Arca, dan Ca dari perempuan lesung. |
| Q_MQ2_S4_DONE | At the graves the Hunter said two armies make twice the forgetting. A fourth fragment showed what his name cost. | Di kuburan si Pemburu bilang dua pasukan membuat dua kali lupa. Pecahan keempat menunjukkan harga namanya. |
| Q_MQ2_S5_DONE | The blockade fell, and the juru kunci gave me Ra and opened the temple stairs. | Blokade runtuh, dan juru kunci memberiku Ra serta membuka tangga candi. |
| Q_MQ2_S6_DONE | The camp at Candi Seribu was a reading room. Laras had been taken east. | Perkemahan di Candi Seribu ternyata ruang baca. Laras sudah dibawa ke timur. |
| Q_MQ2_S7_DONE | Rubble, an abandoned lesung, Laras's Ka strip: all pointed to one old tale. | Puing, lesung yang ditinggalkan, helai Ka Laras: semuanya menunjuk satu kisah lama. |
| Q_MQ2_S8_DONE | The lontar pulled me to the princess's women, and I learned the lesung beat. | Lontar menarikku ke para dayang sang putri, dan aku belajar irama lesung. |
| Q_MQ2_S9_DONE | Laras was forced to read in the reading room. She wrote Ka again. | Laras terpaksa membaca di ruang baca. Ia menulis Ka lagi. |
| Q_MQ2_S10_DONE | With the beat and Ca, Bandung Bondowoso's night ended. | Dengan irama dan Ca, malam Bandung Bondowoso berakhir. |
| Q_MQ2_S11_DONE | On the Pamali stone I wrote Nagawiru's name, the first name I ever wrote for someone. | Di batu Pamali kutuliskan nama Nagawiru, nama pertama yang kutulis untuk orang lain. |
| Q_MQ2_S12_DONE | Ki Sumarto played two brothers who split the land, and I learned what pamali means. | Ki Sumarto memainkan dua saudara yang membelah tanah, dan aku belajar arti pamali. |
| Q_MQ2_S13_DONE | I read Hariang Banga's letters to his mother, then fought him at the ford. | Kubaca surat-surat Hariang Banga untuk ibunya, lalu berduel dengannya di tepi penyeberangan. |
| Q_MQ3_S1_DONE | On the smiths' street I met the smith's daughter, then broke the border ambush. | Di jalan para pandai besi kutemui putri sang empu, lalu kupatahkan penyergapan di perbatasan. |
| Q_MQ3_S2_DONE | Red curse marks led me to Mpu Wirasana, who taught me to break them. | Tanda kutukan merah membawaku ke Mpu Wirasana, yang mengajariku mematahkannya. |
| Q_MQ3_S3_DONE | The widow lost her daughter Timun Mas. I found the seeds, needles, salt and terasi. | Sang janda kehilangan putrinya, Timun Mas. Kutemukan biji, jarum, garam, dan terasi. |
| Q_MQ3_S4_DONE | The lontar pulled me into Timun Mas running from a giant. | Lontar menarikku menjadi Timun Mas yang lari dari seorang raksasa. |
| Q_MQ3_S5_DONE | I beat Buto Ijo, driven mad by the keris's curse. | Kukalahkan Buto Ijo, yang dibuat gila oleh kutukan keris. |
| Q_MQ3_S6_DONE | I broke two practice marks and found the broken scabbard and Wirasana's forge records. | Kupatahkan dua tanda latihan dan menemukan sarung keris patah serta catatan tempa Wirasana. |
| Q_MQ3_S7_DONE | I followed the Hunter's ash trail down the coast and across the Sea of Sand. | Kuikuti jejak abu si Pemburu menyusuri pesisir dan Lautan Pasir. |
| Q_MQ3_S8_DONE | Laras tried to draw my face in the sand and couldn't. She only wrote Ka. | Laras mencoba menggambar wajahku di pasir dan tak bisa. Ia hanya menulis Ka. |
| Q_MQ3_S9_DONE | At the desert shrine I saw Laras reading. A memory of the old forge taught me to douse the curse, and the keris quieted. | Di candi gurun kulihat Laras membaca. Ingatan bengkel tua mengajariku memadamkan kutuk, dan keris itu tenang. |
| Q_MQ3_S10_DONE | The last fragment showed the raid through the Hunter's eyes. The fragments joined into one mask. | Pecahan terakhir menunjukkan penyerbuan lewat mata si Pemburu. Pecahan-pecahan menyatu menjadi satu topeng. |
| Q_MQ3_S11_DONE | I faced the Hunter and gave back the name Aria Kebonan. Then the Eclipse took Laras. | Kuhadapi si Pemburu dan kukembalikan nama Aria Kebonan. Lalu Gerhana mengambil Laras. |
| Q_MQ4_S1_DONE | Hariang Banga's riders carried me home to Desa Purwa under the Eclipse. | Pasukan berkuda Hariang Banga membawaku pulang ke Desa Purwa di bawah Gerhana. |
| Q_MQ4_S2_DONE | I wrote three families' names on their doorposts. | Kutuliskan nama tiga keluarga di tiang pintu mereka. |
| Q_MQ4_S3_DONE | I brought Ibu Laras's ribbon, board and Ka strip. She set the second cup straight. | Kubawakan Ibu pita, papan, dan helai Ka milik Laras. Ia menata cangkir kedua dengan benar. |
| Q_MQ4_S4_DONE | Ciung and Hariang ate at my mother's table as brothers. | Ciung dan Hariang makan di meja ibuku sebagai saudara. |
| Q_MQ4_S5_DONE | Semar told me he is a god who chose to be a servant, and sent me south. | Semar bilang ia dewa yang memilih menjadi abdi, dan menyuruhku ke selatan. |
| Q_MQ4_S6_DONE | On the black-sand shore Mbah Wiryo taught me the sea's manners. | Di pantai pasir hitam Mbah Wiryo mengajariku tata krama laut. |
| Q_MQ4_S7_DONE | I gathered three verses of the sea song from three families. | Kukumpulkan tiga bait lagu laut dari tiga keluarga. |
| Q_MQ4_S8_DONE | The lontar showed Wiryo's wife teaching him to call a name into the water. | Lontar menunjukkan istri Wiryo mengajarinya memanggil nama ke dalam air. |
| Q_MQ4_S9_DONE | I crossed the reef. | Kuseberangi karang. |
| Q_MQ4_S10_DONE | At the cliff shrine I heard the queen of the south told as one tale among many. | Di kuil tebing kudengar ratu selatan dituturkan sebagai satu kisah di antara banyak. |
| Q_MQ4_S11_DONE | Laras followed a voice on the water. The sea still says her name. | Laras mengikuti suara di atas air. Laut masih menyebut namanya. |
| Q_MQ4_S12_DONE | I passed the Trial of the Waves and received Ombak and the Kain Hijau. | Kujalani Ujian Ombak dan menerima Ombak serta Kain Hijau. |
| Q_MQ5_S1_DONE | At the cave mouth I replayed the tag game and won back La. | Di mulut gua kuputar ulang kejar-kejaran dan merebut La. |
| Q_MQ5_S2_DONE | I shattered two time-wards on the Hourglass Sands. | Kuhancurkan dua penangkal waktu di Pasir Jam Pasir. |
| Q_MQ5_S3_DONE | In the Abyss of Forgetting I replayed the two cups and won back Ra. | Di Jurang Lupa kuputar ulang dua cangkir dan merebut Ra. |
| Q_MQ5_S4_DONE | At the last petilasan I replayed the written names and won back Sa. | Di petilasan terakhir kuputar ulang nama-nama yang ditulis dan merebut Sa. |
| Q_MQ5_S5_DONE | Semar told the tale of Murwakala: Kala is hungry, not wicked. | Semar menceritakan Murwakala: Kala lapar, bukan jahat. |
| Q_MQ5_S6_DONE | Laras at the bottom of the dark forgot me, but her hand still wrote Ka. | Laras di dasar kegelapan melupakanku, tapi tangannya masih menulis Ka. |
| Q_MQ5_S7_DONE | I became the dalang at Semar's kelir and read the names. | Aku menjadi dalang di kelir Semar dan membacakan nama-nama. |
| Q_MQ5_S8_DONE | I calmed Batara Kala with the Dawn Ruwatan. | Kutenangkan Batara Kala dengan Ruwatan Fajar. |
| Q_MQ5_S9_DONE | I wrote La-Ra-Sa, and Laras came home. | Kutuliskan La-Ra-Sa, dan Laras pulang. |

## 13. Codex (`codex.csv` and `data/codex/<id>.tres`)
**Entries: 29 codex rows.** Not part of the dialogue budget.
Category `enemy` for the first six (they unlock on kill; `_WEAK` is the weakness line), `legend` for the rest (they unlock through `codex:` actions). Each body is 1-3 sentences. `Src` is "legend" (from the traditional stories) or "game" (invented here); a row can be both and says which part is which.

| Id | Title EN / ID | Body EN | Body ID | Src | Weak EN / ID |
|----|---------------|---------|---------|-----|--------------|
| faceless | The Faceless / Wong Tanpa Rupa | Forgotten people. The Hunter holds their names in a lontar bundle at his belt, and they obey whoever holds them. When one falls, a name floats free for a moment. | Orang-orang yang terlupa. Si Pemburu memegang nama mereka dalam seikat lontar di pinggangnya, dan mereka patuh pada siapa pun yang memegangnya. Saat satu tumbang, sebuah nama melayang sesaat. | game | No letter trick: the combo and the dodge. / Tak ada aksara khusus: kombo dan menghindar. |
| faceless_archer | Faceless Archer / Pemanah Tanpa Rupa | A Faceless with a bow that keeps its distance. | Tanpa Rupa berbusur yang menjaga jarak. | game | Close the gap. / Dekati dia. |
| faceless_captain | Faceless Captain / Kapten Tanpa Rupa | He leads the hunt in the west with a long spear and a loud voice, though he has no mouth. | Ia memimpin perburuan di barat dengan tombak panjang dan suara lantang, padahal ia tak bermulut. | game | Ca Burst during his muster breaks the call and stuns him. / Ca saat ia memanggil pasukan memutus seruannya dan membuatnya pusing. |
| barma_wijaya | Prabu Barma Wijaya / Prabu Barma Wijaya | In the legend, the minister Aria Kebonan was made young and given Galuh's throne on one condition, which he broke. Ciung Wanara caged him. The scraped name and the pact with Kala are the game's. | Dalam legenda, patih Aria Kebonan dibuat muda dan diberi takhta Galuh dengan satu syarat, yang ia langgar. Ciung Wanara mengurungnya. Nama yang dikikis dan perjanjian dengan Kala adalah rekaan gim. | legend + game | Any letter breaks a mirror copy. With the copies gone, the real one is open. / Aksara apa pun memecah bayangan cermin. Setelah semuanya pecah, yang asli terbuka. |
| hariang_banga | Hariang Banga / Hariang Banga | Son of Dewi Pangrenyep. In the legend he fought Ciung Wanara to free his mother. Neither won, and the land was split at the river. | Putra Dewi Pangrenyep. Dalam legenda ia melawan Ciung Wanara demi membebaskan ibunya. Tak ada yang menang, dan tanah dibagi di sungai. | legend | Jawa Na dashes through his guard. / Na Jawa menerjang menembus tangkisannya. |
| nameless_hunter | The Nameless Hunter / Si Tanpa Ngaran | Aria Kebonan's true name, given to Kala in a pact and hollowed out. It hunted the one who could write it back. | Nama sejati Aria Kebonan, diserahkan pada Kala lewat perjanjian dan dikosongkan. Ia memburu orang yang bisa menuliskannya kembali. | game | His "forget" seals your last letter for a few seconds. Switch letters often. / "Lupa"-nya mengunci aksara terakhirmu beberapa detik. Sering-seringlah berganti aksara. |
| nagawiru | Nagawiru / Nagawiru | The old king Prabu Permana Di Kusumah left his throne to become a hermit. In the legend he was killed in disguise, became the naga Nagawiru, and hatched Ciung Wanara's egg (**VERIFY**). | Raja tua Prabu Permana Di Kusumah meninggalkan takhta untuk bertapa. Dalam legenda ia dibunuh saat menyamar, menjadi naga Nagawiru, dan menetaskan telur Ciung Wanara (**VERIFY**). | legend | — |
| naganingrum | Dewi Naganingrum / Dewi Naganingrum | The true king's queen and Ciung Wanara's mother. In the legend her newborn was swapped for a puppy and set adrift, and Lengser hid her away. | Permaisuri raja sejati dan ibu Ciung Wanara. Dalam legenda bayinya ditukar dengan anak anjing lalu dihanyutkan, dan Lengser menyembunyikannya. | legend | — |
| ciung_wanara | Ciung Wanara / Ciung Wanara | Set adrift on the Citanduy as a baby and raised by Aki and Nini Balangantrang of Geger Sunten. His name joins two creatures he saw, the ciung bird and the wanara monkey (**VERIFY**). | Dihanyutkan di Citanduy saat bayi dan dibesarkan Aki dan Nini Balangantrang dari Geger Sunten. Namanya gabungan dua makhluk yang ia lihat, burung ciung dan kera wanara (**VERIFY**). | legend | — |
| lengser | Uwa Batara Lengser / Uwa Batara Lengser | The loyal court officer who spared the queen. Lengser is also a figure in Sundanese welcome ceremonies (**VERIFY**). | Abdi istana setia yang menyelamatkan sang permaisuri. Lengser juga tokoh dalam upacara penyambutan Sunda (**VERIFY**). | legend | — |
| pamali | Pamali / Pamali | Pamali: what must not be done. In the legend the brothers' fight was pamali, and the river where the land was split took the name (**VERIFY**: Ci Pamali / Kali Pemali). | Pamali: pantangan, yang tak boleh dilakukan. Dalam legenda perkelahian dua saudara itu pamali, dan sungai tempat tanah dibagi memakai nama itu (**VERIFY**: Ci Pamali / Kali Pemali). | legend | — |
| pangrenyep | Dewi Pangrenyep / Dewi Pangrenyep | The false king's queen and Hariang Banga's mother. In the legend she and the false king were caged by Ciung Wanara (**VERIFY**). | Permaisuri raja palsu dan ibu Hariang Banga. Dalam legenda ia dan raja palsu dikurung oleh Ciung Wanara (**VERIFY**). | legend | — |
| sangkuriang | Sangkuriang / Sangkuriang | The tale of the man who, unknowing, wanted to marry his mother Dayang Sumbi and built a lake and a boat in one night; the false dawn stopped him. The Crater Seal is the game's. | Kisah lelaki yang tak sadar ingin menikahi ibunya, Dayang Sumbi, dan membangun danau serta perahu dalam semalam; fajar palsu menghentikannya. Segel Kawah adalah rekaan gim. | legend + game | — |
| roro_jonggrang | Roro Jonggrang / Roro Jonggrang | Bandung Bondowoso was asked for a thousand temples in a night; the women pounding rice made the roosters crow early, and he fell one short (**VERIFY**). Seal 3 is the game's. | Bandung Bondowoso diminta seribu candi dalam semalam; para perempuan menumbuk padi hingga ayam berkokok lebih awal, dan ia kurang satu (**VERIFY**). Segel 3 adalah rekaan gim. | legend + game | — |
| four_seals | The Four Great Seals / Empat Segel Agung | Four dangerous stories were written down so they would stay finished: the Crater, the Royal Name of Galuh, the Thousand Temples and the Keris. Break one and its legend walks again. You never break a seal, you end the story again. | Empat kisah berbahaya ditulis agar tetap selesai: Kawah, Nama Raja Galuh, Seribu Candi, dan Keris. Segel yang pecah membuat legendanya berjalan lagi. Kau tak pernah memecahkan segel; kau mengakhiri kisahnya sekali lagi. | game (built on four legends) | — |
| eclipse | The Eclipse of Kala / Gerhana Kala | When the fourth seal opened, the sky dimmed and Kala began to eat names, first of whoever read the seals open. Some tellings say Kala swallows the sun at an eclipse (**VERIFY**). Ombak is the one letter it cannot eat. | Saat segel keempat terbuka, langit meredup dan Kala mulai memakan nama, mula-mula milik yang membaca segel. Sebagian penuturan berkata Kala menelan matahari saat gerhana (**VERIFY**). Ombak satu-satunya huruf yang tak bisa dimakannya. | legend + game | — |
| ruwatan | Ruwatan / Ruwatan | Ruwatan is a living Javanese and Sundanese rite of cleansing, often with a wayang performance of the Murwakala tale, to free someone from Kala's grip (**VERIFY**). In the game Kala is calmed and turned back, never killed. | Ruwatan adalah ritus pembersihan yang masih hidup di Jawa dan Sunda, kerap dengan pertunjukan wayang lakon Murwakala, untuk membebaskan seseorang dari cengkeraman Kala (**VERIFY**). Dalam gim, Kala ditenangkan dan dikembalikan, tak pernah dibunuh. | legend | — |
| ki_sumarto | Ki Sumarto / Ki Sumarto | A dalang of Mataram who plays for both banks of the Pamali because his son marches with Hariang Banga. A game character. | Dalang dari Mataram yang pentas untuk kedua tepi Pamali karena putranya berbaris bersama Hariang Banga. Tokoh rekaan gim. | game | — |
| mpu_wirasana | Mpu Wirasana / Mpu Wirasana | A smith in the east who believes every blade remembers what it was made for. Keris makers (empu) are a real tradition, and many keris are held to carry a spirit (**VERIFY**). A game character. | Pandai besi di timur yang yakin setiap bilah ingat untuk apa ia ditempa. Empu pembuat keris adalah tradisi nyata, dan banyak keris diyakini bertuah (**VERIFY**). Tokoh rekaan gim. | game | — |
| mbah_wiryo | Mbah Wiryo / Mbah Wiryo | The juru kunci of the southern coast, who whispers his late wife's name to the sea each dusk. A juru kunci is the real caretaker of a shrine or a sacred place (**VERIFY**). A game character. | Juru kunci pantai selatan, yang membisikkan nama mendiang istrinya ke laut setiap senja. Juru kunci adalah penjaga nyata sebuah tempat keramat (**VERIFY**). Tokoh rekaan gim. | game | — |
| nyi_roro_kidul | Nyi Roro Kidul / Nyi Roro Kidul | Queen of the Southern Sea in Javanese and Sundanese belief, tied to the colour green; many coastal communities keep taboos on green by the shore (**VERIFY**). The game shows her as belief, with respect. She is never fought. | Ratu Laut Selatan dalam kepercayaan Jawa dan Sunda, lekat dengan warna hijau; banyak masyarakat pesisir berpantang memakai hijau di tepi laut (**VERIFY**). Gim menampilkannya sebagai kepercayaan, dengan hormat. Ia tak pernah dilawan. | legend | — |
| hunter_mask | The Empty Mask / Topeng Kosong | A blank mask lying in Ibu's hearth. The Hunter left it behind, and nobody dares to touch it. | Topeng kosong di perapian Ibu. Si Pemburu meninggalkannya, dan tak seorang pun berani menyentuhnya. | game | — |
| laras_wall | Laras's Message / Pesan Laras | Scratched into the cell wall: "The thousand temples. Don't stop." | Tergores di dinding sel: "Seribu candi. Jangan berhenti." | game | — |
| laras_lontar | Laras's Lontar / Lontar Laras | Her palm-leaf strip, with your name on the back. The letters fade as the Curse of Forgetting grows. | Lembar lontar miliknya, dengan namamu di baliknya. Hurufnya memudar seiring Kutukan Lupa menguat. | game | — |
| laras_ribbon | Laras's Ribbon / Pita Laras | Her hair ribbon, caught on the bamboo where she broke free. | Pita rambutnya, tersangkut di bambu tempat ia meloloskan diri. | game | — |
| angklung | Angklung / Angklung | A Sundanese instrument of bamboo tubes in a frame, each tuned to one note; a group plays a tune by each shaking one (**VERIFY**). | Alat musik Sunda dari tabung bambu dalam bingkai, masing-masing satu nada; sekelompok orang memainkan lagu dengan masing-masing menggoyang satu (**VERIFY**). | legend | — |
| pamor | Pamor / Pamor | The layered pattern in a keris blade, made by folding different metals together. Smiths read character into each pattern (**VERIFY**). | Pola berlapis pada bilah keris, hasil melipat beberapa logam. Para empu membaca watak pada tiap pola (**VERIFY**). | legend | — |
| sandekala | Sandekala / Sandekala | In Sundanese belief, a spirit of dusk that takes children who stay outside at maghrib, so parents call them home (**VERIFY**). The lit oncor and the Hunt are the game's. | Dalam kepercayaan Sunda, roh senja yang mengambil anak yang masih di luar saat maghrib, sehingga orang tua memanggil mereka pulang (**VERIFY**). Oncor menyala dan perburuannya rekaan gim. | legend | Light the oncor. / Nyalakan oncor. |
| sedekah_laut | Sea Offering / Sedekah Laut | Coastal communities give thanks to the sea with songs, food and a boat set afloat (sedekah laut, labuhan; **VERIFY**). The village's lost song is the game's. | Masyarakat pesisir bersyukur kepada laut dengan lagu, makanan, dan sebuah perahu yang dilepas (sedekah laut, labuhan; **VERIFY**). Lagu desa yang hilang adalah rekaan gim. | legend | — |

Keep the Faceless codex unlock on the `hunter_raid` beat even though kills would unlock it too.

## 14. Lines dropped
The old keys below are not in this rewrite. Each leaves the CSV only when a grep of `data/`, `ui/`, `entities/`, `zones/`, `autoload/` and `tests/` finds no other reference. Also replaced by this table: the Aji Saka prologue keys `PROLOGUE_6`-`_13`, the data-only hero keys (`_H1`...) from the earlier wiring pass, `NPC_KIDUL_JURUKUNCI_*` and `NPC_KIDUL_ALTAR_1`-`3`/`_H1`, and the retired SQ-S5/SQ-M5 keys.

**Retired cast (v4).** Ki Wangsa is cut, with his keys `DLG_KI_WANGSA_V1`-`_V4`, `DLG_KI_WANGSA_5` and `NPC_KI_WANGSA_NAME` (the `ki_wangsa.tres` file and the `G` spot in `desa_purwa.md` go). The Dayang Sumbi talk at the lake is cut (a Kelir figure only, never met), with `DLG_DAYANG_SUMBI_V6`. Keys that name Abah Karna, Mbah Marto or Mbok Srini are replaced by display-name lines or dropped below.

- `BEAT_CAGE`: 5
- `BEAT_HUNTER_NAME`: 2
- `BEAT_HUNTER_SHRINE`: 2
- `BEAT_TRUCE`: 3
- `BEAT_LARAS_1`: 1, 2
- `BEAT_LARAS_2`: 1, 2
- `BEAT_LARAS_3`: 1, 2
- `BEAT_LARAS_4`: 1, 2
- `BEAT_LARAS_5`: 1, 2
- `BEAT_LARAS_KIDUL`: 1, 2
- `BEAT_QUIET_HOUSE`: 5
- `DLG_BATU_TULIS`: H1, H2
- `DLG_CIUNG_WANARA`: V2
- `DLG_DAYANG_SUMBI`: V1, V2, V3, V4, V5, V6
- `DLG_FACELESS_DESERTER`: H2
- `DLG_IBU`: V3, V1, V9
- `DLG_JURU_KUNCI`: V4, H2, 2
- `DLG_KI_WANGSA`: V1, V2, V3, V4, 5
- `DLG_LENGSER`: V3, H2, V4
- `DLG_LESUNG_WOMEN`: V4, V5, V6, V7, V8, V9, H2
- `DLG_MATARAM_DALANG`: V5, H1
- `DLG_MBOK_SRINI`: V3
- `DLG_NAGANINGRUM`: V1, H2
- `DLG_PAK_KARTO`: V1, V2, V3, V4, V5, V6, V7
- `DLG_SEMAR`: V11, V12, V13, V2, V6, H1, V3, 23
- `DLG_SUNDA_ELDER`: V5, V1, 8
- `DLG_SUNDA_WEAVER`: H2
- `DLG_TIMUR_EMPU`: V4, V5, H2, 6
- `DLG_WIRYO`: H2
- `NPC_KI_WANGSA`: NAME
- `PROLOGUE`: 3, 4, 5
- `Q_MQ0`: S5_HINT

## 15. Side stories (v4d: side quests, Hunts and companion stories)
Lines for the cards in [quests.md](quests.md) section 5 and the camp talks in section 4. Same format as sections 6 to 10: an NPC heading gives its `.tres` id, an `Entry | if | do` table, then `Key | ID | EN`. A bare `@` row is narration. Clue keys are `CLUE_<ID>_1`, `_2`, `_NOTE`; memory keys are `MEM_<ID>_TITLE/_IN/_HINT/_1..n/_OUT`. **Branch flags are ASSUMED:** `sq_<id>_peaceful` and `sq_<id>_fight`, set by the branch step. **Rule 10:** a clue names a creature only where the card says so (S2 `_2`, M2 `_2`, M3 `_2`, T1 `_2`, T2 `_2`, G2 `_2`); before that the hook text speaks of "the crying", "the sweeping", "the tearing". No spoken text uses a cut name. Keys DLG_<NPC>_V20+ avoid the older keys in sections 6 to 10. New speakers' display names are in section 3. The elite fights have no extra talk lines. Journal titles stay in section 12 and `quests.csv`; they are not touched here.

### Tatar Sunda

### SQ-S1 "Lutung Kasarung" (retelling, M)
#### ki_darsa (the village, juru pantun; name NPC_KI_DARSA_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_s1=4` (report) | |
| 2 | `quest:sq_s1=active` | |
| 3 | `quest:sq_s1=available`, `flag:mq1_3` | `start:sq_s1` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KI_DARSA_V20 | Kulit gadis itu pulih. Ia sendiri tertawa, lama sekali. | The girl's skin is healed. She laughed, for a long time. |
| 1 | DLG_KI_DARSA_V21 | Si lutung hitam itu sebenarnya makhluk surgawi yang menyamar. Wajah pinjaman, Nak. Begitu kisahnya. | The black langur was a heavenly being in disguise. A borrowed face, child. So the tale goes. |
| 1 | DLG_KI_DARSA_V22 | Terimalah iket ini. Pantas dipakai orang yang melihat wajah sebenarnya. | Take this iket. It suits someone who sees the true face. |
| 2 | DLG_KI_DARSA_V23 | Sumber air itu tersembunyi. Dan jangan lupa persembahannya di depan pintu. | The spring is hidden. And don't forget the offerings at her door. |
| 3 | DLG_KI_DARSA_V24 | Salam, Nak. Aku Ki Darsa, juru pantun. Aku menyanyikan kisah lama dari desa ke desa. | Greetings, child. I'm Ki Darsa, a juru pantun. I sing the old tales from village to village. |
| 3 | DLG_KI_DARSA_V25 | Di tepi hutan ada gadis berkulit belang. Seekor lutung hitam menolak pergi dari sisinya. Ia tak mengusirnya. | At the forest's edge lives a girl with spotted skin. A black langur won't leave her side. She doesn't chase him off. |
| 3 | DLG_KI_DARSA_V26 | Lihat persembahan di depan pintunya, lalu cari sumber air yang tersembunyi. | See the offerings at her door, then find the hidden spring. |
| 4 | DLG_KI_DARSA_V27 | Kisah lama itu masih ada. Aku hanya menyanyikannya. | The old tales are still here. I only sing them. |

VERIFY: the juru pantun role, the cure by bathing, and the names Purbasari, Purbararang and Guruminda.

#### Clues S1
| Key | ID | EN |
|-----|----|----|
| CLUE_S1_OFFERINGS_1 | Buah liar dan bunga tertata rapi di ambang pintu. Ada jejak tangan berbulu hitam di tanah. | Wild fruit and flowers lie neatly on the doorstep. A black furry handprint is pressed in the dirt. |
| CLUE_S1_OFFERINGS_2 | Seseorang meninggalkannya tiap pagi, tanpa pernah mengetuk. | Someone leaves them every morning, and never knocks. |
| CLUE_S1_OFFERINGS_NOTE | Persembahan di pintu gadis itu, dari tangan berbulu. | Offerings at the girl's door, from a furry hand. |
| CLUE_S1_SPRING_1 | Mata air jernih di balik semak, tapi sosok-sosok pucat berkerumun di sekelilingnya. | A clear spring behind the bushes, but pale figures crowd around it. |
| CLUE_S1_SPRING_2 | Air ini pasti menyembuhkan sesuatu. Para sosok itu tak ingin ada yang sampai ke sini. | This water must heal something. The figures don't want anyone to reach it. |
| CLUE_S1_SPRING_NOTE | Mata air tersembunyi, dijaga sosok-sosok pucat. | A hidden spring, guarded by pale figures. |

#### Purbasari (at the spring; name NPC_PURBASARI_NAME; step 3 (0-based), `talked_to:purbasari`)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_s1=3` | |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_PURBASARI_V20 | Airnya hangat. Lihat, kulitku... | The water is warm. Look, my skin... |
| 1 | DLG_PURBASARI_V21 | Lutung itu menuntunku ke sini. Ia selalu tahu jalan. | The langur led me here. He always knew the way. |
| 1 | DLG_PURBASARI_V22 | Aku tak pernah mengusirnya. Aku merasa ia bukan hanya seekor lutung. | I never sent him away. I felt he was more than a langur. |
| 2 | DLG_PURBASARI_V23 | Terima kasih, Nak. Sekarang aku bisa pulang. | Thank you, child. Now I can go home. |

#### Memory `sq_s1_lutung` (play; kelir figure: the lutung; the action clears the way to the spring)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_S1_LUTUNG_TITLE | Lutung dan Mata Air | The Langur and the Spring |
| MEM_SQ_S1_LUTUNG_IN | Dengarkan kisah ini, Nak: seekor lutung menuntun seorang gadis ke mata air. Bersihkan jalannya. | Hear this tale, child: a langur leads a girl to a spring. Clear the way. |
| MEM_SQ_S1_LUTUNG_HINT | Bersihkan jalannya | Clear the way |
| MEM_SQ_S1_LUTUNG_1 | Gadis itu berjalan perlahan. Lutung berlari di depan, mengusir kabut dari semak. | The girl walks slowly. The langur runs ahead, shooing mist from the bushes. |
| MEM_SQ_S1_LUTUNG_2 | Di mata air, ia menepi. Ia hanya ingin gadis itu sampai dengan selamat. | At the spring, he steps aside. All he wants is for her to arrive safely. |
| MEM_SQ_S1_LUTUNG_3 | Gadis itu mandi. Kulitnya berseri, dan lutung menunduk, bahagia. | The girl bathes. Her skin glows, and the langur bows his head, glad. |
| MEM_SQ_S1_LUTUNG_OUT | Begitulah ceritanya: ia tak pernah meminta imbalan. Ia hanya membantu. | So the tale goes: he never asked for anything. He only helped. |

### SQ-S2 "Tangis di Rumpun Bambu" / "Crying in the Bamboo" (side Hunt, L)
#### kepala_desa (the village; name NPC_KEPALA_DESA_NAME; replace the side-quest entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_s2=4` (report) | |
| 2 | `quest:sq_s2=active` | |
| 3 | `quest:sq_s2=available`, `flag:mq1_3` | `start:sq_s2` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KEPALA_DESA_V20 | Rumpun itu senyap. Aku mengukir nama di batu itu, supaya yang tidur tahu ia dikenang. | The grove is quiet. I carved a name on the stone, so the one who sleeps there knows she is remembered. |
| 1 | DLG_KEPALA_DESA_V21 | Terimalah golok dan kantong ramuan ini. Kau pantas membawanya. | Take this golok and herb pouch. You've earned them. |
| 2 | DLG_KEPALA_DESA_V22 | Wangi kembang di kuburan tanpa nama. Kain putih di bambu. Itu petunjukku. | The flower scent at a grave with no name. A white cloth on the bamboo. Those are my clues. |
| 3 | DLG_KEPALA_DESA_V23 | Di rumpun bambu itu ada tangis bayi tiap malam. Padahal tak ada rumah di sana. | In the bamboo grove a baby cries every night. And no house stands there. |
| 3 | DLG_KEPALA_DESA_V24 | Aku tak berani mendekat. Kau? | I don't dare go near. Will you? |
| 3 | DLG_KEPALA_DESA_V25 | Cium wangi kembang di kuburan tanpa nama, dan periksa kain putih di bambu. | Smell the flower scent at the unmarked grave, and check the white cloth on the bamboo. |
| 4 | DLG_KEPALA_DESA_V26 | Desa ini tenang. Biarlah begitu. | The village is calm. Let it stay that way. |

#### Clues S2
| Key | ID | EN |
|-----|----|----|
| CLUE_S2_CEMPAKA_1 | Wangi cempaka pekat di atas gundukan tanah tanpa nisan. Tak ada yang menanamnya. | A heavy cempaka scent hangs over a mound with no marker. Nobody planted any. |
| CLUE_S2_CEMPAKA_2 | Seseorang dikubur di sini tanpa nama. Tangisnya tetap tinggal. | Someone was buried here without a name. The crying stayed behind. |
| CLUE_S2_CEMPAKA_NOTE | Gundukan tanpa nisan, berbau cempaka. | A mound with no marker, smelling of cempaka. |
| CLUE_S2_WHITE_CLOTH_1 | Kain putih sobek tersangkut di bambu, setinggi dua orang berdiri. Ujungnya masih basah. | A torn white cloth snags on the bamboo, two people high. The hem is still wet. |
| CLUE_S2_WHITE_CLOTH_2 | Ini kuntilanak, hantu perempuan berbaju putih yang menangis seperti bayi untuk memancing orang. | This is a kuntilanak, a ghost in white who cries like a baby to lure people. |
| CLUE_S2_WHITE_CLOTH_NOTE | Kain putih di bambu: kuntilanak. | A white cloth on the bamboo: a kuntilanak. |

VERIFY: kuntilanak as pan-Indonesian folklore; the tree she is tied to varies (bamboo, waru or another).

#### Memory `sq_s2_grandmother` (play; kelir figure: a grandmother; the action keeps to the lit ground)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_S2_GRANDMOTHER_TITLE | Nenek di Rumpun Bambu | The Grandmother in the Bamboo |
| MEM_SQ_S2_GRANDMOTHER_IN | Dengarkan kisah ini, Nak: seorang nenek melewati rumpun itu tiap malam. Ikuti ia, dan lihat di mana ia melangkah. | Hear this tale, child: a grandmother crosses the grove every night. Follow her, and see where she steps. |
| MEM_SQ_S2_GRANDMOTHER_HINT | Injak tanah terang | Step on lit ground |
| MEM_SQ_S2_GRANDMOTHER_1 | Tangisan memanggil dari balik bambu. Nenek itu tidak menoleh. | The crying calls from behind the bamboo. The grandmother doesn't turn. |
| MEM_SQ_S2_GRANDMOTHER_2 | Ia hanya melangkah di tanah yang disinari bulan. Dari bayang-bayang, sosok putih tak bisa menyentuhnya. | She steps only where the moon shines. From the shadows, the white figure can't touch her. |
| MEM_SQ_S2_GRANDMOTHER_3 | Pagi tiba. Nenek itu pulang, dan sosok itu pun tetap menangis sendirian. | Morning comes. The grandmother goes home, and the figure keeps crying alone. |
| MEM_SQ_S2_GRANDMOTHER_OUT | Begitulah ceritanya: tanah terang adalah tempat aman. Jangan pernah masuk ke bayangan. | So the tale goes: lit ground is safe ground. Never walk into the shadow. |

**ASSUMED:** the lit-ground rule is a game rule unless a source is found (VERIFY).

### SQ-S3, SQ-S4 (errands): checked, see "Errand check".

### Keraton Galuh

### SQ-G1 "Si Kabayan di Alun-alun" (retelling, comic, M)
#### kabayan (alun-alun, sprawled by the stalls; name NPC_KABAYAN_NAME; new)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_g1=5` (report) | |
| 2 | `quest:sq_g1=active` | |
| 3 | `quest:sq_g1=available`, `flag:mqg_0` | `start:sq_g1` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KABAYAN_V20 | Aku menang, kan? Sekarang... aku tidur lagi. | I won, didn't I? Now... back to sleep. |
| 2 | DLG_KABAYAN_V21 | Maklumat dan keranjangku. Kau lihat, belum kau lihat? Jangan berisik. | The decree and my basket. Have you looked? Not yet? Don't be loud. |
| 3 | DLG_KABAYAN_V22 | Ssst. Aku sedang tidur. Aku Si Kabayan. | Shh. I'm sleeping. I'm Si Kabayan. |
| 3 | DLG_KABAYAN_V23 | Pejabat itu berteriak bahwa aku melanggar maklumatnya. Aku bahkan belum bangun. | That official shouts that I broke his decree. I haven't even woken up. |
| 3 | DLG_KABAYAN_V24 | Lihat maklumat di tembok, dan keranjang yang belum selesai kuanyam. | Look at the decree on the wall, and the basket I haven't finished weaving. |
| 4 | DLG_KABAYAN_V25 | Zzz. Pergilah, aku sedang bermimpi bagus. | Zzz. Go away, I'm having a good dream. |

#### galuh_official (the official, alun-alun; name NPC_GALUH_OFFICIAL_NAME; new)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_g1=4` | |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_GALUH_OFFICIAL_V20 | Maklumat itu melarang rebah di tanah. Siapa pun! | The decree forbids lying on the ground. Anyone! |
| 1 | DLG_GALUH_OFFICIAL_V21 | Hmm. Ia berbaring di keranjang gantung. Keranjang itu bukan tanah. | Hmm. He lies in a hanging basket. A basket isn't the ground. |
| 1 | DLG_GALUH_OFFICIAL_V22 | Baiklah. Aku kalah. Kerumunan, jangan menertawakanku. | Very well. I lose. Crowd, stop laughing at me. |
| 2 | DLG_GALUH_OFFICIAL_V23 | Aku tak ingin membahas itu. | I don't want to talk about it. |

#### Clues G1
| Key | ID | EN |
|-----|----|----|
| CLUE_G1_DECREE_1 | Maklumat di tembok: "Dilarang rebah di tanah di alun-alun. Tertanda pejabat." | The decree on the wall: "No lying on the ground in the alun-alun. Signed, the official." |
| CLUE_G1_DECREE_2 | Hanya tanah yang dilarang. Maklumat itu tak menyebut yang lain. | It forbids only the ground. The decree says nothing else. |
| CLUE_G1_DECREE_NOTE | Maklumat melarang rebah di tanah. | The decree forbids lying on the ground. |
| CLUE_G1_BASKET_1 | Keranjang rotan setengah teranyam, cukup besar untuk satu orang. Talinya masih baru. | A half-woven rattan basket, big enough for one person. The rope is still new. |
| CLUE_G1_BASKET_2 | Keranjang ini cukup kuat digantung di dahan. | This basket would hold if hung from a branch. |
| CLUE_G1_BASKET_NOTE | Keranjang setengah jadi, cukup besar untuk satu orang. | A half-woven basket, big enough for one person. |

#### Memory `sq_g1_kabayan` (play; kelir figure: Si Kabayan; the action hangs the basket)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_G1_KABAYAN_TITLE | Kabayan dan Maklumat | Kabayan and the Decree |
| MEM_SQ_G1_KABAYAN_IN | Dengarkan kisah ini, Nak: si pemalas diperintah untuk tidak berbaring. Gantung keranjangnya. | Hear this tale, child: the lazy one is ordered not to lie down. Hang the basket. |
| MEM_SQ_G1_KABAYAN_HINT | Gantung keranjangnya | Hang the basket |
| MEM_SQ_G1_KABAYAN_1 | Maklumatnya jelas: dilarang rebah di tanah. Kabayan menguap. | The decree is clear: no lying on the ground. Kabayan yawns. |
| MEM_SQ_G1_KABAYAN_2 | Ia menggantung keranjang di dahan, lalu naik dan berbaring. | He hangs a basket from a branch, climbs in, and lies down. |
| MEM_SQ_G1_KABAYAN_3 | Pejabat itu membuka mulut, lalu menutupnya lagi. Ia tak punya jawaban. | The official opens his mouth, then shuts it. He has no answer. |
| MEM_SQ_G1_KABAYAN_OUT | Begitulah ceritanya: cerdik itu mengubah perintah menjadi bantal. | So the tale goes: the clever one turns an order into a pillow. |

VERIFY: which Kabayan tale; the decree and basket tale is ASSUMED as a game retelling.

### SQ-G2 "Ririwa Kaputren" / "The Ririwa of the Kaputren" (side Hunt, two-way, L)
#### kaputren_maid (inner palace corridor; name NPC_KAPUTREN_MAID_NAME; new)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_g2=5`, `flag:sq_g2_peaceful` | |
| 2 | `step:sq_g2=5`, `flag:sq_g2_fight` | |
| 3 | `quest:sq_g2=active` | |
| 4 | `quest:sq_g2=available`, `flag:mqg_4` | `start:sq_g2` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KAPUTREN_MAID_V20 | Sapu itu tergantung di kaitnya. Pagi ini lorongnya sunyi. | The broom hangs on its hook. The hall is quiet this morning. |
| 1 | DLG_KAPUTREN_MAID_V21 | Ia pernah punya nama. Aku akan menyebutnya sekali saja: Canga. | He had a name once. I'll say it just once: Canga. |
| 2 | DLG_KAPUTREN_MAID_V22 | Lorongnya tenang. Daftar itu masih tergores. | The hall is calm. The roll is still scraped. |
| 2 | DLG_KAPUTREN_MAID_V23 | Aku tak ingin membahasnya. | I don't want to talk about it. |
| 3 | DLG_KAPUTREN_MAID_V24 | Sapu dan daftar. Jika kau periksa keduanya, kau mungkin paham. | The broom and the roll. If you check both, you may understand. |
| 4 | DLG_KAPUTREN_MAID_V25 | Tiap malam ada yang menyapu lorong perempuan ini. Pagi harinya gagang sapunya aus. | Every night someone sweeps this women's hall. By morning the broom is worn to the handle. |
| 4 | DLG_KAPUTREN_MAID_V26 | Aku tak pernah melihat siapa. Aku hanya mendengar sapuannya. | I've never seen who. I only hear the sweeping. |
| 4 | DLG_KAPUTREN_MAID_V27 | Lihat sapu yang aus itu, dan daftar para pelayan di rak. | See the worn broom, and the servants' roll on the shelf. |
| 5 | DLG_KAPUTREN_MAID_V28 | Kaputren ini selalu sepi. Aku sudah terbiasa. | The kaputren is always quiet. I'm used to it. |

#### Clues G2
| Key | ID | EN |
|-----|----|----|
| CLUE_G2_BROOM_1 | Gagang sapu aus sampai tipis, sehalus kaca. Sapunya sendiri tinggal sehelai lidi. | The broom handle is worn thin, smooth as glass. The brush itself is down to one straw. |
| CLUE_G2_BROOM_2 | Seseorang menyapu di sini lebih lama dari satu hidup. | Someone has swept here longer than a lifetime. |
| CLUE_G2_BROOM_NOTE | Sapu yang aus sampai gagangnya. | A broom worn down to the handle. |
| CLUE_G2_ROLL_1 | Daftar para pelayan. Satu nama dikikis habis, tapi tinta bekasnya masih terasa di kertas: dua huruf. | The servants' roll. One name is scraped out, but the ink's trace still shows on the paper: two letters. |
| CLUE_G2_ROLL_2 | Ririwa, kata orang: hantu yang terus mengerjakan tugas lamanya sampai ada yang mengingat namanya. | A ririwa, they say: a ghost who keeps doing his old chore until someone remembers his name. |
| CLUE_G2_ROLL_NOTE | Nama pelayan dikikis; hantunya ririwa. Tinta menyisakan dua huruf. | A servant's name scraped out; the ghost is a ririwa. The ink leaves two letters. |

VERIFY: ririwa as a Sundanese ghost term, and its description here.

#### Memory `sq_g2_servant` (play; kelir figure: the servant; the action sweeps while nobody says his name)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_G2_SERVANT_TITLE | Hari Terakhir si Penyapu | The Sweeper's Last Day |
| MEM_SQ_G2_SERVANT_IN | Dengarkan kisah ini, Nak: seorang pelayan menyapu sepanjang hari, dan tak seorang pun memanggil namanya. Sapulah, dan dengarkan. | Hear this tale, child: a servant sweeps all day, and nobody calls his name. Sweep, and listen. |
| MEM_SQ_G2_SERVANT_HINT | Sapu, dan dengarkan | Sweep, and listen |
| MEM_SQ_G2_SERVANT_1 | Pagi: "Hei, kau!" Siang: "Kau, sini!" Sore: "Pelayan!" | Morning: "Hey, you!" Noon: "You, here!" Evening: "Servant!" |
| MEM_SQ_G2_SERVANT_2 | Namanya hanya ada di sehelai daftar, ditulis dengan dua huruf: Ca dan Nga. | His name exists only on a roll, written with two letters: Ca and Nga. |
| MEM_SQ_G2_SERVANT_3 | Suatu malam daftar itu dikikis. Ia tetap menyapu, tapi lorong itu tak lagi mengingatnya. | One night the roll is scraped. He keeps sweeping, but the hall no longer remembers him. |
| MEM_SQ_G2_SERVANT_OUT | Begitulah ceritanya: namanya tertulis dengan Ca dan Nga. Tulislah kembali. | So the tale goes: his name is written with Ca and Nga. Write it back. |

#### ririwa_roll (kaputren hall, a shelf with the roll; write card; name NPC_RIRIWA_ROLL_NAME; new)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_g2=4`, `!flag:sq_g2_fight`, `!flag:name_ririwa_name` | `write:ririwa_name:sunda_ca,sunda_nga`, `flag:name_ririwa_name` |
| 2 | `name_written:ririwa_name` | `flag:sq_g2_peaceful` |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_RIRIWA_ROLL_V20 | Tinta bekasnya masih ada. Dua huruf, Ca dan Nga. | The ink's trace is still there. Two letters, Ca and Nga. |
| 1 | DLG_RIRIWA_ROLL_V21 | Tulislah nama itu kembali di daftar. | Write the name back on the roll. |
| 2 | DLG_RIRIWA_ROLL_V22 | Namanya Canga. Sapu itu berhenti. | His name is Canga. The sweeping stops. |
| 3 | DLG_RIRIWA_ROLL_V23 | Sebuah daftar pelayan, rapi dan tenang. | A servants' roll, neat and quiet. |

VERIFY: the name "Canga" (ASSUMED, Sundanese letters Ca and Nga); Ca and Nga both exist as core glyphs.

### Mataram

### SQ-M1 "Jaka Tarub dan Nawang Wulan" (retelling, M)
#### nawang_wulan (rice-farming household; name NPC_NAWANG_WULAN_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_m1=3` (report) | |
| 2 | `quest:sq_m1=active` | |
| 3 | `quest:sq_m1=available`, `flag:mq2_1` | `start:sq_m1` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_NAWANG_WULAN_V20 | Selendang itu ada di sana, di bawah beras terakhir. Suamiku menyembunyikannya, lama sekali. | The shawl was there, under the last of the rice. My husband hid it, long ago. |
| 1 | DLG_NAWANG_WULAN_V21 | Jaka Tarub namanya. Ia baik hati, tapi satu rahasia kecil bisa mengosongkan sebuah periuk. | Jaka Tarub is his name. He's kind, but one small secret can empty a pot. |
| 1 | DLG_NAWANG_WULAN_V22 | Aku pulang ke langit. Terimalah selendang tenunku, semoga ringan langkahmu. | I'm going home to the sky. Take my woven scarf, and may your steps be light. |
| 2 | DLG_NAWANG_WULAN_V23 | Periuk dan lumbung, Nak. Lihat keduanya. | The pot and the lumbung, child. Look at both. |
| 3 | DLG_NAWANG_WULAN_V24 | Selamat datang. Maaf, aku sedang menatap periuk ini. | Welcome. Sorry, I was staring at this pot. |
| 3 | DLG_NAWANG_WULAN_V25 | Dulu sebutir beras mengisinya penuh. Hari ini kosong. | Once a single grain of rice filled it to the brim. Today it's empty. |
| 3 | DLG_NAWANG_WULAN_V26 | Aku mengangkat tutupnya, lalu memalingkan muka. Lihatlah periuk dan lumbungnya, kalau kau mau. | I lifted the lid, then looked away. See the pot and the lumbung, if you will. |
| 4 | DLG_NAWANG_WULAN_V27 | Padi tumbuh subur di sawah ini. Rasanya damai. | The rice grows well in these fields. It feels peaceful. |

VERIFY: all beats of the legend (one grain filling the pot, the hidden shawl, her return to the sky), Nawang Wulan as a bidadari shown with respect, and the legend's location.

#### Clues M1
| Key | ID | EN |
|-----|----|----|
| CLUE_M1_POT_LID_1 | Tutup periuk terangkat sedikit, bertumpu pada sebutir beras. Tak ada uap. | The pot's lid sits lifted, propped on a single grain of rice. No steam. |
| CLUE_M1_POT_LID_2 | Isinya kosong. Periuk ini bergantung pada tutupnya yang tertutup. | It's empty. This pot depended on its lid staying shut. |
| CLUE_M1_POT_LID_NOTE | Tutup periuk terangkat; periuk kosong. | The pot's lid is lifted; the pot is empty. |
| CLUE_M1_RICE_GONE_1 | Lumbung hampir kosong. Padi turun sekaligus, seperti dituang dari atas. | The lumbung is almost empty. The rice went down all at once, as if poured from above. |
| CLUE_M1_RICE_GONE_2 | Padi tidak dicuri. Padi pergi sendiri, seperti mengikuti sesuatu. | The rice wasn't stolen. It went by itself, as if following something. |
| CLUE_M1_RICE_GONE_NOTE | Padi di lumbung turun sekaligus. | The lumbung's rice went down all at once. |

#### Memory `sq_m1_selendang` (play; kelir figure: Nawang Wulan; the action shifts the rice)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_M1_SELENDANG_TITLE | Selendang di Bawah Padi | The Shawl Under the Rice |
| MEM_SQ_M1_SELENDANG_IN | Dengarkan kisah ini, Nak: seorang bidadari mencari selendangnya di lumbung. Singkirkan padinya. | Hear this tale, child: a celestial maiden looks for her shawl in the lumbung. Move the rice. |
| MEM_SQ_M1_SELENDANG_HINT | Singkirkan padi | Move the rice |
| MEM_SQ_M1_SELENDANG_1 | Padi menumpuk tinggi di lumbung. Nawang Wulan mencari tanpa suara. | The rice is piled high in the lumbung. Nawang Wulan searches without a sound. |
| MEM_SQ_M1_SELENDANG_2 | Tangannya menyentuh sesuatu yang halus dan dingin. | Her hand touches something fine and cool. |
| MEM_SQ_M1_SELENDANG_3 | Selendang itu, kusut tapi utuh. Ia memeluknya sejenak. | The shawl, creased but whole. She holds it for a moment. |
| MEM_SQ_M1_SELENDANG_OUT | Begitulah ceritanya: ia tak marah. Ia hanya pulang. | So the tale goes: she isn't angry. She just goes home. |

### SQ-M2 "Anak yang Tak Dipanggil" / "The Child Nobody Called" (side Hunt, two-way, L)
#### m2_neighbour (a worried neighbour; name NPC_M2_NEIGHBOUR_NAME; new, replaces `wewe_neighbor`)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_m2=4`, `flag:sq_m2_peaceful` (bring the boy home) | |
| 2 | `step:sq_m2=4`, `flag:sq_m2_fight` | |
| 3 | `quest:sq_m2=active` | |
| 4 | `quest:sq_m2=available`, `flag:mq2_2` | `start:sq_m2` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_M2_NEIGHBOUR_V20 | Ia pulang! Ibunya menggandengnya, dan ia menangis. | He's home! His mother holds his hand, and she's crying. |
| 1 | DLG_M2_NEIGHBOUR_V21 | Mereka berjanji memanggilnya tiap petang. Itu yang ia butuhkan. | They promise to call him every evening. That's what he needed. |
| 1 | DLG_M2_NEIGHBOUR_V22 | Terimalah jimat ini. Yang pantas dibawa orang yang mau mendengarkan. | Take this jimat. It suits someone who stops to listen. |
| 2 | DLG_M2_NEIGHBOUR_V23 | Anak itu pulang. Ibunya diam saja. | The boy is home. His mother says nothing. |
| 2 | DLG_M2_NEIGHBOUR_V24 | Terimalah jimat ini. Aku tak tahu harus bilang apa lagi. | Take this jimat. I don't know what else to say. |
| 3 | DLG_M2_NEIGHBOUR_V25 | Mainannya di jalan bukit. Orang tuanya di rumah, tanyalah mereka. | His toy's on the hill path. His parents are at home, ask them. |
| 4 | DLG_M2_NEIGHBOUR_V26 | Anak tetanggaku hilang. Ibunya baru sadar petang tadi, padahal ia pergi sejak pagi. | My neighbour's boy is gone. His mother only noticed this evening, though he left in the morning. |
| 4 | DLG_M2_NEIGHBOUR_V27 | Tak ada yang memanggilnya. Itu saja yang bisa kukatakan. | Nobody called him. That's all I can say. |
| 4 | DLG_M2_NEIGHBOUR_V28 | Lihat mainannya di jalan bukit, dan bicaralah pada orang tuanya. | See his toy on the hill path, and speak to his parents. |
| 5 | DLG_M2_NEIGHBOUR_V29 | Pasar ramai, tapi anak-anak butuh dipandang. | The market's lively, but children need to be looked at. |

#### m2_parents_1 (the boy's parents, at their stall; name NPC_M2_PARENTS_NAME; new)
Step 2 talk (`talked_to:m2_parents_1`), after the neighbour's offer.
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_m2=1` | |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_M2_PARENTS_V30 | Kami sibuk di lapak, Nak. Rasanya baru sebentar. | We were busy at the stall, child. It felt like only a moment. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_M2_PARENTS_H30 | Kapan terakhir kalian memanggilnya? | When did you last call his name? |
| 1 | @NPC_M2_PARENTS_NAME | | |
| 1 | DLG_M2_PARENTS_V31 | Tak ada yang memanggilnya. Kami... tak sempat. Cari mainannya di jalan bukit. | Nobody called him. We... never had time. Look for his toy on the hill path. |
| 2 | DLG_M2_PARENTS_V32 | Hari ini banyak pembeli. Tapi hati kami sepi. | Plenty of buyers today. But our hearts are quiet. |

#### wewe_parents_2 (the hill; peaceful `alt`, step 4; the same parents; name NPC_M2_PARENTS_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_m2=3`, `!flag:sq_m2_fight` | `flag:sq_m2_peaceful` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_M2_PARENTS_V40 | Nak, pulanglah. Ibu dan Bapak di sini! | Child, come home. Mother and Father are here! |
| 1 | DLG_M2_PARENTS_V41 | Maafkan kami yang lalai. Kami pukul panci ini supaya kau tahu jalan pulang. | Forgive us for neglecting you. We bang this pot so you'll know the way home. |
| 1 | @ | | |
| 1 | DLG_M2_PARENTS_N1 | Dari balik batu, seorang anak berlari ke pelukan mereka. Di belakangnya, sesosok perempuan tua berambut panjang melepaskan genggamannya dan mundur ke dalam gelap. | From behind a stone, a boy runs into their arms. Behind him, an old woman with long hair lets go of his hand and steps back into the dark. |
| 2 | DLG_M2_PARENTS_V42 | Kami akan lebih sering memanggilnya. Janji. | We'll call him more often. A promise. |

#### Clues M2
| Key | ID | EN |
|-----|----|----|
| CLUE_M2_TOY_1 | Kuda-kudaan kayu kecil tergeletak di jalan bukit. Seutas kertas terikat di lehernya: "Jaga dia. Tak ada yang memanggilnya." | A little wooden toy horse lies on the hill path. A strip of paper is tied round its neck: "Look after him. Nobody calls him." |
| CLUE_M2_TOY_2 | Catatan itu untuk Wewe Gombel, hantu yang kata orang membawa anak terlantar ke bukit. Bukan untuk menyakiti, katanya. | The note is for Wewe Gombel, the ghost who, they say, takes neglected children up the hill. Not to harm them, the tale says. |
| CLUE_M2_TOY_NOTE | Mainan anak di jalan bukit; catatan untuk Wewe Gombel. | A boy's toy on the hill path; a note for Wewe Gombel. |

(The second clue is the talk with the parents above: `talked_to:m2_parents_1`; it has no `CLUE_` keys.)

VERIFY: Wewe Gombel as a spirit who takes neglected children, not to harm them (the card's framing).

#### Memory `sq_m2_child` (play; kelir figure: the neglected child; the action follows a kind voice, then a clanging pot)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_M2_CHILD_TITLE | Suara yang Memanggil | The Voice That Called |
| MEM_SQ_M2_CHILD_IN | Dengarkan kisah ini, Nak: seorang anak yang tak dipanggil mengikuti suara lembut ke atas bukit. Ikuti, dan dengarkan. | Hear this tale, child: a child nobody called follows a soft voice up the hill. Follow, and listen. |
| MEM_SQ_M2_CHILD_HINT | Ikuti suara itu | Follow the voice |
| MEM_SQ_M2_CHILD_1 | Di rumah, tak ada yang menoleh. Di bukit, ada suara yang memanggil namanya pelan-pelan. | At home, nobody turns. On the hill, a voice calls his name, softly. |
| MEM_SQ_M2_CHILD_2 | Anak itu naik. Di bawah, orang tuanya memukul panci dan memanggil: pulang, pulang. | The boy climbs. Below, his parents bang a pot and call: come home, come home. |
| MEM_SQ_M2_CHILD_3 | Bunyi panci sampai ke bukit. Anak itu menoleh, lalu turun. | The pot's clang reaches the hill. The boy turns, and comes down. |
| MEM_SQ_M2_CHILD_OUT | Begitulah ceritanya: panggil dengan lembut, pukul panci, dan yang tersesat akan menemukan jalan pulang. | So the tale goes: call gently, bang a pot, and the lost one finds the way home. |

VERIFY: calling kindly and banging pots as a folk practice.

### SQ-M3 "Uang yang Hilang di Pasar" / "Coins Gone from the Market" (side Hunt, two-way, M)
#### m3_smith (a pande besi with a market stall; name NPC_M3_SMITH_NAME; new, replaces `pande_besi`)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_m3=4`, `flag:sq_m3_peaceful` (report) | |
| 2 | `step:sq_m3=4`, `flag:sq_m3_fight` | |
| 3 | `quest:sq_m3=active` | |
| 4 | `quest:sq_m3=available`, `flag:mq2_1` | `start:sq_m3` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_M3_SMITH_V20 | Pemimpin tuyul itu menghitung kacang sampai pagi? Aku tak percaya. | The tuyul's leader counted beans till morning? I can't believe it. |
| 1 | DLG_M3_SMITH_V21 | Koinku kembali. Ambil tombak dari bengkelku, kau pantas memegangnya. | My coins are back. Take a spear from my forge, you've earned it. |
| 2 | DLG_M3_SMITH_V22 | Pasar sunyi dan koinku tetap di laci. Terima kasih. | The market is quiet and my coins stay in the drawer. Thank you. |
| 2 | DLG_M3_SMITH_V23 | Ambil tombak ini. Jangan bilang siapa-siapa dari mana asalnya. | Take this spear. Don't tell anyone where it came from. |
| 3 | DLG_M3_SMITH_V24 | Abu tungku dan kacang tumpah. Lihat dua-duanya. | The hearth ash and the spilled beans. Look at both. |
| 4 | DLG_M3_SMITH_V25 | Aku pande besi. Koin di lapakku lenyap, padahal mataku tak lepas darinya. | I'm a pande besi. Coins vanish from my stall while my eyes never leave it. |
| 4 | DLG_M3_SMITH_V26 | Aku tak melihat apa-apa. Siapa pun yang mengambilnya, ia cepat. | I see nothing. Whoever takes them is quick. |
| 4 | DLG_M3_SMITH_V27 | Lihat abu di tungku, dan kacang hijau yang tumpah di dekat lapak. | See the ash in my hearth, and the green beans spilled near the stall. |
| 5 | DLG_M3_SMITH_V28 | Besi kutempa, koin kujaga. | I forge iron and guard my coins. |

#### Clues M3
| Key | ID | EN |
|-----|----|----|
| CLUE_M3_FOOTPRINTS_1 | Jejak kaki telanjang, sangat kecil, di abu tungku. Kecil seperti kaki anak tiga tahun. | Tiny bare footprints in the hearth ash. As small as a three-year-old's. |
| CLUE_M3_FOOTPRINTS_2 | Tak ada anak sekecil itu di pasar ini. | No child that small lives in this market. |
| CLUE_M3_FOOTPRINTS_NOTE | Jejak kaki kecil di abu tungku. | Tiny footprints in the hearth ash. |
| CLUE_M3_BEANS_1 | Kacang hijau tumpah di tanah, separuhnya berjajar rapi, seperti sedang dihitung. | Green beans spilled on the ground, half of them in neat rows, as if being counted. |
| CLUE_M3_BEANS_2 | Tuyul, pencuri uang kecil yang usil, kata orang. Ia tak tahan menghitung. | A tuyul, a mischievous little money thief, they say. It can't stop counting. |
| CLUE_M3_BEANS_NOTE | Kacang hijau setengah terhitung: ulah tuyul. | Green beans half counted: a tuyul's work. |

#### Memory `sq_m3_tuyul` (play; kelir figure: a tuyul; the action spills the beans at its feet)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_M3_TUYUL_TITLE | Si Penghitung Kecil | The Little Counter |
| MEM_SQ_M3_TUYUL_IN | Dengarkan kisah ini, Nak: seorang tuyul disuruh majikan serakah mencuri koin. Perhatikan apa yang membuatnya berhenti. | Hear this tale, child: a tuyul sent by a greedy master to steal coins. Watch what makes it stop. |
| MEM_SQ_M3_TUYUL_HINT | Tebar kacang hijau | Scatter the green beans |
| MEM_SQ_M3_TUYUL_1 | Majikannya menyuruh: ambil, ambil, ambil. Tuyul itu menurut. | The master orders: take, take, take. The tuyul obeys. |
| MEM_SQ_M3_TUYUL_2 | Di jalan, kacang tumpah. Ia berhenti. Satu, dua, tiga... Ia tak bisa melewatinya. | On the road, beans spill. It stops. One, two, three... It can't walk past them. |
| MEM_SQ_M3_TUYUL_3 | Majikan menunggu sampai fajar. Tuyulnya masih menghitung. | The master waits until dawn. The tuyul is still counting. |
| MEM_SQ_M3_TUYUL_OUT | Begitulah ceritanya: ia harus berhenti untuk menghitung. Tebarkan kacang, dan ia terjebak dalam hitungannya sendiri. | So the tale goes: it must stop to count. Scatter the beans, and it's trapped in its own counting. |

VERIFY: beans or crabs as the counting distraction (**ASSUMED** beans).

### SQ-M4 "Gamelan yang Bisu" (errand): checked, see "Errand check".

### Tanah Timur

### SQ-T1 "Ande-Ande Lumut" (retelling, side Hunt, two-way, M)
#### klething_kuning (at the riverbank; name NPC_KLETHING_KUNING_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_t1=4`, `flag:sq_t1_peaceful` (she crosses) | |
| 2 | `step:sq_t1=4`, `flag:sq_t1_fight` | |
| 3 | `quest:sq_t1=active` | |
| 4 | `quest:sq_t1=available`, `flag:mq3_1` | `start:sq_t1` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KLETHING_KUNING_V20 | Kupukul airnya dengan sodo lanang, dan sungai surut. Aku tak tahu ia sehebat itu. | I struck the water with the sodo lanang, and the river drew back. I didn't know it could. |
| 1 | DLG_KLETHING_KUNING_V21 | Terima kasih. Terimalah cincin ini. Sekarang aku bisa menemui Ande-Ande Lumut. | Thank you. Take this ring. Now I can go and meet Ande-Ande Lumut. |
| 2 | DLG_KLETHING_KUNING_V22 | Kepiting itu menyelam ke dasar. Jalan terbuka. | The crab dove to the bottom. The way is open. |
| 2 | DLG_KLETHING_KUNING_V23 | Terimalah cincin ini. Aku menyeberang sekarang. | Take this ring. I'm crossing now. |
| 3 | DLG_KLETHING_KUNING_V24 | Goresan di dermaga, dan bungkusanku. Kau boleh lihat. | The marks on the jetty, and my bundle. You may look. |
| 4 | DLG_KLETHING_KUNING_V25 | Aku Klething Kuning. Talinya putus, dan aku harus menyeberang. Ada seseorang yang ingin kutemui, Ande-Ande Lumut. | I'm Klething Kuning. The rope's cut, and I have to cross. There's someone I want to meet, Ande-Ande Lumut. |
| 4 | DLG_KLETHING_KUNING_V26 | Aku membawa bungkusan. Isinya... rahasia. | I'm carrying a bundle. What's in it... is a secret. |
| 4 | DLG_KLETHING_KUNING_V27 | Lihat goresan di dermaga. Dan bungkusanku, kalau kau janji tidak tertawa. | See the marks on the jetty. And my bundle, if you promise not to laugh. |
| 5 | DLG_KLETHING_KUNING_V28 | Sungai ini panjang dan sepi. | This river is long and quiet. |

#### Clues T1
| Key | ID | EN |
|-----|----|----|
| CLUE_T1_CLAW_MARKS_1 | Goresan lebar dan dalam di papan dermaga, searah dengan tali yang putus. Capit. | Wide, deep gouges across the jetty planks, along the cut rope. Pincers. |
| CLUE_T1_CLAW_MARKS_2 | Dari ukurannya, ini Yuyu Kangkang, kepiting raksasa yang minta "bayaran" dari setiap yang menyeberang. | From the size, this is Yuyu Kangkang, a giant crab who demands a "payment" from everyone who crosses. |
| CLUE_T1_CLAW_MARKS_NOTE | Goresan capit di dermaga: Yuyu Kangkang, kepiting raksasa. | Pincer marks on the jetty: Yuyu Kangkang, a giant crab. |
| CLUE_T1_SODO_1 | Dalam bungkusannya hanya ada sebatang lidi sapu panjang. Sodo lanang, lidi dari seorang perempuan tua. | The bundle holds only one long broom stick. A sodo lanang, a stick from an old woman. |
| CLUE_T1_SODO_2 | Terlalu rapi untuk lidi biasa. Ia dijaga seperti benda yang bisa memerintah air. | Too neat for an ordinary stick. It's guarded like something that can command water. |
| CLUE_T1_SODO_NOTE | Bungkusan Klething Kuning berisi sodo lanang, lidi sapu. | Klething Kuning's bundle holds a sodo lanang, a broom stick. |

VERIFY: the sodo lanang, who gave it and what it does; Yuyu Kangkang as the crab; the crab asks for "a payment" (child-friendly), not a kiss.

#### Memory `sq_t1_klething` (play; kelir figure: Klething Kuning; the action strikes the water)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_T1_KLETHING_TITLE | Lidi dari Tangan Tua | The Stick from an Old Hand |
| MEM_SQ_T1_KLETHING_IN | Dengarkan kisah ini, Nak: seorang gadis menerima sodo lanang dan diajari memakainya. Perhatikan sungainya. | Hear this tale, child: a girl is given a sodo lanang and shown how to use it. Watch the river. |
| MEM_SQ_T1_KLETHING_HINT | Pukul permukaan air | Strike the water |
| MEM_SQ_T1_KLETHING_1 | Seorang perempuan tua menyerahkan sebatang lidi sapu pada gadis yang bingung. | An old woman hands a broom stick to a puzzled girl. |
| MEM_SQ_T1_KLETHING_2 | "Pukul airnya," katanya, "jangan yang menghadangmu." | "Strike the water," she says, "not the one who blocks you." |
| MEM_SQ_T1_KLETHING_3 | Gadis itu memukul permukaan sungai. Airnya surut seperti napas yang dihembuskan. | The girl strikes the river's surface. The water draws back like a breath let out. |
| MEM_SQ_T1_KLETHING_OUT | Begitulah ceritanya: pukul air, dan sungai membuka jalan. | So the tale goes: strike the water, and the river makes a way. |

### SQ-T2 "Api Tanpa Angin" / "Fire With No Wind" (side Hunt, L)
#### t2_herder (the herder; name NPC_T2_HERDER_NAME; new, replaces `timur_herder`)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_t2=4` (report) | |
| 2 | `quest:sq_t2=active` | |
| 3 | `quest:sq_t2=available`, `flag:mq3_1` | `start:sq_t2` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_T2_HERDER_V20 | Apinya padam. Rumput akan tumbuh lagi. | The fire is out. The grass will grow back. |
| 1 | DLG_T2_HERDER_V21 | Domba-dombaku mulai merumput lagi. Ambil kantong ramuan ini. | My sheep are grazing again. Take this herb pouch. |
| 2 | DLG_T2_HERDER_V22 | Jejak hangus dan api unggun yang tak ada yang menyalakannya. Itu petunjuknya. | The burnt trail and the campfire nobody lit. Those are your clues. |
| 3 | DLG_T2_HERDER_V23 | Rumputku terbakar membentuk garis, padahal tak ada angin. | My grass burns in a line, and there's no wind. |
| 3 | DLG_T2_HERDER_V24 | Aku tak berani mendekat malam hari. Dombaku pun tak mau. | I don't dare go near at night. My sheep won't either. |
| 3 | DLG_T2_HERDER_V25 | Lihat jejak hangusnya, dan api unggun yang tak seorang pun nyalakan. | Look at the burnt trail, and the campfire nobody lit. |
| 4 | DLG_T2_HERDER_V26 | Dombaku gelisah, tapi sabana ini tetap indah. | My sheep are restless, but the savanna is still beautiful. |

#### Clues T2
| Key | ID | EN |
|-----|----|----|
| CLUE_T2_BURN_TRAIL_1 | Garis hangus di rumput, lurus, lalu berputar kembali ke tempat semula. Seperti sesuatu yang mencari jalan pulang. | A scorched line through the grass, straight, then curling back to where it began. Like something looking for the way home. |
| CLUE_T2_BURN_TRAIL_2 | Tak ada angin, tapi garisnya melingkar. Apinya bergerak sendiri. | There's no wind, yet the line curls. The fire moves by itself. |
| CLUE_T2_BURN_TRAIL_NOTE | Jejak hangus melingkar di rumput, tanpa angin. | A scorched trail circles in the grass, with no wind. |
| CLUE_T2_CAMPFIRE_1 | Api unggun menyala di tengah padang, tapi tak ada kayu, tak ada orang, tak ada asap. | A campfire burns in the middle of the plain, but there's no wood, no people, no smoke. |
| CLUE_T2_CAMPFIRE_2 | Api yang berjalan sendiri. Banaspati, kata orang: bola api berkepala yang membuntuti sendirian di malam hari. | A fire that walks by itself. A banaspati, they say: a head of flame that trails travellers alone at night. |
| CLUE_T2_CAMPFIRE_NOTE | Api unggun tanpa kayu: banaspati, bola api berkepala. | A campfire with no wood: a banaspati, a head of flame. |

VERIFY: the banaspati description; not tied to the Tengger or Bromo rituals.

#### Memory `sq_t2_herder` (play; kelir figure: a herder boy; the action leads the fire to the spring)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_T2_HERDER_TITLE | Anak Gembala dan Api | The Herder Boy and the Fire |
| MEM_SQ_T2_HERDER_IN | Dengarkan kisah ini, Nak: seorang anak gembala belajar bahwa api tak mau menyeberangi air yang mengalir. Cari mata airnya. | Hear this tale, child: a herder boy learns that fire won't cross running water. Find the spring. |
| MEM_SQ_T2_HERDER_HINT | Menuju mata air | Go to the spring |
| MEM_SQ_T2_HERDER_1 | Api mengejar dombanya. Anak gembala berlari sampai napasnya habis. | The fire chases his sheep. The herder boy runs until he's out of breath. |
| MEM_SQ_T2_HERDER_2 | Ia melompati parit kecil. Api berhenti di tepinya, mendesis. | He leaps a small stream. The fire stops at the edge, hissing. |
| MEM_SQ_T2_HERDER_3 | Anak itu duduk di seberang, aman, menatap api yang menunggu. | The boy sits on the far side, safe, watching the fire wait. |
| MEM_SQ_T2_HERDER_OUT | Begitulah ceritanya: air yang mengalir menahannya. Tuntun ia ke mata air di sabana. | So the tale goes: running water holds it back. Lead it to the savanna's spring. |

**ASSUMED:** the fire and running water motif is a game retelling.

### SQ-T3, SQ-T4 (errands): checked, see "Errand check".

### Segara Kidul

### SQ-K1 "Tukik Pulang ke Laut" (errand, S)
#### kidul_nelayan_anak (sk_pantai; name NPC_KIDUL_NELAYAN_ANAK_NAME; no lines existed, new)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_k1=3` (report) | |
| 2 | `quest:sq_k1=active` | |
| 3 | `quest:sq_k1=available`, `flag:mq4_4` | `start:sq_k1` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KIDUL_NELAYAN_ANAK_V20 | Mereka sampai ke ombak! Ia membawa mereka pergi. | They reached the surf! It carried them away. |
| 1 | DLG_KIDUL_NELAYAN_ANAK_V21 | Kata kakekku, penyu selalu ingat pantai tempat ia menetas. Ini kantong ramuan untukmu. | My grandfather says a turtle always remembers the beach where it hatched. Here's a herb pouch for you. |
| 2 | DLG_KIDUL_NELAYAN_ANAK_V22 | Tiga tukik, ingat. Mereka masih di bukit pasir. | Three tukik, remember. They're still in the dunes. |
| 3 | DLG_KIDUL_NELAYAN_ANAK_V23 | Lihat, tukik, anak penyu, tersesat di bukit pasir. Mereka belum menemukan laut. | Look, tukik, baby turtles, are lost in the dunes. They haven't found the sea yet. |
| 3 | DLG_KIDUL_NELAYAN_ANAK_V24 | Aku harus menjaga jaring. Tolong bawa tiga ekor ke ombak. | I have to mind the nets. Please carry three of them to the surf. |
| 4 | DLG_KIDUL_NELAYAN_ANAK_V25 | Laut ramai hari ini. | The sea is busy today. |

VERIFY: turtles returning to their hatching beach (nesting beaches such as Pangumbahan or Sukamade).

### SQ-K2 "Jaring yang Robek" / "The Torn Nets" (side Hunt, L)
#### k2_fisher (river mouth; name NPC_K2_FISHER_NAME; new)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_k2=5` (report) | |
| 2 | `quest:sq_k2=active` | |
| 3 | `quest:sq_k2=available`, `flag:mq4_4` | `start:sq_k2` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_K2_FISHER_V20 | Ia mundur ke laut dalam. Jaring kami tak robek lagi. | It drew back into the deep. Our nets aren't torn any more. |
| 1 | DLG_K2_FISHER_V21 | Kami menebar jaring lagi. Hasil pertama kami taruh di pasir untuknya. | We cast again. The first catch we leave on the sand for it. |
| 2 | DLG_K2_FISHER_V22 | Sisik putih dan Mbah Wiryo. Dua-duanya akan menjawab. | The white scale and Mbah Wiryo. Both will answer you. |
| 3 | DLG_K2_FISHER_V23 | Jaring kami robek dari dalam, tiap malam. Tak ada yang berani menebar di muara. | Our nets are torn from the inside, every night. Nobody dares cast at the river mouth. |
| 3 | DLG_K2_FISHER_V24 | Lihat sisik putih yang tersangkut di jaring. Lalu tanyakan pada juru kunci pantai. | See the white scale caught in the net. Then ask the juru kunci of the shore. |
| 4 | DLG_K2_FISHER_V25 | Muara ini indah, kalau sedang tenang. | The river mouth is lovely when it's calm. |

#### kidul_jurukunci, one-line entry (Mbah Wiryo; first entry for the K2 step; cond `step:sq_k2=2`, `"quiet": true`; do `flag:sq_k2_wiryo`)
| Key | ID | EN |
|-----|----|----|
| DLG_WIRYO_V20 | Yang tua penjaga muara itu? Bajul putih, buaya putih. Ia sudah di sana sebelum kita. | The old one who keeps the river mouth? The bajul putih, the white crocodile. It was there before us. |

#### Clues K2
| Key | ID | EN |
|-----|----|----|
| CLUE_K2_SCALE_1 | Sebuah sisik putih sebesar telapak tangan, tersangkut di jaring yang robek. Tepinya basah, seperti baru lepas. | A white scale as big as a hand, snagged in the torn net. The edge is wet, as if just shed. |
| CLUE_K2_SCALE_2 | Sesuatu yang besar dan tua melewati jaring ini dari dalam air. | Something big and old passed through this net from the water. |
| CLUE_K2_SCALE_NOTE | Sisik putih sebesar tangan di jaring yang robek. | A hand-sized white scale in the torn net. |

#### Memory `sq_k2_fisher` (play; kelir figure: a fisher; the action leaves an offering, then reads the tide)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_K2_FISHER_TITLE | Persembahan di Muara | The Offering at the River Mouth |
| MEM_SQ_K2_FISHER_IN | Dengarkan kisah ini, Nak: seorang nelayan menaruh persembahan di muara. Perhatikan air pasangnya. | Hear this tale, child: a fisher leaves an offering at the river mouth. Watch the tide. |
| MEM_SQ_K2_FISHER_HINT | Baca air pasang | Read the tide |
| MEM_SQ_K2_FISHER_1 | Ia menaruh nasi di atas daun pisang dan menunduk, tanpa kata. | He sets rice on a banana leaf and bows his head, saying nothing. |
| MEM_SQ_K2_FISHER_2 | Air surut sejenak, seperti menarik napas. | The water draws back a moment, like a breath taken. |
| MEM_SQ_K2_FISHER_3 | Setelah itu air menderu maju. Ia sudah mundur ke pasir, tepat waktu. | Then the water rushes forward. He has already stepped back onto the sand, just in time. |
| MEM_SQ_K2_FISHER_OUT | Begitulah ceritanya: air surut dulu, lalu menerjang. Ingat itu saat ia datang. | So the tale goes: the water draws back first, then charges. Remember it when it comes. |

VERIFY: the offering at the river mouth as belief, told with respect; the white crocodile in the Aji Saka legend; the tide tell is a game rule (ASSUMED).

### Companion stories

### SQ-C1 "Ayam Jago Ciung" / "Ciung's Rooster" (Act II, M)
#### ciung_wanara (entries for C1; placed after his main-path entries, before the last; name NPC_CIUNG_WANARA_NAME)
| Entry | if | do |
|-------|----|----|
| c1_done | `step:sq_c1=5` | |
| c1_hook | `quest:sq_c1=available`, `flag:mqg_a1` | `start:sq_c1` |
| c1_wait | `quest:sq_c1=active` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| c1_done | DLG_CIUNG_WANARA_V30 | Ia kembali. Ayam itu satu-satunya keluarga yang kutahu aku punya. | He's back. That rooster is the only family I knew I had. |
| c1_done | DLG_CIUNG_WANARA_V31 | Terima kasih. Kau tak membawa dia ke gelanggang, kan? Bagus. | Thank you. You didn't take him to the ring, did you? Good. |
| c1_hook | DLG_CIUNG_WANARA_V32 | Bertenggernya kosong. Ia kabur sebelum turnamen. | His perch is empty. He ran off before the tournament. |
| c1_hook | DLG_CIUNG_WANARA_V33 | Ia tak suka keramaian. Cari bulunya di lapak penjual ayam, dan keranjang sungai di alun-alun. | He hates crowds. Look for his feathers at the rooster seller's stall, and the river basket in the alun-alun. |
| c1_wait | DLG_CIUNG_WANARA_V34 | Aku tak bisa meninggalkan perannya. Tolong cari dia. | I can't leave my part. Please find him. |

#### Beat `c1_rooster_found` (area `c1_rooster_found`; narration)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_C1_ROOSTER_FOUND_1 | Di balik tumpukan jerami, seekor ayam jantan bertengger tenang. Ia menatapmu, lalu mengikutimu tanpa suara. | Behind a stack of straw, a rooster sits calmly. He looks at you, then follows you without a sound. |

#### Clues C1
| Key | ID | EN |
|-----|----|----|
| CLUE_C1_FEATHERS_1 | Bulu panjang berkilat, hitam dengan ujung emas, tersangkut di lapak penjual ayam. Ada jejak kaki kecil menuju gang belakang. | Long glossy feathers, black with gold tips, snagged at the rooster seller's stall. Small footprints lead into the back lane. |
| CLUE_C1_FEATHERS_2 | Si penjual bilang burung itu lewat dengan angkuh, tanpa membeli apa-apa. | The seller says the bird strutted past, buying nothing. |
| CLUE_C1_FEATHERS_NOTE | Bulu hitam-emas di lapak ayam. | Black and gold feathers at the rooster stall. |
| CLUE_C1_BASKET_1 | Sebuah keranjang rotan kecil hanyut di tepi sungai alun-alun. Anak-anak menggunakannya untuk bermain kapal. | A small rattan basket drifts at the alun-alun's river edge. Children use it to play boats. |
| CLUE_C1_BASKET_2 | Ada sebutir telur kayu di dalamnya, buatan anak-anak. Entah kenapa terasa penting. | A wooden egg sits inside, made by the children. Somehow it feels important. |
| CLUE_C1_BASKET_NOTE | Keranjang hanyut dengan telur kayu. | A drifting basket with a wooden egg. |

#### Memory `sq_c1_basket` (play; kelir figure: a baby in a basket; the action holds the egg)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_C1_BASKET_TITLE | Bayi di Keranjang | The Baby in the Basket |
| MEM_SQ_C1_BASKET_IN | Dengarkan kisah ini, Nak: seorang bayi hanyut di sungai dalam keranjang, memeluk sebutir telur. Jaga telurnya. | Hear this tale, child: a baby drifts down the river in a basket, holding an egg. Keep the egg safe. |
| MEM_SQ_C1_BASKET_HINT | Jaga telurnya | Keep the egg safe |
| MEM_SQ_C1_BASKET_1 | Arus membawa keranjang menjauh dari tepi. Bayi itu memeluk telur erat-erat. | The current carries the basket from the bank. The baby holds the egg tight. |
| MEM_SQ_C1_BASKET_2 | Batu-batu mendekat. Keranjang berputar, tapi telurnya tak jatuh. | Rocks draw near. The basket spins, but the egg doesn't fall. |
| MEM_SQ_C1_BASKET_3 | Di tikungan sungai, telur itu retak. Seekor anak ayam keluar dan berkokok. | At a bend in the river, the egg cracks. A chick steps out and crows. |
| MEM_SQ_C1_BASKET_OUT | Begitulah ceritanya: dari telur itulah ayam jagonya datang. | So the tale goes: from that egg came the rooster. |

VERIFY: the Ciung Wanara motif (the egg that became the rooster); the baby set adrift on a river.

### SQ-C2 "Surat untuk Ibu" / "Letters to Mother" (Acts III-IV, M, cross-zone)
#### hariang_banga, C2 entries (after the truce, `quest:mq2=done`; new; name NPC_HARIANG_BANGA_NAME)
| Entry | if | do |
|-------|----|----|
| c2_done | `step:sq_c2=3` | |
| c2_hook | `quest:sq_c2=available`, `quest:mq2=done` | `start:sq_c2` |
| c2_wait | `quest:sq_c2=active` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| c2_done | DLG_HARIANG_BANGA_V10 | Ibu membalas? Aku belum berani membaca. | Mother replied? I haven't dared read it. |
| c2_hook | DLG_HARIANG_BANGA_V11 | Ada seikat surat yang tak pernah kukirim. Untuk ibuku. | There's a bundle of letters I never sent. For my mother. |
| c2_hook | DLG_HARIANG_BANGA_V12 | Ia dikurung di Galuh. Bisakah kau membawanya? | She's caged in Galuh. Can you take them? |
| c2_wait | DLG_HARIANG_BANGA_V13 | Sampaikan pada ibuku. Itu saja. | Take them to my mother. That's all. |

#### galuh_queen (the cage in Galuh; name NPC_GALUH_QUEEN_NAME; new; step 2 `talked_to:galuh_queen`)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_c2=2`, `flag:choice_mercy` | `flag:c2_reply` |
| 2 | `step:sq_c2=2`, `flag:choice_silent` | `flag:c2_reply` |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_GALUH_QUEEN_V20 | Surat dari anakku. Kau datang dengan belas kasihan. | Letters from my son. You came with mercy. |
| 1 | DLG_GALUH_QUEEN_V21 | Tunggulah. Aku akan menulis balasan sederhana, supaya ia tahu aku masih ada. | Wait. I'll write a short reply, so he knows I'm still here. |
| 2 | DLG_GALUH_QUEEN_V22 | Surat dari anakku. Kau tak berkata apa-apa. Baiklah. | Letters from my son. You say nothing. Very well. |
| 2 | DLG_GALUH_QUEEN_V23 | Aku menulis balasan juga. Letakkan di mejanya, kalau ia ingin membacanya. | I'll write a reply too. Leave it on his table, if he wants to read it. |
| 3 | DLG_GALUH_QUEEN_V24 | Waktu terasa panjang di kandang ini. | Time feels long in this cage. |

#### Clue C2
| Key | ID | EN |
|-----|----|----|
| CLUE_C2_REPLY_LETTER_1 | Sepucuk surat terlipat di samping cangkir kedua. Tulisan tangannya halus, bukan milik Ibu. | A letter lies folded by the second cup. The handwriting is fine, not Ibu's. |
| CLUE_C2_REPLY_LETTER_2 | "Anakku, aku mendapat suratmu semua. Aku baik-baik saja. Pulanglah kalau sempat." | "My son, I got all your letters. I'm well. Come home if you can." |
| CLUE_C2_REPLY_LETTER_NOTE | Balasan sang permaisuri, di samping cangkir kedua. | The queen's reply, by the second cup. |

### SQ-C3 "Nama si Pembelot" / "The Deserter's Name" (Acts III-VI, L, chain)
Lines per act are quiet. The variants share the clue ids; the handed variant uses the `B` keys. Ranga is spoken only after the write card.
#### faceless_deserter (freed variant, `flag:choice_freed`; quiet entries; name NPC_FACELESS_DESERTER_NAME)
| Entry | if | do |
|-------|----|----|
| c3_a | `flag:mq2_7`, `flag:choice_freed`, `!flag:c3_a` | `flag:c3_a` |
| c3_b | `flag:mq3_6`, `flag:choice_freed`, `zone:tt_pasir`, `!flag:c3_b` | `flag:c3_b` |
| c3_c | `flag:mq4_4`, `flag:choice_freed`, `zone:sk_pantai`, `!flag:c3_c` | `flag:c3_c` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| c3_a | DLG_DESERTER_V20 | Aku berjalan di pinggir kemah. Kalau kau tahu nama yang cocok untukku, ucapkan. | I walk at the camp's edge. If you know a name that fits me, say it. |
| c3_b | DLG_DESERTER_V21 | Jalan ini panjang. Aku masih mencari bunyi yang cocok. | The road is long. I'm still looking for a sound that fits. |
| c3_c | DLG_DESERTER_V22 | Ombak menyebut sesuatu. Aku hampir tahu. | The waves are saying something. I almost know. |

#### Clues C3, freed
| Key | ID | EN |
|-----|----|----|
| CLUE_C3_CAMP_SCRAP_1 | Secarik kain di tali jemuran, dijahit dengan satu bunyi: "Ra." | A scrap of cloth on a washing line, stitched with one sound: "Ra." |
| CLUE_C3_CAMP_SCRAP_2 | Seseorang menjahitnya berulang-ulang, seperti belajar mengucapkannya. | Someone stitched it again and again, as if learning to say it. |
| CLUE_C3_CAMP_SCRAP_NOTE | Kain berjahit bunyi "Ra". | A cloth stitched with the sound "Ra". |
| CLUE_C3_ROAD_MARK_1 | Sebuah batu di tepi jalan, digores dengan bunyi lain: "Nga." | A stone by the road, scratched with another sound: "Nga." |
| CLUE_C3_ROAD_MARK_2 | Goresannya baru. Orang itu lewat di sini, lalu pergi lagi. | The scratch is fresh. The man passed here, then went on. |
| CLUE_C3_ROAD_MARK_NOTE | Batu bergores bunyi "Nga". | A stone scratched with the sound "Nga". |
| CLUE_C3_SHORE_NET_1 | Jaring nelayan di pasir hitam, dengan dua simpul besar yang membentuk dua bunyi: Ra dan Nga. | A fishing net on the black sand, tied in two big knots that make two sounds: Ra and Nga. |
| CLUE_C3_SHORE_NET_2 | Tiga petunjuk, dan tiga-tiganya bunyi yang sama. Tinggal menuliskannya. | Three clues, all the same sounds. All that's left is to write them. |
| CLUE_C3_SHORE_NET_NOTE | Jaring dengan simpul "Ra" dan "Nga". | A net with knots for "Ra" and "Nga". |

#### Clues C3, handed (Lengser's note; keys with `B`)
| Key | ID | EN |
|-----|----|----|
| CLUE_C3_CAMP_SCRAP_B_1 | Catatan Lengser terselip di kemah: "Si pembelot di sel terus mengucap satu bunyi. Ra." | Lengser's note, tucked in the camp: "The deserter in the cell keeps saying one sound. Ra." |
| CLUE_C3_CAMP_SCRAP_B_2 | Ia mengucapkannya seperti seseorang yang ingin diingat. | He says it like someone who wants to be remembered. |
| CLUE_C3_ROAD_MARK_B_1 | Catatan kedua: "Ia mengucap bunyi lain. Nga." Tulisannya di sebuah batu di tepi jalan. | A second note: "He says another sound. Nga." It's on a stone by the road. |
| CLUE_C3_ROAD_MARK_B_2 | Dari sel yang jauh, bunyi itu sampai ke jalan ini. | From a distant cell, the sound reaches this road. |
| CLUE_C3_SHORE_NET_B_1 | Catatan ketiga, terikat pada jaring: "Ia berhenti berbicara. Dua bunyi saja yang tersisa." | A third note, tied to the net: "He's stopped speaking. Only two sounds remain." |
| CLUE_C3_SHORE_NET_B_2 | Ra dan Nga. Tiga petunjuk sudah cukup untuk menuliskannya. | Ra and Nga. Three clues are enough to write it. |

#### deserter_stone (Gua Kala mouth `gk_mulut`; write card; name NPC_DESERTER_STONE_NAME; new)
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq5_1`, `flag:c3_a`, `flag:c3_b`, `flag:c3_c`, `!flag:name_deserter_name` | `write:deserter_name:jawa_ra,sunda_nga`, `flag:name_deserter_name` |
| 2 | `name_written:deserter_name`, `flag:choice_freed` | `flag:deserter_named` |
| 3 | `name_written:deserter_name`, `flag:choice_handed` | `flag:deserter_named` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_DESERTER_STONE_V20 | Sebuah batu pipih di mulut gua. Tiga petunjuk menunjuk dua bunyi: Ra dan Nga. | A flat stone at the cave mouth. Three clues point to two sounds: Ra and Nga. |
| 1 | DLG_DESERTER_STONE_V21 | Tulislah, supaya ia mendengar. | Write it, so he can hear. |
| 2 | DLG_DESERTER_STONE_V22 | Ranga. Ia berdiri di sampingmu, dan akhirnya mendengar namanya. | Ranga. He stands beside you, and at last he hears his name. |
| 3 | DLG_DESERTER_STONE_V23 | Ranga. Hanya batu yang mendengarnya. Di Galuh, sebuah sel menjadi sunyi. | Ranga. Only the stone hears it. In Galuh, a cell goes quiet. |
| 4 | DLG_DESERTER_STONE_V24 | Batu pipih yang dingin. | A flat, cold stone. |

ASSUMED: the Deserter's name Ranga (an ordinary Sundanese name). Steps 2 and 3 set `flag:deserter_named`; `deserter_mouth` says V1 ("I remembered my name") only after it, V2 before ("Staging NPCs").

### SQ-C4 "Cepot Si Pemberani" (chain, parts 2 and 3)
#### cepot, C4 entries (name NPC_CEPOT_NAME)
| Entry | if | do |
|-------|----|----|
| c4_3_done | `step:sq_c4_3=3` | `flag:c4_done` |
| c4_3_wait | `quest:sq_c4_3=active` | |
| c4_3_hook | `quest:sq_c4_3=available`, `flag:c4_2`, `flag:mq4_4` | `start:sq_c4_3` |
| c4_2_done | `step:sq_c4_2=4` | `flag:c4_2` |
| c4_2_wait | `quest:sq_c4_2=active` | |
| c4_2_hook | `quest:sq_c4_2=available`, `flag:c4_1`, `flag:mq2_a1` | `start:sq_c4_2` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| c4_2_hook | DLG_CEPOT_V20 | Aku daftar jadi prajurit di dua sisi sekaligus! Pasar sungai ini hebat. | I signed up as a soldier on both sides at once! This river market is great. |
| c4_2_hook | DLG_CEPOT_V21 | Eh, kata mereka itu masalah. Lihat daftarnya, lalu bantu aku keluar sebelum ada yang sadar. | Er, they say that's a problem. See the rolls, then help me out before anyone notices. |
| c4_2_wait | DLG_CEPOT_V22 | Jangan berisik. Mereka masih mencari-cari. | Don't be loud. They're still looking around. |
| c4_2_done | DLG_CEPOT_V23 | Aku selamat! Aku memang pemberani. Sedikit. | I'm safe! I'm brave, you know. A little. |
| c4_3_hook | DLG_CEPOT_V24 | Aku mengikutimu sampai ke pantai! Tapi lautnya besar sekali. Aku takut. | I followed you all the way to the beach! But the sea is so big. I'm scared. |
| c4_3_hook | DLG_CEPOT_V25 | Tukik-tukik itu butuh cahaya. Pegang lenteranya dengan aku, ya? | The hatchlings need light. Hold the lamp with me, will you? |
| c4_3_wait | DLG_CEPOT_V26 | Sedikit lagi. Jangan lepaskan lenteranya. | Nearly there. Don't let go of the lamp. |
| c4_3_done | DLG_CEPOT_V27 | Ombaknya lewat, dan aku masih di sini. Nanti kuceritakan ke semua orang! | The wave passed, and I'm still here. I'll tell everyone! |

#### Clues C4 (part 2)
| Key | ID | EN |
|-----|----|----|
| CLUE_C4_ROLL_A_1 | Daftar perekrut Sunda di pasar sungai. Di bagian bawah, tertulis dengan huruf besar-besar: "Cepot." | The Sunda recruiter's roll at the river market. At the bottom, in large letters: "Cepot." |
| CLUE_C4_ROLL_A_2 | Ia mendaftarkan diri tanpa membaca syaratnya. | He signed up without reading the terms. |
| CLUE_C4_ROLL_A_NOTE | Nama Cepot di daftar perekrut Sunda. | Cepot's name on the Sunda recruiter's roll. |
| CLUE_C4_ROLL_B_1 | Daftar perekrut Jawa. Di bagian bawah lagi: "Cepot", dengan hiasan di huruf pertama. | The Java recruiter's roll. At the bottom again: "Cepot," with a flourish on the first letter. |
| CLUE_C4_ROLL_B_2 | Dua daftar, satu nama. Kalau ketahuan, ia akan dalam kesulitan. | Two rolls, one name. If found out, he'll be in trouble. |
| CLUE_C4_ROLL_B_NOTE | Nama Cepot di daftar perekrut Jawa. | Cepot's name on the Java recruiter's roll. |

VERIFY: Cepot's humor as in wayang golek (no new culture claim). The lamp over the hatchlings' beach reuses SQ-K1's area, with the same conservation note.

### Errand check (S3, S4, M4, T3, T4, K1)
Lines checked in `data/text/dialogue.csv` against the cards: S3 (angklung leader) and S4 (Cepot) match their cards; M4 giver is Ki Sumarto (rule 10 satisfied: the dalang is shown in the market before he is named); T3 and T4 match. No mismatch found that needs a text change here; K1 had no lines, so the rows are in SQ-K1 above. VERIFY: turtles return to the beach where they hatched.

### Replaced keys
The v4d lines replace the old side-quest keys `DLG_KI_DARSA_1` to `_12`, `DLG_KEPALA_DESA_1` to `_15`, `DLG_WEWE_*`, `DLG_PANDE_BESI_*`, `DLG_KLETHING_KUNING_*`, `DLG_TIMUR_HERDER_*`, the side-quest rows of `DLG_NAWANG_WULAN_*` and `DLG_PURBASARI_*`. They named creatures or cut names before rule 10 allowed them. Remove them from `data/text/dialogue.csv` when the CSV is regenerated.

### Epilogue and codex rows (C3, C4)
All ASSUMED; the epilogue budget in section 11 is 40 lines.
| Key | ID | EN |
|-----|----|----|
| EPILOGUE_C3_FREED | Ranga menunggu di mulut gua. Kini ada yang memanggilnya dengan namanya. | Ranga waits at the cave mouth. Now someone calls him by his name. |
| EPILOGUE_C4 | Cepot bercerita pada anak-anak desa tentang pantai itu. Ceritanya keliru semua, tapi ia pemberani. | Cepot tells the village children about the beach. He gets it all wrong, but he is brave. |

| Id | Title EN / ID | Body EN | Body ID | Src | Weak EN / ID |
|----|---------------|---------|---------|-----|--------------|
| deserter_name | The Deserter's Name / Nama si Pembelot | A cell in Galuh goes quiet. The name Ranga is written, even if only the stone hears it. | Sebuah sel di Galuh menjadi sunyi. Nama Ranga tertulis, meski hanya batu yang mendengarnya. | game | n/a |
| ciung_egg | The Egg in the Basket / Telur di Keranjang | In the tale, Ciung Wanara was set adrift on a river as a baby, with an egg that hatched into his rooster. | Dalam kisahnya, Ciung Wanara dihanyutkan di sungai sebagai bayi, dengan sebutir telur yang menetas menjadi ayam jagonya. | legend | n/a |
| kabayan | Si Kabayan / Si Kabayan | A lazy but clever man in Sundanese folk tales, who beats the proud with their own words. | Lelaki malas tapi cerdik dalam cerita rakyat Sunda, yang mengalahkan si sombong dengan kata-katanya sendiri. | legend | n/a |
