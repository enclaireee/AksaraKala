# Script: Story v3.1 main path (ID and EN)

Every main-path line, keyed, Indonesian first. Canon: [story.md](story.md). Steps, beats and flags: [quests.md](quests.md) 4. Rewritten 2026-11-06 (Claude) for v3.1, all **ASSUMED** until the user's playtest; culture facts keep their **VERIFY** tags.

## 1. Rules
- **Talks:** at most 4 lines per NPC talk and 6 per story beat, hero lines (`@NPC_HERO_NAME`) included; choice labels don't count. Every talk ends on a lead (what to do or where to go next).
- **Lines:** one idea per line, about 100 EN characters (**TUNE** against the dialogue box). At most one "!" per talk. No parenthesised stage directions: narration uses the bare `@` speaker. No em dashes.
- **Villains don't explain the plot;** a beat shows it. The hero speaks plainly and doesn't shout names.
- **Show, don't explain.** A character wants something, says it in a concrete detail, and moves on. Lore goes to the codex (section 13: 1-3 sentences, labelled "legend" or "game").
- **Tone:** grounded, specific, a little wry (The Witcher 3). Warm humour comes from Semar and the punakawan; the world is never mocked ([concept.md](concept.md) Tone).
- **Regional arcs:** each act's regional character gets an intro line that shows their want, a turn, and a closing line in the aftermath (Ibu, Naganingrum, Lengser and the Deserter, Ki Sumarto, Wirasana, Wiryo).
- **The Hunter** speaks rarely: the west gate, the throne shadow, the graves, the duel's end. Silent at the crater, the shrine and in the Interlude. **Laras** beats are 2-3 lines, in her voice. The Interlude is quiet and short.
- **Glyphs are earned** by a deed first ([quests.md](quests.md) 4). A teacher names or shows the glyph; nobody hands it over.
- Semar is warm and wry ("hehe"). Lengser is sharp and loyal. Ciung Wanara is fierce and brotherly. Hariang Banga is honourable. The Hunter is cold.
- **Sensitivity:** the rooster fights off-screen and the hero never bets or handles it. Kala is calmed, never killed. Nyi Roro Kidul is belief, speaks once from a distance, is never fought. The Majapahit claim is only ever "some tellings say". Culture facts keep their **VERIFY** tags; every new cultural claim below carries one.
- Indonesian is natural spoken Indonesian; Sundanese or Javanese address terms (`Abah`, `Mbah`, `Uwa`, `Nyi`, `Mbok`, `Ki`) appear only where the speaker would use them. EN strings may use `{they}` `{them}` `{their}` `{They}`; ID strings never need them (`dia`, `-nya`).

## 2. Format (for the data wiring)
- Each NPC section is one `data/dialogue/<npc_id>.tres` (`DialogueData`, `npc_id`, `name_key`, `entries`). Entries are listed in order; the first whose `if` holds wins.
- An entry's `lines` are its keys in table order. A row `@NPC_X_NAME` (no text) is a speaker switch: put the string `"@NPC_X_NAME"` in `lines` ([ui.md](ui.md) 3, `ui/dialogue_box.gd`). A bare `@` row clears the tag (narration), as `beats.tres` already does.
- `choices` is `[{"text": KEY, "do": [...]}, ...]`, shown under the last line.
- Beats live in `data/dialogue/beats.tres` (npc_id `beats`, name_key `""`). Lines with no speaker row are narration. Every beat's `if` starts with `!flag:beat_<id>` and its `do` starts with `flag:beat_<id>`, so it plays once.
- Keys: NPC talks `DLG_<NPC>_V<n>` (NPC lines) and `DLG_<NPC>_H<n>` (hero lines). Beats `BEAT_<ID>_<n>`, hero lines `BEAT_<ID>_H<n>`. Choices `CHOICE_<ID>_<n>`. All go in `data/text/dialogue.csv` (columns `keys,id,en`). Tables below list **ID first, then EN**.
- "Keep" means the entry stays as it is in the current `.tres`. Old keys leave the CSV only when nothing else references them (section 14).
- Step indices are 0-based and follow [quests.md](quests.md) 4: `step:mq1=3` is step 1.4.
- Lakon and codex grants use `lakon:<id>` and `codex:<id>` in a `do` (`lakon:<id>` sets the same lakon flag a quest reward sets).

## 3. Names (`dialogue.csv`, next to the existing `NPC_*_NAME` rows)
| Key | ID | EN |
|-----|----|----|
| NPC_IBU_NAME | Ibu | Ibu |
| NPC_LARAS_NAME | Laras | Laras |
| NPC_NINI_NAME | Nini Balangantrang | Nini Balangantrang |
| NPC_HUNTER_NAME | Si Tanpa Ngaran | The Nameless Hunter |
| NPC_NAGANINGRUM_NAME | Perempuan di tepi danau | Woman by the lake |
| NPC_NAGAWIRU_NAME | Nagawiru | Nagawiru |
| NPC_CIUNG_WANARA_NAME | Ciung Wanara | Ciung Wanara |
| NPC_LENGSER_NAME | Uwa Lengser | Uwa Lengser |
| NPC_FACELESS_DESERTER_NAME | Si pembelot | The deserter |
| NPC_PAMALI_STONE_NAME | Batu Pamali | Pamali stone |
| NPC_BARMA_WIJAYA_NAME | Prabu Barma Wijaya | Prabu Barma Wijaya |
| NPC_HARIANG_BANGA_NAME | Hariang Banga | Hariang Banga |
| NPC_PANGRENYEP_NAME (new) | Dewi Pangrenyep | Dewi Pangrenyep |
| NPC_SAPTO_NAME (new) | Sapto | Sapto |
| NPC_ARCA_BASE_NAME (new) | Tulisan di dasar Arca | Inscription on the Arca |
| NPC_WIRYO_NAME (new) | Mbah Wiryo | Mbah Wiryo |
| NPC_RATU_KIDUL_NAME (text changes from "Voice from the Ocean") | Nyi Roro Kidul | Nyi Roro Kidul |

Existing keys used below, unchanged: `NPC_SEMAR_NAME`, `NPC_SUNDA_ELDER_NAME` (Abah Karna), `NPC_SUNDA_WEAVER_NAME`, `NPC_MATARAM_DALANG_NAME` (Ki Sumarto), `NPC_JURU_KUNCI_NAME` (Mbah Marto), `NPC_TIMUR_EMPU_NAME` (Mpu Wirasana), `NPC_MBOK_SRINI_NAME`, `NPC_KI_WANGSA_NAME`, `NPC_KIDUL_ALTAR_NAME`. The `kidul_jurukunci.tres` `name_key` becomes `NPC_WIRYO_NAME` (replaces `NPC_KIDUL_JURUKUNCI_NAME`). Ciung Wanara and Hariang Banga already have name keys; their Act IV and Interlude lines are in sections 9 and 10.

Boss bar names (`ui.csv`, next to the existing `BOSS_*`): BOSS_FACELESS_CAPTAIN "Faceless Captain" / "Kapten Tanpa Rupa"; BOSS_NAMELESS_HUNTER "The Nameless Hunter" / "Si Tanpa Ngaran"; BOSS_BARMA_WIJAYA "Prabu Barma Wijaya" / "Prabu Barma Wijaya"; BOSS_HARIANG_BANGA "Hariang Banga" / "Hariang Banga".

