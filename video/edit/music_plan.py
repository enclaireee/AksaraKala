"""Music, ambience, ducking and SFX plan. Times are anchors into the EDL so they follow the cut:
    '@<entry id>+0.5'   0.5 s after that entry starts      '@<entry id>$-1.0'  1 s before that entry ends
    '#<segment name>+0' the first frame of a segment        plain float: absolute seconds
All files are the game's own (assets/audio/...). Gains in dB. Fades in seconds (equal-power).

Licences (see video/README.md): Kevin MacLeod tracks are CC BY 4.0 (credit lines in CREDITS below); the composed
tracks (intro, ruwatan, explore_/combat_*) and jingles are the team's own, built from CC0 VSCO-2 CE / VCSL samples;
the added UI sounds are Kenney (CC0). The lamp-out hit is a sub boom from the game's instrument code plus the gong stroke of its 'death' stinger.
"""
from edl import B, S, H

MUSIC = "assets/audio/music/"
LOOP_TIMUR = 128 * 60.0 / 112.0          # explore_/combat_timur: 2 x 16 bars of 4 beats at 112 bpm = 68.571 s

CUES = [
    # cold open: night forest ambience under the black, handing over to the clip's own ambience
    dict(file="assets/audio/amb/forest_night.ogg", at=0.0, src=10.0, until="@hook+0.8", fin=0.4, fout=0.8, gain=-3),
    # low ritual drone (ruwatan, pelog) from the title card through the prologue
    dict(file=MUSIC + "ruwatan.ogg", at="@card_written-0.2", src=0.0, until="@intro+0.6", fin=1.2, fout=1.2, gain=-3),
    # cine_taken (wordless, silent picture): wayang-night ambience until the lamp goes out at 4.50 ...
    dict(file="assets/audio/amb/kelir.ogg", at="@cine_taken-0.6", src=0.0, until="@cine_taken+4.55", fin=0.6,
         fout=0.06, gain=0),
    # ... a cold low drone creeping in at 2.5, gone to near-silence under the lamp-out, back for the grey dawn
    dict(file=MUSIC + "dark_kala.ogg", at="@cine_taken+2.5", src=0.0, until="@intro+0.4", fin=1.8, fout=0.8, gain=-2),
    # the launch intro's own score, in sync with s2_intro (both start at the intro's first frame)
    dict(file=MUSIC + "intro.ogg", at="@intro+0", src=0.0, until="@intro+13.0", fin=0.02, fout=2.0, gain=0),
    # MAIN THEME: Tanah Timur explore (bright pelog, suling + tarompet, 112 bpm) from bar 1 on the world map
    dict(file=MUSIC + "explore_timur.ogg", at="#s3_world+0", src=0.0, until="#s4_casting+%f" % B(4),
         fin=0.05, fout=B(4), gain=-3.5, loop=LOOP_TIMUR, id="theme"),
    # ...crossfades in sync into the same theme's combat arrangement for the casting showcase
    dict(file=MUSIC + "combat_timur.ogg", at="#s4_casting+0", src="sync:theme", until="#s5_features+0.4",
         fin=B(4), fout=0.9, gain=-6, loop=LOOP_TIMUR),
    # features: Rynos Theme's big section (28.6-60 s) peaks under the bosses and resolves before card_free
    dict(file=MUSIC + "boss_sunda.ogg", at="#s5_features-0.5", src=26.73 - 0.5, until="#s6_culture+1.0",
         fin=0.5, fout=2.0, gain=-8),
    # culture: Morning (warm), first downbeat at 2.09 s placed on the segment's first frame
    dict(file=MUSIC + "home.ogg", at="#s6_culture-1.5", src=2.09 - 1.5, until="#s7_next+1.0",
         fin=1.5, fout=1.5, gain=-6),
    # what's next -> end card: the main theme returns at bar 12 so its final cadence lands at end_card + B(13)
    dict(file=MUSIC + "explore_timur.ogg", at="#s7_next-1.0", src=11 * B(4) - 1.0, until="@end_card+%f" % B(13),
         fin=1.0, fout=0.4, gain=-3, ring=7.0, ring_gain=4, id="finale"),
]

