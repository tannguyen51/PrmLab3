import 'package:flutter/widgets.dart';

import 'app.dart';
import 'firebase/firebase_initializer.dart';
import 'services/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  await AnalyticsService().initialize();
  runApp(const JournalTrendAnalyzerApp());
}
