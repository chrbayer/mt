import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../theme/app_theme.dart';

/// Plays the click ten times and counts how many actually ran.
///
/// "Der Ton geht nicht" is impossible to act on: it could be the switch above,
/// the device volume, a missing audio backend, or a stale build. Counting the
/// completions turns it into a number - and it catches the fault that matters
/// here, where the first sounds play and later ones quietly stop coming.
/// The platform's own error text is shown too; on a tablet there is no
/// console to read it from.
class SoundTestButton extends ConsumerStatefulWidget {
  const SoundTestButton({super.key});

  @override
  ConsumerState<SoundTestButton> createState() => _SoundTestButtonState();
}

class _SoundTestButtonState extends ConsumerState<SoundTestButton> {
  bool _running = false;
  String? _error;
  ({int played, int expected})? _result;

  Future<void> _test() async {
    setState(() {
      _running = true;
      _error = null;
      _result = null;
    });

    // The app's own instance, and deliberately not disposed here: it belongs
    // to the whole app, and a second set of players existing alongside it was
    // the fault this button was built to find.
    final sounds = ref.read(feedbackSoundsProvider);
    final result = await sounds.selfTest();
    final error = sounds.lastError;

    if (!mounted) return;
    setState(() {
      _running = false;
      _error = error;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.volume_up_outlined, size: 24),
          label: Text(_running ? 'Spielt …' : 'Ton testen (10 Klicks)',
              style: const TextStyle(fontSize: 18)),
          onPressed: _running ? null : _test,
        ),
        if (_result != null && _error == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _result!.played == _result!.expected
                  ? '${_result!.played} von ${_result!.expected} Klicks haben '
                      'gespielt. War nichts zu hören, liegt es an der '
                      'Lautstärke des Geräts.'
                  : 'Nur ${_result!.played} von ${_result!.expected} Klicks '
                      'haben gespielt - der Ton bricht auf diesem Gerät ab.',
              style: TextStyle(
                fontSize: 17,
                color: _result!.played == _result!.expected
                    ? AppColors.textMuted
                    : AppColors.wrong,
              ),
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