## 4. Prologue cards (`PROLOGUE_1`-`_5`, `ui/prologue.tscn`: lines 5, `semar_from = 0`, `semar_to = 0`)
| Key | ID | EN |
|-----|----|----|
| PROLOGUE_1 | Desa Purwa, malam wayang ruwatan. Di depan kelir, sang dalang membacakan nama anak-anak desa satu per satu, agar mereka terlindung. | Desa Purwa, the night of the wayang ruwatan. Before the screen, the dalang reads the village children's names aloud, one by one, to ward them. |
| PROLOGUE_2 | Adikmu, Laras, duduk di sampingmu dengan sehelai lontar. Ia menulis namanya di satu ujung, dan namamu di ujung lain: {name}. | Your little sister Laras sits beside you with a strip of lontar. She writes her name at one end, and yours at the other: {name}. |
| PROLOGUE_3 | Lalu bayang-bayang turun dari kelir. Topeng kosong, tangan yang menggapai. Laras menatap yang paling jangkung dan berbisik, "Aria." | Then the shadows step off the screen. Blank masks, reaching hands. Laras looks at the tallest and whispers, "Aria." |
| PROLOGUE_4 | "Kak!" Lontar itu robek di antara tanganmu dan tangan mereka. Mereka menyeretnya ke dalam gelap. Lampu padam. | "Kak!" The lontar tears between your hands and theirs. They pull her into the dark. The lamp goes out. |
| PROLOGUE_5 | Pagi. Separuh lontarmu hilang, jatuh entah di mana di panggung yang hangus. Nama Laras di sana mulai memudar. | Morning. Your half of the lontar is gone, dropped somewhere on the burned stage. Her name on it is fading. |

The dalang reading the children's names aloud at a ruwatan (PROLOGUE_1) is **VERIFY** (story.md Spine).

## 5. Prologue: Desa Purwa (MQ0)
Regional character: Ibu (want: two cups she cannot explain; turn: the Interlude; close: the epilogue).

### ibu (name NPC_IBU_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=2` (0.3) | |
| 2 | `step:mq4=1` (4.2, the Interlude) | |
| 3 | `flag:mq5_4` | |
| 4 | `quest:mq0=active` | |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_IBU_H1 | Bu, Laras di mana? Semalam dia tidak pulang. | Ibu, where's Laras? She never came home last night. |
| 1 | @NPC_IBU_NAME | | |
| 1 | DLG_IBU_V2 | Laras? Siapa Laras, Nak? Dari dulu cuma kita berdua. | Laras? Who's Laras, child? It's always been the two of us. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_IBU_H2 | Lalu kenapa ada dua cangkir di meja? | Then why are there two cups on the table? |
| 1 | @NPC_IBU_NAME | | |
| 1 | DLG_IBU_V4 | Dua... Tangan Ibu sendiri yang menaruhnya, entah kenapa. Sudahlah. Semar semalaman di sanggar, tanyalah dia. | Two... My own hands set them out, and I couldn't say why. Never mind. Semar was up all night at the sanggar. Ask him. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_IBU_H3 | Ibu menangis. | Ibu, you're crying. |
| 2 | @NPC_IBU_NAME | | |
| 2 | DLG_IBU_V10 | Masa? Asap dapur, mungkin. Tiap pagi begini, Nak, dan Ibu tak tahu kenapa. | Am I? Kitchen smoke, maybe. Every morning like this, child, and I don't know why. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_IBU_H4 | Aku tahu kenapa. Akan kuceritakan setelah dia pulang. | I know why. I'll tell you once she's home. |
| 2 | @NPC_IBU_NAME | | |
| 2 | DLG_IBU_V11 | Siapa pun dia, bawa pulang. Sekarang duduklah. Dua pemuda di ruang tengah menunggumu sejak subuh, dan berdebat soal kursi. | Whoever she is, bring her home. Now sit. Two young men have waited in the back room since dawn, arguing over a chair. |
| 3 | DLG_IBU_V5 | Laras, siapkan piring, kakakmu pulang! | Laras, set the table, your kakak's home! |
| 3 | DLG_IBU_V6 | Aneh. Tadi Ibu kira rumah ini terlalu sepi. | Funny. For a moment I thought this house was too quiet. |
| 4 | DLG_IBU_V7 | Hati-hati. Sejak semalam seisi desa gelisah. | Be careful. The whole village is jumpy since last night. |
| 5 | DLG_IBU_V8 | Pulanglah kalau sempat. Nasimu Ibu hangatkan. | Come home when you can. I'll keep your rice warm. |

### semar (sanggar; drop every old main-path entry)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=3` (0.4) | |
| 2 | `step:mq0=4` (0.5) | `learn:sunda_ka` |
| 3 | `step:mq0=5` | |
| 4 | `step:mq0=6` | |
| 5 | `quest:mq0=active` | |
| 6 | `quest:mq4=active` | |
| 7 | `quest:mq5=active` | |
| 8 | `flag:mq5_4` | |
| 9 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_SEMAR_V1 | Hehe, mukamu kusut seperti kucing basah. Sebelum aku bicara, ambil dulu lontar yang tertinggal di panggung wayang. Yang gosong itu. | Hehe, you look like a wet cat. Before I say anything, fetch the lontar off the wayang stage. The scorched one. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_SEMAR_H2 | Hurufnya memudar dari ujung. Siapa yang melakukan ini? | The letters are fading from the edges. Who did this? |
| 2 | @NPC_SEMAR_NAME | | |
| 2 | DLG_SEMAR_V4 | Para tanpa rupa. Orang-orang terlupa, yang mengangkut nama bagi dia yang memegangnya. Ibumu sudah kehilangan satu. | The faceless. Forgotten folk who carry names to the one who holds them. Your mother has already lost one. |
| 2 | DLG_SEMAR_V5 | Separuh yang ada namamu masih dipegang adikmu, dan ia menulis di situ. Lihat? Ka, untuk "kakak". Gambar tiga kali sampai tanganmu hafal sendiri. | She still holds the half with your name, and she's writing on it. See? Ka, for "kakak". Draw it three times, until your hand knows it. |
| 3 | DLG_SEMAR_V7 | Lagi. Tiga kali, sampai tanganmu tak perlu menunggu kepalamu. | Again. Three times, until your hand stops waiting for your head. |
| 4 | DLG_SEMAR_V8 | Dengar itu? Mereka kembali mencari sesuatu. Alun-alun, cepat! | Hear that? They came back for something. The plaza, go! |
| 5 | DLG_SEMAR_V9 | Mereka lari ke barat mengejar bocah itu. Pergilah, dan simpan lontarnya dekat jantung. | They ran west after that boy. Go, and keep the lontar close to your heart. |
| 6 | DLG_SEMAR_V10 | Laut selatan. Orang pesisir bilang laut tak pernah lupa. Semoga mereka benar, hehe. | The south sea. The coast folk say the sea never forgets. I hope they're right, hehe. |
| 7 | DLG_SEMAR_V14 | Gua itu lewat kabut di belakang desa. Aku sampai duluan, hehe. | The cave is through the fog behind the village. I'll get there first, hehe. |
| 8 | DLG_SEMAR_V15 | Ssst, pertunjukannya mulai. Tebak lakon siapa. | Shh, the show's starting. Guess whose lakon it is. |
| 9 | DLG_SEMAR_V16 | Setiap kisah dimulai dari orang yang mengingatnya. | Every story starts with someone who remembers it. |

