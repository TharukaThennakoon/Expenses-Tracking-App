import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/app/app_routes.dart';
import 'package:expenses_tracking_app/core/di/injection_container.dart';
import 'package:expenses_tracking_app/core/error/app_exception.dart';
import 'package:expenses_tracking_app/core/widgets/error_state_view.dart';
import 'package:expenses_tracking_app/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expenses_tracking_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expenses_tracking_app/features/dashboard/presentation/widgets/dashboard_skeleton.dart';
import 'package:expenses_tracking_app/features/expenses/data/datasources/expense_data_source.dart';
import 'package:expenses_tracking_app/features/expenses/data/models/expense_model.dart';
import 'package:expenses_tracking_app/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/domain/usecases/delete_expense.dart';
import 'package:expenses_tracking_app/features/expenses/domain/usecases/watch_expense_changes.dart';
import 'package:expenses_tracking_app/features/history/domain/usecases/get_expense_history.dart';
import 'package:expenses_tracking_app/features/history/presentation/controllers/history_controller.dart';
import 'package:expenses_tracking_app/features/history/presentation/pages/history_page.dart';

import '../fakes/in_memory_category_data_source.dart';
import '../fakes/in_memory_data.dart';

/// Data source that is empty, or fails with [error] while it is set.
class _FakeExpenseSource implements ExpenseDataSource {
  Object? error;

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    if (error case final e?) throw e;
    return [];
  }

  @override
  Future<ExpenseModel> saveExpense(ExpenseModel expense) async => expense;

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<void> reassignCategory(String fromId, String toId) async {}

  @override
  Stream<void> get changes => const Stream.empty();
}

HistoryController _historyController(_FakeExpenseSource source) {
  final repository = ExpenseRepositoryImpl(
    source,
    CategoryRepositoryImpl(InMemoryCategoryDataSource()),
  );
  return HistoryController(
    getExpenseHistory: GetExpenseHistory(repository),
    deleteExpense: DeleteExpense(repository),
    watchExpenseChanges: WatchExpenseChanges(repository),
    clock: () => DateTime(2026, 9, 28),
  );
}

Widget _host(Widget child) => MaterialApp(
  onGenerateRoute: AppRoutes.onGenerateRoute,
  home: Scaffold(body: child),
);

void main() {
  setUp(useInMemoryData);

  testWidgets('Dashboard shows a skeleton until data arrives', (tester) async {
    final controller = InjectionContainer.instance.dashboardController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(DashboardPage(controller: controller)));
    expect(find.byType(DashboardSkeleton), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(DashboardSkeleton), findsNothing);
    expect(find.text('John'), findsOneWidget);
  });

  testWidgets('History shows the empty state and can add an expense', (
    tester,
  ) async {
    final controller = _historyController(_FakeExpenseSource());
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(HistoryPage(controller: controller)));
    await tester.pumpAndSettle();

    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.byType(TextField), findsNothing); // no search when empty

    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    expect(find.text('New expense'), findsOneWidget);
  });

  testWidgets('Offline error shows the banner, code and retries', (
    tester,
  ) async {
    final source = _FakeExpenseSource()..error = const NetworkException();
    final controller = _historyController(source);
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(HistoryPage(controller: controller)));
    await tester.pumpAndSettle();

    expect(find.text('Couldn’t load your expenses'), findsOneWidget);
    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.text('Error code: unavailable'), findsOneWidget);

    source.error = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorStateView), findsNothing);
    expect(find.text('No expenses yet'), findsOneWidget);
  });

  testWidgets('Unknown errors skip the offline banner and code', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        ErrorStateView(
          title: 'Couldn’t load your expenses',
          error: StateError('boom'),
          onRetry: () {},
        ),
      ),
    );

    expect(find.byType(OfflineBanner), findsNothing);
    expect(find.textContaining('Error code'), findsNothing);
    expect(find.textContaining('Something went wrong'), findsOneWidget);
  });
}
