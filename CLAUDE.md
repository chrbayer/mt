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

Eine **neue Gruppe in der Mitte des Enums einzufügen ist sicher**:
`hidden_groups` speichert Namen, keine Indizes, und ungenannte Gruppen gelten
als sichtbar. „Einmaleins rückwärts" erscheint dadurch bei allen Kindern, statt
bei denen mit gespeicherten Einstellungen stillschweigend zu fehlen. Die
Reihenfolge im Enum ist zugleich die Reihenfolge im Katalog.

`div_plain` hat beim Umzug in die neue Gruppe **seine ID behalten** und nur
Titel und Beschreibung gewechselt — Gruppe und Titel sind frei, die ID nicht.

`_sampleQuotient` teilt durch `lesson.timesTable`, wenn eine gesetzt ist, und
zieht sonst einen freien Divisor. Damit ist eine Rückwärts-Reihe dieselbe
Lektion wie die Vorwärts-Reihe, nur von der anderen Seite.

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

`TaskForm.clockPhrase` läuft ebenfalls als **Vorrat** statt als Stichprobe:
`_generateClockPhraseTasks` arbeitet die elf Sprechweisen in gemischten
Blöcken ab. Frei gezogen fehlten in zehn Aufgaben im Schnitt vier der elf,
während eine bis zu sechsmal drankam — und die elf Formen sind der ganze
Inhalt der Lektion. Die **Stunde** bleibt zufällig; sie wird nur neu gezogen,
wenn dieselbe Uhrzeit sonst innerhalb des Abstandsfensters wiederkäme.

Beide Vorrats-Lektionen nehmen die **Wiedervorlage** trotzdem an, nur anders:
`_hardestFirst` zieht die schweren Formen an den Anfang des ersten Durchlaufs,
statt sie wie die Stichprobe einzustreuen. Über einen vollen Durchlauf ändert
das nichts — es entscheidet nur, was ein Durchgang zu sehen bekommt, der
kürzer ist als der Vorrat. Ohne das konnte in zehn von elf Sprechweisen
ausgerechnet die schwerste die fehlende sein.

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

## Fertige Lektionen ausblenden

`LessonFilter` ist eine Eigenschaft des **Profils**, kein Anzeigezustand: der
Katalog soll morgen so aussehen wie heute. Gespeichert wird der **Name**, nicht
der Index — dieselbe Vorsicht wie bei `hidden_groups`, und Unbekanntes zählt
als `all`. Ein Downgrade darf keine Lektionen aus Gründen verstecken, die
niemand sehen kann.

Die zweite Stufe ist **strenger, nicht lockerer**: sie verlangt Sterne *und*
Blitze und blendet damit **weniger** aus. Richtig ist nicht dasselbe wie
fertig, und wer schneller werden will, braucht die fehlerfreien, aber langsamen
Lektionen weiter in der Liste.

Die **Ersten Schritte sind nicht ausgenommen** — sie waren es, mit dem
Argument, dass ihre Sterne fürs Beenden kommen und ein Durchgang je Lektion
die Gruppe leert. Das galt, solange Ausblenden eine Einbahnstraße war; seit
ein Elternteil die Sterne zurückgeben kann (2.3.0), ist es bloß Aufräumen.

Die **strengere** Stufe lässt sie trotzdem stehen, und zwar ohne Sonderfall:
wo nichts gemessen wird, gibt es keine Blitze zu holen, also wird
`bolts >= maxBolts` dort nie wahr.

Der Filter gilt auch für die **Empfehlung**: eine Lektion vorzuschlagen, die
eine Zeile weiter unten ausgeblendet ist, wäre ein Widerspruch. Ist am Ende
nichts übrig, steht dort, wie man den Katalog zurückholt — ein leerer
Bildschirm wäre ein Fehler und kein Erfolg.

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

## Farben der Gruppen

`AppColors.groupTints` liefert je Gruppe einen Pastellton für den
Kachelhintergrund, `groupEdges` denselben Ton eine Spur dunkler für den Rand —
ein Pastell ohne Kante liest sich als Fleck, nicht als Karte. Beide sind über
`LessonGroup.index` indiziert und laufen um, damit eine später ergänzte Gruppe
eine Farbe bekommt statt den Katalog abstürzen zu lassen.

Nicht nach Gefühl gewählt: `test/features/group_tints_test.dart` rechnet die
WCAG-Kontraste aus und verlangt 4,5:1 für die kleine graue Zeile, 7:1 für den
Titel und 3:1 für das große blaue Beispiel. Genau daran ist die erste Auswahl
gescheitert — sie landete bei 4,0:1.

Deshalb wurde `textMuted` von `0xFF6B7280` auf `0xFF5E6572` nachgedunkelt: auf
Weiß hatte es nur 4,8:1, und jeder Farbton kostet etwa 0,4. Der Test hält auch
fest, dass es auf den ungetönten Flächen nicht schlechter geworden ist.

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

## Angehaltene Uhr ist kein Pausenbildschirm

`_confirmAbort` hält die Uhr an, während das Kind überlegt — richtig, denn
diese Sekunden sind keine Rechenzeit. Der **Pausenbildschirm** darf dabei
trotzdem nicht erscheinen: er trägt den „Weiter"-Knopf, und hinter einem
modalen Dialog ist der ohnehin nicht erreichbar. Er stand dort hinter dem
Dialog und blitzte nach „Beenden" noch einmal formatfüllend auf, bevor der
Bildschirm wechselte.

`_askingToAbort` und `_leaving` halten ihn heraus. Für die Unterbrechung von
außen (`didChangeAppLifecycleState`) bleibt er unverändert — dort ist er der
ganze Zweck.

