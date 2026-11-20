extends Node
## Auto-update (architecture.md 13b). Only exported builds use it: editor runs and tests skip it.
## Boot: when user://update/ holds a verified pack newer than this build, mount it over res:// before
## any other autoload loads (official templates refuse --main-pack). Title screen: ask GitHub for the latest release once, check the RSA signature on its
## manifest, download this OS's pack, check its SHA-256 against the signed hash, then offer a restart.
## The engine binary is never replaced. A release built on another engine opens the download page instead.

signal changed   # state or info moved: the title card redraws

const API := "https://api.github.com/repos/enclaireee/AksaraKala/releases/latest"
const ASSET_PREFIX := "https://github.com/enclaireee/AksaraKala/releases/download/"
const PAGE_PREFIX := "https://github.com/enclaireee/AksaraKala/releases/"
const MANIFEST := "AksaraKala-update.json"
const DIR := "user://update/"
const INSTALLED := "user://update/installed.json"
const MAX_TRIES := 2          # failed boots on a new pack before it is thrown away
const MAX_JSON := 1 << 16      # the signed manifest
const MAX_API := 1 << 20       # the GitHub release listing
const BAD := "user://update/bad.txt"   # a version that crashed at boot twice
const MAX_PACK := 1 << 30
const SIG_TAG := "AksaraKala-update"
## Bump when a release changes what a pack cannot: project.godot boot settings (autoloads, input map, layers,
## display, translation list) or this file. Older builds then see another engine_id() and get MANUAL, for good.
const BASE := 1
## The private half lives outside the repo (~/.aksarakala/update_key.pem); tools/release_pack.py signs with it.
const PUBLIC_KEY := """-----BEGIN PUBLIC KEY-----
MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAtVqllhsZa0XWikssmqp9
xAPgYOJt3pT6szDaUvKPj/PhDD9mZUsI8VSESoRyvsFF460XYrbS3dNae2lJZv+s
9GffhDTAlX15ai6Z3h6DWl7AddXKVqv2G+2x89uWdYMyxXbzawtb7aL5xVWd9MiU
AHViwCXyIzP7CwhVk6LWZw32J5GGoRH+OrRFXQPpEQRRrYgEt7TVh23y510WXok5
Akix4TKMZpoOjvqmYffU95PR1KX8koDAlmwWyMTicNXtyH8eFZ2pZ1Pm1+kml3aF
nfkGZIUpIFn0vnFyNMzTwGDdOKVyt+7hCQLn53u+ZneQDmTd3y2hiADP+84gk+/X
ZE77rkKAAC+jS2WOcsVgYg5tBNTDu0t05kGWsiKxPXqy1MB+RWYA51BJHMdLIW02
XGnYAsuokJDiUC3tnB9btDbE8GCrzoz0JSU8n0e2yGwd4Mtbc6XBa0jhar/mzM8e
aX6kA4CkzL6CR7GRr5BkEdP9/L0Kd0uZedq7QrUzijMvAgMBAAE=
-----END PUBLIC KEY-----"""

enum { IDLE, CHECKING, NONE, AVAILABLE, DOWNLOADING, READY, MANUAL, FAILED }

var state := IDLE
var info := {}        # "version", "page", "progress" (0..1)
var _manifest := {}
var _pack_url := ""
var _http: HTTPRequest   # the pack download in flight, for progress
var _checked := false


## _init, not _ready: autoloads are created in order, so this mounts the pack before Game's script loads.
func _init() -> void:
	if OS.has_feature("template"):
		_boot()


func _process(_d: float) -> void:
	if state == DOWNLOADING and is_instance_valid(_http) and int(_manifest_pack().get("size", 0)) > 0:
		var p := clampf(float(_http.get_downloaded_bytes()) / float(_manifest_pack().size), 0.0, 1.0)
		if absf(p - float(info.get("progress", 0.0))) >= 0.01:
			info.progress = p
			changed.emit()


# ---------------------------------------------------------------- pure checks (tests/updater_test.gd)

static func engine_id() -> String:
	var v := Engine.get_version_info()
	return "%d.%d.%d.%s.b%d" % [v.major, v.minor, v.patch, v.status, BASE]   # tools/release_pack.py builds the same


static func platform() -> String:
	return OS.get_name() if OS.get_name() in ["macOS", "Windows"] else ""


static func current_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))


## [major, minor, patch], or [] when `s` is not "n.n.n".
static func parse_version(s: Variant) -> Array:
	if typeof(s) != TYPE_STRING or RegEx.create_from_string("^\\d{1,4}\\.\\d{1,4}\\.\\d{1,4}\\z").search(s) == null:
		return []
	return Array(s.split(".")).map(func(x: String) -> int: return int(x))


