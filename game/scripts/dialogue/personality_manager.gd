class_name PersonalityManager
extends RefCounted

func observe(intent: String) -> void:
	match intent:
		"friendly": State.observe("Empathie", 0.7)
		"honest": State.observe("Ehrlichkeit", 0.7)
		"reserved": State.observe("Selbstreflexion", 0.3)
		"confrontational": State.observe("Konfliktbereitschaft", 0.7)
		"humorous": State.observe("Kommunikation", 0.5)
	State.data.decisions += 1
