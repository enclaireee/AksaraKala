# Spells: the aksara drawing system

The gimmick. Inspired by the idea of drawing script characters to cast (the user's reference was "The Magus Circle"; details of that game were not checked). All script facts: **VERIFY**.

Related: [rpg.md](rpg.md), [classes.md](classes.md), [architecture.md](architecture.md).

## 1. Player experience
1. Hold right mouse (needs 15 sakti, see section 9). The world slows to about 20% speed (not stopped), the screen vignettes, a faint circle appears around the cursor.
2. While holding, drag the mouse to draw the character. An ink-brush trail follows.
3. Release. The recognizer matches the stroke. On success the glyph flashes, shows its name and Latin transliteration, and the spell fires. On failure it fizzles and costs nothing.
4. The whole cast must finish within about 2.5 seconds of real time (the slow-mo makes this feel generous).

## 2. Scripts and learning
Two scripts, matching the two cultures in the game.

### Aksara Jawa (Hanacaraka)
20 basic letters, in order: ha na ca ra ka, da ta sa wa la, pa dha ja ya nya, ma ga ba tha nga. The order comes from the Aji Saka legend (see [story.md](story.md)). Unicode block U+A980-A9DF (added in Unicode 5.2). **Verified** (Wikipedia: Javanese script, Aji Saka; Sono Budoyo museum page on the Aji Saka legend).
- Legend wording if the codex prints it spaced: "hana caraka" (there were two messengers), "data sawala" (they quarrelled), "padha jayanya" (equally strong), "maga bathanga" (both died). Word breaks vary between sources, so pick one and cite it.
- Vowel marks are called sandhangan: wulu = i, suku = u, pepet = e (schwa), taling = e (as in "e" acute), taling-tarung = o, tarung = long a. **Verified**.

### Aksara Sunda
Baku (standard) set: 7 vowels (swara), 23 consonants (ngalagena). Basic consonant order: ka ga nga ca ja nya ta da na pa ba ma ya ra la wa sa ha, plus 5 extended letters for foreign sounds (fa va qa xa za). Two further non-standard letters, kha and sya, exist for Arabic sounds. Unicode block U+1B80-1BBF. **Verified**: 7 vowels, 18 basic and 5 extended consonants (Wikipedia: Sundanese script). "Swara" (vowels) and "ngalagena" (consonants) are **verified** (GoodNews from Indonesia 2023; UPI EduBasic journal; Wikipedia spells it ngalagéna). Wikipedia's "32 basic characters" is most likely 7 vowels + 18 basic + 5 extended + kha and sya (inferred from two sources' counts, not stated in either). Sundanese diacritics (rarangkén) include vowel marks and a vowel-killer mark (pamaéh). Per-mark names were not confirmed.

### Learning order (progression)
- Zone 1 (Sunda) teaches 4 Sunda glyphs. Zone 2 (Jawa) teaches 4 Jawa glyphs.
- The rule is "the first four letters of each script" (kept 2026-11-05 after the shape check in section 10).
- Each glyph is earned by a deed (a fight, a rescue, an inscription read in place), then the lesson card runs ([story.md](story.md) Pacing rule 4, [quests.md](quests.md) 4). A teacher may name or show the glyph, never hand it over. Na is read off the Arca base (`arca_base`), not taught by an NPC. Practice in the sanggar with the ghost guide is optional (**ASSUMED**).
- Zone 1 and 2 teach 4 glyphs each; Ombak (Jawa Ka) is the ninth, earned at the Trial of the Waves.

## 3. Glyph and spell mapping (8 MVP glyphs plus Ombak; La, Ra and Sa are write-only name glyphs, not spells)
The spell assigned to a letter is a **gameplay assignment**, not a traditional meaning. The codex must say so.

Damage, Ward absorb and Summon scale with Spirit and Ingatan ([balance.md](balance.md) 3.1).

| Script | Glyph | Spell | Effect (base, **TUNE**) | Gauge cost |
|--------|-------|-------|-------------------------|------------|
| Sunda | Ka | Bolt | Piercing bolt, 36 damage to the first enemy and 27 to a second; sets both burning (30% of the hit over 1.5 s) | 15 |
| Sunda | Ga | Ward | Shield absorbing 60 damage for 10 s. **Same for every class.** When damage breaks it, it bursts: 22 damage and a shove in 56 px | 25 |
| Sunda | Nga | Bind | Area 88 px: roots every enemy 2 s and deals 14 thorn damage. Bosses are slowed 60% for 4 s instead ([combat.md](combat.md) 4) | 20 |
| Sunda | Ca | Burst | Shockwave around the player, 52 damage, radius 72 px, pushes enemies back | 30 |
| Jawa | Ha | Heal | Restore 30% max HP at once and 20% more over 5 s; clears Curse, Burn and Slow | 35 |
| Jawa | Na | Dash-strike | Dash 112 px through enemies, 34 damage, invincible during the dash | 20 |
| Jawa | Ca | Rally | 12 s: +35% attack speed, x2 stamina regen, 40 stamina back at once | 40 |
| Jawa | Ra | Summon | A tiger spirit hunts for 10 s: a swipe of 18 every 0.55 s and a pounce (x2) every 2.2 s | 50 |
| Jawa | Ka | Ombak (Tide), P0 final glyph | A wave in the aim direction: 44 damage, pushes enemies back 64 px, destroys enemy projectiles it touches | 35 |

