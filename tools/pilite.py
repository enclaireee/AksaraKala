"""Stdlib-only stand-in for the tiny slice of PIL.Image that pixlib and the sprite generators use.
Use: `import pilite; pilite.install()` before `import pixlib`. If real PIL exists, install() does nothing.
"""
import math
import struct
import sys
import types
import zlib

NEAREST = 0
FLIP_LEFT_RIGHT = 0


class Image:
    def __init__(self, size, data=None):
        self.size = (int(size[0]), int(size[1]))
        self._d = data if data is not None else [(0, 0, 0, 0)] * (self.size[0] * self.size[1])

    width = property(lambda s: s.size[0])
    height = property(lambda s: s.size[1])

    @staticmethod
    def new(mode, size, color=(0, 0, 0, 0)):
        return Image(size, [tuple(color)] * (size[0] * size[1]))

    def putpixel(self, xy, c):
        self._d[xy[1] * self.size[0] + xy[0]] = tuple(c)

    def getpixel(self, xy):
        return self._d[xy[1] * self.size[0] + xy[0]]

    def load(self):
        return _Px(self)

    def copy(self):
        return Image(self.size, list(self._d))

    def crop(self, box):
        x0, y0, x1, y1 = box
        out = Image.new("RGBA", (x1 - x0, y1 - y0))
        for y in range(y0, y1):
            for x in range(x0, x1):
                if 0 <= x < self.size[0] and 0 <= y < self.size[1]:
                    out._d[(y - y0) * out.size[0] + (x - x0)] = self._d[y * self.size[0] + x]
        return out

    def paste(self, src, pos):
        for y in range(src.size[1]):
            for x in range(src.size[0]):
                tx, ty = pos[0] + x, pos[1] + y
                if 0 <= tx < self.size[0] and 0 <= ty < self.size[1]:
                    self._d[ty * self.size[0] + tx] = src._d[y * src.size[0] + x]

    def alpha_composite(self, src, pos=(0, 0)):
        for y in range(src.size[1]):
            for x in range(src.size[0]):
                s = src._d[y * src.size[0] + x]
                tx, ty = pos[0] + x, pos[1] + y
                if s[3] == 0 or not (0 <= tx < self.size[0] and 0 <= ty < self.size[1]):
                    continue
                i = ty * self.size[0] + tx
                d = self._d[i]
                sa, da = s[3] / 255.0, d[3] / 255.0
                oa = sa + da * (1 - sa)
                if oa <= 0:
                    continue
                self._d[i] = tuple(int((s[k] * sa + d[k] * da * (1 - sa)) / oa) for k in range(3)) + (int(oa * 255),)

    def resize(self, size, resample=NEAREST):
        w, h = size
        out = Image.new("RGBA", (w, h))
        for y in range(h):
            sy = min(self.size[1] - 1, y * self.size[1] // h)
            for x in range(w):
                sx = min(self.size[0] - 1, x * self.size[0] // w)
                out._d[y * w + x] = self._d[sy * self.size[0] + sx]
        return out

    def transpose(self, method):
        out = Image.new("RGBA", self.size)
        w, h = self.size
        for y in range(h):
            for x in range(w):
                out._d[y * w + x] = self._d[y * w + (w - 1 - x)]
        return out

    def rotate(self, angle, expand=False):
        """Counter-clockwise degrees, nearest neighbour (PIL convention)."""
        w, h = self.size
        a = math.radians(angle)
        ca, sa = math.cos(a), math.sin(a)
        if expand:
            nw = int(round(abs(w * ca) + abs(h * sa)))
            nh = int(round(abs(w * sa) + abs(h * ca)))
        else:
            nw, nh = w, h
        out = Image.new("RGBA", (nw, nh))
        cx, cy, ncx, ncy = w / 2.0, h / 2.0, nw / 2.0, nh / 2.0
        for y in range(nh):
            for x in range(nw):
                dx, dy = x + 0.5 - ncx, y + 0.5 - ncy
                sx = dx * ca - dy * sa + cx
                sy = dx * sa + dy * ca + cy
                ix, iy = int(math.floor(sx)), int(math.floor(sy))
                if 0 <= ix < w and 0 <= iy < h:
                    out._d[y * nw + x] = self._d[iy * w + ix]
        return out

    def getbbox(self):
        w, h = self.size
        xs, ys = [], []
        for y in range(h):
            for x in range(w):
                if self._d[y * w + x][3]:
                    xs.append(x)
                    ys.append(y)
        return (min(xs), min(ys), max(xs) + 1, max(ys) + 1) if xs else None

    def save(self, path):
        w, h = self.size
        raw = bytearray()
        for y in range(h):
            raw.append(0)
            for x in range(w):
                raw.extend(self._d[y * w + x][:4])

        def chunk(t, b):
            c = struct.pack(">I", len(b)) + t + b
            return c + struct.pack(">I", zlib.crc32(t + b) & 0xFFFFFFFF)
        png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)) \
            + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")
        with open(path, "wb") as f:
            f.write(png)


class _Px:
    def __init__(self, im):
        self.im = im

    def __getitem__(self, k):
        return self.im._d[k[1] * self.im.size[0] + k[0]]

    def __setitem__(self, k, v):
        self.im._d[k[1] * self.im.size[0] + k[0]] = tuple(v)


def install():
    try:
        import PIL  # noqa: F401
        return
    except ImportError:
        pass
    pil = types.ModuleType("PIL")
    mod = types.ModuleType("PIL.Image")
    mod.Image = Image
    mod.new = Image.new
    mod.NEAREST = NEAREST
    mod.FLIP_LEFT_RIGHT = FLIP_LEFT_RIGHT
    pil.Image = mod
    sys.modules["PIL"] = pil
    sys.modules["PIL.Image"] = mod
