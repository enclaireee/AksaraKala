# Items

Phase 7c revamp (2026-11-27, user call, all **ASSUMED** unless tagged). Every pickup is one of three things:
- **Power**: the Kujang Pusaka spine (section 1). One predictable vertical step per main boss.
- **Choice**: weapons, armor and jimat (sections 2 to 4). A budgeted build that is swapped at the checkpoint.
- **Meaning**: every item has a lore line and a codex page (section 7).

Rules:
- Every item is a data resource ([architecture.md](architecture.md)), so adding items is data entry.
- Two gear slots (weapon, armor) plus the **Jimat** set, which replaces the old accessory slot.
- No random loot, no rarity tiers, no crafting, no per-item upgrades. The pusaka's Ingatan is the only upgrade. Each item has a `mythic` flag, which gives a gold name.
- **No dominated loot.** A weapon earns its place with a twist (shape, speed or a bonus key), not a bigger number.
- **Weapon cap.** `damage x (1 + damage_mult)` is at most 1.25x the starter of its class (favoured items) or its archetype (other items):
  - Archetype starters: light (Dagger) 8, heavy (Broadsword) 22, ranged (Hunting Bow) 8, staff (Oak Staff) 8.
  - Class starters: Lancer (Tombak Prajurit) 20, Herder (Bandring) 10, Dancer (Kipas) 7, Dalang (Kayon) 8.
  - The one exception is the Keris Mpu Gandring, which is paid for with its curse.
  - `tests/items_test.gd` enforces the cap.
- Every item has a source (`tests/item_source_test.gd`) and a lore line in ID and EN (`data/text/items.csv`).
- Every bonus key set in data is read in code (`items_test`).
- Culture facts carry **VERIFY** until sourced. Numbers are **TUNE**.

## 1. The Kujang Pusaka and Ingatan (the spine)
**Story.**
- At MQ0 0.10, Ibu takes the family kujang down from the wall and gives it to you: "I don't know why I took it down today. Take it." She no longer remembers Laras. The kujang is the house's memory of her.
- At 0.11, Semar teaches **jamasan**: a pusaka is washed so it remembers.
- **VERIFY:** the kujang as a Sundanese family heirloom; *jamasan* as the ritual cleansing of a pusaka, usually in the month of Sura; *sipat kandel* as a pusaka carried for protection. The game's jamasan, which happens at any petilasan after a great deed, is a game rule, and the text says so.

**Rules.**
- The kujang is carried, not wielded, so it has no slot and every weapon stays relevant. It is the flag `has_pusaka` plus the int `Game.ingatan`, not an `ItemData` resource.
- **Ingatan tier**, 0 to 4. Each main boss you defeat makes one **jamasan** available:
  - Sangkuriang (Act I)
  - Bandung Bondowoso (Act III)
  - The Keris (Act IV)
  - The Nyi Roro Kidul trial (Act V)
- `Game.jamasan_pending()` = main bosses in `killed` − `ingatan`. It is derived from `killed`, so there is no new currency.
- A jamasan is done from the **Status tab at a petilasan** (`menu.at_petilasan`). It plays a short ritual card and one memory line per tier (script.md).
- Each tier gives **+10% to all weapon and spell damage** (`Game.power_mult()` = `1 + 0.10 x ingatan`, **TUNE**, [balance.md](balance.md) 3.1) and **+1 Daya** (section 4).
- The pusaka has a codex page (`data/codex/kujang.tres`, category item) that shows its current tier.

**Payoffs** (script.md):
- **Act IV:** Mpu Wirasana reads the kujang's pamor and ties it to the Keris seal. This is a dialogue line only.
- **Interlude 4.4:** Ibu recognises the kujang, one line that pays off the arc.

## 2. Weapons
Archetypes (light melee, heavy melee, ranged, staff) differ by behaviour ([combat.md](combat.md) 2.3). Shape fields (`reach`, `arc`, `windup`, `recovery`, `projectile_speed`, `projectile_range`) give common weapons their twist.

### 2.1 Common
| Item | Archetype | Dmg | Twist | Source |
|------|-----------|-----|-------|--------|
| Dagger | Light | 8 | Fast, short reach | Starter (Rogue) |
| Broadsword | Heavy | 22 | Wide swing | Starter (Warrior) |
| Axe | Heavy | 26 | Wide arc (130°), slow | Zone 2 chest |
| Spear | Heavy | 27 | Longest common reach, narrow arc | SQ-M3 Tuyul bounty |
| Golok | Heavy | 25 | Fast heavy chop, short reach | SQ-S2 Kuntilanak bounty |
| Hunting Bow | Ranged | 8 | 4 stamina per shot | Starter (Archer) |
| Crossbow | Ranged | 10 | Slow wind-up, fast bolt, longest range | Zone 3 chest |
| Oak Staff | Staff | 8 | Weak ranged bolt | Starter (Mage) |