### Perfect casts and class variants (2026-11-08 redesign, **TUNE**)
Every spell now pays for the effort of drawing it. A stroke scoring at least 0.92 is a **Perfect cast**: +12% power (damage, shield, heal, duration), a gold flourish and a camera nudge. A smudged cast (below 0.80) still works at 70%.
Each class bends the six spells that gain from it; **Ga is identical for all four** (a shared safety net), and Ha, Ca (Jawa) and Ra keep the same core with a different edge:

| Glyph | Hulubalang (warrior) | Pamanah (archer) | Pendekar (rogue) | Wiku (mage) |
|-------|-----|-----|-----|-----|
| Ka Bolt | Slow heavy bolt: x1.35 damage, knockback, double poise | Fan of 3 that pierce everything | Twin: a second bolt 0.14 s behind at 80% | Homing: curves toward the nearest foe ahead |
| Nga Bind | Radius x1.3, thorns x1.5 | Slow 50% for 3 s after the root | Root x1.3 longer, 0.5 s invincible | Each rooted enemy returns 3 Sakti (max 6) |
| Ca Burst | Radius x1.25, double poise, long knockback | Also looses 8 piercing shards | Slows what it hits 3 s, 0.6 s invincible | A second blast (70%, radius x1.15) 0.45 s later |
| Ha Heal | 12% of max HP becomes a shield | Stamina refilled | 1 s invincible | Both parts x1.2 |
| Na Dash | 96 px, x1.25 damage, shove, double poise | 140 px, ends with a piercing arrow | 128 px, hits bleed, longer i-frames | 104 px, ends with a small blast |
| Ca Rally | Damage taken -20% | Attack speed +50%, move speed +20% | Dodge costs half | Sakti gain x1.5 |
| Ra Summon | Each claw mends the summoner 1.5% | Faster tiger, pounces from 120 px | Two tigers (second at 60%) | 14 s, claws burn |
| Ka Ombak | Wall of water: 90 px push, double poise | Fan of 3 waves | Cold: slows 3 s | Rolls further, a second wave follows |

Spirit scaling and Ingatan still apply to every number. Spells never refill Sakti, except Wiku's Bind refund, which is capped.

Notes:
- **Final glyph: Jawa Ka** (MQ4 4.9, P0 and main path since story v3.1; earned by passing the Trial of the Waves; **ASSUMED**). It completes "ha na ca ra ka", the first line of the Hanacaraka ("there were messengers"), which the epilogue recites, and it is the next letter by the first-letters rule. Kala's fight must stay beatable without it (it breaks the eclipse shield but is not required).
- "Ca" and "Ka" exist in both scripts. They are different shapes, and the recognizer groups templates by script, so this is fine and also a good culture point.
- The Boss 1 "light" mechanic reuses Ca (Burst), cast next to the boeh rarang banner: no extra glyph (**ASSUMED**, see [quests.md](quests.md) MQ1).

### Choice effects on spells (Story v5, flags in `Game.flags`)
Two of the six Major Choices ([story.md](story.md) "Six Major Choices") change a spell. Both are **TUNE** and not built yet.
- **Choice 1, `choice_tell_ciung`:** Sunda `Ca` (Burst) radius `+10%` (64 px to about 70 px), Naganingrum's blessing on your lontar.
- **Choice 5, `choice_offer_memory`:** *Ombak* costs 3 less Sakti (35 to 32) and deals `+20%` poise damage to Eclipse enemies in Act VI. `choice_offer_song` gives the Berkah Pesisir blessing instead ([items.md](items.md)).
- **Choice 6, `choice_release_aria`:** Keteguhan Sunyi, `+15%` stamina and Sakti recovery in the Batara Kala fight, so every spell is easier to chain there.

Spell numbers live in `data/spells/<glyph_id>.tres` (`SpellData`: `cost`, `power`, `duration`, `radius`, `scene`); glyph templates in `data/glyphs/<glyph_id>.tres`. The write-only name glyphs `sunda_la`, `sunda_ra` and `sunda_sa` have a glyph file but no spell file.

