# Aksara Kala: showcase trailer

`AksaraKala_Showcase.mp4` is the final trailer: 4:14.6, 1920x1080, 60 fps, H.264 High yuv420p, AAC 320k 48 kHz
stereo, about -14 LUFS, under 95 MB. The brief and the hard rules are in [PLAN.md](PLAN.md). The final cut is in
[edit/timeline.md](edit/timeline.md), and an optional narration is in [voiceover_script.md](voiceover_script.md).

## Folder map
| Path | What |
|---|---|
| `PLAN.md` | Brief, rules, storyboard, verified facts |
| `capture/` | Godot capture harness (real in-game footage). See `capture/README.md` |
| `gfx/` | Pixel motion graphics (cards, lower-thirds, labels, mock-ups, vistas), drawn at 480x270 and scaled 4x nearest |
| `edit/edl.py` | **The cut**: ordered segments and entries (clip, in, duration in beats, overlays, fades, audio gain) |
| `edit/music_plan.py` | Music cues, ambience, ducks, SFX, credit lines |
| `edit/build.py` | Renders everything (graphics retimes, segments, mix, final encode) |
| `edit/check.py` | Editor's QC: contact sheets, cut frames, loudness, gaps, ffprobe facts |
| `edit/timeline.md` | The final timeline as a table |
| `out/` (git-ignored) | `raw/` captures, `gfx/` rendered graphics, `edit_gfx/` retimed graphics, `edit_cache/` segment cache + mix, `preview/` contact sheets |

## Re-render

**1. Graphics** (only if a card's design changes):
```
python3 video/gfx/render_all.py --list
python3 video/gfx/render_all.py card_free end_card          # -> video/out/gfx/<name>.mp4 / .mov
python3 video/gfx/render_all.py --preview                     # 3 stills per scene + out/preview/gfx_contact.png
```
You do not need to re-render cards to change their length. Give the entry `render=dict(dur=...)` in `edl.py` and
the build re-renders it into `out/edit_gfx/`. That is how the cards, the `fut_*` mock-ups and the beat-timed
`aksara_montage` are fitted to the music.

**2. Capture** (game footage): see `capture/README.md` (`video/capture/shoot.sh <shot>`). Shot lists with in/out
points and ratings are in `out/raw/shots_*.json`.

**3. Edit:**
```
python3 video/edit/build.py --timeline     # print the resolved cut (times, sources, ids) without rendering
python3 video/edit/build.py --preview      # 960x540 draft -> video/out/AksaraKala_preview.mp4  (about 1.5 min)
python3 video/edit/build.py --audio-only   # re-mix only -> video/out/edit_cache/mix.wav
python3 video/edit/build.py                # full 1080p60 render + 2-pass encode -> video/AksaraKala_Showcase.mp4
python3 video/edit/check.py [file.mp4]     # QC: out/preview/final_contact_*.png, out/preview/cuts/, loudness, gaps
```
To change a cut, edit the entry in `edit/edl.py`: its in-point, its length in beats (`B(n)` is the 112 bpm main
theme, `S(n)` is Rynos Theme, `H(n)` is Morning) or its overlays. Then run the build again. Each segment is cached
under a hash of its entries and source files, so only the segments you changed are rendered again. The soundtrack is
always re-mixed (about 40 s), and the final 2-pass encode always runs. Music cues, ducks and SFX use anchors such as
`'@demo1+2.8'` (entry id plus seconds) or `'#s5_features+0'` (segment start), so they move with the cut.

Optional material: an entry with `need="gfx/<file>"` is used only when that file exists, and one with
`skip_if="gfx/<file>"` is its fallback. The region vistas and `cine_taken` are wired in this way. If you delete
`out/gfx/cine_taken.mp4`, the premise goes back to the in-game raid clips, and the sound design built for the
cinematic (anchored to `@cine_taken`) drops out too.

Requirements: ffmpeg 6, Python 3 with numpy, Pillow, scipy, soundfile, pyloudnorm (`pip install librosa soundfile
pyloudnorm`; librosa was used for beat tracking while cutting). Godot is not needed for the edit.

## Picture rules the build enforces
- Footage is never resampled with a smoothing filter. The 960x540 preview halves with nearest-neighbour. The map
  push-in samples the native 480x270 grid and scales it by whole integers (4x, 5x, 6x, 8x).
- Fades are stepped 4x4 Bayer dithers on the native grid, one step every 3 frames. There are no crossfades.
- Segments are encoded as raw H.264 streams and joined byte-for-byte, so the frame count is exact (no lost or
  duplicated frame at a segment join).

## Credits and licences

### Music used in the trailer
| File (`assets/audio/music/`) | Where | Credit / licence |
|---|---|---|
| `explore_timur.ogg`, `combat_timur.ogg` | World showcase, Aksara casting, What's next, End card (main theme) | Original score for Aksara Kala (Tim Biru Muda), composed with `tools/audio` from CC0 samples (VSCO-2 CE, VCSL) |
| `intro.ogg` | Launch intro (in sync with `s2_intro`) | Original score for Aksara Kala, as above |
| `ruwatan.ogg`, `dark_kala.ogg` | Cold-open card, premise (drone) | Original score for Aksara Kala, as above |
| `boss_sunda.ogg` | Gameplay and features | "Rynos Theme" Kevin MacLeod (incompetech.com), Licensed under Creative Commons: By Attribution 4.0 License, http://creativecommons.org/licenses/by/4.0/ |
| `home.ogg` | Culture, benefit, proof | "Morning" Kevin MacLeod (incompetech.com), Licensed under Creative Commons: By Attribution 4.0 License, http://creativecommons.org/licenses/by/4.0/ |

The end card credits "Music: Kevin MacLeod (incompetech.com), CC BY 4.0". Use the two full lines above wherever the
video is published (for example, the description).

### Stingers and SFX added in the edit
- Jingles from `assets/audio/jingle/`: `choice`, `discover`, `glyph`, `quest_done`, `rest`, `quest_new`, `area_title`,
  and the opening gong stroke of `death`. These are original, built by `tools/audio/jingles.py` from CC0 samples.
- UI sounds from `assets/audio/sfx/`: `ui_open`, `ui_page`, `ui_close`, `save`. They are built only from Kenney RPG
  and Interface Sounds, **CC0**.
- The lamp-out hit is `inst.sub_boom` from the game's own instrument code plus the gong stroke above.
- **Needs clearing before public release:** the ambience beds `assets/audio/amb/forest_night.ogg` (cold open) and
  `amb/kelir.ogg` (under `cine_taken`) come from Freesound sources. `.docs/assets.md` §4.1 lists them as not yet
  cleared. The game's own SFX and ambience recorded inside the footage are in the same position, because they ship
  with the game.

### Fonts (in the graphics)
Jersey 10 / Jersey 15, Tiny5, Noto Sans Sundanese and Noto Sans Javanese (`assets/fonts/`), all under the
SIL Open Font License 1.1.
