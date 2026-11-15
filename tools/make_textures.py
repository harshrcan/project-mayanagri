#!/usr/bin/env python3
"""Generate procedural tileable textures for Project Mayanagri (SA-DE look).

Run:  python3 tools/make_textures.py
Writes: world/textures/*.png  (256x256, tileable, ours — regenerate, don't hand-edit)

All textures are original procedural work (numpy + PIL). No art is ripped
from any game. Licence: ours, CC0-equivalent for the project.
"""
import os
import numpy as np
from PIL import Image

S = 256
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "world", "textures")
os.makedirs(OUT, exist_ok=True)


def _noise(fx, fy, seed):
    """One octave of periodic value noise, tileable on the 256 grid."""
    rng = np.random.default_rng(seed)
    g = rng.random((fy + 1, fx + 1))
    g[-1, :] = g[0, :]
    g[:, -1] = g[:, 0]
    gx = np.arange(S) * fx / S
    gy = np.arange(S) * fy / S
    x0 = gx.astype(int)
    y0 = gy.astype(int)
    x1 = x0 + 1
    y1 = y0 + 1
    tx = (gx - x0)[None, :]
    ty = (gy - y0)[:, None]
    g00 = g[y0[:, None], x0[None, :]]
    g01 = g[y0[:, None], x1[None, :]]
    g10 = g[y1[:, None], x0[None, :]]
    g11 = g[y1[:, None], x1[None, :]]
    top = g00 * (1 - tx) + g01 * tx
    bot = g10 * (1 - tx) + g11 * tx
    return top * (1 - ty) + bot * ty


def fbm(fx, fy, octaves=3, seed=1):
    out = np.zeros((S, S))
    amp, tot = 1.0, 0.0
    for o in range(octaves):
        out += amp * _noise(fx * (2 ** o), fy * (2 ** o), seed + o)
        tot += amp
        amp *= 0.5
    return out / tot


def _save(name, rgb, alpha=None):
    arr = np.clip(rgb, 0, 255).astype(np.uint8)
    if alpha is not None:
        a = np.clip(alpha, 0, 255).astype(np.uint8)
        img = Image.fromarray(np.dstack([arr, a]), "RGBA")
    else:
        img = Image.fromarray(arr, "RGB")
    img.save(os.path.join(OUT, name + ".png"))
    print("wrote", name + ".png")


def _hex(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=float)


def brick(base_hex, mortar_hex, seed=1):
    """8 bricks across, 16 rows; offset every other row; per-brick shade."""
    bw, bh = 32, 16
    base, mortar = _hex(base_hex), _hex(mortar_hex)
    yy, xx = np.mgrid[0:S, 0:S]
    row = yy // bh
    off = (row % 2) * (bw // 2)
    lx = (xx - off) % bw
    ly = yy % bh
    is_mortar = (lx < 2) | (ly < 2)
    col = ((xx - off) // bw) % (S // bw)
    rng = np.random.default_rng(seed)
    shades = 0.85 + 0.3 * rng.random((S // bh, S // bw))
    shade = shades[row, col][:, :, None]
    img = np.where(is_mortar[:, :, None], mortar, base * shade)
    grime = fbm(4, 4, 3, seed + 5)
    img *= (0.90 + 0.20 * grime)[:, :, None]
    stains = fbm(2, 2, 2, seed + 9) > 0.62
    img[stains] *= 0.82
    return img


def plaster(base_hex, seed=2):
    base = _hex(base_hex)
    v = fbm(4, 4, 3, seed)
    img = base * (0.88 + 0.24 * v)[:, :, None]
    stains = fbm(2, 2, 2, seed + 3) > 0.64
    img[stains] *= 0.80
    img += (np.sin(np.arange(S) / 40.0) * 4.0)[:, None, None]
    return img


def asphalt(seed=3):
    base = _hex("2e2a26")
    img = base * (0.90 + 0.20 * fbm(6, 6, 3, seed))[:, :, None]
    rng = np.random.default_rng(seed)
    img += rng.normal(0, 7, (S, S, 1))
    # a couple of lighter repair patches
    for (x0, y0, w, h) in [(40, 180, 90, 40), (150, 40, 70, 55)]:
        img[y0:y0 + h, x0:x0 + w] *= 1.18
    return img


def pavement(seed=4):
    base = _hex("8a8178")
    yy, xx = np.mgrid[0:S, 0:S]
    joint = ((xx % 128) < 3) | ((yy % 128) < 3)
    rng = np.random.default_rng(seed)
    slab_shade = 0.90 + 0.2 * rng.random((2, 2))
    shade = slab_shade[yy // 128, xx // 128][:, :, None]
    img = np.where(joint[:, :, None], _hex("55504a"), base * shade)
    img *= (0.92 + 0.16 * fbm(6, 6, 3, seed))[:, :, None]
    return img


def tin(seed=5):
    base = _hex("7a5a48")
    rust = _hex("8a4632")
    xx = np.arange(S)[None, :]
    corr = 0.86 + 0.14 * np.sin(2 * np.pi * xx / 32.0)
    img = np.zeros((S, S, 3))
    img[:, :] = base
    img *= np.repeat(corr, S, axis=0)[:, :, None]
    r = fbm(3, 3, 3, seed)
    rusty = r > 0.66
    img[rusty] = img[rusty] * 0.45 + rust * 0.55 * (0.9 + 0.2 * r[rusty])[:, None]
    img *= (0.92 + 0.16 * fbm(8, 8, 2, seed + 2))[:, :, None]
    return img


def wood(base_hex, seed=6):
    base = _hex(base_hex)
    yy, xx = np.mgrid[0:S, 0:S]
    plank = yy // 64
    gap = (yy % 64) < 2
    rng = np.random.default_rng(seed)
    pshade = 0.88 + 0.24 * rng.random(4)
    shade = pshade[plank][:, :, None]
    grain = fbm(2, 32, 2, seed)
    img = np.where(gap[:, :, None], _hex("3a2a1c"), base * shade * (0.90 + 0.20 * grain)[:, :, None])
    return img


def cloud(seed=7):
    yy, xx = np.mgrid[0:S, 0:S].astype(float)
    yy /= S
    xx /= S
    a = np.zeros((S, S))
    for (cx, cy, r, s) in [(0.30, 0.52, 0.26, 1.0), (0.55, 0.45, 0.22, 0.9), (0.72, 0.60, 0.18, 0.8), (0.45, 0.62, 0.15, 0.7)]:
        d2 = ((xx - cx) ** 2 + (yy - cy) ** 2) / (r ** 2)
        a += s * np.exp(-d2 * 2.0)
    a = np.clip(a, 0, 1) * 0.92
    a *= 0.85 + 0.15 * fbm(6, 6, 2, seed)
    rgb = np.ones((S, S, 3)) * 255.0
    return rgb, a * 255.0


def main():
    _save("brick_ochre", brick("c08a4b", "6b5a44", seed=11))
    _save("brick_red", brick("bd6f5c", "6a5044", seed=12))
    _save("plaster", plaster("c9a06a", seed=13))
    _save("asphalt", asphalt(seed=14))
    _save("pavement", pavement(seed=15))
    _save("tin", tin(seed=16))
    _save("wood", wood("7a5230", seed=17))
    rgb, a = cloud(seed=18)
    _save("cloud", rgb, alpha=a)
    print("done:", sorted(os.listdir(OUT)))


if __name__ == "__main__":
    main()
