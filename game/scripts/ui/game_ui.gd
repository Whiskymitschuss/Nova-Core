class_name GameUI
extends CanvasLayer
const INK = Color("121b2a")
const MINT = Color("e9bd81")
const TEXT = Color("f3eee6")
const MUTED = Color("9ba9bb")
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

func style(color: Color, border: Color = Color.TRANSPARENT, radius: int = 5, padding: int = 16) -> StyleBoxFlat:
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
	b.add_theme_stylebox_override("normal", style(MINT if primary else Color("202c3f"), Color("354158"), 7, 12))
	b.add_theme_stylebox_override("hover", style(Color("f6d6a7") if primary else Color("2e3c52"), MINT, 7, 12))
	b.add_theme_stylebox_override("pressed", style(Color("cc9e63"), MINT, 7, 12))
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

func panel(parent: Node, color: Color = Color(0.055, 0.075, 0.12, 0.98), padding: int = 24) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", style(color, Color("354158"), 5, padding))
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
	toast_label.offset_top = 190 if game.mobile_mode else 240
	toast_label.offset_bottom = 232 if game.mobile_mode else 282
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
	top.add_child(label("EIN BILD VON ZUHAUSE", 14, MINT))
	time_label = label("Dein Apartment  ·  17:20", 16)
	top.add_child(time_label)
	var goal = panel(hud, Color(0.05, 0.10, 0.13, 0.86), 18)
	goal.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	goal.offset_left = -340
	goal.offset_right = -28
	goal.offset_top = 26
	goal.offset_bottom = 225
	if game.mobile_mode:
		goal.offset_left = -460
		goal.offset_right = -140
		goal.offset_bottom = 176
	var goals = vbox(goal, 7)
	goals.add_child(button("Kapitel 1  /  Dein nächster Schritt  →", show_chapter))
	objective = label("", 15)
	goals.add_child(objective)

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

func diagram(parent: Node, mode: String, height: float) -> StoryDiagram:
	var chart = StoryDiagram.new()
	chart.mode = mode
	chart.name = "Diagram_" + mode
	chart.custom_minimum_size = Vector2(0, height)
	chart.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(chart)
	return chart

