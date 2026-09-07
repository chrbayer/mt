#!/usr/bin/env python3
"""Erzeugt die Töne der App als kleine WAV-Dateien.

Selbst erzeugt statt heruntergeladen: zwei kurze Sinustöne sind ein paar
Zeilen Mathematik, brauchen keine Lizenz und wiegen zusammen 20 kB. Wer sie
ändern will, ändert die Noten hier und lässt das Skript neu laufen.
"""
import math
import struct
import wave

RATE = 22050


def tone(frames, freq, start, duration, volume=0.35):
    """Mischt einen Sinus mit weichem Ein- und Ausblenden in die Spur."""
    first = int(start * RATE)
    total = int(duration * RATE)
    fade = int(0.012 * RATE)
    for i in range(total):
        # Ohne Aus- und Einblenden knackt es an den Rändern hörbar.
        edge = min(i, total - i, fade) / fade
        value = math.sin(2 * math.pi * freq * i / RATE) * volume * edge
        index = first + i
        if index < len(frames):
            frames[index] += value


def click(frames, freq, duration, volume, decay):
    """Ein Klick, kein Ton: sofort da und exponentiell wieder weg.

    Ein Sinus mit weichem Einblenden klingt bei 30 ms wie ein Piep. Der
    Klick braucht den harten Anschlag - nur die ersten zwei Millisekunden
    werden gerampt, damit die Membran nicht knackt.
    """
    total = int(duration * RATE)
    attack = int(0.002 * RATE)
    for i in range(total):
        t = i / RATE
        envelope = math.exp(-t / decay) * min(1.0, i / attack)
        frames[i] += math.sin(2 * math.pi * freq * t) * volume * envelope


def write(name, length, notes):
    frames = [0.0] * int(length * RATE)
    for freq, start, duration in notes:
        tone(frames, freq, start, duration)
    with wave.open(f'assets/sound/{name}.wav', 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(b''.join(
            struct.pack('<h', int(max(-1.0, min(1.0, f)) * 32000))
            for f in frames))


# Richtig: zwei steigende Töne, e" und h" - kurz, freundlich, nicht triumphal.
write('correct', 0.30, [(659.25, 0.0, 0.12), (987.77, 0.11, 0.18)])
# Falsch: ein tieferer, einzelner Ton. Kein Summer - ein Fehler ist ein
# Hinweis, keine Rüge.
write('wrong', 0.22, [(311.13, 0.0, 0.20)])

# Tastenklick: ohne erkennbare Tonhöhe und leiser als die Rückmeldung. Er
# kommt bis zu fünfzigmal je Aufgabe, also darf er nichts behaupten - er
# bestätigt nur, dass die Taste angekommen ist. Die zweite Frequenz ist
# absichtlich kein Vielfaches der ersten: zusammen ergeben sie ein Geräusch
# statt einer Note.
def key_click(lead_silence):
    """Derselbe Klick, nur mit unterschiedlich viel Stille davor."""
    body = [0.0] * int(0.12 * RATE)
    click(body, 1720.0, 0.100, 0.13, 0.022)
    click(body, 2630.0, 0.060, 0.06, 0.014)
    return [0.0] * int(lead_silence * RATE) + body


def write_frames(name, frames):
    with wave.open(f'assets/sound/{name}.wav', 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(b''.join(
            struct.pack('<h', int(max(-1.0, min(1.0, f)) * 32000))
            for f in frames))


# Android bekommt den Klick ohne Vorlauf: dort ist er sofort da, und jede
# Millisekunde Verzögerung ist unter dem Finger zu spüren.
write_frames('key', key_click(0.0))

# Der Desktop bekommt 45 ms Stille davor. Zwischen zwei Klicks wird der
# Abspielstrang angehalten, was den PulseAudio-Strom korkt, und eine echte
# Soundkarte braucht danach einige Millisekunden, bis wieder Töne
# herauskommen. Ohne den Vorlauf fällt der ganze Klick in dieses Anlaufen: an
# der echten Karte gemessen kam einer von 33 an, mit Vorlauf 33 von 33.
write_frames('key_desktop', key_click(0.045))
