"""Writes assets/illustrations/<item>.svg: one flat picture per item.

Each picture shows exactly what to photograph (a laptop, not "a computer").
Style: 200x200, thick ink outline, flat fills, a soft floor shadow. Kept to
plain SVG shapes that flutter_svg renders. Run from the repo root:
    python3 tool/illustrations/make_illustrations.py
"""
import pathlib

INK = '#1B2A20'
OUT = pathlib.Path('assets/illustrations')


def svg(body, shadow=True):
    floor = ('<ellipse cx="100" cy="184" rx="62" ry="8" fill="#000000" '
             'fill-opacity="0.08" stroke="none"/>') if shadow else ''
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">'
            f'{floor}<g stroke="{INK}" stroke-width="7" stroke-linejoin="round" '
            f'stroke-linecap="round">{body}</g></svg>\n')


def shine(x, y, w, h, r=None):
    r = w / 2 if r is None else r
    return (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" '
            'fill="#FFFFFF" fill-opacity="0.45" stroke="none"/>')


P = {}

# ---- Kitchen ---------------------------------------------------------------
P['mug'] = (
    '<path d="M134 84 c34 0 34 52 0 52" fill="none" stroke-width="12"/>'
    '<rect x="44" y="62" width="92" height="112" rx="16" fill="#F2643D"/>'
    + shine(56, 76, 12, 70) +
    '<path d="M72 50 q-10 -12 0 -26 M98 50 q-10 -12 0 -26 M124 50 q-10 -12 0 -26" '
    'fill="none" stroke="#9AA5A0" stroke-width="6"/>')
P['plate'] = (
    '<ellipse cx="100" cy="112" rx="84" ry="56" fill="#FFFFFF"/>'
    '<ellipse cx="100" cy="112" rx="52" ry="33" fill="#E4EEF5" stroke-width="5"/>'
    '<path d="M38 104 q8 -26 40 -36" fill="none" stroke="#1F7DB0" stroke-width="6"/>')
P['bowl'] = (
    '<rect x="72" y="150" width="56" height="20" rx="6" fill="#1F7DB0"/>'
    '<path d="M24 88 h152 a76 70 0 0 1 -152 0 z" fill="#1F7DB0"/>'
    '<ellipse cx="100" cy="88" rx="76" ry="16" fill="#8CC5E6"/>'
    + shine(44, 104, 12, 30))
P['spoon'] = (
    '<g transform="rotate(-35 100 100)">'
    '<rect x="92" y="92" width="16" height="100" rx="8" fill="#C9D3DA"/>'
    '<ellipse cx="100" cy="52" rx="30" ry="42" fill="#C9D3DA"/>'
    '<ellipse cx="100" cy="52" rx="16" ry="26" fill="#E9EEF1" stroke="none"/></g>')
P['fork'] = (
    '<g transform="rotate(-30 100 100)">'
    '<rect x="91" y="104" width="18" height="90" rx="9" fill="#C9D3DA"/>'
    '<path d="M64 20 v52 q0 38 36 38 q36 0 36 -38 v-52 h-12 v50 h-12 v-50 h-12 v50 '
    'h-12 v-50 h-12 v50 h-12 v-50 z" fill="#C9D3DA"/></g>')
P['bottle'] = (
    '<rect x="80" y="14" width="40" height="24" rx="6" fill="#1E8A52"/>'
    '<path d="M86 38 h28 v18 q30 16 30 46 v70 q0 12 -12 12 h-64 q-12 0 -12 -12 v-70 '
    'q0 -30 30 -46 z" fill="#8CD3F0"/>'
    '<rect x="56" y="108" width="88" height="44" fill="#FFC12E"/>'
    + shine(66, 70, 10, 30))
P['banana'] = (
    '<path d="M36 52 q-6 98 120 108 q14 2 18 -10 q2 -10 -12 -12 q-92 -6 -108 -88 '
    'q-4 -8 -18 2 z" fill="#FFD43B"/>'
    '<path d="M36 52 l-6 -14" fill="none" stroke-width="10"/>'
    '<path d="M62 74 q24 54 86 70" fill="none" stroke="#E0A100" stroke-width="5"/>')
