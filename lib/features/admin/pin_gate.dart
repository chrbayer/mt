import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../practice/widgets/big_keypad.dart';

/// Asks for the parent PIN and returns whether the parent area may open.
///
/// On first use there is no PIN yet, so the dialog sets one up instead of
/// asking for one - that way there is no default PIN written down anywhere
/// for a child to look up.
Future<bool> requireAdminPin(BuildContext context) async {
  final passed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _PinDialog(),
  );
  return passed ?? false;
}

enum _Step { verify, choose, repeat }

class _PinDialog extends ConsumerStatefulWidget {
  const _PinDialog();

  @override
  ConsumerState<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends ConsumerState<_PinDialog> {
  _Step? _step;
  String _input = '';
  String _firstEntry = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _decideStep();
  }

  Future<void> _decideStep() async {
    final exists = await ref.read(settingsRepositoryProvider).hasAdminPin();
    if (mounted) {
      setState(() => _step = exists ? _Step.verify : _Step.choose);
    }
  }

  void _press(int digit) {
    if (_input.length >= adminPinLength) return;
    setState(() {
      _error = null;
      _input += '$digit';
    });
    if (_input.length == adminPinLength) _submit();
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _submit() async {
    if (_input.length < adminPinLength) return;
    final entered = _input;
    final settings = ref.read(settingsRepositoryProvider);

    switch (_step!) {
      case _Step.verify:
        if (await settings.checkAdminPin(entered)) {
          if (mounted) Navigator.of(context).pop(true);
        } else {
          setState(() {
            _input = '';
            _error = 'Falsche PIN.';
          });
        }
      case _Step.choose:
        setState(() {
          _firstEntry = entered;
          _input = '';
          _step = _Step.repeat;
        });
      case _Step.repeat:
        if (entered == _firstEntry) {
          await settings.setAdminPin(entered);
          if (mounted) Navigator.of(context).pop(true);
        } else {
          setState(() {
            _input = '';
            _firstEntry = '';
            _step = _Step.choose;
            _error = 'Die beiden Eingaben waren verschieden.';
          });
        }
    }
  }

  (String, String) get _labels => switch (_step!) {
        _Step.verify => ('Elternbereich', 'PIN eingeben'),
        _Step.choose => (
            'Elternbereich einrichten',
            'Wähle eine PIN aus $adminPinLength Ziffern'
          ),
        _Step.repeat => ('Elternbereich einrichten', 'PIN wiederholen'),
      };

  @override
  Widget build(BuildContext context) {
    if (_step == null) {
      return const Dialog(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final (title, hint) = _labels;
    final preferences =
        ref.watch(preferencesProvider).value ?? const AppPreferences();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < adminPinLength; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _input.length
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: _error == null
                                ? AppColors.divider
                                : AppColors.wrong,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 34,
                child: _error == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.wrong,
                          ),
                        ),
                      ),
              ),
              SizedBox(
                height: 380,
                child: BigKeypad(
                  haptics: preferences.haptics,
                  onDigit: _press,
                  onBackspace: _backspace,
                  onSubmit: _submit,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
