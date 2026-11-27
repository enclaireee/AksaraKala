# Balance model behind balance.md. Run: python3 balance_model.py
# Change a knob, re-run, copy the tables into balance.md. The asserts fail if a target in section 11 breaks.
import statistics as st

# Player (rpg.md, classes.md)
CLASSES = {  # start stats [vit, end, str, dex, spi], weapon archetype, main stat index
    'Warrior': ([8, 6, 8, 4, 3], 'heavy', 2), 'Archer': ([5, 6, 4, 9, 4], 'ranged', 3),
    'Assassin': ([5, 7, 6, 7, 3], 'light', 2), 'Mage': ([4, 5, 3, 4, 10], 'staff', 4),
    # second paths (classes.md): same archetype and main stat as their school; mechanics (brace, bounce, Wirama, Lakon) are not modelled
    'Lancer': ([7, 7, 8, 4, 3], 'heavy', 2), 'Herder': ([5, 8, 4, 8, 3], 'ranged', 3),
    'Dancer': ([5, 6, 5, 8, 4], 'light', 2), 'Dalang': ([4, 5, 3, 4, 9], 'staff', 4)}
WEAPON = {'heavy': 22, 'light': 8, 'ranged': 8, 'staff': 8}          # starter base damage
SWING = {'heavy': 0.8, 'light': 0.35, 'ranged': 0.45, 'staff': 0.5}  # seconds per attack
GAIN = {'heavy': 10, 'light': 4, 'ranged': 4, 'staff': 4}           # sakti per hit
UPTIME = {'heavy': 0.45, 'light': 0.5, 'ranged': 0.6, 'staff': 0.6}  # share of fight spent attacking
SPELL_DMG, SPELL_COST = 42, 22  # average over Bolt (36 + burn), Burst, Dash-strike (spells redesign 2026-11-08)
CLASS_SPELL = {'Warrior': 0.9, 'Lancer': 0.9, 'Mage': 1.1, 'Dalang': 1.1}
MAGE_GAIN, MAGE_COST = 1.2, 0.9
MAGES = ('Mage', 'Dalang')  # Dalang's Suluk gain (1.35) is close to the Wiku's 1.2; modelled as the same
INGATAN = 0.10  # per Ingatan tier: jamasan of the Kujang Pusaka after each main boss (items.md 1, TUNE)
JIMAT_DMG = 0.10  # cap on jimat damage within the largest Daya budget, outside Rajah (items.md 2)

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
    """(total dps, spell dps, max hp) for `p` points spent and Ingatan tier `rank`; `wmult` is jimat damage."""
    s, arch, ms = build(cls, p)
    ing = 1 + INGATAN * rank
    hit = WEAPON[arch] * wmult * (1 + 0.05 * (s[4] if arch == 'staff' else s[ms])) * ing
    rate = (1 / SWING[arch]) * (1 + 0.01 * s[3]) * UPTIME[arch]
    gain = GAIN[arch] * (1 + 0.02 * s[4]) * (MAGE_GAIN if cls in MAGES else 1)
    spell = SPELL_DMG * wmult * (1 + 0.05 * s[4]) * ing * CLASS_SPELL.get(cls, 1.0)
    sdps = gain * rate / (SPELL_COST * (MAGE_COST if cls in MAGES else 1)) * spell
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
        non_mage = [row[c][0] for c in CLASSES if c not in MAGES]
        assert max(non_mage) / min(non_mage) < 1.15, 'non-mage classes drift apart'
        assert all(1.0 < 40 * HP_T[T] / d < 2.0 for d in non_mage), 'chaser time to kill out of 1-2 s'

    print('== 6 enemy roles by tier (hp/dmg/ilmu)')
    for T in range(5):
        print(T, ' '.join(f'{r} {round(h * HP_T[T])}/{round(d * DMG_T[T])}/{round(i * ILMU_T[T])}' for r, (h, d, i) in ROLE.items()))

    print('== 7 bosses (name, points, rank, armor, target seconds)')
    for n, p, R, arm, sec in [('Capt', 5, 0, 1, 60), ('Sangkuriang', 6, 0, 1, 70), ('Barma', 9, 1, 2, 65),
                              ('Bondowoso', 12, 1, 1, 80), ('Hariang', 15, 2, 3, 70), ('Buto Ijo', 16, 2, 4, 75),
                              ('Keris', 18, 2, 4, 90), ('Hunter', 19, 3, 4, 85), ('Kala', 24, 4, 5, 150)]:
        d = [power(c, p, R)[0] for c in CLASSES]
        hp = round(st.mean(d) * sec, -2)
        ref = 80 + 10 * (5.5 + round(p * 0.3))
        red = 1 - 0.05 * arm
        print(f'{n:12} HP {hp:6.0f} fight {hp / max(d):.0f}-{hp / min(d):.0f}s  light {round(ref * .10 / red)} heavy {round(ref * .22 / red)}')

    print('== 7.3 v9 scaled boss HP and hits (scene HP x0.85, mercy floor x0.68; damage x0.85)')
    HP_K, DMG_K, MERCY_CAP = 0.85, 0.85, 0.20
    for n, hp, light, heavy in [('Capt', 1800, 16, 36), ('Sangkuriang', 2100, 16, 36), ('Sandekala', 1100, 10, 22),
                                ('Barma', 2400, 18, 40), ('Bondowoso', 3100, 18, 41), ('Hariang', 2800, 21, 45),
                                ('Buto Ijo', 3400, 23, 51), ('Keris', 4200, 23, 51), ('Hunter', 4200, 24, 54),
                                ('Kala', 9300, 27, 60)]:
        print(f'{n:12} HP {round(hp * HP_K):5} (mercy floor {round(hp * HP_K * (1 - MERCY_CAP)):5})'
              f'  light {max(1, round(light * DMG_K))} heavy {max(1, round(heavy * DMG_K))}')

    print('== 7.4 fight time / target with Ingatan tiers (scene HP x0.85; main only, and 100% with jimat damage at cap)')
    # Rank = Ingatan tier at the door (main bosses killed before it, jamasan done). The band keeps late fights from
    # spiking (no tiers: Kala 1.17) and from collapsing (a +15% step: Hunter 0.68 and falling).
    for n, hp, p, R, sec in [('Capt', 1800, 5, 0, 60), ('Sangkuriang', 2100, 6, 0, 70), ('Barma', 2400, 9, 1, 65),
                             ('Bondowoso', 3100, 12, 1, 80), ('Hariang', 2800, 15, 2, 70), ('Buto Ijo', 3400, 16, 2, 75),
                             ('Keris', 4200, 18, 2, 90), ('Hunter', 4200, 19, 3, 85), ('Kala', 9300, 24, 4, 150)]:
        main = hp * HP_K / st.mean(power(c, p, R)[0] for c in CLASSES) / sec
        full = hp * HP_K / st.mean(power(c, p + 3, R, 1 + JIMAT_DMG)[0] for c in CLASSES) / sec
        print(f'{n:12} main {main:.2f}  100% {full:.2f}')
        assert 0.65 <= main <= 0.95, f'{n}: main-path fight time outside 0.65-0.95 of target'
        assert full >= 0.5, f'{n}: a 100% player with capped jimat melts the boss'

    print('== 7.5 jimat damage cap (largest Daya budget 6; Rajah excluded)')
    from itertools import combinations
    DMG_JIMAT = {'iron_ring': (2, 0.05, 0.05), 'stone_ring': (2, 0, 0.05), 'mustika': (3, 0, 0.05)}  # daya, weapon, spell
    for k in range(1, len(DMG_JIMAT) + 1):
        for combo in combinations(DMG_JIMAT, k):
            if sum(DMG_JIMAT[j][0] for j in combo) <= 6:
                w, sp = (sum(DMG_JIMAT[j][i] for j in combo) for i in (1, 2))
                assert w <= JIMAT_DMG + 1e-9 and sp <= JIMAT_DMG + 1e-9, f'{combo}: jimat damage over the cap'
    STAT_JIMAT = {
        **DMG_JIMAT,
        'genitri': (2, 0, 0.05), 'blencong': (2, 0, 0.05),
        'gelang_baja': (2, 0.05, 0), 'sabuk_merah': (2, 0.05, 0), 'kantong_panah': (2, 0.05, 0),
    }
    for k in range(1, len(STAT_JIMAT) + 1):
        for combo in combinations(STAT_JIMAT, k):
            if sum(STAT_JIMAT[j][0] for j in combo) <= 6:
                w, sp = (sum(STAT_JIMAT[j][i] for j in combo) for i in (1, 2))
                assert w <= 0.15 + 1e-9 and sp <= 0.15 + 1e-9, f'{combo}: jimat + stat damage over 15%'
    print('ok')

    print('== 7.2 v7 floor hazards and kneel (boss, tick, light hit, reference HP)')
    # Phase-2 floor zones tick every 0.5 s (BossKit.HazardZone). A player who blunders into one is assumed to take
    # HAZ_TICKS ticks before stepping out, HAZ_TIMES times a fight. TUNE. Rules: one blunder costs no more than one
    # light hit, a fight's blunders no more than 25% of the reference HP (about one heavy hit), and the kneel (BossKit.KNEEL) adds at
    # most 4 s to a fight without risk, so target fight times stand.
    HAZ_TICKS, HAZ_TIMES, KNEEL = 3, 2, 4.0
    for n, p, tick, light in [('Capt', 5, 5, 16), ('Sangkuriang', 6, 4, 16), ('Sandekala', 4, 3, 10), ('Barma', 9, 6, 18),
                              ('Bondowoso', 12, 6, 18), ('Hariang', 15, 6, 21), ('Buto Ijo', 16, 7, 23),
                              ('Keris', 18, 7, 23), ('Hunter', 19, 6, 24), ('Kala', 24, 8, 27)]:
        ref = 80 + 10 * (5.5 + round(p * 0.3))
        once, fight = tick * HAZ_TICKS, tick * HAZ_TICKS * HAZ_TIMES
        print(f'{n:12} tick {tick}  blunder {once} (light {light})  per fight {fight} = {fight / ref:.0%} of HP {ref:.0f}  kneel +{KNEEL:.0f}s')
        assert once <= light, f'{n}: one blunder into the floor costs more than a light hit'
        assert fight / ref <= 0.25, f'{n}: floor hazards take over 25% of the reference HP in a fight'

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
