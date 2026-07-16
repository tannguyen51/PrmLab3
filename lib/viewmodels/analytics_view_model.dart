import 'package:flutter/foundation.dart';

import '../services/analytics_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  AnalyticsViewModel({AnalyticsService? analyticsService})
    : _analyticsService = analyticsService ?? AnalyticsService();

  final AnalyticsService _analyticsService;

  Future<void> logLogin() async {
    await _analyticsService.logLogin();
  }

  Future<void> logLogout() async {
    await _analyticsService.logLogout();
  }

  Future<void> logSearchTopic(String keyword) async {
    await _analyticsService.logSearchTopic(keyword);
  }

  Future<void> logViewPublication(String title, int? year) async {
    await _analyticsService.logViewPublication(title, year);
  }
}
