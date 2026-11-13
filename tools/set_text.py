"""Set or add rows in a data/text CSV: python3 tools/set_text.py <csv> <rows.json>, rows = {KEY: [id, en]}."""
import csv, json, sys
path, rows = sys.argv[1], json.load(open(sys.argv[2]))
data = list(csv.reader(open(path, newline="", encoding="utf-8")))
seen = set()
for r in data:
    if r and r[0] in rows:
        r[1:3] = rows[r[0]]
        seen.add(r[0])
data += [[k] + v for k, v in rows.items() if k not in seen]
csv.writer(open(path, "w", newline="", encoding="utf-8"), lineterminator="\n").writerows(data)
print("%d changed, %d added" % (len(seen), len(rows) - len(seen)))
