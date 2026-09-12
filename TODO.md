#0 Git verwenden — erledigt (1.11.0)

#1 erledigt (1.12.0) — Wo sind mehr: auch für Reihe und Wolke. Fehler: - Wie viele (Wolke) Sybole in letzter Reihe werden abgeschnitten, obwohl auf dem Bildschirm noch viel Platz ist. -WIe viele punkte auf Würfel: Zahl nicht unter dem Würfel anzeigen. -Wo sind mehr Bienchen (2x), Bienchen zusammen rechnen (2x), Würfel zusammen rechnen: Hier Zahl anzeigen. Zahlen machen da Sinn, wo man sie mit den Mengen verknüpfen soll, aber nicht da, wo gezählt werden soll.

#2 erledigt (1.13.0) — Ergänzungen zum Thema Uhrzeit: Füge noch bei den Uhreiten etwas hinzu für 24h; Mit Tastaturerweiterung: halb, viertel vor, viertel nach, 10 nach, zwanzig nach, 5 vor halb, 5 nach, usw.
Ergänzungen zim Thema Geld: Wie stelle ich eine vorgebene Summe aus Geldscheinen/Münzen zusammen? Etwas kostet betrag X, ich gebe einen (glatten Betrag Y), wie viel bekomme ich zurück?

#3 erledigt (2.0.0) — Zeitbeschränkungen: Am Stück mit Mindestpause, zusätzlich pro Tag, pro Profil im Elternbereich einstellbar und ein und ausschaltbar

#4 erledigt (1.14.0) — Zeiten pro Lektion (> Erste Schritte): Zeiten je Uebung fuer 1 bis 3 Blitze

#5 erledigt (2.0.0) — Sterne erst ab min. 10

---
Aus einer Durchsicht am 6.9.2026 (Stand 2.1.3). Alles im Code nachgeprüft,
nach Dringlichkeit sortiert.

## Fehler

#6 erledigt (2.1.4) — Die Empfehlungskachel umgeht die Zeitsperre. Sie tippt direkt in
PracticeScreen, wie es "Nochmal" bis 2.1.3 tat — in der Pause lässt sich
darüber weiter üben. Alle drei Türen (Startdialog, Nochmal, Empfehlung) müssen
dieselbe Prüfung machen; am besten eine gemeinsame Stelle statt drei Kopien.
Nebenbei startet die Kachel mit `?? fallbackTaskCount`, also mit 10 Aufgaben,
solange die gespeicherte Länge noch lädt — genau das Erfinden eines Vorgabe-
wertes, das CLAUDE.md verbietet.

#7 erledigt (2.1.4) — Solange die Einstellungen laden, ist der Start erlaubt.
practiceAllowanceForProvider gibt bei `preferences == null` "unlimited"
zurück, und die Bildschirme setzen `?? PracticeAllowance.unlimited` obendrauf.
Der Kommentar an der Stelle sagt das Gegenteil. Ein Kind, das in der Pause
schnell tippt, kommt im ersten Frame durch. Richtig wäre: solange unbekannt,
ist der Start deaktiviert — dieselbe Regel wie bei der Aufgabenzahl.

#8 erledigt (2.1.4) — Der Pausenhinweis rechnet die Restzeit mit DateTime.now(), die Entscheidung
darüber mit clockProvider. Zwei Uhren für dieselbe Aussage; in der App
identisch, aber die Zeitgrenze ist genau der Ort, an dem das auseinanderlaufen
darf.

## Bedienbarkeit

#9 erledigt (2.1.6) — Fünf Aufgaben sind wählbar, bringen aber weder Sterne noch Blitze noch
einen Bestenlisteneintrag — und nichts sagt es. Die Zehnergrenze steht nur in
der Bestenliste und in der Übersicht über alle Kinder, nicht im Startdialog
und nicht im Ergebnis. Ein Kind wählt die erste Kachel, rechnet fünf Aufgaben
fehlerfrei und bekommt drei leere Sterne ohne Erklärung.