### ki_wangsa (the village dalang, your master)
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq5_4` | |
| 2 | `quest:mq0=active` | |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KI_WANGSA_V1 | Malam ini kita mainkan lakon baru. Ada yang menuliskannya untukku. | Tonight we play a new lakon. Someone wrote it down for me. |
| 2 | DLG_KI_WANGSA_V2 | Pertunjukan semalam bagus. Tapi penontonnya sepi, seperti ada yang kurang. | Good show last night. Quiet crowd, though. Like someone was missing. |
| 2 | DLG_KI_WANGSA_V3 | Ambilkan minyak blencong kalau sudah pulang, ya, muridku. | Fetch the blencong oil when you're back, apprentice. |
| 3 | DLG_KI_WANGSA_V4 | Dalang bercerita. Penulis menjaga. Jadilah keduanya, kalau bisa. | A dalang tells. A writer keeps. Be both, if you can. |

### Beat `hunter_raid` (if `!flag:beat_hunter_raid`, `flag:mq0_7`; do `flag:beat_hunter_raid`, `codex:faceless`, `start:mq1`)
| Key | ID | EN |
|-----|----|----|
| BEAT_HUNTER_RAID_1 | Di gerbang barat, sosok jangkung berdiri membelakangi fajar. Topeng kosong, seperti yang lain. Sikapnya tidak. | At the west gate a tall figure stands against the dawn. A blank mask, like the others. The bearing is not. |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_RAID_2 | Anak yang salah. Tapi yang lebih baik. | Wrong child. A better one. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_RAID_H1 | Kembalikan dia! | Give her back! |
| @ | | |
| BEAT_HUNTER_RAID_3 | Ia tidak menoleh. Pasukannya mengalir lewat gerbang seperti asap, ke barat, lalu gerbang itu kosong lagi. | He doesn't turn. His men pour through the gate like smoke, west, and then the gate is empty again. |
| @NPC_NINI_NAME | | |
| BEAT_HUNTER_RAID_4 | Mereka mencari Ciung kami, bocah dengan telur itu. Ia lari ke barat semalam. Susul dia dulu, Nak, sebelum mereka. | It was our Ciung they came for, the boy with the egg. He ran west in the night. Reach him first, child, before they do. |

## 6. Act I: Tatar Sunda (MQ1, "Segel Kawah")
Regional character: Dewi Naganingrum (want: a son she held for one night; turn: the lake; close: the rim).

### sunda_elder (Abah Karna; replace the main-path entries, keep the SQ-S1/S2 entries after them, then the idle entry last)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=3` (1.4) | `flag:mq1_2`, `learn:sunda_ga` |
| 2 | `step:mq1=4` | |
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
| 1 | DLG_SUNDA_ELDER_V3 | Hilir, ke ngarai sungai. Kata orang tua, di sana Sandekala menjemput anak yang masih di luar saat senja. Bawa Ga: angkat, dan cahaya jadi dinding. | Downstream, to the river gorge. The old folk say Sandekala collects any child still outside at dusk. Take Ga: raise it, and the light becomes a wall. |
| 2 | DLG_SUNDA_ELDER_V4 | Ikuti sungai ke hilir. Kau akan tahu saat langit mulai jingga. | Follow the river down. You'll know it when the sky turns orange. |
| 3 | DLG_SUNDA_ELDER_V6 | Batu tulis ada di atas jalan setapak. Teras sawah di baliknya. | The batu tulis is up the path. The terraces are past it. |

VERIFY: Sandekala as a dusk spirit that takes children who stay out at maghrib.

### batu_tulis (replace the `step:mq1=3` entry; keep the fallback)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=5` (1.6) | `learn:sunda_nga` |

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
| 1 | DLG_SUNDA_WEAVER_V2 | Bahwa lelaki tanpa wajah butuh dia membaca sesuatu di kawah. Maka ambil ini, boeh rarang. Kain ini pernah menipu Sangkuriang. Gantung di tiang timur, rapalkan Ca. | That the faceless man needs her to read something at the crater. So take this, boeh rarang. It fooled Sangkuriang once. Hang it on the east post, then cast Ca. |

### naganingrum (ts_situ, cond `flag:mq1_6b`, stays after MQ1; name NPC_NAGANINGRUM_NAME). The turn.
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq1_6b`, `step:mq1=9` (1.10) | `learn:sunda_ca` |
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

### Beat `laras_1` (if `!flag:beat_laras_1`, `step:mq1=11`; do `flag:beat_laras_1`)
| Key | ID | EN |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_1_1 | Kak? Di sini gelap. Ada orang tanpa wajah yang terus menyuruhku membaca. | Kak? It's dark here. A man with no face keeps telling me to read. |
| BEAT_LARAS_1_2 | Aku membaca pelan-pelan. Satu kata, diam, satu kata lagi. Aku tak mau cepat selesai. | I read slowly. One word, a pause, one more. I don't want it finished soon. |

### Beat `crater_seal` (if `!flag:beat_crater_seal`, `flag:mq1_8`; do `flag:beat_crater_seal`, `restore`)
| Key | ID | EN |
|-----|----|----|
| BEAT_CRATER_SEAL_1 | Sang kapten berlutut. Dengan sisa tenaganya ia menghantam batu segel yang sudah retak dengan gagang tombak. | The Captain drops to a knee. With the last of his strength he drives his spear butt into the cracked seal-stone. |
| BEAT_CRATER_SEAL_2 | Batu itu pecah. Di dasar kawah, sesuatu sebesar bukit menarik napas. | The stone splits. Down in the crater, something the size of a hill takes a breath. |
| BEAT_CRATER_SEAL_3 | Di bibir seberang, sosok jangkung bertopeng menonton sebentar, lalu pergi. Di bawahnya, Ciung Wanara tergantung dalam rantai, seperti umpan. | On the far rim a tall masked figure watches a moment, then leaves. Below him Ciung Wanara hangs in chains like bait. |
| @NPC_HERO_NAME | | |
| BEAT_CRATER_SEAL_H1 | Ciung! Bertahanlah! | Ciung! Hold on! |

### Beat `naga` (if `!flag:beat_naga`, `quest:mq1=done`; do `flag:beat_naga`, `flag:mq1_10`, `codex:nagawiru`, `codex:sangkuriang`, `lakon:sangkuriang`, `start:mqg`)
| Key | ID | EN |
|-----|----|----|
| BEAT_NAGA_1 | Fajar palsu padam. Sangkuriang duduk di antara perahunya yang tak pernah jadi dan tertidur. Rantai mengendur, dan seekor naga besar bangkit dari lumpur, sisiknya kusam seperti perunggu tua. | The false dawn fades. Sangkuriang sits down among his never-finished boats and sleeps. The chains slacken, and a great naga rises from the mud, scales dull as old bronze. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_2 | Kau mengikutiku sampai sini? Berani atau bodoh, aku belum tahu. | You followed me all the way here? Brave or stupid, I haven't decided. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_NAGA_3 | Orang di singgasana Galuh memakai wajahku, Nak. Mereka membawa gadis kecil itu ke sana. | The man on Galuh's throne wears my face, child. They took the little girl there. |
| @ | | |
| BEAT_NAGA_4 | Telur di dekapan Ciung retak. Seekor anak ayam jantan menggelinding keluar, sudah galak. | The egg in Ciung's arms cracks. A rooster chick tumbles out, already angry. |
| @NPC_NAGANINGRUM_NAME | | |
| BEAT_NAGA_5 | Nak...? | Child...? |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_6 | Hati-hati, Bu, di sini licin. Nah, kau. Galuh. Ikut? Gerbang timur desamu jalan pintasnya. | Careful, Ibu, it's slippery here. Now you. Galuh. Coming? Your village's east gate is the short way. |

### dayang_sumbi (lake; SQ-S5 is retired: drop every old entry)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq1=done` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_DAYANG_SUMBI_V6 | Danau ini ingat segalanya. Andai saja tidak. | The lake remembers everything. I wish it didn't. |

## 7. Act II: Keraton Galuh (MQG, "Wajah Pinjaman")
Regional characters: Uwa Lengser (want: to say a secret aloud; turn: the queen's eyes; close: relief) and the Deserter (want: his wife's face; turn: the choice; close: epilogue and the cave mouth).

