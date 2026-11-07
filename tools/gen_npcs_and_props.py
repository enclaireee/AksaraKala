#!/usr/bin/env python3
"""Generate NPC & interactive prop spritesheet (assets/art/npcs.png) for Budayago.
16x24 cells, 4 columns (idle breathing frames) x 12 archetype rows:
  0: villager / farmer / fisher
  1: elder / juru_kunci / lengser / dalang
  2: woman / ibu / weaver / nyai / dayang_sumbi
  3: royal / ciung_wanara / queen / princess
  4: semar (panakawan wise figure, round belly, white hair tuft, poleng cloth)
  5: cepot (red-faced Sundanese panakawan, iket, warm grin)
  6: laras (hero's sister, teal/gold kebaya, flower in hair)
  7: smith / empu / guard / official
  8: lutung / cat (dark sacred monkey / village animal)
  9: stone / prasasti / altar (inscribed candi monolith)
 10: wooden mechanism / door / stall / wheel
 11: stone oil lamp (galuh_lamp)
"""
import os
from PIL import Image
import pixlib as px
from pixlib import hexc

CW, CH = 16, 24
IW, IH = 14, 21

PAL = {
    "s": hexc("E3A66E"), "k": hexc("F6CC9A"), "S": hexc("B87848"),
    "r": hexc("D94B38"), "R": hexc("9E2A22"),                      # Cepot red skin
    "h": hexc("2A1D26"), "H": hexc("4F3A4A"), "w": hexc("F4F1DE"), "W": hexc("C7C2AC"),
    "e": hexc("18122B"),
    "g": hexc("F2B84B"), "G": hexc("FFE08A"), "d": hexc("B58228"),
    "t": hexc("6A994E"), "T": hexc("386641"),                      # green tunic
    "b": hexc("4A78A8"), "B": hexc("2D4E73"),                      # indigo batik
    "m": hexc("B84A62"), "M": hexc("7D2B40"),                      # maroon kebaya
    "c": hexc("2A9D8F"), "C": hexc("1D6B62"),                      # teal kebaya (Laras)
    "p": hexc("6B4E35"), "P": hexc("473321"),                      # brown cloth/wood
    "n": hexc("36304A"), "N": hexc("211C30"),                      # dark pangsi
    "q": hexc("8C8881"), "Q": hexc("5E5A54"), "l": hexc("B5B0A6"), # candi stone
    "f": hexc("FF9F1C"), "F": hexc("FFE066"),                      # flame / glow
}


def make_human(head_rows, torso_rows, skirt_rows, bob=0, staff=None, hat_rows=None):
    can = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
    y0 = 3 + bob
    for i, r in enumerate(head_rows):
        for x, ch in enumerate(r):
            if ch != ".":
                can.putpixel((x, y0 + i), PAL[ch])
    if hat_rows:
        for i, r in enumerate(hat_rows):
            for x, ch in enumerate(r):
                if ch != ".":
                    can.putpixel((x, y0 - len(hat_rows) + i + 1), PAL[ch])
    for i, r in enumerate(torso_rows):
        for x, ch in enumerate(r):
            if ch != ".":
                can.putpixel((x, y0 + len(head_rows) + i), PAL[ch])
    sy = 3 + len(head_rows) + len(torso_rows)
    for i, r in enumerate(skirt_rows):
        for x, ch in enumerate(r):
            if ch != ".":
                can.putpixel((x, sy + i), PAL[ch])
    if staff:
        sx, col = staff
        for y in range(4, IH - 1):
            can.putpixel((sx, y), PAL[col])
        can.putpixel((sx, 3), PAL["G"])
    return can


HEAD_STD = [
    "....hhhhhh....",
    "...hhHHhhhh...",
    "...hssssssh...",
    "...hsessesh...",
    "...hssssssh...",
    "....SssssS....",
]
HEAD_ELDER = [
    "....wwwwww....",
    "...wwwwwwww...",
    "...wssssssw...",
    "...wsessesw...",
    "...wwssssww...",
    "....wwwwww....",
]
HEAD_WOMAN = [
    ".....hhhh.....",
    "...hhHHhhhh...",
    "..hhsssssshh..",
    "..hhsesseshh..",
    "..hhsssssshh..",
    "...hSssssSh...",
]
HEAD_CEPOT = [
    "....nnnnnn....",
    "...nnppppnn...",
    "...hrkrrkrh...",
    "...hrerrerh...",
    "...hrrrrrrh...",
    "....RRwwRR....",
]
HEAD_SEMAR = [
    "......ww......",
    "....wwwwww....",
    "...hssssssh...",
    "...hsessesh...",
    "..skssssssks..",
    "...SSSSSSSS...",
]


