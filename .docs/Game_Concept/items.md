# Items

Three gear slots: weapon, armor, accessory. Plus consumables. Most gear comes from quests ([quests.md](quests.md) section 3.4). All descriptions and associations: Checked Nov 2026; remaining VERIFY items are marked. Stats are starting values (**TUNE**). Each item has a one-line culture description shown on pickup and added to the codex.

Rules:
- Every item is a data resource ([architecture.md](architecture.md)), so adding items is data entry.
- No rarity tiers, no crafting, no upgrading.
- Weapons differ in behavior ([combat.md](combat.md) 2.3), not just numbers.

## Weapons
| Item | Archetype | Base dmg | Notes (culture) | Source |
|------|-----------|----------|-----------------|--------|
| Gada | Heavy melee | 22 | Warrior's club | Starter (Warrior) |
| Busur | Ranged | 8 | Bow | Starter (Archer) |
| Keris | Light melee | 8 | Wavy-bladed dagger, a cultural heritage object (UNESCO Intangible Heritage, inscribed 2008; sacred pusaka, treat respectfully) | Starter (Assassin) |
| Tongkat | Staff | 8 | A pujangga's staff | Starter (Mage) |
| Kujang | Light melee | 9 | Sundanese blade, iconic to West Java | Zone 1 chest |
| Golok | Heavy melee | 25 | Common machete-like blade | SQ-S2 Kuntilanak bounty |
| Tombak | Heavy melee | 28 | Long reach, spear | SQ-M3 Tuyul bounty |
| Panah Pasopati | Ranged | 10 | Named after Arjuna's arrow (verified) | Zone 2 secret |
| Keris Luk 7 | Light melee | 10 | A keris with 7 curves ("luk"; keris luk are odd numbers 3 to 13; the meaning of 7 varies by source, say "traditionally associated with") | SQ-T3 Pamor errand |
| Cakra | Thrown | 12 | Krishna/Kresna's disc (Cakra Baskara or Sudarsana) from wayang, returns like a boomerang (stretch) | SQ-K2 sea spirit bounty (P2) |

## Armor
| Item | Defense | Notes (culture) | Source |
|------|---------|-----------------|--------|
| Kain Polos | 1 | Plain cloth, starting | Starter |
| Iket Sunda | 2 | Sundanese cloth head wrap, tied by the wearer | SQ-S1 Lutung Kasarung |
| Blangkon | 3 | Javanese ready-made batik head cloth | SQ-M4 Gamelan errand |
| Baju Batik | 4 | Batik clothing, patterns carry meaning (pick a named pattern with a verified meaning; some, like parang, were royal-only) | MQ2 boss, Bandung Bondowoso |
| Kain Hijau | 5 | Green cloth, linked to Nyi Roro Kidul lore (a belief, see world.md) | MQ4 Segara Kidul trial (P1) |

## Accessories
| Item | Effect | Notes (culture) | Source |
|------|--------|-----------------|--------|
| Cincin Batu | +1 Spirit | A ring with a stone | SQ-T1 Ande-Ande Lumut |
| Gelang Perak | +10% stamina regen | Silver bangle | SQ-S4 Cepot |
| Jimat Kecil | +10 max HP | A small charm | SQ-M2 Wewe Gombel |
| Selendang | +8% move speed | Scarf | SQ-M1 Jaka Tarub |
| Lontar Kuno | Smudged-cast threshold 0.65 -> 0.60 (**TUNE**) | Old palm-leaf manuscript, how aksara were written | SQ-D2 Pustaka, 50% codex (P1) |

## Consumables and pickups
- **Jamu** (UNESCO Intangible Heritage, 2023): heal item, 3 charges, refilled at petilasan ([rpg.md](rpg.md)).
- **Kendi** (clay water jug): +1 max jamu charge, 3 in the game (max 6). Quest rewards only.
- **Rempah** (jamu spices: kunyit, temulawak, jahe, kencur): +5% jamu heal each, 4 in the game (max 60%). Quest rewards only. All four are standard jamu rhizomes (verified 2026-11-05).
- **Ilmu**: currency drops.
- **Daun** (leaves): small HP pickup from enemies, flavored for codex.
- **Gulungan** (scroll): learns a new glyph. Main quest only ([quests.md](quests.md) section 3.3).

## Culture content per item
Each item data has: `name_key`, `description_key` (translation keys with Indonesian and English text, see [architecture.md](architecture.md)), `source_note`, `icon`. Descriptions are 1-2 sentences. Source note names the reference used, for the codex.

## Pickup and equip
- Chests show a short item card. Equip from the menu at any time (not only at petilasans) (**ASSUMED**).
- Swapping weapons is instant, no cooldown.
