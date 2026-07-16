import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/screens/journals/journal_detail_screen.dart';

void main() {
  group('JournalDetailScreen', () {
    test('extracts the most active authors for a journal', () {
      final publications = [
        const Publication(
          id: '1',
          title: 'Paper one',
          publicationYear: 2024,
          citationCount: 30,
          journalName: 'Nature',
          authorNames: ['Ada Lovelace', 'Grace Hopper'],
          doi: null,
          abstractText: 'A sample paper.',
        ),
        const Publication(
          id: '2',
          title: 'Paper two',
          publicationYear: 2023,
          citationCount: 15,
          journalName: 'Nature',
          authorNames: ['Ada Lovelace', 'Katherine Johnson'],
          doi: null,
          abstractText: 'Another sample paper.',
        ),
      ];

      final topAuthors = JournalDetailScreen.topAuthorsForPublications(
        publications,
        limit: 3,
      );

      expect(topAuthors.first.name, 'Ada Lovelace');
      expect(topAuthors.first.publicationCount, 2);
      expect(topAuthors.length, 3);
    });
  });
}
