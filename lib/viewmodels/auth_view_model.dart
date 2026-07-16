import 'package:flutter/foundation.dart';

import '../services/analytics_service.dart';
import '../services/firebase_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    FirebaseAuthService? authService,
    AnalyticsService? analyticsService,
  }) : _authService = authService ?? FirebaseAuthService(),
       _analyticsService = analyticsService;

  final FirebaseAuthService _authService;
  final AnalyticsService? _analyticsService;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authService.currentUser != null;

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await _analyticsService?.setUserContext(
          userId: user.uid,
          provider: 'google',
        );
        await _analyticsService?.logLogin();
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      await _analyticsService?.logLogout();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
