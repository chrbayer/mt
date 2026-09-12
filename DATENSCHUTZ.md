# Datenschutzerklärung für den Mathe-Trainer

Stand: 12. September 2026

Der Mathe-Trainer ist quelloffen: <https://github.com/chrbayer/mt>. Alles,
was hier steht, lässt sich dort nachlesen statt glauben.

## Kurz gesagt

Der Mathe-Trainer sendet nichts. Alles, was die App über ein Kind weiß,
bleibt auf dem Gerät, auf dem geübt wird. Es gibt keine Konten, keine
Werbung, keine Analyse, keine Absturzberichte und keine Verbindung zu
irgendeinem Server.

Die veröffentlichte Fassung der App fordert **keine einzige
Android-Berechtigung** an, auch keinen Internetzugriff. Sie könnte gar nichts
übertragen, selbst wenn sie es wollte.

## Wer verantwortlich ist

<!-- Vor der Veröffentlichung ausfüllen: Play und die DSGVO verlangen einen
     benannten Verantwortlichen mit ladungsfähiger Anschrift. Der Link auf
     das Projekt ersetzt das nicht. -->

    Name:      …
    Anschrift: …
    E-Mail:    …

Quelltext und dieser Text: <https://github.com/chrbayer/mt>. Fragen und
Hinweise gern dort als Issue.

## Welche Daten die App verarbeitet

Alles Folgende wird ausschließlich lokal auf dem Gerät gespeichert, in einer
Datenbank, die nur der App selbst gehört:

* **Profile**: der Name, den ein Elternteil oder Kind vergibt, ein Bild aus
  einer festen Auswahl von Emoji, eine Farbe.
* **Übungsergebnisse**: welche Lektion wann geübt wurde, wie lange, wie viele
  Fehlversuche, die einzelnen Aufgaben eines Durchgangs.
* **Einstellungen**: Übungszeiten, freigeschaltete Bereiche, Aufgaben, die
  ein Elternteil vergibt, und die übrigen Vorgaben.
* **Eltern-PIN**: nicht im Klartext, sondern gesalzen gehasht.

Ein Name ist alles, was hier persönlich sein kann, und auch er ist frei
wählbar — ein Spitzname tut es genauso.

## Sicherungen

Der Elternbereich kann eine Sicherung erstellen. Dabei schreibt die App eine
JSON-Datei in einen temporären Ordner und übergibt sie dem Teilen-Dialog von
Android. **Wohin sie von dort geht, entscheiden Sie**: in eine Cloud, an eine
E-Mail, auf den eigenen Speicher. Ab diesem Moment gelten die
Datenschutzbedingungen des Dienstes, den Sie gewählt haben, nicht mehr diese
hier.

Das Einspielen einer Sicherung liest eine Datei, die Sie selbst auswählen.

## Was die App **nicht** tut

* keine Werbung, keine Werbe-IDs, kein Tracking
* keine Nutzungsstatistik, keine Absturzberichte, keine Telemetrie
* keine Konten, keine Anmeldung, keine Cloud
* keine Weitergabe an Dritte — es gibt nichts weiterzugeben
* kein Standort, kein Adressbuch, keine Kamera, kein Mikrofon

## Kinder

Die App richtet sich an Grundschulkinder. Gerade deshalb verlässt nichts das
Gerät: Es gibt keine Daten, in deren Erhebung ein Elternteil einwilligen
müsste, und nichts, was ein Kind versehentlich preisgeben könnte. Der
Elternbereich ist zusätzlich durch eine PIN geschützt.

## Löschen

* Ein einzelnes Profil samt seiner Ergebnisse löschen Sie im Elternbereich.
* Alles auf einmal löschen Sie, indem Sie die App deinstallieren oder in den
  Android-Einstellungen ihre Daten löschen.

Da uns keine Daten erreichen, gibt es nichts, was wir auf Anfrage herausgeben,
berichtigen oder löschen könnten. Auskunft, Berichtigung und Löschung nach
Art. 15 bis 17 DSGVO betreffen ausschließlich die Daten auf Ihrem Gerät, und
darüber verfügen Sie selbst.

## Änderungen

Ändert sich etwas an der Verarbeitung, ändert sich diese Erklärung, und das
Datum oben sagt wann.

---

*Dieser Text beschreibt, was die App nachweislich tut — er ist keine
Rechtsberatung. Vor einer Veröffentlichung im Play Store sollte jemand mit
juristischem Blick darüber gehen, insbesondere über die Angaben zum
Verantwortlichen.*