#10 erledigt (2.1.6) — Keine Vorwarnung vor der Zeitgrenze. Nirgends steht, wie viel Übungszeit
heute noch bleibt; die Sperre kommt unangekündigt nach einem Durchgang. Ein
"noch 5 Minuten" vor dem Start des letzten Durchgangs wäre freundlicher — und
ein Kind könnte sich die Runde einteilen.

#11 erledigt (2.1.6) — Der Münzhaufen lässt sich nur Stück für Stück abräumen. Wer sich bei
"Betrag zusammenlegen" vertut, tippt sechsmal die Rücktaste. Ein langer Druck
oder eine eigene Taste zum Leeren würde reichen.

## Fehlt

#12 erledigt (2.1.5) — Kein Ton. Der ursprüngliche Plan sah Ton und Haptik vor, es gibt nur
Haptik. Ein kurzer Klang bei richtig/falsch hilft Kindern, die das Tablet
flach auf dem Tisch haben und die Vibration kaum spüren.

#13 erledigt (2.1.5) — Die Wiedervorlage schwerer Aufgaben greift bei den Vorrats-Lektionen
nicht: _generateFixedSumTasks und _generateClockPhraseTasks ignorieren den
review-Parameter. Bei "Uhrzeit sagen" kommen in zehn Aufgaben zehn der elf
Formen dran — ausgerechnet die schwerste kann die fehlende sein. Ein Vorrat
könnte die Wiedervorlage-Formen an den Anfang des Blocks ziehen, statt sie zu
verwerfen.

#14 erledigt (2.4.6) — Klickgeräusch ist nur einmal hörbar.

#15 erledigt (2.4.6) — Abbruch einer Übung hat über einen kurz sichtbaren Pausenscreen geführt.

#16 erledigt (2.4.7) — Um zu verhindern, dass man bei leichten Übungen nur auf Geschwindigkeit geht, ein konfigurierbateres Maximum Sterne pro Übung pro Tag einführen, einstellbar im Elternbereich die die Zeiten auch

#17 erledigt (2.5.0) — Im Elternbereich, Übungsverlauf: Knopf zum Aufräumen unvollständiger Übungsläufe, nur für ausgewählte Version. Das und auch das normale Löschen einer Übung darf die Bestenliste und STerne/Blitze beeinflussen, aber nicht die verbrauchte Zeit. Version 2.5.0

#18 erledigt (2.6.0) — Grüner Knopf für Pineingabe unnötig: Entwerder Eingabe abwarten oder nicht mehr anzeigen.

#19 erledigt (2.6.0) — Neuer default für Gesamtzeit zum Üben: 60 min statt 120 min

#20 erledigt (2.6.0) — Profil temporär im Elternbereich sperrbar machen

#21 erledigt (2.6.2) — Klick unter Linux: kam einmal, das zweite Mal leiser,
dann gar nicht mehr. Ursache war nicht die App, sondern die Länge des Tons:
zwischen zwei Klicks wird der Abspielstrang angehalten, was den
PulseAudio-Strom korkt, und die echte Soundkarte braucht danach einige
Millisekunden. Der 35-ms-Klick fiel komplett in dieses Anlaufen. Mit
demselben Integrationstest gemessen, nur das Ausgabegerät gewechselt: am
Null-Sink 33 von 33 Klicks, an der echten Karte 1 von 33 — deshalb sah jede
frühere Messung gesund aus. Mit 45 ms Stille vorn und längerem Ausklang
kommen an der echten Karte 33 von 33 an.

Auf dem Weg dorthin nebenbei gefunden und behoben (2.6.1): feste
Abspieler-IDs plus ein nicht abgewartetes dispose ließen warmUp bei jedem
zweiten Durchgang hängen. Ein echter Fehler, aber nicht dieser.

#22 erledigt (2.6.3) — click Geräusch ist jetzt unter Android spürbar später, als Hauptplattform nicht ideal

