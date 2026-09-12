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

* **Der Tag.** `commit: v2.13.3` zeigt auf einen annotierten Tag, nicht auf
  einen Branch. Jede weitere Version braucht einen weiteren Eintrag unter
  `Builds` und einen Tag dazu.
* **Die Versionsnummern stehen doppelt.** `--build-name` und
  `--build-number` müssen im Build-Befehl mitgegeben werden, weil
  `pubspec.yaml` bewusst kein `+N` führt (siehe „Versionierung" in
  CLAUDE.md). Ohne sie vergäbe Flutter `versionCode = 1`, und F-Droid bricht
  ab, weil der Code nicht zu dem in der Recipe passt.
* **`--dart-define=MT_VERSION`** ist dieselbe Nummer ein drittes Mal. Ohne
  sie bleibt die Ecke auf dem Profilbildschirm leer — ehrlich, aber unnötig.
* **Die Screenshots und Beschreibungen** holt F-Droid selbst aus
  `fastlane/metadata/android/` im getaggten Commit. Nichts davon gehört in
  die Recipe.

## Drei Punkte, an denen eine Prüfung hängenbleiben kann

**Flutter aus dem Beta-Kanal.** `pubspec.yaml` verlangt Dart
`^3.14.0-95.2.beta`, und die Recipe checkt deshalb `3.48.0-0.4.pre` aus. Ein
stabiles Flutter erfüllt diese Grenze nicht. Reviewer sehen das nicht gern,
und der saubere Ausweg ist, die Grenze zu senken und gegen das aktuelle
stabile Flutter zu prüfen — das ist eine Projektentscheidung und keine Frage
der Recipe. Die Grenze stammt vermutlich nur daher, dass `flutter create`
mit einem Beta-SDK lief.

**Die Signatur.** Ohne `android/key.properties` fällt der Release-Build in
`build.gradle.kts` auf den Debug-Schlüssel zurück, damit
`flutter run --release` ohne Keystore weiterläuft. Auf dem F-Droid-Bauer
gibt es keine `key.properties`, die APK kommt also debug-signiert heraus.
F-Droid signiert am Ende ohnehin selbst (`apksigner sign --in … --out …`
ersetzt vorhandene Signaturen), und `release` bleibt dabei nicht
debuggierbar — es sollte also durchlaufen. Wenn ein Reviewer daran Anstoß
nimmt, ist die Antwort eine Zeile mehr im Gradle-Skript: gar nicht signieren,
wenn kein Keystore da ist.

**Keine automatischen Updates.** `AutoUpdateMode: None` heißt, dass jede neue
Version von Hand als `Builds`-Eintrag nachgetragen wird. `UpdateCheckMode:
Tags` sorgt immerhin dafür, dass F-Droid einen neuen Tag meldet. Voll
automatisch ginge es erst, wenn in `pubspec.yaml` der Versionscode mit
stünde (`version: 2.13.3+21303`) — dann läse ihn die übliche
`UpdateCheckData` heraus. Das wäre dieselbe Zahl an zwei Stellen, und genau
das vermeidet das Projekt bisher.

## Was geprüft ist

* Keine Android-Berechtigung im Manifest, auch kein Internetzugriff.
* Keine Binärdateien im Repository: kein `.jar`, kein `.aar`, kein `.so`,
  kein Gradle-Wrapper-Jar. Die Icons sind PNG aus SVG erzeugt, die Töne
  WAV aus `tool/make_sounds.py`.
* Nur freie Abhängigkeiten; kein Firebase, keine Google Play Services.
* `LICENSE` ist der volle GPL-3-Text, und README nennt „Version 3 oder
  später" — daher `GPL-3.0-or-later`.
