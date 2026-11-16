"""Original, generic 48x48 pixel avatars for the quote cards (stylised, not likenesses)."""
from functools import lru_cache

from PIL import Image, ImageDraw

from pxkit import CLEAR, EDGE, rgb, dilate, mask_sub


def _m(draw_fn, size=48):
    m = Image.new("L", (size, size), 0)
    draw_fn(ImageDraw.Draw(m))
    return m


def _part(img, mask, base, shade, hi=None):
    """Fill mask with base; a 2 px crescent on the lower-right in `shade`, top-left rim in `hi`."""
    img.paste(base, (0, 0), mask)
    sh = Image.new("L", mask.size, 0)
    sh.paste(mask, (0, 0))
    moved = Image.new("L", mask.size, 0)
    moved.paste(mask, (-2, -2))
    cres = mask_sub(mask, moved)
    img.paste(shade, (0, 0), cres)
    if hi:
        up = Image.new("L", mask.size, 0)
        up.paste(mask, (0, 2))
        img.paste(hi, (0, 0), mask_sub(mask, up))


SKIN = {"light": (rgb("E8B48C"), rgb("C98A66"), rgb("F4CBA6")), "mid": (rgb("D49A70"), rgb("A8704E"), rgb("E6B48C")),
        "tan": (rgb("C0845C"), rgb("8E5A3E"), rgb("D49C74"))}

PEOPLE = {
    "pearly": dict(skin="mid", hijab=(rgb("E8E4F4"), rgb("A8A0C8")), top=(rgb("F0F0F6"), rgb("B4B0CC")), glasses=False,
                   bg=(rgb("3A2456"), rgb("6B3A5E")), age="teen"),
    "nurbani": dict(skin="light", hijab=(rgb("3FA39B"), rgb("246C70")), top=(rgb("8E4F7A"), rgb("5E2F54")),
                    glasses=False, bg=(rgb("2A1D47"), rgb("52305E")), age="adult"),
    "munawar": dict(skin="tan", hair=(rgb("8C8AA0"), rgb("5E5C78")), top=(rgb("C8A878"), rgb("94784E")), glasses=True,
                    bg=(rgb("1F2A4A"), rgb("3A4A6E")), age="older", moustache=True),
    "yazid": dict(skin="mid", hair=(rgb("2A2236"), rgb("141026")), top=(rgb("3A4A8C"), rgb("232E5E")), glasses=True,
                  bg=(rgb("2A1D47"), rgb("6B3A5E")), age="young"),
}