#23 erledigt (2.7.0) — Neue Übung: Punkt vor Strich Rechnung: a */ b +- c
(Division ohne Rest, alles im Bereich unter 100). Eine Lektion in „Mal und
Geteilt", beide Reihenfolgen (Punktrechnung vorn und hinten) gleich häufig.
Ein Task trägt jetzt drei Operanden und zwei Rechenarten (Schema v12), damit
Wiedervorlage und „schwere Aufgaben" den vollständigen Term speichern statt
ihn falsch aufzuschreiben.

#24 erledigt (2.8.0, Frist vereinfacht in 2.8.1) — Aufgaben: Ein Elternteil
weist einem Kind eine Lektion zu, mit Rhythmus (täglich oder wöchentlich, die
Woche endet Sonntagabend), wie vielen Durchgängen zu wie vielen Rechnungen,
und mit Mindeststernen und -blitzen. Der Tagesdeckel aus #16 wird dabei ausgesetzt,
aber nur für die zugewiesene Lektion und nur, bis der laufende Zeitraum sein
Ziel erreicht hat — sonst könnten drei missglückte Versuche die Wertung für
den Tag aufbrauchen, bevor die Aufgabe je erfüllt wurde. Für das Kind erscheint
eine offene Aufgabe als Karteikarte in einer eigenen Gruppe „Deine Aufgaben"
ganz oben im Katalog, nach Frist sortiert; eine erfüllte Karte bleibt bis zum
Ende des Zeitraums stehen, gedämpft und mit grünem Haken, aber weiter
antippbar. Eine Aufgabe wird nie geändert, nur beendet und neu angelegt, damit
„geschafft an 12 von 15 Tagen" eine stabile Messlatte behält; der
Elternbereich zeigt genau diese Statistik samt einem Punktestreifen der
letzten vierzehn Zeiträume.

Nachtrag 2.8.1: Die Uhrzeit als Frist ist wieder weg (Schema v14). Ein Kind
schaut nicht auf die Uhr, und „noch bis 18:00" war Druck ohne Zweck; gemeint
ist ohnehin „heute" oder „diese Woche". Nebenbei fiel damit eine
Ungereimtheit weg: mit einer Uhrzeit galt ein Tag, dessen Frist um 18 Uhr
verstrichen war, um 20 Uhr noch als laufend. Jetzt ist die Frist das Ende des
Zeitraums, und beides ist dieselbe Frage.

#25 erledigt (2.8.2) — Ein Profil sperrte sich über Tage selbst: die
Übungszeit von gestern zählte gegen das heutige Tageslimit. Die Tagesgrenze
wurde in jeder Regel einzeln aus `clockProvider` gebildet, also genau einmal
beim Bau des Providers, und auf einem Tablet wird die App nicht neu
gestartet. Verborgen hat es sich dadurch, dass der einzige Weckruf an
`breakUntil` hing und damit nur lief, während ohnehin gesperrt war — der Tag
sprang genau dann um, wenn es am wenigsten nötig war. Jetzt kommt die Grenze
aus `dayStartProvider` und wird beim Zurückkehren in den Vordergrund neu
gestellt.

#26 erledigt (2.8.3) — Neue Gruppen werden pro Profil nur noch dann
automatisch sichtbar, wenn sie an eine schon aktive Gruppe grenzen. Dafür
merkt sich `users.known_groups` (Schema v15), gegen welchen Katalog die
Sichtbarkeit entschieden wurde — ohne das lässt sich „vom Elternteil
angelassen" nicht von „gab es damals noch nicht" unterscheiden. Gemessen wird
nur gegen bekannte Gruppen, damit bei zwei gleichzeitig ergänzten nicht die
eine die andere mitzieht. Bestehende Profile sehen nach dem Update
unverändert dasselbe.

