# Prüfprotokoll · META ME

## Android-Meilenstein 0.2.0

- Godot 4.7.2; OpenJDK 17.0.21; Android-SDK Build Tools 36.0.0.
- 59 Desktop- und 72 Touch-Integrationstests ohne Fehler. Grafischer Touch-Lauf: 75 Prüfungen einschließlich drei Screenshots.
- APK erfolgreich exportiert und installiert. Paket `org.novacore.metame`, Version 0.2.0 / Code 2, Minimum API 24, Ziel API 36.
- ARMv7, ARM64 und x86_64 enthalten; APK-Signaturen v2/v3 und 16-KB-ZIP-Ausrichtung geprüft. Keine zusätzlichen App-Berechtigungen im Manifest.
- Native Geräteprüfung: **Android-7-Emulator ohne KVM, Mesa/GLES 3.1**. Hauptmenü, neue Partie, tatsächliche Touch-Bewegung, Touch-Pause, Android-Zurück, Spiegelinteraktion, Freitext mit generierter Antwort und Hintergrundspeichern erfolgreich geprüft. Nichtleere verschlüsselte Speicherdateien und eine Sicherung wurden im privaten App-Verzeichnis angelegt. Nach vollständigem Stoppen und Neustarten der App wurde der Spielstand erfolgreich geladen, einschließlich Position und Spiegel-Fortschritt. Das abschließende Laufzeitprotokoll enthält keine Godot-Fehler.
- Auf einem Emulatorprofil **ohne Hardwaretastatur** wurde zusätzlich die echte Android-Bildschirmtastatur eingeblendet. Die Antwortliste wird dabei verborgen; Eingabezeile und Senden bleiben oberhalb der Tastatur erreichbar. Screenshot: `builds/android-native-phone-keyboard.png`.
- Der SwiftShader-Treiber des Emulators scheiterte mit Shader-Uniformfehlern; derselbe APK-Build funktioniert mit Mesa/GLES 3.1. Dies ist eine beobachtete Emulator-Treibereinschränkung, kein Beleg für Kompatibilität mit jedem Android-GPU-Treiber.
- Ein physisches Android-Smartphone und FPS-/Akku-/Wärmemessungen stehen nicht zur Verfügung.

## Historische PC-Basis 0.1.0

Geprüfter Stand: erster spielbarer Meilenstein, 29. Oktober 2026. Engine: **Godot 4.7.2.stable.official.ed1daf0bf**. Linux-Cloud, 5 vCPUs, ca. 33 GiB RAM. Grafiktest über lokalen Xvfb-Bildschirm und Mesa llvmpipe/OpenGL 4.5; kein Beleg für 60 FPS auf PC-Zielhardware.

## Ergebnisse

| Prüfung | Ergebnis |
|---|---|
| Offizielle Linux-Engine und Exportvorlagen | SHA512 gegen offizielle `SHA512-SUMS.txt` geprüft |
| Ressourcenimport / Skriptkompilierung | Erfolgreich, keine Skriptfehler |
| Headless-Integrationstest | **59 Prüfungen, 0 Fehler** |
| Grafischer Integrationstest | **62 Prüfungen, 0 Fehler**, einschließlich 3 Screenshots |
| Windows-x64-Release-Export | Erfolgreich, echte EXE und PCK vorhanden |
| Windows-Dateiformat | PE-Signatur und AMD64-Maschinenkennung `0x8664` geprüft |
| Linux-x64-Release-Export | Erfolgreich, ausführbare ELF-Datei und PCK vorhanden |
| Eigenständiger Linux-Export | Headless und mit OpenGL gestartet, ohne Skript-/Ressourcenfehler beendet |
| ZIP-Integrität | Alle erzeugten ZIPs per CRC geprüft |
| Repository | `git diff --check` erfolgreich; keine bestehenden Komponenten gelöscht |
| Windows-Laufzeittest | **Nicht ausgeführt**; kein Windows-System verfügbar |
| Audioausgabe | Dateien integriert; keine hörbare Prüfung, da kein Audiogerät vorhanden |
| Android / Multiplayer / Online-KI | Nicht implementiert, nicht getestet |

