extends Node
## Runs the real scene, physics and UI. Never touches real player saves.
var checks = 0
var failures = 0
var game: Node3D
var test_root = "user://test_run_%d" % Time.get_ticks_usec()
var capture_directory = ""

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func frames(count: int = 4) -> void:
	for i in range(count):
		await get_tree().physics_frame

func capture(name: String) -> void:
	if capture_directory.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	check(image.save_png(capture_directory.path_join(name + ".png")) == OK, "Screenshot " + name)

func finger(index: int, point: Vector2, pressed: bool) -> void:
	var event = InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	get_viewport().push_input(event, true)

func drag(index: int, point: Vector2, relative: Vector2) -> void:
	var event = InputEventScreenDrag.new()
	event.index = index
	event.position = point
	event.relative = relative
	get_viewport().push_input(event, true)

func test_touch() -> void:
	check(is_instance_valid(game.touch) and game.touch.visible, "Touch controls are available during gameplay")
	check(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED, "Touch mode does not capture a mouse")
	var start: Vector3 = game.player.position
	var origin: Vector2 = game.touch.origin
	finger(0, origin, true)
	drag(0, origin + Vector2(0, -60), Vector2(0, -60))
	await frames(20)
	check(game.player.position.distance_to(start) > 0.3, "Virtual joystick moves the real physics character")
	var before = game.player.pivot.rotation.y
	var point: Vector2 = Vector2(game.touch.size.x * 0.55, game.touch.size.y * 0.45)
	finger(1, point, true)
	drag(1, point + Vector2(50, 0), Vector2(50, 0))
	check(not is_equal_approx(game.player.pivot.rotation.y, before), "A second finger rotates the third-person camera")
	check(game.player.touch_move.length() > 0.5, "Looking does not cancel the first finger's movement")
	finger(1, point, false)
	finger(0, origin, false)
	check(game.player.touch_move == Vector2.ZERO and game.touch.look_finger == -1, "Releasing fingers clears movement and camera ownership")
	# Real TouchScreenButton signal routing, independent of mouse emulation.
	var menu_point: Vector2 = game.touch.buttons.menu.position + Vector2(48, 48)
	finger(2, menu_point, true)
	await get_tree().process_frame
	finger(2, menu_point, false)
	check(is_instance_valid(game.ui.modal) and not game.player.enabled, "Touch menu button opens pause")
	check(game.player.touch_move == Vector2.ZERO and not game.touch.visible, "Opening a panel cancels all held touch controls")
	game._notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await frames(2)
	check(game.player.enabled and game.touch.visible, "Android Back closes pause and restores gameplay")
	game.player.position = start
	game.player.pivot.rotation.y = 0

func _ready() -> void:
	var args = OS.get_cmdline_user_args()
	for i in range(args.size() - 1):
		if args[i] == "--capture":
			capture_directory = args[i + 1]
			DirAccess.make_dir_recursive_absolute(capture_directory)
	call_deferred("run")

