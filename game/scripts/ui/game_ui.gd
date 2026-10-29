class_name GameUI
extends CanvasLayer
const INK = Color("101e25")
const MINT = Color("a8edd7")
const TEXT = Color("edf1e9")
const MUTED = Color("a3b5b6")
var game: Node
var root: Control
var menu: Control
var hud: Control
var modal: Control
var dialogue: Control
var speech: Label
var speaker: Label
var response_grid: GridContainer
var free_text: LineEdit
var send_button: Button
var toast_label: Label
var toast_time = 0.0
var prompt: Label
var time_label: Label
var objective: Label
var response_buttons: Array[Button] = []
var response_scroll: ScrollContainer
var speech_scroll: ScrollContainer
var dialogue_footer: Label

func style(color: Color, border: Color = Color.TRANSPARENT, radius: int = 10, padding: int = 16) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.set_border_width_all(1 if border.a > 0 else 0)
	box.set_corner_radius_all(radius)
	box.content_margin_left = padding
	box.content_margin_right = padding
	box.content_margin_top = padding
	box.content_margin_bottom = padding
	return box

func label(text: String, size: int = 18, color: Color = TEXT) -> Label:
	var node = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return node

func button(text: String, action: Callable, primary: bool = false) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size.y = 64 if game != null and game.mobile_mode else 45
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_stylebox_override("normal", style(MINT if primary else Color("20323a"), Color("3c5458"), 7, 12))
	b.add_theme_stylebox_override("hover", style(Color("baf5df") if primary else Color("30494c"), MINT, 7, 12))
	b.add_theme_stylebox_override("pressed", style(Color("76b6a5"), MINT, 7, 12))
	b.add_theme_stylebox_override("focus", style(Color(0, 0, 0, 0), MINT, 7, 12))
	b.add_theme_color_override("font_color", INK if primary else TEXT)
	b.add_theme_color_override("font_hover_color", INK if primary else TEXT)
	b.add_theme_color_override("font_focus_color", INK if primary else TEXT)
	b.add_theme_color_override("font_pressed_color", INK)
	b.add_theme_font_size_override("font_size", 16)
	b.pressed.connect(action)
	return b

func fill(control: Control) -> void:
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func vbox(parent: Node, spacing: int = 12) -> VBoxContainer:
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", spacing)
	parent.add_child(box)
	return box

func panel(parent: Node, color: Color = Color(0.055, 0.095, 0.12, 0.96), padding: int = 24) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", style(color, Color("395055"), 12, padding))
	parent.add_child(p)
	return p

func setup(controller: Node) -> void:
	game = controller
	root = Control.new()
	root.name = "Interface"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill(root)
	var theme = Theme.new()
	theme.default_font = preload("res://assets/Interface.ttf")
	theme.default_font_size = 16
	theme.set_color("font_color", "Label", TEXT)
	root.theme = theme
	add_child(root)
	build_hud()
	toast_label = label("", 17, MINT)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(toast_label)
	toast_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	toast_label.offset_top = 88
	toast_label.offset_bottom = 132
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_menu()

func build_hud() -> void:
	hud = Control.new()
	fill(hud)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)
	var location = panel(hud, Color(0.05, 0.10, 0.13, 0.90), 16)
	location.position = Vector2(28, 26)
	location.custom_minimum_size = Vector2(270, 74)
	var top = vbox(location, 3)
	top.add_child(label("THE BEGINNING  /  01", 15, MINT))
	time_label = label("Dein Apartment  ·  17:20", 16)
	top.add_child(time_label)
	var goal = panel(hud, Color(0.05, 0.10, 0.13, 0.86), 18)
	goal.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	goal.offset_left = -340
	goal.offset_right = -28
	goal.offset_top = 26
	goal.offset_bottom = 210
	if game.mobile_mode:
		goal.offset_left = -460
		goal.offset_right = -140
		goal.offset_bottom = 150
	var goals = vbox(goal, 7)
	goals.add_child(label("DEIN ERSTER TAG", 14, MINT))
	objective = label("", 15)
	goals.add_child(objective)
	goals.add_child(label("OFFLINE  ·  Lokale Dialogregeln", 12, MUTED))
	var controls = label("WASD  Bewegen     Maus  Kamera     Shift  Sprint\nE  Interaktion     F  Gespräch     Tab  Profil     Esc  Menü", 13, TEXT)
	if game.mobile_mode:
		controls.text = "Links bewegen  ·  Rechts wischen"
	hud.add_child(controls)
	controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	controls.offset_left = 28
	controls.offset_right = 590
	controls.offset_top = -68
	controls.offset_bottom = -22
	controls.visible = not game.mobile_mode
	prompt = label("", 17, MINT)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.add_child(prompt)
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt.offset_left = -300
	prompt.offset_right = 300
	prompt.offset_top = -128
	prompt.offset_bottom = -76
	if game.mobile_mode:
		prompt.offset_left = -240
		prompt.offset_right = 140
		prompt.offset_top = -220
		prompt.offset_bottom = -158
	hud.hide()

