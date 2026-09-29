import 'package:flutter/foundation.dart';

import '../currency/currency_controller.dart';
import '../firebase/user_data.dart';
import '../theme/theme_controller.dart';
import '../usecase/usecase.dart';
import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/datasources/firebase_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/controllers/auth_form_controller.dart';
import '../../features/categories/data/datasources/category_firestore_data_source.dart';
import '../../features/categories/data/datasources/category_data_source.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/category_usecases.dart';
import '../../features/categories/presentation/controllers/categories_controller.dart';
import '../../features/dashboard/data/datasources/dashboard_firestore_data_source.dart';
import '../../features/dashboard/data/datasources/dashboard_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/budget_usecases.dart';
import '../../features/dashboard/domain/usecases/get_monthly_summary.dart';
import '../../features/dashboard/domain/usecases/get_recent_expenses.dart';
import '../../features/dashboard/domain/usecases/get_user_profile.dart';
import '../../features/dashboard/domain/usecases/update_profile.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/expenses/data/datasources/expense_firestore_data_source.dart';
import '../../features/expenses/data/datasources/expense_data_source.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/save_expense.dart';
import '../../features/expenses/domain/usecases/add_sample_data.dart';
import '../../features/expenses/domain/usecases/delete_expense.dart';
import '../../features/expenses/domain/usecases/watch_expense_changes.dart';
import '../../features/expenses/presentation/controllers/expense_form_controller.dart';
import '../../features/history/domain/usecases/get_expense_history.dart';
import '../../features/insights/domain/usecases/get_monthly_insights.dart';
import '../../features/insights/presentation/controllers/insights_controller.dart';
import '../../features/history/presentation/controllers/history_controller.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';

/// Simple manual dependency injection. Wires data -> domain -> presentation.
class InjectionContainer {
  InjectionContainer._({
    required AuthDataSource auth,
    required CategoryDataSource categories,
    required ExpenseDataSource expenses,
    required DashboardDataSource profile,
  }) : _authDataSource = auth,
       _categoryDataSource = categories,
       _expenseDataSource = expenses,
       _profileDataSource = profile;

  /// Firebase Auth for accounts; Firestore for everything else.
  factory InjectionContainer._firebase() {
    final userData = UserData();
    return InjectionContainer._(
      auth: FirebaseAuthDataSource(),
      categories: CategoryFirestoreDataSource(userData),
      expenses: ExpenseFirestoreDataSource(userData),
      profile: DashboardFirestoreDataSource(userData),
    );
  }

  static InjectionContainer _instance = InjectionContainer._firebase();

  static InjectionContainer get instance => _instance;

  /// Fresh container on the given data sources, so tests don't share state
  /// or need Firebase.
  @visibleForTesting
  static void useDataSources({
    required AuthDataSource auth,
    required CategoryDataSource categories,
    required ExpenseDataSource expenses,
    required DashboardDataSource profile,
  }) => _instance = InjectionContainer._(
    auth: auth,
    categories: categories,
    expenses: expenses,
    profile: profile,
  );

  final AuthDataSource _authDataSource;
  final CategoryDataSource _categoryDataSource;
  final ExpenseDataSource _expenseDataSource;
  final DashboardDataSource _profileDataSource;

  // ------------------------------------------------------------------- Theme
  /// App-wide; lives as long as the app.
  late final ThemeController themeController = ThemeController();

  /// App-wide display currency.
  late final CurrencyController currencyController = CurrencyController();

  // -------------------------------------------------------------------- Auth
  late final AuthRepository _authRepository = AuthRepositoryImpl(
    _authDataSource,
  );

  /// Drives [AuthWrapper]: Home when signed in, Sign in otherwise.
  Stream<AuthUser?> watchCurrentUser() =>
      WatchCurrentUser(_authRepository, _dashboardRepository)(const NoParams());

  // -------------------------------------------------------------- Categories
  late final CategoryRepository _categoryRepository = CategoryRepositoryImpl(
    _categoryDataSource,
  );

