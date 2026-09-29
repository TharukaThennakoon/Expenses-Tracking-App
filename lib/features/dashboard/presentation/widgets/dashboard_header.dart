import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.profile, this.onSearch});

  final UserProfile profile;
  final VoidCallback? onSearch;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: context.colors.primary,
          child: Text(
            profile.initials,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                profile.firstName,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: context.colors.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onSearch,
            child: SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                Icons.search_rounded,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
