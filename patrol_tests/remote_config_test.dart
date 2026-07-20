import 'package:patrol/patrol.dart';

/// Test Case 10 – Remote Config
///
/// Retrieves Remote Config values and verifies configuration
/// values are displayed.
void main() {
  patrolTest(
    'Remote Config values are displayed',
    ($) async {
      // Navigate to Profile tab
      await $('Profile').tap();
      await $('Remote Config Demo').waitUntilVisible();

      // Verify Remote Config section and its values
      await $('max_journals').waitUntilVisible();
      await $('max_keywords').waitUntilVisible();
    },
  );
}
