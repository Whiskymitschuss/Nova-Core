class_name TouchControls
extends Control
## Independent finger ownership: movement, look and action buttons work together.
var game: Node
var move_finger = -1
var look_finger = -1
var origin = Vector2.ZERO
var stick = Vector2.ZERO
var move_input = Vector2.ZERO
var sprinting = false
var buttons: Dictionary = {}
var radius = 66.0

func setup(controller: Node) -> void:
	game = controller
	name = "TouchControls"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_action("interact", "Benutzen", func():
		if game.target != null:
			game.interact(str(game.target.get_meta("kind"))))
	add_action("talk", "Reden", func():
		if game.npc_near:
			game.start_dialogue("Mara"))
	add_action("menu", "Menü", game.ui.show_pause)
	add_action("save", "Speichern", func(): game.save_game())
	add_action("sprint", "Sprint", func():
		sprinting = not sprinting
		game.player.touch_sprint = sprinting)
	resized.connect(layout)
	layout()

func add_action(id: String, caption: String, callback: Callable) -> void:
	var b = TouchScreenButton.new()
	b.name = "Touch_" + id
	b.texture_normal = preload("res://assets/touch-button.svg")
	b.texture_pressed = preload("res://assets/touch-button-pressed.svg")
	b.pressed.connect(callback)
	add_child(b)
	var text = Label.new()
	text.text = caption
	text.position = Vector2(0, 0)
	text.size = Vector2(96, 96)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 15)
	text.add_theme_color_override("font_color", Color("e8f2ec"))
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(text)
	buttons[id] = b

func layout() -> void:
	if buttons.is_empty():
		return
	var inset = safe_insets()
	origin = Vector2(120 + inset.x, size.y - 116 - inset.w)
	buttons.interact.position = Vector2(size.x - 206 - inset.z, size.y - 112 - inset.w)
	buttons.talk.position = Vector2(size.x - 106 - inset.z, size.y - 212 - inset.w)
	buttons.menu.position = Vector2(size.x - 106 - inset.z, 12 + inset.y)
	buttons.save.position = Vector2(size.x - 316 - inset.z, size.y - 112 - inset.w)
	buttons.sprint.position = Vector2(16 + inset.x, size.y - 302 - inset.w)
	queue_redraw()

func safe_insets() -> Vector4:
	if not OS.has_feature("android"):
		return Vector4(12, 0, 12, 0)
	var safe = DisplayServer.get_display_safe_area()
	var physical = Vector2(DisplayServer.window_get_size())
	if physical.x <= 0 or physical.y <= 0 or safe.size.x <= 0:
		return Vector4(12, 0, 12, 0)
	var ratio = size / physical
	return Vector4(maxf(12, safe.position.x * ratio.x), maxf(0, safe.position.y * ratio.y),
		maxf(12, (physical.x - safe.end.x) * ratio.x), maxf(0, (physical.y - safe.end.y) * ratio.y))

func over_button(point: Vector2) -> bool:
	for b in buttons.values():
		if Rect2(b.position, Vector2(96, 96)).has_point(point):
			return true
	return false

func _input(event: InputEvent) -> void:
	if not visible or game == null or not game.player.enabled:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if over_button(event.position):
				return
			if move_finger < 0 and event.position.distance_to(origin) < radius * 1.8:
				move_finger = event.index
				update_stick(event.position)
			elif look_finger < 0 and event.position.x > size.x * 0.40 and event.position.y > 112:
				look_finger = event.index
			else:
				return
		else:
			if event.index == move_finger:
				move_finger = -1
				stick = Vector2.ZERO
				move_input = Vector2.ZERO
				game.player.touch_move = Vector2.ZERO
			elif event.index == look_finger:
				look_finger = -1
			else:
				return
		get_viewport().set_input_as_handled()
		queue_redraw()
	elif event is InputEventScreenDrag:
		if event.index == move_finger:
			update_stick(event.position)
		elif event.index == look_finger:
			game.player.look(event.relative * 1.6)
		else:
			return
		get_viewport().set_input_as_handled()

func update_stick(point: Vector2) -> void:
	stick = (point - origin).limit_length(radius)
	var value = stick / radius
	# Deadzone prevents a resting thumb from moving the avatar.
	move_input = value if value.length() > 0.15 else Vector2.ZERO
	game.player.touch_move = move_input
	queue_redraw()

func reset() -> void:
	move_finger = -1
	look_finger = -1
	stick = Vector2.ZERO
	move_input = Vector2.ZERO
	sprinting = false
	if game != null:
		game.player.touch_move = Vector2.ZERO
		game.player.touch_sprint = false
	queue_redraw()

func _draw() -> void:
	draw_circle(origin, radius + 12, Color(0.055, 0.075, 0.12, 0.65))
	draw_arc(origin, radius + 12, 0, TAU, 64, Color(0.91, 0.74, 0.51, 0.55), 2, true)
	draw_circle(origin + stick, 30, Color(0.91, 0.74, 0.51, 0.75))
	draw_line(origin + Vector2(-12, 0), origin + Vector2(12, 0), Color("20343b"), 2)
	draw_line(origin + Vector2(0, -12), origin + Vector2(0, 12), Color("20343b"), 2)

func _process(_delta: float) -> void:
	if game == null:
		return
	buttons.interact.modulate.a = 1.0 if game.target != null else 0.4
	buttons.talk.modulate.a = 1.0 if game.npc_near else 0.4
	buttons.sprint.modulate = Color("e9bd81") if sprinting else Color.WHITE