P['apple'] = (
    '<path d="M100 62 c-34 -22 -78 0 -72 50 c6 50 44 76 72 60 c28 16 66 -10 72 -60 '
    'c6 -50 -38 -72 -72 -50 z" fill="#E53935"/>'
    '<path d="M100 62 q0 -22 12 -36" fill="none"/>'
    '<path d="M112 40 q26 -22 46 -6 q-22 22 -46 6 z" fill="#43A047"/>'
    + shine(52, 86, 14, 40))
P['orange'] = (
    '<circle cx="100" cy="108" r="66" fill="#FB8C00"/>'
    '<path d="M100 42 q6 -18 26 -20 q-4 20 -26 20 z" fill="#43A047"/>'
    '<circle cx="100" cy="44" r="4" fill="' + INK + '" stroke="none"/>'
    '<circle cx="80" cy="96" r="3" fill="#C96F00" stroke="none"/>'
    '<circle cx="124" cy="118" r="3" fill="#C96F00" stroke="none"/>'
    '<circle cx="104" cy="146" r="3" fill="#C96F00" stroke="none"/>'
    + shine(58, 84, 14, 40))
P['carrot'] = (
    '<path d="M112 50 q-14 -30 -40 -34 M118 48 q4 -30 24 -40 M124 54 q22 -16 48 -10" '
    'fill="none" stroke="#43A047" stroke-width="12"/>'
    '<path d="M92 56 q36 -18 64 10 l-96 112 q-8 6 -12 -4 z" fill="#FB8C00"/>'
    '<path d="M98 86 l18 10 M86 108 l16 10 M74 132 l14 8" fill="none" stroke-width="5"/>')
P['bread'] = (
    '<path d="M44 92 q-22 -56 32 -62 q24 -4 48 0 q54 6 32 62 v66 q0 12 -12 12 h-88 '
    'q-12 0 -12 -12 z" fill="#D9893F"/>'
    '<path d="M58 96 q-14 -44 26 -50 q16 -2 32 0 q40 6 26 50 v58 q0 4 -4 4 h-76 '
    'q-4 0 -4 -4 z" fill="#FBE3B8" stroke="none"/>'
    '<circle cx="84" cy="104" r="3" fill="#D9893F" stroke="none"/>'
    '<circle cx="114" cy="124" r="3" fill="#D9893F" stroke="none"/>'
    '<circle cx="92" cy="140" r="3" fill="#D9893F" stroke="none"/>')
P['fridge'] = (
    '<rect x="48" y="14" width="104" height="168" rx="14" fill="#EEF3F7"/>'
    '<path d="M48 78 h104" fill="none"/>'
    '<rect x="128" y="34" width="10" height="28" rx="5" fill="' + INK + '"/>'
    '<rect x="128" y="94" width="10" height="44" rx="5" fill="' + INK + '"/>'
    '<circle cx="74" cy="104" r="8" fill="#FFC12E" stroke-width="5"/>'
    '<rect x="66" y="122" width="22" height="16" rx="3" fill="#F2643D" stroke-width="5"/>')
P['sink'] = (
    '<path d="M92 104 v-54 q0 -16 16 -16 h22 q12 0 12 12 v14" fill="none" '
    'stroke="#6E7E88" stroke-width="16"/>'
    '<path d="M92 104 v-54 q0 -16 16 -16 h22 q12 0 12 12 v14" fill="none" '
    'stroke="#C9D3DA" stroke-width="6"/>'
    '<path d="M142 72 q-6 12 0 18 q6 -6 0 -18 z" fill="#4FB3E8" stroke-width="4"/>'
    '<rect x="16" y="104" width="168" height="22" rx="6" fill="#C9D3DA"/>'
    '<path d="M42 126 h116 v18 q0 30 -30 30 h-56 q-30 0 -30 -30 z" fill="#EEF3F7"/>')
P['pot'] = (
    '<rect x="16" y="98" width="28" height="14" rx="7" fill="#6E7E88"/>'
    '<rect x="156" y="98" width="28" height="14" rx="7" fill="#6E7E88"/>'
    '<rect x="36" y="84" width="128" height="88" rx="16" fill="#8A9AA5"/>'
    '<path d="M28 84 q72 -46 144 0 z" fill="#B8C4CC"/>'
    '<circle cx="100" cy="54" r="9" fill="' + INK + '"/>'
    + shine(48, 98, 12, 56))