The Short Sword, Iron Staff and Longbow are **deleted**. Each was its starter plus 1, so it was dominated loot. Their chests now hold jimat (section 4.2).

### 2.2 Mythic (pusaka)
| Item | Archetype | Dmg | Twist | Notes (culture) | Source |
|------|-----------|-----|-------|-----------------|--------|
| Keris Luk 7 | Light | 10 | +6 Sakti on a perfect dodge (`dodge_sakti`) | A keris with 7 curves (*luk*; keris luk are odd numbers 3 to 13). The meaning of 7 varies by source, so the text says "traditionally associated with". The keris is UNESCO Intangible Heritage (2008), a sacred pusaka, and is treated respectfully | SQ-T3 Pamor errand |
| Keris Mpu Gandring | Light | 14 | Cursed: each hit costs 1 HP (`self_damage`). The one exception to the cap | In the Pararaton legend (label it legend), the keris was forged unfinished for Ken Arok and Mpu Gandring's dying curse followed it. **VERIFY** | MQ3 Choice 4, reforge |
| Panah Pasopati | Ranged | 10 | +10% Sakti gain | Named after Arjuna's arrow. Who gave it to him is unconfirmed | Zone 2 secret |
| Cakra | Ranged | 6 | Thrown disc that **returns like a boomerang** and hits on the way back (`sakti_per_hit` 2.5) | Kresna's disc (Cakra Baskara or Sudarsana) in wayang | SQ-K2 sea spirit bounty |
| Gada Rujakpolo | Heavy | 27 | Very wide arc (170°), slow: windup 0.35 s, recovery 0.5 s, cost 28, `sakti_per_hit` 14, 27.8 dps vs the broadsword 27.5 (TUNE) | Bima's club in wayang. **VERIFY** the name and the owner | sk_karang chest (`kidul_chest_2`), Act V |
| Teken Galih Asem | Staff | 10 | +10% spell damage (`spell_mult`) | A walking staff of tamarind heartwood, carried by a wandering ascetic. **VERIFY** *teken* and *galih asem* as an ascetic's staff | tt_pesisir wreck chest (`chest_tt_pesisir`), Act IV |

The old Kujang weapon is **deleted**. Its name and codex entry move to the Kujang Pusaka (section 1).

## 3. Armor
One body slot. `defense` gives 5% damage reduction per point ([rpg.md](rpg.md) 5). The mythic armors each get a twist.

| Item | Tier | Def | Twist | Source |
|------|------|-----|-------|--------|
| Padded Tunic | Common | 1 | Plain padded cloth | Starter |
| Leather Armor | Common | 2 | Light and quiet | Zone 1 chest |
| Chainmail | Common | 4 | Heavy rings of iron, status effects −25% (`status_short`) | Zone 3 chest |
| Iket Sunda | Mythic | 2 | Smudged-cast threshold −0.02 (`smudge`) | Sundanese cloth head wrap, tied by the wearer. From SQ-S1 Lutung Kasarung |
| Blangkon | Mythic | 3 | +5% Sakti gain | Javanese ready-made batik head cloth. From SQ-M4 Gamelan errand |
| Baju Batik | Mythic | 4 | +15 max HP | Batik clothing whose patterns carry meaning (use a named pattern with a verified meaning). From the MQ2 boss, Bandung Bondowoso |
| Kain Hijau | Mythic | 5 | Flask heals +10% (`flask_heal`) | Green cloth linked to Nyi Roro Kidul lore (a belief, see world.md). From MQ4 4.22 at the Sea Altar (`give:kain_hijau`) |

The class-favoured armors are in section 5.

## 4. Jimat (replaces the accessory slot)
### 4.1 Daya
- **Daya** is the budget: `Game.daya()` = 2 + `ingatan`, so it runs from 2 to 6.
- Each jimat costs 1 to 3 Daya (the `daya` field on `ItemData`).
- Worn jimat are `Game.jimat`, an Array of ids. Bonuses sum like gear bonuses, and favoured bonuses still apply.
- You can equip any set whose total cost is within the budget. `Game.equip_jimat(id)` refuses a set that goes over and returns false.
- **Jimat are swapped only at a petilasan.** Weapons and armor can still be changed anywhere.
- **Damage cap.** Within the largest budget, worn jimat add at most +10% weapon damage and +10% spell damage, outside the Rajah window. `balance_model.py` section 7.5 checks this.
- A 100% player owns about 30 Daya of jimat against a budget of 6 at most, so the choice stays real.

