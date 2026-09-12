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
