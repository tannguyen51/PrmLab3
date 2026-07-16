import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/screens/keywords/keyword_detail_screen.dart';
import 'package:journal_trend_analyzer/state/keyword_analyzer.dart';

void main() {
  group('KeywordAnalyzer', () {
    test(
      'extracts repeated keywords from publication titles and abstracts',
      () {
        final publications = [
          const Publication(
            id: '1',
            title: 'Deep learning for AI safety',
            publicationYear: 2024,
            citationCount: 12,
            journalName: 'Nature',
            authorNames: ['Alice Wang'],
            doi: null,
            abstractText: 'AI safety and deep learning for secure systems',
          ),
          const Publication(
            id: '2',
            title: 'Deep learning for safe AI systems',
            publicationYear: 2023,
            citationCount: 8,
            journalName: 'Science',
            authorNames: ['Bob Lin'],
            doi: null,
            abstractText:
                'AI systems require safe and reliable learning pipelines',
          ),
        ];

        final result = KeywordAnalyzer.analyze(publications, limit: 5);

        expect(result.isNotEmpty, isTrue);
        expect(result.any((keyword) => keyword.keyword == 'ai'), isTrue);
        expect(result.any((keyword) => keyword.keyword == 'learning'), isTrue);
        expect(result.first.publicationCount, greaterThanOrEqualTo(1));
      },
    );

    test('filters out generic stop words and keeps domain-relevant terms', () {
      final publications = [
        const Publication(
          id: '3',
          title: 'Cybersecurity in cloud computing systems',
          publicationYear: 2024,
          citationCount: 9,
          journalName: 'IEEE Security',
          authorNames: ['Carol Kim'],
          doi: null,
          abstractText:
              'Cloud computing and cybersecurity defense for modern enterprises.',
        ),
      ];

      final result = KeywordAnalyzer.analyze(publications, limit: 10);
      final keywords = result.map((entry) => entry.keyword).toSet();

      expect(keywords.contains('cybersecurity'), isTrue);
      expect(keywords.contains('cloud'), isTrue);
      expect(keywords.contains('computing'), isTrue);
      expect(keywords.contains('in'), isFalse);
      expect(keywords.contains('for'), isFalse);
      expect(keywords.contains('and'), isFalse);
    });

    test('ranks related publications by relevance before display', () {
      final publications = [
        const Publication(
          id: '4',
          title: 'Learning methods for students',
          publicationYear: 2023,
          citationCount: 10,
          journalName: 'Education Review',
          authorNames: ['Diana Moore'],
          doi: null,
          abstractText: 'A broad overview of educational learning techniques.',
        ),
        const Publication(
          id: '5',
          title: 'Artificial intelligence for healthcare',
          publicationYear: 2024,
          citationCount: 25,
          journalName: 'Nature Medicine',
          authorNames: ['Ethan Cole'],
          doi: null,
          abstractText: 'Artificial intelligence improves medical diagnostics.',
        ),
      ];

      final ranked = KeywordDetailScreen.sortPublicationsByRelevance(
        publications,
        'artificial intelligence',
      );

      expect(ranked.first.title, 'Artificial intelligence for healthcare');
      expect(ranked.first.publicationYear, 2024);
    });
  });
}
