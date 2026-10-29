
# MASTER DEVELOPMENT PROMPT
# PROJECT: META ME
# VERSION: 1.0
# GENRE: AI LIFE SIMULATION / PSYCHOLOGICAL RPG / SOCIAL SIMULATION

## 1. DEINE AUFGABE

Du bist ein vollständiges, professionelles Spieleentwicklungsstudio bestehend aus:

- Senior Game Developer
- Game Designer
- AI Engineer
- Gameplay Programmer
- 3D Environment Designer
- Character Designer
- UI/UX Designer
- Narrative Designer
- Animation Programmer
- Sound Designer
- QA Engineer
- Build Engineer

Deine Aufgabe ist es, das vollständige 3D-Spiel **META ME** zu entwickeln.

Erstelle nicht nur ein Konzept, sondern implementiere ein tatsächlich spielbares Spiel.

Programmiere sämtliche Systeme, erstelle die Projektstruktur, implementiere die Spielmechaniken und stelle ausführbare Builds bereit.

Arbeite selbstständig, strukturiert und in aufeinander aufbauenden Entwicklungsschritten.

Falls bereits ein META-ME-Projekt existiert, analysiere zuerst sämtliche vorhandenen Dateien. Übernimm funktionierende Komponenten und entwickle sie weiter.

Lösche niemals bestehende Projektbestandteile ohne vorherige Analyse.

## 2. SPIELVISION

META ME ist eine virtuelle Welt, in der Spieler ihr eigenes digitales Ich erschaffen.

Das Spiel soll Menschen ermöglichen, ihre Entscheidungen, Gefühle, Verhaltensweisen und Beziehungen auf neue Weise zu erleben.

Der Spieler soll sich fragen:

"Wer bin ich wirklich?"

"Warum reagiere ich so?"

"Wie beeinflusse ich andere Menschen?"

"Kann ich mich verändern?"

META ME darf keine psychologische Diagnose erstellen oder behaupten, die wahre Persönlichkeit eines Menschen zuverlässig bestimmen zu können.

Stattdessen soll das Spiel individuelle Verhaltensmuster spielerisch reflektieren und zur Selbstreflexion anregen.

Das Spiel besitzt kein klassisches Gut-Böse-System.

Jede Entscheidung kann unterschiedliche Konsequenzen haben.

## 3. TECHNISCHE GRUNDLAGE

Engine:
Godot 4.x, aktuelle stabile Version.

Programmiersprache:
GDScript.

Zielplattformen:
- Windows 10/11, 64 Bit
- Android, später
- Linux optional

Grafik:
- Vollständige 3D-Welt
- Hochwertige Beleuchtung
- Dynamische Schatten
- PBR-Materialien
- Realistische Proportionen
- Animierte Charaktere
- Wettereffekte
- Tag-Nacht-Wechsel
- Unterschiedliche Umgebungsgeräusche

Performance:
- Ziel: 60 FPS auf geeigneter PC-Hardware
- Skalierbare Grafikeinstellungen
- LOD-System
- Occlusion Culling
- Ressourcenmanagement
- Asynchrones Laden größerer Gebiete

Es gibt keine künstliche Begrenzung auf 50 oder 100 MB.

Die Qualität des Spiels hat Vorrang vor einer möglichst kleinen Dateigröße.

## 4. DIE SPIELWELT

Erschaffe eine zusammenhängende, begehbare 3D-Welt.

Die Welt soll glaubwürdig, lebendig und interaktiv wirken.

### Startgebiet: THE BEGINNING

Der Spieler erwacht in einem modernen Apartment.

Das Apartment enthält:

- Schlafzimmer
- Wohnzimmer
- Badezimmer
- Küche
- Balkon
- Interaktive Möbel
- Spiegel
- Computer
- Smartphone
- Beleuchtung
- Fenster
- Türen

Der Spieler kann sich frei bewegen.

Vor einem Spiegel findet die erste Begegnung mit META ME statt.

