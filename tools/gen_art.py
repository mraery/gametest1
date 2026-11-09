#!/usr/bin/env python3
"""High-visibility atmospheric pixel-art generator for 'Hapishane Kantin Memuru' (Ironhold 1984).
Generates & upgrades:
- 12 high-contrast, anatomically sculpted prisoner portraits with rim lighting & detailed uniforms (assets/p_*.png + mahkum*.png)
- 7 distinct side-profile prisoner queue silhouettes with overhead corridor rim lighting (assets/kuyruk_1..7.png)
- Animated security guard sprites for Sgt. Dobbs without shadow-outline artifacts (assets/g0_*.png + gardiyan_*.png)
- 3 steel/industrial cupboard cabinet panels with category headers & lit shelves (assets/dolap_*.png)
- 9 crisp, vibrant, custom pixel-art cupboard item sprites (assets/esya_*.png)
- Upgraded stamps, stamp drawer base, delivery tray, dispatch note, rulebook & newspaper props
- Well-lit atmospheric background preserving original detail (assets/ana_ekran_arkaplan.png)
"""
import math, random, os
from PIL import Image, ImageDraw, ImageEnhance

OUT = "assets"
os.makedirs(OUT, exist_ok=True)
OUTLINE = (14, 13, 18, 255)


def mix(a, b, t):
    t = max(0.0, min(1.0, t))
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def shade(c, f):
    return tuple(max(0, min(255, int(v * f))) for v in c[:3])


class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        self.px = self.im.load()

    def put(self, x, y, c):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            if len(c) == 3:
                c = (*c, 255)
            self.px[x, y] = c

    def get(self, x, y):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.px[x, y]
        return (0, 0, 0, 0)

    def rect(self, x0, y0, x1, y1, c):
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                self.put(x, y, c)

    def line(self, x0, y0, x1, y1, c, th=1):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
        for i in range(n + 1):
            t = i / max(1, n)
            x = x0 + (x1 - x0) * t
            y = y0 + (y1 - y0) * t
            for dx in range(th):
                for dy in range(th):
                    self.put(x + dx, y + dy, c)

    def outline(self, col=OUTLINE):
        src = self.im.copy()
        sp = src.load()
        for y in range(self.h):
            for x in range(self.w):
                if sp[x, y][3] == 0:
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < self.w and 0 <= ny < self.h and sp[nx, ny][3] > 180:
                            self.px[x, y] = col
                            break


# ==================================================================================
# 1. HIGH-CONTRAST PRISONER PORTRAITS (120x150)
# ==================================================================================
W, H = 120, 150
CX = 60


def head_half_width(y, rx=25, jaw_w=20, chin_w=7):
    """Organic cranium -> cheekbone -> jaw -> rounded chin profile (y in 18..86)."""
    if y < 18 or y > 86:
        return -1.0
    if y <= 46:
        t = (46 - y) / 28.0
        return rx * math.sqrt(max(0.0, 1.0 - 0.88 * (t ** 2.1)))
    elif y <= 66:
        t = (y - 46) / 20.0
        return rx * (1.0 - t) + jaw_w * t
    else:
        t = (y - 66) / 20.0
        cur = jaw_w * (1.0 - (t ** 1.45)) + chin_w * (t ** 1.45)
        if y > 81:
            u = (y - 81) / 5.0
            cur *= math.sqrt(max(0.0, 1.0 - 0.85 * u * u))
        return cur


def quantize_skin(skin, light, x, y):
    """7-step painterly pixel-art ramp with brighter visibility and crisp highlights."""
    ramp = [
        shade(skin, 0.46),
        shade(skin, 0.58),
        shade(skin, 0.72),
        shade(skin, 0.86),
        shade(skin, 1.00),
        shade(skin, 1.12),
        shade(skin, 1.24),
    ]
    jitter = (((x * 19 + y * 37) ^ (x * 7)) % 9 - 4) * 0.014
    v = max(0.0, min(0.999, light + jitter)) * (len(ramp) - 1)
    return ramp[int(round(v))]