### 4.2 Roster
New bonus keys:
- `spell_mult`: spell damage fraction.
- `flask_heal`: multiplies the flask heal.
- `dodge_sakti`: Sakti on a perfect dodge.
- `ilmu_mult`: Ilmu gain fraction.
- `low_hp_damage`: damage fraction while below 30% HP.
- `kill_heal`: HP per kill.
- `status_short`: fraction cut from the duration of status effects on you.

The existing keys are listed in [classes.md](classes.md).

| Jimat | Daya | Effect (bonus keys) | Notes | Source |
|-------|------|---------------------|-------|--------|
| Iron Ring | 2 | +5% damage (`damage_mult`) | A plain band | Zone 1 chest |
| Stone Ring | 2 | +5% spell damage (`spell_mult`) | A ring with a stone | SQ-T1 Ande-Ande Lumut |
| Amulet | 1 | +15 max HP | A small charm | MQ0 reward |
| Feather Charm | 1 | +8% move speed | Light as a feather | SQ-M1 Jaka Tarub |
| Silver Bangle | 1 | +10% stamina regen | | SQ-S4 Cepot |
| Kembang Setaman | 1 | Flask heals +10% (`flask_heal`) | Seven kinds of flowers floated in water for blessing and cleansing. **VERIFY** | ts_situ chest (`sunda_kujang`, was the Kujang) |
| Batu Akik | 1 | +4 Sakti on a perfect dodge (`dodge_sakti`) | A polished agate ring stone. **VERIFY** the protective beliefs | ts_sawah chest (`sunda_chest_sawah`, was the Short Sword) |
| Kemenyan | 1 | +10% Ilmu (`ilmu_mult`) | Benzoin incense, burned to send words to the ancestors. **VERIFY** | mt_reruntuhan secret (`mataram_secret_gong`, was the Longbow) |
| Jimat (mythic) | 2 | +4 HP per kill (`kill_heal`) | A small protective charm, carried for luck and protection | SQ-M2 Wewe Gombel |
| Lontar Kuno (mythic) | 2 | Smudged-cast threshold −0.05 (`smudge`) | Old palm-leaf manuscript, how aksara were written | SQ-D2 Pustaka, 50% codex |
| Batu Kali (mythic) | 2 | Status effects on you last 50% shorter (`status_short`), +5% stamina regen | A smooth river stone the river gives back when you sink the keris | MQ3 Choice 4, sink |
| Rajah (mythic) | 2 | +20% damage while below 30% HP (`low_hp_damage`) | A written protective formula. **VERIFY** *rajah* as written protective script | mt_wetan chest (`mataram_chest_wetan`, was the Iron Staff) |
| Gelang Akar Bahar (mythic) | 2 | +6% damage reduction (`defense`) | A bangle of black sea coral. **VERIFY** the coastal belief | sk_tebing chest (`kidul_chest_3`), Act V |
| Sabuk Galuh (mythic) | 3 | +8% damage reduction, +1 Vitality | A royal belt of Galuh, a ward from the court smiths | MQ2 Choice 3, judgment |
| Mustika (mythic) | 3 | +12% Sakti gain, +5% spell damage | A *mustika*: a pearl or stone believed to hold power. **VERIFY** | gk_mulut chest (`kala_chest_0`), Act VI |

Every class-favoured jimat (section 5) costs **2 Daya**.

## 5. Class-favoured gear (Phase 4g, numbers **TUNE**)
- Anyone can equip these. The favoured class also gets the last column (`favoured`, `favoured_bonus`). The equipment card shows "Favoured: <class>".
- The icons are recolours of a kin icon (`RECOLOUR` in `tools/gen_items.py`).
- **VERIFY** the marked names before shipping.

**Schools.**