### Class modifiers
Class changes numbers and delivery, not the glyph set. See [classes.md](classes.md) for per-class multipliers (e.g. Archer's Bolt as a 3-arrow fan, Rogue's cheaper Dash).

## 4. Recognition
- **Algorithm:** a point-cloud recognizer such as $P (multi-stroke aware) or $1 (single-stroke). Both are public-domain-style academic methods, about 100 lines in GDScript. Written from scratch.
- **Orientation matters:** do not use rotation-invariant matching, since aksara shapes depend on orientation. Do normalize position and scale.
- **Strokes:** the MVP design uses single-stroke "stylized" versions of each glyph (pen never lifts), so recognition is robust. Multi-stroke glyphs are a stretch. The 8 designs are in [glyph_strokes.py](glyph_strokes.py) (section 10).
- **Direction matters:** matching is order- and direction-sensitive, so a glyph drawn backwards fizzles. The ghost guide and the codex animation always show the start dot and the direction.
- **Templates:** 3-5 hand-drawn variants per glyph, recorded in an in-game recorder tool ([architecture.md](architecture.md)). Hand-drawn by the developer, since automatic extraction from a font does not give stroke paths.
- **Fidelity vs recognizability:** the stylized stroke follows the real character's shape closely enough to be recognizable and educational, but is simplified. Show the true character next to it in the codex.
- **Scoring:**
  - score >= 0.80: full-power cast
  - 0.65 to 0.80: "smudged" cast at 70% power
  - below 0.65: fizzle, no cost
- **Disambiguation:** if the top two glyphs score within 0.05 of each other, the cast fizzles (never cast the wrong spell by accident).
- **Candidates are only the glyphs the player has learned.** This keeps the early game accurate and forgiving.

## 5. Teaching and mastery
- **Sanggar (practice hall):** in Desa Purwa and at some petilasan. Draw any learned glyph with no time pressure and see the score.
- **Glyph lesson (one-time, after every new glyph):** `ui/glyph_lesson` listens to `Events.glyph_learned` and, once any dialogue closes, shows a card (name, aksara, what the spell does, a tip `LESSON_<GLYPH>`) with the ghost guide. Practice mode is on (no sakti, no cost) until the player casts that glyph 3 times (TUNE); another glyph shows "That was X, not Y". Holding interact skips it. The previous `practice` value is restored. The hub debug grant sets `glyphs_learned` directly, so no lesson fires there.
- **Ghost guide:** a faint outline of the stroke in the early game, with a start dot and direction arrows. Settings can keep it always on.
- **Look-alikes:** when Nga is learned (MQ1 1.5), the batu tulis scene shows Ga and Nga side by side: "Nga is Ga without the box". Same idea for Jawa Na and Ca: whichever is learned second is shown beside the first ("Ca has the diagonal").
- **Mastery (stretch):** each successful cast without the guide fills a mastery meter per glyph, and at full mastery the spell gets a small bonus (e.g. +10% power). Encourages learning the glyph, not just spamming.

## 6. Diacritics and combos (stretch)
- **Diacritic modifiers:** Javanese has vowel marks (sandhangan) and Sundanese has rarangkén. After a glyph, a short second stroke could modify the spell (e.g. more power, a different element). This needs multi-stroke recognition. **VERIFY** the marks.
- **Combos:** drawing 2-3 glyphs in order for a stronger effect. Used for the Kala boss mechanic.

## 7. Feedback and juice
- Ink-trail with a soft glow, ends with a flare on success.
- Short sfx on start, ending (success and fizzle), and per spell.
- On success the glyph briefly appears large at the cursor with its Latin name, a quality line under it ("Perfect +12% - 25 sakti", "Clean", "Smudged 70%") and a rune ring blooming around the caster, tinted with the glyph's element colour (`SpellUtil.ELEMENT`). Perfect adds a second gold ring.
- The cursor ring warms toward red and flickers as the 2.5 s draw time runs out.
- Every spell has sprite FX (`assets/art/fx/spells/`, `tools/gen_spell_fx.py`, played by `spells/spell_anim.gd` and `spell_fx.gd`): bolt with impact starbursts, ward bubble and shatter, root eruptions under bound foes, shockwave ring, rising leaves, dash streak, rally aura, a tiger spirit with run and pounce frames, and the Ombak crest.
- Screenshake and hit flash on impact.
- Cast failures fizzle with a gentle puff, not a harsh buzz (forgiving).

## 8. Assist and accessibility
- **Trackpad/assist mode:** lower scoring thresholds by 0.10.
- Settings: slow-mo strength (10-40%), guide always on, draw time limit (2.5-5 s), toggle cast and swap mouse buttons ([controls.md](controls.md) 6).
- Colorblind-safe trail colors.
- Pause menu lets the player review all learned glyphs with the animated stroke order.