@lru_cache(maxsize=None)
def portrait(who):
    """48x48 RGBA bust (opaque square, dusk-dithered backdrop)."""
    p = PEOPLE[who]
    skin, skin_sh, skin_hi = SKIN[p["skin"]]
    img = Image.new("RGBA", (48, 48), CLEAR)
    # backdrop: two-tone dusk with a bayer seam
    top, bot = p["bg"]
    d = ImageDraw.Draw(img)
    for y in range(48):
        for x in range(48):
            k = y / 47.0 + (((x + y) % 2) * 0.12 - 0.06)
            img.putpixel((x, y), top if k < 0.5 else bot)
    body = Image.new("RGBA", (48, 48), CLEAR)
    # shoulders / top
    tc, ts = p.get("top", (rgb("444466"), rgb("2A2A44")))
    _part(body, _m(lambda dr: dr.ellipse([3, 36, 45, 70], fill=255)), tc, ts)
    # neck
    _part(body, _m(lambda dr: dr.rectangle([19, 28, 28, 40], fill=255)), skin, skin_sh)
    hijab = p.get("hijab")
    if hijab:
        hc, hs = hijab
        # cape over shoulders and the framing of the head
        _part(body, _m(lambda dr: dr.polygon([(2, 47), (6, 36), (13, 31), (35, 31), (42, 36), (46, 47)], fill=255)), hc, hs)
        _part(body, _m(lambda dr: dr.ellipse([8, 3, 40, 40], fill=255)), hc, hs)
        # face opening
        face = _m(lambda dr: dr.ellipse([14, 11, 34, 35], fill=255))
        _part(body, face, skin, skin_sh, skin_hi)
        # hijab edge over the forehead and cheeks
        body.paste(hc, (0, 0), _m(lambda dr: dr.ellipse([13, 7, 35, 19], fill=255)))
        body.paste(hs, (0, 0), mask_sub(_m(lambda dr: dr.ellipse([13, 9, 35, 21], fill=255)),
                                        _m(lambda dr: dr.ellipse([13, 7, 35, 19], fill=255))))
    else:
        hc, hs = p["hair"]
        _part(body, _m(lambda dr: dr.ellipse([12, 6, 36, 28], fill=255)), hc, hs)
        _part(body, _m(lambda dr: dr.ellipse([14, 11, 34, 35], fill=255)), skin, skin_sh, skin_hi)
        # hairline / fringe
        fr = _m(lambda dr: dr.ellipse([12, 5, 36, 20], fill=255))
        cut = _m(lambda dr: dr.ellipse([15, 12, 35, 26], fill=255))
        if p["age"] == "older":
            fr = mask_sub(fr, _m(lambda dr: dr.ellipse([17, 8, 33, 18], fill=255)))   # receding
        body.paste(hc, (0, 0), mask_sub(fr, cut))
        body.paste(hs, (0, 0), _m(lambda dr: dr.rectangle([12, 16, 14, 20], fill=255)))
        body.paste(hs, (0, 0), _m(lambda dr: dr.rectangle([34, 16, 36, 20], fill=255)))
        # ears
        for ex in (12, 34):
            body.paste(skin_sh, (0, 0), _m(lambda dr, ex=ex: dr.rectangle([ex, 22, ex + 1, 26], fill=255)))
    # shirt collar
    col = Image.new("L", (48, 48), 0)
    ImageDraw.Draw(col).polygon([(19, 38), (24, 44), (29, 38), (24, 40)], fill=255)
    if not hijab:
        body.paste(skin_sh, (0, 0), col)
    if who == "munawar":
        body.paste(rgb("F4EAD0"), (0, 0), _m(lambda dr: dr.polygon([(15, 41), (20, 38), (23, 44), (18, 47)], fill=255)))
        body.paste(rgb("F4EAD0"), (0, 0), _m(lambda dr: dr.polygon([(33, 41), (28, 38), (25, 44), (30, 47)], fill=255)))
    if who in ("yazid",):
        body.paste(rgb("ECE6F2"), (0, 0), _m(lambda dr: dr.polygon([(19, 38), (24, 46), (29, 38), (27, 37), (24, 41), (21, 37)], fill=255)))
    px = body.load()
    dark = rgb("2A1830")
    # eyes: 2x2 dark with 1 px highlight, brows
    for ex in (19, 27):
        for dx in (0, 1):
            for dy in (0, 1):
                px[ex + dx, 22 + dy] = dark
        px[ex, 22] = rgb("5A3A52") if who != "yazid" else dark
    brow = rgb("4A3040") if p["skin"] != "tan" else rgb("3A2430")
    if p.get("hair"):
        brow = p["hair"][1] if p["age"] != "older" else rgb("5E5C78")
    for ex in (18, 26):
        for dx in range(4):
            px[ex + dx, 19 + (1 if (dx in (0,) and ex == 18) or (dx == 3 and ex == 26) else 0)] = brow
    # smile + blush
    mc = rgb("8E3A4A")
    for xy in ((22, 29), (23, 30), (24, 30), (25, 30), (26, 29)):
        px[xy] = mc
    px[21, 28] = mc
    px[27, 28] = mc
    for xy in ((17, 27), (18, 27), (30, 27), (31, 27)):
        px[xy] = (min(255, skin[0] + 14), skin[1] - 22, skin[2] - 14, 255)
    px[24, 25] = skin_sh   # nose
    px[24, 26] = skin_sh
    if p.get("moustache"):
        for x in range(21, 28):
            px[x, 28] = p["hair"][1]
    if p["glasses"]:
        gl = rgb("2A2236") if who == "yazid" else rgb("5A4E80")
        for ex in (16, 26):
            for x in range(ex, ex + 7):
                px[x, 20] = gl
                px[x, 25] = gl
            for y in range(20, 26):
                px[ex, y] = gl
                px[ex + 6, y] = gl
        for x in (23, 24, 25):
            px[x, 22] = gl
        px[17, 21] = rgb("D8FFFB")
        px[27, 21] = rgb("D8FFFB")
    # selective outline around the whole bust (not the backdrop)
    a = body.split()[3]
    ol = mask_sub(dilate(a, 1), a)
    img.alpha_composite(body)
    img.paste(EDGE, (0, 0), ol)
    return img
