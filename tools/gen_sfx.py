#!/usr/bin/env python3
"""Synthesizes dark ambience + a few sfx (wav, 22.05kHz mono)."""
import wave, struct, math, random, os
SR = 22050
random.seed(4)

def save(name, samples):
    path = os.path.join("assets", name)
    with wave.open(path, "w") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples))

def ambience(sec=24):
    n = SR * sec
    out = []
    lp = 0.0
    lp2 = 0.0
    drips = sorted(random.sample(range(SR * 2, n - SR * 2), 5))
    for i in range(n):
        t = i / SR
        white = random.uniform(-1, 1)
        lp += (white - lp) * 0.012        # brown-ish rumble
        lp2 += (lp - lp2) * 0.2
        hum = math.sin(2 * math.pi * 55 * t) * 0.10 + math.sin(2 * math.pi * 110.4 * t) * 0.045
        hum *= 0.7 + 0.3 * math.sin(2 * math.pi * 0.13 * t)
        s = lp2 * 2.2 + hum
        for d in drips:
            dt = (i - d) / SR
            if 0 <= dt < 0.25:
                s += math.sin(2 * math.pi * (900 - 1500 * dt) * dt) * math.exp(-dt * 22) * 0.18
        # seamless loop fade
        edge = min(i, n - i) / (SR * 1.5)
        s *= min(1.0, edge)
        out.append(s * 0.55)
    return out

def thud():
    n = int(SR * 0.45)
    out = []
    for i in range(n):
        t = i / SR
        s = math.sin(2 * math.pi * (95 - 60 * t) * t) * math.exp(-t * 11) + random.uniform(-1, 1) * math.exp(-t * 60) * 0.5
        out.append(s * 0.9)
    return out

def buzz():
    n = int(SR * 0.35)
    out = []
    for i in range(n):
        t = i / SR
        env = (1.0 if (i // 400) % 2 == 0 else 0.35) * math.exp(-t * 4)
        s = (math.sin(2 * math.pi * 100 * t) + 0.5 * math.sin(2 * math.pi * 300 * t) + random.uniform(-0.4, 0.4)) * env
        out.append(s * 0.4)
    return out

def creak():
    n = int(SR * 0.9)
    out = []
    for i in range(n):
        t = i / SR
        f = 220 + 90 * math.sin(2 * math.pi * 3.1 * t) + 60 * t
        s = (math.sin(2 * math.pi * f * t) * 0.5 + random.uniform(-0.3, 0.3)) * math.sin(math.pi * t / 0.9) ** 1.4
        out.append(s * 0.35)
    return out

def alarm():
    n = int(SR * 1.6)
    out = []
    for i in range(n):
        t = i / SR
        f = 520 if int(t * 3) % 2 == 0 else 390
        s = math.sin(2 * math.pi * f * t) * 0.35 * math.exp(-t * 0.5)
        out.append(s)
    return out

save("ses_ambiyans.wav", ambience())
save("ses_thud.wav", thud())
save("ses_buzz.wav", buzz())
save("ses_gicirti.wav", creak())
save("ses_alarm.wav", alarm())
print("sfx ok")
