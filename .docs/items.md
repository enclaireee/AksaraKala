# Items

Three gear slots: weapon, armor, accessory. Plus consumables. Two tiers: **common** gear (ordinary fantasy-RPG fare) and **mythic** gear (pusaka, the cultural heirlooms). Most gear comes from chests, drops and quests ([quests.md](quests.md) section 3.4). Mythic descriptions and associations: Checked Nov 2026; remaining VERIFY items are marked. Stats are starting values (**TUNE**).

Rules:
- Every item is a data resource ([architecture.md](architecture.md)), so adding items is data entry.
- No rarity tiers, no crafting, no upgrading. Each item has a `mythic` flag (**ASSUMED**).
- Mythic (pusaka) items show a gold name and a lore line, and carry the cultural descriptions. Commons have a plain one-line description.
- Weapons differ by archetype (light melee, heavy melee, ranged, staff, thrown) and behavior ([combat.md](combat.md) 2.3), not just numbers.

## Weapons: common
Numbers **TUNE**. Sources use "Zone N chest" or "drop"; shops are not designed yet.

| Item | Archetype | Base dmg | Notes | Source |
|------|-----------|----------|-------|--------|
| Dagger | Light melee | 8 | Fast, short reach | Starter (Rogue) |
| Short Sword | Light melee | 9 | Balanced blade | Zone 1 chest (ts_sawah) |
| Broadsword | Heavy melee | 22 | Wide swing | Starter (Warrior) |
| Axe | Heavy melee | 26 | Hits hard, slow | Zone 2 chest |
| Spear | Heavy melee | 28 | Long reach | SQ-M3 Tuyul bounty (ex-Tombak) |
| Golok | Heavy melee | 25 | Machete-like chopping blade | SQ-S2 Kuntilanak bounty |
| Hunting Bow | Ranged | 8 | 4 stamina per shot | Starter (Archer) |
| Longbow | Ranged | 10 | Slower draw, more damage | Zone 2 chest |
| Crossbow | Ranged | 14 | Slow wind-up, high damage | Zone 3 chest |
| Oak Staff | Staff | 8 | Weak ranged bolt | Starter (Mage) |
| Iron Staff | Staff | 9 | Sturdier bolt | Zone 2 chest (no enemy drops yet, **ASSUMED**) |

## Weapons: mythic (pusaka)
| Item | Archetype | Base dmg | Notes (culture) | Source |
|------|-----------|----------|-----------------|--------|
| Kujang | Light melee | 9 | Sundanese blade, iconic to West Java | Zone 1 chest |
| Keris Luk 7 | Light melee | 10 | A keris with 7 curves ("luk"; keris luk are odd numbers 3 to 13; the meaning of 7 varies by source, say "traditionally associated with"). Keris is a cultural heritage object (UNESCO Intangible Heritage, inscribed 2008; sacred pusaka, treat respectfully) | SQ-T3 Pamor errand |
| Keris Mpu Gandring | Light melee | 14 | Cursed: strong, but each hit costs 1 HP (**TUNE**). Lore: in the Pararaton legend (label it legend), the keris was forged unfinished for Ken Arok, and Mpu Gandring's dying curse followed it. Never say it is a historical fact. **VERIFY** | MQ3 Choice 4, reforge (`choice_reforge`, Wirasana gives it tamed) |
| Panah Pasopati | Ranged | 10 | Named after Arjuna's arrow (verified). Arjuna is the famous archer of wayang; who gave him Pasopati is unconfirmed | Zone 2 secret |
| Cakra | Thrown | 12 | Krishna/Kresna's disc (Cakra Baskara or Sudarsana) from wayang, returns like a boomerang (stretch) | SQ-K2 sea spirit bounty (P2) |

Decisions (**ASSUMED**): Tombak becomes the common Spear. Golok becomes common. Gada is dropped (its Gatotkaca link was unverified).

## Armor
Body armor only, one slot.