## a > b. A malformed a is never newer; a malformed b is older than anything.
static func newer(a: Variant, b: Variant) -> bool:
	var x := parse_version(a)
	var y := parse_version(b)
	return not x.is_empty() and (y.is_empty() or x > y)


## The exact text the release key signs (tools/release_pack.py builds the same string).
static func signed_text(m: Dictionary) -> String:
	var parts := [SIG_TAG, str(m.version), str(m.engine)]
	var names: Array = m.packs.keys()
	names.sort()
	for n in names:
		var p: Dictionary = m.packs[n]
		parts.append("%s:%s:%d:%s" % [n, p.file, int(p.size), p.sha256])
	return "|".join(parts)


## "" when the manifest is well formed and signed by `key`, otherwise the reason it is not.
static func check_manifest(m: Variant, key: CryptoKey) -> String:
	if typeof(m) != TYPE_DICTIONARY:
		return "not an object"
	for k in ["version", "engine", "packs", "sig"]:
		if not m.has(k):
			return "missing " + k
	if parse_version(m.version).is_empty():
		return "bad version"
	if typeof(m.engine) != TYPE_STRING or RegEx.create_from_string("^[0-9a-z.]{1,32}\\z").search(m.engine) == null:
		return "bad engine"
	if typeof(m.packs) != TYPE_DICTIONARY or m.packs.is_empty():
		return "no packs"
	var name_re := RegEx.create_from_string("^[A-Za-z]{1,16}\\z")
	var file_re := RegEx.create_from_string("^[A-Za-z0-9._-]{1,64}\\.pck\\z")
	var hex_re := RegEx.create_from_string("^[0-9a-f]{64}\\z")
	for n in m.packs:
		var p: Variant = m.packs[n]
		if typeof(n) != TYPE_STRING or name_re.search(n) == null or typeof(p) != TYPE_DICTIONARY:
			return "bad pack entry"
		if typeof(p.get("file")) != TYPE_STRING or file_re.search(p.file) == null:
			return "bad file name"
		if typeof(p.get("sha256")) != TYPE_STRING or hex_re.search(p.sha256) == null:
			return "bad sha256"
		var sz: Variant = p.get("size")
		if typeof(sz) not in [TYPE_INT, TYPE_FLOAT] or float(sz) != floorf(float(sz)) or float(sz) <= 0.0 or float(sz) > MAX_PACK:
			return "bad size"
	if typeof(m.sig) != TYPE_STRING or m.sig.length() > 2048:
		return "bad signature"
	var sig := Marshalls.base64_to_raw(m.sig)
	if key == null or sig.is_empty() or not Crypto.new().verify(HashingContext.HASH_SHA256, signed_text(m).sha256_buffer(), sig, key):
		return "signature does not match"
	return ""


## Only release files of this repo, over https, with nothing that could step out of the path.
static func url_ok(u: Variant, prefix: String) -> bool:
	return typeof(u) == TYPE_STRING and u.begins_with(prefix) and u.length() < 512 \
		and not (".." in u or "\\" in u or "@" in u or " " in u)


## What boot does with the installed pack: "mount" it, "discard" it, mark it "bad" (crashed twice, never
## offer it again), or "none" (nothing installed). `base` is the built-in version. (The hash is checked after.)
static func boot_action(inst: Dictionary, base: String, engine: String) -> String:
	if inst.is_empty():
		return "none"
	if not newer(inst.version, base) or inst.engine != engine:
		return "discard"   # a full install caught up, or the engine changed
	if int(inst.tries) >= MAX_TRIES:
		return "bad"
	return "mount"


## installed.json still carries the signed manifest it came from, and the manifest names this pack.
static func installed_ok(inst: Dictionary, k: CryptoKey) -> bool:
	var m: Variant = inst.get("manifest")
	if check_manifest(m, k) != "" or m.version != inst.version or m.engine != inst.engine:
		return false
	var p: Variant = m.packs.get(platform())
	return p is Dictionary and p.sha256 == inst.sha256 and inst.file == "%s-%s" % [m.version, p.file]


static func key() -> CryptoKey:
	var k := CryptoKey.new()
	return k if k.load_from_string(PUBLIC_KEY, true) == OK else null


# ---------------------------------------------------------------- installed pack

