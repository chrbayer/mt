import 'package:flutter/material.dart';

import '../../data/db/app_database.dart';
import '../../theme/app_theme.dart';

/// Avatar and name of the child currently logged in.
///
/// Shown wherever results are being recorded. On a shared tablet the profile
/// is easy to forget, and a run under a sibling's name is only noticed once
/// the leaderboard looks wrong.
class ProfileBadge extends StatelessWidget {
  final User user;

  /// Font size of the name; the avatar scales with it.
  final double size;

  const ProfileBadge({super.key, required this.user, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(user.avatar, style: TextStyle(fontSize: size * 1.3)),
        SizedBox(width: size * 0.4),
        Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.profileColor(user.colorIndex),
          ),
        ),
      ],
    );
  }
}