| Item | Tier | Defense | Notes | Source |
|------|------|---------|-------|--------|
| Padded Tunic | Common | 1 | Plain padded cloth | Starter (ex-Kain Polos) |
| Leather Armor | Common | 2 | Light and quiet | Zone 1 chest |
| Chainmail | Common | 4 | Heavy rings of iron | Zone 3 chest |
| Iket Sunda | Mythic | 2 | Sundanese cloth head wrap, tied by the wearer | SQ-S1 Lutung Kasarung |
| Blangkon | Mythic | 3 | Javanese ready-made batik head cloth | SQ-M4 Gamelan errand |
| Baju Batik | Mythic | 4 | Batik clothing, patterns carry meaning (pick a named pattern with a verified meaning; some, like parang, were royal-only) | MQ2 boss, Bandung Bondowoso |
| Kain Hijau | Mythic | 5 | Green cloth, linked to Nyi Roro Kidul lore (a belief, see world.md) | MQ4 Trial of the Waves (main path) |

## Accessories
| Item | Tier | Effect | Notes | Source |
|------|------|--------|-------|--------|
| Iron Ring | Common | +1 Strength | A plain band | Zone 1 chest |
| Amulet | Common | +10 max HP | A small charm | Zone 2 chest |
| Feather Charm | Common | +8% move speed | Light as a feather (ex-Selendang) | SQ-M1 Jaka Tarub |
| Silver Bangle | Common | +10% stamina regen | (ex-Gelang Perak) | SQ-S4 Cepot |
| Stone Ring | Common | +1 Spirit | A ring with a stone (ex-Cincin Batu) | SQ-T1 Ande-Ande Lumut |
| Lontar Kuno | Mythic | Smudged-cast threshold 0.65 -> 0.60 (**TUNE**) | Old palm-leaf manuscript, how aksara were written | SQ-D2 Pustaka, 50% codex (P1) |
| Batu Kali | Mythic | +1 Spirit, +5% stamina regen (**TUNE**, **ASSUMED**). Design: also cleanses one status now and then (not built) | A smooth river stone ("river stone") the river gives back when you sink the keris | MQ3 Choice 4, sink (`choice_sink`) |
| Sabuk Galuh | Mythic | +1 Vitality, +8% damage taken reduction (`bonus` keys `vit`, `defense`, **TUNE**, **ASSUMED**) | A royal belt of Galuh, a defense ward from the court smiths. A belt, not body armor, so it sits in the accessory slot | MQ2 Choice 3, judgment (`choice_judgment`) |
| Jimat | Mythic | +10 max HP | A small protective charm, a jimat carried for luck and protection (ex-Jimat Kecil) | SQ-M2 Wewe Gombel |

## Class-favoured gear (Phase 4g, user call 2026-11-12, all **ASSUMED**, numbers **TUNE**)
Common tier. Anyone can equip these. The favoured class also gets the last column (`favoured`, `favoured_bonus` on `ItemData`). Bonus keys are the accessory keys plus `damage_mult` (weapon and spell damage fraction) and `sakti_gain` (Sakti gain fraction). The equipment card shows "Favoured: <class>" above the note, dark ink when it is active and dim when not. The 32 icons are recolours of a kin icon (`RECOLOUR` in `tools/gen_items.py`, **ASSUMED**, redraw when there is time). Names are plain Indonesian or Sundanese words for ordinary objects; **VERIFY** the three marked ones before shipping.

