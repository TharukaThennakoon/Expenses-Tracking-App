# Spendwise: Expense Tracker

A Flutter app for tracking day-to-day spending. Users sign in with email and
password, record expenses by category, set a monthly budget, and see where
their money goes. Each account's data is stored in Cloud Firestore.

- **Platform:** Android (the Firebase config is set up for Android only)
- **Flutter:** 3.44 (Dart 3.12)
- **Architecture:** clean architecture, organised by feature (data → domain → presentation)

---

## Project setup

### Prerequisites

- Flutter SDK 3.44 or newer (`flutter --version`)
- Android Studio with an Android SDK, plus an emulator or an Android phone with USB debugging on
- A Firebase project (the free Spark plan is enough)

### 1. Get the code and packages

```bash
git clone <repository-url>
cd expenses_tracking_app
flutter pub get
```

### 2. Connect Firebase

The app won't start without a Firebase project.

1. In the [Firebase console](https://console.firebase.google.com/), create a project.
2. **Add an Android app** with the package name `com.example.expenses_tracking_app`.
3. Download `google-services.json` and put it in `android/app/`.
4. **Authentication** → Get started → Sign-in method → enable **Email/Password**.
5. **Firestore Database** → Create database, in production mode.
6. In the Firestore **Rules** tab, paste in the contents of [`firestore.rules`](firestore.rules)
   and click **Publish**. These rules let each user read and write only their own data.

The Gradle side is already set up: the Google services plugin is declared in
`android/settings.gradle.kts` and applied in `android/app/build.gradle.kts`.

### 3. Run

```bash
flutter run
```

Adding a Firebase package changes native Android code, so after one is added,
stop the app completely and run `flutter run` again. Hot reload and hot
restart aren't enough.

### 4. Build an APK

```bash
flutter build apk --release
```

The APK is saved at `build/app/outputs/flutter-apk/app-release.apk`. Release
builds are currently signed with the debug key. That's fine for installing on
your own device, but you'll need a proper signing key before publishing to
Google Play.

### 5. Tests

```bash
flutter analyze
flutter test
```

The tests run against in-memory fakes in [`test/fakes/`](test/fakes/), so they
don't need Firebase or an internet connection.

> Known issue: the test *"Insights tab shows totals, shares and weekly bars"*
> expects a hard-coded week label (`22–27`), so it fails on most dates. It
> should be changed to work out the week from a fixed date.

---

## Features

### Accounts
- Sign up with full name, email and password, with checks on each field as you type and a password strength meter
- Sign in, sign out, and a password reset email from **Forgot password?**
- Stays signed in after the app restarts
- Firebase errors are shown as plain messages on the right field (for example, "An account with this email already exists")
- An auth wrapper after the splash screen shows Home or Sign in, and switches by itself when the user signs in or out

### Expenses
- Add, edit and delete expenses: amount, title, category, date and an optional note
- Checks each field as you go, with a summary of what still needs fixing
- Asks before closing a form with unsaved changes
- Delete from the edit screen, or swipe a row in History; both ask for confirmation

### Home (dashboard)
- Amount spent this month compared with the monthly budget, and with the previous month
- Switch months using the arrows or a month picker
- Spending broken down by category
- Most recent expenses

### History
- Expenses grouped by day ("Today", "Yesterday", …) with a total for each day
- Search by title or note
- Filters: date range (this month, last month, last 3 months or custom), categories, and sort order (newest, oldest, highest amount)

### Insights
- Total spent and budget left for the chosen month
- Category donut chart; tap a category to highlight it
- Weekly spending bars
- Choose which month to view

### Settings
- Edit your profile (name and email)
- Set, change or remove the monthly budget
- Manage categories: add your own or delete them. Expenses in a deleted category move to "Other", which can't be deleted
- Display currency (LKR by default, plus USD, EUR, GBP, INR, AUD, CAD, SGD and AED). This only changes the label; amounts are not converted
- Dark mode

### Data and reliability
- All data is stored in Cloud Firestore, per user:
  ```
  users/{uid}                  profile: firstName, lastName, email, monthlyBudget
  users/{uid}/expenses/{id}    title, amount, category, date, note, createdAt
  users/{uid}/categories/{id}  label, icon, color, order
  ```
- New accounts start with no expenses and the default categories
- Screens update live when data changes
- Loading placeholders, empty states, and error screens with a retry button

### Not built yet
- **Export to CSV** shows "coming soon"
- The chosen **currency** and **dark mode** setting reset when the app restarts
- An **Add sample data** button (22 example expenses) is written but commented out in `settings_page.dart`. Uncomment it to fill an account for demos

---

## Technologies and packages

| Package | Version | Used for |
|---|---|---|
| Flutter / Dart | 3.44 / 3.12 | UI framework and language |
| [`firebase_core`](https://pub.dev/packages/firebase_core) | ^4.15.0 | Starting Firebase |
| [`firebase_auth`](https://pub.dev/packages/firebase_auth) | ^6.7.0 | Email/password accounts and password reset |
| [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) | ^6.10.0 | Storing expenses, categories and the profile |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | ^1.0.8 | iOS-style icons |
| [`flutter_lints`](https://pub.dev/packages/flutter_lints) (dev) | ^6.0.0 | Lint rules |
| `flutter_test` (dev) | SDK | Unit and widget tests |

`firebase_analytics` and `provider` are listed in `pubspec.yaml` but aren't
used in the code yet.

**Tooling:** Google services Gradle plugin 4.5.0, Android Gradle Plugin 9.0.1,
Kotlin 2.3.20.

### How the code is organised

```
lib/
  app/        App widget and routes
  core/       Dependency injection, theme, currency, Firebase helpers, shared widgets
  features/
    auth/        Sign in, sign up, auth wrapper
    expenses/    Expense form, save/delete, sample data
    categories/  Category management
    dashboard/   Home screen and profile
    history/     History with search and filters
    insights/    Charts and monthly stats
    settings/    Settings screen
    shell/       Bottom navigation
    splash/      Splash screen
```

Each feature is split into three layers:
- **data:** data sources and models; Firestore in the app, in-memory in tests
- **domain:** entities, repository interfaces and use cases
- **presentation:** pages, widgets and `ChangeNotifier` controllers

The pieces are connected by hand in
[`lib/core/di/injection_container.dart`](lib/core/di/injection_container.dart),
without a dependency injection package.

---

## AI tools used

**Claude Code (Anthropic), in VS Code.** It was used for:
- Setting up Firebase: the Gradle plugin, `google-services.json`, and starting Firebase in `main.dart`
- The auth wrapper that chooses between Home and Sign in
- Moving sign-in from the in-memory mock to Firebase Authentication, including error messages and password reset
- Moving expenses, categories and the profile to Cloud Firestore, including per-user data, security rules and default categories
- Removing the dummy data from the app and moving it into test fakes
- Fixing a blank screen after the splash, caused by the auth check waiting on Firestore
- Adding the sample data feature
- Writing this README

All AI-generated changes were checked with `flutter analyze` and `flutter test`
before being kept.

<!-- Add any other AI tools you used (for example ChatGPT, Gemini or GitHub Copilot) and what you used them for. -->
