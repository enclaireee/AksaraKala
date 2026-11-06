# Script: Story v2 main path (EN and ID)

Every main-path line, keyed. Story: [story_ciung_wanara.md](story_ciung_wanara.md). Steps and flags: [quests.md](quests.md) 4. Written 2026-11-06 (Claude), all **ASSUMED** until the user's playtest; culture facts keep their **VERIFY** tags.

## 1. Rules
- Every main-path talk and story beat is a full, self-contained RPG scene: a player with zero prior knowledge of Sundanese or Javanese folklore must understand 100% of who every character is, what happened, and why the next objective matters without needing to open the Codex.
- The hero (`@NPC_HERO_NAME`, rendered as `{name}`) speaks actively in conversations—asking questions, connecting clues, and confronting villains—rather than standing mute while NPCs monologue.
- Every folklore figure (`Ciung Wanara`, `Nini Balangantrang`, `Dewi Naganingrum`, `Prabu Nagawiru`, `Aria Kebonan`, `Dewi Pangrenyep`, `Hariang Banga`, `Uwa Lengser`, `Mpu Gandring`, `Buto Ijo`, `Batara Kala`) is introduced with clear context in the dialogue before or when they appear.
- Learning Aksara glyphs is framed as acquiring combat wards, royal seals, and counter-curses needed to break the Faceless's hold and save Laras—never as a disconnected classroom lecture.
- Semar is warm and wry ("hehe"). Lengser is sharp and loyal. Ciung Wanara is fierce and brotherly. Hariang Banga is honorable. The Nameless Hunter is cold and relentless.
- EN strings may use `{they}` `{them}` `{their}` `{They}`; ID strings never need them (`dia`, `-nya`).

## 2. Format (for the data wiring)
- Each NPC section is one `data/dialogue/<npc_id>.tres` (`DialogueData`, `npc_id`, `name_key`, `entries`). Entries are listed in order; the first whose `if` holds wins.
- An entry's `lines` are its keys in table order. A row `@NPC_X_NAME` (no text) is a speaker switch: put the string `"@NPC_X_NAME"` in `lines` ([ui.md](ui.md) 3, `ui/dialogue_box.gd`).
- `choices` is `[{"text": KEY, "do": [...]}, ...]`, shown under the last line.
- Beats live in `data/dialogue/beats.tres` (npc_id `beats`, name_key `""`). Lines with no speaker row are narration (empty name tag). Every beat's `if` starts with `!flag:beat_<id>` and its `do` starts with `flag:beat_<id>`, so it plays once even if a later action reloads the zone.
- Keys: new main-path talks use `DLG_<NPC>_V<n>` so they never collide with old keys. Beats `BEAT_<ID>_<n>`. Choices `CHOICE_<ID>_<n>`. All go in `data/text/dialogue.csv` (columns `keys,id,en`).
- "Keep" means: the entry stays as it is in the current `.tres` (side quests). "Drop" means: delete the entry; its old keys go only if nothing else references them.

## 3. Names (`dialogue.csv`, next to the existing `NPC_*_NAME` rows)
| Key | EN | ID |
|-----|----|----|
| NPC_IBU_NAME | Ibu | Ibu |
| NPC_LARAS_NAME | Laras | Laras |
| NPC_NINI_NAME | Nini Balangantrang | Nini Balangantrang |
| NPC_HUNTER_NAME | The Nameless Hunter | Si Tanpa Ngaran |
| NPC_NAGANINGRUM_NAME | Woman by the lake | Perempuan di tepi danau |
| NPC_NAGAWIRU_NAME | Nagawiru | Nagawiru |
| NPC_CIUNG_WANARA_NAME | Ciung Wanara | Ciung Wanara |
| NPC_LENGSER_NAME | Uwa Lengser | Uwa Lengser |
| NPC_FACELESS_DESERTER_NAME | The deserter | Si pembelot |
| NPC_PAMALI_STONE_NAME | Pamali stone | Batu Pamali |
| NPC_BARMA_WIJAYA_NAME | Prabu Barma Wijaya | Prabu Barma Wijaya |
| NPC_HARIANG_BANGA_NAME | Hariang Banga | Hariang Banga |

Boss bar names (`ui.csv`, next to the existing `BOSS_*`): BOSS_FACELESS_CAPTAIN "Faceless Captain" / "Kapten Tanpa Rupa"; BOSS_NAMELESS_HUNTER "The Nameless Hunter" / "Si Tanpa Ngaran"; BOSS_BARMA_WIJAYA "Prabu Barma Wijaya" / "Prabu Barma Wijaya"; BOSS_HARIANG_BANGA "Hariang Banga" / "Hariang Banga".

## 4. Prologue (`PROLOGUE_1`-`_5`, `ui/prologue.tscn`: lines 5, no Semar card: `semar_from = 0`, `semar_to = 0`)
The old `PROLOGUE_1`-`_13` text (Aji Saka) is replaced; keys 6-13 are dropped if unreferenced.

| Key | EN | ID |
|-----|----|----|
| PROLOGUE_1 | Desa Purwa, the night of the wayang. The blencong burns, and the whole village sits before the screen. | Desa Purwa, malam pertunjukan wayang. Blencong menyala, dan seisi desa duduk di depan kelir. |
| PROLOGUE_2 | Your little sister Laras sits beside you, scratching her name onto a strip of lontar. On the back, she wrote yours: {name}. | Adikmu, Laras, duduk di sampingmu, menggores namanya di sehelai lontar. Di baliknya, ia menulis namamu: {name}. |
| PROLOGUE_3 | Then the shadows step off the screen. No faces. Blank masks, and hands that reach. | Lalu bayang-bayang itu turun dari kelir. Tanpa wajah. Topeng kosong, dan tangan yang menggapai. |
| PROLOGUE_4 | "Kak!" They pull her into the dark. All you keep is her lontar. The lamp goes out. | "Kak!" Mereka menyeretnya ke dalam gelap. Yang tersisa hanya lontarnya. Lampu padam. |
| PROLOGUE_5 | Morning. The lontar is still in your hand. Some of her letters have already faded. | Pagi. Lontar itu masih di tanganmu. Sebagian hurufnya sudah memudar. |

## 5. Chapter 0: Desa Purwa (MQ0)

### ibu (new; name NPC_IBU_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=3` | |
| 2 | `flag:mq5_4` | |
| 3 | `quest:mq0=active` | |
| 4 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_IBU_V1 | You're up. The rice has gone cold, but eat something. | Sudah bangun? Nasinya sudah dingin, tapi makanlah. |
| 1 | DLG_IBU_V2 | Laras? Who's Laras, child? It's only ever been you and me. | Laras? Siapa Laras, Nak? Dari dulu cuma ada kau dan Ibu. |
| 1 | DLG_IBU_V3 | You look pale. Bad dream? | Mukamu pucat. Mimpi buruk? |
| 1 | DLG_IBU_V4 | Semar was up all night at the sanggar. Go and see him. | Semar semalaman di sanggar. Temuilah dia. |
| 2 | DLG_IBU_V5 | Laras, set the table, your kakak's home! | Laras, siapkan piring, kakakmu pulang! |
| 2 | DLG_IBU_V6 | Funny. For a moment I thought this house was too quiet. | Aneh. Tadi Ibu kira rumah ini terlalu sepi. |
| 3 | DLG_IBU_V7 | Be careful. The whole village is jumpy since last night. | Hati-hati. Sejak semalam seisi desa gelisah. |
| 4 | DLG_IBU_V8 | Come home when you can. I'll keep your rice warm. | Pulanglah kalau sempat. Nasimu Ibu hangatkan. |