## Navigation aus einem Bottom Sheet

Den `NavigatorState` **vor** dem `pop()` in eine lokale Variable holen. Nach
dem Schließen ist der Kontext des Sheets ungültig, und ein zweites
`Navigator.of(context)` läuft ins Leere, ohne zu meckern — genau so waren „Los
geht's" und „Bestenliste" einmal komplett tot.

## Wo eine Einstellung hingehört

Zwei Orte, und die Grenze verläuft nach **Zuständigkeit**, nicht nach
Bequemlichkeit: Was für die ganze App gilt — Uhr, Vibration, Vorgabe für alle —
steht im Elternbereich hinter der PIN. Was nur das eigene Üben betrifft, steht
in `SettingsScreen`, und der ist ausschließlich aus dem Lektionsbildschirm
eines angemeldeten Kindes erreichbar.

Genau deshalb muss dort **nicht mehr dabeistehen, für wen es gilt**: wer den
Bildschirm sieht, ist angemeldet, und es ist seiner. Ein „Für Mia" daneben war
die Folge davon, dass auf demselben Bildschirm auch die Vorgabe für alle stand.

Auf dem Profilbildschirm gibt es kein Zahnrad mehr. Ohne angemeldetes Kind gibt
es keine eigenen Einstellungen, und die für alle liegen zwei Knöpfe weiter im
Elternbereich.

`TaskCountExplanation` kennt beide Ebenen: „sonst diese hier" muss auf den
richtigen Regler zeigen, und welcher das ist, hängt vom Bildschirm ab.

## Elternbereich

Die PIN (`SettingsRepository.setAdminPin` / `checkAdminPin`) schützt vor einem
neugierigen Geschwisterkind, nicht vor einem Angreifer mit dem Gerät in der
Hand. Trotzdem wird sie gesalzen gehasht abgelegt — ein Blick in die Datenbank
soll sie nicht verraten. Beim Ändern wird die alte PIN gelöscht und der
Einrichtungsdialog erneut gezeigt; nach der alten zu fragen wäre sinnlos, der
Weg dorthin führte gerade durch sie hindurch.

Die PIN-Tastatur hat **keine grüne Taste**. Eine PIN ist genau
`adminPinLength` Ziffern lang, und die letzte schickt sie ab — die grüne
Taste wäre also nur in dem Moment drückbar, in dem die Eingabe noch
unvollständig ist und sie nichts tut. Eine Taste, die manchmal nichts tut,
bringt dem Kind das Falsche über die grüne Taste im Übungsbildschirm bei.
`BigKeypad.showSubmit` lässt sie weg; ihr Platz im Raster bleibt frei, damit
die Ziffern darüber nicht verrutschen.

`requireAdminPin(context)` ist die einzige Schranke. Wer sie umgeht, umgeht den
Schutz — neue geschützte Aktionen also immer dahinter aufhängen.

## Profil vorübergehend sperren

`users.locked` ist eine **Pause, keine Löschung**: Runden, Sterne, Blitze und
Bestzeiten bleiben unangetastet und sind nach dem Freigeben unverändert da.
Ein Elternteil, das das Tablet für eine Weile stilllegen will, soll nicht
zwischen Ermahnen und dem Zerstören eines Jahres Bestzeiten wählen müssen.

Die Schranke sitzt an **einer** Stelle: `_open` im Profilbildschirm. Jeder Weg
in eine Übung beginnt mit einem Tipp auf eine Profilkachel, also reicht diese
eine — dieselbe Überlegung wie bei `PracticeScreen._prepare()`. Die zweite
Tür ist das **Duell**, das Profile ohne Anmeldung auswählt; dort ist ein
gesperrtes Profil nicht wählbar, sonst wäre das Duell der Weg um die Sperre
herum (genau wie bei der Zeitgrenze).

Eine gesperrte Kachel **antwortet trotzdem**: Stille läse sich als kaputte
App. Der Dialog sagt ausdrücklich, dass nichts verloren ist. Die Kachel
behält ihre Farbe, nur gedämpft — sie ist weiterhin Mias Kachel, und sie ins
Graue zu ziehen hieße „weg" statt „später". Das Paletten-Symbol weicht dem
Schloss: Bild und Farbe für eine Kachel zu wählen, die sich nicht öffnen
lässt, wäre eine Tür ins Nichts.

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

## Zahl neben der Menge

`LessonSpec.showCounts` entscheidet, ob unter einem Häufchen (und unter einem
Würfel) die Zahl steht. Die Regel ist inhaltlich, nicht kosmetisch: **eine
Zahl gehört dorthin, wo sie mit der Menge verknüpft werden soll, und nicht
dorthin, wo gezählt werden soll.** Beim Vergleichen und beim Zusammenrechnen
hilft sie, beim Zählen verrät sie die Lösung. Ein Test im Katalog hält die
Zuordnung je Lektion fest.

Wo zwei Mengen nebeneinander stehen, baut `CountedPair` sie als **Tabelle**
auf, nicht als zwei aneinandergeklebte Spalten. Eine Wolke aus vier Bienen ist
höher als eine aus zweien, und unter jedes Häufchen gehängt landeten die
Zahlen auf verschiedenen Höhen und lasen sich nicht mehr als Zahlenpaar. Das
Raster erzwingt, was die Spalten allein nicht halten konnten.

Das Trennzeichen **wiederholt sich unter den Zahlen**, aber nur, wo es etwas
bedeutet: das Plus zwischen zwei Bienenhäufchen gehört auch zwischen ihre
Zahlen, denn „2 + 4" ist genau der Schritt, auf den die Bilder vorbereiten.
Bei „Wo sind mehr?" bleibt die Stelle leer — dort ein Plus zu schreiben würde
eine Rechnung beibringen, nach der niemand gefragt hat.

