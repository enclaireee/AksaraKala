# Balance model behind balance.md. Run: python3 balance_model.py
# Change a knob, re-run, copy the tables into balance.md. The asserts fail if a target in section 11 breaks.
import statistics as st

# Player (rpg.md, classes.md)
CLASSES = {  # start stats [vit, end, str, dex, spi], weapon archetype, main stat index
    'Warrior': ([8, 6, 8, 4, 3], 'heavy', 2), 'Archer': ([5, 6, 4, 9, 4], 'ranged', 3),
    'Assassin': ([5, 7, 6, 7, 3], 'light', 2), 'Mage': ([4, 5, 3, 4, 10], 'staff', 4)}
WEAPON = {'heavy': 22, 'light': 8, 'ranged': 8, 'staff': 8}          # starter base damage
SWING = {'heavy': 0.8, 'light': 0.35, 'ranged': 0.45, 'staff': 0.5}  # seconds per attack
GAIN = {'heavy': 10, 'light': 4, 'ranged': 4, 'staff': 4}           # sakti per hit
UPTIME = {'heavy': 0.45, 'light': 0.5, 'ranged': 0.6, 'staff': 0.6}  # share of fight spent attacking
SPELL_DMG, SPELL_COST = 32, 24  # average over Bolt, Burst, Dash-strike
CLASS_SPELL = {'Warrior': 0.9, 'Mage': 1.1}
MAGE_GAIN, MAGE_COST = 1.2, 0.9
INGATAN = 0.15

# Enemies (balance.md section 6)
HP_T = [1.0, 1.3, 1.6, 1.9, 2.2]
DMG_T = [1.0, 1.15, 1.3, 1.45, 1.6]
ILMU_T = [1, 1.5, 2.25, 3.4, 5.1]
ROLE = {'chaser': (40, 8, 6), 'shooter': (40, 8, 6), 'charger': (60, 12, 9),
        'tank': (150, 12, 15), 'elite': (600, 14, 60)}

cost = lambda n: round(40 * 1.12 ** n)


def build(cls, p):  # half main stat, 30% vitality, rest endurance
    s, arch, ms = CLASSES[cls]
    s = s[:]
    a, v = round(p * 0.5), round(p * 0.3)
    s[ms] += a; s[0] += v; s[1] += p - a - v
    return s, arch, ms


def power(cls, p, rank, wmult=1.0):
    """(total dps, spell dps, max hp) for `p` points spent and Ingatan rank."""
    s, arch, ms = build(cls, p)
    ing = 1 + INGATAN * rank
    hit = WEAPON[arch] * wmult * (1 + 0.05 * (s[4] if arch == 'staff' else s[ms])) * ing
    rate = (1 / SWING[arch]) * (1 + 0.01 * s[3]) * UPTIME[arch]
    gain = GAIN[arch] * (1 + 0.02 * s[4]) * (MAGE_GAIN if cls == 'Mage' else 1)
    spell = SPELL_DMG * (1 + 0.05 * s[4]) * ing * CLASS_SPELL.get(cls, 1.0)
    sdps = gain * rate / (SPELL_COST * (MAGE_COST if cls == 'Mage' else 1)) * spell
    return hit * rate + sdps, sdps, 80 + 10 * s[0]


def pts(ilmu):
    p = 0
    while ilmu >= cost(p):
        ilmu -= cost(p); p += 1
    return p


if __name__ == '__main__':
    print('== 5.2 class dps, main quest only, mid-zone (zone, tier, points, rank)')
    for z, T, p, R in [('Sunda', 0, 3, 0), ('Mataram', 1, 9, 1), ('Timur', 2, 15, 2), ('Kidul', 3, 20, 3), ('Kala', 4, 23, 4)]:
        row = {c: power(c, p, R) for c in CLASSES}
        print(f'{z:8}', ' | '.join(f'{c[:4]} {d:5.1f} ({sd / d:.0%}) ttk {40 * HP_T[T] / d:.1f}/{150 * HP_T[T] / d:.1f}s'
                                   for c, (d, sd, hp) in row.items()))
        non_mage = [row[c][0] for c in ('Warrior', 'Archer', 'Assassin')]
        assert max(non_mage) / min(non_mage) < 1.15, 'non-mage classes drift apart'
        assert all(1.0 < 40 * HP_T[T] / d < 2.0 for d in non_mage), 'chaser time to kill out of 1-2 s'

    print('== 6 enemy roles by tier (hp/dmg/ilmu)')
    for T in range(5):
        print(T, ' '.join(f'{r} {round(h * HP_T[T])}/{round(d * DMG_T[T])}/{round(i * ILMU_T[T])}' for r, (h, d, i) in ROLE.items()))

    print('== 7 bosses (name, points, rank, armor, target seconds)')
    for n, p, R, arm, sec in [('Sangkuriang', 6, 0, 1, 70), ('Bondowoso', 12, 1, 1, 80), ('Buto Ijo', 16, 2, 4, 75),
                              ('Keris', 18, 2, 4, 90), ('Kala', 24, 4, 5, 150)]:
        d = [power(c, p, R)[0] for c in CLASSES]
        hp = round(st.mean(d) * sec, -2)
        ref = 80 + 10 * (5.5 + round(p * 0.3))
        red = 1 - 0.05 * arm
        print(f'{n:12} HP {hp:6.0f} fight {hp / max(d):.0f}-{hp / min(d):.0f}s  light {round(ref * .10 / red)} heavy {round(ref * .22 / red)}')

    print('== 2.2 levels at boss doors (8 Ilmu avg per tier-0 kill)')
    quest = {'Sunda': 60 * 3 + 30 + 90 + 60, 'Mataram': 110 * 3 + 165, 'Timur': 220 * 2 + 330 + 110 + 330, 'Kidul': 190 + 570, 'Kala': 0}
    zones = [('Sunda', 0, 40, 150), ('Mataram', 1, 40, 300), ('Timur', 2, 40, 800), ('Kidul', 3, 30, 700), ('Kala', 4, 10, 0)]
    for label, extra in (('main only', 0), ('100%', 1)):
        il = side = 0; out = []
        for n, T, kills, boss in zones:
            q = quest[n] * extra
            il += (kills + 25 * extra * (T < 3)) * 7.65 * ILMU_T[T] + q; side += q
            out.append(f'{n} L{1 + pts(il)}')
            il += boss
        print(f'{label:9}', ', '.join(out), f'| total {il:.0f}, side share {side / il:.0%}')
        if extra:
            assert 0.25 <= side / il <= 0.35, 'side-quest Ilmu share outside 25-35%'