### semar (sanggar; rewrite: drop every old main-path entry, keep none)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=3` | |
| 2 | `step:mq0=4` | `learn:sunda_ka` |
| 3 | `step:mq0=5` | |
| 4 | `step:mq0=6` | |
| 5 | `quest:mq0=active` | |
| 6 | `quest:mq1=active` | |
| 7 | `quest:mqg=active` | |
| 8 | `quest:mq2=active` | |
| 9 | `quest:mq3=active` | |
| 10 | `quest:mq5=active` | |
| 11 | `flag:mq5_4` | |
| 12 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_SEMAR_V1 | Ah, you're awake. Your mother was calling for you. | Ah, sudah bangun. Ibumu memanggil-manggil tadi. |
| 1 | DLG_SEMAR_V2 | Go home first, then come back. I'm always here, hehe. | Pulang dulu, nanti ke sini lagi. Aku di sini terus, hehe. |
| 2 | DLG_SEMAR_V3 | Laras. Yes, I remember her. Don't stare, I'm hard to forget. | Laras. Ya, aku ingat dia. Jangan melotot, aku memang susah dilupakan. |
| 2 | DLG_SEMAR_V4 | The faceless eat names. Hers is on that lontar, and it's fading. | Para tanpa rupa itu memakan nama. Namanya ada di lontar itu, dan sedang memudar. |
| 2 | DLG_SEMAR_V5 | So you'll learn to write. This is Ka. For kakak, what she calls you. | Jadi kau harus belajar menulis. Ini Ka. Untuk kakak, panggilannya padamu. |
| 2 | DLG_SEMAR_V6 | Draw it. A written word is much harder to eat. | Gambarlah. Kata yang tertulis jauh lebih susah dimakan. |
| 3 | DLG_SEMAR_V7 | Again. Three times, until your hand knows it without you. | Lagi. Tiga kali, sampai tanganmu hafal sendiri. |
| 4 | DLG_SEMAR_V8 | Hear that? They came back for something. The plaza, go! | Dengar itu? Mereka kembali mencari sesuatu. Ke alun-alun, cepat! |
| 5 | DLG_SEMAR_V9 | They ran west after that boy. Go, and keep the lontar close. | Mereka lari ke barat mengejar bocah itu. Pergilah, dan jaga lontarnya. |
| 6 | DLG_SEMAR_V10 | The tea terraces are west. Rest at the petilasan there. | Kebun teh ada di barat. Beristirahatlah di petilasan sana. |
| 7 | DLG_SEMAR_V11 | Galuh is through the east gate. Its king wears a borrowed face. | Galuh ada di balik gerbang timur. Rajanya memakai wajah pinjaman. |
| 8 | DLG_SEMAR_V12 | Two brothers, one river. Wars are hungry things, child. | Dua saudara, satu sungai. Perang itu rakus, Nak. |
| 9 | DLG_SEMAR_V13 | East of the river, the old stories are waking up angry. | Di timur sungai, kisah-kisah lama bangun dengan marah. |
| 10 | DLG_SEMAR_V14 | The cave is through the fog behind the village. I'll get there first, hehe. | Guanya lewat kabut di belakang desa. Aku sampai duluan, hehe. |
| 11 | DLG_SEMAR_V15 | Shh, the show's starting. Guess whose lakon it is. | Ssst, pertunjukannya mulai. Tebak lakon siapa. |
| 12 | DLG_SEMAR_V16 | Every story starts with someone who remembers it. | Setiap kisah dimulai dari orang yang mengingatnya. |

### ki_wangsa (the village dalang, your master; replace both entries)
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq5_4` | |
| 2 | `quest:mq0=active` | |
| 3 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_KI_WANGSA_V1 | Tonight we play a new lakon. Someone wrote it down for me. | Malam ini kita mainkan lakon baru. Ada yang menuliskannya untukku. |
| 2 | DLG_KI_WANGSA_V2 | Good show last night. Quiet crowd, though. Like someone was missing. | Pertunjukan semalam bagus. Tapi penontonnya sepi, seperti ada yang kurang. |
| 2 | DLG_KI_WANGSA_V3 | Fetch the blencong oil when you're back, apprentice. | Nanti ambilkan minyak blencong, ya, muridku. |
| 3 | DLG_KI_WANGSA_V4 | A dalang tells. A writer keeps. Be both, if you can. | Dalang bercerita. Penulis menjaga. Jadilah keduanya, kalau bisa. |

### Beat `hunter_raid` (if `!flag:beat_hunter_raid`, `flag:mq0_7`; do `flag:beat_hunter_raid`, `codex:faceless`)
| Key | EN | ID |
|-----|----|----|
| BEAT_HUNTER_RAID_1 | At the west gate a tall shape waits. A blank mask, like the others. The voice is not. | Di gerbang barat, sosok jangkung menunggu. Topeng kosong, seperti yang lain. Suaranya tidak. |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_RAID_2 | Wrong child. We came for the boy with the egg. | Anak yang salah. Kami datang untuk bocah yang membawa telur. |
| BEAT_HUNTER_RAID_3 | Keep her lontar, little writer. Names fade. Even yours. | Simpan lontarnya, penulis kecil. Nama itu memudar. Namamu juga. |
| @NPC_NINI_NAME | | |
| BEAT_HUNTER_RAID_4 | He's gone! And our Ciung ran west in the night with that egg. Please, find him. | Ia sudah pergi! Dan Ciung kami lari ke barat semalam membawa telur itu. Tolong, temukan dia. |

Note: the narration line has no speaker row. Rows are in `lines` order; the Hunter's name tag shows for lines 2-3.

## 6. Chapter 1: Tatar Sunda (MQ1)

### sunda_elder (Abah Karna; replace the main-path entries, keep the SQ-S1/S2 entries after them, then the new idle entry last)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=0` | |
| 2 | `step:mq1=1` | `flag:mq1_2`, `learn:sunda_ga` |
| (keep) | SQ-S1 / SQ-S2 entries, in their current order | |
| 3 | `quest:mq1=active` | |
| (keep) | the current fallback | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_SUNDA_ELDER_V1 | You walked all night? Rest at the petilasan by the tea first, child. | Kau berjalan semalaman? Istirahat dulu di petilasan dekat kebun teh, Nak. |
| 2 | DLG_SUNDA_ELDER_V2 | Masks with no faces, chasing a boy with an egg? They passed at dawn. | Topeng tanpa wajah, mengejar bocah membawa telur? Mereka lewat subuh tadi. |
| 2 | DLG_SUNDA_ELDER_V3 | Their trail goes to the batu tulis. You'll want a shield. This is Ga. | Jejaknya ke batu tulis. Kau butuh perisai. Ini Ga. |
| 2 | DLG_SUNDA_ELDER_V4 | Raise Ga when a boar charges. It hits the light like a wall. | Angkat Ga saat babi hutan menyeruduk. Ia menabrak cahaya itu seperti tembok. |
| 2 | DLG_SUNDA_ELDER_V5 | I'm Abah Karna. When you've time, this village has troubles of its own. | Aku Abah Karna. Kalau sempat, kampung ini juga punya kesusahan sendiri. |
| 3 | DLG_SUNDA_ELDER_V6 | The batu tulis is up the path. The terraces are past it. | Batu tulis ada di atas jalan setapak. Teras sawah di baliknya. |

