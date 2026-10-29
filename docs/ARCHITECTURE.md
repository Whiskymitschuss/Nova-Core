# Architektur des ersten Meilensteins

`game/scenes/main.tscn` startet `scripts/main.gd`. Der Controller verbindet die echte 3D-Welt, Physik, Dialoge und Oberfläche. Es gibt keine externen Dienste und keine Python-Laufzeitabhängigkeit im exportierten Spiel.

| Bereich | Verantwortung |
|---|---|
| `core/state.gd` · Autoload `State` | Versionierter Welt-/Avatar-/NPC-/Beziehungszustand, Zeit und Spielbeobachtungen |
| `core/save_store.gd` | Formatprüfung, AES-verschlüsselte Dateien über Godot FileAccess, atomarer Austausch, Backup und Löschung |
| `world/apartment.gd` | Eigene Geometrie, Materialien, Licht, NavMesh, Interaktionspunkte und Spiegel-Viewport |
| `world/player.gd` | CharacterBody3D, Beschleunigung/Gravitation, physische Kollisionen, SpringArm-Kamera und Schritte |
| `world/npc.gd` | NavigationAgent3D, kleine Patrouille, Gesprächsunterbrechung und Blickrichtung |
| `world/humanoid.gd` | Prozedurale Figuren mit Gelenken und einfachen zustandsabhängigen Animationen |
| `dialogue/context_manager.gd` | Ort, Zeit, NPC-Eigenschaften, Gesprächsvorgeschichte, Ziele und aktueller Zustand |
| `dialogue/dialogue_manager.gd` | Gesprächslebenszyklus, Freitext-/Auswahlverarbeitung und Systemkoordination |
| `dialogue/dialogue_generator.gd` | Situationsauswahl und Antwortvarianten; keine LLM-Behauptung |
| `dialogue/response_generator.gd` | Sechs Vorschlagskategorien und bewusst einfache, konservative Freitextregeln |
| `dialogue/emotion_manager.gd` | Ereignisbezogene Emotionsänderungen |
| `dialogue/relationship_manager.gd` | Kleine, begrenzte Änderungen von Vertrauen, Respekt, Vertrautheit und Spannung |
| `dialogue/personality_manager.gd` | Beobachtete Spielentscheidungen, keine psychologische Auswertung |
| `dialogue/conversation_memory.gd` | Priorisierte Ereignisse, maximal 80 Einträge, Texte nur bei Aufbewahrungswunsch |
| `ui/game_ui.gd` | Maus-/Tastaturmenüs, Dialog, Profil, Karte, Charakterfarben, Datenschutz und Einstellungen |
| `ui/touch_controls.gd` | Getrennte Finger für analogen Stick und Kamera, mehrfingerfähige Aktionsknöpfe, sichere Ränder und Zurücksetzen bei Unterbrechung |
| `tests/test_game.gd` | Integrationstests mit realem Hauptmenü, Spielszene, Physik und isolierten Speicherdateien |

## Speichervorgang

Spieler- und NPC-Zustand erfassen → vollständige Struktur prüfen → verschlüsselte temporäre Datei schreiben → zurücklesen und prüfen → bisherige gültige Hauptdatei als Backup kopieren → temporäre Datei umbenennen. Beim Laden werden unbekannte Versionen und ungültige Strukturen verworfen, anschließend wird die letzte Sicherung versucht. Ein fehlender lokaler Schlüssel darf vorhandene Saves nicht stillschweigend unlesbar ersetzen. Die drei Speicherplätze teilen einen zufälligen lokalen Schlüssel. Dateirechte unter Unix werden eingeschränkt; Betriebssystemkontoschutz bleibt erforderlich.

Gesprächs-Freitexte sind flüchtig, bis die Aufbewahrung aktiviert wird. Ereignisse werden standardmäßig als Kategorien zusammengefasst. Die Oberfläche zeigt persönliche Einträge an und kann sie aus allen lesbaren Saves und Backups entfernen. Fehler werden gemeldet, nicht als erfolgreiche Löschung ausgegeben. Unlesbare Dateien lassen sich über die vollständige Datenlöschung entfernen.

## Bewusste Grenzen

Die Apartment-Patrouille ist kein vollständiger Tagesplan. Das Journal ist noch kein Welt-/Beziehungsgedächtnis mehrerer NPCs. Die Profilwerte sind kleine Spielzähler, keine wissenschaftliche Persönlichkeitsskala. META ME antwortet zunächst mit freiwilligen Reflexionsfragen und kennt keine verborgenen Gedanken. Freitextregeln können sprachliche Feinheiten nicht verlässlich verstehen.

Online-KI, Multiplayer, Gebietsstreaming und TTS haben **keine leeren Scheinimplementierungen**. Für späteren Netzwerkbetrieb müssen Spielersimulation, Welt-/NPC-IDs und Persistenz weiter getrennt und ein autoritativer Server ergänzt werden. Persönliche Journale dürfen dabei nicht in replizierte Zustände gelangen. Ein künftiges KI-Backend muss Schlüssel ausschließlich serverseitig halten und private Kontexte nur nach informierter Zustimmung übertragen.

Die Raumgeometrie und Charaktere sind originale prozedurale Ressourcen. Die Klangdateien wurden lokal synthetisiert. Die mitgelieferte DejaVu-Sans-Schrift unterliegt `game/assets/FONT-LICENSE.txt`. Keine heruntergeladenen Charaktermodelle, Musikstücke oder Texturen sind notwendig.

## Android ab 0.2.0

`main.gd` erkennt Android oder den Desktop-Testschalter `--touch`, skaliert die UI und verarbeitet Android-Zurück sowie `NOTIFICATION_APPLICATION_PAUSED`. `MetaPlayer` kombiniert analogen Touch-Eingang mit der bestehenden Physiksteuerung. `GameUI` stellt auf scrollbare Touch-Menüs und einen höhenangepassten Dialog um; bei sichtbarer Bildschirmtastatur bleibt die Freitextzeile zugänglich. Das gleiche Spiel läuft als native Godot-APK mit OpenGL ES 3.0. Der Export nutzt offizielle vorkompilierte Vorlagen, keine WebView und keinen Remote-Streaming-Dienst.
