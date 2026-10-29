class_name DialogueManager
extends RefCounted
var generator = DialogueGenerator.new()
var responses = ResponseGenerator.new()
var memory = ConversationMemory.new()
var emotions = EmotionManager.new()
var relationships = RelationshipManager.new()
var personality = PersonalityManager.new()
var active = false
var speaker = "Mara"
var topic = "arrival"
var turn = 0
var rewarded = 0
var opening_text = ""
var seen_intents: Array = []
var chapter_mode = true

func begin(who: String, location: String = "Apartment") -> String:
	speaker = who
	turn = 0
	rewarded = 0
	seen_intents.clear()
	if speaker == "Mara" and State.data.minutes < State.data.boundary_until:
		active = false
		return "Ich brauche gerade Abstand. Bitte lass uns später weiterreden."
	active = true
	if chapter_mode:
		if speaker == "META ME": State.data.mirror_seen = true
		else: State.data.conversations += 1
		topic = "chapter"
		opening_text = Chapter.opening(speaker)
		return opening_text
	if speaker == "META ME":
		topic = "mirror"
		State.data.mirror_seen = true
		State.observe("Selbstreflexion", 1)
		opening_text = "Kennst du dich eigentlich wirklich? Ich bin META ME, dein virtuelles Gegenüber. Wir können gemeinsam auf deine Spielentscheidungen schauen. Wenn du möchtest: Was ist dir bei diesem Neuanfang wichtig?"
		if State.data.decisions > 0:
			opening_text = "Du hast hier bereits Entscheidungen getroffen. Das beschreibt deine Spielgeschichte, nicht deine echte Persönlichkeit. Möchtest du auf dein Gespräch mit Mara zurückblicken? Was war dir dabei wichtig?"
			if State.data.relationship.tension >= 10:
				opening_text = "Dein Spielgespräch mit Mara wurde angespannt. Wenn du möchtest, können wir gemeinsam darauf zurückblicken. Warst du mit deiner Antwort zufrieden? Du kannst die Reflexion jederzeit beenden."
	else:
		var context = ContextManager.new().gather(speaker, location)
		var result = generator.opening(context)
		topic = result.topic
		opening_text = result.text
		State.data.conversations += 1
		if not State.data.topics_seen.has(topic):
			State.data.topics_seen.append(topic)
	State.changed.emit()
	return opening_text

func options() -> Array:
	return Chapter.options(speaker, turn) if chapter_mode else responses.generate(topic, turn)

func answer(text: String, intent: String = "free") -> String:
	if not active:
		return "Dieses Gespräch ist beendet."
	text = text.strip_edges().left(500)
	if text.is_empty():
		return "Nimm dir ruhig einen Moment."
	if chapter_mode:
		if speaker == "Mara" and intent == "free" and responses.classify(text) == "confrontational":
			relationships.apply("confrontational", false)
			emotions.react("confrontational")
			turn += 1
			if State.data.relationship.tension >= 20:
				State.data.boundary_until = State.data.minutes + 12
				active = false
				Chapter.record("insult_boundary", "Mara beendet das Gespräch nach wiederholten Beleidigungen.", "conflict")
				return "Ich beende das Gespräch jetzt. Nach diesen Beleidigungen brauche ich Abstand. Wir können später über das Foto weiterreden."
			Chapter.record("insult", "Du beleidigst Mara. Sie verlangt einen respektvollen Umgang.", "conflict")
			return "So möchte ich nicht angesprochen werden. Wir können über das Foto sprechen, wenn wir respektvoll bleiben."
		var result = Chapter.respond(speaker, text, intent, turn)
		turn += 1
		active = not result.done
		return result.text
	if intent == "free":
		intent = responses.classify(text)
	if speaker == "META ME":
		State.observe("Selbstreflexion", 0.2)
		if State.remember_text:
			State.data.journal.append(text)
			if State.data.journal.size() > 80:
				State.data.journal.pop_front()
		turn += 1
		return "Danke, dass du dir den Moment nimmst. Nur du kannst sagen, was deine Antwort für dich bedeutet. Du kannst deine Einträge im Tagebuch ansehen oder löschen. Möchtest du noch etwas ergänzen?"
	var reward_key = "%d:%s:%s" % [int(State.data.minutes / 1440), topic, intent]
	var allow_growth = rewarded < 3 and not seen_intents.has(intent) and turn < 8 and not State.data.relationship_rewards.has(reward_key)
	if allow_growth:
		State.data.relationship_rewards.append(reward_key)
		if State.data.relationship_rewards.size() > 200: State.data.relationship_rewards.pop_front()
	relationships.apply(intent, allow_growth)
	emotions.react(intent)
	if allow_growth:
		personality.observe(intent)
		rewarded += 1
		seen_intents.append(intent)
	var summaries = {"friendly": "Du hast Mara zugehört und ihr Zugewandtheit gezeigt.",
		"honest": "Du hast Mara offen geantwortet.", "sarcastic": "Du hast eine sarkastische Antwort gewählt.",
		"confrontational": "Euer Gespräch wurde angespannt.", "reserved": "Du hast dir im Gespräch Freiraum gewünscht.",
		"humorous": "Du hast Humor in euer Gespräch gebracht.", "apology": "Du hast Mara um Entschuldigung gebeten.",
		"unknown": "Du hast eine eigene Antwort formuliert. Ihre Bedeutung blieb offen."}
	var summary: String = summaries.get(intent, summaries.unknown)
	if State.remember_text:
		summary += " Deine Antwort: " + text
	memory.remember(summary, 3.0 if intent == "confrontational" else 1.0)
	var reply = generator.reply(intent, text, turn)
	turn += 1
	if State.data.relationship.tension >= 20:
		State.data.boundary_until = State.data.minutes + 12.0
		active = false
		reply = "Ich beende dieses Gespräch jetzt. Bitte respektiere meine Grenze. Wir können später schauen, ob wir wieder miteinander sprechen möchten."
	State.changed.emit()
	return reply

func end() -> void:
	active = false