Der Spiegel reagiert auf den Spieler.

Eine Stimme fragt:

"Kennst du dich eigentlich wirklich?"

Damit beginnt das Spiel.

### Weitere Gebiete

Entwickle anschließend:

1. Wohnviertel mit Häusern und Wohnungen
2. Innenstadt mit Geschäften und Cafés
3. Park mit Sitzmöglichkeiten
4. Arbeitsplatz
5. Schule beziehungsweise Bildungszentrum
6. Nachtclub und Freizeitgebiet
7. Wald als Rückzugsort
8. Erinnerungswelt
9. Spiegelwelt
10. Gemeinschaftsgebiet für zukünftigen Multiplayer

Alle Gebiete sollen schrittweise freigeschaltet werden.

Die Welt muss bereits in der ersten Version vollständig begehbare und funktionierende Startbereiche besitzen.

Verwende keine leeren Platzhalterwelten als angeblich fertige Spielversion.

## 5. SPIELERCHARAKTER

Der Spieler erstellt seinen eigenen Avatar.

Charaktereditor:

- Geschlecht beziehungsweise individuelle Körperdarstellung
- Hautfarbe
- Gesicht
- Frisur
- Augen
- Körperbau
- Kleidung
- Accessoires
- Name
- Stimme

Der Charakter besitzt:

- Laufanimation
- Sprintanimation
- Sitzanimation
- Interaktionsanimation
- Gesprächsanimation
- Emotionale Gesichtsausdrücke
- Gestik
- Kopfbewegungen
- Blickkontakt

Steuerung:

WASD: Bewegung

Maus: Kamera

Shift: Sprinten

E: Interaktion

F: Gespräch beginnen

ESC: Menü

TAB: Persönlichkeitsprofil

M: Weltkarte

Implementiere eine flüssige Third-Person-Kamera.

Die Kamera darf nicht durch Wände hindurchsehen.

## 6. DAS VIRTUELLE ICH

META ME ist eine besondere KI-Figur.

Diese Figur entwickelt sich anhand der Entscheidungen des Spielers.

Sie besitzt ein eigenes digitales Persönlichkeitsprofil.

Das Profil enthält unter anderem:

- Offenheit
- Empathie
- Selbstvertrauen
- Konfliktverhalten
- Vertrauen
- Hilfsbereitschaft
- Ehrlichkeit
- Risikobereitschaft
- Kommunikationsstil
- Selbstreflexion

Die Werte dürfen nicht als objektive Messung der echten Persönlichkeit dargestellt werden.

Sie beschreiben ausschließlich die im Spiel beobachteten Verhaltensweisen.

META ME soll frühere Entscheidungen aufgreifen können.

Beispiel:

Spieler reagiert wiederholt abweisend.

META ME:

"Mir fällt auf, dass du Gespräche häufig beendest, wenn es unangenehm wird. Ist dir das selbst schon aufgefallen?"

Der Spieler kann darauf frei antworten.

META ME soll neugierig und respektvoll reagieren, nicht manipulativ oder belehrend.

## 7. DYNAMISCHER KI-DIALOGGENERATOR

DIES IST EINES DER WICHTIGSTEN SPIELSYSTEME.

Entwickle einen modularen Dialoggenerator.

NPCs dürfen nicht ausschließlich mit fest programmierten Dialogbäumen arbeiten.

Sie müssen dynamisch neue Antworten erzeugen können.

### 7.1 Dialogarchitektur

Implementiere:

DialogueManager

DialogueGenerator

ResponseGenerator

ConversationMemory

EmotionManager

RelationshipManager

PersonalityManager

ContextManager

DialogueUI

Jede Komponente erhält eine klar definierte Aufgabe.

### 7.2 Zwei Betriebsarten

#### ONLINE-KI

Unterstütze eine austauschbare Schnittstelle zu einem externen Sprachmodell.

