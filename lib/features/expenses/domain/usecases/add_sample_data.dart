import 'dart:math' as math;

import '../../../../core/usecase/usecase.dart';
import '../../../dashboard/domain/repositories/dashboard_repository.dart';
import '../entities/expense.dart';
import '../entities/expense_category.dart';
import '../repositories/expense_repository.dart';

/// Fills the signed-in account with example expenses for this month and
/// last, and a budget if none is set. For trying the app out; only offered
/// in debug builds. Returns how many expenses were added.
class AddSampleData implements UseCase<int, NoParams> {
  AddSampleData(this._expenses, this._profiles, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const double sampleBudget = 125000;

  final ExpenseRepository _expenses;
  final DashboardRepository _profiles;
  final DateTime Function() _clock;

  @override
  Future<int> call(NoParams params) async {
    final samples = _samples(_clock());
    await Future.wait(samples.map(_expenses.saveExpense));
    final profile = await _profiles.getUserProfile();
    if (profile.monthlyBudget == null) {
      await _profiles.setMonthlyBudget(sampleBudget);
    }
    return samples.length;
  }

  static List<Expense> _samples(DateTime now) {
    final prev = DateTime(now.year, now.month - 1);

    DateTime daysAgo(int days, int hour) =>
        DateTime(now.year, now.month, now.day - days, hour);
    // Older entries stay in the current month, before the recent ones.
    DateTime thisMonth(int day) => DateTime(
      now.year,
      now.month,
      math.max(1, math.min(day, now.day - 4)),
      9,
    );
    DateTime lastMonth(int day) => DateTime(prev.year, prev.month, day, 12);
    // Stays on today even just after midnight.
    DateTime earlierToday(Duration ago) {
      final time = now.subtract(ago);
      return time.day == now.day
          ? time
          : DateTime(now.year, now.month, now.day);
    }

    Expense e(
      String title,
      double amount,
      ExpenseCategory category,
      DateTime date, [
      String? note,
    ]) => Expense(
      id: '',
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );

    const food = ExpenseCategory.food;
    const transport = ExpenseCategory.transport;
    const bills = ExpenseCategory.bills;
    const shopping = ExpenseCategory.shopping;
    const health = ExpenseCategory.health;
    const leisure = ExpenseCategory.leisure;

    return [
      // This month.
      e(
        'Weekly groceries',
        6480,
        food,
        earlierToday(const Duration(minutes: 40)),
        'Vegetables, rice, milk',
      ),
      e(
        'Ride to campus',
        1250,
        transport,
        earlierToday(const Duration(hours: 3)),
      ),
      e('Internet bill', 4990, bills, daysAgo(1, 19), 'Fibre 100 Mbps'),
      e('Movie night', 1400, leisure, daysAgo(1, 16)),
      e('Pharmacy', 1850, health, daysAgo(3, 11)),
      e('New sneakers', 7800, shopping, thisMonth(22)),
      e('Dinner with friends', 7420, food, thisMonth(20), 'Pizza place'),
      e('Fuel refill', 9600, transport, thisMonth(18)),
      e('Concert tickets', 1900, leisure, thisMonth(16)),
      e('Electricity bill', 8710, bills, thisMonth(14), 'CEB'),
      e('Dental checkup', 3350, health, thisMonth(12)),
      e('Supermarket run', 8200, food, thisMonth(10)),
      e('Monthly train pass', 6000, transport, thisMonth(7)),
      e('Water bill', 4500, bills, thisMonth(5)),
      e('Books & stationery', 4500, shopping, thisMonth(4)),
      e('Groceries', 6300, food, thisMonth(2)),

      // Last month.
      e('Groceries', 31200, food, lastMonth(25)),
      e('Utility bills', 19400, bills, lastMonth(20)),
      e('Transport', 18640, transport, lastMonth(15)),
      e('Clothing', 17500, shopping, lastMonth(10)),
      e('Doctor visit', 6000, health, lastMonth(8)),
      e('Miscellaneous', 3000, ExpenseCategory.other, lastMonth(3)),
    ];
  }
}
