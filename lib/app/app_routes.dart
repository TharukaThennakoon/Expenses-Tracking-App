import 'package:flutter/material.dart';

import '../core/di/injection_container.dart';
import '../features/auth/presentation/pages/auth_wrapper.dart';
import '../features/auth/presentation/pages/sign_in_page.dart';
import '../features/auth/presentation/pages/sign_up_page.dart';
import '../features/categories/presentation/pages/categories_page.dart';
import '../features/expenses/domain/entities/expense.dart';
import '../features/expenses/presentation/expense_form_result.dart';
import '../features/expenses/presentation/pages/expense_form_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

abstract final class AppRoutes {
  static const String splash = '/';

  /// Home or Sign in, whichever fits; see [AuthWrapper].
  static const String authWrapper = '/auth';

  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  /// Argument: the [Expense] to edit, or null for a new one.
  /// Result: an [ExpenseFormResult], or null if cancelled.
  static const String expenseForm = '/expense';

  static const String categories = '/categories';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      authWrapper => _fade(
        AuthWrapper(authState: InjectionContainer.instance.watchCurrentUser()),
        settings,
      ),
      signIn => _fade(
        SignInPage(controller: InjectionContainer.instance.signInController()),
        settings,
      ),
      signUp => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => SignUpPage(
          controller: InjectionContainer.instance.signUpController(),
        ),
      ),
      expenseForm => MaterialPageRoute<ExpenseFormResult>(
        fullscreenDialog: true,
        settings: settings,
        builder: (_) =>
            ExpenseFormPage(expense: settings.arguments as Expense?),
      ),
      categories => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => CategoriesPage(
          controller: InjectionContainer.instance.categoriesController,
        ),
      ),
      _ => MaterialPageRoute(
        builder: (_) => const SplashPage(),
        settings: settings,
      ),
    };
  }

  /// Opens the expense form; returns what happened, or null if cancelled.
  static Future<ExpenseFormResult?> openExpenseForm(
    BuildContext context, {
    Expense? expense,
  }) => Navigator.of(
    context,
  ).pushNamed<ExpenseFormResult>(expenseForm, arguments: expense);

  /// Closes everything above [AuthWrapper], which has already switched to
  /// Home (after signing in) or Sign in (after signing out).
  static void backToAuthWrapper(BuildContext context) =>
      Navigator.of(context).popUntil((route) => route.isFirst);

  static Route<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
