class_name Chapter
extends RefCounted
## Authored chapter: explicit transitions, permanent choices, finite conversations.
const STAGES = ["invitation", "review", "agreement", "action", "reflection", "complete"]
const TITLES = ["Ein unerwarteter Besuch", "Wem gehört dieses Bild?", "Eine klare Vereinbarung", "Worte werden Handlungen", "Was bleibt von diesem Abend?", "Ein Bild von Zuhause"]
const DEFAULT = {"stage": "invitation", "choice": "", "approach": "", "activity": "", "reflection": "", "events": [], "rewards": []}

static func state() -> Dictionary:
	return State.data.chapter

static func index() -> int:
	return STAGES.find(state().stage)

static func title() -> String:
	return TITLES[maxi(0, index())]

static func goal() -> String:
	match state().stage:
		"invitation": return "Sprich mit Mara im Wohnzimmer. Sie hat eine Bitte."
		"review": return "Prüfe Maras Foto am Computer in der Küche."
		"agreement": return "Besprich deine Entscheidung mit Mara."
		"action":
			return "Nimm dir auf dem Sofa deinen Abend." if state().activity == "solo" else "Bereite in der Küche Tee für euch beide zu."
		"reflection": return "Kehre zum Spiegel zurück. Entscheide, was dir bleibt."
	return "Der Abend ist abgeschlossen. Sieh dir deine Spuren an."

static func destination() -> String:
	match state().stage:
		"invitation", "agreement": return "Mara"
		"review": return "computer"
		"action": return "sofa" if state().activity == "solo" else "tea"
		"reflection": return "mirror"
	return ""

static func record(id: String, caption: String, kind: String, intent: String = "") -> void:
	for event in state().events:
		if event.id == id:
			return
	var allowed = not state().rewards.has(id)
	if not intent.is_empty() and allowed:
		RelationshipManager.new().apply(intent, true)
		EmotionManager.new().react(intent)
		PersonalityManager.new().observe(intent)
		state().rewards.append(id)
		State.data.decisions += 1
	state().events.append({"id": id, "caption": caption, "kind": kind, "minute": State.data.minutes,
		"trust": State.data.relationship.trust, "tension": State.data.relationship.tension})
	ConversationMemory.new().remember(caption, 3)
	State.changed.emit()

static func advance(stage: String) -> void:
	state().stage = stage
	State.changed.emit()

static func option(id: String, caption: String, text: String) -> Dictionary:
	return {"intent": id, "label": caption, "text": text}

static func options(speaker: String, turn: int) -> Array:
	if speaker == "META ME":
		if state().stage == "reflection":
			return [option("reflect_boundary", "Meine Grenze", "Ich darf entscheiden, was von mir sichtbar wird."),
				option("reflect_connection", "Verbindung", "Nähe entsteht, wenn wir einander wirklich fragen."),
				option("reflect_repair", "Verantwortung", "Ich will meine Worte an meinen Handlungen messen."), option("reflect_skip", "Für heute genug", "Ich lasse den Abend für sich stehen.")]
		return [option("mirror_goal", "Orientierung", "Was kann ich heute konkret tun?"), option("mirror_leave", "Später", "Ich möchte den Abend erst erleben.")]
	match state().stage:
		"invitation":
			if turn == 0:
				return [option("invite_review", "Erst ansehen", "Zeig mir bitte erst das Foto."), option("invite_ask", "Nachfragen", "Warum ist dir gerade dieses Bild wichtig?"),
					option("invite_boundary", "Grenze setzen", "Meine Wohnung soll privat bleiben."), option("invite_honest", "Offen sein", "Ich bin noch nicht angekommen. Gib mir einen Moment."),
					option("invite_humor", "Leichtigkeit", "Meine Umzugskartons werden also schon berühmt?"), option("invite_conflict", "Vorwurf", "Du fotografierst meine Wohnung, ohne mich zu fragen?")]
			return [option("invite_review", "Gemeinsam prüfen", "Ich will sehen, was auf dem Bild erkennbar ist."), option("invite_boundary", "Privat halten", "Ich möchte das Foto nicht öffentlich zeigen.")]
		"review": return [option("go_review", "Zum Computer", "Ich sehe mir das Bild am Computer an.")]
		"agreement":
			return [option("agree_tea", "Zeit miteinander", "Lass uns bei einem Tee über deinen Blick auf die Stadt reden."),
				option("agree_solo", "Zeit für mich", "Danke, dass du meine Entscheidung respektierst. Heute brauche ich Ruhe."),
				option("agree_apology", "Etwas klären", "Mein Ton vorhin war unfair. Tut mir leid. Bleibst du auf einen Tee?")]
		"action": return [option("go_action", "Vereinbarung einlösen", goal())]
		"reflection": return [option("go_reflect", "Zum Spiegel", "Ich lasse den Abend erst einmal auf mich wirken.")]
	return [option("epilogue", "Auf den Abend zurückblicken", "Was ist dir von heute geblieben?")]

