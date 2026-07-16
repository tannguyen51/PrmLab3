import 'package:journal_trend_analyzer/state/keyword_analyzer.dart';
import 'package:journal_trend_analyzer/models/publication.dart';

void main() {
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
      abstractText: 'AI systems require safe and reliable learning pipelines',
    ),
  ];

  final result = KeywordAnalyzer.analyze(publications, limit: 10);
  print(result.map((k) => '${k.keyword}:${k.publicationCount}').join(', '));
}
