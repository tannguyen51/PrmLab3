import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/services/profile_firebase_service.dart';

void main() {
  group('ProfileFirebaseService', () {
    test(
      'parseConfiguredLimit uses valid values and fallback for invalid ones',
      () {
        expect(ProfileFirebaseService.parseConfiguredLimit('5', 4), 5);
        expect(ProfileFirebaseService.parseConfiguredLimit('6', 4), 6);
        expect(ProfileFirebaseService.parseConfiguredLimit('0', 4), 4);
        expect(ProfileFirebaseService.parseConfiguredLimit('', 4), 4);
        expect(ProfileFirebaseService.parseConfiguredLimit('abc', 4), 4);
      },
    );
  });
}
