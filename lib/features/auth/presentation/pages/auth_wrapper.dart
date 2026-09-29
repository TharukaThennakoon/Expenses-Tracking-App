import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shell/presentation/pages/main_shell_page.dart';
import '../../domain/entities/auth_user.dart';
import 'sign_in_page.dart';

/// Decides between Home and Sign in, and switches by itself whenever the
/// signed-in user changes (sign in, sign up, sign out).
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key, required this.authState});

  /// Emits the signed-in user (or null) on listen, then on every change.
  final Stream<AuthUser?> authState;

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final StreamSubscription<AuthUser?> _subscription;

  /// Built once per account change: the pages own their controllers, so
  /// rebuilding them on every frame would throw their state away.
  Widget? _page;
  String? _email;

  @override
  void initState() {
    super.initState();
    _subscription = widget.authState.listen(
      _onUserChanged,
      // If we can't tell who's signed in, signing in again settles it.
      onError: (Object _) => _onUserChanged(null),
    );
  }

  void _onUserChanged(AuthUser? user) {
    if (_page != null && user?.email == _email) return;
    _email = user?.email;
    final di = InjectionContainer.instance;
    final page = user == null
        ? SignInPage(
            key: const ValueKey('signed-out'),
            controller: di.signInController(),
          )
        : MainShellPage(key: ValueKey(user.email));
    setState(() => _page = page);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      // Until the first value, match the splash so there's no flash.
      child:
          _page ??
          ColoredBox(
            color: context.colors.primary,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.textOnPrimary),
            ),
          ),
    );
  }
}