func clear_menu() -> void:
	if is_instance_valid(menu):
		menu.queue_free()
		menu = null

func show_menu() -> void:
	clear_menu()
	hud.hide()
	menu = Control.new()
	fill(menu)
	root.add_child(menu)
	var left = panel(menu, Color(0.035, 0.075, 0.095, 0.96), 32)
	left.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	left.offset_left = 0
	left.offset_right = 390 if game.mobile_mode else 460
	var scrolling = ScrollContainer.new()
	scrolling.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(scrolling)
	var column = vbox(scrolling, 10)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(label("EIN LEBEN. DEINE ENTSCHEIDUNGEN.", 12, MINT))
	var title = label("META ME" if game.mobile_mode else "META\nME", 45 if game.mobile_mode else 84)
	title.add_theme_constant_override("line_spacing", -22)
	column.add_child(title)
	column.add_child(label("Wer möchtest du hier sein?", 22, MINT))
	if not game.mobile_mode:
		column.add_child(label("Ein neuer Ort. Ein erstes Gespräch.\nUnd ein Gegenüber, das Fragen stellt.", 15, MUTED))
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	column.add_child(spacer)
	var start = button("Neues Spiel beginnen   →", game.choose_new_game, true)
	start.name = "NewGame"
	column.add_child(start)
	var resume = button("Spiel fortsetzen", game.continue_game)
	resume.name = "Continue"
	resume.disabled = not game.store.exists(game.slot)
	column.add_child(resume)
	column.add_child(button("Charakter erstellen", show_avatar))
	column.add_child(button("Einstellungen", show_settings))
	column.add_child(button("Spielstände verwalten", show_slots))
	column.add_child(button("Beenden", func(): game.get_tree().quit()))
	var flexible = Control.new()
	flexible.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(flexible)
	column.add_child(label("SPIELBARE ENTWICKLUNGSVERSION  /  0.2.0", 11, MUTED))
	column.add_child(label("Spielbeobachtungen sind keine psychologische Diagnose.", 11, MUTED))
	var caption = label("01\nTHE BEGINNING", 26)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	menu.add_child(caption)
	caption.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	caption.offset_left = -380
	caption.offset_right = -40
	caption.offset_top = -125
	caption.offset_bottom = -40
	start.grab_focus()

func open_modal(title: String) -> VBoxContainer:
	close_dialogue()
	close_modal(false)
	game.set_controls(false)
	modal = ColorRect.new()
	modal.color = Color(0.01, 0.025, 0.035, 0.70)
	fill(modal)
	root.add_child(modal)
	var center = CenterContainer.new()
	fill(center)
	modal.add_child(center)
	var frame = panel(center)
	frame.custom_minimum_size = Vector2(minf(680, root.size.x - 32), 0)
	var column = vbox(frame, 12)
	column.add_child(label(title, 28, MINT))
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(minf(640, root.size.x - 80), minf(410, root.size.y - (220 if game.mobile_mode else 180)))
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var content = vbox(scroll, 12)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close = button("Zurück", close_modal)
	column.add_child(close)
	close.grab_focus()
	return content

func close_modal(resume: bool = true) -> void:
	if is_instance_valid(modal):
		modal.queue_free()
		modal = null
	if resume and game.running:
		game.set_controls(true)

func show_pause() -> void:
	var content = open_modal("Ein Moment Pause")
	content.add_child(label("Dein Fortschritt bleibt hier. Nimm dir Zeit.", 17, MUTED))
	content.add_child(button("Weiterspielen", close_modal, true))
	content.add_child(button("Spiel speichern", func(): game.save_game()))
	content.add_child(button("Spielstände / Laden", show_slots))
	content.add_child(button("Profil und Beziehungen", show_profile))
	content.add_child(button("Wohnungsplan", show_map))
	content.add_child(button("Tagebuch und Erinnerungen", show_memories))
	content.add_child(button("Einstellungen", show_settings))
	content.add_child(button("Speichern und zum Hauptmenü", game.return_to_menu))

