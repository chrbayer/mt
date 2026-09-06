import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';

enum _Step { name, look }

/// Create or edit a profile. This is the only place in the app that shows the
/// system keyboard - everywhere else input goes through the big keypad.
///
/// It asks in two steps on purpose. The keyboard is only needed for the name,
/// and in the app's forced landscape it swallows most of the screen: a dialog
/// holding a text field, sixteen avatars and eight colours cannot fit above
/// it, least of all on a phone. So step one is nothing but the name - short
/// enough to sit above any keyboard - and step two has the whole dialog to
/// itself because no keyboard is open any more.
class ProfileEditorDialog extends ConsumerStatefulWidget {
  /// Null when creating a new profile.
  final User? user;

  /// Whether the name may be edited. Children get to pick their own picture
  /// and colour, but naming (and therefore creating) a profile belongs to the
  /// parent area.
  final bool allowRename;

  const ProfileEditorDialog({
    super.key,
    this.user,
    this.allowRename = true,
  });

  static Future<void> show(
    BuildContext context, {
    User? user,
    bool allowRename = true,
  }) =>
      showDialog<void>(
        context: context,
        builder: (_) => ProfileEditorDialog(
          user: user,
          allowRename: allowRename,
        ),
      );

  @override
  ConsumerState<ProfileEditorDialog> createState() =>
      _ProfileEditorDialogState();
}

class _ProfileEditorDialogState extends ConsumerState<ProfileEditorDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.user?.name ?? '');
  late String _avatar = widget.user?.avatar ?? avatarChoices.first;
  late int _colorIndex = widget.user?.colorIndex ?? 0;
  late _Step _step = widget.allowRename ? _Step.name : _Step.look;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _toLook() {
    if (_name.text.trim().isEmpty) return;
    // Closing the keyboard first gives the grids the room they need.
    FocusScope.of(context).unfocus();
    setState(() => _step = _Step.look);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;

    final navigator = Navigator.of(context);
    final repository = ref.read(userRepositoryProvider);
    if (widget.user == null) {
      await repository.createUser(
        name: name,
        avatar: _avatar,
        colorIndex: _colorIndex,
      );
    } else {
      await repository.updateUser(
        id: widget.user!.id,
        name: name,
        avatar: _avatar,
        colorIndex: _colorIndex,
      );
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: _step == _Step.name ? _buildNameStep() : _buildLookStep(),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    // On a phone in landscape the keyboard can leave under 200 dp. Anything
    // beyond the field itself then gets clipped, so the heading is dropped
    // rather than half-drawn and the whole step becomes a single row.
    final media = MediaQuery.of(context);
    final free = media.size.height - media.viewInsets.bottom;
    final compact = free < 280;

    final closeButton = IconButton(
      tooltip: 'Abbrechen',
      iconSize: 30,
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.of(context).pop(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.user == null ? 'Neues Profil' : 'Name ändern',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              closeButton,
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                maxLength: 20,
                style: const TextStyle(fontSize: 30),
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: const OutlineInputBorder(),
                  // The character counter costs a line the keyboard has
                  // already taken.
                  counterText: '',
                  hintText: compact
                      ? (widget.user == null ? 'Neues Profil' : null)
                      : null,
                ),
                // The keyboard's own key works too, so the button never has
                // to be reached from behind it.
                onSubmitted: (_) => _toLook(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_forward, size: 28),
              label: const Text('Weiter'),
              onPressed: _name.text.trim().isEmpty ? null : _toLook,
            ),
            if (compact) closeButton,
          ],
        ),
      ],
    );
  }

  Widget _buildLookStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(_avatar, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                _name.text.trim().isEmpty
                    ? 'Bild und Farbe'
                    : _name.text.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(color: AppColors.profileColor(_colorIndex)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Bild', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final emoji in avatarChoices)
              _ChoiceChip(
                selected: emoji == _avatar,
                onTap: () => setState(() => _avatar = emoji),
                child: Text(emoji, style: const TextStyle(fontSize: 34)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Farbe', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < AppColors.profile.length; i++)
              _ChoiceChip(
                selected: i == _colorIndex,
                onTap: () => setState(() => _colorIndex = i),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.profileColor(i),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.allowRename)
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, size: 26),
                label: const Text('Name ändern'),
                onPressed: () => setState(() => _step = _Step.name),
              )
            else
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: _save,
              child: const Text('Speichern'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _ChoiceChip({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : null,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 3 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
