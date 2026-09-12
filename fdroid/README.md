# Aufnahme bei F-Droid

`com.chrbayer.mathe_trainer.yml` ist die Build-Recipe, wie F-Droid sie
erwartet. Sie liegt hier, weil sie bei jeder Veröffentlichung mitgepflegt
werden muss — dort drüben ist sie eine Datei unter vielen, hier steht sie
neben dem, was sie beschreibt.

## Der Weg

F-Droid kennt zwei. Für einen Autor, der seine eigene App einreicht, ist der
**Merge Request** der richtige:

1. <https://gitlab.com/fdroid/fdroiddata> forken, Branch nach der Paket-ID
   benennen (`com.chrbayer.mathe_trainer`).
2. Die Datei hier nach `metadata/com.chrbayer.mathe_trainer.yml` kopieren.
3. Merge Request aufmachen. Die CI dort baut die App und meldet, woran es
   hakt.

Ein **RFP-Issue** unter <https://gitlab.com/fdroid/rfp> ist die andere Tür:
eine Bitte, dass jemand anders die App paketiert. Wer die Recipe ohnehin
schon geschrieben hat, spart sich damit nur die Wartezeit auf einen
Freiwilligen und bekommt dieselbe Prüfung.

Vor dem Einreichen lokal gegenprüfen (braucht `fdroidserver` und Docker):

```bash
fdroid build -v -l com.chrbayer.mathe_trainer
```

## Was die Recipe voraussetzt

* **Der Tag.** `commit: v2.13.4` zeigt auf einen annotierten Tag, nicht auf
  einen Branch. Jede weitere Version braucht einen Tag dazu; den Eintrag
  unter `Builds` schreibt F-Droid selbst (siehe unten).
* **Die Versionsnummern stehen in `pubspec.yaml`**, als `2.13.4+21304`.
  Deshalb braucht der Build-Befehl weder `--build-name` noch
  `--build-number`: Flutter nimmt beides von dort. Ein Test hält die zwei
  Hälften zusammen, siehe „Versionierung" in CLAUDE.md.
* **`--dart-define=MT_VERSION`** ist die Nummer noch einmal, damit die App
  sie anzeigen kann. `$$VERSION$$` setzt F-Droid aus `versionName` ein, also
  steht sie auch hier nicht von Hand da.
* **Die Screenshots und Beschreibungen** holt F-Droid selbst aus
  `fastlane/metadata/android/` im getaggten Commit. Nichts davon gehört in
  die Recipe. Der Änderungshinweis muss unter dem **versionCode** liegen,
  also `changelogs/21304.txt`.
* **Automatische Updates.** `UpdateCheckMode: Tags` findet den neuen Tag,
  `UpdateCheckData` liest Name und Code aus `pubspec.yaml`, und
  `AutoUpdateMode: Version v%v` legt den `Builds`-Eintrag an. Nach einem
  Release ist also nichts mehr von Hand zu tun — vorausgesetzt, der Tag
  heißt `v<Version>` und `pubspec.yaml` trägt das `+N`.

## Ein Punkt, an dem eine Prüfung hängenbleiben kann

**Die Signatur.** Ohne `android/key.properties` fällt der Release-Build in
`build.gradle.kts` auf den Debug-Schlüssel zurück, damit
`flutter run --release` ohne Keystore weiterläuft. Auf dem F-Droid-Bauer
gibt es keine `key.properties`, die APK kommt also debug-signiert heraus.
F-Droid signiert am Ende ohnehin selbst (`apksigner sign --in … --out …`
ersetzt vorhandene Signaturen), und `release` bleibt dabei nicht
debuggierbar — es sollte also durchlaufen. Wenn ein Reviewer daran Anstoß
nimmt, ist die Antwort eine Zeile mehr im Gradle-Skript: gar nicht signieren,
wenn kein Keystore da ist.

## Was geprüft ist

* Keine Berechtigung, die auf Daten, Sensoren oder das Netz zugreift, und
  insbesondere kein Internetzugriff. Die Liste des fertigen APK zeigt eine
  einzige Zeile, `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` — von AndroidX
  erzeugt, `protectionLevel="signature"`, und sie erlaubt nichts, sondern
  hält einen internen Empfänger von anderen Apps fern.
* Keine Binärdateien im Repository: kein `.jar`, kein `.aar`, kein `.so`,
  kein Gradle-Wrapper-Jar. Die Icons sind PNG aus SVG erzeugt, die Töne
  WAV aus `tool/make_sounds.py`.
* Nur freie Abhängigkeiten; kein Firebase, keine Google Play Services.
* `LICENSE` ist der volle GPL-3-Text, und README nennt „Version 3 oder
  später" — daher `GPL-3.0-or-later`.
* Die App baut und läuft auf dem **stabilen** Kanal; `pubspec.yaml` verlangt
  Dart `^3.13.0`, und das erfüllt Flutter 3.47.4.