`countSeparator` wird **ohne Stil** übergeben: `CountedPair` zeichnet ihn in
demselben Grad, Gewicht und Farbton wie die Zahlen, zwischen denen er steht.
Solange jeder Aufrufer seine eigene Größe mitgab, stand im Übungsbildschirm
ein Plus mit 52 neben Ziffern mit 68 und auf der Kachel eins, das größer war
als sie — beides las sich als Versehen, und es gibt keinen Grund, warum die
drei Zeichen je verschieden groß sein sollten.

Der Trenner beim Vergleichen wächst über `stretchSeparator` (eine Zelle mit
`TableCellVerticalAlignment.fill`) auf die Höhe der Häufchen mit. Zwischen
zwei hohen Wolken trennt ein Strichstummel nichts.

Auf der Kachel zeichnen Würfel und Zahlen in `AppColors.primary`. Jede andere
Kachel spricht in Blau; in Schwarz lasen sich die Ersten Schritte als etwas
ganz anderes. Die Emoji lassen sich nicht umfärben, ihre Zahlen und die
Würfel schon.

Bei der Wolke werden die Zellen aus einem Glyphen-`extent` bemessen, nicht aus
der Schriftgröße: ein Zeichen ist höher als sein Schriftgrad, und der `Stack`
schnitt die letzte Reihe sonst ab, obwohl daneben noch Platz war. Der
Regressionstest dazu lädt eine echte Schrift — mit der quadratischen Testschrift
tritt der Überstand gar nicht auf und der Test wäre wertlos.

## Antworten, die keine Zahlen sind

Zwei Lektionen werden nicht auf der Zifferntastatur beantwortet, und beide
lösen das über **dieselbe** Mechanik: `ChoiceKeypad` hat das Raster von
`BigKeypad` (drei Spalten, vier Zeilen, grüne Taste unten rechts) und die
gemeinsame Taste `KeypadKey`. Der Controller bleibt bei zwei Ganzzahlfeldern —
das Wort ist der **Index** in `clockPhrases`, der Münzhaufen die **Summe** in
Cent. So gilt der ganze Rest der Maschinerie unverändert: Wertung, Zeitmalus,
Bestenliste, Wiedervorlage.

`pressPhrase` ersetzt, statt anzuhängen: eine Sprechweise ist eine Auswahl,
keine Eingabe. `pressPiece` legt dagegen auf, und die Rücktaste nimmt **ein
Stück** weg statt einer Ziffer — eine Ziffer von der Summe abzuknapsen ergäbe
einen Betrag, den niemand hingelegt hat.

Bei „Uhrzeit sagen" wechselt die Tastatur mitten in der Aufgabe: Wörter fürs
erste Feld, Ziffern fürs zweite. Das entscheidet `_keypadFor` im
Übungsbildschirm anhand von Form **und** aktivem Feld.

Die volle Stunde fehlt in `clockPhrases` mit Absicht: „3 Uhr" stellt die
Stunde voran, jede andere Lesart stellt sie hinten an, und ein Feld, das je
nach Antwort den Platz mit seinem Nachbarn tauscht, wäre ein Rätsel für sich.
Volle Stunden üben die drei Lektionen, die nach Ziffern fragen.

## 24-Stunden-Uhr

`LessonSpec.clock24` ändert dreierlei an derselben `TaskForm.clock`: die
Stunden laufen 6..23, unter dem Zifferblatt steht die Tageszeit, und die Frage
sagt ausdrücklich „mit 24 Stunden". Ohne all das wäre die Aufgabe nicht
lösbar — die Zeiger sehen um 10 und um 22 Uhr gleich aus.

## Rückmeldung auf drei Kanälen

Farbe, Vibration und Ton sagen dasselbe. Wer auf die Tastatur schaut statt
aufs Antwortfeld, sieht die Farbe nicht; ein flach auf dem Tisch liegendes
Tablet schluckt die Vibration. Deshalb der Ton, und deshalb ist er
standardmäßig an.

Die WAV-Dateien erzeugt `tool/make_sounds.py`. Wer sie ändern will, ändert die
Noten dort und lässt das Skript neu laufen — nicht die Dateien bearbeiten.

Die Töne gehören der **ganzen App**, nicht dem Übungsbildschirm:
`feedbackSoundsProvider` hält genau eine `FeedbackSounds`. Vorher baute jeder
Durchgang drei Audio-Pipelines auf und wieder ab — für Töne von 35 bis 300 ms.

Und die Abspieler bekommen **keine festen IDs** mehr. Sie hießen
`mt-correct`, `mt-wrong` und `mt-key`, was sich in einem Protokoll gut liest
und den Ton gekostet hat: der Bildschirm warf seine `FeedbackSounds` beim
Verlassen weg, ohne das `dispose` abzuwarten, und der nächste Durchgang
meldete Abspieler unter IDs an, die gerade abgebaut wurden. Die Antwort auf
die zweite Anmeldung kam nie, `warmUp` kehrte nie zurück, `_ready` blieb
false — und alles danach war still. Unter Linux headless gemessen und
deterministisch: Durchgang 1 spielt, 2 hängt, 3 spielt, 4 hängt. Ohne feste
IDs vergibt das Paket eine uuid, und sechs Durchgänge hintereinander spielen
5 von 5.

**Warum es auf Android nie auffiel:** dort räumt das Plugin eine doppelt
vergebene ID anders ab. Die Fehlerform „geht einmal, dann nie wieder" war auf
beiden Plattformen dieselbe Ursache — sie hat sich nur auf einer gezeigt.