func show_avatar() -> void:
	var content = open_modal("Dein digitales Ich")
	content.add_child(label("Erster Editor: Name sowie Haut-, Haar- und Kleidungsfarbe. Körperformen, Frisuren, Stimme und Accessoires folgen in späteren Phasen.", 15, MUTED))
	var name_field = LineEdit.new()
	name_field.text = State.data.avatar.name
	name_field.placeholder_text = "Dein Name"
	name_field.max_length = 32
	name_field.custom_minimum_size.y = 44
	content.add_child(name_field)
	for pair in [["skin", "Hautfarbe"], ["hair", "Haarfarbe"], ["outfit", "Kleidung"]]:
		var row = HBoxContainer.new()
		content.add_child(row)
		var caption = label(pair[1])
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(caption)
		var picker = ColorPickerButton.new()
		picker.custom_minimum_size = Vector2(180, 44)
		picker.color = Color(State.data.avatar[pair[0]])
		picker.edit_alpha = false
		var key: String = pair[0]
		picker.color_changed.connect(func(color: Color):
			State.data.avatar[key] = color.to_html(false)
			game.player.model.recolor(State.data.avatar))
		row.add_child(picker)
	content.add_child(button("Charakter übernehmen", func():
		State.data.avatar.name = name_field.text.strip_edges() if not name_field.text.strip_edges().is_empty() else "Alex"
		close_modal()
		toast("Charakter übernommen."), true))

func show_profile() -> void:
	var content = open_modal("Deine Spuren im Spiel")
	content.add_child(label("Dies beschreibt ausschließlich ausgewählte Spielhandlungen. Keine Messung deiner echten Persönlichkeit, keine Diagnose und kein Gut-Böse-Wert.", 15, MUTED))
	content.add_child(label("MARA  /  " + EmotionManager.new().description(), 18, MINT))
	var r = State.data.relationship
	content.add_child(label("Vertrauen %.1f   ·   Respekt %.1f\nVertrautheit %.1f   ·   Konfliktspannung %.1f" % [r.trust, r.respect, r.familiarity, r.tension], 16))
	for key in State.TRAITS:
		content.add_child(label("%s   %.1f" % [key, State.data.traits[key]], 15))
	content.add_child(label("Kleine Änderungen sind Spielsignale, keine Bewertung. Rückzug ist eine gleichwertige Entscheidung.", 13, MUTED))

func show_memories() -> void:
	var content = open_modal("Tagebuch & Erinnerungen")
	content.add_child(label("Freitexte werden nur mit aktivierter Aufbewahrung gespeichert. Spielereignisse bleiben lokal. Du kannst alle persönlichen Einträge löschen.", 15, MUTED))
	content.add_child(label("DEINE REFLEXIONEN", 16, MINT))
	if State.data.journal.is_empty():
		content.add_child(label("Noch keine aufbewahrten Einträge.", 15, MUTED))
	for entry in State.data.journal:
		content.add_child(label(entry, 15))
	content.add_child(label("GEMEINSAME SPIELEREIGNISSE", 16, MINT))
	for entry in State.data.memories:
		content.add_child(label("· " + entry.summary, 14))
	content.add_child(button("Einträge aus allen Speicherplätzen löschen …", confirm_clear_memories))

func confirm_clear_memories() -> void:
	var content = open_modal("Persönliche Einträge löschen?")
	content.add_child(label("Entfernt Erinnerungen und Tagebuchtexte aus der aktuellen Partie sowie aus allen lesbaren Spielständen und deren Sicherungen. Positionen und Beziehungen bleiben erhalten.", 16))
	content.add_child(button("Jetzt Einträge löschen", game.clear_memories))

func show_map() -> void:
	var content = open_modal("THE BEGINNING  /  Wohnungsplan")
	content.add_child(label("NORD\n\nSchlafzimmer    │    Küche & Arbeitsplatz\n─────────────────────────\nBad                   │    Wohnzimmer & META ME\n                         │\n                         └── Tür → Balkon", 19, MINT))
	content.add_child(label("Alle vier Innenbereiche und der Balkon sind begehbar. Die Stadt hinter dem Balkon ist Kulisse. Weitere Viertel, Park und Spiegelwelt sind noch nicht implementiert.", 16, MUTED))

