import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/author_summary.dart';
import '../../models/keyword_summary.dart';
import '../../models/publication.dart';
import '../../state/trend_analyzer.dart';
import '../../widgets/publication_card.dart';
import '../../widgets/trend_chart.dart';
import '../detail/publication_detail_screen.dart';

class KeywordDetailScreen extends StatelessWidget {
  const KeywordDetailScreen({
    super.key,
    required this.keyword,
    required this.topic,
    required this.publications,
  });

  final KeywordSummary keyword;
  final String topic;
  final List<Publication> publications;

  static List<Publication> sortPublicationsByRelevance(
    List<Publication> publications,
    String term,
  ) {
    final normalizedTerm = term.toLowerCase().trim();
    if (normalizedTerm.isEmpty) {
      return publications.toList(growable: false);
    }

    final keywordTokens = normalizedTerm
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);

    return publications
        .where((publication) => _matchesKeyword(publication, term))
        .toList(growable: false)
      ..sort((left, right) {
        final leftScore = _relevanceScore(left, keywordTokens);
        final rightScore = _relevanceScore(right, keywordTokens);
        if (leftScore != rightScore) {
          return rightScore.compareTo(leftScore);
        }
        return right.title.toLowerCase().compareTo(left.title.toLowerCase());
      });
  }

  List<Publication> get matchedPublications {
    return sortPublicationsByRelevance(publications, keyword.keyword);
  }

  static List<AuthorSummary> topAuthorsForPublications(
    List<Publication> publications, {
    int limit = 5,
  }) {
    final counts = <String, int>{};

    for (final publication in publications) {
      for (final author in publication.authorNames) {
        final normalized = author.trim();
        if (normalized.isEmpty) {
          continue;
        }
        counts[normalized] = (counts[normalized] ?? 0) + 1;
      }
    }

    final authors =
        counts.entries
            .map(
              (entry) =>
                  AuthorSummary(name: entry.key, publicationCount: entry.value),
            )
            .toList(growable: false)
          ..sort((left, right) {
            final byCount = right.publicationCount.compareTo(
              left.publicationCount,
            );
            if (byCount != 0) {
              return byCount;
            }
            return left.name.compareTo(right.name);
          });

    return authors.take(limit).toList(growable: false);
  }

  static List<String> relatedJournals(List<Publication> publications) {
    final counts = <String, int>{};
    for (final publication in publications) {
      final journal = publication.journalName.trim();
      if (journal.isEmpty || journal == 'Unknown journal') {
        continue;
      }
      counts[journal] = (counts[journal] ?? 0) + 1;
    }

    final sortedEntries = counts.entries.toList()
      ..sort((left, right) {
        final byCount = right.value.compareTo(left.value);
        if (byCount != 0) {
          return byCount;
        }
        return left.key.compareTo(right.key);
      });

    return sortedEntries.map((entry) => entry.key).toList(growable: false);
  }

  static int _relevanceScore(
    Publication publication,
    List<String> keywordTokens,
  ) {
    final haystack = <String>[
      publication.title,
      publication.abstractText ?? '',
      publication.authorsLabel,
    ].join(' ');

    final haystackTokens = haystack
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toSet();

    var score = 0;
    for (final token in keywordTokens) {
      if (haystackTokens.contains(token)) {
        score += 2;
      }
    }

    if (publication.title.toLowerCase().contains(keywordTokens.join(' '))) {
      score += 3;
    }

    if (publication.abstractText?.toLowerCase().contains(
          keywordTokens.join(' '),
        ) ??
        false) {
      score += 2;
    }

    return score;
  }

  static bool _matchesKeyword(Publication publication, String term) {
    final normalizedTerm = term.toLowerCase().trim();
    if (normalizedTerm.isEmpty) {
      return false;
    }

    final keywordTokens = normalizedTerm
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);

    if (keywordTokens.isEmpty) {
      return false;
    }

    final haystack = <String>[
      publication.title,
      publication.abstractText ?? '',
      publication.authorsLabel,
    ].join(' ');

    final haystackTokens = haystack
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toSet();

    if (keywordTokens.length == 1) {
      return haystackTokens.contains(keywordTokens.first);
    }

    return keywordTokens.every(haystackTokens.contains);
  }

  @override
  Widget build(BuildContext context) {
    final matchedPublications = this.matchedPublications;
    final trend = TrendAnalyzer.analyze(matchedPublications);
    final topAuthors = topAuthorsForPublications(matchedPublications);
    final relatedJournalsList = relatedJournals(matchedPublications);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _DarkAppBar(title: keyword.keyword),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _KeywordHeader(
            keyword: keyword,
            topic: topic,
            publicationCount: matchedPublications.length,
          ),
          const SizedBox(height: 20),
          const _SectionHeader(
            label: 'Keyword Trend Chart',
            accentColor: AppColors.neonCyan,
          ),
          const SizedBox(height: 12),
          _TrendCard(trend: trend),
          const SizedBox(height: 20),
          if (relatedJournalsList.isNotEmpty) ...[
            const _SectionHeader(
              label: 'Related Journals',
              accentColor: AppColors.neonLime,
            ),
            const SizedBox(height: 12),
            _RelatedJournalsCard(journals: relatedJournalsList),
            const SizedBox(height: 20),
          ],
          if (topAuthors.isNotEmpty) ...[
            _SectionHeader(
              label: 'Top Contributing Authors',
              accentColor: const Color(0xFFFFC857),
            ),
            const SizedBox(height: 12),
            _TopAuthorsCard(authors: topAuthors),
            const SizedBox(height: 20),
          ],
          const _SectionHeader(
            label: 'Related Publications',
            accentColor: AppColors.neonLime,
          ),
          const SizedBox(height: 12),
          if (matchedPublications.isEmpty)
            const _EmptyState()
          else
            ...matchedPublications.map((publication) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PublicationCard(
                  publication: publication,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PublicationDetailScreen(publication: publication),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DarkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DarkAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.surface.withValues(alpha: 0.85),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(height: 1, color: AppColors.borderGlass),
      ],
    );
  }
}

