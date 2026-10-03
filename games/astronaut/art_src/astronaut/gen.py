# Generates the astronaut animation frames as SVG (128x160 units, feet at y=122).
# Render to PNG with render.js, which writes player/art/*.png at 224x280 (2x the in-game size).
import math, os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "svg"); os.makedirs(OUT, exist_ok=True)
INK = "#2b2d42"; SUIT = "#f4f6fb"; SUIT_SH = "#cfd6e4"; ACC = "#ff8c42"; ACC_SH = "#d96a2b"; PACK = "#aab4c8"
VISOR = "#a8dcff"; SKIN = "#ffd9b8"; CHEEK = "#ff9aa2"
SW = 4
GROUND = 122

def limb(x, y, ang, w, L, back, end):
    fill = SUIT_SH if back else SUIT
    return (f'<g transform="rotate({ang:.1f} {x} {y})">'
            f'<rect x="{x-w/2}" y="{y-w/2}" width="{w}" height="{L+w/2}" rx="{w/2}" fill="{fill}" stroke="{INK}" stroke-width="{SW}"/>'
            f'{end(x, y+L, back)}</g>')

def boot(x, y, back):
    # toe points forward (right)
    return f'<rect x="{x-8}" y="{y-3}" width="23" height="11" rx="5.5" fill="{ACC_SH if back else ACC}" stroke="{INK}" stroke-width="{SW}"/>'

def glove(x, y, back):
    return f'<circle cx="{x}" cy="{y}" r="6.5" fill="{ACC_SH if back else ACC}" stroke="{INK}" stroke-width="{SW}"/>'

def face(cx, cy, mood):
    # three-quarter view facing right: eyes sit toward the right, far eye slightly smaller
    s = ""
    for ex, k in ((cx + 2, 0.85), (cx + 14, 1.0)):
        if mood == "blink":
            s += f'<path d="M{ex-4*k} {cy-1} q{4*k} 3 {8*k} 0" fill="none" stroke="{INK}" stroke-width="2.5" stroke-linecap="round"/>'
        else:
            s += (f'<ellipse cx="{ex}" cy="{cy-2}" rx="{3.4*k}" ry="{4.6*k}" fill="{INK}"/>'
                  f'<circle cx="{ex+1.3*k}" cy="{cy-3.8}" r="{1.4*k}" fill="#fff"/>')
    s += f'<ellipse cx="{cx+20}" cy="{cy+5}" rx="3.2" ry="2.2" fill="{CHEEK}" opacity=".85"/>'
    s += f'<ellipse cx="{cx-4}" cy="{cy+5}" rx="2.6" ry="2" fill="{CHEEK}" opacity=".7"/>'
    mx = cx + 10
    if mood == "wow":
        s += f'<ellipse cx="{mx}" cy="{cy+7}" rx="2.8" ry="3.4" fill="{INK}"/>'
    elif mood == "grin":
        s += f'<path d="M{mx-4} {cy+5} q5 6 10 0 z" fill="{INK}"/>'
    else:
        s += f'<path d="M{mx-3} {cy+6} q4 4 8 0" fill="none" stroke="{INK}" stroke-width="2.5" stroke-linecap="round"/>'
    return s

def head(cx, cy, mood, uid):
    r = 30
    s = []
    # antenna on the back of the helmet, leaning back
    s.append(f'<line x1="{cx-12}" y1="{cy-r+5}" x2="{cx-20}" y2="{cy-r-9}" stroke="{INK}" stroke-width="{SW}" stroke-linecap="round"/>')
    s.append(f'<circle cx="{cx-21}" cy="{cy-r-10}" r="5" fill="{ACC}" stroke="{INK}" stroke-width="{SW}"/>')
    s.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{SUIT}" stroke="{INK}" stroke-width="{SW}"/>')
    # shading on the back side of the helmet
    # visor sits on the front (right) of the helmet
    vx, vy, vw, vh = cx - 9, cy - 15, 37, 31
    s.append(f'<clipPath id="v{uid}"><rect x="{vx}" y="{vy}" width="{vw}" height="{vh}" rx="14"/></clipPath>')
    s.append(f'<rect x="{vx}" y="{vy}" width="{vw}" height="{vh}" rx="14" fill="{SKIN}"/>')
    s.append(f'<g clip-path="url(#v{uid})">{face(cx + 2, cy, mood)}'
             f'<rect x="{vx}" y="{vy}" width="{vw}" height="{vh}" fill="{VISOR}" opacity=".28"/>'
             f'<path d="M{vx+18} {vy+5} q9 0 13 8" fill="none" stroke="#fff" stroke-width="4" stroke-linecap="round" opacity=".85"/></g>')
    s.append(f'<rect x="{vx}" y="{vy}" width="{vw}" height="{vh}" rx="14" fill="none" stroke="{INK}" stroke-width="{SW}"/>')
    return "".join(s)

def body():
    return (f'<rect x="35" y="68" width="18" height="31" rx="7" fill="{PACK}" stroke="{INK}" stroke-width="{SW}"/>'
            f'<rect x="47" y="70" width="32" height="34" rx="12" fill="{SUIT}" stroke="{INK}" stroke-width="{SW}"/>'
            f'<rect x="64" y="79" width="12" height="11" rx="4" fill="{SUIT_SH}" stroke="{INK}" stroke-width="2.5"/>'
            f'<circle cx="68" cy="84.5" r="2.2" fill="#ff5d73"/><circle cx="73" cy="84.5" r="2" fill="#4cc9f0"/>'
            f'<rect x="47" y="94" width="32" height="5" fill="{ACC}"/>'
            f'<rect x="47" y="70" width="32" height="34" rx="12" fill="none" stroke="{INK}" stroke-width="{SW}"/>')

def pose(name, dy=0, sx=1, sy=1, tilt=0, head_dy=0, legs=(0, 0), arms=(0, 0), mood="smile"):
    lb, lf = legs; ab, af = arms
    parts = [
        limb(61, 77, ab, 12, 18, True, glove),
        limb(59, 100, lb, 14, 12, True, boot),
        body(),
        limb(66, 100, lf, 14, 12, False, boot),
        head(62, 42 + head_dy, mood, name),
        limb(64, 78, af, 12, 18, False, glove),
    ]
    t = f'translate(64 {GROUND+dy}) scale({sx} {sy}) translate(-64 {-GROUND}) rotate({tilt} 64 100)'
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 -32 128 160" width="224" height="280">'
           f'<g transform="{t}" stroke-linejoin="round">{"".join(parts)}</g></svg>')
    open(os.path.join(OUT, f"{name}.svg"), "w").write(svg)

pose("idle_0", legs=(4, -6), arms=(6, -8))
pose("idle_1", dy=1.5, sy=0.98, sx=1.01, head_dy=1.5, legs=(4, -6), arms=(10, -12))
for i in range(6):
    t = i / 6 * 2 * math.pi
    s = math.sin(t)
    pose(f"run_{i}", dy=-5 * (1 - abs(s)) + 1, tilt=8, head_dy=1.5 * abs(s),
         legs=(38 * s, -38 * s), arms=(-50 * s, 50 * s), mood="grin")
pose("jump_0_start", sx=1.1, sy=0.86, head_dy=4, legs=(10, -14), arms=(45, 40))
pose("jump_1_air", dy=-8, sx=0.95, sy=1.06, head_dy=-2, legs=(30, -35), arms=(-150, -115), mood="wow")
pose("jump_2_land", sx=1.14, sy=0.84, head_dy=5, legs=(22, -22), arms=(-60, -85), mood="grin")