static func read_installed() -> Dictionary:
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(INSTALLED)) if FileAccess.file_exists(INSTALLED) else null
	if typeof(d) != TYPE_DICTIONARY or parse_version(d.get("version")).is_empty() or typeof(d.get("engine")) != TYPE_STRING \
			or typeof(d.get("sha256")) != TYPE_STRING or RegEx.create_from_string("^[0-9a-f]{64}\\z").search(d.sha256) == null \
			or typeof(d.get("file")) != TYPE_STRING or RegEx.create_from_string("^[A-Za-z0-9._-]{1,80}\\.pck\\z").search(d.file) == null \
			or typeof(d.get("tries")) not in [TYPE_INT, TYPE_FLOAT]:
		return {}
	return d


static func _write_installed(d: Dictionary) -> bool:
	var f := FileAccess.open(INSTALLED, FileAccess.WRITE)
	return f != null and f.store_string(JSON.stringify(d))


## Forget the installed pack: the game runs the build it shipped with.
static func discard() -> void:
	DirAccess.remove_absolute(INSTALLED)
	_prune("")


## Delete every pack and partial download in user://update/ except `keep`.
static func _prune(keep: String) -> void:
	if not DirAccess.dir_exists_absolute(DIR):
		return
	for f in DirAccess.get_files_at(DIR):
		if f != keep and (f.ends_with(".pck") or f.ends_with(".part")):
			DirAccess.remove_absolute(DIR + f)


func _boot() -> void:
	if not DirAccess.dir_exists_absolute(DIR):
		return
	var inst := read_installed()
	var act := boot_action(inst, current_version(), engine_id())
	if act == "bad":
		var f := FileAccess.open(BAD, FileAccess.WRITE)
		if f:
			f.store_string(inst.version)
	if act != "mount":
		discard()
		return
	var path: String = DIR + inst.file
	_prune(inst.file)   # old packs and partial downloads go before this one is open (Windows locks open files)
	if not installed_ok(inst, key()) or not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != inst.sha256:
		discard()
		return
	inst.tries = int(inst.tries) + 1   # the intro sets it back to 0 (mark_good)
	if not _write_installed(inst):
		discard()   # no crash guard without a counter: run the built-in game
		return
	if not ProjectSettings.load_resource_pack(ProjectSettings.globalize_path(path), true):
		discard()
		return
	ProjectSettings.set_setting("application/config/version", inst.version)   # project.binary is never re-read
	# The engine read these before any autoload: load them again, in place, from the pack.
	var again: Array = [str(ProjectSettings.get_setting("gui/theme/custom", ""))]
	again.append_array(ProjectSettings.get_setting("internationalization/locale/translations", PackedStringArray()))
	for p in again:
		if p != "" and ResourceLoader.exists(p):
			ResourceLoader.load(p, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)


## The version that crashed twice at boot, or "".
static func bad_version() -> String:
	return FileAccess.get_file_as_string(BAD).strip_edges() if FileAccess.file_exists(BAD) else ""


func _relaunch_args(pre: Array) -> PackedStringArray:
	var a := PackedStringArray(pre)
	var ua := OS.get_cmdline_user_args()
	if not ua.is_empty():
		a.append("--")
		a.append_array(ua)
	return a


## The intro calls this: this pack booted fine, so the crash guard starts over.
func mark_good() -> void:
	var inst := read_installed()
	if not inst.is_empty() and inst.version == current_version() and int(inst.tries) != 0:
		inst.tries = 0
		_write_installed(inst)


# ---------------------------------------------------------------- check and download

## Debug builds only: point the updater at a local test server (AKSARAKALA_UPDATE_API / _PREFIX).
func _api() -> String:
	return OS.get_environment("AKSARAKALA_UPDATE_API") if OS.is_debug_build() and OS.has_environment("AKSARAKALA_UPDATE_API") else API


func _prefix(p: String) -> String:
	return OS.get_environment("AKSARAKALA_UPDATE_PREFIX") if OS.is_debug_build() and OS.has_environment("AKSARAKALA_UPDATE_PREFIX") else p


func _to_state(s: int, extra := {}) -> void:
	state = s
	info.merge(extra, true)
	changed.emit()


func _manifest_pack() -> Dictionary:
	return _manifest.get("packs", {}).get(platform(), {})


## Once per launch, from the title screen. Every failure is quiet: play is never blocked.
func check() -> void:
	if _checked or not OS.has_feature("template") or platform() == "" or not load("res://ui/game_settings.gd").check_updates():   # loaded late: a class_name here would pin the built-in copy
		return
	_checked = true
	_to_state(CHECKING)
	var why := await _check()
	if why != "":
		push_warning("updater: " + why)
		_to_state(NONE)