# ---- Living room -----------------------------------------------------------
P['sofa'] = (
    '<rect x="42" y="152" width="12" height="22" rx="3" fill="' + INK + '"/>'
    '<rect x="146" y="152" width="12" height="22" rx="3" fill="' + INK + '"/>'
    '<rect x="30" y="54" width="140" height="70" rx="20" fill="#8E5BD6"/>'
    '<rect x="30" y="112" width="140" height="46" rx="12" fill="#A97BE6"/>'
    '<path d="M100 60 v52" fill="none" stroke-width="5"/>'
    '<rect x="10" y="88" width="34" height="72" rx="16" fill="#8E5BD6"/>'
    '<rect x="156" y="88" width="34" height="72" rx="16" fill="#8E5BD6"/>')
P['tv'] = (
    '<path d="M76 144 l-12 30 h72 l-12 -30" fill="#6E7E88"/>'
    '<rect x="18" y="34" width="164" height="112" rx="12" fill="' + INK + '"/>'
    '<rect x="30" y="46" width="140" height="88" rx="4" fill="#4FB3E8" stroke="none"/>'
    '<circle cx="138" cy="72" r="14" fill="#FFC12E" stroke="none"/>'
    '<path d="M30 134 v-30 q36 -26 70 0 q30 -22 70 6 v24 z" fill="#43A047" stroke="none"/>')
P['laptop'] = (
    '<rect x="42" y="34" width="116" height="84" rx="10" fill="#3A4A40"/>'
    '<rect x="52" y="44" width="96" height="64" rx="3" fill="#8CC5E6" stroke="none"/>'
    '<path d="M14 130 h172 l-14 30 h-144 z" fill="#C9D3DA"/>'
    '<path d="M36 118 h128 v12 h-128 z" fill="#8A9AA5"/>'
    '<rect x="84" y="140" width="32" height="12" rx="3" fill="#EEF3F7" stroke-width="4"/>')
_keys = ''.join(
    f'<rect x="{26 + c * 17}" y="{80 + r * 18}" width="13" height="13" rx="3" '
    'fill="#FFFFFF" stroke-width="3"/>'
    for r in range(3) for c in range(9))
P['keyboard'] = (
    '<rect x="14" y="66" width="172" height="92" rx="12" fill="#8A9AA5"/>' + _keys +
    '<rect x="60" y="134" width="80" height="13" rx="3" fill="#FFFFFF" stroke-width="3"/>')
P['remote'] = (
    '<rect x="66" y="14" width="68" height="170" rx="24" fill="#3A4A40"/>'
    '<circle cx="100" cy="40" r="9" fill="#E53935" stroke-width="4"/>'
    '<circle cx="100" cy="84" r="22" fill="#8A9AA5" stroke-width="4"/>'
    '<circle cx="100" cy="84" r="8" fill="#C9D3DA" stroke-width="3"/>'
    + ''.join(f'<circle cx="{84 + c * 16}" cy="{124 + r * 18}" r="5" fill="#C9D3DA" '
              'stroke="none"/>' for r in range(3) for c in range(3)))
P['phone'] = (
    '<rect x="56" y="14" width="88" height="172" rx="18" fill="' + INK + '"/>'
    '<rect x="64" y="30" width="72" height="136" rx="6" fill="#8CC5E6" stroke="none"/>'
    + ''.join(f'<rect x="{72 + c * 20}" y="{42 + r * 22}" width="14" height="14" '
              f'rx="4" fill="{col}" stroke="none"/>'
              for r, row in enumerate([['#F2643D', '#FFC12E', '#1E8A52'],
                                        ['#8E5BD6', '#D9468F', '#1F7DB0']])
              for c, col in enumerate(row)) +
    '<rect x="88" y="174" width="24" height="4" rx="2" fill="#6E7E88" stroke="none"/>')
P['plant'] = (
    '<path d="M100 112 q-48 -6 -60 -52 q44 0 60 52 z" fill="#43A047"/>'
    '<path d="M100 112 q46 -10 62 -58 q-46 4 -62 58 z" fill="#43A047"/>'
    '<path d="M100 112 q-12 -50 6 -94 q22 42 -6 94 z" fill="#2E8B3E"/>'
    '<path d="M62 124 h76 l-10 56 h-56 z" fill="#E0763A"/>'
    '<rect x="54" y="110" width="92" height="18" rx="6" fill="#F28C38"/>')