Die Schnittstelle muss verschiedene Anbieter oder selbst gehostete Modelle unterstützen können.

API-Schlüssel dürfen niemals ungeschützt im Spielclient gespeichert werden.

Die KI-Anfragen müssen über ein geeignetes Backend erfolgen.

#### OFFLINE-KI

Das Spiel muss auch ohne Internet spielbar sein.

Implementiere dafür ein eigenständiges lokales Dialogsystem.

Dieses verwendet:

- Situationsbasierte Dialogvorlagen
- Dynamische Satzkombinationen
- Persönlichkeitsabhängige Antworten
- Emotionale Reaktionen
- Erinnerungsbasierte Gesprächseinstiege
- Kontextabhängige Fragen
- Variierende Antwortformulierungen

Optional kann später ein lokal ausführbares Sprachmodell integriert werden.

Das Offline-System darf nicht fälschlich als vollwertiges generatives Sprachmodell bezeichnet werden, wenn es lediglich Vorlagen kombiniert.

### 7.3 Gesprächsablauf

Jedes Gespräch berücksichtigt:

1. Wer spricht?
2. Wo findet das Gespräch statt?
3. Welche Beziehung besteht?
4. Was ist zuvor passiert?
5. Welche Emotionen sind aktiv?
6. Welche Persönlichkeit besitzt der NPC?
7. Was möchte der NPC erreichen?
8. Wie hat der Spieler bisher reagiert?

Daraus wird die nächste Antwort erzeugt.

### 7.4 Antwortgenerator für Spieler

Bei jeder NPC-Frage kann der Spieler zwischen mehreren Antworten wählen.

Generiere situationsabhängig beispielsweise:

- Freundliche Antwort
- Ehrliche Antwort
- Sarkastische Antwort
- Konfrontative Antwort
- Zurückhaltende Antwort
- Humorvolle Antwort

Zusätzlich:

"Eigene Antwort schreiben"

Der Spieler darf niemals auf die vorgeschlagenen Antworten beschränkt sein.

Die Vorschläge sollen nicht immer dieselben Formulierungen verwenden.

Jede Auswahl verändert gegebenenfalls den Gesprächsverlauf und die Beziehung.

### 7.5 Dialogbeispiel

NPC:

"Warum hast du mich gestern einfach ignoriert?"

Antwortgenerator:

A: "Tut mir leid. Ich hatte wirklich viel im Kopf."

B: "Weil ich einfach keine Lust auf das Gespräch hatte."

C: "Du hast mich doch selbst ignoriert!"

D: "Ich wusste nicht, wie ich reagieren sollte."

E: Eigene Antwort eingeben.

Der NPC bewertet nicht nur die Antwortkategorie, sondern berücksichtigt auch die Vorgeschichte.

Eine Entschuldigung führt beispielsweise nicht automatisch zur Versöhnung.

## 8. EMOTION ENGINE

Jeder NPC besitzt ein dynamisches Emotionssystem.

Emotionen:

- Freude
- Wut
- Traurigkeit
- Angst
- Überraschung
- Vertrauen
- Misstrauen
- Zuneigung
- Enttäuschung
- Eifersucht
- Scham
- Hoffnung
- Frustration

Jede Emotion erhält einen numerischen Wert.

Emotionen beeinflussen:

- Sprache
- Tonfall
- Gesichtsausdruck
- Körperhaltung
- Animation
- Gesprächsbereitschaft
- Verhalten
- Entscheidungen

Emotionen verändern sich nicht zufällig ohne Anlass.

Sie entstehen aus Ereignissen, Beziehungen, Persönlichkeitsmerkmalen und bisherigen Erfahrungen.

Implementiere zeitliche Emotionsverläufe.

Wut kann beispielsweise langsam abnehmen.

Enttäuschung kann länger bestehen bleiben.

## 9. STREIT- UND KONFLIKTSYSTEM

Spieler und NPCs müssen sich streiten können.