#27 erledigt (2.9.0) — Die Profilverwaltung war unübersichtlich geworden: neun
Abschnitte in einem Dialog-Scroll mit „Speichern" darunter, und vier
beschriftete Knöpfe in jeder Zeile. Jetzt öffnet ein Tipp auf die Zeile einen
eigenen Bildschirm mit App-Bar — Kreuz links, „Speichern" mit Haken rechts,
beides immer sichtbar. Die Zurück-Geste fragt, wenn etwas ungespeichert ist,
und schweigt sonst. Die Sperre steht als eigener Block ganz oben, gesperrte
Profile erscheinen in der Liste gedämpft und mit Schloss. Üben und Zeit
stehen im Querformat nebeneinander, darunter fällt es auf eine Spalte zurück.
Umbenennen, Zurücksetzen und Löschen sind aus der Zeile in den Block
„Aufräumen" am Fuß des Bildschirms gewandert.

#28 erledigt (2.9.1) — In den Ersten Schritten gab es immer drei Sterne,
unabhängig von den Fehlern. Damit sagten die Sterne dort nichts, und ein
einziger Durchgang je Lektion räumte die Gruppe aus dem Katalog, weil
„Fertige Lektionen ausblenden" in der ersten Stufe nur nach Sternen fragt.
Jetzt gilt überall dieselbe Regel: die Fehlerquote entscheidet. Ausgenommen
bleibt allein die Mindestlänge — fünf Bilder zu zählen ist dort ein richtiger
Durchgang. Bereits verdiente Sterne bleiben stehen, sie werden nur nach oben
geschrieben; wer einen sauberen Stand will, gibt sie im Elternbereich zurück.

#29 erledigt (2.9.2) — Die Zeit auf den Lektionskacheln wurde auf schmaleren
Geräten abgeschnitten: bei vier fest eingestellten Spalten blieben ihr auf
960 dp noch 19 dp. Die Fußzeile trägt sechs Symbole zu 24 dp, und nur die
Zeit gibt nach. `tileColumns` wählt die Spaltenzahl jetzt nach der Breite.
Aufgefallen war es nie, weil die Layouttests mit devicePixelRatio 1 auf
1280x800 laufen, also im großzügigen Fall — und weil abgeschnittener Text
kein Layoutfehler ist.

#30 erledigt (2.9.3) — Nachtrag zu #29: die Kopfzeile des Übungsbildschirms
läuft mit ihren Beschriftungen unter rund 900 dp über. Unter 950 dp geben
„Statistik" und „Wechseln" deshalb ihr Wort auf und bleiben als Symbol mit
Tooltip. Dabei stellte sich heraus, dass die erste Messung falsch war: die
quadratische Testschrift macht jedes Wort doppelt so breit, weshalb die
Kopfzeile im Test schon bei 960 dp überlief, auf einem Gerät aber erst unter
900. Auf keinem Tablet trat das je auf.

#31 erledigt (2.9.4) — Der Tagesdeckel für gewertete Durchgänge gilt in den
Ersten Schritten nicht mehr. Dort gibt es nichts zu erschleichen: keine Uhr,
keine Bestenliste, keine Blitze. Bewirkt hat er nur, dass ein vierter Anlauf
keine Sterne mehr brachte — bei den Jüngsten, für die ein vierter Anlauf
genau das ist, wofür die Gruppe da ist. Der Hinweis „zählt heute nicht mehr"
erscheint dort ebenfalls nicht mehr.

#32 erledigt (2.10.0) — Der Übungsverlauf im Elternbereich lässt sich jetzt
zusätzlich nach Zeit eingrenzen: Alle, Heute, 7 Tage, 30 Tage, in einer
eigenen Chip-Reihe unter der nach Kind. Gezählt werden ganze Kalendertage,
gerechnet über DateTime, damit die Zeitumstellung keinen Tag verschiebt. Der
Aufräumknopf für abgebrochene Durchgänge folgt beiden Filtern und entfernt
genau die Zeilen, die auf dem Bildschirm stehen; die Rückfrage nennt Kind und
Zeitraum.