func show_menu() -> void:
	clear_menu()
	hud.hide()
	menu = Control.new()
	fill(menu)
	root.add_child(menu)
	var shade = ColorRect.new()
	shade.color = Color(0.025, 0.04, 0.07, 0.62)
	fill(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(shade)
	var art = StoryDiagram.new()
	art.mode = "cover"
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.offset_left = 400 if game.mobile_mode else 500
	menu.add_child(art)
	var left = panel(menu, Color(0.045, 0.065, 0.105, 0.97), 28 if game.mobile_mode else 42)
	left.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	left.offset_right = 410 if game.mobile_mode else 500
	var scrolling = ScrollContainer.new()
	scrolling.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(scrolling)
	var column = vbox(scrolling, 12)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(label("EIN INTERAKTIVES LEBEN", 12, MINT))
	column.add_child(label("META ME", 48 if game.mobile_mode else 66))
	column.add_child(label("Wem zeigst du, wer du bist?", 19, MUTED))
	var line = HSeparator.new()
	column.add_child(line)
	var start = button("Kapitel 1 beginnen   →", game.choose_new_game, true)
	start.name = "NewGame"
	column.add_child(start)
	var resume = button("Deine Geschichte fortsetzen", game.continue_game)
	resume.name = "Continue"
	resume.disabled = not game.store.exists(game.slot)
	column.add_child(resume)
	var links = HBoxContainer.new()
	links.add_theme_constant_override("separation", 12)
	column.add_child(links)
	for item in [["Dein Charakter", show_avatar], ["Einstellungen", show_settings]]:
		var link = button(item[0], item[1])
		link.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		link.add_theme_font_size_override("font_size", 14)
		links.add_child(link)
	column.add_child(button("Spielstände verwalten", show_slots))
	if not game.mobile_mode: column.add_child(button("Beenden", func(): game.get_tree().quit()))
	column.add_child(label("ENTWICKLUNGSVERSION 0.3.0  /  OFFLINE", 11, MUTED))
	var chapter_card = panel(menu, Color(0.045, 0.065, 0.105, 0.92), 22)
	chapter_card.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	chapter_card.offset_left = -minf(450, root.size.x - left.offset_right - 45)
	chapter_card.offset_right = -28
	chapter_card.offset_top = -235 if game.mobile_mode else -285
	chapter_card.offset_bottom = -28
	var story = vbox(chapter_card, 10)
	story.add_child(label("KAPITEL 1  /  THE BEGINNING", 12, MINT))
	story.add_child(label("Ein Bild von Zuhause", 27))
	story.add_child(label("Ein fremder Blick auf deine Wohnung. Eine Bitte. Und eine Grenze, die nur du setzen kannst.", 16, MUTED))
	story.add_child(label("Bild prüfen  ·  Entscheiden  ·  Folgen erleben", 12, MINT))
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
	content.add_child(button("Deine Spuren · Diagramme", show_profile))
	content.add_child(button("Kapitel und nächster Schritt", show_chapter))
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

func show_chapter() -> void:
	var content = open_modal("Ein Bild von Zuhause")
	content.add_child(label("KAPITEL 1  /  " + ("ABGESCHLOSSEN" if Chapter.index() == 5 else "DEINE GESCHICHTE"), 12, MINT))
	diagram(content, "flow", 96)
	var card = panel(content, Color("1b2738"), 16)
	var col = vbox(card, 6)
	col.add_child(label(Chapter.title(), 21))
	col.add_child(label(Chapter.goal(), 16, MINT))
	if not Chapter.state().choice.is_empty():
		content.add_child(label(Chapter.consequence(), 16))
	if Chapter.index() == 5:
		content.add_child(label("Dein Abend: " + ("Raum für dich." if Chapter.state().activity == "solo" else "Ein gemeinsamer Tee."), 17, MINT))
		content.add_child(label("Mara erinnert sich an deine Freigabe. Kapitel 2 ist noch nicht spielbar; dein Ausgang bleibt gespeichert.", 14, MUTED))
	if Chapter.state().stage == "reflection":
		content.add_child(button("Den Abend ohne Reflexion abschließen", func():
			if Chapter.skip_reflection():
				game.save_game(-1, true)
				show_chapter()))
	if not Chapter.state().choice.is_empty():
		content.add_child(button("Deine Bildfreigabe prüfen", show_photo))
	content.add_child(button("Entwicklungen und Entscheidungen ansehen", show_profile))
	content.add_child(button("Ziel auf dem Wohnungsplan finden", show_map))
	content.add_child(label("WAS BISHER GESCHAH", 13, MINT))
	if Chapter.state().events.is_empty():
		content.add_child(label("Mara wartet im Wohnzimmer mit einer Bitte auf dich.", 15, MUTED))
	for event in Chapter.state().events:
		content.add_child(label("— " + event.caption, 15))

func show_photo() -> void:
	var content = open_modal("Maras Foto  /  Deine Freigabe")
	content.add_child(label("Hofausstellung: »Fenster, die wir nicht kennen«", 16, MINT))
	content.add_child(label("Die markierte Kiste zeigt Name und Adresse. Noch ist nichts veröffentlicht. Prüfe den Ausschnitt, bevor du dich entscheidest.", 15))
	var photo = diagram(content, "photo", 220)
	photo.crop = Chapter.state().choice == "crop"
	if Chapter.state().stage != "review":
		content.add_child(label(Chapter.consequence(), 16, MINT))
		return
	var toggle = CheckButton.new()
	toggle.text = "Sicheren Ausschnitt ansehen"
	toggle.custom_minimum_size.y = 56
	toggle.toggled.connect(func(value: bool): photo.crop = value; photo.queue_redraw())
	content.add_child(toggle)
	for pair in [["crop", "Nur Ausschnitt freigeben · Adresse bleibt privat"], ["private", "Keine Veröffentlichung erlauben"], ["share", "Original mit sichtbarer Adresse freigeben …"]]:
		var id: String = pair[0]
		content.add_child(button(pair[1], func():
			if id == "share": confirm_original()
			else: decide_photo(id), id == "crop"))

func confirm_original() -> void:
	var content = open_modal("Das Original wirklich freigeben?")
	content.add_child(label("Auf dieser Fassung bleiben Name und Adresse erkennbar. Mara darf sie in der fiktiven Hofausstellung zeigen. Du kannst stattdessen den Ausschnitt wählen.", 16))
	content.add_child(button("Original ausdrücklich freigeben", func(): decide_photo("share")))
	content.add_child(button("Zur Bildprüfung zurück", show_photo, true))

func decide_photo(choice: String) -> void:
	if Chapter.choose_photo(choice):
		game.world.apply_state()
		game.save_game(-1, true)
		show_chapter()

func show_profile() -> void:
	var content = open_modal("Deine Spuren")
	content.add_child(label("Ein Verlauf deiner Spielgeschichte. Keine Messung deiner Persönlichkeit.", 14, MUTED))
	content.add_child(label("MARA  /  BEZIEHUNGSVERLAUF", 13, MINT))
	content.add_child(label("Blau: Vertrauen     ·     Koralle: Konfliktspannung", 13))
	var chart = diagram(content, "relationship", 210)
	var evidence = label(Chapter.state().events.back().caption if not Chapter.state().events.is_empty() else "Noch keine Kapitelentscheidung.", 15, MINT)
	content.add_child(evidence)
	chart.event_selected.connect(func(index: int): evidence.text = Chapter.state().events[index].caption)
	content.add_child(label("Tippe auf einen Punkt, um die zugehörige Entscheidung zu sehen. Die Linien verbinden gespeicherte Spielzustände; wenige Ereignisse ergeben noch keinen Trend.", 13, MUTED))
	content.add_child(label("WELCHE ENTSCHEIDUNGEN HAST DU GETROFFEN?", 13, MINT))
	diagram(content, "choices", 168)
	content.add_child(label("Häufigkeiten der unten belegten Kapitelereignisse. Eine Grenze zu setzen ist eine gleichwertige Entscheidung.", 13, MUTED))
	for event in Chapter.state().events:
		var card = panel(content, Color("1b2738"), 12)
		card.add_child(label(event.caption, 15))
	content.add_child(button("Zum Kapitelrückblick", show_chapter))

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
	content.add_child(label("Entfernt Tagebuchtexte, Erinnerungen und die Ereignisse der Diagramme aus der Partie sowie aus lesbaren Spielständen und Sicherungen. Kapitelstand und Beziehungen bleiben erhalten.", 16))
	content.add_child(button("Jetzt Einträge löschen", game.clear_memories))

func show_map() -> void:
	var content = open_modal("Dein Apartment")
	content.add_child(label("GOLD  /  Dein aktuelles Ziel", 13, MINT))
	diagram(content, "map", 330)
	content.add_child(label(Chapter.goal(), 17))
	content.add_child(label("Schematischer Wohnungsplan. Der Balkon liegt im Süden; die Stadt dahinter ist bisher Kulisse.", 13, MUTED))

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
		dialogue = panel(root, Color(0.045, 0.065, 0.105, 0.99), 16 if game.mobile_mode else 22)
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
		end_button.name = "DialogueExit"
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
	speaker.text = "META ME  /  RÜCKBLICK" if game.dialog.speaker == "META ME" else "MARA  /  " + Chapter.title().to_upper()
	dialogue.find_child("DialogueExit", true, false).text = "Schließen ×" if game.dialog.active else "Weiter →"
	speech.text = text
	free_text.clear()
	for child in response_grid.get_children():
		response_grid.remove_child(child)
		child.queue_free()
	response_buttons.clear()
	var options = game.dialog.options()
	for i in range(options.size()):
		var choice: Dictionary = options[i]
		var b = button("%s\n%s" % [choice.label.to_upper(), choice.text], func(): game.answer(choice.text, choice.intent))
		b.name = "Response%d" % i
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size = Vector2(0, 76 if game.mobile_mode else 65)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 16 if game.mobile_mode else 13)
		b.disabled = not game.dialog.active
		response_grid.add_child(b)
		response_buttons.append(b)
	response_grid.visible = game.dialog.active
	free_text.get_parent().visible = game.dialog.active
	dialogue_footer.text = "DEIN NÄCHSTER SCHRITT  /  " + Chapter.goal() if not game.dialog.active else "Eigene Worte oder eine konkrete Antwort wählen  ·  Offline"
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
		objective.text = Chapter.goal()
	if game != null and game.mobile_mode and is_instance_valid(dialogue):
		var physical_height = maxf(1, DisplayServer.window_get_size().y)
		var keyboard = DisplayServer.virtual_keyboard_get_height() * root.size.y / physical_height
		dialogue.offset_bottom = -maxf(12, keyboard + 8)
		response_scroll.visible = keyboard <= 0
		dialogue_footer.visible = keyboard <= 0
		speech_scroll.custom_minimum_size.y = 40 if keyboard > 0 else 84