Die 62 grafischen Prüfungen umfassen dieselben 59 Spielprüfungen plus das erfolgreiche Schreiben von drei Screenshots; es sind **keine 121 unabhängigen Tests**. Xvfb meldet erwartungsgemäß, dass V-Sync nicht umgeschaltet werden kann. Das ist eine Einschränkung des virtuellen Grafiktreibers. Der abschließende Lauf erzeugte keine Objektleck- oder Ressourcenfehlermeldung.

## Tatsächlich geprüfte Spielabläufe

- Hauptmenü und Startknopf starten die echte Spielszene; Menüs suspendieren die Steuerung.
- WASD bewegt den CharacterBody3D, Bodenkollision hält ihn in der Wohnung und Wände blockieren ihn.
- Bedroom- und Badezimmerzugänge sind physisch passierbar; SpringArm zieht die Kamera vor einer Wand ein.
- NavMesh besitzt begehbare Polygone; Mara bewegt sich wirklich entlang eines NavigationAgent-Pfads und bleibt auf dem Boden.
- Spiegel wird durch normale Zielauswahl gefunden; die E-Taste startet META ME und gibt die Maus für Dialoge frei.
- Alle sechs situativen Gesprächseinstiege werden unter ihren Bedingungen ausgewählt.
- Vorschlagsknopf verändert Vertrauen und Gedächtnis; Vorschläge ändern sich mit dem Gesprächsverlauf.
- Eigene Texte werden über die echte Eingabezeile verarbeitet; Fotografie führt zu einer passenden Antwort.
- Wiederholte Beleidigungen lösen eine Gesprächsgrenze aus; erneutes Öffnen umgeht die Abklingzeit nicht.
- Eine Entschuldigung beendet den Konflikt nicht sofort; identische Antworten erzeugen nicht unbegrenzt Vertrauen innerhalb eines Gesprächs.
- Die Balkontür bewegt ihren tatsächlichen Collider, der Durchgang ist passierbar und das Geländer verhindert einen Absturz.
- Lampe verändert Beleuchtung; Teezubereitung verändert Weltzeit.
- Speichern/Laden erhält Position, Beziehungen, Reflexionen und interaktive Weltzustände.
- Freitexte werden standardmäßig nicht im Journal gespeichert, bei Opt-in überleben sie einen Speicherzyklus.
- Verschlüsseltes Save enthält den Testtext nicht im Klartext; ein schemawidriger Hauptstand führt zur Sicherung zurück.
- Ungültige Positionsdaten werden vor dem Schreiben abgelehnt.
- Profil, Karte, Charaktereditor, Einstellungen, Speicherplätze und Erinnerungen öffnen und schließen korrekt.
- Datenlöschung entfernt persönliche Texte auch aus Sicherungen; vollständige Löschung entfernt Testdateien und Schlüssel.
- Speichern und Rückkehr ins Hauptmenü funktionieren.

## Nachvollziehen

```bash
GODOT_BIN=/pfad/zu/Godot_v4.7.2-stable_linux.x86_64 python3 tools/manage.py test
GODOT_BIN=/pfad/zu/Godot_v4.7.2-stable_linux.x86_64 python3 tools/manage.py build
```

Mit lokalem Bildschirm kann zusätzlich ausgeführt werden:

```bash
godot --path game res://tests/tests.tscn -- --capture /absoluter/pfad/screenshots
```

Test-Spielstände landen in einem separaten `test_run_…`-Verzeichnis im Godot-Benutzerdatenordner. Die Tests laden oder löschen keine echten Spieler-Speicherplätze. Rohprotokolle und Screenshots liegen im ignorierten `builds/`-Ordner. Die vollständige Quelle enthält den Testläufer und sämtliche Ressourcen. `builds/SHA256SUMS.txt` dokumentiert die finalen Download-Artefakte.

Vor einem tatsächlichen Release bleiben insbesondere Windows-Spieltests, Grafik-/Dauertests auf Zielhardware, echte Audioprüfung, erweiterte Sprachtests für Offline-Dialoge, Barrierefreiheit und die offenen Phasen der Roadmap erforderlich. Die EXE ist eine unsignierte Entwicklungsversion, kein abschließend getesteter kommerzieller Release.
