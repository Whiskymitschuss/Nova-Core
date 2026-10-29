extends Node3D
var world: Apartment
var player: MetaPlayer
var npc: MetaNPC
var ui: GameUI
var dialog = DialogueManager.new()
var store = SaveStore.new()
var slot = 1
var running = false
var audio_enabled = true
var music: AudioStreamPlayer
var chime: AudioStreamPlayer
var menu_camera: Camera3D
var target: Node3D
var npc_near = false
var autosave = 0.0
var mobile_mode = OS.has_feature("android") or OS.get_cmdline_user_args().has("--touch")
var touch: TouchControls

func _ready() -> void:
	if mobile_mode:
		get_tree().root.content_scale_size = Vector2i(960, 540)
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	setup_inputs()
	world = Apartment.new()
	world.name = "Apartment"
	add_child(world)
	player = MetaPlayer.new()
	player.name = "Player"
	add_child(player)
	player.restore_position()
	npc = MetaNPC.new()
	npc.name = "Mara"
	npc.player = player
	add_child(npc)
	npc.restore_state()
	menu_camera = Camera3D.new()
	menu_camera.position = Vector3(6.3, 2.65, 4.8)
	menu_camera.fov = 74
	menu_camera.cull_mask = 3
	add_child(menu_camera)
	menu_camera.look_at(Vector3(0.0, 1.05, -1.8))
	menu_camera.current = true
	world.player_camera = menu_camera
	player.camera.cull_mask = 3
	world.apply_state(true)
	setup_audio()
	load_settings()
	ui = GameUI.new()
	add_child(ui)
	ui.setup(self)
	if mobile_mode:
		touch = TouchControls.new()
		ui.root.add_child(touch)
		touch.setup(self)
		touch.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().auto_accept_quit = false
	get_tree().quit_on_go_back = false

func setup_inputs() -> void:
	var mapping = {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D,
		"sprint": KEY_SHIFT, "interact": KEY_E, "talk": KEY_F, "pause": KEY_ESCAPE,
		"profile": KEY_TAB, "map": KEY_M, "save": KEY_F5, "load": KEY_F9, "journal": KEY_J}
	for action in mapping:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var key = InputEventKey.new()
		key.physical_keycode = mapping[action]
		InputMap.action_add_event(action, key)

func setup_audio() -> void:
	music = AudioStreamPlayer.new()
	var stream = preload("res://assets/room.ogg") as AudioStreamOggVorbis
	stream.loop = true
	music.stream = stream
	music.volume_db = -20
	add_child(music)
	# No output device means no playback. In particular, do not retain a
	# looping stream in the Dummy driver's unconsumed playback queue.
	if AudioServer.get_driver_name() != "Dummy":
		music.play()
	chime = AudioStreamPlayer.new()
	chime.stream = preload("res://assets/chime.wav")
	chime.volume_db = -12
	add_child(chime)

func _exit_tree() -> void:
	# Release looping playback explicitly before the audio server shuts down.
	if is_instance_valid(music):
		music.stop()
		music.stream = null

func set_controls(value: bool) -> void:
	player.enabled = value and running
	npc.enabled = value and running
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if value and running and not mobile_mode else Input.MOUSE_MODE_VISIBLE
	if is_instance_valid(touch):
		touch.visible = value and running
		if not value:
			touch.reset()

func choose_new_game() -> void:
	for index in range(1, 4):
		if not store.exists(index):
			start_new_game(index)
			return
	var content = ui.open_modal("Neues Spiel · Speicherplatz wählen")
	content.add_child(ui.label("Alle Plätze sind belegt. Wähle bewusst einen Platz: Der alte Stand wird beim Speichern ersetzt.", 16))
	for index in range(1, 4):
		content.add_child(ui.button("Neue Partie auf Platz %d beginnen" % index, func(): start_new_game(index)))

func start_new_game(index: int = 1) -> void:
	var avatar = State.data.avatar.duplicate()
	State.reset()
	State.data.avatar = avatar
	slot = index
	begin_play()
	ui.toast(("Willkommen, %s. Links bewegen, rechts wischen. Sprich mit Mara. Sie hat eine Bitte." if mobile_mode else "Willkommen, %s. Sprich Mara mit F an. Sie hat eine Bitte.") % State.data.avatar.name)

