# Projektkonventionen

## Sprache

Oberfläche und Dokumentation auf Deutsch, Code-Bezeichner und Kommentare auf
Englisch.

## Schichten

`lib/domain/` darf **keinen** Flutter-Import enthalten. Dort liegt die
Fachlogik (Lektionen, Aufgabengenerator, Wertung), und genau deshalb ist sie
vollständig unit-testbar. Neue Rechenregeln gehören dorthin, nicht in Widgets.

Aggregation passiert in SQL (`lib/data/repositories/stats_repository.dart`),
nicht in Dart. Der Wertungsausdruck steht dort einmal als `_score` und bezieht
`wrongAttemptPenaltyMs` aus `domain/scoring.dart` — beim Ändern der Wertung nur
diese eine Konstante anfassen.

## Lektionen

Gespeicherte Durchgänge überleben den Katalog. Wo eine **gespeicherte** ID
angezeigt wird — Übungsverlauf, Bestenlisten-Übersicht — gehört
`lessonByIdOrNull` hin, nicht `lessonById`: eine Sicherung aus einer neueren
Version oder eine entfallene Lektion würde den Elternbereich sonst mitreißen.
Deshalb behielt `calc_to_six` beim Aufspalten in Plus/Minus/gemischt auch
seine ID.

`LessonGroup` heißt nicht mehr `NumberRange`: die ersten vier Werte sind
Zahlenräume, die letzten beiden gruppieren nach Rechenart. Das Einmaleins wird
Reihe für Reihe gelernt, nicht nach Größe der Zahlen.

Lektionen sind Code-Konstanten in `domain/lesson.dart` mit stabiler String-ID.
Die ID landet in der Datenbank, der Rest nicht. **IDs nie umbenennen** — sonst
verlieren bestehende Bestenlisten ihren Bezug. Titel und Erklärtexte dürfen
sich dagegen jederzeit ändern.

Ab 20 bieten alle Zahlenräume dieselben sieben Lektionen; sie entstehen in
`_group()`, damit die Gruppen nicht auseinanderlaufen. **Bis 10 nicht**: dort
kann keine Aufgabe die Zehn überschreiten, eine Aufteilung in „mit" und „ohne
Zehnerübergang" wäre eine Unterscheidung ohne Unterschied. Diese Gruppe steht
deshalb einzeln in `_upTo10Lessons`.

Ein neuer Zahlenraum braucht einen Wert in `NumberRange`, einen Fall in
`rangeTitle()`, zwei Fälle im `switch` in `task_generator.dart` und entweder
einen `_group()`-Aufruf oder eine eigene Liste.

Additionen werden bewusst in beiden Reihenfolgen gezeigt. Die Zahlenbereiche
ziehen den ersten Operanden aus dem weiten Ende und den zweiten aus dem Rest —
ohne den Tausch am Ende von `_sample()` stünde in rund drei Vierteln der
Aufgaben die größere Zahl vorn. Deshalb ignoriert `Task.key` bei
`TaskForm.result` die Reihenfolge: `13 + 68` und `68 + 13` sind dieselbe
Tatsache und sollen nicht kurz hintereinander kommen.

Glatte Zehner und der Operand 1 sind erlaubt, aber durch `_maxEasyShare` auf
ein Fünftel des Durchgangs gedeckelt. Ohne den Deckel wird „Plus ohne
Zehnerübergang bis 20" zur Plus-eins-Übung, weil der Ziehungsbereich für den
zweiten Operanden dort sehr klein ist. Im Zahlenraum bis 10 gilt der Deckel
nicht: dort sind 1 und 10 zwei von elf Zahlen, keine Abkürzungen.

Multiplikation und Division laufen an der Zahlenraum-Logik vorbei:
`_sample()` verzweigt nach Operation, `_sampleProduct` und `_sampleQuotient`
kennen keine `CarryMode`. Divisionen werden **rückwärts** aus dem kleinen
Einmaleins gebaut (Divisor mal Quotient plus Rest), damit sie nie außerhalb
davon landen. Lektionen mit `TaskForm.remainder` haben immer einen Rest ≥ 1 —
das ist es ja, wonach sie benannt sind.

Das Kontingent für leichte Operanden gilt in beiden neuen Gruppen nicht: in
der 10er-Reihe enthält jede einzelne Aufgabe eine Zehn.

Der Generator garantiert **keine** globale Eindeutigkeit: bis 20 gibt es
schlicht keine 50 verschiedenen Aufgaben mit Zehnerübergang. Garantiert ist,
dass sich eine Rechnung innerhalb von acht Aufgaben nicht wiederholt.

