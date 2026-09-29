import 'package:expenses_tracking_app/core/di/injection_container.dart';

import 'in_memory_auth_data_source.dart';
import 'in_memory_category_data_source.dart';
import 'in_memory_dashboard_data_source.dart';
import 'in_memory_expense_data_source.dart';

/// Points the app at fresh in-memory data (with sample expenses and a demo
/// account) instead of Firebase.
void useInMemoryData() => InjectionContainer.useDataSources(
  auth: InMemoryAuthDataSource(),
  categories: InMemoryCategoryDataSource(),
  expenses: InMemoryExpenseDataSource(),
  profile: InMemoryDashboardDataSource(),
);
