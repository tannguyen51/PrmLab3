import '../models/keyword_summary.dart';
import '../models/publication.dart';

class KeywordAnalyzer {
  const KeywordAnalyzer._();

  static List<KeywordSummary> analyze(
    List<Publication> publications, {
    int limit = 10,
    String? topic,
  }) {
    final counts = <String, int>{};
    final publicationMatches = <String, int>{};
    final stopWords = <String>{
      'the',
      'and',
      'for',
      'with',
      'from',
      'that',
      'this',
      'have',
      'their',
      'into',
      'than',
      'were',
      'will',
      'your',
      'about',
      'also',
      'using',
      'used',
      'over',
      'under',
      'through',
      'within',
      'across',
      'between',
      'without',
      'during',
      'after',
      'before',
      'other',
      'these',
      'those',
      'been',
      'more',
      'very',
      'same',
      'such',
      'when',
      'where',
      'which',
      'while',
      'what',
    };

    final domainTerms = <String>{
      'ai',
      'artificial',
      'intelligence',
      'machine',
      'learning',
      'deep',
      'neural',
      'network',
      'networks',
      'cybersecurity',
      'security',
      'cloud',
      'computing',
      'blockchain',
      'data',
      'science',
      'software',
      'engineering',
      'internet',
      'things',
      'iot',
      'robotics',
      'analytics',
      'model',
      'models',
      'system',
      'systems',
      'algorithm',
      'algorithms',
      'vision',
      'language',
      'processing',
      'database',
      'databases',
      'optimization',
      'research',
      'computational',
      'distributed',
      'federated',
      'privacy',
      'safety',
      'secure',
      'reliable',
    };

    final topicTokens = _extractTokens(topic ?? '');

    for (final publication in publications) {
      final titleTokens = _extractTokens(publication.title);
      final abstractTokens = _extractTokens(publication.abstractText ?? '');
      final allTokens = <String>{};

      void addWeightedTerms(List<String> tokens, int weight) {
        for (final token in tokens) {
          if (token.length < 2 || stopWords.contains(token)) {
            continue;
          }

          if (!domainTerms.contains(token) && !topicTokens.contains(token)) {
            if (!RegExp(r'^[a-z]{3,}$').hasMatch(token)) {
              continue;
            }
          }

          if (!allTokens.contains(token)) {
            allTokens.add(token);
            counts[token] = (counts[token] ?? 0) + weight;
            publicationMatches[token] = (publicationMatches[token] ?? 0) + 1;
          }
        }
      }

      addWeightedTerms(titleTokens, 2);
      addWeightedTerms(abstractTokens, 1);

      for (final token in topicTokens) {
        counts[token] = (counts[token] ?? 0) + 3;
        publicationMatches[token] = (publicationMatches[token] ?? 0) + 1;
      }
    }

    final keywords =
        counts.entries
            .where((entry) => publicationMatches[entry.key] != null)
            .map(
              (entry) => KeywordSummary(
                keyword: entry.key,
                publicationCount: publicationMatches[entry.key] ?? 0,
              ),
            )
            .toList(growable: false)
          ..sort((left, right) {
            final byCount = right.publicationCount.compareTo(
              left.publicationCount,
            );
            if (byCount != 0) {
              return byCount;
            }
            final byWeight = (counts[right.keyword] ?? 0).compareTo(
              counts[left.keyword] ?? 0,
            );
            if (byWeight != 0) {
              return byWeight;
            }
            return left.keyword.compareTo(right.keyword);
          });

    return keywords.take(limit).toList(growable: false);
  }

  static List<String> _extractTokens(String text) {
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);

    return normalized;
  }
}