# synthesised hits from the game's own instrument code (tools/audio/inst.py): (kind, at, gain dB)
HITS = [("lampout", "@cine_taken+4.50", -2)]

# (no added gong: the theme's last bar rings out through a long reverb tail, see 'ring' on the finale cue)
GONG = None

# music ducks (dB) under big moments: (start, end, dB)
DUCKS = [
    ("@cine_taken+2.5", "@cine_taken+4.5", -6),       # warmth pulled out of the ruwatan drone
    ("@cine_taken+4.5", "@cine_taken+6.5", -24),      # LAMP OUT: one hit, then near-silence
    ("@cine_taken+6.5", "@cine_taken$0", -8),
    ("@boss_sangkuriang_card+0", "@boss_sangkuriang_card$0", -5),
    ("@boss_buto_card+0", "@boss_buto_card$0", -5),
    ("@boss_bondo_card+0", "@boss_bondo_card$0", -5),
    ("@boss_kala_card+0", "@boss_kala_card$0", -5),
    ("@kala_calmed+0.6", "@kala_calmed$0", -4),
    ("@intro+5.9", "@intro+7.4", -3),                 # logo slam: let the clip's impact through
    ("@demo1+2.8", "@demo1+4.6", -3), ("@weak+1.6", "@weak+6.0", -3),
    ("@semar+0", "@semar$0", -3), ("@choice+0", "@choice$0", -3),
]

# short SFX on graphics: (file, at, gain dB)
J = "assets/audio/jingle/"
X = "assets/audio/sfx/"
SFX = [
    (X + "ui_page.wav", "@cine_taken+7.35", -14),     # the name on the lontar crumbles (paper)
    (X + "ui_page.wav", "@cine_taken+7.8", -16),
    (J + "choice.ogg", "@card_written+1.9", -8),          # "...is remembered." bell
    (X + "ui_close.wav", "@card_forgotten+3.0", -10),      # the line dissolves
    (J + "discover.ogg", "@card_world+0.3", -9),
    (J + "glyph.ogg", "@card_cast+0.3", -7),
    (J + "quest_done.ogg", "@card_free+1.4", -8),
    (J + "rest.ogg", "@card_built_with+0.3", -8),
    (X + "ui_open.wav", "@quote1+0.05", -12), (X + "ui_open.wav", "@quote2+0.05", -12),
    (X + "ui_open.wav", "@quote3+0.05", -12), (X + "ui_open.wav", "@quote4+0.05", -12),
    (J + "quest_new.ogg", "@card_partners+0.5", -9),
    (X + "save.wav", "@card_numbers+0.3", -10),
    (J + "area_title.ogg", "@card_next+0.2", -9),
    (X + "ui_page.wav", "@fut_skins+0.1", -12), (X + "ui_page.wav", "@fut_coop+0.1", -12),
    (X + "ui_page.wav", "@fut_mobile+0.1", -12), (X + "ui_page.wav", "@fut_map+0.1", -12),
]
# lower-thirds and feature labels get a soft UI tick as they slide in (added automatically by build.py)
OVERLAY_SFX = {"lt_": (X + "ui_open.wav", 0.12, -12), "feature_label_": (X + "ui_page.wav", 0.07, -11)}

CREDITS = {
    "boss_sunda.ogg": '"Rynos Theme" Kevin MacLeod (incompetech.com), Licensed under Creative Commons: By Attribution 4.0 License, http://creativecommons.org/licenses/by/4.0/',
    "home.ogg": '"Morning" Kevin MacLeod (incompetech.com), Licensed under Creative Commons: By Attribution 4.0 License, http://creativecommons.org/licenses/by/4.0/',
}
