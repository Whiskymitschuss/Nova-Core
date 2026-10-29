class_name ContextManager
extends RefCounted

func gather(speaker: String, location: String) -> Dictionary:
	return {"speaker": speaker, "location": location, "hour": int(State.data.minutes / 60) % 24,
		"relationship": State.data.relationship.duplicate(), "emotions": State.data.emotions.duplicate(),
		"history": ConversationMemory.new().recent(), "conversations": State.data.conversations,
		"mirror": State.data.mirror_seen, "goal": "Ein ehrliches Kennenlernen, ohne Druck.",
		"personality": {"name": "Mara", "age": 28, "patience": 0.8, "assertiveness": 0.7,
		"interests": ["Fotografie", "Architektur", "ruhige Gespräche"], "dislikes": ["Beleidigungen", "Druck"]}}
