# Nova-Core · META ME

Dieses Repository enthält **META ME 0.2.0 / THE BEGINNING**, einen spielbaren Android-Meilenstein in Godot 4.7.2 mit GDScript. Die ursprüngliche Repository-Beschreibung lautete: „A Discord Community Channel with some Self produced Scripts/Addons“.

## Android

**[Android-APK direkt herunterladen](https://github.com/Whiskymitschuss/Nova-Core/raw/refs/heads/codex/meta-me-android-v0.2.0/downloads/META_ME_Android.apk)**

Die geprüfte Testversion liegt im Repository unter [`downloads/META_ME_Android.apk`](downloads/META_ME_Android.apk). [Installation und Prüfsumme](downloads/README.md).

`builds/META_ME_Android.apk` auf dein Smartphone übertragen und öffnen. Android 7.0/API 24 oder neuer, OpenGL ES 3.0; ARM64, ARMv7 und x86_64 sind enthalten. Die Dateien-/Browser-App muss APKs installieren dürfen. Es handelt sich um eine mit lokalem Entwicklungsschlüssel signierte Testversion zum direkten Installieren, keinen Play-Store-Release.

Links mit dem virtuellen Stick bewegen, rechts zum Drehen der Kamera wischen. **Benutzen**, **Reden**, **Sprint**, **Speichern** und **Menü** sind Touch-Tasten. Über das Menü sind Profil, Wohnungsplan, Erinnerungen und Einstellungen erreichbar. Antworten lassen sich durch Wischen durchsehen; eigene Antworten können mit der Bildschirmtastatur geschrieben werden. Android-Zurück schließt Gespräche oder Menüs. Beim Hintergrundwechsel wird gespeichert und pausiert.

Android startet standardmäßig mit sparsamer Grafik ohne dynamische Schatten und Echtzeitspiegel. Der Spiegel bleibt interaktiv; hohe Qualität kann in den Einstellungen aktiviert werden. Die App benötigt weder Internet- noch Mikrofon- oder gemeinsame Speicherberechtigungen. Spielstände liegen im privaten App-Speicher; eine Deinstallation entfernt sie.

Build, Installation und Android-Prüfung: [docs/ANDROID.md](docs/ANDROID.md).

## Spielen

`builds/META_ME_Windows_x64.zip` vollständig entpacken und `META_ME.exe` starten. `META_ME.pck` muss danebenliegen. Windows 10/11 x64 mit OpenGL-3.3-fähiger Grafik; keine Internetverbindung und kein API-Schlüssel erforderlich. Die Entwicklungsversion ist unsigniert und enthält keinen Installer. Ein Linux-x64-Build und das vollständige Quellprojekt werden ebenfalls erzeugt.

Im Spiel: **Neues Spiel** wählen, das Apartment erkunden, links im Wohnzimmer am Spiegel mit **E** META ME begegnen, mit **F** Mara ansprechen und mit **F5** speichern. Sechs situationsabhängige Gesprächseinstiege, wechselnde Antwortvorschläge und eigene Texteingaben sind integriert. Beziehungen reagieren auf Spielentscheidungen; Konflikte verschwinden nicht durch eine einzelne Entschuldigung.

| Taste | Funktion |
|---|---|
| WASD / Maus | Bewegung / Third-Person-Kamera |
| Shift | Sprint |
| E / F | Objekt benutzen / Gespräch mit Mara |
| Esc | Gespräch beenden, Panel schließen oder Pause |
| Tab / M / J | Spielprofil / Wohnungsplan / Erinnerungen |
| F5 / F9 | Aktuellen Platz speichern / laden |

Der erste Charaktereditor erlaubt Name, Haut-, Haar- und Kleidungsfarbe. Schlafzimmer, Badezimmer, Wohnzimmer, Küche und Balkon sind begehbar. Tür, Lampe, Spiegel, Computer, Smartphone sowie Zeitaktionen am Bett, Sofa und bei der Teezubereitung sind interaktiv. Die Stadt außerhalb des Balkons ist **Kulisse**, kein bereits spielbares Stadtviertel. Figuren und Ausstattung bestehen aus eigener, prozeduraler Geometrie; die Grafik ist stilisiert, nicht fotorealistisch.

## Entwickeln und prüfen

1. Godot **4.7.2 stable**, Standard-Edition (kein .NET erforderlich), installieren.
2. `game/project.godot` öffnen und mit F6/F5 starten. Alternativ `godot --path game`.
3. Integrationstests: `GODOT_BIN=/pfad/zu/godot python3 tools/manage.py test`.
4. Passende offizielle Exportvorlagen **4.7.2.stable** im Godot-Editor installieren. Android ist das Standardziel von `python3 tools/manage.py build`; zusätzlich sind dafür Java und Android-SDK erforderlich. Mit `--target windows` bzw. `--target linux` lässt sich ein Desktop-Ziel auswählen; `--target all` exportiert alle drei Plattformen.

Unter Windows kann `GODOT_BIN` in PowerShell mit `$env:GODOT_BIN='C:\Pfad\Godot.exe'` gesetzt werden; anschließend `python tools/manage.py build` verwenden. Ohne Variable wird `godot`/`godot4` aus `PATH` verwendet. Python 3.10+ genügt; keine Python-Pakete erforderlich. Originaldownloads und SHA512-Prüfsummen: <https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable>.

Jede Cloud-Aufgabe ist bereits isoliert: vorhandenen Checkout verwenden, keinen zusätzlichen Git-Worktree anlegen. In dieser Cloud liegen Editor und Exportvorlagen außerhalb des Repositorys unter `/workspace/meta-me-tools`. Für die vorbereiteten Werkzeuge:

```bash
export GODOT_BIN=/workspace/meta-me-tools/godot/Godot_v4.7.2-stable_linux.x86_64
export XDG_CONFIG_HOME=/workspace/meta-me-tools/config
export XDG_CACHE_HOME=/workspace/meta-me-tools/cache
export XDG_DATA_HOME=/workspace/meta-me-tools/share
export JAVA_HOME=/workspace/meta-me-tools/java/jdk-17.0.21+9
export ANDROID_HOME=/workspace/meta-me-tools/android-sdk
python3 tools/manage.py build --target android
```

`manage.py` prüft die Engine-Version, importiert Ressourcen und führt die echte Spielszene mit Physik und Oberfläche sowohl mit Desktop- als auch Touch-Steuerung aus. Es exportiert erst nach erfolgreichen Tests. Godot-Fehlermeldungen führen auch bei Exit-Code 0 zum Abbruch. Android erzeugt eine APK mit geprüfter Signatur; Desktop-Ziele erzeugen ZIPs mit Binary und PCK. Dazu kommen Quelle, Anleitung und `SHA256SUMS.txt`. Linux-Exporte werden zusätzlich headless gestartet. **Ein Export ersetzt keinen Laufzeittest auf der Zielplattform.** ZIP-Metadaten werden vereinheitlicht; bitidentische Engine-Binaries über verschiedene Betriebssysteme sind nicht zugesichert.

## Daten und Grenzen

Das Offline-System kombiniert Regeln, Situationen und Textvarianten. Es ist **kein generatives Sprachmodell**. Bei unbekannten Freitexten fragt Mara nach, statt angeblich die Absicht zu kennen. Online-KI und Backend sind in dieser Version nicht implementiert; es gibt keine Netzwerkübertragung von Gesprächen.

Spielwerte beschreiben ausschließlich beobachtete Spielentscheidungen, keine echte Persönlichkeit und keine Diagnose. Reflexion ist freiwillig. Zurückhaltung wird nicht als moralischer Mangel gewertet. Drei verschlüsselte Speicherplätze mit atomarem Dateiaustausch, letzter gültiger Sicherung und Formatprüfung sind integriert. Automatisches Speichern erfolgt nach 120 Sekunden aktiven Spiels; normales Schließen des Fensters und „Speichern und zum Hauptmenü“ speichern ebenfalls.

Speicherort: Android im privaten App-Speicher, Windows `%APPDATA%\META_ME`, Linux `$XDG_DATA_HOME/META_ME` bzw. `~/.local/share/META_ME`. Texteingaben werden standardmäßig nicht aufbewahrt; ihre Speicherung kann in den Einstellungen aktiviert werden. Im Tagebuch lassen sich persönliche Einträge aus lesbaren Speicherständen **und Sicherungen** entfernen; die Spielstandverwaltung kann sämtliche Speicherdateien inklusive Schlüssel löschen. Der lokale Verschlüsselungsschlüssel liegt im selben Benutzerkonto: kein Schutz gegen Kontozugriff, Malware, externe Backups oder Datenträgerforensik. Die Löschfunktion ist keine sichere physische Datenträgerlöschung.

Weiterentwicklung, Phasenstatus und bekannte Grenzen: [docs/ROADMAP.md](docs/ROADMAP.md). Architektur: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Prüfprotokoll: [docs/VALIDATION.md](docs/VALIDATION.md). Der vollständige Auftrag bleibt in [docs/MASTER_PROMPT.md](docs/MASTER_PROMPT.md) erhalten.
