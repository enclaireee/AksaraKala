# Script: Story v5 main path and side stories (ID and EN)

Every main-path line, keyed, Indonesian first. Canon: [story.md](story.md). Steps, beats and flags: [quests.md](quests.md) 4. Rewritten 2026-11-06 (Claude) for Story v4, v4b and v4c, then for Story v5 (138 main steps, 6 Major Choices, LC1-LC6 cross-time chapters, topic hubs); all **ASSUMED** until the user's playtest; culture facts keep their **VERIFY** tags.

**Line budget (ASSUMED, TUNE).** v4 had 870 lines for sections 3-11. Story v5 lifts the talk caps (story.md "Dialogue & Storytelling Rules") and nearly doubles the main path, so there is no fixed total any more: each section states its own count, and lines stay short. The pacing check is `python3 .docs/pacing_model.py`, not a line count.

## 1. Rules
- **Talks (v5):** main-path and camp talks run 8-12 lines, story beats 8-10, hero lines (`@NPC_HERO_NAME`) included; choice labels don't count. Side and idle talks stay short (2-6). Every talk ends on a lead (what to do or where to go next). Depth goes into optional **"Ask about..." topic hubs** (section 2), never into the critical path.
- **Lines:** one idea per line, about 100 EN characters (**TUNE** against the dialogue box, 3 lines). At most one "!" per talk. No parenthesised stage directions: narration uses the bare `@` speaker. No em dashes.
- **Villains don't explain the plot;** a beat shows it. The hero speaks plainly and doesn't shout names.
- **Show, don't explain.** A character wants something, says it in a concrete detail, and moves on. Lore goes to the codex (section 13: 1-3 sentences, labelled "legend" or "game").
- **Know before you meet (v4, Pacing 10).** In reading order (the order of this file), a name's first use comes at or after the moment the player saw that person, place or thing, or it is explained in the same line ("Sandekala, the dusk spirit"). A name tag counts as seeing. Exceptions are listed in the check note at the end of section 3.
- **Cast cuts (v4).** The cut names listed in section 3 never appear in a main-path line; helpers use their display names. Codex bodies may name the legend figures.
- **Tone:** grounded, specific, a little wry (The Witcher 3). Warm humour comes from Semar and the punakawan; the world is never mocked ([concept.md](concept.md) Tone).
- **Regional arcs:** each act's regional character gets an intro line that shows their want, a turn, and a closing line in the aftermath (Ibu; Naganingrum; Lengser, Nyai Sekar and Ranga the Deserter; Ki Sumarto and Nyai Gendhis; Wirasana, Ratna and Mbok Srini; Mbah Wiryo and Sari).
- **Six Major Choices (v5, quests.md 4):** one per act, flags `choice_tell_ciung`/`choice_keep_secret` (Act I), `choice_freed`/`choice_handed` (Act II), `choice_mercy`/`choice_judgment` (Act III; v4's `choice_silent` is retired), `choice_reforge`/`choice_sink` (Act IV), `choice_offer_memory`/`choice_offer_song` (Act V), `choice_redeem_aria`/`choice_release_aria` (Act VI). Both branches get their own lines where the choice is made and where it pays off.
- **Laras chapters (v5):** LC1-LC6 set `flag:laras_key_<id>` and `flag:laras_sabotage_<id>` (quests.md 7.1); the act's boss or gate lines then name the flaw she left, so the player connects the two.
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
- **Topic hubs (v5, quests.md 7.1 item 2):** an entry with `"hub": true, "quiet": true` shows its lines, then its `choices`. A choice whose `do` is `topic:<key>` plays the first entry in the same file with `"topic": "<key>"` (always `"quiet": true`), then shows the hub's choices again. The leave choice (`CHOICE_<NPC>_ASK_LEAVE`, no `topic:`) closes it. Keys: hub choices `CHOICE_<NPC>_ASK_<n>`, topic lines in the NPC's normal `DLG_` numbering. Topic entries are skipped by the normal first-match entry search. (Engine support is Phase 4f step 3; ASSUMED.)
- **Key bands (v5):** new keys for NPCs that speak in several acts were numbered per act so the writers never collided: 100-199 Prologue and Act I, 200-299 Acts II-III, 300-399 Act IV to Act V, 400-499 Act VI and the epilogue, 500-599 side stories. Gaps in the numbering are fine.
- Lakon and codex grants use `lakon:<id>` and `codex:<id>` in a `do`; `clue:<id>` sets a clue (quests.md 7.1).
- **Area triggers marked ASSUMED** (`purwa_tag_cat` and the like) set the flag named in the beat's `if`; the zone docs place them.

## 3. Names (`dialogue.csv`, next to the existing `NPC_*_NAME` rows)
**Lines in this section: 128** (v5, no fixed budget).
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
| NPC_SUNDA_MOTHER_NAME (text changes) | Ceu Imas | Ceu Imas |
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
| NPC_LESUNG_WOMEN_NAME (text changes) | Nyai Gendhis | Nyai Gendhis |
| NPC_JURU_KUNCI_NAME (text changes) | Juru kunci | The juru kunci |
| NPC_PAMALI_STONE_NAME | Batu Pamali | Pamali stone |
| NPC_TIMUR_DAUGHTER_NAME (text changes) | Ratna | Ratna |
| NPC_TIMUR_EMPU_NAME | Mpu Wirasana | Mpu Wirasana |
| NPC_MBOK_SRINI_NAME (text changes) | Mbok Srini | Mbok Srini |
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
| NPC_SUNDA_MOTHER_WHO (text changes) | Ceu Imas. Putranya hilang. | Ceu Imas. Her son is missing. |
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
| NPC_LESUNG_WOMEN_WHO (text changes) | Nyai Gendhis. Pemimpin penumbuk padi. | Nyai Gendhis. Leader of the pounders. |
| NPC_JURU_KUNCI_WHO | Juru kunci. Penjaga bukit keramat. | The juru kunci. Keeper of a holy hill. |
| NPC_TIMUR_DAUGHTER_WHO (text changes) | Ratna. Murid sang empu. | Ratna. The empu's apprentice. |
| NPC_TIMUR_EMPU_WHO | Mpu Wirasana. Pembuat keris. | Mpu Wirasana. A keris smith. |
| NPC_MBOK_SRINI_WHO (text changes) | Mbok Srini. Pondoknya hancur. | Mbok Srini. Her hut was smashed. |
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
| NPC_TEA_PICKER_NAME (new) | Pemetik teh | A tea picker |
| NPC_TEA_PICKER_WHO (new) | Pemetik teh. Bernyanyi untuk daun. | A tea picker. Sings for the leaves. |
| NPC_PASAR_INFORMANT_NAME (new) | Pemberi kabar pasar | The market informant |
| NPC_NYAI_SEKAR_NAME (new) | Nyai Sekar | Nyai Sekar |
| NPC_DAYANG_RATU_NAME (new) | Dayang ratu | The queen's attendant |
| NPC_RANGA_NAME (new) | Ranga | Ranga |
| NPC_SAWAH_FARMER_NAME (new) | Petani sawah | A rice farmer |
| NPC_PASAR_REFUGEE_NAME (new) | Seorang bapak pengungsi | A displaced father |
| NPC_HAULER_NAME (new) | Pengangkut batu | A stone-hauler |
| NPC_BANDUNG_BONDOWOSO_NAME (new) | Bandung Bondowoso | Bandung Bondowoso |
| NPC_PASAR_INFORMANT_WHO | Pemberi kabar. Tahu isi tiap gudang. | The informant. Knows every storehouse. |
| NPC_NYAI_SEKAR_WHO | Nyai Sekar. Juru arsip istana. | Nyai Sekar. The palace archivist. |
| NPC_DAYANG_RATU_WHO | Dayang. Melayani Sang Ratu. | An attendant. Serves the queen. |
| NPC_RANGA_WHO | Ranga. Pembelot Tanpa Rupa. | Ranga. A faceless deserter. |
| NPC_SAWAH_FARMER_WHO | Petani. Sawahnya ikut tergenang. | A farmer. Her paddy is flooded. |
| NPC_PASAR_REFUGEE_WHO | Warga pasar. Lapaknya hilang. | A market father. His stall is gone. |
| NPC_HAULER_WHO | Pengangkut batu. Baru terbangun. | A stone-hauler. Just waking up. |
| NPC_BANDUNG_BONDOWOSO_WHO | Bandung Bondowoso. Pembangun candi. | Bandung Bondowoso. The temple-builder. |
| NPC_KIDUL_SARI_NAME (text changes; was "Nenek Sari") | Sari | Sari |
| NPC_CLIFF_ALTAR_NAME (text changes) | Altar Tebing | Cliff Altar |
| NPC_KIDUL_SARI_WHO (new) | Sari. Penyelam muda. | Sari. A young diver. |
| NPC_MEMORIAL_STONE_NAME (new) | Batu Leluhur | The Ancestors' Stone |
| NPC_MEMORIAL_STONE_WHO | Batu Leluhur. Menyimpan nama-nama. | The Ancestors' Stone. Keeps the names. |
| NPC_RIRIWA_ROLL_NAME (new) | Daftar pelayan | The servants' roll |
| NPC_NYAI_RUKMI_WHO (new) | Nyai Rukmi. Penjaga catatan. | Nyai Rukmi. Keeps the records. |

Name check: `python3 .docs/know_check.py` (Pacing 10) runs over sections 4-11 and 15. Name check exceptions: (none)

## 4. Prologue cards (`PROLOGUE_1`-`_2`, `ui/prologue.tscn`: lines 2, `semar_from = 0`, `semar_to = 0`)
**Lines in this section: 2** (ASSUMED budget: at most 10).
Two cards before the class choice and the first step. They show a normal day: no shadows, no raid. `PROLOGUE_3`-`_5` are retired (section 14); their moments are the `raid` beat and its morning card (section 5). Unchanged from v4.

| Key | ID | EN |
|-----|----|----|
| PROLOGUE_1 | Desa Purwa, fajar. Sebuah desa kecil di tepi kerajaan-kerajaan tua, tempat semua orang tahu nama semua orang. | Desa Purwa, dawn. A small village at the edge of the old kingdoms, where everyone knows everyone's name. |
| PROLOGUE_2 | Malam ini wayang ruwatan: sang dalang membacakan nama anak-anak desa agar mereka terlindung. Sampai malam, hari ini biasa saja. Adikmu, Laras, sudah mengetuk pintu. | Tonight is the wayang ruwatan: the dalang reads the children's names aloud to ward them. Until then, an ordinary day. Your little sister Laras is already knocking. |

The dalang reading the children's names aloud at a ruwatan (PROLOGUE_2) is **VERIFY** (story.md Spine). "Dalang" is explained by Semar's name tag in the first talk and by this card ("the dalang reads").

## 5. Prologue: A Day in Desa Purwa (MQ0)
**Lines in this section: 222** (v5 budget, ASSUMED: at most 330).
Regional character: Ibu (want: two cups she cannot explain; turn: the Interlude; close: the epilogue). The day is calm: tag, tea, a walk with talks, the sanggar, the Kelir show. Step indices are v5's: `step:mq0=0` is step 0.1, `step:mq0=11` is 0.12. Everything the game needs later is shown first and named second. The details here are what the Act VI gap memories test, so they must not change: the stray cat is **Kunyit**; the banyan is **Ki Waringin**; the tag ends at **the well**; Laras takes **the chipped cup** (jasmine tea); Ibu says "home before **the show**"; Laras writes with **Semar's bamboo pen**, **your name first**; Semar says a written name **keeps a person in the world**.

**Hub entries (new in v5, quests.md 7.1 item 2).** An entry marked `"hub": true, "quiet": true` shows its lines, then its `choices`. A choice whose `do` is `topic:<key>` plays the entry that has `"topic": "<key>"` (also `"quiet": true`, 3-6 lines, listed in the same table with the Entry label `T:<key>`), then the choice list opens again. The last choice has no `do` and closes the talk. A hub entry takes the place of the NPC's short repeat entry: it plays whenever no step entry above it applies, so it never blocks a main-path talk.

### Chapter 1: Morning and Market (0.1-0.4)

### laras (Desa Purwa, name NPC_LARAS_NAME; `laras_tag` runs the route; entries 3 and 4 are kept for the epilogue `laras` spot)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=0`, `!flag:tag_started` (0.1) | `flag:tag_started` |
| 2 | `step:mq0=0` | |
| 3 | `step:mq0=1` (kept) | |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_LARAS_V1 | Kak! Bangun! Ruwatan malam ini, dan aku mau pamer larinya jago. Tangkap aku kalau bisa! | Kak! Wake up! The ruwatan is tonight, and I want to show off how fast I run. Catch me if you can! |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LARAS_H1 | Laras, ini masih subuh. | Laras, it's barely dawn. |
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_LARAS_V2 | Takut kalah, ya? Satu, dua... sampai sumur, Kak! Yang kalah cuci piring! | Scared to lose? One, two... to the well, Kak! Loser washes the dishes! |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LARAS_H101 | Kau curang. Kau sudah lari sebelum selesai menghitung. | You cheat. You started running before you finished counting. |
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_LARAS_V101 | Itu namanya siasat. Hemat waktu. | That's called strategy. It saves time. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LARAS_H102 | Pakai sepatu dulu. Jalan ke sumur penuh batu. | Put your shoes on. The road to the well is full of stones. |
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_LARAS_V102 | Tak perlu. Tanah desa ini kenal kakiku. | No need. The ground in this village knows my feet. |
| 1 | DLG_LARAS_V103 | Kalau ada yang menghadang, menghindar saja. Berguling, jangan menabrak, Kak. | If something's in the way, dodge it. Roll, don't crash, Kak. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LARAS_H103 | Dari mana kau tahu semua jalan pintas? | How do you know every shortcut? |
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_LARAS_V104 | Kucing-kucing yang cerita. Mulai dari alun-alun, lewat beringin tua, lalu sumur. Kejar aku. | The cats told me. Start at the plaza, past the old banyan, then the well. Chase me. |
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
| BEAT_TAG_CAT_4 | Dia sendiri yang bilang. Semua punya nama sendiri, Kak. | It told me. Everything has a name of its own, Kak. |
| @NPC_HERO_NAME | | |
| BEAT_TAG_CAT_H2 | Kucing tidak bicara, Laras. | Cats don't talk, Laras. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_CAT_5 | Bicara kok. Kau saja yang jarang mendengarkan. | They do. You just don't listen much. |
| @ | | |
| BEAT_TAG_CAT_6 | Kunyit mengibaskan ekornya dan berlari ke arah beringin, seolah menunjukkan jalan. | Kunyit flicks his tail and trots toward the banyan, as if showing the way. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_CAT_7 | Ayo, sumur! Dan jangan lupa menyapa beringin tua di jalan. | Come on, the well! And don't forget to greet the old banyan on the way. |

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
| @NPC_HERO_NAME | | |
| BEAT_TAG_BANYAN_H1 | Ki Waringin? Sejak kapan pohon punya nama? | Ki Waringin? Since when does a tree have a name? |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_BANYAN_5 | Sejak ada yang pertama kali menyapanya. Nama itu hadiah, Kak. Kalau dipanggil, kau ada. | Since someone first greeted him. A name is a gift, Kak. If you're called, you exist. |
| @NPC_HERO_NAME | | |
| BEAT_TAG_BANYAN_H2 | Dan kalau tak ada yang memanggil? | And if nobody calls? |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_BANYAN_6 | Maka dia sendirian. Makanya aku lewat sini tiap hari. | Then he's alone. That's why I come by every day. |
| @ | | |
| BEAT_TAG_BANYAN_7 | Untuk sesaat, kau merasa daun-daun itu ikut mendengarkan. | For a moment you feel the leaves listening too. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_BANYAN_8 | Sudah, sumur menunggu. Yang kalah cuci piring, ingat? | Enough, the well is waiting. Loser washes the dishes, remember? |

### Beat `tag_end` (if `!flag:beat_tag_end`, `flag:mq0_d1`; do `flag:beat_tag_end`). Area `purwa_tag_end` sets `mq0_d1`; the `laras_tag` spot then leaves, so the catch is a beat. New in v5 (0.1)
The old well stands a few steps from the banyan; the catch happens there, because the gap memory `la` asks "where did you catch Laras" and the answer is the well.
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_TAG_END_1 | Laras berhenti di tepi sumur, terengah dan tertawa. Tanganmu menyentuh bahunya setengah langkah sebelum ia sampai ke ember. | Laras stops at the well, panting and laughing. Your hand taps her shoulder half a step before she reaches the bucket. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_END_2 | Kena aku! Kau lebih cepat dari yang kukira, Kak. | You got me! You're faster than I thought, Kak. |
| @NPC_HERO_NAME | | |
| BEAT_TAG_END_H1 | Kau melambat sengaja. | You slowed down on purpose. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_END_3 | Sedikit. Yang kalah cuci piring, dan aku tak suka piring. | A little. The loser washes dishes, and I don't like dishes. |
| @ | | |
| BEAT_TAG_END_4 | Dari rumah di ujung lorong, aroma melati menyebar. Seseorang sedang menyeduh teh. | From the house at the end of the lane, the smell of jasmine drifts over. Someone is brewing tea. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_END_5 | Teh melati Ibu. Cepat, sebelum dingin dan sebelum Ibu mulai memberi kita tugas. | Ibu's jasmine tea. Quick, before it goes cold and before Ibu starts handing out chores. |
| @NPC_HERO_NAME | | |
| BEAT_TAG_END_H2 | Terlambat. Ibu selalu sudah punya tugas. | Too late. Ibu always has a chore ready. |
| @NPC_LARAS_NAME | | |
| BEAT_TAG_END_6 | Ayo ke rumah dulu. Ibu pasti sudah menunggu di meja. | Home first. Ibu will be waiting at the table. |

### ibu (name NPC_IBU_NAME). Entry order for the whole game (the Interlude and epilogue lines are in sections 10 and 11). Entries 2, 3 and 5 to 7 keep their numbers; `H` is the prologue-day hub
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `step:mq0=1`, `!flag:mq0_d2` (0.2, tea) | | |
| H | `flag:mq0_d2`, `!flag:mq0_d8`, `"hub": true`, `"quiet": true` | | CHOICE_IBU_ASK_101 to `topic:ask_ruwatan`; CHOICE_IBU_ASK_102 to `topic:ask_cups`; CHOICE_IBU_ASK_103 (leave) |
| T:ask_ruwatan | `"topic": "ask_ruwatan"`, `"quiet": true` | | |
| T:ask_cups | `"topic": "ask_cups"`, `"quiet": true` | | |
| 2 | `step:mq4=2`, `item:laras_ribbon,item:laras_board,item:laras_strip_ka` (4.3, section 10) | | |
| 3 | `step:mq4=2` (4.3, no items yet, `"quiet": true`, section 10) | | |
| 4 | `step:mq0=9` (0.10, the morning after) | | |
| 5 | `flag:mq5_4` (epilogue, section 11) | | |
| 6 | `quest:mq0=active` | | |
| 7 | (none) | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_IBU_NAME | | |
| 1 | DLG_IBU_V20 | Duduk, minum dulu. Teh melati, dua cangkir: satu untuk Laras, satu untukmu. | Sit, drink. Jasmine tea, two cups: one for Laras, one for you. |
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_IBU_L1 | Aku yang gompal! Kalau tak ada yang pakai, dia sedih. | I get the chipped one! If nobody uses it, it gets sad. |
| 1 | @NPC_IBU_NAME | | |
| 1 | DLG_IBU_V101 | Cangkir itu sudah retak sejak kau kecil. Ibu bilang buang saja, kau bilang nanti dia sedih. | That cup's been chipped since you were small. I said throw it out, you said it would be sad. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_IBU_H101 | Dia betul-betul sayang cangkir gompal itu. | She truly loves that chipped cup. |
| 1 | @NPC_LARAS_NAME | | |
| 1 | DLG_IBU_L101 | Teh lebih enak kalau cangkirnya senang. | Tea tastes better when the cup is happy. |
| 1 | @NPC_IBU_NAME | | |
| 1 | DLG_IBU_V102 | Kalian berdua. Nanti malam ruwatan, jadi pakai baju rapi dan jangan lari-lari. | You two. The ruwatan is tonight, so wear something neat and don't run about. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_IBU_H102 | Laras tak akan sanggup tidak lari-lari. | Laras can't not run about. |
| 1 | @NPC_IBU_NAME | | |
| 1 | DLG_IBU_V21 | Pulang sebelum pertunjukan, berdua. Dan tolong jemput Ciung, anak tetangga kita. Sejak subuh dia di pohon. | Home before the show, both of you. And fetch Ciung, our neighbours' boy. He's been up a tree since dawn. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_IBU_H20 | Ciung dan pohonnya. Beres, Bu. | Ciung and his tree. Leave it to me, Ibu. |
| 1 | @NPC_IBU_NAME | | |
| 1 | DLG_IBU_V103 | Kakek-neneknya di rumah sebelah. Mampirlah dulu, mereka sudah menunggumu sejak tadi. | His grandparents are next door. Stop by first, they've been waiting for you. |
| H | @NPC_IBU_NAME | | |
| H | DLG_IBU_V104 | Masih di sini? Ibu punya waktu sebentar kalau kau mau bertanya. | Still here? I've a moment if you want to ask me something. |
| T:ask_ruwatan | @NPC_IBU_NAME | | |
| T:ask_ruwatan | DLG_IBU_V105 | Kau tiga tahun waktu itu, dan menangis sepanjang pertunjukan karena takut raksasa wayang. | You were three, and you cried through the whole show because you feared the wayang giant. |
| T:ask_ruwatan | DLG_IBU_V106 | Lalu dalang tua itu membacakan namamu, dan kau berhenti seketika. Seperti namamu sendiri yang menenangkanmu. | Then the old dalang read your name, and you stopped at once. As if your own name calmed you. |
| T:ask_ruwatan | @NPC_HERO_NAME | | |
| T:ask_ruwatan | DLG_IBU_H103 | Aku tak ingat. | I don't remember. |
| T:ask_ruwatan | @NPC_IBU_NAME | | |
| T:ask_ruwatan | DLG_IBU_V107 | Ibu ingat. Terasa seperti pintu ditutup pelan dari dalam, hangat. Nanti malam giliran Laras dan Ciung. | I do. It felt like a door closed gently from inside, warm. Tonight it's Laras's and Ciung's turn. |
| T:ask_cups | @NPC_IBU_NAME | | |
| T:ask_cups | DLG_IBU_V108 | Dari dulu begitu. Satu untuk Laras yang tak bisa duduk diam, satu untukmu yang tak mau bangun. | It's always been so. One for Laras, who can't sit still, one for you, who won't get up. |
| T:ask_cups | @NPC_HERO_NAME | | |
| T:ask_cups | DLG_IBU_H104 | Ibu tak pernah menyeduh khusus untuk diri sendiri? | You never brew one just for yourself? |
| T:ask_cups | @NPC_IBU_NAME | | |
| T:ask_cups | DLG_IBU_V109 | Ibu minum sambil menunggu kalian. Tehnya selalu dingin sebelum habis. | I drink while I wait for you two. The tea's always cold before it's finished. |
| T:ask_cups | DLG_IBU_V110 | Kalau suatu hari rumah ini sepi, Ibu tetap akan menyeduh dua. Cangkir juga perlu merasa ditunggu. | If this house ever goes quiet, I'll still brew two. Cups need to feel waited for, too. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_IBU_H1 | Bu, Laras di mana? Semalam dia tidak pulang. | Ibu, where's Laras? She never came home last night. |
| 4 | @NPC_IBU_NAME | | |
| 4 | DLG_IBU_V2 | Laras? Siapa Laras, Nak? Dari dulu cuma kita berdua. | Laras? Who's Laras, child? It's always been the two of us. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_IBU_H111 | Gadis kecil, kepang miring, suka mengajak kucing bicara. Ibu tak ingat? | A little girl, crooked braid, talks to cats. You don't remember? |
| 4 | @NPC_IBU_NAME | | |
| 4 | DLG_IBU_V111 | Nak, kau demam? Ibu tak punya anak lain. | Child, do you have a fever? I have no other child. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_IBU_H2 | Lalu kenapa ada dua cangkir di meja? | Then why are there two cups on the table? |
| 4 | @NPC_IBU_NAME | | |
| 4 | DLG_IBU_V4 | Dua... Satunya gompal, entah kenapa Ibu simpan. Sudahlah. Semar, sang dalang, semalaman di sanggar, tanyalah dia. | Two... One is chipped, and I couldn't say why I kept it. Never mind. Semar, the dalang, was up all night at the sanggar. Ask him. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_IBU_H112 | Bu, matamu basah. | Ibu, your eyes are wet. |
| 4 | @NPC_IBU_NAME | | |
| 4 | DLG_IBU_V112 | Aku? Debu, mungkin. Dari panggung semalam. | Me? Dust, maybe. From the stage last night. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_IBU_H113 | Aku akan membawanya pulang, Bu. Aku janji. | I'll bring her home, Ibu. I promise. |
| 4 | @NPC_IBU_NAME | | |
| 4 | DLG_IBU_V113 | Membawa siapa pulang? Sudahlah. Panggung wayang masih berasap, siapa tahu ada yang tertinggal di sana. | Bring who home? Never mind. The wayang stage is still smoking, something may be left there. |
| 6 | DLG_IBU_V7 | Hati-hati. Sejak semalam seisi desa gelisah. | Be careful. The whole village is jumpy since last night. |
| 7 | DLG_IBU_V8 | Pulanglah kalau sempat. Nasimu Ibu hangatkan. | Come home when you can. I'll keep your rice warm. |

Choices for the Ibu hub:
| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_IBU_ASK_101 | Ceritakan ruwatanku dulu. | Tell me about my own ruwatan. | `topic:ask_ruwatan` |
| CHOICE_IBU_ASK_102 | Kenapa selalu dua cangkir? | Why are there always two cups? | `topic:ask_cups` |
| CHOICE_IBU_ASK_103 | Tidak apa-apa, Bu. | Never mind, Ibu. | |

Entries 2, 3 and 5 are written in sections 10 and 11. **VERIFY**: that a ruwatan reads a child's name aloud (story.md Spine).

### purwa_old_couple (the neighbours' lane; name NPC_PURWA_OLD_COUPLE_NAME; new). The couple who raised Ciung. Ibu's line "our neighbours' boy" came first.
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=1`, `flag:mq0_d2`, `!flag:mq0_d2b` (0.2, after the tea) | |
| 1b | `step:mq0=1`, `!flag:mq0_d2` (`"quiet": true`; the player came here first) | |
| 2 | `quest:mq0=active` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_PURWA_OLD_COUPLE_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_V1 | Nak, tolong. Cucu kami, Ciung, memanjat pohon sejak subuh dan tak mau turun. | Child, please. Our boy Ciung has been up that tree since dawn and won't come down. |
| 1 | DLG_PURWA_OLD_COUPLE_V2 | Ia memeluk sebutir telur aneh. Katanya bukan miliknya, hanya titipan. | He's hugging a strange egg. He says it isn't his, only left in his keeping. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_H101 | Dari mana telur itu? | Where did the egg come from? |
| 1 | @NPC_PURWA_OLD_COUPLE_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_V5 | Kami tak tahu. Ia pulang dari ladang membawanya, hangat seperti baru ditinggalkan. | We don't know. He came home from the fields with it, warm as if just left. |
| 1 | DLG_PURWA_OLD_COUPLE_V6 | Kami sudah tua dan lutut kami tak sanggup memanjat. Kau lebih muda. | We're old and our knees won't climb. You're younger. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_H102 | Apa yang ditakutkan Ciung? | What is Ciung afraid of? |
| 1 | @NPC_PURWA_OLD_COUPLE_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_V7 | Ditinggal. Anak yang ditemukan di sungai selalu takut ditinggal. | Being left. A child found in a river is always afraid of being left. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_H1 | Akan kubawa dia turun. | I'll bring him down. |
| 1 | @NPC_PURWA_OLD_COUPLE_NAME | | |
| 1 | DLG_PURWA_OLD_COUPLE_V3 | Terima kasih. Pohonnya di ujung barat, lewat kolam. | Bless you. The tree is at the far west end, past the pond. |
| 1b | DLG_PURWA_OLD_COUPLE_V8 | Sudah minum teh di rumah ibumu? Mampirlah lagi nanti. | Have you had tea at your mother's yet? Come back after. |
| 2 | DLG_PURWA_OLD_COUPLE_V4 | Ciung anak baik. Hanya keras kepala. | Ciung is a good boy. Only stubborn. |

### ciung_wanara, prologue entries (put first in the file; the Act I camp entries follow, then the Act II to VI entries unchanged, section 7)
| Entry | if | do |
|-------|----|----|
| P1 | `step:mq0=2` (0.3, after the climb) | |
| P2 | `quest:mq0=active`, `flag:mq0_d3` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| P1 | @NPC_HERO_NAME | | |
| P1 | DLG_CIUNG_WANARA_H10 | Ciung! Turunlah. Kakek-nenekmu cemas. | Ciung! Come down. Your grandparents are worried. |
| P1 | @NPC_CIUNG_WANARA_NAME | | |
| P1 | DLG_CIUNG_WANARA_V20 | Tidak mau. Telur ini hangat kalau kupeluk, dingin kalau kutaruh. | No. This egg stays warm if I hold it and goes cold if I put it down. |
| P1 | @NPC_HERO_NAME | | |
| P1 | DLG_CIUNG_WANARA_H101 | Telur apa itu? Burung? | What kind of egg is it? A bird's? |
| P1 | @NPC_CIUNG_WANARA_NAME | | |
| P1 | DLG_CIUNG_WANARA_V101 | Entah. Tapi ada yang berdetak di dalamnya, pelan, seperti menunggu aku bicara. | No idea. But something ticks inside, slow, like it's waiting for me to speak. |
| P1 | @NPC_LARAS_NAME | | |
| P1 | DLG_CIUNG_WANARA_L1 | Ciung itu bukan seluruh namamu, tahu. Kau cuma belum kenal sisanya. | Ciung isn't your whole name, you know. You just haven't met the rest. |
| P1 | @NPC_CIUNG_WANARA_NAME | | |
| P1 | DLG_CIUNG_WANARA_V102 | Aku tak butuh nama lain. Satu saja sudah cukup merepotkan. | I don't need another name. One is trouble enough. |
| P1 | @NPC_HERO_NAME | | |
| P1 | DLG_CIUNG_WANARA_H102 | Kakek-nenekmu takut kau jatuh. | Your grandparents are afraid you'll fall. |
| P1 | @NPC_CIUNG_WANARA_NAME | | |
| P1 | DLG_CIUNG_WANARA_V103 | Mereka selalu takut. Aku tak akan jatuh. | They're always afraid. I won't fall. |
| P1 | DLG_CIUNG_WANARA_V21 | Iya, iya, aku turun sekarang! Telur ini kubawa pulang ya. Terima kasih sudah mengingatkan. | Alright, alright, I'm coming down! I'm bringing this egg home. Thanks for reminding me. |
| P1 | @NPC_LARAS_NAME | | |
| P1 | DLG_CIUNG_WANARA_L101 | Ayo langsung ke sanggar, Kak! Ki Semar sudah menunggu kita untuk persiapan Ruwatan. | Let's head straight to the sanggar, Kak! Ki Semar is waiting for us to get ready for the Ruwatan. |
| P2 | DLG_CIUNG_WANARA_V22 | Aku pulang ke rumah dulu ya. Sampai ketemu nanti malam di panggung wayang! | I'm heading home first. See you tonight at the wayang stage! |

### Chapter 1, step 0.4: Sanggar entrance (Cepot's warning)
### cepot (the sanggar entrance, step 0.4; name NPC_CEPOT_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq0=3` (0.4) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_CEPOT_NAME | | |
| 1 | DLG_CEPOT_V01 | Waduh, kalian dari mana saja?! Syukurlah sudah sampai! Barusan peronda desa lapor ada orang asing jangkung bertopeng putih polos berkeliaran di dekat gerbang desa, terus nanya-nanyain nama anak-anak! | There you are! Thank goodness you made it! Village scouts just reported a tall stranger in a blank white mask lurking near the outskirts, asking for children's names! |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_CEPOT_H01 | Orang asing bertopeng? Untuk apa dia menanyai nama anak-anak? | A masked stranger? What does he want with children's names? |
| 1 | @NPC_CEPOT_NAME | | |
| 1 | DLG_CEPOT_V02 | Mana kutahu! Pokoknya seram sekali! Makanya Bapak langsung menyuruh semua anak berkumpul di sanggar sekarang juga. | How should I know! It's creepy as hell! That's why Father ordered all the village kids into the sanggar right now. |
| 1 | DLG_CEPOT_V03 | Ayo cepat masuk ke dalam, Bapak sudah menunggu kalian dari tadi! | Go on inside, quick! Father's been waiting for you both! |

### purwa_stall (the market; ambient in Prologue, main role in Act V 4.2)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq0=active` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_PURWA_STALL_NAME | | |
| 1 | DLG_PURWA_STALL_V4 | Cabai segar, kemiri baru! Mau beli bumbu dapur, Nak? | Fresh chilli, new candlenut! Looking for kitchen spices, child? |

### Chapter 2: The Sanggar and the Ruwatan Night (0.5-0.8)

### semar (sanggar; drop every old main-path entry). Entry order for the whole game. Entries 9 to 13 keep their numbers (sections 10 and 11 refer to entry 9); the prologue entries use the labels below; `H1` and `H2` are hubs
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `step:mq0=4`, `!flag:mq0_d4` (0.5) | | |
| H1 | `step:mq0=4`, `flag:mq0_d4`, `"hub": true`, `"quiet": true` (0.5, before Cepot) | | CHOICE_SEMAR_ASK_101 to `topic:ask_kala`; CHOICE_SEMAR_ASK_102 to `topic:ask_lontar`; CHOICE_SEMAR_ASK_103 (leave) |
| T:ask_kala | `"topic": "ask_kala"`, `"quiet": true` | | |
| T:ask_lontar | `"topic": "ask_lontar"`, `"quiet": true` | | |
| 2 | `step:mq0=5` (0.6, the lontar table) | | |
| 2b | `step:mq0=6` (0.7, the lamps) | | |
| 3 | `step:mq0=7` (0.8, the show; the kelir spot starts K0, ASSUMED) | | |
| 4 | `step:mq0=9` (0.10) | | |
| 5 | `step:mq0=10`, `!glyph:sunda_ka`, `flag:mq0_5` (0.11) | `learn:sunda_ka` | |
| H2 | `step:mq0=10`, `"hub": true`, `"quiet": true` (0.11, practice) | | CHOICE_SEMAR_ASK_104 to `topic:ask_faceless`; CHOICE_SEMAR_ASK_105 to `topic:ask_halflontar`; CHOICE_SEMAR_ASK_106 (leave) |
| T:ask_faceless | `"topic": "ask_faceless"`, `"quiet": true` | | |
| T:ask_halflontar | `"topic": "ask_halflontar"`, `"quiet": true` | | |
| 7 | `step:mq0=11`, `!flag:mq0_7` (0.12) | | |
| 8 | `step:mq0=11`, `flag:mq0_7` (0.12, after the square) | | |
| 9 | `step:mq4=4` (4.5, section 10) | | |
| 10 | `quest:mq4=active` | | |
| 11 | `quest:mq5=active` | | |
| 12 | `flag:mq5_4` | | |
| 13 | (none) | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_V30 | Hehe, murid yang tak pernah tepat waktu. Lihat: aksara, tulisan kuno kita, bukan sekadar huruf. Digambar dengan hati, ia jadi tenaga. | Hehe, the apprentice who's never on time. Look: aksara, our old script, aren't just letters. Drawn with heart, they become power. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SEMAR_H30 | Dan nama? | And names? |
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_V31 | Nama yang ditulis menahan seseorang tetap ada di dunia. Itu sebabnya malam ini nama anak-anak dibacakan. | A written name keeps a person in the world. That's why the children's names are read tonight. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SEMAR_H101 | Laras sudah tahu itu. Dia menyapa kucing dan pohon pakai nama mereka. | Laras knows that already. She greets cats and trees by name. |
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_V101 | Hehe, aku tahu. Anak itu mendengar nama seperti orang lain mendengar lonceng. | Hehe, I know. That girl hears names the way other people hear bells. |
| 1 | DLG_SEMAR_V102 | Itu anugerah, dan anugerah selalu punya harga. Jaga dia nanti malam. | It's a gift, and gifts always have a price. Keep an eye on her tonight. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SEMAR_H102 | Harga apa? | What price? |
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_V103 | Yang bisa mendengar nama, bisa dipanggil lewat namanya. Sudah, jangan pasang muka cemas. | Whoever can hear names can be called by theirs. There, don't look so worried. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SEMAR_H103 | Di pasar ada orang bertopeng polos, menanyai nama anak-anak. | At the market there's a man in a blank mask asking children's names. |
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_V104 | Aku sudah dengar. Karena itu lampu harus menyala dan nama-nama harus dibacakan hari ini. | I've heard. That's why the lamps must be lit and the names read today. |
| 1 | DLG_SEMAR_V32 | Laras, bawa lontarmu ke meja itu dan tulis. Tapi temui dulu anakku, Cepot. Dia berisik sejak tadi. | Laras, bring your lontar to that table and write. But meet my son Cepot first. He's been loud all morning. |
| H1 | @NPC_SEMAR_NAME | | |
| H1 | DLG_SEMAR_V105 | Cepot di sana, yang suaranya paling keras. Atau tanya aku dulu, hehe. | Cepot's over there, the loudest one. Or ask me first, hehe. |
| T:ask_kala | @NPC_SEMAR_NAME | | |
| T:ask_kala | DLG_SEMAR_V106 | Batara Kala itu dewa waktu, Nak. Bukan jahat, hanya lapar, dan yang dimakannya yang tak dijaga. | Batara Kala is the god of time, child. Not wicked, only hungry, and he eats what isn't guarded. |
| T:ask_kala | DLG_SEMAR_V107 | Menurut cerita lama, anak yang lahir di waktu yang salah jadi santapannya. Karena itu ada ruwatan. | In the old tales, a child born at the wrong hour is his meal. That's why there's a ruwatan. |
| T:ask_kala | @NPC_HERO_NAME | | |
| T:ask_kala | DLG_SEMAR_H104 | Dan kita menjaga dengan apa? | And what do we guard with? |
| T:ask_kala | @NPC_SEMAR_NAME | | |
| T:ask_kala | DLG_SEMAR_V108 | Nama, doa, dan cerita yang dibawakan sampai habis. Cerita yang selesai tak bisa dimakan. | Names, prayers, and a story told to its end. A finished story can't be eaten. |
| T:ask_lontar | @NPC_SEMAR_NAME | | |
| T:ask_lontar | DLG_SEMAR_V109 | Lontar itu daun palem, Nak. Murah, ringan, dan sabar menunggu tangan yang gemetar. | Lontar is palm leaf, child. Cheap, light, and patient with a shaking hand. |
| T:ask_lontar | DLG_SEMAR_V110 | Dulu naskah digores dengan pisau kecil, lalu digosok jelaga supaya hurufnya hitam. Kita pakai pena bambu. | Manuscripts were once scratched with a small knife, then rubbed with soot to blacken the letters. We use a bamboo pen. |
| T:ask_lontar | @NPC_HERO_NAME | | |
| T:ask_lontar | DLG_SEMAR_H105 | Tapi daun bisa lapuk. | But leaves rot. |
| T:ask_lontar | @NPC_SEMAR_NAME | | |
| T:ask_lontar | DLG_SEMAR_V111 | Semua yang kita tulis bisa hilang. Itu sebabnya kita menulisnya dengan sungguh-sungguh. | Everything we write can be lost. That's why we write it with care. |
| 2 | DLG_SEMAR_V33 | Lontar di meja dekat jendela. Tulislah. Aku ingin lihat apakah tulisanmu masih secakar ayam. | The lontar's on the table by the window. Write. I want to see if your hand still scratches like a hen. |
| 2b | DLG_SEMAR_V112 | Empat lampu minyak di sekeliling panggung. Nyalakan sebelum senja habis, dan jangan tumpahkan minyaknya. | Four oil lamps around the stage. Light them before dusk is gone, and don't spill the oil. |
| 2b | @NPC_HERO_NAME | | |
| 2b | DLG_SEMAR_H106 | Siapa yang memegang obornya? | Who holds the torch? |
| 2b | @NPC_SEMAR_NAME | | |
| 2b | DLG_SEMAR_V113 | Kau. Cepot boleh membawa botolnya, hehe. Api bukan temannya. | You. Cepot may carry the bottle, hehe. Fire isn't his friend. |
| 3 | DLG_SEMAR_V34 | Waktunya. Duduklah di balik layar, Nak. Kau yang memegang wayang pertama, hehe. | It's time. Sit behind the screen, child. You hold the first puppet, hehe. |
| 3 | DLG_SEMAR_V114 | Tetap di cahaya lampuku. Laras dan Ciung duduk di barisan depan, jadi tak usah cemas. | Stay in my lamp's light. Laras and Ciung sit in the front row, so don't worry. |
| 4 | DLG_SEMAR_V1 | Hehe, mukamu kusut seperti kucing basah. Sebelum aku bicara, ambil dulu lontar yang tertinggal di panggung wayang. Yang gosong itu. | Hehe, you look like a wet cat. Before I say anything, fetch the lontar off the wayang stage. The scorched one. |
| 4 | DLG_SEMAR_V115 | Tapi tengoklah Ibumu dulu. Ia akan menjawab dengan sakit, tapi kau perlu mendengarnya. | But see your mother first. Her answer will hurt, but you need to hear it. |
| 5 | @NPC_HERO_NAME | | |
| 5 | DLG_SEMAR_H2 | Hurufnya memudar dari ujung. Siapa yang melakukan ini? | The letters are fading from the edges. Who did this? |
| 5 | @NPC_SEMAR_NAME | | |
| 5 | DLG_SEMAR_V4 | Para tanpa rupa: orang-orang terlupa yang mengangkut nama bagi yang memegangnya. Ibumu sudah lupa Laras. Aku belum. | The faceless: forgotten folk who carry names to whoever holds them. Your mother has forgotten Laras. I haven't. |
| 5 | @NPC_HERO_NAME | | |
| 5 | DLG_SEMAR_H107 | Kenapa Ibu lupa, dan kau tidak? | Why did Ibu forget, and you didn't? |
| 5 | @NPC_SEMAR_NAME | | |
| 5 | DLG_SEMAR_V116 | Ibumu menyimpan Laras hanya di ingatan. Aku menyimpannya di tulisan. Kau menyimpannya di lontar itu. | Your mother kept Laras only in memory. I kept her in writing. You keep her in that lontar. |
| 5 | DLG_SEMAR_V5 | Laras masih memegang separuh yang bernamamu, dan ia menulis di situ. Lihat? Ka, untuk "kakak". Gambar tiga kali. | Laras still holds the half with your name, and she's writing on it. See? Ka, for "kakak". Draw it three times. |
| 5 | @NPC_HERO_NAME | | |
| 5 | DLG_SEMAR_H108 | Berapa lama sebelum hurufnya habis? | How long before the letters run out? |
| 5 | @NPC_SEMAR_NAME | | |
| 5 | DLG_SEMAR_V117 | Aku tak tahu. Tiap Ka yang ia tulis menahan namanya di dunia. Selama ia menulis, kau tak bisa lupa. | I don't know. Each Ka she writes holds her name in the world. While she writes, you can't forget. |
| 5 | @NPC_HERO_NAME | | |
| 5 | DLG_SEMAR_H109 | Aku akan menggambarnya sampai tanganku hafal. | I'll draw it until my hand knows it. |
| 5 | @NPC_SEMAR_NAME | | |
| 5 | DLG_SEMAR_V118 | Itu muridku. Tiga kali, di depan boneka latihan itu. | That's my apprentice. Three times, on those practice dummies. |
| H2 | @NPC_SEMAR_NAME | | |
| H2 | DLG_SEMAR_V7 | Lagi. Tiga kali, sampai tanganmu tak perlu menunggu kepalamu. | Again. Three times, until your hand stops waiting for your head. |
| T:ask_faceless | @NPC_SEMAR_NAME | | |
| T:ask_faceless | DLG_SEMAR_V119 | Mereka dulu orang biasa, Nak: tukang, petani, ibu. Lalu dilupakan. | They were ordinary people once, child: craftsmen, farmers, mothers. Then they were forgotten. |
| T:ask_faceless | @NPC_HERO_NAME | | |
| T:ask_faceless | DLG_SEMAR_H110 | Bagaimana orang bisa dilupakan sampai tak punya wajah? | How does a person get forgotten until they have no face? |
| T:ask_faceless | @NPC_SEMAR_NAME | | |
| T:ask_faceless | DLG_SEMAR_V120 | Kalau tak ada yang menyebut atau menulis namamu, wajahmu ikut hilang. Kala yang memakannya. | If nobody speaks or writes your name, your face goes too. Kala eats it. |
| T:ask_faceless | DLG_SEMAR_V121 | Aku belum tahu cara mengembalikannya. Tapi yang pernah bernama, bisa bernama lagi. | I don't know yet how to give it back. But whoever had a name can have one again. |
| T:ask_halflontar | @NPC_SEMAR_NAME | | |
| T:ask_halflontar | DLG_SEMAR_V122 | Lontar itu satu, dipegang dua tangan: satu ujung di tanganmu, satu di tangan Laras. | That lontar is one, held by two hands: one end in yours, one in Laras's. |
| T:ask_halflontar | DLG_SEMAR_V123 | Yang ia tulis di ujungnya muncul di ujungmu, pelan, seperti jejak kaki di pasir. | What she writes on her end appears on yours, slowly, like footprints in sand. |
| T:ask_halflontar | @NPC_HERO_NAME | | |
| T:ask_halflontar | DLG_SEMAR_H111 | Aku bisa membalasnya? | Can I write back? |
| T:ask_halflontar | @NPC_SEMAR_NAME | | |
| T:ask_halflontar | DLG_SEMAR_V124 | Belum. Tapi kau bisa membacanya, dan itu cukup untuk mengikutinya. | Not yet. But you can read it, and that's enough to follow her. |
| 7 | DLG_SEMAR_V8 | Dengar itu? Mereka kembali mencari sesuatu. Alun-alun, cepat! | Hear that? They came back for something. The plaza, go! |
| 8 | DLG_SEMAR_V9 | Mereka lari ke barat, ke gerbang. Pergilah, dan simpan lontarnya dekat jantung. | They ran west, to the gate. Go, and keep the lontar close to your heart. |
| 10 | DLG_SEMAR_V10 | Laut selatan. Orang pesisir bilang laut tak pernah lupa. Semoga mereka benar, hehe. | The south sea. The coast folk say the sea never forgets. I hope they're right, hehe. |
| 11 | DLG_SEMAR_V14 | Gua itu lewat kabut di belakang desa. Aku sampai duluan, hehe. | The cave is through the fog behind the village. I'll get there first, hehe. |
| 12 | DLG_SEMAR_V15 | Ssst, pertunjukannya mulai. Tebak lakon siapa. | Shh, the show's starting. Guess whose lakon it is. |
| 13 | DLG_SEMAR_V16 | Setiap kisah dimulai dari orang yang mengingatnya. | Every story starts with someone who remembers it. |

Choices for the two Semar hubs:
| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_SEMAR_ASK_101 | Ceritakan soal Batara Kala. | Tell me about Batara Kala. | `topic:ask_kala` |
| CHOICE_SEMAR_ASK_102 | Kenapa menulis di daun lontar? | Why write on palm leaf? | `topic:ask_lontar` |
| CHOICE_SEMAR_ASK_103 | Aku temui Cepot dulu. | I'll go and see Cepot. | |
| CHOICE_SEMAR_ASK_104 | Siapa para tanpa rupa itu? | Who are the faceless? | `topic:ask_faceless` |
| CHOICE_SEMAR_ASK_105 | Apa kata lontar Laras? | What does Laras's lontar say? | `topic:ask_halflontar` |
| CHOICE_SEMAR_ASK_106 | Aku kembali berlatih. | Back to practice. | |

Entries 9 to 13 are the later acts' lines, kept as they are (the `DLG_SEMAR_V35`-`_V37`, `_H35` Interlude entry is in section 10). **VERIFY**: that a child "born at the wrong hour" is Kala's prey in ruwatan belief (sukerta); lontar as palm leaf scratched with a knife and blackened with soot.

### cepot (the sanggar, 0.5; entries `P0` and `P1` go first in `cepot.tres`; name NPC_CEPOT_NAME). `P1` is not quiet in v5: `talked_to:cepot` completes the second half of step 0.5
The Act I Cepot entries (SQ-S4) follow; see section 6.
| Entry | if | do |
|-------|----|----|
| P0 | `step:mq0=4`, `!flag:mq0_d4` (`"quiet": true`; the player came to him before Semar) | |
| P1 | `step:mq0=4`, `flag:mq0_d4` (0.5) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| P0 | @NPC_CEPOT_NAME | | |
| P0 | DLG_CEPOT_V101 | Ayahku belum selesai bicara denganmu, kan? Temui dia dulu, baru kita ngobrol. | My father isn't done talking to you, is he? See him first, then we'll chat. |
| P1 | @NPC_CEPOT_NAME | | |
| P1 | DLG_CEPOT_P1 | Ayah! Ceritakan lagi yang ada raksasanya! Ayah? Ayah dengar tidak? | Father! Tell the one with the giant again! Father? Are you even listening? |
| P1 | DLG_CEPOT_P2 | Katanya aksara dulu, raksasa belakangan. Membosankan. | He says aksara first, giants later. Boring. |
| P1 | @NPC_HERO_NAME | | |
| P1 | DLG_CEPOT_H101 | Cepot. Kau berteriak lagi. | Cepot. You're shouting again. |
| P1 | @NPC_CEPOT_NAME | | |
| P1 | DLG_CEPOT_V102 | Aku tidak berteriak, aku bercerita dengan semangat. Beda, tahu. | I'm not shouting, I'm telling it with enthusiasm. There's a difference. |
| P1 | @NPC_HERO_NAME | | |
| P1 | DLG_CEPOT_H102 | Semar bilang kau mau membantu menyalakan lampu. | Semar says you'll help light the lamps. |
| P1 | @NPC_CEPOT_NAME | | |
| P1 | DLG_CEPOT_V103 | Ya, tapi aku tak mau memegang api. Api itu pemarah. Aku pegang minyaknya saja. | Yes, but I won't hold fire. Fire has a temper. I'll hold the oil. |
| P1 | @NPC_HERO_NAME | | |
| P1 | DLG_CEPOT_H103 | Pengecut. | Coward. |
| P1 | @NPC_CEPOT_NAME | | |
| P1 | DLG_CEPOT_V104 | Hati-hati. Aku pemberani, hanya dengan syarat. Tak boleh ada raksasa dalam dua puluh langkah. | Careful. I'm brave, only on conditions. No giants within twenty paces. |
| P1 | DLG_CEPOT_V105 | Sana, tulis di lontar Laras. Aku jaga lampunya, dari jauh, dengan penuh perhatian. | Go on, write on Laras's lontar. I'll watch the lamps, from a distance, very attentively. |

### Beat `lontar_names` (if `!flag:beat_lontar_names`, `flag:mq0_d5`; do `flag:beat_lontar_names`). Area `sanggar_lontar` sets `mq0_d5` (0.6, after the write card). The plant for the tear.
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
| @NPC_HERO_NAME | | |
| BEAT_LONTAR_NAMES_H2 | Kita tak akan lupa, Laras. Kau menulisnya terlalu serius. | We won't forget, Laras. You're writing it far too seriously. |
| @NPC_LARAS_NAME | | |
| BEAT_LONTAR_NAMES_5 | Mungkin. Tapi kata Semar yang tertulis menahan orang di dunia, jadi kutulis dua kali. | Maybe. But Semar says what's written keeps a person in the world, so I wrote it twice. |
| @ | | |
| BEAT_LONTAR_NAMES_6 | Kau memegang ujung yang bernama Laras. Daunnya hangat, seperti baru dilepas dari tangannya. | You hold the end that says Laras. The leaf is warm, as if it just left her hand. |
| @NPC_SEMAR_NAME | | |
| BEAT_LONTAR_NAMES_4 | Hehe, ditulis dengan benar. Simpan baik-baik. Sekarang lampu-lampu di panggung. | Hehe, written properly. Keep it safe. Now the lamps at the stage. |

### Beat `lamps_lit` (if `!flag:beat_lamps_lit`, `flag:mq0_d6b`; do `flag:beat_lamps_lit`). Step 0.7 ends when `puzzle_solved:purwa_stage_lamps` sets `mq0_d6b`. New in v5
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_LAMPS_LIT_1 | Lampu terakhir menyala. Empat nyala kecil mengepung panggung, dan bayanganmu jatuh jauh ke belakang. | The last lamp catches. Four small flames ring the stage, and your shadow falls long behind you. |
| @NPC_CEPOT_NAME | | |
| BEAT_LAMPS_LIT_2 | Lihat? Aku tak menumpahkan setetes pun. Kecuali yang tadi, itu minyak tua. | See? Not a drop spilled. Except that one, but that was old oil. |
| @NPC_HERO_NAME | | |
| BEAT_LAMPS_LIT_H1 | Kau cuma membawa botolnya. | You only carried the bottle. |
| @NPC_CEPOT_NAME | | |
| BEAT_LAMPS_LIT_3 | Botol juga butuh keberanian. | Bottles need courage too. |
| @ | | |
| BEAT_LAMPS_LIT_4 | Penduduk datang membawa tikar. Di barisan depan Ibu melambai, dan di sebelahnya Ciung duduk memeluk telurnya. | The villagers arrive with mats. In the front row Ibu waves, and beside her Ciung sits hugging his egg. |
| @NPC_LARAS_NAME | | |
| BEAT_LAMPS_LIT_5 | Ciung membawa telurnya ke ruwatan. Menurutmu telurnya ikut didoakan? | Ciung brought his egg to the ruwatan. Do you think the egg gets blessed too? |
| @NPC_HERO_NAME | | |
| BEAT_LAMPS_LIT_H2 | Kalau namanya dibacakan, mungkin. | If its name is read, maybe. |
| @ | | |
| BEAT_LAMPS_LIT_6 | Semar menyalakan dupa dan duduk di balik kelir. Para penabuh gamelan mengangkat tangan. | Semar lights the incense and sits behind the kelir. The gamelan players raise their hands. |

### Memory `k0_ruwatan` (play; K0, step 0.8; the first Kelir memory, a tutorial). You move a wayang figure on the kelir; Kala's shadow eats the unlit side. Unchanged from v4
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

### Chapter 3: The Morning After (0.9-0.12)

### Beat `raid` (if `!flag:beat_raid`, `flag:mq0_d8`; do `flag:beat_raid`). The Hunter's first appearance (Pacing 7), step 0.9. The hero does not speak
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_RAID_1 | Bayangan-bayangan turun dari kelir. Topeng kosong, tangan yang menggapai. Orang menjerit; lampu bergoyang. | The shadows step off the screen. Blank masks, reaching hands. People scream; the lamp swings. |
| BEAT_RAID_7 | Gamelan berhenti satu per satu. Kerumunan menyapu kau mundur, jauh dari tempat Laras duduk. | The gamelan stops one by one. The crowd sweeps you back, away from where Laras sits. |
| @NPC_HUNTER_NAME | | |
| BEAT_RAID_2 | Mana bocah dengan telur itu? | Where is the boy with the egg? |
| @ | | |
| BEAT_RAID_8 | Tak ada yang menjawab. Di barisan depan kakek-nenek Ciung saling berpelukan, dan tikar Ciung kosong. | Nobody answers. In the front row Ciung's grandparents hold each other, and Ciung's mat is empty. |
| BEAT_RAID_3 | Ciung sudah menghilang ke dalam gelap. Laras menatap yang paling jangkung dan membisikkan sebuah nama: "Aria." | Ciung has already vanished into the dark. Laras looks at the tallest and whispers a name: "Aria." |
| @NPC_HUNTER_NAME | | |
| BEAT_RAID_4 | Anak yang salah. Tapi yang lebih baik. | Wrong child. A better one. |
| @ | | |
| BEAT_RAID_9 | Laras tidak lari. Ia menggenggam lontarnya erat, dan tangan yang dingin menutup di sekeliling lengannya. | Laras doesn't run. She grips her lontar tight, and a cold hand closes around her arm. |
| @NPC_LARAS_NAME | | |
| BEAT_RAID_5 | Kak! | Kak! |
| @ | | |
| BEAT_RAID_6 | Lontar itu robek di antara tanganmu dan tangan mereka. Mereka menyeretnya ke dalam gelap. Lampu padam. | The lontar tears between your hands and theirs. They drag her into the dark. The lamp goes out. |

### Beat `raid_morning` (if `!flag:beat_raid_morning`, `flag:beat_raid`; do `flag:beat_raid_morning`). A one-line fade card, the old `PROLOGUE_5` (the start of step 0.10). Unchanged
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_RAID_MORNING | Pagi. Separuh lontarmu hilang, jatuh entah di mana di panggung yang hangus. Nama Laras di sana mulai memudar. | Morning. Your half of the lontar is gone, dropped somewhere on the burned stage. Her name on it is fading. |

The lontar on the stage is `item_picked:laras_lontar`: it needs no lines. Ibu's morning talk (entry 4, step 0.10) and the `semar` entries 4 to 8 are in the tables above.

### Beat `hunter_raid` (if `!flag:beat_hunter_raid`, `flag:mq0_7`; do `flag:beat_hunter_raid`, `clue:mask_gate`, `codex:faceless`, `start:mq1`). The west gate (0.12)
| Key | ID | EN |
|-----|----|----|
| BEAT_HUNTER_RAID_1 | Di gerbang barat, sosok jangkung berdiri membelakangi fajar. Topeng kosong, seperti yang lain. Sikapnya tidak. | At the west gate a tall figure stands against the dawn. A blank mask, like the others. The bearing is not. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_RAID_H1 | Kembalikan dia! | Give her back! |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_RAID_2 | Pulanglah. Kau bukan bagian lakon ini. | Go home. You're not part of this lakon. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_RAID_H101 | Laras memanggilmu Aria. Kau kenal nama itu? | Laras called you Aria. Do you know that name? |
| @ | | |
| BEAT_HUNTER_RAID_6 | Sesaat topeng itu miring, seperti mendengar sesuatu dari jauh. Lalu lurus lagi. | For a moment the mask tilts, as if hearing something from far away. Then it straightens. |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_RAID_7 | Tak ada nama itu di sini. | There is no such name here. |
| @ | | |
| BEAT_HUNTER_RAID_3 | Ia tidak menoleh. Pasukannya mengalir lewat gerbang seperti asap, ke barat, lalu gerbang itu kosong lagi. | He doesn't turn. His men pour through the gate like smoke, west, and then the gate is empty again. |
| @NPC_NINI_NAME | | |
| BEAT_HUNTER_RAID_4 | Mereka mencari Ciung kami, bocah dengan telur itu. Ia lari ke barat semalam. Susul dia dulu, Nak, sebelum mereka. | It was our Ciung they came for, the boy with the egg. He ran west in the night. Reach him first, child, before they do. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_RAID_H102 | Ciung ke barat, Laras juga dibawa ke barat. Aku ikut. | Ciung went west, Laras was taken west. I'm going. |
| @ | | |
| BEAT_HUNTER_RAID_5 | Di rumput dekat gerbang tergeletak serpihan topeng putih. Lontarmu bergetar saat kau memungutnya. | A white mask fragment lies in the grass by the gate. Your lontar hums as you pick it up. |

### Clue `mask_gate` (given by the `hunter_raid` beat; no examine lines)
| Key | ID | EN |
|-----|----|----|
| HUNT_MASK_TITLE | Pecahan Topeng | The Mask Fragments |
| CLUE_MASK_GATE_NOTE | Serpihan topeng putih di gerbang barat. Milik si Pemburu. | A white mask fragment at the west gate. The Hunter's. |

## 6. Act I: Tatar Sunda (MQ1, "Segel Kawah")
**Lines in this section: 374** (v5 budget, ASSUMED: at most 560).
Regional character: Dewi Naganingrum (want: a son she held for one night; turn: the lake; close: the rim). Step indices are v5's: `step:mq1=0` is step 1.1, `step:mq1=23` is 1.24. Order of play: arrival slice, the kampung, the Sandekala Hunt (hamlet, clues, memory, boss), the name-stones, the Batu Tulis, the Weaver and the sluices, the Sangkuriang clues, the lake, the crater road, Laras chapter 1, the Captain, the Sangkuriang memory and fight, the naga and Choice 1.

### Chapter 1: Tea and the Bamboo Trail (1.1-1.5)

### tea_picker (dressing, 4 tiles in `ts_kebun`; name NPC_TEA_PICKER_NAME; new; `"quiet": true`)
| Entry | if | do |
|-------|----|----|
| 1 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_TEA_PICKER_NAME | | |
| 1 | DLG_TEA_PICKER_V1 | Dua daun dan satu pucuk, begitu aturannya. Petik lebih, tehnya jadi pahit. | Two leaves and a bud, that's the rule. Pick more and the tea turns bitter. |
| 1 | DLG_TEA_PICKER_V2 | Dengar, kami bernyanyi pelan. Daun lebih suka lagu daripada sunyi. | Listen, we sing softly. Leaves prefer a song to silence. |
| 1 | DLG_TEA_PICKER_V3 | Kalau cari anak kecil, tanya cucu sesepuh di ujung kebun. Dia tak pernah diam. | If you're after a child, ask the elder's grandson at the end of the field. He never sits still. |

**VERIFY**: "two leaves and a bud" as the usual tea-picking rule.

### sunda_grandson (tea terraces; name NPC_SUNDA_GRANDSON_NAME; new). The arrival slice (1.1). The SQ-S3 giver entries (section 15) go before entry 2
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq1=active`, `!flag:mq1_a1` (1.1, sets `mq1_a1`) | `codex:angklung` |
| 2-4 | `flag:remember_freed_scout` / `flag:remember_questioned_scout` / `flag:remember_hid_scout`, `!flag:grandson_noted` (the echo of the kampung choice, once) | `flag:grandson_noted` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_SUNDA_GRANDSON_NAME | | |
| 1 | DLG_SUNDA_GRANDSON_V1 | Dengar para pemetik teh? Mereka bernyanyi supaya daun tak merasa sepi. | Hear the pickers? They sing so the leaves don't feel lonely. |
| 1 | DLG_SUNDA_GRANDSON_V2 | Aku belajar angklung. Satu ruas bambu, satu nada. Sendirian hambar, ramai-ramai merdu. | I'm learning the angklung. One bamboo, one note. Alone it's dull, together it sings. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_GRANDSON_H10 | Kau sendirian di sini? Fajar baru lewat. | You're out here alone? Dawn has only just passed. |
| 1 | @NPC_SUNDA_GRANDSON_NAME | | |
| 1 | DLG_SUNDA_GRANDSON_V10 | Kakek menyuruhku jaga pucuk dari burung. Burungnya tak peduli, nadaku yang sumbang. | Grandfather told me to guard the buds from birds. The birds don't care, it's my notes that are sour. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_GRANDSON_H1 | Kau lihat gadis kecil membawa lontar? | Did you see a little girl with a lontar? |
| 1 | @NPC_SUNDA_GRANDSON_NAME | | |
| 1 | `#wait:1` (cue line, no key) | | |
| 1 | DLG_SUNDA_GRANDSON_V11 | Tidak. Tapi sejak subuh ada orang bertopeng polos lewat. Mereka tak menyentuh teh, hanya menanyai nama. | No. But since dawn, people in blank masks have been passing. They don't touch the tea, they only ask for names. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_GRANDSON_H11 | Di mana mereka sekarang? | Where are they now? |
| 1 | @NPC_SUNDA_GRANDSON_NAME | | |
| 1 | DLG_SUNDA_GRANDSON_V12 | Di rumpun bambu ujung timur. Anehnya, mereka menjauhi kampung. | In the bamboo at the east end. Strangely, they keep away from the kampung. |
| 1 | DLG_SUNDA_GRANDSON_V3 | Tanyakan pada kakekku, sesepuh kampung. Kampungnya di utara, lewat petilasan. | Ask my grandfather, the kampung elder. The kampung is north, past the petilasan. |
| 2 | DLG_SUNDA_GRANDSON_V20 | Kakek bilang kau melepas orang bertopeng itu. Aku bingung harus marah atau lega. | Grandfather says you let the masked man go. I can't tell if I should be angry or relieved. |
| 3 | DLG_SUNDA_GRANDSON_V21 | Kudengar kau membuat orang bertopeng itu bicara. Kakek tak mau cerita isinya. | I heard you made the masked man talk. Grandfather won't say what he said. |
| 4 | DLG_SUNDA_GRANDSON_V22 | Orang bertopeng itu kau sembunyikan? Tetangga berbisik-bisik. Aku tutup mulut. | You hid the masked man? The neighbours are whispering. I'll keep quiet. |
| 5 | DLG_SUNDA_GRANDSON_V4 | Nanti kuajari satu nada, kalau kau kembali utuh. | I'll teach you a note, if you come back in one piece. |

`DLG_SUNDA_GRANDSON_V3` keeps its v4 key and changes text (it now points to the elder and the road).

### Clue `laras_ribbon_spot` and pickup `laras_ribbon` (step 1.1, after the ambush `sunda_edge`)
| Key | ID | EN |
|-----|----|----|
| DLG_RIBBON_H1 | Pita Laras, tersangkut di bambu. Dia lolos dari sini, dan melawan. | Laras's ribbon, caught on the bamboo. She broke free here, and fought. |
| CLUE_LARAS_RIBBON_SPOT_1 | Bambu patah searah, dan di tanah ada jejak sepatu kain kecil. Laras berlari ke sini, bukan diseret. | Bamboo snapped one way, and small cloth-shoe prints in the dirt. Laras ran here, she wasn't dragged. |
| CLUE_LARAS_RIBBON_SPOT_2 | Pitanya tersangkut tinggi di cabang. Dia sengaja meninggalkannya untukku. | Her ribbon is hung high on a branch. She left it there on purpose, for me. |
| CLUE_LARAS_RIBBON_SPOT_NOTE | Bambu patah dan jejak sepatu kain di tepi kebun teh. Laras sempat lolos. | Snapped bamboo and cloth-shoe prints at the tea field's edge. Laras got free for a while. |

### Beat `scout_camp` (if `!flag:beat_scout_camp`, `flag:mq1_a2`; do `flag:beat_scout_camp`). Area `sunda_kebun_camp` cleared sets `mq1_a2` (1.2). New in v5
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SCOUT_CAMP_1 | Di perkemahan yang ditinggalkan, api masih berasap. Potongan lontar berserakan, penuh coretan. | In the abandoned camp the fire still smokes. Scraps of lontar lie scattered, scrawled over. |
| @NPC_HERO_NAME | | |
| BEAT_SCOUT_CAMP_H1 | Daftar nama. Banyak sekali, dan hampir semuanya dicoret. | Lists of names. So many, and nearly all crossed out. |
| @ | | |
| BEAT_SCOUT_CAMP_2 | Beberapa masih terbaca: tukang kayu, pembuat gula, bidan. Di samping tiap nama, tanda silang kasar. | A few can still be read: a carpenter, a sugar-maker, a midwife. Beside each name, a rough cross. |
| `#wait:1` (cue line) | | |
| @NPC_HERO_NAME | | |
| BEAT_SCOUT_CAMP_H2 | Mereka tidak mencatat. Mereka menghapus. | They aren't recording. They're erasing. |
| @ | | |
| `#wait:1` (cue line) | | |
| BEAT_SCOUT_CAMP_3 | Satu lontar terlipat rapi di bawah batu, dan satu nama di atasnya tak dicoret: Laras. | One lontar is folded neatly under a stone, and one name on it isn't crossed out: Laras. |
| @NPC_HERO_NAME | | |
| BEAT_SCOUT_CAMP_H3 | Namanya tak dicoret. Mereka masih membutuhkannya. | Her name isn't crossed out. They still need her. |
| @ | | |
| BEAT_SCOUT_CAMP_4 | Di bawah daftar, jejak sepatu kain kecil mengarah ke utara, ke kampung. Bergegas, tanpa ragu. | Below the lists, small cloth-shoe prints head north toward the kampung. Hurried, unhesitating. |
| @NPC_HERO_NAME | | |
| BEAT_SCOUT_CAMP_H4 | Sebentar lagi, Laras. | Soon, Laras. |

### cepot (SQ-S4, petilasan `sunda_1`, 1.3). The hero meets him again after resting at the petilasan. `talked_to:cepot` completes step 1.3 through the SQ-S4 offer entry (`DLG_CEPOT_11` to `_14`), so that entry is the main-path talk: replace `DLG_CEPOT_11` and extend the entry. `H` is the Act I hub; keep every other Cepot key and entry
His Ga hint (`DLG_CEPOT_15`) plays only after Ga is learned, as the data already gates it (`step:sq_s4=0`, `glyph:sunda_ga`, `!flag:cepot_ga_hint`). Order: keep the SQ-S4 entries as they are, put `H` before the `quest:sq_s4=done` entry.
| Entry | if | do |
|-------|----|----|
| (offer) | `quest:sq_s4=available` (keys below) | `start:sq_s4` |
| H | `quest:sq_s4=done`, `quest:mq1=active`, `"hub": true`, `"quiet": true` | |
| T:ask_father | `"topic": "ask_father"`, `"quiet": true` | |
| T:ask_brave | `"topic": "ask_brave"`, `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| (offer) | @NPC_CEPOT_NAME | | |
| (offer) | DLG_CEPOT_11 | Hei, {name}, dari sanggar itu! Masih ingat aku, Cepot? | Hey, {name}, from the sanggar! Remember me, Cepot? |
| (offer) | @NPC_HERO_NAME | | |
| (offer) | DLG_CEPOT_H110 | Cepot. Kenapa kau di sini? | Cepot. Why are you here? |
| (offer) | @NPC_CEPOT_NAME | | |
| (offer) | DLG_CEPOT_V110 | Ayah menyuruhku menyusul. Katanya kau mencari seseorang yang tak seorang pun ingat, dan aku harus percaya. | Father sent me after you. He said you're looking for someone nobody remembers, and I should believe it. |
| (offer) | @NPC_HERO_NAME | | |
| (offer) | DLG_CEPOT_H111 | Kau tak ingat Laras? | You don't remember Laras? |
| (offer) | @NPC_CEPOT_NAME | | |
| (offer) | DLG_CEPOT_V111 | Tidak. Tapi Ayah tak pernah berbohong soal yang penting. Hanya soal ikan. | No. But Father never lies about the important things. Only about fish. |
| (offer) | @NPC_HERO_NAME | | |
| (offer) | DLG_CEPOT_H112 | Terima kasih sudah datang. | Thank you for coming. |
| (offer) | @NPC_CEPOT_NAME | | |
| (offer) | DLG_CEPOT_V112 | Jangan terharu dulu. Aku datang mengawasi, ingat? Bukan membantu. | Don't get sentimental. I came to supervise, remember? Not to help. |
| (offer) | DLG_CEPOT_V113 | Kampungnya di utara dari sini. Katanya sedang ribut, jadi aku menunggu di sini, dengan setia. | The kampung is north of here. They say there's trouble, so I'm waiting here, loyally. |
| (offer) | DLG_CEPOT_12 | Aku mau buktikan bahwa aku ini pemberani. | I want to prove that I am brave. |
| (offer) | DLG_CEPOT_13 | Ada babi hutan yang berkeliaran di kebun teh. | Wild boars roam the tea terraces. |
| (offer) | DLG_CEPOT_14 | Kalahkan tiga, dan aku mengawasi dari sini. Setuju? | Defeat three, and I supervise from here. Deal? |
| H | DLG_CEPOT_9 | Gelangnya cocok! Tapi jangan lupa siapa yang mengawasi. | The bangle suits you! Don't forget who supervised. |
| T:ask_father | @NPC_CEPOT_NAME | | |
| T:ask_father | DLG_CEPOT_V114 | Ayahku? Dalang desa, tapi di rumah lebih sering diam daripada bicara. | My father? The village dalang, but at home he's quiet more than he talks. |
| T:ask_father | DLG_CEPOT_V115 | Kalau dia diam, seisi sanggar ikut diam. Aneh, kan? Padahal dia cuma duduk. | When he's quiet, the whole sanggar goes quiet. Odd, isn't it? He's only sitting. |
| T:ask_father | @NPC_HERO_NAME | | |
| T:ask_father | DLG_CEPOT_H113 | Kau bangga padanya? | Are you proud of him? |
| T:ask_father | @NPC_CEPOT_NAME | | |
| T:ask_father | DLG_CEPOT_V116 | Bangga setengah mati. Tapi jangan bilang, nanti dia menyuruhku membersihkan wayang. | Proud to bursting. But don't tell him, he'll make me clean the puppets. |
| T:ask_brave | @NPC_CEPOT_NAME | | |
| T:ask_brave | DLG_CEPOT_V117 | Pemberani itu bukan yang tak takut, kata Ayah. Pemberani itu takut, tapi tetap ada di dekat yang maju. | Brave isn't being unafraid, Father says. Brave is being afraid and staying close to the one who goes first. |
| T:ask_brave | @NPC_HERO_NAME | | |
| T:ask_brave | DLG_CEPOT_H114 | Dekat seberapa? | How close? |
| T:ask_brave | @NPC_CEPOT_NAME | | |
| T:ask_brave | DLG_CEPOT_V118 | Dekat yang dengan jarak aman. Kira-kira sepuluh langkah. Dua puluh kalau ada raksasa. | Close with a safe distance. About ten paces. Twenty if there's a giant. |

Choices for the Cepot hub:
| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_CEPOT_ASK_101 | Ceritakan soal ayahmu. | Tell me about your father. | `topic:ask_father` |
| CHOICE_CEPOT_ASK_102 | Kau sungguh pemberani? | Are you really brave? | `topic:ask_brave` |
| CHOICE_CEPOT_ASK_103 | Nanti saja, Cepot. | Later, Cepot. | |

### Beat `kampung_raid` (if `!flag:beat_kampung_raid`, `flag:mq1_2`; do `flag:beat_kampung_raid`; `choices` remember `freed_scout`, `questioned_scout` or `hid_scout`). Area `sunda_kampung` cleared sets `mq1_2` (1.4). The elder is first seen here. The chapter's one real choice (cue lines `#shake:1`, `#cam:sunda_elder`, `#wait:1`, `#cam:hero`): what to do with the one masked scout the villagers hold. The elder reacts in his house talk (entries 1a-1c) and the grandson once; the banner sentences are `REMEMBER_FREED_SCOUT`, `REMEMBER_QUESTIONED_SCOUT`, `REMEMBER_HID_SCOUT`. New in v5
| Key | ID | EN |
|-----|----|----|
| `#shake:1` (cue line) | | |
| @ | | |
| BEAT_KAMPUNG_RAID_1 | Babi hutan terakhir lari ke ladang. Para bertopeng kabur ke kebun teh, kecuali satu yang terjatuh. | The last boar bolts for the fields. The masked ones flee into the tea, all but one who has fallen. |
| `#cam:sunda_elder` (cue line) | | |
| @NPC_SUNDA_ELDER_NAME | | |
| BEAT_KAMPUNG_RAID_2 | Berhenti dulu, Nak. Kau berdarah, dan kampung ini berutang padamu. | Stop a moment, child. You're bleeding, and this kampung owes you. |
| @ | | |
| BEAT_KAMPUNG_RAID_3 | Penduduk keluar dari balik pagar, memegang cangkul dan periuk yang tadi jadi senjata. | The villagers step out from behind the fences, holding hoes and pots that were weapons a moment ago. |
| @NPC_HERO_NAME | | |
| BEAT_KAMPUNG_RAID_H1 | Mereka bukan merampok. | They weren't robbing you. |
| `#wait:1` (cue line) | | |
| @NPC_SUNDA_ELDER_NAME | | |
| BEAT_KAMPUNG_RAID_4 | Bukan. Perampok ada habisnya. Yang ini mencatat, lalu menghapus. | No. Robbers have an end to them. This lot records, then erases. |
| @NPC_HERO_NAME | | |
| BEAT_KAMPUNG_RAID_H2 | Aku mencari adikku, Laras. | I'm looking for my sister, Laras. |
| @NPC_SUNDA_ELDER_NAME | | |
| BEAT_KAMPUNG_RAID_5 | Datanglah ke rumahku. Cucuku sudah bercerita sedikit, dan aku punya sisanya. | Come to my house. My grandson has told you a little, and I have the rest. |
| @ | | |
| BEAT_KAMPUNG_RAID_6 | Ia menunjuk rumah beratap ijuk, asapnya naik lurus seperti garis di lontar. | He points to a house with a palm-fibre roof, its smoke rising straight as a line on a lontar. |
| `#cam:hero` (cue line) | | |
| BEAT_KAMPUNG_RAID_7 | Di belakangnya, dua lelaki menahan satu bertopeng yang tertinggal. Ia tak melawan, hanya gemetar. | Behind him, two men hold the one masked figure left behind. He doesn't fight, he only trembles. |
| @NPC_SUNDA_ELDER_NAME | | |
| BEAT_KAMPUNG_RAID_8 | Dia masih bernapas, Nak. Kaulah yang bertarung. Apa yang kita lakukan padanya? | He's still breathing, child. You did the fighting. What do we do with him? |

Choices for the beat (the pick runs `remember:<key>`, which sets `remember_<key>`):
| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_KAMPUNG_RAID_1 | Lepaskan dia. | Let him go. | `remember:freed_scout` |
| CHOICE_KAMPUNG_RAID_2 | Buat dia bicara. | Make him talk. | `remember:questioned_scout` |
| CHOICE_KAMPUNG_RAID_3 | Sembunyikan dia dari kampung. | Hide him from the kampung. | `remember:hid_scout` |

Banner sentences:
| Key | ID | EN |
|-----|----|----|
| REMEMBER_FREED_SCOUT | Sesepuh kampung akan mengingat bahwa kau melepaskan tawanan bertopeng itu. | The kampung elder will remember that you let the masked prisoner go. |
| REMEMBER_QUESTIONED_SCOUT | Sesepuh kampung akan mengingat bahwa kau memaksa tawanan bertopeng itu bicara. | The kampung elder will remember that you made the masked prisoner talk. |
| REMEMBER_HID_SCOUT | Sesepuh kampung akan mengingat bahwa kau menyembunyikan tawanan itu dari kampung. | The kampung elder will remember that you hid the prisoner from the kampung. |

### sunda_elder (the kampung elder; replace the main-path entries, keep the SQ-S1/S2 entries after them, put hub `H` after those, then the idle entry last)
| Entry | if | do |
|-------|----|----|
| 1a-1c | `step:mq1=4`, `!glyph:sunda_ga`, `flag:remember_freed_scout` / `_questioned_scout` / `_hid_scout` (1.5; the same talk with one opening reaction line, `DLG_SUNDA_ELDER_V21` / `_V22` / `_V23`, before `V10`) | `flag:mq1_3`, `learn:sunda_ga` |
| 1 | `step:mq1=4`, `!glyph:sunda_ga` (1.5) | `flag:mq1_3`, `learn:sunda_ga` |
| 2 | `step:mq1=4`, `glyph:sunda_ga` | |
| (keep) | SQ-S1 / SQ-S2 entries, in their current order | |
| H | `quest:mq1=active`, `"hub": true`, `"quiet": true` | |
| T:ask_kampung | `"topic": "ask_kampung"`, `"quiet": true` | |
| T:ask_wildboy | `"topic": "ask_wildboy"`, `"quiet": true` | |
| (keep) | the current fallback | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_SUNDA_ELDER_NAME | | |
| 1 | DLG_SUNDA_ELDER_V10 | Duduk dulu, Nak. Tehku masih hangat. | Sit a moment, child. My tea is still warm. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_ELDER_H1 | Adikku, Laras. Kecil, membawa lontar. Abah lihat? | My sister, Laras. Small, carrying a lontar. Did you see her? |
| 1 | @NPC_SUNDA_ELDER_NAME | | |
| 1 | DLG_SUNDA_ELDER_V2 | Lihat. Kemarin subuh ia lari dari rumpun bambu bersama bocah liar yang menggendong telur. | I did. Yesterday at dawn she ran from the bamboo with a wild boy hugging an egg. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_ELDER_H11 | Bocah liar itu, Abah kenal? | The wild boy, do you know him? |
| 1 | @NPC_SUNDA_ELDER_NAME | | |
| 1 | DLG_SUNDA_ELDER_V11 | Tidak. Wajahnya mengingatkanku pada seseorang, tapi aku tak sanggup menyebut siapa. | No. His face reminds me of someone, but I can't bring myself to say who. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_ELDER_H2 | Ke mana mereka? | Where did they go? |
| 1 | @NPC_SUNDA_ELDER_NAME | | |
| 1 | `#wait:1` (cue line) | | |
| 1 | DLG_SUNDA_ELDER_V3 | Hilir, ke ngarai sungai. Orang tua bilang Sandekala, roh senja, menjemput anak yang masih di luar saat maghrib. | Downstream, to the river gorge. The old folk say Sandekala, the dusk spirit, collects any child still outside at maghrib. |
| 1 | DLG_SUNDA_ELDER_V20 | Bawa Ga: angkat, dan cahaya jadi dinding. | Take Ga: raise it, and the light becomes a wall. |
| 1 | DLG_SUNDA_ELDER_V12 | Gambar Ga dengan satu goresan tak putus. Jangan ragu di tikungan. | Draw Ga in one unbroken stroke. Don't hesitate at the turn. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_ELDER_H12 | Aku akan mencobanya. | I'll try it. |
| 1 | @NPC_SUNDA_ELDER_NAME | | |
| 1 | DLG_SUNDA_ELDER_V13 | Cobalah di jalan ke ngarai, bukan di kebun lobak kami. | Try it on the road to the gorge, not in our radish patch. |
| 1a | DLG_SUNDA_ELDER_V21 | Kau melepas anak bertopeng itu. Kampung akan menggerutu, tapi aku melihat caramu menatapnya. | You let that masked boy go. The kampung will grumble, but I saw how you looked at him. |
| 1b | DLG_SUNDA_ELDER_V22 | Kau memaksa tawanan itu bicara. Keras, tapi malam ini kampung tidur lebih tenang. | You made the prisoner talk. Harsh, but the kampung will sleep easier tonight. |
| 1c | DLG_SUNDA_ELDER_V23 | Kau menyembunyikan tawanan itu dari kampung. Aku tak akan bertanya di mana. Semoga kau benar. | You hid the prisoner from the kampung. I won't ask where. I hope you were right. |
| 2 | DLG_SUNDA_ELDER_V4 | Ikuti sungai ke hilir, ke dusun di tepi ngarai. Kau akan tahu saat langit mulai jingga. | Follow the river down to the hamlet by the gorge. You'll know it when the sky turns orange. |
| H | @NPC_SUNDA_ELDER_NAME | | |
| H | DLG_SUNDA_ELDER_V6 | Batu tulis, batu berukir itu, ada di atas jalan setapak. Teras sawah di baliknya. | The batu tulis, the carved stone, is up the path. The terraces are past it. |
| T:ask_kampung | @NPC_SUNDA_ELDER_NAME | | |
| T:ask_kampung | DLG_SUNDA_ELDER_V14 | Kampung kecil: tiga puluh rumah, satu balai, satu sumur tua. Dulu aku hafal nama setiap anak. | A small kampung: thirty houses, one hall, one old well. I used to know every child's name. |
| T:ask_kampung | @NPC_HERO_NAME | | |
| T:ask_kampung | DLG_SUNDA_ELDER_H13 | Dulu? | Used to? |
| T:ask_kampung | @NPC_SUNDA_ELDER_NAME | | |
| T:ask_kampung | DLG_SUNDA_ELDER_V15 | Sejak kemarin aku harus berpikir dulu sebelum menyebut cucuku. Itu bukan tua, Nak. Itu yang memakan. | Since yesterday I have to think before I say my grandson's name. That isn't age, child. That's something feeding. |
| T:ask_kampung | DLG_SUNDA_ELDER_V16 | Karena itu kami tetap bernyanyi di kebun. Yang bernyanyi bersama tak mudah lupa. | That's why we keep singing in the fields. People who sing together don't forget so easily. |
| T:ask_wildboy | @NPC_SUNDA_ELDER_NAME | | |
| T:ask_wildboy | DLG_SUNDA_ELDER_V17 | Bocah itu menggendong telur seperti menggendong adik. Orang yang punya sedikit menjaganya habis-habisan. | That boy carried the egg like a little brother. People with little guard it fiercely. |
| T:ask_wildboy | @NPC_HERO_NAME | | |
| T:ask_wildboy | DLG_SUNDA_ELDER_H14 | Dia kasar pada Laras? | Was he rough with Laras? |
| T:ask_wildboy | @NPC_SUNDA_ELDER_NAME | | |
| T:ask_wildboy | DLG_SUNDA_ELDER_V18 | Kasar bicaranya, tangannya tidak. Ia menariknya seperti layangan, tapi tak pernah melepas benangnya. | Rough in his words, not his hands. He towed her like a kite, but never let go of the string. |
| T:ask_wildboy | DLG_SUNDA_ELDER_V19 | Kalau bertemu dia lagi, jangan terburu menjawab marahnya. | If you meet him again, don't be quick to answer his anger. |

Choices for the elder hub:
| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_SUNDA_ELDER_ASK_1 | Ceritakan soal kampung ini. | Tell me about this kampung. | `topic:ask_kampung` |
| CHOICE_SUNDA_ELDER_ASK_2 | Soal bocah liar itu. | About that wild boy. | `topic:ask_wildboy` |
| CHOICE_SUNDA_ELDER_ASK_3 | Terima kasih, Abah. | Thank you, Abah. | |

VERIFY: Sandekala as a dusk spirit that takes children who stay out at maghrib.

### Hunt K1: Sandekala (Chapter 2, 1.6-1.10)
| Key | ID | EN |
|-----|----|----|
| HUNT_K1_TITLE | Sandekala | Sandekala |

### Beat `hamlet_hook` (if `!flag:beat_hamlet_hook`, `glyph:sunda_ga`, `flag:mq1_h1`; do `flag:beat_hamlet_hook`, `codex:sandekala`). K1 hook (1.5). Area `sunda_hamlet` sets `mq1_h1`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_HAMLET_HOOK_1 | Senja di dusun tepi ngarai. Tak ada lampu di jalan setapak. Seorang ibu berdiri di tepi hutan. | Dusk at the hamlet by the gorge. No lamps on the path. A mother stands at the edge of the trees. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_HAMLET_HOOK_2 | Asep! Asep, pulang, Nak! | Asep! Asep, come home, child! |
| @ | | |
| BEAT_HAMLET_HOOK_3 | Tak ada yang menjawab. Pepohonan hanya bergoyang. | Nobody answers. The trees only sway. |
| BEAT_HAMLET_HOOK_6 | Dari ngarai terdengar air, dan di bawahnya sesuatu yang lain: napas yang terlalu panjang, terlalu pelan. | From the gorge comes the sound of water, and beneath it something else: a breath too long, too slow. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_HAMLET_HOOK_4 | Mereka bilang ini ulah Sandekala, roh senja yang mengambil anak di luar saat maghrib. | They say it's Sandekala, the dusk spirit who takes children out at maghrib. |
| BEAT_HAMLET_HOOK_5 | Dulu kami menyalakan oncor, obor bambu, di jalan setiap sore. Entah kenapa kami berhenti. | We used to light oncor, bamboo torches, along the path every evening. I don't know why we stopped. |
| @NPC_HERO_NAME | | |
| BEAT_HAMLET_HOOK_H101 | Kenapa berhenti? | Why did you stop? |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_HAMLET_HOOK_7 | Entahlah. Seperti ada yang menghapusnya dari kepala kami. | I can't say. As if someone wiped it from our heads. |
| @NPC_HERO_NAME | | |
| BEAT_HAMLET_HOOK_H1 | Aku akan mencari anak-anak itu. | I'll find the children. |

### leuwi_mother (the hamlet mother, `leuwi_mother.tres`; name_key `NPC_SUNDA_MOTHER_NAME`). Step 1.6 `talked_to:leuwi_mother`, sets `mq1_h1b`
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=5` (1.6) | |
| 2 | `step:mq1=8` (1.9, before the memory; `"quiet": true`) | |
| 3 | `step:mq1=9` (1.10, `"quiet": true`) | |
| 4 | `flag:mq1_3b` | |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LEUWI_MOTHER_H1 | Bu, aku mencari gadis kecil dan bocah liar. Anak Ibu juga hilang? | Ma'am, I'm looking for a little girl and a wild boy. Is your child missing too? |
| 1 | @NPC_SUNDA_MOTHER_NAME | | |
| 1 | DLG_LEUWI_MOTHER_V1 | Asep, delapan tahun. Dia bermain di tepi ngarai sore tadi dan tak pulang saat maghrib. | Asep, eight years old. He played at the gorge's edge this afternoon and didn't come home by maghrib. |
| 1 | DLG_LEUWI_MOTHER_V2 | Bukan dia saja. Lima anak. Kami cari sampai gelap, tapi tak ada yang berani turun ke sungai. | Not only him. Five children. We searched until dark, but nobody dared go down to the river. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LEUWI_MOTHER_H2 | Kenapa tak berani? | Why not? |
| 1 | @NPC_SUNDA_MOTHER_NAME | | |
| 1 | DLG_LEUWI_MOTHER_V3 | Orang tua bilang itu ulah Sandekala. Sebelum ini tak pernah ada anak hilang di dusun kami. | The old folk say it's Sandekala. Before this no child ever went missing in our hamlet. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LEUWI_MOTHER_H3 | Ada yang melihat gadis kecil membawa lontar? | Did anyone see a little girl carrying a lontar? |
| 1 | @NPC_SUNDA_MOTHER_NAME | | |
| 1 | DLG_LEUWI_MOTHER_V4 | Ada. Dia dan bocah liar itu turun ke ngarai tadi sore, mengejar anak-anak. Kuteriaki, mereka tak menoleh. | Yes. She and the wild boy went down into the gorge this afternoon, chasing the children. I shouted, they didn't turn. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LEUWI_MOTHER_H4 | Mengejar anak-anak. Itu seperti Laras. | Chasing the children. That's just like Laras. |
| 1 | @NPC_SUNDA_MOTHER_NAME | | |
| 1 | DLG_LEUWI_MOTHER_V5 | Kalau kau turun, periksa tepi sungai dulu. Sandal Asep ada di sana, kata tetangga. Bawalah pulang kalau kau lihat. | If you go down, check the riverbank first. Asep's sandal is there, a neighbour says. Bring it home if you see it. |
| 2 | @NPC_SUNDA_MOTHER_NAME | | |
| 2 | DLG_LEUWI_MOTHER_V6 | Waktu kecil, ibuku menyalakan oncor sambil bernyanyi. Aku lupa lagunya, tapi tanganku ingat cara memegang sumbu. | When I was little my mother lit the oncor singing. I forgot the song, but my hands remember how to hold the wick. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_LEUWI_MOTHER_H5 | Lagunya akan kembali kalau oncornya menyala. | The song will come back once the oncor are lit. |
| 2 | @NPC_SUNDA_MOTHER_NAME | | |
| 2 | DLG_LEUWI_MOTHER_V7 | Semoga. Pergilah ke jejak di tepi sungai. Lontarmu akan menunjukkan sisanya. | I hope so. Go to the tracks at the river. Your lontar will show you the rest. |
| 3 | DLG_LEUWI_MOTHER_V8 | Oncor di dusun akan kujaga tetap menyala. Yang di ngarai, kau yang urus. | I'll keep the hamlet's oncor burning. The ones in the gorge are yours. |
| 4 | DLG_LEUWI_MOTHER_V9 | Asep tidur nyenyak dan masih menggenggam sandalnya. Terima kasih, Nak. | Asep sleeps soundly and still holds his sandal. Thank you, child. |
| 5 | DLG_LEUWI_MOTHER_V10 | Oncor kami menyala tiap sore sekarang. Mampirlah kalau lewat. | Our oncor burn every evening now. Stop by if you pass. |

### Clues K1 (step 1.6 `sandal`, 1.7 `oncor` and `gorge_prints`; objects in the dusun and the gorge; `gorge_prints` starts `k1_maghrib`)
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

### Beat `lanterns_lit` (if `!flag:beat_lanterns_lit`, `flag:mq1_h2b`; do `flag:beat_lanterns_lit`). Area `leuwi_outer_oncor` puzzle solved sets `mq1_h2b` (1.8). New in v5
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_LANTERNS_LIT_1 | Lentera bambu terakhir di tepi dusun menyala. Kabut senja yang merayap berhenti di garis cahaya, seperti anjing di ambang pintu. | The last bamboo lantern at the hamlet's edge catches. The creeping dusk mist stops at the line of light, like a dog at a doorstep. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_LANTERNS_LIT_2 | Yang itu dulu milik ayahku. Dua musim tak menyala. | That one was my father's. Two seasons unlit. |
| @NPC_HERO_NAME | | |
| BEAT_LANTERNS_LIT_H1 | Kabutnya mundur. | The mist is backing off. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_LANTERNS_LIT_3 | Bukan kabutnya yang memanggil anak-anak, Nak. Ia hanya tak suka terang. | It isn't the mist that calls the children, child. It just doesn't like light. |
| @ | | |
| BEAT_LANTERNS_LIT_4 | Dari bawah ngarai, bunyi air tiba-tiba berhenti. Lalu terdengar lagi, lebih keras, seperti orang menarik napas untuk marah. | From the gorge below, the sound of water stops. Then it returns, louder, like someone drawing breath to be angry. |
| @NPC_HERO_NAME | | |
| BEAT_LANTERNS_LIT_H2 | Aku turun. Ibu jaga lenteranya. | I'm going down. You keep the lantern lit. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_LANTERNS_LIT_5 | Dulu tiap jalan setapak punya oncor, dan tiap oncor ada yang menjaganya. Lihat sendiri di ngarai. | Once every path had its oncor, and every oncor its keeper. See for yourself in the gorge. |
| @NPC_HERO_NAME | | |
| BEAT_LANTERNS_LIT_H3 | Aku lihat. Aku ke sana. | I'll look. I'm going. |

### Memory `k1_maghrib` (play; K1, step 1.9; kelir figure: a village child at maghrib; the action lights an oncor). Unchanged from v4
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

### Beat `sandekala_after` (if `!flag:beat_sandekala_after`, `flag:mq1_3b`; do `flag:beat_sandekala_after`). K1 aftermath (1.10)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SANDEKALA_AFTER_1 | Sosok tinggi itu lenyap bersama bayangannya. Di pasir ngarai, anak-anak ditemukan tertidur, utuh. | The tall shape is gone with its shadow. On the gorge sand the children are found asleep, whole. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_SANDEKALA_AFTER_2 | Asep! Dia hangat. Dia hangat! | Asep! He's warm. He's warm! |
| @ | | |
| BEAT_SANDEKALA_AFTER_3 | Ibu itu menyalakan oncor pertama sambil menangis dan tertawa. Satu per satu jalan setapak menyala. | The mother lights the first oncor, crying and laughing. One by one the path lights up. |
| @NPC_HERO_NAME | | |
| BEAT_SANDEKALA_AFTER_H1 | Anak-anak lain? | The other children? |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_SANDEKALA_AFTER_5 | Semuanya. Lima, tidur seperti baru dimandikan. Aku tak punya apa pun untuk membayarmu. | All of them. Five, sleeping like they've just been bathed. I have nothing to pay you with. |
| @NPC_HERO_NAME | | |
| BEAT_SANDEKALA_AFTER_H2 | Nyalakan saja oncornya tiap sore. Itu cukup. | Just light the oncor every evening. That's enough. |
| @NPC_SUNDA_MOTHER_NAME | | |
| BEAT_SANDEKALA_AFTER_6 | Akan kulakukan. Dan satu kunyalakan untuk adikmu juga. | I will. And I'll light one for your sister too. |
| @ | | |
| BEAT_SANDEKALA_AFTER_4 | Di lumpur, jejak Laras dan jejak si bocah liar bercabang. Jejak Laras naik ke Batu Tulis, batu berukir di bukit. | In the mud, Laras's prints and the wild boy's part ways. Hers climb to the Batu Tulis, the carved stone on the hill. |

### Chapter 3: The Batu Tulis and the Weaver (1.11-1.15)

### batu_stone_1, batu_stone_2, batu_stone_3 (step 1.11 name-stones; puzzle props, narration only, bare `@`; they keep their `do` flags; new lines in v5)
Stand them up east to west, the way the sun goes. Out of order, a stone shows its hint entry.
| Entry | if | do |
|-------|----|----|
| stone 1 / 1 | `!flag:batu_1` | `flag:batu_1` |
| stone 1 / 2 | (none) | |
| stone 2 / 1 | `flag:batu_1`, `!flag:batu_2` | `flag:batu_2` |
| stone 2 / 2 | `flag:batu_2` | |
| stone 2 / 3 | (none, the hint) | |
| stone 3 / 1 | `flag:batu_2`, `!flag:batu_3` | `flag:batu_3` |
| stone 3 / 2 | `flag:batu_3` | |
| stone 3 / 3 | (none, the hint) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| stone 1 / 1 | @ | | |
| stone 1 / 1 | DLG_BATU_STONE_1_V1 | Sebuah batu nama tumbang, lumutnya dikupas orang. Kau menegakkannya, dan huruf di sisinya menghadap matahari terbit. | A name-stone lies fallen, its moss scraped by someone. You stand it up, and the letters on its side face the sunrise. |
| stone 1 / 2 | @ | | |
| stone 1 / 2 | DLG_BATU_STONE_1_V2 | Batu pertama sudah tegak, di timur. | The first stone stands, in the east. |
| stone 2 / 1 | @ | | |
| stone 2 / 1 | DLG_BATU_STONE_2_V1 | Batu kedua lebih berat. Begitu tegak, hurufnya sejajar dengan yang pertama. | The second stone is heavier. Once it stands, its letters line up with the first. |
| stone 2 / 2 | @ | | |
| stone 2 / 2 | DLG_BATU_STONE_2_V2 | Batu kedua sudah tegak. | The second stone stands. |
| stone 2 / 3 | @ | | |
| stone 2 / 3 | DLG_BATU_STONE_2_V3 | Batu ini belum waktunya. Mulai dari yang timur, seperti jalan matahari. | Not yet for this one. Start with the eastern stone, the way the sun goes. |
| stone 3 / 1 | @ | | |
| stone 3 / 1 | DLG_BATU_STONE_3_V1 | Batu terakhir, di barat. Begitu tegak, ketiganya menunjuk satu garis: ke batu berukir di hutan. | The last stone, in the west. Once it stands, all three point along one line: to the carved stone in the forest. |
| stone 3 / 2 | @ | | |
| stone 3 / 2 | DLG_BATU_STONE_3_V2 | Ketiga batu sudah tegak. | All three stones stand. |
| stone 3 / 3 | @ | | |
| stone 3 / 3 | DLG_BATU_STONE_3_V3 | Dahulukan batu timur dan tengah, baru yang ini. | Raise the eastern and middle stones first, then this one. |

### batu_tulis (replace the `step:mq1=3` entry; keep the two fallbacks `flag:mq1_5` and the last one)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq1=11` (1.12) | `learn:sunda_nga` |
| (keep) | `flag:mq1_5` (`DLG_BATU_TULIS_6`, `_7`) | |
| (keep) | the fallback (`DLG_BATU_TULIS_8` to `_10`) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_BATU_TULIS_V1 | Wajah seorang raja terpahat di batu ini, digores habis dalam-dalam. Debunya masih putih. | A king's face is carved into this stone, scraped out deep. The dust is still white. |
| 1 | @NPC_BATU_TULIS_NAME | | |
| 1 | DLG_BATU_TULIS_V2 | Di bawahnya, goresan kasar tangan kecil: "Mereka butuh aku membaca." | Under it, rough scratches from a small hand: "They need me to read." |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_BATU_TULIS_H101 | Laras. Kau menggores ini sambil dikawal? | Laras. You scratched this with guards around you? |
| 1 | @NPC_BATU_TULIS_NAME | | |
| 1 | DLG_BATU_TULIS_V101 | Goresannya buru-buru, tapi hurufnya rapi. Seperti Laras: cepat, dan tak mau ceroboh. | The scratches are hurried, but the letters are neat. Just like Laras: quick, and unwilling to be careless. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_BATU_TULIS_H102 | Siapa yang menggores habis wajah raja ini? | Who scraped this king's face away? |
| 1 | @NPC_BATU_TULIS_NAME | | |
| 1 | DLG_BATU_TULIS_V102 | Pahatnya bukan pahat pengrajin. Bekasnya lebar dan marah, seperti orang menghapus kenangan yang menyakitkan. | The chisel wasn't a craftsman's. The marks are wide and angry, like someone erasing a painful memory. |
| 1 | DLG_BATU_TULIS_V3 | Di atasnya aksara lama masih bertahan: Ga, lalu Nga, Ga dengan kotak terbuka. Tanganmu membacanya sebelum kau mengerti. Nga mengikat. | Above it the old letters hold: Ga, then Nga, Ga with its box open. Your hand reads it before you understand. Nga binds. |
| 1 | DLG_BATU_TULIS_V4 | Jejak sepatu kain turun ke teras sawah. | Cloth-shoe prints lead down to the rice terraces. |

(`NPC_BATU_TULIS_NAME` is the existing name key of `batu_tulis.tres`.)

### Beat `flood_vista` (if `!flag:beat_flood_vista`, `flag:mq1_5b`; do `flag:beat_flood_vista`). Area `sawah_flood_vista` sets `mq1_5b` (1.13). The Weaver is first seen here. New in v5
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_FLOOD_VISTA_1 | Dari bibir teras, lembah terbentang, dan separuhnya sudah jadi danau. Sawah bertingkat tenggelam sampai pinggang, atap lumbung mengapung seperti tutup periuk. | From the terrace lip the valley opens out, and half of it is already a lake. The terraced paddies stand waist-deep, granary roofs afloat like pot lids. |
| @NPC_HERO_NAME | | |
| BEAT_FLOOD_VISTA_H1 | Kemarin ini semua sawah. | Yesterday this was all paddy. |
| @ | | |
| BEAT_FLOOD_VISTA_2 | Jauh di hulu berdiri sebuah bendungan baru. Tak ada sungai yang membangun bendungan sendiri. | Far upstream stands a new dam. No river builds its own dam. |
| @NPC_HERO_NAME | | |
| BEAT_FLOOD_VISTA_H2 | Jejak Laras turun ke air. Dia lewat sini. | Laras's prints go down into the water. She came this way. |
| @NPC_SUNDA_WEAVER_NAME | | |
| BEAT_FLOOD_VISTA_3 | Jangan injak pematang yang berair, Nak! Jalan bawah sudah dimakan bendungan. | Don't step on the flooded dikes, child! The low road has been eaten by the dam. |
| @NPC_HERO_NAME | | |
| BEAT_FLOOD_VISTA_H3 | Siapa membendung sungai ini? | Who dammed this river? |
| @NPC_SUNDA_WEAVER_NAME | | |
| BEAT_FLOOD_VISTA_4 | Seseorang yang tak sabar menunggu fajar. Kalau mau ke rumah tenunku, keringkan dulu jalannya. | Someone who can't wait for dawn. If you want my loom house, dry the road first. |

### sunda_weaver (step 1.14 talk, step 1.15 gives the cloth; keep the idle entries; drop the SQ-S5 entry, SQ-S5 is retired). Entry `H` is the hub after she has given the cloth
| Entry | if | do |
|-------|----|----|
| 0a | `step:mq1=13` (1.14, `"quiet": true`; she calls from her door across the flood) | |
| 0b | `step:mq1=14`, `!flag:sluice_2` (1.15, `"quiet": true`) | |
| 1 | `step:mq1=14`, `flag:sluice_2` (1.15) | `give:boeh_rarang`, `codex:boeh_rarang` |
| H | `flag:mq1_6`, `"hub": true`, `"quiet": true` | |
| T:ask_boeh | `"topic": "ask_boeh"`, `"quiet": true` | |
| T:ask_laras | `"topic": "ask_laras"`, `"quiet": true` | |
| (keep) | `flag:mq1_5` (`DLG_SUNDA_WEAVER_8`) | |
| (keep) | the idle entries | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 0a | @NPC_SUNDA_WEAVER_NAME | | |
| 0a | DLG_SUNDA_WEAVER_V10 | Kau yang membersihkan terasku dari mereka? Bagus. Tapi jalan ke rumahku masih terendam. | You cleared my terraces of them? Good. But the road to my house is still under water. |
| 0a | DLG_SUNDA_WEAVER_V11 | Dua roda pintu air ada di hulu. Putar yang barat dulu, baru yang timur. | Two sluice wheels stand upstream. Turn the west one first, then the east. |
| 0b | DLG_SUNDA_WEAVER_V12 | Barat dulu, lalu timur. Airnya harus mengalir berurutan. | West first, then east. The water has to go in order. |
| 1 | DLG_SUNDA_WEAVER_1 | Kau yang membebaskan terasku? Duduk. Aku sudah tahu kau mencari siapa. | You cleared my terraces? Sit. I already know who you're looking for. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_WEAVER_H1 | Gadis kecil dengan lontar. Dia lewat sini? | A little girl with a lontar. Did she come through here? |
| 1 | @NPC_SUNDA_WEAVER_NAME | | |
| 1 | DLG_SUNDA_WEAVER_V1 | Semalam. Kusembunyikan di bawah bakul benang. Subuh mereka mengetuk, dan dia keluar sendiri supaya aku tak disakiti. | One night. I hid her under the thread baskets. At dawn they knocked, and she walked out herself so I wouldn't be hurt. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_WEAVER_H101 | Dia keluar sendiri? Laras tak pernah menyerah semudah itu. | She walked out herself? Laras never gives up that easily. |
| 1 | @NPC_SUNDA_WEAVER_NAME | | |
| 1 | DLG_SUNDA_WEAVER_V101 | Dia tidak menyerah, Nak. Dia menyerahkan diri supaya aku selamat. Itu beda. | She didn't give up, child. She gave herself up so I'd be safe. That's different. |
| 1 | DLG_SUNDA_WEAVER_V102 | Sebelum pergi dia bertanya kenapa aku menenun pelan-pelan. Kujawab, supaya tak ada benang yang buru-buru. Dia tertawa. | Before she left she asked why I weave so slowly. I said, so no thread is in a hurry. She laughed. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_WEAVER_H102 | Apa yang dia katakan sebelum pergi? | What did she say before she went? |
| 1 | @NPC_SUNDA_WEAVER_NAME | | |
| 1 | DLG_SUNDA_WEAVER_V2 | Bahwa lelaki tanpa wajah butuh dia membaca sesuatu di kawah. Maka ambil ini, boeh rarang. Kain ini pernah menipu Sangkuriang. Gantung di tiang timur, lalu rapalkan Ca, aksara yang akan kaupelajari di danau. | That the faceless man needs her to read something at the crater. So take this, boeh rarang. It fooled Sangkuriang once. Hang it on the east post, then cast Ca, the letter you'll learn at the lake. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SUNDA_WEAVER_H103 | Siapa yang mengajarkan Ca? | Who teaches Ca? |
| 1 | @NPC_SUNDA_WEAVER_NAME | | |
| 1 | DLG_SUNDA_WEAVER_V103 | Seorang perempuan yang menunggu di tepi danau. Jangan membuatnya menunggu lebih lama. | A woman who waits by the lake. Don't make her wait any longer. |
| H | @NPC_SUNDA_WEAVER_NAME | | |
| H | DLG_SUNDA_WEAVER_V13 | Alat tenunku sudah tenang. Kalau mau tanya sesuatu, duduklah. | My loom has quieted. If you want to ask something, sit down. |
| T:ask_boeh | @NPC_SUNDA_WEAVER_NAME | | |
| T:ask_boeh | DLG_SUNDA_WEAVER_V14 | Boeh rarang itu kain dari kisah. Ibuku menenunnya, ibunya ibuku juga. Selalu putih, selalu menipu. | The boeh rarang is cloth from the tale. My mother wove it, and her mother's mother. Always white, always deceiving. |
| T:ask_boeh | @NPC_HERO_NAME | | |
| T:ask_boeh | DLG_SUNDA_WEAVER_H104 | Menipu siapa? | Deceiving whom? |
| T:ask_boeh | @NPC_SUNDA_WEAVER_NAME | | |
| T:ask_boeh | DLG_SUNDA_WEAVER_V15 | Siapa pun yang sudah menetapkan jam bangunnya sendiri. Dari jauh ia tampak seperti subuh. | Anyone who has set his own hour for waking. From far off it looks like dawn. |
| T:ask_laras | @NPC_SUNDA_WEAVER_NAME | | |
| T:ask_laras | DLG_SUNDA_WEAVER_V16 | Anak itu bertanya hal yang tak ditanyakan anak lain: bagaimana kalau semua orang lupa namaku? | That child asked what other children don't: what if everyone forgets my name? |
| T:ask_laras | DLG_SUNDA_WEAVER_V17 | Kujawab, tulis di kain, kain tak pandai lupa. Dia menyulam huruf kecil di pinggir keranjang. Ka. | I said, write it on cloth, cloth isn't good at forgetting. She stitched a small letter on a basket's edge. Ka. |
| (keep) | DLG_SUNDA_WEAVER_8 | Hati-hati. Benang bisa putus, tapi tekad jangan. | Be careful. Thread may snap, resolve should not. |

Choices for the Weaver hub:
| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_SUNDA_WEAVER_ASK_1 | Ceritakan soal boeh rarang. | Tell me about the boeh rarang. | `topic:ask_boeh` |
| CHOICE_SUNDA_WEAVER_ASK_2 | Soal Laras malam itu. | About Laras that night. | `topic:ask_laras` |
| CHOICE_SUNDA_WEAVER_ASK_3 | Aku harus pergi. | I should go. | |

### Beat `sluices_open` (if `!flag:beat_sluices_open`, `flag:sluice_2`; do `flag:beat_sluices_open`). Wheel 2 sets `sluice_2` and `puzzle_solved:sawah_sluices` (1.15). New in v5
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SLUICES_OPEN_1 | Roda terakhir berderit dan air pergi. Jalan sawah muncul dari bawahnya, licin, penuh ikan kecil yang kebingungan. | The last wheel creaks and the water goes. The paddy road rises from under it, slick, full of bewildered little fish. |
| @NPC_HERO_NAME | | |
| BEAT_SLUICES_OPEN_H1 | Maaf, kalian. | Sorry, you lot. |
| @ | | |
| BEAT_SLUICES_OPEN_5 | Ikan terakhir menggelepar ke parit, dan matahari mulai mengeringkan jalan. | The last fish flop into the ditch, and the sun begins to dry the road. |
| @ | | |
| BEAT_SLUICES_OPEN_2 | Dari rumah tenun terdengar alat tenun memukul pelan, tak-tak, tak-tak, kembali berirama. | From the loom house comes the soft knock of a loom, tak-tak, tak-tak, back in rhythm. |
| @NPC_HERO_NAME | | |
| BEAT_SLUICES_OPEN_H2 | Tenun itu memukul sunyi. Anehnya terdengar seperti jantung. | That loom beats the quiet. Strangely, it sounds like a heart. |
| @ | | |
| BEAT_SLUICES_OPEN_3 | Di jendela rumah seorang perempuan melambai, tak ramah, tapi tak juga menolak. | At the house window a woman waves, not warm, but not turning you away either. |
| @ | | |
| BEAT_SLUICES_OPEN_4 | Di meja depan rumah, dua cangkir teh sudah menanti, dan satunya masih hangat. | On the table by the door, two cups of tea are already waiting, and one is still warm. |
| @NPC_HERO_NAME | | |
| BEAT_SLUICES_OPEN_H3 | Dua cangkir. Seperti di rumah. | Two cups. Like at home. |

### sluice_wheel_1, sluice_wheel_2 (step 1.15 puzzle; narration only, bare `@`; they keep their `do` flags; new lines in v5)
| Entry | if | do |
|-------|----|----|
| wheel 1 / 1 | `!flag:sluice_1` | `flag:sluice_1` |
| wheel 1 / 2 | (none) | |
| wheel 2 / 1 | `flag:sluice_1`, `!flag:sluice_2` | `flag:sluice_2` |
| wheel 2 / 2 | `flag:sluice_2` | |
| wheel 2 / 3 | (none, the hint) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| wheel 1 / 1 | @ | | |
| wheel 1 / 1 | DLG_SLUICE_WHEEL_1_V1 | Roda kayu berkarat. Kau memutarnya, dan sebuah pintu air di hulu berderit membuka. | A rusted wooden wheel. You turn it, and a sluice upstream creaks open. |
| wheel 1 / 2 | @ | | |
| wheel 1 / 2 | DLG_SLUICE_WHEEL_1_V2 | Roda barat sudah terbuka. | The west wheel is already open. |
| wheel 2 / 1 | @ | | |
| wheel 2 / 1 | DLG_SLUICE_WHEEL_2_V1 | Roda timur lebih keras. Kau menariknya dengan seluruh berat badan, dan air di jalan sawah mulai menyurut. | The east wheel is stiffer. You haul it with your whole weight, and the water on the paddy road begins to fall. |
| wheel 2 / 2 | @ | | |
| wheel 2 / 2 | DLG_SLUICE_WHEEL_2_V2 | Roda timur sudah terbuka. | The east wheel is already open. |
| wheel 2 / 3 | @ | | |
| wheel 2 / 3 | DLG_SLUICE_WHEEL_2_V3 | Roda ini tak mau bergerak sebelum yang barat dibuka. Airnya harus mengalir berurutan. | This wheel won't move before the west one is open. The water has to go in order. |

### Beat `lake_hook` (if `!flag:beat_lake_hook`, `flag:mq1_6`, `zone:ts_situ`; do `flag:beat_lake_hook`). K2 hook (1.16). v4's area `sunda_lakeroad` is not in the v5 zone doc, so the beat fires on entering `ts_situ`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_LAKE_HOOK_1 | Hulu sungai tersumbat bendungan baru, seolah dibuat semalam. Di tengah danau berdiri rusuk-rusuk perahu yang belum jadi. | The river's head is choked by a new dam, as if built overnight. In the lake stand the ribs of a half-built boat. |
| @NPC_HERO_NAME | | |
| BEAT_LAKE_HOOK_H1 | Siapa membangun perahu di tengah danau? | Who builds a boat in the middle of a lake? |
| @ | | |
| BEAT_LAKE_HOOK_2 | Air naik setengah langkah setiap kali kau berkedip, sabar, seperti cerita yang menolak berhenti. | The water climbs half a step each time you blink, patient, like a story that refuses to stop. |
| @NPC_HERO_NAME | | |
| BEAT_LAKE_HOOK_H2 | Bendungan, pohon rebah, perahu. Seseorang sedang menyelesaikan sesuatu. | A dam, felled trees, a boat. Someone is finishing something. |
| @ | | |
| BEAT_LAKE_HOOK_3 | Di jalan tepi danau, tiga bertopeng polos berjaga, bergantian menatap air dan menatap langit di timur. | On the lake road three blank masks keep watch, taking turns to stare at the water and at the eastern sky. |
| @NPC_HERO_NAME | | |
| BEAT_LAKE_HOOK_H3 | Mereka menunggu fajar. | They're waiting for dawn. |
| BEAT_LAKE_HOOK_H4 | Kalau Laras di sini, dia pasti sedang menghitung langkah penjaga itu. | If Laras were here, she'd be counting that guard's steps. |
| @ | | |
| BEAT_LAKE_HOOK_4 | Lontarmu bergetar sekali, lalu diam, seperti seseorang di seberang yang menahan napas. | Your lontar shivers once, then stills, like someone far away holding her breath. |

### Hunt K2: Sangkuriang (1.17, 1.23, 1.24)
| Key | ID | EN |
|-----|----|----|
| HUNT_K2_TITLE | Sangkuriang | Sangkuriang |

### Clues K2 (step 1.17; `loom` is in the Weaver's house; `boat_ribs` is on the crater rim and starts `k2_dayang_sumbi`)
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

### Chapter 4: The Exiled Queen by the Lake (1.16-1.19)

### Clue `faceless_toy` (step 1.18; the Captain clue: the masks were people)
| Key | ID | EN |
|-----|----|----|
| CLUE_FACELESS_TOY_1 | Kuda kayu kecil yang dijatuhkan seorang tanpa rupa. Ada nama digores di perutnya: Dasim. | A small wooden horse a faceless one dropped. A name is scratched on its belly: Dasim. |
| CLUE_FACELESS_TOY_2 | Mereka dulu orang. Seseorang pernah mengukir mainan untuk seorang anak. | They were people once. Somebody carved a child a toy. |
| CLUE_FACELESS_TOY_NOTE | Mainan berukir nama "Dasim". Para tanpa rupa dulunya manusia. | A toy marked "Dasim". The faceless were people. |

### naganingrum (ts_situ, cond `flag:mq1_6b`, stays after MQ1; name NPC_NAGANINGRUM_NAME). The turn (1.19). Entries `H`, `N1`, `N2` are hubs; the Choice 1 entries `N1` and `N2` come after the choice
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq1_6b`, `step:mq1=18` (1.19) | `learn:sunda_ca` |
| N1 | `quest:mq1=done`, `flag:choice_tell_ciung`, `"hub": true`, `"quiet": true` | |
| N2 | `quest:mq1=done`, `flag:choice_keep_secret`, `"hub": true`, `"quiet": true` | |
| H | `flag:mq1_7`, `"hub": true`, `"quiet": true` | |
| T:ask_night | `"topic": "ask_night"`, `"quiet": true` | |
| T:ask_lake | `"topic": "ask_lake"`, `"quiet": true` | |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_NAGANINGRUM_H1 | Adikku, dan seorang bocah liar dengan telur. Alisnya bertaut, matanya baik. Dia lewat sini? | My sister, and a wild boy with an egg. Scowling brows, kind eyes. Did he pass this way? |
| 1 | @NPC_NAGANINGRUM_NAME | | |
| 1 | DLG_NAGANINGRUM_V101 | Bertaut seperti ayahnya, dan baik seperti seseorang yang ingin sekali kuingat. | Scowling like his father, and kind like someone I badly want to remember. |
| 1 | DLG_NAGANINGRUM_V2 | Aku kenal wajah itu. Semalam saja kutimang, lima belas tahun lalu, sebelum sungai membawanya pergi. | I know that face. I held it for one night, fifteen years ago, before the river took him. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_NAGANINGRUM_H101 | Anda... ibunya? | You are... his mother? |
| 1 | @NPC_NAGANINGRUM_NAME | | |
| 1 | DLG_NAGANINGRUM_V102 | Aku yang melahirkannya, bukan yang membesarkannya. Jangan katakan padanya, Nak. Belum. | I bore him, I didn't raise him. Don't tell him, child. Not yet. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_NAGANINGRUM_H102 | Kenapa belum? | Why not yet? |
| 1 | @NPC_NAGANINGRUM_NAME | | |
| 1 | DLG_NAGANINGRUM_V103 | Raja palsu menyebar kabar bahwa aku membuang putraku. Kalau ia percaya, ia akan membenciku. Aku belum sanggup. | The false king spread word that I threw my son away. If he believes it, he'll hate me. I can't bear that yet. |
| 1 | DLG_NAGANINGRUM_V3 | Dan yang memburunya bukan pencuri, Nak, melainkan pewaris. Ambil Ca. Ia meledak seperti fajar; kapten yang sedang memanggil pasukannya tak akan selesai berseru. | And what hunts him isn't after a thief, child, it's after an heir. Take Ca. It bursts like dawn, and a captain calling his men won't finish the call. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_NAGANINGRUM_H103 | Pewaris apa? | An heir to what? |
| 1 | @NPC_NAGANINGRUM_NAME | | |
| 1 | DLG_NAGANINGRUM_V104 | Takhta Galuh, kerajaan di timur. Seorang raja palsu duduk di sana memakai wajah suamiku. | The throne of Galuh, the kingdom to the east. A false king sits there wearing my husband's face. |
| 1 | DLG_NAGANINGRUM_V4 | Dia naik ke kawah. Aku menyusul secepat kakiku mau. Kau lebih cepat. | He went up to the crater. I'll follow as fast as my legs allow. You're faster. |
| N1 | @NPC_NAGANINGRUM_NAME | | |
| N1 | DLG_NAGANINGRUM_V105 | Ia datang pagi tadi, berdiri di tepi air lama sekali. Aku tak berani menoleh. | He came this morning and stood at the water's edge a long time. I didn't dare turn. |
| N1 | DLG_NAGANINGRUM_V106 | Lalu ia memanggilku Ibu, pelan, seperti mencoba kata asing. Tak ada kata yang lebih lama kutunggu. | Then he called me Ibu, softly, like trying a foreign word. No word I've waited for longer. |
| N1 | @NPC_HERO_NAME | | |
| N1 | DLG_NAGANINGRUM_H104 | Dia akan kembali setelah Galuh. | He'll come back after Galuh. |
| N1 | @NPC_NAGANINGRUM_NAME | | |
| N1 | DLG_NAGANINGRUM_V107 | Aku akan menyeduh dua cangkir. Dan kau, pulanglah dengan selamat, bersama dia. | I'll brew two cups. And you, come home safe, with him. |
| N2 | @NPC_NAGANINGRUM_NAME | | |
| N2 | DLG_NAGANINGRUM_V108 | Ia datang menanyakan jalan ke Galuh, sopan dan canggung, lalu pergi. Aku menuang teh dan diam. | He came asking the road to Galuh, polite and awkward, then left. I poured tea and said nothing. |
| N2 | DLG_NAGANINGRUM_V109 | Diam itu berat, Nak. Tapi lebih ringan daripada melihat matanya berubah. | Silence is heavy, child. But lighter than watching his eyes change. |
| N2 | @NPC_HERO_NAME | | |
| N2 | DLG_NAGANINGRUM_H105 | Ia akan tahu setelah raja palsu tersingkap. | He'll know once the false king is unmasked. |
| N2 | @NPC_NAGANINGRUM_NAME | | |
| N2 | DLG_NAGANINGRUM_V110 | Aku akan menunggu di tepi air, dengan dua cangkir. | I'll wait at the water's edge, with two cups. |
| H | @NPC_NAGANINGRUM_NAME | | |
| H | DLG_NAGANINGRUM_V5 | Ke kawah. Pergilah, kumohon. | The crater. Go, please. |
| T:ask_night | @NPC_NAGANINGRUM_NAME | | |
| T:ask_night | DLG_NAGANINGRUM_V111 | Hujan deras, sungai naik. Kutimang ia sampai fajar dan kuhitung napasnya, satu, dua, seperti menghitung batu di tangan. | Hard rain, the river rising. I rocked him till dawn and counted his breaths, one, two, like counting stones in my hand. |
| T:ask_night | DLG_NAGANINGRUM_V112 | Fajar datang, dan seorang abdi tua mengambilnya dari tanganku. Kuserahkan sendiri, supaya ia hidup. | Dawn came, and an old servant took him from my hands. I gave him up myself, so he'd live. |
| T:ask_night | @NPC_HERO_NAME | | |
| T:ask_night | DLG_NAGANINGRUM_H106 | Anda menyerahkannya supaya selamat. | You gave him up to save him. |
| T:ask_night | @NPC_NAGANINGRUM_NAME | | |
| T:ask_night | DLG_NAGANINGRUM_V113 | Ya. Itu yang tak pernah kuceritakan pada siapa pun. | Yes. That's what I've never told anyone. |
| T:ask_lake | @NPC_NAGANINGRUM_NAME | | |
| T:ask_lake | DLG_NAGANINGRUM_V114 | Air membawanya pergi, jadi ke air aku kembali. Orang bilang itu kutukan. Aku bilang itu kebiasaan. | The water took him, so to the water I return. People call it a curse. I call it a habit. |
| T:ask_lake | DLG_NAGANINGRUM_V115 | Tiap pagi aku menyapa danau dengan namanya, nama yang kuberikan malam itu. Danau tak pernah menjawab. | Every morning I greet the lake with his name, the one I gave him that night. The lake never answers. |
| T:ask_lake | @NPC_HERO_NAME | | |
| T:ask_lake | DLG_NAGANINGRUM_H107 | Namanya apa? | What was the name? |
| T:ask_lake | @NPC_NAGANINGRUM_NAME | | |
| T:ask_lake | DLG_NAGANINGRUM_V116 | Itu kusimpan. Satu hal yang masih milikku. | I keep that. The one thing still mine. |
| 3 | DLG_NAGANINGRUM_V6 | Airnya tenang hari ini. Pergilah, aku tak ke mana-mana. | The water's quiet today. Go on, I'm not going anywhere. |

Choices for the Naganingrum hubs:
| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_NAGANINGRUM_ASK_101 | Ceritakan malam itu. | Tell me about that night. | `topic:ask_night` |
| CHOICE_NAGANINGRUM_ASK_102 | Kenapa Anda tinggal di tepi danau? | Why do you live by the lake? | `topic:ask_lake` |
| CHOICE_NAGANINGRUM_ASK_103 | Saya permisi dulu. | I'll take my leave. | |

Entries `V4` (ending lead) and the choice flags are the Choice 1 set-up: her request "don't tell him, not yet" (`DLG_NAGANINGRUM_V102`) is what the player weighs in the `naga` beat. `DLG_NAGANINGRUM_V104` names Galuh and explains it in the same line.

### Chapter 5: The Rising Waters and the Crater Seal (1.20-1.24)

### Beat `crater_road` (if `!flag:beat_crater_road`, `flag:mq1_7`, `zone:ts_kawah_jalan`; do `flag:beat_crater_road`). Step 1.20, entering the crater road; the Captain is a dark shape on the ridge (`faceless_captain_seen`, no talk). New in v5
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_CRATER_ROAD_1 | Jalan kawah naik tajam, berbatu hitam, dan baunya seperti korek yang baru padam. | The crater road climbs steeply, black stone, smelling like a match just blown out. |
| @NPC_HERO_NAME | | |
| BEAT_CRATER_ROAD_H1 | Belerang. Gunung ini masih bernapas. | Sulphur. This mountain is still breathing. |
| @ | | |
| BEAT_CRATER_ROAD_2 | Di punggung bukit di depan, sosok jangkung bertombak berdiri tak bergerak seperti tiang. | On the ridge ahead a tall figure with a spear stands motionless as a post. |
| @NPC_HERO_NAME | | |
| BEAT_CRATER_ROAD_H2 | Itu kaptennya. | That's the captain. |
| @ | | |
| BEAT_CRATER_ROAD_3 | Dari sana seruan panjang bergema, memanggil pasukan yang belum datang. Kau ingat kata Naganingrum: ia tak akan selesai berseru. | From there a long call echoes, summoning troops that haven't arrived. You remember Naganingrum: he won't finish the call. |
| @NPC_HERO_NAME | | |
| BEAT_CRATER_ROAD_H3 | Ca akan memotong seruannya, kalau aku cukup dekat. | Ca will cut his call short, if I get close enough. |
| @ | | |
| BEAT_CRATER_ROAD_4 | Lontarmu menghangat di dada, dan di balik angin kau mendengar goresan halus: Ka, Ka, Ka. | Your lontar warms against your chest, and beneath the wind you hear a faint scratching: Ka, Ka, Ka. |
| @NPC_HERO_NAME | | |
| BEAT_CRATER_ROAD_H4 | Tunggu aku, Laras. | Wait for me, Laras. |

### Clue `lc1_voice` (step 1.21; at the upper petilasan `sunda_2`, appears when step 1.21 is current; pulls you into `lc1`)
| Key | ID | EN |
|-----|----|----|
| CLUE_LC1_VOICE_1 | Di petilasan, angin membawa sesuatu: goresan halus, huruf demi huruf. Laras, membaca sangat pelan. | At the petilasan the wind carries something: a faint scratching, letter by letter. Laras, reading very slowly. |
| CLUE_LC1_VOICE_2 | Lontarku berdenyut seirama dengannya. Dia memanggilku lewat tulisannya. | My lontar pulses in time with it. She is calling me through her writing. |
| CLUE_LC1_VOICE_NOTE | Suara Laras di petilasan atas, membaca pelan-pelan. | Laras's voice at the upper petilasan, reading slowly. |

### Laras chapter LC1 `lc1` (step 1.21; kind chapter; Laras is put before the seal-stone at the crater). `do`: `flag:laras_sabotage_crater_seal`, `flag:laras_key_crater_post`, `flag:mq1_lc`
Her one action: say a true name. Generic lines for every chapter first (`LC_HINT` shows on the first chapter only). Keep `LC_FREEZE_1` to `_3`. The Boeh Rarang line is Laras's, because the Weaver told her where the cloth goes. LC1 is 8 lines in v5 (was 4); the order of play is `LC1_1`, `_2`, `_3`, `_5`, `_6`, `_7`, `_8`, `_4`.
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
| LC1_5 | Hei, penjaga. Kau pernah punya nama, kan? Coba ingat sebentar, sementara aku membaca. | Hey, guard. You had a name once, didn't you? Try to remember it, while I read. |
| LC1_6 | Tiang timur ini yang mereka ikat untuk menunggu fajar. Kugores Ka kecil di sini, supaya Kakak tahu. | This east post is where they tie off to wait for dawn. I'll scratch a small Ka here, so Kak knows. |
| LC1_7 | Kak, nanti gantung kain putih Penenun di tiang bertanda. Fajar palsu menunggu di sana. | Kak, later hang the Weaver's white cloth on the marked post. The false dawn waits there. |
| LC1_8 | Ka. Ka. Ka. Satu lagi, supaya Kakak tak lupa aku. | Ka. Ka. Ka. One more, so you don't forget me. |
| LC1_4 | Kak? Di sini gelap. Aku membaca pelan-pelan. Kalau kau dengar ini, jangan lama-lama. | Kak? It's dark here. I'm reading slowly. If you can hear this, don't take long. |

### Beat `crater_seal` (if `!flag:beat_crater_seal`, `flag:mq1_8`; do `flag:beat_crater_seal`, `restore`). Step 1.22, after the Captain falls
| Key | ID | EN |
|-----|----|----|
| BEAT_CRATER_SEAL_1 | Sang kapten berlutut. Dengan sisa tenaganya ia menghantam batu segel yang sudah retak dengan gagang tombak. | The Captain drops to a knee. With the last of his strength he drives his spear butt into the cracked seal-stone. |
| BEAT_CRATER_SEAL_4 | Ia tertawa tanpa mulut, bunyi tombak diseret di batu, dan satu kata terdengar dari dalam topengnya: "Fajar." | He laughs without a mouth, a sound like a spear dragged over stone, and one word comes from inside his mask: "Dawn." |
| BEAT_CRATER_SEAL_2 | Batu itu pecah. Di dasar kawah, sesuatu sebesar bukit menarik napas. | The stone splits. Down in the crater, something the size of a hill takes a breath. |
| BEAT_CRATER_SEAL_5 | Tanah bergetar, dan air danau jauh di bawah ikut mengalir naik, seperti mendengar ada yang memanggilnya. | The ground trembles, and the lake far below rises too, as if something had called it. |
| BEAT_CRATER_SEAL_3 | Di bibir seberang, sosok jangkung bertopeng menonton sebentar, lalu pergi. Di bawahnya, Ciung Wanara tergantung dalam rantai, seperti umpan. | On the far rim a tall masked figure watches a moment, then leaves. Below him Ciung Wanara hangs in chains like bait. |
| @NPC_HERO_NAME | | |
| BEAT_CRATER_SEAL_H1 | Ciung! Bertahanlah! | Ciung! Hold on! |
| @ | | |
| BEAT_CRATER_SEAL_6 | Ciung menoleh dalam rantainya. Matanya marah dan takut sekaligus, dan ia tidak minta tolong. | Ciung turns in his chains. His eyes are angry and afraid at once, and he does not ask for help. |
| @NPC_HERO_NAME | | |
| BEAT_CRATER_SEAL_H2 | Aku datang. Jangan mati dulu. | I'm coming. Don't die yet. |
| @ | | |
| BEAT_CRATER_SEAL_7 | Di sebelahnya rantai lain mengikat sesuatu yang bersisik, perunggu kusam, bernapas sangat pelan. Naga itu menatapmu, tidak marah. | Beside him another chain binds something scaled, dull bronze, breathing very slowly. The naga looks at you, not angry. |

### Clue `hunter_mask_1` and memory `h1` (step 1.22; H1, kind walk; young Aria sweeps a palace floor). Unchanged from v4
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

### Clue `boat_ribs` and memory `k2_dayang_sumbi` (step 1.23; K2, kind play; kelir figure: the woman from Semar's show; the action spreads cloth and pounds the lesung). Unchanged from v4
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

### Beat `dawn_post` (if `!flag:beat_dawn_post`, `flag:mq1_h6`; do `flag:beat_dawn_post`). Step 1.23 beat, right after the K2 memory and before the boss. New in v5
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_DAWN_POST_1 | Kenangan Dayang Sumbi surut, dan bau kain putih masih di hidungmu. Di bawah, raksasa itu bangun seperti gunung memutuskan berdiri. | Dayang Sumbi's night recedes, and the smell of white cloth still clings to you. Below, the giant wakes like a mountain deciding to stand. |
| @NPC_HERO_NAME | | |
| BEAT_DAWN_POST_H1 | Kain Penenun. Tiang timur. Ca. | The Weaver's cloth. The east post. Ca. |
| @ | | |
| BEAT_DAWN_POST_2 | Ia menyeret sebuah perahu yang tak pernah selesai. Mulutnya menghitung: "Sebelum fajar, sebelum fajar." | He drags a boat that is never finished. His mouth counts: "Before dawn, before dawn." |
| @ | | |
| BEAT_DAWN_POST_3 | Di tiang timur, di antara retakan, kau melihat satu goresan yang kau kenal: sebuah Ka miring, seperti tulisan anak kecil. | On the east post, between the cracks, you see a mark you know: a crooked Ka, like a child's writing. |
| @NPC_HERO_NAME | | |
| BEAT_DAWN_POST_H2 | Laras. Kau sudah di sini. | Laras. You were already here. |
| @ | | |
| BEAT_DAWN_POST_4 | Goresan itu hangat. Kau tahu: tiang ini milikmu sekarang. | The mark is warm. You know it: this post is yours now. |
| @NPC_HERO_NAME | | |
| BEAT_DAWN_POST_H3 | Kalau ia menghitung fajar, kuberi ia satu. | If he's counting dawns, I'll give him one. |
| @ | | |
| BEAT_DAWN_POST_5 | Kau membentangkan Boeh Rarang. Cahaya palsu mulai menjalar di kainnya, seperti subuh yang belum punya matahari. | You spread the Boeh Rarang. False light creeps along its weave, like a dawn that has no sun yet. |

### Beat `naga` (if `!flag:beat_naga`, `quest:mq1=done`; do `flag:beat_naga`, `flag:mq1_10`, `codex:nagawiru`, `codex:sangkuriang`, `lakon:sangkuriang`, `start:mqg`). Step 1.24, Choice 1. Nagawiru is first named here (his name tag shows on his first line)
| Key | ID | EN |
|-----|----|----|
| BEAT_NAGA_1 | Fajar palsu padam. Sangkuriang duduk di antara perahunya yang tak pernah jadi dan tertidur. Rantai mengendur, dan seekor naga besar bangkit dari lumpur, sisiknya kusam seperti perunggu tua. | The false dawn fades. Sangkuriang sits down among his never-finished boats and sleeps. The chains slacken, and a great naga rises from the mud, scales dull as old bronze. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_2 | Kau mengikutiku sampai sini? Berani atau bodoh, aku belum tahu. | You followed me all the way here? Brave or stupid, I haven't decided. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_NAGA_3 | Orang di singgasana Galuh, kerajaan di timur, memakai wajahku, Nak. Mereka membawa gadis kecil itu ke sana. | The man on the throne of Galuh, the kingdom east of here, wears my face, child. They took the little girl there. |
| @NPC_HERO_NAME | | |
| BEAT_NAGA_H1 | Galuh? Mereka membawa Laras ke sana? | Galuh? They took Laras there? |
| @ | | |
| BEAT_NAGA_4 | Telur di dekapan Ciung retak. Seekor anak ayam jantan menggelinding keluar, sudah galak. | The egg in Ciung's arms cracks. A rooster chick tumbles out, already angry. |
| @NPC_NAGANINGRUM_NAME | | |
| BEAT_NAGA_5 | Nak...? | Child...? |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_6 | Hati-hati, Bu, licin di sini. Nah, kau. Galuh. Ikut? Gerbang timur desamu jalan pintasnya. | Careful, ma'am, it's slippery here. Now you. Galuh. Coming? Your village's east gate is the short way. |
| @ | | |
| BEAT_NAGA_7 | Ia memegang siku perempuan itu tanpa tahu siapa dia, dan perempuan itu menahan napas, seolah tangan itu bisa pecah. | He holds the woman's elbow without knowing who she is, and she holds her breath as if the hand might shatter. |
| BEAT_NAGA_8 | Lalu Ciung berbalik ke jalan timur. Naganingrum menatapmu, memohon dan takut sekaligus, dan tidak berkata apa-apa. | Then Ciung turns to the east road. Naganingrum looks at you, pleading and afraid at once, and says nothing. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_NAGA_1 | Katakan pada Ciung: perempuan itu ibunya. | Tell Ciung: that woman is his mother. | `flag:choice_tell_ciung` |
| CHOICE_NAGA_2 | Simpan rahasianya sampai raja palsu tersingkap. | Keep her secret until the false king is unmasked. | `flag:choice_keep_secret` |

Effects of Choice 1 (code, not text): **Tell Ciung:** Ciung reconciles with Naganingrum before marching east; she blesses your lontar (`+10% Sunda Ca radius`) and sends lake-wardens to help in Act II's cell yard. **Keep Secret:** Ciung stays focused (`+15% ally damage` in Galuh bouts) and the reunion happens in the Epilogue. Each branch has its own short beat; the choice flags are exclusive.

### Beat `naga_tell` (if `!flag:beat_naga_tell`, `flag:choice_tell_ciung`; do `flag:beat_naga_tell`). Choice 1, Tell Ciung. New in v5
| Key | ID | EN |
|-----|----|----|
| @NPC_HERO_NAME | | |
| BEAT_NAGA_TELL_H1 | Ciung, tunggu. Perempuan ini bukan orang asing. | Ciung, wait. This woman isn't a stranger. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_TELL_1 | Aku tak punya waktu untuk teka-teki. Adikmu ada di Galuh. | I've no time for riddles. Your sister is in Galuh. |
| @NPC_HERO_NAME | | |
| BEAT_NAGA_TELL_H2 | Dia yang melahirkanmu. Dia menimangmu semalam, lima belas tahun lalu, sebelum sungai. | She bore you. She rocked you one night, fifteen years ago, before the river. |
| @ | | |
| BEAT_NAGA_TELL_2 | Ciung berhenti. Di dekapannya cangkang kosong, dan anak ayam di bahunya mengibas, seolah tahu. | Ciung stops. The empty shell is in his arms, and the chick on his shoulder flutters, as if it knows. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_TELL_3 | Kenapa tak ada yang mencariku? | Why did nobody come looking for me? |
| @NPC_NAGANINGRUM_NAME | | |
| BEAT_NAGA_TELL_4 | Aku mencari setiap hari, Nak. Di tepi air, sampai air itu menjawab dengan wajahmu. | I looked every day, child. At the water's edge, until the water answered with your face. |
| @ | | |
| BEAT_NAGA_TELL_5 | Ciung tidak memeluknya. Tapi ia berlutut dan menaruh dahi di punggung tangan perempuan itu, sebentar, sangat sebentar. | Ciung doesn't embrace her. But he kneels and rests his forehead on the back of her hand, briefly, very briefly. |
| @NPC_NAGANINGRUM_NAME | | |
| BEAT_NAGA_TELL_6 | Penulis, dekatkan lontarmu. Kuberkati dia. Dan para penjaga danau akan menyusul kalian ke Galuh. | Writer, hold your lontar close. I bless it. And the lake-wardens will follow you to Galuh. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_TELL_7 | Aku akan kembali, Bu. Setelah Galuh. | I'll come back, Ibu. After Galuh. |

### Beat `naga_secret` (if `!flag:beat_naga_secret`, `flag:choice_keep_secret`; do `flag:beat_naga_secret`). Choice 1, Keep Secret. New in v5
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_NAGA_SECRET_1 | Kau memandang Naganingrum sekali, lalu menutup mulutmu. Ia mengangguk, begitu kecil hingga hanya kau yang melihat. | You look at Naganingrum once, then close your mouth. She nods, so slightly only you see it. |
| @NPC_NAGANINGRUM_NAME | | |
| BEAT_NAGA_SECRET_2 | Terima kasih. Bukan karena takut dibenci. Karena takut ia berhenti, hanya untuk aku. | Thank you. Not because I fear being hated. Because I fear he'd stop, only for me. |
| @NPC_HERO_NAME | | |
| BEAT_NAGA_SECRET_H1 | Dia akan tahu pada waktunya. | He'll know in time. |
| @NPC_NAGANINGRUM_NAME | | |
| BEAT_NAGA_SECRET_3 | Setelah raja palsu tersingkap, bawa dia padaku. Aku akan di tepi air, dengan dua cangkir. | Once the false king is unmasked, bring him to me. I'll be at the water's edge, with two cups. |
| @ | | |
| BEAT_NAGA_SECRET_4 | Ciung menoleh dari jalan timur, curiga pada bisikan yang tak sampai ke telinganya. | Ciung looks back from the east road, wary of whispers that didn't reach his ears. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_NAGA_SECRET_5 | Apa yang kalian bisikkan? Sudahlah. Galuh menunggu, dan aku tak punya telinga untuk rahasia. | What are you two whispering? Never mind. Galuh is waiting, and I've no ear for secrets. |
| @ | | |
| BEAT_NAGA_SECRET_6 | Anak ayam jantan di bahunya berkokok sekali, galak, setuju. | The rooster chick on his shoulder crows once, fierce, in agreement. |
| @NPC_NAGANINGRUM_NAME | | |
| BEAT_NAGA_SECRET_7 | Hati-hati, Nak. Kalian berdua. | Be careful, child. Both of you. |

### Camp talk `camp_sunda` (ciung_wanara entries; cond `flag:mq1_9`, `zone:ts_situ`, `"quiet": true`; do `flag:camp_sunda`; at the lake after Sangkuriang). One entry per Choice 1 branch, then the hub `CH`. These come after the prologue entries `P1` and `P2` and before the Act II entries
| Entry | if | do |
|-------|----|----|
| CS-keep | `flag:mq1_9`, `flag:choice_keep_secret`, `zone:ts_situ`, `"quiet": true` | `flag:camp_sunda` |
| CS-tell | `flag:mq1_9`, `flag:choice_tell_ciung`, `zone:ts_situ`, `"quiet": true` | `flag:camp_sunda` |
| CH | `flag:camp_sunda`, `zone:ts_situ`, `"hub": true`, `"quiet": true` | |
| T:ask_egg | `"topic": "ask_egg"`, `"quiet": true` | |
| T:ask_anger | `"topic": "ask_anger"`, `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| CS-keep | @NPC_CIUNG_WANARA_NAME | | |
| CS-keep | DLG_CIUNG_WANARA_V110 | Kau diam sepanjang jalan dari kawah. Biasanya kau cerewet seperti adikmu. | You were quiet the whole way down from the crater. You're usually chatty, like your sister. |
| CS-keep | @NPC_HERO_NAME | | |
| CS-keep | DLG_CIUNG_WANARA_H110 | Kau terlihat lega, bukan marah. | You look relieved, not angry. |
| CS-keep | @NPC_CIUNG_WANARA_NAME | | |
| CS-keep | DLG_CIUNG_WANARA_V111 | Lega, ya. Rantainya hilang, dan aku tahu siapa yang memburuku. Tapi lega tak mengenyangkan. | Relieved, yes. The chains are gone, and I know who's hunting me. But relief doesn't fill the stomach. |
| CS-keep | DLG_CIUNG_WANARA_V35 | Marahku belum reda. Ada yang kuambil kembali, tapi bukan semuanya. | My anger hasn't faded. I took something back, but not everything. |
| CS-keep | DLG_CIUNG_WANARA_V36 | Perempuan di tepi danau itu menatapku tadi. Aku tak tahu kenapa aku merasa harus menunduk. | The woman by the lake looked at me just now. I don't know why I felt I should bow my head. |
| CS-keep | @NPC_HERO_NAME | | |
| CS-keep | DLG_CIUNG_WANARA_H4 | Kau akan tahu pada waktunya. | You'll know in time. |
| CS-keep | @NPC_CIUNG_WANARA_NAME | | |
| CS-keep | DLG_CIUNG_WANARA_V37 | Kau tahu sesuatu, kan? Baiklah. Aku bisa menunggu. | You know something, don't you? Fine. I can wait. |
| CS-keep | DLG_CIUNG_WANARA_V112 | Anak ayam ini mematukku kalau aku melamun. Dia mau jalan terus, ke Galuh. Aku setuju. | This chick pecks me when I daydream. He wants to keep walking, to Galuh. I agree. |
| CS-tell | @NPC_CIUNG_WANARA_NAME | | |
| CS-tell | DLG_CIUNG_WANARA_V113 | Aku belum tahu harus memanggilnya apa. Ibu... rasanya masih seperti memanggil bayangan. | I don't know what to call her yet. Ibu... it still feels like calling a shadow. |
| CS-tell | @NPC_HERO_NAME | | |
| CS-tell | DLG_CIUNG_WANARA_H111 | Panggil saja sesukamu. Dia sabar. | Call her whatever you like. She's patient. |
| CS-tell | @NPC_CIUNG_WANARA_NAME | | |
| CS-tell | DLG_CIUNG_WANARA_V114 | Dia menuang teh, dan aku tak bisa meminumnya. Tanganku gemetar. Lucu, padahal aku baru mengalahkan raksasa. | She poured tea, and I couldn't drink it. My hands shook. Funny, after beating a giant. |
| CS-tell | @NPC_HERO_NAME | | |
| CS-tell | DLG_CIUNG_WANARA_H112 | Kau tidak mengalahkannya. Fajar palsu yang melakukannya. | You didn't beat him. The false dawn did. |
| CS-tell | @NPC_CIUNG_WANARA_NAME | | |
| CS-tell | DLG_CIUNG_WANARA_V115 | Diam kau, penulis. | Quiet, writer. |
| CS-tell | DLG_CIUNG_WANARA_V116 | Lima belas tahun aku membenci siapa pun yang membuangku. Ternyata tak ada yang membuangku. | Fifteen years I hated whoever threw me away. It turns out nobody did. |
| CS-tell | DLG_CIUNG_WANARA_V117 | Sekarang marahku punya alamat: orang yang memakai wajah naga tua itu. Ke Galuh. Setelah itu aku kembali ke danau. | Now my anger has an address: the man wearing the old naga's face. To Galuh. After that I come back to the lake. |
| CH | @NPC_CIUNG_WANARA_NAME | | |
| CH | DLG_CIUNG_WANARA_V118 | Masih ada waktu sebelum kita jalan. Mau tanya apa? | There's still time before we move. What do you want to ask? |
| T:ask_egg | @NPC_CIUNG_WANARA_NAME | | |
| T:ask_egg | DLG_CIUNG_WANARA_V119 | Telur itu retak di tanganku, dan yang keluar anak ayam. Aku tak tahu telur apa yang menetas jadi ayam jantan. | The egg cracked in my hands and a chick came out. I don't know what kind of egg hatches a rooster. |
| T:ask_egg | DLG_CIUNG_WANARA_V120 | Katanya titipan. Sekarang titipan itu bernapas dan mematukku. Aku tak mau melepasnya. | They said it was left in my keeping. Now it breathes and pecks me. I won't let it go. |
| T:ask_egg | @NPC_HERO_NAME | | |
| T:ask_egg | DLG_CIUNG_WANARA_H113 | Sudah kauberi nama? | Have you named him? |
| T:ask_egg | @NPC_CIUNG_WANARA_NAME | | |
| T:ask_egg | DLG_CIUNG_WANARA_V121 | Belum. Nama itu bukan sesuatu yang kutentukan sendiri, kan? Laras bilang begitu. | Not yet. A name isn't something you decide alone, is it? Laras says so. |
| T:ask_anger | @NPC_CIUNG_WANARA_NAME | | |
| T:ask_anger | DLG_CIUNG_WANARA_V122 | Marah itu hangat. Kalau dilepas, dingin, seperti telur. | Anger is warm. Let go of it and it goes cold, like the egg. |
| T:ask_anger | DLG_CIUNG_WANARA_V123 | Aku tak takut kehilangan marahku. Aku takut kehilangan alasan untuk terus berjalan. | I'm not afraid of losing my anger. I'm afraid of losing a reason to keep walking. |
| T:ask_anger | @NPC_HERO_NAME | | |
| T:ask_anger | DLG_CIUNG_WANARA_H114 | Alasanmu sudah banyak sekarang. | You have plenty of reasons now. |
| T:ask_anger | @NPC_CIUNG_WANARA_NAME | | |
| T:ask_anger | DLG_CIUNG_WANARA_V124 | Kita lihat saja. | We'll see. |

Choices for the Ciung camp hub:
| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_CIUNG_WANARA_ASK_101 | Soal telur dan anak ayam itu. | About the egg and the chick. | `topic:ask_egg` |
| CHOICE_CIUNG_WANARA_ASK_102 | Soal marahmu. | About your anger. | `topic:ask_anger` |
| CHOICE_CIUNG_WANARA_ASK_103 | Ayo jalan. | Let's go. | |

## 7. Act II: Keraton Galuh (MQG, "Wajah Pinjaman")
**Lines in this section: 302** (ASSUMED budget, v5: at most 560). Talks 8-12 lines, beats 8-10, hub topics 3-6, clues 1-2 plus a note (v5 rules, quests.md 7.1).
Regional characters: Uwa Lengser (want: to say a secret aloud; turn: the queen's eyes; close: relief), Nyai Sekar (want: the scraped names kept somewhere safe; turn: the cipher opens; close: she stays and guards the door) and Ranga the Deserter (want: his wife's face; turn: the choice; close: his name and the cave mouth). Order of play: the square and Ciung's plan, Pasar Kuta and the riggers, the bouts, Lengser, the archive, the Kaputren, the cell yard, Laras chapter 2, Ranga and Choice 2, the grate and the gallery, Lengser's memory, the second mask fragment, the throne room.
Hub topic shape (quests.md 7.1 item 2), shown once here and used by every hub below: the hub entry carries `"hub": true, "quiet": true` and its `choices` end in `topic:<key>`; each topic is its own entry in the same file with `"topic": "<key>"` and `"quiet": true`; a choice with an empty `do` leaves. Topics never complete a step and never set a quest flag.

### Chapter 1: Tournament Day and Pasar Kuta (g.1-g.5)

### galuh_seller (kg_alun, the arrival slice; name NPC_GALUH_SELLER_NAME; step g.1 `talked_to`, sets `mqg_a1`)
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
| 1 | DLG_GALUH_SELLER_V5 | Hati-hati, Nak. Hari ini penjaga raja menghitung tiap kepala di gerbang, dan yang terlalu banyak bertanya mereka catat. | Careful, child. Today the king's guards count every head at the gate, and they note down the ones who ask too much. |
| 1 | DLG_GALUH_SELLER_V6 | Ayam-ayam itu bertarung di balik tembok, jauh dari mataku. Aku menjual anaknya, bukan menontonnya. | Those birds fight behind the wall, far from my eyes. I sell their chicks, I don't watch them. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_GALUH_SELLER_H2 | Itu pilihan yang bagus. Aku pun tak mau melihatnya. | A good choice. I don't want to see it either. |
| 1 | @NPC_GALUH_SELLER_NAME | | |
| 1 | DLG_GALUH_SELLER_V7 | Pemuda galak itu di gerbang timur lingkaran. Kalau mau kabar tentang apa yang masuk kota, tanya di Pasar Kuta, selatan sini. | Your scowler is at the ring's east gate. If you want word of what comes into the city, ask at Pasar Kuta, south of here. |
| 2 | DLG_GALUH_SELLER_V4 | Jago terbaik hari ini bukan daganganku. Itu milik pemuda galak itu. | The best bird today isn't mine. It belongs to that scowling young man. |

### ciung_wanara (kg_alun; name NPC_CIUNG_WANARA_NAME). Entry order for Acts II and III only; the prologue entries P1-P2 (section 5), the Act I camp talk (section 6), the Interlude and the Act VI entries come from the other fragments, in the order "later act first". Entries A3-1 and A2-1 to A2-7 go together in this order, after the Interlude entries and before the Act I and prologue entries
| Entry | if | do |
|-------|----|----|
| A3-1 | `quest:mq2=active` (Act III; he holds Galuh and waits for word of the river) | |
| A2-1 | `flag:mqg_4`, `!flag:mqg_7`, `zone:kg_keraton` (the camp talk at `galuh_1`, a hub: `"hub": true`, `"quiet": true`; closes once the king is unmasked, and the zone keeps it out of later acts) | `flag:camp_galuh` |
| A2-2 | `step:mqg=3`, `flag:mqg_1`, `!flag:mqg_2` (g.4, after bout 1) | |
| A2-3 | `step:mqg=3`, `!flag:mqg_1` (g.4, before the bouts) | |
| A2-4 | `step:mqg=1` (g.2, Pasar Kuta) | |
| A2-5 | `step:mqg=2` (g.3, the riggers) | |
| A2-6 | `step:mqg=0`, `flag:mqg_a1` (g.1, the plan; sets `mqg_0`) | |
| A2-7 | `quest:mqg=active` | |
| A2-8 | (none) | |

Hub choices of A2-1 (topics are the entries T1-T4 below): CHOICE_CIUNG_ASK_1 to `topic:ciung_mother`; CHOICE_CIUNG_ASK_2 to `topic:ciung_laras`; CHOICE_CIUNG_ASK_3 to `topic:ciung_throne`; CHOICE_CIUNG_ASK_4 leaves.

| Entry | Key | ID | EN |
|-------|-----|----|----|
| A3-1 | DLG_CIUNG_WANARA_V1 | Katanya putra sang permaisuri yang kita kurung sedang mengumpulkan pasukan. Saudaraku, rupanya. | They say the caged queen's son is raising an army. My brother, apparently. |
| A3-1 | DLG_CIUNG_WANARA_V260 | Galuh tenang sejak raja palsu dikurung. Terlalu tenang, kalau kau tanya aku. Orang lupa cara berebut, lalu ingat lagi. | Galuh is calm since the false king was caged. Too calm, if you ask me. People forget how to quarrel, then remember. |
| A3-1 | DLG_CIUNG_WANARA_V261 | Jalanmu ke timur, lewat sungai. Jangan jadi yang pertama menarik pedang di sana. | Your road goes east, over the river. Don't be the first to draw a sword there. |
| A2-1 | DLG_CIUNG_WANARA_V8 | Kupikir singgasana itu akan terasa seperti pulang. Nyatanya seperti baju kakak: kebesaran, dan bukan milikku. | I thought the throne would feel like coming home. It feels like a big brother's coat: too large, and not mine. |
| A2-1 | @NPC_HERO_NAME | | |
| A2-1 | DLG_CIUNG_WANARA_H3 | Lalu kenapa kau mau? | Then why take it? |
| A2-1 | @NPC_CIUNG_WANARA_NAME | | |
| A2-1 | DLG_CIUNG_WANARA_V262 | Aku belum mau. Tapi ada yang dicuri dariku, dan pencurinya duduk di sana sambil tersenyum. | I don't want it yet. But something was stolen from me, and the thief sits there smiling. |
| A2-1 | DLG_CIUNG_WANARA_V263 | Tanyalah apa saja, Penulis. Di taman ini kita aman, lampunya menyala. | Ask me anything, writer. We're safe in this garden, the lamps are lit. |
| T1 | DLG_CIUNG_WANARA_V264 | Perempuan di tepi danau itu. Kau tahu sesuatu, dan kau tak bilang. Atau memang tak ada yang perlu dibilang. | The woman by the lake. You know something and you won't say. Or there's nothing to say. |
| T1 | DLG_CIUNG_WANARA_V265 | Aku tak minta dikasihani. Aku cuma ingin tahu kenapa lututku lemas tiap dia menatapku. | I'm not asking for pity. I just want to know why my knees go weak when she looks at me. |
| T1 | DLG_CIUNG_WANARA_V266 | Kalau waktunya tiba, bilang saja. Tidak, jangan sekarang. Aku belum siap. | When the time comes, just tell me. No, not now. I'm not ready. |
| T1b | DLG_CIUNG_WANARA_V267 | Ibuku. Dewi Naganingrum. Kau mengatakannya di kawah dan aku masih belum tahu harus berbuat apa dengan kata itu. | My mother. Dewi Naganingrum. You said it at the crater and I still don't know what to do with the word. |
| T1b | DLG_CIUNG_WANARA_V268 | Aku menemuinya sebelum berangkat. Dia menepuk bahuku seolah aku masih kecil. Aku membiarkannya. | I saw her before I left. She patted my shoulder as if I were small. I let her. |
| T1b | DLG_CIUNG_WANARA_V269 | Dia mengirim penjaga danau untuk menemani kita. Katanya cuma pengantar bekal. Pengantar bekal yang membawa tombak. | She sent lake-wardens along. Said they only carry food. Food-carriers with spears. |
| T1b | DLG_CIUNG_WANARA_V270 | Aku akan membawakan Galuh padanya, utuh. Itu janji, bukan sumpah. Sumpah mudah dilanggar. | I'll bring Galuh to her, whole. That's a promise, not an oath. Oaths are easy to break. |
| T2 | DLG_CIUNG_WANARA_V271 | Adikmu. Aku melihatnya di kawah, dan dia membaca seperti orang yang menahan napas. | Your sister. I saw her at the crater, reading like someone holding her breath. |
| T2 | DLG_CIUNG_WANARA_V272 | Aku tak sempat membantu. Itu duri yang kubawa ke mana-mana. | I couldn't help. That's a thorn I carry everywhere. |
| T2 | DLG_CIUNG_WANARA_V273 | Dia anak yang membuat kucing menurut. Kalau ada yang bisa bertahan di tangan mereka, dia orangnya. | She's the girl who makes cats obey. If anyone can survive in their hands, it's her. |
| T3 | DLG_CIUNG_WANARA_V274 | Takhta. Aku sudah bilang, seperti baju kakak. Tapi baju tetap harus ada yang memakainya. | The throne. I said, like a big brother's coat. But somebody has to wear a coat. |
| T3 | DLG_CIUNG_WANARA_V275 | Raja palsu itu memakai wajah orang lain. Aku hanya mau memakai wajahku sendiri, apa pun yang tersisa. | The false king wears someone else's face. I only want to wear my own, whatever is left of it. |
| T3 | DLG_CIUNG_WANARA_V276 | Dan kalau Galuh tak mau aku? Maka aku pulang ke Desa Purwa dan makan teh Ibumu lagi. | And if Galuh doesn't want me? Then I go home to Desa Purwa and drink your mother's tea again. |
| A2-2 | DLG_CIUNG_WANARA_V4 | Satu babak lagi. Mereka di panggung kehormatan mulai gelisah. | One more bout. They're getting nervous up on the dais. |
| A2-2 | DLG_CIUNG_WANARA_V277 | Ayamku sehat, dan aku tak mau melihat apa yang terjadi di gelanggang. Kau cukup kalahkan yang curang. | My bird is fine, and I don't want to see what happens in the ring. You just beat the cheats. |
| A2-3 | DLG_CIUNG_WANARA_V278 | Dua babak, lalu raja menemui kita. Para pengatur taruhannya sudah kau bereskan, jadi arenanya bersih. | Two bouts, then the king has to see us. You dealt with his riggers, so the ring is clean. |
| A2-4 | DLG_CIUNG_WANARA_V279 | Pasar Kuta di selatan. Cari yang mau bicara dan daftar angkutan. Aku menunggu di sini. | Pasar Kuta is south. Find someone who'll talk, and the freight list. I'll wait here. |
| A2-5 | DLG_CIUNG_WANARA_V280 | Gudang itu sarang para pengatur sayembara. Bongkar mereka, baru kita ke gelanggang. | That storehouse is the riggers' nest. Break them, then we go to the ring. |
| A2-6 | @NPC_CIUNG_WANARA_NAME | | |
| A2-6 | DLG_CIUNG_WANARA_V281 | Kau datang juga. Aku bilang jangan menyusul, tapi sekarang aku punya dua pasang mata di kota ini. | You came after all. I said don't follow, but now I have two pairs of eyes in this city. |
| A2-6 | @NPC_HERO_NAME | | |
| A2-6 | DLG_CIUNG_WANARA_H1 | Lewat mana kita masuk? Gerbang istana dijaga ketat. | How do we get in? The palace gate is watched. |
| A2-6 | @NPC_CIUNG_WANARA_NAME | | |
| A2-6 | DLG_CIUNG_WANARA_V3 | Lewat sayembara raja. Ayamku bertarung di gelanggang, kau hajar siapa pun yang curang. | Through the king's tournament. My rooster fights in the ring, you thrash whoever cheats. |
| A2-6 | @NPC_HERO_NAME | | |
| A2-6 | DLG_CIUNG_WANARA_H2 | Aku tak menyentuh ayam. Dan aku tak bertaruh. | I don't touch roosters. And I don't bet. |
| A2-6 | @NPC_CIUNG_WANARA_NAME | | |
| A2-6 | DLG_CIUNG_WANARA_V7 | Siapa yang menyuruh? Ayam itu urusanku. Menangkan dua babak, dan raja terpaksa menemui kita. | Who asked you to? The bird's my business. Win two bouts and the king has to see us. |
| A2-6 | DLG_CIUNG_WANARA_V282 | Tapi ada yang janggal. Tawanan dari desa-desa dibawa lewat kota ini, dan tak seorang pun melihatnya. | But something is off. Captives from the villages are brought through this city, and nobody sees it. |
| A2-6 | @NPC_HERO_NAME | | |
| A2-6 | DLG_CIUNG_WANARA_H201 | Lewat gerbang? Di depan semua orang? | Through the gate? In front of everyone? |
| A2-6 | @NPC_CIUNG_WANARA_NAME | | |
| A2-6 | DLG_CIUNG_WANARA_V283 | Lewat Pasar Kuta, pasar luar di selatan alun-alun. Gudang-gudangnya melayani istana. Cari yang mau bicara dan lihat daftar angkutannya. | Through Pasar Kuta, the outer market south of the square. Its storehouses serve the palace. Find someone who talks and see the freight list. |
| A2-6 | DLG_CIUNG_WANARA_V284 | Dan awasi orang-orang yang mengatur taruhan sayembara. Kudengar mereka bekerja untuk raja, bukan untuk arena. | And watch the men who rig the tournament odds. I hear they work for the king, not the ring. |
| A2-6 | DLG_CIUNG_WANARA_V285 | Aku tunggu di gerbang timur lingkaran. Pergilah ke selatan dulu. | I'll wait at the ring's east gate. Go south first. |
| A2-7 | DLG_CIUNG_WANARA_V5 | Istana ini bau dupa tua dan dusta. | This palace smells of old incense and lies. |
| A2-8 | DLG_CIUNG_WANARA_V6 | Galuh akan punya raja yang adil. Suatu hari. | Galuh will have a fair king. Someday. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_CIUNG_ASK_1 | Tanya tentang ibunya | Ask about his mother | `topic:ciung_mother` |
| CHOICE_CIUNG_ASK_2 | Tanya tentang Laras | Ask about Laras | `topic:ciung_laras` |
| CHOICE_CIUNG_ASK_3 | Tanya tentang takhta | Ask about the throne | `topic:ciung_throne` |
| CHOICE_CIUNG_ASK_4 | Sudah cukup | That's enough | |

Topic entries of the A2-1 hub. T1 and T1b are both `"topic": "ciung_mother"`: T1b comes first (`flag:choice_tell_ciung`), T1 is the `flag:choice_keep_secret` / no-flag answer. `"topic": "ciung_laras"` is T2 and `"topic": "ciung_throne"` is T3; all `"quiet": true`.

| Entry | if | do |
|-------|----|----|
| T1b | `"topic": "ciung_mother"`, `flag:choice_tell_ciung` | |
| T1 | `"topic": "ciung_mother"` | |
| T2 | `"topic": "ciung_laras"` | |
| T3 | `"topic": "ciung_throne"` | |

### Beat `galuh_dais` (if `!flag:beat_galuh_dais`, `flag:mqg_0`, `zone:kg_alun`; do `flag:beat_galuh_dais`). g.1, the beat: the king is seen for the first time, and not yet named as anything but a smile
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_GALUH_DAIS_1 | Di panggung kehormatan, raja Galuh duduk di bawah payung emas. Para pembesar bersorak, dan ia tersenyum pada semuanya sekaligus. | On the dais the king of Galuh sits under a gold parasol. The nobles cheer, and he smiles at everyone at once. |
| BEAT_GALUH_DAIS_2 | Senyumnya tak bergeser sedikit pun saat sorak naik atau turun. Di sampingnya berdiri cermin perunggu setinggi manusia, ditutup kain. | His smile doesn't shift as the cheering rises or falls. Beside him stands a man-high bronze mirror, draped in cloth. |
| @NPC_HERO_NAME | | |
| BEAT_GALUH_DAIS_H1 | Siapa menutup cermin di hari pesta? | Who covers a mirror on a feast day? |
| @ | | |
| BEAT_GALUH_DAIS_3 | Seorang pelayan lewat membawa baki dan menjawab tanpa ditanya, matanya ke tanah. | A servant passes with a tray and answers unasked, eyes on the ground. |
| @NPC_GALUH_SELLER_NAME | | |
| BEAT_GALUH_DAIS_4 | Raja tak suka dilihat dua kali di cermin. Sudah lama begitu. Jangan tanya kenapa, Nak. | The king doesn't like to be seen twice in a mirror. It's been so a long time. Don't ask why, child. |
| @ | | |
| BEAT_GALUH_DAIS_5 | Di bawah panggung, para penjaga bertopeng halus berdiri berderet. Wajah mereka rata, dan tak seorang pun orang banyak memandangnya. | Below the dais guards in smooth masks stand in rows. Their faces are flat, and no one in the crowd looks at them. |
| @NPC_HERO_NAME | | |
| BEAT_GALUH_DAIS_H2 | Mereka semua melihat ke arah lain. Itu juga cara melihat. | Everyone looks away. That's also a way of looking. |
| @ | | |
| BEAT_GALUH_DAIS_6 | Di kerumunan, Ciung menunjuk ke selatan dengan dagunya. Pasar Kuta. | In the crowd Ciung jerks his chin south. Pasar Kuta. |

### pasar_informant (kg_pasar; name NPC_PASAR_INFORMANT_NAME; new). Step g.2 `talked_to`, then the clue; step g.3 the talk after the riggers
| Entry | if | do |
|-------|----|----|
| 1a | `flag:pasar_briefed`, `!flag:clue_wagon_manifest` (a repeat visit before the manifest is read) | |
| 1 | `step:mqg=1` | `flag:pasar_briefed` |
| 2 | `flag:clue_wagon_manifest`, `!flag:mqg_p2` | |
| 3 | `flag:mqg_p2` | `codex:pasar_kuta` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1a | DLG_PASAR_INFORMANT_V15 | Gudang kedua di timur pasar, Nak. Cari daftar angkutan bulan ini, dan jangan berlama-lama di sana. | The second storehouse east of the market, child. Look for this month's freight list, and don't linger there. |
| 1 | @NPC_PASAR_INFORMANT_NAME | | |
| 1 | DLG_PASAR_INFORMANT_V1 | Pelan, pelan. Di Pasar Kuta telinga lebih banyak daripada dagangan. Kau teman si pemuda galak, ya? Dia sudah dua kali bertanya soal pedati. | Slowly now. At Pasar Kuta there are more ears than goods. You're the scowler's friend? He's asked about the wagons twice already. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PASAR_INFORMANT_H1 | Pedati apa? | What wagons? |
| 1 | @NPC_PASAR_INFORMANT_NAME | | |
| 1 | DLG_PASAR_INFORMANT_V2 | Pedati beratap kain, lewat gerbang selatan di malam bulan gelap. Penjaga tak memeriksanya. Mereka cuma melirik segel di kayunya. | Cloth-roofed wagons, through the south gate on dark-moon nights. The guards never search them. They just glance at the seal on the wood. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PASAR_INFORMANT_H2 | Segel siapa? | Whose seal? |
| 1 | @NPC_PASAR_INFORMANT_NAME | | |
| 1 | DLG_PASAR_INFORMANT_V3 | Segel raja. Lilin merahnya selalu masih basah. Katanya isinya pelayan baru untuk istana. | The king's seal. The red wax is always still wet. They say the load is new servants for the palace. |
| 1 | DLG_PASAR_INFORMANT_V4 | Pelayan baru yang tak bicara dan tak makan. Aku jual kabar, Nak, bukan nyawa. Aku tak mau tahu lebih banyak. | New servants who don't speak or eat. I sell news, child, not my neck. I don't want to know more. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PASAR_INFORMANT_H3 | Di mana aku bisa melihat catatannya? | Where can I see the records? |
| 1 | @NPC_PASAR_INFORMANT_NAME | | |
| 1 | DLG_PASAR_INFORMANT_V5 | Gudang kedua di timur pasar. Juru catatnya tak bisa menulis bohong, cuma malas menulis lengkap. Cari daftar angkutan bulan ini. | The second storehouse east of the market. Its clerk can't write lies, only lazily. Look for this month's freight list. |
| 1 | DLG_PASAR_INFORMANT_V6 | Dan jangan kembali lewat jalan yang sama. Pasar ini punya mata juga, bukan cuma telinga. | And don't come back the same way. This market has eyes too, not just ears. |
| 2 | @NPC_PASAR_INFORMANT_NAME | | |
| 2 | DLG_PASAR_INFORMANT_V7 | Kau sudah melihat daftarnya? Pantas wajahmu begitu. Aku sendiri tak berani membacanya sampai habis. | You've seen the list? That explains your face. I never dared read it to the end. |
| 2 | DLG_PASAR_INFORMANT_V8 | Ada satu hal lagi. Gudang itu bukan cuma tempat catatan. Pengatur sayembara raja bersembunyi di dalamnya, orang-orang berseragam bersih. | One more thing. That storehouse isn't only for records. The king's tournament riggers hide in it, men in clean uniforms. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_PASAR_INFORMANT_H4 | Mereka mengatur siapa yang menang? | They decide who wins? |
| 2 | @NPC_PASAR_INFORMANT_NAME | | |
| 2 | DLG_PASAR_INFORMANT_V9 | Siapa yang menang, siapa yang kalah, siapa yang hilang setelahnya. Satu kantong taruhan, satu nama dicoret. | Who wins, who loses, who vanishes afterward. One purse of bets, one name struck off. |
| 2 | DLG_PASAR_INFORMANT_V10 | Kalau kau bongkar mereka, pintu gelanggang terbuka tanpa dicurangi. Hati-hati, mereka tak suka diganggu. | If you break them, the ring opens without a thumb on the scale. Careful, they hate being disturbed. |
| 3 | @NPC_PASAR_INFORMANT_NAME | | |
| 3 | DLG_PASAR_INFORMANT_V11 | Suara itu... gudangnya sepi. Kau benar-benar membersihkannya. Para pedagang berani membuka lapak lagi. | That sound... the storehouse is quiet. You really cleaned it out. The traders dare to open stalls again. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_PASAR_INFORMANT_H5 | Mereka membawa kantong taruhan bersegel. Segel yang sama dengan pedati. | They carried sealed purses. The same seal as the wagons. |
| 3 | @NPC_PASAR_INFORMANT_NAME | | |
| 3 | DLG_PASAR_INFORMANT_V12 | Maka satu tangan mengatur sayembara dan pedati. Jangan sebut tangan itu keras-keras di sini. | So one hand runs both the tournament and the wagons. Don't say whose hand out loud here. |
| 3 | DLG_PASAR_INFORMANT_V13 | Pergilah ke gelanggang. Menangkan dua babak, dan raja harus membuka pintu istananya. Pasar ini berhutang padamu. | Go to the ring. Win both bouts and the king must open his palace door. This market owes you. |
| 4 | DLG_PASAR_INFORMANT_V14 | Pasar Kuta kembali bising. Itu kabar baik, buat orang yang jual kabar. | Pasar Kuta is loud again. Good news, for a seller of news. |

### Clue `wagon_manifest` (step g.2; the manifest in the storehouse; sets `mqg_p1`; hunt `k_ii`, ASSUMED: all Act II person-boss clues share it)
| Key | ID | EN |
|-----|----|----|
| CLUE_WAGON_MANIFEST_1 | Daftar angkutan gudang. Tiap bulan gelap: "pelayan baru, empat belas", lalu cap lilin raja. Tak ada nama, hanya hitungan. | The storehouse freight list. Each dark moon: "new servants, fourteen", then the king's wax. No names, only counts. |
| CLUE_WAGON_MANIFEST_2 | Pedati yang membawa orang diperlakukan seperti karung beras, dan tak seorang pun menandai nama yang dibawanya. | The wagons carrying people are logged like rice sacks, and no one marks the names they carry. |
| CLUE_WAGON_MANIFEST_NOTE | Daftar angkutan Pasar Kuta: "pelayan baru", disegel lilin raja. | The Pasar Kuta freight list: "new servants", sealed with the king's wax. |

### Chapter 1, continued: the bouts and the old chamberlain (g.4-g.5)

### Beat `galuh_bout` (if `!flag:beat_galuh_bout`, `flag:mqg_2`; do `flag:beat_galuh_bout`, `codex:ciung_wanara`). Lengser's hint stays unnamed: Ciung must not learn who the queen was. The rooster stays off-screen
| Key | ID | EN |
|-----|----|----|
| BEAT_GALUH_BOUT_1 | Sorak membahana dari gelanggang di balik tembok. Ayam Ciung Wanara menang. Kau tak melihatnya, hanya mendengar. Tugasmu cuma menghajar yang curang. | A roar goes up from the ring behind the wall. Ciung Wanara's rooster has won. You didn't see it, only heard it. Your job was the cheats. |
| BEAT_GALUH_BOUT_4 | Dua babak selesai, dan tak satu pun taruhan dicurangi. Di panggung kehormatan, raja bertepuk dengan jeda yang terlambat setengah napas. | Two bouts done, and not one wager rigged. On the dais the king claps, half a breath too late. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_GALUH_BOUT_5 | Mereka bilang pemenang boleh menghadap. Kau lihat wajah raja dari dekat? Tidak berkedip, seperti patung. | They say the winner may petition. Did you see the king's face up close? Not a blink, like a statue. |
| @NPC_LENGSER_NAME | | |
| BEAT_GALUH_BOUT_2 | Mata itu... mata seorang ratu yang pernah kukenal. Temui aku, kalian berdua, diam-diam. Dan jangan tersenyum. | Those eyes... the eyes of a queen I used to know. Come and see me, both of you, quietly. And don't smile. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_GALUH_BOUT_3 | Kakek itu menatapku seperti melihat hantu. | The old man looked at me like he'd seen a ghost. |
| @NPC_HERO_NAME | | |
| BEAT_GALUH_BOUT_H1 | Mungkin bukan hantu. Mungkin dia melihat seseorang yang dulu dia sayangi. | Maybe not a ghost. Maybe he saw someone he once loved. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_GALUH_BOUT_6 | Aku tak suka ditatap seperti itu. Tapi pergilah, dengar apa katanya. Aku jaga alun-alun. | I don't like being looked at like that. But go and hear him out. I'll hold the square. |

### lengser (kg_alun, cond `flag:mqg_2`; name NPC_LENGSER_NAME). Step g.5 `talked_to`, sets `mqg_3`; the hub is entry 4
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `step:mqg=4`, `!flag:mqg_3` (g.5) | `codex:lengser` | |
| 2 | `flag:choice_freed`, `!flag:lengser_ack` | `flag:lengser_ack` | |
| 3 | `flag:choice_handed`, `!flag:lengser_ack` | `flag:lengser_ack` | |
| 4 | `flag:mqg_3`, `!flag:mqg_7` (a hub: `"hub": true`, `"quiet": true`) | | CHOICE_LENGSER_ASK_1 to `topic:lengser_secret`; CHOICE_LENGSER_ASK_2 to `topic:lengser_palace`; CHOICE_LENGSER_ASK_3 to `topic:lengser_king`; CHOICE_LENGSER_ASK_4 leaves |
| 5 | `quest:mqg=active` | | |
| 6 | (none) | | |
| T1 | `"topic": "lengser_secret"`, `"quiet": true` | | |
| T2 | `"topic": "lengser_palace"`, `"quiet": true` | | |
| T3 | `"topic": "lengser_king"`, `"quiet": true` | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_LENGSER_V1 | Jangan menoleh. Aku Uwa Lengser, abdi di sini sejak raja yang sah masih bujang. Lima belas tahun kusimpan satu rahasia, dan lututku sudah tak sanggup menanggungnya. | Don't turn around. I'm Uwa Lengser, I've served here since the true king was a bachelor. Fifteen years I've kept one secret, and my knees can't carry it anymore. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LENGSER_H1 | Orang-orang yang diculik, Uwa. Dibawa ke mana? | The taken, Uwa. Where are they kept? |
| 1 | @NPC_LENGSER_NAME | | |
| 1 | DLG_LENGSER_V201 | Lewat gerbang sel, malam hari, di bawah segel raja. Tak seorang pun keluar lagi. Tapi sebelum sel, ada tiga tempat yang harus kau lihat. | In through the cell gate at night, under the king's seal. No one comes out again. But before the cells, there are three places you must see. |
| 1 | DLG_LENGSER_V202 | Balai Pustaka, tempat naskah kerajaan. Kaputren, tempat para perempuan istana. Dan halaman penjara. Ketiganya menyimpan separuh jawaban. | The Balai Pustaka, where the royal manuscripts are. The Kaputren, where the palace women live. And the prison yard. Each holds half an answer. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LENGSER_H201 | Adikku pernah di salah satunya? | Was my sister in one of them? |
| 1 | @NPC_LENGSER_NAME | | |
| 1 | DLG_LENGSER_V203 | Seorang gadis kecil dengan lontar dibawa lewat pasar tiga malam lalu. Kaputren menampungnya dulu. Dayang-dayang yang bercerita. | A small girl with a lontar was brought through the market three nights ago. The Kaputren took her first. The attendants told me. |
| 1 | DLG_LENGSER_V204 | Pelataran dalam kubukakan; di tamannya ada petilasan tua, istirahatlah di sana. Lalu cari Nyai Sekar, juru arsip, di Balai Pustaka. Jangan tersenyum. | I'll open the inner courtyard; its garden has an old petilasan, rest there. Then find Nyai Sekar, the archivist, at the Balai Pustaka. Don't smile. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LENGSER_H202 | Kenapa jangan tersenyum? | Why not smile? |
| 1 | @NPC_LENGSER_NAME | | |
| 1 | DLG_LENGSER_V205 | Senyum itu mahal di sini. Raja menghitung siapa yang tersenyum padanya, dan siapa yang tersenyum saat ia lewat. | Smiles are costly here. The king counts who smiles at him, and who smiles when he passes. |
| 1 | DLG_LENGSER_V206 | Pergilah, Nak. Lututku akan bilang kapan aku harus berhenti bicara. Sekarang waktunya. | Go, child. My knees will tell me when to stop talking. That time is now. |
| 2 | DLG_LENGSER_V5 | Pembelot itu kau lepaskan? Hm. Ampun itu kebiasaan raja. Hati-hati, menular. | You let that deserter go? Hm. Mercy is a king's habit. Careful, it's catching. |
| 2 | DLG_LENGSER_V207 | Aku tidak menyalahkanmu. Aku pernah membiarkan seorang ratu pergi, dan Galuh masih berdiri. | I don't blame you. I once let a queen go, and Galuh still stands. |
| 3 | DLG_LENGSER_V6 | Pembelotmu sudah kenyang dan terkunci. Galuh akan mengadilinya dengan adil. Aku yang jamin. | Your deserter is fed and locked up. Galuh will judge him fairly. I'll see to it. |
| 3 | DLG_LENGSER_V208 | Ia menggambar denah di lantai sel dengan arang. Orang yang lupa nama masih ingat lorong. | He drew a plan on the cell floor in charcoal. A man who forgot his name still remembers corridors. |
| 4 | DLG_LENGSER_V209 | Kau datang lagi, Nak. Duduklah, kalau lututmu sekuat lututku, yaitu tidak. Mau bertanya apa? | You're back, child. Sit, if your knees are as strong as mine, which is to say not at all. What would you ask? |
| T1 | DLG_LENGSER_V210 | Rahasia itu? Di malam raja yang sah pergi bertapa, kuambil ratunya dari sini sebelum tengah malam. | The secret? The night the true king left to be a hermit, I took his queen out of here before midnight. |
| T1 | DLG_LENGSER_V211 | Seorang pelayan tua dengan baki teh, dan seorang perempuan di bawah kain tenun. Tak seorang pun menghentikan baki teh. | An old servant with a tea tray, and a woman under a woven cloth. Nobody stops a tea tray. |
| T1 | DLG_LENGSER_V212 | Aku tak pernah melihatnya lagi. Lalu hari ini, mata yang sama berdiri di gelanggang. Lututku tahu lebih dulu dariku. | I never saw her again. Then today the same eyes stand in the ring. My knees knew before I did. |
| T2 | DLG_LENGSER_V213 | Istana ini punya tiga sayap yang kuhafal. Balai Pustaka punya naskah. Kaputren punya telinga. Penjara punya yang hilang. | This palace has three wings I know by heart. The Balai Pustaka has records. The Kaputren has ears. The prison has the lost. |
| T2 | DLG_LENGSER_V214 | Para dayang tak pernah dihitung penjaga. Itu sebabnya mereka tahu lebih banyak daripada para menteri. | The attendants are never counted by the guards. That's why they know more than the ministers. |
| T2 | DLG_LENGSER_V215 | Kalau tersesat, ikuti bau dupa yang paling tua. Itu selalu jalan ke arsip. | If you get lost, follow the oldest smell of incense. It always leads to the archive. |
| T3 | DLG_LENGSER_V216 | Rajanya? Aku melayaninya lima belas tahun dan tak pernah melihatnya makan, minum, atau menguap. | The king? I served him fifteen years and never saw him eat, drink or yawn. |
| T3 | DLG_LENGSER_V217 | Dia menyuruh semua cermin ditutup. Dia bilang cahaya merusak lukisan. Tak ada lukisan di dekat cermin itu. | He ordered every mirror covered. He said light spoils the paintings. There are no paintings near those mirrors. |
| T3 | DLG_LENGSER_V218 | Kau pikir aku sudah gila. Aku hanya terlalu lama memperhatikan. | You think I've gone mad. I've only paid attention too long. |
| 5 | DLG_LENGSER_V7 | Pelan-pelan. Penjaga di sini menghitung jarinya sendiri pun salah, tapi tetap saja. | Quietly. The guards here can't count their own fingers, but still. |
| 6 | DLG_LENGSER_V8 | Galuh bernapas lega. Lututku juga. | Galuh breathes easier. So do my knees. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_LENGSER_ASK_1 | Tanya tentang rahasianya | Ask about his secret | `topic:lengser_secret` |
| CHOICE_LENGSER_ASK_2 | Tanya tentang ketiga sayap istana | Ask about the three wings | `topic:lengser_palace` |
| CHOICE_LENGSER_ASK_3 | Tanya tentang sang raja | Ask about the king | `topic:lengser_king` |
| CHOICE_LENGSER_ASK_4 | Cukup, Uwa | That's enough, Uwa | |

### Chapter 2: The Royal Archive and the Kaputren (g.6-g.10)

### nyai_sekar (kg_pustaka; name NPC_NYAI_SEKAR_NAME; new). Step g.6 `talked_to`, sets `mqg_ar1`; the hub is entry 4
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `step:mqg=5`, `!flag:mqg_ar1` | `codex:nyai_sekar` | |
| 2 | `flag:mqg_ar1`, `!flag:mqg_ar2` | | |
| 3 | `flag:mqg_ar2`, `!flag:sekar_ack` | `flag:sekar_ack` | |
| 4 | `flag:sekar_ack` (a hub: `"hub": true`, `"quiet": true`) | | CHOICE_SEKAR_ASK_1 to `topic:sekar_scrape`; CHOICE_SEKAR_ASK_2 to `topic:sekar_laras`; CHOICE_SEKAR_ASK_3 to `topic:sekar_lamps`; CHOICE_SEKAR_ASK_4 leaves |
| 5 | (none) | | |
| T1 | `"topic": "sekar_scrape"`, `"quiet": true` | | |
| T2 | `"topic": "sekar_laras"`, `"quiet": true` | | |
| T3 | `"topic": "sekar_lamps"`, `"quiet": true` | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_NYAI_SEKAR_NAME | | |
| 1 | DLG_NYAI_SEKAR_V1 | Berhenti. Kaki yang berat dan napas yang ditahan: kau bukan penjaga. Penjaga tak pernah menutup pintu pelan-pelan. | Stop. Heavy feet and held breath: you're no guard. Guards never close a door gently. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_NYAI_SEKAR_H1 | Uwa Lengser yang menyuruhku. Katanya, jangan tersenyum. | Uwa Lengser sent me. He said not to smile. |
| 1 | @NPC_NYAI_SEKAR_NAME | | |
| 1 | DLG_NYAI_SEKAR_V2 | Lengser. Orang tua itu masih hidup. Aku Nyai Sekar, juru arsip Balai Pustaka. Tiga puluh tahun kuurus naskah yang tak boleh dibaca siapa pun. | Lengser. That old man still lives. I am Nyai Sekar, archivist of the Balai Pustaka. Thirty years I've kept manuscripts no one may read. |
| 1 | DLG_NYAI_SEKAR_V3 | Penjaga di aula itu bukan penjaga lama. Bertopeng, dan buta huruf. Terima kasih sudah menyingkirkan mereka, aku tak sanggup. | The guards in that hall weren't the old guards. Masked, and unable to read. Thank you for clearing them, I couldn't. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_NYAI_SEKAR_H2 | Mereka dikirim untuk menjaga arsip, tapi tak bisa membacanya? | They were sent to guard the archive but can't read it? |
| 1 | @NPC_NYAI_SEKAR_NAME | | |
| 1 | DLG_NYAI_SEKAR_V4 | Mereka dikirim supaya tak ada yang membacanya. Lima belas tahun lalu seseorang menyuruhku mengerik silsilah raja dari tiga puluh gulung lontar. | They were sent so that no one would read it. Fifteen years ago someone had me scrape the king's lineage off thirty rolls of lontar. |
| 1 | DLG_NYAI_SEKAR_V5 | Aku mengerik semuanya, lalu menyimpan serpihannya. Tinta masuk ke serat daun, Nak. Yang dikerik tak pernah sungguh hilang. | I scraped every one, then kept the shavings. Ink sinks into the leaf fibre, child. What's scraped is never truly gone. |
| 1 | DLG_NYAI_SEKAR_V6 | Bayangannya masih ada, dan cahaya lampu yang dipantulkan cermin bisa menampakkannya. Sandi itu kubuat sendiri, di aula tengah. | The shadow is still there, and lamplight bounced off a mirror can raise it. I built that cipher myself, in the central hall. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_NYAI_SEKAR_H3 | Bagaimana cara membukanya? | How do I open it? |
| 1 | @NPC_NYAI_SEKAR_NAME | | |
| 1 | DLG_NYAI_SEKAR_V7 | Putar cermin-cermin perunggu sampai garis cahaya dari lampu pertama menyentuh meja. Pelan. Yang terburu-buru menampakkan bayangan yang salah. | Turn the bronze mirrors until the line of light from the first lamp touches the table. Slowly. The hasty raise the wrong shadow. |
| 2 | DLG_NYAI_SEKAR_V8 | Cermin dulu, lalu meja. Lampu tak pernah bohong, tapi tangan sering. | Mirrors first, then the table. Lamps never lie, but hands often do. |
| 3 | @NPC_NYAI_SEKAR_NAME | | |
| 3 | DLG_NYAI_SEKAR_V9 | Kau melihatnya. Nama itu, dan garis keturunannya yang dikerik. Sudah lama tak kulihat dengan mata telanjang. | You saw it. That name, and its scraped lineage. I haven't seen it with bare eyes in a long time. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_NYAI_SEKAR_H4 | Nagawiru. Naga di danau itu pernah menjadi raja Galuh. | Nagawiru. The naga in the lake was once the king of Galuh. |
| 3 | @NPC_NYAI_SEKAR_NAME | | |
| 3 | DLG_NYAI_SEKAR_V10 | Dan segel kedua dari empat segel, tentang nama raja itu, retak persis pada goresan pertama yang kulakukan. Aku mengerjakan retakan itu dengan tanganku sendiri. | And the second of the four seals, the one about that king's name, cracked on the first scrape I made. I cut that crack with my own hand. |
| 3 | DLG_NYAI_SEKAR_V11 | Aku tak minta diampuni. Aku minta kau menuliskannya kembali, suatu hari. Sekarang pergilah ke Kaputren, lewat serambi di selatan. | I'm not asking to be forgiven. I'm asking you to write it back, one day. Now go to the Kaputren, through the colonnade to the south. |
| 3 | DLG_NYAI_SEKAR_V12 | Adikmu dibawa lewat pelataranku. Dia melihat lampu-lampu itu lama sekali. Lihatlah kamar tamu di sana. | Your sister was brought through my yard. She looked at those lamps for a long time. See the guest chamber there. |
| 4 | DLG_NYAI_SEKAR_V13 | Duduklah di antara gulungan. Kalau mau bertanya, aku punya waktu. Raja tak menengok arsip, sudah lima belas tahun. | Sit among the rolls. If you want to ask, I have time. The king hasn't visited the archive in fifteen years. |
| T1 | DLG_NYAI_SEKAR_V14 | Mengerik itu pekerjaan sunyi. Kau duduk berhari-hari dan menyapu serpihan nama ke dalam wadah. | Scraping is quiet work. You sit for days and sweep the shavings of names into a jar. |
| T1 | DLG_NYAI_SEKAR_V15 | Aku menyimpan wadah itu di bawah meja tulis. Kadang kudengar bunyinya, seperti butiran garam yang mengeluh. | I keep that jar under the writing desk. Sometimes I hear it, like grains of salt complaining. |
| T1 | DLG_NYAI_SEKAR_V16 | Tak ada yang bertanya kenapa aku mau. Aku takut. Itu jawaban yang jelek, tapi benar. | No one asked why I agreed. I was afraid. A poor answer, but a true one. |
| T2 | DLG_NYAI_SEKAR_V17 | Gadis kecil itu lewat di pelataran dengan dua penjaga. Dia tak menangis. Dia menghitung lampu. | The little girl crossed my yard with two guards. She didn't cry. She counted the lamps. |
| T2 | DLG_NYAI_SEKAR_V18 | Pada lampu ketujuh dia menoleh ke jeruji saluran di sudut, lalu ke aku, seolah menanyakan sesuatu. | At the seventh lamp she looked at the drainage grate in the corner, then at me, as if asking something. |
| T2 | DLG_NYAI_SEKAR_V19 | Aku tak mengerti apa yang dia maksud. Mungkin kau akan mengerti. | I didn't understand what she meant. Perhaps you will. |
| T3 | DLG_NYAI_SEKAR_V20 | Lampu pertama menunjuk ke timur, ke arah kamar raja yang dulu. Lampu terakhir menunjuk ke barat, ke arah pasar. | The first lamp points east, toward the king's old chamber. The last points west, toward the market. |
| T3 | DLG_NYAI_SEKAR_V21 | Orang dulu menulis dengan cahaya supaya penjaga yang paling bodoh pun bisa melindunginya. Kau cukup melihat. | The old ones wrote with light so even the dullest guard could protect it. You only need to look. |
| T3 | DLG_NYAI_SEKAR_V22 | Kalau satu lampu padam, gulungan menggelap lagi. Jadi aku menyalakan semuanya tiap malam. | If one lamp dies, the rolls go dark again. So I light them all each night. |
| 5 | DLG_NYAI_SEKAR_V23 | Terus nyalakan lampunya. Itu satu-satunya hal yang bisa kulakukan. | Keep the lamps lit. It's the one thing I can do. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_SEKAR_ASK_1 | Tanya tentang kerikan itu | Ask about the scraping | `topic:sekar_scrape` |
| CHOICE_SEKAR_ASK_2 | Tanya tentang Laras | Ask about Laras | `topic:sekar_laras` |
| CHOICE_SEKAR_ASK_3 | Tanya tentang lampu-lampu | Ask about the lamps | `topic:sekar_lamps` |
| CHOICE_SEKAR_ASK_4 | Terima kasih, Nyai | Thank you, Nyai | |

### Clue `scraped_genealogy` (step g.7; the cipher's reveal; sets `mqg_ar2`; hunt `k_ii`)
| Key | ID | EN |
|-----|----|----|
| CLUE_SCRAPED_GENEALOGY_1 | Di bawah cahaya cermin, kerikan itu menyala: silsilah raja Galuh, dan satu nama yang dicungkil dari ujungnya. Nagawiru. | Under the mirror-light the scrapings glow: the lineage of Galuh's kings, and one name gouged from its end. Nagawiru. |
| CLUE_SCRAPED_GENEALOGY_2 | Orang yang mengerik tidak ingin nama itu dihapus. Ia ingin tak seorang pun mengingat siapa yang duduk di singgasana. | Whoever scraped it didn't only want the name gone. They wanted no one to remember who sits on the throne. |
| CLUE_SCRAPED_GENEALOGY_NOTE | Silsilah raja Galuh, dikerik, namanya Nagawiru. | The lineage of Galuh's kings, scraped; the missing name is Nagawiru. |

### Clue `kaputren_mirror` (step g.8; a covered mirror in the courtyard; journal note only; ASSUMED id, not in the zone doc; hunt `k_ii`)
| Key | ID | EN |
|-----|----|----|
| CLUE_KAPUTREN_MIRROR_1 | Cermin perunggu di serambi, ditutup kain beludru dan diikat tiga kali. Seseorang takut pada apa yang ada di dalamnya. | A bronze mirror in the colonnade, covered with velvet and tied three times. Someone fears what is in it. |
| CLUE_KAPUTREN_MIRROR_2 | Aku mengintip sedikit. Bayanganku menatap balik, dan untuk sesaat wajahnya bukan wajahku. | I peek under the edge. My reflection stares back, and for a moment its face is not mine. |
| CLUE_KAPUTREN_MIRROR_NOTE | Cermin tertutup di Kaputren, diikat tiga kali. | A covered mirror in the Kaputren, tied three times. |

### Clue `laras_hairpin` (step g.9; sets `mqg_kp2`; hunt `k_ii`)
| Key | ID | EN |
|-----|----|----|
| CLUE_LARAS_HAIRPIN_1 | Tusuk rambut kayu kecil di balik kain layar. Ujungnya digigit-gigit, kebiasaan Laras kalau berpikir. | A small wooden hairpin behind the silk screen, its end chewed, Laras's habit when she's thinking. |
| CLUE_LARAS_HAIRPIN_2 | Dia sengaja menjatuhkannya. Dia tahu aku akan mencari. | She dropped it on purpose. She knew I would come looking. |
| CLUE_LARAS_HAIRPIN_NOTE | Tusuk rambut Laras di kamar tamu Kaputren. | Laras's hairpin in the Kaputren guest chamber. |

### Beat `guest_chamber` (if `!flag:beat_guest_chamber`, `flag:mqg_kp2`, `zone:kg_kaputren`; do `flag:beat_guest_chamber`). g.9, the beat
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_GUEST_CHAMBER_1 | Kamar tamu itu rapi sekali, terlalu rapi: ranjang tak tersentuh, cermin dilepas dari dinding hingga tinggal bekas paku. | The guest chamber is tidy, too tidy: an untouched bed, the mirror taken off the wall until only nail holes remain. |
| BEAT_GUEST_CHAMBER_2 | Di sisi dalam kain layar, goresan kecil dengan ujung runcing: Ka, Ka, Ka, berderet seperti anak tangga. | On the inside of the silk screen, small scratches with a sharp tip: Ka, Ka, Ka, in a row like steps. |
| @NPC_HERO_NAME | | |
| BEAT_GUEST_CHAMBER_H1 | Dia berlatih. Dia tak menunggu diselamatkan. | She's practising. She isn't waiting to be rescued. |
| @ | | |
| BEAT_GUEST_CHAMBER_3 | Di bawah goresan itu, tulisan yang lebih kecil: "Mereka bilang aku tamu. Tamu boleh pulang. Aku tanya, kapan?" | Beneath the scratches, smaller writing: "They say I'm a guest. Guests may go home. I asked, when?" |
| BEAT_GUEST_CHAMBER_4 | Tak ada jawaban yang tertulis. Hanya goresan Ka terakhir, lebih dalam dari yang lain. | No answer is written. Only a last Ka, cut deeper than the others. |
| @NPC_HERO_NAME | | |
| BEAT_GUEST_CHAMBER_H2 | Pulang. Aku akan menulis itu sebagai jawabannya, di tempat yang bisa dia baca. | Home. I'll write that as the answer, somewhere she can read it. |
| @ | | |
| BEAT_GUEST_CHAMBER_5 | Dari balik serambi terdengar langkah sepatu tergesa dan suara perempuan yang cemas. | From beyond the colonnade comes the hurry of shoes and an anxious woman's voice. |
| @NPC_HERO_NAME | | |
| BEAT_GUEST_CHAMBER_H3 | Siapa pun itu, aku akan mendengarkan dulu. | Whoever that is, I'll listen first. |

### Beat `kaputren_overhear` (if `!flag:beat_kaputren_overhear`, `flag:mqg_kp3`, `zone:kg_kaputren`; do `flag:beat_kaputren_overhear`). g.10: Hariang Banga is seen and named here first (the tag counts as seeing); the king's name stays out of it
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_KAPUTREN_OVERHEAR_1 | Di balik layar sutra, seorang pemuda berbaju sutra berdiri di depan dua dayang tua. Tangannya terkepal, tapi suaranya lembut. | Behind a silk screen a young man in silk stands before two old attendants. His fists are tight, but his voice is gentle. |
| @NPC_DAYANG_RATU_NAME | | |
| BEAT_KAPUTREN_OVERHEAR_2 | Gusti Pangeran, Sang Ratu belum makan sejak kemarin. Katanya Baginda sudah lama tak menatap matanya. | Gusti Pangeran, the queen hasn't eaten since yesterday. She says His Majesty hasn't looked in her eyes for a long time. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_KAPUTREN_OVERHEAR_3 | Ibunda tak mau menjawab pertanyaanku. Aku bertanya kapan Baginda berubah, dan beliau hanya memandang cermin yang ditutup. | Mother won't answer my questions. I asked when His Majesty changed, and she only looked at the covered mirror. |
| @NPC_DAYANG_RATU_NAME | | |
| BEAT_KAPUTREN_OVERHEAR_4 | Cermin di kamar Baginda diangkut keluar lima belas tahun lalu, Gusti. Para tukang bilang bingkainya dingin sekali. | The mirror in His Majesty's chamber was carried out fifteen years ago, Gusti. The workmen said its frame was cold as ice. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_KAPUTREN_OVERHEAR_5 | Dan gadis kecil di kamar tamu? Penjaga bilang tamu raja, tapi tamu tak menulis di kain layar sampai jarinya berdarah. | And the girl in the guest chamber? The guards call her the king's guest, but guests don't write on screens until their fingers bleed. |
| @NPC_DAYANG_RATU_NAME | | |
| BEAT_KAPUTREN_OVERHEAR_6 | Pedati menunggu di halaman penjara, Gusti. Fajar nanti ia berangkat ke timur. Lorong ke sana dikunci, kuncinya pada Kapten. | The wagon waits in the prison yard, Gusti. It leaves for the east at dawn. The passage there is locked, the Captain has the key. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_KAPUTREN_OVERHEAR_7 | Aku tak tahu siapa memberi perintah itu. Kalau Baginda tahu, kenapa Ibunda gemetar? Kalau tidak tahu, siapa di istana ini yang memegang segelnya? | I don't know who gave that order. If His Majesty knows, why does Mother tremble? If he doesn't, who in this palace holds his seal? |
| @ | | |
| BEAT_KAPUTREN_OVERHEAR_8 | Mereka pergi. Satu dayang lupa menutup pintu samping, dan di baliknya terdengar rantai, besi, dan para pengawal bertopeng. | They leave. One attendant forgets to shut the side door, and beyond it come chains, iron, and the masked guards. |
| @NPC_HERO_NAME | | |
| BEAT_KAPUTREN_OVERHEAR_H1 | Satu pangeran yang tak tahu, dan satu pedati yang tahu. Kunci lorong itu ada pada orang bertopeng. | A prince who doesn't know, and a wagon that does. The key to that passage is with the masked. |

### Chapter 3: The Cell-Yard Ambush and Escape (g.11-g.15)

### Clue `wagon_ruts` (step g.11; on the cell stairs; journal note only; ASSUMED id, not in the zone doc; hunt `k_ii`)
| Key | ID | EN |
|-----|----|----|
| CLUE_WAGON_RUTS_1 | Bekas roda pedati di lantai tangga, dan secarik kain putih tersangkut paku. Kain kamar tamu Kaputren, bunga melatinya sama. | Wagon ruts on the stair floor and a scrap of white cloth snagged on a nail. The Kaputren guest chamber's cloth, same jasmine print. |
| CLUE_WAGON_RUTS_2 | Pedatinya belum lama lewat. Aku masih bisa mengejar. | The wagon passed not long ago. I can still catch it. |
| CLUE_WAGON_RUTS_NOTE | Bekas roda dan kain melati di tangga penjara. | Wheel ruts and jasmine cloth on the prison stairs. |

### Beat `galuh_escort` (if `!flag:beat_galuh_escort`, `flag:mqg_4b`; do `flag:beat_galuh_escort`). g.12, the near miss
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_GALUH_ESCORT_3 | Pedati beratap kain berderak di tengah halaman. Kusirnya orang lain, bertopeng halus, dan para pengawal merapat di sekelilingnya. | A cloth-roofed wagon rattles across the yard. Its driver is someone new, in a smooth mask, and the guards close in around it. |
| BEAT_GALUH_ESCORT_1 | Penjaga terakhir tumbang tepat saat pedati itu lolos dari gerbang. Sesuatu melayang dari balik tembok. | The last guard falls just as the wagon clears the gate. Something comes over the wall. |
| BEAT_GALUH_ESCORT_2 | Secarik lontar, dengan satu huruf goyah: Ka. Saat kau mendongak, pedati itu sudah hilang ke timur. | A strip of lontar, one shaky letter on it: Ka. When you look up, the wagon is gone east. |
| @NPC_HERO_NAME | | |
| BEAT_GALUH_ESCORT_H1 | Ka. Dia masih menulis, jadi dia masih Laras. | Ka. She's still writing, so she's still Laras. |
| @ | | |
| BEAT_GALUH_ESCORT_4 | Roda pedati menggilas sebuah papan lantai sampai terlepas. Papan itu tergeletak di debu, sisi bawahnya tergores. | A wheel grinds a floorboard loose. It lies in the dust, its underside scratched. |
| @NPC_HERO_NAME | | |
| BEAT_GALUH_ESCORT_H2 | Aku akan membacanya nanti. Sekarang, sel-sel di bawah sana. | I'll read that later. Now, the cells below. |
| @ | | |
| BEAT_GALUH_ESCORT_5 | Dari menara gerbang, sebuah terompet berbunyi dua kali. Pintu sel dalam dikunci dari dalam. | From the gate tower a horn sounds twice. The inner cell doors are bolted from within. |

### Clue `laras_wall` (step g.13; the wall message; pulls you into LC2, `memory_id` `lc2`; replaces `DLG_LARAS_WALL_H1`)
| Key | ID | EN |
|-----|----|----|
| CLUE_LARAS_WALL_1 | Di dinding sel, tulisan tangan Laras: "Seribu candi. Jangan berhenti." | On the cell wall, Laras's handwriting: "The thousand temples. Don't stop." |
| CLUE_LARAS_WALL_2 | Dia menulis ini untukku, bukan untuk dirinya. Lontarku bergetar dekat huruf-hurufnya. | She wrote this for me, not for herself. My lontar hums near the letters. |
| CLUE_LARAS_WALL_NOTE | Pesan Laras di dinding sel: "Seribu candi. Jangan berhenti." | Laras's message on the cell wall: "The thousand temples. Don't stop." |

### Laras chapter LC2 `lc2` (step g.14; kind chapter; Laras in the Kaputren guest chamber, then in the wagon with the Deserter driving; sets `mqg_lc`, `flag:laras_sabotage_glamour_seal` and `flag:laras_key_archive_grate`)
| Key | ID | EN |
|-----|----|----|
| LC_2_TITLE | Di Bawah Kain Kereta | Under the Wagon Cloth |
| @NPC_LARAS_NAME | | |
| LC2_6 | Kamar tamunya wangi melati dingin dan pintunya dikunci dari luar. Pintu bohong, tirai jujur. Aku periksa tirai dulu. | The guest chamber smells of cold jasmine and the door is locked from outside. Doors lie, curtains don't. I check the curtains first. |
| LC2_7 | Dayang tua yang membawakan air berbisik bahwa lilin segel raja ada di meja tulis. Katanya jangan sentuh. Tentu saja kusentuh. | The old attendant who brings water whispers that the king's sealing wax is on the writing desk. She says don't touch. Naturally I touch. |
| LC2_8 | Satu goresan Ka di lilin yang masih lunak. Sekarang segel yang disebut raja itu punya cacat yang hanya kulihat. Hehe. | One Ka scratched into the still-soft wax. Now the so-called king's seal has a flaw only I can see. Hehe. |
| LC2_9 | Jalan ke pedati melewati halaman arsip. Di sudutnya ada jeruji saluran dengan baut berkarat, dan penjaga yang separuh ingat namanya. | The way to the wagon crosses the archive yard. In its corner is a drainage grate with a rusted bolt, and a guard who half remembers his name. |
| LC2_10 | Kubisikkan namanya, "Rama", dan ia terhenti tiga tarikan napas. Cukup untuk menggeser baut. Kak, nanti lewat sini. | I whisper his name, "Rama", and he freezes for three breaths. Enough to slide the bolt. Kak, come this way later. |
| LC2_1 | Pedati ini bau jerami dan sedih. Pengemudinya bersenandung. Penjaga yang aneh. | This wagon smells of straw and sadness. The driver hums. Strange guard. |
| LC2_2 | Papan lantainya longgar. Kalau kugores pesan di baliknya, mungkin Kak menemukannya. | The floorboard is loose. If I scratch a message under it, maybe Kak will find it. |
| LC2_3 | Itu suara Kak! Di halaman, bertarung seperti banteng. Aku harus melempar sesuatu! | That's Kak! In the yard, fighting like a bull. I have to throw something! |
| LC2_4 | Kak, aku baik-baik saja. Bilang ke Ibu: jangan buang cangkirku yang gompal. | Kak, I'm fine. Tell Ibu: don't throw out my chipped cup. |
| LC2_5 | Pengemudiku ikut bersenandung waktu aku mengeja Ka. Dia pasti pernah punya nama bagus. | My driver hums along when I spell Ka. He must have had a good name once. |
(The board pickup: item `laras_board` is given when the chapter ends, ASSUMED.)

| Key | ID | EN |
|-----|----|----|
| DLG_BOARD_H1 | Papan lantai kereta, tergores tulisan Laras: "Bilang ke Ibu, jangan buang cangkirku yang gompal." | A wagon floorboard, scratched in Laras's hand: "Tell Ibu, don't throw out my chipped cup." |

### faceless_deserter (kg_penjara; name NPC_FACELESS_DESERTER_NAME until he says his name, then NPC_RANGA_NAME; step g.15, `talked_to`, sets `mqg_6`): Choice 2
Ranga drove Laras from the Kaputren to the cell yard, put down the reins when the fight began, and was dragged into a cell by the Captain. The wagon left under another driver.
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `step:mqg=14` (g.15) | `codex:ranga` | CHOICE_RANGA_1 to `flag:choice_freed`; CHOICE_RANGA_2 to `flag:choice_handed` |
| 2 | `flag:choice_freed` | | |
| 3 | `flag:choice_handed` | | |
| 4 | (none) | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_FACELESS_DESERTER_NAME | | |
| 1 | DLG_FACELESS_DESERTER_V1 | Jangan! Aku bukan... dulu aku tukang gerabah, rasanya. Aku lupa wajah istriku. | Don't! I'm not... I was a potter, I think. I can't remember my wife's face. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_FACELESS_DESERTER_H1 | Kau yang menjaga adikku. Katanya kau membiarkannya menyimpan separuh lontarnya. | You guarded my sister. She says you let her keep her half. |
| 1 | @NPC_FACELESS_DESERTER_NAME | | |
| 1 | DLG_FACELESS_DESERTER_V2 | Tiap malam dia mengeja Ka keras-keras, berulang-ulang. Aku ikut menggumam, dan suatu pagi aku punya satu suku kata namaku sendiri. | Every night she spelled Ka aloud, over and over. I hummed along, and one morning I had one syllable of my own. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_FACELESS_DESERTER_H201 | Suku kata apa? Dia pasti pernah bertanya namamu. | Which syllable? She must have asked your name. |
| 1 | @NPC_FACELESS_DESERTER_NAME | | |
| 1 | DLG_FACELESS_DESERTER_V201 | Dia bertanya tiap malam. "Ra," kataku, hanya itu. Lalu tadi pagi sisanya datang sendiri. Ranga. Aku Ranga. Kurasa. | She asked every night. "Ra," I said, only that. Then this morning the rest came on its own. Ranga. I'm Ranga. I think. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_FACELESS_DESERTER_H202 | Ranga. Kenapa kau di sel dan bukan di kursi pedati? | Ranga. Why are you in a cell and not on the wagon seat? |
| 1 | @NPC_RANGA_NAME | | |
| 1 | DLG_FACELESS_DESERTER_V202 | Waktu kau bertarung di halaman, kulepas tali kekang dan kukatakan aku tak mau lagi. Kapten menyeretku ke sini. Orang lain mengambil cambukku. | When you fought in the yard I let go of the reins and said I wouldn't go on. The Captain dragged me here. Someone else took my whip. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_FACELESS_DESERTER_H203 | Adikku, dia baik-baik saja? | My sister, is she all right? |
| 1 | @NPC_RANGA_NAME | | |
| 1 | DLG_FACELESS_DESERTER_V203 | Dia menulis di lantai pedati dan bernyanyi kecil. Dia tidak takut. Itu yang membuat kami takut. | She wrote on the wagon floor and sang quietly. She wasn't afraid. That's what scared us. |
| 1 | DLG_FACELESS_DESERTER_V3 | Tuan kami bicara dengan suara raja. Aku tak pernah bertanya. Aku cuma mengangkut yang sudah tanpa nama. Mau kau apakan aku? | Our master speaks with the king's voice. I never asked why. I only carried those already nameless. What will you do with me? |
| 2 | @NPC_RANGA_NAME | | |
| 2 | DLG_FACELESS_DESERTER_V4 | Aku pergi saat penjaga lengah. Terima kasih. | I'll go when the guards look away. Thank you. |
| 3 | @NPC_RANGA_NAME | | |
| 3 | DLG_FACELESS_DESERTER_V5 | Lengser, kalau begitu. Lebih baik daripada gelap. | Lengser, then. Better than the dark. |
| 4 | @NPC_FACELESS_DESERTER_NAME | | |
| 4 | DLG_FACELESS_DESERTER_V6 | Singkirkan mereka dulu! | Get them off me first! |

| Key | ID | EN |
|-----|----|----|
| CHOICE_RANGA_1 | Pergilah, Ranga. Carilah namamu dan wajah istrimu. | Go, Ranga. Find your name and your wife's face. |
| CHOICE_RANGA_2 | Uwa Lengser akan menjagamu dan mengadilimu. | Uwa Lengser will keep you safe, and judge you. |

### Beat `ranga_freed` (if `!flag:beat_ranga_freed`, `flag:choice_freed`; do `flag:beat_ranga_freed`). Choice 2, freed: the consequence plays at once
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_RANGA_FREED_1 | Pintu sel terayun terbuka. Ranga berdiri lama di ambangnya, seperti orang yang takut jalan di luar lebih berat daripada sel. | The cell door swings open. Ranga stands a long while on the threshold, like a man afraid the road is heavier than the cell. |
| @NPC_RANGA_NAME | | |
| BEAT_RANGA_FREED_2 | Kalau aku pergi, aku akan lupa lagi. Orang tanpa rupa lupa lebih cepat kalau berjalan sendirian. | If I go, I'll forget again. The faceless forget faster when they walk alone. |
| @NPC_HERO_NAME | | |
| BEAT_RANGA_FREED_H1 | Kalau begitu ucapkan namamu tiap malam. Adikku mengajarkan caranya, tanpa sengaja. | Then say your name every night. My sister taught you how, without meaning to. |
| @NPC_RANGA_NAME | | |
| BEAT_RANGA_FREED_3 | Ranga. Ranga. Ranga. Hm. Terdengar seperti nama orang yang punya istri. | Ranga. Ranga. Ranga. Hm. Sounds like the name of a man who has a wife. |
| BEAT_RANGA_FREED_4 | Aku akan ke timur, ke mana pun pedati itu lewat. Aku masih ingat jalannya, dan jalan itu masih mengingatku. | I'll go east, wherever that wagon passed. I still remember the road, and the road still remembers me. |
| @NPC_HERO_NAME | | |
| BEAT_RANGA_FREED_H2 | Kalau kau melihat sesuatu, kirim kabar. Aku akan ada di mana lontar menarikku. | If you see anything, send word. I'll be wherever the lontar pulls me. |
| @NPC_RANGA_NAME | | |
| BEAT_RANGA_FREED_5 | Aku akan meninggalkan tanda di jalan: satu topeng retak digantung di pohon. Cari yang itu. | I'll leave a sign on the road: one cracked mask hung in a tree. Look for that. |
| @ | | |
| BEAT_RANGA_FREED_6 | Ia berjalan keluar tanpa menoleh. Di pintu, ia berhenti dan mengucapkan namanya pada tembok, sekali, supaya tembok itu ikut ingat. | He walks out without looking back. At the door he stops and says his name to the wall, once, so the wall remembers too. |

### Beat `ranga_handed` (if `!flag:beat_ranga_handed`, `flag:choice_handed`; do `flag:beat_ranga_handed`). Choice 2, handed: the consequence plays at once
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_RANGA_HANDED_1 | Uwa Lengser datang sendiri, tanpa pengawal, dengan baki teh. Seorang lelaki tua yang membawa teh tak pernah dihentikan. | Uwa Lengser comes alone, without guards, carrying a tea tray. An old man with tea is never stopped. |
| @NPC_LENGSER_NAME | | |
| BEAT_RANGA_HANDED_2 | Ini yang kau sebut pembelot? Dia lebih mirip tukang gerabah yang lupa jalan pulang. | This is your deserter? He looks more like a potter who forgot the way home. |
| @NPC_RANGA_NAME | | |
| BEAT_RANGA_HANDED_3 | Aku tak akan melawan, Uwa. Aku cuma minta satu hal: kalau nanti kalian mengadiliku, panggil aku Ranga. | I won't fight, Uwa. I ask one thing only: when you judge me, call me Ranga. |
| @NPC_LENGSER_NAME | | |
| BEAT_RANGA_HANDED_4 | Pengadilan Galuh memanggil orang dengan nama mereka. Itu satu-satunya hal yang masih kami kerjakan dengan benar. | Galuh's court calls people by their names. It's the one thing we still do right. |
| @NPC_HERO_NAME | | |
| BEAT_RANGA_HANDED_H1 | Dia tahu tata letak perkemahan para topeng. Tanyakan dengan sopan. | He knows how the masks' camps are laid out. Ask him politely. |
| @NPC_LENGSER_NAME | | |
| BEAT_RANGA_HANDED_5 | Dengan teh dan kesabaran, Nak. Orang lupa nama, tapi jarang lupa gelas teh yang hangat. | With tea and patience, child. People forget names, but rarely a warm cup of tea. |
| @NPC_RANGA_NAME | | |
| BEAT_RANGA_HANDED_6 | Aku menggambar denahnya di lantai, kalau Uwa mau melihat. Gerbang barat, penjaganya lengah. | I'll draw the layout on the floor, if you want to see. The west gate, the guards are lax. |

### Chapter 4: The Coup in the Throne Room (g.16-g.20)

### Beat `grate_open` (if `!flag:beat_grate_open`, `flag:mqg_6`, `flag:laras_key_archive_grate`, `zone:kg_pustaka`; do `flag:beat_grate_open`). g.16, the way up through Laras's grate; Nyai Sekar's closing lines
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_GRATE_OPEN_1 | Di sudut pelataran arsip, jeruji saluran terbuka selebar tubuh. Bautnya digeser dari dalam, dan di besinya tergores Ka kecil. | In the archive yard's corner the drainage grate stands open a body's width. Its bolt was slid from inside, and a small Ka is scratched on the iron. |
| @NPC_HERO_NAME | | |
| BEAT_GRATE_OPEN_H1 | Kau membukanya sebelum kuminta, Laras. | You opened it before I asked, Laras. |
| @NPC_NYAI_SEKAR_NAME | | |
| BEAT_GRATE_OPEN_2 | Aku mendapatinya begitu waktu fajar, Nak. Bautnya sudah bergeser, dan aku bersumpah tak menyentuhnya. | I found it like that at dawn, child. The bolt had already moved, and I swear I never touched it. |
| BEAT_GRATE_OPEN_3 | Saluran itu tembus ke galeri atas istana. Dulu dipakai membersihkan bilik naskah. Aku sendiri tak pernah berani lewat. | The channel comes out in the palace's upper gallery. It was once used to clean the manuscript rooms. I never dared use it myself. |
| @NPC_HERO_NAME | | |
| BEAT_GRATE_OPEN_H2 | Kenapa Nyai tak ikut? | Why don't you come, Nyai? |
| @NPC_NYAI_SEKAR_NAME | | |
| BEAT_GRATE_OPEN_4 | Seseorang harus tetap menyalakan lampu. Kalau gelap, kerikan itu hilang lagi, dan semua usahamu sia-sia. | Someone has to keep the lamps lit. If it goes dark the scrapings vanish again, and all your work is wasted. |
| BEAT_GRATE_OPEN_5 | Di galeri atas ada potret raja yang sudah tak berwajah. Lihat itu, dan kau akan tahu kenapa Lengser menyimpan rahasianya begitu lama. | In the upper gallery hangs a portrait of the king with no face. See it, and you'll know why Lengser kept his secret so long. |
| @ | | |
| BEAT_GRATE_OPEN_6 | Kau merangkak melewati besi dingin. Di ujungnya, cahaya lilin dari galeri tinggi memantul di lantai marmer. | You crawl through cold iron. At the far end, candlelight from the high gallery glitters on marble. |

### Clue `court_portrait` (step g.17; starts `k_ii`; the person-boss clue)
| Key | ID | EN |
|-----|----|----|
| HUNT_KII_TITLE | Wajah Sang Raja | The King's Face |
| CLUE_COURT_PORTRAIT_1 | Potret raja di galeri, wajahnya dikikis sampai kayu putih. Hanya mahkota yang tersisa. | The king's portrait in the gallery, its face scraped down to pale wood. Only the crown is left. |
| CLUE_COURT_PORTRAIT_2 | Siapa pun yang memakai wajah ini, ia menghapus pemiliknya lebih dulu. | Whoever wears this face scraped off its owner first. |
| CLUE_COURT_PORTRAIT_NOTE | Potret raja di galeri, wajahnya dikikis. | The king's portrait in the gallery, its face scraped away. |

### Memory `k_ii` (walk; K-II, step g.17; Lengser's younger self, one night in this gallery)
| Key | ID | EN |
|-----|----|----|
| MEM_K_II_TITLE | Malam Uwa Lengser | Uwa Lengser's Night |
| MEM_K_II_IN | Ingatan Uwa Lengser, Nak: satu malam, lima belas tahun lalu, di lorong yang sama. | Uwa Lengser's memory, child: one night, fifteen years ago, in this same gallery. |
| MEM_K_II_1 | Lengser muda membawa baki teh ke kamar raja. Pintunya setengah terbuka. | Young Lengser carries a tea tray to the king's chamber. The door stands ajar. |
| MEM_K_II_2 | Di dalam, seorang lelaki berdiri di depan cermin, mencoba wajah sang raja seperti mencoba baju. | Inside, a man stands before a mirror, trying on the king's face like a coat. |
| MEM_K_II_3 | Lengser menjatuhkan baki. Lelaki itu menoleh dengan wajah raja, dan tersenyum. | Lengser drops the tray. The man turns, wearing the king's face, and smiles. |
| MEM_K_II_OUT | Lengser memegang rahasia itu sejak malam itu, Nak. Sekarang kau ikut memegangnya. | Lengser has held that secret since that night, child. Now you hold it too. |

### Clue `hunter_mask_2` and memory `h2` (step g.18; H2, kind walk; Aria wears the king's face). Fragment count follows quests.md v5: crater first, throne second, graves third, shrine fourth
| Key | ID | EN |
|-----|----|----|
| CLUE_HUNTER_MASK_2_1 | Pecahan topeng kedua di kaki takhta. Dingin, kali ini. | A second mask fragment at the foot of the throne. Cold, this time. |
| CLUE_HUNTER_MASK_2_2 | Seperti wajah yang dipinjam terlalu lama. | Like a face borrowed too long. |
| CLUE_HUNTER_MASK_2_NOTE | Pecahan topeng kedua, di dekat takhta. | The second mask fragment, by the throne. |
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
| BEAT_THRONE_SHADOW_2 | Udara di tempatnya berdiri dingin, seperti ruang bekas orang yang lama menahan napas. | The air where it stood is cold, like a room left by someone who held their breath too long. |
| @NPC_HERO_NAME | | |
| BEAT_THRONE_SHADOW_H1 | Dia tak mengambil apa-apa. Dia hanya melihat. | It took nothing. It only looked. |
| @ | | |
| BEAT_THRONE_SHADOW_3 | Cermin itu tinggi, ditutup kain, tapi satu sudutnya tersingkap seujung jari. Tak ada bayangan di dalamnya, bahkan bayanganmu. | The mirror is tall and covered, but one corner has been lifted a fingertip. There is no reflection in it, not even yours. |
| @NPC_HERO_NAME | | |
| BEAT_THRONE_SHADOW_H2 | Dia mencari wajahnya sendiri di sini. Itu yang dia ambil dari kita semua. | He was looking for his own face here. It's what he takes from all of us. |
| @ | | |
| BEAT_THRONE_SHADOW_4 | Dari luar, langkah sepatu kayu dan dengusan napas yang kau kenal. Ciung dan Lengser sudah menunggu. | From outside, wooden sandals and a breath you know. Ciung and Lengser are waiting. |

### Beat `rally` (if `!flag:beat_rally`, `flag:beat_throne_shadow`, `zone:kg_keraton`; do `flag:beat_rally`). g.19, the talk piece: the old guard and Ciung before the breach
| Key | ID | EN |
|-----|----|----|
| @NPC_LENGSER_NAME | | |
| BEAT_RALLY_1 | Penjaga lama sudah berkumpul di serambi. Dua puluh orang, dan separuhnya berlutut sama buruknya dengan lututku. | The old guard has gathered in the colonnade. Twenty of them, and half have knees as bad as mine. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_RALLY_2 | Dua puluh orang tua melawan pasukan bertopeng. Kedengarannya seperti dongeng. | Twenty old men against an army in masks. Sounds like a fairy tale. |
| @NPC_LENGSER_NAME | | |
| BEAT_RALLY_3 | Dongeng akan dimainkan di singgasana itu. Pintu belakang ruang takhta kuncinya padaku, lima belas tahun. | The tale will be played out at that throne. I've held the key to the throne room's back door for fifteen years. |
| @NPC_HERO_NAME | | |
| BEAT_RALLY_H1 | Kita masuk dari tiga sisi. Aku di tengah, kau di kanan, Ciung di kiri. | We go in from three sides. I take the middle, you the right, Ciung the left. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_RALLY_4 | Kau yang di tengah. Kau paling sulit ditebak, dan paling mudah dilupakan. Itu keuntungan. | You take the middle. You're the hardest to read and the easiest to forget. That's an advantage. |
| @NPC_LENGSER_NAME | | |
| BEAT_RALLY_5 | Satu hal. Dia menutup semua cermin karena cermin tak bisa dibohongi. Ingat itu kalau wajahnya mulai berubah. | One thing. He covers every mirror because mirrors can't be lied to. Remember that when his face starts to change. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_RALLY_6 | Kalau aku jatuh, jangan berhenti. Itu kata adikmu, kan? Aku meminjamnya. | If I fall, don't stop. That's what your sister says, isn't it? I'm borrowing it. |
| @ | | |
| BEAT_RALLY_7 | Dua daun pintu ruang takhta berderit. Di baliknya, seseorang menghitung langkah kaki yang mendekat. | The throne room's double doors creak. Behind them, someone counts the footsteps coming. |

### Beat `throne_breach` (if `!flag:beat_throne_breach`, `flag:mqg_6c`, `zone:kg_keraton`; do `flag:beat_throne_breach`). g.20, the court scene before the fight: the king debates, the Glamour copies break out. Laras's wax flaw shows
| Key | ID | EN |
|-----|----|----|
| @NPC_BARMA_WIJAYA_NAME | | |
| BEAT_THRONE_BREACH_1 | Siapa yang membiarkan pelayan dan anak liar masuk ke ruanganku? Pengawal. | Who let a servant and a wild boy into my chamber? Guards. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_THRONE_BREACH_2 | Pengawalmu sedang beristirahat. Lama. | Your guards are resting. For a long while. |
| @NPC_BARMA_WIJAYA_NAME | | |
| BEAT_THRONE_BREACH_3 | Ciung Wanara, juara sayembara. Kuberi kau kehormatan menghadap. Di mana sopan santunmu? | Ciung Wanara, champion of the tournament. I grant you the honour of an audience. Where are your manners? |
| @NPC_HERO_NAME | | |
| BEAT_THRONE_BREACH_H1 | Kami datang menanyakan pedati-pedati yang lewat Pasar Kuta dengan segelmu. | We came to ask about the wagons that passed Pasar Kuta with your seal. |
| @NPC_BARMA_WIJAYA_NAME | | |
| BEAT_THRONE_BREACH_4 | Segelku ada di banyak tangan. Karena itu ia disebut segel, bukan namaku. | My seal is in many hands. That is why it's called a seal and not my name. |
| @NPC_LENGSER_NAME | | |
| BEAT_THRONE_BREACH_5 | Cincinmu cacat, Baginda. Ada goresan kecil di lilinnya, hanya terlihat dari dekat. Sebuah Ka. | Your ring is flawed, Majesty. A small scratch in its wax, only visible up close. A Ka. |
| @ | | |
| BEAT_THRONE_BREACH_6 | Wajah sang raja bergetar sesaat seperti air yang disentuh jari. Di bawahnya, wajah lain, tipis dan ketakutan. | The king's face trembles a moment like water touched by a finger. Beneath it, another face, thin and afraid. |
| @NPC_BARMA_WIJAYA_NAME | | |
| BEAT_THRONE_BREACH_7 | Kalau satu wajah tak cukup, aku punya banyak. | If one face is not enough, I have many. |
| @ | | |
| BEAT_THRONE_BREACH_8 | Bayangan raja memecah menjadi tiga, lalu lima, masing-masing tersenyum persis sama. Tapi satu retak di dahinya, dan satu lagi, dan satu lagi. | The king's shadow splits into three, then five, each smiling exactly alike. But one cracks across its forehead, then another, and another. |

### Beat `confession` (if `!flag:beat_confession`, `flag:mqg_7`; do `flag:beat_confession`). The turn
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
| @NPC_LENGSER_NAME | | |
| BEAT_CONFESSION_6 | Aku melihatmu di depan cermin malam itu, Aria. Aku menjatuhkan baki dan tak pernah memberitahu siapa pun. | I saw you at that mirror that night, Aria. I dropped the tray and never told a soul. |
| @NPC_BARMA_WIJAYA_NAME | | |
| BEAT_CONFESSION_7 | Aku tahu. Aku membiarkanmu hidup, karena kau satu-satunya yang ingat siapa aku sebelum wajah ini. | I know. I let you live, because you were the only one who remembered who I was before this face. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_CONFESSION_8 | Lima belas tahun orang menyembah wajah pinjaman. Kau kira itu cukup untuk menebusnya? | Fifteen years people worshipped a borrowed face. Do you think that's enough to pay for it? |

### Beat `cage` (if `!flag:beat_cage`, `flag:beat_confession`; do `flag:beat_cage`, `codex:barma_wijaya`, `codex:pangrenyep`)
| Key | ID | EN |
|-----|----|----|
| BEAT_CAGE_1 | Ciung Wanara menyeret mereka ke kandang besi di pelataran, seperti dalam kisah: sang raja palsu, dan sang permaisuri bersamanya. | Ciung Wanara drags them to the iron cage in the courtyard, as in the legend: the false king, and the queen with him. |
| @NPC_PANGRENYEP_NAME | | |
| BEAT_CAGE_2 | Putraku akan datang, Nak. Yang dikurung selalu ditebus. | My son will come, child. What is caged is always ransomed. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_CAGE_6 | Aku tak mau mereka mati. Aku mau mereka diadili. Itulah bedaku dengan yang menyuruh mereka. | I don't want them dead. I want them tried. That's the difference between me and whoever sent them. |
| @NPC_HERO_NAME | | |
| BEAT_CAGE_H1 | Yang menyuruh mereka belum tertangkap. Kita hanya mengunci bayangannya. | Whoever sent them isn't caught. We've only locked up the shadow. |
| @NPC_HUNTER_NAME | | |
| BEAT_CAGE_3 | Kandang menahan orangnya, bukan namanya. | The cage holds the man, not the name. |
| @ | | |
| BEAT_CAGE_4 | Suara itu datang dari balik singgasana. Saat kau menoleh, hanya bayangan yang tersisa. | The voice comes from behind the throne. When you turn, only shadow is left. |
| @NPC_LENGSER_NAME | | |
| BEAT_CAGE_7 | Lima belas tahun kutunggu hari ini. Kenapa rasanya seperti membuka pintu ke ruangan yang lebih dingin? | Fifteen years I waited for this day. Why does it feel like opening a door onto a colder room? |

### Beat `escape` (if `!flag:beat_escape`, `quest:mqg=done`, `flag:beat_cage`; do `flag:beat_escape`, `start:mq2`)
| Key | ID | EN |
|-----|----|----|
| BEAT_ESCAPE_1 | Dalam kekacauan, seorang pemuda berbaju sutra melompati pagar pelataran, putra sang ratu, Hariang Banga. | In the chaos a young man in silk vaults the courtyard wall: the queen's son, Hariang Banga. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_ESCAPE_2 | Kalian mengurung dua orang yang belum diadili. Aku akan kembali dengan pasukan. | You've caged two who were never tried. I'll be back with an army. |
| @NPC_HERO_NAME | | |
| BEAT_ESCAPE_H1 | Ibumu tak disakiti. Itu janji kami, di depan semua orang. | Your mother isn't hurt. That's our promise, before everyone here. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_ESCAPE_7 | Janji dari orang yang mengurungnya. Aku akan menimbangnya di tepi sungai, bukan di sini. | A promise from the people who caged her. I'll weigh it at the river, not here. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_ESCAPE_3 | Biarkan. Dia saudaraku, aku tak mau mengejarnya. Galuh harus kujaga. Kau cari adikmu, ke timur, ke arah dia lari. | Let him go. He's my brother, I won't chase him. I have to hold Galuh. You go find your sister, east, the way he ran. |
| @NPC_HERO_NAME | | |
| BEAT_ESCAPE_H2 | Lengser, kau ikut menjaga Galuh? | Lengser, you'll help him hold Galuh? |
| @NPC_LENGSER_NAME | | |
| BEAT_ESCAPE_5 | Dengan lututku? Aku akan duduk di tangga dan mengawasi dari kursi. Pergilah. | With these knees? I'll sit on the steps and watch from a chair. Go on. |
| BEAT_ESCAPE_4 | Lima belas tahun kupegang rahasia itu. Ringan juga setelah dilepas. | Fifteen years I held that secret. Light, once it's let go. |

## 8. Act III: Mataram (MQ2, "Darah di Pamali")
**Lines in this section: 349** (ASSUMED budget, v5: at most 760). Same line rules as section 7.
Regional characters: Ki Sumarto (want: a stage no army will burn; turn: his son marches east; close: Sapto wades home) and Nyai Gendhis (want: the yard to ring again; turn: the dawn rhythm is a weapon; close: the pestles answer from the temple). Order of play: the two recruiters (who's who), the haulers (K3 hook), the farmer at the petilasan, the stage, Ki Sumarto's lesson, the families, the ruins and Na, the graves and the third mask fragment, Nyai Gendhis's yard and Ca, the night siege and Ra, the plain of rising stones, the camp, the K3 clues, Laras chapter 3, the crypt, K3, Bondowoso, the Pamali stone, Ki Sumarto's show, the letters, the ford.

### Chapter 1: The Two-Bank War Front (2.1-2.5)

### recruiter_a (mt_gapura, the west bank; name NPC_RECRUITER_A_NAME). Step 2.1 `all`, any order
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
| 1 | @NPC_RECRUITER_A_NAME | | |
| 1 | DLG_RECRUITER_A_V4 | Lancar karena sudah kuulang seribu kali, dari pasar ke pasar. Tiap diulang, ia terdengar lebih benar. | Smooth because I've said it a thousand times, market to market. Every repeat makes it sound truer. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_RECRUITER_A_H2 | Siapa yang membayarmu? | Who pays you? |
| 1 | @NPC_RECRUITER_A_NAME | | |
| 1 | DLG_RECRUITER_A_V5 | Panji Ciung Wanara membayar dengan makan dan harapan. Bagiku cukup. Perang selalu butuh harapan, dan harapan selalu butuh juru bicara. | Ciung Wanara's banner pays in food and hope. Enough for me. A war always needs hope, and hope always needs a mouth. |
| 1 | DLG_RECRUITER_A_V6 | Aku tak melihat raja palsu itu dikurung. Aku cuma mendengarnya, seperti semua orang. Kau akan terkejut berapa banyak perang dimulai dari kabar. | I never saw the false king caged. I only heard it, like everyone. You'd be surprised how many wars start from word of mouth. |
| 1 | DLG_RECRUITER_A_V7 | Kalau mau lihat siapa yang sungguh menang, pandang ke ladang di luar gerbang. Batu-batu tumbuh di sana tanpa tukang. | If you want to see who really wins, look at the fields beyond the gate. Stones are growing there with no mason. |
| 2 | DLG_RECRUITER_A_V3 | Tombak atau telinga yang baik. Aku terima keduanya. | A spear or a good ear. I'll take either. |

### recruiter_b (mt_gapura, the east bank; name NPC_RECRUITER_B_NAME). Step 2.1 `all`, any order
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
| 1 | @NPC_RECRUITER_B_NAME | | |
| 1 | DLG_RECRUITER_B_V4 | Karena aku percaya setiap katanya. Pangeran kami menulis surat pada ibunya tiap malam, dan itu cukup bagiku. | Because I believe every word. Our prince writes his mother a letter every night, and that's enough for me. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_RECRUITER_B_H2 | Dan kalau ceritamu keliru? | And if your story is wrong? |
| 1 | @NPC_RECRUITER_B_NAME | | |
| 1 | DLG_RECRUITER_B_V5 | Kalau keliru, aku mati membela cerita yang salah. Bukankah itu nasib sebagian besar orang? | Then I die defending a wrong story. Isn't that most people's fate? |
| 1 | DLG_RECRUITER_B_V6 | Tepi barat memanggil kami perampas. Padahal kami hanya bergerak ke arah yang ditunjuk seorang anak yang sedang menangis. | The west bank calls us usurpers. We only move where a crying child points. |
| 1 | DLG_RECRUITER_B_V7 | Lihat ladang di luar gerbang kalau kau tak percaya cerita siapa pun. Di sana tak ada pihak, hanya batu yang tumbuh. | Look at the fields beyond the gate if you trust no one's story. No side there, only stones that grow. |
| 2 | DLG_RECRUITER_B_V3 | Tombak atau telinga yang baik. Aku terima keduanya. | A spear or a good ear. I'll take either. |

### Beat `two_stories` (if `!flag:beat_two_stories`, `flag:mq2_a1`; do `flag:beat_two_stories`). Who's who, in one thought; the lane divided by a rope
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_TWO_STORIES_1 | Seutas tali membelah lorong pasar: panji barat di satu sisi, panji timur di sisi lain. Pedagang yang sama menjual ke keduanya, dengan senyum yang berbeda. | A rope splits the market lane: west banners on one side, east banners on the other. The same traders sell to both, with different smiles. |
| BEAT_TWO_STORIES_2 | Seorang anak kecil melompati tali itu bolak-balik dan tak seorang pun menegurnya. | A small child hops the rope back and forth and nobody scolds him. |
| @NPC_HERO_NAME | | |
| BEAT_TWO_STORIES_H1 | Satu cerita, dua penjahat berbeda. Masing-masing yakin dirinya benar. | One story, two different villains. Each is sure they're in the right. |
| @ | | |
| BEAT_TWO_STORIES_3 | Di lorong itu, tak ada yang bicara tentang gadis kecil dengan lontar, atau tentang para tanpa rupa. Perang punya cerita yang lebih keras. | In that lane no one speaks of a small girl with a lontar, or of the faceless. The war has a louder story. |
| @NPC_HERO_NAME | | |
| BEAT_TWO_STORIES_H3 | Mereka bertengkar soal siapa yang benar, dan tak seorang pun menanyakan siapa yang hilang. | They quarrel over who is right, and no one asks who is missing. |
| @ | | |
| BEAT_TWO_STORIES_4 | Dari ujung lorong, bunyi batu diseret dan napas serempak seratus orang yang tak bernapas. | From the lane's far end comes the drag of stone and the breathing, in unison, of a hundred who aren't breathing. |
| @NPC_HERO_NAME | | |
| BEAT_TWO_STORIES_H2 | Dan Kala makan dari keduanya. Gerbang perbatasan, lalu petilasan. | And Kala eats from both. The border gate, then the petilasan. |

### Beat `haulers` (if `!flag:beat_haulers`, `flag:beat_two_stories`, `zone:mt_gapura`; do `flag:beat_haulers`). K3 hook, the overnight pillars (2.1). Area `mt_gapura` (v4 wrote `mt_gerbang`)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_HAULERS_1 | Di luar gerbang, penduduk desa menyeret batu besar dalam gelap. Mereka tak bicara; mata mereka kosong. | Beyond the gate villagers haul great stones through the dark. They don't speak; their eyes are empty. |
| BEAT_HAULERS_2 | Di ladang yang kemarin kosong, berdiri tembok candi setinggi dada. | In a field that was empty yesterday stands a temple wall chest-high. |
| @NPC_HERO_NAME | | |
| BEAT_HAULERS_H1 | Siapa menyuruh mereka? | Who ordered this? |
| @ | | |
| BEAT_HAULERS_3 | Tak ada yang mengawasi, tapi ritme mereka serempak: angkat, seret, letakkan. Seperti ada yang menghitung dari jauh. | No one watches them, yet their rhythm is exact: lift, drag, set down. As if someone far off is counting. |
| BEAT_HAULERS_4 | Di puncak tembok yang baru, sebuah pilar pendek berdiri sendiri. Pilar itu belum ada saat kau melewati gerbang tadi. | On top of the new wall a short pillar stands alone. It wasn't there when you passed the gate a moment ago. |
| @NPC_HERO_NAME | | |
| BEAT_HAULERS_H2 | Tumbuh. Batu-batu itu tumbuh. | Growing. The stones are growing. |
| @ | | |
| BEAT_HAULERS_5 | Dari pasar, seseorang berteriak bahwa para penjarah sudah menutup jalan ke gerbang perbatasan. Orang-orang berlarian ke arah sebaliknya. | From the market someone shouts that looters have blocked the road to the border gate. People run the other way. |
| @NPC_HERO_NAME | | |
| BEAT_HAULERS_H3 | Gerbang perbatasan dulu. Lalu aku cari petilasan. | The border gate first. Then I look for a petilasan. |

### Hunt K3: Bandung Bondowoso (2.1, 2.15, 2.18, 2.19)
| Key | ID | EN |
|-----|----|----|
| HUNT_K3_TITLE | Seribu Candi | The Thousand Temples |

### sawah_farmer (mt_sawah, the petilasan `mataram_1`; name NPC_SAWAH_FARMER_NAME; new; step 2.2 `talk`, `"quiet": true`, never completes a step)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq2=active`, `flag:mq2_1`, `!flag:lead_pasar` | |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_SAWAH_FARMER_NAME | | |
| 1 | DLG_SAWAH_FARMER_V1 | Istirahatlah di batu itu. Petilasan ini tak pernah diganggu, bahkan oleh penjarah. Mereka takut pada hal yang tak mereka mengerti. | Rest on that stone. This petilasan is never disturbed, even by looters. They fear what they don't understand. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SAWAH_FARMER_H1 | Sawah Ibu tergenang. Ada apa dengan irigasinya? | Your paddy is flooded. What happened to the channels? |
| 1 | @NPC_SAWAH_FARMER_NAME | | |
| 1 | DLG_SAWAH_FARMER_V2 | Para prajurit dari dua tepi menggali saluran untuk mengalihkan air ke parit mereka. Tak seorang pun bertanya padaku. Padi tahun ini sudah jadi bubur. | Soldiers from both banks dug channels to divert water to their trenches. No one asked me. This year's rice is already porridge. |
| 1 | DLG_SAWAH_FARMER_V3 | Keluarga pasar mengungsi lewat jalan sawahku. Kaki mereka tenggelam sampai lutut. Dalang di pasar masih bertahan, katanya. | The market families are fleeing along my paddy road. They sink to the knee. The dalang in the market is still holding out, they say. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SAWAH_FARMER_H2 | Dalang itu? Ki apa namanya? | The dalang? What's his name? |
| 1 | @NPC_SAWAH_FARMER_NAME | | |
| 1 | DLG_SAWAH_FARMER_V4 | Ki Sumarto, si dalang. Dia memainkan lakon untuk dua tepi supaya tak ada yang memanah panggungnya. Cerdik, tapi panggung tak melindungi kelir dari penjarah. | Ki Sumarto, the dalang. He plays for both banks so nobody shoots his stage. Clever, but a stage can't shield a screen from looters. |
| 1 | DLG_SAWAH_FARMER_V5 | Pergilah ke pasar. Dengar suara penjarah di sana, itu pertanda mereka sudah dekat. Kalau kau bisa, hajar mereka untukku. | Go to the market. If you hear looters there, they're close. If you can, thrash them for me. |
| 2 | DLG_SAWAH_FARMER_V6 | Padiku akan tumbuh lagi. Tanah ini keras kepala, seperti aku. | My rice will grow again. This soil is stubborn, like me. |

### mataram_dalang (Ki Sumarto; replace the main-path entries, keep the SQ-M4 entries). Steps 2.3 and 2.4; the hub is entry 3
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `quest:mq2=done` | | |
| 2 | `step:mq2=3` (2.4) | `learn:jawa_ha` | |
| (keep) | SQ-M4 entries | | |
| 3 | `flag:mq2_2`, `!quest:mq2=done` (a hub: `"hub": true`, `"quiet": true`) | | CHOICE_SUMARTO_ASK_1 to `topic:sumarto_sapto`; CHOICE_SUMARTO_ASK_2 to `topic:sumarto_banks`; CHOICE_SUMARTO_ASK_3 to `topic:sumarto_stage`; CHOICE_SUMARTO_ASK_4 leaves |
| 4 | `step:mq2=2` (2.3, the stage under attack) | | |
| (keep) | the current fallback | | |
| T1 | `"topic": "sumarto_sapto"`, `"quiet": true` | | |
| T2 | `"topic": "sumarto_banks"`, `"quiet": true` | | |
| T3 | `"topic": "sumarto_stage"`, `"quiet": true` | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_MATARAM_DALANG_V7 | Anakku pulang menyeberang kali itu. Lakon berikutnya kumainkan untuk satu tepi saja: rumahku. | My son waded home across that river. The next lakon I play for one bank only: my house. |
| 1 | DLG_MATARAM_DALANG_V220 | Dia bilang tombaknya berat sekali, lebih berat daripada wayang mana pun. Kujawab, itu karena tombak tak punya lakon. | He says the spear was heavier than any puppet. I told him that's because a spear has no tale. |
| 2 | DLG_MATARAM_DALANG_V1 | Kelirku selamat, dan kau yang menyelamatkannya. Aku Ki Sumarto, dalang. Pagi untuk tepi barat, malam untuk tepi timur. | My screen survived, and you saved it. I'm Ki Sumarto, dalang. Mornings for the west bank, evenings for the east. |
| 2 | @NPC_MATARAM_DALANG_NAME | | |
| 2 | DLG_MATARAM_DALANG_V2 | Anakku Sapto berbaris dengan pasukan Hariang Banga. Selama dua tepi mau menonton, tak ada yang memanah panggungku. Ini Ha, penyembuh; di timur katanya juga mengangkat kutukan. | My son Sapto marches with Hariang Banga's army. As long as both banks want a show, nobody shoots my stage. This is Ha, it heals; out east they say it lifts curses too. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_MATARAM_DALANG_H201 | Ha. Bagaimana menggambarnya? | Ha. How do I draw it? |
| 2 | @NPC_MATARAM_DALANG_NAME | | |
| 2 | DLG_MATARAM_DALANG_V221 | Seperti membuka jendela rumah yang pengap. Satu goresan tegak, dua lengan terbuka keluar. Gambar pelan, dan luka yang kau sentuh ikut bernapas. | Like opening a window in a stuffy house. One upright stroke, two arms open outward. Draw slowly, and the wound you touch breathes too. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_MATARAM_DALANG_H2 | Gadis kecil dengan lontar. Anda lihat dia? | A little girl with a lontar. Did you see her? |
| 2 | @NPC_MATARAM_DALANG_NAME | | |
| 2 | DLG_MATARAM_DALANG_V222 | Digiring lewat pasar ini lima malam lalu, ke arah Candi Seribu, seribu candi yang sedang didirikan para pengangkut batu. Aku melihatnya dari balik kelir. | Marched through this market five nights ago toward Candi Seribu, the Thousand Temples the haulers are raising. I saw it from behind my screen. |
| 2 | DLG_MATARAM_DALANG_V223 | Tiga jejak bisa kau ikuti. Reruntuhan di barat laut, tempat Arca-arca bangun sendiri. Kuburan, tempat para tanpa rupa mengais nama prajurit. | Three trails you can follow. The ruins to the northwest, where the Arca wake on their own. The graveyard, where the faceless rake names off soldiers. |
| 2 | DLG_MATARAM_DALANG_V224 | Ketiga pelataran lesung di kaki bukit, tempat para perempuan berhenti menumbuk. Tempuh semuanya. Urutannya terserah kakimu. | The third is the lesung yard at the foot of the hill, where the women stopped pounding. Walk them all. The order is up to your feet. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_MATARAM_DALANG_H202 | Kenapa Anda memainkan lakon untuk kedua tepi? | Why do you play for both banks? |
| 2 | @NPC_MATARAM_DALANG_NAME | | |
| 2 | DLG_MATARAM_DALANG_V225 | Dalang yang memilih satu tepi kehilangan separuh ceritanya, dan separuh penontonnya. Pergilah, dan bawakan aku kabar dari kuburan. | A dalang who picks one bank loses half his story, and half his audience. Go, and bring me news from the graveyard. |
| 3 | DLG_MATARAM_DALANG_V226 | Duduklah, Nak. Kelirku sudah dijahit lagi. Mau bertanya apa, selagi aku punya cukup minyak untuk dua lampu? | Sit, child. My screen is sewn up again. What would you ask, while I have enough oil for two lamps? |
| 4 | DLG_MATARAM_DALANG_V4 | Tolong, Nak! Mereka menjarah kelirku! Hajar mereka, nanti kubayar dengan cerita! | Help, child! They're looting my screen! Thrash them, and I'll pay you in stories! |
| T1 | DLG_MATARAM_DALANG_V227 | Sapto lahir di balik kelir ini. Tidurnya di antara wayang, bangunnya di antara gamelan. | Sapto was born behind this screen. He slept among puppets and woke among gamelan. |
| T1 | DLG_MATARAM_DALANG_V228 | Waktu seorang perekrut datang, dia tak minta izin. Dia cuma meninggalkan wayang Bima di bangku dan pergi. | When a recruiter came he didn't ask leave. He just left the Bima puppet on the bench and went. |
| T1 | DLG_MATARAM_DALANG_V229 | Kalau kau bertemu dia di timur, bilang lampu di rumah masih menyala. Itu saja. Jangan bilang aku yang menyuruh. | If you meet him in the east, say the lamp at home is still lit. That's all. Don't say I sent you. |
| T2 | DLG_MATARAM_DALANG_V6 | Hariang Banga bukan orang kejam. Ia ingin ibunya kembali. Aku pun begitu, dengan anakku. | Hariang Banga isn't cruel. He wants his mother back. So would I, with my boy. |
| T2 | DLG_MATARAM_DALANG_V230 | Ciung Wanara juga bukan perampas. Dia ingin sesuatu yang dirampas darinya. Dua anak muda yang menginginkan hal serupa, dan bertengkar karenanya. | Ciung Wanara isn't a usurper either. He wants what was taken from him. Two young men who want the same thing, and quarrel over it. |
| T2 | DLG_MATARAM_DALANG_V231 | Sungai di perbatasan itu bernama pamali, Nak. Yang tak boleh dilanggar. Orang tua kami selalu bilang begitu, tapi tak pernah bilang apa. | The river at the border is called pamali, child. What must not be done. Our elders always said so, but never said what. |
| T3 | DLG_MATARAM_DALANG_V232 | Panggung wayang itu cuma kain dan lampu. Yang membuatnya tahan adalah orang-orang yang percaya pada bayangan. | A wayang stage is only cloth and a lamp. What makes it last is the people who believe in shadows. |
| T3 | DLG_MATARAM_DALANG_V233 | Pemenang perang membakar panggung. Pecundang membakarnya juga, supaya tak ada saksi. Kelir ini selamat karena kau datang tepat waktu. | The winners of wars burn stages. The losers burn them too, so there are no witnesses. This screen survived because you came in time. |
| T3 | DLG_MATARAM_DALANG_V234 | Seorang dalang yang menyebut nama pembunuh keras-keras bisa dibunuh. Karena itu aku menyebutnya lewat wayang. | A dalang who says a killer's name aloud can be killed. So I say it through puppets. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_SUMARTO_ASK_1 | Tanya tentang Sapto | Ask about Sapto | `topic:sumarto_sapto` |
| CHOICE_SUMARTO_ASK_2 | Tanya tentang kedua tepi | Ask about the two banks | `topic:sumarto_banks` |
| CHOICE_SUMARTO_ASK_3 | Tanya tentang panggungnya | Ask about the stage | `topic:sumarto_stage` |
| CHOICE_SUMARTO_ASK_4 | Terima kasih, Ki | Thank you, Ki | |

### Beat `families_safe` (if `!flag:beat_families_safe`, `flag:mq2_2b`, `zone:mt_sawah`; do `flag:beat_families_safe`). 2.5, the talk piece at the end of the paddy road
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_FAMILIES_SAFE_1 | Jalan sawah berakhir di sebuah lumbung kering. Keluarga-keluarga pasar berdiri lama, tanah masih menetes dari kaki dan keranjang mereka. | The paddy road ends at a dry granary. The market families stand a long while, mud still dripping from their feet and baskets. |
| @NPC_PASAR_REFUGEE_NAME | | |
| BEAT_FAMILIES_SAFE_2 | Lapakku di pasar hancur diinjak dua pasukan. Anakku selamat, itu cukup. Terima kasih sudah memegangi tali rakit. | My stall in the market was trampled by two armies. My child is safe, that's enough. Thank you for holding the raft rope. |
| @NPC_HERO_NAME | | |
| BEAT_FAMILIES_SAFE_H1 | Kalian lewat jalan ke candi tadi? Seorang gadis kecil dengan lontar? | Did you pass the temple road? A little girl with a lontar? |
| @NPC_PASAR_REFUGEE_NAME | | |
| BEAT_FAMILIES_SAFE_3 | Seorang gadis, ya. Digiring di tengah barisan orang bertopeng. Di ujung jalan dia berhenti, berjongkok, dan menulis sesuatu di tanah dengan kuku. | A girl, yes. Marched in the middle of a masked line. At the end of the road she stopped, crouched, and wrote something in the dirt with her nail. |
| @NPC_HERO_NAME | | |
| BEAT_FAMILIES_SAFE_H2 | Satu huruf, goyah. Ka. | One letter, shaky. Ka. |
| @NPC_PASAR_REFUGEE_NAME | | |
| BEAT_FAMILIES_SAFE_4 | Kalau itu yang kau cari, ia menulisnya di dinding reruntuhan di barat laut juga. Anak-anak kami melihatnya dari jauh. | If that's what you seek, she wrote it on a ruin wall to the northwest as well. Our children saw it from afar. |
| @ | | |
| BEAT_FAMILIES_SAFE_5 | Seorang anak menarik ujung bajumu dan menunjuk ke reruntuhan. Dari lumbung terlihat tiga garis asap: reruntuhan, kuburan, dan sebuah pelataran kecil. | A child tugs your sleeve and points at the ruins. From the granary you see three threads of smoke: ruins, graveyard, and a small yard. |

### Chapter 2: Three Leads in the Ruins (2.6-2.10)

### pak_karto (side NPC in `mt_reruntuhan`'s outer yard, off the main path since v3.1; no quest yet)
| Entry | if | do |
|-------|----|----|
| 1 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_PAK_KARTO_IDLE | Batu-batu ini dulu bicara. Kini hanya lumut yang mendengarkan. Lihatlah dasar Arca itu kalau kau berani lewat halaman. | These stones used to speak. Now only the moss listens. Look at the Arca's base, if you dare the courtyard. |

### Clue `ka_chalk` (step 2.6; Laras's chalk on the courtyard wall; journal note only)
| Key | ID | EN |
|-----|----|----|
| CLUE_KA_CHALK_1 | Di dinding halaman, kapur putih: Ka, goyah, ditulis oleh seseorang yang berlari. | On the courtyard wall, white chalk: Ka, shaky, written by someone running. |
| CLUE_KA_CHALK_2 | Dia lewat sini sebelum hujan. Kapur ini hanya bertahan sampai hujan berikutnya. | She passed before the rain. This chalk only lasts until the next rain. |
| CLUE_KA_CHALK_NOTE | Ka kapur Laras di dinding halaman reruntuhan. | Laras's chalk Ka on the ruins' courtyard wall. |

### arca_base (object, `flag:lead_ruins`, cond `!flag:mq2_3`; name NPC_ARCA_BASE_NAME). Step 2.6 `glyph_learned:jawa_na`; Pak Karto leaves the main path
| Entry | if | do |
|-------|----|----|
| 1 | `flag:lead_ruins`, `!flag:mq2_3` (2.6) | `learn:jawa_na` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_ARCA_BASE_V1 | Di dasar Arca terpahat aksara Jawa lama, halus, dimakan lumut. Satu goresan lurus tanpa ragu: Na. | At the Arca's base, old Javanese letters, fine and mossed over. One straight stroke with no doubt in it: Na. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_ARCA_BASE_H1 | Tanganku mengikutinya sebelum aku sempat berpikir. | My hand followed it before I could think. |
| 1 | @NPC_ARCA_BASE_NAME | | |
| 1 | DLG_ARCA_BASE_V2 | Na menerjang lurus menembus apa pun. Penjaga batu itu retak di dalam, dan huruf ini membelahnya. | Na dashes straight through whatever stands there. The stone guardians are cracked inside, and this letter splits them. |
| 1 | DLG_ARCA_BASE_V5 | Di bawah goresan itu, bekas kapur putih: Ka yang goyah, ditulis seseorang yang berlari. | Beneath the carving, a smear of white chalk: a shaky Ka, written by someone running. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_ARCA_BASE_H2 | Laras melewati sini. Dia meninggalkan jejak untukku. | Laras came through here. She left a trail for me. |
| 1 | @NPC_ARCA_BASE_NAME | | |
| 1 | DLG_ARCA_BASE_V6 | Kapur tak bertahan lewat hujan. Cepat. Huruf Na ini akan kau butuhkan sebelum kuburan. | Chalk doesn't survive rain. Be quick. You'll need this Na before the graves. |
| 1 | DLG_ARCA_BASE_V3 | Tanah di kaki Arca masih basah oleh jejak sepatu kain, menuju timur. | The earth at the Arca's foot is still wet with cloth-shoe prints, heading east. |
| 2 | DLG_ARCA_BASE_V4 | Lumut dan satu huruf. Na. | Moss, and one letter. Na. |

### Beat `hunter_war` (if `!flag:beat_hunter_war`, `flag:lead_kuburan`; do `flag:beat_hunter_war`). 2.7, the Hunter speaks
| Key | ID | EN |
|-----|----|----|
| BEAT_HUNTER_WAR_1 | Di antara nisan-nisan baru, para tanpa rupa menunduk dan mengangkat sesuatu dari tubuh prajurit: selembar nama, diremas seperti kertas. | Among the new graves the faceless stoop and lift something from the fallen soldiers: a name, crumpled like paper. |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_WAR_2 | Dua pasukan membuat dua kali lupa. | Two armies make twice the forgetting. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_WAR_H1 | Di mana adikku? | Where is my sister? |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_WAR_4 | Tak seorang pun mencarinya di sini. Mereka hanya mencari nama yang bisa diambil. | No one looks for her here. They only look for names that can be taken. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_WAR_H2 | Kau punya nama. Aku tahu namamu. | You have a name. I know your name. |
| @ | | |
| BEAT_HUNTER_WAR_5 | Bayangan jangkung itu diam sejenak, kepalanya miring seperti orang mendengar panggilan jauh. | The tall shadow is still a moment, head tilted like someone hearing a call from far away. |
| BEAT_HUNTER_WAR_3 | Ia berbalik ke arah candi. Hanya jelaga tertinggal di rumput. | He turns toward the temples. Only soot is left on the grass. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_WAR_H3 | Candi. Jadi ke sanalah mereka membawanya. | The temples. So that's where they take her. |

### Clue `hunter_mask_3` and memory `h3` (step 2.8; H3, kind walk; Aria gives his own name to Kala). Third fragment
| Key | ID | EN |
|-----|----|----|
| CLUE_HUNTER_MASK_3_1 | Pecahan topeng ketiga di antara nisan baru. Berat, seperti menahan sesuatu. | A third mask fragment among the new graves. Heavy, like it's holding something. |
| CLUE_HUNTER_MASK_3_2 | Lontarku menarik, seolah ingin menunjukkan harganya. | My lontar tugs, as if it wants to show me the price. |
| CLUE_HUNTER_MASK_3_NOTE | Pecahan topeng ketiga, di antara nisan. | The third mask fragment, among the graves. |
| MEM_H3_TITLE | Harga | The Price |
| MEM_H3_IN | Satu malam sendirian, Nak. Jangan berpaling. | A night alone, child. Don't look away. |
| MEM_H3_1 | Aria duduk sendiri di kamar, dengan wajah raja di wajahnya. Sebuah bayangan besar menunggu di sudut. | Aria sits alone in the chamber, the king's face on his own. A great shadow waits in the corner. |
| MEM_H3_2 | "Aku bisa menjaga wajah ini," katanya. "Harganya?" Bayangan itu: "Namamu." | "I can keep this face," he says. "The price?" The shadow: "Your name." |
| MEM_H3_3 | Aria diam lama. Lalu ia menyerahkannya, seperti menyerahkan sehelai daun. | Aria is silent a long while. Then he gives it up, like handing over a leaf. |
| MEM_H3_OUT | Kala memakan nama dengan sopan, Nak. Ia bahkan menghapus rasa kehilangannya. | Kala eats names politely, child. He even eats the grief for them. |

### lesung_women (Nyai Gendhis; replace all entries; main-path only, the SQ-M5 giver entries are dropped). Steps 2.9 `talk` and 2.10 `glyph_learned:jawa_ca`; the hub is entry 3
| Entry | if | do | choices |
|-------|----|----|---------|
| 1a | `step:mq2=8`, `flag:gendhis_met` (a repeat visit before the yard is cleared) | | |
| 1 | `step:mq2=8` (2.9) | `flag:gendhis_met` | |
| 2 | `flag:mq2_4`, `!flag:mq2_5` (2.10) | `learn:jawa_ca` | |
| 3 | `flag:mq2_5` (a hub: `"hub": true`, `"quiet": true`) | | CHOICE_GENDHIS_ASK_1 to `topic:gendhis_dawn`; CHOICE_GENDHIS_ASK_2 to `topic:gendhis_women`; CHOICE_GENDHIS_ASK_3 to `topic:gendhis_night`; CHOICE_GENDHIS_ASK_4 leaves |
| 4 | (none) | | |
| T1 | `"topic": "gendhis_dawn"`, `"quiet": true` | | |
| T2 | `"topic": "gendhis_women"`, `"quiet": true` | | |
| T3 | `"topic": "gendhis_night"`, `"quiet": true` | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1a | DLG_LESUNG_WOMEN_V31 | Pelataran lesung ada di timur gubuk ini. Pukul alu yang berjalan, jangan terlalu keras, lalu kembali padaku. | The lesung yard is east of this hut. Strike the walking pestles, not too hard, then come back to me. |
| 1 | @NPC_LESUNG_WOMEN_NAME | | |
| 1 | DLG_LESUNG_WOMEN_V1 | Dengar? Tuk, tuk, tuk. Setahun kami tak berani menumbuk. Kuburan itu membuat kami bisu. | Hear that? Tuk, tuk, tuk. A year we haven't dared to pound. That graveyard struck us dumb. |
| 1 | DLG_LESUNG_WOMEN_V11 | Aku Nyai Gendhis. Perempuan-perempuan ini menumbuk padi di pelataran ini sebelum nenekku lahir. Kini alu-alu kami berjalan sendiri tiap malam. | I'm Nyai Gendhis. These women have pounded rice in this yard since before my grandmother was born. Now our pestles walk by themselves each night. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LESUNG_WOMEN_H3 | Alunya berjalan sendiri? Roh pembangun candi? | The pestles walk by themselves? The temple builders' spirits? |
| 1 | @NPC_LESUNG_WOMEN_NAME | | |
| 1 | DLG_LESUNG_WOMEN_V12 | Tuyul, kataku, dan arwah suruhan yang kehabisan batu lalu mencuri alu kami. Mereka menumbuk dengan irama yang salah: fajar palsu tiap malam. | Tuyul, I say, and servant spirits who ran out of stone and stole our pestles. They pound with the wrong rhythm: a false dawn every night. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LESUNG_WOMEN_H4 | Fajar palsu? | A false dawn? |
| 1 | @NPC_LESUNG_WOMEN_NAME | | |
| 1 | DLG_LESUNG_WOMEN_V13 | Ayam berkokok dua jam lebih awal, orang bangun, dan tak seorang pun tahu kenapa pagi terasa begitu pendek. Kami berhenti menumbuk supaya tak ikut dalam iramanya. | Roosters crow two hours early, people wake, and no one knows why the night felt so short. We stopped pounding so we wouldn't join their rhythm. |
| 1 | DLG_LESUNG_WOMEN_V14 | Tapi kau membersihkan kuburan itu, dan itu pertanda baik. Bersihkan pelataran kami juga, dan irama yang benar akan kuajarkan. | But you cleansed that graveyard, and that's a good sign. Clear our yard too, and I'll teach you the true rhythm. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_LESUNG_WOMEN_H5 | Aku bukan penumbuk padi. Tapi aku bisa memukul sesuatu. | I'm no rice pounder. But I can hit things. |
| 1 | @NPC_LESUNG_WOMEN_NAME | | |
| 1 | DLG_LESUNG_WOMEN_V15 | Cukup. Alu yang berjalan sendiri bisa dipukul, jangan terlalu keras. Mereka hanya kehilangan majikan. | Enough. A pestle that walks by itself can be hit, just not too hard. They only lost their master. |
| 1 | DLG_LESUNG_WOMEN_V16 | Pelataran lesung ada di timur gubuk ini. Pulanglah dengan selamat, dan kuajarkan Ca. | The lesung yard is east of this hut. Come back safe, and I'll teach you Ca. |
| 2 | @NPC_LESUNG_WOMEN_NAME | | |
| 2 | DLG_LESUNG_WOMEN_V17 | Tuk, tuk, tuk. Dengar? Alu-alu kami kembali padaku. Pelataran ini jinak lagi, dan kau tak minta upah. | Tuk, tuk, tuk. Hear that? Our pestles are back with me. This yard is tame again, and you asked no pay. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_LESUNG_WOMEN_H1 | Sudah kubersihkan. Irama apa itu? | I cleared it. What rhythm is that? |
| 2 | @NPC_LESUNG_WOMEN_NAME | | |
| 2 | DLG_LESUNG_WOMEN_V2 | Irama fajar palsu. Konon dayang Roro Jonggrang, putri kisah seribu candi, menumbuk begini agar ayam berkokok lebih awal. Ini Ca: gambarlah mengikuti irama, dan tanganmu lebih cepat dari amarah. | The false-dawn rhythm. They say the women of Roro Jonggrang, princess of the thousand-temples tale, pounded like this to fake the dawn. This is Ca: draw to the beat, and your hand outruns anger. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_LESUNG_WOMEN_H6 | Ca. Seperti ketukan ketiga. Terasa di tanganku. | Ca. Like the third beat. I feel it in my hand. |
| 2 | @NPC_LESUNG_WOMEN_NAME | | |
| 2 | DLG_LESUNG_WOMEN_V18 | Tangan yang tahu irama tak perlu terburu-buru. Kau menggambar di antara ketukan, bukan di atasnya. | A hand that knows the rhythm needn't hurry. You draw between the beats, not on top of them. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_LESUNG_WOMEN_H7 | Kenapa Nyai mau mengajarkan irama yang dipakai para roh itu? | Why teach me the rhythm those spirits use? |
| 2 | @NPC_LESUNG_WOMEN_NAME | | |
| 2 | DLG_LESUNG_WOMEN_V19 | Karena irama bisa dibalik. Yang mereka pakai untuk membangun, bisa kita pakai untuk membongkar. | Because a rhythm can be turned. What they use to build, we can use to take down. |
| 2 | DLG_LESUNG_WOMEN_V20 | Batu-batu mengepung kuil di kaki bukit tiap malam. Juru kunci terjebak di dalamnya. Patahkan kepungan itu, dan dia akan menemuimu. | The stones besiege the foothill shrine each night. The juru kunci is trapped inside. Break the siege and he'll receive you. |
| 3 | DLG_LESUNG_WOMEN_V21 | Dengar, alu kami berbunyi benar sekarang. Duduklah di tikar. Mau tahu apa? | Listen, our pestles ring true now. Sit on the mat. What would you like to know? |
| T1 | DLG_LESUNG_WOMEN_V22 | Fajar itu bukan cuma matahari. Fajar itu janji bahwa malam punya akhir. Itu sebabnya irama palsu terasa seperti pencurian. | Dawn isn't only the sun. It's a promise that night has an end. That's why a false rhythm feels like theft. |
| T1 | DLG_LESUNG_WOMEN_V23 | Nenekku bilang, alu pertama menumbuk bukan untuk padi tapi untuk memanggil pagi. Padi cuma bonus. | My grandmother said the first pestle pounded not for rice but to call the morning. The rice was a bonus. |
| T1 | DLG_LESUNG_WOMEN_V24 | Kalau kau ragu, dengarkan kokok pertama. Ayam yang benar tak pernah buru-buru. | If in doubt, listen for the first crow. A true rooster is never in a hurry. |
| T2 | DLG_LESUNG_WOMEN_V25 | Kami sembilan, dulu tiga belas. Empat sudah pergi ke tepi sungai, mencari anak lelaki yang berbaris. | We are nine, once thirteen. Four went to the river, looking for sons who marched. |
| T2 | DLG_LESUNG_WOMEN_V26 | Tiap perempuan punya ketukannya sendiri. Kalau satu hilang, lagunya pincang. Itu sebabnya kami memanggil mereka pulang. | Each woman has her own beat. If one is lost, the song limps. That's why we call them home. |
| T2 | DLG_LESUNG_WOMEN_V27 | Kami bukan prajurit. Kami cuma menumbuk. Tapi dengar, kadang menumbuk lebih keras daripada pedang. | We aren't soldiers. We only pound. But listen, sometimes pounding is louder than swords. |
| T3 | DLG_LESUNG_WOMEN_V28 | Para pembangun malam itu bukan jahat, Nak. Mereka lelah. Seribu candi sebelum fajar, lalu fajar tak pernah datang bagi mereka. | The night builders aren't wicked, child. They're tired. A thousand temples before dawn, and then dawn never comes for them. |
| T3 | DLG_LESUNG_WOMEN_V29 | Kalau waktunya tiba, mungkin aku harus berdiri di dekat pangeran mereka dan menumbuk. Lutut-lututku tak suka ide itu. | When the time comes, perhaps I must stand near their prince and pound. My knees don't like that idea. |
| T3 | DLG_LESUNG_WOMEN_V30 | Jangan khawatir. Kami akan menumbuk dari jauh. Dengar, kau akan mendengarnya. | Don't worry. We'll pound from afar. Listen, you'll hear us. |
| 4 | DLG_LESUNG_WOMEN_V10 | Kami menumbuk padi dan bernyanyi. Ikutlah kapan saja. | We pound rice and sing. Join us anytime. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_GENDHIS_ASK_1 | Tanya tentang fajar palsu | Ask about the false dawn | `topic:gendhis_dawn` |
| CHOICE_GENDHIS_ASK_2 | Tanya tentang para perempuan | Ask about the women | `topic:gendhis_women` |
| CHOICE_GENDHIS_ASK_3 | Tanya tentang para pembangun malam | Ask about the night builders | `topic:gendhis_night` |
| CHOICE_GENDHIS_ASK_4 | Terima kasih, Nyai | Thank you, Nyai | |

VERIFY: Roro Jonggrang's women pounding rice to fake the dawn.

### Beat `lesung_yard` (if `!flag:beat_lesung_yard`, `flag:mq2_4`, `zone:mt_wetan`; do `flag:beat_lesung_yard`). 2.9, the puzzle's end: the pestles are given back
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_LESUNG_YARD_1 | Alu terakhir berhenti berjalan dan roboh di samping lesungnya, seperti anjing yang akhirnya diizinkan tidur. | The last pestle stops walking and collapses beside its mortar, like a dog finally allowed to sleep. |
| @NPC_LESUNG_WOMEN_NAME | | |
| BEAT_LESUNG_YARD_2 | Jangan sentuh dulu. Biarkan mereka dingin. Alu yang disentuh saat marah bisa mengingat marahnya setahun. | Don't touch them yet. Let them cool. A pestle touched in anger can remember the anger for a year. |
| @NPC_HERO_NAME | | |
| BEAT_LESUNG_YARD_H1 | Aku memukul keras. Maaf. | I hit them hard. Sorry. |
| @NPC_LESUNG_WOMEN_NAME | | |
| BEAT_LESUNG_YARD_3 | Mereka sudah biasa dipukul oleh orang yang lupa mereka alat. Kau cuma mengingatkan mereka bahwa mereka benda. | They're used to being hit by people who forget they're tools. You only reminded them they're things. |
| @ | | |
| BEAT_LESUNG_YARD_4 | Sembilan perempuan keluar dari gubuk dan mengambil alu masing-masing. Seseorang menumbuk satu ketukan, ragu, lalu satu lagi. | Nine women come out of the hut and each take up a pestle. One pounds a single beat, hesitant, then another. |
| BEAT_LESUNG_YARD_5 | Pelataran itu berdering, dan di kejauhan seekor ayam berkokok pada saat yang benar. | The yard rings, and far off a rooster crows at the right time. |
| @NPC_LESUNG_WOMEN_NAME | | |
| BEAT_LESUNG_YARD_6 | Datanglah, Nak. Sekarang waktunya kuajarkan yang kujanjikan. | Come, child. Now is the time for what I promised you. |

### Chapter 3: The Shifting Night of Candi Seribu (2.11-2.15)

### Beat `night_siege` (if `!flag:beat_night_siege`, `flag:mq2_5`, `zone:mt_wetan`; do `flag:beat_night_siege`). 2.11, the siege begins; the prince's name is not spoken yet
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_NIGHT_SIEGE_1 | Pelajaran selesai, tapi matahari tak jadi terbenam. Langit gelap begitu saja, seperti tirai ditarik, dan satu per satu obor kuil di bukit padam. | The lesson ends, but the sun never sets. The sky simply goes dark, like a curtain drawn, and the shrine torches on the hill go out one by one. |
| BEAT_NIGHT_SIEGE_2 | Dari tanah yang bergetar muncul tangan-tangan batu, lalu bahu, lalu para pembangun tak bermata, menyeret balok untuk mengepung kuil di kaki bukit. | From the trembling earth rise stone hands, then shoulders, then eyeless builders, dragging blocks to ring the shrine at the hill's foot. |
| @NPC_LESUNG_WOMEN_NAME | | |
| BEAT_NIGHT_SIEGE_3 | Mereka mulai lagi, Nak. Malam yang tak mau habis. Dengar, para perempuan menumbuk dari pelataran, tapi suaranya tertelan. | They've started again, child. A night that won't end. Listen, the women pound in the yard, but the sound is swallowed. |
| @ | | |
| BEAT_NIGHT_SIEGE_4 | Dari dalam kuil, sebuah suara tua berteriak: jangan biarkan lingkarannya tertutup, kalau tertutup tak seorang pun keluar sampai fajar. | From inside the shrine an old voice shouts: don't let the circle close, if it closes no one leaves until dawn. |
| @NPC_HERO_NAME | | |
| BEAT_NIGHT_SIEGE_H1 | Itu juru kunci yang dimaksud. Aku harus menembus lingkaran itu sebelum tertutup. | That's the juru kunci she meant. I have to break the circle before it closes. |
| @NPC_LESUNG_WOMEN_NAME | | |
| BEAT_NIGHT_SIEGE_5 | Pergilah! Kami menumbuk dari sini sebisa kami. Irama yang benar memperlambat langkah mereka, sedikit saja. | Go! We'll pound from here as best we can. The true rhythm slows them, a little. |
| @ | | |
| BEAT_NIGHT_SIEGE_6 | Di tengah gelap, lonceng kuil berbunyi tiga kali, lemah, seperti orang tua yang menghitung sisa tenaganya. | In the dark the shrine bell tolls three times, faintly, like an old man counting his remaining strength. |

### Clue `shrine_chisel` (step 2.11; the shrine steps; journal note only; ASSUMED id, not in the zone doc; hunt `k3`)
| Key | ID | EN |
|-----|----|----|
| CLUE_SHRINE_CHISEL_1 | Anak tangga kuil dipahat semalam: bekasnya rapi, tapi tak ada serpih dan tak ada jejak alat, hanya cap jari dingin. | The shrine steps were cut overnight: neat work, but no chips and no tool marks, only cold fingerprints. |
| CLUE_SHRINE_CHISEL_2 | Bukan tukang yang mengerjakan ini. Ini pekerjaan orang yang tak boleh berhenti. | No mason did this. It's the work of someone who isn't allowed to stop. |
| CLUE_SHRINE_CHISEL_NOTE | Anak tangga kuil dipahat semalam, tanpa jejak alat. | Shrine steps cut overnight, with no tool marks. |

### juru_kunci (Sang Juru Kunci; replace all entries). Steps 2.12 `puzzle_solved:puzzle_wetan_lamps`, then `glyph_learned:jawa_ra`
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=11`, `!flag:puzzle_wetan_lamps` | |
| 2 | `step:mq2=11`, `flag:puzzle_wetan_lamps` (2.12) | `learn:jawa_ra` |
| 3 | `quest:mq2=active`, `flag:mq2_6` | |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_JURU_KUNCI_NAME | | |
| 1 | DLG_JURU_KUNCI_V1 | Blokade itu runtuh? Dua hari aku tak bisa turun menyalakan dupa. Aku juru kunci bukit ini, penjaga kunci candi. | The blockade fell? Two days I couldn't come down to light incense. I'm the juru kunci of this hill, keeper of the temple keys. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_JURU_KUNCI_H1 | Kata orang, Mbah memegang kunci Candi Seribu. | They say you hold the keys to Candi Seribu. |
| 1 | @NPC_JURU_KUNCI_NAME | | |
| 1 | DLG_JURU_KUNCI_V2 | Kunci, ya. Tapi para tanpa rupa berkemah di dalamnya dan membangunkan kutukan prajurit lama. Kunci tak berguna lagi. | The keys, yes. But the faceless have camped inside and woken the old soldiers' curse. Keys are no use now. |
| 1 | DLG_JURU_KUNCI_V7 | Para pembangun malam menyalakan api palsu di empat tungku kuil supaya kutukan malam tak pernah padam. Selaraskan keempatnya, dan kutukan itu retak. | The night builders lit false fires in the shrine's four braziers so the night-curse never goes out. Align all four, and the curse cracks. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_JURU_KUNCI_H3 | Bagaimana aku tahu urutannya? | How do I know the order? |
| 1 | @NPC_JURU_KUNCI_NAME | | |
| 1 | DLG_JURU_KUNCI_V8 | Tungku yang menyala paling dingin dulu, yang paling panas terakhir. Kalau salah, semuanya menyala lagi dan kau mengulang. | The coolest-burning brazier first, the hottest last. If you err, they all flare again and you start over. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_JURU_KUNCI_H4 | Dan kunci yang Mbah pegang? | And the key you hold? |
| 1 | @NPC_JURU_KUNCI_NAME | | |
| 1 | DLG_JURU_KUNCI_V9 | Kubuka setelah apinya serempak. Tangga candi menunggu, tapi api dulu. Lututku tak sanggup menjaga api sendirian. | I open it once the fires match. The temple stairs wait, but fire first. My knees can't keep the fire alone. |
| 2 | @NPC_JURU_KUNCI_NAME | | |
| 2 | DLG_JURU_KUNCI_V10 | Api itu serempak. Kutukan malam pecah seperti telur retak. Kau bertangan sabar, Nak. | The fires match. The night-curse breaks like a cracked egg. You have patient hands, child. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_JURU_KUNCI_H5 | Mbah bilang Ra. Bagaimana menggambarnya? | You said Ra. How do I draw it? |
| 2 | @NPC_JURU_KUNCI_NAME | | |
| 2 | DLG_JURU_KUNCI_V11 | Satu napas panjang, dua kaki yang berlari, ekor melengkung di akhir. Macan tak lari lurus, ia memutar dulu. | One long breath, two running legs, a curled tail at the end. A tiger doesn't run straight, it circles first. |
| 2 | DLG_JURU_KUNCI_V3 | Ra. Roh macan berjalan di sisimu, dan yang terkutuk berbalik menghadapinya. Saat itu, pukul punggungnya. Tangga candi kubuka. | Ra. A tiger spirit walks beside you, and the cursed turn to face it. That's when you strike their backs. The temple stairs are open. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_JURU_KUNCI_H6 | Roh macan itu akan menetap di sisiku? | The tiger spirit will stay beside me? |
| 2 | @NPC_JURU_KUNCI_NAME | | |
| 2 | DLG_JURU_KUNCI_V12 | Selama nyala di dadamu tak padam. Kalau padam, ia pulang ke gunung. Hati-hati di dataran berbatu: batu tumbuh kalau tak ada yang menatapnya. | As long as the flame in your chest holds. If it dies, it goes home to the mountain. Mind the plain of stones: stones grow when no one watches them. |
| 3 | DLG_JURU_KUNCI_V5 | Hancurkan perkemahan itu. Arwah di sini berhak tidur tenang. | Break that camp. The dead here deserve their sleep. |
| 4 | DLG_JURU_KUNCI_V6 | Hati-hati di gerbang candi. Batunya bisa runtuh. | Mind the temple gate. Stones can fall. |

### Clue `pillar_prints` (step 2.13; on the plain of rising stones; journal note only; ASSUMED id, not in the zone doc; hunt `k3`)
| Key | ID | EN |
|-----|----|----|
| CLUE_PILLAR_PRINTS_1 | Di dataran batu, tiap pilar baru berdiri di atas sepasang telapak kaki yang terbenam, kaki orang yang diseret ke sini sambil tidur. | On the plain, every new pillar stands on a pair of sunken footprints, the feet of people dragged here asleep. |
| CLUE_PILLAR_PRINTS_2 | Candi ini dibangun dari orang yang lupa pulang. | This temple is built from people who forgot the way home. |
| CLUE_PILLAR_PRINTS_NOTE | Pilar-pilar tumbuh di atas jejak kaki orang yang tertidur. | Pillars grow over the footprints of sleepwalkers. |

### Beat `pillars_fall` (if `!flag:beat_pillars_fall`, `flag:mq2_6b`, `zone:mt_tegal`; do `flag:beat_pillars_fall`). 2.13, the plain is open
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_PILLARS_FALL_1 | Pilar terakhir retak dari atas ke bawah dan runtuh menjadi pasir. Di seberang dataran, jalan candi terbuka, lurus dan putih di bawah bulan palsu. | The last pillar cracks top to bottom and collapses into sand. Across the plain the temple road lies open, straight and white under a false moon. |
| BEAT_PILLARS_FALL_2 | Di dasar reruntuhan itu, sehelai kapur putih: Ka, goyah, ditulis sebelum pilarnya didirikan di atasnya. | At the base of the rubble a streak of white chalk: Ka, shaky, written before the pillar was raised over it. |
| @NPC_HERO_NAME | | |
| BEAT_PILLARS_FALL_H1 | Dia menandai tiap tempat yang dilewatinya, bahkan yang akan ditimpa batu. | She marks every place she passes, even the ones stone will bury. |
| @ | | |
| BEAT_PILLARS_FALL_3 | Para pembangun yang tersisa berhenti serempak, alat batu mereka terangkat setengah. Tak ada yang melanjutkan. | The remaining builders stop in unison, stone tools half raised. None goes on. |
| BEAT_PILLARS_FALL_4 | Dari jauh, pelan, terdengar ketukan lesung. Ca: irama yang benar, melewati batu-batu. | From far off, faintly, the knock of lesung. Ca: the true rhythm, carried over the stones. |
| @NPC_HERO_NAME | | |
| BEAT_PILLARS_FALL_H2 | Nyai Gendhis masih menumbuk. Aku harus cepat sebelum mereka kelelahan. | Nyai Gendhis is still pounding. I have to hurry before they tire. |
| @ | | |
| BEAT_PILLARS_FALL_5 | Di ujung jalan, gerbang luar Candi Seribu menunggu, tinggi dan bergerigi. | At the road's end the outer gate of Candi Seribu waits, tall and jagged. |

### hauler (mt_candi, at the temple gate; name NPC_HAULER_NAME; new; step 2.14 `talk`, `"quiet": true`)
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq2_6b`, `!flag:mq2_7` | |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_HAULER_NAME | | |
| 1 | DLG_HAULER_V1 | Jangan injak talinya... Aku di mana? Tadi malam aku mengangkat batu untuk candi yang belum pernah kulihat. | Don't step on the rope... Where am I? Last night I was lifting stone for a temple I've never seen. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_HAULER_H1 | Kau di gerbang luar Candi Seribu. Siapa namamu? | You're at the outer gate of Candi Seribu. What's your name? |
| 1 | @NPC_HAULER_NAME | | |
| 1 | DLG_HAULER_V2 | Tukang atap dari kampung di bawah. Dua malam lalu seseorang membaca keras-keras dari bukit ini, lalu aku lupa semuanya. | A roof-thatcher from the village below. Two nights ago someone read aloud from this hill, and then I forgot everything. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_HAULER_H2 | Membaca? Siapa? | Reading? Who? |
| 1 | @NPC_HAULER_NAME | | |
| 1 | DLG_HAULER_V3 | Seorang gadis, suaranya kecil dan tak gentar. Dia membaca sampai batu berderak. Para bertopeng menahan napas. | A girl, with a small unafraid voice. She read until the stones creaked. The masked ones held their breath. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_HAULER_H3 | Dia masih di sana? | Is she still there? |
| 1 | @NPC_HAULER_NAME | | |
| 1 | DLG_HAULER_V4 | Mereka menahannya di ruang tengah halaman, dengan meja panjang. Tiga penjaga di pintu, dan seorang kapten bertombak berhias. | They kept her in the room in the middle of the court, with a long table. Three guards at the door, and a captain with an ornate spear. |
| 1 | DLG_HAULER_V5 | Kalau mau masuk, jangan lewat tengah gerbang. Batunya sudah bergeser. Ikuti tepi yang berlumut. | If you go in, don't use the gate's middle. The stones have shifted. Follow the mossy edge. |
| 2 | DLG_HAULER_V6 | Kakiku masih bergetar seperti memanggul batu. Orang bilang itu hilang sendiri. | My legs still shake as if I carried stone. They say it passes. |

### Beat `lengser_word` (if `!flag:beat_lengser_word`, `flag:choice_handed`, `flag:mq2_6`, `zone:mt_wetan`; do `flag:beat_lengser_word`). Choice 2, handed: Lengser's extracted layout; opens `sc:mt_candi_crypt` early
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_LENGSER_WORD_1 | Titipan dari Uwa: si pembelot menggambar denah kemah itu di tanah. Gerbang barat penjaganya lengah. | A word from Uwa: the deserter drew the camp's layout in the dirt. The west gate is poorly watched. |
| BEAT_LENGSER_WORD_2 | Seorang kurir Galuh menyerahkan segulung kain, denah dengan arang: lorong bawah tanah di bawah altar, ditandai silang kecil. | A Galuh courier hands over a roll of cloth, a charcoal plan: a passage beneath the altar, marked with a small cross. |
| @NPC_HERO_NAME | | |
| BEAT_LENGSER_WORD_H1 | Ranga menggambar ini? Dia masih ingat jalan, rupanya. | Ranga drew this? He still remembers corridors, then. |
| @ | | |
| BEAT_LENGSER_WORD_3 | Kurir itu mengangguk. Satu giliran jaga di kemah dikurangi, dan lorong bawah tanah bisa dibuka lebih awal. | The courier nods. One watch of the camp is cut, and the passage underground can be opened early. |

### Beat `ranga_word` (if `!flag:beat_ranga_word`, `flag:choice_freed`, `flag:mq2_6`, `zone:mt_wetan`; do `flag:beat_ranga_word`). Choice 2, freed: Ranga scouts in Act III (`SQ-C3`); trigger `beat_ranga_word` is ASSUMED, at the same spot as `lengser_word`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_RANGA_WORD_1 | Di tangga kaki bukit, sebuah topeng retak tergantung di dahan, persis seperti yang dijanjikannya. Di bawahnya, orang yang dikenalnya sedang jongkok. | On the stairs at the hill's foot a cracked mask hangs from a branch, exactly as promised. Beneath it a man you know crouches. |
| @NPC_RANGA_NAME | | |
| BEAT_RANGA_WORD_2 | Aku mengikuti mereka dua hari. Kemah itu ruang baca, bukan penjara. Mereka membaca keras-keras, dan para tawanan menanggung kalau berhenti. | I trailed them two days. That camp is a reading room, not a prison. They read aloud, and the captives pay when it stops. |
| @NPC_HERO_NAME | | |
| BEAT_RANGA_WORD_H1 | Ranga. Kau ingat namamu tiap malam? | Ranga. Do you remember your name each night? |
| @NPC_RANGA_NAME | | |
| BEAT_RANGA_WORD_3 | Tiap malam, sampai suaraku serak. Gerbang barat penjaganya lengah, dan satu lorong turun dari altar. Aku tak berani turun sendirian. | Every night, till I'm hoarse. The west gate is lightly watched, and one passage descends from the altar. I didn't dare go down alone. |
| @ | | |
| BEAT_RANGA_WORD_4 | Ia menghilang di balik akar, meninggalkan topeng retak itu berayun pelan, seperti pertanda. | He slips behind the roots, leaving the cracked mask swaying slowly, like a sign. |

### Beat `camp` (if `!flag:beat_camp`, `flag:mq2_7`; do `flag:beat_camp`). The turn
| Key | ID | EN |
|-----|----|----|
| BEAT_CAMP_1 | Perkemahan itu bukan penjara. Meja panjang, lontar terbentang, batu-batu tersusun: sebuah ruang baca. | The camp is no prison. Long tables, lontar spread open, stones stacked: a reading room. |
| BEAT_CAMP_4 | Di ujung tiap meja ada bangku kecil dan sebuah cangkir tanah berisi air yang sudah dingin. Tempat orang yang dipaksa membaca berjam-jam. | At the head of each table stands a small stool and a clay cup of cold water. The place of someone forced to read for hours. |
| BEAT_CAMP_2 | Di lantai, secarik lontar yang robek dari separuh miliknya, penuh satu huruf yang ditulis berulang-ulang: Ka. Makin lama makin goyah. | On the floor, a strip torn from her half of the lontar, covered with one letter written again and again: Ka. Shakier each time. |
| @NPC_HERO_NAME | | |
| BEAT_CAMP_H1 | Dia di sini. Dia menulis Ka sampai tangannya gemetar. | She was here. She wrote Ka until her hand shook. |
| @ | | |
| BEAT_CAMP_5 | Di sudut meja, serpihan mirip tinta kering dan satu helai rambut hitam kusut. Kau menyimpan helai itu di balik bajumu. | In a corner of the table, flakes like dried ink and one tangled black hair. You tuck the hair inside your shirt. |
| BEAT_CAMP_2B | Para tanpa rupa sudah membawanya ke timur. Di bawah tanah, seribu candi berderak, dan Bandung Bondowoso bangun, sang pangeran pembangun seribu candi. | The faceless have taken her east. Underground, a thousand temples creak, and Bandung Bondowoso wakes, the prince who builds a thousand temples. |
| @NPC_HERO_NAME | | |
| BEAT_CAMP_H2 | Dia dibawa pergi, tapi dia meninggalkan jejak. Aku akan membaca semuanya. | She was taken away, but she left a trail. I'll read all of it. |
| @ | | |
| BEAT_CAMP_6 | Di lantai di bawah kaki, batu bergetar. Sesuatu besar menggeser dirinya di kedalaman candi. | Underfoot the stone trembles. Something large shifts itself deep within the temple. |

### Clues K3 (step 2.15; `ka_strip` starts `k3_lesung`)
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

### Chapter 4: The Thousandth Pillar (2.16-2.19)

### Laras chapter LC3 `lc3` (step 2.16; kind chapter; the reading room at Candi Seribu; sets `mq2_lc`, `flag:laras_key_candi_crypt` and `flag:laras_sabotage_bondowoso_pillar`). The game makes her read; the chapter shows why
| Key | ID | EN |
|-----|----|----|
| LC_3_TITLE | Ruang Baca | The Reading Room |
| @NPC_LARAS_NAME | | |
| LC3_1 | Mereka bilang: baca, atau tawanan yang menanggung. Tangan mereka tidak bohong. | They say: read, or the prisoners pay. Their hands don't lie. |
| LC3_2 | Aku menolak sekali. Seorang tawanan berteriak. Aku tak akan mencoba itu lagi. | I refuse once. A prisoner cries out. I won't try that again. |
| LC3_5 | Di pojok, seorang pemuda diikat di tiang: murid Ki Sumarto, katanya. Kunyanyikan sebaris wayang, supaya dia tahu namanya masih disebut. | In the corner a young man is tied to a post: Ki Sumarto's apprentice, he says. I hum a line of wayang, so he knows his name is still said. |
| LC3_6 | Dia membisikkan pintu di balik altar menuju bawah tanah. Palangnya berat, tapi kugeser pelan sambil membaca keras, supaya besinya tak terdengar. | He whispers of a door behind the altar leading underground. The bar is heavy, but I slide it slowly while reading aloud, so the iron isn't heard. |
| LC3_7 | Palangnya bergeser. Satu Ka kecil kutinggalkan di kayu pintu. Kak, kalau kau lewat sini, itu jalanku. | The bar slides. I leave one small Ka on the door wood. Kak, if you come this way, that's my path. |
| LC3_8 | Pahat induk si pembangun ada di atas altar, pahat perak yang selalu hangat. Waktu penjaga menoleh, kusembunyikan di bawah alas altar. | The builder's master chisel lies on the altar, a silver chisel always warm. When the guard turns, I hide it beneath the altar cloth. |
| LC3_9 | Ayat keseribu tak kubaca. Kuloncati, dan batu di atas bergemeretak marah. Pilar itu kini tahu ada yang tak lengkap. | I don't read the thousandth verse. I skip it, and the stone overhead grinds with anger. The pillar now knows something is missing. |
| LC3_3 | Aku membaca, dan salah satu huruf sengaja kubalik. Segelnya tetap retak. Maaf. | I read, and I flip one letter on purpose. The seal cracks anyway. Sorry. |
| LC3_4 | Kak, aku membaca karena mereka menyakiti tawanan kalau aku diam. Aku tahu itu salah. Tetap saja. Kutulis Ka lagi malam ini. | Kak, I read because they hurt the prisoners when I don't. I know it's wrong. I did it anyway. I wrote Ka again tonight. |

### Beat `crypt_door` (if `!flag:beat_crypt_door`, `flag:mq2_lc`, `zone:mt_candi`; do `flag:beat_crypt_door`). 2.17, Laras's door is found open
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_CRYPT_DOOR_1 | Di balik altar yang dingin, sebuah pintu kayu berdiri sedikit terbuka. Palangnya tergeser ke samping, tergores Ka kecil. | Behind the cold altar a wooden door stands ajar. Its bar is slid aside, a small Ka scratched into it. |
| @NPC_HERO_NAME | | |
| BEAT_CRYPT_DOOR_H1 | Jadi ini jalan yang dia buka. Dia memikirkan semuanya, bahkan arah tangga. | So this is the way she opened. She thought of everything, even the stair direction. |
| @ | | |
| BEAT_CRYPT_DOOR_2 | Tangga menurun ke bawah, dan dari bawah naik hawa lembap serta bunyi pahat yang tak berhenti. Di dindingnya, cap tangan kecil: tangan seorang anak. | The stairs descend, and from below rises damp air and the sound of chisels that never stop. On the wall, a small hand-print: a child's. |
| @NPC_HERO_NAME | | |
| BEAT_CRYPT_DOOR_H2 | Aku datang, Laras. Turun pelan, bunyi pahat itu akan menutupi langkahku. | I'm coming, Laras. Down slowly, the chisels will cover my steps. |

### Memory `k3_lesung` (play; K3, step 2.18; kelir figure: one of Roro Jonggrang's women; the action pounds the lesung to a 3-bar beat)
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

### Beat `bondowoso_rise` (if `!flag:beat_bondowoso_rise`, `flag:mq2_h2`, `zone:mt_candi`; do `flag:beat_bondowoso_rise`). 2.19, the boss as a character before the fight
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_BONDOWOSO_RISE_1 | Di inti candi, seribu pilar kecil mengitari lantai berundak. Tinggal satu tempat yang belum berpilar, dan di sana seorang pemuda berbaju kebesaran sedang memahat. | At the temple's heart a thousand small pillars ring a stepped floor. One place is still empty, and there a young man in royal cloth is carving. |
| @NPC_BANDUNG_BONDOWOSO_NAME | | |
| BEAT_BONDOWOSO_RISE_2 | Seribu candi sebelum fajar. Seorang putri memintanya. Aku sudah memberinya sembilan ratus sembilan puluh sembilan, dan ayam berkokok. | A thousand temples before dawn. A princess asked it of me. I gave her nine hundred and ninety-nine, and the roosters crowed. |
| @NPC_HERO_NAME | | |
| BEAT_BONDOWOSO_RISE_H1 | Itu fajar palsu. Para perempuan penumbuk padi yang menipumu. | That was a false dawn. The rice-pounding women tricked you. |
| @NPC_BANDUNG_BONDOWOSO_NAME | | |
| BEAT_BONDOWOSO_RISE_3 | Kau tahu ceritaku. Kalau begitu kau tahu aku tak boleh berhenti. Tiap malam aku mulai lagi, dan tiap malam kurang satu. | You know my story. Then you know I can't stop. Each night I begin again, and each night I'm one short. |
| @NPC_HERO_NAME | | |
| BEAT_BONDOWOSO_RISE_H2 | Berhentilah. Malam ini fajarnya sungguhan. | Stop. Tonight the dawn will be real. |
| @NPC_BANDUNG_BONDOWOSO_NAME | | |
| BEAT_BONDOWOSO_RISE_4 | Aku tak bisa. Pilar-pilarku tak tahu caranya. | I can't. My pillars don't know how. |
| @ | | |
| BEAT_BONDOWOSO_RISE_5 | Pilar-pilar mengelilinginya bergetar, lalu satu per satu mencuat dari lantai, menghalangi jalan masuk. Di kejauhan, sangat samar, lesung berbunyi. | The pillars around him tremble, then jut one by one from the floor, blocking the way in. Far away, very faintly, lesung sound. |

### Beat `bondowoso_end` (if `!flag:beat_bondowoso_end`, `flag:mq2_7b`; do `flag:beat_bondowoso_end`, `codex:bandung_bondowoso`, `codex:nyai_gendhis`). 2.19, the beat: the night ends, nobody is killed
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_BONDOWOSO_END_1 | Pilar terakhir retak serempak dengan ketukan lesung. Dari kejauhan, seekor ayam berkokok pada saat yang benar, dan langit mulai pucat di atas candi. | The last pillar cracks in time with the lesung beat. From far away a rooster crows at the right hour, and the sky pales above the temple. |
| @NPC_BANDUNG_BONDOWOSO_NAME | | |
| BEAT_BONDOWOSO_END_2 | Fajar. Fajar yang sungguhan. Sudah berapa tahun... Sudah berapa ratus tahun aku tak mendengar ayam yang jujur. | Dawn. A real dawn. How many years... how many hundred years since I heard an honest rooster. |
| @NPC_HERO_NAME | | |
| BEAT_BONDOWOSO_END_H1 | Letakkan pahatmu. Tak ada yang menghukummu karena kurang satu. | Put down your chisel. No one will punish you for being one short. |
| @NPC_BANDUNG_BONDOWOSO_NAME | | |
| BEAT_BONDOWOSO_END_3 | Gadis kecil pembaca itu melewatkan ayat keseribu. Itu pertama kalinya ada yang tak menyelesaikan bacaan untukku. | The small girl reader skipped the thousandth verse. It's the first time anyone left a reading unfinished for me. |
| @NPC_HERO_NAME | | |
| BEAT_BONDOWOSO_END_H2 | Adikku. Ke mana mereka membawanya? | My sister. Where did they take her? |
| @NPC_BANDUNG_BONDOWOSO_NAME | | |
| BEAT_BONDOWOSO_END_4 | Ke timur, tapi jalannya tertutup kabut selama dua saudara masih berseteru di sungai yang disebut pamali. Mereka menunggumu di sana, dan keduanya benar. | East, but the road is shut in fog while two brothers still feud at the river called pamali. They wait for you there, and both are right. |
| @ | | |
| BEAT_BONDOWOSO_END_5 | Para pembangun menurunkan alat batu mereka serempak, lalu menjadi debu halus yang ditiup angin pagi. | The builders lower their stone tools in unison, then crumble to fine dust on the morning wind. |
| BEAT_BONDOWOSO_END_7 | Bondowoso duduk di tangga, memandang lantai kosong, dan untuk pertama kalinya ia tidak memahat. | Bondowoso sits on the steps, looking at the empty floor, and for the first time he does not carve. |
| @NPC_BANDUNG_BONDOWOSO_NAME | | |
| BEAT_BONDOWOSO_END_6 | Pergilah. Tutup pintu candi pelan-pelan. Orang-orang yang kutarik ke sini sedang bangun, dan mereka akan lapar. | Go. Close the temple door gently. The people I dragged here are waking, and they'll be hungry. |

### Chapter 5: Blood on the Pamali Ford (2.20-2.24)

### Beat `river_return` (if `!flag:beat_river_return`, `flag:mq2_7c`, `zone:kg_pamali`; do `flag:beat_river_return`). 2.20, the river from the east bank, two camps and no talk
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_RIVER_RETURN_1 | Sungai Pamali terbentang lebar dan tenang, terlalu tenang untuk batas dua pasukan. Di tepi barat panji Ciung, di tepi timur panji Hariang Banga. | The Pamali lies wide and calm, too calm for a border between two armies. On the west bank flies Ciung's banner, on the east Hariang Banga's. |
| BEAT_RIVER_RETURN_2 | Kedua kemah berasap, tapi tak seorang pun menyeberang. Di tengah, di atas batu ceper, burung-burung bangau berdiri satu kaki dan menonton. | Both camps smoke, but no one crosses. In the middle, on a flat stone, herons stand on one leg and watch. |
| @NPC_HERO_NAME | | |
| BEAT_RIVER_RETURN_H1 | Dua pasukan yang saling menunggu salah langkah. Mereka tak butuh Kala, mereka cukup dengan ini. | Two armies waiting for the other's misstep. They don't need Kala, they have enough with this. |
| @ | | |
| BEAT_RIVER_RETURN_3 | Di tepi barat, beberapa prajurit bertopeng halus berjaga di dekat sebuah batu batas tua, mengelilinginya seperti pelayat. | On the west bank a few smooth-masked soldiers stand by an old boundary stone, ringing it like mourners. |
| @NPC_HERO_NAME | | |
| BEAT_RIVER_RETURN_H2 | Batu itu. Itu yang dikerik. Aku harus tiba lebih dulu daripada mereka. | That stone. That's the one scraped bare. I have to get there before they do. |
| @ | | |
| BEAT_RIVER_RETURN_4 | Dari kemah timur, sebuah terompet berbunyi sekali, panjang. Di kemah barat, seseorang menjawab dengan dua nada pendek. | From the east camp a horn sounds once, long. In the west camp someone answers with two short notes. |

### pamali_stone (kg_pamali, cond `flag:mq2_7`; name NPC_PAMALI_STONE_NAME). Step 2.21, `name_written:nagawiru`
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq2=20` (2.21) | `write:nagawiru:jawa_na,sunda_ga` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_PAMALI_STONE_V1 | Batu batas tua di Sungai Pamali, sungai "yang tak boleh dilanggar". Dulu sebuah nama dipahat di sini, lalu dikikis. | An old boundary stone on the Pamali, the river of "what must not be done". A name was cut here once, then scraped away. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PAMALI_STONE_H1 | Nagawiru. | Nagawiru. |
| 1 | @NPC_PAMALI_STONE_NAME | | |
| 1 | DLG_PAMALI_STONE_V2 | Tuliskan kembali: Na dari timur, Ga dari barat. Kandang hanya menahan orang. Nama harus ditulis. | Write it back: Na from the east, Ga from the west. A cage only holds a man. A name has to be written. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PAMALI_STONE_H2 | Na dari timur, Ga dari barat. Dua tepi sungai? | Na from the east, Ga from the west. The two banks? |
| 1 | @NPC_PAMALI_STONE_NAME | | |
| 1 | DLG_PAMALI_STONE_V4 | Dua huruf, dua tepi, satu nama. Raja yang dikikis ini tak pernah ingin satu tepi pun tanpa dirinya. | Two letters, two banks, one name. The scraped king never wanted either bank without him. |
| 1 | DLG_PAMALI_STONE_V5 | Tulis pelan. Batu tak mengampuni goresan yang ragu. | Write slowly. Stone doesn't forgive a wavering stroke. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_PAMALI_STONE_H3 | Aku ragu. Tapi aku tahu namanya. | I'm unsure. But I know the name. |
| 1 | @NPC_PAMALI_STONE_NAME | | |
| 1 | DLG_PAMALI_STONE_V6 | Itu cukup. Nama tak butuh yakin, hanya benar. | That's enough. A name doesn't need certainty, only to be right. |
| 2 | DLG_PAMALI_STONE_V3 | Nama itu bertahan. Suara sungai kini terdengar lain. | The name holds. The river sounds different now. |

### Beat `pamali_name` (if `!flag:beat_pamali_name`, `flag:mq2_8`, `zone:kg_pamali`; do `flag:beat_pamali_name`). 2.21, the beat: Seal 2 is restored
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_PAMALI_NAME_1 | Huruf terakhir selesai, dan batu itu bergetar seperti bel yang dipukul pelan. Di sungai, riak membentuk lingkaran besar yang tak mau berhenti. | The last letter is done, and the stone hums like a bell struck gently. In the river a ripple forms a great circle that won't stop. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_PAMALI_NAME_2 | Na. Ga. Lima belas tahun aku tak mendengar dua bunyi itu bersama. Terima kasih, penulis. | Na. Ga. Fifteen years I haven't heard those two sounds together. Thank you, writer. |
| @NPC_HERO_NAME | | |
| BEAT_PAMALI_NAME_H1 | Namamu sudah pulang. Aku cuma menuliskannya. | Your name is home. I only wrote it. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_PAMALI_NAME_3 | Menuliskan itulah pulang. Segel kedua pulih sedikit. Kala masih lapar, tapi satu pintu tertutup. | Writing it is the coming home. The second seal mends a little. Kala is still hungry, but one door is shut. |
| @ | | |
| BEAT_PAMALI_NAME_4 | Retakan di batu itu menutup pelan, goresan pertama yang dulu menjadi awal semua kemalangan. | The crack in the stone closes slowly, the first scrape that began all the misfortune. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_PAMALI_NAME_5 | Di tepi timur, seorang pemuda menulis surat yang tak pernah terkirim. Ia lebih dekat pada Ciung daripada keduanya sadari. | On the east bank a young man writes letters that are never sent. He is closer to Ciung than either of them knows. |
| @NPC_HERO_NAME | | |
| BEAT_PAMALI_NAME_H2 | Hariang Banga. Aku akan menemuinya. | Hariang Banga. I'll meet him. |
| @NPC_NAGAWIRU_NAME | | |
| BEAT_PAMALI_NAME_6 | Dengarkan dalang di tepi itu dulu. Lakonnya menjawab apa yang kutinggalkan. | Hear the dalang on that bank first. His lakon answers what I left behind. |

### ki_sumarto (kg_pamali, the ford camp; name NPC_MATARAM_DALANG_NAME; a staging figure, id from the zone doc, same character as `mataram_dalang`). Step 2.22 `talk`, `"quiet": true`
| Entry | if | do |
|-------|----|----|
| 1 | `flag:mq2_h5`, `!flag:mq2_h3` | |
| 2 | `flag:mq2_8`, `!flag:mq2_h5` | |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_MATARAM_DALANG_NAME | | |
| 1 | DLG_KI_SUMARTO_V1 | Selesai. Dua tepi menonton dan tak seorang pun bertepuk. Itu pujian tertinggi untuk lakon ini. | Done. Two banks watched and no one clapped. That's the highest praise for this tale. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_KI_SUMARTO_H1 | Ki, Anda memainkannya untuk dua pangeran itu? | Ki, you played it for those two princes? |
| 1 | @NPC_MATARAM_DALANG_NAME | | |
| 1 | DLG_KI_SUMARTO_V2 | Untuk dua tepi. Tak seorang pun bilang lakon itu tentang mereka, jadi tak seorang pun bisa marah. Begitulah wayang bekerja. | For two banks. No one said the tale was about them, so no one can be angry. That's how wayang works. |
| 1 | DLG_KI_SUMARTO_V3 | Anakku ada di antara prajurit timur. Aku mencarinya sejak senja dan belum menemukannya di antara wajah-wajah itu. | My son is among the eastern soldiers. I've looked for him since dusk and haven't found him among those faces. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_KI_SUMARTO_H2 | Dia akan pulang, Ki. Aku yakin begitu. | He will come home, Ki. I'm sure of it. |
| 1 | @NPC_MATARAM_DALANG_NAME | | |
| 1 | DLG_KI_SUMARTO_V4 | Keyakinan itu murah, Nak, tapi kuterima. Pergilah ke kemah timur. Pangeran mereka menulis surat tiap malam, dan suratnya masih di meja. | Certainty is cheap, child, but I accept it. Go to the east camp. Their prince writes letters every night, and the letters are still on the table. |
| 2 | @NPC_MATARAM_DALANG_NAME | | |
| 2 | DLG_KI_SUMARTO_V5 | Kelirku sudah kupasang di dekat api unggun. Duduk dan tonton, Nak. Kau akan lihat lakon yang kuhafal sejak kecil. | My screen is up by the campfire. Sit and watch, child. You'll see a tale I've known since I was small. |
| 2 | DLG_KI_SUMARTO_V6 | Dua tepi menonton, jadi malam ini tak ada yang membawa pedang ke api unggun. Itulah gunaku di sini. | Both banks are watching, so tonight no one brings a sword to the fire. That's my use here. |
| 3 | DLG_KI_SUMARTO_V7 | Kelir sudah kulipat. Ceritanya sudah selesai, tinggal yang menontonnya yang harus memutuskan. | The screen is folded. The story is done, and those who watched must decide. |

### Clue `sumarto_show` and memory `k_iii` (step 2.22; K-III, kind walk; Ki Sumarto's show at the ford camp, cond `flag:mq2_8`)
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

### Clue `hariang_letters` (step 2.23; the person-boss clue)
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
| @NPC_HERO_NAME | | |
| BEAT_FORD_H2 | Aku membaca suratmu. Maaf. Suratmu tak seharusnya dibaca orang asing. | I read your letters. I'm sorry. They shouldn't be read by a stranger. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_FORD_4 | Jadi kau tahu aku tak membenci siapa pun. Aku hanya tak punya cara lain untuk sampai ke ibuku. | Then you know I hate no one. I just have no other road to my mother. |
| @ | | |
| BEAT_FORD_5 | Ia mencabut pedangnya perlahan, bukan seperti orang marah, melainkan seperti orang yang menyelesaikan sebuah janji. Air sungai berkilau di bilahnya. | He draws his sword slowly, not like an angry man but like someone finishing a promise. The river glitters on the blade. |

### Beat `truce` (if `!flag:beat_truce`, `quest:mq2=done`; do `flag:beat_truce`, `codex:pamali`, `codex:roro_jonggrang`, `lakon:roro_jonggrang`, `start:mq3`). Choice 3
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
| BEAT_TRUCE_8 | Dan ibuku. Dia dikurung di Galuh, dan aku menyerah di sungai. Aku tak tahu apa yang akan terjadi padanya. | And my mother. She's caged in Galuh, and I've yielded at the river. I don't know what will become of her. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_TRUCE_5 | Dan orang di kandang itu? Kau yang membawa kami sampai sini. Kau yang bilang. | And the man in the cage? You got us here. You tell me. |
| BEAT_TRUCE_9 | Aku tak mau jadi raja yang haus balas. Tapi aku juga tak mau jadi raja yang lupa. Katakan pendapatmu. | I won't be a king thirsty for revenge. But I won't be a king who forgets either. Tell me what you think. |

Choice 3, shown under the last line:

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_TRUCE_1 | Beri mereka sel yang terang di pelataran, dan ampuni prajurit timur. | Give them a lit cell in the courtyard, and pardon the eastern soldiers. | `flag:choice_mercy` |
| CHOICE_TRUCE_2 | Biarkan hukum Galuh berjalan, dan perkuat jaga di tepi sungai. | Let Galuh's law run its course, and fortify the river watch. | `flag:choice_judgment` |

Nagawiru speaks from the water and Ciung Wanara stands on the west bank. Pangrenyep stays caged. Choice 3 replaces v4's "Choice 2"; `choice_judgment` replaces `choice_silent`.

### Beat `truce_mercy` (if `!flag:beat_truce_mercy`, `flag:choice_mercy`; do `flag:beat_truce_mercy`). Choice 3, mercy: the consequence plays at once
| Key | ID | EN |
|-----|----|----|
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_TRUCE_MERCY_1 | Sel terang di pelataran, lampunya dinyalakan tiap malam, dan prajurit timur pulang dengan senjata di punggung. Baik. Aku setuju. | A lit cell in the courtyard, the lamp lit each night, and the eastern soldiers going home with weapons on their backs. Good. I agree. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_TRUCE_MERCY_2 | Kau tak harus melakukannya. Aku baru saja mengangkat pedang ke arahmu. | You needn't do this. I just raised a sword at you. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_TRUCE_MERCY_3 | Kau mengangkatnya untuk ibumu. Aku tahu rasanya, karena aku juga baru tahu punya ibu. | You raised it for your mother. I know how that feels, because I only just learned I have one. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_TRUCE_MERCY_4 | Maka biar kutulis surat pertamaku yang terkirim. Pangrenyep akan mendapat kabar dari seorang anak, bukan dari seorang pejuang. | Then let me write my first letter that gets sent. Pangrenyep will hear from a son, not from a fighter. |
| @ | | |
| BEAT_TRUCE_MERCY_5 | Dari tepi timur terdengar sorak kecil, ragu-ragu, lalu makin riuh. Prajurit-prajurit menurunkan panji mereka satu per satu. | A small cheer comes from the east bank, hesitant, then louder. The soldiers lower their banners one by one. |
| @NPC_HERO_NAME | | |
| BEAT_TRUCE_MERCY_H1 | Itu langkah pertama. Sisanya akan berat. | That's the first step. The rest will be hard. |

### Beat `truce_judgment` (if `!flag:beat_truce_judgment`, `flag:choice_judgment`; do `flag:beat_truce_judgment`). Choice 3, judgment: the consequence plays at once
| Key | ID | EN |
|-----|----|----|
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_TRUCE_JUDGMENT_1 | Hukum Galuh akan berjalan, dan penjaga sungai diperkuat. Tak seorang pun lolos tanpa nama, tanpa pengadilan. Itu keputusanku. | Galuh's law will run, and the river watch is strengthened. No one passes without a name, without a trial. That's my decision. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_TRUCE_JUDGMENT_2 | Pengadilan itu akan mengadili ibuku. Aku akan hadir, dengan atau tanpa izinmu. | That trial will judge my mother. I'll be present, with or without your leave. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_TRUCE_JUDGMENT_3 | Kau akan hadir dengan izinku. Aku bukan raja yang menolak saudaranya masuk ke ruang sidang. | You'll be present with my leave. I'm not a king who bars his brother from the courtroom. |
| @ | | |
| BEAT_TRUCE_JUDGMENT_4 | Hariang Banga mengangguk sekali, kaku. Ia belum memaafkan, tapi ia mendengar kata saudara untuk kedua kalinya. | Hariang Banga nods once, stiffly. He hasn't forgiven, but he has heard the word brother for the second time. |
| @NPC_HERO_NAME | | |
| BEAT_TRUCE_JUDGMENT_H1 | Hukum dan kehangatan tak harus saling meniadakan. Tapi aku mengerti kenapa kau memilih ini. | Law and warmth needn't cancel each other. But I understand why you chose this. |
| @ | | |
| BEAT_TRUCE_JUDGMENT_5 | Di tepi barat, tukang-tukang besi Galuh mulai memasang tiang jaga baru di tepi sungai, dan seseorang sudah menyiapkan sebuah sabuk anyaman untukmu. | On the west bank Galuh's smiths begin raising new watch-posts at the river, and someone has already readied a woven belt for you. |

### Camp talk `camp_mataram` (hariang_banga entry, a hub; cond `flag:beat_truce`, `zone:kg_pamali`, `!flag:mq3_1`, `"hub": true`, `"quiet": true`; do `flag:camp_mataram`). The first time you two talk as brothers, not rivals
| Entry | if | do | choices |
|-------|----|----|---------|
| H1 | `flag:beat_truce`, `zone:kg_pamali`, `!flag:mq3_1` (the hub) | `flag:camp_mataram` | CHOICE_HARIANG_ASK_1 to `topic:hariang_mother`; CHOICE_HARIANG_ASK_2 to `topic:hariang_ciung`; CHOICE_HARIANG_ASK_3 to `topic:hariang_east`; CHOICE_HARIANG_ASK_4 leaves |
| T1b | `"topic": "hariang_mother"`, `flag:choice_mercy`, `"quiet": true` | | |
| T1 | `"topic": "hariang_mother"`, `flag:choice_judgment`, `"quiet": true` | | |
| T2 | `"topic": "hariang_ciung"`, `"quiet": true` | | |
| T3 | `"topic": "hariang_east"`, `"quiet": true` | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| H1 | DLG_HARIANG_BANGA_V14 | Ciung memanggilku "kakak" tadi. Pertama kalinya, dan tak ada tombak dalam kalimatnya. | Ciung called me "brother" just now. The first time, and no spear in the sentence. |
| H1 | DLG_HARIANG_BANGA_V15 | Rasanya aneh. Hangat, tapi aneh. | It feels odd. Warm, but odd. |
| H1 | DLG_HARIANG_BANGA_V220 | Sebelum kita berangkat, tanyakan apa saja. Orang yang kalah di sungai punya waktu untuk menjawab. | Before we ride, ask me anything. A man who lost at the river has time to answer. |
| T1b | DLG_HARIANG_BANGA_V221 | Ibunda menulis padaku waktu aku kecil: "Jangan mengurung orang yang bisa kauajak bicara." Aku lupa itu, lalu mengingatnya di sini. | Mother wrote me once, when I was small: "Never cage someone you could talk to." I forgot it, then remembered it here. |
| T1b | DLG_HARIANG_BANGA_V230 | Sel yang terang, katamu. Lampu yang menyala tiap malam berarti ada yang menengok. Itu sudah cukup bagiku. | A lit cell, you said. A lamp burning each night means someone looks in. That's already enough for me. |
| T1b | DLG_HARIANG_BANGA_V231 | Kutulis surat pertamaku yang akan terkirim. Isinya pendek: "Aku hidup. Aku datang." | I wrote my first letter that will actually be sent. It's short: "I'm alive. I'm coming." |
| T1 | DLG_HARIANG_BANGA_V222 | Pengadilan Galuh akan berjalan menurut aturan. Aku akan hadir, dan aku akan diam. Itu caraku menghormati Ibunda. | Galuh's court will run by its rules. I'll attend, and I'll be silent. That's how I honour Mother. |
| T1 | DLG_HARIANG_BANGA_V223 | Kalau mereka tak berbuat lebih dari yang adil, aku tak akan mengangkat pedang ke barat lagi. Janji, bukan sumpah. | If they do no more than what's fair, I won't raise a sword westward again. A promise, not an oath. |
| T1 | DLG_HARIANG_BANGA_V232 | Hukum itu dingin, tapi Ibunda mengajariku bahwa dingin bukan berarti jahat. Kadang itu cuma cara menjaga api tetap utuh. | The law is cold, but Mother taught me cold isn't evil. Sometimes it's just a way to keep the fire whole. |
| T2 | DLG_HARIANG_BANGA_V224 | Dia bilang wajahnya bukan wajah raja, hanya baju kebesaran. Aku cuma bisa tertawa. Aku pun memakai baju yang bukan milikku. | He said his face isn't a king's, only an oversized coat. I could only laugh. I wear a coat that isn't mine too. |
| T2 | DLG_HARIANG_BANGA_V225 | Ciung bertarung seperti orang yang tak pernah punya ranjang sendiri. Aku bertarung seperti orang yang tak bisa keluar dari kamarnya. | Ciung fights like someone who never had a bed of his own. I fight like someone who can't leave his room. |
| T2 | DLG_HARIANG_BANGA_V226 | Kami berbeda, tapi di sungai tadi tombak kami sama panjang. Itu mulai terasa seperti pelajaran. | We're different, but at the river our spears were the same length. That begins to feel like a lesson. |
| T3 | @NPC_HERO_NAME | | |
| T3 | DLG_HARIANG_BANGA_H5 | Lalu, apa selanjutnya? | So, what's next? |
| T3 | @NPC_HARIANG_BANGA_NAME | | |
| T3 | DLG_HARIANG_BANGA_V16 | Timur menunggu. Ayo. | The East waits. Let's go. |
| T3 | DLG_HARIANG_BANGA_V227 | Jalan ke timur melewati padang tanah kami, lalu bukit berbatu, lalu pasir. Aku mengenal tiap sumurnya. | The road east crosses our plains, then rocky hills, then sand. I know every well. |
| T3 | DLG_HARIANG_BANGA_V228 | Para empu di sana menempa bilah yang ingat. Aku tak suka itu. Bilah yang ingat tak mudah dimaafkan. | The smiths there forge blades that remember. I don't like that. A blade that remembers is not easily forgiven. |
| T3 | DLG_HARIANG_BANGA_V229 | Aku antar kau sampai pasar para pandai besi. Di luar itu, tanah bukan lagi milikku. | I'll take you as far as the smiths' market. Beyond it, the land is no longer mine. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_HARIANG_ASK_1 | Tanya tentang ibunya | Ask about his mother | `topic:hariang_mother` |
| CHOICE_HARIANG_ASK_2 | Tanya tentang Ciung | Ask about Ciung | `topic:hariang_ciung` |
| CHOICE_HARIANG_ASK_3 | Tanya tentang jalan ke timur | Ask about the road east | `topic:hariang_east` |
| CHOICE_HARIANG_ASK_4 | Sudah cukup | That's enough | |

## 9. Act IV: Tanah Timur (MQ3, "Bilah Tujuh Turunan")
Regional characters: Mpu Wirasana (want: to never forge a blade that eats again; turn: he is the seventh smith of the line; close: the choice), Ratna (want: to be trusted with the old blade; turn: she reads the marks first; close: she tempers your steel in the epilogue), Mbok Srini (want: to cancel a debt she made when lonely; close: her daughter runs home). Ally: Hariang Banga. Step indices are 0-based: `step:mq3=0` is 3.1.

Order of play: the smiths' street and the first ambush (3.1-3.2), the red marks, the forge and the practice stakes (3.3-3.4), the widow, the pouches and two more ambushes (3.5-3.9), the stakes in the fields and the forge defence (3.10-3.11), the vault and the old forge (3.12-3.13), the coast, the sand and the camp (3.14-3.16), Laras in the dunes (3.17), the shrine, the keris and the choice (3.18-3.20), the mask and the Hunter (3.21-3.22).

**The curse, in one place (game, ASSUMED).** Mpu Gandring's keris was made to swallow. Seven generations of one family of smiths were ordered by kings to keep it sharp, and each generation's name is a curse stake; the seventh is Wirasana. The doorpost marks are the first roots of the stakes. Buto Ijo is a giant the waking curse drove mad. Nobody says the legend's ending aloud; the codex does.

### Chapter 1: The Smiths' Road and the Stalking Giant (3.1-3.4)

### timur_daughter (Ratna; the smiths' street in `tt_kulon`; name NPC_TIMUR_DAUGHTER_NAME; named in v5). The arrival slice (3.1) and a topic hub. Keys V20+ so the epilogue keys V5/V6 stay free
Hub shape (shown once here): an entry with `"hub": true, "quiet": true` shows its line and then its `choices`; every choice whose `do` is `topic:<key>` plays the entry whose `"topic"` is `<key>` (`"quiet": true`, listed below with `if` = `topic:<key>`), then the hub choices open again until the leave choice is picked. Topic entries are never reached any other way and never complete a step.

| Entry | if | do |
|-------|----|----|
| 1 | `step:mq3=0`, `!flag:mq3_a1` | `codex:pamor` |
| 2 | `step:mq3=10` (3.11, `"quiet": true`) | |
| H | `quest:mq3=active` (`"hub": true`, `"quiet": true`) | |
| T1 | `topic:ratna_pamor` (`"quiet": true`) | |
| T2 | `topic:ratna_father` (`"quiet": true`) | |
| T3 | `topic:ratna_marks` (`"quiet": true`) | |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_TIMUR_DAUGHTER_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_V1 | Lihat bilah ini? Besi dan baja dilipat puluhan kali, sampai pola seperti awan muncul. Itu pamor. | See this blade? Iron and steel folded dozens of times, until a cloud-like pattern shows. That's pamor. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_H1 | Ayahmu seorang empu, pembuat keris? | Is your father an empu, a keris maker? |
| 1 | @NPC_TIMUR_DAUGHTER_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_V2 | Pembuat keris, ya. Mpu Wirasana, di bengkel ujung jalan. Ayah bilang tiap bilah ingat untuk apa ia ditempa. | A keris maker, yes. Mpu Wirasana, at the forge down the road. Father says every blade remembers what it was made for. |
| 1 | DLG_TIMUR_DAUGHTER_V20 | Aku Ratna, muridnya. Satu-satunya yang berani bilang lipatannya miring, jadi Ayah menganggapku kurang ajar. | I'm Ratna, his apprentice. The only one who dares say a fold is crooked, so Father thinks I'm cheeky. |
| 1 | DLG_TIMUR_DAUGHTER_V3 | Tapi tanda merah di pintu-pintu itu baru muncul pagi ini, dan Ayah tak suka. | But those red marks on the doors appeared this morning, and Father doesn't like them. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_H20 | Muncul bersamaan dengan apa lagi? | What else turned up with them? |
| 1 | @NPC_TIMUR_DAUGHTER_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_V21 | Raksasa hijau, Buto Ijo, kata orang. Dulu cuma dongeng penakut anak. Seminggu ini ia menginjak pagar kami. | A green giant, Buto Ijo, people say. Once only a tale to scare children. This week he's trampling our fences. |
| 1 | DLG_TIMUR_DAUGHTER_V22 | Anehnya ia tak merampok. Ia mengintai: muncul dari rumput, hilang, muncul lagi dari arah lain. | Strangely, he doesn't loot. He stalks: up out of the grass, gone, up again from another side. |
| 1 | DLG_TIMUR_DAUGHTER_V23 | Bawa tiga paku penangkal api ini, kulipat sendiri. Tancapkan di tanah, dan api kutukannya tak merambat. | Take these three fire-ward nails, folded by my own hand. Drive them into the ground and his curse-fire can't spread. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_H21 | Terima kasih. Di mana aku bisa istirahat? | Thank you. Where can I rest? |
| 1 | @NPC_TIMUR_DAUGHTER_NAME | | |
| 1 | DLG_TIMUR_DAUGHTER_V24 | Petilasan di sabana, ke timur. Istirahatlah dulu, lalu ikuti tanda merah ke bengkel Ayah. | The petilasan on the savanna, east of here. Rest first, then follow the red marks to Father's forge. |
| 2 | @NPC_TIMUR_DAUGHTER_NAME | | |
| 2 | DLG_TIMUR_DAUGHTER_V25 | Rapat ke tungku! Keris-keris kecil itu suka besi panas, tapi benci nama pembuatnya. | Stay by the furnace! Those little keris love hot iron, but hate their maker's name. |
| 2 | DLG_TIMUR_DAUGHTER_V26 | Dulu mereka bilah biasa, ditempa lalu dilupakan. Kutukan membangunkan semuanya sekaligus. | They were ordinary blades once, forged then forgotten. The curse woke them all at once. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_TIMUR_DAUGHTER_H22 | Bagaimana menghentikan mereka? | How do I stop them? |
| 2 | @NPC_TIMUR_DAUGHTER_NAME | | |
| 2 | DLG_TIMUR_DAUGHTER_V27 | Ha untuk melunasi tanda di tonggak, api untuk menjatuhkan yang terbang. Aku jaga pintu belakang. | Ha to settle the mark on a stake, fire to bring down the ones that fly. I'll mind the back door. |
| 2 | DLG_TIMUR_DAUGHTER_V28 | Selesai ini, Ayah mau menunjukkan gudang catatan. Aku belum pernah boleh masuk. | When this is done, Father wants to show you the record vault. I've never been let in. |
| 2 | DLG_TIMUR_DAUGHTER_V29 | Kalau ia membukanya untukmu, berarti ia sudah putus asa. Atau percaya. Sulit dibedakan pada Ayah. | If he opens it for you, he's desperate. Or trusting. It's hard to tell with Father. |
| H | @NPC_TIMUR_DAUGHTER_NAME | | |
| H | DLG_TIMUR_DAUGHTER_V30 | Tanya saja. Aku punya waktu selama besi masih panas. | Ask away. I've time as long as the iron's hot. |
| T1 | @NPC_TIMUR_DAUGHTER_NAME | | |
| T1 | DLG_TIMUR_DAUGHTER_V31 | Pamor tak bisa dipalsukan. Tiap lipatan mencatat siapa yang memukulnya dan berapa kuat. | Pamor can't be faked. Every fold records who struck it and how hard. |
| T1 | DLG_TIMUR_DAUGHTER_V32 | Pola beras wutah, pola udan mas: namanya macam-macam, tapi pola paling jujur adalah yang tak direncanakan. | Rice-spill pattern, golden-rain pattern: the names vary, but the most honest pattern is the unplanned one. |
| T1 | DLG_TIMUR_DAUGHTER_V33 | Ayah bisa menebak watak pemilik keris dari pamornya. Aku masih belajar. Lipatanku masih terlalu rapi. | Father can guess an owner's character from the pamor. I'm still learning. My folds are still too neat. |
| T2 | @NPC_TIMUR_DAUGHTER_NAME | | |
| T2 | DLG_TIMUR_DAUGHTER_V34 | Ayah tak tidur sejak tanda pertama. Ia memandangi satu bilah di gudang, dan melarangku menyentuhnya. | Father hasn't slept since the first mark. He stares at one blade in the vault and forbids me to touch it. |
| T2 | DLG_TIMUR_DAUGHTER_V35 | Ia takut pada satu bilah, dan itu membuatnya takut pada semua yang kubuat. Itu yang paling menyakitkan. | He fears one blade, and that makes him fear everything I make. That's what hurts most. |
| T2 | DLG_TIMUR_DAUGHTER_V36 | Tapi tangannya gemetar hanya kalau memegang yang satu itu. Itu kuperhatikan. | But his hands shake only when he holds that one. I've noticed. |
| T3 | @NPC_TIMUR_DAUGHTER_NAME | | |
| T3 | DLG_TIMUR_DAUGHTER_V37 | Tandanya menjalar satu pintu demi satu pintu, dan membentuk garis. Garisnya menunjuk ke candi di timur. | The marks creep door by door and form a line. The line points to the shrine in the east. |
| T3 | DLG_TIMUR_DAUGHTER_V38 | Ayah bilang itu akar tonggak. Tonggak ketujuh akan menyala kalau semua akarnya bertemu. | Father says they're the roots of stakes. The seventh stake will light if every root meets. |
| T3 | DLG_TIMUR_DAUGHTER_V39 | Jangan sentuh tandanya. Rumah yang tersentuh duduk menatap lantai berhari-hari. | Don't touch the marks. A house that's touched sits staring at its floor for days. |
| 3 | DLG_TIMUR_DAUGHTER_V4 | Hati-hati dengan tanda merah itu. Jangan disentuh. | Careful with those red marks. Don't touch them. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_RATNA_ASK_1 | Ceritakan soal pamor. | Tell me about pamor. | `topic:ratna_pamor` |
| CHOICE_RATNA_ASK_2 | Ayahmu orang seperti apa? | What's your father like? | `topic:ratna_father` |
| CHOICE_RATNA_ASK_3 | Tanda merah itu sebenarnya apa? | What are the red marks, really? | `topic:ratna_marks` |
| CHOICE_RATNA_LEAVE | Cukup, terima kasih. | That's enough, thanks. | |

VERIFY: pamor (the layered pattern of a keris blade), the pattern names (beras wutah, udan mas), empu as keris master.

### Clue `doorpost_mark` (step 3.1; the first red mark on a stall doorpost; journal note only)
| Key | ID | EN |
|-----|----|----|
| CLUE_DOORPOST_MARK_1 | Tanda merah di tiang lapak, masih hangat seperti bara. Tak ada yang berani menyentuhnya. | A red mark on a stall post, still warm like an ember. Nobody dares touch it. |
| CLUE_DOORPOST_MARK_2 | Garisnya patah-patah, seperti huruf yang belum selesai ditulis. | Its line is broken, like a letter not yet finished. |
| CLUE_DOORPOST_MARK_NOTE | Tanda kutukan merah di tiang lapak. | A red curse mark on a stall post. |

### Beat `ambush_1` (if `!flag:beat_ambush_1`, `flag:mq3_b1`; do `flag:beat_ambush_1`). 3.2, Stalking Ambush #1 (`buto_ambush_1`, `tt_kulon`). Buto Ijo does not speak
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_AMBUSH_1_1 | Rumput terbelah seperti air. Raksasa hijau itu menerjang dari arah yang salah, lalu paku-paku Ratna menyala dan api kutukannya padam di tanah. | The grass parts like water. The green giant charges from the wrong side, then Ratna's nails flare and his curse-fire dies on the ground. |
| BEAT_AMBUSH_1_2 | Ia mundur, bukan karena takut. Ia mundur seperti ditarik tali. | He retreats, not from fear. He retreats like something pulled on a rope. |
| @NPC_HERO_NAME | | |
| BEAT_AMBUSH_1_H1 | Matanya merah. Merah yang sama dengan tanda di tiang-tiang itu. | His eyes are red. The same red as the marks on those posts. |
| @NPC_TIMUR_DAUGHTER_NAME | | |
| BEAT_AMBUSH_1_3 | Pakunya bekerja! Tiga paku, tiga kali ia mundur. Ayah harus dengar ini. | The nails worked! Three nails, three steps back for him. Father has to hear this. |
| @NPC_HERO_NAME | | |
| BEAT_AMBUSH_1_H2 | Kau mengikutiku? Ayahmu bilang jangan keluar pagar. | You followed me? Your father said stay inside the fence. |
| @NPC_TIMUR_DAUGHTER_NAME | | |
| BEAT_AMBUSH_1_4 | Ayah bilang banyak hal. Aku hanya mendengarkan yang masuk akal. | Father says a lot of things. I only listen to the ones that make sense. |
| BEAT_AMBUSH_1_5 | Ia akan kembali. Ia tak pernah menyerang dua kali dari tempat yang sama. Ayo ke bengkel. | He'll be back. He never strikes twice from the same place. Come on, to the forge. |

### Beat `marks_hook` (if `!flag:beat_marks_hook`, `flag:mq3_h1`; do `flag:beat_marks_hook`). K5 hook. Area `timur_marks` (`tt_beringin`) sets `mq3_h1`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_MARKS_HOOK_1 | Di tiang-tiang pintu, tanda merah terbakar seperti luka. Tiap tanda berdenyut pelan. | On the doorposts, red marks burn like wounds. Each one pulses slowly. |
| BEAT_MARKS_HOOK_2 | Di bawah tiap tanda, penghuni rumah duduk diam, menatap lantai. | Under each mark, the household sits still, staring at the floor. |
| BEAT_MARKS_HOOK_3 | Seorang anak menggambar di debu dengan jari. Ia menggambar tanda yang sama, berulang-ulang, tanpa tahu mengapa. | A child draws in the dust with a finger. The same mark, over and over, without knowing why. |
| @NPC_HERO_NAME | | |
| BEAT_MARKS_HOOK_H1 | Tanda kutukan. Siapa yang membakar ini? | Curse marks. Who burned these? |
| @ | | |
| BEAT_MARKS_HOOK_4 | Tak ada yang menjawab. Tapi garis tanda-tanda itu, bila kau menyipit, menunjuk satu arah: timur, ke candi di balik haze. | Nobody answers. But the line of marks, if you squint, points one way: east, to the shrine behind the haze. |
| BEAT_MARKS_HOOK_5 | Dari bengkel di ujung lorong terdengar palu, pelan, seperti jantung yang menolak berhenti. | From the forge at the end of the lane comes a hammer, slow, like a heart refusing to stop. |

### timur_empu (Mpu Wirasana; the forge in `tt_beringin`; replace the main-path entries, keep the SQ-T3 entries). Keys V20+ for new lines
| Entry | if | do |
|-------|----|----|
| (keep) | the SQ-T3 offer (`quest:sq_t3=available`) and turn-in (`step:sq_t3=2`) | |
| 1 | `flag:choice_reforge` | |
| 2 | `flag:choice_sink` | |
| 3 | `step:mq3=2` (3.3; sets `mq3_2`) | |
| 4 | `step:mq3=3` (3.4, the lesson at the practice stakes) | |
| 5 | `step:mq3=4` (3.5 nudge, `"quiet": true`) | |
| 6 | `step:mq3=10` (3.11, `"quiet": true`) | |
| 7 | `step:mq3=11` (3.12, the vault) | |
| 8 | `step:mq3=12` (3.13, K5 hook, `"quiet": true`) | |
| H | `quest:mq3=active` (`"hub": true`, `"quiet": true`) | |
| T1 | `topic:wirasana_gandring` (`"quiet": true`) | |
| T2 | `topic:wirasana_seven` (`"quiet": true`) | |
| T3 | `topic:wirasana_ratna` (`"quiet": true`) | |
| (keep) | the SQ-T3 reminder (`quest:sq_t3=active`) and the current fallback | |

Runtime order is the row order above: the SQ-T3 entries come before the main-path ones so they are never hidden behind them. The old entry `DLG_TIMUR_EMPU_V7` ("two marks") is replaced by entry 4.

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_TIMUR_EMPU_V8 | Kau membawanya kembali. Kali ini kutempa jadi bilah yang melindungi. | You brought it back. This time I'll forge it into a blade that protects. |
| 1 | DLG_TIMUR_EMPU_V20 | Ratna menempa bagian pertamanya. Lipatannya miring, katanya. Ia benar, dan itu membuatku lega. | Ratna forged the first part. Her fold is crooked, she says. She's right, and that relieves me. |
| 2 | DLG_TIMUR_EMPU_V9 | Sungai yang menyimpannya. Mungkin itu lebih baik. | The river has it. Maybe that's kinder. |
| 2 | DLG_TIMUR_EMPU_V21 | Tujuh nama di tonggak sudah padam. Aku bisa tidur, dan itu pertama kalinya dalam satu generasi. | The seven names on the stakes have gone out. I can sleep, the first time in a generation. |
| 3 | @NPC_TIMUR_EMPU_NAME | | |
| 3 | DLG_TIMUR_EMPU_V1 | Berhenti di ambang. Panas bengkel ini membuat orang jujur, jadi katakan: kau pandai, atau cuma nekat? | Stop at the door. This forge heat makes men honest, so tell me: clever, or just stubborn? |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_TIMUR_EMPU_H1 | Aku mencari pemburu bertopeng, dan keris yang katanya bangun lagi. | I'm after a masked hunter, and a keris they say has woken. |
| 3 | @NPC_TIMUR_EMPU_NAME | | |
| 3 | DLG_TIMUR_EMPU_V2 | Keris itu... keluargaku yang merawat bilahnya, tujuh turunan, dan aku yang ketujuh. Perintah raja, dan tak ada yang bisa menolak raja. | That keris... my family tended its blade, seven generations, and I am the seventh. A king's order, and nobody refuses a king. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_TIMUR_EMPU_H20 | Keris Mpu Gandring? Yang di dongeng itu? | Mpu Gandring's keris? The one in the tale? |
| 3 | @NPC_TIMUR_EMPU_NAME | | |
| 3 | DLG_TIMUR_EMPU_V22 | Mpu Gandring, empu tua yang menempanya, leluhur guru kami. Dongeng lupa bagian yang tak enak: seseorang harus merawatnya. | Mpu Gandring, the old smith who made it, ancestor of our teachers. The tale forgets the awkward part: someone has to tend it. |
| 3 | DLG_TIMUR_EMPU_V23 | Setiap bilah ingat untuk apa ia ditempa. Yang itu ditempa untuk menelan. Tanda di pintu itu akar tonggaknya. | Every blade remembers what it was made for. That one was made to swallow. Those door marks are the roots of its stakes. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_TIMUR_EMPU_H21 | Bagaimana menghentikannya? | How do I stop it? |
| 3 | @NPC_TIMUR_EMPU_NAME | | |
| 3 | DLG_TIMUR_EMPU_V3 | Ditenangkan, bukan dikalahkan. Ia menandai korbannya dengan kutukan, dan aksara mematahkannya. Berlatihlah di tonggak halamanku. | Calmed, not beaten. It marks its victims with curses, and aksara break them. Practise on the stakes in my yard. |
| 3 | DLG_TIMUR_EMPU_V24 | Dan hati-hati pada raksasa di sabana itu. Ia korban pertamanya, bukan musuhmu. | And take care with the giant on the savanna. He's its first victim, not your enemy. |
| 4 | @NPC_TIMUR_EMPU_NAME | | |
| 4 | DLG_TIMUR_EMPU_V25 | Tonggak di halamanku meniru tanda keris itu. Berdirilah di dalam garisnya. | The stakes in my yard copy that keris's mark. Stand inside its line. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_TIMUR_EMPU_H22 | Lalu apa yang kulakukan? | And what do I do? |
| 4 | @NPC_TIMUR_EMPU_NAME | | |
| 4 | DLG_TIMUR_EMPU_V26 | Tulis Ha. Bukan untuk menyembuhkan orang, tapi meluruskan lipatan yang menyimpang, seperti besi yang salah tempa. | Write Ha. Not to heal a person, but to straighten a fold gone wrong, like badly forged iron. |
| 4 | DLG_TIMUR_EMPU_V27 | Tanda kutukan itu hutang darah. Ha melunasinya pelan, satu lipatan setiap kali. | A curse mark is a blood debt. Ha pays it down slowly, one fold at a time. |
| 4 | DLG_TIMUR_EMPU_V28 | Kalau tanganmu gemetar, tanda itu menghisapmu, dan hantu-hantu kecilnya bangun. Kalau tidak, ia padam. | If your hand shakes, the mark drinks you and its little ghosts wake. If not, it goes out. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_TIMUR_EMPU_H23 | Dan kalau tanda padam, tapi hutangnya belum lunas? | And if the mark goes out but the debt isn't paid? |
| 4 | @NPC_TIMUR_EMPU_NAME | | |
| 4 | DLG_TIMUR_EMPU_V29 | Itu sebabnya ada tujuh. Padamkan dua dulu. Lalu temui Mbok Srini, janda di tepi sungai; putrinya dikejar sesuatu yang lebih nyata. | That's why there are seven. Put out two first. Then see Mbok Srini, the widow by the river; her girl is chased by something more urgent. |
| 5 | DLG_TIMUR_EMPU_V6 | Mbok Srini, di tepi sungai. Pergilah. | Mbok Srini, by the river. Go on. |
| 6 | @NPC_TIMUR_EMPU_NAME | | |
| 6 | DLG_TIMUR_EMPU_V30 | Aku tak bisa meninggalkan tungku. Kalau padam, bilah-bilah di rak ikut bangun. | I can't leave the furnace. If it dies, the blades on the rack wake too. |
| 6 | DLG_TIMUR_EMPU_V31 | Seratus tahun aku menempa bilah untuk melindungi, dan kutukan menjadikannya hantu. Lucu, bukan? | A lifetime I forged blades to protect, and the curse made them ghosts. Funny, isn't it? |
| 6 | @NPC_HERO_NAME | | |
| 6 | DLG_TIMUR_EMPU_H24 | Kau menahan mereka lebih baik dari yang kukira. | You're holding them better than I'd have thought. |
| 6 | @NPC_TIMUR_EMPU_NAME | | |
| 6 | DLG_TIMUR_EMPU_V32 | Aku punya putri yang keras kepala, dan sebuah tungku yang lebih keras kepala. Setelah ini, ke gudang catatanku. | I have a stubborn daughter and a more stubborn furnace. After this, to my record vault. |
| 7 | @NPC_TIMUR_EMPU_NAME | | |
| 7 | DLG_TIMUR_EMPU_V33 | Ini kunci gudang. Ratna belum pernah kubolehkan masuk, dan aku tak tahu apakah itu perlindungan atau pengecut. | This is the vault key. I've never let Ratna in, and I don't know whether that was protection or cowardice. |
| 7 | DLG_TIMUR_EMPU_V34 | Di dalam ada sarung bilah itu dan buku catatan tempa. Tujuh nama berderet. Yang terakhir milikku. | Inside are that blade's scabbard and the forge ledger. Seven names in a row. The last is mine. |
| 7 | @NPC_HERO_NAME | | |
| 7 | DLG_TIMUR_EMPU_H25 | Kau tak perlu melihatku saat aku membacanya. | You don't have to watch me read it. |
| 7 | @NPC_TIMUR_EMPU_NAME | | |
| 7 | DLG_TIMUR_EMPU_V35 | Tidak. Aku akan berdiri di pintu. Tujuh turunan sudah cukup bersembunyi dari kertas. | No. I'll stand at the door. Seven generations is long enough to hide from paper. |
| 7 | DLG_TIMUR_EMPU_V36 | Setelah itu, di batu landasan tua di sudut, kau akan merasakan tarikan lontarmu. Ikuti. | After that, at the old anvil stone in the corner, you'll feel your lontar pull. Follow it. |
| 8 | @NPC_TIMUR_EMPU_NAME | | |
| 8 | DLG_TIMUR_EMPU_V37 | Pergilah ke timur lewat pesisir. Pasukan Hariang Banga menunggumu di sana. | Go east by the coast. Hariang Banga's scouts are waiting for you there. |
| 8 | DLG_TIMUR_EMPU_V38 | Kalau kau sampai di candi dan bilah itu sudah bangun, ingat: jangan hukum besinya. Ia hanya patuh. | If you reach the shrine and the blade has woken, remember: don't blame the iron. It only obeys. |
| H | @NPC_TIMUR_EMPU_NAME | | |
| H | DLG_TIMUR_EMPU_V39 | Tanya, kalau kau mau. Tanganku sibuk, telingaku tidak. | Ask, if you like. My hands are busy, my ears aren't. |
| T1 | @NPC_TIMUR_EMPU_NAME | | |
| T1 | DLG_TIMUR_EMPU_V40 | Mpu Gandring menempa bilah itu untuk seorang yang tak sabar. Orang itu merebutnya sebelum selesai. | Mpu Gandring forged that blade for an impatient man. The man snatched it before it was done. |
| T1 | DLG_TIMUR_EMPU_V41 | Sebelum mati sang empu mengutuknya. Itu versi dongeng. Versi bengkel: kutukan itu tinggal di sini, di besinya. | Before dying the smith cursed it. That's the tale's version. The forge's version: the curse stayed here, in the iron. |
| T1 | DLG_TIMUR_EMPU_V42 | Dan siapa pun yang memegang kunci bengkel ini harus memastikan bilahnya tak pernah haus. | And whoever holds this forge's key must make sure the blade is never thirsty. |
| T2 | @NPC_TIMUR_EMPU_NAME | | |
| T2 | DLG_TIMUR_EMPU_V43 | Tujuh nama, tujuh tonggak. Yang pertama murid Mpu Gandring sendiri, yang menjaga bilah itu tetap tenang. | Seven names, seven stakes. The first was Mpu Gandring's own apprentice, who kept the blade quiet. |
| T2 | DLG_TIMUR_EMPU_V44 | Tiap raja mengirim perintah, tiap generasi menjawab. Tak seorang pun bertanya mengapa bilah perlu diasah kalau tak untuk dipakai. | Each king sent an order, each generation answered. Nobody asked why a blade needs sharpening if not to be used. |
| T2 | DLG_TIMUR_EMPU_V45 | Aku bertanya, di generasiku. Dan tak ada yang menjawab. | I asked, in my generation. Nobody answered. |
| T3 | @NPC_TIMUR_EMPU_NAME | | |
| T3 | DLG_TIMUR_EMPU_V46 | Ratna lebih pandai dariku dalam melihat pola, dan aku tak mau mengatakannya keras-keras. | Ratna sees patterns better than I do, and I won't say so out loud. |
| T3 | DLG_TIMUR_EMPU_V47 | Aku melarangnya menyentuh bilah itu karena kalau kutukannya mencari tangan, aku ingin tangan itu tanganku. | I forbid her the blade because if the curse goes looking for a hand, I want it to be mine. |
| T3 | DLG_TIMUR_EMPU_V48 | Itu bukan alasan yang baik, aku tahu. Tapi itu satu-satunya yang kupunya. | It isn't a good reason, I know. It's the only one I have. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_WIRASANA_ASK_1 | Ceritakan soal keris itu. | Tell me about the keris. | `topic:wirasana_gandring` |
| CHOICE_WIRASANA_ASK_2 | Tujuh turunan itu siapa saja? | Who were the seven generations? | `topic:wirasana_seven` |
| CHOICE_WIRASANA_ASK_3 | Kenapa Ratna tak boleh menyentuhnya? | Why can't Ratna touch it? | `topic:wirasana_ratna` |
| CHOICE_WIRASANA_LEAVE | Aku pergi dulu. | I'll go on. | |

VERIFY: the Mpu Gandring tale (an unfinished keris, an impatient owner, the smith's curse); the keris as a thing "tended" across generations is the game's.

### Chapter 2: The Four Pouches of Timun Mas (3.5-3.9)

### mbok_srini (Mbok Srini; the hut in `tt_kali`; name NPC_MBOK_SRINI_NAME; keep the `do` of kept entries; keys V20+ for new lines)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq3=4` (3.5; sets `mq3_3`) | |
| 2 | `step:mq3=5` (3.6 nudge, `"quiet": true`) | |
| 3 | `flag:mq3_4` | |
| H | `quest:mq3=active` (`"hub": true`, `"quiet": true`) | |
| T1 | `topic:srini_promise` (`"quiet": true`) | |
| T2 | `topic:srini_girl` (`"quiet": true`) | |
| T3 | `topic:srini_pouches` (`"quiet": true`) | |
| (keep) | the current fallback `DLG_MBOK_SRINI_8` (re-index the old `DLG_MBOK_SRINI_7`, "see the empu first", to `step:mq3<4`, or drop it) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_MBOK_SRINI_NAME | | |
| 1 | DLG_MBOK_SRINI_V1 | Timun Masku, putriku! Raksasa itu, Buto Ijo, menghancurkan pondokku dan mengejarnya ke arah beringin tua. Kakiku sudah tak sanggup. | My Timun Mas, my daughter! That giant, Buto Ijo, smashed my hut and chased her toward the old banyan. My legs have given out. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_MBOK_SRINI_H1 | Sejak kapan, Mbok? | Since when, Mbok? |
| 1 | @NPC_MBOK_SRINI_NAME | | |
| 1 | DLG_MBOK_SRINI_V20 | Sejak tanda merah. Dulu ia datang setahun sekali menagih janji. Sekarang tiap malam, dan ia tak lagi bicara. | Since the red marks. He used to come once a year to collect on a promise. Now every night, and he no longer speaks. |
| 1 | DLG_MBOK_SRINI_V21 | Janji itu buatanku. Aku perempuan sendirian yang minta anak pada seorang raksasa, dan berjanji menyerahkannya. | The promise was mine. A lonely woman who asked a giant for a child and swore to give her up. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_MBOK_SRINI_H20 | Dan kau mau membatalkannya. | And you want to cancel it. |
| 1 | @NPC_MBOK_SRINI_NAME | | |
| 1 | DLG_MBOK_SRINI_2 | Bawalah empat kantong ini: biji timun, jarum, garam, dan terasi. | Take these four pouches: cucumber seeds, needles, salt and terasi, the shrimp paste. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_MBOK_SRINI_H2 | Seperti dongeng. | Like the tale. |
| 1 | @NPC_MBOK_SRINI_NAME | | |
| 1 | DLG_MBOK_SRINI_V2 | Dongeng ditulis oleh yang berhasil lolos. Biji dulu: lempar saat ia dekat, bukan jauh. | Tales are written by the ones who got away. Seeds first: throw when he's close, not far. |
| 1 | DLG_MBOK_SRINI_V22 | Lihat dulu barang-barang Timun Mas yang tercecer di dasar sungai. Mereka akan bilang apa yang harus kaulakukan. | Look first at Timun Mas's things spilled in the riverbed. They'll tell you what to do. |
| 2 | @NPC_MBOK_SRINI_NAME | | |
| 2 | DLG_MBOK_SRINI_V4 | Coba biji dulu, Nak. Dan jangan melempar sebelum ia dekat. | Try the seeds first, child. And don't throw before he's close. |
| 3 | DLG_MBOK_SRINI_5 (keep) | | |
| 3 | DLG_MBOK_SRINI_6 (keep) | | |
| H | @NPC_MBOK_SRINI_NAME | | |
| H | DLG_MBOK_SRINI_V23 | Duduklah, Nak. Kakiku tak ke mana-mana, telingaku masih. | Sit, child. My legs go nowhere, my ears still do. |
| T1 | @NPC_MBOK_SRINI_NAME | | |
| T1 | DLG_MBOK_SRINI_V24 | Di dongeng, ibu itu tak bersalah. Di pondok ini, ia yang salah, dan ia tahu. | In the tale, the mother is blameless. In this hut, she's the one at fault, and she knows. |
| T1 | DLG_MBOK_SRINI_V25 | Raksasa itu sebenarnya hanya menagih. Kutukan itu yang membuatnya lupa kenyang. | The giant only collected, really. It's the curse that made him forget when to stop. |
| T1 | DLG_MBOK_SRINI_V26 | Aku ingin utangku lunas, bukan anakku. Itu bedanya, dan itu satu-satunya hal yang kuinginkan. | I want my debt paid, not my child. That's the difference, and the only thing I want. |
| T2 | @NPC_MBOK_SRINI_NAME | | |
| T2 | DLG_MBOK_SRINI_V27 | Timun Mas bukan gadis lemah. Ia mencuri tiga mentimun dari kebun tetangga dan menyebutnya "perbekalan". | Timun Mas isn't a weak girl. She stole three cucumbers from a neighbour's garden and called it "provisions". |
| T2 | DLG_MBOK_SRINI_V28 | Ia berlari bukan karena takut, tapi karena aku menyuruhnya. Itu yang paling kutakuti darinya. | She runs not from fear, but because I told her to. That's what I fear most about her. |
| T3 | @NPC_MBOK_SRINI_NAME | | |
| T3 | DLG_MBOK_SRINI_V29 | Pertapa yang memberiku biji timun juga memberi tiga bungkusan lain, dan berpesan: satu tiap kali, tak lebih. | The hermit who gave me the cucumber seeds gave three more pouches, and warned: one at a time, never more. |
| T3 | DLG_MBOK_SRINI_V30 | Biji jadi semak, jarum jadi bambu, garam jadi laut, terasi jadi lumpur. Tiap kantong satu napas waktu. | Seeds make brambles, needles bamboo, salt a sea, terasi mud. Each pouch buys one breath of time. |
| T3 | DLG_MBOK_SRINI_V31 | Dongeng menyingkat. Aslinya empat kantong itu harus disucikan sebelum dipakai, di bawah beringin tua. | The tale shortens. In truth the four pouches must be consecrated before use, under the old banyan. |
| (fallback) | DLG_MBOK_SRINI_8 (keep) | | |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_SRINI_ASK_1 | Soal janji itu, Mbok? | About that promise, Mbok? | `topic:srini_promise` |
| CHOICE_SRINI_ASK_2 | Seperti apa Timun Mas? | What's Timun Mas like? | `topic:srini_girl` |
| CHOICE_SRINI_ASK_3 | Dari mana kantong-kantong ini? | Where do these pouches come from? | `topic:srini_pouches` |
| CHOICE_SRINI_LEAVE | Aku harus pergi. | I should go. | |

### Hunt K4: Buto Ijo (3.5-3.9)
The three clues are spilled around Mbok Srini's hut (3.5). The memory is not opened by `salt_terasi` any more: see clue `banyan_altar` below.
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

### Beat `ambush_2` (if `!flag:beat_ambush_2`, `flag:mq3_b2`; do `flag:beat_ambush_2`). 3.6, Stalking Ambush #2 (`buto_ambush_2`, `tt_kali`)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_AMBUSH_2_1 | Dasar sungai bergetar. Buto Ijo menerjang dari balik batu, dan kantong biji pecah di antara kakimu. | The riverbed trembles. Buto Ijo charges from behind a rock, and the seed pouch bursts between your feet. |
| BEAT_AMBUSH_2_2 | Semak berduri meledak dari tanah kering dan melilit pergelangan raksasa itu. Ia meraung tanpa kata. | Brambles explode from dry ground and wind about the giant's ankles. He roars without words. |
| @NPC_MBOK_SRINI_NAME | | |
| BEAT_AMBUSH_2_3 | Duri itu bertahan sepuluh tarikan napas, Nak! Jangan buang yang kedua! | The thorns hold ten breaths, child! Don't waste the second one! |
| @ | | |
| BEAT_AMBUSH_2_4 | Raksasa itu merobek dirinya bebas, meninggalkan secarik kain hijau di duri, lalu mundur ke timur. | The giant tears himself free, leaving a scrap of green cloth on the thorns, and backs away east. |
| @NPC_HERO_NAME | | |
| BEAT_AMBUSH_2_H1 | Ia selalu mundur ke arah yang sama. Ke ladang itu. | He always backs off the same way. To that field. |
| BEAT_AMBUSH_2_H2 | Itu bukan sarang. Itu tempat ia ditarik. Seseorang menaruh sesuatu di sana. | That isn't a lair. It's where he's being pulled. Someone put something there. |
| @NPC_MBOK_SRINI_NAME | | |
| BEAT_AMBUSH_2_4B | Tiga kantong lagi. Sucikan di beringin tua, sebelum ia belajar jalan di sungai ini. | Three pouches left. Consecrate them at the old banyan before he learns his way along this river. |

### Clue `banyan_altar` and memory `k4_timun_mas` (step 3.7 clue, step 3.8 memory; the clue stands at the ancient banyan in `tt_beringin`, and the memory opens from it; ASSUMED id, replaces the `memory_id` on `salt_terasi`)
| Key | ID | EN |
|-----|----|----|
| CLUE_BANYAN_ALTAR_1 | Di rongga beringin, sebuah batu pipih penuh bekas tangan kecil. Ada yang bersembunyi di sini sambil berdoa. | In the banyan's hollow, a flat stone with small handprints on it. Someone hid here and prayed. |
| CLUE_BANYAN_ALTAR_2 | Saat kuletakkan keempat kantong di atasnya, lontarku menghangat dan menarikku. | As I lay the four pouches on it, my lontar warms and pulls me. |
| CLUE_BANYAN_ALTAR_NOTE | Batu doa di rongga beringin tua, tempat kantong Timun Mas disucikan. | A prayer stone in the old banyan's hollow, where Timun Mas's pouches were consecrated. |
| MEM_K4_TIMUN_MAS_TITLE | Timun Mas | Timun Mas |
| MEM_K4_TIMUN_MAS_IN | Kau Timun Mas sekarang, Nak: gadis yang dijanjikan pada seorang raksasa. Lari, dan lempar kantongmu. | You are Timun Mas now, child: the girl promised to a giant. Run, and throw your pouches. |
| MEM_K4_TIMUN_MAS_HINT | Lempar saat dekat | Throw when close |
| MEM_K4_TIMUN_MAS_1 | Biji timun menjadi semak berduri. Sang raksasa merobek jalannya. | The seeds become brambles. The giant tears his way through. |
| MEM_K4_TIMUN_MAS_2 | Jarum menjadi rimbun bambu. Garam menjadi laut. Ia terus mendekat. | The needles become a bamboo thicket. The salt becomes a sea. He keeps coming. |
| MEM_K4_TIMUN_MAS_3 | Terasi menjadi lumpur. Sang raksasa terperosok, dan gadis itu berlari ke arah fajar. | The terasi becomes mud. The giant sinks, and the girl runs toward the dawn. |
| MEM_K4_TIMUN_MAS_OUT | Pancing dia lewat ladang kantongmu, Nak. Jangan melempar sembarangan: lempar saat dia dekat. | Lure him through your pouch fields, child. Don't throw wildly: throw when he's close. |
| HINT_BUTO_IJO | Pancing lewat kantong | Lure through pouches |

### Beat `ambush_3` (if `!flag:beat_ambush_3`, `flag:mq3_b3`; do `flag:beat_ambush_3`). 3.7, Stalking Ambush #3 (`buto_ambush_3`, `tt_beringin`, at the banyan; Wirasana folds the needles)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_AMBUSH_3_1 | Akar gantung beringin bergoyang tanpa angin. Buto Ijo muncul dari bawah tanah, tepat saat jarum terakhir dilipat. | The banyan's hanging roots sway without wind. Buto Ijo bursts from under the ground just as the last needle is folded. |
| @NPC_TIMUR_EMPU_NAME | | |
| BEAT_AMBUSH_3_2 | Lipatan sebelas! Jarum ini sekarang tahu cara menjadi bambu yang benar! | Eleven folds! These needles now know how to become proper bamboo! |
| @ | | |
| BEAT_AMBUSH_3_3 | Rimbun bambu naik seperti pagar tombak. Raksasa itu tersangkut, meraung, lalu sebuah keris kecil melayang dari bahunya dan jatuh ke tanah, berdenting. | A bamboo thicket rises like a fence of spears. The giant catches, roars, then a small keris floats from his shoulder and clatters to the ground. |
| @NPC_TIMUR_DAUGHTER_NAME | | |
| BEAT_AMBUSH_3_4 | Itu bilah dari rakku! Kutukannya menarik mereka pada dia. Ia membawa kita ke mana-mana. | That's a blade from my rack! The curse pulls them to him. He carries us everywhere. |
| @NPC_HERO_NAME | | |
| BEAT_AMBUSH_3_H1 | Jadi bukan dia yang memburu kita. Ia ditaruh di jalan kita. | So he isn't hunting us. He's been placed in our road. |
| @ | | |
| BEAT_AMBUSH_3_5 | Raksasa itu mundur ke ladang timur. Dari rongga beringin, sepasang mata kecil berlumpur mengintip, mengangkat sebatang mentimun seperti piala, lalu menghilang. | The giant backs off toward the eastern field. From the banyan hollow, a pair of small muddy eyes peeks out, lifts a cucumber like a trophy, then is gone. |
| BEAT_AMBUSH_3_6 | Garam dan terasi masih utuh. Sisanya cukup untuk satu pertarungan terakhir. | The salt and terasi are still whole. They are enough for one last fight. |

### Beat `buto_after` (if `!flag:beat_buto_after`, `flag:mq3_4`; do `flag:beat_buto_after`, `codex:buto_ijo`). K4 aftermath, 3.9
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_BUTO_AFTER_1 | Buto Ijo roboh. Di matanya, merah kutukan seperti tanda di tiang pintu perlahan padam. | Buto Ijo goes down. In his eyes the red of the curse, like the marks on the doorposts, slowly fades. |
| BEAT_BUTO_AFTER_2 | Sang janda memeluk putrinya, Timun Mas, yang berlumur lumpur dan tertawa. | The widow holds her daughter Timun Mas, muddy and laughing. |
| BEAT_BUTO_AFTER_3 | Raksasa itu duduk, terengah, dan untuk pertama kalinya menatap sesuatu selain jalan di depannya. | The giant sits, panting, and for the first time looks at something other than the road ahead. |
| @NPC_MBOK_SRINI_NAME | | |
| BEAT_BUTO_AFTER_4 | Utangku, Nak. Ia tak menagihnya. Ia hanya... lupa. Aku akan membayarnya dengan cara lain. | My debt, child. He isn't collecting. He just... forgot. I'll pay it another way. |
| @NPC_HERO_NAME | | |
| BEAT_BUTO_AFTER_H1 | Kutukan yang sama. Seseorang membuat yang besar jadi buas. Aku harus belajar mematahkannya, di tempat Mpu Wirasana. | The same curse. Someone made a big thing wild. I need to learn to break it, at Mpu Wirasana's. |
| BEAT_BUTO_AFTER_H2 | Ladang ini tadi kering. Sekarang ada tonggak merah muncul dari tanah, satu demi satu. | This field was dry a moment ago. Now red stakes are coming up out of the ground, one by one. |
| @ | | |
| BEAT_BUTO_AFTER_5 | Dari ujung ladang, hawa panas bergetar. Sesuatu yang lebih tua dari raksasa itu baru saja membuka matanya. | From the far end of the field the heat shimmers. Something older than the giant has just opened its eyes. |

### Chapter 3: The Seven-Generation Blood Curse (3.10-3.13)

### Clue `ladang_stake` (step 3.10; the first curse stake in the dry fields of `tt_ladang`; ASSUMED id; journal note only)
| Key | ID | EN |
|-----|----|----|
| CLUE_LADANG_STAKE_1 | Sebatang tonggak merah menembus tanah ladang, tinggi sepinggang. Pada kayunya terukir satu nama yang tak kukenal. | A red stake pierces the field's soil, waist high. One name I don't know is carved in its wood. |
| CLUE_LADANG_STAKE_2 | Namanya hangus pelan-pelan dari bawah ke atas. Tinggal beberapa napas lagi sebelum tonggak ini menyala. | The name chars slowly from the bottom up. A few breaths left before this stake lights. |
| CLUE_LADANG_STAKE_NOTE | Tonggak kutukan merah di ladang, dengan nama terukir. | A red curse stake in the field, with a name carved in it. |

### Beat `ladang_cleared` (if `!flag:beat_ladang_cleared`, `flag:mq3_5a`; do `flag:beat_ladang_cleared`). 3.10
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_LADANG_CLEARED_1 | Tonggak terakhir padam dengan bunyi seperti napas ditahan lalu dilepas. Tanah ladang kembali kering, hanya kering. | The last stake goes out with a sound like a breath held, then let go. The field is dry again, only dry. |
| BEAT_LADANG_CLEARED_2 | Tapi dari desa tempa, jauh di belakang, asap hitam naik. Bukan asap tungku. | But from the forge quarter far behind, black smoke rises. Not furnace smoke. |
| @NPC_HERO_NAME | | |
| BEAT_LADANG_CLEARED_H1 | Padamkan satu, bangun dua. Seperti ada yang menghitung. | Put out one, two wake. Like someone's counting. |
| @ | | |
| BEAT_LADANG_CLEARED_3 | Dari arah bengkel, sebuah keris kecil melesat di atas atap, berdengung, lalu satu lagi, dan satu lagi. | From the forge, a small keris shoots over the roofs, humming, then another, then another. |
| BEAT_LADANG_CLEARED_4 | Buto Ijo, yang masih duduk di ujung ladang, mengangkat kepala dan menunjuk ke arah itu. Ia seperti ingin ikut. | Buto Ijo, still sitting at the field's end, lifts his head and points that way. He looks as if he wants to come. |
| @NPC_HERO_NAME | | |
| BEAT_LADANG_CLEARED_H2 | Tinggallah di sini, Raksasa. Kau sudah cukup menanggung. | Stay here, Giant. You've carried enough. |
| @ | | |
| BEAT_LADANG_CLEARED_5 | Ia mengangguk seperti anak kecil, dan kau berlari kembali ke bengkel. | He nods like a small child, and you run back to the forge. |

### Beat `forge_defended` (if `!flag:beat_forge_defended`, `flag:mq3_5b`; do `flag:beat_forge_defended`). 3.11, after the forge defence (`timur_forge_defense`)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_FORGE_DEFENDED_1 | Keris hantu terakhir jatuh berdenting di lantai bengkel dan diam, bilah biasa lagi. Ratna menyapunya dengan sapu lidi seperti sampah mulia. | The last ghost keris falls clanging on the forge floor and goes still, an ordinary blade again. Ratna sweeps it up with a palm broom like noble rubbish. |
| @NPC_TIMUR_DAUGHTER_NAME | | |
| BEAT_FORGE_DEFENDED_2 | Dua puluh tiga. Aku menghitung. Dua puluh tiga bilah dari rakku sendiri yang mau membunuhku. | Twenty-three. I counted. Twenty-three blades off my own rack that wanted to kill me. |
| @NPC_TIMUR_EMPU_NAME | | |
| BEAT_FORGE_DEFENDED_3 | Mereka tak ingin membunuhmu. Mereka ingin pulang ke bilah induknya. Itu bedanya. | They didn't want to kill you. They wanted to go home to their mother blade. That's the difference. |
| @NPC_TIMUR_DAUGHTER_NAME | | |
| BEAT_FORGE_DEFENDED_4 | Itu tidak membuatku merasa lebih baik, Ayah. | That doesn't make me feel better, Father. |
| @NPC_TIMUR_EMPU_NAME | | |
| BEAT_FORGE_DEFENDED_5 | Aku tahu. Maaf. Maaf untuk seluruh generasi. Ikut aku, kalian berdua. Gudang catatan. | I know. I'm sorry. Sorry for a whole generation. Come with me, both of you. The vault. |
| @NPC_HERO_NAME | | |
| BEAT_FORGE_DEFENDED_H1 | Ratna berjalan di belakangnya, dan untuk pertama kalinya ia tak membantah. | Ratna walks behind him, and for once she doesn't argue. |

### Clues K5 (step 3.12; the broken scabbard and the forge ledger lie in Wirasana's vault; `forge_stone` is also in the vault and starts `k5_forge`, step 3.13)
The two practice marks Wirasana's stakes hold set `flag:clue_practice_marks` (no lines).
| Key | ID | EN |
|-----|----|----|
| HUNT_K5_TITLE | Keris Terkutuk | The Cursed Keris |
| CLUE_SCABBARD_1 | Sarung keris yang patah, kayunya hangus dan tergores. Sesuatu dicabut darinya dengan marah. | A broken keris scabbard, the wood charred and gouged. Something was drawn from it in anger. |
| CLUE_SCABBARD_2 | Apa pun isinya, kini ia berjalan sendiri. | Whatever it held now walks on its own. |
| CLUE_SCABBARD_NOTE | Sarung keris patah, hangus dan tergores. | A broken keris scabbard, charred and gouged. |
| CLUE_FORGE_RECORDS_1 | Catatan tempa Mpu Wirasana: tujuh nama berderet, tujuh turunan, semua mengasah satu bilah. | Mpu Wirasana's forge records: seven names in a row, seven generations, all sharpening one blade. |
| CLUE_FORGE_RECORDS_2 | Yang terakhir: Wirasana. Di sampingnya tertulis: "tak bisa menolak". Dan di tepi halaman, tulisan Ratna: "bisa". | The last: Wirasana. Beside it: "could not refuse". And in the margin, in Ratna's hand: "could". |
| CLUE_FORGE_RECORDS_NOTE | Tujuh turunan empu mengasah satu keris; yang terakhir Wirasana. | Seven generations of smiths sharpened one keris; the last was Wirasana. |
| CLUE_PRACTICE_MARKS_NOTE | Tanda latihan di tonggak Wirasana meniru kutukan sang keris. | The practice marks on Wirasana's stakes copy the keris's curse. |

### Clue `forge_stone` and memory `k5_forge` (step 3.13; K5, kind play; kelir figure: the smith's apprentice; the action douses a curse mark; the stone is the old anvil in the corner of Wirasana's vault in `tt_beringin`)
| Key | ID | EN |
|-----|----|----|
| CLUE_FORGE_STONE_1 | Batu landasan tua di sudut gudang, retak dan hitam. Di sinilah keris itu ditempa, lalu dibawa ke sini tujuh turunan lalu. | An old anvil stone in the vault's corner, cracked and black. The keris was forged here, then carried here seven generations ago. |
| CLUE_FORGE_STONE_2 | Lontarku menarikku kembali ke masa ketika bengkel ini masih berdentang. | My lontar pulls me back to when this forge still rang. |
| CLUE_FORGE_STONE_NOTE | Batu landasan tua di gudang Wirasana, tempat keris ditempa. | The old anvil stone in Wirasana's vault, where the keris was forged. |
| MEM_K5_FORGE_TITLE | Bengkel Tua | The Old Forge |
| MEM_K5_FORGE_IN | Ini bengkel Mpu Gandring, empu yang membuat keris itu, Nak. Kau muridnya. Jangan sampai terbakar. | This is Mpu Gandring's forge, the smith who made that keris, child. You are his apprentice. Don't get burned. |
| MEM_K5_FORGE_HINT | Padamkan tanda kutuk | Douse the curse marks |
| MEM_K5_FORGE_1 | Seorang pemuda datang meminta keris itu sebelum selesai. Sang empu menolak: sedikit lagi. | A young man comes for the keris before it is finished. The smith refuses: a little longer. |
| MEM_K5_FORGE_2 | Pemuda itu merebutnya. Sang empu mengucap kutuk yang lebih terasa daripada terdengar. Lampu bengkel meredup. | The young man snatches it. The smith speaks a curse you feel more than hear. The forge light dims. |
| MEM_K5_FORGE_3 | Tanda merah menyebar di lantai bengkel. Padamkan sebelum bertemu satu sama lain. | Red marks spread across the forge floor. Douse them before they join. |
| MEM_K5_FORGE_OUT | Begitulah kutuk itu lahir, Nak. Padamkan tandanya sebelum menyatu, dan kerisnya tenang. | That is how the curse was born, child. Douse the marks before they join, and the keris quiets. |
| HINT_KERIS | Padamkan tanda kutuk | Douse the curse marks |

VERIFY: the Mpu Gandring tale (an unfinished keris and the smith's curse) as told here; the legend's figures are named only in the codex, in Wirasana's talk and in the memory's Semar line.

### Chapter 4: Across the Sea of Sand (3.14-3.17)

### Clue `ash_trail` (step 3.14; the Hunter's cold ash trail on the coast of `tt_pesisir`; journal note only)
| Key | ID | EN |
|-----|----|----|
| CLUE_ASH_TRAIL_1 | Jejak abu di pasir, hitam seperti api yang padam. Si Pemburu lewat sini. | Ash on the sand, black as a burnt-out fire. The Hunter came this way. |
| CLUE_ASH_TRAIL_2 | Jejaknya lurus, tak berbelok untuk apa pun. Ia tak punya tempat lain untuk dituju. | The trail runs straight, bending for nothing. He has nowhere else to go. |
| CLUE_ASH_TRAIL_NOTE | Jejak abu si Pemburu menyusuri pesisir. | The Hunter's ash trail along the coast. |

### hariang_banga, Act IV entries (the coast talk, step 3.14, and the camp talk below; shared NPC, keys V301+; his Interlude, Gua Kala and C2 entries are elsewhere)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq3=13` (3.14, `"quiet": true`, with his scouts on the coast) | |
| 2 | the `camp_timur` entry below | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_HARIANG_BANGA_NAME | | |
| 1 | DLG_HARIANG_BANGA_V301 | Pengintaiku menemukan jejak abu ini dua hari lalu. Satu orang, tak berhenti makan atau tidur. | My scouts found this ash trail two days ago. One man, never stopping to eat or sleep. |
| 1 | DLG_HARIANG_BANGA_V302 | Kami mengikutinya sampai karang di sana, lalu tak ada lagi yang mau maju. Mereka bilang bayangan mereka berhenti lebih dulu. | We followed it as far as that rock, then nobody would go on. They said their shadows stopped first. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_HARIANG_BANGA_H301 | Kau kenal dia? Jejak ini seperti jejak orang yang kauberi nama. | Do you know him? This trail looks like a man you've named. |
| 1 | @NPC_HARIANG_BANGA_NAME | | |
| 1 | DLG_HARIANG_BANGA_V303 | Tidak. Ia tidak punya nama. Itu yang membuatku gelisah, Penulis. Orang tanpa nama tak bisa dibujuk, tak bisa disuap. | No. He has no name. That's what unsettles me, writer. A man without a name can't be persuaded or bribed. |
| 1 | DLG_HARIANG_BANGA_V304 | Pasir di depan itu menelan pasukan. Pakai patok batu tua sebagai penunjuk, jangan percaya matamu. | The sand ahead swallows armies. Use the old stone waymarkers as guides, don't trust your eyes. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_HARIANG_BANGA_H302 | Kau tak ikut menyeberang? | You're not crossing with me? |
| 1 | @NPC_HARIANG_BANGA_NAME | | |
| 1 | DLG_HARIANG_BANGA_V305 | Pasukanku jaga pesisir. Kutunggu kau di petilasan gurun, dan kalau sempat kuberi dua puluh tombak. | My men hold the coast. I'll wait for you at the desert petilasan, and if I can I'll bring you twenty spears. |

### Clue `pasir_waymarkers` (step 3.15; the puzzle's stone waymarkers in `tt_pasir`; ASSUMED id, set on `puzzle_solved:pasir_waymarkers`)
| Key | ID | EN |
|-----|----|----|
| CLUE_PASIR_WAYMARKERS_1 | Patok batu tua berjajar di pasir, masing-masing menghadap patok berikutnya. Yang satu miring, menunjuk arah yang salah dengan sengaja. | Old stone markers stand in the sand, each facing the next. One leans, pointing the wrong way on purpose. |
| CLUE_PASIR_WAYMARKERS_2 | Kuluruskan, dan badai abu tak lagi menelan jejak kakiku. | I set it straight, and the ash gale no longer swallows my footprints. |
| CLUE_PASIR_WAYMARKERS_NOTE | Patok batu penunjuk jalan di Lautan Pasir. | Stone waymarkers across the Sea of Sand. |

### Camp talk `camp_timur` (hariang_banga entry 2; cond `flag:mq3_6`, `zone:tt_pasir`, `"hub": true`, `"quiet": true`; do `flag:camp_timur`; at `timur_2`. The zone keeps it from replaying in Desa Purwa and Gua Kala; his other entries are in section 10, "Staging NPCs")
Topic entries (`if` = `topic:<key>`, `"quiet": true`) follow the hub shape shown at `timur_daughter`.
| Key | ID | EN |
|-----|----|----|
| @NPC_HARIANG_BANGA_NAME | | |
| DLG_HARIANG_BANGA_V1 | Ini jalan para pedagang garam. Jangan ikuti jejak abu, Penulis. Abu menuntun, tapi tak pernah ke tempat baik. | This is the salt traders' road. Don't follow the ash trail, writer. Ash leads, but never anywhere good. |
| @NPC_HERO_NAME | | |
| DLG_HARIANG_BANGA_H1 | Kenapa kau membantuku? | Why help me? |
| @NPC_HARIANG_BANGA_NAME | | |
| DLG_HARIANG_BANGA_V2 | Ciung dan aku sepakat satu hal: kami tak mau jadi lakon yang diulang. Tidurlah. Candinya di balik bukit itu. | Ciung and I agree on one thing: we won't be a lakon that gets replayed. Sleep. The shrine is behind that hill. |
| @NPC_HARIANG_BANGA_NAME | | |
| DLG_HARIANG_BANGA_V306 | Aku berjaga dulu. Tanya apa saja, selagi api masih kecil. | I'll take the first watch. Ask anything, while the fire's still small. |

| Entry (topic) | Key | ID | EN |
|-------|-----|----|----|
| ask_1 `hb_ciung` | @NPC_HARIANG_BANGA_NAME | | |
| ask_1 | DLG_HARIANG_BANGA_V307 | Ciung memanggilku kakak sekali, di sungai itu, dan aku masih mendengarnya tiap malam. | Ciung called me brother once, at that river, and I still hear it every night. |
| ask_1 | DLG_HARIANG_BANGA_V308 | Dulu ia musuhku, lalu saudaraku, tanpa jeda di antaranya. Aku belum tahu cara membawa dua hal itu sekaligus. | He was my enemy, then my brother, with no gap between. I don't yet know how to carry both. |
| ask_1 | DLG_HARIANG_BANGA_V309 | Kau yang membuatnya mungkin. Jangan minta aku mengatakannya lagi. | You made it possible. Don't ask me to say it twice. |
| ask_2 `hb_mother` | @NPC_HARIANG_BANGA_NAME | | |
| ask_2 | DLG_HARIANG_BANGA_V310 | Ibuku di kandang itu, dan aku di jalan. Tiap hari aku menghitung mana yang lebih melanggar sumpahku. | My mother is in that cage and I'm on the road. Every day I count which breaks my oath worse. |
| ask_2 | DLG_HARIANG_BANGA_V311 | Orang bilang keputusanmu di sungai menentukan sel itu bergaris cahaya atau tidak. Aku tak pernah menanyakannya padamu. | They say your choice at the river decided whether that cell has a lamp. I never asked you about it. |
| ask_2 | DLG_HARIANG_BANGA_V312 | Bukan karena tak ingin tahu. Karena aku takut jawabannya terlalu cepat. | Not because I don't want to know. Because I fear the answer would come too fast. |
| ask_3 `hb_hunter` | @NPC_HARIANG_BANGA_NAME | | |
| ask_3 | DLG_HARIANG_BANGA_V313 | Aku bertarung dengan banyak orang. Orang bertopeng itu lain: ia tak menahan diri, dan tak menikmatinya. | I've fought many men. The masked one's different: he doesn't hold back, and he doesn't enjoy it. |
| ask_3 | DLG_HARIANG_BANGA_V314 | Seorang prajurit tahu rasa takut dan rasa marah. Ia hanya punya rasa lelah. Itu lebih sulit dilawan. | A soldier knows fear and anger. He only has weariness. That's harder to fight. |
| ask_3 | DLG_HARIANG_BANGA_V315 | Kalau kau menang dan ada waktu, tanyakan namanya. Aku ingin tahu. | If you win and there's time, ask his name. I'd like to know. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_HB_ASK_1 | Soal Ciung. | About Ciung. | `topic:hb_ciung` |
| CHOICE_HB_ASK_2 | Soal ibumu. | About your mother. | `topic:hb_mother` |
| CHOICE_HB_ASK_3 | Soal si bertopeng. | About the masked one. | `topic:hb_hunter` |
| CHOICE_HB_LEAVE | Tidurlah dulu, aku jaga. | Sleep first, I'll watch. | |

### Laras chapter LC4 `lc4` (step 3.17; kind chapter, 5 to 8 minutes; the dunes and the shrine; opened from the clue `lc4_lontar` in the alcove beside `timur_2`)
On completion (`memory_done:lc4`): `flag:mq3_lc`, `flag:laras_key_sand_tunnel` (opens the wind-tunnel shortcut), `flag:laras_sabotage_keris_seventh_stake` (the seventh stake cannot light for good).
| Key | ID | EN |
|-----|----|----|
| LC_4_TITLE | Wajah Siapa | Whose Face |
| @NPC_LARAS_NAME | | |
| LC4_1 | Aku mencoba menggambar wajah Kak di pasir. Matanya kuingat, mulutnya tidak. | I try to draw Kak's face in the sand. I remember the eyes, not the mouth. |
| LC4_2 | Aku ingat kejar-kejaran dan kata "kakak". Dan Kak kalah. Itu juga kuingat, hehe. | I remember the tag game and the word "kakak". And that you lost. I remember that too, hehe. |
| LC4_5 | Mereka menggiringku menyeberangi pasir. Penjaganya tak berwajah, jadi aku menyebut nama mereka sampai mereka berhenti: tiga napas, tak lebih. | They march me across the sand. The guards have no faces, so I say their names until they stop: three breaths, no more. |
| LC4_6 | Ada kisi besi di bukit pasir, setengah terkubur. Angin keluar dari bawahnya seperti napas. Kubuka, dan terowongan itu menganga. | There's an iron grate in a dune, half buried. Wind breathes out from under it. I pry it open, and the tunnel gapes. |
| LC4_7 | Kak lewat terowongan ini nanti. Badai abu tak bisa masuk. Aku mengikat batu agar kisinya tak menutup lagi. | Kak will come through this tunnel later. The ash gale can't get in. I wedge a stone so the grate won't close again. |
| LC4_8 | Di candi, ada tujuh tonggak, dan yang ketujuh tertulis nama seorang empu yang belum mati. Aku disuruh membaca keras-keras. Aku membaca satu huruf saja. | At the shrine there are seven stakes, and the seventh bears the name of a smith who isn't dead yet. They tell me to read aloud. I read one letter only. |
| LC4_3 | Angin menghapus Ka-ku. Tidak boleh. Kutulis lagi, lebih dalam, di tonggak ketujuh. | The wind wipes out my Ka. No way. I write it again, deeper, on the seventh stake. |
| LC4_4 | Kak... wajahmu tak bisa kulihat lagi, hanya bayangan. Di lontarku tinggal satu huruf: Ka. Kugenggam erat-erat. Jangan terlambat. | Kak... I can't see your face anymore, only a shape. One letter is left on my half: Ka. I'm holding it tight. Don't be late. |

### Chapter 5: The Eastern Shrine and Aria's Face (3.18-3.22)

### Beat `shrine_sight` (if `!flag:beat_shrine_sight`, `flag:mq3_6b`, `zone:tt_candi`; do `flag:beat_shrine_sight`). The turn. Area `candi_inner_sanctum` sets `mq3_6b`; the trigger needs `flag:laras_key_sand_tunnel` (the shortcut), so the breach is Laras's
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SHRINE_SIGHT_0 | Terowongan angin Laras berujung di balik arca. Dari sana kau melihat seluruh pelataran candi, dan tujuh tonggak merah berdiri melingkarinya. | Laras's wind tunnel ends behind a statue. From there you see the whole shrine court, and seven red stakes ringed around it. |
| BEAT_SHRINE_SIGHT_1 | Di seberang pelataran candi, kecil sekali di bawah arca-arca: Laras. | Across the shrine court, small beneath the statues: Laras. |
| @NPC_HERO_NAME | | |
| BEAT_SHRINE_SIGHT_H1 | Laras! | Laras! |
| @ | | |
| BEAT_SHRINE_SIGHT_2 | Ia tidak menoleh. Ia membaca dari lontar yang sangat tua, pelan, dan Si Tanpa Ngaran menarik keris dari sarungnya. | She doesn't turn. She reads from a very old lontar, slowly, and the Nameless Hunter draws a keris from its sheath. |
| BEAT_SHRINE_SIGHT_4 | Satu huruf padam di lontarnya. Ia berhenti, mengerutkan dahi, lalu menulis sesuatu yang tak ada dalam teks itu. | A letter fades on her strip. She stops, frowns, then writes something that isn't in the text. |
| BEAT_SHRINE_SIGHT_5 | Tonggak ketujuh berkedip dua kali, lalu tak menyala. Ka kecil terukir di kayunya, dan kutukan itu tersandung pada huruf itu. | The seventh stake flickers twice, then does not light. A small Ka is carved in its wood, and the curse stumbles on the letter. |
| BEAT_SHRINE_SIGHT_3 | Keris itu bangun, dan seluruh candi berdengung seperti lonceng yang dipukul dari dalam. | The keris wakes, and the whole shrine hums like a bell struck from inside. |
| @NPC_HERO_NAME | | |
| BEAT_SHRINE_SIGHT_H2 | Ka-nya bekerja. Ia menghentikan satu tonggak dari sana. Baik, Laras. Sekarang giliranku. | Her Ka works. She stopped one stake from over there. All right, Laras. My turn. |

### Beat `shrine_lancers` (if `!flag:beat_shrine_lancers`, `flag:beat_shrine_sight`, `flag:choice_mercy`; do `flag:beat_shrine_lancers`). Choice 3, Mercy: Hariang Banga's lancers join the shrine assault. With `choice_judgment` the beat never plays and you face the court alone
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SHRINE_LANCERS_1 | Derap kuda mengguncang pasir di belakangmu. Dua puluh tombak Mataram turun dari bukit, bendera mereka terbalik tanda tak membawa dendam. | Hoofbeats shake the sand behind you. Twenty Mataram spears pour down the hill, their banners reversed to show they carry no grudge. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_SHRINE_LANCERS_2 | Ibu menulis dari kandangnya. Katanya: kalau kau membantu seseorang, bantu sampai selesai. Aku di sini. | Mother wrote from her cage. She said: if you help someone, help to the end. I'm here. |
| @NPC_HERO_NAME | | |
| BEAT_SHRINE_LANCERS_H1 | Kau tak perlu membawa pasukan sebanyak ini. | You didn't have to bring this many men. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_SHRINE_LANCERS_3 | Dua puluh bukan pasukan. Itu hutang yang belum kubayar karena lampu di selnya. | Twenty isn't an army. It's a debt I haven't paid for the lamp in her cell. |
| BEAT_SHRINE_LANCERS_4 | Mereka menahan tonggak di sisi barat. Yang di tengah itu urusanmu. | They'll hold the stakes on the west side. The one in the middle is yours. |

### Beat `keris` (if `!flag:beat_keris`, `flag:mq3_7`; do `flag:beat_keris`, `codex:keris_gandring`). Choice 4: the fate of the blade. Mpu Wirasana stands in the court (the second `timur_empu` instance)
| Key | ID | EN |
|-----|----|----|
| BEAT_KERIS_1 | Keris itu terdiam di tanganmu. Kutukannya habis terbakar, tinggal besi hangat yang masih ingat untuk apa ia ditempa. | The keris falls quiet in your hand. The curse has burned itself out, leaving warm iron that remembers what it was made for. |
| BEAT_KERIS_3 | Tujuh tonggak padam satu demi satu, namanya hangus menjadi abu halus. Yang terakhir, milik Wirasana, padam paling pelan. | The seven stakes go out one by one, their names crumbling to fine ash. The last, Wirasana's, goes out slowest. |
| @NPC_TIMUR_EMPU_NAME | | |
| BEAT_KERIS_4 | Aku datang karena mendengar bunyinya mati. Bunyi yang kudengar sejak kecil. Sunyi ini... aneh. | I came because I heard its sound die. A sound I've heard since childhood. This silence... is strange. |
| BEAT_KERIS_5 | Bilah itu sekarang milikmu, Penulis. Aku tak berhak memutuskan, dan aku lega tak harus. | The blade is yours now, writer. I have no right to decide, and I'm relieved I don't have to. |
| @NPC_HERO_NAME | | |
| BEAT_KERIS_H1 | Kau tahu apa yang kau minta kalau aku membawanya padamu? | Do you know what you're asking if I bring it to you? |
| @NPC_TIMUR_EMPU_NAME | | |
| BEAT_KERIS_6 | Aku tahu. Tempa ulang, dan aku mungkin menciptakan yang lebih buruk. Tenggelamkan, dan aku tak pernah tahu apakah ia tidur. | I know. Reforge it and I might make something worse. Sink it, and I'll never know if it sleeps. |
| BEAT_KERIS_2 | Besi bisa ditempa ulang, atau direlakan. | Iron can be forged again, or let go. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_KERIS_1 | Bawa ke sang empu untuk ditempa ulang. | Take it to the empu to reforge. | `flag:choice_reforge`, `give:keris_gandring` |
| CHOICE_KERIS_2 | Serahkan pada sungai. | Give it to the river. | `flag:choice_sink`, `give:batu_kali` |

### Beat `keris_reforge` (if `!flag:beat_keris_reforge`, `flag:choice_reforge`, `flag:beat_keris`; do `flag:beat_keris_reforge`). Choice 4, Reforge: Keris Mpu Gandring is yours; Ratna tempers your blade in the epilogue
| Key | ID | EN |
|-----|----|----|
| @NPC_TIMUR_EMPU_NAME | | |
| BEAT_KERIS_REFORGE_1 | Kalau begitu, tempa ulang. Bukan olehku. Aku sudah terlalu lama mengenalnya. | Then reforge it. Not by me. I've known it too long. |
| BEAT_KERIS_REFORGE_2 | Putriku akan menyelesaikannya, dengan lipatan miringnya yang menyebalkan itu. Aku akan berdiri di pintu. | My daughter will finish it, with those infuriating crooked folds. I'll stand at the door. |
| @NPC_HERO_NAME | | |
| BEAT_KERIS_REFORGE_H1 | Bilah itu sekarang ada di sabukku, ringan, lebih ringan dari seharusnya. Ia seperti menunggu aku bicara. | The blade at my belt is light, lighter than it should be. It seems to wait for me to speak. |
| @ | | |
| BEAT_KERIS_REFORGE_2B | Keris Mpu Gandring menjadi senjatamu. Ratna akan menyepuh bilahmu saat semuanya selesai. | Keris Mpu Gandring becomes your weapon. Ratna will temper your blade once it's all over. |

### Beat `keris_sink` (if `!flag:beat_keris_sink`, `flag:choice_sink`, `flag:beat_keris`; do `flag:beat_keris_sink`). Choice 4, Sink: Batu Kali; the cursed wisps of Tanah Timur turn into fireflies
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_KERIS_SINK_1 | Jurang sungai berdesis ketika keris itu jatuh, dan airnya berhenti seakan menahan napas. | The river canyon hisses as the keris falls, and the water stops as though holding its breath. |
| BEAT_KERIS_SINK_2 | Dari dasar naik sebutir batu bulat, hangat, licin, tanpa satu pun tanda merah. | From the bottom rises a round stone, warm, smooth, without one red mark. |
| @NPC_TIMUR_EMPU_NAME | | |
| BEAT_KERIS_SINK_3 | Batu kali. Sungai tak pernah mengembalikan pisau, tapi kadang ia mengembalikan sesuatu yang lebih jinak. | A river stone. A river never gives back a knife, but sometimes it gives back something gentler. |
| @ | | |
| BEAT_KERIS_SINK_4 | Di sabana yang jauh, lampu-lampu merah kutukan melepas warnanya satu per satu, dan menjadi kunang-kunang. | Far across the savanna, the red curse-lights let go of their colour one by one and become fireflies. |
| @NPC_HERO_NAME | | |
| BEAT_KERIS_SINK_H1 | Batu Kali, bersih dan hangat. Ia akan menjaga Sakti-ku tetap mengalir. | The Batu Kali, clean and warm. It will keep my Sakti flowing. |

### Clue `hunter_mask_4` and memory `h4` (step 3.21; H4, kind walk; the prologue raid from Aria's eyes)
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

### Clue `mask_joined` and memory `k6_servant` (step 3.21; K6, kind walk, about 2 minutes, no mechanic; the joined mask at the shrine door, cond `flag:mq3_h7`)
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
| @ | | |
| BEAT_HUNTER_SHRINE_1 | Di belakangmu, bayangan candi berdiri. Ia tidak berkata apa-apa. Ia sudah tak punya apa-apa untuk dikatakan. | Behind you, the shrine's shadow stands up. He says nothing. He has nothing left to say. |
| BEAT_HUNTER_SHRINE_2 | Pelataran itu sunyi. Tujuh tonggak yang padam masih mengepul tipis, seperti dupa yang dilupakan. | The court is silent. The seven spent stakes still smoke thinly, like forgotten incense. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_SHRINE_H1 | Topeng ini retak di tengah, tapi ia masih menahanmu. Aku akan melepasnya. | This mask is cracked down the middle, but it still holds you. I'll take it off. |
| @ | | |
| BEAT_HUNTER_SHRINE_3 | Lontarmu hangat di sabuk, dan satu huruf di dalamnya berdenyut: Ka. Kau tahu ia belum sempat selesai. | Your lontar is warm at your belt, and one letter in it pulses: Ka. You know she wasn't able to finish. |

### Beat `hunter_name` (if `!flag:beat_hunter_name`, `quest:mq3=done`; do `flag:beat_hunter_name`, `codex:nameless_hunter`, `start:mq4`, `goto:desa_purwa:from_riders`)
| Key | ID | EN |
|-----|----|----|
| BEAT_HUNTER_NAME_1 | Topeng itu retak di tengah. Di baliknya, wajah seorang pemuda: wajah yang dulu dipakai raja palsu. | The mask cracks down the middle. Under it, a young man's face: the face the false king once wore. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_NAME_H1 | Aria Kebonan. Itu namamu. Ambil kembali. | Aria Kebonan. That is your name. Take it back. |
| @ | | |
| BEAT_HUNTER_NAME_3 | Lalu langit padam. Tepi matahari menghitam, dan Laras, di ujung pelataran, lenyap di tengah satu kata. | Then the sky goes out. The sun's rim turns black, and Laras, at the far end of the court, vanishes mid-word. |
| @NPC_LARAS_NAME | | |
| BEAT_HUNTER_NAME_L1 | Kak, kalau kau dengar, aku menulis Ka di | Kak, if you can hear me, I'm writing Ka on |
| @NPC_HUNTER_NAME | | |
| BEAT_HUNTER_NAME_5 | Aria. Dulu aku tahu nama itu. Dia pergi ke tempat yang kutuju. | Aria. I knew that name, once. She's gone where I was going. |
| @ | | |
| BEAT_HUNTER_NAME_6 | Ia luntur seperti tinta kena hujan. Ikatan lontarnya pecah, nama-nama terbang pulang, kecuali namanya. Di kandang Galuh, seorang tua mendapat wajahnya kembali. | He runs like ink in rain. His bundle bursts and the names fly home, all but hers. In Galuh's cage, an old man gets his face back. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_HUNTER_NAME_4 | Naik. Kuda kami membawamu pulang sebelum kabut menutup jalan. Gua Kala ada di belakang desamu. | Up. Our horses carry you home before the fog closes the road. Kala's cave is behind your village. |
| @NPC_HERO_NAME | | |
| BEAT_HUNTER_NAME_H2 | Tadi dia menulis sesuatu di pasir sebelum hilang. Aku tak melihat apa. | She was writing something in the sand before she went. I didn't see what. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_HUNTER_NAME_7 | Nanti kau lihat. Naik dulu. | You'll see. Get up first. |

## 10. Interlude and Act V (MQ4 4.1-4.22)
The Interlude is quiet and has no combat: the village forgets its own names, you write them back, Ibu sees three of Laras's things, the brothers eat at one table, Aria asks to be forgotten, and Semar says why he remembers. Act V is the sea: the lost song, the mangrove beacons, Laras in the dark water, the Three Sacred Trials, the cliff offering and the Trial of the Waves. Step indices are 0-based: `step:mq4=0` is 4.1, `step:mq4=8` is 4.9. Act VI starts at "### Act VI: Gua Kala" (another fragment).

### Interlude "Rumah yang Sunyi" (4.1-4.8, about 50 minutes, no combat)
Regional character: Ibu (want: two cups she cannot explain; turn: the shelf; close: the second cup set straight). Choice 3 shapes the dinner (`choice_mercy` / `choice_judgment`; v4's `choice_silent` is now `choice_judgment`).

### Beat `eclipse_home` (if `!flag:beat_eclipse_home`, `step:mq4=0`, `zone:desa_purwa`; do `flag:beat_eclipse_home`). 4.1, the riders drop you at spawn `from_riders`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_ECLIPSE_HOME_1 | Gerhana menggantung di atas Desa Purwa. Tak ada bayangan, dan tak ada yang menyapa sesama dengan nama. | The Eclipse hangs over Desa Purwa. No shadows, and nobody greets a neighbour by name. |
| BEAT_ECLIPSE_HOME_3 | Pasukan berkuda Hariang Banga menurunkanmu di jalan di depan rumahmu, lalu berbalik tanpa bersuara, kudanya gelisah. | Hariang Banga's riders set you down on the road before your house, then turn away without a word, their horses uneasy. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_ECLIPSE_HOME_4 | Aku akan datang bila ibumu mengundang. Ciung juga. Tapi lihat dulu gua di belakang desamu. | I'll come if your mother invites me. Ciung too. But look first at the cave behind your village. |
| @ | | |
| BEAT_ECLIPSE_HOME_2 | Di belakang desa, kabut di mulut gua memakan setiap huruf yang kau lempar kepadanya. | Behind the village, the fog at the cave mouth eats every glyph you throw at it. |
| @NPC_HERO_NAME | | |
| BEAT_ECLIPSE_HOME_H1 | Rumah. Tapi aku mendengar langkahku sendiri terlalu keras. | Home. But I hear my own footsteps too loudly. |
| @ | | |
| BEAT_ECLIPSE_HOME_5 | Di jendela-jendela, lampu menyala, tapi tak seorang pun berdiri di depannya. | In the windows lamps burn, but nobody stands before them. |
| BEAT_ECLIPSE_HOME_6 | Kau berjalan ke utara, ke arah kabut, karena sesuatu harus diuji dulu sebelum kau bisa percaya padanya. | You walk north toward the fog, because something has to be tested before you can believe it. |

### Beat `north_fog` (if `!flag:beat_north_fog`, `flag:mq4_i0`; do `flag:beat_north_fog`). 4.1, area `purwa_north_fog` sets `mq4_i0`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_NORTH_FOG_1 | Kau menggambar Ka di udara. Kabut menelannya sebelum garisnya selesai, tanpa suara, tanpa cahaya. | You draw Ka in the air. The fog swallows it before the stroke is done, without a sound, without light. |
| BEAT_NORTH_FOG_2 | Kau mencoba Ga, lalu Na. Kabut menelan semuanya seperti mulut yang sudah lama lapar. | You try Ga, then Na. The fog swallows them all like a mouth long hungry. |
| @NPC_HERO_NAME | | |
| BEAT_NORTH_FOG_H1 | Bukan kabut. Ini mulut. Dan ia belum mau makan aku. | Not fog. A mouth. And it doesn't want to eat me yet. |
| @ | | |
| BEAT_NORTH_FOG_3 | Dari kedalaman kabut, sesuatu yang besar bernapas. Tarikan, lalu hembusan, sangat pelan, seperti orang yang tidur. | From deep in the fog, something huge breathes. In, then out, very slowly, like a sleeper. |
| BEAT_NORTH_FOG_4 | Di desa, seseorang memanggil nama anaknya dan lupa di tengah kata. Kau berbalik. Ada yang harus dikerjakan di sini sebelum ke mana pun. | In the village, someone calls a child's name and forgets mid-word. You turn. There's work here before anywhere else. |

### purwa_old_couple, the Interlude entry (4.2; new first entry in the NPC's file; keys V20+ so the prologue keys stay free)
| Entry | if | do |
|-------|----|----|
| I1 | `step:mq4=1` (`talked_to:purwa_old_couple`) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| I1 | @NPC_PURWA_OLD_COUPLE_NAME | | |
| I1 | DLG_PURWA_OLD_COUPLE_V20 | Nak, kau tahu kami? Kami menyiapkan mangkuk ketiga tiap malam, dan tak ingat untuk siapa. | Child, do you know us? We set out a third bowl each night, and can't remember for whom. |
| I1 | @NPC_HERO_NAME | | |
| I1 | DLG_PURWA_OLD_COUPLE_H20 | Untuk cucu kalian. Ciung. | For your grandson. Ciung. |
| I1 | @NPC_PURWA_OLD_COUPLE_NAME | | |
| I1 | DLG_PURWA_OLD_COUPLE_V21 | Ciung. Ciung... bunyinya seperti burung. Lucu, ya? Seperti mengunyah batu kecil yang manis. | Ciung. Ciung... it sounds like a bird. Funny, isn't it? Like chewing a small sweet stone. |
| I1 | DLG_PURWA_OLD_COUPLE_V22 | Kata Semar, nama yang tak ditulis akan hilang. Kami tak punya lontar. Kami hanya punya mangkuk. | Semar says a name not written will vanish. We have no lontar. We only have a bowl. |
| I1 | @NPC_HERO_NAME | | |
| I1 | DLG_PURWA_OLD_COUPLE_H21 | Dia hidup. Dia akan datang makan malam ini, bersama kakaknya. | He's alive. He'll come to dinner tonight, with his brother. |
| I1 | @NPC_PURWA_OLD_COUPLE_NAME | | |
| I1 | DLG_PURWA_OLD_COUPLE_V23 | Kakak? Kami punya satu cucu saja... atau dua? Sudah, sudah. Tanyalah penjaga lapak, ia juga bingung. | A brother? We only had one grandson... or two? Never mind. Ask the stall-keeper, she's lost too. |
| I1 | DLG_PURWA_OLD_COUPLE_V24 | Dan kalau kau punya tinta, tolong tuliskan nama di pintu rumah-rumah yang paling sunyi. | And if you have ink, please write a name on the doors of the quietest houses. |

### purwa_stall, the Interlude entry (4.2; second step trigger; keys V20+)
| Entry | if | do |
|-------|----|----|
| I1 | `step:mq4=1` (`talked_to:purwa_stall`; sets `mq4_i0b`) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| I1 | @NPC_PURWA_STALL_NAME | | |
| I1 | DLG_PURWA_STALL_V20 | Aku jual cabai, tapi pagi ini tak ingat harganya. Aku bahkan tak ingat nama anakku. | I sell chilli, but this morning I couldn't remember the price. I can't even remember my child's name. |
| I1 | @NPC_HERO_NAME | | |
| I1 | DLG_PURWA_STALL_H20 | Lelaki bertopeng polos itu datang lagi? | The man in the blank mask came again? |
| I1 | @NPC_PURWA_STALL_NAME | | |
| I1 | DLG_PURWA_STALL_V21 | Tidak. Sekarang bukan ia yang datang. Sekarang kami yang pelan-pelan berhenti datang pada diri sendiri. | No. It's not him coming now. Now it's us slowly ceasing to come to ourselves. |
| I1 | DLG_PURWA_STALL_V22 | Ada tiga rumah yang paling parah: keluarga Eman, keluarga Karsih, keluarga Dulah. Tiang pintu mereka kosong. | Three houses are worst: the Eman family, the Karsih family, the Dulah family. Their doorposts are blank. |
| I1 | @NPC_HERO_NAME | | |
| I1 | DLG_PURWA_STALL_H21 | Aku kenal mereka semua. Aku akan menuliskannya. | I know them all. I'll write them. |
| I1 | @NPC_PURWA_STALL_NAME | | |
| I1 | DLG_PURWA_STALL_V23 | Kalau kau tahu nama mereka, kau lebih kaya dari semua pedagang di pasar ini. Cepatlah. | If you know their names, you're richer than every trader in this market. Hurry. |

### door_a, door_b, door_c (three houses; name NPC_DOOR_NEIGHBOUR_NAME; v4 text kept). Step 4.3: a write card each
Each entry 1 runs the write card (glyph ids **ASSUMED**: door_a `sunda_ka,sunda_ga`, door_b `sunda_nga,sunda_ca`, door_c `jawa_ha,jawa_na`). The hero knows his neighbours; they have lost their own names. The Eclipse is in the air, but the doorposts take ink. The cond moves from `step:mq4=1` (v4, and the desa_purwa.md legend) to `step:mq4=2`.
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq4=2`, `!flag:name_door_x` | `write:door_x:...`, `flag:name_door_x` (x is a, b or c) |
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

### Clues, Ibu's shelf (step 4.4; `shelf_ribbon`, `shelf_board`, `shelf_strip` in house_a; the items come from Acts I to III; journal notes, no hunt)
| Key | ID | EN |
|-----|----|----|
| CLUE_SHELF_RIBBON_1 | Rak Laras kosong, kecuali bekas lingkaran debu tempat pita itu dulu digantung. | Laras's shelf is empty, except for a ring in the dust where the ribbon used to hang. |
| CLUE_SHELF_RIBBON_2 | Pita itu tersangkut di bambu saat ia melarikan diri. Kuletakkan kembali di tempatnya. | That ribbon caught on bamboo when she broke free. I put it back where it belongs. |
| CLUE_SHELF_RIBBON_NOTE | Pita Laras, kembali di raknya. | Laras's ribbon, back on her shelf. |
| CLUE_SHELF_BOARD_1 | Di sudut rak, ada ruang selebar sebilah papan. Pas untuk papan lantai kereta itu. | In the corner of the shelf, a gap as wide as one board. Exactly the wagon floorboard. |
| CLUE_SHELF_BOARD_2 | "Jangan buang cangkirku yang gompal." Ia menulisnya dari dalam kereta penjara, dan tulisannya masih rapi. | "Don't throw out my chipped cup." She wrote it from inside a prison wagon, and her hand is still neat. |
| CLUE_SHELF_BOARD_NOTE | Papan kereta dengan pesan Laras, di raknya. | The wagon board with Laras's message, on her shelf. |
| CLUE_SHELF_STRIP_1 | Selembar lontar kecil dengan satu huruf: Ka. Ia menulisnya di Mataram, di bawah ancaman. | A small lontar strip with one letter: Ka. She wrote it in Mataram, under threat. |
| CLUE_SHELF_STRIP_2 | Hurufnya sudah memudar di tepinya, tapi garis tengahnya tegas. Itu Laras sekali. | The letter has faded at its edges, but the middle stroke is firm. That's Laras all over. |
| CLUE_SHELF_STRIP_NOTE | Helai Ka tulisan Laras, di raknya. | Laras's Ka strip, on her shelf. |

### ibu, the Interlude (entries of the table in section 5; shared NPC, new keys V301+/H301+)
| Entry | if | do |
|-------|----|----|
| 2 | `step:mq4=3`, `item:laras_ribbon,item:laras_board,item:laras_strip_ka` (4.4; sets `mq4_2`) | |
| 3 | `step:mq4=3` (4.4, `"quiet": true`; no items yet) | |
| H | `quest:mq4=active` (`"hub": true`, `"quiet": true`; after 4.4) | |
| T1 | `topic:ibu_cups` (`"quiet": true`) | |
| T2 | `topic:ibu_dinner` (`"quiet": true`) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_IBU_H5 | Bu, lihat. Pita, sebuah papan, dan selembar lontar. Semuanya milik seseorang. | Ibu, look. A ribbon, a board, a strip of lontar. They all belong to someone. |
| 2 | @NPC_IBU_NAME | | |
| 2 | DLG_IBU_V12 | Pita ini... Ibu pernah mengikatnya di rambut seseorang. | This ribbon... I once tied it in someone's hair. |
| 2 | DLG_IBU_V13 | Papan ini tertulis: "Jangan buang cangkirku yang gompal." Ibu tidak membuangnya, kan? | This board says: "Don't throw out my chipped cup." I never threw it out, did I? |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_IBU_H6 | Tidak, Bu. Ibu tidak pernah membuangnya. | No, Ibu. You never did. |
| 2 | @NPC_IBU_NAME | | |
| 2 | DLG_IBU_V301 | Dan ini... satu huruf. Ibu tidak bisa membacanya, tapi jariku tahu garisnya. | And this... one letter. I can't read it, but my fingers know the line. |
| 2 | DLG_IBU_V302 | Tiap pagi Ibu menuang dua cangkir, dan tiap malam Ibu menuang yang kedua kembali ke teko. Kenapa, Nak? | Every morning I pour two cups, and every night I pour the second back into the pot. Why, child? |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_IBU_H301 | Karena Ibu menunggu. Dan karena tubuh Ibu belum lupa, walau kepala Ibu sudah. | Because you're waiting. And because your body hasn't forgotten, though your head has. |
| 2 | @NPC_IBU_NAME | | |
| 2 | DLG_IBU_V303 | Kalau begitu biar tubuhku yang menang. Cangkir kedua kutata lurus, dan kuberi teh yang hangat. | Then let my body win. I'll set the second cup straight, and pour it warm. |
| 2 | DLG_IBU_V304 | Dua anak dari seberang sungai makan malam di sini nanti. Kau yang harus menceritakan siapa mereka. | Two boys from across the river eat here tonight. You'll have to tell me who they are. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_IBU_H3 | Ibu menangis. | Ibu, you're crying. |
| 3 | @NPC_IBU_NAME | | |
| 3 | DLG_IBU_V10 | Masa? Asap dapur, mungkin. Tiap pagi begini, Nak, dan Ibu tak tahu kenapa. | Am I? Kitchen smoke, maybe. Every morning like this, child, and I don't know why. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_IBU_H4 | Aku tahu kenapa. Akan kuceritakan setelah dia pulang. | I know why. I'll tell you once she's home. |
| 3 | @NPC_IBU_NAME | | |
| 3 | DLG_IBU_V11 | Siapa pun dia, bawa pulang. Bawa sesuatu yang pernah ia sentuh, Ibu ingin melihatnya. | Whoever she is, bring her home. Bring something she touched, I'd like to see it. |
| 3 | DLG_IBU_V305 | Rak di kamar belakang itu kosong, tapi Ibu selalu mengelapnya. Lihatlah, siapa tahu ada yang tertinggal. | The shelf in the back room is empty, but I always dust it. Take a look, maybe something was left. |
| H | @NPC_IBU_NAME | | |
| H | DLG_IBU_V306 | Duduklah dulu, Nak. Ibu mau teh, kamu mau cerita. Atau sebaliknya. | Sit a while, child. I want tea, you want to talk. Or the other way round. |
| T1 | @NPC_IBU_NAME | | |
| T1 | DLG_IBU_V307 | Cangkir yang gompal itu tak bisa Ibu buang. Tanganku menolak, seperti anak yang menolak digendong orang asing. | I can't throw out that chipped cup. My hand refuses, like a child refusing a stranger's arms. |
| T1 | DLG_IBU_V308 | Kalau ada yang pernah memakainya, mungkin dia suka bibirnya yang kasar. Orang kecil suka hal-hal yang tak sempurna. | If someone used it, maybe she liked its rough rim. Small people like imperfect things. |
| T2 | @NPC_IBU_NAME | | |
| T2 | DLG_IBU_V309 | Nasi sudah Ibu tanak dua kali, dan sambalnya lebih pedas dari biasa. Pangeran kan biasanya makan yang pedas? | I've steamed the rice twice, and the sambal is hotter than usual. Princes eat spicy food, don't they? |
| T2 | DLG_IBU_V310 | Kau harus bantu Ibu sopan. Mereka datang dari dua sisi, dan Ibu hanya punya satu meja. | You have to help me be polite. They come from two sides, and I only have one table. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_IBU_ASK_1 | Soal cangkir yang gompal. | About the chipped cup. | `topic:ibu_cups` |
| CHOICE_IBU_ASK_2 | Soal makan malam nanti. | About tonight's dinner. | `topic:ibu_dinner` |
| CHOICE_IBU_LEAVE | Aku lihat dulu ke luar, Bu. | I'll look outside first, Ibu. | |

### Beat `ibu_cups` (if `!flag:beat_ibu_cups`, `flag:mq4_2`; do `flag:beat_ibu_cups`). 4.4, the second beat
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_IBU_CUPS_1 | Ibu menuang teh ke cangkir yang gompal, lalu menunggu seseorang duduk. Tak ada yang duduk. Ia tersenyum juga. | Ibu pours tea into the chipped cup, then waits for someone to sit. Nobody sits. She smiles anyway. |
| BEAT_IBU_CUPS_2 | Ia meluruskan cangkir kedua sampai gagangnya menghadap kursi kosong, persis, seperti dulu, tanpa tahu mengapa. | She straightens the second cup until its handle faces the empty chair, exactly, as before, without knowing why. |
| @NPC_HERO_NAME | | |
| BEAT_IBU_CUPS_H1 | Dia akan duduk di situ lagi, Bu. Aku janji. | She'll sit there again, Ibu. I promise. |
| @ | | |
| BEAT_IBU_CUPS_3 | Di luar, dua derap kuda berhenti di depan pagar. Ibu mengangkat kepala, dan untuk sekejap, ia terlihat seperti sedang mengingat sesuatu. | Outside, two sets of hooves stop at the gate. Ibu lifts her head, and for a moment she looks like she's remembering something. |

### Beat `table_dishes` (if `!flag:beat_table_dishes`, `flag:mq4_i3`; do `flag:beat_table_dishes`; listed before `quiet_house` and `quiet_house_judgment`). 4.5, the playable dinner: pass dishes, choose a seat (flavour only)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_TABLE_DISHES_1 | Ibu menghidangkan nasi dan sambal. Ciung Wanara dan Hariang Banga masing-masing menunggu yang lain duduk dulu. | Ibu serves rice and sambal. Ciung Wanara and Hariang Banga each wait for the other to sit first. |
| BEAT_TABLE_DISHES_2 | Dua kursi tersisa: satu di samping Ciung, satu di samping Hariang. | Two seats are left: one beside Ciung, one beside Hariang. |
| CHOICE_SEAT_1 | Duduk di samping Ciung. | Sit beside Ciung. |
| CHOICE_SEAT_2 | Duduk di samping Hariang. | Sit beside Hariang. |

Choices: CHOICE_SEAT_1 does `flag:seat_ciung`, CHOICE_SEAT_2 does `flag:seat_hariang`. Neither is a stake; the dinner beat for the Choice 3 flag plays right after either.

### Beat `quiet_house` (if `!flag:beat_quiet_house`, `flag:beat_table_dishes`, `flag:choice_mercy`; do `flag:beat_quiet_house`). Choice 3, Mercy: the warm dinner
| Key | ID | EN |
|-----|----|----|
| BEAT_QUIET_HOUSE_1 | Di meja ibumu, dua cangkir dan dua pemuda yang menolak duduk di kursi yang sama. Ciung Wanara dari tepi barat, Hariang Banga dari timur, bertemu sebagai saudara untuk pertama kali. | At your mother's table, two cups and two young men who refuse the same chair. Ciung Wanara from the west bank, Hariang Banga from the east, meeting as brothers for the first time. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_QUIET_HOUSE_2 | Kandangnya sekarang punya lampu. Kecil. Dia tak minta lebih. | The cage has a lamp now. A small one. He doesn't ask for more. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_QUIET_HOUSE_3 | Terima kasih. | Thank you. |
| @ | | |
| BEAT_QUIET_HOUSE_5 | Ibu menaruh dua sendok nasi di piring masing-masing tanpa bertanya. Ciung tertawa, pertama kali dalam seminggu, dan Hariang ikut tersenyum karena tak tahu harus apa lagi. | Ibu puts two scoops of rice on each plate without asking. Ciung laughs, the first time in a week, and Hariang smiles because he doesn't know what else to do. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_QUIET_HOUSE_6 | Sambalnya pedas sekali. Kalian punya ibu yang berbahaya. | The sambal is very hot. You have a dangerous mother. |
| @NPC_HERO_NAME | | |
| BEAT_QUIET_HOUSE_H1 | Dia bukan ibuku saja malam ini. Dia ibu semua orang di meja ini. | She isn't only my mother tonight. She's everyone's at this table. |
| @ | | |
| BEAT_QUIET_HOUSE_4 | Di perapian, topeng kosong tergeletak di antara bara. Tak ada yang menyentuhnya. | In the hearth, an empty mask lies among the embers. Nobody touches it. |

### Beat `quiet_house_judgment` (if `!flag:beat_quiet_house`, `flag:beat_table_dishes`, `flag:choice_judgment`; do `flag:beat_quiet_house`). Choice 3, Judgment: the same table, strained (replaces v4 `quiet_house_silent`)
| Key | ID | EN |
|-----|----|----|
| BEAT_QUIET_HOUSE_1 | (same as above) | (same as above) |
| BEAT_QUIET_HOUSE_J2 | Ciung menatap api, bukan kau. Kandang di Galuh dijaga ketat, dan tak seorang pun menyebutkannya. | Ciung watches the fire, not you. The cage in Galuh is strictly guarded, and nobody mentions it. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_QUIET_HOUSE_J3 | Hukum itu adil, kata mereka. Aku belum menemukan kata untuk membantahnya. Aku tak mau. | The law is just, they say. I haven't found a word to argue. I don't want to. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_QUIET_HOUSE_J4 | Itu bukan tuduhan, Kak. Itu pagar sungai. Pagar tak menyakiti, hanya menahan. | That isn't an accusation, brother. That's the river's fence. A fence doesn't hurt, it only holds. |
| @ | | |
| BEAT_QUIET_HOUSE_J5 | Ibu menaruh dua sendok nasi di piring masing-masing tanpa bertanya. Mereka makan, rapi, tanpa bicara. Sendok berdenting terlalu keras. | Ibu puts two scoops of rice on each plate without asking. They eat, neatly, without speaking. The spoons clink too loudly. |
| @NPC_HERO_NAME | | |
| BEAT_QUIET_HOUSE_JH1 | Aku memilih pagar itu. Dan malam ini aku mendengar bunyi pagar itu di meja ibuku. | I chose that fence. And tonight I hear the fence at my mother's table. |
| BEAT_QUIET_HOUSE_4 | (same as above) | (same as above) |

### aria_kebonan (by the burned stage; name NPC_ARIA_KEBONAN_NAME; step 4.6 `talked_to:aria_kebonan`, sets `mq4_i4`; since v5 a step, no longer optional; keys V301+)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq4=5`, `!flag:aria_talk` (4.6) | `flag:aria_talk` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_ARIA_KEBONAN_NAME | | |
| 1 | DLG_ARIA_KEBONAN_V1 | Wajahku kembali, tapi namaku tinggal bunyi tanpa arti. Kala tidur di jantung gua, di balik Jurang Lupa. | My face is back, but my name is a sound without meaning. Kala sleeps at the cave's heart, past the Abyss of Forgetting. |
| 1 | DLG_ARIA_KEBONAN_V301 | Kala tak lapar pada orang. Ia lapar pada nama. Mulutnya terbuka sambil tidur, dan tiap nama yang hilang jatuh ke dalamnya. | Kala isn't hungry for people. It's hungry for names. Its mouth hangs open as it sleeps, and every lost name falls in. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_ARIA_KEBONAN_H301 | Nama Laras ada di sana? | Is Laras's name in there? |
| 1 | @NPC_ARIA_KEBONAN_NAME | | |
| 1 | DLG_ARIA_KEBONAN_V302 | Dipecah tiga. La, Ra, Sa. Masing-masing diikat pada satu kenangan hari itu, dan Kala menggerogoti kenangan itu sepotong demi sepotong. | Split in three. La, Ra, Sa. Each tied to one memory of that day, and Kala gnaws the memories piece by piece. |
| 1 | DLG_ARIA_KEBONAN_V303 | Isi lubangnya dengan yang benar, dan huruf itu pulang. Itu yang kuingat dari perjanjian itu. Cuma itu. | Fill the holes with the right things, and the letter comes home. That's what I remember of the pact. Only that. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_ARIA_KEBONAN_H302 | Kau membantuku, setelah semua yang terjadi? | You're helping me, after everything? |
| 1 | @NPC_ARIA_KEBONAN_NAME | | |
| 1 | DLG_ARIA_KEBONAN_V304 | Aku tak membantu. Aku membuang apa yang tersisa. Seorang pelayan mengembalikan barang yang bukan miliknya. | I'm not helping. I'm discarding what's left. A servant returning something that isn't his. |
| 1 | DLG_ARIA_KEBONAN_V2 | Sebutlah namaku sekali saja, kalau kau bersedia. | Say my name once, if you will. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_ARIA_KEBONAN_H1 | Aria Kebonan. | Aria Kebonan. |
| 1 | @NPC_ARIA_KEBONAN_NAME | | |
| 1 | DLG_ARIA_KEBONAN_V3 | Terima kasih. Sudah lama sekali. | Thank you. It has been so long. |
| 1 | DLG_ARIA_KEBONAN_V305 | Setelah itu, lupakan aku. Jangan tulis namaku di batu mana pun. Biarkan aku jadi bunyi. Sekarang temui Semar. | After that, forget me. Don't write my name on any stone. Let me be a sound. Now go to Semar. |
| 2 | DLG_ARIA_KEBONAN_V4 | Pergilah. Aku akan duduk di sini dan berusaha mengingat. | Go. I'll sit here and try to remember. |

### cepot, the Interlude entry (the sanggar, step 4.7; shared NPC, keys V301+; `"quiet": true`)
| Entry | if | do |
|-------|----|----|
| I1 | `step:mq4=6` (`"quiet": true`) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| I1 | @NPC_CEPOT_NAME | | |
| I1 | DLG_CEPOT_V301 | Kau kembali! Ayah tak mau makan, tak mau tidur. Ia hanya menatap lakon yang tak mau selesai. | You're back! Father won't eat, won't sleep. He just stares at a lakon that won't finish. |
| I1 | @NPC_HERO_NAME | | |
| I1 | DLG_CEPOT_H301 | Kau sendiri baik-baik saja? | Are you all right yourself? |
| I1 | @NPC_CEPOT_NAME | | |
| I1 | DLG_CEPOT_V302 | Aku lupa nama kucing tetangga. Kupikir itu hal besar, sampai aku sadar aku juga lupa nama paman sendiri. | I forgot the neighbour's cat's name. I thought it was a big deal, until I noticed I'd forgotten my own uncle's too. |
| I1 | DLG_CEPOT_V303 | Aku takut, tapi jangan bilang Ayah. Dia sudah cukup berat. Bicaralah, dia menunggumu di dalam. | I'm scared, but don't tell Father. He's carrying enough. Go on in, he's waiting for you. |

### semar, the Interlude talk (entry of the table in section 5; step 4.7 `step:mq4=6`, sets `mq4_i5`, opens the south exit; shared NPC, keys V301+) and a hub for later
| Entry | if | do |
|-------|----|----|
| 9 | `step:mq4=6` (4.7) | |
| K | `step:mq4=8` (4.9, at `kidul_1`; see Act V below) | |
| H | `quest:mq4=active` (`"hub": true`, `"quiet": true`; after 4.7) | |
| T1 | `topic:semar_ismaya` (`"quiet": true`) | |
| T2 | `topic:semar_kala` (`"quiet": true`) | |
| T3 | `topic:semar_sea` (`"quiet": true`) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 9 | @NPC_SEMAR_NAME | | |
| 9 | DLG_SEMAR_V35 | Kau heran kenapa aku masih ingat, hehe. Aku bukan dari desa ini, Nak. | You wonder why I still remember, hehe. I'm not from this village, child. |
| 9 | @NPC_HERO_NAME | | |
| 9 | DLG_SEMAR_H35 | Lalu kau siapa sebenarnya? | Then who are you, really? |
| 9 | @NPC_SEMAR_NAME | | |
| 9 | DLG_SEMAR_V36 | Dalam kisah wayang, aku dewa yang memilih hidup sebagai abdi. Dewa sulit dibuat lupa, dan aku keras kepala. | In the wayang tales, I'm a god who chose to live as a servant. Gods are hard to make forget, and I'm stubborn. |
| 9 | DLG_SEMAR_V301 | Sumpahku sederhana: aku tak boleh pergi dari mereka yang kulayani. Kala ingin aku pergi. Aku tak pergi. | My vow is simple: I may not leave those I serve. Kala wants me gone. I'm not going. |
| 9 | @NPC_HERO_NAME | | |
| 9 | DLG_SEMAR_H301 | Tapi kau tak bisa menyelamatkan Laras dari dalam sana. | But you can't save Laras from in there. |
| 9 | @NPC_SEMAR_NAME | | |
| 9 | DLG_SEMAR_V302 | Tidak. Kala lebih tua dari sumpahku, tapi bukan lebih tua dari semuanya. Ada yang lebih tua dari dia: laut. | No. Kala is older than my vow, but not older than everything. Something is older than he is: the sea. |
| 9 | DLG_SEMAR_V303 | Laut menulis ombak tiap detik. Hurufnya tak pernah selesai, jadi tak bisa dimakan. Dari sana kau mulai. | The sea writes the wave every second. Its letter is never finished, so it can't be eaten. Start there. |
| 9 | @NPC_HERO_NAME | | |
| 9 | DLG_SEMAR_H302 | Kau ikut? | Are you coming? |
| 9 | @NPC_SEMAR_NAME | | |
| 9 | DLG_SEMAR_V304 | Aku sampai di sana duluan, hehe. Gerbang selatan akan terbuka. Pergilah sebelum ibumu menyuruhmu makan lagi. | I'll get there first, hehe. The south gate will open. Go before your mother tells you to eat again. |
| 9 | DLG_SEMAR_V37 | Ada yang lebih tua dari Kala: laut. Laut tak pernah lupa. Pergilah ke selatan. | Something is older than Kala: the sea. The sea does not forget. Go south. |
| H | @NPC_SEMAR_NAME | | |
| H | DLG_SEMAR_V305 | Hehe, tanyalah. Aku punya jawaban, atau cerita yang mirip jawaban. | Hehe, ask. I have answers, or stories that look like answers. |
| T1 | @NPC_SEMAR_NAME | | |
| T1 | DLG_SEMAR_V306 | Ismaya dan saudaranya berebut sebuah gunung, dan ditakdirkan jadi manusia kecil yang menjaga manusia besar. | Ismaya and his brother quarrelled over a mountain, and were fated to be small men who guard the great. |
| T1 | DLG_SEMAR_V307 | Aku tak menyesal. Dari bawah, kau melihat banyak hal yang tak terlihat dari takhta. | I don't regret it. From below, you see many things you can't see from the throne. |
| T1 | DLG_SEMAR_V308 | Yang ini, versi dalangnya, bukan sabda. Kau boleh menolaknya, hehe. | This is the dalang's version, not scripture. You may reject it, hehe. |
| T2 | @NPC_SEMAR_NAME | | |
| T2 | DLG_SEMAR_V309 | Kala bukan penjahat, Nak. Ia dewa waktu yang dibuat lapar karena tak ada yang meruwatnya. | Kala isn't a villain, child. He's a god of time made hungry because nobody performed his ruwatan. |
| T2 | DLG_SEMAR_V310 | Kau tak membunuh waktu. Kau mengajaknya pulang. Itu yang akan kita lakukan di gua. | You don't kill time. You invite it home. That's what we'll do in the cave. |
| T2 | DLG_SEMAR_V311 | Tapi aksaramu harus lengkap dulu, termasuk satu yang belum kau punya. Itu sebabnya selatan. | But your aksara must be complete first, including one you don't have yet. That's why the south. |
| T3 | @NPC_SEMAR_NAME | | |
| T3 | DLG_SEMAR_V312 | Orang pesisir tak menyembah laut, mereka bertamu. Bawalah oleh-oleh yang benar, yaitu nama dan lagu. | The coast folk don't worship the sea, they visit it. Bring the right gift: a name and a song. |
| T3 | DLG_SEMAR_V313 | Jangan pakai hijau. Jangan menunjuk ombak. Dan kalau Mbah Wiryo, juru kunci pantai, berkata diam, diamlah. | Don't wear green. Don't point at the waves. And if Mbah Wiryo, the coast's juru kunci, says be quiet, be quiet. |
| T3 | DLG_SEMAR_V314 | Ini kepercayaan, bukan hukum. Tapi tata krama tak butuh hukum, hehe. | This is belief, not law. But manners need no law, hehe. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_SEMAR_ASK_1 | Soal sumpah Ismaya. | About Ismaya's vow. | `topic:semar_ismaya` |
| CHOICE_SEMAR_ASK_2 | Soal Kala. | About Kala. | `topic:semar_kala` |
| CHOICE_SEMAR_ASK_3 | Soal laut selatan. | About the southern sea. | `topic:semar_sea` |
| CHOICE_SEMAR_LEAVE | Aku jalan dulu. | I'll get going. | |

VERIFY: Semar as a god who chose to live as a servant (Batara Ismaya in Javanese and Sundanese wayang), the quarrel over a mountain, and Kala as the god of time made hungry (Murwakala tradition).

### Beat `south_gate` (if `!flag:beat_south_gate`, `flag:mq4_i6`; do `flag:beat_south_gate`). 4.8, `zone_entered:sk_pantai` sets `mq4_i6`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SOUTH_GATE_1 | Gerbang selatan terbuka, dan kabut surut seperti seseorang yang mundur dengan sopan. Di baliknya, pasir hitam dan laut yang hijau. | The south gate opens, and the fog withdraws like someone stepping back politely. Beyond it, black sand and a green sea. |
| BEAT_SOUTH_GATE_2 | Angin asin menampar wajahmu. Tak ada gerhana di sini, atau gerhananya lebih jauh, atau laut tak mengizinkannya. | Salt wind slaps your face. No eclipse here, or it's farther off, or the sea doesn't allow it. |
| @NPC_HERO_NAME | | |
| BEAT_SOUTH_GATE_H1 | Aku bisa mendengar ombak menyebut sesuatu. Hampir seperti namaku. | I can hear the surf saying something. Almost like my name. |
| @ | | |
| BEAT_SOUTH_GATE_3 | Di cakrawala selatan, cahaya hijau samar menyala di atas air: keraton laut, jauh sekali. Jangan menunjuknya. | On the southern horizon, a faint green glow burns over the water: the sea pavilion, very far. Don't point at it. |
| BEAT_SOUTH_GATE_4 | Di pantai, sekelompok nelayan duduk menambal jala dan tak bicara sepatah pun. | On the shore, a group of fishers sit mending nets and say not a word. |

### Act V "Laut Tak Pernah Lupa" (4.9-4.22). Regional characters: Mbah Wiryo (want: the sea to say Sumi's name; turn: the sea answers; close: a louder answer) and Sari (want: the beacons lit so boats find home; turn: she remembers the second verse; close: she sings it)

### Chapter 3: Kampung Nelayan and the Lost Song (4.9-4.12)

### Beat `song_hook` (if `!flag:beat_song_hook`, `flag:mq4_a1`, `zone:sk_nelayan`; do `flag:beat_song_hook`, `codex:sedekah_laut`). K8 hook and the arrival slice, 4.9 (`zone_entered:sk_nelayan` sets `mq4_a1`). Nobody speaks: you have not met Wiryo yet
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SONG_HOOK_1 | Di Kampung Nelayan, rumah-rumah panggung berdiri di atas air surut, dan para nelayan menambal jala untuk sedekah laut. Mereka mulai bernyanyi, lalu hanya bergumam. Kata-katanya hilang. | In Kampung Nelayan, stilt houses stand over the ebbed water, and the fishers mend nets for the sea offering. They begin to sing, then only hum. The words are gone. |
| BEAT_SONG_HOOK_3 | Seorang nenek berhenti di tengah baris, memandang tangannya sendiri, lalu mengambil jarum lagi seolah tak terjadi apa-apa. | An old woman stops mid-line, looks at her own hands, then picks up her needle again as if nothing happened. |
| BEAT_SONG_HOOK_4 | Di rak jemur, ikan asin bergantung dalam barisan rapi. Tak ada yang berani tertawa terlalu keras. | On the drying racks, salt fish hang in neat rows. Nobody dares laugh too loudly. |
| @NPC_HERO_NAME | | |
| BEAT_SONG_HOOK_H1 | Lagu itu hilang? Dari siapa aku bisa mendapatkannya? | The song is lost? Who can I get it from? |
| @ | | |
| BEAT_SONG_HOOK_2 | Di ujung dermaga, seorang lelaki tua berdiri menghadap laut, dan seorang gadis muda menggulung tali dengan terlalu keras. | At the end of the jetty an old man stands facing the sea, and a young girl coils a rope far too hard. |

VERIFY: the sea offering (sedekah laut, labuhan) and how the village keeps it; the song is the game's.

### semar, at the petilasan `kidul_1` (entry K of the table above; 4.9 `step:mq4=8`, `"quiet": true`; shared NPC, keys V301+)
| Entry | Key | ID | EN |
|-------|-----|----|----|
| K | @NPC_SEMAR_NAME | | |
| K | DLG_SEMAR_V315 | Sudah kubilang aku sampai duluan, hehe. Lihat cahaya hijau di cakrawala itu? Jangan tunjuk. | I said I'd get here first, hehe. See that green glow on the horizon? Don't point. |
| K | @NPC_HERO_NAME | | |
| K | DLG_SEMAR_H315 | Ini pantai yang baik. Kenapa terasa menahan napas? | This is a good shore. Why does it feel like it's holding its breath? |
| K | @NPC_SEMAR_NAME | | |
| K | DLG_SEMAR_V316 | Karena lagunya hilang. Setiap tahun mereka menyanyi untuk laut, dan tahun ini mulut mereka kosong. | Because the song is gone. Every year they sing for the sea, and this year their mouths are empty. |
| K | DLG_SEMAR_V317 | Gerhana tak sampai ke sini, tapi lupanya sampai. Lupa itu pandai berenang. | The eclipse doesn't reach here, but the forgetting does. Forgetting is a good swimmer. |
| K | @NPC_HERO_NAME | | |
| K | DLG_SEMAR_H316 | Siapa yang harus kutemui? | Who should I meet? |
| K | @NPC_SEMAR_NAME | | |
| K | DLG_SEMAR_V318 | Orang tua di ujung dermaga: Mbah Wiryo, juru kunci pantai ini. Ia berbisik pada ombak tiap senja, dan ombak balas berbisik. | The old man at the end of the jetty: Mbah Wiryo, keeper of this coast. He whispers to the surf each dusk, and it whispers back. |
| K | DLG_SEMAR_V319 | Dan gadis yang menggulung tali itu Sari, seorang penyelam. Ia tahu jalan di bawah air lebih baik dari siapa pun di sini. | And the girl coiling rope is Sari, a diver. She knows the way under the water better than anyone here. |
| K | DLG_SEMAR_V320 | Bicaralah dengan sopan, dan jangan sebut apa yang kau cari di depan ombak. Mereka suka kejutan yang baik. | Speak politely, and don't say what you're looking for in front of the waves. They like good surprises. |

### kidul_jurukunci (Mbah Wiryo; name NPC_WIRYO_NAME; shared NPC, new keys V301+; replace the main-path entries, keep any SQ entries; the SQ-K2 giver unlocks on `flag:mq4_4`)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:mq4=done` | |
| 2 | the `camp_kidul` entry below (`flag:mq4_8`, `zone:sk_pantai`, `!flag:mq5_1`, `"quiet": true`) | `flag:camp_kidul` |
| 3 | `step:mq4=9` (4.10; sets `mq4_4`) | `codex:nyi_roro_kidul`, `codex:three_trials` |
| 4 | `step:mq4=10` (4.11, `"quiet": true`) | |
| 5 | `step:mq4=12` (4.13 nudge, `"quiet": true`) | |
| H | `quest:mq4=active` (`"hub": true`, `"quiet": true`) | |
| T1 | `topic:wiryo_sumi` (`"quiet": true`) | |
| T2 | `topic:wiryo_manners` (`"quiet": true`) | |
| T3 | `topic:wiryo_trials` (`"quiet": true`) | |
| 6 | `quest:mq4=active` | |
| (keep) | SQ entries and the current fallback | |

The hub (entry H) sits before entry 6 so the player can still ask; entry 6 is the plain nudge once the hub is left.
| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_WIRYO_V6 | Senja tadi kusebut namanya lagi. Hari ini ombak menjawab lebih keras. Mungkin Sumi-ku senang. | I said her name again at dusk. Today the surf answered louder. Maybe my Sumi is glad. |
| 3 | @NPC_WIRYO_NAME | | |
| 3 | DLG_WIRYO_V1 | Berhenti di garis pasang, Nak. Laut ini punya tata krama, dan dia menilai tamu dari cara melangkah. | Stop at the tide line, child. This sea has manners, and it judges a guest by how they walk. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_WIRYO_H1 | Aku mencari suara adikku. Orang di desaku bilang laut tak pernah lupa. | I'm looking for my sister's voice. They say in my village the sea never forgets. |
| 3 | @NPC_WIRYO_NAME | | |
| 3 | DLG_WIRYO_V2 | Laut tak mengembalikan siapa pun. Ia hanya mengingat. Tiap senja kubisikkan nama istriku, Sumi, ke ombak, dan ombak membisikkannya kembali. Empat puluh tahun. | The sea gives nobody back. It only remembers. Every dusk I whisper my wife's name, Sumi, to the surf, and the surf whispers it back. Forty years. |
| 3 | DLG_WIRYO_V3 | Kata orang, Nyi Roro Kidul, ratu laut selatan, menguasai laut ini. Jangan memakai hijau di pantai, jangan menunjuk ombak. Yang pantas boleh lewat karang dan tebing. | They say Nyi Roro Kidul, queen of the southern sea, rules these waters. Don't wear green on the shore, don't point at the waves. The worthy may pass the reef and the cliff. |
| 3 | DLG_WIRYO_V301 | Orang tua kami menyebutnya tiga ujian suci: obor di karang, arus di gua, dan ombak di keraton. Yang lulus ketiganya, laut menyebut namanya. | Our elders call them the three sacred trials: the torches on the reef, the current in the cave, and the waves at the pavilion. Whoever passes all three, the sea says their name. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_WIRYO_H301 | Tapi tak seorang pun di sini bernyanyi. | But nobody here is singing at all. |
| 3 | @NPC_WIRYO_NAME | | |
| 3 | DLG_WIRYO_V302 | Gerhana memakan lagu sedekah laut kami, bait demi bait. Orang-orang menambal jala dalam diam, seperti menunggu seseorang mengingat. | The Eclipse ate our sea-offering song, verse by verse. People mend nets in silence, as if waiting for someone to remember. |
| 3 | DLG_WIRYO_V303 | Tiga keluarga memegang tiga bait, tapi lupa bait sendiri. Sari, penyelam muda itu, tahu jalan di sini lebih baik dariku. Temui dia. | Three families hold three verses, but forget their own. Sari, the young diver, knows the paths here better than I do. Meet her. |
| 3 | DLG_WIRYO_V304 | Senja nanti aku memanggil Sumi seperti biasa. Kau boleh ikut mendengarkan, asal tak menunjuk. | At dusk I'll call Sumi as usual. You may listen, as long as you don't point. |
| 4 | @NPC_WIRYO_NAME | | |
| 4 | DLG_WIRYO_V7 | Tiga keluarga, tiga bait. Tanyakan pelan-pelan, Nak. Lupa itu pemalu. | Three families, three verses. Ask gently, child. Forgetting is shy. |
| 5 | @NPC_WIRYO_NAME | | |
| 5 | DLG_WIRYO_V305 | Kau sudah dengar ombak menjawabku. Sekarang giliran suar. Sari tahu tempatnya, di hutan bakau. | You've heard the surf answer me. Now it's the beacons' turn. Sari knows the place, in the mangroves. |
| H | @NPC_WIRYO_NAME | | |
| H | DLG_WIRYO_V306 | Tanya, Nak. Ombak sedang pasang, dan orang tua suka bercerita saat air naik. | Ask, child. The tide is rising, and old men like to talk when water climbs. |
| T1 | @NPC_WIRYO_NAME | | |
| T1 | DLG_WIRYO_V307 | Sumi suka menjemur kain di batu itu. Ia bilang jemuran yang basah itu doa yang malas. | Sumi liked to dry cloth on that rock. She said wet washing was a lazy prayer. |
| T1 | DLG_WIRYO_V308 | Empat puluh tahun aku memanggilnya dan ombak membalas, tapi tak pernah dengan suaranya. Hanya dengan namanya. | Forty years I've called her and the surf answers, but never in her voice. Only with her name. |
| T1 | DLG_WIRYO_V309 | Itu cukup. Orang yang berhenti memanggil sudah menyerah, dan aku belum. | That's enough. A man who stops calling has given up, and I haven't. |
| T2 | @NPC_WIRYO_NAME | | |
| T2 | DLG_WIRYO_V310 | Tata krama laut ini sederhana: jangan hijau, jangan menunjuk, jangan menghitung ombak keras-keras. | The sea's manners are simple: no green, no pointing, don't count the waves aloud. |
| T2 | DLG_WIRYO_V311 | Kalau kau lupa, tunduk saja. Laut tak butuh pembelaan, hanya sopan santun. | If you forget, just bow. The sea needs no defence, only courtesy. |
| T2 | DLG_WIRYO_V312 | Ini kepercayaan kami, bukan hukum. Orang dari tempat lain boleh tak percaya. Tetaplah sopan. | This is our belief, not a law. People from elsewhere may disbelieve. Be polite anyway. |
| T3 | @NPC_WIRYO_NAME | | |
| T3 | DLG_WIRYO_V313 | Ujian pertama di karang: barisan obor Lampor yang berjalan di air surut. Padamkan, jangan kejar. | The first trial is on the reef: the Lampor torch-lines walking on low-tide water. Put them out, don't chase them. |
| T3 | DLG_WIRYO_V314 | Kedua di gua karang, tempat arus palung menguji siapa yang ingin lewat. Ketiga di keraton, tempat ombak menjawab. | The second in the sea cave, where the abyssal current tests who wants to pass. The third at the pavilion, where the waves answer. |
| T3 | DLG_WIRYO_V315 | Tak seorang pun menang atas ujian ini. Kau hanya lulus, atau tidak. | Nobody wins these trials. You only pass, or you don't. |
| 6 | DLG_WIRYO_V4 | Karang dulu, lalu tebing. Dan jangan hijau. | The reef first, then the cliff. And no green. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_WIRYO_ASK_1 | Soal Sumi. | About Sumi. | `topic:wiryo_sumi` |
| CHOICE_WIRYO_ASK_2 | Soal tata krama laut. | About the sea's manners. | `topic:wiryo_manners` |
| CHOICE_WIRYO_ASK_3 | Soal tiga ujian. | About the three trials. | `topic:wiryo_trials` |
| CHOICE_WIRYO_LEAVE | Aku jalan dulu. | I'll go on. | |

VERIFY: the green taboo on the southern coast; the juru kunci's role; Nyi Roro Kidul as belief. Told as belief throughout. The "three sacred trials" are the game's.

### kidul_sari (Sari; `sk_nelayan`, with other instances in `sk_bakau` and the mouth of `sk_gua`; name NPC_KIDUL_SARI_NAME; new in v5; keys V1+)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq4=9`, `flag:mq4_4` (4.10; sets `mq4_4b`) | |
| 2 | `step:mq4=9`, `!flag:mq4_4` (`"quiet": true`) | |
| 3 | `step:mq4=12` (4.13, in `sk_bakau`, `"quiet": true`) | |
| 4 | `step:mq4=16` (4.17, at the mouth of `sk_gua`, `"quiet": true`) | |
| 5 | `flag:mq4_8` (after the Trial of the Waves; `"quiet": true`) | |
| H | `quest:mq4=active` (`"hub": true`, `"quiet": true`) | |
| T1 | `topic:sari_grandmother` (`"quiet": true`) | |
| T2 | `topic:sari_diving` (`"quiet": true`) | |
| T3 | `topic:sari_father` (`"quiet": true`) | |
| 6 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_KIDUL_SARI_NAME | | |
| 1 | DLG_KIDUL_SARI_V1 | Kau yang disebut Mbah Wiryo? Kukira lebih tinggi. Hehe, maaf, aku gugup kalau orang baru datang. | You're the one Mbah Wiryo mentioned? I thought you'd be taller. Hehe, sorry, I get nervous when strangers arrive. |
| 1 | DLG_KIDUL_SARI_V2 | Aku Sari. Aku menyelam untuk mutiara dan jala tersangkut. Sekarang untuk yang lebih sulit: mengingat. | I'm Sari. I dive for pearls and snagged nets. Now for something harder: remembering. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_KIDUL_SARI_H1 | Mbah Wiryo bilang kau tahu jalan di bawah air. | Mbah Wiryo says you know the way under the water. |
| 1 | @NPC_KIDUL_SARI_NAME | | |
| 1 | DLG_KIDUL_SARI_V3 | Pagi tadi tiga keluarga bernyanyi tiga bait, lalu berhenti di tengah kata. Itu bukan sakit. Itu pencuri. | This morning three families sang three verses, then stopped mid-word. That's not an illness. That's a thief. |
| 1 | DLG_KIDUL_SARI_V4 | Nenekku mengajariku bait kedua. Nadanya kuingat, kata-katanya lepas seperti ikan dari tangan. | My grandmother taught me the second verse. I remember the tune, but the words slip like fish from my hands. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_KIDUL_SARI_H2 | Kita cari kata-katanya satu per satu. | We'll find the words one by one. |
| 1 | @NPC_KIDUL_SARI_NAME | | |
| 1 | DLG_KIDUL_SARI_V5 | Setelah itu ada suar pasang-surut di hutan bakau. Mati semua. Tanpa suar, perahu tak tahu arah pulang. Aku ikut denganmu ke sana. | After that there are tidal beacons in the mangroves. All dead. Without beacons, boats can't tell which way is home. I'll go with you. |
| 1 | DLG_KIDUL_SARI_V6 | Mulai dari jala di halaman barat, dan cari keluarga yang paling keras kepala berkata "lupa". Biasanya mereka yang paling ingat. | Start with the nets in the west yard, and find the family most stubborn about saying "forgot". They usually remember most. |
| 2 | @NPC_KIDUL_SARI_NAME | | |
| 2 | DLG_KIDUL_SARI_V7 | Temui Mbah Wiryo dulu. Ia tak suka orang yang bicara denganku sebelum ia. Laut punya urutan. | See Mbah Wiryo first. He dislikes people who talk to me before him. The sea has an order. |
| 3 | @NPC_KIDUL_SARI_NAME | | |
| 3 | DLG_KIDUL_SARI_V8 | Hutan bakau ini pasang dua kali sehari, dan dua-duanya tak ramah. Ikuti papan, jangan lihat ke bawah. | These mangroves flood twice a day, and neither time is friendly. Follow the boards, don't look down. |
| 3 | DLG_KIDUL_SARI_V9 | Ada tiga suar. Satu di mulut sungai, satu di tikungan akar, satu di ujung dermaga bakau. Semua harus menyala bersamaan. | There are three beacons. One at the river mouth, one at the root bend, one at the end of the mangrove jetty. All must burn together. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_KIDUL_SARI_H3 | Kau takut dengan arusnya? | Are you scared of the current? |
| 3 | @NPC_KIDUL_SARI_NAME | | |
| 3 | DLG_KIDUL_SARI_V10 | Aku takut kalau tak ada yang menyalakannya. Itu bedanya. Pegang apinya, aku tahu jalannya. | I'm scared if nobody lights them. That's different. You hold the fire, I know the way. |
| 4 | @NPC_KIDUL_SARI_NAME | | |
| 4 | DLG_KIDUL_SARI_V11 | Di dalam sana arusnya tak punya wajah, tak punya hukum, hanya selera. Nenekku bilang arus palung memilih siapa yang lewat. | In there the current has no face and no law, only appetite. My grandmother says the abyssal current chooses who passes. |
| 4 | DLG_KIDUL_SARI_V12 | Katanya ia tak memilih yang paling kuat, tapi yang tak ingin menang. Aku tak mengerti, tapi aku percaya. | She said it doesn't choose the strongest, but the one who doesn't want to win. I don't understand, but I believe it. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_KIDUL_SARI_H4 | Kau menunggu di sini? | You'll wait here? |
| 4 | @NPC_KIDUL_SARI_NAME | | |
| 4 | DLG_KIDUL_SARI_V13 | Aku menjaga talinya. Kalau tali berhenti bergerak, aku akan menarik, dan kau akan marah padaku. Tak apa. | I'll mind the rope. If it stops moving, I'll pull, and you'll be angry with me. That's fine. |
| 5 | @NPC_KIDUL_SARI_NAME | | |
| 5 | DLG_KIDUL_SARI_V14 | Semua perahu pulang semalam, tanpa satu pun tersesat. Aku bernyanyi di dermaga sampai tengah malam. | Every boat came home last night, not one lost. I sang on the jetty until midnight. |
| 5 | DLG_KIDUL_SARI_V15 | Nenek pasti bangga. Atau menyuruhku mengulang bait kedua dari awal, hehe. | Grandmother would be proud. Or tell me to sing the second verse again from the start, hehe. |
| H | @NPC_KIDUL_SARI_NAME | | |
| H | DLG_KIDUL_SARI_V16 | Mau tahu apa lagi? Aku punya waktu selama talinya belum kusut. | What else do you want to know? I have time as long as the rope isn't tangled. |
| T1 | @NPC_KIDUL_SARI_NAME | | |
| T1 | DLG_KIDUL_SARI_V17 | Nenekku menyanyikan bait kedua tiap petang di teras. Suaranya serak, tapi nadanya tak pernah meleset. | My grandmother sang the second verse every dusk on the porch. Her voice was hoarse, but the tune never slipped. |
| T1 | DLG_KIDUL_SARI_V18 | Kalau ia lupa kata, ia mengarang kata lain yang lebih lucu, dan seluruh dermaga tertawa. | When she forgot a word, she made up a funnier one, and the whole jetty laughed. |
| T1 | DLG_KIDUL_SARI_V19 | Mungkin itu sebabnya lagunya selamat sejauh ini. Lagu suka dibuat sedikit bodoh. | Maybe that's why the song survived this long. Songs like being made a little silly. |
| T2 | @NPC_KIDUL_SARI_NAME | | |
| T2 | DLG_KIDUL_SARI_V20 | Menyelam itu soal sabar. Laut tak suka orang yang buru-buru, dan ia selalu tahu. | Diving is about patience. The sea dislikes people in a hurry, and it always knows. |
| T2 | DLG_KIDUL_SARI_V21 | Aturanku tiga: hitung napas, ikat tali, dan jangan pernah mengambil sesuatu tanpa meninggalkan sesuatu. | My three rules: count your breaths, tie your rope, and never take anything without leaving something. |
| T2 | DLG_KIDUL_SARI_V22 | Mutiara pertamaku kukembalikan, jadi laut menganggapku sopan. Itu investasi terbaikku. | I returned my first pearl, so the sea thinks I'm polite. Best investment I ever made. |
| T3 | @NPC_KIDUL_SARI_NAME | | |
| T3 | DLG_KIDUL_SARI_V23 | Waktu aku kecil, ayahku melaut di malam sedekah laut, dan suar pasang padam karena badai. | When I was small, my father went to sea on sedekah laut night, and the tidal beacons went out in a storm. |
| T3 | DLG_KIDUL_SARI_V24 | Seluruh kampung menyalakan obor di dermaga sambil bernyanyi, dan ia pulang lewat suara itu. Itu alasanku. | The whole village lit torches on the jetty and sang, and he came home by that sound. That's my reason. |
| 6 | DLG_KIDUL_SARI_2 (keep) | | |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_SARI_ASK_1 | Soal nenekmu. | About your grandmother. | `topic:sari_grandmother` |
| CHOICE_SARI_ASK_2 | Soal menyelam. | About diving. | `topic:sari_diving` |
| CHOICE_SARI_ASK_3 | Soal ayahmu. | About your father. | `topic:sari_father` |
| CHOICE_SARI_LEAVE | Nanti kita bicara lagi. | We'll talk again. | |

### Hunt K8: The sea's name (4.11-4.12)
The three verses are the sea-song (the game's). `song_3` opens the memory.
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

### Beat `song_whole` (if `!flag:beat_song_whole`, `flag:mq4_h1`; do `flag:beat_song_whole`). 4.11, the three verses come together
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SONG_WHOLE_1 | Kau mengucapkan ketiga bait itu pelan-pelan di dermaga: pasang, perahu pulang, nama dalam air. Seorang nelayan berhenti menambal jala. | You say the three verses slowly on the jetty: the tide, the boats coming home, the name in the water. A fisher stops mending his net. |
| BEAT_SONG_WHOLE_2 | Lalu nenek yang menangis mengangkat suaranya, dan seluruh dermaga ikut, tersendat, salah nada, tapi bernyanyi. | Then the old woman who wept lifts her voice, and the whole jetty joins, stumbling, off-key, but singing. |
| @NPC_KIDUL_SARI_NAME | | |
| BEAT_SONG_WHOLE_3 | Itu salah di bait dua! Biarkan. Itu salah yang paling benar kudengar seumur hidupku. | That's wrong in verse two! Leave it. It's the rightest wrong I've heard in my life. |
| @NPC_WIRYO_NAME | | |
| BEAT_SONG_WHOLE_4 | Bait ketiga bukan lagu, Nak. Itu petunjuk memanggil. Aku akan menunjukkan dengan cara yang benar saat senja. | The third verse isn't a song, child. It's instructions for calling. I'll show you properly at dusk. |
| @NPC_HERO_NAME | | |
| BEAT_SONG_WHOLE_H1 | Aku mau lihat. Aku butuh tahu bagaimana memanggil sebuah nama ke laut. | I want to see. I need to know how to call a name to the sea. |
| @ | | |
| BEAT_SONG_WHOLE_5 | Di batu pantai, tempat Mbah Wiryo selalu berdiri, jejak kaki tua tertanam dalam di pasir. Lontarmu menghangat. | On the shore rock where Mbah Wiryo always stands, old footprints are pressed deep in the sand. Your lontar warms. |

### Memory `k8_wiryo_wife` (walk; K8, step 4.12; kelir figure: Sumi, Mbah Wiryo's wife; no death shown, the screen fades to light)
| Key | ID | EN |
|-----|----|----|
| MEM_K8_WIRYO_WIFE_TITLE | Istri Mbah Wiryo | Mbah Wiryo's Wife |
| MEM_K8_WIRYO_WIFE_IN | Senja di pantai ini juga, Nak, puluhan tahun lalu. Dengarkan perempuan itu. | Dusk on this same shore, child, long years ago. Listen to the woman. |
| MEM_K8_WIRYO_WIFE_1 | Sumi menuntun suaminya, Wiryo, ke garis pasang di senja yang jingga. | Sumi leads her husband Wiryo to the tide line in an orange dusk. |
| MEM_K8_WIRYO_WIFE_2 | Ia mengajarinya: panggil sebuah nama ke dalam air, pelan, dan air memanggil balik. | She teaches him: call a name into the water, softly, and the water calls back. |
| MEM_K8_WIRYO_WIFE_3 | Ia memanggil namanya sendiri, dan ombak menjawab. Lalu ia melangkah ke cahaya senja, tersenyum, dan layar memutih. | She calls her own name, and the surf answers. Then she steps into the dusk light, smiling, and the screen goes white. |
| MEM_K8_WIRYO_WIFE_OUT | Begitulah Wiryo belajar memanggil, Nak. Sekarang kau pun tahu: panggil nama ke dalam air. | That is how Wiryo learned to call, child. Now you know it too: call a name into the water. |

### Beat `wiryo_dusk` (if `!flag:beat_wiryo_dusk`, `flag:mq4_h2`; do `flag:beat_wiryo_dusk`). 4.12, the talk after the memory: Wiryo calls Sumi at dusk
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_WIRYO_DUSK_1 | Senja jingga turun ke pantai, seperti dalam ingatan. Mbah Wiryo berdiri di garis pasang, tangannya terjuntai di sisi tubuh. | An orange dusk settles over the shore, as in the memory. Mbah Wiryo stands at the tide line, hands hanging at his sides. |
| @NPC_WIRYO_NAME | | |
| BEAT_WIRYO_DUSK_2 | Sumi. | Sumi. |
| @ | | |
| BEAT_WIRYO_DUSK_3 | Ombak naik, putih di tepinya, dan membisikkan sesuatu yang bukan suara siapa pun: Sumi. Bunyinya sama, empat puluh tahun tanpa ganti. | A wave climbs, white at its edge, and whispers something that is no one's voice: Sumi. The same sound, forty years unchanged. |
| @NPC_WIRYO_NAME | | |
| BEAT_WIRYO_DUSK_4 | Kau melihatnya, ya? Tadi, dalam ingatan itu. Ia tersenyum. Aku tak pernah melihat bagian itu. | You saw her, didn't you? Just now, in that memory. She smiled. I never got to see that part. |
| @NPC_HERO_NAME | | |
| BEAT_WIRYO_DUSK_H1 | Ia tersenyum, Mbah. Ia mengajarimu, dan ia tersenyum. | She smiled, Mbah. She taught you, and she smiled. |
| @NPC_WIRYO_NAME | | |
| BEAT_WIRYO_DUSK_5 | Terima kasih. Itu cukup untuk empat puluh tahun lagi. Sekarang panggillah namanya sendiri, Nak. Namanya, bukan lagu. | Thank you. That's enough for forty more years. Now call hers, child. Her name, not the song. |
| @ | | |
| BEAT_WIRYO_DUSK_6 | Kau belum siap. Belum. Tapi kau sudah tahu cara berdiri di garis pasang. Sari menunggumu di dermaga, dengan tali dan suar. | You aren't ready. Not yet. But you know how to stand at the tide line. Sari waits on the jetty, with rope and beacons. |

### Chapter 4: The Mangrove and the Sea Cavern (4.13-4.16)

### Beat `beacons_lit` (if `!flag:beat_beacons_lit`, `flag:mq4_5a`; do `flag:beat_beacons_lit`). 4.13, after `puzzle_solved:bakau_beacons`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_BEACONS_LIT_1 | Suar ketiga menyala, dan ketiga cahaya pasang-surut berdenyut serempak, menyusuri air gelap di antara akar-akar bakau. | The third beacon catches, and all three tidal lights pulse together, running down the dark water between the mangrove roots. |
| @NPC_KIDUL_SARI_NAME | | |
| BEAT_BEACONS_LIT_2 | Aku bisa melihat jalan pulang dari sini. Persis seperti waktu kecil. | I can see the way home from here. Exactly like when I was small. |
| @ | | |
| BEAT_BEACONS_LIT_3 | Ia menarik napas panjang, dan tanpa sadar mulai bersenandung. Nada bait kedua, lalu kata-katanya, satu per satu, naik seperti gelembung. | She takes a long breath and, without noticing, begins to hum. The tune of the second verse, then the words, one by one, rising like bubbles. |
| @NPC_KIDUL_SARI_NAME | | |
| BEAT_BEACONS_LIT_4 | "Perahu pulang, jala penuh..." Aku ingat! Nenek, aku ingat! | "Boats come home, nets full..." I remember! Grandmother, I remember! |
| @NPC_HERO_NAME | | |
| BEAT_BEACONS_LIT_H1 | Kau menyanyikannya tanpa salah. | You sang it without a mistake. |
| @NPC_KIDUL_SARI_NAME | | |
| BEAT_BEACONS_LIT_5 | Satu kata salah, tapi nenekku selalu begitu. Ayo, Karang menunggu, dan ia tak sesabar suar. | One wrong word, but my grandmother always did too. Come on, the reef is waiting, and it's less patient than a beacon. |

### Clue `reef_thread` (step 4.14; a thread tied to a rock on the sandbar of `sk_karang`: Laras's trail; journal note only)
| Key | ID | EN |
|-----|----|----|
| CLUE_REEF_THREAD_1 | Seutas benang dari pita Laras, terikat pada batu di gosong pasir. Aku mengenal simpulnya. | A thread from Laras's ribbon, tied to a rock on the sandbar. I know that knot. |
| CLUE_REEF_THREAD_2 | Ia lewat sini, entah kapan. Jejaknya melintasi waktu, bukan hanya tempat. | She came this way, whenever that was. Her trail crosses time, not only place. |
| CLUE_REEF_THREAD_NOTE | Benang pita Laras di batu karang. | A thread of Laras's ribbon on a reef rock. |

### Beat `trial_torch` (if `!flag:beat_trial_torch`, `flag:mq4_5b`; do `flag:beat_trial_torch`). 4.14, Sacred Trial I: the Torch-Lines (`kidul_karang_2`)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_TRIAL_TORCH_1 | Di karang surut, barisan Lampor berjalan seperti prosesi obor yang lupa tujuannya. Satu demi satu kau memadamkannya, tanpa mengejar. | On the low-tide reef the Lampor walk like a torch procession that forgot its destination. One by one you put them out, without chasing. |
| BEAT_TRIAL_TORCH_2 | Yang terakhir padam, dan karang menjadi sunyi seperti halaman kitab yang selesai dibaca. | The last goes out, and the reef falls quiet like a page of a book that's been read. |
| @NPC_HERO_NAME | | |
| BEAT_TRIAL_TORCH_H1 | Itu yang pertama. Aku tak melawan mereka. Aku hanya mengingatkan mereka bahwa waktunya habis. | That's the first. I didn't fight them. I only reminded them their time was up. |
| @ | | |
| BEAT_TRIAL_TORCH_3 | Di batu pipih di ujung karang, sebuah tanda obor terukir menyala hijau samar, lalu padam. Kau tak menunjuknya. | On a flat stone at the reef's end, a torch-mark carved there glows faintly green, then fades. You don't point at it. |
| BEAT_TRIAL_TORCH_4 | Dari timur, ombak membawa suara lonceng perunggu, jauh dan dalam. Gua Karang memanggil. | From the east, the surf carries the sound of a bronze bell, far and deep. The Gua Karang calls. |

### Clue `gua_bell_marks` (step 4.15; green stains and bronze marks on the cave wall of `sk_gua`; ASSUMED id; journal note only)
| Key | ID | EN |
|-----|----|----|
| CLUE_GUA_BELL_MARKS_1 | Di dinding gua, tiga lingkaran perunggu menempel di batu, masing-masing setinggi pinggang orang dewasa, dan basah. | On the cave wall, three bronze rings cling to the stone, each waist-high on a grown person, and wet. |
| CLUE_GUA_BELL_MARKS_2 | Lonceng-lonceng itu pernah tergantung di sini. Sekarang mereka di bawah air, menunggu dipukul. | Bells once hung here. Now they're under the water, waiting to be struck. |
| CLUE_GUA_BELL_MARKS_NOTE | Tiga bekas lonceng perunggu di dinding Gua Karang. | Three bronze-bell marks on the wall of the Gua Karang. |

### Beat `gua_approach` (if `!flag:beat_gua_approach`, `flag:mq4_6a`; do `flag:beat_gua_approach`). 4.15, after `gua_karang_approach`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_GUA_APPROACH_1 | Gua itu bergema seperti mangkuk raksasa. Setiap langkahmu kembali padamu dua kali, sedikit berubah. | The cave echoes like a giant bowl. Every step comes back to you twice, slightly changed. |
| BEAT_GUA_APPROACH_2 | Di ujung lorong, air hitam setinggi dada berdiri seperti dinding, tenang, tak bergerak. Arus palung menjaganya. | At the corridor's end, black water stands chest-high like a wall, calm, motionless. The abyssal current guards it. |
| @NPC_HERO_NAME | | |
| BEAT_GUA_APPROACH_H1 | Aku tak bisa melewatinya. Seharusnya ada cara membukanya dari dalam, bukan dari sini. | I can't pass it. There should be a way to open it from inside, not from here. |
| @ | | |
| BEAT_GUA_APPROACH_3 | Lontar di sabukmu menghangat dan berdenyut ke arah air. Sesuatu di seberang sana sedang menulis. | The lontar at your belt warms and pulses toward the water. Something on the other side is writing. |
| BEAT_GUA_APPROACH_4 | Dari kedalaman, lonceng pertama berbunyi sekali, sangat pelan, lalu berhenti. Seperti seseorang mencoba. | From the depths, the first bell rings once, very softly, then stops. Like someone trying. |

### Clue `lc5_cavern` (step 4.16; the sunken bronze bells; opens chapter `lc5`; the zone doc's id, the old `lc5_lontar` at the cliff shrine is retired)
| Key | ID | EN |
|-----|----|----|
| CLUE_LC5_CAVERN_1 | Lonceng perunggu yang tenggelam, hijau karat, satu bergeming, dua miring. Tali dari lontar masih terikat di salah satunya. | The sunken bronze bells, green with rust, one still, two tilted. A strip of lontar cord is still tied to one. |
| CLUE_LC5_CAVERN_2 | Ikatan itu simpul Laras. Lontarku menarikku ke dalam air. | That knot is Laras's. My lontar pulls me into the water. |
| CLUE_LC5_CAVERN_NOTE | Lonceng perunggu tenggelam di Gua Karang, dengan simpul Laras. | Sunken bronze bells in the Gua Karang, with Laras's knot. |

### Laras chapter LC5 `lc5` (step 4.16; kind chapter; the voice on the water; 5 to 8 minutes)
On completion (`memory_done:lc5`): `flag:mq4_lc`, `flag:laras_key_tidal_gate` (lowers the abyssal water barrier in `sk_gua`).
| Key | ID | EN |
|-----|----|----|
| LC_5_TITLE | Suara di Atas Air | The Voice on the Water |
| @NPC_LARAS_NAME | | |
| LC5_1 | Gelap sekali di sini. Tapi ada yang memanggil namaku dari air, pelan. | It's so dark here. But something is calling my name from the water, softly. |
| LC5_2 | Bukan orang bertopeng. Bukan Kak. Ini lebih tua, dan baik hati. | Not a masked man. Not Kak. This is older, and kind. |
| LC5_3 | Aku berjalan ke arah suaranya. Kalau ini jebakan, jebakannya sopan sekali. | I walk toward the sound. If it's a trap, it's a very polite one. |
| LC5_5 | Ada nyanyian samar di atas air, laki-laki tua, serak. Bait pertama, tiga kali salah. Aku mau membetulkannya dan tak bisa. | A faint song floats over the water, an old man, hoarse. The first verse, wrong three times. I want to correct him and can't. |
| LC5_6 | Tiga lonceng perunggu tergantung di dalam air, satu hijau, satu hitam, satu berkilau. Tali lontar di masing-masing, tapi tak ada yang menariknya. | Three bronze bells hang in the water, one green, one black, one gleaming. A lontar cord on each, but nobody pulling. |
| LC5_7 | Aku memukul yang hijau dulu: bait pertama, pasang. Lalu yang hitam: bait kedua, perahu pulang. Airnya menjawab dengan bunyi seperti napas lega. | I strike the green one first: verse one, the tide. Then the black: verse two, boats coming home. The water answers with a sound like relief. |
| LC5_8 | Yang ketiga yang berkilau, nama dalam air. Kusebut namaku sendiri, dan laut menyahut, dan dinding air di depan gerbang itu runtuh pelan-pelan. | The third, the gleaming one: a name in the water. I say my own, and the sea answers, and the water wall before the gate sinks slowly. |
| LC5_4 | Kak? Ini bukan gua. Ini air. Laut masih menyebut namaku. Laut tak lupa, jadi aku tak takut. Datanglah. | Kak? This isn't a cave. It's water. The sea still says my name. The sea doesn't forget, so I'm not afraid. Come. |

### Chapter 5: The Cliff Shrine and the Offering (4.17-4.19)

### Beat `trial_current` (if `!flag:beat_trial_current`, `flag:mq4_6b`; do `flag:beat_trial_current`). 4.17, Sacred Trial II: the Abyssal Current (`kidul_gua_trial`)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_TRIAL_CURRENT_1 | Gerbang air terbuka karena Laras, dan arus palung menyeretmu dengan lembut, seperti tangan yang menimbang sebuah barang. | The water gate is open because of Laras, and the abyssal current drags you gently, like a hand weighing an object. |
| BEAT_TRIAL_CURRENT_2 | Penjaga palung menerjang dari gelap: yang bertaring, yang bersisik putih, yang bersinar. Kau bertahan tanpa mengejar kemenangan. | The cavern guardians lunge from the dark: the fanged, the white-scaled, the glowing. You hold your ground without chasing victory. |
| @NPC_HERO_NAME | | |
| BEAT_TRIAL_CURRENT_H1 | Nenek Sari benar. Arus ini tak mau dikalahkan. Ia hanya ingin tahu apakah kau akan pergi. | Sari's grandmother was right. This current doesn't want to be beaten. It only wants to know whether you'll leave. |
| @ | | |
| BEAT_TRIAL_CURRENT_3 | Arus mereda. Di dinding gua, tanda kedua terukir menyala hijau samar: gelombang di bawah gelombang. Lalu padam. | The current eases. On the cave wall a second mark glows faintly green: a wave beneath a wave. Then it fades. |
| BEAT_TRIAL_CURRENT_4 | Tali di pinggangmu menarik tiga kali, pelan: Sari, di luar. Jalan ke atas terbuka. | The rope at your waist tugs three times, softly: Sari, outside. The way up is open. |

### Clue `shrine_tale` and memory `k9_queen_south` (step 4.18; K9, walk; the carved tale at the cliff shrine `kidul_3`; one retelling among several, told as belief, no fight, no appearance)
| Key | ID | EN |
|-----|----|----|
| CLUE_SHRINE_TALE_1 | Di dinding kuil tebing terukir sebuah kisah dan sebuah lampu yang tak pernah padam. Ini versi Ki Sumarto. | On the cliff shrine's wall a tale is carved, and a lamp that never goes out. This is Ki Sumarto's version. |
| CLUE_SHRINE_TALE_2 | Di bawahnya, orang pesisir menggores versi mereka sendiri, berbeda di tiap garis. | Beneath it, the coast folk have scratched their own versions, different on every line. |
| CLUE_SHRINE_TALE_NOTE | Ukiran kisah Ratu Selatan di kuil tebing. | The carved tale of the Southern Queen at the cliff shrine. |
| HUNT_K9_TITLE | Ratu di Selatan | The Queen of the South |
| MEM_K9_QUEEN_SOUTH_TITLE | Ratu di Selatan | The Queen of the South |
| MEM_K9_QUEEN_SOUTH_IN | Satu penuturan di antara banyak, Nak. Ki Sumarto menceritakannya begini, dan orang pesisir menceritakannya lain. | One telling among many, child. Ki Sumarto tells it like this, and the coast folk tell it otherwise. |
| MEM_K9_QUEEN_SOUTH_1 | Konon seorang putri disingkirkan dari istananya, berjalan ke laut, dan menjadi ratunya. | They say a princess was cast out of her palace, walked into the sea, and became its queen. |
| MEM_K9_QUEEN_SOUTH_2 | Orang pesisir menghormatinya dan menjauhi warna hijau. Mereka tak takut; mereka tahu tata krama. | The coast folk honour her and keep off green. They aren't afraid; they know manners. |
| MEM_K9_QUEEN_SOUTH_3 | Ada yang bilang ia bukan putri, melainkan laut itu sendiri. Tak ada yang bisa memastikan. | Some say she was never a princess, only the sea itself. Nobody can be sure. |
| MEM_K9_QUEEN_SOUTH_OUT | Percaya atau tidak, Nak, hormatilah. Laut tak butuh pembela, hanya tata krama. | Believe it or not, child, be respectful. The sea needs no defender, only manners. |

VERIFY: Nyi Roro Kidul retellings (a cast-out princess, the sea itself); told as belief, never as fact, never fought.

### Beat `k9_after` (if `!flag:beat_k9_after`, `flag:mq4_h3`; do `flag:beat_k9_after`). 4.18, after the memory, at the cliff shrine
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_K9_AFTER_1 | Angin tebing meniup api lampu di kuil, tapi apinya tak padam. Ia hanya miring, seperti membungkuk. | The cliff wind blows on the shrine lamp, but the flame doesn't die. It only leans, as if bowing. |
| BEAT_K9_AFTER_2 | Di bawah, laut sangat tenang, terlalu tenang, seperti pendengar yang menahan napas. | Below, the sea is very calm, too calm, like a listener holding its breath. |
| @NPC_HERO_NAME | | |
| BEAT_K9_AFTER_H1 | Satu kisah di antara banyak. Tapi malam ini aku merasa ia mendengarkan semuanya. | One tale among many. But tonight I feel she's listening to all of them. |
| @ | | |
| BEAT_K9_AFTER_3 | Di batu persembahan di ujung tebing, bekas-bekas lilin dan bunga layu berderet. Tak seorang pun pernah meminta apa pun yang besar di sini. | On the offering stone at the cliff's end, candle stubs and wilted flowers lie in rows. Nobody ever asked for anything large here. |
| BEAT_K9_AFTER_4 | Kau tahu apa yang akan kau tanyakan. Kau berjalan ke altar dan memanggil satu nama, pelan, ke arah air. | You know what you'll ask. You walk to the altar and call one name, softly, toward the water. |

### cliff_altar (the altar at the cliff shrine `kidul_3`; name NPC_CLIFF_ALTAR_NAME; step 4.19; Choice 5; keys V1+; keep `CHOICE_OFFER_MEMORY` and `CHOICE_OFFER_SONG` as the key names the data already uses)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq4=18`, `!flag:mq4_offering` | |
| 2 | `flag:mq4_offering` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @ | | |
| 1 | DLG_CLIFF_ALTAR_V1 | Angin laut berputar di atas batu persembahan tebing ini. Laut meminta satu persembahan sebelum membuka jalan ke keraton. | The sea wind swirls above this cliffside offering stone. The sea asks one offering before it opens the way to the pavilion. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_CLIFF_ALTAR_H1 | Laras. | Laras. |
| 1 | @ | | |
| 1 | DLG_CLIFF_ALTAR_V2 | Ombak di bawah tebing menarik napas. Nama itu dikembalikan padamu sedikit berubah, seperti suara dari ruang lain. | The waves beneath the cliff draw breath. The name is returned to you slightly changed, like a voice from another room. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_CLIFF_ALTAR_H2 | Ia mendengar. Laut masih menyebutnya. Aku bisa memberi apa saja yang diminta. | She's heard. The sea still says her. I can give whatever's asked. |
| 1 | @ | | |
| 1 | DLG_CLIFF_ALTAR_V3 | Yang diminta tak ditentukan. Laut menerima satu dari dua: sepotong ingatanmu yang paling hangat, atau lagu tiga keluarga yang baru kau kumpulkan. | What's asked isn't fixed. The sea takes one of two: the warmest piece of your own memory, or the song of three families you just gathered. |
| 1 | DLG_CLIFF_ALTAR_V4 | Yang satu hilang darimu selamanya. Yang lain hilang dari desa itu. Tak ada yang gratis di antara dua pilihan ini. | One is lost to you forever. The other is lost to that village. Nothing is free between these two. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_CLIFF_ALTAR_H3 | Beringin itu. Ingatanku tentang pohon beringin, yang kupanjat sebelum aku tahu arti kehilangan. Atau lagunya. | That banyan. My memory of the banyan tree, the one I climbed before I knew what losing meant. Or the song. |
| 2 | DLG_CLIFF_ALTAR_2 | Ombak di bawah tebing menjawab dengan tenang. Jalan menuju keraton laut telah terbuka. | The waves below the cliff answer calmly. The way to the sea court stands open. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_OFFER_MEMORY | Persembahkan ingatan masa kecilmu tentang beringin. | Offer your childhood memory of the banyan. | `flag:choice_offer_memory`, `flag:mq4_offering` |
| CHOICE_OFFER_SONG | Persembahkan lagu tiga keluarga yang telah utuh. | Offer the restored song of the three families. | `flag:choice_offer_song`, `flag:mq4_offering` |

### Beat `offering_memory` (if `!flag:beat_offering`, `flag:choice_offer_memory`; do `flag:beat_offering`). Choice 5, Offer Memory: Ombak costs 3 less Sakti and deals +20% poise damage in Act VI; one banyan detail is hazy in the epilogue
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_OFFERING_MEMORY_1 | Kau memikirkan beringin itu: dahan rendah, kulit kasar, bau getah, suara Laras tertawa di bawah. Kau menyerahkannya ke angin, sepotong demi sepotong. | You think of the banyan: the low branch, the rough bark, the smell of sap, Laras laughing below. You hand it to the wind, piece by piece. |
| BEAT_OFFERING_MEMORY_2 | Ombak di bawah menyerapnya tanpa suara. Tebing bergetar pelan, seperti pintu yang digeser. | The waves below take it in without a sound. The cliff shakes softly, like a door sliding. |
| @NPC_HERO_NAME | | |
| BEAT_OFFERING_MEMORY_H1 | Aku ingat pohonnya. Tapi bukan lagi apa yang kami bicarakan di bawahnya. Satu detail hilang, dan aku tahu ia hilang. | I remember the tree. But not what we talked about under it. One detail is gone, and I know it's gone. |
| @ | | |
| BEAT_OFFERING_MEMORY_3 | Di cakrawala selatan, jalan batu kuno naik dari air, mulus, bergaris lumut, menuju cahaya hijau. | On the southern horizon an ancient stone causeway rises from the water, smooth, mossy, toward the green light. |
| BEAT_OFFERING_MEMORY_4 | Ombak akan terasa lebih ringan di tanganmu. Itu harganya, dan itu hadiahnya. | Ombak will feel lighter in your hand. That is the price, and that is the gift. |

### Beat `offering_song` (if `!flag:beat_offering`, `flag:choice_offer_song`; do `flag:beat_offering`). Choice 5, Offer Song: Berkah Pesisir (one auto-revive shield in Act VI); the coastal villagers sing at the epilogue ruwatan
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_OFFERING_SONG_1 | Kau mengucapkan tiga bait itu ke arah laut, pelan, tanpa menunjuk. Pasang, perahu pulang, nama dalam air. | You say the three verses toward the sea, softly, without pointing. The tide, boats coming home, a name in the water. |
| BEAT_OFFERING_SONG_2 | Ombak di bawah tebing berhenti sejenak, lalu menjawab dengan nada yang sama, utuh, dari ujung ke ujung. | The waves beneath the cliff pause, then answer in the same tune, whole, from end to end. |
| BEAT_OFFERING_SONG_3 | Jauh di pantai, di Kampung Nelayan, seseorang berhenti menambal jala dan mulai bernyanyi lebih keras dari sebelumnya, karena laut sekarang yang menyimpannya. | Far away on the shore, in Kampung Nelayan, someone stops mending a net and begins to sing louder than before, because the sea is holding it now. |
| @NPC_HERO_NAME | | |
| BEAT_OFFERING_SONG_H1 | Lagunya tidak hilang. Hanya dipinjamkan, dan laut akan mengembalikannya kapan pun mereka butuh. | The song isn't lost. Only lent, and the sea will give it back whenever they need it. |
| @ | | |
| BEAT_OFFERING_SONG_4 | Sesuatu hangat menyelimuti bahumu seperti kain basah: berkah pesisir, ringan, tak terlihat. Jalan batu kuno naik dari air menuju cahaya hijau. | Something warm settles over your shoulders like a damp cloth: the coast's blessing, light, unseen. An ancient stone causeway rises from the water toward the green light. |

### Chapter 6: The Trial of the Waves (4.20-4.22)

### Clue `causeway_post` (step 4.20; a mooring post on the sea causeway to `sk_keraton`; ASSUMED id; journal note only)
| Key | ID | EN |
|-----|----|----|
| CLUE_CAUSEWAY_POST_1 | Tiang tambat dari batu hijau di tepi jalan batu. Tali tambatnya telah membusuk seribu tahun lalu, tapi simpulnya masih utuh. | A green stone mooring post beside the causeway. The rope rotted a thousand years ago, but the knot is still whole. |
| CLUE_CAUSEWAY_POST_2 | Seseorang menambatkan sesuatu di sini dengan hormat, lalu pergi dengan hormat. | Someone moored something here with respect, then left with respect. |
| CLUE_CAUSEWAY_POST_NOTE | Tiang tambat batu di jalan menuju Keraton Laut. | A stone mooring post on the road to the Sea Pavilion. |

### semar, at the petilasan `kidul_2` (entry L of the table above; 4.20 `step:mq4=19`, `"quiet": true`; shared NPC, keys V301+)
| Entry | if | do |
|-------|----|----|
| L | `step:mq4=19` (`"quiet": true`) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| L | @NPC_SEMAR_NAME | | |
| L | DLG_SEMAR_V321 | Kau melewati jalan batu itu tanpa menunjuk atau menghitung. Hehe, aku bangga. Sedikit. | You crossed that stone road without pointing or counting. Hehe, I'm proud. A little. |
| L | @NPC_HERO_NAME | | |
| L | DLG_SEMAR_H321 | Dua ujian sudah lewat. Aku masih tak tahu apa yang diharapkan pada yang ketiga. | Two trials are behind me. I still don't know what's expected in the third. |
| L | @NPC_SEMAR_NAME | | |
| L | DLG_SEMAR_V322 | Ombak. Tiga gelombang, dan di antaranya kau diminta membaca apa yang naik dari dangkal. Jangan dilawan, dijawab. | Waves. Three of them, and between them you're asked to read what rises from the shallows. Don't fight them, answer them. |
| L | DLG_SEMAR_V323 | Orang pesisir bilang sang ratu mengamati, tapi tak pernah bicara. Kalau ia bicara, anggap itu hadiah, bukan ancaman. | The coast folk say the queen watches, but never speaks. If she does, take it as a gift, not a threat. |
| L | @NPC_HERO_NAME | | |
| L | DLG_SEMAR_H322 | Dan kalau aku gagal? | And if I fail? |
| L | @NPC_SEMAR_NAME | | |
| L | DLG_SEMAR_V324 | Air tak menghukum yang gagal. Ia hanya mengulang. Istirahatlah, minum, lalu masuk ke pelataran. | Water doesn't punish those who fail. It only repeats. Rest, drink, then go into the court. |

### Clues, the Trial of the Waves (step 4.21; `trial_sign_1` rises after wave 1, `trial_sign_2` after wave 2; journal notes only)
| Key | ID | EN |
|-----|----|----|
| CLUE_TRIAL_SIGN_1_1 | Sebuah batu hijau naik dari dangkal. Terukir di atasnya satu kata, dan airnya mengucapkan kata itu balik padaku. | A green stone rises from the shallows. One word is carved on it, and the water says the word back to me. |
| CLUE_TRIAL_SIGN_1_2 | Kata itu namaku. Atau nama seseorang yang kukenal, aku tak yakin. | The word is my name. Or someone's I know, I'm not sure. |
| CLUE_TRIAL_SIGN_1_NOTE | Batu tanda pertama: air mengucapkan nama kembali. | First sign-stone: the water says names back. |
| CLUE_TRIAL_SIGN_2_1 | Batu kedua naik, lebih tinggi. Di dalamnya sebuah lonceng kecil, retak, belum berbunyi. | A second stone rises, taller. Inside it a small bell, cracked, not yet sounded. |
| CLUE_TRIAL_SIGN_2_2 | Ujian ini bukan soal kekuatan. Ia soal apakah aku masih menyebut diriku dengan namaku. | This trial isn't about strength. It's about whether I still call myself by my own name. |
| CLUE_TRIAL_SIGN_2_NOTE | Batu tanda kedua: lonceng retak di dalam batu. | Second sign-stone: a cracked bell inside the stone. |

### Beat `kidul_trial` (if `!flag:beat_kidul_trial`, `flag:mq4_8`; do `flag:beat_kidul_trial`). 4.21, Sacred Trial III: the Waves. Nyi Roro Kidul speaks once, from afar
| Key | ID | EN |
|-----|----|----|
| BEAT_KIDUL_TRIAL_1 | Ombak ketiga surut, dan air di paviliun berhenti bergerak. Tak ada yang naik dari laut. Hanya hijau, jauh sekali, di seberang batas pasang. | The third wave ebbs, and the water in the pavilion stills. Nothing climbs out of the sea. Only green, very far, beyond the tide line. |
| BEAT_KIDUL_TRIAL_3 | Ketiga ujian telah lewat: obor, arus, ombak. Tiga tanda hijau di dinding paviliun menyala bersamaan, lalu menjadi satu. | All three trials are passed: the torches, the current, the waves. The three green marks on the pavilion wall light together, then become one. |
| @NPC_RATU_KIDUL_NAME | | |
| BEAT_KIDUL_TRIAL_2 | Kau tidak melawanku. Ambil aksara Ombak, sang gelombang, dan kainku. Laut mengingat apa yang diberikan kepadanya. | You did not fight me. Take the letter Ombak, the wave, and my cloth. The sea remembers what is given to it. |
| @ | | |
| BEAT_KIDUL_TRIAL_4 | Suara itu jauh, tenang, tanpa wajah. Kau tak menjawab dan tak menoleh. Beberapa kebaikan harus diterima dalam diam. | The voice is far, calm, without a face. You neither answer nor turn. Some kindnesses must be received in silence. |
| BEAT_KIDUL_TRIAL_5 | Di dalam kepalamu, satu nama muncul, tak diminta: Laras. Laut menyebutnya dengan suara yang tak punya pemilik. | In your head one name rises, unasked: Laras. The sea says it in a voice that has no owner. |
| @ | | |
| BEAT_KIDUL_TRIAL_6 | Hijau itu surut seperti napas dihembuskan. Kau membungkuk. Tak ada yang melihat. | The green recedes like a breath let go. You bow. Nobody sees. |

Told as belief; she is never fought or touched. VERIFY the tradition of her trial as portrayed.

### kidul_altar (4.22; name NPC_KIDUL_ALTAR_NAME)
| Entry | if | do |
|-------|----|----|
| 1 | `step:mq4=21` | `write:ombak:jawa_ka`, `learn:jawa_ka`, `give:kain_hijau` |
| 2 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KIDUL_ALTAR_V1 | Di altar paviliun, sehelai kain hijau terlipat, basah oleh ombak yang tak ada. | On the pavilion altar, a green cloth lies folded, wet from a wave that isn't there. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_KIDUL_ALTAR_H1 | Satu goresan, naik dan turun. Ombak. | One stroke, rising and falling. Ombak. |
| 1 | @ | | |
| 1 | DLG_KIDUL_ALTAR_V3 | Garis itu tak punya awal dan akhir, hanya arah. Tanganmu belajar menulisnya seperti bernapas. | The line has no beginning or end, only direction. Your hand learns to write it like breathing. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_KIDUL_ALTAR_H2 | Huruf yang tak bisa dimakan Gerhana. Aku mengerti kenapa Semar mengirimku ke sini. | The letter the Eclipse can't eat. I see why Semar sent me here. |
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
| @NPC_HERO_NAME | | |
| BEAT_KIDUL_H2 | Laras masih menyebut namaku di air itu. Kuharap ia mendengar aku menjawab. | Laras still says my name in that water. I hope she hears me answer. |
| @NPC_SEMAR_NAME | | |
| BEAT_KIDUL_3 | Ia mendengar. Laut tak membawa suara, tapi ia membawa nama, dan nama lebih tahan lama. | She hears. The sea carries no voices, but it carries names, and names last longer. |
| BEAT_KIDUL_4 | Jangan lupa pamit pada Mbah Wiryo. Orang tua itu pantas mendengar terima kasih, walau ia akan pura-pura tak butuh. | Don't forget to say goodbye to Mbah Wiryo. The old man deserves a thank-you, though he'll pretend he doesn't need one. |

### Camp talk `camp_kidul` (kidul_jurukunci entry 2 above; cond `flag:mq4_8`, `zone:sk_pantai`, `!flag:mq5_1`, `"quiet": true`; do `flag:camp_kidul`). Two variants after Choice 5, listed first
| Entry | if | do |
|-------|----|----|
| S | `flag:mq4_8`, `flag:choice_offer_song` | `flag:camp_kidul` |
| M | `flag:mq4_8`, `flag:choice_offer_memory` | `flag:camp_kidul` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| S | @NPC_WIRYO_NAME | | |
| S | DLG_WIRYO_V316 | Seluruh kampung bernyanyi semalam, dan laut menyanyikan balik nadanya. Sari menangis di dermaga. | The whole village sang last night, and the sea sang the tune back. Sari wept on the jetty. |
| S | DLG_WIRYO_V317 | Aku tak minta lagunya dikembalikan, tapi itu persembahan paling pantas yang pernah kudengar. | I didn't ask for the song back, but it's the most fitting offering I've ever heard. |
| M | @NPC_WIRYO_NAME | | |
| M | DLG_WIRYO_V318 | Kau mempersembahkan sebagian dirimu, bukan lagu. Itu lebih berat, Nak. Aku tahu rasanya. | You gave a piece of yourself, not the song. That's heavier, child. I know how it feels. |
| M | DLG_WIRYO_V319 | Sari menyanyikan lagu itu tiap petang, jadi yang hilang bukan lagunya, melainkan sesuatu yang lebih sepi. | Sari sings the song every dusk, so what's lost isn't the song but something quieter. |
| 2 | DLG_WIRYO_V21 | Sekarang aku akan mengatakan sesuatu yang lain pada laut, bukan namanya. | Now I'll tell the sea something other than her name. |
| 2 | DLG_WIRYO_V22 | Terima kasih. Itu saja. Ia sudah menunggu lama untuk mendengarnya. | Thank you. That's all. It has waited a long time to hear it. |
| 2 | DLG_WIRYO_V23 | Pergilah. Di balik paviliun itu, gua menunggumu. | Go. Past the pavilion, the cave waits for you. |

(Entries S and M come before the plain entry 2; the plain lines V21-V23 are the fallback.)

### Act VI: Gua Kala (MQ5, "Ke Rahang Sang Waktu")
Story v5, 14 steps, 7 areas. `step:mq5=N` is step 5.(N+1). The Hunter does not appear in Act VI, but Aria Kebonan's name is decided at the memorial stone (Choice 6, step 5.2), and if `flag:choice_redeem_aria` his shadow, unmasked, steps in once in Phase 3. The three letters of Laras's name are held in three memories of the prologue day (section 5), eaten in part by Kala. The player replays each and fills the grey gaps by choosing the right detail (3 gaps per memory, 3 options per gap, **ASSUMED**). A wrong pick flashes the gap grey and changes nothing. Memory ids `la`, `ra`, `sa`. Each starts from a lontar-lit letter clue (`letter_la`, `letter_ra`, `letter_sa`). Allies at `gk_pelataran` depend on earlier choices and side quests: Ciung and Hariang always; Ranga (`faceless_deserter`) if `flag:choice_freed`; Dewi Naganingrum (`naganingrum`) if `flag:choice_tell_ciung`; Cepot (`cepot`) if `flag:c4_done`. Ciung's royal vanguard stands on the walls if `flag:choice_judgment`.

**Step map (0-based)**
| Step | `step:mq5=` | Trigger and flag | Where in this section |
|------|-------------|------------------|-----------------------|
| 5.1 | 0 | `zone_entered:gk_pelataran`; `area_cleared:kala_pelataran_siege` sets `mq5_0` | Beat `pelataran`; Ciung and Hariang talks; ally talks |
| 5.2 | 1 | `flag:mq5_choice6` (Choice 6) | `memorial_stone` talk and choices; beats `aria_redeem` / `aria_release` |
| 5.3 | 2 | `area_cleared:kala_mulut`, sets `mq5_1b` | Clue `eclipse_veil` |
| 5.4 | 3 | `memory_done:la`, sets `mq5_la` | Clue `letter_la`, gap memory `la`, beat `la_back` |
| 5.5 | 4 | `area_cleared:kala_pasir_1`, then `kala_pasir_2`, sets `mq5_1c` | Clue `ward_inscription`, beat `wards_down` |
| 5.6 | 5 | `area_cleared:kala_hutan_echoes`, then `puzzle_solved:hutan_name_chimes`, sets `mq5_1cb` | Clue `name_trees` |
| 5.7 | 6 | `area_cleared:kala_lupa`, sets `mq5_1d`; `memory_done:ra`, sets `mq5_ra` | Clue `letter_ra`, gap memory `ra`, beat `ra_back` |
| 5.8 | 7 | `area_cleared:kala_jembatan_echoes`, sets `mq5_1e` | Clue `bridge_echo`, beat `bridge` |
| 5.9 | 8 | `petilasan_activated:kala_1`, sets `mq5_2`; `memory_done:sa`, sets `mq5_sa` | `semar_kala` main talk, clue `letter_sa`, gap memory `sa`, beat `sa_back` |
| 5.10 | 9 | `memory_done:k10_murwakala`, sets `mq5_h2` | Clue `semar_tale`, memory `k10_murwakala` |
| 5.11 | 10 | `memory_done:k7_ruwatan`, sets `mq5_h1` | Clue `semar_kelir`, memory `k7_ruwatan` |
| 5.12 | 11 | `memory_done:lc6`, sets `mq5_lc` and `flag:laras_sabotage_kala_eclipse` | Laras chapter `lc6` |
| 5.13 | 12 | `boss_defeated:batara_kala`, sets `mq5_3` | Beats `kala_wake`, `kala_p2`, `kala_p3`, `kala_p3_redeem`, `kala_p3_release`; Laras segments `lc6_p2`, `lc6_p3` |
| 5.14 | 13 | `name_written:laras`, sets `mq5_4` | Beat `write`, entry `write_card` |

No `laras_key` flag is set in Act VI; the only Laras flag is `laras_sabotage_kala_eclipse`. Phase flags `kala_p2` and `kala_p3` are set by `batara_kala.gd` when the boss crosses each phase threshold (**ASSUMED**; the beats below wait on them).

### Hunt title for the Gua Kala clues
| Key | ID | EN |
|-----|----|----|
| HUNT_KALA_TITLE | Rahang Sang Waktu | The Maw of Time |

### Chapter 1: The Courtyard of Time and the First Letter (5.1-5.4)

### Beat `pelataran` (if `!flag:beat_pelataran`, `step:mq5=0`, `zone:gk_pelataran`; do `flag:beat_pelataran`). Step 5.1, the arrival and the setpiece. The brothers' banners replace the old `mouth` beat
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_PELATARAN_1 | Pelataran Waktu terbentang di depan gua: lantai batu hitam, tiang-tiang leluhur, dan langit Gerhana yang tak bergerak. | The Courtyard of Time spreads before the cave: black stone floor, ancestor pillars, and a stalled Eclipse sky. |
| BEAT_PELATARAN_2 | Dua panji berdiri berdampingan di tengahnya, satu dari tiap tepi Pamali. Di bawahnya dua pasukan menahan gelombang bayangan, bahu ke bahu. | Two banners stand side by side in the middle, one from each bank of the Pamali. Beneath them two armies hold a tide of shadow, shoulder to shoulder. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_PELATARAN_3 | Kau terlambat, Penulis. Syukurlah. Kami baru saja belajar berbaris bersama. | You're late, writer. Good. We only just learned to march together. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_PELATARAN_4 | Barisanku diam, barisannya cerewet. Hampir seimbang. | My ranks are quiet, his are chatty. Nearly balanced. |
| @NPC_HERO_NAME | | |
| BEAT_PELATARAN_H1 | Berapa lama kalian bisa bertahan? | How long can you hold? |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_PELATARAN_5 | Sampai fajar, kalau kau cepat. Gelombang itu memakan nama, bukan tulang. Yang lupa namanya sendiri, jatuh. | Until dawn, if you're quick. That tide eats names, not bones. Whoever forgets their own name goes down. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_PELATARAN_6 | Maka sebut namamu keras-keras. Kami sudah mulai. Ciung bernyanyi sumbang. | So say your name loud. We started an hour ago. Ciung sings off-key. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_PELATARAN_7 | Aku tidak sumbang. Awas gelombang, Penulis! Bersihkan halaman ini, lalu temui kami di batu leluhur. | I'm not off-key. Mind the tide, writer! Clear this yard, then meet us at the ancestors' stone. |

Allies who fight beside you are placed by flags (the NPC spots of `gk_pelataran` carry the conds below), so this one beat serves every save.

### ciung_wanara, Gua Kala entries (placed after his SQ-C1 entries, before the idle entry; every cond adds `zone:gk_pelataran`; the epilogue entries of section 11 come first in the file). Ask-about hub, Ciung
Hub shape (used by every "Ask about" hub in this fragment): the hub entry has `"hub": true`, `"quiet": true`, a line or two, and a `choices` table whose `do` is `topic:<key>`. A topic entry is found by its `"topic": "<key>"` and has `"quiet": true`; when two topic entries share a key, the first whose `if` holds plays (**ASSUMED**). After a topic the choice list opens again, until the player picks the leave choice (empty `do`).

| Entry | if | do |
|-------|----|----|
| K1 | `step:mq5=1`, `!flag:ciung_k1`, `zone:gk_pelataran` (5.1 after the siege, the main talk) | `flag:ciung_k1` |
| KH | `flag:mq5_0`, `zone:gk_pelataran`, `"hub": true`, `"quiet": true` | |
| KT1 | `"topic": "ciung_troops"`, `flag:choice_judgment`, `"quiet": true` | |
| KT2 | `"topic": "ciung_troops"`, `"quiet": true` (mercy; the fallback) | |
| KT3 | `"topic": "ciung_mother"`, `flag:choice_tell_ciung`, `"quiet": true` | |
| KT4 | `"topic": "ciung_mother"`, `"quiet": true` (keep secret; the fallback) | |
| KT5 | `"topic": "ciung_brother"`, `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| K1 | @NPC_CIUNG_WANARA_NAME | | |
| K1 | DLG_CIUNG_WANARA_V401 | Gelombang pertama patah. Yang kedua datang tiap Gerhana berkedip, dan ia sering berkedip. | The first wave broke. The next comes whenever the Eclipse blinks, and it blinks often. |
| K1 | DLG_CIUNG_WANARA_V402 | Lihat batu tinggi di belakang kami, dikelilingi pahatan nama? Itu Batu Leluhur. Galuh dan Mataram sama-sama memahat di sana. | See the tall stone behind us, ringed with carved names? That's the Ancestors' Stone. Galuh and Mataram both carved there. |
| K1 | @NPC_HERO_NAME | | |
| K1 | DLG_CIUNG_WANARA_H401 | Namanya mulai pudar. | The names are fading. |
| K1 | @NPC_CIUNG_WANARA_NAME | | |
| K1 | DLG_CIUNG_WANARA_V403 | Satu demi satu. Kala menjilatnya seperti anak menjilat gula. | One by one. Kala licks them off like a child with sugar. |
| K1 | DLG_CIUNG_WANARA_V404 | Hariang tahu satu nama yang tak pernah terpahat di situ. Bicaralah padanya, lalu putuskan sendiri. | Hariang knows one name that was never carved there. Talk to him, then decide for yourself. |
| K1 | @NPC_HERO_NAME | | |
| K1 | DLG_CIUNG_WANARA_H402 | Putuskan apa? | Decide what? |
| K1 | @NPC_CIUNG_WANARA_NAME | | |
| K1 | DLG_CIUNG_WANARA_V405 | Apakah lelaki yang mencuri wajah ayahku layak punya tempat di batu itu. | Whether the man who stole my father's face deserves a place on that stone. |
| K1 | DLG_CIUNG_WANARA_V406 | Sepuluh kali aku menjawabnya, dan tiap kali jawabannya lain. Karena itu aku tak mau memutuskan untukmu. | I've answered it ten times and the answer changes each time. That's why I won't decide for you. |
| K1 | DLG_CIUNG_WANARA_V407 | Datanglah ke batu itu kalau sudah siap. Kami berdiri di belakang apa pun yang kau pilih. | Come to the stone when you're ready. We stand behind whatever you choose. |
| KH | @NPC_CIUNG_WANARA_NAME | | |
| KH | DLG_CIUNG_WANARA_V408 | Ada lagi yang mau kau tanyakan, Penulis? Aku toh berdiri di sini seharian. | Anything else, writer? I'm standing here all day anyway. |
| KT1 | @NPC_CIUNG_WANARA_NAME | | |
| KT1 | DLG_CIUNG_WANARA_V409 | Barisan berbaju kelabu di tembok barat itu pengawal kerajaanku. Kukirim mereka begitu hakim Galuh selesai. | The grey-coated line on the west wall is my royal vanguard. I sent them once Galuh's judges were done. |
| KT1 | DLG_CIUNG_WANARA_V410 | Hukum yang tegas membuat orang mau berbaris. Tak ada yang berani lari, dan itu tidak sepenuhnya kabar baik. | Firm law makes men march. Nobody dares run, and that isn't entirely good news. |
| KT1 | DLG_CIUNG_WANARA_V411 | Sabuk Galuh yang kau pakai ditempa di landasan yang sama. Pakailah baik-baik. | The Sabuk Galuh you wear came off the same anvils. Wear it well. |
| KT2 | @NPC_CIUNG_WANARA_NAME | | |
| KT2 | DLG_CIUNG_WANARA_V412 | Tak ada pengawal kerajaan di sini. Hanya sukarelawan dari dua tepi, datang karena tawanan kita diberi makan dan lentera. | No royal guard here. Only volunteers from both banks, who came because our prisoners were fed and given a lamp. |
| KT2 | DLG_CIUNG_WANARA_V413 | Aneh, ya? Belas kasih ternyata mengumpulkan lebih banyak tombak daripada hukuman. | Odd, isn't it? Mercy turned out to raise more spears than punishment. |
| KT2 | DLG_CIUNG_WANARA_V414 | Mereka kurang rapi, tapi tak seorang pun lari. | They're untidy, but not one has run. |
| KT3 | @NPC_CIUNG_WANARA_NAME | | |
| KT3 | DLG_CIUNG_WANARA_V415 | Ibuku datang ke tepi ini, kau tahu. Ia berdiri di belakang panji kami dengan lentera dari danau. | My mother came to this edge, you know. She stands behind our banner with a lantern from the lake. |
| KT3 | DLG_CIUNG_WANARA_V416 | Tiga hari aku tak bisa bicara. Dia yang menenangkanku, katanya aku mirip ayahku kalau gugup. | For three days I couldn't speak. She calmed me, said I look like my father when I'm nervous. |
| KT3 | DLG_CIUNG_WANARA_V417 | Terima kasih sudah memberitahuku, Penulis. Rahasia sebesar itu terlalu berat dipikul sendirian. | Thank you for telling me, writer. A secret that size is too heavy to carry alone. |
| KT4 | @NPC_CIUNG_WANARA_NAME | | |
| KT4 | DLG_CIUNG_WANARA_V418 | Soal ibuku, aku tak punya cerita. Hanya mimpi tentang air dan nyanyian dari seberang danau. | About my mother, I have no story. Only dreams of water and a song from across a lake. |
| KT4 | DLG_CIUNG_WANARA_V419 | Aneh, merindukan wajah yang tak pernah kulihat. Kalau semua ini selesai, aku akan mencarinya. | Strange, to miss a face I've never seen. When this is over, I'll go looking. |
| KT4 | @NPC_HERO_NAME | | |
| KT4 | DLG_CIUNG_WANARA_H403 | Kalau semua selesai, aku ada di sana. | When it's over, I'll be there. |
| KT5 | @NPC_CIUNG_WANARA_NAME | | |
| KT5 | DLG_CIUNG_WANARA_V420 | Hariang? Dulu kuincar lehernya. Sekarang dia menutup sisi kiriku. | Hariang? I used to want his neck. Now he covers my left side. |
| KT5 | DLG_CIUNG_WANARA_V421 | Kami tak pernah membahasnya. Ia lewat membawa air, aku lewat membawa roti, dan itu cukup. | We never discuss it. He passes me water, I pass him bread, and that's enough. |
| KT5 | DLG_CIUNG_WANARA_V422 | Saudara itu bukan hadiah, Penulis. Itu pekerjaan tiap hari. | A brother isn't a prize, writer. It's work every day. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_CIUNG_ASK_401 | Tanya soal pasukannya. | Ask about his soldiers. | `topic:ciung_troops` |
| CHOICE_CIUNG_ASK_402 | Tanya soal ibunya. | Ask about his mother. | `topic:ciung_mother` |
| CHOICE_CIUNG_ASK_403 | Tanya soal Hariang. | Ask about Hariang. | `topic:ciung_brother` |
| CHOICE_CIUNG_ASK_404 | Sudah cukup. | That's enough. | (none) |

The choices belong to entry `KH`.

### hariang_banga, Gua Kala entries (replace `DLG_HARIANG_BANGA_V3`; every cond adds `zone:gk_pelataran`; his file runs: epilogue entries (section 11), entry `H1` below, entry `HH`, the topics, entry 2 `quest:mq4=active` (V4), entry 3 `camp_timur` (section 9), entry 4 no cond (V5)). Ask-about hub, Hariang
| Entry | if | do |
|-------|----|----|
| H1 | `step:mq5=1`, `!flag:hariang_k1` (5.1 after the siege, the main talk) | `flag:hariang_k1` |
| HH | `flag:mq5_0`, `"hub": true`, `"quiet": true` | |
| HT1 | `"topic": "hariang_mother"`, `flag:choice_mercy`, `"quiet": true` | |
| HT2 | `"topic": "hariang_mother"`, `"quiet": true` (judgment; the fallback) | |
| HT3 | `"topic": "hariang_brother"`, `"quiet": true` | |
| HT4 | `"topic": "hariang_kala"`, `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| H1 | @NPC_HARIANG_BANGA_NAME | | |
| H1 | DLG_HARIANG_BANGA_V401 | Ciung sudah bercerita soal batu itu. Biar kuceritakan satu nama yang tak ada di sana. | Ciung told you about the stone. Let me tell you about one name that isn't on it. |
| H1 | DLG_HARIANG_BANGA_V402 | Aria Kebonan, yang dulu bernama Prabu Barma Wijaya. Suami ibuku. Ia mencuri wajah seorang raja. | Aria Kebonan, once called Prabu Barma Wijaya. My mother's husband. He stole a king's face. |
| H1 | @NPC_HERO_NAME | | |
| H1 | DLG_HARIANG_BANGA_H401 | Kau marah padanya. | You're angry at him. |
| H1 | @NPC_HARIANG_BANGA_NAME | | |
| H1 | DLG_HARIANG_BANGA_V403 | Setiap hari. Tapi Kala memakan apa pun yang tak dipegang, dan aku tak mau ibuku jadi satu-satunya yang mengingatnya. | Every day. But Kala eats whatever nobody holds, and I won't have my mother be the only one who remembers him. |
| H1 | DLG_HARIANG_BANGA_V404 | Nama yang dipahat adalah nama yang dipegang. Itu bukan ampun. Itu cuma pegangan. | A carved name is a name held. That isn't forgiveness. It's only a grip. |
| H1 | @NPC_HERO_NAME | | |
| H1 | DLG_HARIANG_BANGA_H402 | Dan kalau dibiarkan kosong? | And if it's left blank? |
| H1 | @NPC_HARIANG_BANGA_NAME | | |
| H1 | DLG_HARIANG_BANGA_V405 | Maka ia beristirahat, dan mungkin ia berhak atas itu juga. Aku prajurit, bukan dalang. | Then he rests, and maybe he's owed that too. I'm a soldier, not a dalang. |
| H1 | DLG_HARIANG_BANGA_V406 | Pilih dengan tangan yang tak gemetar. Kami berdiri di belakangmu. | Choose with a steady hand. We stand behind you. |
| HH | @NPC_HARIANG_BANGA_NAME | | |
| HH | DLG_HARIANG_BANGA_V407 | Tanyalah, Penulis. Jagaku baru selesai saat fajar. | Ask, writer. My watch doesn't end until dawn. |
| HT1 | @NPC_HARIANG_BANGA_NAME | | |
| HT1 | DLG_HARIANG_BANGA_V408 | Ibuku kini punya sel dengan jendela dan lentera. Surat terakhirnya hangat, tak ada duri di dalamnya. | My mother has a cell with a window and a lantern now. Her last letter was warm, no thorns in it. |
| HT1 | DLG_HARIANG_BANGA_V409 | Ia menulis soal Aria juga. Katanya ia kasihan padanya. | She wrote about Aria too. She said she pities him. |
| HT1 | DLG_HARIANG_BANGA_V410 | Aku tak tahu harus berbuat apa dengan kasihan semacam itu. Tapi aku mulai belajar. | I don't know what to do with pity like that. But I'm learning. |
| HT2 | @NPC_HARIANG_BANGA_NAME | | |
| HT2 | DLG_HARIANG_BANGA_V411 | Ibuku tetap di bawah penjagaan hukum. Aku menyurati, ia membalas pendek, dan selalu dengan kalimat yang tegak. | My mother stays under the law's guard. I write, she answers short, always in upright sentences. |
| HT2 | DLG_HARIANG_BANGA_V412 | Ciung benar menegakkan hukum. Aku tak membencinya karena itu, dan itu mengejutkanku. | Ciung is right to keep the law. I don't hate him for it, and that surprises me. |
| HT2 | DLG_HARIANG_BANGA_V413 | Ibuku tak mau Aria dikenang baik. Katanya biar sejarah yang memutuskan. | My mother won't have Aria remembered kindly. She says let history decide. |
| HT3 | @NPC_HARIANG_BANGA_NAME | | |
| HT3 | DLG_HARIANG_BANGA_V414 | Di Pamali ia memanggilku kakak. Aku masih belum tahu harus menjawab apa. | At the Pamali he called me brother. I still don't know how to answer. |
| HT3 | DLG_HARIANG_BANGA_V415 | Jadi tadi pagi kujawab dengan roti. Itu usaha terbaikku sejauh ini. | So this morning I answered with bread. My best attempt so far. |
| HT4 | @NPC_HARIANG_BANGA_NAME | | |
| HT4 | DLG_HARIANG_BANGA_V416 | Prajuritku yang paling muda lupa nama kampungnya kemarin. Kami mengulang-ulangnya sampai ia hafal. | My youngest soldier forgot his village's name yesterday. We repeated it until it stuck. |
| HT4 | DLG_HARIANG_BANGA_V417 | Itu yang kami lakukan di sini: saling mengingatkan. Sederhana, dan melelahkan. | That's what we do here: remind each other. Simple, and exhausting. |
| HT4 | DLG_HARIANG_BANGA_V418 | Tuliskan nama adikmu, Penulis. Biar kami yang menahan pintu. | Write your sister's name, writer. We'll hold the door. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_HARIANG_ASK_401 | Tanya soal ibunya. | Ask about his mother. | `topic:hariang_mother` |
| CHOICE_HARIANG_ASK_402 | Tanya soal Ciung. | Ask about Ciung. | `topic:hariang_brother` |
| CHOICE_HARIANG_ASK_403 | Tanya soal para prajurit. | Ask about the soldiers. | `topic:hariang_kala` |
| CHOICE_HARIANG_ASK_404 | Sudah cukup. | That's enough. | (none) |

The choices belong to entry `HH`.

### faceless_deserter, Gua Kala entries (Ranga, only if `flag:choice_freed`; after his SQ-C3 entries, before the idle entry; replaces the old `deserter_mouth` staging lines; he stands at `gk_pelataran`, not the cave mouth). Ask-about hub, Ranga
The old spot `deserter_mouth` in `gk_mulut` is retired; the SQ-C3 write stone `deserter_stone` stands at `gk_pelataran` (zone doc, area 5) and entries 2 and 3 of the stone keep setting `flag:deserter_named`.

| Entry | if | do |
|-------|----|----|
| R1 | `flag:choice_freed`, `!flag:deserter_named`, `zone:gk_pelataran`, `!flag:ranga_k1` | `flag:ranga_k1` |
| R2 | `flag:choice_freed`, `flag:deserter_named`, `zone:gk_pelataran`, `!flag:ranga_k2` | `flag:ranga_k2` |
| RH | `flag:choice_freed`, `zone:gk_pelataran`, `"hub": true`, `"quiet": true` | |
| RT1 | `"topic": "ranga_faceless"`, `"quiet": true` | |
| RT2 | `"topic": "ranga_wife"`, `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| R1 | @NPC_FACELESS_DESERTER_NAME | | |
| R1 | DLG_FACELESS_DESERTER_V401 | Namaku belum utuh. Tapi pintu ini bisa kujaga utuh. | My name isn't whole yet. This door I can guard whole. |
| R1 | @NPC_HERO_NAME | | |
| R1 | DLG_FACELESS_DESERTER_H401 | Kau ikut sampai sini. | You came all this way. |
| R1 | @NPC_FACELESS_DESERTER_NAME | | |
| R1 | DLG_FACELESS_DESERTER_V402 | Kau melepas rantaiku. Aku tak punya cara lain membayarnya selain berdiri di sini. | You took off my chains. I've no other way to repay it than standing here. |
| R1 | DLG_FACELESS_DESERTER_V403 | Bahuku masih ingat tombak. Tanganku tak ingat siapa yang menyerahkannya padaku. | My shoulders still remember the spear. My hands don't remember who handed it to me. |
| R1 | DLG_FACELESS_DESERTER_V404 | Gelombang itu memakan nama. Aku sudah tak punya apa-apa untuk dimakan, jadi aku berdiri di depan. | That tide eats names. I've nothing left to eat, so I stand in front. |
| R1 | @NPC_HERO_NAME | | |
| R1 | DLG_FACELESS_DESERTER_H402 | Kita akan menemukan namamu. | We'll find your name. |
| R1 | @NPC_FACELESS_DESERTER_NAME | | |
| R1 | DLG_FACELESS_DESERTER_V405 | Batu pipih di sudut halaman itu terus menatapku. Tiap kali lewat, rasanya ia sedang menunggu. | That flat stone in the corner of the yard keeps looking at me. Each time I pass, it feels like it's waiting. |
| R1 | DLG_FACELESS_DESERTER_V406 | Bawa dia pulang, Penulis. Adikmu. Aku ingin melihat satu orang pulang dengan utuh. | Bring her home, writer. Your sister. I'd like to see one person come home whole. |
| R2 | @NPC_FACELESS_DESERTER_NAME | | |
| R2 | DLG_FACELESS_DESERTER_V407 | Ranga. Hm. Aku masih mengucapkannya pelan-pelan, seperti makan sesuatu yang panas. | Ranga. Hm. I still say it slowly, like eating something hot. |
| R2 | @NPC_HERO_NAME | | |
| R2 | DLG_FACELESS_DESERTER_H403 | Nama yang bagus. | A good name. |
| R2 | @NPC_FACELESS_DESERTER_NAME | | |
| R2 | DLG_FACELESS_DESERTER_V408 | Istriku pernah bilang, sebelum aku lupa wajahnya: pulanglah sebelum nasimu dingin. Kalimatnya kuingat, wajahnya tidak. | My wife once told me, before I lost her face: come home before your rice goes cold. I remember the sentence, not the face. |
| R2 | DLG_FACELESS_DESERTER_V409 | Itu cukup untuk berdiri. Halaman ini kujaga penuh, dengan namaku sendiri. | That's enough to stand on. I'll hold this yard in full, with my own name. |
| R2 | DLG_FACELESS_DESERTER_V410 | Pergilah. Dan kalau kau melihat istriku, bilang aku sedang pulang. | Go. And if you see my wife, tell her I'm on my way home. |
| R2 | @NPC_HERO_NAME | | |
| R2 | DLG_FACELESS_DESERTER_H404 | Akan kubilang. | I will. |
| R2 | @NPC_FACELESS_DESERTER_NAME | | |
| R2 | DLG_FACELESS_DESERTER_V411 | Terima kasih. Itu lebih dari yang kuharapkan. | Thank you. That's more than I hoped for. |
| RH | @NPC_FACELESS_DESERTER_NAME | | |
| RH | DLG_FACELESS_DESERTER_V412 | Mau tanya apa? Kenanganku sedikit, tapi kuberikan yang ada. | What do you want to ask? My memories are few, but you can have what I've got. |
| RT1 | @NPC_FACELESS_DESERTER_NAME | | |
| RT1 | DLG_FACELESS_DESERTER_V413 | Para Tanpa Rupa itu tidak jahat. Mereka kosong, dan yang kosong menurut. Kukira dulu aku sama. | The Faceless aren't wicked. They're empty, and the empty obey. I think I was the same. |
| RT1 | DLG_FACELESS_DESERTER_V414 | Kalau namamu disebut cukup keras, kadang mereka menoleh. Dua kali kulihat itu. | If you say a name loud enough, they sometimes turn their heads. I've seen it twice. |
| RT1 | DLG_FACELESS_DESERTER_V415 | Jangan benci mereka. Benci juga makanan, dan Kala tak pernah kenyang. | Don't hate them. Hate is food too, and Kala is never full. |
| RT2 | @NPC_FACELESS_DESERTER_NAME | | |
| RT2 | DLG_FACELESS_DESERTER_V416 | Dia menjual garam di pasar tepi sungai. Aku ingat bau garam dan bunyi timbangan, bukan wajahnya. | She sold salt at the riverside market. I remember the smell of salt and the clink of scales, not her face. |
| RT2 | DLG_FACELESS_DESERTER_V417 | Kalau aku mati dalam lupa, setidaknya aku mati mengingat bau garamnya. | If I die forgetting, at least I die remembering the smell of her salt. |
| RT2 | DLG_FACELESS_DESERTER_V418 | Tapi aku berniat tidak mati. Jangan bilang itu rencana yang bagus. | But I don't plan to die. Don't tell me that's a good plan. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_FACELESS_DESERTER_ASK_1 | Tanya soal para Tanpa Rupa. | Ask about the Faceless. | `topic:ranga_faceless` |
| CHOICE_FACELESS_DESERTER_ASK_2 | Tanya soal istrinya. | Ask about his wife. | `topic:ranga_wife` |
| CHOICE_FACELESS_DESERTER_ASK_3 | Sudah cukup. | That's enough. | (none) |

The choices belong to entry `RH`. When `flag:choice_handed`, no Deserter stands at the gate; Lengser keeps him (section 11).

### naganingrum, Gua Kala entries (only if `flag:choice_tell_ciung`; first entries of her Gua Kala set, every cond adds `zone:gk_pelataran`; the epilogue entries of section 11 come first in the file). Ask-about hub, Naganingrum
Her lake-wardens stand with their lanterns behind the banners (Choice 1, Tell). If `flag:choice_keep_secret` she is not here: Ciung does not know she lives, and the two meet in the epilogue.

| Entry | if | do |
|-------|----|----|
| N1 | `flag:choice_tell_ciung`, `zone:gk_pelataran`, `!flag:naga_k1` | `flag:naga_k1` |
| NH | `flag:choice_tell_ciung`, `zone:gk_pelataran`, `"hub": true`, `"quiet": true` | |
| NT1 | `"topic": "naga_child"`, `"quiet": true` | |
| NT2 | `"topic": "naga_king"`, `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| N1 | @NPC_NAGANINGRUM_NAME | | |
| N1 | DLG_NAGANINGRUM_V401 | Aku bukan pejuang, Nak. Tapi para penjaga danau tak mau tinggal di rumah, dan aku tak mau mereka berjalan sendirian. | I'm no fighter, child. But the lake-wardens wouldn't stay home, and I wouldn't let them walk alone. |
| N1 | DLG_NAGANINGRUM_V402 | Lihat lenteranya? Api dari tepi danau. Bayangan takut pada lampu yang dinyalakan tangan yang ingat. | See the lanterns? Fire from the lakeshore. Shadows fear a lamp lit by a hand that remembers. |
| N1 | @NPC_HERO_NAME | | |
| N1 | DLG_NAGANINGRUM_H401 | Ciung berdiri tegak sekali hari ini. | Ciung is standing very straight today. |
| N1 | @NPC_NAGANINGRUM_NAME | | |
| N1 | DLG_NAGANINGRUM_V403 | Karena aku menonton. Anak itu akan jatuh dari tembok sebelum mau tampak lemah di depan ibunya. | Because I'm watching. That boy would fall off a wall before looking weak in front of his mother. |
| N1 | DLG_NAGANINGRUM_V404 | Aku menunggu begitu lama di tepi danau sampai lupa bahwa menunggu pun boleh berakhir. | I waited so long by the lake I forgot that waiting is allowed to end. |
| N1 | DLG_NAGANINGRUM_V405 | Kau yang mengakhirinya. Aku belum berterima kasih dengan layak. | You ended it. I haven't thanked you properly. |
| N1 | DLG_NAGANINGRUM_V406 | Tulislah nama adikmu dengan tangan yang percaya. Lontarmu sudah kuberkati, ingat? | Write your sister's name with a hand that believes. Your lontar is already blessed, remember? |
| N1 | DLG_NAGANINGRUM_V407 | Dan pulanglah. Aku ingin melihat dua keluarga makan di satu meja. | And come home. I want to see two families eating at one table. |
| NH | @NPC_NAGANINGRUM_NAME | | |
| NH | DLG_NAGANINGRUM_V408 | Duduklah sebentar. Lentera ini masih lama menyala. | Sit a moment. These lanterns burn a long while. |
| NT1 | @NPC_NAGANINGRUM_NAME | | |
| NT1 | DLG_NAGANINGRUM_V409 | Aku menggendongnya satu jam. Hanya satu jam, dan beratnya masih kuhafal sampai sekarang. | I held him one hour. Only one hour, and I still know his weight by heart. |
| NT1 | DLG_NAGANINGRUM_V410 | Lalu ia dihanyutkan, dan aku diberi tahu bahwa aku melahirkan seekor anjing kecil. Tak ada ibu yang percaya itu. | Then he was set adrift, and I was told I had borne a puppy. No mother believes that. |
| NT1 | DLG_NAGANINGRUM_V411 | Sekarang ia tinggi dan berisik. Aku tak punya keluhan. | Now he's tall and loud. I've no complaints. |
| NT2 | @NPC_NAGANINGRUM_NAME | | |
| NT2 | DLG_NAGANINGRUM_V412 | Nagawiru, suamiku, tidur tenang di danau sekarang. Dulu aku takut mendekat, sebab ia seekor naga. | Nagawiru, my husband, sleeps calmly in the lake now. I used to be afraid to go near, because he was a naga. |
| NT2 | DLG_NAGANINGRUM_V413 | Kini tiap pagi aku duduk di tepinya, dan ia mendengkur pelan sekali. Aku menyukainya. | Now every morning I sit at his shore, and he snores very softly. I like it. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_NAGANINGRUM_ASK_1 | Tanya soal Ciung waktu bayi. | Ask about Ciung as a baby. | `topic:naga_child` |
| CHOICE_NAGANINGRUM_ASK_2 | Tanya soal Nagawiru. | Ask about Nagawiru. | `topic:naga_king` |
| CHOICE_NAGANINGRUM_ASK_3 | Sudah cukup. | That's enough. | (none) |

The choices belong to entry `NH`.

### cepot, Gua Kala entries (only if `flag:c4_done`, the lamp on the turtle beach; `zone:gk_pelataran`; after his C4 entries; the epilogue entries of section 11 come first). Ask-about hub, Cepot
| Entry | if | do |
|-------|----|----|
| C1 | `flag:c4_done`, `zone:gk_pelataran`, `!flag:cepot_k1` | `flag:cepot_k1` |
| CH | `flag:c4_done`, `zone:gk_pelataran`, `"hub": true`, `"quiet": true` | |
| CT1 | `"topic": "cepot_bapak"`, `"quiet": true` | |
| CT2 | `"topic": "cepot_beach"`, `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| C1 | @NPC_CEPOT_NAME | | |
| C1 | DLG_CEPOT_V401 | Aku bukan takut, ya. Ini cuma kakiku yang menolak maju. Dua-duanya, sendiri-sendiri. | I'm not scared, all right. It's just my legs refusing to go forward. Both of them, separately. |
| C1 | @NPC_HERO_NAME | | |
| C1 | DLG_CEPOT_H401 | Kau jauh dari panggung, Cepot. | You're a long way from the stage, Cepot. |
| C1 | @NPC_CEPOT_NAME | | |
| C1 | DLG_CEPOT_V402 | Panggung ikut ke mana-mana, Penulis. Di pantai kupegang lentera semalaman, ingat? Ombaknya kapok. | The stage goes everywhere, writer. At the beach I held the lamp all night, remember? The waves learned their lesson. |
| C1 | DLG_CEPOT_V403 | Sejak itu aku tak takut air. Aku takut gelap, bayangan, bunyi aneh, dan Bapak kalau marah. | Since then I'm not afraid of water. I'm afraid of the dark, shadows, odd noises, and Bapak when he's cross. |
| C1 | DLG_CEPOT_V404 | Tapi gelombang di sini memakan nama, dan aku suka namaku. Jadi tugasku membawa air dan berteriak. | But this tide eats names and I like mine. So my job is carrying water and shouting. |
| C1 | @NPC_HERO_NAME | | |
| C1 | DLG_CEPOT_H402 | Berteriak apa? | Shouting what? |
| C1 | @NPC_CEPOT_NAME | | |
| C1 | DLG_CEPOT_V405 | Supaya para prajurit tahu mereka masih punya suara. Dan nama. Cepot, Cepot. Lihat, masih ada. | So the soldiers know they've still got voices. And names. Cepot, Cepot. See, still there. |
| C1 | DLG_CEPOT_V406 | Pergilah, tulis namanya. Kalau gagal, akan kubilang pada Bapak itu salahku. | Go write her name. If you fail, I'll tell Bapak it was my fault. |
| CH | @NPC_CEPOT_NAME | | |
| CH | DLG_CEPOT_V407 | Mau tanya apa? Jawabanku banyak, separuhnya benar. | What d'you want to ask? I've lots of answers, half of them true. |
| CT1 | @NPC_CEPOT_NAME | | |
| CT1 | DLG_CEPOT_V408 | Bapak sampai di gua sebelum kita. Kutanya naik apa, ia bilang jangan tanya. Tiap kali. | Bapak got to the cave before us. I asked how, he said don't ask. Every time. |
| CT1 | DLG_CEPOT_V409 | Aku lahir dari lelaki yang tak pernah menjelaskan apa pun. Kurasa karena itu aku cerewet. | I was born to a man who never explains anything. I think that's why I talk so much. |
| CT2 | @NPC_CEPOT_NAME | | |
| CT2 | DLG_CEPOT_V410 | Di pantai itu aku sungguh takut. Dan kau lihat? Tak ada yang menertawakanku. | At that beach I was truly scared. And did you see? Nobody laughed at me. |
| CT2 | DLG_CEPOT_V411 | Kalau takut tapi tetap memegang lentera, itu sudah boleh disebut berani. Dengar, baru saja kukarang. | If you're scared and still hold the lamp, that counts as brave. Listen, I just made that up. |
| CT2 | DLG_CEPOT_V412 | Bagus, kan? Tolong dicatat. | Good, right? Please write it down. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_CEPOT_ASK_1 | Tanya soal Semar. | Ask about Semar. | `topic:cepot_bapak` |
| CHOICE_CEPOT_ASK_2 | Tanya soal pantai. | Ask about the beach. | `topic:cepot_beach` |
| CHOICE_CEPOT_ASK_3 | Sudah cukup. | That's enough. | (none) |

The choices belong to entry `CH`.

### memorial_stone (`gk_pelataran`, step 5.2; name NPC_MEMORIAL_STONE_NAME; new). Choice 6, Aria Kebonan's name
Entry 1 is the talk of step 5.2; its choices end the step. `write:aria_kebonan:jawa_ra,jawa_ka,jawa_na` is a stand-in glyph run for the carve card (**ASSUMED**; the glyph set for the name is a code task). The story reason for each branch: Hariang says a carved name is held, Ciung says some names want rest, and the hero remembers what Aria asked for by the burned stage (to be said once).

| Entry | if | do |
|-------|----|----|
| 1 | `step:mq5=1`, `!flag:mq5_choice6` (5.2) | |
| 2 | `flag:choice_redeem_aria` | |
| 3 | `flag:choice_release_aria` | |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_MEMORIAL_STONE_V401 | Di batu ini tertulis nama-nama Galuh dan Mataram: raja, juru masak, anak-anak. Separuhnya sudah licin. | On this stone are the names of Galuh and Mataram: kings, cooks, children. Half of them are rubbed smooth. |
| 1 | DLG_MEMORIAL_STONE_V402 | Satu ruang di tengahnya masih kosong, selebar sebuah nama. Tak seorang pun pernah memahatnya. | One space in the middle is still blank, the width of a single name. Nobody ever carved it. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_MEMORIAL_STONE_H401 | Itu ruang untuk Aria Kebonan. | That's the space for Aria Kebonan. |
| 1 | @NPC_MEMORIAL_STONE_NAME | | |
| 1 | DLG_MEMORIAL_STONE_V403 | Seorang tukang batu Galuh meninggalkannya, dan seorang tukang batu Mataram membiarkannya. Dua bangsa, satu keraguan. | A Galuh mason left it, and a Mataram mason let it be. Two peoples, one doubt. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_MEMORIAL_STONE_H402 | Ia mencuri wajah seorang raja dan memberikan namanya sendiri pada Kala. | He stole a king's face and gave his own name to Kala. |
| 1 | @NPC_MEMORIAL_STONE_NAME | | |
| 1 | DLG_MEMORIAL_STONE_V404 | Nama yang dipahat ditahan dunia, baik atau buruk. Nama yang tak dipahat dimakan Kala, atau dibiarkan beristirahat. | A carved name is held by the world, good or bad. An uncarved name is eaten by Kala, or left to rest. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_MEMORIAL_STONE_H403 | Di dekat panggung yang terbakar ia hanya minta namanya diucapkan sekali. | By the burned stage he only asked for his name to be said once. |
| 1 | @NPC_MEMORIAL_STONE_NAME | | |
| 1 | DLG_MEMORIAL_STONE_V405 | Itu sudah kau lakukan. Pahat atau jangan: keduanya kau tanggung sendiri. | You did that already. Carve it or don't: either way you carry it. |
| 1 | DLG_MEMORIAL_STONE_V406 | Pahat, dan ia tertambat dengan segala dosanya. Biarkan, dan ia pergi dengan tenang, tanpa apa pun untuk dipegang. | Carve, and he's anchored, sins and all. Leave it, and he goes quiet, with nothing to hold. |
| 1 | DLG_MEMORIAL_STONE_V407 | Ciung dan Hariang menunggu di belakangmu. Batu itu menunggu di depanmu. | Ciung and Hariang wait behind you. The stone waits before you. |
| 2 | DLG_MEMORIAL_STONE_V408 | Aria Kebonan, terpahat di antara raja dan juru masak. Batunya hangat. | Aria Kebonan, carved among kings and cooks. The stone is warm. |
| 3 | DLG_MEMORIAL_STONE_V409 | Ruang di tengah tetap kosong, dan tenang. | The space in the middle stays blank, and quiet. |
| 4 | DLG_MEMORIAL_STONE_V410 | Batu hitam tinggi, penuh nama yang memudar. | A tall black stone, full of fading names. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_ARIA_1 | Pahat nama Aria Kebonan di batu ini. | Carve Aria Kebonan's name on this stone. | `write:aria_kebonan:jawa_ra,jawa_ka,jawa_na`, `flag:choice_redeem_aria`, `flag:mq5_choice6` |
| CHOICE_ARIA_2 | Biarkan ruang itu kosong. Biar namanya beristirahat. | Leave the space blank. Let his name rest. | `flag:choice_release_aria`, `flag:mq5_choice6` |

### Beat `aria_redeem` (if `!flag:beat_aria`, `flag:choice_redeem_aria`, `flag:mq5_choice6`; do `flag:beat_aria`). Choice 6, redeem. The Phase 3 payoff is in `kala_p3_redeem`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_ARIA_REDEEM_1 | Aksara demi aksara muncul di ruang kosong itu. Aria Kebonan. Batu itu menghangat di bawah telapak tanganmu. | Letter by letter the name appears in the blank space. Aria Kebonan. The stone grows warm under your palm. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_ARIA_REDEEM_2 | Ibuku akan menangis kalau tahu. Aku sendiri belum memutuskan perasaanku. | My mother will cry when she hears. I haven't decided how I feel myself. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_ARIA_REDEEM_3 | Aku tak memaafkannya. Batu ini hanya menyimpan, tidak membebaskan. | I don't forgive him. This stone only keeps, it doesn't free. |
| @NPC_HERO_NAME | | |
| BEAT_ARIA_REDEEM_H1 | Cukup begitu. Yang dipegang tak bisa dimakan. | That's enough. What's held can't be eaten. |
| @ | | |
| BEAT_ARIA_REDEEM_4 | Dari mulut gua, sesuatu menoleh. Tirai Gerhana bergetar, seakan Kala merasa satu nama diambil kembali dari mulutnya. | From the cave mouth something turns. The Eclipse veil shivers, as if Kala felt one name taken back from his mouth. |
| BEAT_ARIA_REDEEM_5 | Sekejap, sosok tinggi tanpa topeng berdiri di samping batu, lalu hilang. | For a heartbeat a tall figure with no mask stands beside the stone, then is gone. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_ARIA_REDEEM_6 | Tirai di mulut gua tak mempan oleh huruf biasa. Kau punya Ombak. Pakailah. | The veil at the cave mouth won't take ordinary letters. You have Ombak. Use it. |

### Beat `aria_release` (if `!flag:beat_aria`, `flag:choice_release_aria`, `flag:mq5_choice6`; do `flag:beat_aria`). Choice 6, release. The Keteguhan Sunyi passive is in effect from here; the Phase 3 note is in `kala_p3_release`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_ARIA_RELEASE_1 | Kau menurunkan tanganmu dari batu. Ruang di tengahnya tetap kosong, selebar sebuah nama, dan sunyi. | You lower your hand from the stone. The space in the middle stays blank, the width of a name, and quiet. |
| BEAT_ARIA_RELEASE_2 | Sunyi itu menjalar. Gelombang bayangan di pagar halaman seakan berhenti sebentar untuk mendengarkan. | The quiet spreads. The shadow tide at the courtyard fence seems to pause and listen. |
| @NPC_CIUNG_WANARA_NAME | | |
| BEAT_ARIA_RELEASE_3 | Ia hanya minta sedikit. Kau memberinya itu. | He asked for little. You gave him that. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_ARIA_RELEASE_4 | Aku tak yakin ibuku akan mengerti. Aku mengerti. | I'm not sure my mother will understand. I do. |
| @NPC_HERO_NAME | | |
| BEAT_ARIA_RELEASE_H1 | Ada nama yang ingin beristirahat, bukan dipegang. | Some names want to rest, not be held. |
| @ | | |
| BEAT_ARIA_RELEASE_5 | Napasmu melambat. Tanganmu mantap, dan aksara terasa ringan di ujung jari, seakan sunyi ikut menulis bersamamu. | Your breath slows. Your hand steadies, and the letters feel light at your fingertips, as if the quiet writes with you. |
| @NPC_HARIANG_BANGA_NAME | | |
| BEAT_ARIA_RELEASE_6 | Tirai di mulut gua tak mempan oleh huruf biasa. Kau punya Ombak. Pakailah. | The veil at the cave mouth won't take ordinary letters. You have Ombak. Use it. |

### Clue `eclipse_veil` (step 5.3; at the veil across the cave mouth in `gk_mulut`; hunt `kala`; the player draws *Ombak* to part it)
| Key | ID | EN |
|-----|----|----|
| CLUE_ECLIPSE_VEIL_1 | Tirai Gerhana menggantung di mulut gua, hitam dan basah seperti kain yang belum dijemur. | The Eclipse veil hangs across the cave mouth, black and wet like cloth that hasn't dried. |
| CLUE_ECLIPSE_VEIL_2 | Aksara Sunda dan Jawa menembusnya tanpa bekas. Hanya Ombak yang bisa membelahnya. | Sunda and Jawa letters pass through it without a mark. Only Ombak can part it. |
| CLUE_ECLIPSE_VEIL_NOTE | Tirai Gerhana menutup mulut Gua Kala; Ombak membelahnya. | An Eclipse veil seals the mouth of Gua Kala; Ombak parts it. |

### Clue `letter_la` and gap memory `la` (step 5.4; gap kind; the tag game in the lane; the letter floats on the east road of `gk_mulut`, cond `flag:mq5_1b`)
The third gap changes in v5: Laras's laugh replaces "where you caught her" (same key `GAP_LA_END`, same correct slot `3`). The laugh to match is Laras's "Kena aku! Hehe." in `DLG_LARAS_V4` (section 5).

| Key | ID | EN |
|-----|----|----|
| HUNT_GAP_TITLE | Tiga Huruf Namanya | The Letters of Her Name |
| CLUE_LETTER_LA_1 | Sebuah huruf pudar melayang di jalan timur: La. Tepinya habis dimakan. | A faded letter drifts along the east road: La. Its edges have been eaten away. |
| CLUE_LETTER_LA_2 | Kuulurkan tangan, dan lontarku bergetar seperti anak anjing yang mengenali suara. | I reach out, and my lontar trembles like a pup that knows a voice. |
| CLUE_LETTER_LA_NOTE | Huruf La melayang di jalan timur Gua Kala; ia menyimpan kenangan kejar-kejaran. | The letter La drifts on the east road of Gua Kala; it holds the tag-game memory. |
| MEM_GAP_LA_TITLE | Kejar-kejaran | The Tag Game |
| MEM_GAP_LA_IN | Hari itu, Nak, dalam ingatanmu sendiri. Kabut sudah memakan sebagiannya. Isi yang hilang dengan yang kau ingat. | That day, child, in your own memory. The fog has eaten some of it. Fill what's missing with what you remember. |
| MEM_GAP_LA_1 | Kau berlari di lorong, Laras selangkah di depan, tertawa. | You run down the lane, Laras a step ahead, laughing. |
| MEM_GAP_LA_2 | Di bawah beringin tua, daun-daunnya bergetar padahal tak ada angin. | Under the old banyan the leaves shiver though there's no wind. |
| GAP_LA_CAT_P | Siapa nama kucing yang dipanggil Laras? | What did Laras call the cat? |
| GAP_LA_CAT_1 | Jahe | Jahe |
| GAP_LA_CAT_2 | Kunyit | Kunyit |
| GAP_LA_CAT_3 | Pandan | Pandan |
| GAP_LA_TREE_P | Siapa nama beringin tua yang disapa Laras? | What was the old banyan's name, the one Laras greeted? |
| GAP_LA_TREE_1 | Ki Waringin | Ki Waringin |
| GAP_LA_TREE_2 | Ki Jati | Ki Jati |
| GAP_LA_TREE_3 | Nyai Beringin | Nyai Beringin |
| GAP_LA_END_P | Bagaimana bunyi tawa Laras saat kau menangkapnya? | How did Laras laugh when you caught her? |
| GAP_LA_END_1 | Hahaha, keras dan panjang | Hahaha, loud and long |
| GAP_LA_END_2 | Hihi, tertahan di balik tangan | Hihi, held in behind her hand |
| GAP_LA_END_3 | Hehe, pendek dan nakal | Hehe, short and cheeky |
| MEM_GAP_LA_OUT | Satu huruf kembali: La, yang pertama dari namanya. | One letter back: La, the first of her name. |

Correct answers (a gap's `correct` key): `GAP_LA_CAT_2` (Kunyit), `GAP_LA_TREE_1` (Ki Waringin), `GAP_LA_END_3` (Hehe). Gap ids `la_cat`, `la_tree`, `la_end`.

### Beat `la_back` (if `!flag:beat_la_back`, `flag:mq5_la`; do `flag:beat_la_back`). Step 5.4, the beat after the first letter
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_LA_BACK_1 | Huruf La meluncur dari ingatan itu ke lontarmu dan menetap di sana, jernih, tanpa tepi yang termakan. | The letter La slides from the memory onto your lontar and settles there, clear, with no eaten edges. |
| BEAT_LA_BACK_2 | Dari dalam gua, jauh sekali, terdengar tawa yang pendek dan nakal. Mungkin hanya gema. | From deep in the cave, far away, comes a short, cheeky laugh. Maybe only an echo. |
| @NPC_HERO_NAME | | |
| BEAT_LA_BACK_H1 | Satu. Tinggal dua. | One. Two to go. |
| @ | | |
| BEAT_LA_BACK_3 | Di timur, jalan menurun ke hamparan pasir yang berkilau seperti kaca pecah. | To the east a road falls away into sand that glitters like broken glass. |

### Chapter 2: The Hourglass Sands and the Forgotten Woods (5.5-5.7)

### Clue `ward_inscription` (step 5.5; at the foot of a sand tower in `gk_pasir`; hunt `kala`; journal note only)
| Key | ID | EN |
|-----|----|----|
| CLUE_WARD_INSCRIPTION_1 | Sebuah prasasti di kaki menara pasir: waktu yang dikurung tak lagi mengalir, ia hanya menunggu dimakan. | An inscription at the foot of a sand tower: time that's caged no longer flows, it only waits to be eaten. |
| CLUE_WARD_INSCRIPTION_2 | Dua penangkal, barat dan timur. Putar batu-batunya sampai pasir mengalir naik. | Two wards, west and east. Turn the stones until the sand runs upward. |
| CLUE_WARD_INSCRIPTION_NOTE | Prasasti di Pasir Jam Pasir: dua penangkal waktu menjaga lapar Kala; putar batu sampai pasir naik. | An inscription on the Hourglass Sands: two time-wards guard Kala's hunger; turn the stones until the sand runs up. |

### Beat `wards_down` (if `!flag:beat_wards_down`, `flag:mq5_1c`, `zone:gk_pasir`; do `flag:beat_wards_down`). Step 5.5; the beat spot at the high gallery. Semar's voice, not his body
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_WARDS_DOWN_1 | Penangkal timur pecah seperti kaca tipis. Sesaat semua pasir di aula berhenti jatuh dan melayang seperti debu di sinar pagi. | The eastern ward cracks like thin glass. For a moment all the sand in the hall stops falling and hangs like dust in morning light. |
| BEAT_WARDS_DOWN_2 | Lalu pasir itu jatuh sekaligus, dan di baliknya terlihat tangga batu yang menurun ke gelap berbau tanah basah. | Then the sand drops all at once, and behind it a stone stair leads down into a dark that smells of wet earth. |
| BEAT_WARDS_DOWN_3 | Dari bawah, angin membawa suara tipis, seperti benang yang ditarik pelan. | From below, the wind carries a thin voice, like a thread drawn gently. |
| @NPC_SEMAR_NAME | | |
| BEAT_WARDS_DOWN_4 | Hehe, kau lambat. Airnya sudah kujerang, Nak. Turunlah, tapi jangan percaya apa pun yang menyebut namamu. | Hehe, you're slow. I've already put the water on, child. Come down, but trust nothing that says your name. |
| @NPC_HERO_NAME | | |
| BEAT_WARDS_DOWN_H1 | Semar? Kau di mana? | Semar? Where are you? |
| @NPC_SEMAR_NAME | | |
| BEAT_WARDS_DOWN_5 | Di tempat yang kutuju. Hutan di bawah sana menelan nama. Jangan jawab bisikan, dengarkan saja. | Where I was headed. The wood below swallows names. Don't answer the whispers, only listen. |
| @NPC_HERO_NAME | | |
| BEAT_WARDS_DOWN_H2 | Bagaimana aku tahu mana yang bisikan? | How will I know which are whispers? |
| @NPC_SEMAR_NAME | | |
| BEAT_WARDS_DOWN_6 | Yang menyebut namamu tapi tak mengenalmu. Pergilah, jam pasir ini tak menunggu. | The ones that say your name but don't know you. Go, this hourglass won't wait. |

### Clue `name_trees` (step 5.6; the whispering stone trees of `gk_hutan`; hunt `kala`; the puzzle `hutan_name_chimes` follows from it)
| Key | ID | EN |
|-----|----|----|
| CLUE_NAME_TREES_1 | Pohon-pohon batu di hutan ini berbisik: nama-nama yang bukan milikku, dari mulut yang sudah tak ada. | The stone trees of this wood whisper names that aren't mine, from mouths that no longer exist. |
| CLUE_NAME_TREES_2 | Beberapa bisikan terdengar seperti nama anak-anak yang dibacakan di ruwatan malam itu. | Some of the whispers sound like the children's names read at the ruwatan that night. |
| CLUE_NAME_TREES_NOTE | Hutan Lupa menelan nama; lonceng batu bergetar pada tiap nama yang dibisikkan pepohonan. | Hutan Lupa swallows names; stone chimes tremble at every name the trees whisper. |

### Clue `letter_ra` and gap memory `ra` (step 5.7; Ibu's table, two cups; the letter drifts between the stone shelves of `gk_lupa`, cond `flag:mq5_1d`). Text kept from v4
| Key | ID | EN |
|-----|----|----|
| CLUE_LETTER_RA_1 | Huruf kedua melayang di antara rak batu, terpisah dari yang lain: Ra. | A second letter drifts between the stone shelves, apart from the others: Ra. |
| CLUE_LETTER_RA_2 | Dari dekat, ia berbau teh melati. | Up close, it smells of jasmine tea. |
| CLUE_LETTER_RA_NOTE | Huruf Ra melayang di Jurang Lupa; ia menyimpan kenangan dua cangkir teh. | The letter Ra drifts in the Abyss of Forgetting; it holds the memory of two cups of tea. |
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

### Beat `ra_back` (if `!flag:beat_ra_back`, `flag:mq5_ra`; do `flag:beat_ra_back`). Step 5.7, the beat after the second letter
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_RA_BACK_1 | Huruf Ra menetap di lontarmu, hangat seperti cangkir yang baru diseduh. | The letter Ra settles on your lontar, warm as a freshly poured cup. |
| BEAT_RA_BACK_2 | Di sebelah timur jurang, sebuah jembatan batu hitam melintang di atas kehampaan. Di ujung selatan, api kecil petilasan berkelip. | East of the abyss a black stone bridge crosses the void. To the south a small petilasan flame flickers. |
| @NPC_HERO_NAME | | |
| BEAT_RA_BACK_H1 | Dua. Tinggal Sa, dan jembatan itu dulu. | Two. Only Sa left, and that bridge first. |

### Chapter 3: The Shadow Bridge and Murwakala (5.8-5.11)

### Clue `bridge_echo` (step 5.8; the row of name-stones at the end of Jembatan Bayang in `gk_jembatan`; hunt `kala`)
| Key | ID | EN |
|-----|----|----|
| CLUE_BRIDGE_ECHO_1 | Di ujung jembatan berdiri deretan batu nama. Tiap batu bergetar, seakan ada yang ingin keluar. | At the bridge's end stand rows of name-stones. Each trembles as if something inside wants out. |
| CLUE_BRIDGE_ECHO_2 | Ukirannya kukenal: perahu, wajah bermahkota, tiang batu, raksasa, keris. Semua yang pernah kuhadapi. | I know the carvings: a boat, a crowned face, a stone pillar, a giant, a keris. Everything I've faced. |
| CLUE_BRIDGE_ECHO_NOTE | Jembatan Bayang membangkitkan gema legenda yang pernah kuhadapi; tiap gema goyah di titik lemahnya yang lama. | The Shadow Bridge raises echoes of the legends I faced; each stumbles where it stumbled before. |

### Beat `bridge` (if `!flag:beat_bridge`, `step:mq5=7`, `zone:gk_jembatan`; do `flag:beat_bridge`). Step 5.8, the setpiece. The echoes are shadows of the old bosses; they don't speak, and the Hunter and the living kings are not among them
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_BRIDGE_1 | Jembatan Bayang melintang di atas kehampaan, selebar tiga langkah. Di bawahnya tak ada dasar, hanya jam-jam yang berdetak. | The Shadow Bridge spans the void, three paces wide. Beneath it there's no floor, only ticking clocks. |
| BEAT_BRIDGE_2 | Satu per satu bayangan naik dari batu: sebuah perahu bertulang rusuk, wajah bermahkota yang retak, tiang-tiang yang berdiri sendiri. | One by one shadows rise from the stone: a boat of ribs, a cracked crowned face, pillars that stand by themselves. |
| BEAT_BRIDGE_3 | Di belakangnya raksasa hijau membungkuk, dan sebilah keris bergetar dalam genggaman tanpa lengan. | Behind them a green giant stoops, and a keris trembles in a grip with no arm. |
| @NPC_HERO_NAME | | |
| BEAT_BRIDGE_H1 | Gema. Bukan mereka sendiri. | Echoes. Not the real ones. |
| @ | | |
| BEAT_BRIDGE_4 | Gema itu tak bicara. Mereka hanya meniru apa yang dulu mereka lakukan, sedikit lebih lambat, seperti kenangan yang kehabisan tenaga. | The echoes don't speak. They only copy what they did before, a little slower, like memories running out of strength. |
| @NPC_HERO_NAME | | |
| BEAT_BRIDGE_H2 | Kalau kuhadapi seperti dulu, mereka jatuh seperti dulu. | If I face them as I did, they'll fall as they did. |
| @ | | |
| BEAT_BRIDGE_5 | Dari balik pagar jembatan, bisikan Kala menyentuh pundakmu: bukan kata, hanya lapar. | From beyond the bridge rail Kala's whisper touches your shoulder: not words, only hunger. |
| BEAT_BRIDGE_6 | Para gema melangkah maju. Waktu menahan napas. | The echoes step forward. Time holds its breath. |

### semar_kala (at `kala_1` in `gk_lupa`; replace every old entry; step 5.9 is the first entry; hubs on entries 2, 4 and 6). Ask-about hub, Semar
| Entry | if | do |
|-------|----|----|
| 1 | `!flag:mq5_sa`, `!flag:semar_k1` (5.9, after the petilasan rest; the main talk) | `flag:semar_k1` |
| 2 | `flag:mq5_sa`, `!flag:mq5_lc`, `"hub": true`, `"quiet": true` (K10, K7 and LC6 stand next to the fire) | |
| 3 | `flag:mq5_lc`, `!flag:mq5_3`, `!flag:semar_k2` (before the finale) | `flag:semar_k2` |
| 4 | `flag:mq5_lc`, `!flag:mq5_3`, `"hub": true`, `"quiet": true` | |
| 5 | `flag:mq5_3` | |
| 6 | (none), `"hub": true`, `"quiet": true` (after the first talk, before Sa) | |
| ST1 | `"topic": "semar_kala"`, `"quiet": true` | |
| ST2 | `"topic": "semar_aria"`, `flag:choice_redeem_aria`, `"quiet": true` | |
| ST3 | `"topic": "semar_aria"`, `"quiet": true` (release; the fallback) | |
| ST4 | `"topic": "semar_laras"`, `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_KALA_V1 | Sudah kubilang aku sampai duluan, hehe. Jangan tanya bagaimana. | Told you I'd get here first, hehe. Don't ask how. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SEMAR_KALA_H1 | Dua suku kata sudah kembali. Tinggal Sa, dan dia. | Two syllables back. Only Sa left, and him. |
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_KALA_V2 | Kala tidak jahat, Nak. Dia lapar. Dia memakan yang tak lagi digenggam siapa pun. Maka genggam erat. | Kala isn't wicked, child. He's hungry. He eats what nobody holds on to. So hold on. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SEMAR_KALA_H2 | Bagaimana kalau aku yang lupa? | And if I'm the one who forgets? |
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_KALA_V3 | Kau menulis. Itu bedanya manusia dengan kabut. Tenangkan dia dengan ruwatan fajar: aksara Sunda, lalu Jawa, dan Ombak untuk gerhananya. | You write. That's what separates a person from fog. Calm him with the dawn ruwatan: Sunda letters, then Jawa, and Ombak for the eclipse. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SEMAR_KALA_H401 | Di gerbang, dua raja itu berdiri satu barisan. Kau yang mengaturnya? | At the gate, the two kings stand in one line. Did you arrange that? |
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_KALA_V401 | Aku? Tidak. Dua anak itu belajar berdiri berdampingan sendiri. Kau sedikit membantu, hehe. | Me? No. Those two boys learned to stand side by side on their own. You helped a little, hehe. |
| 1 | DLG_SEMAR_KALA_V402 | Huruf Sa melayang dekat apiku. Rebut dengan ingatan, bukan dengan kepalan. | The letter Sa drifts near my fire. Win it back with memory, not with fists. |
| 1 | @NPC_HERO_NAME | | |
| 1 | DLG_SEMAR_KALA_H402 | Dan setelah itu? | And after that? |
| 1 | @NPC_SEMAR_NAME | | |
| 1 | DLG_SEMAR_KALA_V403 | Setelah itu sebuah kisah, Nak. Kisah lahirnya Kala, yang membuat dalang berani. Duduklah dekat apiku. | After that, a tale, child. The tale of Kala's birth, the one that makes a dalang brave. Sit near my fire. |
| 2 | @NPC_SEMAR_NAME | | |
| 2 | DLG_SEMAR_KALA_V404 | La, Ra, Sa sudah di lontarmu. Dengarkan kisahku, lalu pegang wayang di kelir itu. Setelah itu lontar kecil adikmu menunggu. | La, Ra, Sa are on your lontar. Hear my tale, then take the puppet at that kelir. After that your sister's little lontar waits. |
| 3 | @NPC_SEMAR_NAME | | |
| 3 | DLG_SEMAR_KALA_V405 | Lontar adikmu sudah kau baca, dan ruwatannya sudah kau latih. Kau siap, hehe, walau tak merasa. | You've read your sister's lontar and practised the ruwatan. You're ready, hehe, though you don't feel it. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_SEMAR_KALA_H403 | Laras ada di dalam bayangannya. | Laras is inside his shadow. |
| 3 | @NPC_SEMAR_NAME | | |
| 3 | DLG_SEMAR_KALA_V406 | Ya, dan itu bukan nasib buruk, Nak. Bayangan adalah tempat Kala menyimpan yang ia makan. Orang di dalamnya bisa menyentuh simpanan itu. | Yes, and that isn't bad luck, child. A shadow is where Kala keeps what he eats. Someone inside can touch the store. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_SEMAR_KALA_H404 | Dia tak ingat aku. | She doesn't remember me. |
| 3 | @NPC_SEMAR_NAME | | |
| 3 | DLG_SEMAR_KALA_V407 | Ingatan bisa hilang. Tangan yang menulis Ka tidak. Percayalah pada tangan itu. | Memory can be lost. A hand that writes Ka can't. Trust the hand. |
| 3 | DLG_SEMAR_KALA_V408 | Kau di luar, ia di dalam. Ruwatan fajar bekerja dari dua sisi, seperti kelir: dalang di belakang, penonton di depan. | You're outside, she's inside. The dawn ruwatan works from both sides, like a kelir: dalang behind, audience in front. |
| 3 | @NPC_HERO_NAME | | |
| 3 | DLG_SEMAR_KALA_H405 | Dan kalau aku lupa urutannya? | And if I forget the order? |
| 3 | @NPC_SEMAR_NAME | | |
| 3 | DLG_SEMAR_KALA_V409 | Sunda, Jawa, Ombak. Ucapkan seperti menyebut nama anak-anak. Dan jangan lupa bernapas. | Sunda, Jawa, Ombak. Say them like children's names. And don't forget to breathe. |
| 3 | DLG_SEMAR_KALA_V410 | Pergilah. Fajar tak datang sendiri. | Go. Dawn doesn't come by itself. |
| 4 | @NPC_SEMAR_NAME | | |
| 4 | DLG_SEMAR_KALA_V411 | Masih ada waktu untuk satu pertanyaan, hehe. Fajar bisa menunggu sebentar. | There's still time for a question, hehe. Dawn can wait a little. |
| 5 | @NPC_SEMAR_NAME | | |
| 5 | DLG_SEMAR_KALA_V4 | Nah? Tuliskanlah, Nak. | Well? Write it, child. |
| 6 | @NPC_SEMAR_NAME | | |
| 6 | DLG_SEMAR_KALA_V412 | Huruf Sa ada dekat apiku. Rebutlah dulu, lalu kita bicara lagi, hehe. | The letter Sa is near my fire. Win it back first, then we'll talk again, hehe. |
| ST1 | @NPC_SEMAR_NAME | | |
| ST1 | DLG_SEMAR_KALA_V413 | Kala itu tua, Nak. Lebih tua dari kerajaan mana pun. Ia lahir lapar, dan dunia tak pernah menyediakan cukup makanan untuknya. | Kala is old, child. Older than any kingdom. He was born hungry, and the world never set out enough food for him. |
| ST1 | DLG_SEMAR_KALA_V414 | Kami para dalang mengajarinya memakan kisah, bukan orang. Itu pekerjaan juga, dan tak pernah selesai. | We dalang teach him to eat tales, not people. That's work too, and it's never finished. |
| ST1 | DLG_SEMAR_KALA_V415 | Karena itu ia dibalikkan, bukan dibunuh. Yang lapar tak bisa dibunuh, hanya dikenyangkan. | That's why he's turned back, not killed. The hungry can't be killed, only fed. |
| ST2 | @NPC_SEMAR_NAME | | |
| ST2 | DLG_SEMAR_KALA_V416 | Kau memahat namanya. Hehe, itu berat, Nak. Memegang nama orang yang berbuat jahat itu seperti memegang bara. | You carved his name. Hehe, that's heavy, child. Holding a wrongdoer's name is like holding a coal. |
| ST2 | DLG_SEMAR_KALA_V417 | Tapi bara yang dipegang tak membakar rumah. Bara yang dilepas bisa. | But a coal that's held doesn't burn the house. A coal let go can. |
| ST2 | DLG_SEMAR_KALA_V418 | Kalau suatu saat ia datang menolong, jangan kaget. Yang dipegang kadang ingin menebus. | If he comes to help one day, don't be surprised. Those who are held sometimes want to make amends. |
| ST3 | @NPC_SEMAR_NAME | | |
| ST3 | DLG_SEMAR_KALA_V419 | Kau membiarkan batu itu kosong. Itu juga memahat, Nak, hanya dengan sunyi. | You left the stone blank. That carves too, child, only with silence. |
| ST3 | DLG_SEMAR_KALA_V420 | Ada nama yang butuh tangan, ada yang butuh pergi. Kau mendengar yang kedua. | Some names need a hand, some need to go. You heard the second kind. |
| ST3 | DLG_SEMAR_KALA_V421 | Sunyi itu akan menolongmu di dalam sana. Bawalah dengan ringan. | That quiet will help you in there. Carry it lightly. |
| ST4 | @NPC_SEMAR_NAME | | |
| ST4 | DLG_SEMAR_KALA_V422 | Adikmu keras kepala. Tahu dari mana? Dari tulisannya: satu Ka itu ia tarik sampai ke dasar gelap. | Your sister is stubborn. How do I know? From her writing: she dragged that one Ka down to the bottom of the dark. |
| ST4 | DLG_SEMAR_KALA_V423 | Hehe, kakak-adik sama saja: tak mau berhenti sebelum selesai. | Hehe, siblings are all alike: neither stops before it's done. |
| ST4 | DLG_SEMAR_KALA_V424 | Kala tak bisa menelan huruf yang masih ditulis. Karena itu ia belum menelannya. | Kala can't swallow a letter that's still being written. That's why he hasn't swallowed her. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_SEMAR_KALA_ASK_1 | Tanya soal Kala. | Ask about Kala. | `topic:semar_kala` |
| CHOICE_SEMAR_KALA_ASK_2 | Tanya soal Aria Kebonan. | Ask about Aria Kebonan. | `topic:semar_aria` |
| CHOICE_SEMAR_KALA_ASK_3 | Tanya soal Laras. | Ask about Laras. | `topic:semar_laras` |
| CHOICE_SEMAR_KALA_ASK_4 | Sudah cukup. | That's enough. | (none) |

The choices belong to entries 2, 4 and 6.

### Clue `letter_sa` and gap memory `sa` (step 5.9; the sanggar and the lontar; the letter drifts by Semar's fire at `kala_1`, cond `flag:mq5_2`). Text kept from v4
| Key | ID | EN |
|-----|----|----|
| CLUE_LETTER_SA_1 | Huruf ketiga melayang dekat api Semar, ragu seperti burung yang belum percaya pada tangan: Sa. | The third letter drifts near Semar's fire, hesitant as a bird that doesn't yet trust a hand: Sa. |
| CLUE_LETTER_SA_2 | Di sampingnya tercium bau tinta dan arang. | Beside it hangs a smell of ink and charcoal. |
| CLUE_LETTER_SA_NOTE | Huruf Sa melayang dekat api petilasan terakhir; ia menyimpan kenangan menulis nama di sanggar. | The letter Sa drifts by the last petilasan's fire; it holds the memory of writing names in the sanggar. |
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

### Beat `sa_back` (if `!flag:beat_sa_back`, `flag:mq5_sa`; do `flag:beat_sa_back`). Step 5.9, the beat after the third letter
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_SA_BACK_1 | Huruf Sa menetap di lontarmu. Kini tiga huruf berjejer di sana, pudar di tepinya, tapi lengkap. | Sa settles on your lontar. Three letters now sit in a row, faded at the edges but whole. |
| @NPC_SEMAR_NAME | | |
| BEAT_SA_BACK_2 | La, Ra, Sa. Laras. Lihat betapa pendek namanya, Nak? Sependek itu, dan hampir hilang. | La, Ra, Sa. Laras. See how short her name is, child? That short, and nearly lost. |
| @NPC_HERO_NAME | | |
| BEAT_SA_BACK_H1 | Tapi belum bisa kutulis. Kenapa? | But I can't write it yet. Why? |
| @NPC_SEMAR_NAME | | |
| BEAT_SA_BACK_3 | Karena Kala berdiri di antara kau dan lembarnya. Dengar dulu kisahnya, dan latih tanganmu. Lalu kita bicara soal adikmu. | Because Kala stands between you and the page. Hear his tale first, and train your hand. Then we'll talk about your sister. |
| @ | | |
| BEAT_SA_BACK_4 | Api petilasan berderak pelan. Di dekat batu, Semar membuka selembar lontar kosong. | The petilasan fire crackles softly. Beside the stone Semar unrolls a blank lontar. |

### Clue `semar_tale` and memory `k10_murwakala` (step 5.10; K10, kind walk; Semar's tale at `kala_1`). Text kept from v4
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

### Clue `semar_kelir` and memory `k7_ruwatan` (step 5.11; K7, kind play, `allow_cast`; the prologue show again, but you are the dalang; v5 adds *Ombak* as the third script). Changed lines are marked
| Key | ID | EN |
|-----|----|----|
| HUNT_K7_TITLE | Ruwatan Fajar | The Dawn Ruwatan |
| CLUE_SEMAR_KELIR_1 | Kelir Semar berdiri di petilasan terakhir, sama seperti malam itu di Desa Purwa. Tapi kali ini lampunya menungguku. | Semar's kelir stands at the last petilasan, like that night in Desa Purwa. But this time the lamp waits for me. |
| CLUE_SEMAR_KELIR_2 | Semar menyerahkan wayang pertama kepadaku. "Kau dalangnya sekarang." | Semar hands me the first puppet. "You're the dalang now." |
| CLUE_SEMAR_KELIR_NOTE | Kelir Semar di petilasan terakhir; aku jadi dalang. | Semar's kelir at the last petilasan; I am the dalang. |
| MEM_K7_RUWATAN_TITLE | Ruwatan Fajar | The Dawn Ruwatan |
| MEM_K7_RUWATAN_IN (changed) | Pertunjukan malam itu lagi, Nak, tapi kali ini kau dalangnya. Bacakan nama-nama: Sunda, Jawa, dan Ombak untuk penutupnya. | That night's show again, child, but this time you're the dalang. Read the names: Sunda, Jawa, and Ombak to close. |
| MEM_K7_RUWATAN_HINT (changed) | Sunda, Jawa, Ombak | Sunda, Jawa, Ombak |
| MEM_K7_RUWATAN_1 | Kau membacakan nama-nama anak desa. Tiap nama satu huruf, dan bayangan Kala menunduk. | You read the village children's names. One letter for each name, and Kala's shadow bows. |
| MEM_K7_RUWATAN_2 (changed) | Sunda, Jawa, Sunda, Jawa. Iramanya seperti lesung dan oncor sekaligus. | Sunda, Jawa, Sunda, Jawa. The rhythm is lesung and oncor together. |
| MEM_K7_RUWATAN_3 (changed) | Nama terakhir kau tutup dengan Ombak, dan bayangan Kala melunak seperti lilin dekat api. | You close the last name with Ombak, and on the kelir Kala's shadow softens like wax near a flame. |
| MEM_K7_RUWATAN_OUT | Begitulah ruwatan fajar, Nak: bergantian, sabar, dan dengan nama. | That is the dawn ruwatan, child: in turn, patient, and with names. |
| HINT_BATARA_KALA (changed) | Sunda, Jawa, Ombak | Sunda, Jawa, Ombak |

### Chapter 4: The Dual Ruwatan of Dawn (5.12-5.14)

### Laras chapter LC6 `lc6` (step 5.12; kind chapter; the bottom of the dark; the letter fragment `lc6_lontar` at `kala_1` starts it, cond `flag:mq5_h1`; on finish `flag:mq5_lc` and `flag:laras_sabotage_kala_eclipse`). The first lines are kept from v4
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
| @NPC_LARAS_NAME | | |
| LC6_5 | Untukmu? Kalau begitu harus kutulis bagus-bagus. Tapi kenapa tulisanku gemetar begini? | For you? Then I'd better write it nicely. But why is my writing so shaky? |
| LC6_6 | Ada sesuatu yang besar di sini. Napasnya seperti orang yang sangat lapar. Bukan marah, cuma lapar. | There's something huge here. It breathes like someone very hungry. Not angry, just hungry. |
| LC6_7 | Aku juga galak kalau lapar. Jadi aku tak mau menendangnya. Aku mau menyelinap ke bayangannya dan mencolek dari dalam. | I get grumpy when I'm hungry too. So I won't kick him. I'll slip into his shadow and poke from the inside. |
| @NPC_HERO_NAME | | |
| LC6_H2 | Hati-hati. Aku tak bisa melihatmu. | Careful. I can't see you. |
| @NPC_LARAS_NAME | | |
| LC6_8 | Tak perlu lihat. Suaramu cukup. Nanti kalau kau menyebut huruf, aku ikut menyebut namanya dari sini. | No need to see. Your voice is enough. When you say a letter, I'll say its name from in here. |
| @NPC_HERO_NAME | | |
| LC6_H3 | Setuju. Aku tak akan berhenti. | Agreed. I won't stop. |
| @NPC_LARAS_NAME | | |
| LC6_9 | Bagus. Kalau begitu aku mulai mencolek. Rasakan retaknya, siapa pun kamu. | Good. Then I'll start poking. Feel the crack, whoever you are. |

### Laras chapter segments `lc6_p2` and `lc6_p3` (played inside the finale at the Phase 2 and Phase 3 transitions; kind chapter, about 40 seconds each, the hero stands still, Laras speaks from inside Kala's shadow; `lc6_p2` starts after beat `kala_p2`, `lc6_p3` after beats `kala_p3` and its variant; **ASSUMED**)
| Key | ID | EN |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| LC6_10 | Ketemu. Ada retakan di bayangannya, tepat di bawah dagu. Kucolek sekarang. | Found it. There's a crack in his shadow, right under the chin. Poking now. |
| LC6_11 | Ka. Ga. Nga. Aku ingat semuanya, entah dari mana. Kau menyebut huruf, aku menyebut namanya. | Ka. Ga. Nga. I remember all of them, from who knows where. You say a letter, I say its name. |
| LC6_12 | Dia mundur. Dia takut pada nama sendiri. Siapa pun kamu, ucapkan yang berikutnya. | He's backing off. He's afraid of his own name. Whoever you are, say the next one. |
| LC6_13 | Ha. Na. Ca. Ra. Ka. Perisainya bergoyang seperti lampu ditiup. | Ha. Na. Ca. Ra. Ka. His shield sways like a lamp in a breeze. |
| LC6_14 | Satu lagi. Ombak. Itu bunyi laut, kan? Aku pernah mendengarnya, dari seseorang yang bernyanyi. | One more. Ombak. That's the sound of the sea, isn't it? I've heard it, from someone singing. |
| @NPC_HERO_NAME | | |
| LC6_H4 | Aku tak berhenti, Laras. | I'm not stopping, Laras. |
| @NPC_LARAS_NAME | | |
| LC6_15 | Pecahkan dari dalam, pukul dari luar. Sekarang, siapa pun kamu. | Crack from the inside, strike from the outside. Now, whoever you are. |

LC6_10 to LC6_12 are the `lc6_p2` segment; LC6_13 to LC6_15 and `LC6_H4` are the `lc6_p3` segment.

### Beat `kala_wake` (if `!flag:beat_kala_wake`, `flag:mq5_lc`, `zone:gk_ruang_kala`; do `flag:beat_kala_wake`). Step 5.13, the boss wakes; the dual-perspective finale starts. Kala is shown with respect: hungry, not wicked
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_KALA_WAKE_1 | Ruang bundar itu berdetak. Di lantai, wajah jam raksasa. Di langit-langit, jam pasir besar yang pasirnya jatuh ke atas. | The round chamber ticks. On the floor a giant clock face. Overhead, a great hourglass whose sand falls upward. |
| BEAT_KALA_WAKE_2 | Batara Kala bangkit dari bayangannya sendiri: besar, letih, dan sangat lapar. | Batara Kala rises from his own shadow: vast, weary, and very hungry. |
| @NPC_HERO_NAME | | |
| BEAT_KALA_WAKE_H1 | Aku tak mau melukaimu. Aku hanya mau adikku. | I don't want to hurt you. I only want my sister. |
| @ | | |
| BEAT_KALA_WAKE_3 | Kala tak menjawab dengan kata. Ia menjawab dengan lapar, dan seisi ruangan bergeser ke arahnya. | Kala doesn't answer with words. He answers with hunger, and the whole chamber leans toward him. |
| BEAT_KALA_WAKE_4 | Dari dalam bayangannya, sangat samar, terdengar seseorang menghitung huruf. Laras. | From inside his shadow, very faint, someone is counting letters. Laras. |
| @NPC_HERO_NAME | | |
| BEAT_KALA_WAKE_H2 | Aku datang. Bertahanlah. | I'm coming. Hold on. |
| @ | | |
| BEAT_KALA_WAKE_5 | Kau mengingat ruwatan Semar: Sunda, lalu Jawa, lalu Ombak, sabar dan dengan nama. | You remember Semar's ruwatan: Sunda, then Jawa, then Ombak, patient and with names. |
| BEAT_KALA_WAKE_6 | Perisai Gerhana menyala di sekeliling Kala. Fajar belum tiba. | The Eclipse shield flares around Kala. Dawn has not come. |

### Beat `kala_p2` (if `!flag:beat_kala_p2`, `flag:kala_p2`; do `flag:beat_kala_p2`). Phase 2; then the Laras segment `lc6_p2` plays. `flag:laras_sabotage_kala_eclipse` is what makes the shield crack
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_KALA_P2_1 | Kala berlutut, dan seisi ruang menegang seperti tali yang ditarik. | Kala kneels, and the whole chamber tightens like a drawn rope. |
| @NPC_HERO_NAME | | |
| BEAT_KALA_P2_H1 | Retak. Retaknya di mana? | A crack. Where is it? |
| @ | | |
| BEAT_KALA_P2_2 | Dari dalam bayangan Kala, sebuah suara kecil menjawab. Bukan dari lawanmu. Dari adikmu. | From inside Kala's shadow a small voice answers. Not from your foe. From your sister. |
| BEAT_KALA_P2_3 | Perisai kedua menyala, lebih rapat. Irama ruwatan harus diulang dari awal. | A second shield flares, tighter. The ruwatan rhythm must begin again from the top. |

### Beat `kala_p3` (if `!flag:beat_kala_p3`, `flag:kala_p3`; do `flag:beat_kala_p3`). Phase 3, the ruwatan setpiece; the four floor quadrants carry motifs of earlier regions. Then `kala_p3_redeem` or `kala_p3_release`, then the segment `lc6_p3`
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_KALA_P3_1 | Batara Kala berdiri tegak, dan jam di lantai berputar mundur. Ini lapar terakhirnya. | Batara Kala stands straight, and the clock on the floor spins backward. This is his last hunger. |
| BEAT_KALA_P3_2 | Empat penjuru lantai menyala satu per satu, tiap sudut membawa bayangan sebuah negeri yang pernah kau lewati. | The four quadrants of the floor light one by one, each carrying the shadow of a land you crossed. |
| @NPC_HERO_NAME | | |
| BEAT_KALA_P3_H1 | Sunda. Jawa. Ombak. Sekarang. | Sunda. Jawa. Ombak. Now. |
| @ | | |
| BEAT_KALA_P3_3 | Pusaran pelahap bergulir dari tengah lantai, selebar lorong. | A devour-pulse rolls from the centre of the floor, wide as a lane. |

### Beat `kala_p3_redeem` (if `!flag:beat_kala_p3a`, `flag:beat_kala_p3`, `flag:choice_redeem_aria`; do `flag:beat_kala_p3a`). Choice 6, redeem: Aria's shadow holds back one devour-pulse (`+6 s` on the Ruwatan countdown; code)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_KALA_P3_REDEEM_1 | Seorang lelaki tinggi tanpa topeng melangkah di antara pusaran dan dirimu. Wajahnya, untuk pertama kali, adalah wajahnya sendiri. | A tall man without a mask steps between the swirl and you. His face, for the first time, is his own. |
| @NPC_ARIA_KEBONAN_NAME | | |
| BEAT_KALA_P3_REDEEM_2 | Aria Kebonan. Namaku dipegang. Kupegang ini sebentar. | Aria Kebonan. My name is held. I'll hold this a moment. |
| @NPC_HERO_NAME | | |
| BEAT_KALA_P3_REDEEM_H1 | Terima kasih. | Thank you. |
| @NPC_ARIA_KEBONAN_NAME | | |
| BEAT_KALA_P3_REDEEM_3 | Jangan berterima kasih. Tuliskan dia pulang. | Don't thank me. Write her home. |
| @ | | |
| BEAT_KALA_P3_REDEEM_4 | Pusaran itu pecah di tangannya, dan bayangannya memudar ke dalam batu. Enam detik tambahan jatuh ke tanganmu. | The swirl breaks on his hands and his shadow fades into the stone. Six borrowed seconds fall into your hands. |

### Beat `kala_p3_release` (if `!flag:beat_kala_p3a`, `flag:beat_kala_p3`, `flag:choice_release_aria`; do `flag:beat_kala_p3a`). Choice 6, release: Keteguhan Sunyi (`+15%` stamina and sakti recovery, code)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_KALA_P3_RELEASE_1 | Pusaran lapar itu datang, tapi sunyi yang kau bawa dari batu leluhur menahan lututmu. Napasmu tetap panjang. | The hunger swirl comes, but the quiet you carried from the ancestors' stone steadies your knees. Your breath stays long. |
| BEAT_KALA_P3_RELEASE_2 | Tak ada bayangan yang melangkah di antara kalian. Tak ada nama yang perlu dipegang malam ini. | No shadow steps between you. No name needs holding tonight. |
| @NPC_HERO_NAME | | |
| BEAT_KALA_P3_RELEASE_H1 | Aku bisa terus. Tenang itu cukup. | I can keep going. The calm is enough. |
| @ | | |
| BEAT_KALA_P3_RELEASE_3 | Napas dan Sakti pulih lebih cepat dari biasanya, seperti air kembali ke tempayan. | Stamina and Sakti come back faster than usual, like water returning to a jar. |

### Beat `write` (if `!flag:beat_write`, `flag:mq5_3`; do `flag:beat_write`). Step 5.14, then entry `write_card` (if `!flag:mq5_4`, `flag:beat_write`; no lines; do `write:laras:sunda_la,sunda_ra,sunda_sa`): split so a save or quit during the card replays the card, not the talk
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_WRITE_1 | Kala berhenti. Laparnya surut seperti ombak, dan ia berbalik ke dalam gelap, tenang, tidak mati. | Kala stops. The hunger goes out of him like a tide, and he turns back into the dark, calm, not dead. |
| BEAT_WRITE_4 | Di tempat bayangan itu menyusut, sebuah tangan kecil menggapai, lalu berhenti, tak tahu siapa yang hendak digapainya. | Where the shadow shrinks a small hand reaches out, then stops, not knowing whom it reaches for. |
| BEAT_WRITE_2 | Separuh lontarmu tergeletak di batu. Kosong. | Your half of the lontar lies on the stone. It's blank. |
| @NPC_SEMAR_NAME | | |
| BEAT_WRITE_3 | Tak ada lagi yang ingat bagaimana namanya ditulis. Kecuali kau. Tuliskanlah, Nak. | Nobody else remembers how her name goes. Except you. Write it, child. |
| @NPC_HERO_NAME | | |
| BEAT_WRITE_H1 | La, Ra, Sa. Tiga huruf. | La, Ra, Sa. Three letters. |
| @NPC_SEMAR_NAME | | |
| BEAT_WRITE_5 | Tiga huruf dan tiga kenangan. Tulis seperti kau berlari ke sumur: tanpa ragu. | Three letters and three memories. Write like you ran to the well: without doubt. |
| @NPC_HERO_NAME | | |
| BEAT_WRITE_H2 | Dan kalau aku gagal? | And if I fail? |
| @NPC_SEMAR_NAME | | |
| BEAT_WRITE_6 | Kau tak akan gagal. Kau tahu cara memegang. | You won't fail. You know how to hold on. |

### Staging NPCs (v5, replaces the 2026-11-06 table)
These NPCs stand in a scene for a beat or a later act. Each gets one line so a talk is never empty. Hariang Banga's file runs, in order: the epilogue entries (section 11), entries `H1`, `HH` and the topics (Gua Kala, above), entry 2 `quest:mq4=active` (V4, the Interlude table), entry 3 the `camp_timur` talk (section 9), entry 4 no cond (V5, the throne room before his escape). The old entry `DLG_HARIANG_BANGA_V3` (the cave mouth) and the old Deserter lines `DLG_DESERTER_MOUTH_V1` and `_V2` are replaced by the Gua Kala entries above. The others have a single entry with no cond.

| Key | ID | EN |
|-----|----|----|
| DLG_HARIANG_BANGA_V4 | Ibumu menyiapkan cangkir untukku. Tak ada yang melakukannya sejak kurungan itu. | Your mother set out a cup for me. Nobody has done that since the cage. |
| DLG_HARIANG_BANGA_V5 | Jangan sekarang. Ada ibu yang harus kubebaskan. | Not now. I have a mother to free. |
| DLG_NAMELESS_HUNTER_V1 | Bukan kau. Belum. | Not you. Not yet. |
| DLG_NINI_V1 | Ciung-ku lari ke barat semalam. Susul dia, Nak, sebelum para topeng itu. | My Ciung ran west in the night. Find him, child, before the masks do. |
| DLG_SAPTO_V1 | Bilang pada ayahku aku pulang. Ia boleh berhenti main untuk dua tepi. | Tell my father I'm walking home. He can stop playing for both banks. |
| DLG_NAGAWIRU_V1 | Patahkan dulu fajar palsu itu, Penulis kecil. Baru rantainya. | Break the false dawn first, little writer. Then the chains. |
| DLG_PANGRENYEP_V1 | Puaskan matamu, Nak. Anakku sudah di jalan. | Look your fill, child. My son is already on the road. |
| DLG_SEAL_STONE_V1 | Retakan menjalar di aksara tua itu. Seseorang membaca batu ini separuh jalan, pelan-pelan. | Cracks run through the old letters. Someone read this stone halfway, slowly. |

## 11. Epilogue (`ui/epilogue.tscn`: lines 8, `semar_from = 7`, `semar_to = 7`, variants `{1: "choice_keep_secret", 2: "choice_handed", 3: "choice_judgment", 4: "choice_sink", 5: "choice_offer_song", 6: "choice_release_aria"}`, extras `{2: ["EPILOGUE_C3_FREED", "flag:choice_freed,flag:deserter_named"], 5: ["EPILOGUE_C4", "flag:c4_done"]}`; the playable day follows the cards)
Cards 1 to 6 are the six choice cards, one per Major Choice in act order (Choice 1 on card 1 and so on). The base card is the first option of each pair (`choice_tell_ciung`, `choice_freed`, `choice_mercy`, `choice_reforge`, `choice_offer_memory`, `choice_redeem_aria`); `_ALT` is the second. Card 7 is Semar's invitation and card 8 is the title card the `credits` action shows. Indexes are 1-based. An `extras` line (side-story rows at the end of section 15: `EPILOGUE_C3_FREED`, `EPILOGUE_C4`) is added under its card, after a blank line, when its cond holds (**ASSUMED**). The v4 variant `choice_silent` is retired; its card text became the Judgment card. Order: the 7 cards, then the playable day, then the credits.

| Key | ID | EN |
|-----|----|----|
| EPILOGUE_1 | Di barat Pamali, Ciung Wanara memerintah Sunda dengan adil, dan ibunya duduk di sisinya sejak hari di kawah. Di danau, Nagawiru akhirnya tidur. | West of the Pamali, Ciung Wanara rules a fair Sunda, and his mother has sat at his side since the day at the crater. In the lake, Nagawiru sleeps at last. |
| EPILOGUE_1_ALT | Di barat Pamali, Ciung Wanara memerintah Sunda dengan adil, dan suatu pagi ia menyeberangi danau menemui seorang perempuan yang telah menunggu. Di danau, Nagawiru akhirnya tidur. | West of the Pamali, Ciung Wanara rules a fair Sunda, and one morning he crosses the lake to meet a woman who has waited. In the lake, Nagawiru sleeps at last. |
| EPILOGUE_2 | Si pembelot menemukan jalan pulang. Ia masih lupa wajah istrinya, tapi istrinya ingat wajahnya. | The deserter found his way home. He still can't recall his wife's face, but she remembers his. |
| EPILOGUE_2_ALT | Lengser mengadili si pembelot dengan adil. Kini ia memperbaiki tempayan istana, dan Galuh memberinya makan. | Lengser judged the deserter fairly. He mends the palace pots now, and Galuh feeds him. |
| EPILOGUE_3 | Orang tua di kurungan kini punya halaman berlentera, dan setahun sekali Ciung Wanara membuka gerbangnya agar ia bisa melihat langit. Prajurit timur pulang tanpa hukuman, dan Hariang Banga berkirim surat ke barat. | The old man in the cage has a lantern-lit courtyard now, and once a year Ciung Wanara opens the gate so he can see the sky. The eastern soldiers walk home unpunished, and Hariang Banga writes letters west. |
| EPILOGUE_3_ALT | Kurungan itu tetap terkunci. Dalam legenda, memang selalu begitu. Hukum Galuh berdiri tegak di sepanjang sungai, dan surat Hariang Banga dari timur pendek, tapi selalu sampai. | The cage stays shut. In the legend, it always does. Galuh's law stands upright along the river, and Hariang Banga's letters from the east are short, but they always arrive. |
| EPILOGUE_4 | Mpu Wirasana menempa ulang keris itu. Kini ia menjaga gerbang sebuah desa di timur, dan tak ada yang takut padanya. | Mpu Wirasana reforged the keris. It guards a village gate in the east, and nobody fears it. |
| EPILOGUE_4_ALT | Sungai menyimpan keris itu. Kata para nelayan, kadang di malam hari airnya bersenandung. | The river keeps the keris. Some nights, the fishermen say, the water hums. |
| EPILOGUE_5 | Para nelayan selatan bercerita tentang laut yang tak pernah lupa. Satu butir masa kecilmu kabur di sana, dan Laras selalu senang mengisinya kembali. | The southern fishers tell of a sea that never forgets. One grain of your childhood is hazy there, and Laras is always glad to fill it back in. |
| EPILOGUE_5_ALT | Tiga keluarga nelayan menyanyikan lagu laut yang pulih tiap senja, dan laut menjawab dengan nada rendah. Mbah Wiryo ikut bernyanyi, sumbang. | Three fishing families sing the restored sea song each dusk, and the sea answers in a low note. Mbah Wiryo joins in, off-key. |
| EPILOGUE_6 | Nama Aria Kebonan terpahat di Batu Leluhur, tersimpan di antara raja dan juru masak. Tak ada yang memaafkannya, dan tak ada yang membiarkannya hilang. | Aria Kebonan's name is carved on the Ancestors' Stone, kept among kings and cooks. Nobody forgives him, and nobody lets him vanish. |
| EPILOGUE_6_ALT | Ruang kosong di Batu Leluhur tetap kosong. Di dekat panggung yang terbakar, seorang lelaki duduk tenang menonton abu, dan untuk pertama kalinya tak berusaha mengingat. | The blank space on the Ancestors' Stone stays blank. By the burned stage a man sits quietly watching the ashes, and for the first time isn't trying to remember. |
| EPILOGUE_7 | Dan malam ini wayang desa memainkan lakon baru. Duduk, duduk. Ini tentang seseorang yang kau kenal, hehe. | And tonight the village wayang plays a new lakon. Sit, sit. It's about someone you know, hehe. |
| EPILOGUE_8 | `{name} & Laras\n\n` followed by the old EPILOGUE_6 ID text, unchanged (the title card; was EPILOGUE_7) | `{name} & Laras\n\n` followed by the old EPILOGUE_6 EN text, unchanged (BUDAYAGO, made by fatih, Codex %d%%) |

The old `EPILOGUE_1` (Laras comes home) is now the playable day itself (`epi_wake`). The old kings card (`EPILOGUE_2`) is folded into cards 1 and 3.

### The playable epilogue (about 15 minutes; beats and quiet talks, not quest steps; starts after the cards, `from_gua_kala`, `flag:mq5_4`)
It mirrors the prologue day: Laras wakes you, Ibu pours two cups, you walk the village while the ruwatan stage is built, and the show tells your story. Order: `epi_wake`, Ibu's tea (entry 5), the village talks, `epi_banyan` (only after Choice 5, Offer Memory), `epi_show`. The credits roll at the end of `epi_show`.

New epilogue spots the zone doc `desa_purwa.md` does not list yet (it still has the v4 cast): Hariang Banga, Dewi Naganingrum, Ciung Wanara (all `cond:"flag:mq5_4"`), Cepot (a second spot near the stage), Sari (`kidul_sari`), Mpu Wirasana (`timur_empu`, `flag:choice_reforge`), Aria Kebonan (`aria_kebonan`, `flag:mq5_4`, at the burned stage; its v4 cond ends at `mq4_9`), and Ranga's cond `flag:mq5_4,!flag:choice_handed` stays. Wirasana's daughter is `timur_daughter` here (quests.md 8); the zone doc says `wirasana_daughter`.

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
| @NPC_HERO_NAME | | |
| BEAT_EPI_WAKE_H2 | Kali ini aku yang menang. | This time I win. |
| @NPC_LARAS_NAME | | |
| BEAT_EPI_WAKE_5 | Wah, percaya diri. Cepat, Ibu sudah menyeduh teh. Dua cangkir, tentu saja. | Wow, confident. Hurry, Ibu's brewed the tea. Two cups, of course. |
| @ | | |
| BEAT_EPI_WAKE_6 | Di luar jendela, panggung ruwatan sedang didirikan. Seseorang di atasnya bersenandung, sumbang. | Outside the window the ruwatan stage is going up. Someone on it is humming, off-key. |

### laras, the epilogue (entry placed first in `laras.tres`, cond `flag:mq5_4`, `"quiet": true`; the spot `Q`)
| Key | ID | EN |
|-----|----|----|
| @NPC_LARAS_NAME | | |
| DLG_LARAS_V401 | Kak, semalam aku bermimpi aneh. Tempat gelap, dan suaramu memanggil dari jauh. | Kak, I had a strange dream last night. A dark place, and your voice calling from far away. |
| @NPC_HERO_NAME | | |
| DLG_LARAS_H401 | Bagaimana mimpinya berakhir? | How did the dream end? |
| @NPC_LARAS_NAME | | |
| DLG_LARAS_V402 | Aku terus menulis Ka sampai ada yang membalas. Lalu aku bangun, dan kau mendengkur. | I kept writing Ka until someone answered. Then I woke up, and you were snoring. |
| @NPC_HERO_NAME | | |
| DLG_LARAS_H402 | Aku tidak mendengkur. | I don't snore. |
| @NPC_LARAS_NAME | | |
| DLG_LARAS_V403 | Kau mendengkur, dan namamu masih Kakak. Cepat, nanti teh Ibu dingin. | You snore, and your name is still Kakak. Hurry, Ibu's tea will go cold. |

### ibu, the epilogue (entry 5 of the table in section 5)
| Entry | Key | ID | EN |
|-------|-----|----|----|
| 5 | @NPC_IBU_NAME | | |
| 5 | DLG_IBU_V5 | Laras, siapkan piring, kakakmu pulang! | Laras, set the table, your kakak's home! |
| 5 | @NPC_LARAS_NAME | | |
| 5 | DLG_IBU_L2 | Aku di sini, Bu! Yang gompal punyaku, ya! | I'm here, Ibu! The chipped one's mine, right! |
| 5 | @NPC_IBU_NAME | | |
| 5 | DLG_IBU_V6 | Aneh. Tadi Ibu kira rumah ini terlalu sepi. | Funny. For a moment I thought this house was too quiet. |
| 5 | DLG_IBU_V401 | Dan nasinya Ibu tanak untuk dua puluh orang. Entah kenapa Ibu merasa akan ada tamu. | And I've cooked rice for twenty. I don't know why, I just felt there'd be guests. |
| 5 | @NPC_HERO_NAME | | |
| 5 | DLG_IBU_H401 | Ibu benar. Mereka sudah berdatangan. | You're right, Ibu. They're already arriving. |
| 5 | @NPC_IBU_NAME | | |
| 5 | DLG_IBU_V402 | Nah, kan. Ibu jarang salah soal makanan. | There, see. I'm rarely wrong about food. |
| 5 | DLG_IBU_V23 | Teh melati, dua cangkir, seperti biasa. Pulang sebelum pertunjukan, berdua. | Jasmine tea, two cups, as ever. Home before the show, both of you. |

### Epilogue village talks (one or more entries each, first in the NPC's file, cond `flag:mq5_4` plus the cond shown; `"quiet": true`; entries that set a `once` flag play once, then the next entry or the file's old entries follow). Who is there depends on the journey and the six choices
The talks cover Choice 1 (Ciung and Naganingrum), 2 (Ranga, Lengser), 3 (Hariang, Ki Sumarto, Sapto, Ciung's cage topic), 4 (Ratna, Wirasana), 5 (Wiryo, Sari, the banyan beat) and 6 (Aria Kebonan). The elder's grandson and Semar keep their v4 lines unchanged: `DLG_SUNDA_GRANDSON_V5` ("I brought my angklung! Remember the note you were owed?") and Semar's entries 12 and 13 (`DLG_SEMAR_V15`, `DLG_SEMAR_V16`).

#### ciung_wanara (Choice 1 and Choice 3; hub)
| Entry | if | do |
|-------|----|----|
| E1 | `flag:mq5_4`, `flag:choice_tell_ciung`, `!flag:epi_ciung` | `flag:epi_ciung` |
| E2 | `flag:mq5_4`, `flag:choice_keep_secret`, `!flag:epi_ciung` | `flag:epi_ciung` |
| EH | `flag:mq5_4`, `"hub": true`, `"quiet": true` | |
| ET1 | `"topic": "ciung_cage"`, `flag:choice_mercy`, `"quiet": true` | |
| ET2 | `"topic": "ciung_cage"`, `"quiet": true` (judgment; the fallback) | |
| ET3 | `"topic": "ciung_show"`, `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| E1 | @NPC_CIUNG_WANARA_NAME | | |
| E1 | DLG_CIUNG_WANARA_V423 | Ibu menyuruhku duduk lurus. Aku belum pernah duduk lurus untuk siapa pun. | Mother told me to sit straight. I've never sat straight for anyone. |
| E1 | DLG_CIUNG_WANARA_V424 | Ia menyebutku nak tiap kalimat kedua, dan aku tak keberatan sedikit pun. | She calls me child every second sentence, and I don't mind one bit. |
| E1 | @NPC_HERO_NAME | | |
| E1 | DLG_CIUNG_WANARA_H404 | Kau tampak bahagia. | You look happy. |
| E1 | @NPC_CIUNG_WANARA_NAME | | |
| E1 | DLG_CIUNG_WANARA_V425 | Aku tampak seperti orang yang takut bangun. Tapi ini bukan mimpi. Terima kasih sudah memberitahuku waktu itu. | I look like someone afraid to wake up. But this isn't a dream. Thank you for telling me back then. |
| E1 | DLG_CIUNG_WANARA_V426 | Laras menyuruhku menjaga barisan depan. Kubilang aku raja. Ia bilang ia kakak sang Penulis, jadi ia bosnya. | Laras told me to guard the front row. I said I'm a king. She said she's the Writer's sister, so she's the boss. |
| E1 | DLG_CIUNG_WANARA_V427 | Temui Hariang. Ia membawa roti, dan itu langka. | Find Hariang. He's carrying bread, and that's rare. |
| E2 | @NPC_CIUNG_WANARA_NAME | | |
| E2 | DLG_CIUNG_WANARA_V428 | Tadi ada perempuan di dekat sumur yang menatapku seakan sudah mengenal namaku sebelum aku. | There was a woman by the well just now who looked at me as if she knew my name before I did. |
| E2 | @NPC_HERO_NAME | | |
| E2 | DLG_CIUNG_WANARA_H405 | Mungkin memang begitu. | Maybe she did. |
| E2 | @NPC_CIUNG_WANARA_NAME | | |
| E2 | DLG_CIUNG_WANARA_V429 | Lengser menarik lengan bajuku dan berbisik: itu ibumu. Hanya itu, lalu pergi, si tua licik. | Lengser tugged my sleeve and whispered: that's your mother. Just that, then wandered off, the sly old man. |
| E2 | DLG_CIUNG_WANARA_V430 | Aku berdiri seperti tiang. Ia yang melangkah lebih dulu. Kau sudah tahu sejak lama, bukan? | I stood there like a post. She stepped first. You've known for a long time, haven't you? |
| E2 | @NPC_HERO_NAME | | |
| E2 | DLG_CIUNG_WANARA_H406 | Sejak di danau. Maaf aku menunggu. | Since the lake. I'm sorry I waited. |
| E2 | @NPC_CIUNG_WANARA_NAME | | |
| E2 | DLG_CIUNG_WANARA_V431 | Jangan minta maaf. Kau menjaga rahasia yang bukan hakmu untuk dibuka. Aku belum tentu sanggup menerimanya lebih awal. | Don't apologise. You kept a secret that wasn't yours to open. I might not have borne it any sooner. |
| E2 | DLG_CIUNG_WANARA_V432 | Ia mengajakku makan siang. Tolong suruh Laras jangan menertawakanku. | She's invited me to lunch. Please tell Laras not to laugh at me. |
| EH | @NPC_CIUNG_WANARA_NAME | | |
| EH | DLG_CIUNG_WANARA_V433 | Kalau mau tanya sesuatu, tanyalah. Malam ini aku tak ke mana-mana. | If you want to ask something, ask. I'm not going anywhere tonight. |
| ET1 | @NPC_CIUNG_WANARA_NAME | | |
| ET1 | DLG_CIUNG_WANARA_V12 | Dia titip salam. Lampunya masih menyala. | He sends his greetings. The lamp is still lit. |
| ET1 | DLG_CIUNG_WANARA_V434 | Setahun sekali kubuka gerbangnya supaya ia melihat langit. Ia tak pernah meminta lebih. | Once a year I open the gate so he can see the sky. He never asks for more. |
| ET1 | DLG_CIUNG_WANARA_V435 | Aneh rasanya. Dulu ia mencuri wajah ayahku, dan aku yang membawakannya lampu. | Strange. He once stole my father's face, and I'm the one who brings him a lamp. |
| ET2 | @NPC_CIUNG_WANARA_NAME | | |
| ET2 | DLG_CIUNG_WANARA_V13 | Aku datang karena Laras mengundangku. Soal kandang itu... lain kali. | I came because Laras invited me. About the cage... another time. |
| ET2 | DLG_CIUNG_WANARA_V436 | Hukum Galuh tegak, dan aku tidur nyenyak, hampir tiap malam. Hampir. | Galuh's law stands, and I sleep soundly, most nights. Most. |
| ET3 | @NPC_CIUNG_WANARA_NAME | | |
| ET3 | DLG_CIUNG_WANARA_V437 | Semar bilang lakonnya tentang seseorang yang kukenal. Aku sudah menebak, dan tak akan kubilang. | Semar says the lakon is about someone I know. I've guessed, and I won't say. |
| ET3 | DLG_CIUNG_WANARA_V438 | Duduklah di depan. Laras sudah menyisakan tempat, dan ia menggigit. | Sit up front. Laras has saved you a seat, and she bites. |

| Key | ID | EN | do |
|-----|----|----|----|
| CHOICE_CIUNG_EPI_1 | Tanya soal kurungan itu. | Ask about the cage. | `topic:ciung_cage` |
| CHOICE_CIUNG_EPI_2 | Tanya soal pertunjukan malam ini. | Ask about tonight's show. | `topic:ciung_show` |
| CHOICE_CIUNG_EPI_3 | Sudah cukup. | That's enough. | (none) |

The choices belong to entry `EH`.

#### naganingrum (Choice 1)
| Entry | if | do |
|-------|----|----|
| NE1 | `flag:mq5_4`, `flag:choice_tell_ciung`, `!flag:epi_naga` | `flag:epi_naga` |
| NE2 | `flag:mq5_4`, `flag:choice_keep_secret`, `!flag:epi_naga` | `flag:epi_naga` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| NE1 | @NPC_NAGANINGRUM_NAME | | |
| NE1 | DLG_NAGANINGRUM_V414 | Aku diberi kursi di barisan depan. Kayunya empuk bagi punggung seorang ratu yang pernah tidur di tepi danau. | I've been given a seat in the front row. The wood is soft on the back of a queen who once slept by a lake. |
| NE1 | DLG_NAGANINGRUM_V415 | Anakku belum berhenti menoleh ke arahku. Ia takut aku hilang lagi. | My son hasn't stopped turning to look at me. He's afraid I'll vanish again. |
| NE1 | @NPC_HERO_NAME | | |
| NE1 | DLG_NAGANINGRUM_H407 | Ia tak akan membiarkan itu. | He won't let that happen. |
| NE1 | @NPC_NAGANINGRUM_NAME | | |
| NE1 | DLG_NAGANINGRUM_V416 | Aku tahu. Karena itu aku sengaja duduk di tempat yang bisa ia lihat. Seorang ibu boleh memanjakan sedikit. | I know. That's why I sit where he can see me. A mother may spoil a little. |
| NE1 | DLG_NAGANINGRUM_V417 | Nikmati pertunjukannya, Nak. Aku sudah menikmati bagian terbaiknya. | Enjoy the show, child. I've already had the best part. |
| NE2 | @NPC_NAGANINGRUM_NAME | | |
| NE2 | DLG_NAGANINGRUM_V418 | Seseorang menarik lengan bajuku di dekat sumur tadi. Seorang pemuda yang berdiri seperti tiang. | Someone tugged my sleeve by the well just now. A young man standing like a post. |
| NE2 | DLG_NAGANINGRUM_V419 | Aku tertawa, lalu menangis, lalu ia ikut menangis dan berusaha menyembunyikannya di balik lengan bajunya. | I laughed, then cried, then he cried too and tried to hide it in his sleeve. |
| NE2 | @NPC_HERO_NAME | | |
| NE2 | DLG_NAGANINGRUM_H408 | Ia sudah menunggumu, tanpa tahu. | He was waiting for you, without knowing. |
| NE2 | @NPC_NAGANINGRUM_NAME | | |
| NE2 | DLG_NAGANINGRUM_V420 | Dan aku menunggunya, dengan tahu. Terima kasih sudah memberi kami waktu untuk siap, Nak. | And I waited for him, knowing. Thank you for giving us time to be ready, child. |
| NE2 | DLG_NAGANINGRUM_V421 | Duduklah dekat kami. Ia ingin mengenalkanku pada semua orang. | Sit near us. He wants to introduce me to everyone. |

#### hariang_banga (Choice 3)
| Entry | if | do |
|-------|----|----|
| HE1 | `flag:mq5_4`, `flag:choice_mercy`, `!flag:epi_hariang` | `flag:epi_hariang` |
| HE2 | `flag:mq5_4`, `flag:choice_judgment`, `!flag:epi_hariang` | `flag:epi_hariang` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| HE1 | @NPC_HARIANG_BANGA_NAME | | |
| HE1 | DLG_HARIANG_BANGA_V419 | Ibuku menulis lagi. Dua halaman, hangat, dan separuhnya tentang Ciung. | My mother wrote again. Two pages, warm, and half of them about Ciung. |
| HE1 | DLG_HARIANG_BANGA_V420 | Aku membalasnya di tepi sumur desa, dengan pena pinjaman Laras. | I answered by the village well, with Laras's borrowed pen. |
| HE1 | @NPC_HERO_NAME | | |
| HE1 | DLG_HARIANG_BANGA_H403 | Kalian jadi bersaudara. | You've become brothers. |
| HE1 | @NPC_HARIANG_BANGA_NAME | | |
| HE1 | DLG_HARIANG_BANGA_V421 | Sebagian hari. Sebagian hari lainnya kami hanya dua raja yang berebut sepotong pisang goreng. | Some days. Other days we're just two kings fighting over a piece of fried banana. |
| HE1 | DLG_HARIANG_BANGA_V422 | Cobalah pisang goreng ibumu. Itu satu-satunya perang yang kuinginkan lagi. | Try your mother's fried bananas. That's the only war I want again. |
| HE2 | @NPC_HARIANG_BANGA_NAME | | |
| HE2 | DLG_HARIANG_BANGA_V423 | Ibuku tetap di bawah hukum Galuh. Bulan lalu kujenguk. Ia menyuruhku makan banyak dan tidak menangis. | My mother stays under Galuh's law. I visited last month. She told me to eat plenty and not cry. |
| HE2 | DLG_HARIANG_BANGA_V424 | Aku tak menangis. Aku hanya bersin. Banyak. | I didn't cry. I only sneezed. A lot. |
| HE2 | @NPC_HERO_NAME | | |
| HE2 | DLG_HARIANG_BANGA_H404 | Itu bukan tangis. | That isn't crying. |
| HE2 | @NPC_HARIANG_BANGA_NAME | | |
| HE2 | DLG_HARIANG_BANGA_V425 | Ibuku bilang begitu juga. Kami tak sepakat soal banyak hal, dan itu menenangkan. | My mother said the same. We disagree about a lot, and it's soothing. |
| HE2 | DLG_HARIANG_BANGA_V426 | Aku di sini karena Laras mengundangku. Dan karena roti ibumu. | I'm here because Laras invited me. And because of your mother's bread. |

#### lengser (Choice 2)
| Entry | if | do |
|-------|----|----|
| LE1 | `flag:mq5_4`, `flag:choice_freed` | |
| LE2 | `flag:mq5_4`, `flag:choice_handed` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| LE1 | @NPC_LENGSER_NAME | | |
| LE1 | DLG_LENGSER_V9 | Panggung wayang desa ini lebih rendah dari singgasana Galuh, tapi kursinya lebih empuk. Lututku setuju. | This village's wayang stage is lower than Galuh's throne, but the seats are softer. My knees agree. |
| LE1 | DLG_LENGSER_V401 | Si pembelot duduk di barisan paling belakang tanpa topeng. Kuperhatikan, ia menghitung pintu keluar. | The deserter sits in the back row without his mask. I notice he counts the exits. |
| LE1 | @NPC_HERO_NAME | | |
| LE1 | DLG_LENGSER_H401 | Kau curiga padanya? | Do you suspect him? |
| LE1 | @NPC_LENGSER_NAME | | |
| LE1 | DLG_LENGSER_V402 | Aku curiga pada semua orang. Itu pekerjaanku. Tapi harus kuakui, ia pandai memegang tangan. | I suspect everyone. That's my job. But I must admit, he holds a hand well. |
| LE1 | DLG_LENGSER_V403 | Pergilah. Sebentar lagi pertunjukan mulai, dan lututku tak mau berdiri lagi. | Go on. The show starts soon, and my knees won't stand again. |
| LE2 | @NPC_LENGSER_NAME | | |
| LE2 | DLG_LENGSER_V9 | Panggung wayang desa ini lebih rendah dari singgasana Galuh, tapi kursinya lebih empuk. Lututku setuju. | This village's wayang stage is lower than Galuh's throne, but the seats are softer. My knees agree. |
| LE2 | DLG_LENGSER_V404 | Si pembelot yang kuperiksa itu menambal tempayan istana sekarang, dengan telaten. Ia tak datang malam ini; kuberi izin tidur. | The deserter I questioned mends the palace pots now, patiently. He's not here tonight; I gave him leave to sleep. |
| LE2 | @NPC_HERO_NAME | | |
| LE2 | DLG_LENGSER_H402 | Ia baik-baik saja? | Is he well? |
| LE2 | @NPC_LENGSER_NAME | | |
| LE2 | DLG_LENGSER_V405 | Tiga tempayan pecah, empat utuh. Itu kemajuan. | Three pots broken, four whole. That's progress. |
| LE2 | DLG_LENGSER_V403 | Pergilah. Sebentar lagi pertunjukan mulai, dan lututku tak mau berdiri lagi. | Go on. The show starts soon, and my knees won't stand again. |

#### faceless_deserter (Ranga, only if freed; Choice 2)
| Entry | if | do |
|-------|----|----|
| RE1 | `flag:mq5_4`, `flag:choice_freed`, `flag:deserter_named` | |
| RE2 | `flag:mq5_4`, `flag:choice_freed` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| RE1 | @NPC_FACELESS_DESERTER_NAME | | |
| RE1 | DLG_FACELESS_DESERTER_V7 | Wajah istriku masih kabur. Tapi ia memegang tanganku di depan panggung. Cukup. | My wife's face is still a blur. But she's holding my hand at the front of the stage. That's enough. |
| RE1 | DLG_FACELESS_DESERTER_V419 | Ranga. Ia memanggilku Ranga di depan semua orang, dan tak seorang pun menoleh heran. | Ranga. She called me Ranga in front of everyone, and nobody turned in surprise. |
| RE1 | @NPC_HERO_NAME | | |
| RE1 | DLG_FACELESS_DESERTER_H405 | Nama yang cocok untukmu. | A name that suits you. |
| RE1 | @NPC_FACELESS_DESERTER_NAME | | |
| RE1 | DLG_FACELESS_DESERTER_V420 | Katanya dulu aku berisik. Aku tak ingat, tapi kupercaya. | She says I used to be loud. I don't remember, but I believe her. |
| RE1 | DLG_FACELESS_DESERTER_V421 | Duduklah di depan. Aku di belakang, dan aku akan sering menengok. | Sit up front. I'll be at the back, and I'll look over often. |
| RE2 | @NPC_FACELESS_DESERTER_NAME | | |
| RE2 | DLG_FACELESS_DESERTER_V7 | Wajah istriku masih kabur. Tapi ia memegang tanganku di depan panggung. Cukup. | My wife's face is still a blur. But she's holding my hand at the front of the stage. That's enough. |
| RE2 | DLG_FACELESS_DESERTER_V422 | Ia memanggilku suamiku, dan untuk sementara itu cukup sebagai nama. | She calls me husband, and for now that does for a name. |
| RE2 | @NPC_HERO_NAME | | |
| RE2 | DLG_FACELESS_DESERTER_H406 | Nama yang lain akan kutemukan untukmu. | I'll find you the other name too. |
| RE2 | @NPC_FACELESS_DESERTER_NAME | | |
| RE2 | DLG_FACELESS_DESERTER_V423 | Mungkin. Sementara itu aku punya tangan yang digenggam. Itu pun sebuah nama, rasanya. | Maybe. Meanwhile I have a hand to hold. That's a kind of name too, I think. |

#### mataram_dalang and sapto (Ki Sumarto and Sapto; Choice 3)
| Entry (NPC id) | if | do |
|----------------|----|----|
| ME1 (mataram_dalang) | `flag:mq5_4`, `flag:choice_mercy` | |
| ME2 (mataram_dalang) | `flag:mq5_4`, `flag:choice_judgment` | |
| SE1 (sapto) | `flag:mq5_4`, `flag:choice_mercy` | |
| SE2 (sapto) | `flag:mq5_4`, `flag:choice_judgment` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| ME1 | @NPC_MATARAM_DALANG_NAME | | |
| ME1 | DLG_MATARAM_DALANG_V8 | Semar menyuruhku menonton saja malam ini. Pertama kalinya kelirku tak perlu dibela. | Semar told me to just watch tonight. The first time my screen needs no defending. |
| ME1 | DLG_MATARAM_DALANG_V401 | Lakonku minggu ini tentang sebuah sel dengan jendela. Dua tepi menonton dan tak satu pun melempar sandal. | My lakon this week was about a cell with a window. Both banks watched and nobody threw a sandal. |
| ME1 | @NPC_HERO_NAME | | |
| ME1 | DLG_MATARAM_DALANG_H401 | Itu pujian tertinggi. | That's the highest praise. |
| ME1 | @NPC_MATARAM_DALANG_NAME | | |
| ME1 | DLG_MATARAM_DALANG_V402 | Dari penonton Mataram, ya. Sapto bilang ia diam-diam menyukainya. | From a Mataram crowd, yes. Sapto says he secretly liked it. |
| ME2 | @NPC_MATARAM_DALANG_NAME | | |
| ME2 | DLG_MATARAM_DALANG_V8 | Semar menyuruhku menonton saja malam ini. Pertama kalinya kelirku tak perlu dibela. | Semar told me to just watch tonight. The first time my screen needs no defending. |
| ME2 | DLG_MATARAM_DALANG_V403 | Lakonku minggu ini tentang seorang hakim yang tak bisa tidur. Dua tepi menonton dengan tegang, dan satu orang mengangguk. | My lakon this week was about a judge who couldn't sleep. Both banks watched tensely, and one man nodded. |
| ME2 | @NPC_HERO_NAME | | |
| ME2 | DLG_MATARAM_DALANG_H402 | Siapa yang mengangguk? | Who nodded? |
| ME2 | @NPC_MATARAM_DALANG_NAME | | |
| ME2 | DLG_MATARAM_DALANG_V404 | Seorang prajurit dari barisan belakang. Aku tak bertanya. Dalang yang bijak tak bertanya. | A soldier from the back rows. I didn't ask. A wise dalang doesn't ask. |
| SE1 | @NPC_SAPTO_NAME | | |
| SE1 | DLG_SAPTO_V2 | Bapak menangis di barisan depan. Katanya debu. | Bapak is crying in the front row. He says it's dust. |
| SE1 | DLG_SAPTO_V401 | Prajurit timur boleh pulang tanpa hukuman, termasuk kawan-kawanku. Beberapa ada di sini, makan pisang goreng. | The eastern soldiers can go home unpunished, my friends among them. Some are here, eating fried bananas. |
| SE1 | DLG_SAPTO_V402 | Bapak langsung menyuruhku mengangkat tiang panggung. Pulang itu ternyata pekerjaan. | Bapak put me straight to work lifting stage poles. Coming home turns out to be a job. |
| SE2 | @NPC_SAPTO_NAME | | |
| SE2 | DLG_SAPTO_V2 | Bapak menangis di barisan depan. Katanya debu. | Bapak is crying in the front row. He says it's dust. |
| SE2 | DLG_SAPTO_V403 | Sungai kini dijaga ketat, tapi aku boleh menyeberang sebagai tamu. Kata Bapak itu kemajuan, kataku itu antrean. | The river is guarded tightly now, but I may cross as a guest. Bapak calls it progress, I call it a queue. |
| SE2 | @NPC_HERO_NAME | | |
| SE2 | DLG_SAPTO_H401 | Tamu yang sabar. | A patient guest. |
| SE2 | @NPC_SAPTO_NAME | | |
| SE2 | DLG_SAPTO_V404 | Terlatih, maksudmu. | Trained, you mean. |

#### timur_daughter and timur_empu (Ratna and Wirasana; Choice 4)
Ratna's reforge entry sets `flag:epi_ratna_temper`, the moment she tempers your Keris Mpu Gandring (**ASSUMED**; the item stays the same, a short fade-and-lamp effect).

| Entry (NPC id) | if | do |
|----------------|----|----|
| TE1 (timur_daughter) | `flag:mq5_4`, `flag:choice_reforge` | `flag:epi_ratna_temper` |
| TE2 (timur_daughter) | `flag:mq5_4`, `flag:choice_sink` | |
| WE1 (timur_empu) | `flag:mq5_4`, `flag:choice_reforge` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| TE1 | @NPC_TIMUR_DAUGHTER_NAME | | |
| TE1 | DLG_TIMUR_DAUGHTER_V5 | Ayah ikut datang. Katanya bilah yang kau bawa akhirnya tidur nyenyak. | Father came too. He says the blade you carry finally sleeps well. |
| TE1 | DLG_TIMUR_DAUGHTER_V401 | Boleh kulihat bilahmu? Bukan untuk ditukar. Hanya disepuh air kembang, seperti Ayah mengajariku. | May I see your blade? Not to swap it. Only to temper it with flower water, the way Father taught me. |
| TE1 | @NPC_HERO_NAME | | |
| TE1 | DLG_TIMUR_DAUGHTER_H401 | Silakan. | Please. |
| TE1 | @NPC_TIMUR_DAUGHTER_NAME | | |
| TE1 | DLG_TIMUR_DAUGHTER_V402 | Selesai. Ia hangat. Kalau ia berbisik, jangan takut, itu cuma menyapa. | Done. It's warm. If it whispers, don't be afraid, it's only saying hello. |
| TE2 | @NPC_TIMUR_DAUGHTER_NAME | | |
| TE2 | DLG_TIMUR_DAUGHTER_V6 | Ayah tinggal di bengkel. Katanya sungai pasti menjaga keris itu lebih baik darinya. | Father stayed at the forge. He says the river will keep that keris better than he could. |
| TE2 | DLG_TIMUR_DAUGHTER_V403 | Aku sering ke sungai. Kadang kudengar nyanyiannya, dan kupikir itu bilahnya bermimpi. | I go to the river often. Sometimes I hear it humming, and I think it's the blade dreaming. |
| TE2 | @NPC_HERO_NAME | | |
| TE2 | DLG_TIMUR_DAUGHTER_H402 | Mimpi yang baik? | A good dream? |
| TE2 | @NPC_TIMUR_DAUGHTER_NAME | | |
| TE2 | DLG_TIMUR_DAUGHTER_V404 | Mimpi yang pelan. Batu Kali yang kau bawa? Simpan baik-baik. Ia lebih jujur daripada keris mana pun. | A slow dream. The Batu Kali you carry? Keep it safe. It's more honest than any keris. |
| WE1 | @NPC_TIMUR_EMPU_NAME | | |
| WE1 | DLG_TIMUR_EMPU_V401 | Seumur hidup aku takut pada keris itu. Sekarang aku menyambungnya sendiri, dan tanganku tak gemetar. | All my life I feared that keris. Now I've joined it myself, and my hands don't shake. |
| WE1 | @NPC_HERO_NAME | | |
| WE1 | DLG_TIMUR_EMPU_H401 | Kau berhasil. | You did it. |
| WE1 | @NPC_TIMUR_EMPU_NAME | | |
| WE1 | DLG_TIMUR_EMPU_V402 | Putriku yang menenangkannya. Aku hanya memegang. Anak muda memang suka mengejutkan ayahnya. | My daughter calmed it. I only held. The young do like to surprise their fathers. |
| WE1 | DLG_TIMUR_EMPU_V403 | Duduklah, Penulis. Malam ini aku yang menonton bayangan, bukan menempa besi. | Sit, writer. Tonight I watch shadows instead of forging iron. |

#### kidul_jurukunci and kidul_sari (Mbah Wiryo and Sari; Choice 5)
| Entry (NPC id) | if | do |
|----------------|----|----|
| WY1 (kidul_jurukunci) | `flag:mq5_4`, `flag:choice_offer_song` | |
| WY2 (kidul_jurukunci) | `flag:mq5_4`, `flag:choice_offer_memory` | |
| SA1 (kidul_sari) | `flag:mq5_4`, `flag:choice_offer_song` | |
| SA2 (kidul_sari) | `flag:mq5_4`, `flag:choice_offer_memory` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| WY1 | @NPC_WIRYO_NAME | | |
| WY1 | DLG_WIRYO_V8 | Senja tadi ombak menyebut nama Sumi sebelum kuminta. Aku datang untuk bilang terima kasih. | At dusk the surf said Sumi's name before I asked. I came to say thank you. |
| WY1 | DLG_KIDUL_JURUKUNCI_V401 | Tiga keluarga itu menyanyikan lagunya tiap senja sekarang. Laut menjawab dengan nada rendah. | The three families sing the song every dusk now. The sea answers in a low note. |
| WY1 | @NPC_HERO_NAME | | |
| WY1 | DLG_KIDUL_JURUKUNCI_H401 | Kau ikut bernyanyi? | Do you sing along? |
| WY1 | @NPC_WIRYO_NAME | | |
| WY1 | DLG_KIDUL_JURUKUNCI_V402 | Sumbang, tapi ikut. Sumi tak pernah keberatan dengan suaraku. | Off-key, but I join in. Sumi never minded my voice. |
| WY2 | @NPC_WIRYO_NAME | | |
| WY2 | DLG_WIRYO_V8 | Senja tadi ombak menyebut nama Sumi sebelum kuminta. Aku datang untuk bilang terima kasih. | At dusk the surf said Sumi's name before I asked. I came to say thank you. |
| WY2 | DLG_KIDUL_JURUKUNCI_V403 | Kau memberikan sepotong masa kecilmu pada laut. Akan kuselipkan sepotong itu dalam lagu, supaya ia tak sendirian di sana. | You gave the sea a piece of your childhood. I'll slip a piece of it into the song, so it isn't alone there. |
| WY2 | @NPC_HERO_NAME | | |
| WY2 | DLG_KIDUL_JURUKUNCI_H402 | Terima kasih, Mbah. | Thank you, Mbah. |
| WY2 | @NPC_WIRYO_NAME | | |
| WY2 | DLG_KIDUL_JURUKUNCI_V404 | Kalau suatu hari kau rindu bagian itu, datanglah ke pantai dan bernyanyi. Laut mengembalikannya sedikit. | If one day you miss that piece, come to the shore and sing. The sea gives a little back. |
| SA1 | @NPC_KIDUL_SARI_NAME | | |
| SA1 | DLG_KIDUL_SARI_V401 | Aku yang memimpin paduan suara pantai malam ini. Tiga keluarga, dua belas suara, satu sumbang. Itu Mbah. | I'm leading the coast choir tonight. Three families, twelve voices, one off-key. That's Mbah. |
| SA1 | @NPC_HERO_NAME | | |
| SA1 | DLG_KIDUL_SARI_H401 | Aku akan mendengarkan dari depan. | I'll listen from the front. |
| SA1 | @NPC_KIDUL_SARI_NAME | | |
| SA1 | DLG_KIDUL_SARI_V402 | Kami membawa lagu ini jauh dari laut, supaya orang-orang di sini tahu bunyi laut yang mengingat. | We carried this song far from the sea, so people here know how a remembering sea sounds. |
| SA2 | @NPC_KIDUL_SARI_NAME | | |
| SA2 | DLG_KIDUL_SARI_V403 | Mbah bilang kau memberi laut sesuatu yang pribadi. Aku menyelam tiap pagi, siapa tahu menemukannya. | Mbah says you gave the sea something personal. I dive every morning, in case I find it. |
| SA2 | @NPC_HERO_NAME | | |
| SA2 | DLG_KIDUL_SARI_H402 | Itu tak akan ada di dasar. | It won't be on the bottom. |
| SA2 | @NPC_KIDUL_SARI_NAME | | |
| SA2 | DLG_KIDUL_SARI_V404 | Kalau begitu kucari di tempat lain. Aku keras kepala, kata Mbah, seperti istrinya. | Then I'll look elsewhere. I'm stubborn, Mbah says, like his wife. |

#### cepot (SQ-C4; he is bragging to the village children)
| Entry | if | do |
|-------|----|----|
| CE1 | `flag:mq5_4`, `flag:c4_done` | |
| CE2 | `flag:mq5_4` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| CE1 | @NPC_CEPOT_NAME | | |
| CE1 | DLG_CEPOT_V413 | Dengar, anak-anak! Pada suatu malam, Cepot memegang lentera sendirian di pantai, dan semua ombak kapok. | Listen, children! One night, Cepot held the lamp alone on the beach, and every wave learned its lesson. |
| CE1 | @NPC_HERO_NAME | | |
| CE1 | DLG_CEPOT_H403 | Bukan sendirian, Cepot. | Not alone, Cepot. |
| CE1 | @NPC_CEPOT_NAME | | |
| CE1 | DLG_CEPOT_V414 | Itu bagian yang kupotong supaya ceritanya lebih pendek. | That's the part I cut to keep the story short. |
| CE1 | DLG_CEPOT_V415 | Aku tak lari sekali pun. Kecuali waktu lari. | I never ran once. Except when running. |
| CE2 | @NPC_CEPOT_NAME | | |
| CE2 | DLG_CEPOT_V416 | Dengar, anak-anak. Cepot ikut menyelamatkan dunia. Sebagian besar dengan mengomel. | Listen, children. Cepot helped save the world. Mostly by grumbling. |
| CE2 | @NPC_HERO_NAME | | |
| CE2 | DLG_CEPOT_H404 | Itu cukup akurat. | That's fairly accurate. |
| CE2 | @NPC_CEPOT_NAME | | |
| CE2 | DLG_CEPOT_V417 | Terima kasih. Baru kali ini ada yang bilang aku akurat. | Thank you. First time anyone's called me accurate. |

#### aria_kebonan (Choice 6; he sits at the burned stage, `"quiet": true`; both entries replace entry 2 of the Interlude table for `flag:mq5_4`)
| Entry | if | do |
|-------|----|----|
| AE1 | `flag:mq5_4`, `flag:choice_redeem_aria` | |
| AE2 | `flag:mq5_4`, `flag:choice_release_aria` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| AE1 | @NPC_ARIA_KEBONAN_NAME | | |
| AE1 | DLG_ARIA_KEBONAN_V401 | Seorang anak menyebut namaku tadi, tanpa tahu siapa aku. Namaku terdengar ringan. | A child said my name just now, not knowing who I am. My name sounded light. |
| AE1 | @NPC_HERO_NAME | | |
| AE1 | DLG_ARIA_KEBONAN_H401 | Namamu terpahat di batu itu. | Your name is carved on that stone. |
| AE1 | @NPC_ARIA_KEBONAN_NAME | | |
| AE1 | DLG_ARIA_KEBONAN_V402 | Aku tahu. Tak seorang pun memaafkanku, dan batu itu tak peduli. Aku sedang belajar hidup dengan itu. | I know. Nobody forgives me, and the stone doesn't mind. I'm learning to live with it. |
| AE1 | DLG_ARIA_KEBONAN_V403 | Duduklah di depan. Aku di belakang, di tempat yang pantas bagiku. | Sit up front. I'll be at the back, where I belong. |
| AE2 | @NPC_ARIA_KEBONAN_NAME | | |
| AE2 | DLG_ARIA_KEBONAN_V404 | Aku duduk di sini menonton abu. Tak ada yang menyebut namaku, dan itu menyenangkan. | I sit here watching the ashes. Nobody says my name, and it's pleasant. |
| AE2 | @NPC_HERO_NAME | | |
| AE2 | DLG_ARIA_KEBONAN_H402 | Kau tak ingin diingat? | Don't you want to be remembered? |
| AE2 | @NPC_ARIA_KEBONAN_NAME | | |
| AE2 | DLG_ARIA_KEBONAN_V405 | Aku ingin berhenti berusaha mengingat. Itu bukan hal yang sama, dan baru kali ini aku bisa membedakannya. | I want to stop trying to remember. That isn't the same thing, and this is the first time I can tell them apart. |
| AE2 | DLG_ARIA_KEBONAN_V406 | Pergilah. Pertunjukannya akan mulai, dan kelirnya terdengar sampai sini juga. | Go on. The show is about to start, and the kelir carries even here. |

### Beat `epi_banyan` (if `!flag:beat_epi_banyan`, `flag:beat_epi_wake`, `flag:choice_offer_memory`, area `epi_banyan` at the old banyan; do `flag:beat_epi_banyan`). Choice 5, Offer Memory: the hazy banyan detail, which Laras restores. Area `epi_banyan` is ASSUMED (the tag-game banyan of section 5)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_EPI_BANYAN_1 | Kau berhenti di bawah beringin tua. Sesuatu tentang tempat ini terasa kabur, seperti kaca yang dihembus napas. | You stop under the old banyan. Something about this place feels blurred, like glass breathed on. |
| @NPC_HERO_NAME | | |
| BEAT_EPI_BANYAN_H1 | Beringin ini. Daunnya, apa yang dilakukan daunnya? | This banyan. Its leaves, what did the leaves do? |
| @NPC_LARAS_NAME | | |
| BEAT_EPI_BANYAN_2 | Kak, kamu lupa? Waktu aku menyapa Ki Waringin, daunnya bergetar padahal tak ada angin. Kau sendiri yang bilang itu rahasia kita. | Kak, you forgot? When I greeted Ki Waringin, the leaves shivered with no wind. You said that was our secret. |
| @NPC_HERO_NAME | | |
| BEAT_EPI_BANYAN_H2 | Bergetar. Ya. Sekarang aku ingat. | Shivered. Yes. Now I remember. |
| @NPC_LARAS_NAME | | |
| BEAT_EPI_BANYAN_3 | Nah. Tak apa. Ada bagian yang laut simpan, ada bagian yang aku simpan. Kita impas. | There. It's fine. Some pieces the sea keeps, some pieces I keep. We're even. |
| @ | | |
| BEAT_EPI_BANYAN_4 | Daun-daun di atas kalian bergetar pelan, seperti tertawa. | The leaves above you shiver softly, as if laughing. |
| @NPC_HERO_NAME | | |
| BEAT_EPI_BANYAN_H3 | Terima kasih, Laras. Sudah mengingatkan. | Thank you, Laras. For reminding me. |
| @NPC_LARAS_NAME | | |
| BEAT_EPI_BANYAN_5 | Sama-sama. Sekarang sampai sumur, Kak. Yang kalah cuci piring. | You're welcome. Now to the well, Kak. Loser washes the dishes. |

### Beat `epi_show` (if `!flag:beat_epi_show`, `flag:beat_epi_wake`, `flag:epi_show_ready`; do `flag:beat_epi_show`, `credits`). Area `wayang_stage` in the evening sets `epi_show_ready` (ASSUMED); `credits` is a new action (ASSUMED)
| Key | ID | EN |
|-----|----|----|
| @NPC_SEMAR_NAME | | |
| BEAT_EPI_SHOW_1 | Duduk, duduk. Pada suatu masa ada seorang murid yang hanya mengulang cerita orang lain... | Sit, sit. Once there was an apprentice who only repeated other people's stories... |
| @NPC_LARAS_NAME | | |
| BEAT_EPI_SHOW_2 | Kak, ini tentang kamu, kan? Bagian mana yang kulewatkan? | Kak, this is about you, isn't it? Which part did I miss? |
| @NPC_HERO_NAME | | |
| BEAT_EPI_SHOW_H1 | Banyak. Akan kuceritakan, dari kejar-kejaran sampai nama. | A lot. I'll tell you, from the tag game to the name. |
| @NPC_SEMAR_NAME | | |
| BEAT_EPI_SHOW_4 | Di kelir, seorang murid belajar bahwa nama adalah pegangan, dan bahwa tak ada yang terlalu kecil untuk ditulis. | On the screen an apprentice learns that a name is a handhold, and that nothing is too small to write. |
| @NPC_CEPOT_NAME | | |
| BEAT_EPI_SHOW_5 | Bapak, jangan lupa bagianku. Aku yang paling berani. | Bapak, don't forget my part. I was the bravest. |
| @NPC_SEMAR_NAME | | |
| BEAT_EPI_SHOW_6 | Kau muncul di akhir, Cepot, sebagai awan. | You appear at the end, Cepot, as a cloud. |
| @ | | |
| BEAT_EPI_SHOW_3 | Di kelir, bayanganmu dan bayangan Laras duduk berdampingan. Lampu blencong bergoyang. Kredit mulai bergulir. | On the kelir your shadow and Laras's sit side by side. The blencong lamp sways. The credits begin to roll. |

## 12. Quest text (`quests.csv`)
**Lines in this section: 396** (v5, no fixed budget).
- `Q_<ID>_TITLE`, quest id upper-cased. The journal shows the act title; MQ4 shows the Act V title for the whole quest.

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_TITLE | A Day in Desa Purwa | Sehari di Desa Purwa |
| Q_MQ1_TITLE | The Crater Seal | Segel Kawah |
| Q_MQG_TITLE | The Borrowed Face | Wajah Pinjaman |
| Q_MQ2_TITLE | Blood on the Pamali | Darah di Pamali |
| Q_MQ3_TITLE | The Seven-Generation Blade | Bilah Tujuh Turunan |
| Q_MQ4_TITLE | The Sea Does Not Forget (steps 4.1-4.8: "The Quiet House" / "Rumah yang Sunyi") | Laut Tak Pernah Lupa |
| Q_MQ5_TITLE | Into the Maw of Time | Ke Rahang Sang Waktu |

- `Q_<ID>_S<n>_OBJ`: the Objective columns of [quests.md](quests.md) 4, `n` 1-based in table order (0.1 is S1, g.1 is S1), shortened to a HUD line where needed; the 138 main steps, then the side quests:

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_S1_OBJ | Catch Laras: she dares you to a game of tag | Tangkap Laras: dia menantangmu bermain kejar-kejaran |
| Q_MQ0_S2_OBJ | Have tea with Ibu, then hear the old couple's request | Minum teh bersama Ibu, lalu dengarkan permintaan pasangan tua di sebelah |
| Q_MQ0_S3_OBJ | Climb the banyan ridge and fetch Ciung and his strange egg | Daki punggung beringin dan jemput Ciung beserta telurnya yang aneh |
| Q_MQ0_S4_OBJ | Walk the morning market and ask the stall-keeper about the masked stranger | Susuri pasar pagi dan tanya penjaga lapak tentang orang asing bertopeng polos |
| Q_MQ0_S5_OBJ | Meet Semar and Cepot at the sanggar | Temui Semar dan Cepot di sanggar |
| Q_MQ0_S6_OBJ | Write your name and Laras's at opposite ends of her lontar | Tuliskan namamu dan nama Laras di kedua ujung lontarnya |
| Q_MQ0_S7_OBJ | Help light the four oil lamps around the wayang stage | Bantu nyalakan empat lampu minyak di sekeliling panggung wayang |
| Q_MQ0_S8_OBJ | Play Semar's wayang ruwatan behind the lit kelir | Mainkan wayang ruwatan Semar di balik kelir yang menyala |
| Q_MQ0_S9_OBJ | Fight through the crowd to reach Laras as shadows step off the screen | Terobos kerumunan untuk mencapai Laras saat bayangan turun dari layar |
| Q_MQ0_S10_OBJ | Wake in the quiet house, ask Ibu about Laras, and pull her lontar from the burned stage | Bangun di rumah yang sunyi, tanya Ibu soal Laras, dan ambil lontarnya dari panggung terbakar |
| Q_MQ0_S11_OBJ | Bring the torn lontar to Semar, learn Ka and cast it three times | Bawa lontar yang robek kepada Semar, pelajari Ka dan rapalkan tiga kali |
| Q_MQ0_S12_OBJ | Drive the faceless from the square and see the Hunter at the west gate | Usir para tanpa rupa dari alun-alun dan lihat sang Pemburu di gerbang barat |
| Q_MQ1_S1_OBJ | Arrival. Walk the tea terraces at dawn, meet the elder's grandson, break the ambush and find Laras's ribbon | Jalani kebun teh saat fajar, temui cucu sesepuh, patahkan penyergapan dan temukan pita Laras |
| Q_MQ1_S2_OBJ | Follow the broken bamboo trail and clear the Faceless scout camp | Ikuti jejak bambu patah dan bersihkan perkemahan pengintai Tanpa Rupa |
| Q_MQ1_S3_OBJ | Rest at the terrace petilasan and speak with Cepot | Beristirahat di petilasan kebun teh dan bicara dengan Cepot |
| Q_MQ1_S4_OBJ | Defend the kampung from the Faceless and the wild boars | Pertahankan kampung dari Tanpa Rupa dan babi hutan |
| Q_MQ1_S5_OBJ | Ask the kampung elder about Laras, learn Ga, then follow a mother's calling to the hamlet by the gorge | Tanya sesepuh kampung tentang Laras, pelajari Ga, lalu ikuti suara seorang ibu ke dusun di tepi ngarai |
| Q_MQ1_S6_OBJ | Speak with the mother at the hamlet and search the dusk riverbank | Bicara dengan sang ibu di dusun dan periksa tepi sungai saat senja |
| Q_MQ1_S7_OBJ | K1 clues. Examine the unlit torches and the split tracks in the gorge | Periksa obor yang padam dan jejak terpisah di ngarai |
| Q_MQ1_S8_OBJ | Relight the outer hamlet lanterns to push back the dusk mist | Nyalakan kembali lentera luar dusun untuk menghalau kabut senja |
| Q_MQ1_S9_OBJ | K1 memory. Follow the lontar's pull: a child at maghrib | Ikuti tarikan lontar: seorang anak saat maghrib |
| Q_MQ1_S10_OBJ | Defeat Sandekala in the river gorge by keeping the four oncor lit | Kalahkan Sandekala di ngarai sungai dengan menjaga keempat oncor menyala |
| Q_MQ1_S11_OBJ | Climb into the deep forest, clear the spirit ambush and stand the three name-stones | Daki hutan lebat, bersihkan penyergapan roh dan tegakkan tiga batu nama |
| Q_MQ1_S12_OBJ | Read the defaced Batu Tulis and learn Nga | Baca Batu Tulis yang dirusak dan pelajari Nga |
| Q_MQ1_S13_OBJ | Descend to the rice terraces, where a dam has begun to flood the valley | Turun ke teras sawah, tempat bendungan mulai membanjiri lembah |
| Q_MQ1_S14_OBJ | Drive the Faceless and the forest spirits off the Weaver's terraces | Usir Tanpa Rupa dan jurig hutan dari teras sawah Penenun |
| Q_MQ1_S15_OBJ | Open the two sluice wheels and take the Boeh Rarang from the Weaver | Buka dua roda pintu air dan terimalah Boeh Rarang dari Penenun |
| Q_MQ1_S16_OBJ | Follow the dammed river toward the rising lake | Ikuti sungai yang dibendung menuju danau yang meluap |
| Q_MQ1_S17_OBJ | K2 clues. Find out why: felled trees, empty coops, the Weaver's loom | Cari tahu sebabnya: pohon tumbang, kandang kosong, alat tenun |
| Q_MQ1_S18_OBJ | Clear the lake shore and look at what the fallen Faceless dropped | Bersihkan tepi danau dan lihat apa yang dijatuhkan seorang Tanpa Rupa yang tumbang |
| Q_MQ1_S19_OBJ | Speak with the woman by the lake and learn Ca | Bicara dengan perempuan di tepi danau dan pelajari Ca |
| Q_MQ1_S20_OBJ | Fight up the crater road and rest at the upper petilasan | Bertempur mendaki jalan kawah dan beristirahat di petilasan atas |
| Q_MQ1_S21_OBJ | LC1. Play Laras: reading slowly at the crater | Mainkan Laras: membaca pelan-pelan di kawah |
| Q_MQ1_S22_OBJ | Defeat the Faceless Captain on the crater rim and take the mask fragment | Kalahkan Kapten Tanpa Rupa di bibir kawah dan ambil pecahan topeng |
| Q_MQ1_S23_OBJ | K2 memory. Follow the lontar's pull: Dayang Sumbi's night | Ikuti tarikan lontar: malam Dayang Sumbi |
| Q_MQ1_S24_OBJ | End the legend again with the false dawn, then decide what to tell Ciung | Akhiri legenda sekali lagi dengan fajar palsu, lalu putuskan apa yang kauberitahukan pada Ciung |
| Q_MQG_S1_OBJ | Arrival. Meet the rooster seller, then plan the infiltration with Ciung Wanara | Kedatangan. Temui penjual ayam jago, lalu susun rencana penyusupan bersama Ciung Wanara |
| Q_MQG_S2_OBJ | Scout Pasar Kuta: talk to the informant and read the wagon manifest | Intai Pasar Kuta: bicara dengan pemberi kabar dan baca daftar angkutan pedati |
| Q_MQG_S3_OBJ | Expose and defeat the king's tournament riggers in the storehouse | Bongkar dan kalahkan pengatur curang sayembara raja di gudang pasar |
| Q_MQG_S4_OBJ | Win both bouts of the royal tournament | Menangkan kedua babak sayembara kerajaan |
| Q_MQG_S5_OBJ | Speak with Uwa Lengser and rest at the inner garden petilasan | Bicara dengan Uwa Lengser dan beristirahat di petilasan taman dalam |
| Q_MQG_S6_OBJ | Infiltrate the Balai Pustaka and meet the archivist, Nyai Sekar | Menyusup ke Balai Pustaka dan temui juru arsip, Nyai Sekar |
| Q_MQG_S7_OBJ | Solve the mirror-lamp cipher and read the scraped royal lineage | Pecahkan sandi lampu-cermin dan baca silsilah raja yang dikerik |
| Q_MQG_S8_OBJ | Cross the guarded colonnade into the Kaputren | Seberangi serambi yang dijaga menuju Kaputren |
| Q_MQG_S9_OBJ | Solve the screens and search the guest chamber where Laras was held | Pecahkan tirai dan periksa kamar tamu tempat Laras ditahan |
| Q_MQG_S10_OBJ | Overhear a prince of Galuh and the queen's attendants, then open the passage to the prison yard | Dengarkan seorang pangeran Galuh dan para dayang ratu, lalu buka lorong ke halaman penjara |
| Q_MQG_S11_OBJ | Fight down the cell stairs as the prisoner wagon prepares to leave | Bertempur menuruni tangga sel saat kereta tahanan bersiap berangkat |
| Q_MQG_S12_OBJ | Stop the Faceless escort in the cell yard as Laras's wagon escapes east | Hadang pengawal Tanpa Rupa di halaman penjara saat kereta Laras lolos ke timur |
| Q_MQG_S13_OBJ | Clear the inner cells and read Laras's message on the wall | Bersihkan sel dalam dan baca pesan Laras di dinding |
| Q_MQG_S14_OBJ | LC2. Play Laras: the guest chamber and the wagon | Mainkan Laras: kamar tamu dan kereta |
| Q_MQG_S15_OBJ | Confront the faceless deserter who guarded Laras and decide his fate | Hadapi pembelot tanpa rupa yang menjaga Laras dan putuskan nasibnya |
| Q_MQG_S16_OBJ | Use Laras's unlocked archive grate to reach the upper palace gallery | Gunakan jeruji arsip yang dibuka Laras untuk mencapai galeri atas istana |
| Q_MQG_S17_OBJ | Examine the scraped royal portrait and see Lengser's memory | Periksa potret raja yang dikerik dan alami kenangan Lengser |
| Q_MQG_S18_OBJ | Take the second mask fragment behind the throne and see the Borrowed Face (H2) | Ambil pecahan topeng kedua di balik takhta dan saksikan Wajah Pinjaman (H2) |
| Q_MQG_S19_OBJ | Rally Lengser's old guard and Ciung Wanara to breach the throne room | Kerahkan penjaga lama Lengser dan Ciung Wanara untuk mendobrak ruang takhta |
| Q_MQG_S20_OBJ | Unmask and defeat the false king in the throne room | Buka kedok dan kalahkan raja palsu di ruang takhta |
| Q_MQ2_S1_OBJ | Arrival. Cross into Mataram and hear both armies' recruiters at the border market | Seberangi ke Mataram dan dengarkan perekrut kedua pasukan di pasar perbatasan |
| Q_MQ2_S2_OBJ | Break the looter blockade at the border gate and rest at the market petilasan | Patahkan blokade penjarah di gerbang perbatasan dan beristirahat di petilasan pasar |
| Q_MQ2_S3_OBJ | Defend the market dalang's wayang stage from war-profiteers and Tuyul | Pertahankan panggung wayang dalang pasar dari penjarah perang dan Tuyul |
| Q_MQ2_S4_OBJ | Speak with the dalang about his son, learn Jawa Ha and hear of three leads on Laras | Bicara dengan dalang tentang putranya, pelajari Jawa Ha dan dengar tiga petunjuk tentang Laras |
| Q_MQ2_S5_OBJ | Escort the displaced market families across the flooded paddies | Kawal keluarga pasar yang mengungsi melintasi sawah yang tergenang |
| Q_MQ2_S6_OBJ | Lead 1, the ruins. Defeat the awakened Arca and read Jawa Na off the statue base | Petunjuk 1, reruntuhan. Kalahkan Arca yang bangkit dan baca Jawa Na dari dasar patung |
| Q_MQ2_S7_OBJ | Lead 2, the graveyard. Cleanse the graves where the faceless harvest soldiers' names | Petunjuk 2, kuburan. Bersihkan makam tempat para tanpa rupa memanen nama prajurit |
| Q_MQ2_S8_OBJ | H3. Take the third mask fragment in the graveyard and see the price | H3. Ambil pecahan topeng ketiga di kuburan dan lihat harganya |
| Q_MQ2_S9_OBJ | Lead 3, the lesung yard. Help the lesung women clear the haunted mill yard | Petunjuk 3, pelataran lesung. Bantu para perempuan lesung membersihkan pelataran tumbuk berhantu |
| Q_MQ2_S10_OBJ | Learn the dawn rhythm and Jawa Ca from Nyai Gendhis | Pelajari irama fajar dan Jawa Ca dari Nyai Gendhis |
| Q_MQ2_S11_OBJ | Break the spirit-builder siege on the foothill shrine | Hancurkan kepungan roh pembangun di kuil kaki bukit |
| Q_MQ2_S12_OBJ | Align the shrine braziers and receive Jawa Ra from the juru kunci | Selaraskan tungku kuil dan terimalah Jawa Ra dari juru kunci |
| Q_MQ2_S13_OBJ | Fight across the plain of rising stones and shatter the spirit-pillars | Bertempur melintasi dataran batu yang tumbuh dan hancurkan pilar roh |
| Q_MQ2_S14_OBJ | Breach the outer gate of Candi Seribu and storm the Faceless reading camp | Tembus gerbang luar Candi Seribu dan serbu perkemahan baca Tanpa Rupa |
| Q_MQ2_S15_OBJ | K3 clues. Examine the chiselled rubble, the silent lesung and Laras's Ka strip | Periksa puing berpahat, lesung yang membisu dan helai Ka Laras |
| Q_MQ2_S16_OBJ | LC3. Play Laras: the reading room | Mainkan Laras: ruang baca |
| Q_MQ2_S17_OBJ | Descend through Laras's unlocked crypt to the central sanctum | Turuni ruang bawah tanah yang dibuka Laras ke ruang suci utama |
| Q_MQ2_S18_OBJ | K3 memory. Follow the lontar's pull: the princess's women | Ikuti tarikan lontar: para dayang sang putri |
| Q_MQ2_S19_OBJ | End Bandung Bondowoso's night with the lesung rhythm and Jawa Ca | Akhiri malam Bandung Bondowoso dengan irama lesung dan Jawa Ca |
| Q_MQ2_S20_OBJ | Take the temple shortcut back toward the western border and reach the Pamali river | Ambil jalan pintas candi kembali ke perbatasan barat dan capai Sungai Pamali |
| Q_MQ2_S21_OBJ | Clear the river-bank skirmish and write Nagawiru's name on the Pamali stone | Bersihkan pertempuran tepi sungai dan tuliskan nama Nagawiru di batu Pamali |
| Q_MQ2_S22_OBJ | K-III. Watch Ki Sumarto's show at the river camp: the brothers who split the land | Saksikan pertunjukan Ki Sumarto di perkemahan sungai: dua saudara yang membelah tanah |
| Q_MQ2_S23_OBJ | Read Hariang Banga's unsent letters to his mother at the eastern camp | Baca surat Hariang Banga yang tak terkirim untuk ibunya di perkemahan timur |
| Q_MQ2_S24_OBJ | Duel Hariang Banga at the ford, witness the river truce and make your choice | Berduel dengan Hariang Banga di penyeberangan, saksikan gencatan senjata sungai dan tentukan pilihanmu |
| Q_MQ3_S1_OBJ | Arrival. Meet Ratna on the smiths' street, then rest at the savanna petilasan | Tiba. Temui Ratna di jalan para pandai besi, lalu beristirahat di petilasan sabana |
| Q_MQ3_S2_OBJ | Stalking Ambush 1. Survive Buto Ijo's rampage and drive him back with fire-wards | Penyergapan 1. Bertahan dari amukan Buto Ijo dan pukul dia mundur dengan penangkal api |
| Q_MQ3_S3_OBJ | Follow the red curse marks to Mpu Wirasana's forge | Ikuti tanda kutukan merah ke bengkel Mpu Wirasana |
| Q_MQ3_S4_OBJ | Learn to put out two practice curse stakes in the forge yard | Pelajari cara memadamkan dua tonggak kutukan latihan di halaman tempa |
| Q_MQ3_S5_OBJ | Reach Mbok Srini's smashed hut and examine the seeds, needle case and salt and terasi | Capai pondok Mbok Srini yang hancur dan periksa biji, tempat jarum, garam dan terasi |
| Q_MQ3_S6_OBJ | Stalking Ambush 2. Test the bramble-seed pouch on the dry riverbed | Penyergapan 2. Uji bungkusan biji berduri di dasar sungai kering |
| Q_MQ3_S7_OBJ | Stalking Ambush 3. Consecrate the three remaining pouches at the old banyan | Penyergapan 3. Sucikan tiga bungkusan terakhir di beringin tua |
| Q_MQ3_S8_OBJ | K4 memory. Follow the lontar's pull: Timun Mas | Ikuti tarikan lontar: Timun Mas |
| Q_MQ3_S9_OBJ | Lure Buto Ijo into his lair and defeat him with the four pouch fields | Pancing Buto Ijo ke sarangnya dan kalahkan dia dengan medan empat bungkusan |
| Q_MQ3_S10_OBJ | Return to the dry fields and put out the curse stakes the keris lit | Kembali ke ladang kering dan padamkan tonggak kutukan yang dinyalakan keris |
| Q_MQ3_S11_OBJ | Help Mpu Wirasana and Ratna defend the forge quarter from the flying keris | Bantu Mpu Wirasana dan Ratna menjaga kampung tempa dari kawanan keris terbang |
| Q_MQ3_S12_OBJ | Examine the broken scabbard and the seven-generation forge ledger in the vault | Periksa sarung keris patah dan buku tempa tujuh turunan di gudang |
| Q_MQ3_S13_OBJ | K5 memory. Follow the lontar's pull at the old anvil: the smith's apprentice | Ikuti tarikan lontar di landasan tua: murid sang empu |
| Q_MQ3_S14_OBJ | Follow the Hunter's ash trail down the coast with Hariang Banga's scouts | Ikuti jejak abu Si Pemburu menyusuri pesisir bersama pengintai Hariang Banga |
| Q_MQ3_S15_OBJ | Cross the Sea of Sand using the old stone waymarkers | Seberangi Lautan Pasir dengan patok batu kuno |
| Q_MQ3_S16_OBJ | Rest at the desert petilasan and speak with Hariang Banga | Beristirahat di petilasan gurun dan bicara dengan Hariang Banga |
| Q_MQ3_S17_OBJ | LC4. Play Laras across the dunes and the shrine | Mainkan Laras melintasi bukit pasir dan kuil |
| Q_MQ3_S18_OBJ | Use Laras's wind tunnel to breach the shrine and see her across the court | Pakai terowongan angin Laras untuk menembus kuil dan lihat dia di seberang pelataran |
| Q_MQ3_S19_OBJ | Lay the awakened keris to rest, using Laras's bound seventh stake | Tenangkan keris yang bangkit dengan patok ketujuh yang diikat Laras |
| Q_MQ3_S20_OBJ | Decide the fate of the blade: reforge it or give it to the river | Putuskan nasib bilah itu: tempa ulang atau serahkan pada sungai |
| Q_MQ3_S21_OBJ | Take the last mask fragment (H4) and join the whole mask (K6) | Ambil pecahan topeng terakhir (H4) dan satukan topeng utuh (K6) |
| Q_MQ3_S22_OBJ | Defeat the Nameless Hunter and give back the name Aria Kebonan | Kalahkan Si Tanpa Ngaran dan kembalikan nama Aria Kebonan |
| Q_MQ4_S1_OBJ | Return to Desa Purwa under the Eclipse and test the fog at the northern cave mouth | Kembali ke Desa Purwa di bawah Gerhana dan uji kabut di mulut gua utara |
| Q_MQ4_S2_OBJ | Talk to the old couple and the stall-keeper, who are forgetting their own families | Bicara dengan pasangan tua dan penjaga lapak yang mulai lupa keluarga sendiri |
| Q_MQ4_S3_OBJ | Write each family's name on the doorposts of three houses | Tuliskan nama keluarga di tiang pintu tiga rumah |
| Q_MQ4_S4_OBJ | Bring Ibu three of Laras's things from her shelf: the ribbon, the board and the Ka strip | Bawakan Ibu tiga benda Laras dari raknya: pita, papan, dan helai Ka |
| Q_MQ4_S5_OBJ | Sit at your mother's table with Ciung Wanara and Hariang Banga | Duduk di meja ibumu bersama Ciung Wanara dan Hariang Banga |
| Q_MQ4_S6_OBJ | Speak with Aria Kebonan beside the burned stage | Bicara dengan Aria Kebonan di dekat panggung yang terbakar |
| Q_MQ4_S7_OBJ | Hear Semar at the sanggar on his vow and why the sea never forgets | Dengarkan Semar di sanggar tentang sumpahnya dan mengapa laut tak pernah lupa |
| Q_MQ4_S8_OBJ | Walk south through the opened gate toward Segara Kidul | Berjalan ke selatan lewat gerbang yang terbuka menuju Segara Kidul |
| Q_MQ4_S9_OBJ | Arrival. Rest at the black-sand petilasan and enter Kampung Nelayan | Tiba. Beristirahat di petilasan pasir hitam dan masuki Kampung Nelayan |
| Q_MQ4_S10_OBJ | Meet Mbah Wiryo and the young diver Sari | Temui Mbah Wiryo dan penyelam muda Sari |
| Q_MQ4_S11_OBJ | K8 clues. Help three families recover the three verses of the sea song | Bantu tiga keluarga menemukan kembali tiga bait lagu laut |
| Q_MQ4_S12_OBJ | K8 memory. Follow the lontar's pull: Mbah Wiryo's wife on the shore | Ikuti tarikan lontar: istri Mbah Wiryo di pantai |
| Q_MQ4_S13_OBJ | Relight the three tidal beacons in the flooded mangroves with Sari | Nyalakan kembali tiga suar pasang di hutan bakau bersama Sari |
| Q_MQ4_S14_OBJ | Sacred Trial I, the Torch-Lines. Cross the reef and put out the Lampor | Ujian Suci I, Barisan Obor. Seberangi karang dan padamkan Lampor |
| Q_MQ4_S15_OBJ | Descend into the Gua Karang and clear the sunken shrine approach | Turun ke Gua Karang dan bersihkan jalur kuil tenggelam |
| Q_MQ4_S16_OBJ | LC5. Play Laras in the dark water and ring the three sunken bells | Mainkan Laras di air gelap dan bunyikan tiga lonceng tenggelam |
| Q_MQ4_S17_OBJ | Sacred Trial II, the Abyssal Current. Cross Laras's open gate and pass the cavern guardians | Ujian Suci II, Arus Palung. Seberangi gerbang yang dibuka Laras dan lalui penjaga gua |
| Q_MQ4_S18_OBJ | Climb the storm cliffs, rest at the cliff shrine and hear K9, the Queen of the South | Daki tebing badai, beristirahat di kuil tebing dan dengarkan K9, Ratu Selatan |
| Q_MQ4_S19_OBJ | Call Laras's name to the sea at the cliff altar and make your offering | Panggil nama Laras ke laut di altar tebing dan berikan persembahanmu |
| Q_MQ4_S20_OBJ | Walk the sea causeway to the Sea Pavilion and rest at the petilasan | Susuri jalan batu laut menuju Keraton Laut dan beristirahat di petilasan |
| Q_MQ4_S21_OBJ | Sacred Trial III, the Waves. Pass the three waves of the pavilion court | Ujian Suci III, Ombak. Lalui tiga gelombang di pelataran keraton |
| Q_MQ4_S22_OBJ | Write and learn Ombak at the Sea Altar and receive the Kain Hijau | Tulis dan pelajari Ombak di Altar Laut dan terimalah Kain Hijau |
| Q_MQ5_S1_OBJ | Arrival. Join Ciung Wanara, Hariang Banga and your allies holding the Courtyard of Time | Bergabunglah dengan Ciung Wanara, Hariang Banga, dan sekutumu yang menjaga Pelataran Waktu |
| Q_MQ5_S2_OBJ | Stand at the ancestors' stone and decide Aria Kebonan's name (Choice 6) | Berdiri di Batu Leluhur dan tentukan nama Aria Kebonan (Pilihan 6) |
| Q_MQ5_S3_OBJ | Part the Eclipse veil with Ombak and fight into the Cave Mouth | Belah tirai Gerhana dengan Ombak dan bertempur masuk ke Mulut Gua |
| Q_MQ5_S4_OBJ | Gap Memory La. Reclaim the first letter of Laras's name in the morning tag game | Ingatan Rumpang La. Rebut aksara pertama nama Laras dalam permainan kejar-kejaran pagi |
| Q_MQ5_S5_OBJ | Cross the Hourglass Sands and shatter the western and eastern time-wards | Seberangi Pasir Jam Pasir dan hancurkan penangkal waktu barat dan timur |
| Q_MQ5_S6_OBJ | Descend into Hutan Lupa and silence the whispering name-trees | Turun ke Hutan Lupa dan tenangkan pepohonan bisik yang menelan nama |
| Q_MQ5_S7_OBJ | Clear the Abyss of Forgetting and reclaim Ra in the memory of the two cups | Bersihkan Jurang Lupa dan rebut Ra dalam kenangan dua cangkir teh |
| Q_MQ5_S8_OBJ | Cross the Shadow Bridge and overcome the echoes of fallen legends | Seberangi Jembatan Bayang dan kalahkan gema legenda yang telah lewat |
| Q_MQ5_S9_OBJ | Rest at the last petilasan, talk with Semar and reclaim Sa in the memory of the written names | Beristirahat di petilasan terakhir, bicara dengan Semar, dan rebut Sa dalam kenangan nama-nama yang ditulis |
| Q_MQ5_S10_OBJ | K10. Hear Semar's tale of Murwakala: why a dalang's words calm Kala | K10. Dengarkan kisah Murwakala dari Semar: mengapa kata dalang menenangkan Kala |
| Q_MQ5_S11_OBJ | K7. Take the dalang's place and practise the Sunda, Jawa and Ombak ruwatan | K7. Ambil tempat dalang dan latih ruwatan aksara Sunda, Jawa, dan Ombak |
| Q_MQ5_S12_OBJ | LC6. Play Laras at the bottom of Kala's dark | LC6. Mainkan Laras di dasar kegelapan Kala |
| Q_MQ5_S13_OBJ | Calm Batara Kala in the Ruwatan of Dawn, with Laras inside his shadow | Tenangkan Batara Kala dalam Ruwatan Fajar, bersama Laras di dalam bayangannya |
| Q_MQ5_S14_OBJ | Write Laras's full name, La - Ra - Sa, on your lontar | Tuliskan nama lengkap Laras, La - Ra - Sa, di lontarmu |
| Q_SQ_S1_TITLE | Lutung Kasarung | Lutung Kasarung |
| Q_SQ_S1_S1_OBJ | Talk to Ki Darsa about the girl and the langur | Bicara dengan Ki Darsa tentang gadis dan lutung itu |
| Q_SQ_S1_S2_OBJ | Look at the langur's offerings and the hidden spring | Periksa persembahan si lutung dan mata air tersembunyi |
| Q_SQ_S1_S3_OBJ | Memory. As the langur, lead the girl to the spring | Ingatan. Sebagai lutung, tuntun gadis itu ke mata air |
| Q_SQ_S1_S4_OBJ | Clear the spring's guardians and restore the water | Bersihkan penjaga mata air dan pulihkan alirannya |
| Q_SQ_S1_S5_OBJ | Speak with Purbasari | Bicara dengan Purbasari |
| Q_SQ_S2_TITLE | Crying in the Bamboo | Tangis di Rumpun Bambu |
| Q_SQ_S2_S1_OBJ | Hear out the village head | Dengarkan kepala desa |
| Q_SQ_S2_S2_OBJ | Examine the grave and the torn cloth in the grove | Periksa kuburan dan kain sobek di rumpun bambu |
| Q_SQ_S2_S3_OBJ | Memory. Walk the grove at night as the grandmother did | Ingatan. Susuri rumpun bambu di malam hari seperti sang nenek |
| Q_SQ_S2_S4_OBJ | Defeat the kuntilanak on the lit ground | Kalahkan kuntilanak di tanah yang terang |
| Q_SQ_S2_S5_OBJ | Carve the forgotten woman's name with the village head | Ukir nama perempuan yang terlupakan bersama kepala desa |
| Q_SQ_S3_TITLE | The Lost Angklung Notes | Nada Angklung yang Hilang |
| Q_SQ_S3_S1_OBJ | Recover 3 tuned bamboo tubes in the gardens, kampung and terraces | Temukan 3 ruas bambu bernada di kebun, kampung, dan sawah |
| Q_SQ_S3_S2_OBJ | Arrange the pentatonic scale at the kampung pavilion | Susun tangga nada pentatonik di paviliun kampung |
| Q_SQ_S3_S3_OBJ | Play the harmony with the villagers | Mainkan harmoninya bersama warga |
| Q_SQ_S4_TITLE | Brave Cepot, Part 1 | Cepot Si Pemberani, Bagian 1 |
| Q_SQ_S4_S1_OBJ | Talk to Cepot | Bicara dengan Cepot |
| Q_SQ_S4_S2_OBJ | Free Cepot's supply pack from the 3 boars with Ga Ward | Bebaskan bungkusan bekal Cepot dari 3 babi hutan dengan Ga Ward |
| Q_SQ_S4_S3_OBJ | Report back to Cepot | Lapor kembali kepada Cepot |
| Q_SQ_G1_TITLE | The Wit of Si Kabayan | Akal Si Kabayan |
| Q_SQ_G1_S1_OBJ | Talk to Si Kabayan under the market banyan | Bicara dengan Si Kabayan di bawah beringin pasar |
| Q_SQ_G1_S2_OBJ | Help him with the official's riddles: the ledger and the sack | Bantu ia melawan teka-teki pejabat: buku pajak dan karung |
| Q_SQ_G1_S3_OBJ | Memory. Hang the basket as the tale tells | Ingatan. Gantung keranjang seperti dalam kisahnya |
| Q_SQ_G1_S4_OBJ | Watch the official's public defeat | Saksikan kekalahan pejabat di depan umum |
| Q_SQ_G2_TITLE | The Sweeping Ghost of the Kaputren | Hantu Penyapu di Kaputren |
| Q_SQ_G2_S1_OBJ | Talk to the old palace maid | Bicara dengan pelayan istana yang tua |
| Q_SQ_G2_S2_OBJ | Examine the worn broom and the scraped servants' roll | Periksa sapu yang aus dan daftar pelayan yang dikikis |
| Q_SQ_G2_S3_OBJ | Memory. Sweep as the servant did and listen | Ingatan. Menyapulah seperti sang pelayan dan dengarkan |
| Q_SQ_G2_S4_OBJ | Write his stolen name back on the servants' roll | Tulis kembali namanya yang dicuri di daftar pelayan |
| Q_SQ_G2_S4_OBJ_FIGHT | Face the sweeping ghost in the hall | Hadapi hantu penyapu di lorong |
| Q_SQ_G2_S5_OBJ | Report to the maid | Lapor kepada pelayan itu |
| Q_SQ_M1_TITLE | Jaka Tarub and Nawang Wulan | Jaka Tarub dan Nawang Wulan |
| Q_SQ_M1_S1_OBJ | Talk to Nawang Wulan | Bicara dengan Nawang Wulan |
| Q_SQ_M1_S2_OBJ | Examine the lifted pot lid and the empty lumbung | Periksa tutup periuk yang terangkat dan lumbung yang kosong |
| Q_SQ_M1_S3_OBJ | Memory. Search the lumbung as she did | Ingatan. Cari di lumbung seperti yang ia lakukan |
| Q_SQ_M1_S4_OBJ | Clear the thieves at the spring and return her shawl | Usir para pencuri di mata air dan kembalikan selendangnya |
| Q_SQ_M2_TITLE | The Child Nobody Called | Anak yang Tak Dipanggil |
| Q_SQ_M2_S1_OBJ | Talk to the worried neighbour | Bicara dengan tetangga yang cemas |
| Q_SQ_M2_S2_OBJ | Find the toy on the hill path and question the boy's parents | Temukan mainan di jalan bukit dan tanyai orang tua si anak |
| Q_SQ_M2_S3_OBJ | Memory. Follow the voice up the hill | Ingatan. Ikuti suara itu ke atas bukit |
| Q_SQ_M2_S4_OBJ | Lead the parents up the hill to call him kindly | Bawa orang tuanya ke bukit untuk memanggilnya dengan lembut |
| Q_SQ_M2_S4_OBJ_FIGHT | Defeat the spirit on the hill | Kalahkan roh di bukit |
| Q_SQ_M2_S5_OBJ | Bring the boy home | Antar anak itu pulang |
| Q_SQ_M3_TITLE | Coins Gone from the Market | Uang yang Hilang di Pasar |
| Q_SQ_M3_S1_OBJ | Talk to the blacksmith | Bicara dengan pande besi |
| Q_SQ_M3_S2_OBJ | Examine the tiny footprints and the half-counted beans | Periksa jejak kecil dan kacang yang setengah terhitung |
| Q_SQ_M3_S3_OBJ | Memory. Scatter the beans before the little counter | Ingatan. Tebar kacang di depan si penghitung kecil |
| Q_SQ_M3_S4_OBJ | Set the green-bean counting trap | Pasang jebakan hitung kacang hijau |
| Q_SQ_M3_S4_OBJ_FIGHT | Defeat the tuyul leader | Kalahkan pemimpin tuyul |
| Q_SQ_M3_S5_OBJ | Tell the blacksmith | Kabari pande besi |
| Q_SQ_M4_TITLE | The Silent Gamelan | Gamelan yang Bisu |
| Q_SQ_M4_S1_OBJ | Talk to Ki Sumarto about the silent gamelan | Bicara dengan Ki Sumarto tentang gamelan yang bisu |
| Q_SQ_M4_S2_OBJ | Recover the stolen gong ageng from the sunken ruin vault | Ambil gong ageng yang dicuri dari bilik reruntuhan yang tenggelam |
| Q_SQ_M4_S3_OBJ | Set the gong in the pavilion | Pasang gong itu di paviliun |
| Q_SQ_T1_TITLE | Ande-Ande Lumut | Ande-Ande Lumut |
| Q_SQ_T1_S1_OBJ | Talk to Klething Kuning at the cut ferry | Bicara dengan Klething Kuning di penyeberangan yang putus |
| Q_SQ_T1_S2_OBJ | Examine the claw marks and her bundle | Periksa bekas capit dan bungkusannya |
| Q_SQ_T1_S3_OBJ | Memory. Strike the water with the stick | Ingatan. Pukul air dengan lidi itu |
| Q_SQ_T1_S4_OBJ | Strike the river with the sodo lanang | Pukul sungai dengan sodo lanang |
| Q_SQ_T1_S4_OBJ_FIGHT | Defeat the giant crab | Kalahkan kepiting raksasa |
| Q_SQ_T1_S5_OBJ | Speak with Klething Kuning | Bicara dengan Klething Kuning |
| Q_SQ_T2_TITLE | Fire With No Wind | Api Tanpa Angin |
| Q_SQ_T2_S1_OBJ | Talk to the herder about the grass fires | Bicara dengan penggembala tentang kebakaran rumput |
| Q_SQ_T2_S2_OBJ | Track the scorched trail and the unlit campfire | Telusuri jejak hangus dan api unggun yang tak dinyalakan |
| Q_SQ_T2_S3_OBJ | Memory. Lead the fire to the spring | Ingatan. Tuntun api ke mata air |
| Q_SQ_T2_S4_OBJ | Open the oasis channel and defeat the fire spirit | Buka saluran oasis dan kalahkan roh api |
| Q_SQ_T2_S5_OBJ | Report to the herder | Lapor kepada penggembala |
| Q_SQ_T3_TITLE | Pamor from the Sky | Pamor dari Langit |
| Q_SQ_T3_S1_OBJ | Talk to Mpu Wirasana and Ratna | Bicara dengan Mpu Wirasana dan Ratna |
| Q_SQ_T3_S2_OBJ | Find the fallen star-stone on the Mataram temple plain | Temukan batu bintang yang jatuh di dataran candi Mataram |
| Q_SQ_T3_S3_OBJ | Defend the crater from the stone guardians | Pertahankan kawah dari para penjaga batu |
| Q_SQ_T3_S4_OBJ | Bring the star-stone back and fold the pamor steel | Bawa batu bintang pulang dan lipat baja pamor |
| Q_SQ_T4_TITLE | The Lost Kuda Kepang | Kuda Kepang yang Hilang |
| Q_SQ_T4_S1_OBJ | Recover the 3 woven bamboo horses | Temukan 3 kuda kepang anyaman bambu |
| Q_SQ_T4_S2_OBJ | Return them and watch the troupe dance | Kembalikan dan saksikan rombongan menari |
| Q_SQ_K1_TITLE | Hatchlings Home to the Sea | Tukik Pulang ke Laut |
| Q_SQ_K1_S1_OBJ | Gather 3 stranded hatchlings in the dunes and mangrove edge | Kumpulkan 3 tukik yang tersesat di bukit pasir dan tepi bakau |
| Q_SQ_K1_S2_OBJ | Clear the reef predators along the surf | Singkirkan pemangsa karang di sepanjang ombak |
| Q_SQ_K1_S3_OBJ | Release the hatchlings into the tide | Lepaskan tukik ke dalam ombak |
| Q_SQ_K2_TITLE | The Torn Nets | Jaring yang Robek |
| Q_SQ_K2_S1_OBJ | Talk to the river-mouth fisher | Bicara dengan nelayan muara |
| Q_SQ_K2_S2_OBJ | Examine the white scale and ask Mbah Wiryo | Periksa sisik putih dan tanya Mbah Wiryo |
| Q_SQ_K2_S3_OBJ | Memory. Leave the offering and read the tide | Ingatan. Taruh persembahan dan baca air pasang |
| Q_SQ_K2_S4_OBJ | Face the old one in the river-mouth lagoon | Hadapi yang tua di laguna muara |
| Q_SQ_K2_S5_OBJ | Report to the fisher | Lapor kepada nelayan |
| Q_SQ_C1_TITLE | Ciung's Rooster | Ayam Jago Ciung |
| Q_SQ_C1_S1_OBJ | Talk to Ciung Wanara about his missing rooster | Bicara dengan Ciung Wanara tentang ayam jantannya yang hilang |
| Q_SQ_C1_S2_OBJ | Follow the feathers through the market and find the old river basket | Ikuti bulu-bulu di pasar dan temukan keranjang sungai tua |
| Q_SQ_C1_S3_OBJ | Memory. Keep the egg safe on the river | Ingatan. Jaga telur itu di sungai |
| Q_SQ_C1_S4_OBJ | Coax the rooster down from the market rooftop | Bujuk ayam jantan itu turun dari atap pasar |
| Q_SQ_C1_S5_OBJ | Talk with Ciung and Uwa Lengser about the basket's charm | Bicara dengan Ciung dan Uwa Lengser tentang bandul keranjang |
| Q_SQ_C2_TITLE | Letters Across the Pamali | Surat di Seberang Pamali |
| Q_SQ_C2_S1_OBJ | Talk to Hariang Banga about his unsent letters | Bicara dengan Hariang Banga tentang surat-suratnya |
| Q_SQ_C2_S2_OBJ | Deliver the letters to the queen in Galuh | Antarkan surat-surat itu kepada sang permaisuri di Galuh |
| Q_SQ_C2_S3_OBJ | Retrieve the queen's signet ring from the kaputren | Ambil cincin segel sang permaisuri dari kaputren |
| Q_SQ_C2_S4_OBJ | Take her reply to Hariang Banga, then read the note on Ibu's table | Bawa balasannya kepada Hariang Banga, lalu baca surat di meja Ibu |
| Q_SQ_C3_TITLE | The Deserter's Name | Nama si Pembelot |
| Q_SQ_C3_S1_OBJ | Find the stitched cloth at Candi Seribu | Temukan kain berjahit di Candi Seribu |
| Q_SQ_C3_S2_OBJ | Find the old shield mark on the desert road | Temukan tanda perisai tua di jalan gurun |
| Q_SQ_C3_S3_OBJ | Find the driftwood charm in the fishing village and relive his memory | Temukan bandul kayu hanyut di desa nelayan dan hidupi ingatannya |
| Q_SQ_C3_S4_OBJ | Write his true name at the courtyard of time | Tulis nama aslinya di halaman waktu |
| Q_SQ_C4_TITLE | Brave Cepot | Cepot Si Pemberani |
| Q_SQ_C4_2_TITLE | Brave Cepot (Part 2) | Cepot Si Pemberani (Bagian 2) |
| Q_SQ_C4_2_S1_OBJ | Part 2. Look at both recruiters' rolls | Bagian 2. Lihat kedua daftar perekrut |
| Q_SQ_C4_2_S2_OBJ | Part 2. Sneak Cepot out of the border market | Bagian 2. Selundupkan Cepot keluar dari pasar perbatasan |
| Q_SQ_C4_2_S3_OBJ | Part 2. Talk to Cepot | Bagian 2. Bicara dengan Cepot |
| Q_SQ_C4_3_TITLE | Brave Cepot (Part 3) | Cepot Si Pemberani (Bagian 3) |
| Q_SQ_C4_3_S1_OBJ | Part 3. Talk to Cepot on the beach | Bagian 3. Bicara dengan Cepot di pantai |
| Q_SQ_C4_3_S2_OBJ | Part 3. Hold the ward-lamp through the night waves | Bagian 3. Pegang lentera penjaga melewati ombak malam |
| Q_SQ_C4_3_S3_OBJ | Part 3. Talk to Cepot | Bagian 3. Bicara dengan Cepot |
| Q_SQ_D1_TITLE | Lakon | Lakon |
| Q_SQ_D1_S1_OBJ | Collect lakon by finishing retellings and legends | Kumpulkan lakon dengan menamatkan kisah ulang dan legenda |
| Q_SQ_D2_TITLE | Pustaka | Pustaka |
| Q_SQ_D2_S1_OBJ | Fill the codex for Nyai Rukmi | Isi codex untuk Nyai Rukmi |

### Recap lines ("Story so far", ui.md 3, quests.md 7.4)
One short past-tense line per main step, key `Q_<QUEST>_S<n>_DONE`, `n` as above. They are read in the journal in order, so each only uses names the player has met by then (Pacing 10).

| Key | EN | ID |
|-----|----|----|
| Q_MQ0_S1_DONE | I chased Laras to the well. She called a stray cat by its real name, and it came. | Kukejar Laras sampai sumur. Ia memanggil seekor kucing dengan nama aslinya, dan kucing itu datang. |
| Q_MQ0_S2_DONE | We had jasmine tea with Ibu, and the old couple next door asked me to fetch Ciung. | Kami minum teh melati bersama Ibu, dan pasangan tua di sebelah memintaku menjemput Ciung. |
| Q_MQ0_S3_DONE | I climbed the banyan ridge and Ciung came down with his strange egg. | Kudaki punggung beringin, dan Ciung turun bersama telurnya yang aneh. |
| Q_MQ0_S4_DONE | The stall-keeper said a tall man in a blank mask was asking children's names. | Penjaga lapak bilang seorang lelaki jangkung bertopeng polos menanyai nama anak-anak. |
| Q_MQ0_S5_DONE | Semar said a written name keeps a person in the world, and Cepot fussed about the lamps. | Semar bilang nama yang ditulis menahan seseorang di dunia, dan Cepot ribut soal lampu. |
| Q_MQ0_S6_DONE | Laras wrote our names at opposite ends of one lontar, with Semar's bamboo pen. | Laras menulis nama kami di kedua ujung satu lontar, dengan pena bambu Semar. |
| Q_MQ0_S7_DONE | We lit four lamps around the stage as dusk fell. | Kami menyalakan empat lampu di sekeliling panggung saat senja turun. |
| Q_MQ0_S8_DONE | Semar played the ruwatan: Batara Kala, the Four Seals, and the children's names read aloud. | Semar mementaskan ruwatan: Batara Kala, Empat Segel, dan nama anak-anak yang dibacakan. |
| Q_MQ0_S9_DONE | The shadows stepped off the screen. The Hunter took Laras, and our lontar tore. | Bayangan turun dari kelir. Si Pemburu membawa Laras, dan lontar kami robek. |
| Q_MQ0_S10_DONE | Ibu doesn't remember Laras, yet two cups were set out. I took my lontar from the burned stage. | Ibu tak ingat Laras, tapi dua cangkir terhidang. Kuambil lontarku dari panggung yang hangus. |
| Q_MQ0_S11_DONE | Semar still remembers Laras. He taught me Ka, and I cast it three times. | Semar masih ingat Laras. Ia mengajariku Ka, dan kurapalkan tiga kali. |
| Q_MQ0_S12_DONE | I drove the faceless from the square. The Hunter stood at the west gate; Ciung had run west, and the masks followed. | Kuusir para tanpa rupa dari alun-alun. Si Pemburu berdiri di gerbang barat; Ciung lari ke barat, dan para topeng mengikutinya. |
| Q_MQ1_S1_DONE | On the tea terraces I broke an ambush and found Laras's ribbon in the bamboo. | Di kebun teh kupatahkan penyergapan dan kutemukan pita Laras di rumpun bambu. |
| Q_MQ1_S2_DONE | I cleared the Faceless scout camp. Their lists were crossed out, but Laras's name was not. | Kubersihkan perkemahan pengintai Tanpa Rupa. Daftar mereka dicoret, tapi nama Laras tidak. |
| Q_MQ1_S3_DONE | At the petilasan Cepot found me. He doesn't remember Laras, but he believes his father. | Di petilasan Cepot menemukanku. Ia tak ingat Laras, tapi ia percaya ayahnya. |
| Q_MQ1_S4_DONE | I broke the raid on the kampung, boars and masks together. | Kupatahkan serangan di kampung, babi hutan dan para topeng sekaligus. |
| Q_MQ1_S5_DONE | The kampung elder saw Laras running with a wild boy. He taught me Ga. | Sesepuh kampung melihat Laras berlari bersama bocah liar. Ia mengajariku Ga. |
| Q_MQ1_S6_DONE | Ceu Imas lost her son Asep at maghrib. I found his sandal by the river. | Ceu Imas kehilangan putranya, Asep, saat maghrib. Kutemukan sandalnya di tepi sungai. |
| Q_MQ1_S7_DONE | The torches were cold, and the prints of Laras, Ciung and the children led into the gorge. | Obor-obor padam, dan jejak Laras, Ciung dan anak-anak menuju ngarai. |
| Q_MQ1_S8_DONE | I relit the hamlet's outer lanterns, and the dusk mist stopped at their light. | Kunyalakan kembali lentera luar dusun, dan kabut senja berhenti di cahayanya. |
| Q_MQ1_S9_DONE | The lontar pulled me into a child's maghrib, and I learned to light the oncor. | Lontar menarikku ke maghrib seorang anak, dan aku belajar menyalakan oncor. |
| Q_MQ1_S10_DONE | I beat Sandekala in the gorge. Laras's and Ciung's tracks split there. | Kukalahkan Sandekala di ngarai. Jejak Laras dan Ciung berpisah di sana. |
| Q_MQ1_S11_DONE | I stood three name-stones in a line, east to west, and cleared the grove around them. | Kutegakkan tiga batu nama dalam satu garis, dari timur ke barat, dan kubersihkan hutan di sekitarnya. |
| Q_MQ1_S12_DONE | On the defaced Batu Tulis Laras scratched: "They need me to read." I learned Nga. | Di Batu Tulis yang dirusak Laras menggores: "Mereka butuh aku membaca." Kupelajari Nga. |
| Q_MQ1_S13_DONE | From the terraces I saw the valley half drowned by a dam built overnight. | Dari teras kulihat lembah setengah tenggelam oleh bendungan yang dibangun semalam. |
| Q_MQ1_S14_DONE | I drove the faceless and the forest spirits off the Weaver's terraces. | Kuusir para tanpa rupa dan jurig hutan dari teras sawah Penenun. |
| Q_MQ1_S15_DONE | I opened the sluices. The Weaver hid Laras for a night and gave me the Boeh Rarang. | Kubuka pintu air. Penenun menyembunyikan Laras semalam dan memberiku Boeh Rarang. |
| Q_MQ1_S16_DONE | I followed the dammed river to a rising lake with a half-built boat in it. | Kuikuti sungai yang dibendung sampai danau yang meluap, dengan perahu setengah jadi di dalamnya. |
| Q_MQ1_S17_DONE | A dammed river, empty coops, felled trees: someone is building a boat on the lake. | Sungai dibendung, kandang kosong, pohon tumbang: seseorang membangun perahu di danau. |
| Q_MQ1_S18_DONE | A faceless one dropped a named toy. They were people once. | Seorang tanpa rupa menjatuhkan mainan bernama. Mereka dulu manusia. |
| Q_MQ1_S19_DONE | The woman at the lake knew Ciung's face. She asked me to keep her secret, and taught me Ca. | Perempuan di danau mengenali wajah Ciung. Ia memintaku menjaga rahasianya, dan mengajariku Ca. |
| Q_MQ1_S20_DONE | I fought up the crater road. A tall shape on the ridge watched, and waited. | Kutempuh jalan kawah sambil bertempur. Sosok jangkung di punggung bukit mengawasi, dan menunggu. |
| Q_MQ1_S21_DONE | At the crater Laras was made to read. She read slowly on purpose, and I heard her voice. | Di kawah Laras dipaksa membaca. Ia sengaja membaca pelan, dan aku mendengar suaranya. |
| Q_MQ1_S22_DONE | I beat the Faceless Captain, but he cracked the seal first. I found a second mask fragment. | Kukalahkan Kapten Tanpa Rupa, tapi ia sempat memecahkan segel. Kutemukan pecahan topeng kedua. |
| Q_MQ1_S23_DONE | The lontar pulled me into Dayang Sumbi's night: white cloth, lesung, a false dawn. | Lontar menarikku ke malam Dayang Sumbi: kain putih, lesung, fajar palsu. |
| Q_MQ1_S24_DONE | A false dawn ended Sangkuriang again. Ciung and Nagawiru are free, and I chose what to tell Ciung. | Fajar palsu mengakhiri Sangkuriang sekali lagi. Ciung dan Nagawiru bebas, dan aku memilih apa yang kuberitahukan pada Ciung. |
| Q_MQG_S1_DONE | In Galuh's tournament crowd I met a rooster seller, and Ciung and I made a plan. | Di keramaian sayembara Galuh kutemui penjual ayam jago, dan Ciung serta aku menyusun rencana. |
| Q_MQG_S2_DONE | At Pasar Kuta an informant told me of wagons sealed with the king's wax. The freight list called their load new servants. | Di Pasar Kuta seorang pemberi kabar bercerita tentang pedati bersegel lilin raja. Daftar angkutan menyebut muatannya pelayan baru. |
| Q_MQG_S3_DONE | I broke the tournament riggers in the storehouse. Their purses wore the same seal as the wagons. | Kubongkar para pengatur curang sayembara di gudang. Kantong mereka bersegel sama dengan pedati. |
| Q_MQG_S4_DONE | I won both bouts; Ciung's rooster won behind the wall. | Kumenangkan kedua babak; ayam Ciung menang di balik tembok. |
| Q_MQG_S5_DONE | Uwa Lengser opened the inner palace. He saw a queen's eyes in Ciung. | Uwa Lengser membuka istana dalam. Ia melihat mata seorang ratu pada Ciung. |
| Q_MQG_S6_DONE | In the Balai Pustaka, Nyai Sekar told me she scraped the king's lineage off thirty rolls and kept the shavings. | Di Balai Pustaka, Nyai Sekar bercerita bahwa ia mengerik silsilah raja dari tiga puluh gulung dan menyimpan serpihannya. |
| Q_MQG_S7_DONE | Mirror-light raised the scraped lineage. The missing name was Nagawiru. | Cahaya cermin menampakkan silsilah yang dikerik. Nama yang hilang adalah Nagawiru. |
| Q_MQG_S8_DONE | I crossed the colonnade into the Kaputren. A mirror stood covered there too. | Kuseberangi serambi menuju Kaputren. Sebuah cermin di sana pun tertutup. |
| Q_MQG_S9_DONE | In the guest chamber I found Laras's hairpin and her Ka scratched like steps. | Di kamar tamu kutemukan tusuk rambut Laras dan Ka yang digoresnya seperti anak tangga. |
| Q_MQG_S10_DONE | I overheard a prince and the queen's attendants: a wagon waited in the prison yard to leave at dawn. | Kudengar seorang pangeran dan para dayang ratu: sebuah pedati menunggu di halaman penjara untuk berangkat saat fajar. |
| Q_MQG_S11_DONE | I fought down the cell stairs after the wagon, following wheel ruts and jasmine cloth. | Kutempuh tangga sel mengejar pedati, mengikuti bekas roda dan kain melati. |
| Q_MQG_S12_DONE | I was too late: Laras's wagon escaped east, but she threw me a strip marked Ka. | Aku terlambat: kereta Laras lolos ke timur, tapi ia melempar helai bertanda Ka. |
| Q_MQG_S13_DONE | On the cell wall Laras wrote: "The thousand temples. Don't stop." | Di dinding sel Laras menulis: "Seribu candi. Jangan berhenti." |
| Q_MQG_S14_DONE | I lived Laras's hours: she marked the king's wax, freed the archive grate and left a message for Ibu about the cup. | Kualami jam-jam Laras: ia menandai lilin raja, membuka jeruji arsip, dan menitip pesan untuk Ibu soal cangkir. |
| Q_MQG_S15_DONE | The deserter remembered his name, Ranga, from humming along to Laras. I decided what became of him. | Si pembelot ingat namanya, Ranga, dari ikut bersenandung bersama Laras. Kuputuskan nasibnya. |
| Q_MQG_S16_DONE | Laras's grate led me through the archive wall to the palace's upper gallery. | Jeruji Laras membawaku menembus tembok arsip ke galeri atas istana. |
| Q_MQG_S17_DONE | The king's portrait was scraped bare. Lengser's memory showed a man trying on the king's face. | Potret raja dikikis habis. Ingatan Lengser menunjukkan seorang lelaki mencoba wajah raja. |
| Q_MQG_S18_DONE | A second mask fragment lay by the throne. Aria borrowed the king's face, and the price was his name. | Pecahan topeng kedua tergeletak di dekat takhta. Aria meminjam wajah raja, dan harganya namanya sendiri. |
| Q_MQG_S19_DONE | Lengser's old guard and Ciung gathered to breach the throne room. | Penjaga lama Lengser dan Ciung berkumpul untuk mendobrak ruang takhta. |
| Q_MQG_S20_DONE | I unmasked Barma Wijaya. He confessed he gave his old name to Kala, and that name is the Hunter. | Kubuka topeng Barma Wijaya. Ia mengaku memberikan namanya yang dulu pada Kala, dan nama itu si Pemburu. |
| Q_MQ2_S1_DONE | At the river market two recruiters told the same war backwards, and stones grew in the fields beyond the gate. | Di pasar sungai dua perekrut menceritakan perang yang sama secara terbalik, dan batu tumbuh di ladang di luar gerbang. |
| Q_MQ2_S2_DONE | I broke the looters' blockade at the border gate and rested at the petilasan. | Kupatahkan blokade penjarah di gerbang perbatasan dan beristirahat di petilasan. |
| Q_MQ2_S3_DONE | I saved a dalang's stage from war-profiteers and Tuyul. | Kuselamatkan panggung seorang dalang dari penjarah perang dan Tuyul. |
| Q_MQ2_S4_DONE | Ki Sumarto taught me Ha and named three trails to Laras: the ruins, the graveyard and the lesung yard. | Ki Sumarto mengajariku Ha dan menyebut tiga jejak menuju Laras: reruntuhan, kuburan, dan pelataran lesung. |
| Q_MQ2_S5_DONE | I led the market families over the flooded paddies. Their children had seen Laras's Ka. | Kukawal keluarga pasar melintasi sawah tergenang. Anak-anak mereka melihat Ka Laras. |
| Q_MQ2_S6_DONE | At the ruins I beat the awakened Arca and read Na off the statue base. | Di reruntuhan kukalahkan Arca yang bangkit dan kubaca Na dari dasar patung. |
| Q_MQ2_S7_DONE | At the graves the Hunter said two armies make twice the forgetting. | Di kuburan si Pemburu bilang dua pasukan membuat dua kali lupa. |
| Q_MQ2_S8_DONE | A third mask fragment showed what his name cost. | Pecahan topeng ketiga menunjukkan harga namanya. |
| Q_MQ2_S9_DONE | Nyai Gendhis and I cleared the lesung yard, and the pestles were handed back. | Nyai Gendhis dan aku membersihkan pelataran lesung, dan alu-alu dikembalikan. |
| Q_MQ2_S10_DONE | Nyai Gendhis taught me the false-dawn rhythm and Ca. | Nyai Gendhis mengajariku irama fajar palsu dan Ca. |
| Q_MQ2_S11_DONE | I broke the night builders' siege on the foothill shrine. | Kupatahkan kepungan para pembangun malam di kuil kaki bukit. |
| Q_MQ2_S12_DONE | I aligned the shrine's braziers, and the juru kunci gave me Ra and opened the temple stairs. | Kuselaraskan tungku kuil, dan juru kunci memberiku Ra serta membuka tangga candi. |
| Q_MQ2_S13_DONE | I shattered the pillars on the plain of rising stones. | Kuhancurkan pilar-pilar di dataran batu yang tumbuh. |
| Q_MQ2_S14_DONE | The camp at Candi Seribu was a reading room. Laras had been taken east. | Perkemahan di Candi Seribu ternyata ruang baca. Laras sudah dibawa ke timur. |
| Q_MQ2_S15_DONE | Rubble, an abandoned lesung, Laras's Ka strip: all pointed to one old tale. | Puing, lesung yang ditinggalkan, helai Ka Laras: semuanya menunjuk satu kisah lama. |
| Q_MQ2_S16_DONE | Laras read slowly in the reading room, freed a crypt door and hid the builder's chisel. | Laras membaca pelan di ruang baca, membuka pintu ruang bawah tanah, dan menyembunyikan pahat si pembangun. |
| Q_MQ2_S17_DONE | Laras's crypt door led me down to the temple's heart. | Pintu ruang bawah tanah Laras membawaku turun ke jantung candi. |
| Q_MQ2_S18_DONE | The lontar pulled me to the princess's women, and I learned the lesung beat. | Lontar menarikku ke para dayang sang putri, dan aku belajar irama lesung. |
| Q_MQ2_S19_DONE | With the beat and Ca, Bandung Bondowoso's night ended. | Dengan irama dan Ca, malam Bandung Bondowoso berakhir. |
| Q_MQ2_S20_DONE | The temple shortcut brought me back to the Pamali, where two armies waited. | Jalan pintas candi membawaku kembali ke Pamali, tempat dua pasukan menunggu. |
| Q_MQ2_S21_DONE | On the Pamali stone I wrote Nagawiru's name, the first name I ever wrote for someone. | Di batu Pamali kutuliskan nama Nagawiru, nama pertama yang kutulis untuk orang lain. |
| Q_MQ2_S22_DONE | Ki Sumarto played two brothers who split the land, and I learned what pamali means. | Ki Sumarto memainkan dua saudara yang membelah tanah, dan aku belajar arti pamali. |
| Q_MQ2_S23_DONE | I read Hariang Banga's letters to his mother. | Kubaca surat-surat Hariang Banga untuk ibunya. |
| Q_MQ2_S24_DONE | I fought Hariang Banga at the ford. The river truce held, and I answered Ciung about the caged. | Kulawan Hariang Banga di penyeberangan. Gencatan senjata sungai bertahan, dan kujawab Ciung soal para terkurung. |
| Q_MQ3_S1_DONE | On the smiths' street I met Ratna, who folds keris. She gave me three fire-ward nails and sent me to rest. | Di jalan para pandai besi kutemui Ratna, yang melipat keris. Ia memberiku tiga paku penangkal api dan menyuruhku beristirahat. |
| Q_MQ3_S2_DONE | A green giant, Buto Ijo, charged me out of the grass. The nails drove him back, and his eyes were the red of the curse. | Raksasa hijau, Buto Ijo, menerjangku dari rumput. Paku-paku itu mendorongnya mundur, dan matanya semerah kutukan. |
| Q_MQ3_S3_DONE | Red curse marks led me to Mpu Wirasana. He is the seventh smith to tend a blade made to swallow. | Tanda kutukan merah membawaku ke Mpu Wirasana. Ia empu ketujuh yang merawat bilah yang ditempa untuk menelan. |
| Q_MQ3_S4_DONE | At his yard I put out two practice stakes with Ha. A mark is a debt, and Ha pays it down. | Di halamannya kupadamkan dua tonggak latihan dengan Ha. Tanda itu hutang, dan Ha melunasinya perlahan. |
| Q_MQ3_S5_DONE | Mbok Srini lost her daughter Timun Mas to the giant. I found the seeds, the needle case, the salt and the terasi. | Mbok Srini kehilangan putrinya, Timun Mas, pada raksasa itu. Kutemukan biji, tempat jarum, garam dan terasi. |
| Q_MQ3_S6_DONE | On the dry riverbed the seed pouch grew brambles and held Buto Ijo for ten breaths. | Di dasar sungai kering, bungkusan biji menumbuhkan semak berduri dan menahan Buto Ijo sepuluh napas. |
| Q_MQ3_S7_DONE | At the old banyan I consecrated the pouches while the giant came a third time. He was being placed in our road. | Di beringin tua kusucikan bungkusan-bungkusan itu saat raksasa datang ketiga kali. Ia ditaruh di jalan kami. |
| Q_MQ3_S8_DONE | The lontar pulled me into Timun Mas running from a giant with four pouches. | Lontar menarikku menjadi Timun Mas yang lari dari raksasa dengan empat bungkusan. |
| Q_MQ3_S9_DONE | I led Buto Ijo through the four pouch fields and beat him. Mbok Srini held her muddy daughter. | Kupancing Buto Ijo melewati empat medan bungkusan dan kukalahkan. Mbok Srini memeluk putrinya yang berlumpur. |
| Q_MQ3_S10_DONE | Red stakes rose in the dry fields, each with a name. I put them out one by one. | Tonggak merah muncul di ladang kering, masing-masing bernama. Kupadamkan satu per satu. |
| Q_MQ3_S11_DONE | Twenty-three ghost keris flew at the forge. Wirasana, Ratna and I held the quarter. | Dua puluh tiga keris hantu menerjang bengkel. Wirasana, Ratna dan aku menjaga kampung tempa. |
| Q_MQ3_S12_DONE | In the vault I found the broken scabbard and the ledger of seven smiths. The last name was Wirasana's. | Di gudang kutemukan sarung patah dan buku tujuh empu. Nama terakhirnya Wirasana. |
| Q_MQ3_S13_DONE | At the old anvil I became the apprentice who saw the curse born, and learned to douse it. | Di landasan tua aku menjadi murid yang melihat kutukan lahir, dan belajar memadamkannya. |
| Q_MQ3_S14_DONE | With Hariang Banga's scouts I followed the Hunter's ash trail down the coast. It runs straight. | Bersama pengintai Hariang Banga kuikuti jejak abu Si Pemburu menyusuri pesisir. Jejaknya lurus. |
| Q_MQ3_S15_DONE | I crossed the Sea of Sand by the old waymarkers. One leaned on purpose. | Kuseberangi Lautan Pasir dengan patok kuno. Satu miring dengan sengaja. |
| Q_MQ3_S16_DONE | At the desert fire Hariang Banga talked of Ciung, his mother and a man with only weariness. | Di api unggun gurun Hariang Banga bicara tentang Ciung, ibunya, dan lelaki yang hanya punya rasa lelah. |
| Q_MQ3_S17_DONE | Laras tried to draw my face in the sand and couldn't. She opened a wind tunnel and wrote Ka on the seventh stake. | Laras mencoba menggambar wajahku di pasir dan tak bisa. Ia membuka terowongan angin dan menulis Ka pada tonggak ketujuh. |
| Q_MQ3_S18_DONE | Her tunnel brought me behind the shrine. Across the court I saw her reading, and the seventh stake would not light. | Terowongannya membawaku ke belakang kuil. Di seberang pelataran kulihat ia membaca, dan tonggak ketujuh tak mau menyala. |
| Q_MQ3_S19_DONE | I laid the awakened keris to rest. Seven stakes went out, the last one slowest. | Kutenangkan keris yang bangkit. Tujuh tonggak padam, yang terakhir paling pelan. |
| Q_MQ3_S20_DONE | I chose what to do with the blade: Wirasana's forge or the river. | Kuputuskan nasib bilah itu: bengkel Wirasana atau sungai. |
| Q_MQ3_S21_DONE | The last fragment showed the raid through the Hunter's eyes. The fragments joined into one mask. | Pecahan terakhir menunjukkan penyerbuan lewat mata si Pemburu. Pecahan-pecahan menyatu menjadi satu topeng. |
| Q_MQ3_S22_DONE | I faced the Hunter and gave back the name Aria Kebonan. Then the Eclipse took Laras mid-word. | Kuhadapi si Pemburu dan kukembalikan nama Aria Kebonan. Lalu Gerhana mengambil Laras di tengah kata. |
| Q_MQ4_S1_DONE | Hariang Banga's riders set me down in Desa Purwa under the Eclipse. The fog at the cave mouth ate every glyph I threw. | Pasukan Hariang Banga menurunkanku di Desa Purwa di bawah Gerhana. Kabut di mulut gua memakan setiap huruf yang kulempar. |
| Q_MQ4_S2_DONE | The old couple and the stall-keeper are forgetting their own families. They named three houses worst. | Pasangan tua dan penjaga lapak mulai lupa keluarga sendiri. Mereka menyebut tiga rumah yang paling parah. |
| Q_MQ4_S3_DONE | I wrote three families' names on their doorposts, and the houses remembered. | Kutuliskan nama tiga keluarga di tiang pintu mereka, dan rumah-rumah itu ingat. |
| Q_MQ4_S4_DONE | I brought Ibu Laras's ribbon, board and Ka strip. She set the second cup straight. | Kubawakan Ibu pita, papan, dan helai Ka milik Laras. Ia menata cangkir kedua dengan benar. |
| Q_MQ4_S5_DONE | Ciung and Hariang ate at my mother's table as brothers. | Ciung dan Hariang makan di meja ibuku sebagai saudara. |
| Q_MQ4_S6_DONE | Aria Kebonan told me Kala eats names, and Laras's is split in three. He asked to be forgotten. | Aria Kebonan bilang Kala memakan nama, dan nama Laras dipecah tiga. Ia minta dilupakan. |
| Q_MQ4_S7_DONE | Semar told me he is a god who chose to be a servant, and sent me south to the sea. | Semar bilang ia dewa yang memilih menjadi abdi, dan menyuruhku ke selatan, ke laut. |
| Q_MQ4_S8_DONE | The south gate opened onto black sand and a green sea. | Gerbang selatan terbuka ke pasir hitam dan laut hijau. |
| Q_MQ4_S9_DONE | On the black-sand shore I rested at the petilasan, and Kampung Nelayan mended its nets in silence. | Di pantai pasir hitam aku beristirahat di petilasan, dan Kampung Nelayan menambal jala dalam diam. |
| Q_MQ4_S10_DONE | Mbah Wiryo taught me the sea's manners and the three sacred trials. Sari, the diver, offered to guide me. | Mbah Wiryo mengajariku tata krama laut dan tiga ujian suci. Sari, sang penyelam, menawarkan diri memandu. |
| Q_MQ4_S11_DONE | I gathered three verses of the sea song from three families. | Kukumpulkan tiga bait lagu laut dari tiga keluarga. |
| Q_MQ4_S12_DONE | The lontar showed Wiryo's wife teaching him to call a name into the water. | Lontar menunjukkan istri Wiryo mengajarinya memanggil nama ke dalam air. |
| Q_MQ4_S13_DONE | With Sari I lit the three tidal beacons. She remembered the second verse. | Bersama Sari kunyalakan tiga suar pasang. Ia ingat bait kedua. |
| Q_MQ4_S14_DONE | I passed the first sacred trial by putting out the Lampor on the reef. | Kulalui ujian suci pertama dengan memadamkan Lampor di karang. |
| Q_MQ4_S15_DONE | In the Gua Karang a wall of black water barred the way, and a bell rang once. | Di Gua Karang dinding air hitam menghalangi jalan, dan sebuah lonceng berbunyi sekali. |
| Q_MQ4_S16_DONE | Laras rang three sunken bells and the sea answered. The water gate sank. | Laras membunyikan tiga lonceng tenggelam dan laut menjawab. Gerbang air itu surut. |
| Q_MQ4_S17_DONE | I passed the second sacred trial, the abyssal current, without chasing victory. | Kulalui ujian suci kedua, arus palung, tanpa mengejar kemenangan. |
| Q_MQ4_S18_DONE | At the cliff shrine I heard the queen of the south told as one tale among many. | Di kuil tebing kudengar ratu selatan dituturkan sebagai satu kisah di antara banyak. |
| Q_MQ4_S19_DONE | I called Laras's name to the sea and made my offering. The causeway opened. | Kupanggil nama Laras ke laut dan memberi persembahanku. Jalan batu terbuka. |
| Q_MQ4_S20_DONE | I walked the sea causeway to the Sea Pavilion and rested. | Kususuri jalan batu laut ke Keraton Laut dan beristirahat. |
| Q_MQ4_S21_DONE | I passed the third sacred trial, the Waves, and the queen spoke once from far away. | Kulalui ujian suci ketiga, Ombak, dan sang ratu bicara sekali dari kejauhan. |
| Q_MQ4_S22_DONE | I wrote Ombak at the Sea Altar and received the Kain Hijau. The cave is open. | Kutulis Ombak di Altar Laut dan menerima Kain Hijau. Gua itu terbuka. |
| Q_MQ5_S1_DONE | At the Courtyard of Time I joined Ciung and Hariang, and together we broke the first shadow tide. | Di Pelataran Waktu kubergabung dengan Ciung dan Hariang, dan bersama kami mematahkan gelombang bayangan pertama. |
| Q_MQ5_S2_DONE | At the ancestors' stone I chose what would become of Aria Kebonan's name. | Di Batu Leluhur kutentukan apa yang terjadi pada nama Aria Kebonan. |
| Q_MQ5_S3_DONE | I parted the Eclipse veil with Ombak and fought into the cave mouth. | Kubelah tirai Gerhana dengan Ombak dan bertempur masuk ke mulut gua. |
| Q_MQ5_S4_DONE | I replayed the tag game and won back La. | Kuputar ulang kejar-kejaran dan merebut La. |
| Q_MQ5_S5_DONE | I shattered two time-wards on the Hourglass Sands. | Kuhancurkan dua penangkal waktu di Pasir Jam Pasir. |
| Q_MQ5_S6_DONE | In Hutan Lupa I silenced the trees that whisper stolen names. | Di Hutan Lupa kutenangkan pepohonan yang membisikkan nama curian. |
| Q_MQ5_S7_DONE | In the Abyss of Forgetting I replayed the two cups and won back Ra. | Di Jurang Lupa kuputar ulang dua cangkir dan merebut Ra. |
| Q_MQ5_S8_DONE | On the Shadow Bridge I beat the echoes of the legends I had faced. | Di Jembatan Bayang kukalahkan gema legenda yang pernah kuhadapi. |
| Q_MQ5_S9_DONE | At the last petilasan Semar kept his fire, and I replayed the written names and won back Sa. | Di petilasan terakhir Semar menjaga apinya, dan kuputar ulang nama-nama yang ditulis dan merebut Sa. |
| Q_MQ5_S10_DONE | Semar told the tale of Murwakala: Kala is hungry, not wicked. | Semar menceritakan Murwakala: Kala lapar, bukan jahat. |
| Q_MQ5_S11_DONE | I took the dalang's place at Semar's kelir and read the names, Sunda, Jawa and Ombak. | Kuambil tempat dalang di kelir Semar dan membacakan nama-nama: Sunda, Jawa, dan Ombak. |
| Q_MQ5_S12_DONE | Laras at the bottom of the dark forgot me, but her hand still wrote Ka, and she began to crack Kala's shadow. | Laras di dasar kegelapan melupakanku, tapi tangannya masih menulis Ka, dan ia mulai meretakkan bayangan Kala. |
| Q_MQ5_S13_DONE | I calmed Batara Kala with the Dawn Ruwatan while Laras broke his shield from inside. | Kutenangkan Batara Kala dengan Ruwatan Fajar sementara Laras memecahkan perisainya dari dalam. |
| Q_MQ5_S14_DONE | I wrote La-Ra-Sa, and Laras came home. | Kutuliskan La-Ra-Sa, dan Laras pulang. |

## 13. Codex (`codex.csv` and `data/codex/<id>.tres`)
**Entries: 53 codex rows.** Not part of the dialogue budget.
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
| banyan | The Banyan / Beringin | Old banyans (waringin) often stand at the heart of a Javanese or Sundanese village, and people greet them and leave offerings (**VERIFY**). Ki Waringin of Desa Purwa is a game character. | Beringin tua (waringin) kerap berdiri di jantung desa Jawa dan Sunda, dan orang menyapanya serta meletakkan sesaji (**VERIFY**). Ki Waringin di Desa Purwa adalah tokoh rekaan gim. | legend + game | — |
| maghrib | Maghrib / Maghrib | Maghrib is the sunset prayer time. Many Sundanese families call children indoors then, and some say a dusk spirit takes those still outside (**VERIFY**). The hamlet's oncor custom is the game's. | Maghrib adalah waktu salat saat matahari terbenam. Banyak keluarga Sunda memanggil anak pulang saat itu, dan sebagian berkata roh senja mengambil yang masih di luar (**VERIFY**). Kebiasaan oncor dusun itu rekaan gim. | legend + game | — |
| tangkuban_perahu | Tangkuban Parahu / Tangkuban Parahu | The name means "upturned boat". In the Sangkuriang tale the mountain is the boat he kicked over in rage (**VERIFY**). The game's Crater Seal sits on its rim. | Namanya berarti "perahu terbalik". Dalam kisah Sangkuriang gunung itu adalah perahu yang ia tendang karena murka (**VERIFY**). Segel Kawah gim ini berada di bibirnya. | legend + game | — |
| crater_seal | The Crater Seal / Segel Kawah | The first of the Four Great Seals: a stone on the crater rim that keeps Sangkuriang's night unfinished. Someone read it halfway, slowly, and it cracked. | Segel pertama dari Empat Segel Agung: batu di bibir kawah yang menjaga malam Sangkuriang tetap belum selesai. Seseorang membacanya separuh jalan, pelan-pelan, dan batu itu retak. | game | — |
| boeh_rarang | Boeh Rarang / Boeh Rarang | In some tellings, the white cloth Dayang Sumbi spread in the east to fake the dawn (**VERIFY**). In the game the Weaver's family has woven it for generations. | Dalam sebagian penuturan, kain putih yang dibentangkan Dayang Sumbi di timur untuk memalsukan fajar (**VERIFY**). Dalam gim, keluarga Penenun menenunnya turun-temurun. | legend + game | — |
| nyai_sekar | Nyai Sekar / Nyai Sekar | The palace archivist of Galuh, who scraped the king's lineage off thirty rolls and kept the shavings. A game character. The mirror-lamp cipher is the game's. | Juru arsip istana Galuh, yang mengerik silsilah raja dari tiga puluh gulung dan menyimpan serpihannya. Tokoh rekaan gim. Sandi lampu-cermin adalah rekaan gim. | game | — |
| kaputren | The Kaputren / Kaputren | The royal women's quarters of a palace (keputren in Javanese, **VERIFY** spelling and Sundanese usage). In the game it is where Laras was held and where the attendants talk. | Bagian istana tempat tinggal para perempuan keraton (keputren dalam bahasa Jawa, **VERIFY** ejaan dan pemakaian dalam bahasa Sunda). Dalam gim di sinilah Laras ditahan dan para dayang berbincang. | game | — |
| pasar_kuta | Pasar Kuta / Pasar Kuta | The outer market below Galuh's walls. Kuta means a fortress or walled town in old Javanese and Sundanese (**VERIFY**). The riggers and the wagon ledgers are the game's. | Pasar luar di bawah tembok Galuh. Kuta berarti benteng atau kota bertembok dalam bahasa Jawa dan Sunda kuno (**VERIFY**). Para pengatur curang dan daftar angkutan pedati adalah rekaan gim. | game | — |
| galuh | Galuh / Galuh | The kingdom of Galuh, shown here after the Karang Kamulyan site in Ciamis, West Java, linked to the Ciung Wanara legend (**VERIFY**). The square, the tournament ring and the palace layout are the game's. | Kerajaan Galuh, digambarkan mengikuti situs Karang Kamulyan di Ciamis, Jawa Barat, yang dikaitkan dengan legenda Ciung Wanara (**VERIFY**). Alun-alun, gelanggang, dan tata istana adalah rekaan gim. | legend | — |
| pamali_cage | The Iron Cage / Kandang Besi | In the legend Ciung Wanara shut the false king and his queen in an iron cage (**VERIFY**). The game keeps the cage and adds that the cage holds a man, not a name. | Dalam legenda Ciung Wanara mengurung raja palsu dan permaisurinya dalam kandang besi (**VERIFY**). Gim mempertahankan kandang itu dan menambahkan bahwa kandang menahan orang, bukan nama. | legend | — |
| ranga | Ranga / Ranga | A faceless captain who remembered his name by humming along to Laras's Ka. A game character; the faceless are people whose names were taken. | Kapten tanpa rupa yang mengingat namanya dengan ikut bersenandung bersama Ka Laras. Tokoh rekaan gim; para tanpa rupa adalah orang yang namanya diambil. | game | — |
| nyai_gendhis | Nyai Gendhis / Nyai Gendhis | Leader of the lesung women of the Mataram foothills. A lesung is a rice mortar and the alu its pestle, pounded in rhythm in village tradition (**VERIFY**). A game character. | Pemimpin perempuan lesung di kaki bukit Mataram. Lesung adalah lumpang padi dan alu penumbuknya, ditumbuk berirama dalam tradisi desa (**VERIFY**). Tokoh rekaan gim. | game | — |
| bandung_bondowoso | Bandung Bondowoso / Bandung Bondowoso | In the Prambanan tale he is asked to raise a thousand temples in one night, and the faked dawn leaves him one short (**VERIFY**). In the game his night-curse is calmed by a true dawn, never killed. | Dalam kisah Prambanan ia diminta membangun seribu candi dalam semalam, dan fajar palsu membuatnya kurang satu (**VERIFY**). Dalam gim kutukan malamnya ditenangkan oleh fajar yang sungguhan, tak pernah dibunuh. | legend | Ca on the lesung beat cracks his pillars. / Ca pada irama lesung memecahkan pilarnya. |
| buto_ijo | Buto Ijo / Buto Ijo | In the Timun Mas tale, a green giant is promised a child by a lonely woman and chases the girl, who throws four pouches to escape (**VERIFY**: seeds, needles, salt, terasi). Here the waking curse drove him mad, and he stalks the savanna. | Dalam kisah Timun Mas, raksasa hijau dijanjikan seorang anak oleh perempuan kesepian dan mengejar gadis itu, yang melempar empat bungkusan untuk lolos (**VERIFY**: biji, jarum, garam, terasi). Di sini kutukan yang bangkit membuatnya gila, dan ia mengintai sabana. | legend | Brambles slow his charge; the four pouches break each of his phases. / Semak berduri memperlambat terjangannya; keempat bungkusan memutus tiap fasenya. |
| keris_gandring | The Keris of Mpu Gandring / Keris Mpu Gandring | In the legend, the smith Mpu Gandring was killed over a keris not yet finished, and cursed it (**VERIFY**: its victims and the number of generations). The seven smiths who tended it, their stakes and Wirasana's line are the game's. | Dalam legenda, empu Mpu Gandring dibunuh karena keris yang belum selesai, dan ia mengutuknya (**VERIFY**: korban dan jumlah turunannya). Tujuh empu yang merawatnya, tonggak-tonggaknya, dan garis keluarga Wirasana adalah rekaan gim. | legend | Ha settles a curse mark; calm it, don't break it. / Ha melunasi tanda kutukan; tenangkan, jangan patahkan. |
| three_trials | The Three Sacred Trials / Tiga Ujian Suci | The coast tells of the reef, the cave and the pavilion as places where the sea tests a visitor's manners (**VERIFY**: any such tradition). The three trials named here (torches, current, waves) are the game's. | Pesisir bercerita tentang karang, gua dan keraton sebagai tempat laut menguji tata krama tamu (**VERIFY**: adakah tradisi seperti itu). Tiga ujian yang disebut di sini (obor, arus, ombak) adalah rekaan gim. | game | — |
| batara_kala | Batara Kala / Batara Kala | In Javanese and Sundanese belief a god of time and devouring, born hungry, who may eat those born on an unlucky day (**VERIFY**). In the game he is calmed and turned back by the ruwatan, never killed. | Dalam kepercayaan Jawa dan Sunda, dewa waktu dan pelahap, lahir lapar, yang boleh memakan mereka yang lahir pada hari tak baik (**VERIFY**). Dalam permainan ia ditenangkan dan dibalikkan lewat ruwatan, tak pernah dibunuh. | legend | Sunda, then Jawa, then Ombak. / Sunda, lalu Jawa, lalu Ombak. |
| murwakala | Murwakala / Murwakala | The tale told at a ruwatan: Kala asks his father for food, and a dalang's words and the child's name turn him back (**VERIFY**: the details of the lakon vary between tellings). | Kisah yang dituturkan pada ruwatan: Kala meminta makanan pada ayahnya, dan kata-kata dalang serta nama si anak membalikkannya (**VERIFY**: rincian lakon berbeda antarpenuturan). | legend | — |
| ancestors_stone | The Ancestors' Stone / Batu Leluhur | A black stone at the Courtyard of Time where Galuh and Mataram carved the names of their dead. One space in the middle was never carved. It is the game's. | Batu hitam di Pelataran Waktu tempat Galuh dan Mataram memahat nama orang-orang mereka yang telah tiada. Satu ruang di tengahnya tak pernah dipahat. Ini rekaan permainan. | game | — |
| deserter_name | The Deserter's Name / Nama si Pembelot | A cell in Galuh goes quiet, or a man stands beside you. The name Ranga is written, the sounds Ra and Nga at last in one place. | Sebuah sel di Galuh menjadi sunyi, atau seorang lelaki berdiri di sampingmu. Nama Ranga tertulis, bunyi Ra dan Nga akhirnya berada di satu tempat. | game | — |
| ciung_egg | The Egg in the Basket / Telur di Keranjang | In the tale, Ciung Wanara was set adrift on a river as a baby, with an egg that hatched into his rooster. In the game an old servant tied a wooden charm to that basket (**VERIFY** the legend's part, the servant is the game's own). | Dalam kisahnya, Ciung Wanara dihanyutkan di sungai sebagai bayi, dengan sebutir telur yang menetas menjadi ayam jagonya. Dalam permainan ini seorang abdi tua mengikatkan bandul kayu pada keranjang itu (**VERIFY** bagian legenda; abdi itu rekaan permainan). | legend | — |
| kabayan | Si Kabayan / Si Kabayan | A lazy but clever man in Sundanese folk tales, who beats the proud with their own words (**VERIFY** the tale used). | Lelaki malas tapi cerdik dalam cerita rakyat Sunda, yang mengalahkan si sombong dengan kata-katanya sendiri (**VERIFY** kisah yang dipakai). | legend | — |
| ririwa | Ririwa / Ririwa | A ghost that keeps doing its old chore until someone remembers its name (**VERIFY** the Sundanese term). In the game the servant Canga is remembered by writing his name, or driven off. | Hantu yang terus mengerjakan tugas lamanya sampai ada yang mengingat namanya (**VERIFY** istilah Sunda). Dalam permainan, pelayan Canga diingat dengan menuliskan namanya, atau diusir. | legend | — |
| pangrenyep_letter | The Queen's Letter / Surat Sang Permaisuri | A mother's reply across the river: a short letter sealed with her own ring, wording that depends on the judgment given at the Pamali. | Balasan seorang ibu dari seberang sungai: surat pendek bersegel cincinnya sendiri, dengan kata-kata yang bergantung pada keputusan di Pamali. | game | — |

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

### Story v5 changes (2026-11-06)
Per act, the keys the v5 rewrite dropped or re-texted. Same rule: a key leaves the CSV only when nothing references it.

**Prologue and Act I.**
No key that script.md v4 defines for the Prologue or Act I is removed: every old key keeps its place or keeps its key with changed text. Four stale keys sit in `data/text/dialogue.csv` but were never in script.md and no `.tres` references them (checked with grep); they are old pre-v4 beat and talk lines that v5's Choice 1 and the Naganingrum talk replace. Add them to the section 14 list:

- `BEAT_NAGA`: 3B, 5B
- `DLG_NAGANINGRUM`: V2B
- `DLG_SUNDA_ELDER`: V2B

(`DLG_SEMAR_V4B` is also CSV-only; it is outside this fragment's keys, so the Semar owner may drop it.) The v4 `Q_MQ0_S5_HINT` stays dropped.

The CSV rows `BEAT_NAGA_H1` and `CLUE_LARAS_RIBBON_SPOT_1` also exist with different old text; this fragment's text replaces them.

Keys that keep their key but change their text or place (so a merger must not treat them as dropped, and the CSV row must be updated, not deleted): `BEAT_TAG_CAT_4` (the "Ayo, sumur!" moved to the new `BEAT_TAG_CAT_7`), `DLG_SEMAR_V32` (now points to Cepot, not the market), `DLG_SEMAR_V33` (the lontar table, not the market), `BEAT_LONTAR_NAMES_4` (now points to the lamps, not the market), `DLG_PURWA_OLD_COUPLE_V3` (the tree is "far west, past the pond"), `DLG_SUNDA_GRANDSON_V3` (now points to the elder and the road), `DLG_CEPOT_11` (one "!" less, since the hero's face is now known), `DLG_CEPOT_P1` and `_P2` (the entry is no longer quiet). Entry-level changes: the old `semar` entry 6 (practice) is now the hub `H2` and keeps `DLG_SEMAR_V7` as its intro; the old `ibu` entry 6 and 7 are unchanged; the old `purwa_stall` cond `step:mq0=2`, `flag:mq0_d5` becomes `step:mq0=3`.

**Acts II and III.**
- `CHOICE_DESERTER`: 1, 2
- `CHOICE_MERCY`: 1, 2
- `DLG_CIUNG_WANARA`: V9
- `DLG_LARAS_WALL`: H1
- `DLG_LENGSER`: V2
- `DLG_LESUNG_WOMEN`: V3
- `DLG_MATARAM_DALANG`: V3

**Act IV, Interlude and Act V.**
Old v4 keys of this range that this fragment no longer uses (each leaves the CSV only after a grep finds no other reference):
- `DLG_TIMUR_EMPU_V7` (replaced by the lesson entry), `DLG_ASH_TRAIL_H1` (now `CLUE_ASH_TRAIL_1`), `BEAT_QUIET_HOUSE_S2` (v4 `choice_silent` branch, now `BEAT_QUIET_HOUSE_J2`).
- `DLG_MBOK_SRINI_V4` text is kept but changed ("eastern field" lines gone); `DLG_MBOK_SRINI_V1` and `DLG_MBOK_SRINI_V2` changed text (the banyan replaces the eastern field).
- `DLG_TIMUR_EMPU_V2`, `DLG_TIMUR_EMPU_V3` changed text (seventh generation; practice in the yard); `DLG_TIMUR_EMPU_V6` changed text (Mbok Srini).
- Old `NPC_KIDUL_SARI_NAME` text "Nenek Sari" and `DLG_KIDUL_SARI_1` (grandmother who sang the verse); `DLG_KIDUL_SARI_2` is kept as the fallback.
- Old `DLG_CLIFF_ALTAR_1` (replaced by `DLG_CLIFF_ALTAR_V1`...) and the old choice texts of `CHOICE_OFFER_MEMORY` / `CHOICE_OFFER_SONG` (same keys, new text).
- The retired step references: all v4 `step:mq3=n` and `step:mq4=n` conds in sections 9 and 10 (renumbered), and `flag:choice_silent` (now `flag:choice_judgment`).

**Act VI and Epilogue.**
Old v4 keys of the Act VI and Epilogue text that this fragment replaces. Each leaves the CSV only when a grep of `data/`, `ui/`, `entities/`, `zones/`, `autoload/` and `tests/` finds no other reference.
- `BEAT_MOUTH_1` to `BEAT_MOUTH_4` (beat `mouth` and `mouth_freed`; the two brothers now hold `gk_pelataran`, and their lines moved into `BEAT_PELATARAN_*` and `DLG_FACELESS_DESERTER_V401`).
- `DLG_HARIANG_BANGA_V3` (the cave mouth line, replaced by `DLG_HARIANG_BANGA_V401` to `V418`).
- `DLG_DESERTER_MOUTH_V1` and `DLG_DESERTER_MOUTH_V2` (replaced by the `faceless_deserter` Gua Kala entries; the spot `deserter_mouth` in `gk_mulut` goes).
- `Q_MQ5_S1_OBJ` to `S9_OBJ` and `Q_MQ5_S1_DONE` to `S9_DONE` get new text and `S10` to `S14` are new (re-keyed, not dropped).
- The v4 entries of the Epilogue (`EPILOGUE_1` to `EPILOGUE_7`, `EPILOGUE_3_ALT` to `EPILOGUE_5_ALT`) are re-keyed: every key still exists, with new text on the same names (`EPILOGUE_8` and `EPILOGUE_1_ALT`, `_2_ALT`, `_6_ALT` are new). The v4 variant `choice_silent` is retired.
- `GAP_LA_END_P`, `GAP_LA_END_1` to `_3` change text only (the third gap is Laras's laugh); `CLUE_LETTER_*`, `MEM_GAP_LA_2` and the other new keys are additions.

**Side stories.**
Old v4d keys of section 15 that this rewrite no longer uses (each leaves the CSV only when a grep of `data/`, `ui/`, `entities/`, `zones/`, `autoload/` and `tests/` finds no other reference):
- `DLG_KI_DARSA`: V22 (the iket line moved to Purbasari V24).
- `CLUE_S2_CEMPAKA`: 1, 2, NOTE and `CLUE_S2_WHITE_CLOTH`: 1, 2, NOTE (replaced by `CLUE_S2_GRAVE_*` and `CLUE_S2_CLOTH_*`, the v5 clue ids).
- `CLUE_G1_DECREE`: 1, 2, NOTE and `CLUE_G1_BASKET`: 1, 2, NOTE (replaced by `CLUE_G1_DEBT_LEDGER_*` and `CLUE_G1_PALM_SACK_*`).
- `DLG_GALUH_OFFICIAL`: none dropped (V20 to V22 moved into the Kabayan finale, V23 kept).
- `DLG_GALUH_QUEEN`: V22, V23 text changed from the retired `choice_silent` reply to the `choice_judgment` reply (same keys, new text).
- `CLUE_C3_ROAD_MARK` and `CLUE_C3_SHORE_NET` (and their `B` keys): same keys, text changed (shield mark, driftwood charm).
- The old `### Errand check` and `### Replaced keys` notes of v4d are not carried over; the errands (S3, S4, M4, T3, T4, K1) now have lines above.
- `DLG_ANGKLUNG_LEADER_1` to `_13`, `DLG_MATARAM_DALANG_8` to `_15` (old csv-only errand lines) and `DLG_KEPANG_LEADER_1` to `_8`, `DLG_TIMUR_EMPU_12` to `_22`: replaced by the `V20+`/`V30+`/`V500+` keys above where the errands are concerned.

## 15. Side stories (v5: four templates, 20 quests and the hub meta quests)
Lines for the cards in [quests.md](quests.md) section 5 and the hub cards in section 6. Same format as sections 6 to 10: an NPC heading gives its `.tres` id, an `Entry | if | do` table (a fourth column `choices` where a hub or choice is used), then `Key | ID | EN`. A bare `@` row is narration; `@NPC_X_NAME` rows switch speaker. Clue keys are `CLUE_<ID>_1`, `_2`, `_NOTE`; hunt titles `HUNT_<ID>_TITLE`; memory keys `MEM_<ID>_TITLE/_IN/_HINT/_1..n/_OUT`.

**Conventions for this section.**
- **Step conds are 0-based** and follow the cards: `step:sq_s1=3` is the 4th step of SQ-S1. A card's step (1) is `=0`. The giver's first talk starts the quest (`start:<id>` in its `do`) and its `talked_to` completes step `=0`.
- **Branch flags are ASSUMED:** `sq_<id>_peaceful` and `sq_<id>_fight`, set by the branch step (G2, M2, M3, T1). The `alt` step is index 3, the report is index 4.
- **Reward grants** in a `do` (`lakon:<id>`, `codex:<id>`) go on the final entry of a quest. Items, Ilmu and the Flask Shards come from the QuestData reward, not from a line.
- **Rule 10 (a clue names a creature only where its card says so):** S2 `_CLOTH_2`, G2 `_ROLL_2`, M2 `_TOY_2`, M3 `_BEANS_2`, T1 `_CLAW_MARKS_2`, T2 `_CAMPFIRE_2`. Before that the hook text speaks of "the crying", "the sweeping", "the tearing". K2 names the white crocodile only through Mbah Wiryo's line. No spoken text uses a cut name.
- **Hub shape (quests.md 7.1 item 2, shown once at Ki Darsa below).** A hub entry carries `"hub": true` in its `do`; its `choices` are `CHOICE_<NPC>_ASK_<n>` with `do` `topic:<key>`, plus a leave choice with an empty `do`. Each topic is its own entry with `"topic": "<key>"` and `"quiet": true` in its `do` and 3 to 6 lines. After a topic the choice list re-opens until the player picks the leave choice. A hub never advances a quest step.
- **Key ranges.** Shared NPCs (`semar, ibu, laras, cepot, ciung_wanara, hariang_banga, lengser, faceless_deserter, aria_kebonan, naganingrum, mataram_dalang, kidul_jurukunci`) use `V500` to `V599` and `H500` to `H599` here; their older side keys (V20 to V37 and so on) are kept where a line still fits. Other NPCs continue the `V20+` side numbering. Where a main-path act may also add entries for the same NPC (`sunda_grandson`, `timur_empu`), the side entries start at `V30`.
- **Entry placement.** Side entries for an NPC with main-path entries go after the main-path entries and before the last `(none)` entry, as v4d did.

### Tatar Sunda

### SQ-S1 "Lutung Kasarung" (retelling, M)
Card: giver Ki Darsa and Purbasari (zone docs place Ki Darsa on the kampung plaza; the lines work wherever he sits). Steps 0 talk, 1 `clue_examined:s1_offerings` and `s1_spring`, 2 `memory_done:sq_s1_lutung`, 3 `area_cleared:s1_spring_guardians`, 4 `talked_to:purbasari`.
#### ki_darsa (the juru pantun; name NPC_KI_DARSA_NAME; replace all entries)
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `quest:sq_s1=done` | `"hub": true` | CHOICE_KI_DARSA_ASK_1 to `topic:lutung`; CHOICE_KI_DARSA_ASK_2 to `topic:kakak`; CHOICE_KI_DARSA_ASK_3 to `topic:pantun`; CHOICE_KI_DARSA_ASK_4 (leave) |
| topic lutung | `"topic": "lutung"` | `"quiet": true` | |
| topic kakak | `"topic": "kakak"` | `"quiet": true` | |
| topic pantun | `"topic": "pantun"` | `"quiet": true` | |
| 2 | `step:sq_s1=3` | | |
| 3 | `quest:sq_s1=active` | | |
| 4 | `quest:sq_s1=available`, `flag:mq1_3` | `start:sq_s1` | |
| 5 | (none) | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KI_DARSA_V20 | Kulit gadis itu pulih. Ia sendiri tertawa, lama sekali. | The girl's skin is healed. She laughed, for a long time. |
| 1 | DLG_KI_DARSA_V21 | Si lutung hitam itu sebenarnya makhluk surgawi yang menyamar. Wajah pinjaman, Nak. Begitu kisahnya. | The black langur was a heavenly being in disguise. A borrowed face, child. So the tale goes. |
| 1 | DLG_KI_DARSA_V30 | Duduklah. Mau dengar sisi cerita yang tak masuk pantunku? | Sit down. Want to hear the sides of the tale that never made it into my pantun? |
| topic lutung | DLG_KI_DARSA_V31 | Dalam kisahnya ia Guruminda, dewa muda yang dihukum turun ke bumi dalam rupa lutung. | In the tale he is Guruminda, a young god sent down to earth in a langur's shape. |
| topic lutung | DLG_KI_DARSA_V32 | Hukuman itu ujian. Ia harus dilihat dari perbuatannya, bukan dari bulunya. | The punishment was a test. He had to be seen by his deeds, not by his fur. |
| topic lutung | @NPC_HERO_NAME | | |
| topic lutung | DLG_KI_DARSA_H21 | Dan hanya Purbasari, sang putri, yang melihatnya. | And only Purbasari, the princess, saw it. |
| topic lutung | @NPC_KI_DARSA_NAME | | |
| topic lutung | DLG_KI_DARSA_V33 | Kau cepat belajar. Kisah ini bukan tentang lutung. Ini tentang siapa yang mau melihat. | You learn fast. This tale isn't about a langur. It's about who is willing to look. |
| topic kakak | DLG_KI_DARSA_V34 | Purbararang, kakak Purbasari. Ada penuturan yang menjadikannya pengutuk adiknya. | Purbararang, Purbasari's older sister. Some tellings make her the one who cursed her. |
| topic kakak | DLG_KI_DARSA_V35 | Penuturan lain hanya menyebutnya iri, dan iri itu tumbuh jadi perbuatan. | Other tellings only call her jealous, and the jealousy grew into deeds. |
| topic kakak | @NPC_HERO_NAME | | |
| topic kakak | DLG_KI_DARSA_H22 | Yang mana yang benar? | Which one is true? |
| topic kakak | @NPC_KI_DARSA_NAME | | |
| topic kakak | DLG_KI_DARSA_V36 | Keduanya, mungkin. Karena itu kisahnya awet. Pendengar memilih yang dibawa pulang. | Both, maybe. That's why the tale lasts. The listener chooses which to carry home. |
| topic pantun | DLG_KI_DARSA_V37 | Pantun dinyanyikan sambil duduk, diiringi kecapi, semalam suntuk kalau pendengarnya betah. | A pantun is sung sitting down, with a kecapi, all night if the listeners stay. |
| topic pantun | DLG_KI_DARSA_V38 | Selama senar kecapi masih bergetar, kisahnya tak boleh putus. Itu janji juru pantun. | As long as the kecapi strings hum, the tale may not break. That's a juru pantun's promise. |
| topic pantun | DLG_KI_DARSA_V39 | Kudengar ada murid dalang yang berani mengubah akhir kisah. Semoga itu kau. | I hear a dalang's apprentice has been daring to change endings. I hope it's you. |
| 2 | DLG_KI_DARSA_V28 | Sosok-sosok pucat itu menjaga mata air, tapi mereka tak jahat. Mereka lupa untuk siapa mereka berjaga. | The pale figures guard the spring, but they aren't wicked. They forgot who they guard it for. |
| 2 | DLG_KI_DARSA_V29 | Bersihkan mereka, dan alirkan lagi airnya. Gadis itu menunggu di sana. | Clear them, and let the water run again. The girl waits there. |
| 3 | DLG_KI_DARSA_V23 | Sumber air itu tersembunyi. Dan jangan lupa persembahannya di depan pintu. | The spring is hidden. And don't forget the offerings at her door. |
| 4 | DLG_KI_DARSA_V24 | Salam, Nak. Aku Ki Darsa, juru pantun. Kubawa kecapiku dari desa ke desa, menyanyikan kisah lama. | Greetings, child. I'm Ki Darsa, a juru pantun. I carry my kecapi from village to village, singing old tales. |
| 4 | DLG_KI_DARSA_V25 | Di tepi hutan ada gadis berkulit belang. Seekor lutung hitam menolak pergi dari sisinya. Ia tak mengusirnya. | At the forest's edge lives a girl with spotted skin. A black langur won't leave her side. She doesn't chase him off. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_KI_DARSA_H20 | Katanya ia dikutuk? | They say she's cursed? |
| 4 | @NPC_KI_DARSA_NAME | | |
| 4 | DLG_KI_DARSA_V40 | Orang bilang begitu. Tapi lutung itu menaruh buah di depan pintunya tiap pagi, dan tak pernah mengetuk. | So people say. But that langur leaves fruit at her door every morning, and never knocks. |
| 4 | DLG_KI_DARSA_V26 | Lihat persembahan di depan pintunya, lalu cari sumber air yang tersembunyi. | See the offerings at her door, then find the hidden spring. |
| 5 | DLG_KI_DARSA_V27 | Kisah lama itu masih ada. Aku hanya menyanyikannya. | The old tales are still here. I only sing them. |

| Key | ID | EN |
|-----|----|----|
| CHOICE_KI_DARSA_ASK_1 | Kenapa lutung itu menyamar? | Why did the langur wear that face? |
| CHOICE_KI_DARSA_ASK_2 | Bagaimana dengan kakaknya? | What about her sister? |
| CHOICE_KI_DARSA_ASK_3 | Bagaimana juru pantun bernyanyi? | How does a juru pantun sing? |
| CHOICE_KI_DARSA_ASK_4 | Cukup, terima kasih. | That's enough, thank you. |

VERIFY: the juru pantun role and the kecapi, the cure by bathing, the names Purbasari, Purbararang and Guruminda, and that tellings differ on the sister's part.

#### Clues S1 (hunt `HUNT_SQ_S1_TITLE`; `s1_offerings` and `s1_spring`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_S1_TITLE | Lutung Kasarung | Lutung Kasarung |
| CLUE_S1_OFFERINGS_1 | Buah liar dan bunga tertata rapi di ambang pintu. Ada jejak tangan berbulu hitam di tanah. | Wild fruit and flowers lie neatly on the doorstep. A black furry handprint is pressed in the dirt. |
| CLUE_S1_OFFERINGS_2 | Seseorang meninggalkannya tiap pagi, tanpa pernah mengetuk. | Someone leaves them every morning, and never knocks. |
| CLUE_S1_OFFERINGS_NOTE | Persembahan di pintu gadis itu, dari tangan berbulu. | Offerings at the girl's door, from a furry hand. |
| CLUE_S1_SPRING_1 | Mata air jernih di balik semak, tapi sosok-sosok pucat berkerumun di sekelilingnya. | A clear spring behind the bushes, but pale figures crowd around it. |
| CLUE_S1_SPRING_2 | Air ini pasti menyembuhkan sesuatu. Para sosok itu tak ingin ada yang sampai ke sini. | This water must heal something. The figures don't want anyone to reach it. |
| CLUE_S1_SPRING_NOTE | Mata air tersembunyi, dijaga sosok-sosok pucat. | A hidden spring, guarded by pale figures. |

#### Purbasari (at the spring; name NPC_PURBASARI_NAME; step 4 (0-based), `talked_to:purbasari`)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_s1=4` | `lakon:lutung_kasarung` |
| 2 | `quest:sq_s1=active` | |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_PURBASARI_V20 | Airnya hangat. Lihat, kulitku... | The water is warm. Look, my skin... |
| 1 | DLG_PURBASARI_V21 | Lutung itu menuntunku ke sini. Ia selalu tahu jalan. | The langur led me here. He always knew the way. |
| 1 | DLG_PURBASARI_V22 | Aku tak pernah mengusirnya. Aku merasa ia bukan hanya seekor lutung. | I never sent him away. I felt he was more than a langur. |
| 1 | DLG_PURBASARI_V24 | Ki Darsa menitipkan iket ini. Katanya cocok untuk orang yang mau melihat wajah sebenarnya. | Ki Darsa left this iket for you. He says it suits someone who looks for the true face. |
| 2 | DLG_PURBASARI_V25 | Aku tinggal di sini sejak orang berhenti menyapaku. Tapi persembahan itu tak pernah berhenti. | I've lived here since people stopped greeting me. But the offerings never stopped. |
| 2 | DLG_PURBASARI_V26 | Kalau kau menemukan mata airnya, singkirkan penjaganya dulu. Mereka tak mau melukaimu, hanya tak mau dilewati. | If you find the spring, clear its guardians first. They don't want to hurt you, only to not be passed. |
| 3 | DLG_PURBASARI_V23 | Terima kasih, Nak. Sekarang aku bisa pulang. | Thank you, child. Now I can go home. |

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

### SQ-S2 "Tangis di Rumpun Bambu" / "Crying in the Bamboo" (Kuntilanak two-way hunt, L)
Card: giver `kepala_desa` in `ts_kampung`. Steps 0 talk, 1 `clue_examined:s2_grave` and `s2_cloth`, 2 `memory_done:sq_s2_grandmother`, 3 `enemy_killed:kuntilanak_elite`, 4 carve the name with the village head. The card names no write id: **ASSUMED** `name_written:s2_grave_name`, card `write:s2_grave_name:sunda_ga,sunda_nga` (the name Ganga, **ASSUMED**; Ga is known from 1.3 and Nga from 1.7). The quest ends on the write; the closing talk is entry 1.
#### kepala_desa (the village; name NPC_KEPALA_DESA_NAME; replace the side-quest entries)
| Entry | if | do |
|-------|----|----|
| 1 | `name_written:s2_grave_name` | `flag:s2_named` |
| 2 | `step:sq_s2=4`, `!flag:name_s2_grave_name` | `write:s2_grave_name:sunda_ga,sunda_nga`, `flag:name_s2_grave_name` |
| 3 | `step:sq_s2=3` | |
| 4 | `quest:sq_s2=active` | |
| 5 | `quest:sq_s2=available`, `flag:mq1_3` | `start:sq_s2` |
| 6 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KEPALA_DESA_V20 | Rumpun itu senyap. Namanya sudah terukir di batu, supaya yang tidur di sana tahu ia dikenang. | The grove is quiet. Her name is cut into the stone, so the one who sleeps there knows she is remembered. |
| 1 | DLG_KEPALA_DESA_V21 | Terimalah golok dan kantong ramuan ini. Kau pantas membawanya. | Take this golok and herb pouch. You've earned them. |
| 2 | DLG_KEPALA_DESA_V27 | Nenekku bilang perempuan itu dikubur tanpa nisan, karena tak seorang pun mau mengaku keluarganya. Namanya Ganga. | My grandmother said the woman was buried without a marker, because nobody would claim her. Her name was Ganga. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_KEPALA_DESA_H21 | Dua bunyi, Ga dan Nga. Aku bisa menuliskannya. | Two sounds, Ga and Nga. I can write it. |
| 2 | @NPC_KEPALA_DESA_NAME | | |
| 2 | DLG_KEPALA_DESA_V28 | Ukirlah di batu penanda itu. Aku yang memegang lampunya. | Carve it on the marker stone. I'll hold the lamp. |
| 3 | DLG_KEPALA_DESA_V29 | Ia menangis karena tak ada yang memanggil namanya. Berdirilah di tanah terang, seperti nenek dalam ingatan itu. | She cries because nobody calls her name. Stand on lit ground, like the grandmother in that memory. |
| 4 | DLG_KEPALA_DESA_V22 | Wangi kembang di kuburan tanpa nama. Kain putih di bambu. Itu petunjukku. | The flower scent at a grave with no name. A white cloth on the bamboo. Those are my clues. |
| 5 | DLG_KEPALA_DESA_V23 | Di rumpun bambu itu ada tangis bayi tiap malam. Padahal tak ada rumah di sana. | In the bamboo grove a baby cries every night. And no house stands there. |
| 5 | DLG_KEPALA_DESA_V24 | Aku tak berani mendekat. Kau? | I don't dare go near. Will you? |
| 5 | DLG_KEPALA_DESA_V25 | Cium wangi kembang di kuburan tanpa nama, dan periksa kain putih di bambu. | Smell the flower scent at the unmarked grave, and check the white cloth on the bamboo. |
| 6 | DLG_KEPALA_DESA_V26 | Desa ini tenang. Biarlah begitu. | The village is calm. Let it stay that way. |

#### Clues S2 (hunt `HUNT_SQ_S2_TITLE`; `s2_grave` and `s2_cloth`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_S2_TITLE | Tangis di Rumpun Bambu | Crying in the Bamboo |
| CLUE_S2_GRAVE_1 | Wangi cempaka pekat di atas gundukan tanah tanpa nisan. Tak ada yang menanamnya. | A heavy cempaka scent hangs over a mound with no marker. Nobody planted any. |
| CLUE_S2_GRAVE_2 | Seseorang dikubur di sini tanpa nama. Tangisnya tetap tinggal. | Someone was buried here without a name. The crying stayed behind. |
| CLUE_S2_GRAVE_NOTE | Gundukan tanpa nisan, berbau cempaka. | A mound with no marker, smelling of cempaka. |
| CLUE_S2_CLOTH_1 | Kain putih sobek tersangkut di bambu, setinggi dua orang berdiri. Ujungnya masih basah. | A torn white cloth snags on the bamboo, two people high. The hem is still wet. |
| CLUE_S2_CLOTH_2 | Ini kuntilanak, hantu perempuan berbaju putih yang menangis seperti bayi untuk memancing orang. | This is a kuntilanak, a ghost in white who cries like a baby to lure people. |
| CLUE_S2_CLOTH_NOTE | Kain putih di bambu: kuntilanak. | A white cloth on the bamboo: a kuntilanak. |

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

### SQ-S3 "Nada Angklung yang Hilang" / "The Lost Angklung Notes" (craft and harmony puzzle, M)
Card: giver `sunda_grandson` in `ts_kebun` (zone docs also name the `angklung_leader` at the kampung plaza; both are written, the grandson starts it and the leader runs the pavilion). Unlock `mq1_1`. Steps 0 recover 3 resonant tubes (**ASSUMED** `item_picked:angklung_1` to `angklung_3`; the map has five pickups, only three count), 1 arrange the pentatonic scale at the kampung pavilion (**ASSUMED** `puzzle_solved:s3_scale`), 2 play the harmony with the villagers (**ASSUMED** `area_entered:s3_harmony`, the beat). The card lists no clue ids; the two `clue` pieces are the sparkle pickups.
#### sunda_grandson (ts_kebun; name NPC_SUNDA_GRANDSON_NAME; side entries after the main-path entries)
| Entry | if | do |
|-------|----|----|
| s3_done | `quest:sq_s3=done` | |
| s3_wait | `quest:sq_s3=active` | |
| s3_hook | `quest:sq_s3=available`, `flag:mq1_1` | `start:sq_s3` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| s3_done | DLG_SUNDA_GRANDSON_V30 | Dengar? Itu nada kakekku. Ia menangis waktu kami main, tapi bilang itu debu. | Hear that? That's my grandfather's note. He cried when we played, and said it was dust. |
| s3_done | DLG_SUNDA_GRANDSON_V31 | Satu bambu, satu nada. Sekarang kampung ini tahu lagu itu lagi. | One bamboo, one note. Now the kampung knows that tune again. |
| s3_wait | DLG_SUNDA_GRANDSON_V32 | Tiga ruas bambu bernada, ingat. Satu di kebun, satu di kampung, satu di sawah. Cari yang berkilau. | Three tuned bamboo tubes, remember. One in the gardens, one in the kampung, one in the terraces. Look for a glint. |
| s3_wait | DLG_SUNDA_GRANDSON_V33 | Kalau sudah lengkap, bawa ke paviliun kampung. Pemimpin angklung menunggu di sana. | When you have them all, take them to the kampung pavilion. The angklung leader waits there. |
| s3_hook | DLG_SUNDA_GRANDSON_V34 | Kau lihat para topeng lewat kemarin? Mereka menyepak keranjang angklung kami sampai berhamburan. | Did you see the masks pass yesterday? They kicked our angklung basket until it scattered. |
| s3_hook | DLG_SUNDA_GRANDSON_V35 | Tiga ruas bambu bernada hilang. Tanpa itu, angklung kami cuma bunyi, bukan lagu. | Three tuned tubes are missing. Without them, our angklung is just noise, not a tune. |
| s3_hook | @NPC_HERO_NAME | | |
| s3_hook | DLG_SUNDA_GRANDSON_H30 | Di mana terakhir kau melihatnya? | Where did you last see them? |
| s3_hook | @NPC_SUNDA_GRANDSON_NAME | | |
| s3_hook | DLG_SUNDA_GRANDSON_V36 | Terlempar ke kebun, ke kampung, dan ke sawah. Bambu yang bernada berkilau kalau kau dekat. Tolong, ya? | Thrown into the gardens, the kampung and the terraces. A tuned bamboo glints when you're near. Please? |

#### angklung_leader (the kampung pavilion; name NPC_ANGKLUNG_LEADER_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:sq_s3=done` | |
| 2 | `step:sq_s3=2` | |
| 3 | `step:sq_s3=1` | |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_ANGKLUNG_LEADER_V24 | Kelompok kami main lagi berkatmu. Dan Flask Shard itu, simpanlah, tanda terima kasih dari lembah. | Our group plays again thanks to you. And that flask shard is yours, a thank-you from the valley. |
| 2 | DLG_ANGKLUNG_LEADER_V20 | Ketiganya sudah kembali! Berdirilah, semua orang. Kita main bersama. | All three are back! Stand up, everyone. We play together. |
| 2 | DLG_ANGKLUNG_LEADER_V21 | Satu orang, satu angklung, satu nada. Tak ada yang boleh main sendirian. | One person, one angklung, one note. Nobody gets to play alone. |
| 3 | DLG_ANGKLUNG_LEADER_V22 | Susunlah nadanya dari rendah ke tinggi, lima saja. Telingamu yang menentukan, bukan mataku. | Set the notes from low to high, five only. Your ears decide, not my eyes. |
| 3 | DLG_ANGKLUNG_LEADER_V23 | Kalau salah, bambunya akan meringis. Kau akan tahu. | If it's wrong, the bamboo will wince. You'll know. |
| 4 | DLG_ANGKLUNG_LEADER_V25 | Kami kelompok angklung kampung. Sayang, sekarang tak ada nada yang cukup untuk bermain. | We're the kampung's angklung group. Sadly, we haven't enough notes to play right now. |
| 4 | DLG_ANGKLUNG_LEADER_V26 | Cucu sesepuh tahu sisanya. Bicaralah padanya di kebun. | The elder's grandson knows the rest. Talk to him in the gardens. |

### Beat `s3_harmony` (if `!flag:beat_s3_harmony`, `step:sq_s3=2`; do `flag:beat_s3_harmony`). Area `s3_harmony` (ASSUMED) completes step 2. The kampung plays together
| Key | ID | EN |
|-----|----|----|
| @NPC_ANGKLUNG_LEADER_NAME | | |
| BEAT_S3_HARMONY_1 | Pegang angklungmu, Nak. Kau yang memulai, pada hitungan ketiga. | Hold your angklung, child. You start it, on the third count. |
| @ | | |
| BEAT_S3_HARMONY_2 | Satu nada, lalu dua, lalu seluruh paviliun bergetar halus, bambu demi bambu. | One note, then two, then the whole pavilion hums softly, bamboo by bamboo. |
| BEAT_S3_HARMONY_3 | Para pemetik teh berhenti di terasnya. Seorang nenek menutup mulut dengan tangan. | The tea pickers stop on their terraces. An old woman covers her mouth with her hand. |
| @NPC_SUNDA_GRANDSON_NAME | | |
| BEAT_S3_HARMONY_4 | Kakek! Dengar? Itu lagu yang kau nyanyikan di dapur! | Grandfather! Do you hear? That's the song you hum in the kitchen! |
| @ | | |
| BEAT_S3_HARMONY_5 | Lagunya tak selesai sempurna. Seseorang terlambat satu nada, dan semua orang tertawa. Itu justru bagian terbaiknya. | The tune doesn't end perfectly. Someone is a note late, and everyone laughs. That is the best part. |

VERIFY: angklung as a tuned bamboo instrument played one note per person; the pentatonic (five-note) scale in Sundanese angklung.

### SQ-S4 "Cepot Si Pemberani (Bagian 1)" / "Brave Cepot (Part 1)" (companion errand, S)
Card: giver Cepot at `sunda_1`. Unlock `mq1_1`. Steps 0 `talked_to:cepot`, 1 rescue the supply pack from 3 boars (**ASSUMED** `area_cleared:s4_boars`; Ga Ward is the hint), 2 report to Cepot, which sets `c4_1`. Part 2 and 3 entries are under SQ-C4.
#### cepot, C4 part 1 entries (name NPC_CEPOT_NAME; shared NPC, keys V500+; placed with his other side entries)
| Entry | if | do |
|-------|----|----|
| c4_1_done | `step:sq_s4=2` | `flag:c4_1` |
| c4_1_wait | `quest:sq_s4=active` | |
| c4_1_hook | `quest:sq_s4=available`, `flag:mq1_1` | `start:sq_s4` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| c4_1_done | DLG_CEPOT_V500 | Bungkusanku! Lengkap, bahkan kuenya masih hangat. Kau hebat, hehe. | My pack! All of it, and the cake is still warm. You're good at this, hehe. |
| c4_1_done | DLG_CEPOT_V501 | Ambillah gelang perak ini. Bapak yang memberiku, tapi aku lebih suka kau yang pakai. | Take this silver bangle. Bapak gave it to me, but I'd rather you wear it. |
| c4_1_done | DLG_CEPOT_V502 | Aku akan ikut denganmu nanti. Jangan bilang Bapak. Aku pemberani, kan? Sedikit. | I'm coming with you later. Don't tell Bapak. I'm brave, aren't I? A little. |
| c4_1_wait | DLG_CEPOT_V503 | Tiga babi hutan itu menjaga bungkusanku seperti tamu undangan. Pakai Ga untuk menahan serudukannya. | Those three boars guard my pack like invited guests. Use Ga to hold off their charge. |
| c4_1_hook | DLG_CEPOT_V504 | Kau datang! Bagus, aku butuh orang berani, atau setidaknya orang yang bukan aku. | You came! Good, I need someone brave, or at least someone who isn't me. |
| c4_1_hook | DLG_CEPOT_V505 | Bungkusan bekalku tersangkut di semak, dan tiga babi hutan duduk di atasnya. Mereka kelihatannya lapar. | My supply pack got stuck in a bush, and three wild boars are sitting on it. They look hungry. |
| c4_1_hook | @NPC_HERO_NAME | | |
| c4_1_hook | DLG_CEPOT_H500 | Kenapa tak kau ambil sendiri? | Why not get it yourself? |
| c4_1_hook | @NPC_CEPOT_NAME | | |
| c4_1_hook | DLG_CEPOT_V506 | Aku sudah mencoba! Aku pura-pura jadi batu. Mereka menyukainya, itu masalahnya. | I tried! I pretended to be a rock. They liked it, that's the problem. |
| c4_1_hook | DLG_CEPOT_V507 | Dorong mereka dengan Ga, lalu ambil bungkusanku di kebun. Cepat, kuenya bisa dingin. | Push them back with Ga, then fetch my pack in the gardens. Quick, the cake could go cold. |

### Keraton Galuh

### SQ-G1 "Akal Si Kabayan" / "The Wit of Si Kabayan" (trickster comedy retelling, M)
Card (v5): Si Kabayan rests under a banyan in `kg_pasar` (was the alun-alun). Unlock `mqg_a1`. Steps 0 talk, 1 `clue_examined:g1_debt_ledger` and `g1_palm_sack` (three comic riddles across `kg_pasar` and `kg_alun`: the ledger, the sack, and the decree the official shouts in the alun-alun), 2 `memory_done:sq_g1_kabayan`, 3 `talked_to:kabayan` (the public defeat). The v4 clues `g1_decree` and `g1_basket` are dropped; the decree now lives in the official's talk and the hanging basket in the memory.
#### kabayan (kg_pasar, under the banyan; name NPC_KABAYAN_NAME; replace all entries)
| Entry | if | do | choices |
|-------|----|----|---------|
| 1 | `quest:sq_g1=done` | `"hub": true` | CHOICE_KABAYAN_ASK_1 to `topic:malas`; CHOICE_KABAYAN_ASK_2 to `topic:iteung`; CHOICE_KABAYAN_ASK_3 to `topic:akal`; CHOICE_KABAYAN_ASK_4 (leave) |
| topic malas | `"topic": "malas"` | `"quiet": true` | |
| topic iteung | `"topic": "iteung"` | `"quiet": true` | |
| topic akal | `"topic": "akal"` | `"quiet": true` | |
| 2 | `step:sq_g1=3` | `lakon:si_kabayan`, `codex:kabayan` | |
| 3 | `quest:sq_g1=active` | | |
| 4 | `quest:sq_g1=available`, `flag:mqg_a1` | `start:sq_g1` | |
| 5 | (none) | | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KABAYAN_V26 | Eh, kau. Mau mengobrol? Asal aku boleh tetap tiduran. | Oh, you. Want to chat? As long as I can stay lying down. |
| topic malas | DLG_KABAYAN_V27 | Aku tidak malas. Aku hemat tenaga untuk hal yang benar-benar perlu. | I'm not lazy. I'm saving my strength for things that really matter. |
| topic malas | DLG_KABAYAN_V28 | Sejauh ini yang benar-benar perlu baru tidur siang dan menang dari pejabat. Dua-duanya kukerjakan dengan baik. | So far the things that really matter are naps and beating officials. I do both very well. |
| topic malas | @NPC_HERO_NAME | | |
| topic malas | DLG_KABAYAN_H21 | Dan menanam padi? | And planting rice? |
| topic malas | @NPC_KABAYAN_NAME | | |
| topic malas | DLG_KABAYAN_V29 | Padi tumbuh sendiri kalau kau sabar. Itu rahasia yang kuberikan gratis. | Rice grows by itself if you're patient. That's a secret I give away free. |
| topic iteung | DLG_KABAYAN_V30 | Iteung istriku. Dalam kisah-kisah, ia yang sebenarnya bekerja, dan aku yang sebenarnya bercerita. | Iteung is my wife. In the tales she's the one who really works, and I'm the one who really talks. |
| topic iteung | DLG_KABAYAN_V31 | Dan mertuaku? Ia sering kuberi akal-akalan, karena ia suka sekali menyuruh. | And my father-in-law? I often give him my tricks, because he loves giving orders. |
| topic iteung | DLG_KABAYAN_V32 | Setiap kisah Kabayan berakhir sama: orang yang sombong malu, dan aku tetap tidur. | Every Kabayan tale ends the same way: the proud one is embarrassed, and I stay asleep. |
| topic akal | DLG_KABAYAN_V33 | Akal itu cuma membaca perintah sampai habis. Pejabat membaca setengah, aku membaca semuanya. | Wit is only reading an order to the end. The official reads half, I read all of it. |
| topic akal | DLG_KABAYAN_V34 | Maklumatnya bilang tanah. Bukunya bilang pajak barang. Dua-duanya punya celah seluas pintu. | His decree says ground. His ledger says taxed goods. Both have a gap as wide as a door. |
| topic akal | DLG_KABAYAN_V35 | Kalau kau mau ubah akhir sebuah cerita, cari celah itu dulu. Baru lawan. | If you want to change a tale's ending, find that gap first. Then fight. |
| 2 | @NPC_KABAYAN_NAME | | |
| 2 | DLG_KABAYAN_V36 | Pak Pejabat, bacakan maklumatmu sekali lagi. Pelan-pelan, supaya semua pasar dengar. | Sir Official, read your decree once more. Slowly, so the whole market hears. |
| 2 | @NPC_GALUH_OFFICIAL_NAME | | |
| 2 | DLG_GALUH_OFFICIAL_V20 | Maklumat itu melarang rebah di tanah. Siapa pun. | The decree forbids lying on the ground. Anyone. |
| 2 | @ | | |
| 2 | DLG_KABAYAN_N1 | Kabayan berbaring dalam keranjang rotan yang digantung di dahan beringin. Keranjang itu berayun pelan, tepat di atas topi sang pejabat. | Kabayan lies in a rattan basket hung from a banyan bough. It sways gently, right above the official's hat. |
| 2 | @NPC_GALUH_OFFICIAL_NAME | | |
| 2 | DLG_GALUH_OFFICIAL_V21 | Hmm. Ia berbaring di keranjang gantung. Keranjang itu bukan tanah. | Hmm. He lies in a hanging basket. A basket isn't the ground. |
| 2 | @NPC_KABAYAN_NAME | | |
| 2 | DLG_KABAYAN_V37 | Dan buku pajakmu tak menyebut karung tali. Impas, Pak. Boleh aku tidur sekarang? | And your ledger doesn't tax a sack of rope. Even, sir. May I sleep now? |
| 2 | @NPC_GALUH_OFFICIAL_NAME | | |
| 2 | DLG_GALUH_OFFICIAL_V22 | Baiklah. Aku kalah. Kerumunan, jangan menertawakanku! | Very well. I lose. Crowd, stop laughing at me! |
| 2 | @NPC_KABAYAN_NAME | | |
| 2 | DLG_KABAYAN_V20 | Aku menang, kan? Sekarang... aku tidur lagi. | I won, didn't I? Now... back to sleep. |
| 2 | DLG_KABAYAN_V38 | Ceritaku sudah masuk lakon desamu, Nak. Sana, kembali ke urusanmu. | My tale is in your village's lakon now, child. Go on, back to your business. |
| 3 | DLG_KABAYAN_V21 | Buku piutang pejabat dan karung gula arenku. Sudah kau lihat? Belum? Jangan berisik. | The official's ledger and my palm-sugar sack. Have you looked? Not yet? Don't be loud. |
| 4 | DLG_KABAYAN_V22 | Ssst. Aku sedang tidur. Aku Si Kabayan. | Shh. I'm sleeping. I'm Si Kabayan. |
| 4 | DLG_KABAYAN_V23 | Pejabat itu berteriak bahwa aku melanggar maklumatnya. Aku bahkan belum bangun. | That official shouts that I broke his decree. I haven't even woken up. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_KABAYAN_H20 | Dan kau mau aku membantu? | And you want my help? |
| 4 | @NPC_KABAYAN_NAME | | |
| 4 | DLG_KABAYAN_V39 | Aku mau kau yang bekerja, aku yang menang. Begitu adat kami. | I want you to do the work and me to win. That's our custom. |
| 4 | DLG_KABAYAN_V24 | Lihat buku piutang di lapak itu, dan karung gula arenku. Tiga teka-teki, satu pejabat. | Look at the ledger on that stall, and my palm-sugar sack. Three riddles, one official. |
| 5 | DLG_KABAYAN_V25 | Zzz. Pergilah, aku sedang bermimpi bagus. | Zzz. Go away, I'm having a good dream. |

| Key | ID | EN |
|-----|----|----|
| CHOICE_KABAYAN_ASK_1 | Kenapa kau malas? | Why are you lazy? |
| CHOICE_KABAYAN_ASK_2 | Siapa Iteung? | Who is Iteung? |
| CHOICE_KABAYAN_ASK_3 | Bagaimana kau selalu menang? | How do you always win? |
| CHOICE_KABAYAN_ASK_4 | Sudah, terima kasih. | That's enough, thanks. |

#### galuh_official (the official; kg_alun; name NPC_GALUH_OFFICIAL_NAME; optional, `"quiet": true`; the third riddle, the decree)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:sq_g1=done` | `"quiet": true` |
| 2 | `quest:sq_g1=active` | `"quiet": true` |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_GALUH_OFFICIAL_V23 | Aku tak ingin membahas itu. | I don't want to talk about it. |
| 2 | DLG_GALUH_OFFICIAL_V24 | Aturan tetap aturan! Pajak berdiri, pajak duduk, dan dilarang rebah di tanah alun-alun. | Rules are rules! Tax for standing, tax for sitting, and no lying on the alun-alun ground. |
| 2 | DLG_GALUH_OFFICIAL_V25 | Si pemalas itu sudah dua kali kuseret. Ia selalu lolos. Aku tak mengerti caranya. | I've dragged that layabout off twice. He always slips away. I don't understand how. |
| 3 | DLG_GALUH_OFFICIAL_V26 | Minggir. Aku sedang menghitung pajak. | Step aside. I'm counting taxes. |

#### Clues G1 (hunt `HUNT_SQ_G1_TITLE`; `g1_debt_ledger` and `g1_palm_sack`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_G1_TITLE | Akal Si Kabayan | The Wit of Si Kabayan |
| CLUE_G1_DEBT_LEDGER_1 | Buku pajak pejabat terbuka di lapak: pajak berdiri, pajak duduk, pajak rebahan. Semuanya tercatat, kecuali tidur. | The official's tax ledger lies open on a stall: tax for standing, for sitting, for lying down. All listed, except sleeping. |
| CLUE_G1_DEBT_LEDGER_2 | Tiap pasal menyebut tanah. Tak satu pun menyebut yang menggantung di atasnya. | Every clause names the ground. None names what hangs above it. |
| CLUE_G1_DEBT_LEDGER_NOTE | Buku pajak pejabat: tiap pasal menyebut tanah. | The official's ledger: every clause names the ground. |
| CLUE_G1_PALM_SACK_1 | Karung gula aren Kabayan, teranyam longgar. Isinya hanya tali ijuk dan rotan yang belum diraut. | Kabayan's palm-sugar sack, loosely woven. Inside: only fibre rope and unshaved rattan. |
| CLUE_G1_PALM_SACK_2 | Tak ada dagangan, jadi tak ada yang bisa dipajaki. Tapi tali dan rotan ini cukup untuk satu keranjang gantung. | No goods, so nothing to tax. But this rope and rattan would make a hanging basket. |
| CLUE_G1_PALM_SACK_NOTE | Karung Kabayan: hanya tali dan rotan, tanpa dagangan. | Kabayan's sack: only rope and rattan, no goods. |

#### Memory `sq_g1_kabayan` (play; kelir figure: Si Kabayan; the action hangs the basket; opened by `g1_palm_sack`)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_G1_KABAYAN_TITLE | Kabayan dan Maklumat | Kabayan and the Decree |
| MEM_SQ_G1_KABAYAN_IN | Dengarkan kisah ini, Nak: si pemalas diperintah untuk tidak berbaring. Gantung keranjangnya. | Hear this tale, child: the lazy one is ordered not to lie down. Hang the basket. |
| MEM_SQ_G1_KABAYAN_HINT | Gantung keranjangnya | Hang the basket |
| MEM_SQ_G1_KABAYAN_1 | Maklumatnya jelas: dilarang rebah di tanah. Kabayan menguap. | The decree is clear: no lying on the ground. Kabayan yawns. |
| MEM_SQ_G1_KABAYAN_2 | Ia menggantung keranjang di dahan, lalu naik dan berbaring. | He hangs a basket from a branch, climbs in, and lies down. |
| MEM_SQ_G1_KABAYAN_3 | Pejabat itu membuka mulut, lalu menutupnya lagi. Ia tak punya jawaban. | The official opens his mouth, then shuts it. He has no answer. |
| MEM_SQ_G1_KABAYAN_OUT | Begitulah ceritanya: cerdik itu mengubah perintah menjadi bantal. | So the tale goes: the clever one turns an order into a pillow. |

VERIFY: which Kabayan tale; Iteung and the father-in-law as stock figures of the cycle; the decree and basket tale is ASSUMED as a game retelling.

### SQ-G2 "Ririwa di Kaputren" / "The Sweeping Ghost of the Kaputren" (two-way hunt, L)
Card: giver an old palace maid (`g2_maid`) in `kg_kaputren`; unlock `mqg_kp1` (**not in the zone docs**, which unlock at `mqg_4` in `kg_keraton`; the v4d maid id `kaputren_maid` is replaced by `g2_maid`). Steps 0 talk, 1 `clue_examined:g2_broom` and `g2_roll`, 2 `memory_done:sq_g2_servant`, 3 alt: write `name_written:ririwa_name` (peaceful) or `enemy_killed:ririwa` (fight), 4 report. Title ID avoids the creature name (rule 10).
#### g2_maid (old palace maid, kg_kaputren; name NPC_KAPUTREN_MAID_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_g2=4`, `flag:sq_g2_peaceful` | `codex:ririwa` |
| 2 | `step:sq_g2=4`, `flag:sq_g2_fight` | `codex:ririwa` |
| 3 | `step:sq_g2=3` | |
| 4 | `quest:sq_g2=active` | |
| 5 | `quest:sq_g2=available`, `flag:mqg_kp1` | `start:sq_g2` |
| 6 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KAPUTREN_MAID_V20 | Sapu itu tergantung di kaitnya. Pagi ini lorongnya sunyi. | The broom hangs on its hook. The hall is quiet this morning. |
| 1 | DLG_KAPUTREN_MAID_V21 | Ia pernah punya nama. Aku akan menyebutnya sekali saja: Canga. | He had a name once. I'll say it just once: Canga. |
| 1 | DLG_KAPUTREN_MAID_V29 | Daftar pelayan itu kini lengkap lagi. Ada yang menyapanya tiap pagi. Itu sudah cukup. | The servants' roll is whole again. Someone greets him every morning. That's enough. |
| 2 | DLG_KAPUTREN_MAID_V22 | Lorongnya tenang. Daftar itu masih tergores. | The hall is calm. The roll is still scraped. |
| 2 | DLG_KAPUTREN_MAID_V23 | Aku tak ingin membahasnya. | I don't want to talk about it. |
| 3 | DLG_KAPUTREN_MAID_V30 | Kau sudah dengar kisahnya. Tulislah namanya di daftar, atau hadapi ia di lorong. Aku tak akan menghalangi. | You've heard his story. Write his name on the roll, or face him in the hall. I won't stop you. |
| 4 | DLG_KAPUTREN_MAID_V24 | Sapu dan daftar. Jika kau periksa keduanya, kau mungkin paham. | The broom and the roll. If you check both, you may understand. |
| 5 | DLG_KAPUTREN_MAID_V25 | Tiap malam ada yang menyapu lorong perempuan ini. Pagi harinya gagang sapunya aus. | Every night someone sweeps this women's hall. By morning the broom is worn to the handle. |
| 5 | DLG_KAPUTREN_MAID_V26 | Aku tak pernah melihat siapa. Aku hanya mendengar sapuannya. | I've never seen who. I only hear the sweeping. |
| 5 | @NPC_HERO_NAME | | |
| 5 | DLG_KAPUTREN_MAID_H20 | Sudah berapa lama? | How long has it been? |
| 5 | @NPC_KAPUTREN_MAID_NAME | | |
| 5 | DLG_KAPUTREN_MAID_V31 | Sejak sebelum aku masuk istana, dan aku sudah tua. Lihat sapu yang aus itu, dan daftar para pelayan di rak. | Since before I came to the palace, and I'm old. See the worn broom, and the servants' roll on the shelf. |
| 6 | DLG_KAPUTREN_MAID_V28 | Kaputren ini selalu sepi. Aku sudah terbiasa. | The kaputren is always quiet. I'm used to it. |

#### Clues G2 (hunt `HUNT_SQ_G2_TITLE`; `g2_broom` and `g2_roll`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_G2_TITLE | Sapu di Kaputren | The Broom in the Kaputren |
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

#### ririwa_roll (kaputren hall, a shelf with the roll; write card; name NPC_RIRIWA_ROLL_NAME; peaceful `alt`, step 3)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_g2=3`, `!flag:sq_g2_fight`, `!flag:name_ririwa_name` | `write:ririwa_name:sunda_ca,sunda_nga`, `flag:name_ririwa_name` |
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

### SQ-M1 "Jaka Tarub dan Nawang Wulan" (folklore retelling, M)
Card: giver Nawang Wulan in `mt_sawah`; unlock `mq2_1`. Steps 0 talk, 1 `clue_examined:m1_pot_lid` and `m1_rice_gone`, 2 `memory_done:sq_m1_selendang`, 3 clear the spirit thieves around the spring and return her shawl (`talked_to:nawang_wulan`; the thieves' encounter id is **ASSUMED** `area_cleared:m1_spring_thieves`, the card gives none).
#### nawang_wulan (rice-farming household; name NPC_NAWANG_WULAN_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_m1=3`, `area_cleared:m1_spring_thieves` | `lakon:jaka_tarub` |
| 2 | `step:sq_m1=3` | `"quiet": true` |
| 3 | `quest:sq_m1=active` | |
| 4 | `quest:sq_m1=available`, `flag:mq2_1` | `start:sq_m1` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_NAWANG_WULAN_V20 | Selendang itu kembali. Suamiku menyembunyikannya di bawah beras terakhir, lama sekali. | The shawl is back. My husband hid it under the last of the rice, long ago. |
| 1 | DLG_NAWANG_WULAN_V21 | Jaka Tarub namanya. Ia baik hati, tapi satu rahasia kecil bisa mengosongkan sebuah periuk. | Jaka Tarub is his name. He's kind, but one small secret can empty a pot. |
| 1 | DLG_NAWANG_WULAN_V22 | Aku pulang ke langit. Terimalah selendang tenunku, semoga ringan langkahmu. | I'm going home to the sky. Take my woven scarf, and may your steps be light. |
| 2 | DLG_NAWANG_WULAN_V28 | Para pencuri bayangan itu masih berkerumun di mata air. Selendangku ada pada mereka. | The shadow thieves still crowd the spring. My shawl is with them. |
| 2 | DLG_NAWANG_WULAN_V29 | Usir mereka pelan-pelan, Nak. Mereka hanya tertarik pada yang berkilau. | Drive them off gently, child. They're only drawn to what glitters. |
| 3 | DLG_NAWANG_WULAN_V23 | Periuk dan lumbung, Nak. Lihat keduanya. | The pot and the lumbung, child. Look at both. |
| 4 | DLG_NAWANG_WULAN_V24 | Selamat datang. Maaf, aku sedang menatap periuk ini. | Welcome. Sorry, I was staring at this pot. |
| 4 | DLG_NAWANG_WULAN_V25 | Dulu sebutir beras mengisinya penuh. Hari ini kosong. | Once a single grain of rice filled it to the brim. Today it's empty. |
| 4 | @NPC_HERO_NAME | | |
| 4 | DLG_NAWANG_WULAN_H20 | Kenapa tutupnya terangkat? | Why is the lid lifted? |
| 4 | @NPC_NAWANG_WULAN_NAME | | |
| 4 | DLG_NAWANG_WULAN_V30 | Aku yang mengangkatnya. Aku sedang mencari sesuatu yang hilang lama, selendangku. | I lifted it. I was looking for something lost long ago, my shawl. |
| 4 | DLG_NAWANG_WULAN_V26 | Aku mengangkat tutupnya, lalu memalingkan muka. Lihatlah periuk dan lumbungnya, kalau kau mau. | I lifted the lid, then looked away. See the pot and the lumbung, if you will. |
| 5 | DLG_NAWANG_WULAN_V27 | Padi tumbuh subur di sawah ini. Rasanya damai. | The rice grows well in these fields. It feels peaceful. |

VERIFY: all beats of the legend (one grain filling the pot, the hidden shawl, her return to the sky), Nawang Wulan as a bidadari shown with respect, and the legend's location.

#### Clues M1 (hunt `HUNT_SQ_M1_TITLE`; `m1_pot_lid` and `m1_rice_gone`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_M1_TITLE | Jaka Tarub dan Nawang Wulan | Jaka Tarub and Nawang Wulan |
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

### SQ-M2 "Anak yang Tak Dipanggil" / "The Child Nobody Called" (Wewe Gombel two-way hunt, L)
Card: giver `m2_neighbour` in `mt_pasar`; unlock `mq2_2`. Steps 0 talk, 1 `clue_examined:m2_toy` and `talked_to:m2_parents_1`, 2 `memory_done:sq_m2_child`, 3 alt: `talked_to:wewe_parents_2` (peaceful) or `enemy_killed:wewe_elite` (fight), 4 bring the child home.
#### m2_neighbour (a worried neighbour; name NPC_M2_NEIGHBOUR_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_m2=4`, `flag:sq_m2_peaceful` | |
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

#### m2_parents_1 (the boy's parents, at their stall; name NPC_M2_PARENTS_NAME; step 1 talk, `talked_to:m2_parents_1`, and the step 4 turn-in)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_m2=4` | |
| 2 | `step:sq_m2=1` | |
| 3 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_M2_PARENTS_V43 | Ia di sini. Ia sudah tidur di pangkuanku, dan aku tak berani bergerak. | He's here. He fell asleep in my lap, and I daren't move. |
| 1 | DLG_M2_PARENTS_V44 | Kami akan menutup lapak lebih awal tiap petang. Ada yang harus kami panggil pulang. | We'll close the stall early every evening. There's someone we have to call home. |
| 2 | DLG_M2_PARENTS_V30 | Kami sibuk di lapak, Nak. Rasanya baru sebentar. | We were busy at the stall, child. It felt like only a moment. |
| 2 | @NPC_HERO_NAME | | |
| 2 | DLG_M2_PARENTS_H30 | Kapan terakhir kalian memanggilnya? | When did you last call his name? |
| 2 | @NPC_M2_PARENTS_NAME | | |
| 2 | DLG_M2_PARENTS_V31 | Tak ada yang memanggilnya. Kami... tak sempat. Cari mainannya di jalan bukit. | Nobody called him. We... never had time. Look for his toy on the hill path. |
| 3 | DLG_M2_PARENTS_V32 | Hari ini banyak pembeli. Tapi hati kami sepi. | Plenty of buyers today. But our hearts are quiet. |

#### wewe_parents_2 (the hill; peaceful `alt`, step 3; the same parents; name NPC_M2_PARENTS_NAME)
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

#### Clues M2 (hunt `HUNT_SQ_M2_TITLE`; `m2_toy`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_M2_TITLE | Anak yang Tak Dipanggil | The Child Nobody Called |
| CLUE_M2_TOY_1 | Kuda-kudaan kayu kecil tergeletak di jalan bukit. Seutas kertas terikat di lehernya: "Jaga dia. Tak ada yang memanggilnya." | A little wooden toy horse lies on the hill path. A strip of paper is tied round its neck: "Look after him. Nobody calls him." |
| CLUE_M2_TOY_2 | Catatan itu untuk Wewe Gombel, hantu yang kata orang membawa anak terlantar ke bukit. Bukan untuk menyakiti, katanya. | The note is for Wewe Gombel, the ghost who, they say, takes neglected children up the hill. Not to harm them, the tale says. |
| CLUE_M2_TOY_NOTE | Mainan anak di jalan bukit; catatan untuk Wewe Gombel. | A boy's toy on the hill path; a note for Wewe Gombel. |

The second trigger of step 1 is the talk with the parents above (`talked_to:m2_parents_1`); it has no `CLUE_` keys.

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

### SQ-M3 "Uang yang Hilang di Pasar" / "Coins Gone from the Market" (tuyul two-way hunt, M)
Card: giver `m3_smith` in `mt_pasar`; unlock `mq2_1`. Steps 0 talk, 1 `clue_examined:m3_footprints` and `m3_beans`, 2 `memory_done:sq_m3_tuyul`, 3 alt: `area_entered:m3_trap_sprung` (peaceful) or `enemy_killed:tuyul_leader` (fight), 4 tell the smith.
#### m3_smith (a pande besi with a market stall; name NPC_M3_SMITH_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_m3=4`, `flag:sq_m3_peaceful` | |
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

#### Clues M3 (hunt `HUNT_SQ_M3_TITLE`; `m3_footprints` and `m3_beans`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_M3_TITLE | Uang yang Hilang | The Missing Coins |
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

### SQ-M4 "Gamelan yang Bisu" / "The Silent Gamelan" (cultural world-state quest, M)
Card: giver Ki Sumarto (`mataram_dalang`) in `mt_pasar`; unlock `mq2_2`. Steps 0 talk, 1 recover the stolen `gong_ageng` from the sunken vault of `mt_reruntuhan` (**ASSUMED** `item_picked:gong_ageng`), 2 restore it to the pavilion (**ASSUMED** `area_entered:m4_pavilion`, the beat below). Reward: the gong layer joins Mataram's music.
#### mataram_dalang, M4 entries (Ki Sumarto; name NPC_MATARAM_DALANG_NAME; shared NPC, keys V500+; placed with his other side entries)
| Entry | if | do |
|-------|----|----|
| m4_done | `quest:sq_m4=done` | |
| m4_gong | `step:sq_m4=2` | `"quiet": true` |
| m4_wait | `quest:sq_m4=active` | |
| m4_hook | `quest:sq_m4=available`, `flag:mq2_2` | `start:sq_m4` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| m4_done | DLG_MATARAM_DALANG_V507 | Dengar? Gong itu menutup tiap putaran lagu. Mataram bernapas lagi. | Hear it? The gong closes every round of the tune. Mataram breathes again. |
| m4_done | DLG_MATARAM_DALANG_V508 | Ambillah blangkon ini. Dalang tanpa blangkon itu seperti gamelan tanpa gong. | Take this blangkon. A dalang without one is like a gamelan without a gong. |
| m4_gong | DLG_MATARAM_DALANG_V506 | Gong ageng! Letakkan di paviliun, di tengah bingkainya. Aku tak berani menyentuhnya, takut ia pecah lagi. | The gong ageng! Set it in the pavilion, in the middle of its frame. I daren't touch it, in case it breaks again. |
| m4_wait | DLG_MATARAM_DALANG_V505 | Bilik tenggelam di bawah halaman luar reruntuhan. Bawa pulang gongnya, tapi jangan dipukul dulu. | The sunken chamber under the ruins' outer yard. Bring the gong home, but don't strike it yet. |
| m4_hook | DLG_MATARAM_DALANG_V500 | Dengar? Tak ada. Gamelanku bisu, Nak, dan wayangku ikut pincang. | Hear that? Nothing. My gamelan is mute, child, and my wayang limps with it. |
| m4_hook | DLG_MATARAM_DALANG_V501 | Gong ageng dicuri waktu perang. Tanpa dia, tak ada lagu yang punya titik; semuanya menggantung. | The gong ageng was stolen in the war. Without it no tune has a full stop; everything hangs. |
| m4_hook | @NPC_HERO_NAME | | |
| m4_hook | DLG_MATARAM_DALANG_H500 | Siapa yang mengambilnya? | Who took it? |
| m4_hook | @NPC_MATARAM_DALANG_NAME | | |
| m4_hook | DLG_MATARAM_DALANG_V502 | Penjarah yang butuh perunggu. Mereka menyembunyikannya di bilik bawah reruntuhan, yang tenggelam. | Looters who needed bronze. They hid it in the chamber under the ruins, the sunken one. |
| m4_hook | DLG_MATARAM_DALANG_V503 | Arca penjaga di sana tak ramah. Dan hati-hati dengan air, bilik itu lebih basah daripada ceritanya. | The guardian statues there aren't friendly. And mind the water, that chamber is wetter than its story. |
| m4_hook | DLG_MATARAM_DALANG_V504 | Kalau gongnya pulang, Mataram akan mendengar dirinya sendiri lagi. Pergilah. | If the gong comes home, Mataram will hear itself again. Go on. |

### Beat `m4_gong` (if `!flag:beat_m4_gong`, `step:sq_m4=2`; do `flag:beat_m4_gong`). Area `m4_pavilion` (ASSUMED) completes step 2. The gong layer joins the world music
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_M4_GONG_1 | Kau mengangkat gong ageng ke bingkainya di paviliun. Perunggunya dingin dan berat, seperti ingatan yang lama tak disentuh. | You lift the gong ageng into its frame in the pavilion. The bronze is cold and heavy, like a memory long untouched. |
| @NPC_HERO_NAME | | |
| BEAT_M4_GONG_H1 | Sekali saja, pelan. | Once, and gently. |
| @ | | |
| BEAT_M4_GONG_2 | Satu pukulan. Suaranya membulat, turun ke tanah, lalu naik lagi ke atap paviliun. | One strike. The sound swells, sinks into the ground, then rises to the pavilion roof. |
| @NPC_MATARAM_DALANG_NAME | | |
| BEAT_M4_GONG_3 | Itu dia. Itu suara yang kutunggu bertahun-tahun. | There it is. That's the sound I've waited years for. |
| @ | | |
| BEAT_M4_GONG_4 | Di pasar, para pedagang berhenti menawar. Seorang anak menirukan bunyinya dengan mulut, dan gamelan lain mulai menyusul. | In the market the traders stop haggling. A child hums the sound back, and other gamelan start to follow. |
| BEAT_M4_GONG_5 | Musik Mataram kini punya satu lapis baru di bawah semua nada: napas panjang yang menyatukan. | Mataram's music now has a new layer beneath every note: a long breath that holds it together. |

VERIFY: the gong ageng closing the gamelan cycle (gongan) as the largest gong in a Javanese gamelan.

### Tanah Timur

### SQ-T1 "Ande-Ande Lumut" (folklore retelling and two-way crossing, M)
Card: giver Klething Kuning at `tt_kali`; unlock `mq3_1`. Steps 0 talk, 1 `clue_examined:t1_claw_marks` and `t1_sodo`, 2 `memory_done:sq_t1_klething`, 3 alt: `area_entered:t1_crossing_dry` (peaceful) or `enemy_killed:yuyu_kangkang` (fight), 4 speak with Klething Kuning.
#### klething_kuning (at the riverbank; name NPC_KLETHING_KUNING_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_t1=4`, `flag:sq_t1_peaceful` | `lakon:ande_ande_lumut` |
| 2 | `step:sq_t1=4`, `flag:sq_t1_fight` | `lakon:ande_ande_lumut` |
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

#### Clues T1 (hunt `HUNT_SQ_T1_TITLE`; `t1_claw_marks` and `t1_sodo`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_T1_TITLE | Ande-Ande Lumut | Ande-Ande Lumut |
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

### SQ-T2 "Api Tanpa Angin" / "Fire With No Wind" (banaspati hunt, L)
Card: giver `t2_herder` in `tt_kulon` (zone docs: `tt_sabana`); unlock `mq3_1`. Steps 0 talk, 1 `clue_examined:t2_burn_trail` and `t2_campfire`, 2 `memory_done:sq_t2_herder`, 3 open the oasis channel and `enemy_killed:banaspati_elite`, 4 report.
#### t2_herder (the herder; name NPC_T2_HERDER_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_t2=4` | |
| 2 | `step:sq_t2=3` | |
| 3 | `quest:sq_t2=active` | |
| 4 | `quest:sq_t2=available`, `flag:mq3_1` | `start:sq_t2` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_T2_HERDER_V20 | Apinya padam. Rumput akan tumbuh lagi. | The fire is out. The grass will grow back. |
| 1 | DLG_T2_HERDER_V21 | Domba-dombaku mulai merumput lagi. Ambil kantong ramuan ini. | My sheep are grazing again. Take this herb pouch. |
| 2 | DLG_T2_HERDER_V27 | Air mengalir menahannya, kata kisah itu. Buka saluran di oasis pesisir, lalu hadapi ia di sana. | Running water holds it back, the tale says. Open the channel at the coastal oasis, then face it there. |
| 3 | DLG_T2_HERDER_V22 | Jejak hangus dan api unggun yang tak ada yang menyalakannya. Itu petunjuknya. | The burnt trail and the campfire nobody lit. Those are your clues. |
| 4 | DLG_T2_HERDER_V23 | Rumputku terbakar membentuk garis, padahal tak ada angin. | My grass burns in a line, and there's no wind. |
| 4 | DLG_T2_HERDER_V24 | Aku tak berani mendekat malam hari. Dombaku pun tak mau. | I don't dare go near at night. My sheep won't either. |
| 4 | DLG_T2_HERDER_V25 | Lihat jejak hangusnya, dan api unggun yang tak seorang pun nyalakan. | Look at the burnt trail, and the campfire nobody lit. |
| 5 | DLG_T2_HERDER_V26 | Dombaku gelisah, tapi sabana ini tetap indah. | My sheep are restless, but the savanna is still beautiful. |

#### Clues T2 (hunt `HUNT_SQ_T2_TITLE`; `t2_burn_trail` and `t2_campfire`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_T2_TITLE | Api Tanpa Angin | Fire With No Wind |
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

### SQ-T3 "Pamor dari Langit" / "Pamor from the Sky" (cross-region smithing quest, M)
Card: giver Mpu Wirasana and Ratna at the `tt_beringin` forge; unlock `mq3_2`. Steps 0 talk, 1 find the fallen meteorite `batu_bintang` on the Mataram temple plain (card says `mt_tegal`, zone docs `mt_candi` east yard; **ASSUMED** `clue_examined:t3_crater`), 2 defend the crater from stone guardians (**ASSUMED** `area_cleared:t3_guardians`), 3 bring it back and fold the pamor (**ASSUMED** puzzle `puzzle_solved:t3_pamor`, then `talked_to:timur_empu`).
#### timur_empu, T3 entries (Mpu Wirasana; name NPC_TIMUR_EMPU_NAME; side entries after the main-path entries)
| Entry | if | do |
|-------|----|----|
| t3_done | `quest:sq_t3=done` | |
| t3_back | `step:sq_t3=3` | |
| t3_wait | `quest:sq_t3=active` | |
| t3_hook | `quest:sq_t3=available`, `flag:mq3_2` | `start:sq_t3` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| t3_done | DLG_TIMUR_EMPU_V535 | Luk tujuh, ditempa dari batu langit. Ratna yang memegang palunya di lipatan terakhir. | Seven curves, forged from sky-stone. Ratna held the hammer for the last fold. |
| t3_done | DLG_TIMUR_EMPU_V536 | Terimalah keris ini. Pamornya akan mengingatkanmu bahwa tak semua yang jatuh itu kutukan. | Take this keris. Its pamor will remind you that not everything that falls is a curse. |
| t3_back | DLG_TIMUR_EMPU_V532 | Batu bintang! Ringan di tangan, tapi bercahaya seperti ia ingat langit. | A star-stone! Light in the hand, but it glows as if it remembers the sky. |
| t3_back | DLG_TIMUR_EMPU_V533 | Ratna, nyalakan tungku. Kita lipat bajanya bersama, tujuh kali, dan kau yang menjaga api, Nak. | Ratna, light the furnace. We fold the steel together, seven times, and you keep the fire, child. |
| t3_back | DLG_TIMUR_EMPU_V534 | Sabar. Pamor tak bisa diburu-buru, sama seperti kutukan tak bisa dilupakan cepat-cepat. | Patience. Pamor can't be rushed, just as a curse can't be forgotten in a hurry. |
| t3_wait | DLG_TIMUR_EMPU_V531 | Batu itu jatuh di dataran candi Mataram. Penjaga batu mungkin sudah mengerumuninya. Hati-hati. | The stone fell on Mataram's temple plain. Stone guardians may already crowd around it. Be careful. |
| t3_hook | DLG_TIMUR_EMPU_V530 | Kerisku yang baru butuh pamor yang belum pernah dilihat siapa pun. Pamor dari langit. | My new keris needs a pamor nobody has ever seen. A pamor from the sky. |
| t3_hook | DLG_TIMUR_EMPU_V537 | Konon sebongkah batu bintang jatuh di dataran candi Mataram, dekat Prambanan. Ratna, ceritakan. | They say a star-stone fell on the temple plain of Mataram, near Prambanan. Ratna, tell it. |
| t3_hook | @NPC_TIMUR_DAUGHTER_NAME | | |
| t3_hook | DLG_TIMUR_DAUGHTER_V530 | Aku melihatnya dari bubungan atap: garis api, lalu dentuman. Pemburu batu sudah berebut sejak itu. | I saw it from the roof ridge: a line of fire, then a boom. Stone hunters have been fighting over it since. |
| t3_hook | @NPC_HERO_NAME | | |
| t3_hook | DLG_TIMUR_EMPU_H530 | Aku akan membawanya pulang. | I'll bring it home. |

#### Clue `t3_crater` (hunt `HUNT_SQ_T3_TITLE`; **ASSUMED** id, the `clue` piece; the crater rim on the temple plain)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_T3_TITLE | Pamor dari Langit | Pamor from the Sky |
| CLUE_T3_CRATER_1 | Sebuah cekungan hangus di tanah, dengan serpih hitam berkilau di tepinya. Rumput di sekelilingnya melingkar menjauh. | A scorched dip in the ground, with glinting black flakes along its rim. The grass curls away around it. |
| CLUE_T3_CRATER_2 | Di dasarnya, bongkahan sebesar kepala masih hangat. Patung-patung batu mulai bergeser mendekat. | At the bottom, a head-sized lump is still warm. Stone statues begin to shift closer. |
| CLUE_T3_CRATER_NOTE | Kawah kecil di dataran candi: batu bintang, dijaga patung. | A small crater on the temple plain: the star-stone, guarded by statues. |

VERIFY: pamor from meteoritic iron in keris smithing.

### SQ-T4 "Kuda Kepang yang Hilang" / "The Lost Kuda Kepang" (cultural performance errand, S)
Card: giver the troupe leader (`kepang_leader`) at the `tt_beringin` troupe camp; unlock `mq3_1`. Steps 0 recover 3 woven bamboo horses (`item_picked:kuda_kepang_1` to `_3`), 1 return them and watch the dance (`area_entered:kepang_stage`, the beat). Zone docs place the pickups in `tt_sabana`, `tt_kali`, `tt_pesisir` (card: `tt_kulon` and `tt_beringin`).
#### kepang_leader (troupe camp; name NPC_KEPANG_LEADER_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:sq_t4=done` | |
| 2 | `step:sq_t4=1` | |
| 3 | `quest:sq_t4=active` | |
| 4 | `quest:sq_t4=available`, `flag:mq3_1` | `start:sq_t4` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KEPANG_LEADER_V20 | Pertunjukan yang indah, bukan? Terima kasih, Nak. Pecahan labu itu tanda terima kasih rombongan. | A fine show, wasn't it? Thank you, child. That flask shard is the troupe's thanks. |
| 2 | DLG_KEPANG_LEADER_V21 | Kuda-kudaku lengkap! Duduklah di depan panggung. Kami mulai. | My horses are all here! Sit in front of the stage. We begin. |
| 3 | DLG_KEPANG_LEADER_V22 | Tiga kuda kepang kami terbawa angin. Cari yang berkilau di tanah, di sabana, di kali, dan di pesisir. | Three of our kuda kepang blew away. Look for a sparkle on the ground, on the savanna, by the river and on the shore. |
| 4 | DLG_KEPANG_LEADER_V23 | Kami rombongan kuda lumping. Badai menerbangkan tiga kuda kepang kami, dan tanpa mereka kami hanya orang yang menari. | We're a kuda lumping troupe. A storm blew away three of our kuda kepang, and without them we're just people dancing. |
| 4 | DLG_KEPANG_LEADER_V24 | Kuda kepang itu anyaman bambu, ringan dan lincah. Maukah kau mencarinya? | A kuda kepang is woven bamboo, light and nimble. Will you find them? |
| 5 | DLG_KEPANG_LEADER_V25 | Panggung ini sepi tanpa tarian. | This stage is quiet without dancing. |

### Beat `t4_dance` (if `!flag:beat_t4_dance`, `step:sq_t4=1`; do `flag:beat_t4_dance`). Area `kepang_stage` completes step 1. A performance only, no trance
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_T4_DANCE_1 | Para penari naik ke panggung dengan kuda anyaman di antara paha, dan gamelan kecil mulai berdenting. | The dancers climb on stage with woven horses between their knees, and a small gamelan begins to chime. |
| BEAT_T4_DANCE_2 | Mereka berderap dalam barisan, lalu berputar, lalu berderap lagi, tertawa karena satu penari salah belok. | They gallop in a line, then turn, then gallop again, laughing because one dancer takes a wrong turn. |
| @NPC_KEPANG_LEADER_NAME | | |
| BEAT_T4_DANCE_3 | Itu yang kami sebut menunggang tanpa kuda sungguhan. Kau bisa bertepuk, Nak. | That's what we call riding without a real horse. You may clap, child. |
| @ | | |
| BEAT_T4_DANCE_4 | Penonton bertepuk. Debu naik dari panggung, emas dalam cahaya sore. | The crowd claps. Dust rises from the stage, gold in the afternoon light. |

VERIFY: kuda kepang or kuda lumping as a woven-bamboo dance horse; here a performance only, no trance.

### Segara Kidul

### SQ-K1 "Tukik Pulang ke Laut" / "Hatchlings Home to the Sea" (conservation errand, S)
Card: giver the fisher's child (`kidul_nelayan_anak`) in `sk_pantai`; unlock `mq4_4`. Steps 0 gather 3 hatchlings (`item_picked:tukik_1` to `_3`), 1 clear the reef predators along the surf (**ASSUMED** `area_cleared:k1_surf`), 2 release them (`area_entered:kidul_tukik_laut`, the beat).
#### kidul_nelayan_anak (sk_pantai; name NPC_KIDUL_NELAYAN_ANAK_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `quest:sq_k1=done` | |
| 2 | `step:sq_k1=2` | |
| 3 | `quest:sq_k1=active` | |
| 4 | `quest:sq_k1=available`, `flag:mq4_4` | `start:sq_k1` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_KIDUL_NELAYAN_ANAK_V20 | Mereka sampai ke ombak! Ia membawa mereka pergi. | They reached the surf! It carried them away. |
| 1 | DLG_KIDUL_NELAYAN_ANAK_V21 | Kata kakekku, penyu selalu ingat pantai tempat ia menetas. Ini kantong ramuan untukmu. | My grandfather says a turtle always remembers the beach where it hatched. Here's a herb pouch for you. |
| 2 | DLG_KIDUL_NELAYAN_ANAK_V26 | Pelan-pelan, jangan terlalu dekat ombak. Letakkan mereka di pasir basah, mereka tahu sisanya. | Go gently, not too close to the surf. Set them on the wet sand, they know the rest. |
| 3 | DLG_KIDUL_NELAYAN_ANAK_V22 | Tiga tukik, ingat. Dan hati-hati dengan yang menunggu di karang. | Three tukik, remember. And watch for what waits on the reef. |
| 4 | DLG_KIDUL_NELAYAN_ANAK_V23 | Lihat, tukik, anak penyu, tersesat di bukit pasir. Mereka belum menemukan laut. | Look, tukik, baby turtles, are lost in the dunes. They haven't found the sea yet. |
| 4 | DLG_KIDUL_NELAYAN_ANAK_V24 | Aku harus menjaga jaring. Tolong bawa tiga ekor ke ombak. | I have to mind the nets. Please carry three of them to the surf. |
| 4 | DLG_KIDUL_NELAYAN_ANAK_V27 | Ada kepiting karang dan ikan buas di sepanjang ombak. Singkirkan mereka dulu, ya. | There are reef crabs and fierce fish all along the surf. Clear them first, will you. |
| 5 | DLG_KIDUL_NELAYAN_ANAK_V25 | Laut ramai hari ini. | The sea is busy today. |

### Beat `k1_release` (if `!flag:beat_k1_release`, `step:sq_k1=2`; do `flag:beat_k1_release`). Area `kidul_tukik_laut` completes step 2
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_K1_RELEASE_1 | Kau meletakkan tukik terakhir di pasir basah. Ombak datang, menyentuh, lalu menarik mereka pelan. | You set the last hatchling on the wet sand. A wave comes, touches, then draws them gently away. |
| BEAT_K1_RELEASE_2 | Tiga kepala kecil timbul sekali di antara buih, lalu hilang ke arah matahari terbenam. | Three small heads surface once in the foam, then vanish toward the sunset. |

VERIFY: turtles returning to their hatching beach (nesting beaches such as Pangumbahan or Sukamade).

### SQ-K2 "Jaring yang Robek" / "The Torn Nets" (white crocodile hunt, L)
Card: giver `k2_fisher` (card says `sk_nelayan`; zone docs place him at the river mouth in `sk_karang`); unlock `mq4_4`. Steps 0 talk, 1 `clue_examined:k2_scale` and `talked_to:kidul_jurukunci`, 2 `memory_done:sq_k2_fisher`, 3 `enemy_killed:bajul_putih_tua` (at 0 HP it dives, never dies), 4 report.
#### k2_fisher (river mouth; name NPC_K2_FISHER_NAME; replace all entries)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_k2=4` | |
| 2 | `step:sq_k2=3` | |
| 3 | `quest:sq_k2=active` | |
| 4 | `quest:sq_k2=available`, `flag:mq4_4` | `start:sq_k2` |
| 5 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_K2_FISHER_V20 | Ia mundur ke laut dalam. Jaring kami tak robek lagi. | It drew back into the deep. Our nets aren't torn any more. |
| 1 | DLG_K2_FISHER_V21 | Kami menebar jaring lagi. Hasil pertama kami taruh di pasir untuknya. | We cast again. The first catch we leave on the sand for it. |
| 2 | DLG_K2_FISHER_V26 | Air akan surut dulu sebelum ia menerjang. Ingat itu. Dan jangan lupa, ia penjaga, bukan musuh. | The water draws back before it charges. Remember that. And don't forget, it's a keeper, not an enemy. |
| 3 | DLG_K2_FISHER_V22 | Sisik putih dan Mbah Wiryo. Dua-duanya akan menjawab. | The white scale and Mbah Wiryo. Both will answer you. |
| 4 | DLG_K2_FISHER_V23 | Jaring kami robek dari dalam, tiap malam. Tak ada yang berani menebar di muara. | Our nets are torn from the inside, every night. Nobody dares cast at the river mouth. |
| 4 | DLG_K2_FISHER_V24 | Lihat sisik putih yang tersangkut di jaring. Lalu tanyakan pada juru kunci pantai. | See the white scale caught in the net. Then ask the juru kunci of the shore. |
| 5 | DLG_K2_FISHER_V25 | Muara ini indah, kalau sedang tenang. | The river mouth is lovely when it's calm. |

#### kidul_jurukunci, one-line entry (Mbah Wiryo; shared NPC, V500+; cond `step:sq_k2=1`, `"quiet": true`; do `flag:sq_k2_wiryo`; completes `talked_to:kidul_jurukunci`)
| Key | ID | EN |
|-----|----|----|
| DLG_WIRYO_V500 | Yang tua penjaga muara itu? Bajul putih, buaya putih. Ia sudah di sana sebelum kita. | The old one who keeps the river mouth? The bajul putih, the white crocodile. It was there before us. |

#### Clues K2 (hunt `HUNT_SQ_K2_TITLE`; `k2_scale`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_K2_TITLE | Jaring yang Robek | The Torn Nets |
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
Card: giver Ciung Wanara in `kg_alun`; unlock `mqg_a1`. Steps 0 talk, 1 `clue_examined:c1_feathers` (`kg_pasar`) and `c1_basket` (the old river basket in `kg_kaputren`; zone docs put both clues in `kg_alun`), 2 `memory_done:sq_c1_basket`, 3 `area_entered:c1_rooster_found` (market rooftop perch puzzle), 4 talk with Ciung and Uwa Lengser about the basket token. The rooster is never handled in a fight (rule 1). Step 4 is **ASSUMED** as: Lengser's entry sets `flag:c1_token`, then Ciung's entry completes `talked_to:ciung_wanara`.
#### ciung_wanara, C1 entries (name NPC_CIUNG_WANARA_NAME; shared NPC, V500+ and the kept V30-V34; after his main-path entries)
| Entry | if | do |
|-------|----|----|
| c1_done | `quest:sq_c1=done` | |
| c1_token | `step:sq_c1=4`, `flag:c1_token` | `codex:ciung_egg` |
| c1_wait | `quest:sq_c1=active` | |
| c1_hook | `quest:sq_c1=available`, `flag:mqg_a1` | `start:sq_c1` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| c1_done | DLG_CIUNG_WANARA_V30 | Ia kembali. Ayam itu satu-satunya keluarga yang kutahu aku punya. | He's back. That rooster is the only family I knew I had. |
| c1_done | DLG_CIUNG_WANARA_V31 | Terima kasih. Kau tak membawa dia ke gelanggang, kan? Bagus. | Thank you. You didn't take him to the ring, did you? Good. |
| c1_token | DLG_CIUNG_WANARA_V504 | Lengser menunjukkan bandul itu padaku. Bandul kayu kecil, terikat di keranjang yang membawaku. | Lengser showed me the token. A small wooden charm, tied to the basket that carried me. |
| c1_token | @NPC_HERO_NAME | | |
| c1_token | DLG_CIUNG_WANARA_H501 | Ia mengikatnya sendiri. | He tied it himself. |
| c1_token | @NPC_CIUNG_WANARA_NAME | | |
| c1_token | DLG_CIUNG_WANARA_V505 | Lima belas tahun ia menyimpan rahasia itu dan tak sekali pun menaruh bebannya di pundakku. | Fifteen years he kept that secret and never once put its weight on my shoulders. |
| c1_token | DLG_CIUNG_WANARA_V506 | Aku marah sebentar. Lalu sadar: orang pertama yang menyayangiku adalah pelayan tua, bukan raja. | I was angry for a moment. Then I saw: the first person who loved me was an old servant, not a king. |
| c1_token | DLG_CIUNG_WANARA_V507 | Ayamku mengikutimu tanpa dipaksa. Mungkin ia lebih tahu siapa yang pantas dipercaya. | My rooster followed you without being forced. Maybe he knows better who deserves trust. |
| c1_token | DLG_CIUNG_WANARA_V508 | Terima kasih, kawan. Masih ada pintu istana yang harus kita buka. | Thank you, friend. There are still palace doors we have to open. |
| c1_wait | DLG_CIUNG_WANARA_V34 | Aku tak bisa meninggalkan perannya. Tolong cari dia. | I can't leave my part. Please find him. |
| c1_wait | DLG_CIUNG_WANARA_V503 | Bulunya di pasar, keranjang tua di kaputren. Dan kalau kau menemukan sesuatu yang aneh di keranjang itu, bawa pada Uwa Lengser. | His feathers in the market, an old basket in the kaputren. And if you find anything odd in that basket, take it to Uwa Lengser. |
| c1_hook | DLG_CIUNG_WANARA_V32 | Bertenggernya kosong. Ia kabur sebelum turnamen. | His perch is empty. He ran off before the tournament. |
| c1_hook | @NPC_HERO_NAME | | |
| c1_hook | DLG_CIUNG_WANARA_H500 | Kau yakin ia kabur, bukan dicuri? | Are you sure he ran, and wasn't stolen? |
| c1_hook | @NPC_CIUNG_WANARA_NAME | | |
| c1_hook | DLG_CIUNG_WANARA_V500 | Ayam itu tak mau dicuri. Ia mematuk tangan yang salah. | That bird won't be stolen. He pecks the wrong hand. |
| c1_hook | DLG_CIUNG_WANARA_V501 | Ia benci keramaian. Cari bulunya di pasar, dan keranjang sungai tua di kaputren. | He hates crowds. Look for his feathers in the market, and the old river basket in the kaputren. |
| c1_hook | DLG_CIUNG_WANARA_V502 | Jangan bawa ia dekat gelanggang. Aku cuma mau dia pulang. | Don't take him near the ring. I only want him home. |

#### lengser, C1 entry (Uwa Lengser; name NPC_LENGSER_NAME; shared NPC, V500+; cond `step:sq_c1=4`, `!flag:c1_token`; `"quiet": true`; do `flag:c1_token`)
| Key | ID | EN |
|-----|----|----|
| DLG_LENGSER_V500 | Bandul kayu itu. Kuukir sendiri di dapur istana, malam sebelum keranjang itu kuturunkan ke sungai. | That wooden charm. I carved it myself in the palace kitchen, the night before I lowered that basket to the river. |
| DLG_LENGSER_V501 | Aku tak bisa ikut, jadi kutitipkan sesuatu yang bisa menemaninya. Sebutir telur dan sebuah bandul. | I couldn't go, so I sent something to keep him company. An egg and a charm. |
| @NPC_HERO_NAME | | |
| DLG_LENGSER_H500 | Ciung menunggu untuk mendengarnya. | Ciung is waiting to hear it. |
| @NPC_LENGSER_NAME | | |
| DLG_LENGSER_V502 | Aku tahu. Lima belas tahun aku melatih kalimat pertamanya, dan sekarang semuanya hilang dari kepalaku. | I know. Fifteen years I rehearsed the first sentence, and now it's gone from my head. |
| DLG_LENGSER_V503 | Katakan padanya: Lengser tua ini menyesal sudah diam, tapi tak menyesal sudah menyelamatkannya. | Tell him: this old Lengser regrets his silence, but not saving him. |

### Beat `c1_rooster_found` (area `c1_rooster_found`; step 3)
| Key | ID | EN |
|-----|----|----|
| @ | | |
| BEAT_C1_ROOSTER_FOUND_2 | Kau memanjat ke atap pasar, mengikuti bulu hitam-emas dari satu genteng ke genteng berikutnya. | You climb to the market roof, following black-and-gold feathers from one tile to the next. |
| BEAT_C1_ROOSTER_FOUND_1 | Di balik tumpukan jerami, seekor ayam jantan bertengger tenang. Ia menatapmu, lalu mengikutimu tanpa suara. | Behind a stack of straw, a rooster sits calmly. He looks at you, then follows you without a sound. |
| @NPC_HERO_NAME | | |
| BEAT_C1_ROOSTER_FOUND_H1 | Aku teman Ciung. Ayo pulang. | I'm Ciung's friend. Let's go home. |
| @ | | |
| BEAT_C1_ROOSTER_FOUND_3 | Ia memiringkan kepala, mengenali nama itu, lalu melompat ke bahumu dengan cakar yang tertahan. | He tilts his head, knows the name, then hops onto your shoulder with his claws held back. |

#### Clues C1 (hunt `HUNT_SQ_C1_TITLE`; `c1_feathers` and `c1_basket`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_C1_TITLE | Ayam Jago Ciung | Ciung's Rooster |
| CLUE_C1_FEATHERS_1 | Bulu panjang berkilat, hitam dengan ujung emas, tersangkut di lapak penjual ayam. Ada jejak kaki kecil menuju gang belakang. | Long glossy feathers, black with gold tips, snagged at the rooster seller's stall. Small footprints lead into the back lane. |
| CLUE_C1_FEATHERS_2 | Si penjual bilang burung itu lewat dengan angkuh, tanpa membeli apa-apa. | The seller says the bird strutted past, buying nothing. |
| CLUE_C1_FEATHERS_NOTE | Bulu hitam-emas di pasar. | Black and gold feathers in the market. |
| CLUE_C1_BASKET_1 | Sebuah keranjang rotan tua teronggok di gudang kaputren, tepinya lapuk oleh air sungai. | An old rattan basket sits in a kaputren storeroom, its rim rotted by river water. |
| CLUE_C1_BASKET_2 | Sebuah bandul kayu kecil terikat di tepinya dengan simpul tua. Seseorang memahatnya dengan sayang. | A small wooden charm is tied to its rim with an old knot. Someone carved it with care. |
| CLUE_C1_BASKET_NOTE | Keranjang sungai tua dengan bandul kayu. | An old river basket with a wooden charm. |

#### Memory `sq_c1_basket` (play; kelir figure: a baby in a basket; the action holds the egg)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_C1_BASKET_TITLE | Bayi di Keranjang | The Baby in the Basket |
| MEM_SQ_C1_BASKET_IN | Dengarkan kisah ini, Nak: seorang bayi hanyut di sungai dalam keranjang, memeluk sebutir telur. Jaga telurnya. | Hear this tale, child: a baby drifts down the river in a basket, holding an egg. Keep the egg safe. |
| MEM_SQ_C1_BASKET_HINT | Jaga telurnya | Keep the egg safe |
| MEM_SQ_C1_BASKET_1 | Arus membawa keranjang menjauh dari tepi. Bayi itu memeluk telur erat-erat. | The current carries the basket from the bank. The baby holds the egg tight. |
| MEM_SQ_C1_BASKET_2 | Batu-batu mendekat. Keranjang berputar, tapi telurnya tak jatuh. | Rocks draw near. The basket spins, but the egg doesn't fall. |
| MEM_SQ_C1_BASKET_3 | Di tikungan sungai, telur itu retak. Seekor anak ayam keluar dan berkokok. | At a bend in the river, the egg cracks. A chick steps out and crows. |
| MEM_SQ_C1_BASKET_4 | Di tepi keranjang, sebuah bandul kayu berayun. Seorang tua di tepi sungai melambai sampai keranjang itu hilang dari pandang. | On the basket's rim a wooden charm swings. An old man on the bank waves until the basket is out of sight. |
| MEM_SQ_C1_BASKET_OUT | Begitulah ceritanya: dari telur itulah ayam jagonya datang. Dan seseorang melepasnya dengan tangan gemetar. | So the tale goes: from that egg came the rooster. And someone let go with shaking hands. |

VERIFY: the Ciung Wanara motif (the egg that became the rooster); the baby set adrift on a river; Lengser's part in it is the game's own.

### SQ-C2 "Surat di Seberang Pamali" / "Letters Across the Pamali" (Acts III-IV, M, cross-zone)
Card: giver Hariang Banga at `kg_pamali`; unlock `quest:mq2=done`. Steps 0 talk, 1 `talked_to:galuh_queen` (lines vary by Choice 3: `choice_mercy` or `choice_judgment`; v4 `choice_silent` is retired), 2 retrieve the Queen's heirloom signet from `kg_kaputren` (**ASSUMED** `clue_examined:c2_signet`, after a drawer puzzle and one fight; the card gives no id), 3 deliver her reply to Hariang Banga at his Tanah Timur camp (`tt_pasir`, **ASSUMED** `flag:c2_sealed` then his entry) and read the final note on Ibu's table (`clue_examined:c2_reply_letter`, completes the quest). Choice 3's labels and beats are in the Act III section; only its flags are used here.
#### hariang_banga, C2 entries (name NPC_HARIANG_BANGA_NAME; shared NPC, V500+ and the kept V10-V13)
| Entry | if | do |
|-------|----|----|
| c2_deliver | `step:sq_c2=3`, `flag:c2_sealed`, `zone:tt_pasir`, `!flag:c2_delivered` | `"quiet": true`, `flag:c2_delivered` |
| c2_wait | `quest:sq_c2=active` | |
| c2_hook_m | `quest:sq_c2=available`, `quest:mq2=done`, `flag:choice_mercy` | `start:sq_c2` |
| c2_hook_j | `quest:sq_c2=available`, `quest:mq2=done`, `flag:choice_judgment` | `start:sq_c2` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| c2_deliver | DLG_HARIANG_BANGA_V10 | Ibu membalas? Aku belum berani membaca. | Mother replied? I haven't dared read it. |
| c2_deliver | DLG_HARIANG_BANGA_V514 | Simpan di tasku. Aku akan membukanya di meja yang ada orang lain, supaya aku tak menangis sendirian. | Put it in my bag. I'll open it at a table with other people, so I don't weep alone. |
| c2_deliver | @NPC_HERO_NAME | | |
| c2_deliver | DLG_HARIANG_BANGA_H504 | Meja siapa? | Whose table? |
| c2_deliver | @NPC_HARIANG_BANGA_NAME | | |
| c2_deliver | DLG_HARIANG_BANGA_V515 | Entah. Yang jelas semeja dengan Ciung, kalau hari itu datang. Sekarang jalan ke gua Kala dulu. | I don't know. Certainly one I share with Ciung, if that day comes. For now, the road to Kala's cave. |
| c2_wait | DLG_HARIANG_BANGA_V13 | Sampaikan pada ibuku. Itu saja. | Take them to my mother. That's all. |
| c2_hook_m | DLG_HARIANG_BANGA_V11 | Ada seikat surat yang tak pernah kukirim. Untuk ibuku. | There's a bundle of letters I never sent. For my mother. |
| c2_hook_m | DLG_HARIANG_BANGA_V12 | Ia dikurung di Galuh. Bisakah kau membawanya? | She's caged in Galuh. Can you take them? |
| c2_hook_m | DLG_HARIANG_BANGA_V510 | Kau mengampuni lelaki di kandang itu. Aku tak bisa menyayanginya, tapi aku tak akan lupa kau melakukannya. | You showed mercy to the man in the cage. I can't love him, but I won't forget that you did. |
| c2_hook_m | DLG_HARIANG_BANGA_V512 | Aku menulis tiap malam sejak ibuku dikurung. Aku malu mengirimnya. | I've written every night since my mother was caged. I was too ashamed to send them. |
| c2_hook_m | @NPC_HERO_NAME | | |
| c2_hook_m | DLG_HARIANG_BANGA_H503 | Aku yang membawanya. | I'll carry them. |
| c2_hook_m | @NPC_HARIANG_BANGA_NAME | | |
| c2_hook_m | DLG_HARIANG_BANGA_V513 | Ia ada di penjara istana, di ujung galeri. Terima kasih. | She's in the palace cells, at the end of the gallery. Thank you. |
| c2_hook_j | DLG_HARIANG_BANGA_V516 | Ada seikat surat yang tak pernah kukirim. Untuk ibuku. Ia dikurung di Galuh, dan kau tahu itu. | There's a bundle of letters I never sent. For my mother. She's caged in Galuh, and you know it. |
| c2_hook_j | DLG_HARIANG_BANGA_V511 | Kau menghakimi lelaki itu, dan aku tak akan membantahmu. Tapi ibuku tak ikut memutuskan apa pun. | You judged that man, and I won't argue. But my mother had no part in deciding anything. |
| c2_hook_j | DLG_HARIANG_BANGA_V517 | Aku menulis tiap malam sejak ia dikurung. Aku malu mengirimnya. | I've written every night since she was caged. I was too ashamed to send them. |
| c2_hook_j | @NPC_HERO_NAME | | |
| c2_hook_j | DLG_HARIANG_BANGA_H505 | Aku yang membawanya. | I'll carry them. |
| c2_hook_j | @NPC_HARIANG_BANGA_NAME | | |
| c2_hook_j | DLG_HARIANG_BANGA_V518 | Ia ada di penjara istana, di ujung galeri. Tolong, sampaikan. | She's in the palace cells, at the end of the gallery. Please, deliver them. |

#### galuh_queen (the cage in Galuh; name NPC_GALUH_QUEEN_NAME; step 1 `talked_to:galuh_queen`, and the seal)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_c2=1`, `flag:choice_mercy` | `flag:c2_reply` |
| 2 | `step:sq_c2=1`, `flag:choice_judgment` | `flag:c2_reply` |
| 3 | `step:sq_c2=3`, `!flag:c2_sealed` | `"quiet": true`, `flag:c2_sealed` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_GALUH_QUEEN_V20 | Surat dari anakku. Kau datang dengan belas kasihan. | Letters from my son. You came with mercy. |
| 1 | DLG_GALUH_QUEEN_V21 | Tunggulah. Aku akan menulis balasan sederhana, supaya ia tahu aku masih ada. | Wait. I'll write a short reply, so he knows I'm still here. |
| 1 | DLG_GALUH_QUEEN_V25 | Tapi balasan tanpa cap hanyalah kertas. Cincin segelku tertinggal di kamar lamaku di kaputren. | But a reply without a seal is only paper. My signet ring was left in my old room in the kaputren. |
| 1 | DLG_GALUH_QUEEN_V26 | Penjaga tanpa wajah berjaga di sana. Ambilkan, dan bawa hati-hati. Cincin itu lebih tua dari kita semua. | Faceless guards watch there. Fetch it, and carry it carefully. That ring is older than all of us. |
| 2 | DLG_GALUH_QUEEN_V22 | Surat dari anakku. Kau datang bukan dengan belas kasihan, tapi dengan keadilan. | Letters from my son. You came not with mercy, but with judgment. |
| 2 | DLG_GALUH_QUEEN_V23 | Aku tak menyalahkanmu. Aku akan menulis, supaya ia tahu seorang ibu tak ikut menghakimi. | I don't blame you. I'll write, so he knows a mother took no part in the judging. |
| 2 | DLG_GALUH_QUEEN_V27 | Tapi tulisan tanpa cap hanyalah kertas. Cincin segelku tertinggal di kamar lamaku di kaputren. | But writing without a seal is only paper. My signet ring was left in my old room in the kaputren. |
| 2 | DLG_GALUH_QUEEN_V28 | Penjaga tanpa wajah berjaga di sana. Ambilkan, dan bawa hati-hati. | Faceless guards watch there. Fetch it, and carry it carefully. |
| 3 | DLG_GALUH_QUEEN_V29 | Cincinnya. Masih hangat dari kamar itu. | The ring. Still warm from that room. |
| 3 | DLG_GALUH_QUEEN_V30 | Lihat capnya. Tak seorang pun menyentuh surat ini selain aku dan anakku. | See the seal. Nobody touches this letter but me and my son. |
| 3 | DLG_GALUH_QUEEN_V31 | Bawa ke Hariang Banga di timur. Katakan ibunya masih menulis dengan tangannya sendiri. | Take it to Hariang Banga in the east. Tell him his mother still writes with her own hand. |
| 4 | DLG_GALUH_QUEEN_V24 | Waktu terasa panjang di kandang ini. | Time feels long in this cage. |

#### Clues C2 (hunt `HUNT_SQ_C2_TITLE`; `c2_signet` ASSUMED, in `kg_kaputren`; `c2_reply_letter`, on Ibu's table, cond `flag:c2_reply`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_C2_TITLE | Surat di Seberang Pamali | Letters Across the Pamali |
| CLUE_C2_SIGNET_1 | Di dasar laci rahasia, sebuah cincin segel emas kusam, berukir burung di atas gelombang. | In the bottom of a hidden drawer, a dull gold signet ring, carved with a bird above waves. |
| CLUE_C2_SIGNET_2 | Cap ini pernah menutup surat-surat raja. Kini ia akan menutup satu surat dari seorang ibu. | This seal once closed the king's letters. Now it will close a letter from a mother. |
| CLUE_C2_SIGNET_NOTE | Cincin segel sang permaisuri, dari laci rahasia kaputren. | The queen's signet ring, from a hidden drawer in the kaputren. |
| CLUE_C2_REPLY_LETTER_1 | Sepucuk surat terlipat di samping cangkir kedua. Tulisan tangannya halus, bukan milik Ibu. | A letter lies folded by the second cup. The handwriting is fine, not Ibu's. |
| CLUE_C2_REPLY_LETTER_2 | "Anakku, aku mendapat suratmu semua. Aku baik-baik saja. Pulanglah kalau sempat." | "My son, I got all your letters. I'm well. Come home if you can." |
| CLUE_C2_REPLY_LETTER_J_2 | "Anakku, aku mendapat suratmu semua. Aku tak menyalahkan siapa pun. Pulanglah kalau sempat." | "My son, I got all your letters. I blame no one. Come home if you can." |
| CLUE_C2_REPLY_LETTER_NOTE | Balasan sang permaisuri, di samping cangkir kedua. | The queen's reply, by the second cup. |

The judgment variant of the reply uses `_1` and `_NOTE` as above and `_J_2` for the second line (cond `flag:choice_judgment`).

### SQ-C3 "Nama si Pembelot (Ranga)" / "The Deserter's Name" (Acts III-VI, L, multi-act chain)
Card: giver Ranga (if `choice_freed`) or Uwa Lengser's notes (if `choice_handed`); unlock `mq2_7`. Steps 0 `clue_examined:c3_camp_scrap` (`mt_candi`), 1 `clue_examined:c3_road_mark` (`tt_pasir`), 2 `clue_examined:c3_shore_net` (`sk_nelayan`; zone docs `sk_pantai`) then `memory_done:sq_c3_ranga`, 3 `name_written:deserter_name` at `gk_pelataran`. The player does not learn the name "Ranga" until the write card: before it he is "the deserter", and quest text avoids the name. Freed: Ranga's first quiet talk starts the quest. Handed: **ASSUMED** the first clue starts it (no NPC gives it). The three scout spots for Ranga's quiet talks (`mt_candi`, `tt_pasir`, `sk_pantai`) are not in the zone docs.
#### faceless_deserter (freed variant, `flag:choice_freed`; quiet entries; name NPC_FACELESS_DESERTER_NAME; shared NPC, V500+ and the kept V20-V22)
| Entry | if | do |
|-------|----|----|
| c3_a | `flag:mq2_7`, `flag:choice_freed`, `zone:mt_candi`, `!flag:c3_a` | `"quiet": true`, `flag:c3_a`, `start:sq_c3` |
| c3_b | `flag:mq3_6`, `flag:choice_freed`, `zone:tt_pasir`, `!flag:c3_b` | `"quiet": true`, `flag:c3_b` |
| c3_c | `flag:mq4_4`, `flag:choice_freed`, `zone:sk_pantai`, `!flag:c3_c` | `"quiet": true`, `flag:c3_c` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| c3_a | DLG_DESERTER_V20 | Aku berjalan di pinggir kemah. Kalau kau tahu nama yang cocok untukku, ucapkan. | I walk at the camp's edge. If you know a name that fits me, say it. |
| c3_a | DLG_FACELESS_DESERTER_V500 | Ada secarik kain di tali jemuran dekat tangga candi. Kutemukan jariku menjahit satu bunyi di sana. | There's a scrap of cloth on a washing line by the temple stairs. I found my fingers stitching one sound on it. |
| c3_a | @NPC_HERO_NAME | | |
| c3_a | DLG_FACELESS_DESERTER_H500 | Kenapa kau menjahitnya? | Why did you stitch it? |
| c3_a | @NPC_FACELESS_DESERTER_NAME | | |
| c3_a | DLG_FACELESS_DESERTER_V501 | Tangan ini ingat lebih banyak daripada kepalaku. Lihatlah kainnya, kalau kau lewat. | These hands remember more than my head. See the cloth, if you pass by. |
| c3_b | DLG_DESERTER_V21 | Jalan ini panjang. Aku masih mencari bunyi yang cocok. | The road is long. I'm still looking for a sound that fits. |
| c3_b | DLG_FACELESS_DESERTER_V502 | Perisai tua yang tertancap di tepi jalan itu. Gambarnya kukenal: tanda pasukan yang dulu berbaris dari Galuh. | The old shield stuck in the roadside. I know its mark: the company that once marched out of Galuh. |
| c3_b | @NPC_HERO_NAME | | |
| c3_b | DLG_FACELESS_DESERTER_H501 | Perisaimu? | Your shield? |
| c3_b | @NPC_FACELESS_DESERTER_NAME | | |
| c3_b | DLG_FACELESS_DESERTER_V503 | Mungkin. Ada goresan di bagian dalam pinggirnya. Satu bunyi lagi. Lihatlah, kalau kau mau. | Maybe. There's a scratch on the inside rim. Another sound. Look, if you will. |
| c3_c | DLG_DESERTER_V22 | Ombak menyebut sesuatu. Aku hampir tahu. | The waves are saying something. I almost know. |
| c3_c | DLG_FACELESS_DESERTER_V504 | Ada bandul kayu terdampar di jaring nelayan. Aku tak berani menyentuhnya. Kalau itu milikku... | There's a driftwood charm tangled in a fisher's net. I daren't touch it. If it's mine... |
| c3_c | @NPC_HERO_NAME | | |
| c3_c | DLG_FACELESS_DESERTER_H502 | Aku yang akan melihatnya. | I'll look at it. |

#### Clues C3, freed (hunt `HUNT_SQ_C3_TITLE`; `c3_camp_scrap`, `c3_road_mark`, `c3_shore_net`)
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_C3_TITLE | Nama si Pembelot | The Deserter's Name |
| CLUE_C3_CAMP_SCRAP_1 | Secarik kain di tali jemuran Candi Seribu, dijahit dengan satu bunyi: "Ra." | A scrap of cloth on a washing line at Candi Seribu, stitched with one sound: "Ra." |
| CLUE_C3_CAMP_SCRAP_2 | Seseorang menjahitnya berulang-ulang, seperti belajar mengucapkannya. | Someone stitched it again and again, as if learning to say it. |
| CLUE_C3_CAMP_SCRAP_NOTE | Kain berjahit bunyi "Ra". | A cloth stitched with the sound "Ra". |
| CLUE_C3_ROAD_MARK_1 | Sebuah perisai tua tertancap di tepi jalan gurun, bertanda pasukan Galuh. Di dalam pinggirnya tergores satu bunyi: "Nga." | An old shield is stuck in the desert roadside, marked with Galuh's company sign. Inside its rim, one sound is scratched: "Nga." |
| CLUE_C3_ROAD_MARK_2 | Goresannya baru. Pemilik perisai ini lewat di sini, lalu pergi lagi. | The scratch is fresh. The shield's owner passed here, then went on. |
| CLUE_C3_ROAD_MARK_NOTE | Perisai tua bergores bunyi "Nga". | An old shield scratched with the sound "Nga". |
| CLUE_C3_SHORE_NET_1 | Di jaring nelayan di pasir hitam tersangkut bandul kayu hanyut, diukir dengan dua bunyi: Ra dan Nga. | Tangled in a fishing net on the black sand is a driftwood charm, carved with two sounds: Ra and Nga. |
| CLUE_C3_SHORE_NET_2 | Tiga petunjuk, dan tiga-tiganya bunyi yang sama. Bandul ini terasa seperti ingatan seseorang. | Three clues, all the same sounds. This charm feels like someone's memory. |
| CLUE_C3_SHORE_NET_NOTE | Bandul kayu hanyut dengan bunyi "Ra" dan "Nga". | A driftwood charm with the sounds "Ra" and "Nga". |

#### Clues C3, handed (Lengser's notes; keys with `B`)
| Key | ID | EN |
|-----|----|----|
| CLUE_C3_CAMP_SCRAP_B_1 | Catatan Lengser terselip di kemah: "Si pembelot di sel terus mengucap satu bunyi. Ra." | Lengser's note, tucked in the camp: "The deserter in the cell keeps saying one sound. Ra." |
| CLUE_C3_CAMP_SCRAP_B_2 | Ia mengucapkannya seperti seseorang yang ingin diingat. | He says it like someone who wants to be remembered. |
| CLUE_C3_ROAD_MARK_B_1 | Catatan kedua, terselip di balik perisai tua di tepi jalan: "Ia mengucap bunyi lain. Nga." | A second note, tucked behind an old shield by the road: "He says another sound. Nga." |
| CLUE_C3_ROAD_MARK_B_2 | Dari sel yang jauh, bunyi itu sampai ke jalan ini. | From a distant cell, the sound reaches this road. |
| CLUE_C3_SHORE_NET_B_1 | Catatan ketiga, terikat pada bandul kayu di jaring: "Ia berhenti berbicara. Dua bunyi saja yang tersisa." | A third note, tied to a wooden charm in the net: "He's stopped speaking. Only two sounds remain." |
| CLUE_C3_SHORE_NET_B_2 | Ra dan Nga. Tiga petunjuk sudah cukup untuk menuliskannya. | Ra and Nga. Three clues are enough to write it. |

#### Memory `sq_c3_ranga` (walk; opened by `c3_shore_net`; a soldier before the mask; the day his name was taken)
| Key | ID | EN |
|-----|----|----|
| MEM_SQ_C3_RANGA_TITLE | Hari Namanya Diambil | The Day His Name Was Taken |
| MEM_SQ_C3_RANGA_IN | Ingatan seseorang yang belum bernama, Nak: satu hari di kemah, lama sebelum kau lahir. Berjalanlah, dan dengarkan. | The memory of someone who has no name yet, child: one day in a camp, long before you were born. Walk, and listen. |
| MEM_SQ_C3_RANGA_1 | Seorang prajurit muda berdiri dalam barisan, di depan juru tulis yang memegang pisau kerok kecil. | A young soldier stands in line before a clerk holding a small scraping knife. |
| MEM_SQ_C3_RANGA_2 | Namanya dibacakan sekali. Lalu dikikis dari daftar, dan sebuah topeng polos diletakkan di wajahnya. | His name is read once. Then it is scraped from the roll, and a blank mask is set on his face. |
| MEM_SQ_C3_RANGA_3 | Sebelum itu ia sempat menyelipkan secarik kain di ikat pinggang. Dua bunyi dijahit dengan benang yang sama: Ra dan Nga. | Before that he managed to tuck a scrap of cloth into his belt. Two sounds stitched with the same thread: Ra and Nga. |
| MEM_SQ_C3_RANGA_4 | Hari itu ia lupa wajahnya sendiri. Tapi kain itu ikut berjalan, ke Galuh, ke candi, ke pantai. | That day he forgot his own face. But the cloth kept walking, to Galuh, to the temple, to the shore. |
| MEM_SQ_C3_RANGA_OUT | Begitulah ceritanya: namanya tak hilang. Ia hanya disimpan di tempat paling jauh. Tuliskan, Nak. | So the tale goes: his name wasn't lost. It was kept in the farthest place. Write it, child. |

#### deserter_stone (Gua Kala, `gk_pelataran`; write card; name NPC_DESERTER_STONE_NAME; speaks Ranga's name only here)
| Entry | if | do |
|-------|----|----|
| 1 | `step:sq_c3=3`, `!flag:name_deserter_name` | `write:deserter_name:jawa_ra,sunda_nga`, `flag:name_deserter_name` |
| 2 | `name_written:deserter_name`, `flag:choice_freed` | `flag:deserter_named`, `codex:deserter_name` |
| 3 | `name_written:deserter_name`, `flag:choice_handed` | `flag:deserter_named`, `codex:deserter_name` |
| 4 | (none) | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| 1 | DLG_DESERTER_STONE_V20 | Sebuah batu pipih di halaman gerbang. Tiga petunjuk menunjuk dua bunyi: Ra dan Nga. | A flat stone in the gate courtyard. Three clues point to two sounds: Ra and Nga. |
| 1 | DLG_DESERTER_STONE_V21 | Tulislah, supaya ia mendengar. | Write it, so he can hear. |
| 2 | DLG_DESERTER_STONE_V22 | Ranga. Ia berdiri di sampingmu, dan akhirnya mendengar namanya. | Ranga. He stands beside you, and at last he hears his name. |
| 2 | @NPC_FACELESS_DESERTER_NAME | | |
| 2 | DLG_FACELESS_DESERTER_V505 | Ra. Nga. Ranga. Tukang gerabah dari tepi sungai, bukan topeng. | Ra. Nga. Ranga. A potter from the riverbank, not a mask. |
| 2 | DLG_FACELESS_DESERTER_V506 | Aku akan berdiri di sisimu di gerbang ini, kawan. Kali ini dengan namaku sendiri. | I'll stand at your side at this gate, friend. This time with my own name. |
| 3 | DLG_DESERTER_STONE_V23 | Ranga. Hanya batu yang mendengarnya. Di Galuh, sebuah sel menjadi sunyi. | Ranga. Only the stone hears it. In Galuh, a cell goes quiet. |
| 4 | DLG_DESERTER_STONE_V24 | Batu pipih yang dingin. | A flat, cold stone. |

ASSUMED: the Deserter's name Ranga (an ordinary Sundanese name). Steps 2 and 3 set `flag:deserter_named`; `deserter_mouth` says V1 ("I remembered my name") only after it, V2 before ("Staging NPCs"). After this write the display name `NPC_FACELESS_DESERTER_NAME` should read "Ranga" in Gua Kala (an Act VI text change, not made here).

### SQ-C4 "Cepot Si Pemberani (Bagian 2 & 3)" / "Brave Cepot" (Acts III and V, S each)
Part 2 (`sq_c4_2`, Act III, `mt_gapura`): steps 0 `clue_examined:c4_roll_a` and `c4_roll_b`, 1 `area_entered:c4_market_clear` (the stealth puzzle), 2 `talked_to:cepot`, sets `c4_2`. Part 3 (`sq_c4_3`, Act V, `sk_pantai`): steps 0 `talked_to:cepot`, 1 `trial_completed:c4_lamp` (the card says a two-wave night defense; the zone doc says one 8-second wave), 2 `talked_to:cepot`, sets `c4_done`. Part 1 is under SQ-S4.
#### cepot, C4 entries (name NPC_CEPOT_NAME; shared NPC; the kept V20-V27 and new V510+)
| Entry | if | do |
|-------|----|----|
| c4_3_done | `step:sq_c4_3=2` | `flag:c4_done` |
| c4_3_wait | `quest:sq_c4_3=active` | |
| c4_3_hook | `quest:sq_c4_3=available`, `flag:c4_2`, `flag:mq4_4` | `start:sq_c4_3` |
| c4_2_done | `step:sq_c4_2=2` | `flag:c4_2` |
| c4_2_wait | `quest:sq_c4_2=active` | |
| c4_2_hook | `quest:sq_c4_2=available`, `flag:c4_1`, `flag:mq2_a1` | `start:sq_c4_2` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| c4_2_hook | DLG_CEPOT_V20 | Aku daftar jadi prajurit di dua sisi sekaligus! Pasar sungai ini hebat. | I signed up as a soldier on both sides at once! This river market is great. |
| c4_2_hook | DLG_CEPOT_V21 | Eh, kata mereka itu masalah. Lihat daftarnya, lalu bantu aku keluar sebelum ada yang sadar. | Er, they say that's a problem. See the rolls, then help me out before anyone notices. |
| c4_2_hook | @NPC_HERO_NAME | | |
| c4_2_hook | DLG_CEPOT_H510 | Kau tidak membaca syaratnya? | You didn't read the terms? |
| c4_2_hook | @NPC_CEPOT_NAME | | |
| c4_2_hook | DLG_CEPOT_V510 | Syaratnya panjang, Nak. Gajinya pendek. Aku menilai dari bagian yang gampang. | The terms were long, child. The pay was short. I judged by the easy part. |
| c4_2_wait | DLG_CEPOT_V22 | Jangan berisik. Mereka masih mencari-cari. | Don't be loud. They're still looking around. |
| c4_2_done | DLG_CEPOT_V23 | Aku selamat! Aku memang pemberani. Sedikit. | I'm safe! I'm brave, you know. A little. |
| c4_2_done | DLG_CEPOT_V511 | Jangan ceritakan ke Bapak. Kalau ia tanya, aku cuma tersasar ke pasar. | Don't tell Bapak. If he asks, I only got lost in a market. |
| c4_3_hook | DLG_CEPOT_V24 | Aku mengikutimu sampai ke pantai! Tapi lautnya besar sekali. Aku takut. | I followed you all the way to the beach! But the sea is so big. I'm scared. |
| c4_3_hook | DLG_CEPOT_V25 | Tukik-tukik itu butuh cahaya. Pegang lenteranya dengan aku, ya? | The hatchlings need light. Hold the lamp with me, will you? |
| c4_3_wait | DLG_CEPOT_V26 | Sedikit lagi. Jangan lepaskan lenteranya. | Nearly there. Don't let go of the lamp. |
| c4_3_done | DLG_CEPOT_V27 | Ombaknya lewat, dan aku masih di sini. Nanti kuceritakan ke semua orang! | The wave passed, and I'm still here. I'll tell everyone! |
| c4_3_done | DLG_CEPOT_V512 | Bapak bilang berani itu bukan tak takut, tapi tetap berdiri sambil takut. Aku berdiri. Sedikit gemetar. | Bapak says brave isn't having no fear, but standing while afraid. I stood. A little shaky. |

#### Clues C4 (part 2; hunt `HUNT_SQ_C4_TITLE`) and the lamp hint
| Key | ID | EN |
|-----|----|----|
| HUNT_SQ_C4_TITLE | Cepot Si Pemberani | Brave Cepot |
| CLUE_C4_ROLL_A_1 | Daftar perekrut Sunda di pasar sungai. Di bagian bawah, tertulis dengan huruf besar-besar: "Cepot." | The Sunda recruiter's roll at the river market. At the bottom, in large letters: "Cepot." |
| CLUE_C4_ROLL_A_2 | Ia mendaftarkan diri tanpa membaca syaratnya. | He signed up without reading the terms. |
| CLUE_C4_ROLL_A_NOTE | Nama Cepot di daftar perekrut Sunda. | Cepot's name on the Sunda recruiter's roll. |
| CLUE_C4_ROLL_B_1 | Daftar perekrut Jawa. Di bagian bawah lagi: "Cepot", dengan hiasan di huruf pertama. | The Java recruiter's roll. At the bottom again: "Cepot," with a flourish on the first letter. |
| CLUE_C4_ROLL_B_2 | Dua daftar, satu nama. Kalau ketahuan, ia akan dalam kesulitan. | Two rolls, one name. If found out, he'll be in trouble. |
| CLUE_C4_ROLL_B_NOTE | Nama Cepot di daftar perekrut Jawa. | Cepot's name on the Java recruiter's roll. |
| HINT_C4_LAMP | Pegang lenteranya | Hold the lamp |

VERIFY: Cepot's humor as in wayang golek (no new culture claim). The lamp over the hatchlings' beach reuses SQ-K1's area, with the same conservation note.

### Hub meta quests (Desa Purwa; quests.md section 6)
Both cards have only thresholds, no step lines; the lines below are the thresholds' talks. The flags `lakon_4`, `lakon_9`, `codex_25`, `codex_50`, `codex_75` and `codex_100` are **ASSUMED** (set by the game when the count is reached). Rewards (Flask Shard #3, Ilmu, Lontar Kuno, the credits tribute) come from the QuestData.

#### semar, SQ-D1 entries (the wayang stage; name NPC_SEMAR_NAME; shared NPC, V500+; quiet; after his other entries)
| Entry | if | do |
|-------|----|----|
| d1_nine | `flag:lakon_9`, `!flag:d1_nine_told` | `"quiet": true`, `flag:d1_nine_told` |
| d1_four | `flag:lakon_4`, `!flag:d1_four_told` | `"quiet": true`, `flag:d1_four_told` |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| d1_nine | DLG_SEMAR_V520 | Sembilan lakon, Nak. Sembilan kisah yang kau mainkan dengan kakimu sendiri, bukan cuma dengan lidahmu. | Nine lakon, child. Nine tales you played with your own feet, not just your tongue. |
| d1_nine | DLG_SEMAR_V521 | Di akhir pertunjukan nanti, kelir akan punya satu bait khusus untuk mereka semua. Hehe, jangan bilang siapa-siapa. | At the end of the show, the kelir will have a special verse for all of them. Hehe, tell no one. |
| d1_four | DLG_SEMAR_V522 | Empat lakon sudah kau hidupkan. Dalang lama akan bilang itu cukup untuk satu pecahan labu. | Four lakon you've brought to life. An old dalang would say that's worth a flask shard. |
| d1_four | DLG_SEMAR_V523 | Ambillah. Dan teruslah mengumpulkan. Panggungku selalu muat satu kisah lagi. | Take it. And keep collecting. My stage always has room for one more tale. |

#### nyai_rukmi (the codex keeper; name NPC_NYAI_RUKMI_NAME; replace all entries; SQ-D2 thresholds and a hub)
| Entry | if | do | choices |
|-------|----|----|---------|
| r100 | `flag:codex_100`, `!flag:rukmi_100` | `flag:rukmi_100` | |
| r75 | `flag:codex_75`, `!flag:rukmi_75` | `flag:rukmi_75` | |
| r50 | `flag:codex_50`, `!flag:rukmi_50` | `flag:rukmi_50` | |
| r25 | `flag:codex_25`, `!flag:rukmi_25` | `flag:rukmi_25` | |
| hub | (none) | `"hub": true` | CHOICE_NYAI_RUKMI_ASK_1 to `topic:lontar`; CHOICE_NYAI_RUKMI_ASK_2 to `topic:catatan`; CHOICE_NYAI_RUKMI_ASK_3 to `topic:lupa`; CHOICE_NYAI_RUKMI_ASK_4 (leave) |
| topic lontar | `"topic": "lontar"` | `"quiet": true` | |
| topic catatan | `"topic": "catatan"` | `"quiet": true` | |
| topic lupa | `"topic": "lupa"` | `"quiet": true` | |

| Entry | Key | ID | EN |
|-------|-----|----|----|
| r100 | DLG_NYAI_RUKMI_V30 | Seratus bagian dari seratus. Bukuku penuh, dan kau tahu apa yang paling kusuka? Halaman kosong di belakangnya. | A hundred out of a hundred. My book is full, and do you know what I like best? The blank pages at the back. |
| r100 | DLG_NYAI_RUKMI_V31 | Berkat dari penjaga catatan untukmu, dan namamu akan tercantum di akhir kisah ini. Hehe, seperti dalang. | A keeper's blessing for you, and your name will stand at the end of this tale. Hehe, like a dalang. |
| r75 | DLG_NYAI_RUKMI_V32 | Tiga perempat sudah tercatat. Kau mulai bisa membedakan kisah yang diceritakan dari kisah yang dijalani. | Three quarters written down. You're starting to tell a tale that is told from one that is lived. |
| r75 | DLG_NYAI_RUKMI_V33 | Ini ilmu dari catatanku. Pakailah dengan baik. | Here is learning from my notes. Use it well. |
| r50 | DLG_NYAI_RUKMI_V34 | Separuh bukuku sudah terisi. Ini lontar kuno yang kusimpan dari kakekku. Jaga baik-baik, ya. | Half my book is filled. Here's an old lontar I kept from my grandfather. Look after it. |
| r50 | DLG_NYAI_RUKMI_V35 | Isinya bukan mantra. Hanya catatan orang yang tak mau lupa. | It isn't a spell. Only the notes of someone who refused to forget. |
| r25 | DLG_NYAI_RUKMI_V36 | Seperempat sudah kutulis berkat kau. Terimalah sedikit ilmu dari catatanku, sebagai upah juru tulis. | A quarter written thanks to you. Take a little learning from my notes, a scribe's wage. |
| hub | DLG_NYAI_RUKMI_V37 | Tehku hangat dan bukuku terbuka. Mau tahu sesuatu? | My tea is warm and my book is open. Want to know something? |
| topic lontar | DLG_NYAI_RUKMI_V38 | Lontar itu daun palem yang diiris, dikeringkan, lalu digores dengan pisau kecil dan dihitamkan dengan jelaga. | Lontar is palm leaf, sliced, dried, scratched with a small knife and blackened with soot. |
| topic lontar | DLG_NYAI_RUKMI_V39 | Tulisannya tak bisa dihapus, hanya bisa dilupakan. Itu sebabnya kita menjaganya. | The writing can't be erased, only forgotten. That's why we keep it. |
| topic catatan | DLG_NYAI_RUKMI_V40 | Tiap legenda yang kau temui kutulis dua kali. Sekali apa yang diceritakan, sekali apa yang kau lihat sendiri. | Every legend you meet I write twice. Once as it's told, once as you saw it yourself. |
| topic catatan | DLG_NYAI_RUKMI_V41 | Kalau keduanya berbeda, aku tak memilih. Aku menaruhnya berdampingan. | When the two differ, I don't choose. I set them side by side. |
| topic lupa | DLG_NYAI_RUKMI_V42 | Lupa bukan musuh, Nak. Lupa yang tak diberi nama itu yang berbahaya. | Forgetting isn't the enemy, child. Forgetting without a name is the dangerous kind. |
| topic lupa | DLG_NYAI_RUKMI_V43 | Karena itu aku menulis. Satu nama di buku ini lebih tahan lama daripada seribu kata yang kuucapkan. | That's why I write. One name in this book lasts longer than a thousand words I say. |

| Key | ID | EN |
|-----|----|----|
| CHOICE_NYAI_RUKMI_ASK_1 | Tentang lontar. | About lontar. |
| CHOICE_NYAI_RUKMI_ASK_2 | Tentang catatanmu. | About your notes. |
| CHOICE_NYAI_RUKMI_ASK_3 | Tentang lupa. | About forgetting. |
| CHOICE_NYAI_RUKMI_ASK_4 | Cukup, terima kasih. | That's enough, thank you. |