Konflikte dürfen nicht ausschließlich aus vorgegebenen Dialogen bestehen.

NPCs können:

- Widersprechen
- Kritik äußern
- Verärgert reagieren
- Gespräche abbrechen
- Abstand verlangen
- Enttäuschung zeigen
- Sich entschuldigen
- Verzeihen
- Eine Entschuldigung ablehnen
- Später erneut das Gespräch suchen

NPCs sollen eigenständige Grenzen besitzen.

Ein NPC muss nicht jede Entscheidung des Spielers akzeptieren.

### Beispiel

Der Spieler beleidigt einen NPC.

Der NPC reagiert abhängig von seiner Persönlichkeit.

Ein selbstbewusster NPC konfrontiert den Spieler.

Ein zurückhaltender NPC zieht sich möglicherweise zurück.

Ein impulsiver NPC reagiert verärgert.

Ein geduldiger NPC versucht zunächst, die Situation zu klären.

Konflikte müssen langfristige Auswirkungen auf Beziehungen haben können.

Gewalt, Demütigung oder emotionale Manipulation dürfen nicht als notwendiger Weg zu Vertrauen oder Nähe belohnt werden.

## 10. BEZIEHUNGSSYSTEM

Jeder NPC besitzt individuelle Beziehungswerte zum Spieler.

Dazu gehören:

- Vertrauen
- Respekt
- Sympathie
- Vertrautheit
- Konfliktspannung
- Gemeinsame Erfahrungen

Beziehungen entwickeln sich über längere Zeit.

Ein einzelnes freundliches Gespräch macht zwei Personen nicht automatisch zu besten Freunden.

Ein einzelner Streit zerstört nicht zwangsläufig eine langjährige Beziehung.

NPCs sollen sich an wichtige gemeinsame Ereignisse erinnern.

Beispiel:

Ein NPC wurde vom Spieler in einer schwierigen Situation unterstützt.

Mehrere Spieltage später:

"Ich habe übrigens nicht vergessen, dass du damals für mich da warst."

## 11. NPC-KÜNSTLICHE INTELLIGENZ

Erschaffe mindestens zehn unterschiedliche NPC-Persönlichkeitsprofile für den ersten größeren Entwicklungsstand.

Jeder NPC erhält:

- Namen
- Alter
- Aussehen
- Persönlichkeit
- Interessen
- Abneigungen
- Tagesablauf
- Wohnort
- Beziehungen
- Erinnerungen
- Emotionen
- Persönliche Ziele

NPCs dürfen nicht dauerhaft an derselben Stelle stehen.

Sie sollen:

- Spazieren gehen
- Arbeiten
- Sich unterhalten
- Nach Hause gehen
- Schlafen
- Freizeitaktivitäten ausführen
- Andere NPCs treffen
- Auf Ereignisse reagieren

Verwende NavigationAgent3D, NavigationMesh und eine geeignete Verhaltenssteuerung.

Implementiere Tagesabläufe und Zustandsmaschinen.

NPCs dürfen eigenständig Gespräche miteinander führen.

Diese Gespräche können ihre Beziehungen beeinflussen.

## 12. ERINNERUNGSSYSTEM

Implementiere ein langfristiges Gedächtnis.

Speichere:

- Wichtige Gespräche
- Entscheidungen
- Konflikte
- Versöhnungen
- Gemeinsame Erlebnisse
- Persönliche Informationen
- Beziehungen
- Ereignisse

Unterscheide:

Kurzzeitgedächtnis:
Aktuelle Unterhaltung.

Langzeitgedächtnis:
Wichtige vergangene Ereignisse.

Beziehungsgedächtnis:
Gemeinsame Erfahrungen zweier Charaktere.

Weltgedächtnis:
Ereignisse, die Auswirkungen auf die Spielwelt besitzen.

Nicht jede Aussage muss dauerhaft gespeichert werden.

Entwickle eine Priorisierung wichtiger Informationen.

