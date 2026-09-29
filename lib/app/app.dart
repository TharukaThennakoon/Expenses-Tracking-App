import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../core/currency/currency_controller.dart';
import '../core/di/injection_container.dart';
import '../core/theme/app_theme.dart';
import '../features/categories/presentation/controllers/categories_controller.dart';
import 'app_routes.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final di = InjectionContainer.instance;
    final themeController = di.themeController;
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.mode,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        // Status bar icons follow the theme (screens can still override).
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: CurrencyScope(
            controller: di.currencyController,
            child: CategoriesScope(
              controller: di.categoriesController,
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}