  /// App-wide; screens read it through [CategoriesScope].
  late final CategoriesController categoriesController = CategoriesController(
    getCategories: GetCategories(_categoryRepository),
    addCategory: AddCategory(_categoryRepository),
    deleteCategory: DeleteCategory(_categoryRepository, _expenseRepository),
    watchCategoryChanges: WatchCategoryChanges(_categoryRepository),
  );

  // ---------------------------------------------------------------- Expenses
  late final ExpenseRepository _expenseRepository = ExpenseRepositoryImpl(
    _expenseDataSource,
    _categoryRepository,
  );

  late final SaveExpense _saveExpense = SaveExpense(_expenseRepository);
  late final DeleteExpense _deleteExpense = DeleteExpense(_expenseRepository);
  late final WatchExpenseChanges _watchExpenseChanges = WatchExpenseChanges(
    _expenseRepository,
  );

  // --------------------------------------------------------------- Dashboard
  late final DashboardRepository _dashboardRepository = DashboardRepositoryImpl(
    _profileDataSource,
    _expenseRepository,
  );

  late final GetUserProfile _getUserProfile = GetUserProfile(
    _dashboardRepository,
  );
  late final GetMonthlySummary _getMonthlySummary = GetMonthlySummary(
    _dashboardRepository,
  );
  late final GetRecentExpenses _getRecentExpenses = GetRecentExpenses(
    _dashboardRepository,
  );
  late final SetMonthlyBudget _setMonthlyBudget = SetMonthlyBudget(
    _dashboardRepository,
  );
  late final WatchProfileChanges _watchProfileChanges = WatchProfileChanges(
    _dashboardRepository,
  );

  // ----------------------------------------------------------------- History
  late final GetExpenseHistory _getExpenseHistory = GetExpenseHistory(
    _expenseRepository,
  );

  // ---------------------------------------------------------------- Insights
  late final GetMonthlyInsights _getMonthlyInsights = GetMonthlyInsights(
    _dashboardRepository,
    _expenseRepository,
  );

  // ------------------------------------------------------------ Controllers
  // New instance per screen; the caller disposes it.

  DashboardController dashboardController() => DashboardController(
    getUserProfile: _getUserProfile,
    getMonthlySummary: _getMonthlySummary,
    getRecentExpenses: _getRecentExpenses,
    watchExpenseChanges: _watchExpenseChanges,
    watchProfileChanges: _watchProfileChanges,
  );

  ExpenseFormController expenseFormController([Expense? expense]) =>
      ExpenseFormController(
        saveExpense: _saveExpense,
        deleteExpense: _deleteExpense,
        initial: expense,
      );

  InsightsController insightsController() => InsightsController(
    getMonthlyInsights: _getMonthlyInsights,
    watchExpenseChanges: _watchExpenseChanges,
    watchProfileChanges: _watchProfileChanges,
  );

  HistoryController historyController() => HistoryController(
    getExpenseHistory: _getExpenseHistory,
    deleteExpense: _deleteExpense,
    watchExpenseChanges: _watchExpenseChanges,
  );

  SignInController signInController() => SignInController(
    signIn: SignIn(_authRepository, _dashboardRepository),
    sendPasswordReset: SendPasswordReset(_authRepository),
  );

  SignUpController signUpController() =>
      SignUpController(signUp: SignUp(_authRepository, _dashboardRepository));

  SettingsController settingsController() => SettingsController(
    getUserProfile: _getUserProfile,
    setMonthlyBudget: _setMonthlyBudget,
    updateProfile: UpdateProfile(_dashboardRepository),
    signOut: SignOut(_authRepository),
    watchProfileChanges: _watchProfileChanges,
    themeController: themeController,
    currencyController: currencyController,
    // Example data is for trying the app out, never for real users.
    addSampleData: kDebugMode
        ? AddSampleData(_expenseRepository, _dashboardRepository)
        : null,
  );
}