| Item (id) | Slot | Stats | Favoured class: extra | Source |
|---|---|---|---|---|
| Parang Perang (`parang_perang`) | Heavy melee | 24 dmg, quicker swing | Hulubalang: +10% damage | Zone chest |
| Tombak Panji (`tombak_panji`) | Heavy melee | 27 dmg, long reach | Hulubalang: +1 Vitality | SQ-X1 |
| Zirah Sisik (`zirah_sisik`) | Armor | Defense 4 | Hulubalang: +10 max HP | Zone chest |
| Gelang Baja (`gelang_baja`) | Accessory | +5% damage reduction | Hulubalang: +1 Strength | Zone chest |
| Busur Petung (`busur_petung`) | Ranged | 7 dmg, 3 stamina, fast | Pamanah: +10% damage | Zone chest |
| Gendewa Tanduk (`gendewa_tanduk`) | Ranged | 11 dmg | Pamanah: +1 Dexterity | SQ-X1 |
| Kampret Pemburu (`kampret_pemburu`) | Armor | Defense 2, +5% move speed | Pamanah: +10% stamina regen | Zone chest |
| Kantong Panah (`kantong_panah`) | Accessory | +10% stamina regen | Pamanah: +1 Dexterity | Zone chest |
| Golok Pendek (`golok_pendek`) | Light melee | 11 dmg | Pendekar: +10% damage | Zone chest |
| Kujang Kembar (`kujang_kembar`) | Light melee | 10 dmg, very fast. **VERIFY**: the kujang is a Sundanese heirloom blade; a paired fighting use is a game invention and the text must say so or the name changes | Pendekar: +1 Dexterity | SQ-X1 |
| Pangsi Hitam (`pangsi_hitam`) | Armor | Defense 2, +8% move speed. **VERIFY**: pangsi as silat and daily Sundanese clothing | Pendekar: +10% stamina regen | Zone chest |
| Sabuk Merah (`sabuk_merah`) | Accessory | +1 Endurance | Pendekar: +1 Strength | Zone chest |
| Tongkat Genta (`tongkat_genta`) | Staff | 9 dmg, 6 Sakti per hit | Wiku: +10% Sakti gain | Zone chest |
| Tongkat Cendana (`tongkat_cendana`) | Staff | 10 dmg | Wiku: +1 Spirit | SQ-X1 |
| Jubah Wiku (`jubah_wiku`) | Armor | Defense 1, +1 Spirit | Wiku: +10% Sakti gain | Zone chest |
| Genitri (`genitri`) | Accessory | +1 Spirit. **VERIFY**: genitri (rudraksha) prayer beads and who wore them | Wiku: smudge threshold -0.03 | Zone chest |

**Second paths (2026-11-12).** Each row is the sibling of the school item in brackets. There are no extra chests: when a second-path player would receive the bracketed item (class chest or `SQ-X1`), `Game.add_item` gives the sibling instead (`Game.SIBLING_ITEM`).

| Item (id) | Slot | Stats | Favoured class: extra | Sibling of |
|---|---|---|---|---|
| Tombak Galah (`tombak_galah`) | Heavy melee | 22 dmg, longest reach | Prajurit: +10% damage | `parang_perang` |
| Tombak Bendera (`tombak_bendera`) | Heavy melee | 26 dmg, long reach | Prajurit: +1 Vitality | `tombak_panji` |
| Baju Keprajuritan (`baju_keprajuritan`) | Armor | Defense 4. **VERIFY**: keraton soldier dress | Prajurit: +10 max HP | `zirah_sisik` |
| Tameng Rotan (`tameng_rotan`) | Accessory | +5% damage reduction | Prajurit: +1 Endurance | `gelang_baja` |
| Bandring Kulit (`bandring_kulit`) | Ranged | 8 dmg, 3 stamina, fast | Pangangon: +10% damage | `busur_petung` |
| Bandring Ijuk (`bandring_ijuk`) | Ranged | 11 dmg | Pangangon: +1 Dexterity | `gendewa_tanduk` |
| Sarung Gembala (`sarung_gembala`) | Armor | Defense 2, +5% move speed | Pangangon: +10% stamina regen | `kampret_pemburu` |
| Suling Bambu (`suling_bambu`) | Accessory | +10% stamina regen | Pangangon: +1 Endurance | `kantong_panah` |
| Kipas Bambu (`kipas_bambu`) | Light melee | 11 dmg | Penari Topeng: +10% damage | `golok_pendek` |
| Kipas Kembar (`kipas_kembar`) | Light melee | 10 dmg, very fast | Penari Topeng: +1 Dexterity | `kujang_kembar` |
| Baju Penari (`baju_penari`) | Armor | Defense 2, +8% move speed | Penari Topeng: +10% stamina regen | `pangsi_hitam` |
| Gelang Kaki (`gelang_kaki`) | Accessory | +1 Endurance. Ankle bells | Penari Topeng: +1 Dexterity | `sabuk_merah` |
| Cempala (`cempala`) | Staff | 9 dmg, 6 Sakti per hit. **VERIFY**: the dalang's wooden knocker | Dalang: +10% Sakti gain | `tongkat_genta` |
| Kayon Gapuran (`kayon_gapuran`) | Staff | 10 dmg. **VERIFY**: gapuran as a kayon type | Dalang: +1 Spirit | `tongkat_cendana` |
| Beskap Dalang (`beskap_dalang`) | Armor | Defense 1, +1 Spirit. **VERIFY**: beskap | Dalang: +10% Sakti gain | `jubah_wiku` |
| Blencong (`blencong`) | Accessory | +1 Spirit. **VERIFY**: the oil lamp behind the screen | Dalang: smudge threshold -0.03 | `genitri` |