Lektionen mit `fixedSum` (verliebte Zahlen) laufen an dieser Stichprobenlogik
vorbei: ihr Vorrat sind elf feste Paare, deshalb erzeugt
`_generateFixedSumTasks` gemischte Durchläufe des kompletten Vorrats. Jedes
Paar kommt gleich oft dran, in jeder Runde neu gemischt, nie zweimal
hintereinander.

`TaskForm.partner` wird bewusst nicht als Gleichung dargestellt: Erstklässler
lesen noch keine Gleichungen. Deshalb Frage plus Herz statt `3 + ? = 10`.

## Zeitmessung

Immer über `Stopwatch` (monoton), nie über `DateTime.now()`-Differenzen. Die
Uhr läuft über Fehlversuche hinweg weiter und wird angehalten, sobald die App
in den Hintergrund geht — sonst verfälschen Unterbrechungen die Statistik.
`PracticeController` nimmt eine `Stopwatch` als Parameter entgegen, damit Tests
die Zeit selbst vorspulen können.

## Oberfläche

Die Zifferntastatur akzeptiert eine einzelne **0** als Antwort — es gibt
Aufgaben mit Ergebnis 0 (`8 − 8`, später auch `3 · 0`). Eine folgende Ziffer
ersetzt die 0, statt `07` daraus zu machen. Entsprechend schließt der Generator
Ergebnisse von 0 nicht aus, wohl aber knappe Beinahe-Treffer wie `74 − 73`.

Querformat, sehr große Typografie, keine Ablenkung. Während der Übung wird
**nie** die Systemtastatur benutzt — Eingabe ausschließlich über `BigKeypad`
(Tasten mindestens 96 dp). Einzige Ausnahme: die Namenseingabe im
Profil-Editor.

## Eine Zeit, überall dieselbe

`scoreMsPerTask` — Zeit plus 3 Sekunden je Fehlversuch, geteilt durch die
Aufgabenzahl — ist **die** Zeitangabe der App: Ergebnisbildschirm, Lernkurve,
Lektionstabelle, Übungsverlauf, Bestenlisten. Es gibt bewusst **keine**
strafenfreie Variante mehr. Es gab eine, und das Ergebnis war, dass
Ergebnisbildschirm und Bestenliste unterschiedliche Zahlen für denselben
Durchgang zeigten; kein Erklärsatz hat das geheilt.

Roh gespeichert bleiben `total_ms` und `wrong_attempts` getrennt — daraus lässt
sich die gewertete Zeit jederzeit bilden, umgekehrt nicht. Wer eine reine
Rechenzeit braucht, rechnet sie aus diesen beiden aus.

Die einzige Ausnahme ist „geübte Zeit" in der Übersicht über alle Kinder: das
ist eine **Dauer**, keine Wertung. Wer Fehler macht, hat nicht länger geübt.

## Bestenlisten

Die Übersicht über alle Bestenlisten holt `watchAllLeaderboards()` in **einer**
Abfrage, nicht in einer je Lektion — es sind über vierzig. Sie nutzt dieselbe
`MIN()`-Eigenschaft von SQLite wie die Einzelliste (die übrigen Spalten stammen
aus der Bestzeile) und ermittelt „zuletzt geübt" über eine korrelierte
Unterabfrage, weil das etwas anderes ist als der Zeitpunkt der Bestleistung.

## Sichtbare Bereiche

`users.hidden_groups` speichert die **abgeschalteten** Gruppen als
kommagetrennte Enum-Namen, nicht die freigeschalteten. So erscheint eine in
einer späteren Version ergänzte Gruppe bei allen Kindern, statt stillschweigend
unsichtbar zu bleiben. Unbekannte Namen werden beim Lesen übergangen
(`UserVisibleGroups` in `user_repository.dart`), damit ein Downgrade die
Einstellung nicht zerstört.

## Datenbank

Zeitstempel sind Epoch-Millisekunden in `IntColumn`, damit das rohe SQL in den
Repositories eindeutig bleibt. Nach Änderungen am Schema
`dart run build_runner build` ausführen, `schemaVersion` erhöhen und
`onUpgrade` ergänzen — **und einen Migrationstest schreiben**. Es gibt einen
in `test/data/repositories_test.dart`, der eine Datenbank ins alte Schema
zurückbaut, sie erneut öffnet und prüft, dass Profile und Durchgänge die
Migration überleben. Auf den Tablets liegen echte Ergebnisse.

## Icon