Persönliche Gesprächsinhalte müssen geschützt gespeichert werden. Spieler müssen ihre gespeicherten Daten einsehen und löschen können.

## 13. DYNAMISCHE SPIELEREIGNISSE

Die Spielwelt soll eigenständig Ereignisse erzeugen.

Beispiele:

- Ein NPC hat einen schlechten Tag.
- Zwei NPCs streiten sich.
- Ein Freund bittet um Hilfe.
- Ein NPC organisiert eine Feier.
- Ein Charakter zieht um.
- Ein Missverständnis entsteht.
- Ein alter Konflikt wird erneut angesprochen.
- Ein NPC möchte ein persönliches Geheimnis teilen.

Ereignisse werden anhand der Weltlage und Beziehungen generiert.

Sie dürfen nicht permanent wiederholt werden.

## 14. SELBSTREFLEXIONSSYSTEM

META ME soll dem Spieler ermöglichen, seine Entscheidungen zu reflektieren.

Nach wichtigen Ereignissen kann eine Reflexion angeboten werden.

Beispielfragen:

"Warum hast du so reagiert?"

"Warst du mit deiner Entscheidung zufrieden?"

"Würdest du heute anders handeln?"

"Was war dir in dieser Situation wichtig?"

Die Teilnahme ist freiwillig.

Das System soll niemals behaupten, die echten Gedanken, Gefühle oder Absichten des Spielers zu kennen.

Es darf keine psychologischen Diagnosen erstellen.

## 15. SPIEGELWELT

Implementiere eine besondere Spielwelt namens MIRROR WORLD.

Diese Welt stellt die bisherige Entwicklung des virtuellen Charakters symbolisch dar.

Die Umgebung verändert sich abhängig von den Spielerentscheidungen.

Beispiele:

Häufige soziale Interaktionen:
Mehr Begegnungsmöglichkeiten und lebendige Szenen.

Häufiger Rückzug:
Ruhigere Umgebungen und zusätzliche Rückzugsorte.

Viele ungelöste Konflikte:
Bestimmte Erinnerungsräume werden zugänglich.

Die Spiegelwelt darf keine Persönlichkeitsmerkmale moralisch abwerten.

Sie soll zur Reflexion anregen.

## 16. BENUTZEROBERFLÄCHE

Entwickle eine moderne, hochwertige Benutzeroberfläche.

Design:

- Dunkle Farbtöne
- Dezente Neon-Akzente
- Transparente Dialogfenster
- Hochwertige Typografie
- Weiche Animationen
- Übersichtliche Menüs

Hauptmenü:

- Neues Spiel
- Spiel fortsetzen
- Charakter erstellen
- Einstellungen
- Spielstand verwalten
- Beenden

Ingame-Menü:

- Persönlichkeitsprofil
- Beziehungen
- Erinnerungen
- Weltkarte
- Tagebuch
- Einstellungen

Dialogoberfläche:

- NPC-Name
- NPC-Porträt
- Dialogtext
- Dynamische Antwortmöglichkeiten
- Freitext-Eingabe
- Gespräch beenden

Implementiere vollständige Maus- und Tastaturbedienung.

## 17. SOUND UND SPRACHAUSGABE

Implementiere ein Audio-System.

Benötigt werden:

- Umgebungsmusik
- Schritte
- Türen
- Wettergeräusche
- Stadtgeräusche
- Naturgeräusche
- Interaktionssounds
- Emotionale Musikübergänge

Bereite eine Text-to-Speech-Schnittstelle vor.

NPC-Dialoge sollen später optional vorgelesen werden können.

Unterschiedliche NPCs benötigen unterschiedliche Stimmen.

Unterstütze eine deaktivierbare Sprachausgabe.

## 18. SPEICHERSYSTEM

Das Spiel muss jederzeit speicherbar sein.

Speichere:

- Spielerposition
- Charakterdaten
- Inventar
- Beziehungen
- Emotionen
- Erinnerungen
- Weltzustand
- NPC-Zustände
- Entscheidungen
- Aktuelle Ereignisse

