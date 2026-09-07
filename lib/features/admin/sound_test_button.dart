import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../practice/feedback_sounds.dart';

/// Plays the three sounds once, and says what went wrong if they stay silent.
///
/// "Der Ton geht nicht" is impossible to act on: it could be the switch above,
/// the device volume, a missing audio backend, or a stale build. A button that
/// plays them here answers the first three, and shows the platform's own error
/// text for the fourth - on a tablet there is no console to read it from.
class SoundTestButton extends StatefulWidget {
  const SoundTestButton({super.key});

  @override
  State<SoundTestButton> createState() => _SoundTestButtonState();
}

class _SoundTestButtonState extends State<SoundTestButton> {
  bool _running = false;
  String? _error;
  bool _played = false;

  Future<void> _test() async {
    setState(() {
      _running = true;
      _error = null;
      _played = false;
    });

    // Its own player, disposed straight after: the practice screen has one of
    // its own, and borrowing that would tie this button to whether a run
    // happens to be open.
    final sounds = FeedbackSounds();
    final ready = await sounds.warmUp();
    if (ready) {
      // All three, spaced out, so it is audible that each one replays and
      // not just the first - that was a real fault once.
      sounds.playKey();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      sounds.playCorrect();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      sounds.playWrong();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      sounds.playKey();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    final error = sounds.lastError;
    await sounds.dispose();

    if (!mounted) return;
    setState(() {
      _running = false;
      _error = error;
      _played = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.volume_up_outlined, size: 24),
          label: Text(_running ? 'Spielt …' : 'Ton testen',
              style: const TextStyle(fontSize: 18)),
          onPressed: _running ? null : _test,
        ),
        if (_played)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Vier Töne wurden abgespielt: Klick, richtig, falsch, Klick. '
              'War nichts zu hören, liegt es an der Lautstärke des Geräts.',
              style: TextStyle(fontSize: 17, color: AppColors.textMuted),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Der Ton ist auf diesem Gerät nicht verfügbar:\n$_error',
              style: const TextStyle(fontSize: 17, color: AppColors.wrong),
            ),
          ),
      ],
    );
  }
}