### batu_tulis (replace the `step:mq1=3` entry; keep the fallback)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=3` | `learn:sunda_nga` |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_BATU_TULIS_V1 | A king's face is carved here. Someone scratched it out, deep. | Di sini terpahat wajah seorang raja. Seseorang menggoresnya habis, dalam-dalam. |
| 1 | DLG_BATU_TULIS_V2 | Under it the letters still hold: Ga, and beside it Nga, Ga with its box open. | Di bawahnya, huruf-huruf masih bertahan: Ga, dan di sampingnya Nga, Ga yang kotaknya terbuka. |
| 1 | DLG_BATU_TULIS_V3 | Nga binds. Even the heavy jurig of this forest can't swing. | Nga mengikat. Jurig hutan yang berat pun tak bisa mengayun. |
| 1 | DLG_BATU_TULIS_V4 | Fresh footprints lead down to the rice terraces. | Jejak kaki baru menuju teras sawah. |

### naganingrum (new, ts_situ, cond `!quest:mq1=done`; name NPC_NAGANINGRUM_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=5` | `learn:sunda_ca` |
| 2 | `flag:mq1_7` | |
| 3 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_NAGANINGRUM_V1 | You carry that lontar like a lamp. Who are you looking for? | Kau membawa lontar itu seperti membawa pelita. Siapa yang kau cari? |
| 1 | DLG_NAGANINGRUM_V2 | A boy with an egg came by. He had... kind eyes. | Tadi lewat seorang bocah membawa telur. Matanya... matanya baik. |
| 1 | DLG_NAGANINGRUM_V3 | Take Ca. It bursts like dawn. A captain calling his men can't finish the call. | Bawalah Ca. Ia meledak seperti fajar. Kapten yang memanggil anak buahnya tak akan selesai berseru. |
| 1 | DLG_NAGANINGRUM_V4 | He went up to the crater. Hurry. | Ia naik ke kawah. Cepatlah. |
| 2 | DLG_NAGANINGRUM_V5 | The crater. Go, please. | Ke kawah. Pergilah, kumohon. |
| 3 | DLG_NAGANINGRUM_V6 | The water's quiet today. Go on, I'm not going anywhere. | Airnya tenang hari ini. Pergilah, aku tak ke mana-mana. |

### Beat `laras_1` (if `!flag:beat_laras_1`, `step:mq1=7`; do `flag:beat_laras_1`)
| Key | EN | ID |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_1_1 | Kak? It's dark here. A man with no face keeps asking my name. | Kak? Di sini gelap. Ada orang tanpa wajah yang terus menanyakan namaku. |
| BEAT_LARAS_1_2 | I won't tell him. I'm writing it on my hand instead, so I don't forget. | Aku tak mau bilang. Kutulis saja di tanganku, biar tidak lupa. |

### Beat `naga` (if `!flag:beat_naga`, `quest:mq1=done`; do `flag:beat_naga`, `flag:mq1_10`, `codex:nagawiru`, `start:mqg`)
| Key | EN | ID |
|-----|----|----|
| BEAT_NAGA_1 | The captain falls. Behind him a great naga lies in chains, its scales dull as old bronze. | Sang kapten tumbang. Di belakangnya seekor naga besar terbelenggu, sisiknya kusam seperti perunggu tua. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_2 | You followed me all this way? You're either brave or stupid. | Kau mengikutiku sejauh ini? Kau ini berani atau bodoh. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_NAGA_3 | I was a king once. Galuh. The man on my throne wears my face. | Dulu aku raja. Galuh. Orang di singgasanaku memakai wajahku. |
| BEAT_NAGA_4 | The egg, boy. Give it here. | Telur itu, Nak. Berikan padaku. |
| BEAT_NAGA_5 | The shell cracks in the naga's breath. A rooster chick tumbles out, already angry. | Cangkangnya retak oleh napas sang naga. Seekor anak ayam jantan terguling keluar, sudah galak. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_6 | Then I'm going to Galuh. Coming? Your village's east gate is the short way. | Kalau begitu aku ke Galuh. Ikut? Gerbang timur desamu jalan pintasnya. |

Note: BEAT_NAGA_5 is narration under Nagawiru's tag. If the box can't clear a tag mid-entry, write it as Nagawiru's line instead: "Ah. There. Already angry, like his father." / "Nah. Itu dia. Sudah galak, seperti ayahnya." (pick one in wiring; do not add a new speaker-clear syntax).

### dayang_sumbi (SQ-S5 giver, cond `quest:mq1=done`; drop the old `step:mq1=6` and `flag:mq1_7` entries)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:sq_s5=done` | |
| 2 | `quest:sq_s5=active` | |
| 3 | `quest:sq_s5=available` | `start:sq_s5` |
| 4 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_DAYANG_SUMBI_V1 | He's sleeping now. The story can rest. | Ia tertidur sekarang. Kisahnya bisa beristirahat. |
| 2 | DLG_DAYANG_SUMBI_V2 | Hang the cloth on the east post, then cast Ca. The false dawn stops him. | Gantung kain itu di tiang timur, lalu rapalkan Ca. Fajar palsu menghentikannya. |
| 3 | DLG_DAYANG_SUMBI_V3 | My son is building a boat on the crater again. Every night, the same night. | Anakku membangun perahu di kawah lagi. Setiap malam, malam yang sama. |
| 3 | DLG_DAYANG_SUMBI_V4 | An old story, woken up wrong. He doesn't know me anymore. | Kisah lama, terbangun dengan keliru. Ia tak mengenaliku lagi. |
| 3 | DLG_DAYANG_SUMBI_V5 | Ask the weaver for the boeh rarang. Only a false dawn stops him. | Mintalah boeh rarang pada si penenun. Hanya fajar palsu yang bisa menghentikannya. |
| 4 | DLG_DAYANG_SUMBI_V6 | The lake remembers everything. I wish it didn't. | Danau ini ingat segalanya. Andai saja tidak. |

### sunda_weaver (SQ-S5 step 1)
Re-gate the entry with `give:boeh_rarang` from `step:mq1=5` to `step:sq_s5=0`. Its lines (DLG_SUNDA_WEAVER_1-7) stay; line 7 "I hope the cloth helps at the crater rim" still fits. The `flag:mq1_5` entry (DLG_SUNDA_WEAVER_11, the terraces) and the fallback stay.

## 7. Chapter 2: Keraton Galuh (MQG)

### ciung_wanara (new, kg_alun; name NPC_CIUNG_WANARA_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq2=active` | |
| 2 | `step:mqg=0` | |
| 3 | `step:mqg=1` | |
| 4 | `quest:mqg=active` | |
| 5 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_CIUNG_WANARA_V1 | They say Pangrenyep's son is raising an army. My brother, apparently. | Katanya anak Pangrenyep mengumpulkan pasukan. Saudaraku, rupanya. |
| 2 | DLG_CIUNG_WANARA_V2 | My rooster fights in the ring. You fight whoever tries to cheat. Deal? | Ayamku bertarung di gelanggang. Kau hajar siapa pun yang curang. Setuju? |
| 2 | DLG_CIUNG_WANARA_V3 | Win both bouts and the king has to see us. | Menangkan dua babak, dan raja terpaksa menemui kita. |
| 3 | DLG_CIUNG_WANARA_V4 | One more bout. They're getting nervous up on the dais. | Satu babak lagi. Mereka di panggung mulai gelisah. |
| 4 | DLG_CIUNG_WANARA_V5 | This palace smells of old incense and lies. | Istana ini bau dupa tua dan dusta. |
| 5 | DLG_CIUNG_WANARA_V6 | Galuh will have a fair king. Someday. | Galuh akan punya raja yang adil. Suatu hari. |

### Beat `galuh_bout` (if `!flag:beat_galuh_bout`, `flag:mqg_2`; do `flag:beat_galuh_bout`, `codex:ciung_wanara`)
| Key | EN | ID |
|-----|----|----|
| BEAT_GALUH_BOUT_1 | A roar goes up from the ring. Ciung Wanara's rooster has beaten the king's. | Sorak membahana dari gelanggang. Ayam Ciung Wanara mengalahkan ayam sang raja. |
| @NPC_LENGSER_NAME | | |
| BEAT_GALUH_BOUT_2 | Those eyes... the queen's eyes. Heavens. Come and see me, both of you. Quietly! | Mata itu... mata sang permaisuri. Ya ampun. Temui aku, kalian berdua. Diam-diam! |