Implementiere:

- Automatisches Speichern
- Manuelles Speichern
- Mehrere Spielstände
- Sicherungskopien
- Fehlerbehandlung bei beschädigten Spielständen

Speicherstände müssen nach Möglichkeit mit späteren Versionen kompatibel bleiben.

## 19. MULTIPLAYER-VORBEREITUNG

META ME soll später Multiplayer unterstützen.

Bereite die Architektur darauf vor.

Verwende klare Trennungen zwischen:

- Spielerzustand
- NPC-Zustand
- Weltzustand
- Dialogsystem
- Netzwerkkommunikation

Multiplayer-Ziele:

- Gemeinsame Spielwelt
- Spielerbegegnungen
- Gemeinsame Aktivitäten
- Spieler-zu-Spieler-Kommunikation
- Gemeinsame Ereignisse
- Freundeslisten
- Private Räume

Persönliche Erinnerungen, Gesprächsprotokolle und Reflexionen dürfen niemals automatisch anderen Spielern zugänglich sein.

Für die erste Version ist kein vollständig implementierter Multiplayer erforderlich.

## 20. ENTWICKLUNGSROADMAP

Arbeite die folgenden Phasen nacheinander ab.

### PHASE 1: TECHNISCHES FUNDAMENT

- Bestehendes Projekt analysieren
- Godot-Projekt erstellen beziehungsweise migrieren
- Projektstruktur aufbauen
- Hauptmenü implementieren
- Spielszene erstellen
- Kamera implementieren
- Spielersteuerung implementieren
- Speichersystem vorbereiten

Ergebnis:
Ein startbares Windows-Spiel mit funktionierender 3D-Steuerung.

### PHASE 2: ERSTE SPIELWELT

- Apartment erstellen
- Außenbereich erstellen
- Beleuchtung implementieren
- Tag-Nacht-System
- Interaktive Türen
- Interaktive Objekte
- Kollisionssystem
- Navigation

Ergebnis:
Eine begehbare und glaubwürdige 3D-Umgebung.

### PHASE 3: ERSTER NPC

- Vollständigen NPC implementieren
- Persönlichkeitsprofil erstellen
- NPC-Animationen
- Interaktionssystem
- Dialogoberfläche
- Gesprächssteuerung

Ergebnis:
Ein NPC, mit dem der Spieler interagieren kann.

### PHASE 4: ANTWORTGENERATOR

- DialogueManager
- DialogueGenerator
- ResponseGenerator
- Offline-Dialogsystem
- Freitextantworten
- Online-KI-Schnittstelle
- Kontextverarbeitung

Ergebnis:
Ein dynamisches Dialogsystem, das unterschiedliche Gespräche ermöglicht.

### PHASE 5: EMOTIONEN UND BEZIEHUNGEN

- EmotionManager
- RelationshipManager
- Vertrauenssystem
- Konfliktsystem
- Versöhnungssystem
- Emotionale Animationen

Ergebnis:
NPCs reagieren emotional und verändern ihre Beziehungen zum Spieler.

### PHASE 6: META ME

- Virtuelles Ich implementieren
- Persönlichkeitsentwicklung
- Erinnerungsfunktion
- Selbstreflexionssystem
- Spiegelwelt
- Persönlichkeitsdashboard

Ergebnis:
Die zentrale META-ME-Spielmechanik ist spielbar.

### PHASE 7: LEBENDIGE WELT

- Weitere NPCs
- Tagesabläufe
- NPC-zu-NPC-Interaktionen
- Dynamische Ereignisse
- Neue Gebäude
- Neue Gebiete
- Zusätzliche Animationen

Ergebnis:
Eine lebendige Spielwelt.

### PHASE 8: QUALITÄT UND RELEASE

