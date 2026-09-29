import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/app/app.dart';
import 'package:expenses_tracking_app/core/constants/app_constants.dart';
import 'package:expenses_tracking_app/core/utils/formatters.dart';

import 'fakes/in_memory_auth_data_source.dart';
import 'fakes/in_memory_data.dart';

/// Starts the app and waits for the splash to hand over to Sign in.
Future<void> _toSignIn(WidgetTester tester) async {
  useInMemoryData();
  await tester.pumpWidget(const ExpenseTrackerApp());
  expect(find.text(AppConstants.appName), findsOneWidget);
  await tester.pump(AppConstants.splashDuration);
  await tester.pumpAndSettle();
}

/// Starts the app and signs in with the demo account.
Future<void> _pastSplash(WidgetTester tester) async {
  await _toSignIn(tester);
  await tester.enterText(
    find.byType(TextField).at(0),
    InMemoryAuthDataSource.demoEmail,
  );
  await tester.enterText(
    find.byType(TextField).at(1),
    InMemoryAuthDataSource.demoPassword,
  );
  await tester.tap(find.text('Sign in'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Splash goes to Sign in; wrong password is rejected', (
    tester,
  ) async {
    _usePhoneSize(tester);
    await _toSignIn(tester);
    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'john@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect email or password'), findsOneWidget);
    expect(find.text('Spent this month'), findsNothing);
  });

  testWidgets('Signs up, lands on Home, then signs out', (tester) async {
    _usePhoneSize(tester);
    await _toSignIn(tester);
    await tester.tap(
      find.textContaining('Create an account', findRichText: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);

    Finder field(int i) => find.byType(TextField).at(i);
    await tester.enterText(field(0), 'Ama Silva');
    await tester.enterText(field(1), 'john@example.com'); // already taken
    await tester.enterText(field(2), 'Sunny-Day-2026');
    await tester.pump();
    expect(find.text('Strong'), findsOneWidget);
    await tester.enterText(field(3), 'Sunny-Day');
    await tester.pump();
    expect(find.text('Passwords don’t match'), findsOneWidget);
    await tester.enterText(field(3), 'Sunny-Day-2026');
    await tester.pump();
    expect(find.text('Passwords don’t match'), findsNothing);

    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(
      find.text('An account with this email already exists'),
      findsOneWidget,
    );

    await tester.enterText(field(1), 'ama@example.com');
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Ama'), findsOneWidget); // Home greeting

    // Sign out from Settings returns to Sign in; Back can't return Home.
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Ama Silva'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sign out'), 100);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);

    // The new account works for signing back in.
    await tester.enterText(field(0), 'ama@example.com');
    await tester.enterText(field(1), 'Sunny-Day-2026');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Ama'), findsOneWidget);
  });

  testWidgets('Splash screen navigates to the dashboard', (tester) async {
    await _pastSplash(tester);

    expect(find.text('John'), findsOneWidget);
    expect(find.text('By category'), findsOneWidget);
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Weekly groceries'), findsOneWidget);
  });

  testWidgets('History tab shows grouped expenses and supports search', (
    tester,
  ) async {
    await _pastSplash(tester);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Today ·', findRichText: true), findsOneWidget);
    expect(
      find.textContaining('Yesterday ·', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Movie night'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'fibre');
    await tester.pumpAndSettle();

    expect(find.text('Internet bill'), findsWidgets);
    expect(find.text('Movie night'), findsNothing);
  });

  testWidgets('New expense shows live validation, then saves', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('New expense'), findsOneWidget);

    // Nothing filled in: three field errors and a summary banner.
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount greater than 0'), findsOneWidget);
    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Pick a category'), findsOneWidget);
    expect(find.text('Fix 3 fields to save this expense'), findsOneWidget);

    // Errors clear as each field is fixed.
    await tester.enterText(find.byType(TextField).at(0), '2450');
    await tester.pumpAndSettle();
    expect(find.text('Fix 2 fields to save this expense'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'Lunch with team');
    await tester.pumpAndSettle();
    expect(find.text('Title is required'), findsNothing);
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fix '), findsNothing);

    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    expect(find.text('New expense'), findsNothing);
    expect(find.text('Lunch with team'), findsOneWidget);
    expect(find.text('LKR 2,450.00'), findsOneWidget);
  });

  testWidgets('Edits an expense from History', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    await tester.drag(find.text('Weekly groceries'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Edit expense'), findsOneWidget);
    expect(find.text('6,480.00'), findsOneWidget);
    expect(find.textContaining('Added '), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), 'Big grocery run');
    // Category opens a picker sheet in edit mode.
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shopping'));
    await tester.pumpAndSettle();
    expect(find.text('Shopping'), findsOneWidget);

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Big grocery run'), findsOneWidget);
    expect(find.textContaining('Shopping · Vegetables'), findsOneWidget);
    expect(find.text('Changes saved'), findsOneWidget);
  });

  testWidgets('Deletes from the edit screen after confirming', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    await tester.drag(find.text('Ride to campus'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit').hitTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete expense'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this expense?'), findsOneWidget);

    // Cancel keeps it.
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(find.text('Edit expense'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Edit expense'), findsNothing);
    expect(find.text('Ride to campus'), findsNothing);
    expect(find.text('"Ride to campus" deleted'), findsOneWidget);
  });

  testWidgets('Swipe delete asks for confirmation', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    await tester.drag(find.text('Internet bill'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Delete this expense?'), findsOneWidget);
    expect(find.text('LKR 4,990.00'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Internet bill'), findsNothing);
  });

  testWidgets('Tapping a History row opens it for editing', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    // A tap on a row whose actions are open just closes them.
    await tester.drag(find.text('Movie night'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1,400.00')); // still visible when open
    await tester.pumpAndSettle();
    expect(find.text('Edit expense'), findsNothing);
    expect(find.text('Delete').hitTestable(), findsNothing);

    // A plain tap opens the edit screen with the expense filled in.
    await tester.tap(find.text('Movie night'));
    await tester.pumpAndSettle();
    expect(find.text('Edit expense'), findsOneWidget);
    expect(find.text('1,400.00'), findsOneWidget);
    expect(find.text('Leisure'), findsOneWidget);
  });

  testWidgets('Tapping a Home row opens it; deleting updates Home', (
    tester,
  ) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);

    await tester.tap(find.text('Weekly groceries'));
    await tester.pumpAndSettle();
    expect(find.text('Edit expense'), findsOneWidget);
    expect(find.text('Vegetables, rice, milk'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Edit expense'), findsNothing);
    expect(find.text('Weekly groceries'), findsNothing);
    expect(find.text('"Weekly groceries" deleted'), findsOneWidget);
  });

  testWidgets('Insights tab shows totals, shares and weekly bars', (
    tester,
  ) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);

    await tester.tap(find.text('Insights').last);
    await tester.pumpAndSettle();

    expect(find.text('Total spent'), findsOneWidget);
    expect(find.text('84,250'), findsOneWidget);
    expect(find.text('Budget left'), findsOneWidget);
    expect(find.text('40,750'), findsOneWidget);
    expect(find.text('Where it went'), findsOneWidget);
    expect(find.text('34%'), findsOneWidget);
    expect(find.text('6 cats'), findsOneWidget);

    // Tapping a legend row highlights that category in the centre.
    await tester.tap(find.text('Bills').last);
    await tester.pumpAndSettle();
    expect(find.text('18,200'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Weekly spending'), 100);
    expect(find.text('Weekly spending'), findsOneWidget);
    expect(find.text('22–27'), findsOneWidget);

    // Switching month updates the numbers.
    await tester.tap(find.text('September 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('August 2026'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Total spent'), -100);
    expect(find.text('95,740'), findsOneWidget);
    expect(find.text('Month ended'), findsOneWidget);
  });

  testWidgets('Settings tab shows profile and preferences', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('John Nethmina'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
    expect(find.text('LKR'), findsOneWidget);
    expect(find.text('125,000'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Export to CSV'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);

    Brightness brightness() =>
        Theme.of(tester.element(find.text('Dark mode'))).brightness;

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(brightness(), Brightness.light);

    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(brightness(), Brightness.dark);

    // Other tabs follow too.
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('John'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.light);
  });

  testWidgets('Changing currency relabels amounts across the app', (
    tester,
  ) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);
    expect(find.text('LKR 6,480.00'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();
    expect(find.text('US dollar'), findsOneWidget);

    await tester.tap(find.text('US dollar'));
    await tester.pumpAndSettle();
    expect(find.text('US dollar'), findsNothing); // sheet closed
    expect(find.text('USD'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('USD 6,480.00'), findsOneWidget);
    expect(find.text('LKR 6,480.00'), findsNothing);

    // The amount is unchanged, only relabelled.
    await tester.tap(find.text('Weekly groceries'));
    await tester.pumpAndSettle();
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('6,480.00'), findsOneWidget);
  });

  testWidgets('Sets, changes and removes the monthly budget', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('125,000'), findsOneWidget);

    await tester.tap(find.text('Monthly budget'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.text('Save budget'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount greater than 0'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '90000');
    await tester.tap(find.text('Save budget'));
    await tester.pumpAndSettle();
    expect(find.text('90,000'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('LKR 90,000', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monthly budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove budget'));
    await tester.pumpAndSettle();
    expect(find.text('Not set'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No budget set', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('Adds and deletes categories from Settings', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget);

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete Other'), findsNothing); // fallback stays

    // Add "Rent"; a duplicate name is rejected first.
    await tester.tap(find.text('Add category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'food');
    await tester.tap(find.widgetWithText(FilledButton, 'Add category').last);
    await tester.pumpAndSettle();
    expect(find.text('You already have "food"'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Rent');
    await tester.tap(find.widgetWithText(FilledButton, 'Add category').last);
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsOneWidget);

    // Delete "Food" after confirming.
    await tester.tap(find.byTooltip('Delete Food'));
    await tester.pumpAndSettle();
    expect(find.text('Delete "Food"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete Food'), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget); // 7 - Food + Rent

    // The new list is what the expense form offers.
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });

  testWidgets('Edits the profile name from Settings', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('John Nethmina'));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsOneWidget);

    // Invalid input shows field errors and keeps the sheet open.
    await tester.enterText(find.byType(TextField).at(0), '  ');
    await tester.enterText(find.byType(TextField).at(2), 'not-an-email');
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();
    expect(find.text('First name is required'), findsOneWidget);
    expect(find.text('Enter a valid email'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Tharuka');
    await tester.enterText(find.byType(TextField).at(1), 'Perera');
    await tester.enterText(find.byType(TextField).at(2), 'tharuka@example.com');
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();

    expect(find.text('Edit profile'), findsNothing);
    expect(find.text('Tharuka Perera'), findsOneWidget);
    expect(find.text('tharuka@example.com'), findsOneWidget);
    expect(find.text('TP'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Tharuka'), findsOneWidget);
    expect(find.text('John'), findsNothing);
  });

  testWidgets('Home card changes month by picker and arrows', (tester) async {
    _usePhoneSize(tester);
    await _pastSplash(tester);

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final twoAgo = DateTime(now.year, now.month - 2);
    final oneAgo = DateTime(now.year, now.month - 1);

    expect(find.text('Spent this month'), findsOneWidget);
    // Can't go past the current month.
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text(Formatters.monthYear(thisMonth)), findsOneWidget);

    // Pick a month from the list.
    await tester.tap(find.text(Formatters.monthYear(thisMonth)));
    await tester.pumpAndSettle();
    expect(find.text('Choose month'), findsOneWidget);
    await tester.tap(find.text(Formatters.monthYear(twoAgo)));
    await tester.pumpAndSettle();
    expect(find.text('Choose month'), findsNothing);
    expect(find.text(Formatters.monthYear(twoAgo)), findsOneWidget);
    expect(
      find.text('Spent in ${Formatters.monthName(twoAgo)}'),
      findsOneWidget,
    );

    // Arrows step one month at a time.
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text(Formatters.monthYear(oneAgo)), findsOneWidget);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text(Formatters.monthYear(twoAgo)), findsOneWidget);
  });

  testWidgets('Closing a dirty form asks before discarding', (tester) async {
    await _pastSplash(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), 'Coffee');
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('New expense'), findsNothing);
    expect(find.text('Coffee'), findsNothing);
  });
}

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}
