# META ME · Entwicklungsstand 0.3.0

Das technische Fundament ist spielbar; Kapitel 1 hat ab 0.3.0 einen ausgearbeiteten Handlungsbogen. Dies ist **kein vollständiger Release aller acht Phasen**. Die folgenden Häkchen bezeichnen jeweils die konkrete Teilfunktion, keine Produktionsreife einer ganzen Phase.

## Aktueller Ausbau · Kapitel 1 „Ein Bild von Zuhause“

Dieser Ausbau verbindet Phase 3/4 (NPC und zielgerichtete Gespräche), Phase 5 (dauerhafte Folgen), Phase 6 (nachvollziehbarer Rückblick) und Phase 8 (mobile UX). Neue Weltgebiete bleiben offen.

- [x] Endliche Handlung: Einladung → Bildprüfung oder Ablehnung → Vereinbarung → Aktivität in der Welt → optionaler Rückblick → Abschluss.
- [x] Drei dauerhafte Bildausgänge: sicherer Ausschnitt, ausdrücklich bestätigtes Original oder keine Veröffentlichung.
- [x] Gemeinsamer Tee mit erzähltem Hintergrund, eigenständiger Rückzug und Versöhnungsversuch nach Vorwurf.
- [x] Aktuelles Ziel, Marker im Apartment, grafischer Wohnungsplan und Kapitelpfad.
- [x] Beziehungsdiagramm mit antippbaren Entscheidungspunkten und belegten Ereignissen; Häufigkeitsdiagramm statt unkommentierter Persönlichkeitswerte.
- [x] Persistente Kapitelentscheidungen, Autosave bei Fortschritt, Laden mitten im Kapitel, Kompatibilität mit 0.2-Spielständen.
- [x] Überarbeitete Menüs und Dialoge für Android; Ende eines Gesprächs führt zu einem konkreten nächsten Schritt.
- [ ] Externe Spieltests für Dramaturgie, Umfang, Lesbarkeit und Bedienung auf mehreren echten Android-Geräten.
- [ ] Kapitel 2 und spätere Weltgebiete; der Abschluss kündigt keine bereits spielbare Fortsetzung an.

## Phase 1 · Technisches Fundament

- [x] Vorhandenes Repository analysiert: ausschließlich ursprüngliche README, keine META-ME-Komponenten vorhanden.
- [x] Godot-4.7.2-Projekt, modulare GDScript-Struktur, Haupt- und Pausenmenü.
- [x] Begehbares, möbliertes Apartment, Third-Person-Charakter und kollidierende Kamera.
- [x] Erster interaktiver NPC mit artikulierter Figur und einfachen Lauf-/Gesprächsanimationen.
- [x] Sechs kontextabhängige Gesprächseinstiege, wechselnde Vorschläge und Freitext.
- [x] Grundlegendes Vertrauen, Konfliktspannung, Spielbeobachtungen und Erinnerungen.
- [x] Drei verschlüsselte Speicherplätze, Autosave, Sicherung, Validierung und Löschoberflächen.
- [x] Reproduzierbarer Windows-/Linux-Export und automatisierte Integrationstests.
- [ ] Nativer Windows-Spieltest und Test auf repräsentativer PC-Grafikhardware.

## Phase 2 · Erste Spielwelt

- [x] Schlafzimmer, Bad, Wohnzimmer, Küche, Balkon, Fensteröffnungen und physische Kollisionen.
- [x] Interaktive Balkontür, Beleuchtung, Spiegel, Computer, Smartphone und Zeitaktionen.
- [x] Tageszeit verändert den Sonnenstand; Laufzeit-NavMesh für das Apartment.
- [ ] Begehbares Wohnviertel mit zugänglichen Gebäuden; vorhandene Stadtkulisse ersetzen/erweitern.
- [ ] Wetter, detailreichere PBR-Ressourcen, bessere Innenraumbeleuchtung und Welt-Audio.
- [ ] Gebietswechsel, asynchrones Laden und Performanceprüfung.

## Phase 3 · Erster NPC

- [x] Mara, 28, ruhig und selbstbewusst, Interesse an Fotografie und Architektur.
- [x] Gesprächssteuerung, Interaktionsreichweite/Sichtprüfung, Oberfläche mit Vorschlägen/Freitext.
- [x] NavigationAgent3D und Patrouille zwischen Wohn-, Küchen- und Fensterbereich.
- [x] Einfache Atem-, Gang-, Kopf- und Gesprächsbewegungen, emotionsabhängige Haltung.
- [ ] Produktionsreifes Charaktermodell, differenzierte Gesichtsanimationen und IK.
- [ ] Vollständiger Tagesplan statt der bisherigen Apartment-Patrouille.

