import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/state/trend_analyzer.dart';

void main() {
  test('analyze groups publications by year and sorts ascending', () {
    const publications = [
      Publication(
        id: 'W1',
        title: 'P1',
        publicationYear: 2022,
        citationCount: 10,
        journalName: 'J1',
        authorNames: ['A'],
        doi: null,
        abstractText: null,
      ),
      Publication(
        id: 'W2',
        title: 'P2',
        publicationYear: 2021,
        citationCount: 2,
        journalName: 'J2',
        authorNames: ['B'],
        doi: null,
        abstractText: null,
      ),
      Publication(
        id: 'W3',
        title: 'P3',
        publicationYear: 2022,
        citationCount: 8,
        journalName: 'J3',
        authorNames: ['C'],
        doi: null,
        abstractText: null,
      ),
      Publication(
        id: 'W4',
        title: 'P4',
        publicationYear: null,
        citationCount: 5,
        journalName: 'J4',
        authorNames: ['D'],
        doi: null,
        abstractText: null,
      ),
    ];

    final result = TrendAnalyzer.analyze(publications);

    expect(result.totalPublications, 4);
    expect(result.points.length, 2);
    expect(result.points[0].year, 2021);
    expect(result.points[0].count, 1);
    expect(result.points[1].year, 2022);
    expect(result.points[1].count, 2);
    expect(result.mostActiveYear, 2022);
    expect(result.mostActiveCount, 2);
    expect(result.yearRangeLabel, '2021 - 2022');
  });
}