## Warum der Klick 45 ms Stille vorn hat

`tool/make_sounds.py` setzt `LEAD_SILENCE` vor den Tastenklick. Das ist kein
Schönheitsfehler, sondern der ganze Punkt.

Zwischen zwei Klicks hält `_play` den Abspielstrang an (`stop()` → PAUSED),
und das **korkt den PulseAudio-Strom**. Beim nächsten Klick braucht eine
echte Soundkarte einige Millisekunden, bis sie wieder Töne ausgibt. Der alte
Klick war 35 ms lang und fiel vollständig in dieses Anlaufen.

Gemessen, mit demselben Integrationstest und derselben Aufnahme, nur mit
gewechseltem Ausgabegerät:

| Ziel | Klicks hörbar |
|---|---|
| Null-Sink (`module-null-sink`) | 33 von 33 |
| echte Soundkarte | **1 von 33** |

Deshalb sahen alle früheren Messungen gesund aus: ein Null-Sink läuft nicht
an. Mit 45 ms Stille vorn, längerem Ausklang und knapp der halben Lautstärke
der Antworttöne kommen an der echten Karte **33 von 33** an. Die 45 ms
Verzögerung liegen weit unter der Schwelle, ab der sich eine Taste träge
anfühlt.

Wer den Klang ändert, muss ihn an einer **echten** Karte gegenmessen. Ein
kürzerer oder leiserer Klick fällt sofort wieder in dieselbe Lücke.

## Wie man das debuggt

Der Desktop-Build lässt sich **headless** fahren, ohne ein Fenster auf den
Bildschirm zu bringen:

```bash
flutter build linux --debug -t lib/audio_probe.dart   # eigener Einstiegspunkt
wlheadless-run -c weston -- ./build/linux/x64/debug/bundle/mathe_trainer
```

Braucht `weston` und `xwayland-run`. Ein eigener Einstiegspunkt statt der
App ist der Trick: er braucht keine Eingaben, fährt die fragliche Abfolge
selbst und schreibt das Ergebnis nach stdout. Für `log()` bitte `print` —
`stdout.writeln` mit `flush()` wirft beim nächsten Schreiben „StreamSink is
bound to a stream".

Für den **Ton** reicht das aber nicht: was das Plugin meldet und was aus dem
Lautsprecher kommt, sind zwei verschiedene Dinge. `onPlayerComplete` zählte
zehn von zehn, während nichts zu hören war. Also den Schall selbst aufnehmen
und vermessen — und dabei an der **echten** Karte, nicht an einem Null-Sink:

```bash
DEF=$(pactl get-default-sink)
parec -d "$DEF.monitor" --format=s16le --rate=48000 --channels=1 \
      --file-format=raw > audio.raw &
wlheadless-run -c weston -- \
  flutter test integration_test/sound_on_keypad_test.dart -d linux
```

`integration_test/sound_on_keypad_test.dart` tippt dafür echte Ziffern auf
den echten Übungsbildschirm. Es läuft **nicht** bei `flutter test` mit — es
braucht ein Gerät und ein Aufnahmegerät daneben — und ist als Reproduktion
aufgehoben, nicht als Regressionstest.

`FeedbackSounds` schaltet bei jedem Abspieler den **`positionUpdater` ab**.
Jeder `AudioPlayer` fragt sonst über einen `FramePositionUpdater` die
Abspielposition **einmal pro Bild** ab, solange ein Ton läuft, und einmal
zusätzlich bei jedem `stop()`. Hier zeichnet niemand einen Fortschrittsbalken
— die Töne sind 35 bis 300 ms lang —, also ist das reiner Verkehr auf dem
Kanal.

Unter Linux ist es mehr als Verschwendung: jede Abfrage ist eine
GStreamer-Positionsabfrage auf demselben Thread, der die Zustandswechsel der
Wiedergabe ausführt, und der Updater startet seine Frame-Callback-Kette bei
jedem `resume()` neu, ohne die vorige zuverlässig zu beenden. Nach ein paar
Dutzend Tastendrücken fragen mehrere Ketten parallel, und das `resume()`, das
den nächsten Klick starten soll, steht hinter ihnen in der Schlange. Von
außen sieht das so aus, als verschwände der Ton.

`FeedbackSounds` merkt sich seinen letzten Fehler (`lastError`), statt ihn nur
zu loggen: auf einem Tablet gibt es keine Konsole, und „der Ton geht nicht"
lässt sich ohne den Fehlertext nicht bearbeiten. Der Knopf **Ton testen** im
Elternbereich spielt den Klick **zehnmal** und zählt über
`onPlayerComplete`, wie viele davon wirklich gelaufen sind — ein
Abschlussereignis kommt nur für einen Ton, der tatsächlich lief. „8 von 10"
sagt etwas, „der Ton geht nicht" nicht. Genau diese Fehlerform ist zweimal
aufgetreten: die ersten Töne kommen, die späteren nicht mehr.

`FeedbackSounds` hält alle Abspieler vorgeladen: einen erst beim ersten
Fehler zu erzeugen verzögert genau den Ton, der sofort kommen soll. Jeder
Fehler beim Laden oder Abspielen wird geschluckt und nur geloggt — auf einem
Gerät ohne funktionierendes Audio darf der Durchgang nicht mitfallen.

## Der Klick unter der Taste

Dazu kommt ein dritter Ton, aber kein Urteil: 35 ms, ohne erkennbare Tonhöhe
und mit 41 % der Lautstärke der Rückmeldung. Er kommt bis zu fünfzigmal je
Aufgabe und darf deshalb nichts behaupten — er bestätigt nur, dass die Taste
angekommen ist. Der grüne Haken bekommt ihn **nicht**: dort sagen schon zwei
Töne etwas viel Wichtigeres.

