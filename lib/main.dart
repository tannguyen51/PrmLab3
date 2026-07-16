import 'package:flutter/widgets.dart';

import 'app.dart';
import 'firebase/firebase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  runApp(const JournalTrendAnalyzerApp());
}
