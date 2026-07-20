import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Top-level background FCM handler — must be a global function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notification = message.notification;
  debugPrint(
    'Background FCM: ${notification?.title ?? 'No title'}: ${notification?.body ?? 'No body'}',
  );
}

class ProfileFirebaseResult {
  const ProfileFirebaseResult({
    required this.success,
    required this.message,
    this.url,
  });

  final bool success;
  final String message;
  final String? url;
}

class ProfileFirebaseService extends ChangeNotifier {
  ProfileFirebaseService({
    FirebaseStorage? storage,
    FirebaseRemoteConfig? remoteConfig,
    FirebaseCrashlytics? crashlytics,
    FirebaseMessaging? messaging,
  }) : _storage = storage ?? FirebaseStorage.instance,
       _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance,
       _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
       _messaging = messaging ?? FirebaseMessaging.instance;

  static int parseConfiguredLimit(String? value, int fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return fallback;
    }

    return parsed;
  }

  final FirebaseStorage _storage;
  final FirebaseRemoteConfig _remoteConfig;
  final FirebaseCrashlytics _crashlytics;
  final FirebaseMessaging _messaging;

  final List<String> _notificationMessages = [];
  String? _fcmToken;

  List<String> get notificationMessages => List.unmodifiable(_notificationMessages);
  String? get fcmToken => _fcmToken;

  Future<void> setup() async {
    try {
      // Register background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        _fcmToken = await _messaging.getToken();
        debugPrint('FCM token: $_fcmToken');
      }

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen(_handleMessage);

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        debugPrint('FCM token refreshed: $token');
      });
    } catch (error) {
      debugPrint('FCM setup failed: $error');
    }
  }

  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final text = notification?.title != null
        ? '${notification!.title}${notification.body != null ? ': ${notification.body}' : ''}'
        : 'New notification received';
    _notificationMessages.insert(0, text);
    notifyListeners();
  }

  Future<List<String>> loadNotifications() async {
    if (_notificationMessages.isNotEmpty) return _notificationMessages;

    // Return sample notifications if no real ones arrived yet
    return const [
      'New trending research topic.',
      'Highly cited publication alert.',
      'Research trend updates.',
    ];
  }

  Future<Map<String, String>> loadRemoteConfigValues() async {
    try {
      await _remoteConfig.setDefaults({
        'max_journals': '4',
        'max_keywords': '4',
      });
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (error) {
      debugPrint('Remote config load failed: $error');
    }

    return {
      'max_journals': _remoteConfig.getString('max_journals').isNotEmpty
          ? _remoteConfig.getString('max_journals')
          : '4',
      'max_keywords': _remoteConfig.getString('max_keywords').isNotEmpty
          ? _remoteConfig.getString('max_keywords')
          : '4',
    };
  }

  Future<ProfileFirebaseResult> exportPdfReport(List<int> pdfBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/journal_trend_report_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Try Firebase Storage upload (requires Blaze plan — may fail)
      String? uploadedUrl;
      try {
        final ref = _storage.ref().child(
          'reports/journal_trend_report_$timestamp.pdf',
        );
        final uploadTask = await ref.putFile(file);
        uploadedUrl = await uploadTask.ref.getDownloadURL();
      } catch (_) {
        // Storage upload failed (likely need Blaze plan) — use local path
      }

      return ProfileFirebaseResult(
        success: true,
        message: uploadedUrl != null
            ? 'Report uploaded successfully.'
            : 'Report saved locally at:\n$filePath',
        url: uploadedUrl ?? filePath,
      );
    } catch (error) {
      return ProfileFirebaseResult(
        success: false,
        message: 'Unable to export the report. $error',
      );
    }
  }

  @Deprecated('Use exportPdfReport instead')
  Future<ProfileFirebaseResult> exportAndUploadReport(String reportText) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/journal_trend_report.txt');
      await file.writeAsString(reportText);

      final ref = _storage.ref().child(
        'reports/journal_trend_report_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return ProfileFirebaseResult(
        success: true,
        message: 'Report uploaded successfully.',
        url: downloadUrl,
      );
    } catch (error) {
      return ProfileFirebaseResult(
        success: false,
        message: 'Unable to upload the report right now. $error',
      );
    }
  }

  Future<void> generateHandledException() async {
    try {
      throw StateError('Handled profile demo exception');
    } catch (error, stackTrace) {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: 'Profile demo handled exception',
      );
    }
  }

  Future<void> generateTestCrash() async {
    _crashlytics.crash();
  }
}