Er klingt nur, wenn die Eingabe **angenommen** wurde. Deshalb geben
`pressDigit`, `pressPhrase`, `pressPiece`, `clearPieces` und `backspace` ein
`bool` zurück, und `PracticeScreen._key` hängt den Ton daran. Ob eine vierte
Ziffer, eine Rücktaste im leeren Feld oder ein Tipp während des grünen
Aufblitzens etwas bewirkt hat, weiß nur der Controller — und ein Klick, der
trotzdem käme, meldete dem Kind ein Ankommen, das nicht stattgefunden hat.

Die **Vibration** folgt dieser Regel nicht: sie sitzt im Tastatur-Widget und
kommt bei jedem Druck. Das ist so geblieben, weil ein Finger auf einer Taste
etwas anderes ist als eine Zahl im Feld.

`FeedbackSounds._play` spult mit `stop()` zurück, **nicht** mit `seek()`.
`seek` wartet auf das Plattform-Ereignis `onSeekComplete` — mit 30 Sekunden
Zeitlimit. Androids MediaPlayer meldet einen Sprung, der nirgendwohin geht,
nicht zuverlässig, und nach dem Ende eines Tons hat das Plugin ihn bereits
auf null zurückgespult: jede Wiederholung war genau so ein Sprung. Das
`await` kam nie zurück, das `resume()` darunter lief nie, und **jeder Ton war
genau einmal je Durchgang hörbar**. `stop()` spult ohne Ereignis zurück, und
mit `ReleaseMode.stop` bleibt die Quelle geladen.

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
`twoStarErrorRate`, `maxStars`). Seit die Sterne gespeichert werden, wendet
**nur noch `starsFor`** sie an — die SQL-Fassung im Repository ist weg, und
damit auch die Gefahr, dass zwei Kopien der Regel auseinanderlaufen. Die
einzige verbliebene SQL-Fassung steht in der Migration auf v8 und läuft genau
einmal.

Die Sterne werden **gespeichert**, nicht mehr aus den Runden errechnet:
`lesson_stars` (Kind × Lektion). Sobald ein Elternteil sie einer Gruppe
zurückgeben kann, ohne die Zeiten anzurühren, können die beiden auseinander
liegen — und dann kann nur ein gespeicherter Wert sagen, was tatsächlich
verdient wurde. `SessionRepository._awardStars` schreibt nach jedem
abgeschlossenen Lauf, **nur nach oben**: eine schlechte Runde nach einer guten
nimmt nichts weg.

`resetStarsInGroup` löscht die Zeilen einer Gruppe. Die Sitzungen bleiben, also
bleiben Bestzeiten, Lernkurve, Bestenlisten **und Blitze** — Blitze hängen an
der Zeit, und die Zeit ist ausdrücklich das, was erhalten bleiben soll.

Beide Schreibwege gehen über **Drifts API**, nicht über `customStatement`: ein
rohes Statement sagt Drift nicht, welche Tabelle es angefasst hat, und die
zwischengespeicherten Streams zeigten danach weiter den alten Stand. Das war
in der ersten Fassung genau der Fehler.

Die Migration auf v8 füllt die Tabelle **einmalig** aus den vorhandenen
Runden, mit derselben Regel, die die Statistik vorher laufend anwandte.
Niemand darf verlieren, was er gesammelt hat, weil die App die Buchführung
gewechselt hat. Der Ausdruck steht dort ausgeschrieben und nicht als Verweis
auf das Repository: die Fassung dort verschwindet mit diesem Schritt, und eine
Migration muss gegen das Schema ihres eigenen Moments funktionieren.

Der Gesamtstand läuft über `lessonsInGroup`, **nicht** über das, was der
Filter stehen lässt: fertige Lektionen auszublenden räumt die Liste auf und
nimmt keine Sterne weg. Was es zu holen gibt, hängt allein daran, welche
Bereiche freigeschaltet sind — ein Test hält beides fest.

In der Statuszeile trägt der Sternstand sein Maximum, der Blitzstand nur seine
Zahl. Die Ungleichheit ist die Aussage: Sorgfalt hat eine Marke, Tempo ist die
Zugabe. Mit zwei vollen Abzeichen läuft die Kopfzeile auf dem 10-Zoll-Tablet
außerdem um 24 Pixel über.

Der Gesamtstand zählt **pro Lektion die beste Runde, einmal**. Sonst wäre es
lohnender, dieselbe leichte Lektion zu wiederholen, als eine neue anzufangen.

`StarRow` zeigt immer alle drei Sterne, auch die leeren: die leeren sind die
Botschaft. `StarTotal` trägt selbst einen gefüllten Stern — Tests, die
Kachel-Sterne zählen, müssen deshalb auf `StarRow` einschränken.

## Was die App von sich aus sagt

`ShortRunHint` und `RemainingTimeHint` in `features/common/run_hints.dart`
stehen dort, wo sie eine Entscheidung ändern: unter der Auswahl im
Startdialog, nicht in einem Hilfetext. Beide Regeln waren vorher richtig und
stumm — drei leere Sterne nach fünf fehlerfreien Aufgaben, und eine Sperre,
die nach dem Durchgang aus dem Nichts kam.

Im Startdialog teilen sich **beide Zeilen einen Platz**: entweder was drei
Blitze kosten oder dass dieser Durchgang zu kurz ist, um etwas wert zu sein.
Die zwei gelten nie gleichzeitig — unter zehn Aufgaben gibt es keine Blitze zu
holen —, und der gemeinsame Platz ist es, was den Dialog davon abhält, unter
einem Finger auf dem Weg zum Knopf zu wachsen und zu schrumpfen.