Alle Android-Icons werden aus `assets/icon/*.svg` erzeugt, nicht von Hand
bearbeitet. Nach einer Änderung an der SVG neu rendern (`rsvg-convert`):

* `mipmap-<dichte>/ic_launcher.png` — 48/72/96/144/192 px aus `icon.svg`
* `mipmap-<dichte>/ic_launcher_foreground.png` und `_monochrome.png` —
  108/162/216/324/432 px aus `icon_foreground.svg` bzw. `icon_monochrome.svg`
* `drawable-<dichte>/launch_image.png` — 128/192/256/384/512 px aus `icon.svg`

Der Vordergrund ist bewusst auf 0.7 skaliert: Android zeigt nur die mittleren
66 % der Adaptive-Icon-Fläche, der Rest wird von der Maske beschnitten.

## Zwei Eingabefelder

`TaskForm.remainder` ist die einzige Form mit zwei Antworten. Der
`PracticeController` führt dafür `activeField`; der grüne Haken schiebt vom
Ergebnis zum Rest weiter, **ohne** das Ergebnis schon zu bewerten — sonst
verriete die Rückmeldung die halbe Aufgabe. Rückschritt aus dem leeren
Rest-Feld führt zurück ins Ergebnisfeld. Gewertet wird erst beides zusammen.

## Systemtastatur

Der Profil-Editor ist die einzige Stelle mit Systemtastatur, und die App ist
aufs Querformat festgenagelt — auf einem Handy bleiben damit unter 200 dp.
Deshalb fragt er in zwei Schritten: erst nur der Name, danach Bild und Farbe
ohne offene Tastatur. Unter 280 dp Resthöhe entfällt zusätzlich die
Überschrift, sonst wird sie halb abgeschnitten.

Der Test in `test/features/profile_editor_test.dart` simuliert die Tastatur
über `tester.view.viewInsets` und prüft, dass der Schritt **nicht scrollen
muss** — scrollen hieße, dass etwas verdeckt ist. Wer dort etwas ergänzt, muss
diesen Test bestehen.

## Navigation aus einem Bottom Sheet

Den `NavigatorState` **vor** dem `pop()` in eine lokale Variable holen. Nach
dem Schließen ist der Kontext des Sheets ungültig, und ein zweites
`Navigator.of(context)` läuft ins Leere, ohne zu meckern — genau so waren „Los
geht's" und „Bestenliste" einmal komplett tot.

## Elternbereich

Die PIN (`SettingsRepository.setAdminPin` / `checkAdminPin`) schützt vor einem
neugierigen Geschwisterkind, nicht vor einem Angreifer mit dem Gerät in der
Hand. Trotzdem wird sie gesalzen gehasht abgelegt — ein Blick in die Datenbank
soll sie nicht verraten. Beim Ändern wird die alte PIN gelöscht und der
Einrichtungsdialog erneut gezeigt; nach der alten zu fragen wäre sinnlos, der
Weg dorthin führte gerade durch sie hindurch.

`requireAdminPin(context)` ist die einzige Schranke. Wer sie umgeht, umgeht den
Schutz — neue geschützte Aktionen also immer dahinter aufhängen.

## Aufgabenzahl: drei Ebenen

`resolveTaskCount` in `domain/task_count.dart` legt die Rangfolge fest: Lektion
vor Profil vor global. Gespeichert wird in drei Töpfen — `lesson_preferences`
(Kind × Lektion), `users.default_task_count` (Kind) und `app_settings`
(global).

Der Startdialog schreibt **nur** die Lektionsebene. Vorher schrieb er den
globalen Standard, womit ein Kind, das für eine Lektion einmal 50 wählte,
allen anderen die Vorauswahl verstellte.

`resolvedTaskCountProvider` liefert `AsyncLoading`, bis alle Ebenen geantwortet
haben — siehe unten, warum hier nichts erfunden wird.

## Einstellungen laden

`preferencesProvider` wird in `app.dart` von der Wurzel aus gehalten, damit er
nie kalt ist, wenn ein Bildschirm ihn braucht. Trotzdem gilt: **niemals einen
Standardwert erfinden**, solange der echte noch lädt. Genau das ließ die
ausgewählte Aufgabenzahl sichtbar von 10 auf den gespeicherten Wert springen.
Wo eine Auswahl davon abhängt, ist der Wert `null`-fähig und es ist eben kurz
nichts ausgewählt.

## Reihe oder Wolke

