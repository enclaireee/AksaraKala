"""Build the auto-update assets for one release (architecture.md 13b).
Usage: python3 tools/release_pack.py 1.1.1   (from the project root)
A release that changes what a pack cannot (project.godot boot settings, autoload/updater.gd) bumps BASE in
autoload/updater.gd first: every older game then opens the download page instead of patching itself.
Needs the private key at ~/.aksarakala/update_key.pem (or $AKSARAKALA_KEY) and Godot at $GODOT.
Exports one .pck per platform into build/update/, hashes and signs them, writes AksaraKala-update.json,
and prints the gh command that publishes them. It never publishes anything itself."""
import base64, hashlib, json, os, re, subprocess, sys

GODOT = os.environ.get("GODOT", "/Applications/Godot.app/Contents/MacOS/Godot")
KEY = os.path.expanduser(os.environ.get("AKSARAKALA_KEY", "~/.aksarakala/update_key.pem"))
PACKS = {"macOS": ("macOS", "AksaraKala-macos.pck"), "Windows": ("Windows Desktop", "AksaraKala-windows.pck")}
SIG_TAG = "AksaraKala-update"   # same as autoload/updater.gd SIG_TAG
OUT = "build/update"


def die(msg):
    sys.exit("release_pack: " + msg)


if len(sys.argv) != 2 or not re.fullmatch(r"\d{1,4}\.\d{1,4}\.\d{1,4}", sys.argv[1]):
    die("usage: python3 tools/release_pack.py <major.minor.patch>")
ver = sys.argv[1]
m = re.search(r'^config/version="([^"]*)"', open("project.godot").read(), re.M)
if not m or m.group(1) != ver:
    die('project.godot has config/version="%s"; set it to "%s" first' % (m.group(1) if m else "", ver))
if not os.path.exists(KEY):
    die("no private key at " + KEY)

# the key must be the one the game trusts
src = open("autoload/updater.gd").read()
embedded = re.search(r"-----BEGIN PUBLIC KEY-----.*?-----END PUBLIC KEY-----", src, re.S).group(0)
pub = subprocess.run(["openssl", "rsa", "-in", KEY, "-pubout"], capture_output=True, text=True, check=True).stdout.strip()
if pub != embedded.strip():
    die("the private key does not match PUBLIC_KEY in autoload/updater.gd")

out = subprocess.run([GODOT, "--version"], capture_output=True, text=True).stdout.strip()
e = re.match(r"(\d+)\.(\d+)(?:\.(\d+))?\.([a-z0-9]+)", out)
if not e:
    die("cannot read the Godot version from: " + out)
base = re.search(r"^const BASE := (\d+)$", src, re.M).group(1)
engine = "%s.%s.%s.%s.b%s" % (e.group(1), e.group(2), e.group(3) or "0", e.group(4), base)   # = Updater.engine_id()

os.makedirs(OUT, exist_ok=True)
packs = {}
for plat, (preset, fname) in PACKS.items():
    path = os.path.join(OUT, fname)
    if os.path.exists(path):
        os.remove(path)
    r = subprocess.run([GODOT, "--headless", "--path", ".", "--export-pack", preset, path], capture_output=True, text=True)
    if r.returncode != 0 or not os.path.exists(path):
        die("export of %s failed:\n%s" % (preset, (r.stdout + r.stderr)[-2000:]))
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    packs[plat] = {"file": fname, "size": os.path.getsize(path), "sha256": h.hexdigest()}

text = "|".join([SIG_TAG, ver, engine] + ["%s:%s:%d:%s" % (n, packs[n]["file"], packs[n]["size"], packs[n]["sha256"]) for n in sorted(packs)])
sig = subprocess.run(["openssl", "dgst", "-sha256", "-sign", KEY], input=text.encode(), capture_output=True, check=True).stdout
manifest = {"version": ver, "engine": engine, "packs": packs, "sig": base64.b64encode(sig).decode()}
with open(os.path.join(OUT, "AksaraKala-update.json"), "w") as f:
    json.dump(manifest, f, indent=1)

print("built %s for engine %s:" % (ver, engine))
for n in sorted(packs):
    print("  %-8s %s  %.1f MB" % (n, packs[n]["file"], packs[n]["size"] / 1e6))
print("\nPublish (attach the full builds too, for new players):")
print("  gh release create v%s --repo enclaireee/AksaraKala --title \"v%s\" %s/AksaraKala-update.json %s/*.pck <full builds>" % (ver, ver, OUT, OUT))