Er war dabei nicht nur unruhig, sondern zu hoch: mit der 5 ragte er um 63 px
über ein 10-Zoll-Tablet hinaus. Der Layouttest maß nur die Vorauswahl 10 und
sah es deshalb nie. Er wechselt jetzt die Auswahl durch und prüft dabei, dass
sich der Dialog **nicht bewegt**.

Die Restzeit nennt immer die **knappere** der beiden Grenzen: eine Strecke mit
zwanzig freien Minuten nützt nichts, wenn der Tag noch fünf hat.

Auf dem Ergebnisbildschirm nimmt der Hinweis den Platz des Abstands darunter,
statt ihn zu ergänzen — die Spalte dort kann nicht wachsen, und ein
Layouttest fängt es sofort ab.

## Blitze

Zwei Achsen, absichtlich getrennt: **Sterne für Sorgfalt** (Fehlerquote),
**Blitze fürs Tempo** (Punktzeit pro Aufgabe). Deshalb dürfen Blitze **null**
werden, Sterne nie — ohne Untergrenze hieße „ein Blitz" gar nichts, und
umgekehrt soll niemand fürs saubere Rechnen mit leeren Sternen bestraft
werden.

Die Zielzeit steht **nicht** 54-mal von Hand im Katalog, sondern kommt aus
`LessonSpec.targetMsPerTask`: Grundwert je Gruppe, Faktoren für Aufgabenform,
Zehnerübergang, gemischte Rechenart und Einmaleins-Reihe. 54 erfundene
Zahlentripel könnte niemand untereinander konsistent halten; eine Regel mit
sechs Faktoren schon. `scored == false` heißt Ziel 0 und damit keine Blitze —
in den Ersten Schritten wird nicht gemessen.

Die Schwellen (`twoBoltFactor`, `oneBoltFactor`, `maxBolts`) liegen wie die
Sternschwellen in `domain/scoring.dart`, und `_bolts` in
`stats_repository.dart` interpoliert sie ins SQL. Die Zieltabelle `_boltTarget`
wird genauso **aus dem Katalog erzeugt** wie `_unscored` — nicht abgeschrieben.
Ein Test lässt SQL- und Dart-Fassung gegeneinander laufen.

Auf einer Kachel erscheinen Blitze erst, wenn die Lektion geübt wurde. Sechs
Symbole nebeneinander verdrängen sonst „noch nicht geübt", und drei graue
Blitze sagen nichts, was die drei grauen Sterne nicht schon sagen. In der
Statistiktabelle stehen die beiden Reihen aus demselben Grund untereinander.

## Übungszeit am Stück

Ein **Stück** ist alles seit der letzten echten Pause. `watchPracticeStretch`
findet die Grenze in SQL mit `LAG` und einer laufenden Summe — sie in Dart zu
suchen hieße, sämtliche Sitzungen herüberzuholen, also genau das, was dieses
Repository vermeiden soll. Abgebrochene Durchgänge zählen mit: wer anfängt und
aufhört, hat trotzdem am Tablet gesessen.

`practiceAllowance` in `domain/practice_limit.dart` entscheidet daraus. Eine
**eingehaltene Pause setzt das Stück auf null zurück**, egal wie lang es war —
sonst wäre die Grenze nach dem ersten langen Nachmittag für immer erreicht.

Gesperrt wird nur der **Start**, nie ein laufender Durchgang. `PracticeScreen`
schaut die Erlaubnis **nirgends** an — das ist die Zusicherung, und ein Test
spielt einen Durchgang zu Ende, während die Zeit mitten darin abläuft. Mitten in einer
Aufgabe hinausgeworfen zu werden verlöre die Runde und brächte dem Kind bei,
dass der App nicht zu trauen ist. Die **verbindliche** Prüfung sitzt in `PracticeScreen._prepare()` — der einen
Stelle, durch die jeder Durchgang muss, egal welcher Knopf dorthin geführt
hat. Sie fragt **einmal**, bevor Aufgaben erzeugt werden; danach nie wieder.
Vorher stand die Prüfung an den Knöpfen, und es waren vier: Startdialog,
„Nochmal", die Empfehlungskachel und ihr „Los" — zwei davon gingen daran
vorbei.

Die Knöpfe fragen trotzdem, aber nur noch, um sich auszugrauen; alle über
denselben `practiceGateProvider`. Der antwortet, **solange etwas lädt, mit
„nein"**: weder Profil noch Grenzen zu kennen heißt nicht „keine Grenzen". Aus
demselben Grund wartet `practiceAllowanceForProvider` mit `await` auf
`usersProvider` und `preferencesProvider`, statt deren `AsyncValue` als „kein
Profil, also unbegrenzt" zu lesen.

`_prepare()` hält den Provider über das `await` hinweg mit `listenManual` fest.
Ohne Zuhörer wird er beim Lesen sofort entsorgt und sein Future wird nie
fertig — der Bildschirm hing dann still.

Die **Tagesgrenze** zählt unabhängig davon alle Durchgänge des Tages. Sie hat
Vorrang vor der Stückgrenze: wenn der Tag aufgebraucht ist, hilft keine Pause,
und eine Uhrzeit zu nennen wäre ein Versprechen, das die App nicht halten
kann. Die Tagesgrenze selbst wird als `dayStartMs` in die Abfrage gereicht
statt in SQL aus `now` gebildet — die App hat **eine** Uhr, und eine Regel,
die um Mitternacht umspringt, muss zu jeder Tageszeit prüfbar sein.

