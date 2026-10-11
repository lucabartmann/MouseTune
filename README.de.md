<p align="center">
  <img src="Resources/AppIcon.png" width="128" alt="MouseTune icon">
</p>

<h1 align="center">MouseTune</h1>

Eine kleine, native Menüleisten-App für macOS, die jeder Maus die wichtigsten Funktionen von Logitech Options+ gibt — ohne Logitech-Software, Abhängigkeiten, Netzwerkzugriff oder Telemetrie.

*English version: [README.md](README.md)*

## Funktionen
- **Zeigergeschwindigkeit** nur für die Maus (Trackpad bleibt unberührt)
- **Scrollgeschwindigkeit** nur für das Mausrad
- **Scrollrichtung** (System / Natürlich / Klassisch), unabhängig von der Systemeinstellung „Natürliches Scrollen“ — Maus und Trackpad können dauerhaft unterschiedlich scrollen
- **Tastenbelegung** für die Tasten 2–7 (Mitte, Zurück, Vor, …): Mission Control, Spaces, Kopieren/Einfügen, Medientasten, Bildschirmfoto u. a.
- Geführtes **Onboarding**, UI auf **Deutsch / English** (in der App umschaltbar), Akzentfarben, Start beim Anmelden

Voraussetzung: macOS 13 oder neuer.

## Installieren
### Homebrew
```bash
brew install --cask lucabartmann/tap/mousetune
```

### Manuell
`MouseTune.zip` von der Releases-Seite laden, entpacken und `MouseTune.app` nach `/Programme` verschieben. Releases sind ad hoc signiert — beim ersten Start Rechtsklick → *Öffnen*.

## Selbst bauen
Voraussetzung: Xcode oder Command Line Tools.

```bash
./build.sh            # erzeugt build/MouseTune.app
./build.sh --zip      # erzeugt zusätzlich build/MouseTune.zip
swift test            # führt die Unit-Tests aus
```

Oder `MouseTune.xcodeproj` in Xcode öffnen und ⌘R drücken. Dateien in `Sources/MouseTune` werden automatisch übernommen.

Eigenes Zertifikat: `SIGN_IDENTITY="Dein Name" ./build.sh`

## Berechtigungen
Der Event-Tap (Scrollen, Tasten) braucht **Systemeinstellungen → Datenschutz & Sicherheit → Bedienungshilfen**, auf manchen macOS-Versionen auch **Eingabeüberwachung**. Das Onboarding führt dich hindurch; der Hinweis in der App verschwindet automatisch, sobald die Freigabe erteilt ist. Die Zeigergeschwindigkeit braucht keine Berechtigung.

Eine Ad-hoc-Signatur ändert sich bei jedem Build, wodurch macOS die Freigabe verwirft. Eintrag in den Systemeinstellungen entfernen und die App neu hinzufügen — oder mit einem stabilen Zertifikat signieren.

## Hinweise
- Die Zeigergeschwindigkeit gilt nur, solange MouseTune läuft; beim Beenden wird der Systemwert wiederhergestellt.
- Logitechs Gestentaste und das Daumenrad laufen über HID++ und erscheinen ohne Logitech-Software eventuell nicht als Maustaste.
- Links- und Rechtsklick werden nie verändert.

## Mitmachen
Siehe [CONTRIBUTING.md](CONTRIBUTING.md). Eine neue Sprache hinzuzufügen erfordert nur eine Datei.

## Datenschutz
MouseTune baut keine Netzwerkverbindungen auf, sammelt keine Daten und protokolliert keine Eingaben.

## Lizenz
[MIT](LICENSE)
