import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  Future<void> logLogin() async {
    await _analytics.logLogin();
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  Future<void> logSearchTopic(String keyword) async {
    await _analytics.logEvent(
      name: 'search_topic',
      parameters: {'keyword': keyword},
    );
  }

  Future<void> logViewPublication(
    String publicationTitle,
    int? publicationYear,
  ) async {
    final parameters = <String, Object>{'publication_title': publicationTitle};
    if (publicationYear != null) {
      parameters['publication_year'] = publicationYear;
    }

    await _analytics.logEvent(name: 'view_publication', parameters: parameters);
  }

  Future<void> logViewJournal(String journalName) async {
    await _analytics.logEvent(
      name: 'view_journal',
      parameters: {'journal_name': journalName},
    );
  }

  Future<void> logViewKeyword(String keyword) async {
    await _analytics.logEvent(
      name: 'view_keyword',
      parameters: {'keyword': keyword},
    );
  }
}
