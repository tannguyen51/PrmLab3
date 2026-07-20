import 'package:flutter/widgets.dart';

import 'app.dart';
import 'firebase/firebase_initializer.dart';
import 'services/analytics_service.dart';
import 'services/profile_firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  final analyticsService = AnalyticsService();
  await analyticsService.initialize();
  final profileService = ProfileFirebaseService();
  await profileService.setup();
  runApp(JournalTrendAnalyzerApp(
    analyticsService: analyticsService,
    profileService: profileService,
  ));
}
