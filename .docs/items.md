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
| Short Sword | Light melee | 9 | Balanced blade | Zone 1 drop |
| Broadsword | Heavy melee | 22 | Wide swing | Starter (Warrior) |
| Axe | Heavy melee | 26 | Hits hard, slow | Zone 2 chest |
| Spear | Heavy melee | 28 | Long reach | SQ-M3 Tuyul bounty (ex-Tombak) |
| Golok | Heavy melee | 25 | Machete-like chopping blade | SQ-S2 Kuntilanak bounty |
| Hunting Bow | Ranged | 8 | 4 stamina per shot | Starter (Archer) |
| Longbow | Ranged | 10 | Slower draw, more damage | Zone 2 chest |
| Crossbow | Ranged | 14 | Slow wind-up, high damage | Zone 3 chest |
| Oak Staff | Staff | 8 | Weak ranged bolt | Starter (Mage) |
| Iron Staff | Staff | 9 | Sturdier bolt | Zone 2 drop |

## Weapons: mythic (pusaka)
| Item | Archetype | Base dmg | Notes (culture) | Source |
|------|-----------|----------|-----------------|--------|
| Kujang | Light melee | 9 | Sundanese blade, iconic to West Java | Zone 1 chest |
| Keris Luk 7 | Light melee | 10 | A keris with 7 curves ("luk"; keris luk are odd numbers 3 to 13; the meaning of 7 varies by source, say "traditionally associated with"). Keris is a cultural heritage object (UNESCO Intangible Heritage, inscribed 2008; sacred pusaka, treat respectfully) | SQ-T3 Pamor errand |
| Keris Mpu Gandring | Light melee | 14 | Cursed: strong, but each hit costs 1 HP (**TUNE**). Lore: in the Pararaton legend (label it legend), the keris was forged unfinished for Ken Arok, and Mpu Gandring's dying curse followed it. Never say it is a historical fact. **VERIFY** | Late-game secret (after MQ3) |
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
| Kain Hijau | Mythic | 5 | Green cloth, linked to Nyi Roro Kidul lore (a belief, see world.md) | MQ4 Segara Kidul trial (P1) |

## Accessories
| Item | Tier | Effect | Notes | Source |
|------|------|--------|-------|--------|
| Iron Ring | Common | +1 Strength | A plain band | Zone 1 chest |
| Amulet | Common | +10 max HP | A small charm | Zone 2 chest |
| Feather Charm | Common | +8% move speed | Light as a feather (ex-Selendang) | SQ-M1 Jaka Tarub |
| Silver Bangle | Common | +10% stamina regen | (ex-Gelang Perak) | SQ-S4 Cepot |
| Stone Ring | Common | +1 Spirit | A ring with a stone (ex-Cincin Batu) | SQ-T1 Ande-Ande Lumut |
| Lontar Kuno | Mythic | Smudged-cast threshold 0.65 -> 0.60 (**TUNE**) | Old palm-leaf manuscript, how aksara were written | SQ-D2 Pustaka, 50% codex (P1) |
| Jimat | Mythic | +10 max HP | A small protective charm, a jimat carried for luck and protection (ex-Jimat Kecil) | SQ-M2 Wewe Gombel |

## Consumables and pickups
- **Healing Flask**: heal item, 3 charges, 40% heal each, refilled at a petilasan ([rpg.md](rpg.md)).
- **Flask Shard**: +1 max flask charge, 3 in the game (max 6). Quest rewards only.
- **Herb Pouch**: +5% flask heal each, 4 in the game (max 60%). Quest rewards only.
- **Ilmu**: currency drops.
- **Herb**: small HP pickup from enemies.
- **Gulungan** (scroll): learns a new glyph. Main quest only ([quests.md](quests.md) section 3.3).

## Data per item
Mythic items: `name_key`, `description_key`, `lore_key` (translation keys with Indonesian and English text, see [architecture.md](architecture.md)), `source_note` (the reference used, for the codex), `icon`, `mythic = true`. Commons: `name_key`, `description_key` (one line), `icon`. Lore lines are 1-2 sentences.

## Pickup and equip
- Chests show a short item card. Equip from the menu at any time (not only at petilasans) (**ASSUMED**).
- Swapping weapons is instant, no cooldown.