#33 erledigt (2.10.1) — Gruppentitel wurden neben dem Lektionstitel
kleingeschrieben, also „uhrzeit und geld" statt „Uhrzeit und Geld". Im
Deutschen ist ein Gruppentitel ein Name; die Kleinschreibung stand an drei
Stellen (Übungsverlauf, Aufgabenliste, Statistiktabelle) und ist überall weg.
Beim Durchsehen der übrigen Texte im Aufgabenbereich: „Mindestens Sterne"
und „Mindestens Blitze" heißen jetzt „Mindeststerne" und „Mindestblitze", der
Platzhalter der Lektionsauswahl „Bitte auswählen" statt „auswählen".

#34 erledigt (2.10.2) — Am Ende eines Durchgangs war nicht zu erkennen, was
die Aufgabe überhaupt verlangt hatte. Der Ergebnisbildschirm zeigt jetzt die
geforderten Sterne und Blitze in denselben Symbolen wie die verdienten, dazu
den Stand („zählt für deine Aufgabe: 1 von 3") oder den grünen Haken, wenn
sie erfüllt ist.

#35 erledigt (2.10.3) — Eine laufende Aufgabe lässt sich im Elternbereich
ändern: Rhythmus, Durchgänge, Rechnungen, Mindeststerne und Mindestblitze.
Kind und Lektion bleiben fest, die machen eine andere Aufgabe daraus. Der
Erledigt-Status zieht automatisch nach, weil an einer Aufgabe nichts
eingefroren ist — eine höher gehängte Latte nimmt den grünen Haken von heute
also wieder weg, eine tiefer gehängte gibt ihn zurück.

#36 erledigt (2.11.0) — Eine Aufgabe kann mehrere Übungen umfassen, gewählt
über eine Mehrfachauswahl. Erledigt ist sie, wenn jede davon erfüllt ist;
gemessen wird jede für sich. Beim Ändern sind schon geschaffte Übungen
gedämpft und abgehakt, aber weiter abwählbar, und mindestens eine muss stehen
bleiben. Für das Kind ändert sich nichts: jede Übung ist ihre eigene
Karteikarte wie bisher. Schema v16 benennt die Spalte auf eine Liste um, eine
einzelne ID ist bereits eine gültige einelementige Liste.

#37 erledigt (2.12.0) — Aus einer Durchsicht des ganzen Projekts:

* Der Elternbereich zeigt, wann zuletzt gesichert wurde, und mahnt nach vier
  Wochen. Vorher erinnerte nichts daran, obwohl alles auf einem Tablet liegt.
* Gelöschte Durchgänge lassen sich direkt danach zurückholen. Sie werden
  ohnehin nur markiert, es fehlte allein der Weg zurück.
* Der Startdialog nennt jetzt auch die geforderten Sterne und Blitze, nicht
  erst der Ergebnisbildschirm. Die Marke auf der Profilkachel zählt nur noch
  offene Aufgaben und sagt „alles geschafft", wenn nichts mehr aussteht.
* Rohe Ausnahmetexte stehen nicht mehr auf Kinderbildschirmen; im
  Elternbereich bleibt die technische Zeile, dort kann jemand etwas damit
  anfangen. Nach einem Duell meldet sich die App wieder ab.

Nachgemessen und in Ordnung: bis 130 % System-Schriftgröße bricht kein
Bildschirm, und Duell-Durchgänge werden je Kind gespeichert und zählen auf
die Übungszeit.

#38 erledigt (2.12.1) — Die drei offen gebliebenen Punkte aus der Durchsicht:

* Gelöschte Durchgänge lassen sich über den Chip „Gelöschte" im
  Übungsverlauf auch später zurückholen, nicht nur in den acht Sekunden, die
  die Meldung steht.
* Die Elternliste sagt je Lektion, wie viele abgeschlossene Zeiträume sie
  gehalten hat. Der Punktestreifen sagte nur, dass einer gerissen wurde.
* Die Zahl am Aufräumknopf kommt aus einer eigenen Abfrage statt aus der
  angezeigten Liste, die bei 200 Zeilen endet. Ist die Liste abgeschnitten,
  steht das jetzt dabei.

#39 erledigt (2.12.2) — Die beiden Prüflücken geschlossen: die Layouttests
laufen zusätzlich auf 960x600 (was ein 10-Zoll-Tablet mit 1920x1200 meldet)
und mit einer echten Schrift statt der quadratischen Testschrift. Beides
förderte sofort etwas zutage — die Lektionstabelle der Statistik lief bei
960 dp über, und der Startdialog passte mit aufgeklappter Erklärung nicht
mehr auf einen 600 dp hohen Schirm. Beides behoben, nicht weggeprüft.

#40 erledigt (2.13.0) — Aufgaben lassen sich planen statt nur wiederholen.
Aus „täglich/wöchentlich" werden zwei Felder: was ein Zeitraum ist (Tag oder
Woche) und ob er wiederkommt. Eine einmalige Aufgabe trägt ein Datum, und
mehrere nebeneinander sind ein Plan — heute das, morgen jenes, diese Woche
das, nächste Woche jenes. Dazu die Option „Nachziehen": eine nicht erledigte
einmalige Aufgabe bleibt stehen, bis sie gemacht ist, der Tag selbst gilt
aber weiter als verpasst. Nachziehen gibt es nur für einmalige; bei
wiederkehrenden wäre es eine Schuld ohne Boden. Für das Kind ändert sich
nichts an der Darstellung.

