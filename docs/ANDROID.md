# META ME 0.3.0 · Android

## Direkt installieren

1. `builds/META_ME_Android.apk` auf das Gerät übertragen und in der Dateien-App öffnen.
2. Falls Android fragt, der verwendeten Dateien-/Browser-App die Installation unbekannter Apps erlauben.
3. META ME öffnen und „Kapitel 1 beginnen“ antippen und mit Mara sprechen. Der goldene Marker und das Kapitelmenü zeigen den nächsten Schritt.

Alternativ mit USB-Debugging und Android-SDK:

```bash
adb install -r builds/META_ME_Android.apk
adb shell am start -n org.novacore.metame/com.godot.game.GodotAppLauncher
```

Voraussetzungen: **Android 7.0/API 24 oder neuer**, OpenGL ES 3.0, ARMv7, ARM64 oder x86_64. Empfohlen sind 3 GB RAM oder mehr. Die APK ist eine mit lokalem Entwicklungsschlüssel signierte Testversion. Ein Play-Store-Release mit eigenem Produktionsschlüssel und AAB ist nicht enthalten. Ein Update einer bereits installierten Variante benötigt denselben Signierschlüssel. Ein Entfernen der alten App löscht ihren privaten Spielstand.

## Bedienung

| Touch-Aktion | Funktion |
|---|---|
| Linker Stick | Analoge Bewegung, einschließlich diagonaler Bewegung |
| Auf freier Fläche rechts wischen | Third-Person-Kamera drehen |
| Sprint | Sprint umschalten; beim Öffnen eines Panels wird er zurückgesetzt |
| Benutzen | Das angezeigte Objekt in Reichweite verwenden |
| Reden | Gespräch mit Mara in Reichweite beginnen |
| Speichern | Aktuellen Speicherplatz sichern |
| Menü | Pause, Spielstände, Profil, Wohnungsplan, Erinnerungen und Einstellungen |
| Android-Zurück | Gespräch oder Panel schließen, sonst Pause öffnen |
| Antwortliste wischen | Weitere Gesprächsvorschläge ansehen |
| Eigene Antwort | Antippen, mit Bildschirmtastatur schreiben und Senden wählen |

Mehrere Finger besitzen unabhängige Aufgaben: Der linke Daumen kann die Figur bewegen, während der rechte die Kamera dreht. Touch-Aktionsknöpfe verwenden `TouchScreenButton`, damit sie parallel zum Stick funktionieren. Menüs, Dialoge und Hintergrundwechsel lösen alle gehaltenen Bewegungen. Sobald die Bildschirmtastatur sichtbar ist, wird die Vorschlagsliste ausgeblendet und die Eingabe oberhalb der Tastatur gehalten.

## Android-Verhalten

- Querformat, skalierbare Touch-Oberfläche und Berücksichtigung der Display-Sicherheitsränder bei den Touch-Steuerungen.
- Standardmäßig keine dynamischen Schatten und kein Echtzeit-Spiegelrendering. Die Spiegelinteraktion bleibt erhalten; hohe Qualität ist optional.
- 3D-Auflösung auf mobilen Geräten auf 75 % skaliert, Oberfläche bleibt separat skaliert. Mobile Licht-/Shaderpuffer sind für kleinere GLES-Grenzen reduziert.
- Autosave bei Kapitelübergängen sowie Speichern und Pause beim Wechsel in den Hintergrund. Der Android-Prozess kann später ohne Schlussbenachrichtigung beendet werden.
- Private App-Dateien, deaktiviertes Android-Cloud-Backup. Keine Internet-, Mikrofon- oder gemeinsamen Speicherberechtigungen erforderlich.
- Kein Online-KI-Dienst und keine extern übertragenen Gespräche.

## Selbst bauen

Benötigt werden Godot **4.7.2 stable**, passende offizielle Android-Exportvorlagen, **OpenJDK 17** sowie Android-SDK Platform Tools, Build Tools **36.0.0** und Plattform **android-36**. Der vorgefertigte APK-Export verwendet keine benutzerdefinierten Java-Plugins; Gradle, NDK und CMake sind dafür nicht erforderlich.

Die SDK-Pakete können mit den offiziellen Android Command-line Tools installiert werden:

```bash
sdkmanager --sdk_root="$ANDROID_HOME" "platform-tools" "build-tools;36.0.0" "platforms;android-36"
```

Danach die Pfade setzen und bauen:

```bash
export JAVA_HOME=/pfad/zum/jdk-17
export ANDROID_HOME=/pfad/zum/android-sdk
export GODOT_BIN=/pfad/zu/godot-4.7.2
python3 tools/manage.py build --target android
```

Godot verwendet diese Pfade als Editor-Standardwerte. Wenn ein vorhandenes Editorprofil andere Pfade gespeichert hat, unter Editor-Einstellungen → Export → Android „Java SDK Path“ und „Android SDK Path“ entsprechend setzen. Auf dieser Cloud-Instanz sind diese Pfade eingerichtet; die genauen Umgebungsvariablen stehen in der README.

Der Build führt die Desktop- und Touch-Integrationstests aus, exportiert die Debug-/Test-APK aus den offiziellen Godot-Vorlagen, prüft ZIP-Struktur, enthaltene Architekturen und APK-Signatur und erzeugt Quelle sowie SHA256-Prüfsummen. Die APK benötigt keinen separaten PCK-Download. Die Signierung erfolgt mit dem lokalen Godot-Entwicklungsschlüssel; Schlüsseldateien gehören nicht in das Repository oder Quellarchiv.

Für die Sichtprüfung ohne Android-Gerät lässt sich die Touch-Oberfläche auch auf dem Desktop einschalten:

```bash
godot --path game --resolution 1280x720 -- --touch
godot --path game res://tests/tests.tscn -- --touch
```

Die Testdateien prüfen unter anderem Mehrfingerbewegung, Kamera, Touch-Menü, Android-Zurück, Dialoggröße und den Speicherablauf beim Hintergrundwechsel. Das ersetzt keine Geräteprüfung. Messungen zu Akkulaufzeit, Wärmeentwicklung und 60 FPS auf konkreten Smartphones bleiben offen; die stilisierte Grafik und der bisherige Spielumfang entsprechen weiterhin dem ersten Meilenstein.

Für den nativen Bildschirmtastaturtest die emulierte Hardwaretastatur im AVD deaktivieren und das Gerät kalt starten. Eine aktivierte Hardwaretastatur kann die Bildschirmtastatur unterdrücken. In dieser Umgebung wurden Android 7 mit Mesa/GLES 3.1, echte Touch-Interaktionen, Freitext, Bildschirmtastatur, Hintergrundspeichern und Laden nach App-Neustart geprüft. Der SwiftShader-Treiber dieses Emulators erzeugte Shaderfehler und wurde für den erfolgreichen Lauf durch Mesa ersetzt; siehe Prüfprotokoll. Ein physisches Smartphone wurde noch nicht geprüft.
