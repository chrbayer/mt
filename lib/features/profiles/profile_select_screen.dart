import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_screen.dart';
import '../admin/pin_gate.dart';
import '../common/version_label.dart';
import '../duel/duel_screen.dart';
import '../lessons/lesson_home_screen.dart';
import '../stats/global_stats_screen.dart';
import 'profile_editor.dart';

/// Start screen: a tap on a tile is the whole login.
class ProfileSelectScreen extends ConsumerWidget {
  const ProfileSelectScreen({super.key});

  /// The one door into a run: every path to practice starts with a tap on a
  /// profile tile, so this is where a locked profile is turned away.
  void _open(BuildContext context, WidgetRef ref, User user) {
    if (user.locked) {
      _sayItIsLocked(context, user);
      return;
    }
    ref.read(activeUserProvider.notifier).select(user);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LessonHomeScreen()),
    );
  }

  /// A locked tile still answers. Silence would read as a broken app, and a
  /// child needs to know that nothing of theirs is gone.
  void _sayItIsLocked(BuildContext context, User user) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${user.name} macht gerade Pause'),
        content: const Text(
          'Dieses Profil ist vorübergehend gesperrt. Alle Sterne, Blitze und '
          'Bestzeiten bleiben erhalten - sie sind wieder da, sobald die '
          'Eltern es freigeben.',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Alles klar'),
          ),
        ],
      ),
    );
  }

  /// Creating a profile means giving it a name, and naming is a parent job -
  /// so this is the one action on this screen behind the PIN.
  Future<void> _createProfile(BuildContext context) async {
    if (!await requireAdminPin(context)) return;
    if (context.mounted) await ProfileEditorDialog.show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wer rechnet?'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.groups_outlined, size: 28),
            label: const Text('Alle Ergebnisse',
                style: TextStyle(fontSize: 20)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => const GlobalStatsScreen()),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: const Icon(Icons.sports_score, size: 28),
            label: const Text('Duell', style: TextStyle(fontSize: 20)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DuelSetupScreen()),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: const Icon(Icons.lock_outline, size: 26),
            label: const Text('Eltern', style: TextStyle(fontSize: 20)),
            onPressed: () => AdminScreen.open(context),
          ),
          // No settings button here any more: what used to sit behind it is
          // either a child's own business - and then it belongs inside their
          // own screen - or a parent's, and then it belongs behind the PIN.
          const SizedBox(width: 12),
        ],
      ),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Fehler: $error')),
        data: (list) => Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Noch kein Profil. Tippe auf „Neu", um anzufangen.',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              // A family or a small group has a handful of profiles, so the
              // tiles are centred and generously sized instead of sitting in
              // a wide grid that leaves most of the screen empty.
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final user in list)
                          _ProfileTile(
                            user: user,
                            onTap: () => _open(context, ref, user),
                            onEditLook: () => ProfileEditorDialog.show(
                              context,
                              user: user,
                              allowRename: false,
                            ),
                          ),
                        _NewProfileTile(
                          onTap: () => _createProfile(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom right, in the quietest corner there is: for a parent
              // checking which build sits on this tablet.
              const Align(
                alignment: Alignment.centerRight,
                child: VersionLabel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile tiles are big touch targets: a first-grader taps them from a
/// distance, often with the tablet flat on a table.
const double _tileWidth = 260;
const double _tileHeight = 240;

class _ProfileTile extends ConsumerWidget {
  final User user;
  final VoidCallback onTap;

  /// Picture and colour are the child's own business; renaming and deleting
  /// live in the parent area.
  final VoidCallback onEditLook;

  const _ProfileTile({
    required this.user,
    required this.onTap,
    required this.onEditLook,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A locked profile keeps its own colour, only muted: it is still Mia's
    // tile, and greying it into anonymity would say "gone" rather than
    // "later".
    final locked = user.locked;
    final color = locked
        ? AppColors.textMuted
        : AppColors.profileColor(user.colorIndex);
    // "Why should I practise today?" gets asked before the login, not after -
    // the badge only counts, it never says which lesson or whether it is
    // still open.
    final assignments = ref.watch(openAssignmentsProvider(user.id)).value;
    final assignmentCount = assignments?.length ?? 0;
    return SizedBox(
      width: _tileWidth,
      height: _tileHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: color.withValues(alpha: locked ? 0.06 : 0.12),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: color, width: 3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: locked ? 0.4 : 1,
                        child: Text(user.avatar,
                            style: const TextStyle(fontSize: 88)),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      if (!locked && assignmentCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          assignmentCount == 1
                              ? '1 Aufgabe'
                              : '$assignmentCount Aufgaben',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: locked
                // No palette while locked: choosing a colour for a tile you
                // cannot open is a door that leads nowhere.
                ? Icon(Icons.lock_outline, color: color, size: 28)
                : IconButton(
                    tooltip: 'Bild und Farbe ändern',
                    icon: Icon(Icons.palette_outlined, color: color, size: 28),
                    onPressed: onEditLook,
                  ),
          ),
        ],
      ),
    );
  }
}

class _NewProfileTile extends StatelessWidget {
  final VoidCallback onTap;

  const _NewProfileTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _tileWidth,
      height: _tileHeight,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider, width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 72, color: AppColors.textMuted),
                SizedBox(height: 8),
                Text(
                  'Neu',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