### ciung_wanara (kg_alun; name NPC_CIUNG_WANARA_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq4_9` (holding the Gua Kala mouth, Act VI) | |
| 2 | `quest:mq4=active` (the Interlude table in Desa Purwa) | |
| 3 | `quest:mq2=active` | |
| 4 | `step:mqg=0` (g.1) | |
| 5 | `step:mqg=2` (g.3, after bout 1) | |
| 6 | `flag:mqg_4`, `!flag:mqg_7`, `zone:kg_keraton` (camp talk at `galuh_1`, `"quiet": true`; closes once the king is unmasked, since its last line looks ahead to that, and the zone keeps it out of later acts) | `flag:camp_galuh` |
| 7 | `quest:mqg=active` | |
| 8 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_CIUNG_WANARA_V10 | Masuklah. Tak ada yang lewat dua raja dan satu pintu. | Go in. Nothing gets past two kings and one door. |
| 2 | DLG_CIUNG_WANARA_V11 | Ibumu menuangkan teh untukku tanpa bertanya siapa aku. Pergilah ke selatan, Penulis. | Your mother poured me tea without asking who I was. Go south, writer. |
| 3 | DLG_CIUNG_WANARA_V1 | Katanya anak Pangrenyep mengumpulkan pasukan. Saudaraku, rupanya. | They say Pangrenyep's son is raising an army. My brother, apparently. |
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

### Beat `galuh_bout` (if `!flag:beat_galuh_bout`, `flag:mqg_2`; do `flag:beat_galuh_bout`, `codex:ciung_wanara`)
| Key | ID | EN |
|-----|----|----|
| BEAT_GALUH_BOUT_1 | Sorak membahana dari gelanggang di balik tembok. Ayam Ciung Wanara menang. Kau tak melihatnya, hanya mendengar. Tugasmu cuma menghajar yang curang. | A roar goes up from the ring behind the wall. Ciung Wanara's rooster has won. You didn't see it, only heard it. Your job was the cheats. |
| @NPC_LENGSER_NAME | | |
| BEAT_GALUH_BOUT_2 | Mata itu... mata sang permaisuri. Dewata. Temui aku, kalian berdua, diam-diam. Dan jangan tersenyum. | Those eyes... the queen's eyes. Heavens. Come and see me, both of you, quietly. And don't smile. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_GALUH_BOUT_3 | Kakek itu menatapku seperti melihat hantu. | The old man looked at me like he'd seen a ghost. |

The rooster stays off-screen ([quests.md](quests.md) MQG sensitivity).

### lengser (kg_alun, cond `flag:mqg_2`; name NPC_LENGSER_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mqg=3` (g.4) | `codex:lengser` |
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

### Beat `laras_2` (if `!flag:beat_laras_2`, `step:mqg=7`; do `flag:beat_laras_2`). After the cells (ASSUMED: no petilasan here).
| Key | ID | EN |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_2_1 | Kak, yang di halaman tadi kamu, kan? Aku dengar. Sekarang aku di bawah kain pedati, bergoyang ke timur. | Kak, that was you in the yard. I heard you. I'm under a wagon cloth now, rocking east. |
| BEAT_LARAS_2_2 | Penjaga di sel dulu membiarkan aku memegang separuh lontarku. Dia ikut bersenandung waktu aku mengeja. Orang aneh. | The guard in the cells let me keep my half. He hummed along when I spelled. Strange man. |

### faceless_deserter (kg_penjara; name NPC_FACELESS_DESERTER_NAME): Choice 1
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `step:mqg=7` (g.8) | | CHOICE_DESERTER_1 to `flag:choice_freed`; CHOICE_DESERTER_2 to `flag:choice_handed` |
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
| BEAT_CAGE_1 | Ciung Wanara menyeret mereka ke kandang besi di pelataran, seperti dalam kisah: sang raja palsu, dan Permaisuri Pangrenyep bersamanya. | Ciung Wanara drags them to the iron cage in the courtyard, as in the legend: the false king, and Queen Pangrenyep with him. |
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
Regional character: Ki Sumarto (want: a stage no army will burn; turn: his son marches east; close: Sapto wades home).

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
| 2 | DLG_MATARAM_DALANG_V3 | Digiring lewat pasar, ke arah Candi Seribu. Ada tiga jalan ke sana: reruntuhan, kuburan, dan pasar ini. Tempuh semuanya. | Marched through this market toward Candi Seribu. Three roads lead there: the ruins, the graveyard, and this market. Walk them all. |
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
| 1 | DLG_LESUNG_WOMEN_V2 | Irama fajar palsu. Konon perempuan Roro Jonggrang menumbuk begini supaya ayam berkokok sebelum waktunya. Ini Ca: gambarlah mengikuti irama, dan tanganmu lebih cepat dari amarah. | The false-dawn rhythm. They say Roro Jonggrang's women pounded like this to make the roosters crow early. This is Ca: draw to the beat, and your hand outruns anger. |
| 1 | DLG_LESUNG_WOMEN_V3 | Batu-batunya bergerak lagi tiap malam. Mbah Marto di bukit memegang kuncinya. Tembus blokade, dan dia akan menemuimu. | The stones move again every night. Mbah Marto on the hill keeps the key. Break the blockade and he'll receive you. |
| 2 | DLG_LESUNG_WOMEN_V10 | Kami menumbuk padi dan bernyanyi. Ikutlah kapan saja. | We pound rice and sing. Join us anytime. |

VERIFY: Roro Jonggrang's women pounding rice to fake the dawn.

### juru_kunci (Mbah Marto; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=7` (2.8) | `learn:jawa_ra` |
| 2 | `quest:mq2=active`, `flag:mq2_6` | |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_JURU_KUNCI_V1 | Blokade itu runtuh? Dua hari aku tak bisa turun menyalakan dupa. Mbah Marto, juru kunci candi. | The blockade fell? Two days I couldn't come down to light incense. Mbah Marto, keeper of the temple keys. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_JURU_KUNCI_H1 | Kata orang, Mbah memegang kunci Candi Seribu. | They say you hold the keys to Candi Seribu. |
| 1 | @NPC_JURU_KUNCI_NAME | | |
| 1 | DLG_JURU_KUNCI_V2 | Kunci, ya. Tapi para tanpa rupa berkemah di dalamnya dan membangunkan kutukan prajurit lama. Kunci tak berguna lagi. | The keys, yes. But the faceless have camped inside and woken the old soldiers' curse. Keys are no use now. |
| 1 | DLG_JURU_KUNCI_V3 | Ra. Roh macan berjalan di sisimu, dan yang terkutuk berbalik menghadapinya. Saat itu, pukul punggungnya. Tangga candi kubuka. | Ra. A tiger spirit walks beside you, and the cursed turn to face it. That's when you strike their backs. The temple stairs are open. |
| 2 | DLG_JURU_KUNCI_V5 | Hancurkan perkemahan itu. Arwah di sini berhak tidur tenang. | Break that camp. The dead here deserve their sleep. |
| 3 | DLG_JURU_KUNCI_V6 | Hati-hati di gerbang candi. Batunya bisa runtuh. | Mind the temple gate. Stones can fall. |

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
| BEAT_CAMP_2B | Para tanpa rupa sudah membawanya ke timur. Di bawah tanah, seribu candi berderak, dan Bandung Bondowoso bangun. | The faceless have taken her east. Underground, a thousand temples creak, and Bandung Bondowoso wakes. |

### Beat `laras_3` (if `!flag:beat_laras_3`, `step:mq2=10`, `flag:beat_camp`; do `flag:beat_laras_3`)
| Key | ID | EN |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_3_1 | Kak, aku membaca karena mereka menyakiti tawanan kalau aku diam. Aku tahu itu salah. Tetap saja. | Kak, I read because they hurt the prisoners when I don't. I know it's wrong. I did it anyway. |
| BEAT_LARAS_3_2 | Malam ini kutulis Ka lagi. Separuh lontarku makin pendek. | I wrote Ka again tonight. My half's getting shorter. |

