class_name SaveStore
extends RefCounted
## Encrypted per-user saves, atomic replacement and one last-known-good backup.
## The local key is NOT a substitute for OS account / disk security.
var root: String
var last_error = ""
var recovered = false

func _init(directory: String = "user://saves") -> void:
	root = directory

func path_for(slot: int) -> String:
	return root.path_join("slot_%d.save" % slot)

func _key() -> String:
	var path = root.path_join("local.key")
	if FileAccess.file_exists(path):
		var existing = FileAccess.get_file_as_string(path).strip_edges()
		return existing if existing.length() == 64 else ""
	# Never silently replace a missing key if encrypted saves already exist.
	for slot in range(1, 4):
		if FileAccess.file_exists(path_for(slot)) or FileAccess.file_exists(path_for(slot) + ".bak"):
			return ""
	var secret = Crypto.new().generate_random_bytes(32).hex_encode()
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(secret)
	file.close()
	FileAccess.set_unix_permissions(path, 384)
	return secret

func exists(slot: int) -> bool:
	return FileAccess.file_exists(path_for(slot)) or FileAccess.file_exists(path_for(slot) + ".bak")

func valid(value: Variant) -> bool:
	if not value is Dictionary or value.get("version", 0) != 1:
		return false
	for key in ["avatar", "traits", "relationship", "emotions"]:
		if not value.get(key) is Dictionary:
			return false
	for key in ["position", "npc_position"]:
		if not value.get(key) is Array or value[key].size() != 3:
			return false
		for item in value[key]:
			if not _number(item) or absf(float(item)) > 10000:
				return false
	for key in ["minutes", "yaw", "pitch", "decisions", "conversations", "boundary_until", "npc_target"]:
		if not _number(value.get(key)):
			return false
	for key in ["memories", "journal", "topics_seen"]:
		if not value.get(key) is Array or value[key].size() > 200:
			return false
	for key in ["mirror_seen", "lamp_on", "door_open", "saved_once", "remember_text"]:
		if not value.get(key) is bool:
			return false
	for key in ["name", "skin", "outfit", "hair"]:
		if not value.avatar.get(key) is String or value.avatar[key].length() > 100:
			return false
	for key in State.TRAITS:
		if not _number(value.traits.get(key)):
			return false
	for key in ["trust", "respect", "familiarity", "tension"]:
		if not _number(value.relationship.get(key)) or value.relationship[key] < 0 or value.relationship[key] > 100:
			return false
	for key in ["joy", "anger", "disappointment", "hope"]:
		if not _number(value.emotions.get(key)) or value.emotions[key] < 0 or value.emotions[key] > 1:
			return false
	for item in value.memories:
		if not item is Dictionary or not item.get("summary") is String or not _number(item.get("minute")) or not _number(item.get("importance")):
			return false
	for item in value.journal:
		if not item is String:
			return false
	for item in value.topics_seen:
		if not item is String:
			return false
	if value.has("chapter") and not valid_chapter(value.chapter):
		return false
	if value.has("relationship_rewards"):
		if not value.relationship_rewards is Array or value.relationship_rewards.size() > 200: return false
		for item in value.relationship_rewards:
			if not item is String or item.length() > 160: return false
	return value.npc_target >= 0 and value.npc_target < 4

func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

func _read(path: String, key: String) -> Dictionary:
	if not FileAccess.file_exists(path) or key.is_empty():
		return {}
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, key)
	if file == null:
		return {}
	if file.get_length() > 2_000_000:
		return {}
	var parser = JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {}
	return parser.data if valid(parser.data) else {}

func save_game(slot: int, value: Dictionary) -> bool:
	last_error = ""
	if slot < 1 or slot > 3 or not valid(value):
		last_error = "Ungültiger Spielstand; nichts überschrieben."
		return false
	var err = DirAccess.make_dir_recursive_absolute(root)
	if err != OK:
		last_error = "Speicherordner nicht beschreibbar."
		return false
	FileAccess.set_unix_permissions(root, 448)
	var key = _key()
	if key.is_empty():
		last_error = "Lokaler Speicherschlüssel fehlt oder ist nicht lesbar."
		return false
	var path = path_for(slot)
	var file = FileAccess.open_encrypted_with_pass(path + ".tmp", FileAccess.WRITE, key)
	if file == null:
		last_error = "Spielstand konnte nicht geschrieben werden."
		return false
	file.store_string(JSON.stringify(value))
	file.close()
	FileAccess.set_unix_permissions(path + ".tmp", 384)
	if _read(path + ".tmp", key).is_empty():
		last_error = "Prüfung der neuen Speicherdatei fehlgeschlagen."
		return false
	if not _read(path, key).is_empty():
		if DirAccess.copy_absolute(path, path + ".bak") != OK:
			last_error = "Sicherung fehlgeschlagen; bisheriger Stand bleibt erhalten."
			return false
	if DirAccess.rename_absolute(path + ".tmp", path) != OK:
		last_error = "Spielstand konnte nicht ersetzt werden."
		return false
	return true

func load_game(slot: int) -> Dictionary:
	last_error = ""
	recovered = false
	if slot < 1 or slot > 3:
		last_error = "Unbekannter Speicherplatz."
		return {}
	var key = _key() if DirAccess.dir_exists_absolute(root) else ""
	var value = _read(path_for(slot), key)
	if value.is_empty():
		value = _read(path_for(slot) + ".bak", key)
		recovered = not value.is_empty()
	if value.is_empty():
		last_error = "Kein lesbarer Spielstand. Datei beschädigt, Version unbekannt oder Schlüssel fehlt."
	return value

func delete_all() -> bool:
	if not DirAccess.dir_exists_absolute(root):
		return true
	var ok = true
	for name in DirAccess.get_files_at(root):
		if name == "local.key" or name.begins_with("slot_"):
			ok = DirAccess.remove_absolute(root.path_join(name)) == OK and ok
	return ok

func valid_chapter(chapter: Variant) -> bool:
	if not chapter is Dictionary: return false
	if chapter.get("stage") not in Chapter.STAGES: return false
	if chapter.get("choice") not in ["", "crop", "share", "private"]: return false
	if chapter.get("approach") not in ["", "conflict"]: return false
	if chapter.get("activity") not in ["", "solo", "tea"]: return false
	if chapter.get("reflection") not in ["", "reflect_boundary", "reflect_connection", "reflect_repair", "reflect_skip"]: return false
	var progress = Chapter.STAGES.find(chapter.stage)
	if progress >= 2 and chapter.choice.is_empty(): return false
	if progress >= 3 and chapter.activity.is_empty(): return false
	if progress == 5 and chapter.reflection.is_empty(): return false
	for key in ["events", "rewards"]:
		if not chapter.get(key) is Array or chapter[key].size() > 32: return false
	for item in chapter.rewards:
		if not item is String or item.length() > 100: return false
	for event in chapter.events:
		if not event is Dictionary: return false
		for key in ["id", "caption", "kind"]:
			if not event.get(key) is String or event[key].length() > 500: return false
		for key in ["minute", "trust", "tension"]:
			if not _number(event.get(key)): return false
		if event.trust < 0 or event.trust > 100 or event.tension < 0 or event.tension > 100: return false
	return true
