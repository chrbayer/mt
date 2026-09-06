#!/usr/bin/env python3
"""Erzeugt die beiden Rückmeldungstöne der App als kleine WAV-Dateien.

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