static func opening(speaker: String) -> String:
	if speaker == "META ME":
		if state().stage == "reflection":
			return "Heute ging es um ein Foto. Eigentlich ging es darum, wer über dein Zuhause entscheidet. %s Was möchtest du aus diesem Abend mitnehmen?" % consequence()
		return "Ein neuer Ort wird durch Entscheidungen zu deinem Zuhause. Mara hat ein Bild mitgebracht und braucht deine Antwort. Du musst dich nicht bewerten lassen. Was brauchst du gerade?"
	match state().stage:
		"invitation": return "Hey, ich bin Mara von nebenan. Für unsere kleine Hofausstellung habe ich das Abendlicht an deinem Balkon fotografiert. Erst danach habe ich die Umzugskartons im Bild gesehen. Bevor ich es zeige: Möchtest du es mit mir ansehen?"
		"review": return "Das Foto ist auf deinem Computer geöffnet. Auf dem Karton steht deine Adresse. Schau es dir in Ruhe an; ohne deine Entscheidung geht es nicht in die Ausstellung."
		"agreement": return "%s Mir war das Licht wichtig, aber es ist dein Zuhause. Wie möchtest du den Abend jetzt verbringen?" % consequence()
		"action": return "Ich lasse dir den Abend. Wir sehen uns morgen." if state().activity == "solo" else "Ich warte hier, während du den Tee machst. Danach erzähle ich dir, warum ich diese stillen Fenster fotografiere."
		"reflection": return "Danke für den Abend. Du hast gesagt, was du brauchst, und es auch getan. Vielleicht sehen wir uns morgen im Hof."
	return "Ich denke noch an heute. %s %s" % [consequence(), "Morgen frage ich dich erst, bevor ich die Kamera hebe." if state().choice == "private" else "Für die Ausstellung gilt genau die Fassung, die du freigegeben hast."]

static func respond(speaker: String, text: String, intent: String, turn: int) -> Dictionary:
	if intent == "free":
		intent = classify(text)
	if speaker == "META ME":
		if State.remember_text:
			State.data.journal.append(text)
			if State.data.journal.size() > 80: State.data.journal.pop_front()
		if state().stage == "reflection" and intent.begins_with("reflect_"):
			state().reflection = intent
			record("reflection", {"reflect_boundary": "Du nimmst deine selbst gesetzte Grenze mit.", "reflect_connection": "Du nimmst das gegenseitige Fragen mit.", "reflect_repair": "Du nimmst Verantwortung für Worte und Handlungen mit.", "reflect_skip": "Du lässt den Abend ohne weitere Reflexion stehen."}[intent], "reflection")
			advance("complete")
			return {"text": "Der Abend gehört jetzt zu deiner Geschichte. %s Dein Kapitelrückblick verbindet jede Entwicklung mit deiner Entscheidung. Du kannst die Wohnung weiter erkunden." % consequence(), "done": true}
		if state().stage == "reflection":
			return {"text": "Was möchtest du konkret festhalten? Wähle unten Grenze, Verbindung oder Verantwortung; ich deute deinen Text nicht automatisch als Entscheidung.", "done": false}
		return {"text": goal(), "done": true}
	match state().stage:
		"invitation":
			match intent:
				"invite_review":
					record("invitation", "Du möchtest das Bild prüfen, bevor du zustimmst.", "question", "friendly")
					advance("review")
					return {"text": "Ja. Du findest das Foto am Computer in der Küche. Achte auf den Karton unten rechts. Du entscheidest dort, ob und in welcher Form ich es zeigen darf.", "done": true}
				"invite_boundary":
					state().choice = "private"
					record("invitation", "Du setzt eine klare Grenze: Die Wohnung bleibt privat.", "boundary", "reserved")
					advance("agreement")
					return {"text": "In Ordnung. Das Foto kommt nicht in die Ausstellung. Ich habe die öffentliche Fassung zurückgezogen. Danke, dass du es klar sagst. Möchtest du trotzdem einen Tee zusammen trinken oder lieber allein sein?", "done": false}
				"invite_ask": return {"text": "In vielen Fenstern sehe ich Menschen, die ich kaum kenne. Ich wollte zeigen, wie nah wir wohnen und wie wenig wir voneinander wissen. Aber dein Name gehört nicht ungefragt an eine Ausstellungswand. Möchtest du das Bild prüfen?", "done": false}
				"invite_humor": return {"text": "Die Kartons hätten schon einen Künstlernamen. Aber auf einem steht dein echter Name. Deshalb ist deine Zustimmung keine Kleinigkeit. Sehen wir es uns an?", "done": false}
				"invite_honest": return {"text": "Dann machen wir langsam. Ich zeige nichts ohne deine Entscheidung. Du kannst es ansehen oder die Veröffentlichung einfach ablehnen.", "done": false}
				"invite_conflict":
					state().approach = "conflict"
					record("conflict", "Du wirfst Mara vor, deine Privatsphäre übergangen zu haben.", "conflict", "confrontational")
					return {"text": "Du hast recht, ich hätte zuerst fragen sollen. Der Vorwurf trifft mich trotzdem. Das Foto wurde nicht veröffentlicht. Lass uns konkret entscheiden: ansehen oder privat halten?", "done": false}
		"review": return {"text": "Am Computer in der Küche kannst du Original und Ausschnitt prüfen. Dort legst du fest, welche Fassung ich verwenden darf.", "done": true}
		"agreement":
			if intent in ["agree_tea", "agree_solo", "agree_apology"]:
				state().activity = "solo" if intent == "agree_solo" else "tea"
				var caption = "Du entscheidest dich für einen ruhigen Abend allein." if state().activity == "solo" else "Du lädst Mara zu einem gemeinsamen Tee ein."
				var effect = "reserved" if state().activity == "solo" else ("apology" if intent == "agree_apology" else "friendly")
				record("agreement", caption, "boundary" if state().activity == "solo" else "connection", effect)
				advance("action")
				var reply = "Dann lasse ich dir deinen Abend. Mach es dir auf dem Sofa bequem. Danke für die klare Antwort."
				if state().activity == "tea":
					reply = "Gern. Bereite den Tee in der Küche zu; ich bleibe im Wohnzimmer. Ich erzähle dir danach von dem Fenster meiner Mutter, das mich zu dieser Reihe gebracht hat."
					if intent == "agree_apology": reply = "Danke für die Entschuldigung. Ich brauche etwas Zeit, aber der Tee ist ein Anfang. Ich warte im Wohnzimmer."
				return {"text": reply, "done": true}
		"action", "reflection", "complete": return {"text": opening("Mara"), "done": true}
	return {"text": "Damit ich dich richtig verstehe: Geht es dir um das Foto oder darum, wie du den Abend verbringen möchtest? Wähle eine der konkreten Möglichkeiten unten. Deine Entscheidung bleibt offen.", "done": false}