func show_settings() -> void:
	var content = open_modal("Einstellungen")
	var privacy = CheckButton.new()
	privacy.text = "Meine Freitextantworten lokal aufbewahren"
	privacy.button_pressed = State.remember_text
	privacy.toggled.connect(func(value: bool): State.remember_text = value; game.save_settings())
	content.add_child(privacy)
	content.add_child(label("Standard: aus. Spielstände sind verschlüsselt; der Schlüssel liegt im selben Betriebssystemkonto. Verwende für vertrauliche Daten zusätzlich Geräte- und Kontoschutz.", 13, MUTED))
	var audio = CheckButton.new()
	audio.text = "Musik und Spielgeräusche"
	audio.button_pressed = game.audio_enabled
	audio.toggled.connect(game.set_audio)
	content.add_child(audio)
	var quality = CheckButton.new()
	quality.text = "Hohe Grafikqualität · Schatten & Echtzeitspiegel"
	quality.button_pressed = not game.world.low_quality
	quality.toggled.connect(func(value: bool): game.set_quality(value))
	content.add_child(quality)
	content.add_child(label("Mausempfindlichkeit", 16))
	var slider = HSlider.new()
	slider.min_value = 0.001
	slider.max_value = 0.006
	slider.step = 0.00025
	slider.value = game.player.sensitivity
	slider.value_changed.connect(func(value: float): game.player.sensitivity = value; game.save_settings())
	content.add_child(slider)
	content.add_child(label("Dialogmodus: OFFLINE\nRegel- und vorlagenbasiert, kein lokales Sprachmodell. Es werden keine Gesprächsdaten an einen Onlinedienst gesendet. Online-KI ist in diesem Meilenstein nicht angeschlossen.", 14, MUTED))

func show_slots() -> void:
	var content = open_modal("Spielstände")
	content.add_child(label(("Drei lokale Speicherplätze mit je einer Sicherung. Aktuell: Platz %d. 'Speichern' sichert sofort; auch beim Wechsel in den Hintergrund wird gespeichert." if game.mobile_mode else "Drei lokale Speicherplätze mit je einer Sicherung. Aktuell: Platz %d. Automatisches Speichern nach zwei Spielminuten in Echtzeit; F5 speichert sofort.") % game.slot, 15, MUTED))
	for index in range(1, 4):
		var row = HBoxContainer.new()
		content.add_child(row)
		row.add_child(label("Platz %d · %s" % [index, "vorhanden" if game.store.exists(index) else "leer"], 16))
		var load_button = button("Laden", func(): game.load_game(index))
		load_button.disabled = not game.store.exists(index)
		row.add_child(load_button)
		var save_button = button("Hier speichern", func(): confirm_slot(index))
		save_button.disabled = not game.running
		row.add_child(save_button)
	content.add_child(button("Alle Spielstände & persönlichen Daten löschen …", confirm_delete))

func confirm_slot(index: int) -> void:
	if not game.store.exists(index):
		game.save_game(index)
		show_slots()
		return
	var content = open_modal("Platz %d ersetzen?" % index)
	content.add_child(label("Der bisherige Stand wird zur Sicherung. Künftige Speicherungen ersetzen auch diese Sicherung.", 16))
	content.add_child(button("Aktuelle Partie hier speichern", func(): game.save_game(index); show_slots(), true))

func confirm_delete() -> void:
	var content = open_modal("Alle lokalen Spielstände löschen?")
	content.add_child(label("Entfernt alle drei Speicherplätze, Sicherungen, Tagebucheinträge und den lokalen Speicherschlüssel. Das kann nicht rückgängig gemacht werden.", 16))
	content.add_child(button("Alle Daten endgültig löschen", game.delete_all_data))

