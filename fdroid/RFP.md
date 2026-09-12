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
| Aktuelle Version | 2.13.4 (versionCode 21304), Tag `v2.13.4` |
| Gebaut mit | Flutter 3.47.4 (stable) |

Ich bin der Autor und reiche die App selbst ein.

## Warum sie hierher passt

* **Keine Berechtigung, die auf Daten, Sensoren oder das Netz zugreift**,
  insbesondere kein Internetzugriff — die App kann nichts übertragen, selbst
  wenn sie wollte. Die Liste zeigt einen einzigen Eintrag, den AndroidX
  erzeugt: `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` mit
  `protectionLevel="signature"`, der nur einen internen Empfänger vor anderen
  Apps abschirmt.
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

Sie baut mit dem stabilen Kanal, und `UpdateCheckMode: Tags` zusammen mit
`AutoUpdateMode` sollte jede weitere Version ohne Zutun finden: Name und
versionCode stehen beide in `pubspec.yaml`, und die Tags heißen `v<Version>`.