P['chair'] = (
    '<rect x="54" y="118" width="12" height="62" rx="4" fill="#9A5B26"/>'
    '<rect x="134" y="118" width="12" height="62" rx="4" fill="#9A5B26"/>'
    '<rect x="56" y="20" width="88" height="86" rx="14" fill="#C27A3A"/>'
    '<path d="M80 34 v58 M100 34 v58 M120 34 v58" fill="none" stroke-width="5"/>'
    '<rect x="44" y="102" width="112" height="22" rx="8" fill="#D9934F"/>')
P['clock'] = (
    '<circle cx="100" cy="100" r="80" fill="#1F7DB0"/>'
    '<circle cx="100" cy="100" r="62" fill="#FFFFFF"/>'
    '<path d="M100 46 v10 M100 144 v10 M46 100 h10 M144 100 h10" fill="none" '
    'stroke-width="6"/>'
    '<path d="M100 100 v-34 M100 100 l26 16" fill="none" stroke-width="8"/>'
    '<circle cx="100" cy="100" r="6" fill="' + INK + '"/>')
P['book'] = (
    '<path d="M48 160 h104 v12 h-104 z" fill="#FFFFFF"/>'
    '<rect x="40" y="24" width="120" height="140" rx="8" fill="#E53935"/>'
    '<rect x="40" y="24" width="22" height="140" rx="6" fill="#B71C1C"/>'
    '<rect x="78" y="52" width="64" height="20" rx="4" fill="#FFC12E" stroke-width="5"/>'
    '<path d="M78 92 h50 M78 108 h36" fill="none" stroke="#FFFFFF" stroke-width="6"/>')
P['lamp'] = (
    '<ellipse cx="100" cy="172" rx="42" ry="10" fill="#8A9AA5"/>'
    '<rect x="94" y="94" width="12" height="76" fill="#8A9AA5"/>'
    '<path d="M68 22 h64 l28 74 h-120 z" fill="#FFC12E"/>'
    '<path d="M30 112 l-14 10 M170 112 l14 10 M54 124 l-8 14 M146 124 l8 14" '
    'fill="none" stroke="#FFC12E" stroke-width="6"/>')
P['curtain'] = (
    '<rect x="50" y="36" width="100" height="138" fill="#BFE3F5"/>'
    '<path d="M100 36 v138 M50 104 h100" fill="none" stroke="#FFFFFF" stroke-width="6"/>'
    '<path d="M24 36 h56 q-16 70 6 140 h-62 z" fill="#D9468F"/>'
    '<path d="M176 36 h-56 q16 70 -6 140 h62 z" fill="#D9468F"/>'
    '<path d="M44 46 q-6 60 4 120 M156 46 q6 60 -4 120" fill="none" stroke="#B0306F" '
    'stroke-width="5"/>'
    '<path d="M14 30 h172" fill="none" stroke-width="10"/>')

# ---- Kids' room ------------------------------------------------------------
P['teddy'] = (
    '<circle cx="62" cy="40" r="18" fill="#B5763A"/>'
    '<circle cx="138" cy="40" r="18" fill="#B5763A"/>'
    '<ellipse cx="54" cy="128" rx="18" ry="24" fill="#B5763A"/>'
    '<ellipse cx="146" cy="128" rx="18" ry="24" fill="#B5763A"/>'
    '<ellipse cx="72" cy="168" rx="22" ry="16" fill="#B5763A"/>'
    '<ellipse cx="128" cy="168" rx="22" ry="16" fill="#B5763A"/>'
    '<ellipse cx="100" cy="134" rx="44" ry="44" fill="#C98A4B"/>'
    '<ellipse cx="100" cy="140" rx="24" ry="26" fill="#E8C08A" stroke="none"/>'
    '<circle cx="100" cy="66" r="44" fill="#C98A4B"/>'
    '<ellipse cx="100" cy="80" rx="20" ry="15" fill="#E8C08A"/>'
    '<ellipse cx="100" cy="74" rx="7" ry="5" fill="' + INK + '"/>'
    '<circle cx="82" cy="56" r="5" fill="' + INK + '" stroke="none"/>'
    '<circle cx="118" cy="56" r="5" fill="' + INK + '" stroke="none"/>')
