#!/usr/bin/env python3
"""Blank order-note paper (text is drawn by the game so it can change per day)."""
import random
from PIL import Image
random.seed(9)
W, H = 157, 95
im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
px = im.load()
for y in range(H):
    for x in range(W):
        n = random.randint(-6, 6)
        base = (176 + n, 150 + n, 92 + n)
        # edge darkening and a stain
        e = min(x, y, W - 1 - x, H - 1 - y)
        f = 0.72 + 0.28 * min(1.0, e / 6.0)
        stain = 1.0 - 0.18 * max(0, 1 - ((x - 120) ** 2 + (y - 70) ** 2) ** 0.5 / 28.0)
        px[x, y] = (int(base[0] * f * stain), int(base[1] * f * stain), int(base[2] * f * stain), 255)
# torn corner
for y in range(0, 8):
    for x in range(W - 8 + y // 2, W):
        px[x, y] = (0, 0, 0, 0)
# tape on top
for y in range(0, 7):
    for x in range(W // 2 - 14, W // 2 + 14):
        px[x, y] = (150, 150, 140, 190)
# outline
src = im.copy(); sp = src.load()
for y in range(H):
    for x in range(W):
        if sp[x, y][3] == 0:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < W and 0 <= ny < H and sp[nx, ny][3] > 0:
                    px[x, y] = (22, 18, 14, 255); break
im.save("assets/emir_notu_bos.png")
print("note ok")
