# Entwurf für ein RFP-Issue

Für <https://gitlab.com/fdroid/rfp/-/issues>, falls der Weg über ein Issue
statt über einen Merge Request gehen soll. GitLab legt dort eine eigene
Vorlage vor; was hier steht, passt in deren Felder oder ersetzt sie.

Der Merge Request ist der schnellere Weg, siehe [README.md](README.md).

---

**Titel:** Mathe-Trainer

## Was die App macht

Kopfrechnen für die Grundschule, auf einem Tablet im Querformat. Die App
misst die Zeit bis zur richtigen Lösung und macht daraus eine Lernkurve und
Bestenlisten, in denen mehrere Kinder auf demselben Gerät gegeneinander
antreten. 76 Lektionen in neun Gruppen, von Bildern zählen über Plus und
Minus bis zum Einmaleins, Uhrzeit und Geld.

Eltern schalten hinter einer PIN Bereiche frei, begrenzen die Übungszeit am
Stück und am Tag und geben Aufgaben vor — täglich, wöchentlich oder als Plan
für einen bestimmten Tag.

Die Oberfläche ist auf Deutsch.

## Angaben

| | |
|---|---|
| Paket-ID | `com.chrbayer.mathe_trainer` |
| Quelltext | <https://github.com/chrbayer/mt> |
| Lizenz | GPL-3.0-or-later |
| Fehler und Fragen | <https://github.com/chrbayer/mt/issues> |
| Aktuelle Version | 2.13.3 (versionCode 21303), Tag `v2.13.3` |
| Gebaut mit | Flutter 3.48.0-0.4.pre |

Ich bin der Autor und reiche die App selbst ein.

## Warum sie hierher passt

* **Keine einzige Android-Berechtigung**, auch kein Internetzugriff. Die App
  kann nichts übertragen, selbst wenn sie wollte.
* Keine Werbung, kein Tracking, keine Analyse, keine Absturzberichte, keine
  Konten. Alles bleibt in einer Datenbank auf dem Gerät.
* Nur freie Abhängigkeiten, kein Firebase, keine Google Play Services.
* Keine Binärdateien im Repository: keine `.jar`, `.aar` oder `.so`, auch
  kein Gradle-Wrapper-Jar. Icons werden aus SVG gerendert, die Töne erzeugt
  ein Python-Skript im Repository.
* Beschreibungen, Änderungshinweise, Icon und zehn Screenshots liegen unter
  `fastlane/metadata/android/` in Deutsch und Englisch. Die Screenshots
  stammen aus der App selbst, erzeugt von einem Skript im Repository.
* Eine Datenschutzerklärung liegt als `DATENSCHUTZ.md` bei.

## Build-Recipe

Liegt fertig im Repository unter
[`fdroid/com.chrbayer.mathe_trainer.yml`](https://github.com/chrbayer/mt/blob/master/fdroid/com.chrbayer.mathe_trainer.yml).

Ein Punkt, den ich von mir aus nenne: `pubspec.yaml` verlangt Dart
`^3.14.0-95.2.beta`, die Recipe checkt deshalb ein Flutter aus dem
Beta-Kanal aus (`3.48.0-0.4.pre`). Die Grenze stammt daher, dass das Projekt
mit einem Beta-SDK angelegt wurde; ob die App sie tatsächlich braucht, habe
ich nicht gegengeprüft. Wenn ein stabiles Flutter Bedingung ist, senke ich
die Grenze und prüfe dagegen.
