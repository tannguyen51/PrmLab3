import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/author_summary.dart';
import '../../models/journal_summary.dart';
import '../../models/publication.dart';
import '../../widgets/publication_card.dart';
import '../detail/publication_detail_screen.dart';

class JournalDetailScreen extends StatelessWidget {
  const JournalDetailScreen({
    super.key,
    required this.journal,
    required this.topic,
    required this.publications,
  });

  final JournalSummary journal;
  final String topic;
  final List<Publication> publications;

  List<Publication> get _journalPublications {
    return publications
        .where((publication) => publication.journalName == journal.name)
        .toList(growable: false);
  }

  static List<Publication> sortPublicationsByImpact(
    List<Publication> publications,
  ) {
    return [...publications]..sort((left, right) {
      final byCitations = right.citationCount.compareTo(left.citationCount);
      if (byCitations != 0) {
        return byCitations;
      }

      final byYear = (right.publicationYear ?? 0).compareTo(
        left.publicationYear ?? 0,
      );
      if (byYear != 0) {
        return byYear;
      }

      return left.title.toLowerCase().compareTo(right.title.toLowerCase());
    });
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

  @override
  Widget build(BuildContext context) {
    final journalPublications = sortPublicationsByImpact(_journalPublications);
    final featuredPublication = journalPublications.isEmpty
        ? null
        : journalPublications.first;
    final topAuthors = topAuthorsForPublications(journalPublications);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _DarkAppBar(title: journal.name),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _JournalHeader(
            journal: journal,
            topic: topic,
            count: journalPublications.length,
          ),
          const SizedBox(height: 20),
          if (featuredPublication != null)
            _ImpactSummaryCard(publication: featuredPublication),
          const SizedBox(height: 20),
          if (topAuthors.isNotEmpty) ...[
            const _SectionHeader(
              label: 'Top authors',
              accentColor: AppColors.neonLime,
            ),
            const SizedBox(height: 12),
            _TopAuthorsCard(authors: topAuthors),
            const SizedBox(height: 20),
          ],
          const _SectionHeader(
            label: 'Publications',
            accentColor: AppColors.neonCyan,
          ),
          const SizedBox(height: 12),
          if (journalPublications.isEmpty)
            const _EmptyState()
          else
            ...journalPublications.map((publication) {
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

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({
    required this.journal,
    required this.topic,
    required this.count,
  });

  final JournalSummary journal;
  final String topic;
  final int count;

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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonLime.withValues(alpha: 0.14),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.neonLime,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'JOURNAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      journal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Top venue for "$topic" with ${journal.publicationCount} papers matched.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Badge(label: '$count publications', color: AppColors.neonCyan),
              const SizedBox(width: 8),
              _Badge(label: 'Topic view', color: AppColors.neonLime),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
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

class _ImpactSummaryCard extends StatelessWidget {
  const _ImpactSummaryCard({required this.publication});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonLime.withValues(alpha: 0.14),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppColors.neonLime,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most cited paper',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  publication.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${publication.citationCount} citations • ${publication.publicationYear ?? 'Unknown year'}',
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
    );
  }
}

class _TopAuthorsCard extends StatelessWidget {
  const _TopAuthorsCard({required this.authors});

  final List<AuthorSummary> authors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonCyan.withValues(alpha: 0.14),
                    ),
                    alignment: Alignment.center,
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
                          '${authors[index].publicationCount} papers in this journal',
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
            borderRadius: BorderRadius.circular(99),
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
      child: Column(
        children: const [
          Icon(Icons.menu_book_outlined, size: 42, color: AppColors.neonCyan),
          SizedBox(height: 18),
          Text(
            'No publications found for this journal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Try another topic or return to the Search tab.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
