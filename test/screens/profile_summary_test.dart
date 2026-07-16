import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/screens/profile/profile_summary.dart';

void main() {
  group('ProfileSummary', () {
    test('summarizes the current search context for the profile page', () {
      final publications = [
        const Publication(
          id: '1',
          title: 'AI for medicine',
          publicationYear: 2024,
          citationCount: 18,
          journalName: 'Nature',
          authorNames: ['Ada Lovelace'],
          doi: null,
          abstractText: 'An AI study.',
        ),
        const Publication(
          id: '2',
          title: 'Machine learning systems',
          publicationYear: 2023,
          citationCount: 10,
          journalName: 'Science',
          authorNames: ['Grace Hopper'],
          doi: null,
          abstractText: 'A learning study.',
        ),
      ];

      final summary = ProfileSummary.fromSearchState(
        topic: 'Artificial Intelligence',
        publications: publications,
      );

      expect(summary.currentTopic, 'Artificial Intelligence');
      expect(summary.publicationCount, 2);
      expect(summary.journalCount, 2);
      expect(summary.highlightLabel, 'Top venue');
      expect(summary.highlightValue, 'Nature');
    });
  });
}
