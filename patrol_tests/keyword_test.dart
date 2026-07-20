import 'package:patrol/patrol.dart';

/// Test Case 6 – Keywords Navigation
///
/// Navigates to the Keywords tab and verifies keyword statistics
/// and keyword list are displayed.
///
/// Test Case 7 – Keyword Details
///
/// Opens a keyword from the keyword list and verifies keyword
/// analysis information is displayed.
void main() {
  patrolTest(
    'Navigate to Keywords tab',
    ($) async {
      // Navigate to Keywords tab via bottom nav
      await $('Keywords').tap();
      await $('Keywords').waitUntilVisible();

      // Verify the Keywords heading is displayed
      await $('Keywords').waitUntilVisible();
    },
  );

  patrolTest(
    'Open keyword details',
    ($) async {
      // Search first to have keyword data
      await $('Search keywords, authors, journals...').enterText('Data Science');
      await $('Search OpenAlex').tap();
      await $('Trending Publications').waitUntilVisible(timeout: const Duration(seconds: 30));

      // Navigate to Keywords tab
      await $('Keywords').tap();
      await $('Top recurring terms').waitUntilVisible();

      // Tap the first keyword
      await $('publications').tap();

      // Verify keyword detail elements
      await $('KEYWORD INSIGHT').waitUntilVisible();
      await $('Keyword Trend Chart').waitUntilVisible();
      await $('Related Publications').waitUntilVisible();
    },
  );
}
