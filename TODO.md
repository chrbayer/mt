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

#6 Die Empfehlungskachel umgeht die Zeitsperre. Sie tippt direkt in
PracticeScreen, wie es "Nochmal" bis 2.1.3 tat — in der Pause lässt sich
darüber weiter üben. Alle drei Türen (Startdialog, Nochmal, Empfehlung) müssen
dieselbe Prüfung machen; am besten eine gemeinsame Stelle statt drei Kopien.
Nebenbei startet die Kachel mit `?? fallbackTaskCount`, also mit 10 Aufgaben,
solange die gespeicherte Länge noch lädt — genau das Erfinden eines Vorgabe-
wertes, das CLAUDE.md verbietet.

#7 Solange die Einstellungen laden, ist der Start erlaubt.
practiceAllowanceForProvider gibt bei `preferences == null` "unlimited"
zurück, und die Bildschirme setzen `?? PracticeAllowance.unlimited` obendrauf.
Der Kommentar an der Stelle sagt das Gegenteil. Ein Kind, das in der Pause
schnell tippt, kommt im ersten Frame durch. Richtig wäre: solange unbekannt,
ist der Start deaktiviert — dieselbe Regel wie bei der Aufgabenzahl.

#8 Der Pausenhinweis rechnet die Restzeit mit DateTime.now(), die Entscheidung
darüber mit clockProvider. Zwei Uhren für dieselbe Aussage; in der App
identisch, aber die Zeitgrenze ist genau der Ort, an dem das auseinanderlaufen
darf.

## Bedienbarkeit

#9 Fünf Aufgaben sind wählbar, bringen aber weder Sterne noch Blitze noch
einen Bestenlisteneintrag — und nichts sagt es. Die Zehnergrenze steht nur in
der Bestenliste und in der Übersicht über alle Kinder, nicht im Startdialog
und nicht im Ergebnis. Ein Kind wählt die erste Kachel, rechnet fünf Aufgaben
fehlerfrei und bekommt drei leere Sterne ohne Erklärung.

#10 Keine Vorwarnung vor der Zeitgrenze. Nirgends steht, wie viel Übungszeit
heute noch bleibt; die Sperre kommt unangekündigt nach einem Durchgang. Ein
"noch 5 Minuten" vor dem Start des letzten Durchgangs wäre freundlicher — und
ein Kind könnte sich die Runde einteilen.

#11 Der Münzhaufen lässt sich nur Stück für Stück abräumen. Wer sich bei
"Betrag zusammenlegen" vertut, tippt sechsmal die Rücktaste. Ein langer Druck
oder eine eigene Taste zum Leeren würde reichen.

## Fehlt

#12 Kein Ton. Der ursprüngliche Plan sah Ton und Haptik vor, es gibt nur
Haptik. Ein kurzer Klang bei richtig/falsch hilft Kindern, die das Tablet
flach auf dem Tisch haben und die Vibration kaum spüren.

#13 Die Wiedervorlage schwerer Aufgaben greift bei den Vorrats-Lektionen
nicht: _generateFixedSumTasks und _generateClockPhraseTasks ignorieren den
review-Parameter. Bei "Uhrzeit sagen" kommen in zehn Aufgaben zehn der elf
Formen dran — ausgerechnet die schwerste kann die fehlende sein. Ein Vorrat
könnte die Wiedervorlage-Formen an den Anfang des Blocks ziehen, statt sie zu
verwerfen.