func _check() -> String:
	var body: Variant = await _fetch(_api(), MAX_API, "", ["Accept: application/vnd.github+json"])
	var rel: Variant = JSON.parse_string(body.get_string_from_utf8()) if body is PackedByteArray else null
	if typeof(rel) != TYPE_DICTIONARY or typeof(rel.get("assets")) != TYPE_ARRAY:
		return "no release info"
	var urls := {}   # asset name -> download url, only for urls inside this repo's releases
	for a in rel.assets:
		if typeof(a) == TYPE_DICTIONARY and typeof(a.get("name")) == TYPE_STRING and url_ok(a.get("browser_download_url"), _prefix(ASSET_PREFIX)):
			urls[a.name] = a.browser_download_url
	if not urls.has(MANIFEST):
		return "release has no " + MANIFEST
	var page: String = rel.html_url if url_ok(rel.get("html_url"), _prefix(PAGE_PREFIX)) else PAGE_PREFIX + "latest"
	body = await _fetch(urls[MANIFEST], MAX_JSON)
	var m: Variant = JSON.parse_string(body.get_string_from_utf8()) if body is PackedByteArray else null
	var bad := check_manifest(m, key())
	if bad != "":
		return "manifest rejected: " + bad
	if not newer(m.version, current_version()) or newer(read_installed().get("version"), m.version):
		return ""   # up to date, or a newer pack is already waiting
	if m.version == bad_version():
		return "%s crashed at boot twice: not offered again" % m.version
	var p: Variant = m.packs.get(platform())
	if m.engine != engine_id() or p == null or not urls.has(p.file):
		_to_state(MANUAL, {"version": m.version, "page": page})
		return ""
	_manifest = m
	_pack_url = urls[p.file]
	var inst := read_installed()
	if inst.get("version") == m.version and inst.get("sha256") == p.sha256 and FileAccess.file_exists(DIR + inst.file):
		_to_state(READY, {"version": m.version})
	else:
		_to_state(AVAILABLE, {"version": m.version})
	return ""


func download() -> void:
	if state != AVAILABLE and state != FAILED or _manifest.is_empty():
		return
	var p := _manifest_pack()
	var local := "%s-%s" % [_manifest.version, p.file]   # versioned: never the name of the pack running now
	var part := DIR + local + ".part"
	DirAccess.make_dir_recursive_absolute(DIR)
	DirAccess.remove_absolute(part)
	_to_state(DOWNLOADING, {"progress": 0.0})
	var ok: Variant = await _fetch(_pack_url, int(p.size), part)
	var good: bool = ok != null and _file_size(part) == int(p.size) and FileAccess.get_sha256(part) == p.sha256
	if not good or DirAccess.rename_absolute(part, DIR + local) != OK:
		DirAccess.remove_absolute(part)
		_to_state(FAILED)
		return
	if not _write_installed({"version": _manifest.version, "engine": _manifest.engine, "file": local, "sha256": p.sha256, "tries": 0, "manifest": _manifest}):
		DirAccess.remove_absolute(DIR + local)
		_to_state(FAILED)
		return
	_to_state(READY)


static func _file_size(path: String) -> int:
	var f := FileAccess.open(path, FileAccess.READ)
	return f.get_length() if f else -1


## A fresh copy of the game starts and mounts the new pack at boot.
func restart() -> void:
	if state == READY and OS.create_instance(_relaunch_args([])) > 0:
		get_tree().quit()


func open_page() -> void:
	if state == MANUAL and url_ok(info.get("page"), _prefix(PAGE_PREFIX)):
		OS.shell_open(info.page)


func dismiss() -> void:
	_to_state(NONE)


## GET `url`. Returns the body (or true when `to_file` is set), or null on any failure.
func _fetch(url: String, limit: int, to_file := "", headers: Array = []) -> Variant:
	var h := HTTPRequest.new()
	h.max_redirects = 5
	h.body_size_limit = limit
	h.download_file = to_file
	h.timeout = 0.0 if to_file != "" else 20.0
	add_child(h)
	if to_file != "":
		_http = h
	var res: Array = [HTTPRequest.RESULT_CANT_CONNECT, 0, [], PackedByteArray()]
	if h.request(url, PackedStringArray(["User-Agent: AksaraKala-updater"] + headers)) == OK:
		res = await h.request_completed
	h.queue_free()
	if res[0] != HTTPRequest.RESULT_SUCCESS or res[1] != 200:
		return null
	return true if to_file != "" else res[3]