#41 erledigt (2.13.1) — Zwei lose Enden aus 2.13.0: die Aufgabenliste im
Elternbereich ist nach dem Tag sortiert, zu dem eine Aufgabe gehört, nicht
nach dem Zeitpunkt der Eingabe — sonst liest sich ein Plan nicht als Plan.
Und eine vergangene einmalige Aufgabe sagt nur dann „noch offen", wenn sie
wirklich nachgezogen wird; sonst steht dort der Tag, an dem sie war.

#42 erledigt (2.13.2) — Eine einmalige Aufgabe bekam im Elternbereich die
Wiederholungsstatistik der wiederkehrenden: „Geschafft an 0 von 1 Tagen" und
ein einzelner Punkt. Sie hat einen Zeitraum, also gibt es ein Urteil statt
einer Zählung: geschafft, verpasst, verpasst und später nachgeholt, oder
steht noch aus. Dabei fiel auf, dass ein bewusst rückdatierter Tag durch die
Regel fiel, die eine wiederkehrende Aufgabe vor Tagen schützt, die es vor ihr
gab — für eine einmalige gilt sie nicht, ihr Tag ist gewählt.

#43 erledigt (2.13.3) — Alles vorbereitet, was F-Droid aus dem Repository
liest: Titel, Kurz- und Langbeschreibung auf Deutsch und Englisch, ein
Änderungshinweis, ein 512er-Icon und zehn Screenshots, alle unter
`fastlane/metadata/android/`. Die Bilder entstehen aus der App selbst
(`tool/screenshots_test.dart`), nicht aus einem Emulator, und mit der echten
Roboto — mit DejaVu brach die Statistiktabelle „Zehnerübergang" mitten im
Wort um, ein Fehler, den es auf dem Gerät nicht gibt. Die Übungshistorie in
den Bildern kommt aus dem echten Aufgabengenerator und ist über drei Wochen
verteilt: mit einem gemeinsamen Satz Zahlen stand in jeder Tabellenzeile
dasselbe, und mit einheitlichem Zeitstempel zeichnete die Lernkurve ein Kind,
das langsamer wird. Dazu die Versionen von 1.11.0 an nachträglich getaggt —
eine Build-Recipe zeigt auf einen Tag, nicht auf einen Branch.

#44 erledigt (2.13.3) — Ein Test lief eine Woche lang richtig und sonntags
falsch: „die Tageskarte steht vor der Wochenkarte" gilt nur, solange die
Woche später endet als der Tag. Am Sonntag laufen beide im selben Moment ab,
und dann entscheidet das Alter — was der Test daneben ohnehin prüft. Der Test
stellt die Uhr jetzt selbst auf einen Mittwoch, statt sich auf den Kalender
zu verlassen.
