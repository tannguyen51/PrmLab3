import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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

class ProfileFirebaseService {
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

  Future<List<String>> loadNotifications() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await _messaging.getToken();
        debugPrint('FCM token: $token');
      }
    } catch (_) {}

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
