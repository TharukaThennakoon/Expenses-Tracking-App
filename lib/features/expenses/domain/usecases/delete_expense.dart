import '../../../../core/usecase/usecase.dart';
import '../repositories/expense_repository.dart';

class DeleteExpense implements UseCase<void, String> {
  const DeleteExpense(this._repository);

  final ExpenseRepository _repository;

  /// Deletes the expense with the given id.
  @override
  Future<void> call(String id) => _repository.deleteExpense(id);
}
