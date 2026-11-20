extends SceneTree
## Auto-update checks with no network (architecture.md 13b): version order, manifest signature,
## tampering, URL allowlist, crash guard, and that editor/test runs never mount or check.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _sign(m: Dictionary, U: GDScript, k: CryptoKey) -> Dictionary:
	m.sig = Marshalls.raw_to_base64(Crypto.new().sign(HashingContext.HASH_SHA256, U.signed_text(m).sha256_buffer(), k))
	return m


func _manifest() -> Dictionary:
	return {"version": "1.2.0", "engine": "4.7.2.stable", "packs": {
		"macOS": {"file": "AksaraKala-macos.pck", "size": 1000, "sha256": "a".repeat(64)},
		"Windows": {"file": "AksaraKala-windows.pck", "size": 2000, "sha256": "b".repeat(64)}}}


func _initialize() -> void:
	await process_frame
	var U: GDScript = load("res://autoload/updater.gd")
	var up: Node = root.get_node("Updater")

	# version order
	check(U.newer("1.10.0", "1.9.0"), "1.10.0 > 1.9.0")
	check(not U.newer("1.1.0", "1.1.0"), "equal is not newer")
	check(not U.newer("1.0.9", "1.1.0"), "older is not newer")
	check(not U.newer("1.2", "1.1.0") and not U.newer(1.2, "1.0.0"), "malformed versions are never newer")
	check(U.parse_version(str(ProjectSettings.get_setting("application/config/version", ""))).size() == 3, "project.godot has config/version n.n.n")
	check(U.key() != null, "the embedded public key loads")

	# signatures: a throwaway key signs, its public half verifies
	var crypto := Crypto.new()
	var k := crypto.generate_rsa(2048)
	var pub := CryptoKey.new()
	pub.load_from_string(k.save_to_string(true), true)
	var good := _sign(_manifest(), U, k)
	check(U.check_manifest(good, pub) == "", "a signed manifest is accepted: " + U.check_manifest(good, pub))
	check(U.check_manifest(good, U.key()) != "", "a manifest signed by another key is rejected")
	var t := good.duplicate(true)
	t.packs.macOS.sha256 = "c".repeat(64)
	check(U.check_manifest(t, pub) != "", "a tampered hash is rejected")
	t = good.duplicate(true)
	t.packs.Windows.size = 2001
	check(U.check_manifest(t, pub) != "", "a tampered size is rejected")
	t = good.duplicate(true)
	t.version = "9.9.9"
	check(U.check_manifest(t, pub) != "", "a tampered version is rejected")
	t = good.duplicate(true)
	t.sig = "bm9wZQ=="
	check(U.check_manifest(t, pub) != "", "a bad signature is rejected")
	t = _sign(_manifest(), U, k)
	t.packs.macOS.file = "../../evil.pck"
	check(U.check_manifest(_sign(t, U, k), pub) == "bad file name", "a path in the file name is rejected even when signed")
	t = _manifest()
	t.packs.macOS.size = -5
	check(U.check_manifest(_sign(t, U, k), pub) == "bad size", "a negative size is rejected")
	check(U.check_manifest("[]", pub) != "" and U.check_manifest({}, pub) != "", "junk is rejected")
	var parsed: Variant = JSON.parse_string(JSON.stringify(good))   # sizes come back as floats from JSON
	check(U.check_manifest(parsed, pub) == "", "a manifest survives a JSON round trip")

	# url allowlist
	check(U.url_ok("https://github.com/enclaireee/AksaraKala/releases/download/v1.2.0/AksaraKala-update.json", U.ASSET_PREFIX), "a release asset url is allowed")
	for bad in ["http://github.com/enclaireee/AksaraKala/releases/download/x", "https://github.com.evil.io/enclaireee/AksaraKala/releases/download/x",
			"https://github.com/someone/AksaraKala/releases/download/x", "https://github.com/enclaireee/AksaraKala/releases/download/../../x", 42]:
		check(not U.url_ok(bad, U.ASSET_PREFIX), "url rejected: %s" % [bad])

	# boot mount and crash guard
	var e: String = U.engine_id()
	var inst := {"version": "1.2.0", "engine": e, "file": "1.2.0-AksaraKala-macos.pck", "sha256": "a".repeat(64), "tries": 0}
	check(U.boot_action(inst, "1.1.0", e) == "mount", "a newer pack mounts")
	inst.tries = 1
	check(U.boot_action(inst, "1.1.0", e) == "mount", "one failed boot still mounts")
	inst.tries = 2
	check(U.boot_action(inst, "1.1.0", e) == "bad", "two failed boots mark the pack bad")
	inst.tries = 0
	check(U.boot_action(inst, "1.2.0", e) == "discard", "a full install of the same version discards the pack")
	check(U.boot_action(inst, "1.3.0", e) == "discard", "a newer full install discards the old pack")
	inst.engine = "4.8.0.stable"
	check(U.boot_action(inst, "1.1.0", e) == "discard", "a pack for another engine is discarded")
	check(U.boot_action({}, "1.1.0", e) == "none", "nothing installed")
	check(e.ends_with(".b%d" % U.BASE), "engine_id carries the boot-settings BASE")

	# boot re-checks the signed manifest stored in installed.json
	var sm := _sign(_manifest(), U, k)
	sm.engine = "4.7.2.stable"
	var pk: Dictionary = sm.packs.get(U.platform(), sm.packs.macOS)
	var mine := {"version": "1.2.0", "engine": sm.engine, "file": "1.2.0-" + pk.file, "sha256": pk.sha256, "tries": 0, "manifest": JSON.parse_string(JSON.stringify(sm))}
	check(U.installed_ok(mine, pub), "an installed pack with its signed manifest passes")
	var x := mine.duplicate(true)
	x.sha256 = "e".repeat(64)
	check(not U.installed_ok(x, pub), "a planted pack hash that the manifest does not sign fails")
	x = mine.duplicate(true)
	x.erase("manifest")
	check(not U.installed_ok(x, pub), "an installed.json without a manifest fails")
	x = mine.duplicate(true)
	x.manifest.sig = "bm9wZQ=="
	check(not U.installed_ok(x, pub), "a forged manifest fails")
	x = mine.duplicate(true)
	x.file = "1.2.0-other.pck"
	check(not U.installed_ok(x, pub), "a file the manifest does not name fails")

	# a trailing newline never slips past an anchored pattern
	check(U.parse_version("1.2.0\n").is_empty(), "a version with a newline is malformed")
	t = _manifest()
	t.packs.macOS.file = "AksaraKala-macos.pck\n"
	check(U.check_manifest(_sign(t, U, k), pub) == "bad file name", "a file name with a newline is rejected")

	# editor and test runs never check or hand off
	up.check()
	check(up.state == up.IDLE, "check() does nothing outside an exported build")

	quit(1 if fails > 0 else 0)