`clockProvider` liefert die Uhrzeit. Die Übungsgrenze ist die einzige Regel,
die sich **ohne Zutun** ändert, und ohne steuerbare Uhr ließe sich weder
prüfen, dass die Pause sperrt, noch dass sie sich von selbst wieder öffnet.
Der Wecker aufs Pausenende ist ein echter `Timer`, kein `await` in einem
Generator: nur so bricht ihn das Abmelden wirklich ab. Er ruft
`ref.invalidateSelf()` statt bloß neu zu bewerten — wenn der Weckruf
Mitternacht ist, hat sich der Tag geändert und die Abfrage muss neu gestellt
werden.

## „Heute geübt"

`TodaySummary` oben im Übungsverlauf zählt mit **derselben Buchführung wie die
Tagesgrenze**: ab Tagesbeginn nach `clockProvider`, und **abgebrochene
Durchgänge zählen mit**. Anders gerechnet stünde dort „12 min", während die
App dem Kind sagt, die zwanzig seien um — und ein Elternteil würde dem einen
oder dem anderen nicht mehr glauben. Ein Test prüft beide Zahlen
gegeneinander.

Deshalb **nicht** `watchActivity` wiederverwendet: die zählt nur beendete
Läufe, was für eine Lernkurve richtig ist und für eine Zeitgrenze falsch wäre.

## Zwei Ebenen für die Übungszeit

Wie bei der Aufgabenzahl, nur mit zwei Ebenen statt dreien: `users` speichert
die drei Zeiten **nullable**, `app_settings` die Vorgabe für alle,
`resolvePracticeLimits` setzt sie zusammen.

Nullable und nicht 0, weil **null und 0 verschiedene Dinge sind**: „wie für
alle" und „dieses Kind hat keine Grenze". Wären beide 0, könnte ein Elternteil
eine Grenze für ein Kind nicht gezielt abschalten, ohne sie für alle
abzuschalten.

Die Vorgaben sind bewusst **nicht** „keine Grenze": 20 Minuten am Stück und
**eine Stunde** am Tag. Wer die Einstellungen nie öffnet, bekommt trotzdem
eine vernünftige Feierabendzeit fürs Tablet. Zwei Stunden, wie es anfangs
war, sind für ein Grundschulkind keine Grenze, sondern eine Formalie.

Die Migration auf v6 setzt genau die Werte auf NULL, die v5 selbst vergeben
hat (0 / 15 / 0). Was ein Elternteil tatsächlich gewählt hat, bleibt stehen —
alles andere hätte eine bewusste Entscheidung stillschweigend überschrieben.

## Wie oft eine Übung am Tag zählt

Sterne stehen für Sorgfalt, Blitze fürs Tempo — beides ließ sich aber
erarbeiten, indem man die leichteste Lektion so lange wiederholte, bis die
Zeit stimmte oder kein Fehler mehr passierte. Dagegen steht ein Deckel:
`scoredRunsPerLesson` sagt, wie viele Durchgänge **einer Lektion an einem
Tag** noch etwas einbringen dürfen. Vorgabe drei, null heißt kein Deckel.

Der Deckel sperrt **nichts**. Dieselbe Übung darf weiter gemacht werden, sie
zählt zur geübten Zeit, steht im Verlauf und erhöht „12× geübt" auf der
Kachel. Was sie nicht mehr tut: eine Bestzeit setzen, Sterne oder Blitze
vergeben, in eine Bestenliste kommen. Üben zu verbieten wäre die falsche
Antwort auf zu viel Üben.

Entschieden wird **einmal, beim Speichern**, und in `sessions.scored`
festgehalten. Später neu zu rechnen bräuchte den Deckel, wie er an jenem Tag
stand — und Eltern dürfen ihn morgen ändern. Abgebrochene Durchgänge sind nie
gewertet und verbrauchen deshalb auch keinen Platz.

In den Abfragen ist die Trennung genau die zwischen **Rekord und Tatsache**:
`best_score` und `best_bolts` in `watchLessonStats`, beide Bestenlisten und
`watchBoltTotals` sehen nur gewertete Läufe; `runs`, Durchschnitt,
Fehlerquote, geübte Zeit, Verlauf und Serie sehen alle. Ein Lauf über dem
Deckel hat wirklich stattgefunden.

Die Sterne hängen nicht am SQL, sondern an `_awardStars`, das nur noch bei
`scored` läuft. Ein perfekter vierter Lauf hebt den Stand also nicht.

Gesagt wird es an beiden Stellen, an denen es eine Entscheidung ändert: im
Startdialog teilt sich `UsedUpTodayHint` den Platz mit Blitzziel und
Kurzlauf-Hinweis (der Dialog darf nicht wachsen), und auf dem
Ergebnisbildschirm stehen dann **null Sterne und null Blitze** — dieselbe
Linie, die ein zu kurzer Lauf schon zieht. Drei goldene Sterne neben „zählt
nicht" wären zwei Antworten auf dieselbe Frage.

## Löschen, ohne die Zeit zurückzugeben

`deleteSession` **markiert** (`sessions.deleted`), es löscht nicht. Die Zeile
bleibt, weil die **geübte Zeit** bleiben muss: dass Eltern beim Aufräumen
Sterne, Blitze und einen Bestenlistenplatz kosten, ist genau das, worum sie
bitten — einen Nachmittag Bildschirmzeit zurückzugeben ist es nicht. Sonst
hätte die Tagesgrenze einen Löschknopf daneben.

Die Grenze verläuft wieder zwischen **Rekord und Zeit**: Kachelwerte,
Bestenlisten, Lernkurve, Verlauf, schwere Aufgaben und der Tagesdeckel sehen
gelöschte Läufe nicht; `watchPracticeStretch`, `watchPractisedToday`,
`watchActivity`, `watchStreaks` und die Kinderübersicht sehen sie weiter.
Letztere ist ausdrücklich eine **Aufwands**-Ansicht — gesessen hat das Kind
trotzdem.