## Phase 4 · Antwortgenerator

- [x] DialogueManager, DialogueGenerator, ResponseGenerator, ContextManager und ConversationMemory.
- [x] Offline-Situationen, Varianten, konservative Freitextregeln und Nachfragen.
- [ ] Größere Satzbau-Komposition und semantisch differenzierte Offline-Erkennung.
- [ ] Austauschbarer Online-Anbieter über ein abgesichertes Backend, mit ausdrücklichem Opt-in.
- [ ] Serverseitige Authentisierung, Ratenlimits, Anbieter-Timeouts, Inhalts- und Datenschutzkonzept.

## Phase 5 · Emotionen und Beziehungen

- [x] Vertrauen, Respekt, Vertrautheit, Konfliktspannung; langsame positive Veränderungen.
- [x] Freude, Wut, Enttäuschung und Hoffnung; Wut nimmt schneller ab als Enttäuschung.
- [x] Konfliktantworten, Abbruchgrenze und zeitlicher Abstand, keine automatische Vergebung.
- [x] Wiederholte identische Antworten erzeugen innerhalb eines Gesprächs keine weiteren Vertrauenspunkte.
- [ ] Alle 13 Emotionen, mehrere Beziehungspartner und langfristige Beziehungsereignisse.
- [x] Kapitelbelohnungen einmal pro Ereignis; generische Dialogbelohnungen pro Spieltag/Thema/Absicht begrenzt, auch über erneutes Öffnen hinweg.
- [ ] Langfristiges Beziehungsbalancing über mehrere Spieltage und mehrere NPCs.

## Phase 6 · META ME

- [x] Reaktiver Spiegel mit Echtzeitreflexion und freiwilligem Reflexionsgespräch.
- [x] Ereignisbasierter Beziehungsverlauf und Entscheidungsdiagramme mit klarer Nicht-Diagnose-Erklärung. Interne zehn Eigenschaftszähler werden nicht als vermeintliches Persönlichkeitsprofil angezeigt.
- [x] Lokales Journal mit ausdrücklicher Aufbewahrungsoption und Datenlöschung.
- [ ] Kontextreiche Rückblicke auf mehrere Spieltage und frei betretbare MIRROR WORLD.
- [ ] Bessere Interpretation langfristiger Entscheidungen ohne reale Persönlichkeitsbehauptungen.

## Phase 7 · Lebendige Welt

- [x] Technische Grundlage für Navigation und zeitbasierten Weltzustand.
- [ ] Zehn vollständig ausgearbeitete NPC-Profile mit eigenen Ressourcen und Tagesplänen.
- [ ] NPC-zu-NPC-Beziehungen, Gespräche und Ereignispriorisierung mit Wiederholungssperren.
- [ ] Innenstadt, Park, Arbeit, Bildung, Nachtleben, Wald, Erinnerungs- und Spiegelwelt.
- [ ] Fortschrittsabhängige Freischaltung und ein funktionierendes soziales Ereignissystem.

## Phase 8 · Qualität und Release

- [x] Tests für reale Steuerung, Kollisionen, Kamera, Dialogfolgen, UI, Spielstände und Datenschutz.
- [x] Grafisch ausgeführte Integrationstests und lokale Screenshots.
- [x] Grafik-/Audio-/Mauseinstellungen; kompatibler OpenGL-Renderer.
- [x] Getesteter Buildprozess und ausführbare Export-Artefakte.
- [ ] Windows-QA, Belastungs-/Dauertests, 60-FPS-Messungen auf Zielhardware.
- [ ] LOD, Occlusion Culling, Qualitätsstufen pro Ressourcentyp und Messung großer Gebiete.
- [ ] Vollständiger Avatar-Editor, Sprachausgabe/TTS, barrierearme Layouts und Controller.
- [ ] Signierung, Installer und ausführliche externe Spieltests.
- [x] Android-Exportziel, Touch-Mehrfingersteuerung, Android-Zurück, Hintergrundspeichern und sparsamer Grafikstandard.
- [x] Mobile Dialog-/Menüoberfläche, Bildschirmtastatur-Anpassung und Android-spezifische Integrationstests.
- [ ] Weitere Android-Gerätetests und Performanceoptimierung; Multiplayer bleibt zukünftige Architekturarbeit.

Keine Anwendungscode-Veröffentlichung, kein Push und keine Cloud-Veröffentlichung werden durch den lokalen Build ausgelöst.