func begin_play() -> void:
	running = true
	autosave = 0
	ui.close_modal(false)
	ui.clear_menu()
	ui.close_dialogue()
	ui.hud.show()
	player.restore_position()
	npc.restore_state()
	world.apply_state(true)
	player.camera.current = true
	world.player_camera = player.camera
	set_controls(true)

func continue_game() -> void:
	load_game(slot)

func save_game(index: int = -1, quiet: bool = false) -> bool:
	if not running:
		return false
	if index == -1:
		index = slot
	player.capture_state()
	npc.capture_state()
	var saved_before: bool = State.data.saved_once
	State.data.saved_once = true
	if not store.save_game(index, State.snapshot()):
		State.data.saved_once = saved_before
		ui.toast(store.last_error)
		return false
	slot = index
	autosave = 0
	if not quiet: ui.toast("Fortschritt auf Platz %d gespeichert." % slot)
	return true

func load_game(index: int = -1) -> bool:
	if index == -1:
		index = slot
	var value = store.load_game(index)
	if value.is_empty():
		ui.toast(store.last_error)
		return false
	State.restore(value)
	slot = index
	begin_play()
	ui.toast("Sicherungskopie wiederhergestellt." if store.recovered else "Spielstand geladen.")
	return true

func return_to_menu() -> void:
	if running and not save_game():
		return
	ui.close_dialogue()
	ui.close_modal(false)
	running = false
	set_controls(false)
	menu_camera.current = true
	world.player_camera = menu_camera
	ui.show_menu()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_instance_valid(ui):
		handle_back()
	elif what == NOTIFICATION_APPLICATION_PAUSED and running and is_instance_valid(ui):
		# Android may kill a background process without sending a close event.
		save_game()
		ui.show_pause()
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if running and not save_game():
			ui.show_pause()
			return
		get_tree().quit()

func can_reach(point: Vector3) -> bool:
	var query = PhysicsRayQueryParameters3D.create(player.global_position + Vector3(0, 1.3, 0), point, 1)
	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.position.distance_to(point) < 0.45

func update_targets() -> void:
	target = null
	var closest = 2.2
	for object in world.objects:
		var distance = player.position.distance_to(object.position)
		if distance < closest and can_reach(object.global_position):
			closest = distance
			target = object
	npc_near = npc.visible and player.position.distance_to(npc.position) < 2.6 and can_reach(npc.global_position + Vector3(0, 1.3, 0))
	var text = ("Benutzen  ·  " if mobile_mode else "E  ·  ") + str(target.get_meta("label")) if target != null else ""
	if npc_near:
		text += ("\n" if not text.is_empty() else "") + ("Reden  ·  Mit Mara sprechen" if mobile_mode else "F  ·  Mit Mara sprechen")
	ui.prompt.text = text

func _process(delta: float) -> void:
	if not running:
		return
	if player.enabled:
		State.tick(delta)
		autosave += delta
		if autosave >= 120:
			save_game()
			# Failed autosaves should not retry every frame.
			autosave = 0
		update_targets()
	else:
		ui.prompt.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("pause"):
		handle_back()
		get_viewport().set_input_as_handled()
		return
	if not running or not player.enabled:
		return
	if event.is_action_pressed("talk") and npc_near:
		start_dialogue("Mara")
	elif event.is_action_pressed("interact") and target != null:
		interact(str(target.get_meta("kind")))
	elif event.is_action_pressed("profile"):
		ui.show_profile()
	elif event.is_action_pressed("map"):
		ui.show_map()
	elif event.is_action_pressed("journal"):
		ui.show_memories()
	elif event.is_action_pressed("save"):
		save_game()
	elif event.is_action_pressed("load"):
		load_game()

func handle_back() -> void:
	if is_instance_valid(ui.dialogue):
		end_dialogue()
	elif is_instance_valid(ui.modal):
		ui.close_modal()
	elif running:
		ui.show_pause()

