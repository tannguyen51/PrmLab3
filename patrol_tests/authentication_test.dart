import 'package:patrol/patrol.dart';

/// Test Case 1 – Google Sign-In
///
/// Launches the application, performs Google Sign-In, and verifies
/// successful navigation to the Home screen.
void main() {
  patrolTest(
    'Google Sign-In flow',
    ($) async {
      // The app should show the login screen
      await $('Continue with Google').waitUntilVisible();
      await $('Continue with Google').tap();

      // After successful sign-in, the bottom navigation bar with Home tab
      // should be visible
      await $('Home').waitUntilVisible();
    },
  );
}
