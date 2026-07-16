import 'dart:math' as math;

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
      'a',
      'about',
      'across',
      'after',
      'all',
      'also',
      'an',
      'and',
      'any',
      'are',
      'as',
      'at',
      'be',
      'been',
      'before',
      'between',
      'but',
      'by',
      'can',
      'could',
      'did',
      'do',
      'does',
      'each',
      'few',
      'for',
      'from',
      'get',
      'got',
      'has',
      'have',
      'having',
      'here',
      'how',
      'however',
      'in',
      'into',
      'is',
      'it',
      'its',
      'just',
      'many',
      'may',
      'more',
      'most',
      'much',
      'must',
      'of',
      'on',
      'or',
      'other',
      'our',
      'out',
      'over',
      'same',
      'should',
      'some',
      'such',
      'than',
      'that',
      'the',
      'their',
      'them',
      'there',
      'these',
      'they',
      'this',
      'those',
      'through',
      'to',
      'under',
      'using',
      'used',
      'very',
      'was',
      'were',
      'what',
      'when',
      'where',
      'which',
      'while',
      'will',
      'with',
      'without',
      'would',
      'your',
    };

    final genericTerms = <String>{
      'analysis',
      'analyses',
      'application',
      'applications',
      'approach',
      'approaches',
      'article',
      'articles',
      'based',
      'case',
      'cases',
      'compared',
      'comparison',
      'developed',
      'development',
      'method',
      'methods',
      'paper',
      'papers',
      'problem',
      'problems',
      'proposed',
      'result',
      'results',
      'review',
      'reviews',
      'showed',
      'study',
      'studies',
      'survey',
      'surveys',
      'technique',
      'techniques',
      'work',
      'works',
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

          if (genericTerms.contains(token)) {
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

    final rawKeywords = counts.entries
        .where((entry) => publicationMatches[entry.key] != null)
        .map(
          (entry) => KeywordSummary(
            keyword: entry.key,
            publicationCount: publicationMatches[entry.key] ?? 0,
          ),
        )
        .toList(growable: false);

    // Require stronger evidence for a keyword to be considered "highly specific".
    final minPubMatches = publications.length >= 4 ? 3 : 2;
    final docFrequency = publicationMatches;
    final totalDocs = publications.length;

    final keywords =
        rawKeywords
            .where((k) {
              final token = k.keyword;
              final pubMatches = docFrequency[token] ?? 0;

              // Always allow explicit domain terms or topic tokens.
              if (domainTerms.contains(token) || topicTokens.contains(token)) {
                return true;
              }

              // Require the token to appear in at least `minPubMatches` publications.
              if (pubMatches < minPubMatches) {
                return false;
              }

              // Short tokens must be domain acronyms; otherwise require length >= 4.
              if (token.length < 4) {
                return false;
              }

              // Require a minimum aggregated weight to avoid noisy terms.
              if ((counts[token] ?? 0) < 4) {
                return false;
              }

              return true;
            })
            .toList(growable: false)
          ..sort((left, right) {
            final leftToken = left.keyword;
            final rightToken = right.keyword;
            final leftMatches = docFrequency[leftToken] ?? 0;
            final rightMatches = docFrequency[rightToken] ?? 0;
            final leftWeight = counts[leftToken] ?? 0;
            final rightWeight = counts[rightToken] ?? 0;

            // Compute an IDF-style factor: rare enough to matter, but not so rare as to be noise.
            final leftIdf = math.log(1 + totalDocs / (leftMatches + 1));
            final rightIdf = math.log(1 + totalDocs / (rightMatches + 1));
            final leftScore = leftWeight * leftIdf;
            final rightScore = rightWeight * rightIdf;

            if (leftScore != rightScore) {
              return rightScore.compareTo(leftScore);
            }

            final byCount = right.publicationCount.compareTo(
              left.publicationCount,
            );
            if (byCount != 0) {
              return byCount;
            }
            final byWeight = rightWeight.compareTo(leftWeight);
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
