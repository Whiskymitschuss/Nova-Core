class_name EmotionManager
extends RefCounted

func react(intent: String) -> void:
	var e = State.data.emotions
	match intent:
		"confrontational":
			e.anger = clampf(e.anger + 0.18, 0, 1)
			e.disappointment = clampf(e.disappointment + 0.12, 0, 1)
		"friendly", "humorous":
			e.joy = clampf(e.joy + 0.05, 0, 1)
		"apology":
			e.anger = maxf(0, e.anger - 0.06)
		"honest":
			e.hope = clampf(e.hope + 0.04, 0, 1)

func description() -> String:
	var e = State.data.emotions
	if e.anger > 0.45:
		return "braucht Abstand"
	if e.disappointment > 0.22:
		return "noch nachdenklich"
	if e.joy > 0.35:
		return "zugewandt"
	return "ruhig und neugierig"
