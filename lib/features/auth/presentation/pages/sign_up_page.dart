import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../controllers/auth_form_controller.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_meter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.controller});

  final SignUpController controller;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  SignUpController get _controller => widget.controller;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Shown as soon as the confirmation differs, not only on submit.
  String? get _liveConfirmError =>
      _confirm.text.isNotEmpty && _confirm.text != _password.text
      ? AuthValidators.confirmPassword(_password.text, _confirm.text)
      : null;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final ok = await _controller.submit(
      fullName: _name.text,
      email: _email.text,
      password: _password.text,
      confirmPassword: _confirm.text,
    );
    if (ok && mounted) AppRoutes.backToAuthWrapper(context);
  }

  void _backToSignIn() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            color: colors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: colors.border),
                            ),
                            child: IconButton(
                              tooltip: 'Back',
                              onPressed: _backToSignIn,
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Create your account',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start tracking where your money goes.',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: 'Full name',
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          error: _controller.errorFor(AuthField.fullName),
                          onChanged: (_) =>
                              _controller.clearError(AuthField.fullName),
                        ),
                        const SizedBox(height: 18),
                        AuthTextField(
                          label: 'Email',
                          controller: _email,
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
                          obscure: true,
                          autofillHints: const [AutofillHints.newPassword],
                          error: _controller.errorFor(AuthField.password),
                          onChanged: (_) {
                            _controller.clearError(AuthField.password);
                            setState(() {}); // strength meter + match check
                          },
                        ),
                        const SizedBox(height: 10),
                        PasswordStrengthMeter(password: _password.text),
                        const SizedBox(height: 18),
                        AuthTextField(
                          label: 'Confirm password',
                          controller: _confirm,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          error:
                              _controller.errorFor(AuthField.confirmPassword) ??
                              _liveConfirmError,
                          onChanged: (_) {
                            _controller.clearError(AuthField.confirmPassword);
                            setState(() {});
                          },
                          onSubmitted: (_) => _submit(),
                        ),
                        if (_controller.formError case final error?) ...[
                          const SizedBox(height: 16),
                          FormErrorBanner(message: error),
                        ],
                        const Spacer(),
                        const SizedBox(height: 28),
                        AuthSubmitButton(
                          label: 'Create account',
                          busy: _controller.isBusy,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 6),
                        AuthSwitchPrompt(
                          text: 'Already have an account? ',
                          action: 'Sign in',
                          onTap: _backToSignIn,
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
