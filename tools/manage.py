#!/usr/bin/env python3
"""Reproducible Godot import, meaningful integration tests and release packaging.

Use GODOT_BIN to select the pinned 4.7.2 editor. Export templates must match.
No third-party Python packages required. All generated output stays in builds/.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT / "game"
OUT = ROOT / "builds"
VERSION = "0.3.0"
ENGINE = "4.7.2"


def godot() -> str:
    binary = os.environ.get("GODOT_BIN") or shutil.which("godot") or shutil.which("godot4")
    if not binary:
        raise RuntimeError("Godot fehlt. Godot 4.7.2 installieren und GODOT_BIN setzen.")
    result = subprocess.run([binary, "--version"], check=True, capture_output=True, text=True)
    if not result.stdout.strip().startswith(ENGINE + ".stable"):
        raise RuntimeError(f"Godot {ENGINE} stable erforderlich; gefunden: {result.stdout.strip()}")
    return str(binary)


def run(binary: str, args: list[str], log: str, exported: bool = False) -> str:
    command = [binary, *args] if exported else [binary, "--path", str(GAME), *args]
    result = subprocess.run(command, cwd=Path(binary).parent if exported else ROOT,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=180)
    output = result.stdout
    (OUT / log).write_text(output, encoding="utf-8")
    print(output, end="")
    if result.returncode or re.search(r"(^|\n)(SCRIPT ERROR:|ERROR:)", output):
        raise RuntimeError(f"Godot fehlgeschlagen ({result.returncode}); siehe builds/{log}")
    return output


def tests(binary: str) -> None:
    run(binary, ["--headless", "--editor", "--import", "--quit"], "import.log")
    output = run(binary, ["--headless", "res://tests/tests.tscn"], "tests.log")
    match = re.search(r"RESULT: (\d+) checks, (\d+) failures", output)
    if not match or int(match[1]) < 50 or int(match[2]):
        raise RuntimeError("Integrationstests unvollständig oder fehlgeschlagen.")
    output = run(binary, ["--headless", "res://tests/tests.tscn", "--", "--touch"], "tests-touch.log")
    match = re.search(r"RESULT: (\d+) checks, (\d+) failures", output)
    if not match or int(match[1]) < 70 or int(match[2]):
        raise RuntimeError("Touch-Integrationstests unvollständig oder fehlgeschlagen.")


def android_package(binary: str) -> Path:
    sdk = Path(os.environ.get("ANDROID_HOME", ""))
    java = Path(os.environ.get("JAVA_HOME", ""))
    if not (sdk / "platform-tools" / ("adb.exe" if os.name == "nt" else "adb")).is_file():
        raise RuntimeError("ANDROID_HOME muss auf ein SDK mit platform-tools zeigen.")
    if not (java / "bin" / ("keytool.exe" if os.name == "nt" else "keytool")).is_file():
        raise RuntimeError("JAVA_HOME muss auf OpenJDK 17 oder höher zeigen.")
    # Godot initializes its SDK defaults from ANDROID_HOME/JAVA_HOME. The
    # regular editor import/shutdown path avoids running an editor SceneTree
    # script while EditorNode is still being initialized.
    artifact = OUT / "META_ME_Android.apk"
    run(binary, ["--headless", "--export-debug", "Android", str(artifact)], "export-android.log")
    with zipfile.ZipFile(artifact) as archive:
        if archive.testzip() is not None:
            raise RuntimeError("APK-Integritätsprüfung fehlgeschlagen.")
        entries = set(archive.namelist())
        for entry in ["AndroidManifest.xml", "classes.dex", "lib/arm64-v8a/libgodot_android.so", "lib/x86_64/libgodot_android.so"]:
            if entry not in entries:
                raise RuntimeError(f"APK unvollständig: {entry} fehlt.")
    tools = sorted((sdk / "build-tools").iterdir(), reverse=True)
    suffix = ".bat" if os.name == "nt" else ""
    signer = next((path / ("apksigner" + suffix) for path in tools if (path / ("apksigner" + suffix)).is_file()), None)
    if signer is None:
        raise RuntimeError("apksigner fehlt in ANDROID_HOME/build-tools.")
    signed = subprocess.run([str(signer), "verify", "--verbose", str(artifact)],
                            check=True, capture_output=True, text=True, timeout=60)
    (OUT / "android-signature.log").write_text(signed.stdout + signed.stderr, encoding="utf-8")
    (OUT / "ANDROID-INSTALLATION.txt").write_text(
        "META ME 0.3.0 — Android-Testversion\n\n"
        "META_ME_Android.apk auf das Gerät übertragen und dort öffnen.\n"
        "Für die verwendete Dateien-/Browser-App die Installation unbekannter Apps erlauben.\n"
        "Alternativ über das Android-SDK: adb install -r META_ME_Android.apk\n"
        "Android 7.0/API 24 oder neuer, OpenGL ES 3.0; ARMv7, ARM64 und x86_64.\n\n"
        "Links: Bewegungsstick. Rechts: zum Drehen der Kamera wischen.\n"
        "Benutzen/Reden: Objekt/Gespräch in Reichweite. Sprint: umschalten.\n"
        "Menü: Pause, Profil, Wohnungsplan, Einstellungen und Spielstände.\n"
        "Speichern: sofort sichern. Android-Zurück: Dialog/Panel schließen.\n"
        "Beim Hintergrundwechsel wird gespeichert und pausiert.\n"
        "Dialogantworten nach oben wischen oder eigene Antwort über Bildschirmtastatur eingeben.\n\n"
        "Mit lokalem Entwicklungsschlüssel signierte Test-APK, kein Play-Store-Release.\n"
        "Keine Internet-, Mikrofon- oder gemeinsamen Speicherberechtigungen nötig.\n"
        "Speicherstände liegen im privaten App-Speicher. Deinstallation entfernt sie.\n"
        "Ein anderer Signierschlüssel verhindert ein Update über eine vorhandene Installation.\n",
        encoding="utf-8")
    print(f"Erstellt und Signatur geprüft: {artifact} ({artifact.stat().st_size:,} Bytes)")
    return artifact


def package(binary: str, target: str) -> Path:
    windows = target == "windows"
    folder = OUT / target
    folder.mkdir(exist_ok=True)
    executable = folder / ("META_ME.exe" if windows else "META_ME.x86_64")
    run(binary, ["--headless", "--export-release", "Windows Desktop" if windows else "Linux",
                 str(executable)], f"export-{target}.log")
    pack = executable.with_suffix(".pck")
    if not executable.is_file() or not pack.is_file() or pack.stat().st_size < 1000:
        raise RuntimeError("Export unvollständig: Binary oder Ressourcen fehlen.")
    if windows:
        with executable.open("rb") as handle:
            if handle.read(2) != b"MZ":
                raise RuntimeError("Export ist keine Windows-PE-Datei.")
    else:
        executable.chmod(0o755)
        run(str(executable), ["--headless", "--quit-after", "60"], "linux-export-smoke.log", exported=True)
    (folder / "README.txt").write_text(
        "META ME 0.3.0 — THE BEGINNING\n\n"
        "Den gesamten ZIP-Inhalt entpacken. " + executable.name + " starten.\n"
        "EXE/Binary und META_ME.pck im selben Ordner behalten.\n"
        "Windows 10/11 x64, OpenGL 3.3-kompatible Grafik. Kein Internet nötig.\n"
        "Unsignierte Entwicklungsversion; kein Installer, kein finaler Release.\n\n"
        "WASD: Bewegung | Maus: Kamera | Shift: Sprint\n"
        "E: Objekt benutzen | F: mit Mara sprechen | Esc: Pause\n"
        "Tab: Profil | M: Wohnungsplan | J: Erinnerungen | F5: Speichern | F9: Laden\n\n"
        "Erkunde den Spiegel links im Wohnzimmer, sprich mit Mara und speichere.\n"
        "Drei Speicherplätze; automatische Sicherung nach 120 Sekunden aktiven Spiels.\n"
        "Freitextaufbewahrung ist standardmäßig aus. Löschung in Spielstände/Erinnerungen.\n"
        "Lokale Verschlüsselung schützt nicht gegen Zugriff auf dein Betriebssystemkonto.\n"
        "Spielwerte sind keine psychologische Diagnose oder echte Persönlichkeitsmessung.\n\n"
        "Umfang: ein Apartment mit Schlafzimmer, Bad, Küche, Wohnzimmer und Balkon;\n"
        "ein NPC, Offline-Dialoge, einfache Spielbeobachtungen und lokale Spielstände.\n"
        "Nicht enthalten: Online-KI, weitere Viertel, vollständiger Avatar-Editor,\n"
        "Spiegelwelt, Multiplayer, realistische Charaktergrafik. Android hat einen separaten APK-Export.\n",
        encoding="utf-8")
    (folder / "VERSION.json").write_text(json.dumps({
        "game": "META ME", "version": VERSION, "godot": ENGINE, "target": target,
        "stage": "first-playable", "windows_native_runtime_tested": False,
    }, indent=2) + "\n", encoding="utf-8")
    shutil.copyfile(GAME / "assets/FONT-LICENSE.txt", folder / "FONT-LICENSE.txt")
    archive = OUT / ("META_ME_Windows_x64.zip" if windows else "META_ME_Linux_x64.zip")
    # Fixed timestamp/order for deterministic ZIP metadata; export uses engine tools.
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as handle:
        for path in sorted(folder.iterdir()):
            if path.is_file():
                info = zipfile.ZipInfo(path.name, (2026, 1, 1, 0, 0, 0))
                info.external_attr = (0o100755 if path == executable else 0o100644) << 16
                info.compress_type = zipfile.ZIP_DEFLATED
                handle.writestr(info, path.read_bytes())
    print(f"Erstellt: {archive} ({archive.stat().st_size:,} Bytes)")
    return archive


def source_archive() -> Path:
    archive = OUT / "META_ME_Source.zip"
    files = [ROOT / "README.md", ROOT / ".gitignore"]
    for directory in [GAME, ROOT / "tools", ROOT / "docs"]:
        files += [p for p in directory.rglob("*") if p.is_file()
                  and ".godot" not in p.parts and "__pycache__" not in p.parts]
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as handle:
        for path in sorted(files):
            handle.write(path, Path("META_ME") / path.relative_to(ROOT))
    return archive


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["test", "build", "source"])
    parser.add_argument("--target", choices=["android", "windows", "linux", "all"], default="android")
    args = parser.parse_args()
    OUT.mkdir(exist_ok=True)
    archives = []
    if args.command != "source":
        binary = godot()
        tests(binary)
        if args.command == "build":
            for target in (["android", "windows", "linux"] if args.target == "all" else [args.target]):
                archives.append(android_package(binary) if target == "android" else package(binary, target))
    if args.command in ["source", "build"]:
        archives.append(source_archive())
        if args.command == "source":
            archives = sorted([*OUT.glob("META_ME_*.zip"), *OUT.glob("META_ME_*.apk")])
        (OUT / "SHA256SUMS.txt").write_text("".join(
            f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}\n" for path in archives), encoding="utf-8")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"FEHLER: {error}", file=sys.stderr)
        sys.exit(1)
