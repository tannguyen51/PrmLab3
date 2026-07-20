import 'package:patrol/patrol.dart';

/// Test Case 2 – Topic Search
///
/// Enters a research topic, executes a search, and verifies
/// publication results are displayed.
///
/// Test Case 3 – Publication Details
///
/// Opens a publication from the search results and verifies
/// publication information is displayed correctly.
void main() {
  patrolTest(
    'Topic search and verify results',
    ($) async {
      await $('Search OpenAlex').waitUntilVisible();

      // Enter a research topic
      await $('Search keywords, authors, journals...').enterText('Data Science');
      await $('Search OpenAlex').tap();

      // Wait for results to load — verify publications appear
      await $('Trending Publications').waitUntilVisible(timeout: const Duration(seconds: 30));
    },
  );

  patrolTest(
    'Open publication details',
    ($) async {
      await $('Search OpenAlex').waitUntilVisible();

      // Search first
      await $('Search keywords, authors, journals...').enterText('AI');
      await $('Search OpenAlex').tap();

      // Wait for results
      await $('Trending Publications').waitUntilVisible(timeout: const Duration(seconds: 30));

      // Tap the first publication card
      await $('Citations').tap();

      // Verify publication detail screen elements
      await $('Publication Details').waitUntilVisible();
      await $('DOI').waitUntilVisible();
      await $('Abstract').waitUntilVisible();
    },
  );
}
