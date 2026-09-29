class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.monthlyBudget,
  });

  final String firstName;
  final String lastName;
  final String email;

  /// Null when no budget is set.
  final double? monthlyBudget;

  String get fullName => '$firstName $lastName'.trim();

  String get initials =>
      '${firstName.isEmpty ? '' : firstName[0]}'
              '${lastName.isEmpty ? '' : lastName[0]}'
          .toUpperCase();
}
