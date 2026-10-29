class_name ConversationMemory
extends RefCounted

func remember(summary: String, importance: float = 1.0) -> void:
	var memory = State.data.memories
	memory.append({"summary": summary.left(400), "minute": State.data.minutes, "importance": importance})
	if memory.size() > 80:
		var lowest = 0
		for i in range(memory.size()):
			if memory[i].importance < memory[lowest].importance:
				lowest = i
		memory.remove_at(lowest)

func recent() -> String:
	if State.data.memories.is_empty():
		return ""
	return State.data.memories.back().summary
