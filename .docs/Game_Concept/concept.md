# Concept

**Title:** Budayago
**Made for:** a culture competition (lomba budaya). The brief is not a design input (decided 2026-11-05): the goal is simply a good game.
**Genre:** top-down 2D action RPG, Soul Knight-style pixel art and real-time combat, with RPG structure (open map, stats, gear, checkpoints, NPCs, quests).
**Engine:** Godot 4. **Platform:** PC first. Web export is a stretch goal (**ASSUMED**).
**Setting:** the island of Java, Sunda and Javanese lands, drawn from folklore and legend.

## One-line pitch
Learn to write the lost aksara of Java and Sunda, and use them as spells, to stop a curse of forgetting.

## Pillars
1. **Learn the script by using it.** Drawing aksara is the combat gimmick, and learning each script is the progression.
2. **Folklore is the world, not decoration.** Zones, enemies, bosses, gear and NPCs all come from real legends.
3. **Forgiving, readable, juicy action.** Not a hardcore game. Soul Knight-style clarity, with screenshake, hit flash and loud simple sfx.
4. **Accurate and cited.** Every cultural claim and every glyph is checked against reliable sources. Sources go in-game (codex) and in [assets.md](assets.md).

## Core loop
Explore a zone -> fight folklore enemies with weapon and drawn spells -> earn Ilmu (knowledge, the currency) and gear -> rest at a petilasan (checkpoint: heal, level up, equip) -> learn new glyphs -> boss -> next zone.

## The gimmick: aksara casting
Hold the right mouse button, the world slows, and draw a character from Aksara Sunda or Aksara Jawa. A recognizer matches the stroke to a glyph and casts its spell. Every class can cast. Full design: [spells.md](spells.md).

## Player and classes
The player is a custom hero (the player names them). At the start they choose a **lineage**: a class inspired by a folklore figure. They are classes, not separate characters.

| Class | Inspired by |
|-------|-------------|
| Warrior | Gatotkaca |
| Archer | Arjuna / Srikandi |
| Assassin | Ken Arok |
| Mage | Nyi Roro Kidul |

Details: [classes.md](classes.md).

## Win / lose
- **Win:** defeat the final boss and restore the aksara.
- **Lose:** no real fail state. Dying returns you to the last petilasan with nothing lost ([rpg.md](rpg.md)).

## Audience and first impression
- Judges may play only 10-15 minutes. The first 10 minutes must show everything that matters: class choice, drawing a glyph, a folklore enemy with an on-screen description, the codex, and a boss tease. Design the opening as a deliberate demo path.
- A **quick-start option** that skips the prologue and gives starting glyphs may be useful for demos (**ASSUMED**, stretch).

## Tone
Respectful, warm, a bit of humor from the punakawan (wayang clown-servants). Enemies are stylized and cartoonish in the Soul Knight way, not gory.

## Cultural sensitivity
- Nyi Roro Kidul, Batara Kala and other figures are meaningful to many people. Portray them with respect. No mockery, no cheap jokes.
- Avoid presenting folklore as religious doctrine. Present it as stories and heritage.
- Horror figures (pocong, kuntilanak) stay cartoonish and are labeled as folklore.
- Have someone familiar with Sundanese and Javanese culture review the final text, if possible.

## Open questions
- Final game title and class names (draft)
- ~~Language~~: decided 2026-11-05, all text in Indonesian and English ([quests.md](quests.md) section 7.7)

Related: [story.md](story.md), [world.md](world.md), [rpg.md](rpg.md), [spells.md](spells.md).
