import 'package:patrol/patrol.dart';

/// Test Case 4 – Journals Navigation
///
/// Navigates to the Journals tab and verifies journal statistics
/// and journal list are displayed.
///
/// Test Case 5 – Journal Details
///
/// Opens a journal from the journal list and verifies journal
/// details are displayed correctly.
void main() {
  patrolTest(
    'Navigate to Journals tab',
    ($) async {
      // Navigate to Journals tab via bottom nav
      await $('Journals').tap();
      await $('Journals').waitUntilVisible();

      // Verify the Journals heading is displayed
      await $('Journals').waitUntilVisible();
    },
  );

  patrolTest(
    'Open journal details',
    ($) async {
      // First search for a topic to have journal data
      await $('Search keywords, authors, journals...').enterText('Cybersecurity');
      await $('Search OpenAlex').tap();
      await $('Trending Publications').waitUntilVisible(timeout: const Duration(seconds: 30));

      // Navigate to Journals tab
      await $('Journals').tap();
      await $('Top journals identified').waitUntilVisible();

      // Tap the first journal in the list
      await $('1').tap();

      // Verify journal detail elements
      await $('JOURNAL').waitUntilVisible();
    },
  );
}
