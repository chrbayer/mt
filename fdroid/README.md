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

* **Ein Commit-Hash, kein Tag.** `commit:` nennt den vollständigen Hash des
  getaggten Commits. Der Paketierer hat das ausdrücklich verlangt: ein Tag
  lässt sich verschieben, ein Hash nicht. Getaggt wird trotzdem, denn
  `UpdateCheckMode: Tags` findet neue Versionen über die Tags.
* **Die Versionsnummern stehen in `pubspec.yaml`**, als `2.13.7+21307`.
  Deshalb braucht der Build-Befehl weder `--build-name` noch
  `--build-number`: Flutter nimmt beides von dort. Ein Test hält die zwei
  Hälften zusammen, siehe „Versionierung" in CLAUDE.md.
* **`--dart-define=MT_VERSION`** ist die Nummer noch einmal, damit die App
  sie anzeigen kann. `$$VERSION$$` setzt F-Droid aus `versionName` ein, also
  steht sie auch hier nicht von Hand da.
* **Die Screenshots und Beschreibungen** holt F-Droid selbst aus
  `fastlane/metadata/android/` im getaggten Commit. Nichts davon gehört in
  die Recipe. Der Änderungshinweis muss unter dem **versionCode** liegen,
  also `changelogs/21307.txt`.
* **Die Flutter-Version kommt aus dem Projekt.** Die Recipe holt
  `flutter@stable` und checkt dann den Tag aus, der in `.flutter-version`
  steht. Auch das hat der Paketierer verlangt, und es hat einen Vorteil:
  F-Droid kopiert beim automatischen Update den vorigen `Builds`-Block, eine
  fest eingetragene Flutter-Version bliebe also für immer stehen.
* **Automatische Updates.** `UpdateCheckMode: Tags` findet den neuen Tag,
  `UpdateCheckData` liest Name und Code aus `pubspec.yaml`, und
  `AutoUpdateMode: Version v%v` legt den `Builds`-Eintrag an. Nach einem
  Release ist also nichts mehr von Hand zu tun — vorausgesetzt, der Tag
  heißt `v<Version>` und `pubspec.yaml` trägt das `+N`.

## Reproducible Builds

Der Paketierer hat sie im Review erbeten. F-Droid baut die APKs dann weiter
selbst aus dem Quelltext, vergleicht sie aber mit den APKs aus dem
GitHub-Release und übernimmt **deren Signatur**, wenn jedes Byte stimmt. So
tragen die F-Droid-Fassung und die eigenen APKs denselben Schlüssel.

Der Ablauf je Version:

1. Version anheben, committen, `v<Version>` taggen und pushen.
2. Im eigenen Terminal, mit gesetztem `MT_KEYSTORE_PATH` und
   `MT_KEYSTORE_PASS`, auf genau diesem Commit `./build_android.sh --github`.
3. In der Recipe je Block `binary:` auf das passende Release-APK zeigen lassen
   und oben `AllowedAPKSigningKeys` mit dem Fingerabdruck des Zertifikats:
   `7e85b3258cfd28059278887f771d0be0feb7b81c8143903129f8529937a611a1`.

Stimmen F-Droids Build und das Release nicht überein, meldet das die CI. Der
wahrscheinlichste Unterschied ist der Build-Pfad; das Skript gibt ihn aus.

## Ein APK je Prozessorart

Der Paketierer hat es im Review verlangt, und es lohnt sich: statt 60 MB für
alle drei Prozessorarten sind es 18 bis 22 MB je APK. Die Recipe hat deshalb
drei `Builds`-Blöcke, je einer mit `--split-per-abi --target-platform=…`.

Die Codes vergibt `android/app/build.gradle.kts`: `versionCode * 10` plus 1
für `armeabi-v7a`, 2 für `arm64-v8a`, 3 für `x86_64`. F-Droid prüft, dass der
Code **im APK** zu dem in der Recipe passt, also muss das Schema im Projekt
stehen und nicht nur in `VercodeOperation`. Geprüft an gebauten APKs.

## Zwei Dinge, die die CI beim ersten Anlauf beanstandet hat

Beide sind behoben; sie stehen hier, weil sie beim nächsten Mal wieder
zuschlagen würden.

**`AutoUpdateMode: Version v%v` ist ungültig.** Das Schema erlaubt nur
`None` oder `Version`, letzteres höchstens mit einem `+Suffix`. Der
Tag-Präfix gehört nicht dorthin: `UpdateCheckMode: Tags` findet den Tag, und
Name und Code kommen aus `UpdateCheckData`, nicht aus dem Tag-Namen.

**`AutoName` muss dabeistehen.** Der CI-Schritt `checkupdates` liest den
Namen aus dem Android-Manifest und trägt ihn nach; steht er nicht schon da,
verändert der Schritt die Datei und schlägt genau deshalb fehl.

**Gradles Abhängigkeitsblock muss raus.** `check apk` wies das fertige APK
ab: „Found extra signing block 'Dependency metadata'". Den legt das
Android-Gradle-Plugin an, verschlüsselt mit einem Google-Play-Schlüssel, und
von außen ist nicht nachprüfbar, was darin steht. `dependenciesInfo` in
`android/app/build.gradle.kts` schaltet ihn ab. Das gehört ins Projekt, nicht
in die Recipe.

## Die Signatur ist kein Problem

Ohne `android/key.properties` fällt der Release-Build in `build.gradle.kts`
auf den Debug-Schlüssel zurück, damit `flutter run --release` ohne Keystore
weiterläuft, und auf dem F-Droid-Bauer gibt es keine `key.properties`. Das
war die offene Frage, und die CI hat sie beantwortet: sie hat
`com.chrbayer.mathe_trainer:21307` gebaut und anschließend mit
`apksigner sign --in … --out …` selbst signiert. Eine vorhandene Signatur
wird dabei ersetzt.

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
* **Der Bauer von F-Droid hat es selbst gebaut.** Der CI-Schritt
  `fdroid build` im Fork meldet „Successfully built
  com.chrbayer.mathe_trainer:21307" — nicht aus dieser Recipe abgeleitet,
  sondern mit ihr ausgeführt.
