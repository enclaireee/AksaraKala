# Pacing model behind story.md "Pacing & Dialogue Rules (Story v5)". Run: python3 .docs/pacing_model.py
# Reads the main-quest step tables in quests.md 4 (the "Play" column) and the runtime table in story.md,
# and the side-quest cards in quests.md 5 (each card's "- Play:" lines, sized against BANDS).
# Prints minutes per act and every rule that breaks. Exits 1 if a rule breaks.
# Re-measure piece minutes after each playtest and change MIN below (TUNE).
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
MIN = {
    'talk': 1.0, 'beat': 1.5, 'lesson': 1.5, 'write': 1.5, 'clue': 2.0,
    'fight': 2.0, 'travel': 4.0, 'puzzle': 4.0, 'memory': 4.0,
    'chapter': 6.0, 'miniboss': 4.0, 'boss': 6.0, 'setpiece': 5.0
}
PLAY = {'fight', 'travel', 'puzzle', 'miniboss', 'boss', 'setpiece', 'chapter', 'memory'}
READ = {'talk', 'beat', 'lesson'}
STORY = {'clue', 'talk', 'beat', 'memory', 'chapter', 'write'}
PAYOFF = {'miniboss', 'boss', 'setpiece', 'beat'}
HEADS = {'MQ0': 'Prologue', 'MQ1': 'Act I', 'MQG': 'Act II', 'MQ2': 'Act III', 'MQ3': 'Act IV', 'MQ5': 'Act VI'}
BANDS = {'S': (8, 15), 'M': (15, 28), 'L': (25, 45)}  # side-quest minutes by card size in v5 (TUNE)
STEP_MIN, TOL, PLAY_SHARE, READ_SHARE, STORY_GAP, PAYOFF_GAP, READ_RUN = 5.0, 0.15, 0.55, 0.25, 14, 34, 3


def act_of(mq, num):
    if mq == 'MQ4':
        return 'Interlude' if int(num.split('.')[1]) <= 8 else 'Act V'
    return HEADS.get(mq)


def pieces(cell):  # "travel, fight x2, talk" -> ['travel', 'fight', 'fight', 'talk']
    out = []
    for tok in [t.strip() for t in cell.replace('`', '').split(',') if t.strip()]:
        m = re.fullmatch(r'([a-z]+)(?:\s*x\s*(\d+))?', tok)
        if not m or m.group(1) not in MIN:
            raise ValueError('unknown piece "%s"' % tok)
        out += [m.group(1)] * int(m.group(2) or 1)
    return out


def read_steps():
    acts, mq, col = {}, None, None
    for line in open(os.path.join(HERE, 'quests.md'), encoding='utf-8'):
        h = re.match(r'###\s+(MQ\w+)', line)
        if h:
            mq, col = h.group(1), None
            continue
        if line.startswith('## ') and not line.startswith('## 4'):
            mq = None
        if mq is None or not line.startswith('|'):
            continue
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if cells and cells[0] == '#':
            col = cells.index('Play') if 'Play' in cells else None
            continue
        if not re.fullmatch(r"(\d+|g)\.\d+[a-z]?", cells[0] or ""):
            continue
        act = act_of(mq, re.match(r"(?:\d+|g)\.\d+", cells[0]).group(0))
        if act is None:
            continue
        if col is None or col >= len(cells):
            acts.setdefault(act, []).append((cells[0], None))
        else:
            acts.setdefault(act, []).append((cells[0], pieces(cells[col])))
    return acts


def read_targets():
    t = {}
    for line in open(os.path.join(HERE, 'story.md'), encoding='utf-8'):
        if not line.startswith('|'):
            continue
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if len(cells) >= 6 and cells[5].isdigit():
            name = cells[0].replace('*', '')
            for a in ['Prologue', 'Act VI', 'Act V', 'Act IV', 'Act III', 'Act II', 'Act I', 'Interlude']:
                if name.startswith(a):
                    t.setdefault(a, int(cells[5]))
                    break
        elif len(cells) >= 4 and cells[3].isdigit():
            name = cells[0].replace('*', '')
            for a in ['Prologue', 'Act VI', 'Act V', 'Act IV', 'Act III', 'Act II', 'Act I', 'Interlude']:
                if name.startswith(a):
                    t.setdefault(a, int(cells[3]))
                    break
    return t


