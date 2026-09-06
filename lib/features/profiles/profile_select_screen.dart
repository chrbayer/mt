import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_screen.dart';
import '../admin/pin_gate.dart';
import '../duel/duel_screen.dart';
import '../lessons/lesson_home_screen.dart';
import '../stats/global_stats_screen.dart';
import 'profile_editor.dart';

/// Start screen: a tap on a tile is the whole login.
class ProfileSelectScreen extends ConsumerWidget {
  const ProfileSelectScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, User user) {
    ref.read(activeUserProvider.notifier).select(user);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LessonHomeScreen()),
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

class _ProfileTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(user.colorIndex);
    return SizedBox(
      width: _tileWidth,
      height: _tileHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: color.withValues(alpha: 0.12),
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
                      Text(user.avatar, style: const TextStyle(fontSize: 88)),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
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
