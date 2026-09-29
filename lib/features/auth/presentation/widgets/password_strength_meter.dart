import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/auth_usecases.dart';

/// Four bars plus a label ("Weak" .. "Strong") for a new password.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  static const _labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final score = AuthValidators.passwordStrength(password);
    final color = switch (score) {
      1 => colors.danger,
      2 => AppColors.warning,
      _ => colors.success,
    };
    return Semantics(
      label:
          'Password strength: ${_labels[score].isEmpty ? 'none' : _labels[score]}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 5,
                decoration: BoxDecoration(
                  color: i < score ? color : colors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            child: Text(
              _labels[score],
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