func show_dialogue(text: String) -> void:
	game.set_controls(false)
	if not is_instance_valid(dialogue):
		dialogue = panel(root, Color(0.035, 0.075, 0.095, 0.98), 16 if game.mobile_mode else 22)
		dialogue.name = "DialogueUI"
		dialogue.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		dialogue.offset_left = 80
		dialogue.offset_right = -80
		dialogue.offset_top = -470
		dialogue.offset_bottom = -24
		if game.mobile_mode:
			dialogue.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			dialogue.offset_left = 16
			dialogue.offset_right = -16
			dialogue.offset_top = 12
			dialogue.offset_bottom = -12
		var col = vbox(dialogue, 10)
		var head = HBoxContainer.new()
		col.add_child(head)
		speaker = label("", 19, MINT)
		speaker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(speaker)
		var end_button = button("Beenden  ×" if game.mobile_mode else "Gespräch beenden  ×", game.end_dialogue)
		if game.mobile_mode:
			end_button.custom_minimum_size.y = 56
		head.add_child(end_button)
		speech = label("", 17)
		if game.mobile_mode:
			speech_scroll = ScrollContainer.new()
			speech_scroll.custom_minimum_size.y = 84
			speech_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			col.add_child(speech_scroll)
			speech.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			speech_scroll.add_child(speech)
		else:
			speech.custom_minimum_size.y = 82
			col.add_child(speech)
		response_grid = GridContainer.new()
		response_grid.columns = 1 if game.mobile_mode else 2
		response_grid.add_theme_constant_override("h_separation", 10)
		response_grid.add_theme_constant_override("v_separation", 8)
		if game.mobile_mode:
			response_scroll = ScrollContainer.new()
			response_scroll.custom_minimum_size.y = 80
			response_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
			response_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			col.add_child(response_scroll)
			response_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			response_scroll.add_child(response_grid)
		else:
			col.add_child(response_grid)
		var row = HBoxContainer.new()
		col.add_child(row)
		free_text = LineEdit.new()
		free_text.name = "FreeText"
		free_text.placeholder_text = "Eigene Antwort schreiben … (max. 500 Zeichen)"
		free_text.max_length = 500
		free_text.custom_minimum_size.y = 44
		if game.mobile_mode:
			free_text.custom_minimum_size.y = 64
			free_text.add_theme_font_size_override("font_size", 18)
		free_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		free_text.text_submitted.connect(func(value: String): game.answer(value))
		row.add_child(free_text)
		send_button = button("Senden  ↵", func(): game.answer(free_text.text), true)
		row.add_child(send_button)
		dialogue_footer = label("Antworten wischen  ·  Eigene Texte möglich  ·  Lokale Dialogregeln" if game.mobile_mode else "Lokale Dialogregeln · Freitext wird vorsichtig eingeordnet; unklare Antworten werden nachgefragt.", 11, MUTED)
		col.add_child(dialogue_footer)
	speaker.text = ("◈  META ME  /  Freiwillige Reflexion" if game.dialog.speaker == "META ME" else "◉  MARA  /  " + EmotionManager.new().description())
	speech.text = text
	free_text.clear()
	for child in response_grid.get_children():
		response_grid.remove_child(child)
		child.queue_free()
	response_buttons.clear()
	var options = game.dialog.options()
	for i in range(options.size()):
		var choice: Dictionary = options[i]
		var b = button("%d  /  %s\n%s" % [i + 1, choice.label, choice.text], func(): game.answer(choice.text, choice.intent))
		b.name = "Response%d" % i
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size = Vector2(0, 76 if game.mobile_mode else 65)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 16 if game.mobile_mode else 13)
		b.disabled = not game.dialog.active
		response_grid.add_child(b)
		response_buttons.append(b)
	free_text.editable = game.dialog.active
	send_button.disabled = not game.dialog.active
	if not response_buttons.is_empty():
		response_buttons[0].grab_focus()

func close_dialogue() -> void:
	if is_instance_valid(dialogue):
		dialogue.queue_free()
		dialogue = null
	if game != null:
		game.dialog.end()
		game.npc.talking = false

func toast(text: String) -> void:
	toast_label.text = text
	toast_time = 5
	root.move_child(toast_label, root.get_child_count() - 1)

func _process(delta: float) -> void:
	toast_time = maxf(0, toast_time - delta)
	toast_label.visible = toast_time > 0 if is_instance_valid(toast_label) else false
	if is_instance_valid(time_label):
		time_label.text = "Dein Apartment  ·  " + State.clock_text()
		objective.text = "%s META ME am Spiegel begegnen\n%s Ein Gespräch mit Mara führen\n%s Deinen Fortschritt speichern" % ["✓" if State.data.mirror_seen else "○", "✓" if State.data.decisions > 0 else "○", "✓" if State.data.saved_once else "○"]
	if game != null and game.mobile_mode and is_instance_valid(dialogue):
		var physical_height = maxf(1, DisplayServer.window_get_size().y)
		var keyboard = DisplayServer.virtual_keyboard_get_height() * root.size.y / physical_height
		dialogue.offset_bottom = -maxf(12, keyboard + 8)
		response_scroll.visible = keyboard <= 0
		dialogue_footer.visible = keyboard <= 0
		speech_scroll.custom_minimum_size.y = 40 if keyboard > 0 else 84