P['toycar'] = (
    '<path d="M100 50 v-16 M88 34 h24" fill="none" stroke="#E0A100" stroke-width="9"/>'
    '<path d="M28 132 v-28 q0 -12 12 -14 l24 -4 q14 -32 40 -32 h14 q22 0 34 30 '
    'l12 4 q12 4 12 16 v28 z" fill="#E53935"/>'
    '<path d="M76 86 q10 -20 26 -20 h8 v20 z M118 66 q12 0 20 20 h-20 z" '
    'fill="#BFE3F5" stroke-width="5"/>'
    '<circle cx="58" cy="138" r="24" fill="' + INK + '"/>'
    '<circle cx="146" cy="138" r="24" fill="' + INK + '"/>'
    '<circle cx="58" cy="138" r="9" fill="#FFC12E" stroke="none"/>'
    '<circle cx="146" cy="138" r="9" fill="#FFC12E" stroke="none"/>')
def _brick(x, y, w, h, color, studs):
    s = f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="6" fill="{color}"/>'
    step = w / studs
    for i in range(studs):
        cx = x + step * (i + 0.5)
        s += (f'<rect x="{cx - 9}" y="{y - 12}" width="18" height="14" rx="3" '
              f'fill="{color}" stroke-width="5"/>')
    return s
P['lego'] = _brick(30, 110, 140, 62, '#E53935', 4) + _brick(58, 58, 84, 44, '#1F7DB0', 3)
P['bed'] = (
    '<rect x="26" y="150" width="10" height="24" fill="#9A5B26"/>'
    '<rect x="170" y="150" width="10" height="24" fill="#9A5B26"/>'
    '<rect x="18" y="56" width="28" height="112" rx="8" fill="#C27A3A"/>'
    '<rect x="40" y="118" width="148" height="36" rx="6" fill="#FFFFFF"/>'
    '<rect x="50" y="96" width="46" height="26" rx="12" fill="#FFFFFF"/>'
    '<rect x="88" y="110" width="102" height="50" rx="8" fill="#1F7DB0"/>'
    '<path d="M104 128 h70" fill="none" stroke="#8CC5E6" stroke-width="6"/>')
P['pillow'] = (
    '<path d="M36 48 q64 -18 128 0 q16 52 0 104 q-64 18 -128 0 q-16 -52 0 -104 z" '
    'fill="#F7F2E8"/>'
    '<path d="M36 48 l-12 -10 M164 48 l12 -10 M36 152 l-12 10 M164 152 l12 10" '
    'fill="none" stroke-width="6"/>'
    '<path d="M58 80 q42 -8 84 0" fill="none" stroke="#C9D3DA" stroke-width="5"/>'
    '<circle cx="100" cy="100" r="7" fill="#1F7DB0" stroke-width="4"/>')
P['shoe'] = (
    '<path d="M22 140 v-56 q0 -12 12 -12 h32 q16 32 46 36 l52 14 q14 4 14 18 z" '
    'fill="#1F7DB0"/>'
    '<rect x="18" y="138" width="166" height="22" rx="10" fill="#FFFFFF"/>'
    '<path d="M70 92 l14 -8 M82 102 l14 -8 M94 110 l14 -8" fill="none" '
    'stroke="#FFFFFF" stroke-width="5"/>'
    '<path d="M28 104 h30" fill="none" stroke="#FFC12E" stroke-width="8"/>')
P['hat'] = (
    '<circle cx="100" cy="34" r="18" fill="#FFFFFF"/>'
    '<path d="M38 140 q0 -96 62 -96 q62 0 62 96 z" fill="#E53935"/>'
    '<rect x="32" y="128" width="136" height="38" rx="12" fill="#F27A6E"/>'
    '<path d="M56 136 v22 M80 136 v22 M104 136 v22 M128 136 v22 M150 136 v22" '
    'fill="none" stroke-width="4"/>')
P['backpack'] = (
    '<path d="M76 46 q0 -26 24 -26 q24 0 24 26" fill="none" stroke-width="9"/>'
    '<rect x="44" y="42" width="112" height="138" rx="32" fill="#1E8A52"/>'
    '<rect x="62" y="110" width="76" height="54" rx="14" fill="#2FA39A"/>'
    '<path d="M74 124 h52" fill="none" stroke-width="5"/>'
    '<path d="M60 72 q40 -12 80 0" fill="none" stroke="#FFC12E" stroke-width="6"/>')
P['glasses'] = (
    '<path d="M30 92 l-18 -24 M170 92 l18 -24" fill="none" stroke-width="8"/>'
    '<path d="M86 100 q14 -14 28 0" fill="none" stroke-width="8"/>'
    '<circle cx="58" cy="104" r="34" fill="#CDEBFA" stroke-width="9"/>'
    '<circle cx="142" cy="104" r="34" fill="#CDEBFA" stroke-width="9"/>'
    + shine(40, 86, 8, 24) + shine(124, 86, 8, 24))