def row_frames(kind):
    frames = []
    for f in range(4):
        bob = (0, 0, -1, 0)[f]
        if kind == 0:  # villager
            im = make_human(
                HEAD_STD,
                ["..tttttttttt..", ".ttTttttttTtt.", ".sTppppppppTs.", "..tTttttttTt.."],
                ["...pppppppp...", "...ppPppPpp...", "...ppP..Ppp...", "...SS....SS..."],
                bob=bob, hat_rows=[".....pppp.....", "...pppppppp..."],
            )
        elif kind == 1:  # elder
            im = make_human(
                HEAD_ELDER,
                ["..bbbbbbbbbb..", ".bbBbbbbbbBbb.", ".sBggggggggBs.", "..bBbbbbbbBb.."],
                ["...pppppppp...", "...ppPppPpp...", "...pppppppp...", "...SS....SS..."],
                bob=bob, staff=(12, "p"), hat_rows=["....pppppp...."],
            )
        elif kind == 2:  # woman / ibu
            im = make_human(
                HEAD_WOMAN,
                ["..mmmmmmmmmm..", ".mmMmmmmmmMmm.", ".sMggggggggMs.", "..mMmmmmmmMm.."],
                ["...pppppppp...", "...ppgpggpp...", "...ppPppPpp...", "....SS..SS...."],
                bob=bob,
            )
        elif kind == 3:  # royal
            im = make_human(
                HEAD_STD,
                ["..gggggggggg..", ".gmMmmmmmmMmg.", ".sMggggggggMs.", "..mMmmmmmmMm.."],
                ["...bbbbbbbb...", "...bbgbbgbb...", "...bbBbbBbb...", "....dd..dd...."],
                bob=bob, hat_rows=["....g.gg.g....", "...gggggggg..."],
            )
        elif kind == 4:  # semar
            im = make_human(
                HEAD_SEMAR,
                [".ssssssssssss.", "ssSssssssssSss", "sswNwwNwwNwwss", ".sNwwNwwNwwNs."],
                ["..nnnnnnnnnn..", "..nnNnnnnNnn..", "...nnnnnnnn...", "....SS..SS...."],
                bob=bob,
            )
        elif kind == 5:  # cepot
            im = make_human(
                HEAD_CEPOT,
                ["..nnnnnnnnnn..", ".nnNnnnnnnNnn.", ".rNrrrrrrrrNr.", "..nNnnnnnnNn.."],
                ["...pppppppp...", "...ppPppPpp...", "...ppP..Ppp...", "...RR....RR..."],
                bob=bob,
            )
        elif kind == 6:  # laras
            im = make_human(
                HEAD_WOMAN,
                ["..cccccccccc..", ".ccCccccccCcc.", ".sCggggggggCs.", "..cCccccccCc.."],
                ["...pppppppp...", "...ppgpggpp...", "...ppPppPpp...", "....SS..SS...."],
                bob=bob, hat_rows=[".........G...."],
            )
        elif kind == 7:  # smith / guard
            im = make_human(
                HEAD_STD,
                [".qqppppppppqq.", ".ppPppppppPpp.", ".sPddddddddPs.", "..pPppppppPp.."],
                ["...nnnnnnnn...", "...nnNnnNnn...", "...nnN..Nnn...", "...PP....PP..."],
                bob=bob, hat_rows=["....nnnnnn...."],
            )
        elif kind == 8:  # lutung / sacred monkey / cat
            rows = [
                "..............",
                "..............",
                "..............",
                "..............",
                "....nnnnnn....",
                "...nNNNNNNn...",
                "...nNfeefNn...",
                "...nNssssNn...",
                "....nnnnnn....",
                "..nnnnnnnnnn..",
                "..nNNNNNNNNn..",
                "..nNnnnnnnNn..n",
                "...nnnnnnnn..n.",
                "...nn....nn.n..",
                "...PP....PPn...",
            ]
            im = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
            for i, r in enumerate(rows):
                for x, ch in enumerate(r[:IW]):
                    if ch != ".":
                        im.putpixel((x, 4 + bob + i), PAL[ch])
        elif kind == 9:  # stone / prasasti / altar
            rows = [
                ".....llll.....",
                "...llqqqqll...",
                "...lqqFFqql...",
                "...lqqqqqql...",
                "..llqqFFqqll..",
                "..lqqqqqqqql..",
                "..lqqQffQqql..",
                "..lqqqqqqqql..",
                "..lQQQQQQQQl..",
                ".llqqqqqqqqll.",
                ".lQQQQQQQQQQl.",
            ]
            im = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
            for i, r in enumerate(rows):
                for x, ch in enumerate(r):
                    if ch != ".":
                        c = PAL["f"] if (ch == "F" and f % 2 == 1) else PAL[ch]
                        im.putpixel((x, 8 + i), c)
        elif kind == 10:  # ornate wooden door / mechanism / stall
            rows = [
                "..pppppppppp..",
                ".ppggggggggpp.",
                ".pPppppppppPp.",
                ".pPpPppppPpPp.",
                ".pPpPppppPpPp.",
                ".pPpPgpggPpPp.",
                ".pPpPppppPpPp.",
                ".pPpPppppPpPp.",
                ".pPppppppppPp.",
                ".pPPPPPPPPPPp.",
            ]
            im = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
            for i, r in enumerate(rows):
                for x, ch in enumerate(r):
                    if ch != ".":
                        im.putpixel((x, 9 + i), PAL[ch])
        else:  # 11: stone oil lamp (oncor / galuh_lamp)
            fl = "F" if f % 2 == 0 else "f"
            rows = [
                f"......{fl}F......",
                f".....f{fl}{fl}f.....",
                ".....gggg.....",
                "....lqqqql....",
                ".....lQql.....",
                ".....lQql.....",
                ".....lQql.....",
                "....llqqll....",
                "...lQQQQQQl...",
            ]
            im = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
            for i, r in enumerate(rows):
                for x, ch in enumerate(r):
                    if ch != ".":
                        im.putpixel((x, 10 + i), PAL[ch])
        o = px.outline(im)
        cell = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
        px._clip_paste(cell, o, (CW - o.width) // 2, CH - o.height - 1)
        frames.append(cell)
    return frames


def main():
    sh = Image.new("RGBA", (CW * 4, CH * 12), (0, 0, 0, 0))
    for r in range(12):
        for c, fr in enumerate(row_frames(r)):
            sh.alpha_composite(fr, (c * CW, r * CH))
    out = px.save(sh, "npcs.png")
    print("wrote", out, sh.size)


if __name__ == "__main__":
    main()
