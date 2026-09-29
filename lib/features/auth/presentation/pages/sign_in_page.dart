import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/auth_user.dart';
import '../controllers/auth_form_controller.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.controller});

  final SignInController controller;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  SignInController get _controller => widget.controller;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final ok = await _controller.submit(
      email: _email.text,
      password: _password.text,
    );
    if (ok && mounted) AppRoutes.backToAuthWrapper(context);
  }

  Future<void> _forgotPassword() async {
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    final ok = await _controller.sendPasswordReset(email: email);
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('If $email has an account, a reset link is on its way'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.primary,
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: SafeArea(
                    top: false,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthTextField(
                            label: 'Email',
                            controller: _email,
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            error: _controller.errorFor(AuthField.email),
                            onChanged: (_) =>
                                _controller.clearError(AuthField.email),
                          ),
                          const SizedBox(height: 18),
                          AuthTextField(
                            label: 'Password',
                            controller: _password,
                            icon: Icons.lock_outline_rounded,
                            obscure: true,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            error: _controller.errorFor(AuthField.password),
                            onChanged: (_) =>
                                _controller.clearError(AuthField.password),
                            onSubmitted: (_) => _submit(),
                            labelTrailing: GestureDetector(
                              onTap: _forgotPassword,
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: colors.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          if (_controller.formError case final error?) ...[
                            const SizedBox(height: 16),
                            FormErrorBanner(message: error),
                          ],
                          const SizedBox(height: 24),
                          AuthSubmitButton(
                            label: 'Sign in',
                            trailingIcon: Icons.arrow_forward_rounded,
                            busy: _controller.isBusy,
                            onPressed: _submit,
                          ),
                          const Spacer(),
                          const SizedBox(height: 24),
                          AuthSwitchPrompt(
                            text: 'New to ${AppConstants.appName}? ',
                            action: 'Create an account',
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.signUp),
                          ),
                        ],
                      ),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final ring = Colors.white.withValues(alpha: 0.12);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Decorative rings in the top-right corner.
        Positioned(right: -110, top: 40, child: _Ring(size: 260, color: ring)),
        Positioned(right: -40, top: 110, child: _Ring(size: 140, color: ring)),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.ink,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Know where\nevery rupee '),
                      TextSpan(
                        text: 'goes.',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 34,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sign in to see your spending at a glance.',
                  style: TextStyle(
                    color: AppColors.textOnPrimaryMuted,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
    );
  }
}