class _KeywordHeader extends StatelessWidget {
  const _KeywordHeader({
    required this.keyword,
    required this.topic,
    required this.publicationCount,
  });

  final KeywordSummary keyword;
  final String topic;
  final int publicationCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonLime.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'KEYWORD INSIGHT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.neonLime,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            keyword.keyword,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Topic: $topic',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                label: '$publicationCount publications',
                color: AppColors.neonCyan,
              ),
              _MetricChip(
                label: '${keyword.publicationCount} related matches',
                color: AppColors.neonLime,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend});

  final dynamic trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trend.points.isEmpty
                ? 'No yearly publication data for this keyword yet.'
                : 'The keyword appears most often in ${trend.mostActiveYear ?? 'recent years'}.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TrendChart(points: trend.points),
        ],
      ),
    );
  }
}

class _RelatedJournalsCard extends StatelessWidget {
  const _RelatedJournalsCard({required this.journals});

  final List<String> journals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Column(
        children: [
          for (var index = 0; index < journals.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == journals.length - 1 ? 0 : 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonLime.withValues(alpha: 0.14),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neonLime,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      journals[index],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TopAuthorsCard extends StatelessWidget {
  const _TopAuthorsCard({required this.authors});

  final List<AuthorSummary> authors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Column(
        children: [
          for (var index = 0; index < authors.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == authors.length - 1 ? 0 : 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonCyan.withValues(alpha: 0.14),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authors[index].name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${authors[index].publicationCount} publications',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_outlined, size: 44, color: AppColors.neonLime),
          SizedBox(height: 16),
          Text(
            'No publications matched this keyword.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try another keyword or expand the search topic.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
