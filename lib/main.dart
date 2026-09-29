import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reads config from android/app/google-services.json via the Gradle plugin.
  await Firebase.initializeApp();
  runApp(const ExpenseTrackerApp());
}
