class_name ResponseGenerator
extends RefCounted

const OPTIONS = {
	"arrival": ["Danke, dass du vorbeikommst. Das macht den Anfang leichter.", "Ich fühle mich noch etwas fremd hier.", "Ein Umzug, was soll da schon schiefgehen?", "Mir sind das gerade zu viele Fragen.", "Ich möchte erst einmal ankommen.", "Meine Kartons kennen die Wohnung besser als ich."],
	"mirror": ["Vielleicht können wir das gemeinsam herausfinden.", "Im Spiegel war ich mir kurz selbst fremd.", "Mein Spiegel hat offenbar Philosophie studiert.", "Ich brauche gerade keine Analyse.", "Darüber möchte ich noch nicht sprechen.", "Ich hätte lieber einen Spiegel mit Wetterbericht."],
	"evening": ["Ein gemeinsamer Tee wäre schön.", "Ich bin erschöpft und brauche etwas Ruhe.", "Mein großer Plan: nichts planen.", "Ich entscheide selbst, was ich heute mache.", "Vielleicht bleibe ich heute lieber hier.", "Ich führe ein wichtiges Gespräch mit meinem Sofa."],
	"conflict": ["Ich möchte verstehen, was dich verletzt hat.", "Ich habe dich vorhin unfair behandelt.", "Wir sind wohl beide hervorragend im Aneinandervorbeireden.", "Das ist allein dein Problem.", "Können wir eine Pause machen?", "Vielleicht brauchen wir beide erst einen Tee."],
	"memory": ["Unser letztes Gespräch ist mir wichtig.", "Ich sehe manches inzwischen anders.", "Du vergisst offenbar wirklich nichts.", "Ich will das nicht wieder diskutieren.", "Gib mir noch etwas Zeit dafür.", "Unser Gespräch braucht wohl ein Lesezeichen."],
	"connection": ["Was fotografierst du am liebsten?", "Ich weiß noch nicht, was mir hier fehlen wird.", "Du bist also die Expertin für Neuanfänge?", "Warum willst du das alles wissen?", "Ich höre heute lieber erst einmal zu.", "Vielleicht finde ich hier endlich meine Zimmerpflanzen-Begabung."]}
const INTENTS = ["friendly", "honest", "sarcastic", "confrontational", "reserved", "humorous"]
const LABELS = ["Zugewandt", "Ehrlich", "Sarkastisch", "Konfrontativ", "Zurückhaltend", "Humorvoll"]

func generate(topic: String, turn: int) -> Array:
	var lines = OPTIONS.get(topic, OPTIONS.connection)
	var result = []
	for i in range(6):
		var text = lines[i]
		if turn > 0:
			var alternatives = ["Was ist dir dabei wichtig?", "Ich möchte ehrlich bleiben, auch wenn es schwer ist.", "Wir machen es uns wirklich nicht leicht.", "Ich finde deine Sicht unfair.", "Ich möchte das in Ruhe überdenken.", "Ein kleiner Neustart wäre jetzt praktisch."]
			var other = ["Ich höre dir zu. Erzähl weiter.", "Ich bin mir noch unsicher, was ich brauche.", "Das Leben liefert leider keine Anleitung mit.", "Du hörst mir gerade überhaupt nicht zu.", "Lass uns später weiterreden.", "Zum Glück gibt es für Gespräche keine Noten."]
			text = alternatives[i] if turn % 2 == 1 else other[i]
		result.append({"intent": INTENTS[i], "label": LABELS[i], "text": text})
	return result

func classify(text: String) -> String:
	# Deliberately conservative pattern rules, NOT an inference of real intentions.
	var lower = text.to_lower()
	if lower.contains("tut mir leid") or lower.contains("entschuldigung") or lower.contains("unfair behandelt"):
		return "apology"
	for insult in ["idiot", "halt die klappe", "allein dein problem", "blöd", "dumm"]:
		if lower.contains(insult) and not lower.contains("nicht") and not lower.contains("kein"):
			return "confrontational"
	if lower.contains("danke"):
		return "friendly"
	return "unknown"
