import 'package:patrol/patrol.dart';

/// Test Case 8 – Profile Navigation
///
/// Navigates to the Profile tab and verifies user profile
/// information is displayed.
///
/// Test Case 11 – Logout
///
/// Performs logout and verifies redirection to the Login screen.
void main() {
  patrolTest(
    'Navigate to Profile tab and verify user info',
    ($) async {
      // Navigate to Profile tab via bottom nav
      await $('Profile').tap();
      await $('Profile').waitUntilVisible();

      // Verify profile elements are displayed
      await $('Current research snapshot').waitUntilVisible();
      await $('Sign Out').waitUntilVisible();
      await $('Notification Center').waitUntilVisible();
      await $('Remote Config Demo').waitUntilVisible();
      await $('Crashlytics Demo').waitUntilVisible();
    },
  );

  patrolTest(
    'Logout redirects to login screen',
    ($) async {
      // Navigate to Profile tab
      await $('Profile').tap();
      await $('Sign Out').waitUntilVisible();

      // Tap Sign Out button
      await $('Sign Out').tap();

      // Verify redirect to login screen
      await $('Continue with Google').waitUntilVisible();
      await $('Sign in with Google').waitUntilVisible();
    },
  );
}