| Item (id) | Slot | Stats | Favoured class: extra | Source |
|---|---|---|---|---|
| Parang Perang (`parang_perang`) | Heavy | 24 dmg, quicker swing | Hulubalang: +10% damage | Zone chest |
| Tombak Panji (`tombak_panji`) | Heavy | 27 dmg, long reach | Hulubalang: +1 Vitality | SQ-X1 |
| Zirah Sisik (`zirah_sisik`) | Armor | Def 4 | Hulubalang: +5% damage reduction | Zone chest |
| Gelang Baja (`gelang_baja`) | Jimat 2 | +5% damage reduction | Hulubalang: +1 Strength | Zone chest (`mt_tegal`) |
| Busur Petung (`busur_petung`) | Ranged | 7 dmg, 3 stamina, fast | Pamanah: +10% damage | Zone chest |
| Gendewa Tanduk (`gendewa_tanduk`) | Ranged | 10 dmg | Pamanah: +1 Dexterity | SQ-X1 |
| Kampret Pemburu (`kampret_pemburu`) | Armor | Def 2, +5% move speed | Pamanah: +10% stamina regen | Zone chest |
| Kantong Panah (`kantong_panah`) | Jimat 2 | +10% stamina regen | Pamanah: +1 Dexterity | Zone chest (`tt_kulon`) |
| Golok Pendek (`golok_pendek`) | Light | 9 dmg | Pendekar: +10% damage | Zone chest |
| Kujang Kembar (`kujang_kembar`) | Light | 10 dmg, very fast. **VERIFY**: a paired fighting use of the kujang is a game invention, and the text must say so | Pendekar: +1 Dexterity | SQ-X1 |
| Pangsi Hitam (`pangsi_hitam`) | Armor | Def 2, +8% move speed. **VERIFY**: pangsi as silat and daily Sundanese clothing | Pendekar: +10% stamina regen | Zone chest |
| Sabuk Merah (`sabuk_merah`) | Jimat 2 | +1 Endurance | Pendekar: +1 Strength | SQ-G1 Si Kabayan |
| Tongkat Genta (`tongkat_genta`) | Staff | 9 dmg, 6 Sakti per hit | Wiku: +10% Sakti gain | Zone chest |
| Tongkat Cendana (`tongkat_cendana`) | Staff | 10 dmg | Wiku: +1 Spirit | SQ-X1 |
| Jubah Wiku (`jubah_wiku`) | Armor | Def 1, +1 Spirit | Wiku: +10% Sakti gain | Zone chest |
| Genitri (`genitri`) | Jimat 2 | +1 Spirit. **VERIFY**: genitri (rudraksha) prayer beads | Wiku: smudge threshold −0.03 | SQ-G2 Ririwa |

**Second paths.** Each row is the sibling of the school item named in the last column. `Game.SIBLING_ITEM` swaps it in for a second-path player.

| Item (id) | Slot | Stats | Favoured class: extra | Sibling of |
|---|---|---|---|---|
| Tombak Galah (`tombak_galah`) | Heavy | 22 dmg, longest reach | Prajurit: +15% tip sweet-spot damage | `parang_perang` |
| Tombak Bendera (`tombak_bendera`) | Heavy | 25 dmg, long reach | Prajurit: +15% melee and spell reach | `tombak_panji` |
| Baju Keprajuritan (`baju_keprajuritan`) | Armor | Def 4. **VERIFY**: keraton soldier dress | Prajurit: 15% faster Kuda-kuda brace | `zirah_sisik` |
| Tameng Rotan (`tameng_rotan`) | Jimat 2 | +5% damage reduction | Prajurit: +15 stamina when hit while braced | `gelang_baja` |
| Bandring Kulit (`bandring_kulit`) | Ranged | 8 dmg, 3 stamina, fast | Pangangon: +35 px Batu Pantul bounce range | `busur_petung` |
| Bandring Ijuk (`bandring_ijuk`) | Ranged | 11 dmg | Pangangon: +20% Batu Pantul bounce damage | `gendewa_tanduk` |
| Sarung Gembala (`sarung_gembala`) | Armor | Def 2, +5% move speed | Pangangon: +15% dodge distance | `kampret_pemburu` |
| Suling Bambu (`suling_bambu`) | Jimat 2 | +10% stamina regen | Pangangon: +20% zone and summon duration (`zone_life`) | `kantong_panah` |
| Kipas Bambu (`kipas_bambu`) | Light | 8 dmg | Penari Topeng: +1 Wirama on combo finisher | `golok_pendek` |
| Kipas Kembar (`kipas_kembar`) | Light | 8 dmg, very fast | Penari Topeng: +2 max Wirama (8 → 10) | `kujang_kembar` |
| Baju Penari (`baju_penari`) | Armor | Def 2, +8% move speed | Penari Topeng: keep half Wirama when hit | `pangsi_hitam` |
| Gelang Kaki (`gelang_kaki`) | Jimat 2 | +1 Endurance. Ankle bells | Penari Topeng: +12% attack and move speed at 4+ Wirama | `sabuk_merah` |
| Cempala (`cempala`) | Staff | 9 dmg, 6 Sakti per hit. **VERIFY**: the dalang's wooden knocker | Dalang: +8 Sakti on a max Lakon cast | `tongkat_genta` |
| Kayon Gapuran (`kayon_gapuran`) | Staff | 10 dmg. **VERIFY**: gapuran as a kayon type | Dalang: +15% zone and summon duration (`zone_life`) | `tongkat_cendana` |
| Beskap Dalang (`beskap_dalang`) | Armor | Def 1, +1 Spirit. **VERIFY**: beskap | Dalang: +1 max Lakon stack | `jubah_wiku` |
| Blencong (`blencong`) | Jimat 2 | +1 Spirit. **VERIFY**: the oil lamp behind the screen | Dalang: +15% spell zone and blast radius (`spell_radius`) | `genitri` |