def read_side():  # [(id, header, [pieces per Play line])] from quests.md 5
    cards, on = [], False
    for line in open(os.path.join(HERE, 'quests.md'), encoding='utf-8'):
        if line.startswith('## '):
            on = line.startswith('## 5')
            continue
        if not on:
            continue
        h = re.match(r'\*\*(SQ-[A-Z]\d+)\b[^*]*\*\*\s*(.*)', line)
        if h:
            cards.append((h.group(1), line, []))
        elif cards and re.match(r'\s*- Play:', line):
            cards[-1][2].append(pieces(line.split(':', 1)[1]))
    return [c for c in cards if 'retired' not in c[1]]


def check_side(fails):
    print('%-6s %4s %7s' % ('Side', 'size', 'minutes'))
    total = 0.0
    for sq, head, plays in read_side():
        size = re.search(r'[(,]\s*([SML])\b', head)
        if not size:
            fails.append('%s: no size S/M/L in its header' % sq); continue
        if not plays:
            fails.append('%s: no "- Play:" line' % sq); continue
        lo, hi = BANDS[size.group(1)]
        mins = [sum(MIN[x] for x in p) for p in plays]
        parts = mins if 'each' in head else [sum(mins)]  # "S each" chains size each part
        for m in parts:
            if not lo <= m <= hi:
                fails.append('%s: %.1f min outside %s band %d-%d' % (sq, m, size.group(1), lo, hi))
        if re.search(r'hunt', head, re.I) and not all(x in sum(plays, []) for x in ('clue', 'memory')):
            fails.append('%s: a Hunt card needs a clue and a memory piece' % sq)
        total += sum(parts)
        print('%-6s %4s %7.1f' % (sq, size.group(1), sum(parts)))
    print('%-6s %4s %7.1f' % ('Total', '', total))


def main():
    acts, targets, fails = read_steps(), read_targets(), []
    order = ['Prologue', 'Act I', 'Act II', 'Act III', 'Act IV', 'Interlude', 'Act V', 'Act VI']
    print('%-10s %5s %7s %7s %6s %6s' % ('Act', 'steps', 'minutes', 'target', 'play%', 'read%'))
    total = 0.0
    for a in order:
        steps = acts.get(a, [])
        missing = [n for n, p in steps if p is None]
        if missing:
            fails.append('%s: no Play column for steps %s' % (a, ', '.join(missing)))
        seq, mins = [], 0.0
        for n, p in steps:
            if p is None:
                continue
            m = sum(MIN[x] for x in p)
            mins += m
            seq += p
            min_req = 3.0 if a == 'Interlude' else STEP_MIN
            if m < min_req:
                fails.append('%s %s: thin step (%.1f min < %.1f)' % (a, n, m, min_req))
        total += mins
        tgt = targets.get(a)
        play = sum(MIN[x] for x in seq if x in PLAY) / mins if mins else 0
        read = sum(MIN[x] for x in seq if x in READ) / mins if mins else 0
        print('%-10s %5d %7.1f %7s %5.0f%% %5.0f%%' % (a, len(steps), mins, tgt if tgt else '-', play * 100, read * 100))
        if not steps:
            fails.append('%s: no steps found' % a)
            continue
        if tgt and abs(mins - tgt) > TOL * tgt:
            fails.append('%s: %.0f min, target %d (+-%d%%)' % (a, mins, tgt, TOL * 100))
        if a != 'Interlude' and mins:
            if play < PLAY_SHARE:
                fails.append('%s: play share %.0f%% < %.0f%%' % (a, play * 100, PLAY_SHARE * 100))
            if read > READ_SHARE:
                fails.append('%s: reading share %.0f%% > %.0f%%' % (a, read * 100, READ_SHARE * 100))
            t = since_story = since_payoff = 0.0
            run = 0
            for x in seq:
                t += MIN[x]
                since_story = 0 if x in STORY else since_story + MIN[x]
                since_payoff = 0 if x in PAYOFF else since_payoff + MIN[x]
                run = run + 1 if x in READ else 0
                if since_story > STORY_GAP:
                    fails.append('%s at %.0f min: no story piece for %d min' % (a, t, STORY_GAP)); since_story = 0
                if since_payoff > PAYOFF_GAP:
                    fails.append('%s at %.0f min: no payoff for %d min' % (a, t, PAYOFF_GAP)); since_payoff = 0
                if run > READ_RUN:
                    fails.append('%s at %.0f min: more than %d reading pieces in a row' % (a, t, READ_RUN)); run = 0
    print('%-10s %5s %7.1f' % ('Total', '', total))
    check_side(fails)
    for f in fails:
        print('FAIL', f)
    sys.exit(1 if fails else 0)


if __name__ == '__main__':
    main()
