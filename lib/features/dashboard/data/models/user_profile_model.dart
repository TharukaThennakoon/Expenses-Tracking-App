import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.monthlyBudget,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble(),
      );

  final String firstName;
  final String lastName;
  final String email;

  /// Null when no budget is set.
  final double? monthlyBudget;

  UserProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
  }) => UserProfileModel(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    monthlyBudget: monthlyBudget,
  );

  /// Pass the budget explicitly (null clears it).
  UserProfileModel withBudget(double? monthlyBudget) => UserProfileModel(
    firstName: firstName,
    lastName: lastName,
    email: email,
    monthlyBudget: monthlyBudget,
  );

  UserProfile toEntity() => UserProfile(
    firstName: firstName,
    lastName: lastName,
    email: email,
    monthlyBudget: monthlyBudget,
  );
}