### pamali_stone (kg_pamali, cond `flag:mq2_7`; name NPC_PAMALI_STONE_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=11` (2.12) | `write:nagawiru:jawa_na,sunda_ga` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_PAMALI_STONE_V1 | Batu batas tua. Dulu sebuah nama dipahat di sini, lalu dikikis. | An old boundary stone. A name was cut here once, then scraped away. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PAMALI_STONE_H1 | Nagawiru. | Nagawiru. |
| 1 | @NPC_PAMALI_STONE_NAME | | |
| 1 | DLG_PAMALI_STONE_V2 | Tuliskan kembali: Na dari timur, Ga dari barat. Kandang hanya menahan orang. Nama harus ditulis. | Write it back: Na from the east, Ga from the west. A cage only holds a man. A name has to be written. |
| 2 | DLG_PAMALI_STONE_V3 | Nama itu bertahan. Suara sungai kini terdengar lain. | The name holds. The river sounds different now. |

### Beat `ford` (if `!flag:beat_ford`, `flag:mq2_8`; do `flag:beat_ford`)
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
| BEAT_TRUCE_4 | Timur, kalau begitu. Penulis, jalan ke gua melewati tanahku. Akan kutunjukkan. | East, then. Writer, the road to the cave runs through my land. I'll show you. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_TRUCE_5 | Dan orang di kandang itu? Kau yang membawa kami sampai sini. Kau yang bilang. | And the man in the cage? You got us here. You tell me. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_MERCY_1 | Ampuni dia. Ia pun pernah dirampas sesuatu. | Show him mercy. Even he was robbed of something. | `flag:choice_mercy` |
| CHOICE_MERCY_2 | (Diam saja.) | (Say nothing.) | `flag:choice_silent` |

Nagawiru speaks from the water and Ciung Wanara stands on the west bank. Pangrenyep stays caged.

## 9. Act IV: Tanah Timur (MQ3, "Bilah Tujuh Turunan")
Regional character: Mpu Wirasana (want: to never again forge a blade that eats; turn: the keris he once sharpened; close: the choice). Ally: Hariang Banga.

### timur_empu (Mpu Wirasana; replace the main-path entries, keep the SQ-T3 entries)
| Entry | if | do |
|-------|----|----|
| 3 | `step:mq3=2` (3.3) | |
| (keep) | the SQ-T3 offer (`quest:sq_t3=available`) and turn-in (`step:sq_t3=2`) | |
| 1 | `flag:choice_reforge` | |
| 2 | `flag:choice_sink` | |
| 4 | `step:mq3=3` | |
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
| 3 | DLG_TIMUR_EMPU_V3 | Ditenangkan, bukan dikalahkan. Ia menandai korbannya dengan kutukan, dan aksara mematahkannya. Berlatihlah di tonggakku. Tapi temui dulu Mbok Srini di sungai; anaknya dikejar sesuatu yang lebih nyata. | Calmed, not beaten. It marks its victims with curses, and aksara break them. Practise on my stakes. But see Mbok Srini by the river first; her girl is being chased by something more urgent. |
| 4 | DLG_TIMUR_EMPU_V6 | Mbok Srini, di tepi sungai. Pergilah. | Mbok Srini, by the river. Go on. |
| 5 | DLG_TIMUR_EMPU_V7 | Dua tanda. Patahkan, dan kau siap ke candi. | Two marks. Break them, and you're ready for the shrine. |

### mbok_srini (replace the entries' text, keep their `if` and `do`)
| Entry (`if`) | Key | ID | EN |
|-------|-----|----|----|
| `step:mq3=3` (3.4) | DLG_MBOK_SRINI_V1 | Timun Masku! Buto Ijo mengejarnya sampai ladang timur, dan kakiku sudah tak sanggup. | My Timun Mas! Buto Ijo has chased her to the eastern field, and my legs have given out. |
| `step:mq3=3` | @NPC_HERO_NAME | | |
| `step:mq3=3` | DLG_MBOK_SRINI_H1 | Sejak kapan, Mbok? | Since when, Mbok? |
| `step:mq3=3` | @NPC_MBOK_SRINI_NAME | | |
| `step:mq3=3` | DLG_MBOK_SRINI_2 (keep) | Bawalah empat kantong ini: biji timun, jarum, garam, dan terasi. | Take these four pouches: cucumber seeds, needles, salt and terasi. |
| `step:mq3=3` | @NPC_HERO_NAME | | |
| `step:mq3=3` | DLG_MBOK_SRINI_H2 | Seperti dalam dongeng. | Like the tale. |
| `step:mq3=3` | @NPC_MBOK_SRINI_NAME | | |
| `step:mq3=3` | DLG_MBOK_SRINI_V2 | Dongeng ditulis oleh yang berhasil lolos. Lempar satu per satu saat ia dekat. Ladang timur, Nak, cepat! | Tales are written by the ones who got away. Throw them one by one when he's close. The eastern field, child, quickly! |
| `flag:mq3_4` | DLG_MBOK_SRINI_5 (keep), DLG_MBOK_SRINI_6 (keep) | | |
| `step:mq3=1` | DLG_MBOK_SRINI_7 (keep) | | |
| `quest:mq3=active` | DLG_MBOK_SRINI_V4 | Ladang timur, Nak! Sebelum ia tertangkap! | The eastern field, child! Before he catches her! |
| (none) | DLG_MBOK_SRINI_8 (keep) | | |

### Beat `laras_4` (if `!flag:beat_laras_4`, `step:mq3=9`; do `flag:beat_laras_4`)
| Key | ID | EN |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_4_1 | Kak... wajahmu tak bisa kulihat lagi. Kucoba, tapi cuma bayangan. | Kak... I can't see your face anymore. I try, and it's just a shape. |
| BEAT_LARAS_4_2 | Di separuh lontarku tinggal satu huruf: Ka. Kugenggam erat-erat. Jangan terlambat. | Only one letter is left on my half: Ka. I'm holding it tight. Don't be late. |

### Camp talk `camp_timur` (hariang_banga entry 3; cond `flag:mq3_6`, `zone:tt_pasir`, `"quiet": true`; do `flag:camp_timur`; at `timur_2`. The zone keeps it from replaying in Desa Purwa and Gua Kala; his other entries are in section 10, "Staging NPCs")
| Key | ID | EN |
|-----|----|----|
| DLG_HARIANG_BANGA_V1 | Ini jalan para pedagang garam. Jangan ikuti jejak abu, Penulis. Abu menuntun, tapi tak pernah ke tempat baik. | This is the salt traders' road. Don't follow the ash trail, writer. Ash leads, but never anywhere good. |
| @NPC_HERO_NAME | | |
| DLG_HARIANG_BANGA_H1 | Kenapa kau membantuku? | Why help me? |
| @NPC_HARIANG_BANGA_NAME | | |
| DLG_HARIANG_BANGA_V2 | Ciung dan aku sepakat satu hal: kami tak mau jadi lakon yang diulang. Tidurlah. Candinya di balik bukit itu. | Ciung and I agree on one thing: we won't be a lakon that gets replayed. Sleep. The shrine is behind that hill. |

### Beat `shrine_sight` (if `!flag:beat_shrine_sight`, `flag:mq3_6`, `flag:beat_laras_4`, `zone:tt_candi`; do `flag:beat_shrine_sight`). The turn.
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
| CHOICE_KERIS_1 | Bawa ke sang empu untuk ditempa ulang. | Take it to the empu to reforge. | `flag:choice_reforge`, `give:keris_mpu_gandring` |
| CHOICE_KERIS_2 | Serahkan pada sungai. | Give it to the river. | `flag:choice_sink`, `give:batu_kali` |