Weil die Sterne gespeichert sind, rechnet `_recountStars` sie nach dem
Löschen aus den übriggebliebenen Läufen neu — in Dart über `starsFor`, nicht
in SQL: seit v8 steht diese Regel an genau einer Stelle, und eine zweite
Fassung hier wäre das, was die gespeicherten Sterne gerade beenden sollten.
Bleibt nichts übrig, verschwindet die Zeile aus `lesson_stars`.

`deleteIncompleteSessions` räumt abgebrochene Läufe weg und **nur die vom
gewählten Filter** — die Liste aufzuräumen, die man ansieht, ist etwas
anderes, als stillschweigend die aller Kinder aufzuräumen. Sie haben nie
etwas verdient, also ist danach auch nichts nachzurechnen.

## Mindestlänge für eine Wertung

`minTasksForAward` (10) gilt für **Bestenliste, Sterne und Blitze**
gleichermaßen. Fünf schnelle Aufgaben sind ein Aufwärmen, und ohne Untergrenze
wäre der kürzeste Durchgang der billigste Weg zu vollen Sternen.

Die **Ersten Schritte sind ausgenommen**: `starsFor(..., scored: false)` gibt
immer volle Sterne, und die SQL-Fassung prüft `IN ($_unscored)` vor der
Mindestlänge. Dort ist das Durchhalten die Leistung, und fünf Aufgaben sind
eine richtige Länge.

`LessonStat.bestBolts` kommt aus SQL statt aus `bestScoreMs` im Widget: die
schnellste Runde kann zu kurz zum Werten gewesen sein, und diese Regel soll an
einer Stelle je Achse stehen.

## Sicherung

Export und Import gehen über JSON, nicht über eine Kopie der Datenbankdatei —
so lässt sich eine ältere Sicherung nach einer Schemaänderung noch einspielen;
fehlende Spalten kommen auf ihre Vorgabewerte. Ein Import **ersetzt** alles:
IDs von zwei Tablets würden kollidieren, und halb verschmolzene Ergebnisse
sind schlimmer als ein klares „das ist jetzt diese Sicherung". Die PIN reist
mit, sonst sperrt eine Wiederherstellung die Eltern aus.

## Versionierung

`pubspec.yaml` führt nur den Build-Namen: `version: 1.0.0`. Der Teil vor einem
`+` wird zum Android-`versionName`, der Teil dahinter zum `versionCode` — die
ganze Zeichenkette an `--build-name` zu hängen wäre falsch, dann stünde das
`+N` im sichtbaren Versionsnamen.

Ohne `+N` gäbe Flutter jeder App **`versionCode = 1`**, und genau daran
entscheidet Android, ob eine APK ein Update ist. Zwei verschiedene Builds, die
beide 1 behaupten, sind für den Paketmanager kein Update; eine über die andere
zu installieren kann die App halb ersetzt zurücklassen, so dass sie nicht mehr
startet. Genau das ist einmal passiert — 2.4.0 startete nicht, lief aber
einwandfrei, nachdem die Zwischenversionen der Reihe nach installiert worden
waren, obwohl sich zwischen 2.3.0 und 2.4.0 am Schema nichts geändert hatte.

Die Skripte leiten den Code deshalb aus der Version ab: `2.4.1` wird `20401`.
Damit ist jede Version wirklich neuer als die vorige — und ältere lassen sich
nicht mehr darüber installieren, ohne vorher zu deinstallieren. Das ist der
Preis und er ist richtig herum.

## Versionsnummer in der App

`--build-name` landet nur im Android-Manifest, das die Dart-Seite ohne Plugin
nicht lesen kann. Beide Build-Skripte geben die Nummer deshalb zusätzlich als
`--dart-define=MT_VERSION` mit, und `appVersion` liest sie als
`String.fromEnvironment`. Eine Zeile ist kein Plugin wert.

Ohne Define ist die Konstante leer, und dann zeigt `VersionLabel` **gar
nichts**. Eine leere Ecke ist ehrlich; eine erfundene oder veraltete Nummer
wäre schlimmer als keine. Der Test passt sich an, wie er läuft, und deckt
damit beide Wege ab — einmal ohne Define, einmal mit.

## Linux-Build

Der Desktop-Build wird **nicht** von `build_android.sh` mitgebaut. Wer eine
Android-Version veröffentlicht, hat damit noch keine neue Linux-Version — und
ein alter Bundle sieht aus wie ein Fehler in der neuen Fassung. Beides ist
genau so passiert: „Ton kommt nur einmal" und „Versionsnummer fehlt" waren
zwei bereits behobene Fehler in einem Bundle, das seit Wochen nicht neu
gebaut worden war. Die Versionsnummer unten rechts auf dem Profilbildschirm
sagt, welcher Stand tatsächlich läuft; steht dort nichts, wurde ohne
`build_client.sh` gebaut.

Braucht GStreamer-Entwicklungspakete (`gstreamer1-devel`,
`gstreamer1-plugins-base-devel`): `audioplayers` zieht auf Linux
`audioplayers_linux` nach, und dessen CMake bricht ohne sie ab, bevor etwas
übersetzt wird. Das ist der Preis für den Ton — auf einem frischen Rechner
scheitert der Desktop-Build sonst mit „required package not found:
gstreamer-1.0" und man sucht ihn im eigenen Code.

## Vor dem Abschluss

```bash
flutter analyze   # muss ohne Befund durchlaufen
flutter test
```
