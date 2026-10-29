extends Node
## Serializable simulation state. Values describe game choices, never a real person.
signal changed

const VERSION = 1
const TRAITS = ["Offenheit", "Empathie", "Selbstvertrauen", "Konfliktbereitschaft", "Vertrauen", "Hilfsbereitschaft", "Ehrlichkeit", "Risikobereitschaft", "Kommunikation", "Selbstreflexion"]
var data: Dictionary
var remember_text = false

func _ready() -> void:
	reset()

func reset() -> void:
	var traits = {}
	for key in TRAITS:
		traits[key] = 50.0
	data = {"version": VERSION, "avatar": {"name": "Alex", "skin": "c89473", "outfit": "699d99", "hair": "322c2c"},
		"position": [0.8, 0.08, 2.8], "yaw": 0.0, "pitch": -0.22, "minutes": 17.0 * 60.0 + 20.0,
		"traits": traits, "relationship": {"trust": 30.0, "respect": 45.0, "familiarity": 0.0, "tension": 0.0},
		"emotions": {"joy": 0.2, "anger": 0.0, "disappointment": 0.0, "hope": 0.4},
		"memories": [], "journal": [], "decisions": 0, "conversations": 0, "mirror_seen": false,
		"lamp_on": true, "door_open": false, "saved_once": false, "topics_seen": [], "boundary_until": 0.0,
		"npc_position": [4.3, 0.06, 0.85], "npc_target": 0, "remember_text": remember_text}
	changed.emit()

func tick(delta: float) -> void:
	data.minutes += delta * 0.35
	data.emotions.anger = maxf(0.0, data.emotions.anger - delta * 0.0015)
	data.emotions.disappointment = maxf(0.0, data.emotions.disappointment - delta * 0.00015)

func clock_text() -> String:
	var m = int(data.minutes) % 1440
	return "%02d:%02d" % [m / 60, m % 60]

func snapshot() -> Dictionary:
	data.remember_text = remember_text
	return data.duplicate(true)

func restore(value: Dictionary) -> void:
	data = value.duplicate(true)
	remember_text = data.get("remember_text", false)
	changed.emit()

func observe(trait_name: String, amount: float) -> void:
	if data.traits.has(trait_name):
		data.traits[trait_name] = clampf(data.traits[trait_name] + amount, 0.0, 100.0)