func interact(kind: String) -> void:
	var stage_before = Chapter.state().stage
	if AudioServer.get_driver_name() != "Dummy":
		chime.play()
	match kind:
		"mirror": start_dialogue("META ME")
		"door":
			State.data.door_open = not State.data.door_open
			world.apply_state()
		"lamp":
			State.data.lamp_on = not State.data.lamp_on
			world.apply_state()
		"computer":
			if Chapter.state().stage == "review": ui.show_photo()
			else: ui.show_chapter()
		"phone": ui.show_chapter()
		"tea":
			State.data.minutes += 20
			if Chapter.act("tea"):
				world.apply_state()
				ui.show_evening()
			else: ui.toast("Du bereitest einen Tee zu. Zwanzig ruhige Minuten vergehen.")
		"bed":
			State.data.minutes += 60
			ui.toast("Du ruhst dich aus. Eine Stunde vergeht.")
		"sofa":
			State.data.minutes += 10
			if Chapter.act("sofa"):
				world.apply_state()
				ui.show_evening()
			else: ui.toast("Du nimmst dir zehn Minuten ohne Verpflichtungen.")
		"balcony": start_dialogue("META ME")
	if Chapter.state().stage != stage_before: save_game(-1, true)

func start_dialogue(who: String) -> void:
	var opening = dialog.begin(who)
	npc.talking = who == "Mara" and dialog.active
	ui.show_dialogue(opening)

func answer(text: String, intent: String = "free") -> void:
	if text.strip_edges().is_empty():
		ui.toast("Schreibe eine Antwort oder wähle einen Vorschlag.")
		return
	var stage_before = Chapter.state().stage
	ui.show_dialogue(dialog.answer(text, intent))
	if Chapter.state().stage != stage_before: save_game(-1, true)
	world.apply_state()
	npc.talking = dialog.speaker == "Mara" and dialog.active

func end_dialogue() -> void:
	ui.close_dialogue()
	set_controls(true)

func clear_memories() -> void:
	State.data.memories.clear()
	State.data.journal.clear()
	State.data.chapter.events.clear()
	var errors = 0
	for index in range(1, 4):
		if not store.exists(index):
			continue
		var value = store.load_game(index)
		if value.is_empty():
			errors += 1
			continue
		value.memories = []
		value.journal = []
		if value.has("chapter"): value.chapter.events = []
		if not store.save_game(index, value):
			errors += 1
		else:
			# Both generations must be scrubbed: save twice to replace the backup too.
			if not store.save_game(index, value):
				errors += 1
	ui.show_memories()
	ui.toast("Einträge gelöscht." if errors == 0 else "Einige Dateien nicht löschbar. Bitte über 'Alle Daten löschen' entfernen.")

func delete_all_data() -> void:
	if not store.delete_all():
		ui.toast("Nicht alle Dateien konnten gelöscht werden.")
		return
	State.reset()
	running = false
	ui.close_modal(false)
	ui.close_dialogue()
	set_controls(false)
	menu_camera.current = true
	world.player_camera = menu_camera
	ui.show_menu()
	ui.toast("Alle lokalen Spielstände und persönlichen Einträge gelöscht.")

func set_audio(value: bool) -> void:
	audio_enabled = value
	AudioServer.set_bus_mute(0, not value)
	save_settings()

func set_quality(high: bool) -> void:
	world.low_quality = not high
	world.sun.shadow_enabled = high
	world.lamp.shadow_enabled = high
	world.mirror_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS if high else SubViewport.UPDATE_DISABLED
	world.mirror.visible = true
	world.mirror.material_override = world.mirror_live_material if high else world.mat("mobileMirror", "759ca2", 0.15, 0.85)
	save_settings()

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("preferences", "audio", audio_enabled)
	config.set_value("preferences", "high_quality", not world.low_quality)
	config.set_value("preferences", "sensitivity", player.sensitivity)
	config.set_value("preferences", "remember_text", State.remember_text)
	config.save("user://settings.cfg")

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		if mobile_mode:
			set_quality(false)
		return
	audio_enabled = config.get_value("preferences", "audio", true)
	AudioServer.set_bus_mute(0, not audio_enabled)
	player.sensitivity = clampf(float(config.get_value("preferences", "sensitivity", 0.0025)), 0.001, 0.006)
	State.remember_text = config.get_value("preferences", "remember_text", false)
	set_quality(config.get_value("preferences", "high_quality", not mobile_mode))