static func classify(text: String) -> String:
	var lower = text.to_lower().strip_edges()
	# Exact authored sentences plus explicit phrases; ambiguity never grants consent.
	for who in ["Mara", "META ME"]:
		for turn in [0, 1]:
			for item in options(who, turn):
				if lower == item.text.to_lower(): return item.intent
	if state().stage == "invitation":
		if lower in ["foto ansehen", "bild ansehen", "zeig mir das foto"]: return "invite_review"
		if lower in ["privat halten", "keine veröffentlichung", "bitte nicht veröffentlichen"]: return "invite_boundary"
	if state().stage == "agreement":
		if lower in ["gemeinsam tee trinken", "lass uns tee trinken"]: return "agree_tea"
		if lower in ["ich möchte allein sein", "ich brauche ruhe"]: return "agree_solo"
	return "unknown"

static func choose_photo(choice: String) -> bool:
	if state().stage != "review" or choice not in ["crop", "share", "private"]: return false
	state().choice = choice
	record("photo", {"crop": "Du gibst nur den Ausschnitt ohne Namen und Adresse frei.", "share": "Du gibst das Original mit sichtbarem Adressetikett ausdrücklich frei.", "private": "Du gibst keine Fassung zur Veröffentlichung frei."}[choice], "boundary" if choice == "private" else "decision")
	advance("agreement")
	return true

static func act(kind: String) -> bool:
	if state().stage != "action" or kind != ("sofa" if state().activity == "solo" else "tea"): return false
	record("action", "Du nimmst dir den vereinbarten Abend auf dem Sofa." if kind == "sofa" else "Beim Tee erzählt Mara vom Fenster ihrer Mutter. Das Foto war für sie eine Erinnerung, für dich eine Frage der Privatsphäre.", "action", "reserved" if kind == "sofa" else "honest")
	advance("reflection")
	return true

static func consequence() -> String:
	match state().choice:
		"crop": return "Mara zeigt nur den freigegebenen Ausschnitt. Name und Adresse bleiben unsichtbar."
		"share": return "Mara darf das Original zeigen. Dein Adressetikett bleibt darauf erkennbar."
		"private": return "Dein Zuhause bleibt privat. Mara nimmt ein anderes Bild für die Ausstellung."
	return "Über das Bild wurde noch nicht entschieden."

static func skip_reflection() -> bool:
	if state().stage != "reflection": return false
	state().reflection = "reflect_skip"
	record("reflection", "Du lässt den Abend ohne weitere Reflexion stehen.", "reflection")
	advance("complete")
	return true
