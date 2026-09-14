# Eine neue Version veröffentlichen

Die Schritte in der Reihenfolge, in der sie passieren müssen. Warum es so ist,
steht jeweils in den verlinkten Abschnitten; hier steht nur, was zu tun ist.

Eine Version landet an drei Stellen: als APK für alle auf criby.de, als
GitHub-Release mit vier APKs und — ohne weiteres Zutun — bei F-Droid. F-Droid
baut die App selbst aus dem Quelltext, vergleicht sie Byte für Byte mit dem
GitHub-Release und übernimmt dessen Signatur nur, wenn beides übereinstimmt.
Fast jede Regel unten dient diesem Vergleich.

## Einmalig vorhanden

* **Der Release-Schlüssel** unter `~/keys/mathetrainer-release.jks`, Alias
  `mathetrainer`, samt Kennwort **an zwei getrennten Orten gesichert**. Ohne ihn
  gibt es kein Update mehr, das sich über die installierte App legt — weder
  bei F-Droid noch bei den eigenen APKs.
* **`gh`** ist bei GitHub angemeldet (`gh auth status`).
* **Das installierte Flutter** ist genau die Fassung aus `.flutter-version`.

## 1. Version anheben

In `pubspec.yaml` Version **und** versionCode, beide zusammen:

```yaml
version: 2.14.0+21400
```

Der Code ist `Major * 10000 + Minor * 100 + Patch`. `flutter test` schlägt
fehl, wenn die beiden nicht zusammenpassen. Hintergrund: CLAUDE.md,
„Versionierung".

## 2. Änderungshinweis schreiben

Je eine **neue** Datei unter dem neuen versionCode, auf Deutsch und Englisch:

```
fastlane/metadata/android/de-DE/changelogs/21400.txt
fastlane/metadata/android/en-US/changelogs/21400.txt
```

Die alten Dateien bleiben liegen, jede gehört zu ihrer Version. Kurz halten,
höchstens 500 Zeichen, geschrieben für Eltern, nicht für Entwickler. F-Droid
zeigt ihn als „Was ist neu".

Hat sich an der Oberfläche etwas sichtbar geändert, auch die Screenshots
erneuern (README.md, „Store-Texte und Screenshots") und nach `en-US` kopieren.

## 3. Prüfen

```bash
flutter analyze
flutter test
```

Beides muss ohne Befund durchlaufen.

## 4. Committen, taggen, pushen

```bash
git add -A
git commit -m "…  (2.14.0)"
git tag -a v2.14.0 -m "…  (2.14.0)"
git push origin master
git push origin v2.14.0
```

`git add -A` und nicht `git commit -a`: die neuen Änderungshinweise aus
Schritt 2 sind neue Dateien, und `-a` nimmt nur schon bekannte mit. Das Skript
in Schritt 5 würde das nicht bemerken, denn neue, noch nicht erfasste Dateien
zählen für seine Prüfung nicht als Änderung.

Der Tag heißt immer `v` plus Version. Daran erkennt F-Droid die neue Version.

**Ab jetzt bis nach Schritt 5 nichts mehr committen.** Das Release muss genau
aus dem getaggten Commit entstehen.

## 5. Bauen und veröffentlichen

Im **eigenen Terminal**, nicht über ein Werkzeug, das die Eingaben mitliest:

```bash
cd ~/mt
export MT_KEYSTORE_PASS="$(systemd-ask-password 'Kennwort:')"
export MT_KEYSTORE_PATH=~/keys/mathetrainer-release.jks
./build_android.sh --github
```

Das Skript prüft vor dem ersten Build Schlüssel, Flutter-Version, sauberen
Arbeitsbaum und dass HEAD genau auf dem gepushten Tag steht, und bricht sonst
mit einer Meldung ab. Dann:

* baut es das APK für alle und lädt es nach criby.de (`--no-upload` lässt das
  weg),
* baut es drei APKs nach Prozessorart, genau so, wie F-Droid sie baut,
* prüft es, dass keines mit dem Debug-Schlüssel signiert ist,
* legt es alle vier als GitHub-Release `v2.14.0` ab.

Einzelheiten: CLAUDE.md, „Veröffentlichen für F-Droid".

## 6. Abwarten

Bei F-Droid ist **nichts von Hand** zu tun. Der Update-Check findet den neuen
Tag, liest Version und Code aus `pubspec.yaml`, legt die drei Build-Einträge
samt Verweis auf die Release-APKs an, baut, vergleicht und veröffentlicht. Das
läuft in F-Droids eigenem Takt und kann einige Tage dauern.

`fdroid/com.chrbayer.mathe_trainer.yml` im Projekt ist die Fassung aus dem
Merge Request. Nach der Aufnahme pflegt F-Droid die Recipe selbst; die Kopie
hier muss nicht bei jeder Version nachgezogen werden.

## Wenn etwas schiefgeht

* **Das Skript bricht vor dem Build ab.** Die Meldung sagt, welche Bedingung
  fehlt. Fehlt der Tag auf GitHub, erst pushen; steht HEAD nicht auf dem Tag,
  wurde nach dem Taggen noch committet.
* **Ein Upload ist schiefgegangen.** Das Skript überschreibt nie. Solange
  F-Droid die Version noch nicht gebaut hat, die betroffene Datei von Hand
  löschen (`gh release delete-asset v2.14.0 <Datei>`) und das Skript erneut
  laufen lassen. Hat F-Droid sie schon veröffentlicht, **nichts ersetzen**,
  sondern eine neue Version machen.
* **F-Droids Vergleich schlägt fehl.** Im Build-Log steht, welche Datei
  abweicht. War es eine native Bibliothek, ist meist ein neues Plugin mit
  C-Code der Grund; siehe CLAUDE.md, „Veröffentlichen für F-Droid".

## Sonderfälle

* **Flutter aktualisieren:** `.flutter-version` auf die neue Fassung setzen,
  prüfen, dann erst veröffentlichen. Das Skript verweigert ein Release mit
  einer anderen Fassung. Hintergrund: CLAUDE.md, „Flutter stable, nicht beta".
* **Ein Plugin mit nativem Code kommt dazu:** Beim ersten Release danach auf
  F-Droids Vergleich achten.
* **Tablets mit einer älteren, debug-signierten Installation:** Android lässt
  den Wechsel auf den Release-Schlüssel nicht zu. Im Elternbereich sichern,
  deinstallieren, neu installieren, Sicherung einspielen.