The 12 chest items replace Ilmu-only chests in the zone docs (`.docs/zones/*.md`).

## Main-path quest items
Not equipment. Each is a data resource with `quest_item = true` (**ASSUMED**), shown in the journal's items list, never sold or dropped. Ids are the ones quests.md and script.md use. Side-quest pickups (angklung, selendang, gong, batu bintang, sodo lanang, kuda kepang, tukik) are listed with their quests in [quests.md](quests.md) section 5.

| Item | Id | Effect | Notes | Source |
|------|----|--------|-------|--------|
| Laras's Lontar | `laras_lontar` | None | Her palm-leaf strip, with your name on the back. The letters fade as the Curse of Forgetting grows. Semar reads it | MQ0 0.4, pickup on the burned stage (`item_picked:laras_lontar`) |
| Laras's Ribbon | `laras_ribbon` | None (flavor) | Her hair ribbon, caught on the bamboo where she broke free. Step 1.1 completes on the fight, not on the pickup | MQ1 1.1, pickup at the bamboo edge |
| Boeh Rarang | `boeh_rarang` | Hung on the eastern post at the crater to call the false dawn (`arena_post`, post_id "east"), then Ca | A woven cloth that, in the Sangkuriang legend, helps raise the false dawn (**VERIFY** the legend detail). The Weaver gives it | MQ1 1.8 (`give:boeh_rarang`) |

The Hunter's empty mask in the Interlude (`hunter_mask`) is a codex entry, not an item. The Keris Mpu Gandring (weapon) and the Batu Kali (accessory) are in the tables above; Choice 4 gives one of them. Kain Hijau (armor) is given at the altar (`give:kain_hijau`, MQ4 4.9; the file is `data/items/kain_hijau.tres`, defense 5).

## Choice rewards that are not items
Two of the six Major Choices ([story.md](story.md) "Six Major Choices") give a blessing or passive, not gear. They are flags, not `ItemData` resources (**ASSUMED**):
- **Berkah Pesisir** (`choice_offer_song`, Act V): once in Act VI, an auto-revive or ward shield.
- **Keteguhan Sunyi** (`choice_release_aria`, Act VI): `+15%` stamina and Sakti recovery in the final fight.

Choice flags with spell effects (Sunda `Ca` radius `+10%`, *Ombak* cost and poise) are in [spells.md](spells.md).

## Consumables and pickups
- **Healing Flask**: heal item, 3 charges, 40% heal each, refilled at a petilasan ([rpg.md](rpg.md)).
- **Flask Shard**: +1 max flask charge, 3 in the game (max 6). Quest rewards only.
- **Herb Pouch**: +5% flask heal each, 4 in the game (max 60%). Quest rewards only.
- **Ilmu**: currency drops. A chest with no gear left to give holds Ilmu S or M of its zone instead (`item_id: "ilmu:<n>"`, **ASSUMED**).
- **Herb**: small HP pickup from enemies.
- **Gulungan** (scroll): learns a new glyph. Main quest only ([quests.md](quests.md) section 3.3).

## Data per item
Mythic items: `name_key`, `description_key`, `lore_key` (translation keys with Indonesian and English text, see [architecture.md](architecture.md)), `source_note` (the reference used, for the codex), `icon`, `mythic = true`. Commons: `name_key`, `description_key` (one line), `icon`. Lore lines are 1-2 sentences.

`icon` is a 16x16 PNG at `assets/art/items/<id>.png` generated by `tools/gen_items.py` (Phase 6b), exported on `ItemData.icon`. Consumables and quest items get icons in the same folder.

## Pickup and equip
- Chests show a short item card. Equip from the menu at any time (not only at petilasans) (**ASSUMED**).
- Swapping weapons is instant, no cooldown.
