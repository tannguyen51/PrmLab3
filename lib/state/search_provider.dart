import 'package:flutter/foundation.dart';

import '../models/publication.dart';
import '../services/analytics_service.dart';
import '../services/publication_repository.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider({
    PublicationRepository? repository,
    AnalyticsService? analyticsService,
  }) : _repository = repository,
       _analyticsService = analyticsService;

  PublicationRepository? _repository;
  AnalyticsService? _analyticsService;

  bool _isLoading = false;
  String? _errorMessage;
  String _currentTopic = '';
  List<Publication> _publications = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentTopic => _currentTopic;
  List<Publication> get publications => _publications;
  bool get hasSearched => _currentTopic.isNotEmpty;

  set repository(PublicationRepository repository) {
    _repository = repository;
  }

  set analyticsService(AnalyticsService analyticsService) {
    _analyticsService = analyticsService;
  }

  Future<void> search(String topic) async {
    final repository = _repository;
    if (repository == null) {
      _errorMessage = 'Search service is not available.';
      notifyListeners();
      return;
    }

    if (_isLoading) return;

    _currentTopic = topic.trim();
    if (_currentTopic.isEmpty) {
      _publications = const [];
      _errorMessage = 'Please enter a research topic.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _analyticsService?.logSearchTopic(_currentTopic);
      _publications = await repository.searchByTopic(_currentTopic);
    } catch (error) {
      _publications = const [];
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