func run() -> void:
	State.reset()
	game = preload("res://scenes/main.tscn").instantiate()
	add_child(game)
	game.store = SaveStore.new(test_root)
	game.dialog.chapter_mode = false
	await frames(8)
	check(game.ui.menu.visible and not game.player.enabled, "Main menu starts; controls are suspended")
	await capture("01-main-menu")
	game.ui.menu.find_child("NewGame", true, false).pressed.emit()
	await frames(8)
	check(game.running and game.player.camera.current and game.player.enabled, "New game button starts third-person scene")
	check(game.world.navigation.navigation_mesh.get_polygon_count() > 0, "Runtime navigation mesh has walkable polygons")
	check(game.world.objects.size() >= 9, "Furnished apartment has discoverable interactive objects")
	check(game.npc.model.get_child_count() > 0, "Animated NPC model exists in live world")
	# Let the actual navigation agent move along a path, not merely exist.
	var npc_start: Vector3 = game.npc.position
	game.npc.agent.target_position = Vector3(5.2, 0, 3.6)
	game.npc.wait_time = 0
	await frames(120)
	if game.npc.position.distance_to(npc_start) <= 0.6:
		print("NAV DIAG: start=", npc_start, " end=", game.npc.position, " enabled=", game.npc.enabled,
			" map_iteration=", NavigationServer3D.map_get_iteration_id(game.npc.agent.get_navigation_map()),
			" target=", game.npc.agent.target_position, " path=", game.npc.agent.get_current_navigation_path(),
			" next=", game.npc.agent.get_next_path_position())
	check(game.npc.position.distance_to(npc_start) > 0.6, "NPC follows a navigation path instead of standing permanently still")
	check(absf(game.npc.position.y) < 0.12, "NPC patrol stays on the apartment floor")
	game.npc.restore_state()
	game.npc.wait_time = 1000
	if game.mobile_mode:
		await test_touch()
	var start: Vector3 = game.player.position
	Input.action_press("move_forward")
	await frames(35)
	Input.action_release("move_forward")
	await frames(6)
	check(game.player.position.distance_to(start) > 0.7, "WASD input moves the physics body")
	check(absf(game.player.position.y) < 0.12, "Floor collision keeps player above ground")
	# A sustained move into the back wall must stop at its collider.
	game.player.position = Vector3(-0.8, 0.05, -4.7)
	game.player.velocity = Vector3.ZERO
	game.player.pivot.rotation.y = 0
	Input.action_press("move_forward")
	await frames(70)
	Input.action_release("move_forward")
	check(game.player.position.z > -5.72, "Solid wall blocks sustained movement")
	# Camera boom collides with the front wall behind the player.
	game.player.position = Vector3(0.8, 0.05, 5.35)
	await frames(8)
	check(game.player.arm.get_hit_length() < 1.0, "SpringArm retracts at wall, preventing camera clipping")
	game.player.position = Vector3(-0.5, 0.05, -3)
	game.player.pivot.rotation.y = 0
	Input.action_press("move_left")
	await frames(55)
	Input.action_release("move_left")
	await frames(5)
	check(game.player.position.x < -2.5, "Bedroom doorway is physically traversable")
	game.player.position = Vector3(-0.5, 0.05, 2.7)
	Input.action_press("move_left")
	await frames(55)
	Input.action_release("move_left")
	await frames(5)
	check(game.player.position.x < -2.5, "Bathroom doorway is physically traversable")
	# Mirror interaction starts the central mechanic, no moral/personality claim.
	game.player.position = Vector3(-0.5, 0.05, 0.9)
	await frames(5)
	check(game.target != null and game.target.get_meta("kind") == "mirror", "Mirror is discoverable through normal interaction targeting")
	var interaction = InputEventKey.new()
	interaction.physical_keycode = KEY_E
	interaction.pressed = true
	Input.parse_input_event(interaction)
	await get_tree().process_frame
	await get_tree().process_frame
	await frames(3)
	interaction = InputEventKey.new()
	interaction.physical_keycode = KEY_E
	interaction.pressed = false
	Input.parse_input_event(interaction)
	check(State.data.mirror_seen and game.dialog.speaker == "META ME", "Interactive mirror introduces META ME")
	check(not game.player.enabled and is_instance_valid(game.ui.dialogue), "Dialogue UI releases mouse and suspends movement")
	if not is_instance_valid(game.ui.dialogue):
		print("RESULT: %d checks, %d failures (required interaction failed)" % [checks, failures])
		game.store.delete_all()
		get_tree().quit(1)
		return
	if game.mobile_mode:
		await get_tree().process_frame
		check(not game.touch.visible, "Dialogue hides all gameplay touch buttons")
		check(game.ui.dialogue.get_global_rect().end.y <= game.ui.root.size.y + 1, "Mobile dialogue fits the viewport height")
		check(game.ui.free_text.get_global_rect().end.y <= game.ui.root.size.y + 1, "Mobile free-text entry remains on screen")
	game.ui.free_text.text = "Ich möchte in Ruhe ankommen."
	game.ui.free_text.text_submitted.emit(game.ui.free_text.text)
	check(State.data.journal.is_empty(), "Private free-text storage is opt-in")
	game.end_dialogue()
	await frames(3)
	check(game.player.enabled, "Ending a conversation restores controls")
	# Check all six situational openers independently of the display.
	var generator = DialogueGenerator.new()
	var base = ContextManager.new().gather("Mara", "Apartment")
	base.conversations = 0
	check(generator.opening(base).topic == "arrival", "Arrival opener")
	base.conversations = 1
	base.mirror = true
	State.data.topics_seen = []
	check(generator.opening(base).topic == "mirror", "Mirror opener")
	State.data.topics_seen = ["mirror"]
	base.hour = 19
	check(generator.opening(base).topic == "evening", "Evening opener")
	base.hour = 12
	base.history = "Eine frühere Begegnung"
	base.conversations = 2
	check(generator.opening(base).topic == "memory", "Memory opener")
	base.conversations = 3
	check(generator.opening(base).topic == "connection", "Interests opener")
	base.relationship.tension = 15
	check(generator.opening(base).topic == "conflict", "Conflict opener")
	# Real NPC UI and buttons update shared state and memory.
	State.data.relationship.tension = 0
	game.player.position = Vector3(2.7, 0.05, 1.0)
	game.player.pivot.rotation.y = 0.4
	await frames(5)
	check(game.npc_near, "NPC conversation discovered within range with line of sight")
	game.start_dialogue("Mara")
	var trust = State.data.relationship.trust
	var first = game.ui.response_buttons[0].text
	game.ui.response_buttons[0].pressed.emit()
	await frames(3)
	check(State.data.relationship.trust > trust, "Friendly response button changes trust")
	check(not State.data.memories.is_empty(), "Conversation records a prioritized memory")
	check(game.ui.response_buttons[0].text != first, "Response suggestions change with conversation turn")
	game.ui.free_text.text = "Fotografierst du gern?"
	game.ui.free_text.text_submitted.emit(game.ui.free_text.text)
	check(game.ui.speech.text.contains("fotografiere"), "Free text gets a contextual generated reply")
	await capture("02-conversation")
	game.answer("Idiot", "free")
	game.answer("Idiot", "free")
	game.answer("Idiot", "free")
	check(not game.dialog.active and State.data.boundary_until > State.data.minutes, "Repeated insults trigger an NPC boundary and cooldown")
	var tense = State.data.relationship.tension
	game.end_dialogue()
	game.start_dialogue("Mara")
	check(not game.dialog.active, "Cooldown cannot be bypassed by reopening dialogue")
	game.end_dialogue()
	State.data.minutes += 13
	game.start_dialogue("Mara")
	game.answer("Tut mir leid.")
	check(State.data.relationship.tension > 0 and State.data.relationship.tension < tense, "Apology reduces tension without instant reconciliation")
	check(ResponseGenerator.new().classify("Du bist nicht dumm.") != "confrontational", "Conservative free-text rule handles a negation")
	game.end_dialogue()
	# Repetition cannot farm trust indefinitely in a session.
	State.data.relationship.tension = 0
	game.start_dialogue("Mara")
	game.answer("Danke", "friendly")
	var once = State.data.relationship.trust
	for i in range(12):
		game.answer("Danke", "friendly")
	check(is_equal_approx(State.data.relationship.trust, once), "Repeating the same response does not farm trust")
	game.end_dialogue()
	game.interact("door")
	await frames(45)
	check(State.data.door_open and absf(game.world.door.rotation.y) > 1.0, "Interactive balcony door animates its actual collider")
	game.player.position = Vector3(3, 0.05, 5.0)
	game.player.pivot.rotation.y = 0
	Input.action_press("move_back")
	await frames(65)
	Input.action_release("move_back")
	check(game.player.position.z > 6.4, "Open doorway leads to a walkable balcony")
	game.player.position = Vector3(3, 0.05, 8.5)
	Input.action_press("move_back")
	await frames(40)
	Input.action_release("move_back")
	check(game.player.position.z < 8.8, "Balcony railing prevents falling out of the world")
	game.interact("lamp")
	check(not game.world.lamp.visible, "Lamp interaction changes illumination")
	var clock = State.data.minutes
	game.interact("tea")
	check(State.data.minutes >= clock + 20, "Tea interaction advances world time")
	# Validated encrypted save, backup recovery and persistent world state.
	game.player.position = Vector3(0.8, 0.05, 2.8)
	State.remember_text = true
	game.start_dialogue("META ME")
	game.answer("Eine persönliche Testnotiz.")
	game.end_dialogue()
	check(game.save_game(1), "Manual save writes a validated encrypted slot")
	var saved = State.snapshot()
	check(not FileAccess.get_file_as_bytes(game.store.path_for(1)).hex_encode().contains("Testnotiz".to_utf8_buffer().hex_encode()), "Saved personal text is not plaintext")
	State.data.relationship.trust = 98
	game.player.position = Vector3(5, 0.1, 5)
	check(game.load_game(1), "Saved game loads through controller")
	check(is_equal_approx(State.data.relationship.trust, saved.relationship.trust), "Load restores relationship values")
	check(game.player.position.distance_to(Vector3(saved.position[0], saved.position[1], saved.position[2])) < 0.01, "Load restores player position")
	check(State.data.journal.has("Eine persönliche Testnotiz."), "Opt-in reflection survives encrypted save/load")
	check(State.data.door_open and not State.data.lamp_on, "Load restores interactive world state")
	check(game.save_game(1), "Repeated save creates a backup")
	var key = FileAccess.get_file_as_string(test_root.path_join("local.key"))
	var corrupt = FileAccess.open_encrypted_with_pass(game.store.path_for(1), FileAccess.WRITE, key)
	corrupt.store_string('{"version":999}')
	corrupt.close()
	var recovered = game.store.load_game(1)
	check(not recovered.is_empty() and game.store.recovered, "Unsupported or damaged primary save recovers last-known-good backup")
	var invalid = saved.duplicate(true)
	invalid.position = ["bad", 0, 0]
	check(not game.store.save_game(2, invalid), "Malformed save data is rejected before writing")
	# UI views must build without errors and release controls correctly.
	for view in [game.ui.show_profile, game.ui.show_map, game.ui.show_avatar, game.ui.show_settings, game.ui.show_slots, game.ui.show_memories]:
		view.call()
		await frames(2)
		check(is_instance_valid(game.ui.modal) and not game.player.enabled, "In-game panel opens: " + str(view.get_method()))
		game.ui.close_modal()
		await frames(2)
	# Privacy deletion must scrub both generations, not just the current save.
	if game.mobile_mode:
		game._notification(NOTIFICATION_APPLICATION_PAUSED)
		check(game.store.exists(game.slot) and not game.player.enabled, "Android background notification saves progress and pauses")
		game._notification(NOTIFICATION_WM_GO_BACK_REQUEST)
		await frames(2)
	game.clear_memories()
	await frames(3)
	check(game.store.load_game(1).journal.is_empty(), "Privacy deletion scrubs current encrypted save")
	check(game.store._read(game.store.path_for(1) + ".bak", key).journal.is_empty(), "Privacy deletion scrubs backup too")
	game.ui.close_modal()
	game.player.position = Vector3(0.8, 0.05, 2.8)
	await frames(5)
	await capture("03-apartment")
	await test_chapter()
	game.return_to_menu()
	await frames(3)
	check(not game.running and game.ui.menu.visible, "Save-and-return restores main menu")
	# Avoid the synthetic room audio / generated scene being held during shutdown.
	check(game.store.delete_all(), "All test slots, backups and key can be deleted")
	DirAccess.remove_absolute(test_root)
	game.queue_free()
	await frames(4)
	print("RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func test_chapter() -> void:
	game.dialog.chapter_mode = true
	# Exercise every authored ending through actual UI/controller actions.
	for route in ["crop", "private", "share"]:
		game.start_new_game(1)
		await frames(3)
		check(Chapter.state().stage == "invitation", "Chapter starts with Mara's concrete request")
		game.start_dialogue("Mara")
		game.answer("Vielleicht, aber bitte noch nichts veröffentlichen.")
		check(Chapter.state().stage == "invitation" and Chapter.state().choice.is_empty(), "Ambiguous free text never grants permission or changes stage")
		game.end_dialogue()
		game.start_dialogue("Mara")
		if route == "private":
			game.answer("Meine Wohnung soll privat bleiben.", "invite_boundary")
			check(Chapter.state().stage == "agreement" and Chapter.state().choice == "private", "A boundary creates a valid route without forcing image inspection")
		else:
			game.answer("Zeig mir bitte erst das Foto.", "invite_review")
			check(Chapter.state().stage == "review" and not game.dialog.active, "Invitation ends with a concrete destination, not an endless loop")
			game.end_dialogue()
			game.interact("computer")
			await frames(3)
			check(is_instance_valid(game.ui.modal) and not game.player.enabled, "Computer opens the actual image inspection UI")
			if route == "share":
				game.ui.confirm_original()
				check(Chapter.state().choice.is_empty(), "Original photo requires an explicit second decision")
			game.ui.decide_photo(route)
			check(Chapter.state().stage == "agreement" and Chapter.state().choice == route, "Image choice persists: " + route)
			check(not Chapter.choose_photo("private"), "A completed photo decision cannot be silently overwritten")
			game.ui.close_modal()
		game.end_dialogue()
		var before = State.data.relationship.trust
		game.start_dialogue("Mara")
		game.end_dialogue()
		game.start_dialogue("Mara")
		check(State.data.relationship.trust == before, "Reopening the authored conversation never farms trust")
		game.answer("Heute brauche ich Ruhe." if route == "private" else "Lass uns Tee trinken.", "agree_solo" if route == "private" else "agree_tea")
		check(Chapter.state().stage == "action", "Conversation creates a physical activity: " + route)
		game.end_dialogue()
		game.interact("tea" if route == "private" else "sofa")
		check(Chapter.state().stage == "action", "An unrelated object does not complete the agreement")
		game.interact("sofa" if route == "private" else "tea")
		await frames(3)
		check(Chapter.state().stage == "reflection", "The agreed world interaction advances the story")
		check(game.npc.visible == (route != "private"), "Choosing solitude results in Mara actually leaving the apartment")
		check(game.world.tea_setting.visible == (route != "private"), "Shared tea has a visible world consequence")
		game.ui.close_modal()
		check(game.save_game(1), "Chapter progress passes encrypted save validation")
		var snapshot = State.snapshot()
		State.reset()
		check(game.load_game(1) and Chapter.state().choice == route and Chapter.state().stage == "reflection", "Reload resumes exact choice and next objective")
		game.start_dialogue("META ME")
		game.answer("Ich bin nicht sicher.")
		check(Chapter.state().stage == "reflection", "Unknown reflection does not invent a personal interpretation")
		game.answer("Meine Grenze ist mir wichtig.", "reflect_boundary")
		check(Chapter.state().stage == "complete" and not game.dialog.active, "Reflection reaches a finite chapter ending: " + route)
		check(Chapter.state().events.back().trust == State.data.relationship.trust, "Diagram endpoint comes from the real saved relationship")
		var count = Chapter.state().events.size()
		game.end_dialogue()
		game.start_dialogue("Mara")
		game.answer("Was bleibt?", "epilogue")
		check(Chapter.state().events.size() == count, "Epilogue remembers the outcome without duplicating decisions")
		game.end_dialogue()
		game.ui.show_chapter()
		await frames(3)
		if route == "crop": await capture("04-chapter-outcome")
		game.ui.show_profile()
		await frames(3)
		var chart = game.ui.modal.find_child("Diagram_relationship", true, false)
		var tap = InputEventMouseButton.new()
		tap.pressed = true
		tap.position = Vector2(55, 90)
		chart._gui_input(tap)
		check(chart.selected == 0, "Relationship diagram accepts point selection")
		if route == "crop": await capture("05-story-diagrams")
		game.ui.show_map()
		await frames(3)
		if route == "crop": await capture("06-apartment-map")
		game.ui.close_modal()
		var invalid = snapshot.duplicate(true)
		invalid.chapter.stage = "unknown"
		check(not game.store.valid(invalid), "Unknown chapter state is rejected")
		invalid = snapshot.duplicate(true)
		invalid.chapter.events[0].trust = "bad"
		check(not game.store.valid(invalid), "Corrupted diagram samples are rejected before loading")
	game.start_new_game(1)
	game.start_dialogue("Mara")
	game.answer("Du hast nicht gefragt.", "invite_conflict")
	game.answer("Das bleibt privat.", "invite_boundary")
	game.answer("Tut mir leid.", "agree_apology")
	check(Chapter.state().activity == "tea" and State.data.relationship.tension > 0, "Repair route acknowledges conflict without instant forgiveness")
	game.end_dialogue()
	game.interact("tea")
	game.ui.close_modal()
	check(Chapter.skip_reflection() and Chapter.state().stage == "complete", "Reflection remains optional and still permits chapter completion")
	game.start_new_game(1)
	game.start_dialogue("Mara")
	for i in range(3): game.answer("Idiot")
	check(not game.dialog.active and State.data.boundary_until > State.data.minutes, "Authored chapter also enforces boundaries for repeated free-text insults")
	game.end_dialogue()
	game.start_dialogue("Mara")
	check(not game.dialog.active, "Chapter cooldown survives reopening")
	game.end_dialogue()
	State.data.minutes += 13
	game.start_dialogue("Mara")
	check(game.dialog.active and Chapter.state().stage == "invitation", "A stopped conversation can resume its pending story after cooldown")
	game.end_dialogue()
	var old_save = State.snapshot()
	old_save.erase("chapter")
	old_save.erase("relationship_rewards")
	check(game.store.valid(old_save), "Existing 0.2 saves remain compatible")
	State.restore(old_save)
	check(Chapter.state().stage == "invitation", "Old saves acquire a clean chapter without changing their relationship")
	game.dialog.chapter_mode = false
	State.data.conversations = 0
	State.data.relationship.tension = 0
	game.start_dialogue("Mara")
	game.answer("Danke", "friendly")
	game.end_dialogue()
	var once = State.data.relationship.trust
	game.dialog.generator = DialogueGenerator.new()
	State.data.conversations = 0
	game.start_dialogue("Mara")
	game.answer("Danke", "friendly")
	check(State.data.relationship.trust == once, "Generic dialogue rewards are also capped across reopened conversations")
	game.end_dialogue()
	game.dialog.chapter_mode = true