### Beat `hunter_shrine` (if `!flag:beat_hunter_shrine`, `flag:beat_keris`; do `flag:beat_hunter_shrine`, `restore`)
The Hunter boss's cond stays `flag:beat_keris`. He says nothing here.
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
| BEAT_HUNTER_NAME_4 | Naik. Kuda kami membawamu pulang sebelum kabut menutup jalan. Guanya di belakang desamu. | Up. Our horses carry you home before the fog closes the road. The cave is behind your village. |

## 10. Interlude, Act V and Act VI (MQ4, MQ5)
### Interlude "Rumah yang Sunyi" (4.1-4.2, about 10 minutes, no combat)
Ibu's talk (entry 2 in section 5) is step 4.2. Then:

### Beat `quiet_house` (if `!flag:beat_quiet_house`, `flag:mq4_2`, `flag:choice_mercy`; do `flag:beat_quiet_house`)
| Key | ID | EN |
|-----|----|----|
| BEAT_QUIET_HOUSE_1 | Di meja ibumu, dua cangkir dan dua pemuda yang menolak duduk di kursi yang sama. Ciung Wanara dari tepi barat, Hariang Banga dari timur, bertemu sebagai saudara untuk pertama kali. | At your mother's table, two cups and two young men who refuse the same chair. Ciung Wanara from the west bank, Hariang Banga from the east, meeting as brothers for the first time. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_QUIET_HOUSE_2 | Kandangnya sekarang punya lampu. Kecil. Dia tak minta lebih. | The cage has a lamp now. A small one. He doesn't ask for more. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_QUIET_HOUSE_3 | Terima kasih. | Thank you. |
| @ | | |
| BEAT_QUIET_HOUSE_4 | Di perapian, topeng kosong tergeletak di antara bara. Tak ada yang menyentuhnya. | In the hearth, an empty mask lies among the embers. Nobody touches it. |
| @NPC_SEMAR_NAME | | |
| BEAT_QUIET_HOUSE_5 | Laut tak pernah lupa. Pergilah ke selatan, Nak. Bawa topi, anginnya nakal, hehe. | The sea does not forget. Go south, child. Bring a hat, the wind there is naughty, hehe. |

### Beat `quiet_house_silent` (if `!flag:beat_quiet_house`, `flag:mq4_2`, `flag:choice_silent`; do `flag:beat_quiet_house`)
| Key | ID | EN |
|-----|----|----|
| BEAT_QUIET_HOUSE_1 | (same as above) | (same as above) |
| BEAT_QUIET_HOUSE_S2 | Ciung menatap api, bukan kau. Kandang di Galuh tak disebut siapa pun. | Ciung watches the fire, not you. Nobody mentions the cage in Galuh. |
| BEAT_QUIET_HOUSE_4 | (same as above) | (same as above) |
| @NPC_SEMAR_NAME | | |
| BEAT_QUIET_HOUSE_5 | (same as above) | (same as above) |

### Act V "Laut Tak Pernah Lupa" (4.3-4.9). Regional character: Mbah Wiryo (want: the sea to say her name; turn: the sea answers; close: a louder answer).

### kidul_jurukunci (Mbah Wiryo; name NPC_WIRYO_NAME; replace the main-path entries, keep any SQ entries)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq4=done` | |
| 2 | `step:mq4=3` (4.4) | `codex:nyi_roro_kidul` |
| 3 | `quest:mq4=active` | |
| (keep) | SQ entries and the current fallback | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_WIRYO_V6 | Senja tadi kusebut namanya lagi. Hari ini ombak menjawab lebih keras. Mungkin Sumi senang. | I said her name again at dusk. Today the surf answered louder. Maybe Sumi is glad. |
| 2 | DLG_WIRYO_V1 | Berhenti di garis pasang, Nak. Laut ini punya tata krama, dan dia menilai tamu dari cara melangkah. | Stop at the tide line, child. This sea has manners, and it judges a guest by how they walk. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_WIRYO_H1 | Aku mencari suara adikku. Orang di desa bilang laut tak pernah lupa. | I'm looking for my sister's voice. They say in my village the sea never forgets. |
| 2 | @NPC_WIRYO_NAME | | |
| 2 | DLG_WIRYO_V2 | Laut tak mengembalikan siapa pun. Ia hanya mengingat. Tiap senja kubisikkan nama istriku, Sumi, ke ombak, dan ombak membisikkannya kembali. Empat puluh tahun. | The sea gives nobody back. It only remembers. Every dusk I whisper my wife's name, Sumi, to the surf, and the surf whispers it back. Forty years. |
| 2 | DLG_WIRYO_V3 | Kata orang, Ratu Kidul penguasa laut ini. Jangan memakai hijau di pantai, jangan menunjuk ombak. Yang pantas boleh lewat karang dan tebing, sampai paviliun di seberangnya. | The Queen of the South rules this sea, they say. Don't wear green on the shore, don't point at the waves. The worthy may pass the reef and the cliff, to the pavilion beyond. |
| 3 | DLG_WIRYO_V4 | Karang dulu, lalu tebing. Dan jangan hijau. | The reef first, then the cliff. And no green. |

VERIFY: the green taboo on the southern coast; the juru kunci's role. Told as belief.

### Beat `laras_kidul` (if `!flag:beat_laras_kidul`, `step:mq4=7`; do `flag:beat_laras_kidul`)
| Key | ID | EN |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_KIDUL_1 | Kak? Ini bukan gua. Ini air. Aku bisa mendengar laut, dan laut masih menyebut namaku. | Kak? This isn't a cave. It's water. I can hear the sea, and the sea still says my name. |
| BEAT_LARAS_KIDUL_2 | Laut tak lupa, jadi aku tak takut. Datanglah. | The sea doesn't forget, so I'm not afraid. Come. |

### Beat `kidul_trial` (if `!flag:beat_kidul_trial`, `flag:mq4_8`; do `flag:beat_kidul_trial`)
| Key | ID | EN |
|-----|----|----|
| BEAT_KIDUL_TRIAL_1 | Ombak ketiga surut, dan air di paviliun berhenti bergerak. Tak ada yang naik dari laut. Hanya hijau, jauh sekali, di seberang batas pasang. | The third wave ebbs, and the water in the pavilion stills. Nothing climbs out of the sea. Only green, very far, beyond the tide line. |
| @NPC_RATU_KIDUL_NAME | | |
| BEAT_KIDUL_TRIAL_2 | Kau tidak melawanku. Ambil Ombak dan kainku. Laut mengingat apa yang diberikan kepadanya. | You did not fight me. Take Ombak and my cloth. The sea remembers what is given to it. |
| @ | | |
| BEAT_KIDUL_TRIAL_3 | Hijau itu surut seperti napas dihembuskan. Kau membungkuk. Tak ada yang melihat. | The green recedes like a breath let go. You bow. Nobody sees. |

Told as belief; she is never fought or touched. VERIFY the tradition of her trial as portrayed.

### kidul_altar (4.9; name NPC_KIDUL_ALTAR_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq4=8` | `write:ombak:jawa_ka`, `learn:jawa_ka`, `give:kain_hijau` |
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

### Act VI: Gua Kala (MQ5, "Ke Rahang Sang Waktu")
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

### Beat `laras_5` (if `!flag:beat_laras_5`, `step:mq5=6`; do `flag:beat_laras_5`)
| Key | ID | EN |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_5_1 | Siapa di sana? Maaf. Aku tak ingat kamu. | Who's there? I'm sorry. I don't remember you. |
| BEAT_LARAS_5_2 | Tapi aku masih menulis Ka. Aku cuma tak tahu untuk siapa. Tanganku bilang, jangan berhenti. | But I'm still writing Ka. I just don't know who it's for. My hand says don't stop. |

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