## 9. Edge cases
- Pause mid-cast: cancel.
- Taking damage mid-cast: the cast continues (slow-mo reduces the pressure), no cancel (**ASSUMED**). Other combat rules while casting: [combat.md](combat.md) 6.
- Stroke too short or only a click: treat as cancel, no cost.
- **Slow-mo gate (confirmed 2026-11-05):** Drawing can only start with at least 15 sakti (14 for Mage and Rogue, their cheapest spell), and not within 1 s after a cancel or fizzle. The sanggar is exempt, so practice is always free. Without it, pressing and cancelling over and over would play every fight at 20% speed. Pressing cast when blocked flashes the gauge and plays a dull sound.
- Gauge too low for the matched spell: show the spell's cost, fizzle with a distinct soft sound, no gauge loss.
- Multiple monitors/HiDPI: collect points in viewport coordinates and normalize.

## 10. Glyph shapes, stroke designs and research
**Shapes (checked 2026-11-05).** Rendered locally from Noto Sans Javanese and Noto Sans Sundanese. Each glyph has a single-stroke design traced over the font in [glyph_strokes.py](glyph_strokes.py) (start point, direction, retraced parts). These coordinates are the starting point for the ghost guide and the recorded templates.

| Glyph | Single stroke (pen never lifts) |
|-------|----------------------------------|
| Sunda Ka | Two "7"s. The pen slides up from the first foot to the second bar (the slide is the one added line) |
| Sunda Ga | Top bar, slant down-left, bottom bar right, then up-right and back left to close the small box |
| Sunda Nga | The same body as Ga, but the tail flicks up-left (no box) |
| Sunda Ca | Top bar, slant down into a small loop, round bottom, long slant up-right |
| Jawa Ha | From the bottom-left tail: left arch, bottom bowl, two humps (the middle leg is drawn down and back up) |
| Jawa Na | Tail, left arch, down and back up its leg, crossbar into the small loop, big right arch |
| Jawa Ca | Tail, left bowl, small loop, diagonal down-right, up the stem, top bar, right leg. The small flag left of the stem is left out |
| Jawa Ra | Small spur, top bar, hook down-left, diagonal down-right, up into the right arch |

**Stroke order: no source found.** A research pass found no published stroke order, start point or direction for any of the 8: school articles list letters only, and handwriting-recognition datasets are images. So the order above is a game design. The codex says "cara menggambar di game ini / how to draw it in this game", never "the traditional stroke order". Open leads: the Kairaga "Panduan Menulis Aksara Sunda" PDF (kairaga.com, 2024) has a "Cara Menulis" section that could not be read; and expert review by a Sundanese and a Javanese teacher.

**Confusability (simulation, `python3 glyph_strokes.py`).** Sloppy mouse drawings (wobble, uneven scale, slant, small tilt), one clean template per glyph, all 8 learned, section 4 thresholds and tie rule:

| Pair | Template similarity | Sloppy drawings |
|------|--------------------|-----------------|
| Sunda Ga / Nga | 0.80 | about 13% fizzle, Ga misread as Nga 2% |
| Jawa Na / Ca | 0.84 | about 10% fizzle, no misreads |
| Other four glyphs | 0.76 or less | 99-100% cast |

The tie rule turns most doubt into a fizzle, which is the intended failure. **Decision (confirmed 2026-11-05):** keep Ga and Nga (the real ka-ga-nga-ca order), teach the difference (section 5), and measure again in Phase 2 with real recorded templates (3-5 per glyph). If Ga/Nga fizzles stay above 10%, swap Nga for a more distinct Sunda letter then. The simulation is synthetic; real players are the test.

Student error studies (search summaries only, not read in full) name Javanese ha and ca among often-confused letters, but their partners (ta, la, ba) are not in the MVP set. This matters only if more Jawa glyphs are added.

**Jawa Ka** (final glyph): closest template is Jawa Ha (0.79). In the sim it casts 92%, fizzles 7%, no misreads; Ha drops to 95%. Re-test with real templates when MQ4 is built.

**Still open**
- Test fonts for in-game text ([assets.md](assets.md)). Noto Sans Javanese and Noto Sans Sundanese are SIL OFL 1.1 (verified). **Required test:** whether Godot 4's text server (HarfBuzz-based advanced server) shapes Javanese and Sundanese correctly is **unverified**, and no Godot issue was found either way. Build a small render test scene first and make sure the project does not use the fallback text server. If shaping fails, use pre-rendered glyph images. Single letters (all the codex needs for the 8 glyphs) need no shaping, so they are safe either way.
- Expert review of the 8 stroke designs and the codex text.
