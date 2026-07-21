import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/screens/search/search_screen.dart';
import 'package:journal_trend_analyzer/services/openalex_service.dart';
import 'package:journal_trend_analyzer/services/publication_repository.dart';
import 'package:journal_trend_analyzer/state/search_provider.dart';

Widget _buildTestApp(SearchProvider provider) {
  return ChangeNotifierProvider<SearchProvider>.value(
    value: provider,
    child: const MaterialApp(home: SearchScreen()),
  );
}

void main() {
  testWidgets('search screen renders trending chips', (WidgetTester tester) async {
    final provider = SearchProvider(repository: _FakePublicationRepository());

    await tester.pumpWidget(_buildTestApp(provider));
    await tester.pump();

    // Verify static UI elements
    expect(find.text('Data Science'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Cybersecurity'), findsOneWidget);
    expect(find.text('Blockchain'), findsOneWidget);
  });

  testWidgets('search populates publications and shows results', (WidgetTester tester) async {
    final provider = SearchProvider(repository: _FakePublicationRepository());

    await tester.pumpWidget(_buildTestApp(provider));

    // Trigger search directly on provider
    provider.search('Artificial Intelligence');
    await tester.pumpAndSettle();

    // After search, the chip tap or search should show results
    expect(provider.publications.length, greaterThan(0));
    expect(provider.hasSearched, isTrue);
  });
}

class _FakePublicationRepository extends PublicationRepository {
  _FakePublicationRepository() : super(const OpenAlexService());

  @override
  Future<List<Publication>> searchByTopic(String topic) async {
    return const [
      Publication(
        id: 'W1',
        title: 'AI for Software Engineering',
        publicationYear: 2024,
        citationCount: 128,
        journalName: 'Journal of Smart Systems',
        authorNames: ['Alice Nguyen', 'Minh Tran'],
        doi: '10.1000/xyz123',
        abstractText: 'This paper studies how AI supports software teams.',
      ),
    ];
  }
}