`PictureArrangement` ist eine Eigenschaft der **Lektion**, nicht der Aufgabe:
dieselbe Aufgabe „vier Bienen" ist in der Reihe und in der Wolke dieselbe
Rechnung, nur anders schwer. Deshalb wird sie vom Übungsbildschirm an
`TaskDisplay` durchgereicht und nicht in `Task` gespeichert — der
Wiedervorlage-Vorrat soll beide als eine Aufgabe behandeln.

Die Streuung kommt aus einem gesetzten Zufallsgenerator und hält damit über
Neuaufbauten still. Bilder, die beim Zählen umherspringen, wären unbenutzbar;
ein Test hält das fest.

## Nicht gewertete Lektionen

`LessonSpec.scored == false` heißt dreierlei: keine sichtbare Uhr, kein
Eintrag in einer Bestenliste, und Sterne fürs Beenden statt für die
Fehlerquote. `unscoredLessonIds` reicht die betroffenen IDs an die
SQL-Abfragen weiter — SQL kann den Katalog nicht lesen.

Nicht alle Formen sind Rechnungen. `Task._isCalculation` entscheidet das, und
`result` liefert für die übrigen schlicht die Antwort: eine Uhr, die 9:45
zeigt, hatte sonst ein „Ergebnis" von 54.

Manche Vorräte sind winzig — ein Würfel hat sechs Seiten. Der Generator kann
dort keine Abstände zusichern, **aber** eine Aufgabe kommt nie zweimal
hintereinander; das gilt für jede Lektion und wird für alle geprüft.

## Zwei Eingabefelder, drei Aufgabenformen

`TaskForm.remainder`, `.money` und `.clock` fragen zwei Zahlen ab. Ob eine Form
das tut, sagt `Task.expectedSecond != null` — **nicht** ein Vergleich mit einer
bestimmten Form. Beschriftung und Einheit liefern `secondLabel` und
`secondUnit`, damit der Übungsbildschirm nichts über die einzelnen Formen
wissen muss.

Geld wird durchgehend in **Cent** gerechnet und nur beim Anzeigen formatiert.
Zwei Felder statt einer Komma-Taste: die Tastatur bleibt dadurch überall die
gleiche, und ein Kind muss nicht lernen, wo das Komma sitzt.

Die Uhr ist gezeichnet (`ClockFace`), nicht als Bild eingebunden — sie muss
jede Zeit zeigen können. Der Zahlenstil wird von außen hereingereicht: ein
`CustomPainter` hat keinen umgebenden `DefaultTextStyle` und fiele sonst auf
die Systemschrift zurück.

## Sterne

Die Schwellen stehen in `domain/scoring.dart` (`threeStarErrorRate`,
`twoStarErrorRate`, `maxStars`) und werden von der SQL-Fassung in
`stats_repository.dart` (`_stars`) hineininterpoliert — zwei Kopien der Regel
„was zählt als drei Sterne" würden auseinanderlaufen. Ein Test vergleicht beide
Fassungen gegeneinander.

Der Gesamtstand zählt **pro Lektion die beste Runde, einmal**. Sonst wäre es
lohnender, dieselbe leichte Lektion zu wiederholen, als eine neue anzufangen.

`StarRow` zeigt immer alle drei Sterne, auch die leeren: die leeren sind die
Botschaft. `StarTotal` trägt selbst einen gefüllten Stern — Tests, die
Kachel-Sterne zählen, müssen deshalb auf `StarRow` einschränken.

## Sicherung

Export und Import gehen über JSON, nicht über eine Kopie der Datenbankdatei —
so lässt sich eine ältere Sicherung nach einer Schemaänderung noch einspielen;
fehlende Spalten kommen auf ihre Vorgabewerte. Ein Import **ersetzt** alles:
IDs von zwei Tablets würden kollidieren, und halb verschmolzene Ergebnisse
sind schlimmer als ein klares „das ist jetzt diese Sicherung". Die PIN reist
mit, sonst sperrt eine Wiederherstellung die Eltern aus.

## Versionierung

`pubspec.yaml` führt nur den Build-Namen: `version: 1.0.0`. Der Teil vor einem
`+` wird zum Android-`versionName`, der Teil dahinter zum `versionCode`. Ohne
`+N` vergibt Flutter `versionCode = 1`. Die Build-Skripte übergeben die Nummer
nur, wenn sie tatsächlich in der pubspec steht — die ganze Zeichenkette an
`--build-name` zu hängen wäre falsch, dann stünde das `+N` im sichtbaren
Versionsnamen.

## Vor dem Abschluss

```bash
flutter analyze   # muss ohne Befund durchlaufen
flutter test
```