The rooster fight stays off-screen ([quests.md](quests.md) MQG sensitivity).

### lengser (new, kg_alun, cond `flag:mqg_2`; name NPC_LENGSER_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mqg=2` | `codex:lengser` |
| 2 | `flag:choice_freed` | |
| 3 | `flag:choice_handed` | |
| 4 | `quest:mqg=active` | |
| 5 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_LENGSER_V1 | I'm Uwa Lengser. I served the true king, and I'll serve his son. | Aku Uwa Lengser. Aku mengabdi pada raja sejati, dan akan mengabdi pada putranya. |
| 1 | DLG_LENGSER_V2 | The taken? Brought in at night through the cell gate. Never out again. | Yang diculik? Dibawa masuk malam-malam lewat gerbang sel. Tak pernah keluar lagi. |
| 1 | DLG_LENGSER_V3 | I'll open the palace. Rest in the courtyard, then search the cells. | Istana kubukakan. Beristirahatlah di pelataran, lalu geledah sel-selnya. |
| 1 | DLG_LENGSER_V4 | And mind the king. He smiles with a face that isn't his. | Dan waspadai sang raja. Ia tersenyum dengan wajah yang bukan miliknya. |
| 2 | DLG_LENGSER_V5 | You let that deserter go? Hm. Mercy is a king's habit. Careful, it's catching. | Kau lepaskan si pembelot? Hm. Ampunan itu kebiasaan raja. Hati-hati, menular. |
| 3 | DLG_LENGSER_V6 | Your deserter is fed and locked up. Galuh will judge him fairly. I'll see to it. | Pembelotmu sudah makan dan dikurung. Galuh akan mengadilinya dengan adil. Aku yang jamin. |
| 4 | DLG_LENGSER_V7 | Quietly, quietly. The guards here can't count their own fingers, but still. | Pelan-pelan. Penjaga di sini menghitung jari sendiri pun salah, tapi tetap saja. |
| 5 | DLG_LENGSER_V8 | Galuh breathes easier. So do my knees. | Galuh bernapas lega. Lututku juga. |

### Beat `laras_2` (if `!flag:beat_laras_2`, `step:mqg=4`; do `flag:beat_laras_2`)
| Key | EN | ID |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_2_1 | Kak, are you in a palace? I dreamed you were. There's no palace here. | Kak, kau di istana? Aku memimpikannya. Di sini tak ada istana. |
| BEAT_LARAS_2_2 | Only the dark. And something breathing, very slowly. | Cuma gelap. Dan sesuatu yang bernapas, pelan sekali. |

### faceless_deserter (new, kg_penjara; name NPC_FACELESS_DESERTER_NAME) — choice 1
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `step:mqg=5` | | CHOICE_DESERTER_1 → `flag:choice_freed`; CHOICE_DESERTER_2 → `flag:choice_handed` |
| 2 | `flag:choice_freed` | | |
| 3 | `flag:choice_handed` | | |
| 4 | (none) | | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_FACELESS_DESERTER_V1 | Don't! I'm not... I was a potter, I think. I can't remember my wife's face. | Jangan! Aku bukan... dulu aku pembuat gerabah, rasanya. Aku lupa wajah istriku. |
| 1 | DLG_FACELESS_DESERTER_V2 | Names? They take the names first. I only carried the ones without. | Nama? Nama diambil duluan. Aku cuma mengangkut yang sudah tanpa nama. |
| 1 | DLG_FACELESS_DESERTER_V3 | The king is behind that door. Please... what will you do with me? | Raja ada di balik pintu itu. Tolong... mau kau apakan aku? |
| 2 | DLG_FACELESS_DESERTER_V4 | I'll go when the guards look away. Thank you. | Aku pergi saat penjaga lengah. Terima kasih. |
| 3 | DLG_FACELESS_DESERTER_V5 | Lengser, then. Better than the dark. | Lengser, kalau begitu. Lebih baik daripada gelap. |
| 4 | DLG_FACELESS_DESERTER_V6 | Get them off me first! | Singkirkan mereka dulu! |

| Key | EN | ID |
|-----|----|----|
| CHOICE_DESERTER_1 | Go. Find your wife's face. | Pergilah. Carilah wajah istrimu. |
| CHOICE_DESERTER_2 | Lengser will keep you safe, and judge you. | Lengser akan menjagamu, dan mengadilimu. |

### Beat `cage` (if `!flag:beat_cage`, `quest:mqg=done`; do `flag:beat_cage`, `codex:barma_wijaya`, `start:mq2`)
| Key | EN | ID |
|-----|----|----|
| BEAT_CAGE_1 | The glamour shatters. Under the king's face is an old minister's, grey and frightened. | Pesona itu pecah. Di balik wajah raja ada wajah seorang patih tua, kelabu dan ketakutan. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_CAGE_2 | Into the cage. You, and Pangrenyep with you. | Masuk kandang. Kau, dan Pangrenyep bersamamu. |
| @NPC_BARMA_WIJAYA_NAME | | |
| BEAT_CAGE_3 | The girl? She was never here. The forgotten go east, to the cave. I only... fed it. | Gadis itu? Tak pernah di sini. Yang terlupa pergi ke timur, ke gua. Aku cuma... memberinya makan. |
| @NPC_HUNTER_NAME | | |
| BEAT_CAGE_4 | Cage the man, little writer. His name is mine now. | Kurunglah orangnya, penulis kecil. Namanya sudah milikku. |
| BEAT_CAGE_5 | East, then. Over the river, where two brothers are about to go to war. | Ke timur, kalau begitu. Menyeberangi sungai, tempat dua saudara akan berperang. |

