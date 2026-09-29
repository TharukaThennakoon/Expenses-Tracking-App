import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/dashboard_repository.dart';

class GetUserProfile implements UseCase<UserProfile, NoParams> {
  const GetUserProfile(this._repository);

  final DashboardRepository _repository;

  @override
  Future<UserProfile> call(NoParams params) => _repository.getUserProfile();
}
