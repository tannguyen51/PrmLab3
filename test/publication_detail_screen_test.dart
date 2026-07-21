import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/screens/detail/publication_detail_screen.dart';

void main() {
  testWidgets('publication detail screen renders required fields', (
    WidgetTester tester,
  ) async {
    const publication = Publication(
      id: 'W1',
      title: 'AI for Software Engineering',
      publicationYear: 2024,
      citationCount: 128,
      journalName: 'Journal of Smart Systems',
      authorNames: ['Alice Nguyen', 'Minh Tran'],
      doi: '10.1000/xyz123',
      abstractText: 'This paper studies how AI supports software teams.',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PublicationDetailScreen(publication: publication),
      ),
    );
    await tester.pump();

    expect(find.text('Publication Details'), findsOneWidget);
    expect(find.text('AI for Software Engineering'), findsOneWidget);
    expect(find.text('Alice Nguyen, Minh Tran'), findsOneWidget);
    expect(find.text('Journal of Smart Systems'), findsOneWidget);
    expect(find.text('10.1000/xyz123'), findsOneWidget);
    expect(
      find.text('This paper studies how AI supports software teams.'),
      findsOneWidget,
    );
  });
}
