import 'package:flutter/material.dart';

import '../error/app_exception.dart';
import '../theme/app_colors.dart';

/// Full-screen "couldn't load" state with a retry button.
///
/// A [NetworkException] adds the offline banner and a connection hint.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.title,
    required this.error,
    required this.onRetry,
  });

  final String title;
  final Object? error;
  final VoidCallback onRetry;

  bool get _offline => error is NetworkException;

  String get _message => _offline
      ? 'We couldn’t reach the server. Check your connection and try '
            'again — nothing you’ve saved is lost.'
      : 'Something went wrong on our side. Try again in a moment — '
            'nothing you’ve saved is lost.';

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    return Column(
      children: [
        if (_offline) const OfflineBanner(),
        Expanded(
          child: SafeArea(
            top: !_offline,
            bottom: false,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 120),
                child: Column(
                  children: [
                    const _ErrorIcon(),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: onRetry,
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.accent,
                        ),
                        label: const Text('Try again'),
                      ),
                    ),
                    if (error is AppException) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Error code: ${error.code}',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: context.colors.errorTint,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.cloud_outlined, size: 44, color: context.colors.danger),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              '!',
              style: TextStyle(
                color: context.colors.danger,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark strip at the top of the screen telling the user they're offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.offlineBanner,
      child: const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, size: 20, color: AppColors.warning),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You’re offline. Changes will sync later.',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