## 6. Main-path quest items
These are not equipment. Each is a data resource with `quest_item = true`, shown in the journal's items list and never sold or dropped. Side-quest pickups are listed with their quests in [quests.md](quests.md) section 5.

| Item | Id | Effect | Notes | Source |
|------|----|--------|-------|--------|
| Laras's Lontar | `laras_lontar` | None | Her palm-leaf strip, with your name on the back. The letters fade as the Curse of Forgetting grows | MQ0 0.4 |
| Laras's Ribbon | `laras_ribbon` | None (flavor) | Her hair ribbon, caught on the bamboo where she broke free | MQ1 1.1 |
| Boeh Rarang | `boeh_rarang` | Hung on the eastern post to call the false dawn | A woven cloth that, in the Sangkuriang legend, helps raise the false dawn (**VERIFY**) | MQ1 1.8 (`give:boeh_rarang`) |

The Hunter's empty mask (`hunter_mask`) is a codex entry, not an item.

## 7. Codex: the Items page
- The codex gains a **Barang / Items** category, built straight from `ItemData`:
  - Every weapon, armor and jimat, plus the Kujang Pusaka at the top.
  - Title, icon, description and lore come from `data/text/items.csv`. There is no duplicate CodexEntry text.
- An item that is not in your inventory or equipped shows as "???".
- The page has its own found/total counter. `Game.codex_percent()` is unchanged, so the Lontar Kuno 50% gate stays stable.
- Lore lines are 1 to 2 sentences, in ID and EN, for every item.

## 8. Consumables and pickups
- **Healing Flask:** 3 charges, 40% heal each, refilled at a petilasan. The heal is multiplied by `1 + flask_heal`.
- **Flask Shard:** +1 max flask charge, 3 in the game (max 6). Quest rewards only.
- **Herb Pouch:** +5% flask heal each, 4 in the game (max 60%). Quest rewards only.
- **Ilmu:** currency drops, multiplied by `1 + ilmu_mult`. A chest with no gear holds Ilmu of its zone (`item_id: "ilmu:<n>"`). Of the ten late Ilmu chests in Acts IV to VI, four now hold items (sections 2.2 and 4.2).
- **Herb:** small HP pickup from enemies.
- **Gulungan** (scroll): learns a new glyph. Main quest only.

## 9. Choice rewards that are not items
Two of the six Major Choices give a blessing, not gear. They are flags, not `ItemData`:
- **Berkah Pesisir** (`choice_offer_song`, Act V): once in Act VI, an auto-revive or ward shield.
- **Keteguhan Sunyi** (`choice_release_aria`, Act VI): +15% stamina and Sakti recovery in the final fight.

## 10. Data per item and save
- `ItemData` fields: `id`, `title`, `slot` (weapon, armor or accessory; an accessory is a jimat), `archetype`, `mythic`, `description`, `lore`, `icon`, the weapon shape fields, `defense`, `bonus`, `daya` (jimat only, 1 to 3), `favoured`, `favoured_bonus`.
- `icon` is a 16x16 PNG at `assets/art/items/<id>.png`, generated by `tools/gen_items.py`.
- **Save v4** ([rpg.md](rpg.md) 11) adds `ingatan` and `jimat`. Loading a v3 save:
  - The old equipped accessory becomes the first jimat, unless it costs more than the 2 Daya a v3 save starts with (Sabuk Galuh, 3). Then it stays in the inventory, to wear after the first jamasan.
  - Deleted ids (`short_sword`, `iron_staff`, `longbow`, `kujang`) are dropped from the inventory. An equipped deleted weapon falls back to the class starter.
  - `has_pusaka` is set if MQ0 is past 0.10.
  - Bosses already beaten show as pending jamasan, so no tier backfill is needed.

## 11. Pickup and equip
- Chests show a short item card.
- Weapons and armor can be equipped from the menu at any time. Jimat can be equipped only at a petilasan.
- Swapping weapons is instant, with no cooldown.
