import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  Future<void> initialize() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
    } catch (error) {
      debugPrint('Analytics initialization failed: $error');
    }
  }

  Future<void> setUserContext({String? userId, String? provider}) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        await _analytics.setUserId(id: userId);
      }
      if (provider != null && provider.isNotEmpty) {
        await _analytics.setUserProperty(
          name: 'auth_provider',
          value: provider,
        );
      }
    } catch (error) {
      debugPrint('Analytics user context update failed: $error');
    }
  }

  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    try {
      final safeParameters = <String, Object>{};
      parameters?.forEach((key, value) {
        if (value == null) {
          return;
        }
        if (value is String || value is num || value is bool) {
          safeParameters[key] = value;
        } else {
          safeParameters[key] = value.toString();
        }
      });

      await _analytics.logEvent(name: name, parameters: safeParameters);
      debugPrint('Analytics event sent: $name');
    } catch (error) {
      debugPrint('Failed to send analytics event $name: $error');
    }
  }

  Future<void> logLogin() async {
    await logEvent('login', parameters: {'method': 'google'});
  }

  Future<void> logLogout() async {
    await logEvent('logout', parameters: {'method': 'google'});
  }

  Future<void> logSearchTopic(String keyword) async {
    await logEvent('search_topic', parameters: {'keyword': keyword});
  }

  Future<void> logViewPublication(
    String publicationTitle,
    int? publicationYear,
  ) async {
    final parameters = <String, Object?>{'publication_title': publicationTitle};
    if (publicationYear != null) {
      parameters['publication_year'] = publicationYear;
    }

    await logEvent('view_publication', parameters: parameters);
  }

  Future<void> logViewJournal(String journalName) async {
    await logEvent('view_journal', parameters: {'journal_name': journalName});
  }

  Future<void> logViewKeyword(String keyword) async {
    await logEvent('view_keyword', parameters: {'keyword': keyword});
  }

  Future<void> logExportPdf(String topic) async {
    await logEvent('export_pdf', parameters: {'topic': topic});
  }
}
