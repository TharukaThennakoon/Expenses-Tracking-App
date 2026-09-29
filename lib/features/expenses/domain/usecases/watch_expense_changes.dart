import '../../../../core/usecase/usecase.dart';
import '../repositories/expense_repository.dart';

class WatchExpenseChanges implements StreamUseCase<void, NoParams> {
  const WatchExpenseChanges(this._repository);

  final ExpenseRepository _repository;

  @override
  Stream<void> call(NoParams params) => _repository.watchChanges();
}