### Beat `write` (if `!flag:beat_write`, `flag:mq5_3`; do `flag:beat_write`). Then entry `write_card` (if `!flag:mq5_4`, `flag:beat_write`; no lines; do `write:laras:sunda_la,sunda_ra,sunda_sa`): split so a save or quit during the card replays the card, not the talk
| Key | ID | EN |
|-----|----|----|
| BEAT_WRITE_1 | Kala berhenti. Laparnya surut seperti ombak, dan ia berbalik ke dalam gelap, tenang, tidak mati. | Kala stops. The hunger goes out of him like a tide, and he turns back into the dark, calm, not dead. |
| BEAT_WRITE_2 | Separuh lontarmu tergeletak di batu. Kosong. | Your half of the lontar lies on the stone. It's blank. |
| @NPC_SEMAR_NAME | | |
| BEAT_WRITE_3 | Tak ada lagi yang ingat bagaimana namanya ditulis. Kecuali kau. Tuliskanlah, Nak. | Nobody else remembers how her name goes. Except you. Write it, child. |

### Staging NPCs (fixed 2026-11-06)
These NPCs stand in a scene for a beat or a later act. Each gets one line so a talk is never empty. Hariang Banga's file runs, in order: entry 1 `flag:mq4_9` (V3, the Gua Kala mouth), entry 2 `quest:mq4=active` (V4, the Interlude table), entry 3 the `camp_timur` talk (section 9), entry 4 no cond (V5, the throne room before his escape). The others have a single entry with no cond.

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

## 11. Epilogue (`ui/epilogue.tscn`: lines 7, `semar_from = 6`, `semar_to = 6`, variants `{3: "choice_handed", 4: "choice_silent", 5: "choice_sink"}`)
The base card is the first choice of each pair; `_ALT` is the second.

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

## 12. Quest text (`quests.csv`)
- `Q_<ID>_TITLE`, quest id upper-cased. The journal shows the act title; MQ4 shows the Act V title for the whole quest.

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_TITLE | The Night of the Wayang | Malam Wayang |
| Q_MQ1_TITLE | The Crater Seal | Segel Kawah |
| Q_MQG_TITLE | The Borrowed Face | Wajah Pinjaman |
| Q_MQ2_TITLE | Blood on the Pamali | Darah di Pamali |
| Q_MQ3_TITLE | The Seven-Generation Blade | Bilah Tujuh Turunan |
| Q_MQ4_TITLE | The Sea Does Not Forget (steps 4.1-4.2: "The Quiet House" / "Rumah yang Sunyi") | Laut Tak Pernah Lupa |
| Q_MQ5_TITLE | Into the Maw of Time | Ke Rahang Sang Waktu |

- `Q_<ID>_S<n>_OBJ`: the Objective columns of [quests.md](quests.md) 4, `n` 1-based in table order (0.1 is S1, g.1 is S1). Identical to quests.md; the 71 steps:

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_S1_OBJ | Watch the wayang show and survive the night | Saksikan pertunjukan wayang dan bertahanlah malam itu |
| Q_MQ0_S2_OBJ | Choose your path | Pilih jalanmu |
| Q_MQ0_S3_OBJ | Ask Ibu where Laras is | Tanya Ibu di mana Laras berada |
| Q_MQ0_S4_OBJ | Pull Laras's lontar from the burned stage | Ambil lontar Laras dari panggung wayang yang terbakar |
| Q_MQ0_S5_OBJ | Show the lontar to Semar and learn Ka | Tunjukkan lontar itu kepada Semar dan pelajari Ka |
| Q_MQ0_S6_OBJ | Cast Ka three times | Rapalkan Ka tiga kali |
| Q_MQ0_S7_OBJ | Drive the faceless out of the village square | Usir para tanpa rupa dari alun-alun desa |
| Q_MQ0_S8_OBJ | Follow the raiders west | Ikuti jejak para penyerbu ke barat |
| Q_MQ1_S1_OBJ | Break the ambush at the bamboo edge and find Laras's ribbon | Patahkan penyergapan di tepi rumpun bambu dan temukan pita Laras |
| Q_MQ1_S2_OBJ | Rest at the petilasan by the tea terraces | Beristirahat di petilasan dekat kebun teh |
| Q_MQ1_S3_OBJ | Break the ambush at Abah Karna's kampung | Patahkan penyergapan di kampung Abah Karna |
| Q_MQ1_S4_OBJ | Ask Abah Karna about Laras and learn Ga | Tanya Abah Karna tentang Laras dan pelajari Ga |
| Q_MQ1_S5_OBJ | Defeat Sandekala in the river gorge at dusk | Kalahkan Sandekala di ngarai sungai saat senja |
| Q_MQ1_S6_OBJ | Read the defaced Batu Tulis and learn Nga | Baca Batu Tulis yang dirusak dan pelajari Nga |
| Q_MQ1_S7_OBJ | Drive the faceless off the rice terraces | Usir para tanpa rupa dari teras sawah |
| Q_MQ1_S8_OBJ | Find the Weaver who hid Laras and take the Boeh Rarang | Temui Penenun yang menyembunyikan Laras dan terimalah Boeh Rarang |
| Q_MQ1_S9_OBJ | Clear the lake shore | Bersihkan tepi danau |
| Q_MQ1_S10_OBJ | Speak with the woman by the lake and learn Ca | Bicara dengan perempuan di tepi danau dan pelajari Ca |
| Q_MQ1_S11_OBJ | Rest at the petilasan on the crater road | Beristirahat di petilasan jalan kawah |
| Q_MQ1_S12_OBJ | Defeat the Faceless Captain on the crater rim | Kalahkan Kapten Tanpa Rupa di bibir kawah |
| Q_MQ1_S13_OBJ | End the legend again: the false dawn | Akhiri legenda itu sekali lagi: fajar palsu |
| Q_MQG_S1_OBJ | Plan the infiltration with Ciung Wanara at the square gates | Susun rencana menyusup bersama Ciung Wanara di gerbang alun-alun |
| Q_MQG_S2_OBJ | Win the first bout of the king's tournament | Menangkan babak pertama sayembara raja |
| Q_MQG_S3_OBJ | Win the second bout | Menangkan babak kedua |
| Q_MQG_S4_OBJ | Speak with the old chamberlain, Uwa Lengser | Bicara dengan Uwa Lengser, abdi tua istana |
| Q_MQG_S5_OBJ | Rest in the palace courtyard | Beristirahat di pelataran istana |
| Q_MQG_S6_OBJ | Stop the wagon in the cell yard | Hadang kereta di halaman penjara |
| Q_MQG_S7_OBJ | Search the cells for Laras | Geledah sel tahanan, cari Laras |
| Q_MQG_S8_OBJ | Decide the deserter's fate | Putuskan nasib si pembelot |
| Q_MQG_S9_OBJ | Unmask the king | Buka topeng sang raja |
| Q_MQ2_S1_OBJ | Break the ambush at the border gate | Patahkan penyergapan di gerbang perbatasan |
| Q_MQ2_S2_OBJ | Rest at the petilasan by the rice fields | Beristirahat di petilasan dekat sawah |
| Q_MQ2_S3_OBJ | Follow the three leads on Laras: the market, the ruins, the graveyard | Telusuri tiga petunjuk tentang Laras: pasar, reruntuhan, dan kuburan |
| Q_MQ2_S4_OBJ | Learn Ha from Ki Sumarto, whose show you saved | Pelajari Ha dari Ki Sumarto, yang pertunjukannya kau selamatkan |
| Q_MQ2_S5_OBJ | Read Na from the inscription on the Arca's base | Baca Na dari tulisan di dasar Arca |
| Q_MQ2_S6_OBJ | Learn Ca from the lesung women | Pelajari Ca dari para perempuan di lesung |
| Q_MQ2_S7_OBJ | Break the blockade on the foothill | Hancurkan blokade di kaki bukit |
| Q_MQ2_S8_OBJ | Receive the juru kunci's blessing and learn Ra | Terimalah restu juru kunci dan pelajari Ra |
| Q_MQ2_S9_OBJ | Fight through the temple gate | Tembus gerbang candi |
| Q_MQ2_S10_OBJ | Storm the Faceless camp at Candi Seribu | Serbu perkemahan tanpa rupa di Candi Seribu |
| Q_MQ2_S11_OBJ | End Bandung Bondowoso's night | Akhiri malam Bandung Bondowoso |
| Q_MQ2_S12_OBJ | Write Nagawiru's true name on the Pamali stone | Tuliskan nama sejati Nagawiru di batu Pamali |
| Q_MQ2_S13_OBJ | Duel Hariang Banga at the ford | Berduel dengan Hariang Banga di tepi penyeberangan |
| Q_MQ3_S1_OBJ | Break the ambush at the eastern border | Patahkan penyergapan di perbatasan timur |
| Q_MQ3_S2_OBJ | Rest at the petilasan on the savanna | Beristirahat di petilasan di sabana |
| Q_MQ3_S3_OBJ | Find Mpu Wirasana at the forge and learn to break curse marks | Temui Mpu Wirasana di bengkel tempa dan belajar mematahkan tanda kutukan |
| Q_MQ3_S4_OBJ | Help Mbok Srini find Timun Mas | Bantu Mbok Srini mencari Timun Mas |
| Q_MQ3_S5_OBJ | Defeat Buto Ijo | Kalahkan Buto Ijo |
| Q_MQ3_S6_OBJ | Break two practice curse marks | Patahkan dua tanda kutukan latihan |
| Q_MQ3_S7_OBJ | Follow the Hunter's ash trail down the coast | Ikuti jejak abu Si Tanpa Ngaran menyusuri pesisir |
| Q_MQ3_S8_OBJ | Cross the Sea of Sand | Seberangi Lautan Pasir |
| Q_MQ3_S9_OBJ | Rest at the petilasan in the desert | Beristirahat di petilasan di gurun |
| Q_MQ3_S10_OBJ | Lay the cursed keris to rest | Tenangkan keris terkutuk |
| Q_MQ3_S11_OBJ | Face the Nameless Hunter | Hadapi Si Tanpa Ngaran |
| Q_MQ4_S1_OBJ | Go home to Desa Purwa | Pulanglah ke Desa Purwa |
| Q_MQ4_S2_OBJ | Talk to Ibu | Bicara dengan Ibu |
| Q_MQ4_S3_OBJ | Rest at the petilasan on the black-sand coast | Beristirahat di petilasan di pantai pasir hitam |
| Q_MQ4_S4_OBJ | Speak with Mbah Wiryo, the juru kunci of the coast | Bicara dengan Mbah Wiryo, juru kunci pantai |
| Q_MQ4_S5_OBJ | Cross the reef | Seberangi karang |
| Q_MQ4_S6_OBJ | Climb the cliff path | Daki jalan setapak di tebing |
| Q_MQ4_S7_OBJ | Rest at the cliff shrine and listen to the water | Beristirahat di kuil tebing dan dengarkan suara dari air |
| Q_MQ4_S8_OBJ | Pass the Trial of the Waves | Jalani Ujian Ombak |
| Q_MQ4_S9_OBJ | Receive Ombak and the Kain Hijau | Terimalah Ombak dan Kain Hijau |
| Q_MQ5_S1_OBJ | Enter Gua Kala | Masuki Gua Kala |
| Q_MQ5_S2_OBJ | Reclaim La, the first letter of her name, at the Maw | Rebut La, huruf pertama namanya, di mulut gua |
| Q_MQ5_S3_OBJ | Shatter the western time-ward on the Hourglass Sands | Hancurkan penangkal waktu sebelah barat di Pasir Jam Pasir |
| Q_MQ5_S4_OBJ | Shatter the eastern time-ward | Hancurkan penangkal waktu sebelah timur |
| Q_MQ5_S5_OBJ | Reclaim Ra, the second letter of her name, in the Abyss of Forgetting | Rebut Ra, huruf kedua namanya, di Jurang Lupa |
| Q_MQ5_S6_OBJ | Rest at the last petilasan | Beristirahat di petilasan terakhir |
| Q_MQ5_S7_OBJ | Calm Batara Kala | Tenangkan Batara Kala |
| Q_MQ5_S8_OBJ | Write Laras's name | Tuliskan nama Laras |

