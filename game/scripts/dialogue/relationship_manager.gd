class_name RelationshipManager
extends RefCounted

func apply(intent: String, allow_growth: bool) -> void:
	var r = State.data.relationship
	match intent:
		"confrontational":
			r.trust -= 3
			r.respect -= 2
			r.tension += 7
		"sarcastic":
			r.tension += 1
		"apology":
			r.tension -= 2
			if allow_growth:
				r.trust += 0.5
		"friendly", "honest", "humorous":
			if allow_growth:
				r.trust += 1.5 if r.tension < 10 else 0.25
				r.respect += 1
		"reserved":
			r.tension -= 0.5
	if allow_growth:
		r.familiarity += 2
	for key in r:
		r[key] = clampf(r[key], 0, 100)
