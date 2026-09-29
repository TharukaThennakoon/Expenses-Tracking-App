import '../../../../core/usecase/usecase.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../repositories/dashboard_repository.dart';

class GetRecentExpenses implements UseCase<List<Expense>, int> {
  const GetRecentExpenses(this._repository);

  final DashboardRepository _repository;

  /// [limit] is the maximum number of expenses to return.
  @override
  Future<List<Expense>> call(int limit) =>
      _repository.getRecentExpenses(limit: limit);
}
