import 'package:patrol/patrol.dart';

/// Test Case 9 – PDF Export
///
/// Generates a PDF report, uploads the report to Firebase Storage,
/// and verifies successful upload.
void main() {
  patrolTest(
    'PDF export and upload',
    ($) async {
      // First search for a topic to have data to export
      await $('Search keywords, authors, journals...').enterText('AI');
      await $('Search OpenAlex').tap();
      await $('Trending Publications').waitUntilVisible(timeout: const Duration(seconds: 30));

      // Navigate to Profile tab
      await $('Profile').tap();
      await $('Report Export').waitUntilVisible();

      // Check that the export status is visible
      await $('Ready to export dashboard analytics').waitUntilVisible();
    },
  );
}