- Hints, MQ0 only (input-map keys in braces). The step numbers follow the v3.1 table (S3 ask Ibu, S4 stage, S5 Semar, S6 cast, S7 fight); old S4-S7 hint keys move accordingly.

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_S3_HINT | Walk home and press {interact} near Ibu | Pulang lalu tekan {interact} di dekat Ibu |
| Q_MQ0_S4_HINT | Walk to the burned wayang stage | Jalan ke panggung wayang yang terbakar |
| Q_MQ0_S5_HINT | Enter the sanggar and talk to Semar | Masuk ke sanggar lalu bicara dengan Semar |
| Q_MQ0_S6_HINT | Hold {cast}, trace Ka over the guide, then release | Tahan {cast}, gambar Ka mengikuti bayangan, lalu lepas |
| Q_MQ0_S7_HINT | {attack} attacks · {dodge} dodges | {attack} menyerang · {dodge} menghindar |

- SQ-S5 and SQ-M5 are retired ([quests.md](quests.md) 5): drop `Q_SQ_S5_*` and `Q_SQ_M5_*`.


## 13. Codex (`codex.csv` and `data/codex/<id>.tres`)
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

Keep the Faceless codex unlock on the `hunter_raid` beat even though kills would unlock it too.

## 14. Lines dropped
The old keys below are not in this rewrite. Each leaves the CSV only when a grep of `data/`, `ui/`, `entities/`, `zones/`, `autoload/` and `tests/` finds no other reference. Also replaced by this table: the Aji Saka prologue keys `PROLOGUE_6`-`_13`, the data-only hero keys (`_H1`...) from the earlier wiring pass, `NPC_KIDUL_JURUKUNCI_*` and `NPC_KIDUL_ALTAR_1`-`3`/`_H1`, and the retired SQ-S5/SQ-M5 giver lines (`DLG_DAYANG_SUMBI_V1`-`V5`, `DLG_LESUNG_WOMEN_V5`-`V9`, `DLG_SUNDA_WEAVER_5`-`7`/`11`). The `pak_karto` main-path entries (`DLG_PAK_KARTO_V1`-`V7`) leave the main path with Na now read off `arca_base`.

- `BEAT_CAGE`: 5
- `BEAT_HUNTER_NAME`: 2
- `BEAT_HUNTER_SHRINE`: 2
- `BEAT_TRUCE`: 3
- `DLG_BATU_TULIS`: H1, H2
- `DLG_CIUNG_WANARA`: V2
- `DLG_DAYANG_SUMBI`: V1, V2, V3, V4, V5
- `DLG_FACELESS_DESERTER`: H2
- `DLG_IBU`: V3, V1, V9
- `DLG_JURU_KUNCI`: V4, H2
- `DLG_LENGSER`: V3, H2, V4
- `DLG_LESUNG_WOMEN`: V4, V5, V6, V7, V8, V9, H2
- `DLG_MATARAM_DALANG`: V5, H1
- `DLG_MBOK_SRINI`: V3
- `DLG_NAGANINGRUM`: V1, H2
- `DLG_PAK_KARTO`: V1, V2, V3, V4, V5, V6, V7
- `DLG_SEMAR`: V11, V12, V13, V2, V6, H1, V3
- `DLG_SUNDA_ELDER`: V5, V1
- `DLG_SUNDA_WEAVER`: H2
- `DLG_TIMUR_EMPU`: V4, V5, H2
- `DLG_WIRYO`: H2
