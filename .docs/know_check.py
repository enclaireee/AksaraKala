# Know-before-you-meet check (story.md Pacing 10, script.md 1). Run: python3 .docs/know_check.py
# In script.md order (sections 4-11, then 15), a name's first use in an EN line must come at or after it is seen
# or explained ("Name, the/who/queen ...", "I'm Name", "Name. I ...", "your sister Name"). Seen: an NPC heading "### <id> (... name NPC_X_NAME ...)" or a speaker switch "@NPC_X_NAME".
# Names: proper NPC_*_NAME texts of
# section 3, the boss bar names and EXTRA. Exceptions: "Name check exceptions: A, B" in section 3. Exits 1 on a fail.
# ponytail: a word match over the EN column; places and nicknames are not checked (add them to EXTRA if needed).
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
GENERIC = {'The', 'A', 'An', 'Woman', 'Inscription', 'Sea', 'Altar', 'Ibu', 'Si', 'Ki', 'Mpu', 'Mbah', 'Nyi', 'Uwa', 'Prabu'}
EXTRA = ['Sandekala', 'Sangkuriang', 'Bandung Bondowoso']  # legends fought, with no NPC_*_NAME (ASSUMED)
CHECKED = re.compile(r'^## (4|5|6|7|8|9|10|11|15)\.')


def main():
    lines = open(os.path.join(HERE, 'script.md'), encoding='utf-8').read().split('\n')
    names, keyname, skip, sec = {}, {}, set(), None
    for ln in lines:
        if ln.startswith('## '):
            sec = ln
        if not sec or not sec.startswith('## 3.'):
            continue
        m = re.match(r'\|\s*(NPC_\w+_NAME)\b[^|]*\|[^|]*\|\s*([^|]+?)\s*\|', ln)
        if m:
            en = m.group(2)
            keyname[m.group(1)] = en
            if en.split()[0] not in GENERIC or len(en.split()) > 1 and en.split()[1][:1].isupper():
                names[en] = m.group(1)
        for b in re.findall(r'BOSS_\w+ "([^"]+)"', ln):
            names.setdefault(b, None)
        e = re.match(r'Name check exceptions:\s*(.*)', ln)
        if e:
            skip |= {x.strip() for x in e.group(1).split(',') if x.strip()}
    for x in EXTRA:
        names.setdefault(x, None)
    seen, fails, on = set(), [], False
    for ln in lines:
        if ln.startswith('## '):
            on = bool(CHECKED.match(ln))
        if not on:
            continue
        for k in re.findall(r'\bname (NPC_\w+_NAME)', ln) + re.findall(r'@(NPC_\w+_NAME)', ln):
            if k in keyname:
                seen.add(keyname[k])
        cells = [c.strip() for c in ln.strip().strip('|').split('|')] if ln.startswith('|') else []
        ki = next((i for i, c in enumerate(cells[:2]) if re.fullmatch(r'[A-Z][A-Z0-9_]{3,}', c)), None)
        if ki is None or ki + 2 >= len(cells):
            continue
        key, en = cells[ki], cells[ki + 2]
        for k in re.findall(r'@(NPC_\w+_NAME)', en):
            seen.add(keyname.get(k, ''))
        for n in sorted(names, key=len, reverse=True):
            if n in seen or n in skip or not re.search(r'\b%s\b' % re.escape(n), en):
                continue
            if re.search(r'\b%s\b(\s+[a-z]+)?(,\s+[a-z]|\s+\((the|a|an)\b|\.\s+I\b)|\bI\'m\s+%s\b|\b(sister|brother|son|daughter|mother|father|wife|husband)\b,?\s+%s\b' % (re.escape(n), re.escape(n), re.escape(n)), en):
                seen.add(n); continue
            fails.append('%s: "%s" before it is seen or explained' % (key, n))
            seen.add(n)  # one fail per name
    for f in fails:
        print('FAIL', f)
    print('%d names checked, %d fails' % (len(names), len(fails)))
    sys.exit(1 if fails else 0)


if __name__ == '__main__':
    main()
