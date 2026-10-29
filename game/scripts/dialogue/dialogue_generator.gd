class_name DialogueGenerator
extends RefCounted

func opening(context: Dictionary) -> Dictionary:
	var topic = "connection"
	if context.relationship.tension >= 10:
		topic = "conflict"
	elif context.conversations == 0:
		topic = "arrival"
	elif context.mirror and not State.data.topics_seen.has("mirror"):
		topic = "mirror"
	elif context.hour >= 18 and not State.data.topics_seen.has("evening"):
		topic = "evening"
	elif not context.history.is_empty() and context.conversations % 2 == 0:
		topic = "memory"
	var openings = {
		"arrival": "Hey, ich bin Mara, deine Nachbarin. Du bist gerade erst eingezogen, oder? Wie fühlt sich dieser Neuanfang für dich an?",
		"mirror": "Du standest gerade lange vor dem Spiegel. Hat dich etwas beschäftigt? Du musst nichts erzählen, wenn du nicht möchtest.",
		"evening": "Draußen wird es langsam ruhig. Möchtest du den Abend für dich haben oder noch einen Tee zusammen trinken?",
		"conflict": "Unser Gespräch hat mich verletzt. Ich möchte reden, aber ich brauche einen respektvollen Umgang. Wie siehst du das?",
		"memory": "Ich habe unser letztes Gespräch nicht vergessen. Ist dir seitdem noch etwas dazu eingefallen?",
		"connection": "Ich fotografiere gern kleine Dinge, die man sonst übersieht. Gibt es etwas, das dir in einer neuen Umgebung zuerst auffällt?"}
	if topic == "memory":
		var remembered: String = context.history.get_slice(" Deine Antwort:", 0).left(180)
		openings.memory = "Ich erinnere mich an unser Gespräch. In deinem Tagebuch steht: „%s“ Ist dir seitdem noch etwas dazu eingefallen?" % remembered
	return {"topic": topic, "text": openings[topic]}

func reply(intent: String, text: String, turn: int) -> String:
	var tense = State.data.relationship.tension > 9
	var variants = {
		"friendly": ["Danke, dass du mir zuhörst. Was würde dir helfen, hier anzukommen?", "Das bedeutet mir etwas. Was wünschst du dir von unserem Miteinander?"],
		"honest": ["Danke für deine Offenheit. Du musst hier keine fertigen Antworten haben. Was brauchst du gerade?", "Ich schätze es, dass du das aussprichst. Möchtest du mehr davon erzählen?"],
		"sarcastic": ["Ich höre den Sarkasmus. Ich bin nicht sicher, ob du gerade Abstand brauchst. Magst du es mir sagen?", "Ich kann darüber schmunzeln. Trotzdem würde ich gern wissen, was du meinst."],
		"confrontational": ["So möchte ich nicht angesprochen werden. Wir können anderer Meinung sein und trotzdem respektvoll bleiben.", "Das trifft mich. Ich brauche einen Moment Abstand, wenn das so weitergeht."],
		"reserved": ["Das ist in Ordnung. Du musst dich nicht erklären. Wollen wir das Gespräch für heute beenden?", "Nimm dir die Zeit, die du brauchst. Wir können auch einfach einen Moment still sein."],
		"humorous": ["Okay, das hat mich zum Lächeln gebracht. Ein wenig Leichtigkeit tut gut. Was beschäftigt dich sonst?", "Den Humor behalten wir. Und falls darunter etwas Ernstes steckt, höre ich auch zu."],
		"apology": ["Danke für die Entschuldigung. Ich brauche trotzdem Zeit. Was würdest du beim nächsten Gespräch anders machen?", "Ich höre dich. Vertrauen wächst für mich durch das, was nach der Entschuldigung passiert."],
		"unknown": ["Ich möchte dir nichts in den Mund legen. Was bedeutet das für dich gerade?", "Ich bin nicht sicher, ob ich dich richtig verstehe. Möchtest du mir das anders beschreiben?"]}
	var response: String = variants[intent][turn % 2]
	if tense and intent in ["friendly", "humorous"]:
		response = "Ich sehe, dass du auf mich zugehst. Das von vorhin beschäftigt mich aber noch. Geben wir uns etwas Zeit?"
	if intent == "unknown" and text.to_lower().contains("fotograf"):
		response = "Am liebsten fotografiere ich Licht in leeren Straßen. Es erinnert mich daran, kurz langsamer zu werden. Was lässt dich innehalten?"
	return response
