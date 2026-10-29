class_name StoryDiagram
extends Control
## Resolution-independent diagrams drawn from persisted events, never sample data.
signal event_selected(index: int)
var selected = -1
var mode = "relationship"
var crop = false
const GOLD = Color("e9bd81")
const SOFT = Color("9ba9bb")
const WHITE = Color("f3eee6")
const BLUE = Color("7db5cb")
const RED = Color("da8d81")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP if mode == "relationship" else Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func text_at(point: Vector2, text: String, color: Color = SOFT, font_size: int = 14) -> void:
	draw_string(get_theme_default_font(), point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw() -> void:
	match mode:
		"flow": draw_flow()
		"map": draw_map()
		"photo": draw_photo()
		"choices": draw_choices()
		"cover": draw_cover()
		_: draw_relationship()

func draw_relationship() -> void:
	var bounds = Rect2(55, 32, size.x - 78, size.y - 78)
	for i in range(3):
		var y = bounds.position.y + bounds.size.y * i / 2
		draw_line(Vector2(bounds.position.x, y), Vector2(bounds.end.x, y), Color("293344"), 1)
	text_at(Vector2(2, 36), "hoch", SOFT, 12)
	text_at(Vector2(2, bounds.end.y), "niedrig", SOFT, 12)
	var events: Array = Chapter.state().events
	if events.is_empty():
		text_at(Vector2(70, 96), "Noch kein Verlauf. Triff deine erste Entscheidung.")
		return
	for series in [["trust", BLUE], ["tension", RED]]:
		var points = PackedVector2Array()
		for i in range(events.size()):
			var x = bounds.position.x + bounds.size.x * i / maxi(1, events.size() - 1)
			var y = bounds.end.y - bounds.size.y * clampf(events[i][series[0]], 0, 100) / 100.0
			points.append(Vector2(x, y))
		if points.size() > 1: draw_polyline(points, series[1], 2.5, true)
		for point in points: draw_circle(point, 4, series[1], true, -1, true)
	if selected >= 0 and selected < events.size():
		var x = bounds.position.x + bounds.size.x * selected / maxi(1, events.size() - 1)
		draw_line(Vector2(x, bounds.position.y), Vector2(x, bounds.end.y), GOLD, 1, true)
	text_at(Vector2(55, size.y - 18), "Erste Entscheidung", SOFT, 12)
	text_at(Vector2(size.x - 128, size.y - 18), "Zuletzt", SOFT, 12)

func draw_flow() -> void:
	var labels = ["Ankommen", "Bild", "Absprechen", "Handeln", "Rückblick"]
	var current = Chapter.index()
	for i in range(5):
		var x = 40 + (size.x - 80) * i / 4
		var y = 26.0
		var complete = current > i
		if i < 4:
			draw_line(Vector2(x + 12, y), Vector2(x + (size.x - 80) / 4 - 12, y), GOLD if complete else Color("354052"), 2, true)
		draw_circle(Vector2(x, y), 9, GOLD if complete else Color("263246"), true, -1, true)
		if i == 1 and Chapter.state().choice == "private":
			draw_line(Vector2(x - 6, y + 6), Vector2(x + 6, y - 6), Color("121b2a"), 2, true)
		if current == i: draw_arc(Vector2(x, y), 13, 0, TAU, 40, GOLD, 2, true)
		text_at(Vector2(x - 30, 61), labels[i], WHITE if complete or current == i else SOFT, 12)
	if Chapter.state().choice == "private": text_at(Vector2(18, 88), "Privat halten überspringt die Bildprüfung.", SOFT, 12)

func draw_choices() -> void:
	var counts = {"question": 0, "boundary": 0, "connection": 0, "conflict": 0}
	for event in Chapter.state().events:
		if counts.has(event.kind): counts[event.kind] += 1
	var titles = {"question": "Nachgefragt", "boundary": "Grenze gesetzt", "connection": "Nähe angeboten", "conflict": "Vorwurf gemacht"}
	var max_count = 1
	for value in counts.values(): max_count = maxi(max_count, value)
	var i = 0
	for key in counts:
		var y = 20 + i * 40
		text_at(Vector2(0, y), titles[key], WHITE, 13)
		var width = maxf(40, size.x - 200)
		draw_rect(Rect2(160, y - 13, width, 12), Color("263246"))
		if counts[key] > 0: draw_rect(Rect2(160, y - 13, width * counts[key] / max_count, 12), GOLD)
		text_at(Vector2(170 + width, y), str(counts[key]), SOFT, 13)
		i += 1

func draw_map() -> void:
	var sx = size.x / 640.0
	var sy = size.y / 370.0
	var rooms = [Rect2(12, 12, 196, 148), Rect2(12, 172, 196, 130), Rect2(220, 12, 408, 148), Rect2(220, 172, 408, 130), Rect2(330, 314, 210, 44)]
	var names = ["Schlafzimmer", "Bad", "Küche / Arbeitsplatz", "Wohnzimmer", "Balkon"]
	for i in range(rooms.size()):
		var r: Rect2 = rooms[i]
		r = Rect2(r.position * Vector2(sx, sy), r.size * Vector2(sx, sy))
		draw_rect(r, Color("1b2738"), true)
		draw_rect(r, Color("495063"), false, 1.5)
		text_at(r.position + Vector2(12, 23), names[i], SOFT, 12)
	var positions = {"computer": Vector2(300, 87), "tea": Vector2(490, 100), "mirror": Vector2(258, 244), "sofa": Vector2(445, 245), "Mara": Vector2(530, 242)}
	var captions = {"computer": "Foto", "tea": "Tee", "mirror": "Spiegel", "sofa": "Sofa", "Mara": "Mara"}
	for key in positions:
		var pos: Vector2 = positions[key] * Vector2(sx, sy)
		var active = key == Chapter.destination()
		draw_circle(pos, 5, GOLD if active else BLUE, true, -1, true)
		if active: draw_arc(pos, 11, 0, TAU, 32, GOLD, 2, true)
		text_at(pos + Vector2(10, 5), captions[key], GOLD if active else WHITE, 12)

func draw_photo() -> void:
	# Authored illustration of the exact privacy issue the player decides on.
	var r = Rect2(0, 0, size.x, size.y)
	draw_rect(r, Color("665d71"))
	draw_rect(Rect2(0, size.y * 0.6, size.x, size.y * 0.4), Color("30384a"))
	draw_circle(Vector2(size.x * 0.76, size.y * 0.28), 29, GOLD)
	for i in range(8):
		var x = size.x * i / 8
		draw_rect(Rect2(x, size.y * 0.35, size.x / 11, size.y * 0.28), Color("404456"))
	draw_rect(Rect2(size.x * 0.14, 13, size.x * 0.48, size.y - 26), Color("e0c1a1"), false, 8)
	draw_line(Vector2(size.x * 0.38, 13), Vector2(size.x * 0.38, size.y - 13), Color("b89e8a"), 4)
	if not crop:
		var box = Rect2(size.x * 0.63, size.y * 0.61, size.x * 0.32, size.y * 0.33)
		draw_rect(box, Color("a38263"))
		draw_rect(Rect2(box.position + Vector2(10, 10), box.size - Vector2(20, 20)), WHITE)
		text_at(box.position + Vector2(16, 29), State.data.avatar.name.to_upper().left(12) + " / ADRESSE", Color("393b48"), 12)
		draw_rect(box.grow(4), RED, false, 2)
	else:
		draw_rect(Rect2(size.x * 0.63, 0, size.x * 0.37, size.y), Color("101826"))
		draw_line(Vector2(size.x * 0.63, 0), Vector2(size.x * 0.63, size.y), GOLD, 2)
		text_at(Vector2(size.x * 0.67, size.y * 0.65), "Entfernt", GOLD, 13)

func draw_cover() -> void:
	var center = size * Vector2(0.58, 0.48)
	for i in range(7):
		draw_arc(center, 54 + i * 30, -PI * 0.85, PI * 0.8, 100, Color(0.91, 0.74, 0.51, 0.26 - i * 0.025), 1.4, true)
	draw_line(center + Vector2(-140, 100), center + Vector2(100, -140), GOLD, 2, true)
	draw_circle(center, 9, GOLD, true, -1, true)

func _gui_input(event: InputEvent) -> void:
	if mode != "relationship" or Chapter.state().events.is_empty(): return
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		selected = clampi(roundi((event.position.x - 55) / maxf(1, size.x - 78) * (Chapter.state().events.size() - 1)), 0, Chapter.state().events.size() - 1)
		event_selected.emit(selected)
		queue_redraw()
		accept_event()
