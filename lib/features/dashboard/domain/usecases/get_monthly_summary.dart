import '../../../../core/usecase/usecase.dart';
import '../entities/monthly_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetMonthlySummary implements UseCase<MonthlySummary, DateTime> {
  const GetMonthlySummary(this._repository);

  final DashboardRepository _repository;

  @override
  Future<MonthlySummary> call(DateTime month) =>
      _repository.getMonthlySummary(DateTime(month.year, month.month));
}