def make_portrait(p, seed):
    rnd = random.Random(seed)
    c = Canvas(W, H)
    skin = p["skin"]
    cloth = p.get("cloth", (78, 92, 82))
    rx = p.get("rx", 25)
    jaw_w = p.get("jaw_w", 19)
    chin_w = p.get("chin_w", 7)

    # ---- 1. Shoulders & Detailed Prison Jumpsuit (y = 95..149)
    for y in range(95, H):
        t = (y - 95) / 55.0
        halfw = min(56, int(18 + 38 * (t ** 0.78)))
        for x in range(CX - halfw, CX + halfw + 1):
            lx = (CX - x) / 56.0
            f = 0.96 + 0.24 * lx - 0.16 * t
            fold = math.sin((x - CX) * 0.28 + y * 0.08) * 0.07
            col = shade(cloth, max(0.42, f + fold))

            # Ribbed institutional undershirt in central V-neck
            v_width = max(0.0, 11.5 - (y - 95) * 0.52)
            if abs(x - CX) < v_width and y < 118:
                u_sh = 0.90 if (x % 2 == 0) else 0.78
                col = shade((182, 176, 162), u_sh - 0.12 * ((y - 95) / 24.0))
            # Collar lapel trim
            elif abs(abs(x - CX) - (13 - (y - 95) * 0.45)) < 2.2 and y < 124:
                col = shade(cloth, 1.22 if x < CX else 0.55)
            # Center zipper / placket seam below V-neck
            elif abs(x - CX) <= 1 and y >= 117:
                col = shade(cloth, 0.48 if x == CX else 1.15)
            # Shoulder institutional stripe accent
            elif abs(x - CX) > halfw - 7 and y < 116 and (y // 3) % 2 == 0:
                col = mix(col, (210, 165, 65), 0.45)

            # Crisp rim highlight on outer shoulder edges
            if abs(x - (CX - halfw)) <= 1:
                col = shade(cloth, 1.32)
            elif abs(x - (CX + halfw)) <= 1:
                col = mix(col, (145, 170, 200), 0.38)
            c.put(x, y, col)

    # ---- 2. Muscular Neck & Collar V (y = 76..112)
    for y in range(76, 112):
        nw = 13 + int(max(0, (y - 88)) * 0.22)
        for x in range(CX - nw, CX + nw + 1):
            if y >= 95 and abs(x - CX) > max(0, 11 - (y - 95) * 0.62):
                continue
            lx = (CX - x) / 16.0
            light = 0.56 + 0.22 * lx
            chin_hw = max(0.0, head_half_width(min(86, y + 4), rx, jaw_w, chin_w))
            if y < 92 and abs(x - CX) < chin_hw + 4:
                light -= 0.24 * max(0.0, (92 - y) / 14.0)
            td1 = abs(abs(x - CX) - (9 - (y - 80) * 0.22))
            if td1 < 1.6 and y > 84:
                light += 0.10
            elif td1 < 3.0 and abs(x - CX) < 6 and y > 88:
                light -= 0.08
            c.put(x, y, quantize_skin(skin, light, x, y))

    # High-contrast Prison ID badge on chest
    if p.get("tag", True):
        c.rect(74, 116, 98, 127, (222, 212, 186))
        c.rect(74, 116, 98, 117, (245, 238, 215))
        c.rect(74, 127, 98, 127, (95, 86, 70))
        c.rect(76, 119, 80, 125, (195, 42, 36))
        for i in range(4):
            c.rect(83 + i * 3, 120, 84 + i * 3, 125, (28, 25, 22))

    # Left chest prison block stencil patch
    c.rect(24, 118, 42, 125, shade(cloth, 0.62))
    for i in range(3):
        c.rect(26 + i * 5, 120, 28 + i * 5, 123, (215, 185, 95))

    # Bloodstains / grime on uniform
    if p.get("torn"):
        for _ in range(14):
            bx = CX + rnd.randint(-36, 36)
            by = rnd.randint(104, 145)
            for dy in range(-2, 3):
                for dx in range(-3, 4):
                    if dx * dx + dy * dy <= 6 and c.get(bx + dx, by + dy)[3]:
                        c.put(bx + dx, by + dy, mix(c.get(bx + dx, by + dy), (112, 24, 24), 0.65))

    if p.get("straps"):
        for off in (-1, 1):
            c.line(CX - 34 * off, 100, CX + 24 * off, 149, (116, 104, 86), 4)
            c.line(CX - 34 * off + 1, 100, CX + 24 * off + 1, 149, (164, 150, 124), 1)
        c.rect(CX - 6, 122, CX + 6, 132, (130, 136, 144))
        c.rect(CX - 3, 125, CX + 3, 129, (55, 58, 64))

    # ---- 3. Ears (y = 44..61)
    for sx in (-1, 1):
        if p.get("no_ear") == sx:
            continue
        hw = int(head_half_width(52, rx, jaw_w, chin_w))
        ex = CX + sx * (hw + 1)
        for y in range(45, 61):
            ew = 3 if 47 <= y <= 58 else 2
            for k in range(ew):
                sh = 0.84 if sx < 0 else 0.62
                if k == ew - 1:
                    sh += 0.14 if sx < 0 else 0.10
                c.put(ex + sx * k, y, shade(skin, sh))
        c.rect(ex + sx, 49, ex + sx * 2, 56, shade(skin, 0.44))

    # ---- 4. Sculpted Head (y = 18..86)
    gaunt = p.get("gaunt", False)
    underlight = p.get("underlight", False)
    for y in range(18, 87):
        hw = head_half_width(y, rx, jaw_w, chin_w)
        if hw < 0:
            continue
        ihw = int(round(hw))
        for x in range(CX - ihw, CX + ihw + 1):
            nx = (x - CX) / max(1.0, rx)
            ny = (y - 52) / 34.0
            nz = math.sqrt(max(0.05, 1.0 - min(0.95, nx * nx * 0.85 + ny * ny * 0.75)))
            # Balanced top-left key light + stronger ambient fill
            light = (-0.32 * nx - 0.26 * ny + 0.84 * nz)

            # Cool rim light on right edge of face
            if nx > 0.72:
                light += 0.24 * ((nx - 0.72) / 0.28)

            # Deep sunken eye sockets (y ~ 47..55, x ~ CX ± 11)
            for sx in (-1, 1):
                edx = (x - (CX + sx * 11)) / 7.5
                edy = (y - 50) / 4.8
                ed2 = edx * edx + edy * edy
                if ed2 < 1.0:
                    light -= 0.34 * (1.0 - ed2)

            # Brow ridge prominence (y ~ 42..45)
            if 41 <= y <= 45 and abs(x - CX) < 20:
                light += 0.12 * (1.0 - abs(y - 43) / 2.5)

            # Glabella frown furrow between brows
            if 40 <= y <= 49 and abs(x - CX) <= 2:
                light -= 0.15 * (1.0 - abs(x - CX) / 2.5)

            # Nose bridge highlight & side shadows (y = 46..63)
            if 46 <= y <= 63:
                if -2 <= x - CX <= 1:
                    light += 0.18
                elif 2 <= abs(x - CX) <= 5:
                    light -= 0.12

            # Cheekbone highlight & hollow gaunt cavity below cheekbone
            for sx in (-1, 1):
                cdx = (x - (CX + sx * 15)) / 7.0
                cdy = (y - 57) / 4.5
                if cdx * cdx + cdy * cdy < 1.0:
                    light += 0.12 * (1.0 - (cdx * cdx + cdy * cdy))
                hdx = (x - (CX + sx * 14)) / 6.5
                hdy = (y - 68) / 8.0
                hd2 = hdx * hdx + hdy * hdy
                if hd2 < 1.0:
                    depth = 0.26 if gaunt else 0.14
                    light -= depth * (1.0 - hd2)

            # Nasolabial folds
            for sx in (-1, 1):
                fx = CX + sx * (5 + (y - 61) * 0.45)
                if 61 <= y <= 75 and abs(x - fx) < 1.6:
                    light -= 0.16 * (1.0 - abs(x - fx) / 1.6)

            # Chin boss & sub-mental shadow
            if 76 <= y <= 83 and abs(x - CX) < 6:
                light += 0.10
            if y >= 83:
                light -= 0.18

            if underlight and y > 62:
                light += 0.14 * ((y - 62) / 24.0)

            c.put(x, y, quantize_skin(skin, light, x, y))

    # Jawline shadow rim along lower jaw so head separates cleanly from neck
    for y in range(68, 87):
        hw = int(round(head_half_width(y, rx, jaw_w, chin_w)))
        for sx in (-1, 1):
            jx = CX + sx * hw
            if c.get(jx, y)[3]:
                c.put(jx, y, shade(skin, 0.38 if sx < 0 else 0.92))
            if c.get(jx - sx, y)[3] and y > 75:
                c.put(jx - sx, y, shade(skin, 0.48))

    # ---- 5. Hair / Skull Features
    hair = p.get("hair", "bald")
    hcol = p.get("hcol", (34, 30, 28))
    if hair in ("buzz", "slick", "long"):
        for y in range(16, 40):
            hw = head_half_width(max(18, y), rx + 1, jaw_w, chin_w)
            if hw < 0:
                continue
            ihw = int(round(hw))
            for x in range(CX - ihw, CX + ihw + 1):
                hline = 30 - int(3 * math.cos((x - CX) / max(1.0, rx) * 1.5))
                if abs(x - CX) > ihw - 3 and y < 44:
                    hline = 42
                if y <= hline:
                    sh = 1.08 if x < CX else 0.78
                    if hair == "buzz":
                        if (x + y) % 2 == 0 and y > hline - 3:
                            continue
                        col = shade(hcol, sh * (0.9 + 0.18 * ((x * 5 + y * 3) % 3)))
                    elif hair == "slick":
                        stripe = 1.35 if (x - y // 2) % 4 == 0 else 0.90
                        col = shade(hcol, sh * stripe)
                    else:
                        col = shade(hcol, sh * (0.85 + 0.28 * ((x + y) % 3)))
                    c.put(x, y, col)
        if hair == "long":
            for sx in (-1, 1):
                for y in range(30, 96):
                    hw = int(round(head_half_width(min(84, max(24, y)), rx, jaw_w, chin_w)))
                    bx = CX + sx * (hw + 1) + int(math.sin(y * 0.3 + sx) * 1.5)
                    for k in range(5):
                        px_x = bx - sx * k
                        if y > 55 and k > 3:
                            continue
                        c.put(px_x, y, shade(hcol, 1.05 if (y + k) % 3 else 0.65))
    elif hair == "mohawk":
        mcol = p.get("mcol", (185, 38, 38))
        for y in range(9, 34):
            w = 4 if y > 15 else (2 if (y % 2 == 0) else 3)
            for x in range(CX - w, CX + w + 1):
                if y < 14 and abs(x - CX) % 2 == 1:
                    continue
                sh = 1.20 if x < CX else 0.80
                c.put(x, y, shade(mcol, sh * (0.88 + 0.15 * ((x + y) % 3))))

    # Forehead creases
    if p.get("wrinkle", True):
        for wy in (34, 37, 40):
            for x in range(CX - 12, CX + 13):
                dip = 1 if abs(x - CX) < 3 else 0
                if c.get(x, wy + dip)[3]:
                    c.put(x, wy + dip, shade(c.get(x, wy + dip), 0.72))

    # ---- 6. Eyes & Brows (y ~ 48..52)
    eyey = 49
    eye_style = p.get("eyes", "normal")
    glow = p.get("glow", (245, 70, 55))
    for sx in (-1, 1):
        ex = CX + sx * 11
        if p.get("patch") == sx:
            for dy in range(-4, 5):
                for dx in range(-6, 7):
                    if (dx / 6.2) ** 2 + (dy / 4.2) ** 2 <= 1.0:
                        c.put(ex + dx, eyey + dy, (22, 20, 26))
            c.line(ex - 5, eyey - 2, CX - sx * 24, 34, (32, 28, 36), 2)
            c.line(ex + 5 * sx, eyey + 1, CX + sx * 24, 54, (32, 28, 36), 2)
            continue

        for dx in range(-5, 6):
            c.put(ex + dx, eyey - 3, shade(skin, 0.32))
            c.put(ex + dx, eyey + 3, shade(skin, 0.40))
            c.put(ex + dx, eyey + 4, shade(skin, 0.54))

        if eye_style in ("hollow", "glow"):
            for dy in range(-2, 3):
                for dx in range(-5, 6):
                    if (dx / 5.2) ** 2 + (dy / 2.6) ** 2 <= 1.0:
                        c.put(ex + dx, eyey + dy, (12, 10, 16))
            c.rect(ex - 1, eyey - 1, ex, eyey, glow)
            c.put(ex - 2, eyey, shade(glow, 0.55))
            c.put(ex + 1, eyey, shade(glow, 0.55))
        elif eye_style == "blank":
            for dy in range(-1, 2):
                for dx in range(-4, 5):
                    c.put(ex + dx, eyey + dy, (212, 222, 228) if abs(dy) == 0 else (168, 178, 186))
            c.rect(ex - 1, eyey - 1, ex, eyey, (240, 246, 250))
            c.put(ex - 4, eyey, (140, 60, 60))
            c.put(ex + 4, eyey, (140, 60, 60))
        elif eye_style == "blind_left" and sx == -1:
            for dy in range(-1, 2):
                for dx in range(-4, 5):
                    c.put(ex + dx, eyey + dy, (202, 208, 216))
            c.put(ex, eyey, (235, 240, 245))
        else:
            for dy in range(-1, 2):
                for dx in range(-4, 5):
                    col = (214, 206, 188) if dy == 0 else (172, 162, 144)
                    if abs(dx) == 4:
                        col = (165, 64, 58)
                    c.put(ex + dx, eyey + dy, col)
            r_sz = 2 if (eye_style == "mismatch" and sx > 0) else 1
            for dy in range(-r_sz, r_sz + 1):
                for dx in range(-r_sz, r_sz + 1):
                    if abs(dx) + abs(dy) <= r_sz + 1 and abs(dy) <= 1:
                        c.put(ex + dx, eyey + dy, (18, 16, 20))
            c.put(ex - 1, eyey - 1, (245, 242, 230))

    # Heavy angry eyebrows
    bcol = shade(hcol, 0.85)
    slant = p.get("slant", 1.2)
    for sx in (-1, 1):
        if p.get("patch") == sx:
            continue
        for k in range(2, 16):
            bx = CX + sx * k
            by = eyey - 6 - int((k - 2) * 0.22 * slant)
            c.put(bx, by, bcol)
            c.put(bx, by + 1, bcol)

    # ---- 7. Nose (y = 49..63)
    ny0, ny1 = 49, 62
    broken = p.get("broken_nose", False)
    for y in range(ny0, ny1 + 1):
        sh_x = 2 if (broken and y > 54) else 0
        c.put(CX - 1 + sh_x, y, shade(skin, 1.16))
        c.put(CX + sh_x, y, shade(skin, 1.04))
        c.put(CX + 2 + sh_x, y, shade(skin, 0.56))
        c.put(CX - 3 + sh_x, y, shade(skin, 0.64))
    c.rect(CX - 4, ny1, CX + 4, ny1 + 2, shade(skin, 0.60))
    c.rect(CX - 2, ny1 - 1, CX + 1, ny1 + 1, shade(skin, 1.02))
    c.rect(CX - 3, ny1 + 1, CX - 2, ny1 + 2, (24, 16, 16))
    c.rect(CX + 2, ny1 + 1, CX + 3, ny1 + 2, (24, 16, 16))

    # ---- 8. Beard / Stubble
    beard = p.get("beard")
    bcol2 = p.get("bcol", (36, 32, 28))
    if beard:
        for y in range(62, 87):
            hw = int(round(head_half_width(y, rx, jaw_w, chin_w)))
            for x in range(CX - hw, CX + hw + 1):
                px = c.get(x, y)
                if not px[3]:
                    continue
                if beard == "stubble":
                    if (x * 11 + y * 17) % 3 == 0:
                        c.put(x, y, mix(px, bcol2, 0.42))
                elif beard == "full":
                    if y > 66 or abs(x - CX) > 10:
                        sh = 1.05 if x < CX else 0.76
                        c.put(x, y, shade(bcol2, sh * (0.85 + 0.25 * ((x * 3 + y * 5) % 3))))

    # ---- 9. Mouth (my = 71)
    my = 71
    mouth = p.get("mouth", "flat")
    if mouth == "flat":
        c.rect(CX - 8, my - 1, CX + 8, my - 1, shade(skin, 0.52))
        c.rect(CX - 9, my, CX + 9, my, (28, 16, 18))
        c.rect(CX - 7, my + 1, CX + 7, my + 2, shade(skin, 0.72))
        c.rect(CX - 6, my + 3, CX + 6, my + 3, shade(skin, 0.45))
        c.put(CX - 10, my + 1, (36, 20, 20))
        c.put(CX + 10, my + 1, (36, 20, 20))
    elif mouth == "stitched":
        c.rect(CX - 11, my - 1, CX + 11, my + 1, shade(skin, 0.50))
        c.rect(CX - 11, my, CX + 11, my, (24, 12, 14))
        for k in range(-9, 10, 3):
            c.line(CX + k, my - 3, CX + k + 1, my + 3, (24, 22, 24))
            c.put(CX + k, my - 4, (145, 36, 36))
            c.put(CX + k + 1, my + 4, (145, 36, 36))
    elif mouth == "grin":
        c.rect(CX - 11, my - 2, CX + 11, my + 4, (22, 10, 12))
        for k in range(-9, 10):
            if k in (-3, 4) and p.get("missing_teeth"):
                continue
            tcol = (225, 195, 85) if k == -6 else ((212, 200, 162) if k % 2 == 0 else (178, 166, 130))
            c.rect(CX + k, my - 1, CX + k, my + 1, tcol)
            if k % 2 == 0:
                c.rect(CX + k, my + 2, CX + k, my + 3, shade(tcol, 0.85))
        c.line(CX - 11, my - 1, CX - 13, my - 3, (28, 14, 16))
        c.line(CX + 11, my - 1, CX + 13, my - 3, (28, 14, 16))
    elif mouth == "slack":
        c.rect(CX - 7, my - 1, CX + 7, my + 4, (20, 8, 10))
        c.rect(CX - 5, my - 1, CX + 5, my, (195, 184, 152))
        c.rect(CX - 4, my + 3, CX + 4, my + 4, (126, 34, 38))
        c.line(CX + 4, my + 4, CX + 5, my + 11, (140, 28, 30))
    elif mouth == "snarl":
        c.rect(CX - 10, my - 1, CX + 10, my + 3, (20, 8, 10))
        for k in range(-8, 9, 2):
            h = 2 if abs(k) in (6, 8) else 1
            c.rect(CX + k, my - 1, CX + k + 1, my - 1 + h, (218, 206, 164))
            c.rect(CX + k, my + 2, CX + k + 1, my + 3, (190, 178, 140))
    elif mouth == "muzzle":
        for y in range(60, 86):
            hw = int(round(head_half_width(y, rx, jaw_w, chin_w)))
            for x in range(CX - hw, CX + hw + 1):
                nx = (x - CX) / max(1.0, hw)
                sh = 0.90 - 0.30 * nx - 0.12 * ((y - 60) / 26.0)
                col = shade((118, 124, 134), max(0.38, sh))
                if 66 <= y <= 80 and abs(x - CX) <= 13 and (x - CX) % 4 == 0:
                    col = (22, 22, 28)
                elif y in (61, 65, 81):
                    col = shade(col, 1.28 if y == 61 else 0.72)
                c.put(x, y, col)
        for rx_off in (-16, -10, 10, 16):
            c.rect(CX + rx_off, 62, CX + rx_off + 1, 63, (205, 210, 220))

    # ---- 10. Scars, Burns, Bandages, Hoods & Tattoos
    for (x0, y0, x1, y1) in p.get("scars", []):
        c.line(CX + x0, y0, CX + x1, y1, (158, 42, 46), 1)
        c.line(CX + x0 + 1, y0, CX + x1 + 1, y1, (216, 162, 156), 1)
        for i in range(1, 5):
            t = i / 5.0
            sx = CX + x0 + (x1 - x0) * t
            sy = y0 + (y1 - y0) * t
            c.line(sx - 2, sy - 1, sx + 2, sy + 1, (68, 28, 30))

    if p.get("claw"):
        for k in range(-1, 2):
            c.line(CX + 4 + k * 4, 36 + k * 2, CX + 15 + k * 4, 68 + k * 2, (156, 28, 32), 1)
            c.line(CX + 5 + k * 4, 36 + k * 2, CX + 16 + k * 4, 68 + k * 2, (72, 16, 18), 1)

    if p.get("burn"):
        bx, by = CX - 13, 56
        for y in range(36, 78):
            for x in range(CX - 26, CX - 1):
                if not c.get(x, y)[3]:
                    continue
                d = math.hypot((x - bx) / 13.0, (y - by) / 18.0)
                wobble = 0.18 * math.sin(y * 0.45 + x * 0.3) + 0.12 * math.cos(y * 0.8 - x * 0.5)
                if d + wobble < 1.0:
                    px = c.get(x, y)
                    if math.hypot((x - (CX - 11)) / 5.0, (y - eyey) / 2.5) < 1.0:
                        continue
                    v = math.sin(x * 0.9) * math.cos(y * 0.9)
                    bcol_burn = (142, 52, 52) if v > 0.2 else ((98, 34, 36) if v < -0.2 else (172, 82, 74))
                    strength = min(0.85, (1.0 - (d + wobble)) * 1.3)
                    c.put(x, y, mix(px, bcol_burn, strength))

    if p.get("bruise"):
        bx, by = p["bruise"]
        for y in range(by - 8, by + 9):
            for x in range(CX + bx - 9, CX + bx + 10):
                d = math.hypot((x - (CX + bx)) / 9.0, (y - by) / 8.0)
                if d < 1.0 and c.get(x, y)[3]:
                    c.put(x, y, mix(c.get(x, y), (84, 42, 96), 0.55 * (1.0 - d)))

    if p.get("stitch_head"):
        c.line(CX - 15, 28, CX + 8, 33, (32, 18, 20), 1)
        c.line(CX - 15, 29, CX + 8, 34, (158, 46, 46), 1)
        for k in range(-13, 7, 3):
            yy = 28 + int((k + 15) * 5 / 23.0)
            c.line(CX + k, yy - 3, CX + k, yy + 3, (28, 24, 28))

    if p.get("bandage"):
        for y in range(22, 41):
            hw = int(round(head_half_width(max(24, y), rx + 1, jaw_w, chin_w))) + 1
            for x in range(CX - hw, CX + hw + 1):
                sh = 1.02 - 0.26 * ((x - CX) / max(1, hw))
                stripe = 0.92 if (y + x // 6) % 4 == 0 else 1.0
                col = shade((218, 208, 186), sh * stripe)
                if math.hypot(x - (CX + 11), y - 32) < 6.5:
                    col = mix(col, (148, 28, 30), 0.78)
                c.put(x, y, col)

    if p.get("tear"):
        tx = CX + p["tear"]
        c.rect(tx, 55, tx + 1, 58, (42, 64, 102))
        c.put(tx, 54, (42, 64, 102))

    if p.get("hood"):
        hc = p["hood"]
        for y in range(12, 108):
            for x in range(CX - 42, CX + 43):
                dx = (x - CX) / 40.0
                dy = (y - 54) / 48.0
                outer = dx * dx + dy * dy
                fh = head_half_width(y, rx - 2, jaw_w - 2, chin_w)
                arch_top = 29 + int(((x - CX) / 18.0) ** 2 * 6)
                in_face = (fh > 0 and abs(x - CX) < fh and arch_top <= y <= 84)
                if outer <= 1.0 and not in_face:
                    f = 0.96 - 0.30 * max(0.0, dx) - 0.18 * ((y - 12) / 96.0)
                    if fh > 0 and abs(abs(x - CX) - fh) < 3 and 28 <= y <= 85:
                        f *= 0.62
                    c.put(x, y, shade(hc, max(0.32, f)))
        for y in range(28, 56):
            for x in range(CX - 25, CX + 26):
                px = c.get(x, y)
                if px[3] and not (y in (eyey - 1, eyey) and abs(abs(x - CX) - 11) <= 2):
                    k = max(0.0, min(1.0, (56 - y) / 26.0))
                    c.put(x, y, shade(px, 1.0 - 0.48 * k))

    # ---- 11. Final Crisp Outline & Balanced Contrast
    c.outline()
    im = c.im
    px = im.load()
    tint = p.get("tint", (0.98, 1.00, 1.02))
    for y in range(H):
        for x in range(W):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            f = 1.0 - 0.14 * max(0.0, (y - 96) / 54.0)
            f *= 1.0 - 0.08 * (abs(x - CX) / 60.0)
            px[x, y] = (
                max(0, min(255, int(r * f * tint[0]))),
                max(0, min(255, int(g * f * tint[1]))),
                max(0, min(255, int(b * f * tint[2]))),
                a,
            )
    return im


PRISONERS = {
    "dutch": dict(
        skin=(166, 142, 122), cloth=(78, 94, 82), hair="buzz", hcol=(36, 32, 28),
        eyes="blind_left", mouth="flat", scars=[(-15, 39, -6, 62)], tear=-16,
        beard="stubble", slant=1.3, torn=True, wrinkle=True
    ),
    "ghost": dict(
        skin=(192, 196, 194), cloth=(92, 102, 108), hair="bald",
        eyes="blank", mouth="flat", gaunt=True, rx=24, jaw_w=17, chin_w=6,
        tint=(0.92, 0.98, 1.06), wrinkle=True
    ),
    "vince": dict(
        skin=(158, 138, 112), cloth=(112, 82, 58), hair="slick", hcol=(24, 22, 22),
        eyes="normal", mouth="grin", missing_teeth=True, broken_nose=True,
        beard="stubble", slant=1.5, wrinkle=True
    ),
    "doc": dict(
        skin=(168, 150, 132), cloth=(76, 96, 106), hair="bald",
        eyes="normal", patch=1, mouth="flat", bandage=True,
        scars=[(6, 60, 17, 79)], bruise=(-13, 58), beard="stubble", gaunt=True
    ),
    "moe": dict(
        skin=(148, 122, 104), cloth=(86, 82, 72), hair="bald",
        eyes="mismatch", mouth="muzzle", rx=27, jaw_w=23, chin_w=10,
        straps=True, slant=1.6, bruise=(12, 54), stitch_head=True
    ),
    "eddie": dict(
        skin=(176, 182, 172), cloth=(74, 88, 84), hair="long", hcol=(30, 30, 28),
        eyes="hollow", glow=(245, 65, 55), mouth="slack", gaunt=True,
        rx=23, jaw_w=16, chin_w=5, underlight=True, tint=(0.92, 0.98, 1.04)
    ),
    "wolf": dict(
        skin=(162, 130, 106), cloth=(104, 76, 56), hair="long", hcol=(46, 34, 26),
        beard="full", bcol=(48, 36, 26), eyes="glow", glow=(250, 190, 50),
        mouth="snarl", claw=True, slant=1.7, rx=26, jaw_w=21, torn=True
    ),
    "stitches": dict(
        skin=(172, 162, 146), cloth=(84, 92, 98), hair="bald",
        eyes="mismatch", mouth="stitched", stitch_head=True,
        scars=[(-14, 38, -5, 56)], gaunt=True, tear=15
    ),
    "tommy": dict(
        skin=(170, 146, 126), cloth=(118, 74, 62), hair="mohawk", mcol=(175, 36, 36),
        eyes="mismatch", mouth="grin", missing_teeth=True, burn=True,
        slant=1.5, torn=True
    ),
    "crow": dict(
        skin=(152, 134, 118), cloth=(68, 74, 86), hood=(58, 64, 76),
        eyes="glow", glow=(205, 232, 255), mouth="flat",
        scars=[(-12, 58, -3, 74)], beard="stubble", underlight=True
    ),
    "elias": dict(
        skin=(170, 152, 134), cloth=(88, 98, 84), hair="buzz", hcol=(56, 48, 42),
        eyes="normal", mouth="flat", bruise=(-12, 56),
        scars=[(9, 36, 16, 46)], beard="stubble", slant=0.8, gaunt=True
    ),
    "hargrove": dict(
        skin=(178, 166, 150), cloth=(96, 92, 84), hair="bald",
        eyes="normal", mouth="slack", gaunt=True, rx=23, jaw_w=16, chin_w=5,
        wrinkle=True, scars=[(-16, 58, -11, 76), (16, 58, 11, 76)]
    ),
}


def gen_prisoners():
    for i, (k, p) in enumerate(PRISONERS.items()):
        im = make_portrait(p, 100 + i)
        im.save(os.path.join(OUT, "p_%s.png" % k))
    Image.open(os.path.join(OUT, "p_dutch.png")).save(os.path.join(OUT, "mahkum.png"))
    Image.open(os.path.join(OUT, "p_vince.png")).save(os.path.join(OUT, "mahkum_2.png"))
    Image.open(os.path.join(OUT, "p_wolf.png")).save(os.path.join(OUT, "mahkum_3.png"))
    Image.open(os.path.join(OUT, "p_doc.png")).save(os.path.join(OUT, "mahkum_4.png"))
    print("prisoners ok")


# ==================================================================================
# 2. SIDE-PROFILE QUEUE SILHOUETTES (36x88) - Sculpted inmates with strong rim light
# ==================================================================================
def make_queue(idx):
    w, h = 36, 88
    c = Canvas(w, h)
    profiles = [
        dict(top=6, hunch=2, bw=9, head_r=7, hood=False, suit=(52, 64, 62), skin=(108, 96, 86)),
        dict(top=10, hunch=3, bw=10, head_r=7, hood=False, suit=(68, 56, 48), skin=(98, 86, 78)),
        dict(top=4, hunch=1, bw=10, head_r=7, hood=False, suit=(48, 58, 70), skin=(112, 102, 92)),
        dict(top=8, hunch=3, bw=10, head_r=7, hood=True, suit=(56, 60, 68), skin=(104, 94, 86)),
        dict(top=7, hunch=2, bw=9, head_r=7, hood=False, suit=(64, 68, 56), skin=(108, 96, 84)),
        dict(top=9, hunch=3, bw=10, head_r=7, hood=False, suit=(72, 58, 50), skin=(96, 84, 74)),
        dict(top=5, hunch=2, bw=10, head_r=7, hood=True, suit=(50, 62, 66), skin=(106, 96, 88)),
    ]
    pr = profiles[idx % len(profiles)]
    suit = pr["suit"]
    skin = pr["skin"]
    rim = (132, 152, 174)
    cx = 16
    top = pr["top"]
    hunch = pr["hunch"]
    bw = pr["bw"]
    hr = pr["head_r"]

    # Boots & prison trousers (side-profile legs with knee bend & rim highlight)
    for lx, sh_f in ((cx - 5, 0.66), (cx + 1, 0.88)):
        for y in range(56, 82):
            knee = 1 if 66 <= y <= 72 else 0
            for dx in range(5):
                col = shade(suit, sh_f * (1.12 if dx >= 3 else 0.82))
                if dx == 4 and lx > cx:
                    col = mix(col, rim, 0.45)
                c.put(lx + dx + knee, y, col)
        c.rect(lx - 1, 81, lx + 6, 85, (28, 30, 36))
        c.rect(lx, 81, lx + 5, 82, (64, 68, 76))

    # Torso / prison jacket tapering slightly with collar & waist belt
    for y in range(top + 15, 58):
        t = (y - (top + 15)) / 43.0
        shift = int(hunch * (1.0 - t * 0.6))
        left = cx - bw + shift // 2
        right = cx + bw + shift
        for x in range(left, right + 1):
            xf = (x - left) / max(1.0, right - left)
            col = shade(suit, 0.58 + 0.52 * xf)
            if x == right:
                col = mix(col, rim, 0.65)
            elif x == left:
                col = shade(suit, 0.45)
            if 53 <= y <= 55:
                col = (34, 32, 36)  # belt
            c.put(x, y, col)

    # Folded arm & orange/yellow prison armband stripe
    for y in range(top + 21, 49):
        arm_l = cx - 1
        arm_r = cx + bw - 1
        for x in range(arm_l, arm_r + 1):
            col = shade(suit, 1.08 if x > arm_l + 1 else 0.72)
            if top + 24 <= y <= top + 27:
                col = (186, 134, 52) if x > arm_l + 1 else (132, 92, 36)
            if x == arm_r:
                col = mix(col, rim, 0.50)
            c.put(x, y, col)

    # Neck & Sculpted Side-Profile Head facing right
    hx = cx + hunch + 1
    hy = top + hr + 1
    c.rect(hx - 3, hy + hr - 2, hx + 2, hy + hr + 3, shade(skin, 0.72))
    for y in range(hy - hr, hy + hr + 1):
        for x in range(hx - hr, hx + hr + 2):
            dx = (x - hx) / float(hr)
            dy = (y - hy) / float(hr)
            if dx * dx + dy * dy <= 1.0:
                sh = 0.68 + 0.38 * max(0.0, dx) - 0.15 * dy
                col = shade(skin, sh)
                if y < hy - 2 and not pr["hood"]:
                    col = (38, 34, 32) if dx < 0.3 else (58, 52, 48)
                c.put(x, y, col)
    # Nose & brow ridge facing right
    c.rect(hx + hr, hy - 2, hx + hr + 1, hy + 1, shade(skin, 1.05))
    c.put(hx + hr + 1, hy, rim)
    c.put(hx + hr, hy - 3, rim)

    if pr["hood"]:
        for y in range(hy - hr - 2, hy + hr + 3):
            for x in range(hx - hr - 2, hx + hr + 2):
                if (x - hx) ** 2 + (y - hy) ** 2 <= (hr + 2) ** 2 and x < hx + hr - 1:
                    sh = 0.95 if x > hx else 0.62
                    c.put(x, y, shade(suit, sh))
    # Glinting eye slit facing right
    c.put(hx + hr - 2, hy - 1, (215, 225, 235))
    c.outline((12, 14, 18, 255))
    return c.im


def gen_queue():
    for i in range(7):
        make_queue(i).save(os.path.join(OUT, "kuyruk_%d.png" % (i + 1)))
    print("queue ok")


# ==================================================================================
# 3. SECURITY GUARD ("SGT. DOBBS") - 72x150, Anatomically Sculpted Officer (No Boxy Rects)
# ==================================================================================
GW, GH = 72, 150


def _draw_capsule(c, x0, y0, x1, y1, r0, r1, base_col, light_dir=(-0.55, -0.35)):
    """Draws a smooth, anatomically tapered limb segment with 3D cylindrical shading."""
    steps = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
    lx_d, ly_d = light_dir
    for i in range(steps + 1):
        t = i / float(max(1, steps))
        cx = x0 + (x1 - x0) * t
        cy = y0 + (y1 - y0) * t
        r = r0 + (r1 - r0) * t
        ir = int(math.ceil(r)) + 1
        for dy in range(-ir, ir + 1):
            for dx in range(-ir, ir + 1):
                d2 = (dx * dx + dy * dy) / max(0.5, r * r)
                if d2 <= 1.0:
                    nx = dx / max(1.0, r)
                    ny = dy / max(1.0, r)
                    nz = math.sqrt(max(0.05, 1.0 - min(0.95, nx * nx + ny * ny)))
                    sh = 0.62 + 0.46 * max(0.0, nx * lx_d + ny * ly_d + nz * 0.72)
                    if nx < -0.55:
                        sh += 0.14  # subtle rim highlight
                    c.put(cx + dx, cy + dy, shade(base_col, sh))


def make_guard(frame=0, paper=False, baton=True, variant=0, arm_up=False):
    c = Canvas(GW, GH)
    cx = 37
    cloth = [(40, 48, 60), (48, 46, 38), (36, 48, 46)][variant % 3]
    coat_skirt = shade(cloth, 0.88)
    trouser_col = shade(cloth, 0.76)
    leather = (24, 18, 18)
    skin = (162, 132, 108)

    # 4-frame natural walk cycle (hips, knees, ankles, arm swing)
    stride = [0, 7, 0, -7][frame % 4]
    knee_bend_l = 3 if frame % 4 == 1 else (1 if frame % 4 == 2 else 0)
    knee_bend_r = 3 if frame % 4 == 3 else (1 if frame % 4 == 0 else 0)
    lift_l = 3 if frame % 4 == 1 else 0
    lift_r = 3 if frame % 4 == 3 else 0

    # ---- 1. Back Arm (Right arm in 3/4 view, behind torso)
    back_swing = -stride * 0.65
    sh_rx, sh_ry = cx + 11, 47
    el_rx, el_ry = cx + 14 + back_swing * 0.45, 65
    wr_rx, wr_ry = cx + 12 + back_swing, 82
    _draw_capsule(c, sh_rx, sh_ry, el_rx, el_ry, 4.2, 3.6, shade(cloth, 0.72))
    _draw_capsule(c, el_rx, el_ry, wr_rx, wr_ry, 3.5, 2.8, shade(cloth, 0.68))
    _draw_capsule(c, wr_rx, wr_ry, wr_rx - 1, wr_ry + 4, 2.6, 2.2, shade(skin, 0.72))

    # ---- 2. Articulated Legs (Thigh -> Knee -> Calf) & Sculpted Combat Boots
    for side, s_off, k_bend, lift in (
        (1, -stride, knee_bend_r, lift_r),   # back/right leg drawn first
        (-1, stride, knee_bend_l, lift_l),   # front/left leg drawn second
    ):
        hip_x = cx + side * 5
        hip_y = 94
        knee_x = hip_x + s_off * 0.45 - k_bend * 0.8
        knee_y = 115 - lift * 0.5
        ank_x = hip_x + s_off * 0.85
        ank_y = 135 - lift

        leg_col = shade(trouser_col, 0.98 if side < 0 else 0.76)
        # Thigh (tapered officer breeches)
        _draw_capsule(c, hip_x, hip_y, knee_x, knee_y, 5.2, 4.0, leg_col)
        # Calf
        _draw_capsule(c, knee_x, knee_y, ank_x, ank_y, 3.9, 3.1, leg_col)

        # Sculpted leather combat boot (curved shaft, instep, rounded toe cap, heel)
        bx, by = int(round(ank_x)), int(round(ank_y))
        boot_col = leather if side < 0 else shade(leather, 0.78)
        _draw_capsule(c, bx, by - 5, bx, by + 3, 3.4, 3.6, boot_col)
        # Curved toe cap facing left (cx is facing slightly left)
        _draw_capsule(c, bx + 2, by + 4, bx - 6, by + 5, 3.2, 2.5, boot_col)
        # Boot sole & heel tread
        for sx_b in range(bx - 8, bx + 5):
            c.put(sx_b, by + 7, (12, 11, 14))
            if sx_b < bx - 2:
                c.put(sx_b, by + 4, (58, 52, 54))  # toe specular highlight

    # ---- 3. Sculpted Officer Greatcoat (Sloped Shoulders -> Chest V-Taper -> Cinched Waist -> Flared Skirt)
    for y in range(40, 104):
        if y < 48:
            # Smooth sloped deltoid/shoulder curve from neck (w=6) to shoulder peak (w=15.5)
            st = (y - 40) / 8.0
            half_l = 6.0 + 9.8 * (st ** 0.75)
            half_r = 6.0 + 9.2 * (st ** 0.75)
            center_x = cx
        elif y < 78:
            # Anatomical chest-to-waist V-taper
            ct = (y - 48) / 30.0
            rib_curve = math.sin(ct * math.pi) * 1.2
            half_l = 15.8 - 4.2 * ct + rib_curve
            half_r = 15.2 - 4.0 * ct + rib_curve * 0.8
            center_x = cx - 0.5 * math.sin(ct * math.pi)
        else:
            # Flared officer greatcoat skirt below belt (y = 78..103)
            kt = (y - 78) / 25.0
            sway = stride * 0.28 * kt
            half_l = 11.6 + 4.6 * (kt ** 0.85)
            half_r = 11.2 + 4.2 * (kt ** 0.85)
            center_x = cx + sway

        x_start = int(round(center_x - half_l))
        x_end = int(round(center_x + half_r))
        span = max(1.0, float(x_end - x_start))
        for x in range(x_start, x_end + 1):
            nx = (x - center_x) / (span * 0.5)
            nz = math.sqrt(max(0.08, 1.0 - min(0.92, nx * nx * 0.82)))
            sh = 0.56 + 0.48 * max(0.0, -0.45 * nx + 0.78 * nz)

            # Vertical drapery folds on coat skirt
            if y >= 81:
                fold = math.sin((x - center_x) * 0.55) * 0.08
                sh += fold
                # Center coat vent shadow
                if abs(x - (center_x - 1)) <= 1 and y > 88:
                    sh *= 0.62

            base = cloth if y < 80 else coat_skirt
            col = shade(base, sh)

            # Open collar lapels & dark shirt/red tie V-neck (y = 41..55)
            if 41 <= y <= 55:
                v_w = max(0.0, 4.8 - (y - 41) * 0.34)
                dx_v = x - (cx - 1)
                if abs(dx_v) < v_w:
                    col = (148, 32, 32) if abs(dx_v) <= 1.0 else (30, 34, 42)
                elif abs(abs(dx_v) - (v_w + 1.8)) < 1.3:
                    col = shade(cloth, 1.18 if dx_v < 0 else 0.62)  # sculpted lapel ridge

            # Rim highlight on left chest edge
            if x == x_start and 46 <= y <= 98:
                col = shade(base, 1.24)
            c.put(x, y, col)

    # Angled Crimson Epaulettes following the natural shoulder slope
    c.line(cx - 6, 41, cx - 14, 46, (158, 34, 34), 2)
    c.line(cx + 6, 41, cx + 13, 46, (128, 28, 28), 2)
    c.put(cx - 10, 43, (218, 190, 88))
    c.put(cx + 9, 43, (192, 168, 76))

    # Sam Browne Leather Cross-Strap, Cinched Waist Belt, Holster & Brass Buckle
    c.line(cx - 11, 44, cx + 8, 78, leather, 2)
    for y in range(77, 81):
        for x in range(cx - 12, cx + 12):
            if c.get(x, y)[3]:
                c.put(x, y, leather if y > 77 else (48, 38, 36))
    # Brass buckle slightly left of center (3/4 view)
    c.rect(cx - 4, 76, cx + 1, 81, (206, 176, 82))
    c.rect(cx - 3, 78, cx, 79, (46, 38, 18))
    # Sculpted curved pistol holster on right hip
    _draw_capsule(c, cx + 7, 80, cx + 9, 91, 3.2, 2.2, (36, 26, 26))

    # Double-breasted brass buttons & chest badge following torso curve
    for yy in (54, 61, 68, 74):
        c.put(cx - 6, yy, (212, 186, 90))
        c.put(cx + 2, yy, (186, 162, 76))
    # Shield-shaped officer badge on chest
    for dy in range(5):
        bw = 2 if dy < 3 else (1 if dy == 3 else 0)
        for dx in range(-bw, bw + 1):
            c.put(cx + 6 + dx, 50 + dy, (224, 196, 94) if dx <= 0 else (168, 142, 62))

    # ---- 4. Sculpted Neck & Organic Head (y = 14..41)
    hx, hy = cx - 1, 27
    # Muscular neck with jaw cast shadow
    for y in range(35, 43):
        for x in range(hx - 4, hx + 6):
            sh = 0.68 - 0.14 * max(0.0, (40 - y) / 5.0) + 0.10 * ((hx - x) / 5.0)
            c.put(x, y, shade(skin, sh))

    # Organic Cranium -> Cheekbone -> Tapered Jaw -> Chin silhouette
    for y in range(15, 39):
        if y <= 25:
            t = (25 - y) / 10.0
            hw = 10.2 * math.sqrt(max(0.05, 1.0 - 0.78 * (t ** 2)))
        elif y <= 32:
            t = (y - 25) / 7.0
            hw = 10.2 * (1.0 - t) + 8.4 * t
        else:
            t = (y - 32) / 6.0
            hw = 8.4 * (1.0 - (t ** 1.35)) + 3.2 * (t ** 1.35)
        ihw = int(round(hw))
        for x in range(hx - ihw, hx + ihw + 1):
            nx = (x - hx) / 10.5
            ny = (y - 26) / 12.0
            nz = math.sqrt(max(0.05, 1.0 - min(0.95, nx * nx * 0.85 + ny * ny * 0.75)))
            sh = 0.58 + 0.46 * max(0.0, -0.38 * nx - 0.25 * ny + 0.82 * nz)
            # Cap visor shadow across upper forehead
            if y <= 21:
                sh *= 0.66
            # Eye socket hollows
            for ex_c in (hx - 4, hx + 3):
                if abs(x - ex_c) <= 2 and 24 <= y <= 26:
                    sh *= 0.78
            # Cheekbone highlight
            if 27 <= y <= 29 and abs(x - (hx - 5)) <= 2:
                sh += 0.10
            c.put(x, y, shade(skin, max(0.42, sh)))

    # Sculpted Ear on right side of head
    for y in range(25, 31):
        c.put(hx + 9, y, shade(skin, 0.76))
        c.put(hx + 10, y, shade(skin, 0.62))

    # Stern Eyes & Furrowed Brows
    ey = 25
    for ex_off in (-5, 2):
        c.put(hx + ex_off, ey, (226, 220, 206))
        c.put(hx + ex_off + 2, ey, (214, 208, 194))
        c.put(hx + ex_off + 1, ey, (20, 18, 22))
        for bx_i in range(4):
            c.put(hx + ex_off - 1 + bx_i, ey - 2, (38, 30, 26))

    # Sculpted Nose & Curved Officer Mustache
    c.line(hx - 1, 25, hx - 2, 29, shade(skin, 1.12), 1)
    c.put(hx - 1, 29, shade(skin, 0.72))
    for dx in range(-5, 5):
        drop = 1 if abs(dx) >= 3 else 0
        c.put(hx + dx, 31 + drop, (42, 32, 26))
        c.put(hx + dx, 32 + drop, (32, 24, 20))
    if arm_up:
        c.rect(hx - 2, 34, hx + 1, 35, (28, 16, 16))
    else:
        c.line(hx - 2, 34, hx + 1, 34, shade(skin, 0.52), 1)

    # ---- 5. Curved Saddle-Crown Peaked Officer Cap (No Boxy Rectangles!)
    for y in range(7, 21):
        for x in range(hx - 14, hx + 15):
            dx = (x - hx) / 14.0
            # Arched saddle crown top & flared side walls tapering inward to cap band
            top_curve = 8.0 + 2.8 * (dx * dx) - 0.8 * math.cos(dx * math.pi)
            if y < top_curve:
                continue
            if y <= 15:
                max_w = 13.8 - (15 - y) * 0.35
            else:
                max_w = 10.8  # fitted crimson cap band
            if abs(x - hx) <= max_w:
                sh = 1.08 - 0.32 * dx - 0.08 * ((y - 8) / 12.0)
                if y <= int(top_curve) + 1:
                    col = shade((78, 92, 108), sh)  # crown piping highlight
                elif y >= 16:
                    col = shade((156, 34, 34), sh)   # crimson officer band
                else:
                    col = shade((44, 54, 66), sh)    # dark slate crown
                c.put(x, y, col)

    # Curved glossy black visor projecting slightly left
    for x in range(hx - 13, hx + 10):
        dx = (x - (hx - 2)) / 11.5
        vy0 = 18 + int(1.6 * dx * dx)
        vy1 = vy0 + 2
        for y in range(vy0, vy1 + 1):
            col = (46, 50, 58) if (y == vy0 and dx < 0) else (16, 16, 22)
            c.put(x, y, col)

    # Gold Cockade Emblem on cap crown
    for dy in range(-2, 3):
        for dx in range(-2, 3):
            if abs(dx) + abs(dy) <= 3:
                c.put(hx - 1 + dx, 13 + dy, (224, 196, 88) if abs(dx) + abs(dy) > 1 else (168, 36, 34))

    # ---- 6. Articulated Front Arm (Shoulder -> Elbow -> Forearm -> Hand & Prop)
    sh_lx, sh_ly = cx - 12, 47
    if paper:
        # Elbow bent holding an angled folded newspaper in front
        el_lx, el_ly = cx - 18, 63
        wr_lx, wr_ly = cx - 12, 70
        _draw_capsule(c, sh_lx, sh_ly, el_lx, el_ly, 4.3, 3.7, shade(cloth, 1.04))

        # Angled folded newspaper with natural perspective & ragged page layers
        for py in range(-11, 12):
            for px_i in range(-10, 11):
                rx_p = int(round(( cx - 22 ) + px_i * 0.92 - py * 0.22))
                ry_p = int(round(63 + py * 0.95 + px_i * 0.18))
                col = (224, 214, 188) if px_i < 8 else (188, 178, 154)
                if abs(py) >= 10 or abs(px_i) >= 9:
                    col = (142, 132, 112)
                elif -8 <= py <= -6 and -7 <= px_i <= 6:
                    col = (34, 30, 28)  # masthead
                elif py == -4 and -7 <= px_i <= 6:
                    col = (158, 38, 34) # red sub-rule
                elif py > -2 and py % 3 == 0 and -7 <= px_i <= 5:
                    col = (84, 78, 70)  # newsprint columns
                c.put(rx_p, ry_p, col)

        _draw_capsule(c, el_lx, el_ly, wr_lx, wr_ly, 3.7, 3.0, shade(cloth, 1.08))
        _draw_capsule(c, wr_lx - 2, wr_ly, wr_lx - 6, wr_ly + 2, 2.8, 2.4, shade(skin, 0.98))
    elif arm_up:
        # Expressive gesturing arm bent at elbow, pointing/talking
        el_lx, el_ly = cx - 19, 60
        wr_lx, wr_ly = cx - 26, 46
        _draw_capsule(c, sh_lx, sh_ly, el_lx, el_ly, 4.3, 3.6, shade(cloth, 1.04))
        _draw_capsule(c, el_lx, el_ly, wr_lx, wr_ly, 3.6, 2.9, shade(cloth, 1.08))
        _draw_capsule(c, wr_lx, wr_ly, wr_lx - 3, wr_ly - 3, 2.7, 2.0, shade(skin, 1.02))
        c.line(wr_lx - 3, wr_ly - 3, wr_lx - 6, wr_ly - 5, shade(skin, 1.06), 2)
    else:
        # Natural walking/idle arm swing with slight anatomical elbow bend
        front_swing = stride * 0.65
        el_lx = cx - 16 + front_swing * 0.45
        el_ly = 65
        wr_lx = cx - 14 + front_swing
        wr_ly = 82
        _draw_capsule(c, sh_lx, sh_ly, el_lx, el_ly, 4.3, 3.7, shade(cloth, 1.02))
        _draw_capsule(c, el_lx, el_ly, wr_lx, wr_ly, 3.6, 2.9, shade(cloth, 1.05))
        _draw_capsule(c, wr_lx, wr_ly, wr_lx - 1, wr_ly + 4, 2.8, 2.3, shade(skin, 0.98))
        if baton:
            bx0, by0 = int(round(wr_lx - 1)), int(round(wr_ly + 3))
            _draw_capsule(c, bx0 + 2, by0 - 2, bx0 - 7, by0 + 24, 1.8, 1.6, (24, 22, 28))
            c.line(bx0 + 1, by0, bx0 - 6, by0 + 22, (78, 76, 86), 1)

    # ---- 7. Crisp Pixel Outline & Soft Ground Shadow
    c.outline()
    for y in range(143, 149):
        for x in range(14, 58):
            d2 = ((x - 36) / 22.0) ** 2 + ((y - 146) / 3.0) ** 2
            if d2 <= 1.0 and c.get(x, y)[3] == 0:
                c.put(x, y, (6, 8, 12, int(115 * (1.0 - d2 * 0.6))))
    return c.im


def gen_guards():
    for v in range(3):
        for f in range(4):
            make_guard(f, paper=False, variant=v).save(os.path.join(OUT, "g%d_walk%d.png" % (v, f)))
            make_guard(f, paper=True, variant=v).save(os.path.join(OUT, "g%d_paper%d.png" % (v, f)))
        make_guard(0, paper=False, variant=v, baton=True).save(os.path.join(OUT, "g%d_idle.png" % v))
        make_guard(0, paper=False, variant=v, baton=False, arm_up=True).save(os.path.join(OUT, "g%d_point.png" % v))
    Image.open(os.path.join(OUT, "g0_idle.png")).save(os.path.join(OUT, "gardiyan_bos.png"))
    Image.open(os.path.join(OUT, "g0_paper0.png")).save(os.path.join(OUT, "gardiyan_gazeteli.png"))
    Image.open(os.path.join(OUT, "g0_idle.png")).save(os.path.join(OUT, "gardiyan_nobet.png"))
    print("guards ok")


# ==================================================================================
# 4. DARK GUNMETAL CUPBOARD CABINETS (86x294) & DARK DYSTOPIAN SHELF ITEMS (56x72)
# ==================================================================================
def make_cabinet(kind):
    """Generates an 86x294 dark gunmetal 1984 prison ration cabinet with heavy rivets & deep shadows."""
    w, h = 86, 294
    c = Canvas(w, h)
    themes = {
        "ilac": dict(badge=(128, 34, 30), trim=(74, 80, 88)),
        "yiyecek": dict(badge=(132, 92, 32), trim=(80, 74, 68)),
        "icecek": dict(badge=(34, 88, 124), trim=(70, 80, 90)),
    }
    th = themes[kind]
    frame_outer = (24, 28, 34)
    frame_bevel = (48, 54, 62)
    back_dark = (14, 18, 22)

    # Outer dark gunmetal steel cabinet frame (8px side/top border)
    c.rect(0, 0, w - 1, h - 1, frame_outer)
    c.rect(1, 1, w - 2, h - 2, (36, 40, 48))
    c.rect(2, 2, w - 3, h - 3, frame_outer)

    # Deep dark interior recess (x = 8..77, y = 12..285)
    for y in range(12, 286):
        for x in range(8, w - 8):
            # Subtle vertical steel plate seam & dark vignette inside recess
            edge_d = min(x - 8, (w - 9) - x)
            sh = 0.82 if edge_d < 4 else (0.92 if edge_d < 9 else 1.0)
            if x in (28, 57):
                sh *= 0.88
            c.put(x, y, shade(back_dark, sh))

    # Inner recessed frame bevel around the interior
    c.rect(7, 11, w - 8, 11, (10, 12, 16))
    c.rect(7, 286, w - 8, 286, frame_bevel)
    c.rect(7, 11, 7, 286, (10, 12, 16))
    c.rect(w - 8, 11, w - 8, 286, frame_bevel)

    # Muted dark category indicator bar & stencil emblem at top header (y = 3..9)
    c.rect(12, 3, w - 13, 9, (18, 20, 24))
    c.rect(14, 4, w - 15, 8, shade(th["badge"], 0.65))
    c.rect(14, 4, w - 15, 5, shade(th["badge"], 0.90))
    bx = w // 2
    if kind == "ilac":
        c.rect(bx - 4, 4, bx + 4, 8, (168, 160, 148))
        c.rect(bx - 1, 4, bx + 1, 8, (142, 32, 28))
        c.rect(bx - 3, 5, bx + 3, 7, (142, 32, 28))
    elif kind == "yiyecek":
        c.rect(bx - 4, 4, bx + 4, 8, (158, 126, 64))
        c.rect(bx - 2, 5, bx + 2, 7, (92, 58, 22))
    else:
        c.rect(bx - 4, 4, bx + 4, 8, (138, 158, 172))
        c.rect(bx - 2, 5, bx + 2, 7, (32, 82, 114))

    # Heavy steel shelf dividers matching dolap_preview.png (y=107..113 and y=197..203, plus bottom y=282..286)
    for sy in (107, 197):
        c.rect(6, sy, w - 7, sy + 1, (58, 64, 72))        # top highlight edge
        c.rect(6, sy + 2, w - 7, sy + 4, (36, 40, 48))    # steel face
        c.rect(8, sy + 5, w - 9, sy + 7, (9, 11, 14))     # deep cast shadow under shelf
        for rx in (12, 42, 73):
            c.put(rx, sy + 2, (76, 82, 92))
            c.put(rx, sy + 3, (20, 22, 26))

    # Rivets along outer vertical steel posts
    for ry in (6, 56, 108, 154, 198, 244, 288):
        for rx in (3, w - 4):
            c.put(rx, ry, (58, 64, 72))
            c.put(rx, ry + 1, (14, 16, 20))

    return c.im


def make_item_amber_bottle():
    """56x72 Dark Gritty Amber Glass Painkiller Bottle (matches new_inventory_preview.png)."""
    img = Image.new("RGBA", (56, 72), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shadow
    d.ellipse([12, 60, 44, 68], fill=(0, 0, 0, 125))
    # Bottle body (dark amber glass)
    d.rounded_rectangle([14, 24, 42, 64], radius=5, fill=(92, 42, 14, 255), outline=(22, 14, 10, 255), width=2)
    # Inner shading
    d.rounded_rectangle([17, 27, 39, 61], radius=3, fill=(118, 56, 18, 255))
    d.rectangle([32, 27, 39, 61], fill=(68, 30, 10, 255))
    # Glass highlight
    d.line([(18, 29), (18, 58)], fill=(175, 105, 45, 200), width=2)
    # Neck
    d.rectangle([21, 16, 35, 25], fill=(82, 38, 12, 255), outline=(22, 14, 10, 255), width=2)
    # Ribbed Bakelite Cap
    d.rounded_rectangle([19, 8, 37, 17], radius=2, fill=(155, 148, 132, 255), outline=(22, 14, 10, 255), width=2)
    for x in range(22, 36, 3):
        d.line([(x, 10), (x, 15)], fill=(108, 102, 90, 255), width=1)
    # Worn vintage pharmacy label
    d.rectangle([16, 34, 40, 54], fill=(186, 174, 146, 255), outline=(42, 36, 28, 255), width=1)
    # Red cross on label
    d.rectangle([26, 38, 30, 48], fill=(148, 34, 28, 255))
    d.rectangle([23, 41, 33, 45], fill=(148, 34, 28, 255))
    return img


def make_item_green_dropper():
    """56x72 Dark Desaturated Green Sedative Syrup Bottle."""
    img = Image.new("RGBA", (56, 72), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([13, 60, 43, 68], fill=(0, 0, 0, 125))
    # Tall green glass body
    d.rounded_rectangle([15, 22, 41, 64], radius=6, fill=(28, 68, 42, 255), outline=(14, 22, 16, 255), width=2)
    d.rounded_rectangle([18, 25, 38, 61], radius=4, fill=(38, 88, 54, 255))
    d.rectangle([31, 25, 38, 61], fill=(20, 50, 30, 255))
    # Highlight
    d.line([(19, 27), (19, 58)], fill=(86, 145, 102, 190), width=2)
    # Neck
    d.rectangle([22, 13, 34, 23], fill=(28, 68, 42, 255), outline=(14, 22, 16, 255), width=2)
    # Dark Metal Cap
    d.rectangle([20, 7, 36, 14], fill=(64, 68, 72, 255), outline=(14, 22, 16, 255), width=2)
    # Diamond/Hexagon label
    d.polygon([(28, 31), (39, 42), (28, 53), (17, 42)], fill=(182, 174, 150, 255), outline=(38, 34, 28, 255))
    d.line([(23, 42), (33, 42)], fill=(28, 68, 42, 255), width=2)
    d.line([(25, 46), (31, 46)], fill=(45, 45, 45, 255), width=1)
    return img


def make_item_blue_capsules():
    """56x72 Dark Slate & Cobalt Medicine Box + Blister Strip."""
    img = Image.new("RGBA", (56, 72), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([10, 60, 46, 68], fill=(0, 0, 0, 125))
    # Cardboard box (3D angled look)
    d.rectangle([12, 16, 40, 62], fill=(168, 164, 152, 255), outline=(22, 24, 28, 255), width=2)
    # Side panel for 3D depth
    d.polygon([(40, 16), (46, 12), (46, 58), (40, 62)], fill=(118, 114, 104, 255), outline=(22, 24, 28, 255))
    d.polygon([(12, 16), (18, 12), (46, 12), (40, 16)], fill=(192, 188, 176, 255), outline=(22, 24, 28, 255))
    # Clinical blue stripe
    d.rectangle([14, 24, 38, 34], fill=(36, 76, 118, 255))
    # Pill graphic on box
    d.rounded_rectangle([18, 42, 34, 50], radius=4, fill=(148, 42, 38, 255), outline=(35, 35, 35, 255), width=1)
    d.rectangle([26, 43, 33, 49], fill=(195, 190, 178, 255))
    # Text lines
    d.line([(16, 20), (32, 20)], fill=(48, 48, 48, 255), width=2)
    d.line([(16, 55), (35, 55)], fill=(78, 78, 78, 255), width=2)
    return img


def make_item_bandage():
    """56x72 Aged Sterile Gauze Bandage Roll with Dark Red Cross Band."""
    img = Image.new("RGBA", (56, 72), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([10, 60, 46, 68], fill=(0, 0, 0, 125))
    # Main cylinder body
    d.rectangle([13, 22, 43, 60], fill=(184, 176, 158, 255), outline=(28, 26, 22, 255), width=2)
    # Shading on right side
    d.rectangle([34, 24, 41, 58], fill=(148, 140, 124, 255))
    # Gauze texture lines
    for y in range(28, 58, 5):
        d.line([(15, y), (41, y)], fill=(164, 156, 138, 255), width=1)
    # Paper wrapper around middle
    d.rectangle([12, 33, 44, 49], fill=(154, 136, 108, 255), outline=(28, 26, 22, 255), width=2)
    # Red cross on wrapper
    d.rectangle([26, 36, 30, 46], fill=(142, 32, 28, 255))
    d.rectangle([23, 39, 33, 43], fill=(142, 32, 28, 255))
    # Top oval (roll spiral)
    d.ellipse([13, 16, 43, 28], fill=(198, 190, 174, 255), outline=(28, 26, 22, 255), width=2)
    d.ellipse([18, 18, 38, 26], fill=(172, 164, 148, 255), outline=(112, 104, 92, 255), width=1)
    d.ellipse([24, 20, 32, 24], fill=(54, 48, 42, 255))
    return img


def make_item_canned_food():
    """56x72 Tarnished Steel Ration Can with Muted Olive/Ochre Label (matches new_food_preview.png)."""
    img = Image.new("RGBA", (56, 72), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([10, 59, 46, 68], fill=(0, 0, 0, 135))
    # Cylinder body (dark tarnished tin)
    d.rectangle([13, 20, 43, 60], fill=(96, 100, 104, 255), outline=(22, 24, 26, 255), width=2)
    # Right side shadow
    d.rectangle([34, 22, 41, 58], fill=(68, 72, 76, 255))
    # Left highlight
    d.rectangle([16, 22, 20, 58], fill=(134, 138, 144, 255))
    # Ribbed metal ridges
    for y in [25, 55]:
        d.line([(14, y), (42, y)], fill=(54, 58, 62, 255), width=1)
    # Paper label around middle (muted olive green / dirty ochre)
    d.rectangle([13, 29, 43, 51], fill=(78, 88, 58, 255), outline=(22, 24, 26, 255), width=2)
    d.rectangle([34, 31, 41, 49], fill=(56, 64, 42, 255))
    # Label emblem (rust red star / ration mark)
    d.ellipse([22, 34, 34, 46], fill=(168, 156, 128, 255), outline=(38, 34, 28, 255), width=1)
    d.rectangle([26, 37, 30, 43], fill=(138, 42, 34, 255))
    d.rectangle([25, 39, 31, 41], fill=(138, 42, 34, 255))
    # Bottom rim
    d.ellipse([12, 55, 44, 63], fill=(82, 86, 90, 255), outline=(22, 24, 26, 255), width=2)
    # Top lid ellipse
    d.ellipse([12, 14, 44, 26], fill=(124, 128, 134, 255), outline=(22, 24, 26, 255), width=2)
    d.ellipse([15, 16, 41, 24], fill=(98, 102, 108, 255), outline=(58, 62, 66, 255), width=1)
    # Pull tab
    d.ellipse([24, 18, 32, 22], fill=(148, 152, 158, 255), outline=(42, 44, 48, 255), width=1)
    return img


def make_item_chips():
    """56x72 Crinkled Rust-Red & Kraft Ration Crisps Packet (matches new_food_preview.png)."""
    img = Image.new("RGBA", (56, 72), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([10, 60, 46, 68], fill=(0, 0, 0, 135))
    # Bag body (slightly pinched waist polygon, muted rust red / brown)
    bag_poly = [(12, 14), (44, 14), (41, 38), (43, 61), (13, 61), (15, 38)]
    d.polygon(bag_poly, fill=(136, 48, 36, 255), outline=(22, 18, 16, 255))
    d.line(bag_poly + [bag_poly[0]], fill=(22, 18, 16, 255), width=2)
    # Right side shadow fold
    shade_poly = [(34, 16), (42, 16), (39, 38), (41, 59), (34, 59)]
    d.polygon(shade_poly, fill=(96, 32, 24, 255))
    # Left crinkle highlight
    d.line([(17, 18), (19, 38), (17, 57)], fill=(176, 78, 58, 255), width=2)
    # Center banner (aged yellow/beige)
    d.rectangle([15, 29, 41, 47], fill=(182, 156, 98, 255), outline=(28, 22, 18, 255), width=1)
    # Crisp chip graphic inside banner
    d.ellipse([21, 33, 35, 43], fill=(196, 138, 54, 255), outline=(82, 52, 20, 255), width=1)
    # Top and bottom crimped seals (kraft gold/brown)
    d.rectangle([11, 11, 45, 16], fill=(156, 128, 76, 255), outline=(22, 18, 16, 255), width=2)
    d.rectangle([12, 59, 44, 64], fill=(156, 128, 76, 255), outline=(22, 18, 16, 255), width=2)
    for x in range(15, 43, 4):
        d.line([(x, 12), (x, 15)], fill=(86, 68, 38, 255), width=1)
        d.line([(x, 60), (x, 63)], fill=(86, 68, 38, 255), width=1)
    return img


def make_item_cola():
    """56x72 Dark Espresso Glass Cola Bottle with Crimson Band (matches new_food_preview.png)."""
    img = Image.new("RGBA", (56, 72), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([13, 60, 43, 68], fill=(0, 0, 0, 135))
    # Classic contoured dark glass bottle
    bottle_poly = [
        (23, 10), (33, 10),
        (34, 22), (40, 32),
        (38, 46), (40, 62),
        (16, 62), (18, 46),
        (16, 32), (22, 22)
    ]
    d.polygon(bottle_poly, fill=(36, 20, 16, 255))
    d.line(bottle_poly + [bottle_poly[0]], fill=(16, 10, 8, 255), width=2)
    # Upper glass neck (slightly lighter amber/brown)
    neck_poly = [(23, 12), (33, 12), (34, 22), (22, 22)]
    d.polygon(neck_poly, fill=(68, 44, 34, 255))
    # Right side dark shadow
    d.rectangle([32, 32, 38, 60], fill=(22, 12, 10, 255))
    # Specular glass highlight on left
    d.line([(20, 32), (21, 45), (19, 58)], fill=(112, 78, 64, 210), width=2)
    # Red & Cream vintage soda band
    d.rectangle([17, 34, 39, 46], fill=(148, 34, 28, 255), outline=(18, 12, 10, 255), width=2)
    d.line([(19, 40), (37, 38)], fill=(196, 186, 164, 255), width=2)
    # Crown bottle cap
    d.rounded_rectangle([22, 7, 34, 12], radius=2, fill=(148, 38, 32, 255), outline=(18, 12, 10, 255), width=2)
    return img


def make_item_juice():
    """56x72 Muted Ochre & Olive Ration Juice Carton with Straw (matches new_food_preview.png)."""
    img = Image.new("RGBA", (56, 72), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([11, 60, 45, 68], fill=(0, 0, 0, 135))
    # Bent drinking straw sticking out top
    d.line([(32, 18), (35, 8), (42, 10)], fill=(186, 178, 156, 255), width=3)
    d.line([(32, 18), (35, 8), (42, 10)], fill=(28, 24, 20, 255), width=1)
    # 3D Carton Box Front
    d.rectangle([14, 18, 38, 62], fill=(176, 114, 42, 255), outline=(24, 20, 16, 255), width=2)
    # 3D Side Panel
    d.polygon([(38, 18), (44, 14), (44, 58), (38, 62)], fill=(124, 78, 28, 255), outline=(24, 20, 16, 255))
    # 3D Top Panel
    d.polygon([(14, 18), (20, 14), (44, 14), (38, 18)], fill=(198, 138, 58, 255), outline=(24, 20, 16, 255))
    # Green top band on carton
    d.rectangle([16, 20, 36, 27], fill=(58, 92, 48, 255))
    # Cream center panel
    d.rectangle([16, 30, 36, 52], fill=(188, 178, 152, 255), outline=(44, 36, 28, 255), width=1)
    # Orange fruit icon inside panel
    d.ellipse([20, 35, 32, 47], fill=(188, 92, 28, 255), outline=(58, 32, 14, 255), width=1)
    d.polygon([(26, 35), (29, 31), (32, 34)], fill=(54, 98, 44, 255))
    return img


def gen_shelf_items():
    # Generate the 3 dark gunmetal cupboard cabinets
    make_cabinet("ilac").save(os.path.join(OUT, "dolap_ilac.png"))
    make_cabinet("yiyecek").save(os.path.join(OUT, "dolap_yiyecek.png"))
    make_cabinet("icecek").save(os.path.join(OUT, "dolap_icecek.png"))

    # Generate all 9 dark dystopian shelf items
    amber = make_item_amber_bottle()
    amber.save(os.path.join(OUT, "esya_ilac.png"))
    amber.save(os.path.join(OUT, "esya_ilac_kehribar.png"))

    make_item_green_dropper().save(os.path.join(OUT, "esya_ilac_yesil.png"))
    make_item_blue_capsules().save(os.path.join(OUT, "esya_ilac_mavi.png"))
    make_item_bandage().save(os.path.join(OUT, "esya_sargi.png"))
    make_item_canned_food().save(os.path.join(OUT, "esya_konserve.png"))
    make_item_chips().save(os.path.join(OUT, "esya_cips.png"))
    make_item_cola().save(os.path.join(OUT, "esya_kola.png"))
    make_item_juice().save(os.path.join(OUT, "esya_meyvesuyu.png"))
    print("cabinets & shelf items ok")


# ==================================================================================
# 5. DARK DYSTOPIAN DESK PROPS (Stamps, Stamp Drawer, Delivery Tray, Dispatch Note, Books)
# ==================================================================================
def restore_dark_stamps():
    """Restores the dark realistic wood & brass stamps (damga_gercek_*.png) with dark mood toning."""
    pairs = [
        ("damga_gercek_onay.png", "yeni_damga_onay.png"),
        ("damga_gercek_onay_basili.png", "yeni_damga_onay_basili.png"),
        ("damga_gercek_red.png", "yeni_damga_red.png"),
        ("damga_gercek_red_basili.png", "yeni_damga_red_basili.png"),
    ]
    for src_name, dst_name in pairs:
        src_p = os.path.join(OUT, src_name)
        dst_p = os.path.join(OUT, dst_name)
        if os.path.exists(src_p):
            im = Image.open(src_p).convert("RGBA")
            r, g, b, a = im.split()
            rgb = Image.merge("RGB", (r, g, b))
            rgb = ImageEnhance.Brightness(rgb).enhance(0.88)
            rgb = ImageEnhance.Contrast(rgb).enhance(1.12)
            nr, ng, nb = rgb.split()
            Image.merge("RGBA", (nr, ng, nb, a)).save(dst_p)


def make_drawer_base():
    """Dark iron & recessed felt stamp drawer base (250x150)."""
    w, h = 250, 150
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    for y in range(h):
        for x in range(w):
            if y < 10:
                px[x, y] = (6, 7, 9, 255)
            else:
                n = ((x * 17 + y * 31) % 5) - 2
                base = 22 + n
                px[x, y] = (base, base + 1, base + 2, 255)
    draw = ImageDraw.Draw(im)
    draw.rectangle([38, 22, 226, 136], outline=(58, 62, 68, 255), width=2)
    # Left stamp recess well (RED / RET)
    for r, col in ((24, (54, 50, 44, 255)), (21, (14, 12, 14, 255)), (18, (64, 20, 20, 255)), (14, (86, 26, 26, 255))):
        draw.ellipse([83 - r, 64 - r, 83 + r, 64 + r], fill=col)
    # Right stamp recess well (ONAY)
    for r, col in ((24, (54, 50, 44, 255)), (21, (12, 14, 14, 255)), (18, (18, 58, 32, 255)), (14, (26, 78, 44, 255))):
        draw.ellipse([190 - r, 64 - r, 190 + r, 64 + r], fill=col)
    return im


def make_delivery_tray():
    """Dark gunmetal & worn hazard-striped delivery tray (teslim_bolmesi.png, 260x74)."""
    w, h = 260, 74
    c = Canvas(w, h)
    c.rect(0, 0, w - 1, h - 1, (16, 18, 22))
    c.rect(2, 2, w - 3, h - 3, (38, 42, 48))
    c.rect(2, 2, w - 3, 4, (64, 70, 78))
    # Worn dark amber & black hazard stripes on left & right rails
    for y in range(6, h - 6):
        stripe = ((y // 5) % 2 == 0)
        col = (146, 112, 32) if stripe else (20, 22, 26)
        c.rect(4, y, 10, y, col)
        c.rect(w - 11, y, w - 5, y, col)

    # Inner recessed tray area
    c.rect(13, 6, w - 14, h - 16, (22, 26, 30))
    c.rect(13, 6, w - 14, 9, (52, 58, 66))

    # 4 Dark Recessed Item/Form Slots
    slot_w = 48
    gap = 8
    start_x = 19
    for i in range(4):
        sx0 = start_x + i * (slot_w + gap)
        sx1 = sx0 + slot_w
        c.rect(sx0 - 1, 10, sx1 + 1, 54, (14, 16, 20))
        c.rect(sx0, 54, sx1, 55, (62, 68, 76))
        for y in range(11, 54):
            ty = (y - 11) / 43.0
            for x in range(sx0, sx1 + 1):
                cx_d = abs(x - (sx0 + sx1) / 2.0) / (slot_w / 2.0)
                glow = max(0.0, (1.0 - ty * 0.7) * (1.0 - 0.5 * cx_d * cx_d))
                col = mix((18, 21, 26), (34, 40, 46), glow)
                if y % 6 == 0:
                    col = shade(col, 0.88)
                c.put(x, y, col)

    c.rect(18, h - 13, w - 19, h - 4, (28, 32, 38))
    c.rect(18, h - 13, w - 19, h - 12, (54, 60, 68))
    return c.im


def make_dispatch_note():
    """Generates a gritty aged 157x95 prison dispatch note card (emir_notu_bos.png)."""
    w, h = 157, 95
    c = Canvas(w, h)
    for y in range(h):
        for x in range(w):
            if x > w - 7 and y < 7 and (x - (w - 7)) + (7 - y) > 6:
                continue
            grain = (((x * 13 + y * 29) ^ (x * 3)) % 7 - 3) * 2
            edge = min(x, y, w - 1 - x, h - 1 - y)
            vig = 0.84 if edge < 4 else (0.91 if edge < 8 else 1.0)
            r = int((194 + grain) * vig)
            g = int((174 + grain) * vig)
            b = int((132 + grain) * vig)
            c.put(x, y, (r, g, b))
    c.rect(0, 0, w - 1, 0, (48, 38, 28))
    c.rect(0, h - 1, w - 1, h - 1, (48, 38, 28))
    c.rect(0, 0, 0, h - 1, (48, 38, 28))
    c.rect(w - 1, 6, w - 1, h - 1, (48, 38, 28))
    c.rect(4, 5, w - 8, 11, (128, 32, 28))
    c.rect(w // 2 - 16, 0, w // 2 + 16, 6, (164, 158, 142))
    return c.im


def restore_dark_books():
    """Restores yeni_kural_kitabi_orig.png and yeni_gazete_orig.png with dark, moody 1984 contrast."""
    for name in ("yeni_kural_kitabi.png", "yeni_gazete.png"):
        orig = os.path.join("tools", name.replace(".png", "_orig.png"))
        dst = os.path.join(OUT, name)
        if os.path.exists(orig):
            im = Image.open(orig).convert("RGBA")
            r, g, b, a = im.split()
            rgb = Image.merge("RGB", (r, g, b))
            rgb = ImageEnhance.Brightness(rgb).enhance(0.92)
            rgb = ImageEnhance.Contrast(rgb).enhance(1.12)
            rgb = ImageEnhance.Color(rgb).enhance(0.90)
            nr, ng, nb = rgb.split()
            Image.merge("RGBA", (nr, ng, nb, a)).save(dst)


def make_dialogue_strip(has_tail=False):
    """Generates a large, crisp 340x58 (or 340x68 with tail) Papers, Please-style intercom speech bubble strip."""
    w = 340
    h = 68 if has_tail else 58
    body_h = 54
    c = Canvas(w, h)

    for y in range(4, body_h + 3):
        for x in range(4, w - 1):
            if (x in (4, w - 2) and y in (4, body_h + 2)):
                continue
            c.put(x, y, (6, 8, 10, 180))
    if has_tail:
        for ty in range(body_h, h):
            t = (ty - body_h) / float(max(1, h - 1 - body_h))
            tx0 = int(34 - 12 * t)
            tx1 = int(50 - 14 * t)
            for x in range(tx0 + 2, tx1 + 3):
                c.put(x, ty, (6, 8, 10, 175))

    x0, y0, x1, y1 = 1, 1, w - 4, body_h - 1
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            cd = min(x - x0, x1 - x) + min(y - y0, y1 - y)
            if cd < 2:
                continue
            if x <= x0 + 1 or x >= x1 - 1 or y <= y0 + 1 or y >= y1 - 1 or cd == 2:
                c.put(x, y, (18, 16, 20))
            elif y == y0 + 2 or x == x0 + 2:
                c.put(x, y, (236, 228, 210))
            elif y == y1 - 2 or x == x1 - 2:
                c.put(x, y, (176, 162, 136))
            else:
                grain = (((x * 17 + y * 29) ^ (x * 5)) % 5 - 2)
                scan = -2 if (y % 4 == 0) else 0
                c.put(x, y, (224 + grain + scan, 214 + grain + scan, 192 + grain + scan))

    bar_col = (148, 36, 32) if not has_tail else (164, 92, 28)
    bar_hi = (186, 58, 52) if not has_tail else (198, 124, 46)
    for y in range(y0 + 6, y1 - 5):
        c.rect(6, y, 11, y, bar_col)
        c.put(6, y, bar_hi)
    for dy in range(y0 + 9, y1 - 7, 4):
        c.put(8, dy, (232, 222, 200))
    for y in range(y0 + 4, y1 - 3):
        c.put(15, y, (182, 170, 146))
        c.put(16, y, (232, 224, 208))

    if has_tail:
        for ty in range(y1 - 1, h - 1):
            t = (ty - (y1 - 1)) / float(max(1, h - 2 - (y1 - 1)))
            tx0 = int(34 - 13 * t)
            tx1 = int(50 - 16 * t)
            for x in range(tx0, tx1 + 1):
                if ty == h - 2 or x <= tx0 + 1 or x >= tx1 - 1:
                    c.put(x, ty, (18, 16, 20))
                elif x == tx0 + 2:
                    c.put(x, ty, (236, 228, 210))
                elif x == tx1 - 2:
                    c.put(x, ty, (176, 162, 136))
                else:
                    c.put(x, ty, (220, 210, 188))
    return c.im


def make_citation_slip():
    """Generates a 310x136 Papers, Please-style dot-matrix printer citation slip (ihtar_fisi.png)."""
    w, h = 310, 136
    c = Canvas(w, h)
    # Soft drop shadow
    for y in range(4, h):
        for x in range(4, w):
            c.put(x, y, (6, 8, 10, 155))

    # Main paper body with serrated top & bottom tear-off teeth
    for y in range(1, h - 3):
        for x in range(1, w - 4):
            # Serrated top & bottom edge
            if y == 1 and (x % 6 >= 3):
                continue
            if y == h - 4 and ((x + 3) % 6 >= 3):
                continue
            # Border
            if x == 1 or x == w - 5 or y == 1 or y == h - 4:
                c.put(x, y, (42, 26, 28))
                continue
            # Pinkish-beige dot-matrix thermal citation paper with horizontal scanlines
            grain = (((x * 13 + y * 31) ^ (x * 7)) % 7 - 3)
            scan = -4 if (y % 3 == 0) else 0
            # Left & right tractor-feed strips (x < 20 or x > w - 24)
            if x < 20 or x > w - 24:
                base_r, base_g, base_b = 198, 174, 166
            else:
                base_r, base_g, base_b = 216, 192, 182
            c.put(x, y, (base_r + grain + scan, base_g + grain + scan, base_b + grain + scan))

    # Perforation vertical dotted lines separating tractor-feed margins
    for y in range(3, h - 5, 2):
        c.put(20, y, (124, 96, 92))
        c.put(w - 24, y, (124, 96, 92))

    # Tractor-feed sprocket holes along left & right margins
    for hy in range(12, h - 10, 18):
        for hx in (10, w - 14):
            for dy in range(-3, 4):
                for dx in range(-3, 4):
                    if dx * dx + dy * dy <= 9:
                        c.put(hx + dx, hy + dy, (22, 18, 20, 235))
                    elif dx * dx + dy * dy <= 13:
                        c.put(hx + dx, hy + dy, (138, 112, 106))

    # Top crimson dot-matrix header band (y = 7..27)
    c.rect(24, 7, w - 28, 26, (132, 28, 30))
    c.rect(24, 7, w - 28, 8, (164, 42, 44))
    c.rect(24, 29, w - 28, 30, (112, 34, 34))

    # Bottom warning footer band (y = h - 28..h - 8)
    c.rect(24, h - 28, w - 28, h - 27, (112, 34, 34))
    c.rect(24, h - 25, w - 28, h - 8, (44, 22, 24))
    return c.im


def make_prisoner_note(with_money=False):
    """Generates a 244x198 torn, creased handwritten notebook paper scrap (mahkum_notu.png / mahkum_notu_parali.png)."""
    w, h = 244, 198
    c = Canvas(w, h)

    # Soft drop shadow on desk
    for y in range(6, h):
        for x in range(6, w - 2):
            c.put(x, y, (6, 8, 10, 155))

    # Torn notebook paper scrap body
    for y in range(2, h - 4):
        # Jagged torn right edge & bottom edge
        tear_r = ((y * 19 + 7) % 4) if y % 5 != 0 else 4
        for x in range(3, w - 5 - tear_r):
            tear_b = ((x * 23 + 11) % 4) if x % 7 != 0 else 4
            if y > h - 6 - tear_b:
                continue
            # Folded dog-ear bottom-right corner
            if (x - (w - 26)) + (y - (h - 26)) > 18:
                continue
            # Dark paper outline
            if (
                x == 3
                or y == 2
                or x == w - 6 - tear_r
                or y == h - 6 - tear_b
                or (x - (w - 26)) + (y - (h - 26)) == 18
            ):
                c.put(x, y, (38, 32, 26))
                continue

            # Paper texture: aged yellowish-beige notebook paper with creases & smudges
            grain = (((x * 17 + y * 29) ^ (x * 11 + y * 3)) % 9 - 4)
            crease = -8 if abs((x - y * 1.2) - 42) < 1.8 or abs((x + y * 0.9) - 210) < 1.6 else 0
            stain = -10 if ((x - 185) ** 2 + (y - 125) ** 2 < 340) else 0
            r = 224 + grain + crease + stain
            g = 212 + grain + crease + stain
            b = 184 + grain + crease + stain

            # Faint horizontal blue-gray notebook rules every 15px
            if y >= 34 and y < h - 14 and (y % 15 == 0):
                r, g, b = int(r * 0.84), int(g * 0.87), int(b * 0.94)
            # Vertical faded red margin line on left (x = 24)
            if x == 24 and y >= 28:
                r, g, b = int(r * 0.88 + 22), int(g * 0.72), int(b * 0.72)

            c.put(x, y, (max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b))))

    # Dog-ear folded flap triangle at bottom-right
    for y in range(h - 24, h - 6):
        for x in range(w - 24, w - 6):
            if (x - (w - 26)) + (y - (h - 26)) <= 18 and (x - (w - 24)) >= 0 and (y - (h - 24)) >= 0:
                if (x - (w - 24)) + (y - (h - 24)) <= 16:
                    c.put(x, y, (186, 172, 144))

    # Spiral notebook punch holes along the left edge (x = 12)
    for hy in range(18, h - 16, 22):
        for dy in range(-3, 4):
            for dx in range(-3, 4):
                if dx * dx + dy * dy <= 8:
                    c.put(12 + dx, hy + dy, (20, 16, 14, 235))
                elif dx * dx + dy * dy <= 12:
                    c.put(12 + dx, hy + dy, (148, 134, 112))
        # Torn notch from hole to left edge
        c.rect(3, hy - 1, 9, hy + 1, (28, 22, 18, 220))

    # Dark charcoal/crimson header band at top (y = 7..26)
    c.rect(22, 7, w - 16, 25, (42, 34, 30))
    c.rect(22, 7, w - 16, 8, (68, 52, 44))
    c.rect(22, 26, w - 16, 27, (128, 46, 38))

    # Bottom subtle separator rule (y = 154)
    c.rect(26, 154, w - 18, 155, (142, 126, 104))

    # Optional $20 bribe banknote paperclipped to top-right / right side
    if with_money:
        bx0, by0, bx1, by1 = w - 66, 2, w - 4, 36
        for y in range(by0, by1 + 1):
            for x in range(bx0, bx1 + 1):
                if x == bx0 or x == bx1 or y == by0 or y == by1:
                    c.put(x, y, (22, 42, 24))
                elif x in (bx0 + 2, bx1 - 2) or y in (by0 + 2, by1 - 2):
                    c.put(x, y, (168, 198, 156))
                else:
                    mg = ((x * 13 + y * 17) % 7 - 3)
                    c.put(x, y, (76 + mg, 122 + mg, 74 + mg))
        # Center emblem & "20$" markings on banknote
        for dy in range(-7, 8):
            for dx in range(-9, 10):
                if dx * dx + dy * dy <= 52:
                    c.put(bx0 + 31 + dx, by0 + 17 + dy, (52, 88, 52))
        # Metallic silver paperclip holding the bill to the note
        c.rect(bx0 + 8, 0, bx0 + 16, 2, (210, 218, 226))
        c.rect(bx0 + 8, 2, bx0 + 9, 22, (195, 204, 214))
        c.rect(bx0 + 15, 2, bx0 + 16, 18, (165, 174, 184))
        c.rect(bx0 + 11, 5, bx0 + 12, 18, (215, 222, 230))
        c.rect(bx0 + 9, 21, bx0 + 15, 22, (180, 188, 198))

    return c.im


def gen_props():
    restore_dark_stamps()
    make_drawer_base().save(os.path.join(OUT, "damga_cekmecesi_taban.png"))
    make_delivery_tray().save(os.path.join(OUT, "teslim_bolmesi.png"))
    note = make_dispatch_note()
    note.save(os.path.join(OUT, "emir_notu_bos.png"))
    note.save(os.path.join(OUT, "yeni_emir_notu.png"))
    make_dialogue_strip(has_tail=False).save(os.path.join(OUT, "diyalog_seridi_1.png"))
    make_dialogue_strip(has_tail=True).save(os.path.join(OUT, "diyalog_seridi_2.png"))
    make_citation_slip().save(os.path.join(OUT, "ihtar_fisi.png"))
    make_prisoner_note(with_money=False).save(os.path.join(OUT, "mahkum_notu.png"))
    make_prisoner_note(with_money=True).save(os.path.join(OUT, "mahkum_notu_parali.png"))
    restore_dark_books()
    print("props ok")


# ==================================================================================
# 6. DARK, GRITTY 1984 DYSTOPIAN BACKGROUND (assets/ana_ekran_arkaplan.png)
# ==================================================================================
def darken_bg():
    src = "tools/ana_ekran_arkaplan_orig.png"
    dst = "assets/ana_ekran_arkaplan.png"
    if not os.path.exists(src):
        Image.open(dst).save(src)
    orig_im = Image.open(src).convert("RGBA")
    src_px = orig_im.load()
    im = orig_im.copy()
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = src_px[x, y]
            if x < 346 and y < 232:
                # Dim, oppressive cold corridor lighting
                lamp = math.exp(-(((x - 172) / 160.0) ** 2 + ((y - 60) / 170.0) ** 2))
                f = 0.56 + 0.22 * lamp
                r, g, b = int(r * f * 0.90), int(g * f * 0.96), int(b * f * 1.04)
            elif 368 <= x <= 634 and 28 <= y <= 198:
                # Grim booth window interior
                bulb = math.exp(-(((x - 501) / 115.0) ** 2 + ((y - 58) / 115.0) ** 2))
                brick = 3 if ((y // 14) % 2 == 0 and x % 28 == 0) or (y % 14 == 0) else 0
                r = int(r * 0.88 + 14 * bulb - brick)
                g = int(g * 0.88 + 12 * bulb - brick)
                b = int(b * 0.88 + 8 * bulb - brick)
            elif x > 650 and y < 232:
                # Shadowy right guard station & heavy door
                lamp_r = math.exp(-(((x - 840) / 200.0) ** 2 + ((y - 90) / 165.0) ** 2))
                f = 0.82 + 0.16 * lamp_r
                r, g, b = int(r * f), int(g * f), int(b * f)
            elif y >= 268:
                # Seamless dark walnut wood desk across full width (removes baked-in left cabinet/button artifacts)
                if x < 310 or (x > 980 and y > 530):
                    sx = 340 + (x % 580)
                    sy = 280 + ((y - 268) % 260)
                    r, g, b, _ = src_px[sx, sy]
                desk_lamp = math.exp(-(((x - 540) / 320.0) ** 2 + ((y - 375) / 210.0) ** 2))
                r = int(r * 0.88 + 12 * desk_lamp)
                g = int(g * 0.86 + 9 * desk_lamp)
                b = int(b * 0.84 + 5 * desk_lamp)
            else:
                # Concrete counter ledge & upper trim (y in 232..267)
                if y >= 244 and x < 310:
                    sx = 340 + (x % 580)
                    r, g, b, _ = src_px[sx, y]
                r, g, b = int(r * 0.86), int(g * 0.86), int(b * 0.86)
            px[x, y] = (max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)), a)
    im.save(dst)
    print("bg ok")


if __name__ == "__main__":
    import sys
    what = sys.argv[1:] or ["prisoners", "queue", "guards", "shelf", "props", "bg"]
    if "prisoners" in what: gen_prisoners()
    if "queue" in what: gen_queue()
    if "guards" in what: gen_guards()
    if "shelf" in what: gen_shelf_items()
    if "props" in what: gen_props()
    if "bg" in what: darken_bg()