- Fehlerbehebung
- Performanceoptimierung
- Grafikeinstellungen
- Audiooptimierung
- Benutzerfreundlichkeit
- Spieltests
- Windows-Export
- Installationspaket
- Versionsverwaltung

Ergebnis:
Eine stabile, eigenständig spielbare Version.

## 21. QUALITÄTSANFORDERUNGEN

Das Spiel darf nicht nur aus Konzeptdateien bestehen.

Erstelle funktionierenden Programmcode.

Verwende keine leeren Funktionen als angeblich fertige Features.

Alle implementierten Systeme müssen tatsächlich miteinander kommunizieren.

Überprüfe:

- Startet das Spiel?
- Funktioniert die Bewegung?
- Funktionieren Kollisionen?
- Sind NPCs sichtbar?
- Können Gespräche gestartet werden?
- Werden Antworten erzeugt?
- Verändern Antworten die Beziehungen?
- Werden Erinnerungen gespeichert?
- Funktioniert Laden und Speichern?
- Gibt es kritische Fehlermeldungen?

Schreibe automatisierte Tests, soweit technisch sinnvoll.

Wenn eine Funktion noch nicht fertig ist, kennzeichne sie ausdrücklich als unvollständig.

## 22. BUILD-SYSTEM

Erstelle ein reproduzierbares Build-System.

Ziel:

META_ME_Windows_x64.zip

Inhalt:

- Ausführbare Spieldatei
- Erforderliche Ressourcen
- Konfiguration
- README
- Versionsinformationen

Erstelle später zusätzlich:

META_ME_Android.apk

Ein Build gilt nur dann als fertig, wenn der Export erfolgreich war und die verfügbaren Tests bestanden wurden.

Falls in der Entwicklungsumgebung keine Godot-Exportvorlagen oder erforderlichen Werkzeuge vorhanden sind, dokumentiere die fehlenden Voraussetzungen und stelle das vollständige Projekt bereit.

Behaupte niemals, eine APK oder EXE erstellt zu haben, wenn tatsächlich kein entsprechender Build existiert.

## 23. ARBEITSWEISE

Arbeite möglichst eigenständig.

Stelle nur Fragen, wenn eine Entscheidung für die weitere Entwicklung zwingend erforderlich ist.

Wähle ansonsten sinnvolle technische Standardlösungen.

Priorisiere:

1. Funktionsfähigkeit
2. Spielbarkeit
3. Stabilität
4. Dialogqualität
5. Emotionale Glaubwürdigkeit
6. Grafische Qualität
7. Erweiterbarkeit

Erstelle für jede Phase eine Aufgabenübersicht.

Dokumentiere erledigte und offene Aufgaben.

Behebe gefundene Fehler vor der Implementierung weiterer komplexer Funktionen.

Arbeite kontinuierlich an einem vollständigen Spiel, nicht an voneinander getrennten Demonstrationen.

## 24. ERSTE KONKRETE AUFGABE

Beginne jetzt mit Phase 1.

Analysiere zuerst das vorhandene Repository beziehungsweise die bereitgestellten META-ME-Dateien.

Erstelle anschließend das Godot-Projekt mit:

- Funktionierendem Hauptmenü
- Begehbarem Apartment
- Steuerbarem 3D-Charakter
- Third-Person-Kamera
- Einem interaktiven NPC
- Einfacher Dialogoberfläche
- Mindestens fünf situationsabhängigen Gesprächseinstiegen
- Dynamischen Antwortvorschlägen
- Möglichkeit zur freien Texteingabe
- Grundlegendem Vertrauenssystem
- Funktionierendem Speichersystem

Der erste Meilenstein ist erreicht, wenn ein Spieler das Spiel starten, sich bewegen, einen NPC ansprechen, ein Gespräch führen und seine Fortschritte speichern kann.

Erstelle danach einen überprüfbaren Windows-Build, sofern die Entwicklungsumgebung dies ermöglicht.

Entwickle anschließend Phase für Phase weiter.

# END OF MASTER PROMPT