BEAT_CAGE_5 is narration (same note as BEAT_NAGA_5: if a tag can't clear, give it to the Hunter as "Go east, then. The river is about to run red." / "Pergilah ke timur. Sungai itu akan segera memerah.").

## 8. Chapter 3: Mataram (MQ2)

### mataram_dalang (Ki Sumarto; replace the main-path entries, keep the SQ-M4 entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=0` | |
| 2 | `step:mq2=1` | `learn:jawa_ha` |
| (keep) | SQ-M4 entries | |
| 3 | `quest:mq2=active` | |
| (keep) | the current fallback | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_MATARAM_DALANG_V1 | Rest at the petilasan by the fields first. You look half-dead. | Istirahat dulu di petilasan dekat sawah. Kau kelihatan setengah mati. |
| 2 | DLG_MATARAM_DALANG_V2 | West bank, east bank, and my market squeezed between their war. | Tepi barat, tepi timur, dan pasarku terjepit di tengah perang mereka. |
| 2 | DLG_MATARAM_DALANG_V3 | I'm Ki Sumarto. I stitch more wounds than puppets now. Here, learn Ha. | Aku Ki Sumarto. Kini aku lebih sering menjahit luka daripada wayang. Ini, pelajari Ha. |
| 2 | DLG_MATARAM_DALANG_V4 | Ha heals. Out east they say it lifts curses too. Remember that. | Ha menyembuhkan. Di timur, katanya ia juga mengangkat kutukan. Ingat itu. |
| 2 | DLG_MATARAM_DALANG_V5 | Pak Karto the stone-carver is by the ruins. Both armies want them. | Pak Karto si pemahat batu ada di dekat reruntuhan. Dua pasukan sama-sama mengincarnya. |
| 3 | DLG_MATARAM_DALANG_V6 | Hariang Banga isn't cruel. He wants his mother back. So would I. | Hariang Banga bukan orang kejam. Ia ingin ibunya kembali. Aku pun begitu. |

### pak_karto (replace all main-path entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=2` | `learn:jawa_na` |
| 2 | `step:mq2=3` | |
| 3 | `quest:mq2=active`, `!flag:mq2_3` | |
| 4 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_PAK_KARTO_V1 | Ki Sumarto sent you? Good. I need someone who can break stone. | Ki Sumarto yang mengirimmu? Bagus. Aku butuh orang yang bisa memecah batu. |
| 1 | DLG_PAK_KARTO_V2 | This is Na. It dashes you straight through whatever stands in front. | Ini Na. Ia membawamu menerjang lurus menembus apa pun di depanmu. |
| 1 | DLG_PAK_KARTO_V3 | The statues in the ruins are old stone, cracked inside. Na splits them. | Arca di reruntuhan itu batu tua, retak di dalam. Na membelahnya. |
| 1 | DLG_PAK_KARTO_V4 | Clear the ruins before the armies make a graveyard of them. | Bersihkan reruntuhan itu sebelum dua pasukan menjadikannya kuburan. |
| 2 | DLG_PAK_KARTO_V5 | The ruins. Mind the statues, they wake when you pass. | Reruntuhan itu. Hati-hati, arcanya bangun kalau kau lewat. |
| 3 | DLG_PAK_KARTO_V6 | I carve stone. See Ki Sumarto at the market first. | Aku pemahat batu. Temui Ki Sumarto di pasar dulu. |
| 4 | DLG_PAK_KARTO_V7 | Stone remembers longer than people. Most days. | Batu ingat lebih lama daripada manusia. Biasanya. |

### lesung_women (replace all entries; adds the SQ-M5 giver)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=4` | `learn:jawa_ca` |
| 2 | `quest:sq_m5=done` | |
| 3 | `quest:sq_m5=active` | |
| 4 | `flag:mq2_5`, `quest:sq_m5=available` | `start:sq_m5` |
| 5 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_LESUNG_WOMEN_V1 | Come, child! A war won't stop us pounding rice. | Mari, Nak! Perang tak akan menghentikan kami menumbuk padi. |
| 1 | DLG_LESUNG_WOMEN_V2 | Tuk, tuk, tuk. Feel the rhythm? That's Ca. It quickens your hands. | Tuk, tuk, tuk. Terasa iramanya? Itulah Ca. Ia mempercepat tanganmu. |
| 1 | DLG_LESUNG_WOMEN_V3 | Draw it before a big fight, and every swing comes quicker. | Gambarlah sebelum pertarungan besar, dan setiap ayunan jadi lebih cepat. |
| 1 | DLG_LESUNG_WOMEN_V4 | Mbah Marto keeps the temple keys. Ask him for the tiger. | Mbah Marto memegang kunci candi. Mintalah macan padanya. |
| 2 | DLG_LESUNG_WOMEN_V5 | Our grandmothers would be proud. So are we. | Nenek kami pasti bangga. Kami juga. |
| 3 | DLG_LESUNG_WOMEN_V6 | Go! The temples, while our false dawn holds. | Pergilah! Ke candi, selagi fajar palsu kami bertahan. |
| 4 | DLG_LESUNG_WOMEN_V7 | Our grandmothers told of a prince who built a thousand temples in a night. | Nenek kami bercerita tentang pangeran yang membangun seribu candi dalam semalam. |
| 4 | DLG_LESUNG_WOMEN_V8 | Now the stones move again after dark. The story is replaying itself. | Kini batu-batu itu bergerak lagi tiap malam. Kisahnya terulang sendiri. |
| 4 | DLG_LESUNG_WOMEN_V9 | When he comes, we'll pound the lesung and fool the dawn. You stop him. | Kalau ia datang, kami tumbuk lesung untuk menipu fajar. Kau yang hentikan dia. |
| 5 | DLG_LESUNG_WOMEN_V10 | We pound rice and sing. Join us anytime. | Kami menumbuk padi dan bernyanyi. Ikutlah kapan saja. |

### juru_kunci (Mbah Marto; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=5` | `learn:jawa_ra` |
| 2 | `quest:mq2=active`, `flag:mq2_6` | |
| 3 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_JURU_KUNCI_V1 | Guests, in wartime? Mbah Marto, keeper of the temple keys. | Tamu, di masa perang? Mbah Marto, juru kunci candi. |
| 1 | DLG_JURU_KUNCI_V2 | The faceless have camped at the temples. They wake the old soldiers' curse. | Para tanpa rupa berkemah di candi. Mereka membangkitkan kutukan prajurit lama. |
| 1 | DLG_JURU_KUNCI_V3 | Take Ra. A tiger spirit fights beside you, and the cursed turn to face it. | Bawalah Ra. Roh macan bertarung di sisimu, dan yang terkutuk akan berbalik menghadapinya. |
| 1 | DLG_JURU_KUNCI_V4 | Strike their backs then. The temple stairs are open to you. | Saat itulah pukul punggungnya. Tangga candi terbuka untukmu. |
| 2 | DLG_JURU_KUNCI_V5 | Break that camp. The dead here deserve their sleep. | Hancurkan perkemahan itu. Arwah di sini berhak tidur tenang. |
| 3 | DLG_JURU_KUNCI_V6 | Mind the temple gate. Stones can fall. | Hati-hati di gerbang candi. Batunya bisa runtuh. |

### Beat `hunter_war` (if `!flag:beat_hunter_war`, `flag:mq2_6`; do `flag:beat_hunter_war`)
| Key | EN | ID |
|-----|----|----|
| BEAT_HUNTER_WAR_1 | As you turn to go, a tall shape steps out of the temple's shadow. | Saat kau beranjak, sosok jangkung keluar dari bayangan candi. |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_WAR_2 | Two armies, little writer. Twice the forgetting. He has never eaten so well. | Dua pasukan, penulis kecil. Dua kali lipat yang terlupa. Ia belum pernah makan sekenyang ini. |
| BEAT_HUNTER_WAR_3 | Your sister still asks for you. Less every night. | Adikmu masih menanyakanmu. Makin jarang tiap malam. |

### Beat `laras_3` (if `!flag:beat_laras_3`, `step:mq2=7`; do `flag:beat_laras_3`)
| Key | EN | ID |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_3_1 | I wrote your name again tonight, Kak. So I won't lose it. | Malam ini kutulis lagi namamu, Kak. Biar tidak hilang. |
| BEAT_LARAS_3_2 | The lontar's shorter now. I can't remember how the last letters went. | Lontarnya makin pendek. Aku lupa bagaimana huruf-huruf terakhirnya. |

### pamali_stone (new, kg_pamali, cond `flag:mq2_7`; name NPC_PAMALI_STONE_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=7` | `write:nagawiru:jawa_na,sunda_ga` |
| 2 | (none) | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_PAMALI_STONE_V1 | An old boundary stone. A name was cut here once, then scraped away. | Batu batas tua. Dulu sebuah nama dipahat di sini, lalu dikikis. |
| 1 | DLG_PAMALI_STONE_V2 | Nagawiru. Write it back: Na from the east, Ga from the west. | Nagawiru. Tuliskan kembali: Na dari timur, Ga dari barat. |
| 2 | DLG_PAMALI_STONE_V3 | The name holds. The river sounds different now. | Nama itu bertahan. Suara sungai kini terdengar lain. |

### Beat `ford` (if `!flag:beat_ford`, `flag:mq2_8`; do `flag:beat_ford`)
| Key | EN | ID |
|-----|----|----|
| BEAT_FORD_1 | Banners on the east bank. A young man wades into the ford alone. | Panji-panji di tepi timur. Seorang pemuda mengarungi penyeberangan sendirian. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_FORD_2 | You helped cage my mother. I won't spend my men on this. Just you and me. | Kau ikut mengurung ibuku. Tak akan kukorbankan pasukanku untuk ini. Cukup kau dan aku. |

### Beat `truce` (if `!flag:beat_truce`, `quest:mq2=done`; do `flag:beat_truce`, `codex:pamali`, `start:mq3`) — choice 2
| Key | EN | ID |
|-----|----|----|
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_TRUCE_1 | Enough. I yield. | Cukup. Aku menyerah. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_TRUCE_2 | Hariang Banga. Ciung Wanara. To fight your brother is pamali. | Hariang Banga. Ciung Wanara. Melawan saudara sendiri itu pamali. |
| BEAT_TRUCE_3 | Let this river be the line between you. West, and east. | Biarlah sungai ini jadi batas kalian. Barat, dan timur. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_TRUCE_4 | East, then. Writer, the road to the cave runs through my land. I'll show you. | Timur, kalau begitu. Penulis, jalan ke gua melewati tanahku. Akan kutunjukkan. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_TRUCE_5 | And the man in the cage? You got us here. You tell me. | Lalu orang di kandang itu? Kau yang membawa kami sampai sini. Kau yang bilang. |

| Key | EN | ID | do |
|-----|----|----|----|
| CHOICE_MERCY_1 | Show him mercy. Even he was robbed of something. | Ampuni dia. Ia pun pernah dirampas sesuatu. | `flag:choice_mercy` |
| CHOICE_MERCY_2 | (Say nothing.) | (Diam saja.) | `flag:choice_silent` |

Nagawiru speaks from the water and Ciung Wanara comes to the west bank (this replaces "the two queens" in [quests.md](quests.md) MQ2: Pangrenyep is caged).

## 9. Chapter 4: Tanah Timur (MQ3)

### timur_empu (Mpu Wirasana; replace the main-path entries, keep the SQ-T3 entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq3=0` | |
| 2 | `step:mq3=1` | |
| 3 | `step:mq3=2`; also `step:mq3=3` (two entries, same line) | |
| 4 | `step:mq3=4` | |
| 5 | `flag:choice_reforge` | |
| 6 | `flag:choice_sink` | |
| (keep) | SQ-T3 entries and the current fallback | |

| Entry | Key | EN | ID |
|-------|-----|----|----|
| 1 | DLG_TIMUR_EMPU_V1 | Rest first. The savanna is crueller than it looks. | Istirahat dulu. Sabana ini lebih kejam daripada kelihatannya. |
| 2 | DLG_TIMUR_EMPU_V2 | The way into Kala's cave? You'll find it at the end of a blade. | Jalan ke gua Kala? Kau akan menemukannya di ujung sebilah keris. |
| 2 | DLG_TIMUR_EMPU_V3 | A keris I knew woke in the old shrine, angry and grieving. Kala woke it. | Sebilah keris yang kukenal bangun di candi tua, marah dan berduka. Kala yang membangunkannya. |
| 2 | DLG_TIMUR_EMPU_V4 | It marks its victims with curses. Aksara break them. Practise on my stakes. | Ia menandai korbannya dengan kutukan. Aksara mematahkannya. Berlatihlah di tonggakku. |
| 2 | DLG_TIMUR_EMPU_V5 | But first, Mbok Srini by the river. Her girl is in trouble. | Tapi temui dulu Mbok Srini di tepi sungai. Anaknya dalam bahaya. |
| 3 | DLG_TIMUR_EMPU_V6 | Mbok Srini, by the river. Go on. | Mbok Srini, di tepi sungai. Pergilah. |
| 4 | DLG_TIMUR_EMPU_V7 | Two marks. Break them, and you're ready for the shrine. | Dua tanda. Patahkan, dan kau siap ke candi. |
| 5 | DLG_TIMUR_EMPU_V8 | You brought it back. This time I'll make it a blade that protects. | Kau membawanya kembali. Kali ini akan kutempa jadi bilah yang melindungi. |
| 6 | DLG_TIMUR_EMPU_V9 | The river has it. Maybe that's kinder. | Sungai yang menyimpannya. Mungkin itu lebih baik. |

### mbok_srini (replace the entries' text, keep their `if` and `do`)
| Entry (current `if`) | Key | EN | ID |
|-------|-----|----|----|
| `step:mq3=2` | DLG_MBOK_SRINI_V1 | My Timun Mas! Buto Ijo is chasing her across the field. | Timun Masku! Buto Ijo mengejarnya ke ladang. |
| `step:mq3=2` | DLG_MBOK_SRINI_2 (keep) | Take these four pouches: cucumber seeds, needles, salt and terasi. | (keep) |
| `step:mq3=2` | DLG_MBOK_SRINI_V2 | Throw them one by one when he's close. That's how she escapes, in the tale. | Lemparkan satu per satu saat ia dekat. Begitulah ia lolos, dalam dongeng. |
| `step:mq3=2` | DLG_MBOK_SRINI_V3 | The eastern field. Please hurry. | Ladang timur. Cepatlah, kumohon. |
| `flag:mq3_4` | DLG_MBOK_SRINI_5 (keep), DLG_MBOK_SRINI_6 (keep) | | |
| `quest:mq3=active` | DLG_MBOK_SRINI_V4 | The eastern field, child! Before he catches her! | Ladang timur, Nak! Sebelum ia tertangkap! |
| (none) | DLG_MBOK_SRINI_8 (keep) | | |

Add before the `quest:mq3=active` entry: `step:mq3=1` → DLG_MBOK_SRINI_7 (keep, "See the empu at the banyan forge first").

### Beat `laras_4` (if `!flag:beat_laras_4`, `step:mq3=6`; do `flag:beat_laras_4`)
| Key | EN | ID |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_4_1 | Kak... I can't see your face anymore. I try, and it's just a shape. | Kak... aku tak bisa melihat wajahmu lagi. Kucoba, tapi cuma bayangan. |
| BEAT_LARAS_4_2 | I have one letter of your name left. I'm holding it very tight. | Namamu tinggal satu huruf. Kugenggam erat-erat. |

### Beat `keris` (if `!flag:beat_keris`, `flag:mq3_7`; do `flag:beat_keris`) — choice 3
| Key | EN | ID |
|-----|----|----|
| BEAT_KERIS_1 | The keris falls quiet in your hand. The curse has burned itself out. | Keris itu terdiam di tanganmu. Kutukannya telah habis terbakar. |
| BEAT_KERIS_2 | It's only steel now. Steel can be made again, or let go. | Kini ia hanya besi. Besi bisa ditempa ulang, atau direlakan. |

| Key | EN | ID | do |
|-----|----|----|----|
| CHOICE_KERIS_1 | Take it to the empu to reforge. | Bawa ke sang empu untuk ditempa ulang. | `flag:choice_reforge` |
| CHOICE_KERIS_2 | Give it to the river. | Serahkan pada sungai. | `flag:choice_sink` |

### Beat `hunter_shrine` (if `!flag:beat_hunter_shrine`, `flag:beat_keris`; do `flag:beat_hunter_shrine`)
The Hunter boss's cond stays `flag:beat_keris`; this beat plays as he appears.

| Key | EN | ID |
|-----|----|----|
| BEAT_HUNTER_SHRINE_1 | Behind you, the shrine's shadow stands up. | Di belakangmu, bayangan candi berdiri. |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_SHRINE_2 | No more echoes, little writer. Just you, me, and the one letter she has left. | Tak ada gema lagi, penulis kecil. Tinggal kau, aku, dan satu huruf yang tersisa padanya. |

### Beat `hunter_name` (if `!flag:beat_hunter_name`, `quest:mq3=done`; do `flag:beat_hunter_name`, `codex:nameless_hunter`, `start:mq5`)
| Key | EN | ID |
|-----|----|----|
| BEAT_HUNTER_NAME_1 | The mask cracks down the middle. Under it is a young man's face: the face the false king wore. | Topeng itu retak di tengah. Di baliknya, wajah seorang pemuda: wajah yang dulu dipakai raja palsu. |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_NAME_2 | Aria... Kebonan. I knew that word, once. | Aria... Kebonan. Dulu aku tahu kata itu. |
| BEAT_HUNTER_NAME_3 | He runs like ink in the rain. Far west, in a cage in Galuh, an old man touches his own face. | Ia luntur seperti tinta kena hujan. Jauh di barat, di sebuah kandang di Galuh, seorang lelaki tua meraba wajahnya sendiri. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_HUNTER_NAME_4 | The cave is behind your village, through the fog. My brother and I will hold its mouth. | Guanya di belakang desamu, lewat kabut. Aku dan saudaraku akan menjaga mulutnya. |

BEAT_HUNTER_NAME_3 is narration (same note as BEAT_NAGA_5; fallback as the Hunter: "Give it back to him. It was always his." / "Kembalikan padanya. Itu memang selalu miliknya.").

## 10. Finale: Gua Kala (MQ5)

### Beat `mouth` (if `!flag:beat_mouth`, `flag:mq5_1`; do `flag:beat_mouth`)
| Key | EN | ID |
|-----|----|----|
| BEAT_MOUTH_1 | Two banners at the cave mouth, one from each bank of the Pamali. | Dua panji di mulut gua, satu dari tiap tepi Pamali. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_MOUTH_2 | Go on. Whatever comes out of there goes through us first. | Masuklah. Apa pun yang keluar dari sana harus lewat kami dulu. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_MOUTH_3 | Bring her home, writer. | Bawa dia pulang, penulis. |

### Beat `laras_5` (if `!flag:beat_laras_5`, `step:mq5=2`; do `flag:beat_laras_5`)
| Key | EN | ID |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| BEAT_LARAS_5_1 | Who's there? I'm sorry. I don't remember you. | Siapa di sana? Maaf. Aku tak ingat kamu. |
| BEAT_LARAS_5_2 | I'm still writing, though. I just don't know whose name it is anymore. | Tapi aku masih menulis. Aku cuma sudah tak tahu ini nama siapa. |

### semar_kala (replace both entries' text, keep their `if`)
| Entry | Key | EN | ID |
|-------|-----|----|----|
| `!flag:mq5_3` | DLG_SEMAR_KALA_V1 | Told you I'd get here first, hehe. Don't ask how. | Sudah kubilang aku sampai duluan, hehe. Jangan tanya bagaimana. |
| `!flag:mq5_3` | DLG_SEMAR_KALA_V2 | Kala isn't wicked. He's hungry. He eats what nobody holds on to. | Kala tidak jahat. Ia lapar. Ia memakan apa yang tak lagi digenggam orang. |
| `!flag:mq5_3` | DLG_SEMAR_KALA_V3 | So hold on. You're the last one who remembers her. | Jadi genggam erat. Kaulah satu-satunya yang masih mengingatnya. |
| (none) | DLG_SEMAR_KALA_V4 | Well? Write it, child. | Nah? Tuliskanlah, Nak. |

### Beat `write` (if `!flag:beat_write`, `flag:mq5_3`; do `flag:beat_write`). Then entry `write_card` (if `!flag:mq5_4`, `flag:beat_write`; no lines; do `write:laras:sunda_la,sunda_ra,sunda_sa`): split so a save or quit during the card replays the card, not the talk, until the name is written
| Key | EN | ID |
|-----|----|----|
| BEAT_WRITE_1 | Kala stops. The hunger goes out of him like a tide, and he turns back into the dark. | Kala berhenti. Laparnya surut seperti ombak, dan ia berbalik ke dalam gelap. |
| BEAT_WRITE_2 | Laras's lontar lies on the stone. It's blank. | Lontar Laras tergeletak di batu. Kosong. |
| @NPC_SEMAR_NAME | | |
| BEAT_WRITE_3 | Nobody else remembers how her name goes. So, child. Write it. | Tak ada lagi yang ingat bagaimana namanya ditulis. Jadi, Nak. Tuliskanlah. |

## 11. Epilogue (`ui/epilogue.tscn`: lines 7, `semar_from = 6`, `semar_to = 6`, variants `{3: "choice_handed", 4: "choice_silent", 5: "choice_sink"}`)
The base card is the first choice of each pair; `_ALT` is the second. The old EPILOGUE_1-6 text is replaced.

| Key | EN | ID |
|-----|----|----|
| EPILOGUE_1 | Laras comes home. Ibu sets a plate for her like always. Nobody remembers that she was ever gone. | Laras pulang. Ibu menyiapkan piring untuknya seperti biasa. Tak ada yang ingat ia pernah hilang. |
| EPILOGUE_2 | West of the Pamali, Ciung Wanara rules a fair Sunda. East of it, Hariang Banga rules Java. They write to each other. | Di barat Pamali, Ciung Wanara memerintah Sunda dengan adil. Di timurnya, Hariang Banga memerintah Jawa. Mereka saling berkirim surat. |
| EPILOGUE_3 | The deserter found his way home. He still can't recall his wife's face, but she remembers his. | Si pembelot menemukan jalan pulang. Ia masih lupa wajah istrinya, tapi istrinya ingat wajahnya. |
| EPILOGUE_3_ALT | Lengser judged the deserter fairly. He mends the palace pots now, and Galuh feeds him. | Lengser mengadili si pembelot dengan adil. Kini ia memperbaiki tempayan istana, dan Galuh memberinya makan. |
| EPILOGUE_4 | Once a year, Ciung Wanara opens the cage so the old man can see the sky. He never asks for more. | Setahun sekali, Ciung Wanara membuka kandang itu agar lelaki tua itu bisa melihat langit. Ia tak pernah meminta lebih. |
| EPILOGUE_4_ALT | The cage stays shut. In the legend, it always does. | Kandang itu tetap terkunci. Dalam legenda, memang selalu begitu. |
| EPILOGUE_5 | Mpu Wirasana reforged the keris. It guards a village gate in the east, and nobody fears it. | Mpu Wirasana menempa ulang keris itu. Kini ia menjaga gerbang sebuah desa di timur, dan tak ada yang takut padanya. |
| EPILOGUE_5_ALT | The river keeps the keris. Some nights, the fishermen say, the water hums. | Sungai menyimpan keris itu. Kata para nelayan, kadang di malam hari airnya bersenandung. |
| EPILOGUE_6 | And tonight the village wayang plays a new lakon. Sit, sit. It's about someone you know, hehe. | Dan malam ini, wayang desa memainkan lakon baru. Duduk, duduk. Ini tentang seseorang yang kau kenal, hehe. |
| EPILOGUE_7 | `{name} & Laras\n\n` followed by the old EPILOGUE_6 EN text, unchanged (BUDAYAGO, made by fatih, Codex %d%%) | `{name} & Laras\n\n` followed by the old EPILOGUE_6 ID text, unchanged |

## 12. Quest text (`quests.csv`)
- `Q_<ID>_TITLE`: the chapter title from each [quests.md](quests.md) 4 heading (MQ0 "Malam Wayang" / "The Night of the Wayang", MQ1 "Jejak ke Barat" / "The Trail West", MQG "Topeng Sang Raja" / "The King's Mask", MQ2 "Perang Saudara" / "Brothers at War", MQ3 "Keris dan Pemburu" / "The Keris and the Hunter", MQ5 "Gua Kala" / "Kala's Cave"). `<ID>` is the quest id upper-cased: MQ0, MQ1, MQG, MQ2, MQ3, MQ5.
- `Q_<ID>_S<n>_OBJ`: the Objective EN / ID columns of the step tables, `n` 1-based in table order (0.1 is S1).
- Hints, MQ0 only (input-map keys in braces, as now):

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_S4_HINT | Walk home and press {interact} near Ibu | Pulang lalu tekan {interact} di dekat Ibu |
| Q_MQ0_S5_HINT | Enter the sanggar and talk to Semar | Masuk ke sanggar lalu bicara dengan Semar |
| Q_MQ0_S6_HINT | Hold {cast}, trace Ka over the guide, then release | Tahan {cast}, gambar Ka mengikuti bayangan, lalu lepas |
| Q_MQ0_S7_HINT | {attack} attacks · {dodge} dodges | {attack} menyerang · {dodge} menghindar |

Old Q_MQ0_S1/S2 hints are dropped (those steps are struck).
- SQ-S5: Q_SQ_S5_TITLE "Echo: Sangkuriang" / "Gema: Sangkuriang"; S1 "Ask the weaver for the boeh rarang" / "Minta boeh rarang pada si penenun"; S2 "Stop Sangkuriang before the night ends" / "Hentikan Sangkuriang sebelum malam berakhir".
- SQ-M5: Q_SQ_M5_TITLE "Echo: A Thousand Temples" / "Gema: Seribu Candi"; S1 "Stop Bandung Bondowoso at the temples" / "Hentikan Bandung Bondowoso di candi".

## 13. Codex (`codex.csv` and `data/codex/<id>.tres`)
Category `enemy` for the first six (they unlock on kill, like the other enemies; `_WEAK` is the weakness line), `legend` for the rest (they unlock through `codex:` actions). `source` is "game" for game inventions, "legend" otherwise.

| Id | Title EN / ID | Body EN | Body ID | Weak EN / ID |
|----|---------------|---------|---------|--------------|
| faceless | The Faceless / Wong Tanpa Rupa | People whose names were eaten. Blank masks, hollow hands. When one falls, a name floats free for a moment. A game invention. | Orang-orang yang namanya telah dimakan. Topeng kosong, tangan hampa. Saat satu tumbang, sebuah nama melayang sesaat. Rekaan gim. | No letter trick: the combo and the dodge. / Tak ada aksara khusus: kombo dan menghindar. |
| faceless_archer | Faceless Archer / Pemanah Tanpa Rupa | A Faceless with a bow that keeps its distance. A game invention. | Tanpa Rupa berbusur yang menjaga jarak. Rekaan gim. | Close the gap. / Dekati dia. |
| faceless_captain | Faceless Captain / Kapten Tanpa Rupa | He leads the hunt in the west with a long spear and a loud voice, though he has no mouth. A game invention. | Ia memimpin perburuan di barat dengan tombak panjang dan suara lantang, padahal ia tak bermulut. Rekaan gim. | Ca Burst during his muster breaks the call and stuns him. / Ca saat ia memanggil pasukan memutus seruannya dan membuatnya pusing. |
| barma_wijaya | Prabu Barma Wijaya / Prabu Barma Wijaya | In the legend, the minister Aria Kebonan was made young and given Galuh's throne on one condition, which he broke. Ciung Wanara caged him. His pact with Kala is the game's. | Dalam legenda, patih Aria Kebonan dibuat muda dan diberi takhta Galuh dengan satu syarat, yang ia langgar. Ciung Wanara mengurungnya. Perjanjiannya dengan Kala adalah rekaan gim. | Any letter breaks a mirror copy. With the copies gone, the real one is open. / Aksara apa pun memecah bayangan cermin. Setelah semuanya pecah, yang asli terbuka. |
| hariang_banga | Hariang Banga / Hariang Banga | Son of Dewi Pangrenyep. In the legend he fought Ciung Wanara to free his mother. Neither won, and the land was split at the river. | Putra Dewi Pangrenyep. Dalam legenda ia melawan Ciung Wanara demi membebaskan ibunya. Tak ada yang menang, dan tanah dibagi di sungai. | Jawa Na dashes through his guard. / Na Jawa menerjang menembus tangkisannya. |
| nameless_hunter | The Nameless Hunter / Si Tanpa Ngaran | Aria Kebonan's true name, given to Kala in a pact and hollowed out. It hunted the one who could write it back. A game invention. | Nama sejati Aria Kebonan, diserahkan pada Kala lewat perjanjian dan dikosongkan. Ia memburu orang yang bisa menuliskannya kembali. Rekaan gim. | His "forget" seals your last letter for a few seconds. Switch letters often. / "Lupa"-nya mengunci aksara terakhirmu beberapa detik. Sering-seringlah berganti aksara. |
| nagawiru | Nagawiru / Nagawiru | The old king Prabu Permana Di Kusumah left his throne to become a hermit. In the legend he was killed in disguise, became the naga Nagawiru, and hatched Ciung Wanara's egg. | Raja tua Prabu Permana Di Kusumah meninggalkan takhta untuk bertapa. Dalam legenda ia dibunuh saat menyamar, menjadi naga Nagawiru, dan menetaskan telur Ciung Wanara. | — |
| naganingrum | Dewi Naganingrum / Dewi Naganingrum | The true king's queen and Ciung Wanara's mother. In the legend her newborn was swapped for a puppy and set adrift, and Lengser hid her away. | Permaisuri raja sejati dan ibu Ciung Wanara. Dalam legenda bayinya ditukar dengan anak anjing lalu dihanyutkan, dan Lengser menyembunyikannya. | — |
| ciung_wanara | Ciung Wanara / Ciung Wanara | Set adrift on the Citanduy as a baby and raised by Aki and Nini Balangantrang of Geger Sunten. His name joins two creatures he saw, the ciung bird and the wanara monkey (**VERIFY**). | Dihanyutkan di Citanduy saat bayi dan dibesarkan Aki dan Nini Balangantrang dari Geger Sunten. Namanya gabungan dua makhluk yang ia lihat, burung ciung dan kera wanara (**VERIFY**). | — |
| lengser | Uwa Batara Lengser / Uwa Batara Lengser | The loyal court officer who spared the queen. Lengser is also a figure in Sundanese welcome ceremonies (**VERIFY**). | Abdi istana setia yang menyelamatkan sang permaisuri. Lengser juga tokoh dalam upacara penyambutan Sunda (**VERIFY**). | — |
| pamali | Pamali / Pamali | Pamali: what must not be done. In the legend the brothers' fight was pamali, and the river where the land was split took the name (**VERIFY**: Ci Pamali / Kali Pemali). | Pamali: pantangan, yang tak boleh dilakukan. Dalam legenda perkelahian dua saudara itu pamali, dan sungai tempat tanah dibagi memakai nama itu (**VERIFY**: Ci Pamali / Kali Pemali). | — |

Keep the Faceless codex unlock on the `hunter_raid` beat even though kills would unlock it too: the player should read it before the first fight in Tatar Sunda.

## 14. Lines dropped with the old story
The old main-path entries of semar (mq0-mq3 "return" talks), dayang_sumbi (Ca), sunda_elder, batu_tulis, mataram_dalang, pak_karto, lesung_women, juru_kunci, timur_empu, ki_wangsa and the Aji Saka prologue. Their keys leave the CSVs only when a grep of `data/`, `ui/`, `entities/`, `zones/`, `autoload/` and `tests/` finds no other reference.
