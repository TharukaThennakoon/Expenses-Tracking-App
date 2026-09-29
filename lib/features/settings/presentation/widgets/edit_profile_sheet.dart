import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/domain/entities/user_profile.dart';
import '../../../dashboard/domain/usecases/update_profile.dart';

/// Edits first name, last name and email. [onSave] may throw
/// [ProfileValidationException]. Returns true once saved.
Future<bool?> showEditProfileSheet(
  BuildContext context, {
  required UserProfile profile,
  required Future<void> Function(UserProfile profile) onSave,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _EditProfileSheet(profile: profile, onSave: onSave),
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile, required this.onSave});

  final UserProfile profile;
  final Future<void> Function(UserProfile profile) onSave;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final _first = TextEditingController(text: widget.profile.firstName);
  late final _last = TextEditingController(text: widget.profile.lastName);
  late final _email = TextEditingController(text: widget.profile.email);
  ProfileErrors _errors = const ProfileErrors();
  bool _saving = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final errors = UpdateProfile.validate(
      firstName: _first.text,
      lastName: _last.text,
      email: _email.text,
    );
    if (!errors.isEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(
        UserProfile(
          firstName: _first.text,
          lastName: _last.text,
          email: _email.text,
          monthlyBudget: widget.profile.monthlyBudget,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on ProfileValidationException catch (e) {
      setState(() {
        _errors = e.errors;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              _Field(
                label: 'First name',
                controller: _first,
                error: _errors.firstName,
                autofocus: true,
                capitalize: true,
                onChanged: () => setState(
                  () => _errors = ProfileErrors(
                    lastName: _errors.lastName,
                    email: _errors.email,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Field(
                label: 'Last name (optional)',
                controller: _last,
                error: _errors.lastName,
                capitalize: true,
                onChanged: () => setState(
                  () => _errors = ProfileErrors(
                    firstName: _errors.firstName,
                    email: _errors.email,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Field(
                label: 'Email',
                controller: _email,
                error: _errors.email,
                keyboardType: TextInputType.emailAddress,
                last: true,
                onSubmitted: _save,
                onChanged: () => setState(
                  () => _errors = ProfileErrors(
                    firstName: _errors.firstName,
                    lastName: _errors.lastName,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Save profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.error,
    this.autofocus = false,
    this.capitalize = false,
    this.keyboardType,
    this.last = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final String? error;
  final bool autofocus;
  final bool capitalize;
  final TextInputType? keyboardType;
  final bool last;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textCapitalization: capitalize
          ? TextCapitalization.words
          : TextCapitalization.none,
      autocorrect: !last,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      onChanged: (_) {
        if (error != null) onChanged();
      },
      onSubmitted: (_) => onSubmitted?.call(),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        filled: true,
        fillColor: context.colors.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
