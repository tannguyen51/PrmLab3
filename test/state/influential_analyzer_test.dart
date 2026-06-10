import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/state/influential_analyzer.dart';

void main() {
  test('topPapers sorts by citation descending and applies limit', () {
    const publications = [
      Publication(
        id: 'W1',
        title: 'Paper A',
        publicationYear: 2022,
        citationCount: 12,
        journalName: 'J1',
        authorNames: ['A'],
        doi: null,
        abstractText: null,
      ),
      Publication(
        id: 'W2',
        title: 'Paper B',
        publicationYear: 2021,
        citationCount: 45,
        journalName: 'J2',
        authorNames: ['B'],
        doi: null,
        abstractText: null,
      ),
      Publication(
        id: 'W3',
        title: 'Paper C',
        publicationYear: 2023,
        citationCount: 30,
        journalName: 'J3',
        authorNames: ['C'],
        doi: null,
        abstractText: null,
      ),
    ];

    final topTwo = InfluentialAnalyzer.topPapers(publications, limit: 2);

    expect(topTwo.length, 2);
    expect(topTwo[0].title, 'Paper B');
    expect(topTwo[1].title, 'Paper C');
  });
}