P['balloon'] = (
    '<path d="M100 146 q-14 14 4 26 q16 10 -2 24" fill="none" stroke-width="5"/>'
    '<path d="M94 146 l6 -10 l6 10 z" fill="#D9468F" stroke-width="5"/>'
    '<ellipse cx="100" cy="78" rx="54" ry="62" fill="#D9468F"/>'
    + shine(66, 46, 14, 34))
P['jacket'] = (
    '<path d="M64 30 l-38 24 l-14 92 h28 l6 -56 v98 h108 v-98 l6 56 h28 l-14 -92 '
    'l-38 -24 q-22 22 -44 0 z" fill="#FB8C00"/>'
    '<path d="M100 52 v134" fill="none" stroke-width="5"/>'
    '<path d="M64 30 l36 22 l36 -22" fill="none"/>'
    '<rect x="62" y="130" width="24" height="18" rx="4" fill="#E07A00" stroke-width="5"/>'
    '<rect x="114" y="130" width="24" height="18" rx="4" fill="#E07A00" stroke-width="5"/>')

# ---- Around the house --------------------------------------------------------
P['dog'] = (
    '<ellipse cx="100" cy="140" rx="48" ry="42" fill="#D9A066"/>'
    '<ellipse cx="100" cy="150" rx="22" ry="28" fill="#F5E1C4" stroke="none"/>'
    '<ellipse cx="54" cy="62" rx="18" ry="34" fill="#8B5A2B" transform="rotate(20 54 62)"/>'
    '<ellipse cx="146" cy="62" rx="18" ry="34" fill="#8B5A2B" transform="rotate(-20 146 62)"/>'
    '<circle cx="100" cy="70" r="44" fill="#D9A066"/>'
    '<ellipse cx="100" cy="90" rx="24" ry="18" fill="#F5E1C4"/>'
    '<ellipse cx="100" cy="82" rx="9" ry="6" fill="' + INK + '"/>'
    '<path d="M100 104 q0 14 8 14 q8 0 6 -10" fill="#F28CA0" stroke-width="5"/>'
    '<circle cx="82" cy="62" r="6" fill="' + INK + '" stroke="none"/>'
    '<circle cx="118" cy="62" r="6" fill="' + INK + '" stroke="none"/>')
P['cat'] = (
    '<path d="M144 166 q40 -6 36 -48" fill="none" stroke="#8A9AA5" stroke-width="16"/>'
    '<ellipse cx="100" cy="140" rx="46" ry="40" fill="#8A9AA5"/>'
    '<path d="M58 66 l6 -42 l30 24 z M142 66 l-6 -42 l-30 24 z" fill="#8A9AA5"/>'
    '<circle cx="100" cy="76" r="42" fill="#8A9AA5"/>'
    '<ellipse cx="84" cy="72" rx="6" ry="9" fill="#9BD86B"/>'
    '<ellipse cx="116" cy="72" rx="6" ry="9" fill="#9BD86B"/>'
    '<path d="M94 92 l6 6 l6 -6 z" fill="#F28CA0" stroke-width="4"/>'
    '<path d="M60 96 l24 2 M60 108 l24 -4 M140 96 l-24 2 M140 108 l-24 -4" '
    'fill="none" stroke-width="3"/>')
P['bicycle'] = (
    '<circle cx="52" cy="128" r="36" fill="none" stroke-width="8"/>'
    '<circle cx="152" cy="128" r="36" fill="none" stroke-width="8"/>'
    '<path d="M52 128 l34 -54 h54 l12 54 M86 74 l24 54 l30 -54 M110 128 h-58" '
    'fill="none" stroke="#E53935" stroke-width="9"/>'
    '<path d="M74 60 h28" fill="none" stroke-width="10"/>'
    '<path d="M140 74 l-6 -22 h20" fill="none" stroke-width="7"/>'
    '<circle cx="110" cy="128" r="8" fill="#8A9AA5" stroke-width="4"/>')
