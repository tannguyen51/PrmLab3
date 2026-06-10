import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/screens/trend/trend_analysis_screen.dart';

void main() {
  testWidgets('trend analysis screen shows trend metrics and chart section', (
    WidgetTester tester,
  ) async {
    const publications = [
      Publication(
        id: 'W1',
        title: 'AI 1',
        publicationYear: 2021,
        citationCount: 20,
        journalName: 'J1',
        authorNames: ['A'],
        doi: null,
        abstractText: null,
      ),
      Publication(
        id: 'W2',
        title: 'AI 2',
        publicationYear: 2022,
        citationCount: 30,
        journalName: 'J2',
        authorNames: ['B'],
        doi: null,
        abstractText: null,
      ),
      Publication(
        id: 'W3',
        title: 'AI 3',
        publicationYear: 2022,
        citationCount: 15,
        journalName: 'J3',
        authorNames: ['C'],
        doi: null,
        abstractText: null,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: TrendAnalysisScreen(
          topic: 'Artificial Intelligence',
          publications: publications,
        ),
      ),
    );

    expect(find.text('Trend Analysis'), findsOneWidget);
    expect(find.text('Artificial Intelligence'), findsOneWidget);
    expect(find.text('Total Publications'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    expect(find.text('Most Active Year'), findsOneWidget);
    expect(find.text('2022'), findsWidgets);
    expect(find.text('Publications by Year'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Top Influential Papers'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Top Influential Papers'), findsOneWidget);
    expect(find.text('View Full Ranking'), findsOneWidget);
  });

  testWidgets('tapping full ranking opens top influential papers screen', (
    WidgetTester tester,
  ) async {
    const publications = [
      Publication(
        id: 'W1',
        title: 'AI 1',
        publicationYear: 2021,
        citationCount: 20,
        journalName: 'J1',
        authorNames: ['A'],
        doi: null,
        abstractText: null,
      ),
      Publication(
        id: 'W2',
        title: 'AI 2',
        publicationYear: 2022,
        citationCount: 30,
        journalName: 'J2',
        authorNames: ['B'],
        doi: null,
        abstractText: null,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: TrendAnalysisScreen(
          topic: 'Artificial Intelligence',
          publications: publications,
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('View Full Ranking'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Full Ranking'));
    await tester.pumpAndSettle();

    expect(find.text('Top Influential Papers'), findsOneWidget);
    expect(find.text('AI 2'), findsOneWidget);
    expect(find.text('AI 1'), findsOneWidget);
  });
}
