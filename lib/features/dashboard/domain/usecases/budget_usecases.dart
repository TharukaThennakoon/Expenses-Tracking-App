import '../../../../core/usecase/usecase.dart';
import '../repositories/dashboard_repository.dart';

/// Sets the monthly budget, or removes it when given null.
class SetMonthlyBudget implements UseCase<void, double?> {
  const SetMonthlyBudget(this._repository);

  final DashboardRepository _repository;

  @override
  Future<void> call(double? budget) {
    if (budget != null && budget <= 0) {
      throw ArgumentError.value(budget, 'budget', 'must be greater than 0');
    }
    return _repository.setMonthlyBudget(budget);
  }
}

/// Emits whenever the profile (including the budget) changes.
class WatchProfileChanges implements StreamUseCase<void, NoParams> {
  const WatchProfileChanges(this._repository);

  final DashboardRepository _repository;

  @override
  Stream<void> call(NoParams params) => _repository.watchProfileChanges();
}