P['umbrella'] = (
    '<path d="M100 96 v64 q0 18 -16 18 q-14 0 -14 -12" fill="none" stroke-width="8"/>'
    '<path d="M18 100 q82 -100 164 0 q-13.7 -14 -27.3 0 q-13.7 -14 -27.3 0 '
    'q-13.7 -14 -27.3 0 q-13.7 -14 -27.3 0 q-13.7 -14 -27.3 0 q-13.7 -14 -27.3 0 z" '
    'fill="#1F7DB0"/>'
    '<path d="M100 34 q-24 30 -27 66 M100 34 q24 30 27 66" fill="none" stroke-width="5"/>'
    '<path d="M100 34 v-12" fill="none" stroke-width="7"/>')
P['car'] = (
    '<path d="M14 136 v-26 q0 -12 12 -14 l30 -6 l22 -30 q6 -8 16 -8 h40 q10 0 16 8 '
    'l20 28 l14 4 q12 4 12 16 v28 z" fill="#1F7DB0"/>'
    '<path d="M70 92 l16 -22 h22 v22 z M118 70 h18 l16 22 h-34 z" fill="#BFE3F5" '
    'stroke-width="5"/>'
    '<path d="M174 112 h12" fill="none" stroke="#FFC12E" stroke-width="8"/>'
    '<circle cx="54" cy="138" r="20" fill="' + INK + '"/>'
    '<circle cx="150" cy="138" r="20" fill="' + INK + '"/>'
    '<circle cx="54" cy="138" r="7" fill="#C9D3DA" stroke="none"/>'
    '<circle cx="150" cy="138" r="7" fill="#C9D3DA" stroke="none"/>')
P['stairs'] = (
    '<path d="M16 180 v-30 h34 v-30 h34 v-30 h34 v-30 h34 v-30 h32 v150 z" '
    'fill="#C27A3A"/>'
    '<path d="M50 150 h34 M84 120 h34 M118 90 h34 M152 60 h32" fill="none" '
    'stroke="#F2C48D" stroke-width="5"/>'
    '<path d="M30 118 l140 -110" fill="none" stroke-width="8"/>'
    '<path d="M34 146 v-30 M84 110 v-36 M134 70 v-34" fill="none" stroke-width="6"/>')
P['helmet'] = (
    '<path d="M60 150 q8 22 30 18" fill="none" stroke-width="6"/>'
    '<path d="M24 136 q0 -96 84 -96 q66 0 70 80 l-18 22 z" fill="#43A047"/>'
    '<path d="M60 72 q20 -18 46 -18 M118 56 q26 4 40 26" fill="none" '
    'stroke="#1B5E20" stroke-width="10"/>'
    '<path d="M24 136 h136" fill="none"/>'
    '<path d="M160 142 l26 -10 l-6 -14 z" fill="#2E7D32"/>')
P['skateboard'] = (
    '<rect x="44" y="114" width="28" height="12" rx="3" fill="#8A9AA5"/>'
    '<rect x="128" y="114" width="28" height="12" rx="3" fill="#8A9AA5"/>'
    '<circle cx="50" cy="136" r="14" fill="#FFC12E"/>'
    '<circle cx="150" cy="136" r="14" fill="#FFC12E"/>'
    '<path d="M14 92 q0 14 16 18 h140 q16 -4 16 -18 q-10 6 -20 6 h-132 q-10 0 -20 -6 z" '
    'fill="#F2643D"/>'
    '<path d="M60 102 l12 -6 M88 102 l12 -6 M116 102 l12 -6" fill="none" '
    'stroke="#FFFFFF" stroke-width="5"/>')
P['toothbrush'] = (
    '<g transform="rotate(-30 100 100)">'
    '<rect x="20" y="104" width="130" height="22" rx="11" fill="#2FA39A"/>'
    '<rect x="140" y="104" width="44" height="22" rx="8" fill="#2FA39A"/>'
    '<rect x="140" y="70" width="44" height="34" rx="4" fill="#FFFFFF"/>'
    '<path d="M151 72 v30 M162 72 v30 M173 72 v30" fill="none" stroke="#4FB3E8" '
    'stroke-width="4"/>'
    '<path d="M136 66 q10 -16 22 -6 q10 -14 24 -2" fill="none" stroke="#FFFFFF" '
    'stroke-width="12"/>'
    '<path d="M136 66 q10 -16 22 -6 q10 -14 24 -2" fill="none" stroke="#4FB3E8" '
    'stroke-width="4"/></g>')

if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    for name, body in P.items():
        (OUT / f'{name}.svg').write_text(svg(body))
    print(len(P), 'illustrations')
