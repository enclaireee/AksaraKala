# Aksara Kala: Official Showcase Trailer — production brief

Everyone working on the video reads this file first. It is the single source of truth for the trailer.

## Deliverables (all inside `video/`)
- `AksaraKala_Showcase.mp4`: 1920x1080, 60 fps, H.264 yuv420p + AAC, about 4:00, **under 95 MB**.
- `voiceover_script.md`: optional narration, one line per timestamp range. The video itself has NO voice.
- `README.md`: how to re-render.
- Sources: `capture/` (Godot capture scripts), `gfx/` (pixel motion graphics), `edit/` (edit list + build script).
- Scratch and big files go to `video/out/` (git-ignored): `out/raw/` captures, `out/gfx/` rendered graphics, `out/preview/`.

## Hard rules
- **Do not edit anything outside `video/`.** No changes to game code, data, assets, `project.godot`, docs. If the game
  has a bug that blocks a shot, work around it inside the capture script and report it.
- Never `git commit`, `git push`, or delete files outside `video/out/`.
- Everything on screen is English. The game is captured with locale `en`.
- Everything is pixel art. Graphics are drawn on the game's native **480x270** grid and scaled 4x with
  nearest-neighbour. No blur, no soft gradients, no anti-aliased vector text, no smooth alpha fades on text
  (use dithered or stepped reveals, wipes, typewriter, pixel dissolve). Motion in whole native pixels.
- Fonts: `assets/fonts/` (Jersey10, Jersey15, Tiny5 for Latin; NotoSansSundanese / NotoSansJavanese for aksara).
  Palette: the game's dusk palette (see `tools/pixlib.py`, `tools/gen_ui_dusk.py`, the title screen): deep
  indigo/purple, sunset orange/pink, cream text `#f0e6d2`-ish, cyan glow for aksara.
- Music and SFX run continuously in the final edit: no silent gaps, no hard audio cuts.
- Facts must match the repo and proposal. Verified: 20 aksara (11 Sunda + 9 Jawa), 8 classes, 6 regions + Gua Kala,
  49 areas, 97 Codex entries, 6 moral choices, 10 bosses, 30+ hours, 85 automated tests, v1.0.0 free on
  Windows and macOS, Indonesian + English. Site: aksarakala.vercel.app.
- Cultural care: Batara Kala is calmed (ruwatan), never "killed" or "defeated". Do not write "kill Batara Kala".
  Sunda and Jawa scripts are distinct; never mix their labels.

## Tooling
- Godot: `GODOT=/tmp/claude-0/-home-user-budayago/cc9c633a-65f6-531b-8fb7-3537ff0bd1e7/scratchpad/godot/Godot_v4.7.2-stable_linux.x86_64`
  (4.7.2; project already imported). No GPU: Mesa llvmpipe. Display via `xvfb-run -a -s "-screen 0 1920x1080x24"`.
- Proven: `xvfb-run ... $GODOT --path . --rendering-driver opengl3 --resolution 1920x1080 --fixed-fps 60
  --write-movie out.avi --quit-after N` records video + audio deterministically (about 10-17% of real time).
- ffmpeg 6.1, Python 3 with Pillow and numpy. `pip install` is allowed.
- 4 CPU cores are shared by all agents: do quick previews at low resolution, final takes at 1080p.
- The game has a Demo route (`ui/demo_route.gd`, `.docs/architecture.md` §10b) that replays the story to any act
  start, area arrival or boss door, and play tests (`tests/*_play_test.gd`) that show how to drive the game from script.
- Read docs by section only (`grep -n "^#" .docs/x.md` then `sed -n`).

## Storyboard (target 4:00)
| # | Time | Segment | Content |
|---|---|---|---|
| 1 | 0:00-0:15 | Cold open (hook) | Dark screen, the cursor draws one glowing aksara in slow motion, the spell bursts onto enemies. Card: "What is written... is remembered." |
| 2 | 0:15-0:35 | Premise | The ruwatan wayang night, Laras is taken (prologue cutscene). Card: "What is forgotten is devoured by Batara Kala." Then the Aksara Kala logo on the title screen. |
| 3 | 0:35-1:25 | World showcase | World map, zoom into the 6 regions + Gua Kala. Per region: HUD-less camera pan(s), a lower-third with region name + its folktale. Card: "49 areas. Six legends." Reference: Chef RPG official trailer (slow HUD-less pans over lively scenes, mood/time changes). |
| 4 | 1:25-2:10 | Main show: Aksara Casting | Draw an aksara, the game recognises it, the spell fires. Side-by-side stroke vs real glyph, accuracy meter (80%+ full power, 65-80% weak, below fails). Lesson card, then a montage of all 20 aksara. Card: "Draw the script. Cast the spell." |
| 5 | 2:10-2:45 | Gameplay & features | 8 classes (class select + a cut of several classes), boss montage (Sangkuriang, Bandung Bondowoso, Buto Ijo, Batara Kala), a moral choice, the Culture Codex (97 entries), "30+ hours. Free." |
| 6 | 2:45-3:10 | Culture, benefit, proof | Card "Built with the people who keep the culture." Pixel quote cards, partnership card, testing numbers. |
| 7 | 3:10-3:45 | What's next (mock-ups, labelled "In development") | Local-artist skin shop; co-op & Paguyuban; mobile + classroom mode; the map of Indonesia lighting up: Bali 2029, Lontara 2030, Batak 2031. Card "The Aksara Map of Indonesia." |
| 8 | 3:45-4:00 | End card | Key art + logo, "Play free now", aksarakala.vercel.app, Tim Biru Muda credits, "BUDAYA GO! 2026", music credits. |

Region to folktale: Desa Purwa (home; the ruwatan night), Tatar Sunda (Sangkuriang & Tangkuban Perahu), Keraton
Galuh (Ciung Wanara & Hariang Banga), Mataram (Roro Jonggrang & Bandung Bondowoso), Tanah Timur (Timun Mas & Buto
Ijo; the keris of Mpu Gandring), Segara Kidul (Nyi Roro Kidul), Gua Kala (Batara Kala & the Murwakala).

## Quotes (segment 6; translated from the team's interviews, names as in the proposal)
- Pearly, 16, high-school student, Garut: "It takes me a long time to read Aksara Sunda... but it matters, so we still know our own culture."
- F. Nurbani, 43, school principal, SMPN 1 Cipeundeuy, Garut: "With interactive media, students are far more enthusiastic."
- D. Munawar, 52, District Secretary, Malangbong, Garut: "Sacred figures should not be enemies, but wise protectors. Not every problem is solved with violence."
- Yazid, 24, Javanese Literature alumnus, Universitas Indonesia: "Master the base aksara first, and never treat Jawa and Sunda as the same."
Partnership card: "In partnership with the Government of Malangbong District, Garut" and "Classroom pilot partner: SMPN 1 Cipeundeuy".
Numbers card: 85 automated tests; 30 quests and 5,000+ bilingual lines checked; recognition 85%+ on every aksara; v1.0.0 out now.

## End card text
Aksara Kala / The Script of Time / Play free now on Windows & macOS / aksarakala.vercel.app /
Tim Biru Muda, Universitas Indonesia: Muhammad Nafis Yusa', Fahmi Milan Amyar, Muhammad Fatih Zamzami /
BUDAYA GO! 2026 / Music: Kevin MacLeod (incompetech.com), CC BY 4.0 (check `.docs/assets.md` for the exact credit lines of the tracks used).