func show_evening() -> void:
	var shared = Chapter.state().activity == "tea"
	var content = open_modal("Ein gemeinsamer Tee" if shared else "Ein Abend für dich")
	content.add_child(label("ZWANZIG MINUTEN SPÄTER" if shared else "ZEHN MINUTEN SPÄTER", 12, MINT))
	content.add_child(label("Mara stellt ihre Tasse ab. »Meine Mutter hat jahrelang aus ihrem Küchenfenster fotografiert. Immer dieselbe Straße. Auf den Bildern konnte ich später sehen, wie unser Zuhause sich verändert hat.«" if shared else "Mara hat sich verabschiedet. Die Wohnung wird still. Zum ersten Mal seit dem Umzug fühlt sich diese Ruhe wie deine eigene Entscheidung an. Mara hat deine Grenze akzeptiert; du schuldest ihr heute kein weiteres Gespräch.", 19))
	if shared:
		content.add_child(label("»Deshalb sammle ich Fenster. Aber für dich ist dieser Balkon keine Bildidee, sondern dein Zuhause. Danke, dass du mir gesagt hast, was davon sichtbar sein darf.«", 18, MUTED))
	content.add_child(label(Chapter.consequence(), 16, MINT))
	content.add_child(button("Den Abend nachklingen lassen", close_modal, true))
	content.add_child(label("Wenn du möchtest, wartet am Spiegel der Kapitelrückblick.", 14, MUTED))
