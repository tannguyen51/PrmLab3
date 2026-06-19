import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/author_summary.dart';
import '../../models/journal_summary.dart';

class TopContributorsScreen extends StatelessWidget {
  const TopContributorsScreen({
    super.key,
    required this.topic,
    required this.journals,
    required this.authors,
  });

  final String topic;
  final List<JournalSummary> journals;
  final List<AuthorSummary> authors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const _DarkAppBar(title: 'Top Journals & Authors'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          // ── Topic banner ──────────────────────────────────────────────
          _TopicBanner(
            topic: topic,
            journalCount: journals.length,
            authorCount: authors.length,
          ),
          const SizedBox(height: 24),

          // ── Top Journals ──────────────────────────────────────────────
          const _SectionHeader(
            label: 'Top Journals',
            accentColor: AppColors.neonCyan,
          ),
          const SizedBox(height: 12),
          if (journals.isEmpty)
            _EmptySection(
              icon: Icons.menu_book_outlined,
              iconColor: AppColors.neonCyan,
              message: 'No journal ranking available for this topic.',
            )
          else
            ...journals.asMap().entries.map((entry) {
              return _RankedRow(
                rank: entry.key + 1,
                name: entry.value.name,
                count: entry.value.publicationCount,
                accentColor: AppColors.neonCyan,
                countLabel: 'papers',
              );
            }),
          const SizedBox(height: 24),

          // ── Top Authors ───────────────────────────────────────────────
          const _SectionHeader(
            label: 'Top Authors',
            accentColor: AppColors.neonLime,
          ),
          const SizedBox(height: 12),
          if (authors.isEmpty)
            _EmptySection(
              icon: Icons.person_outline,
              iconColor: AppColors.neonLime,
              message: 'No author ranking available for this topic.',
            )
          else
            ...authors.asMap().entries.map((entry) {
              return _RankedRow(
                rank: entry.key + 1,
                name: entry.value.name,
                count: entry.value.publicationCount,
                accentColor: AppColors.neonLime,
                countLabel: 'papers',
              );
            }),
        ],
      ),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

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
          backgroundColor: AppColors.surface.withValues(alpha:0.85),
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

// ─── Topic Banner ─────────────────────────────────────────────────────────────

class _TopicBanner extends StatelessWidget {
  const _TopicBanner({
    required this.topic,
    required this.journalCount,
    required this.authorCount,
  });

  final String topic;
  final int journalCount;
  final int authorCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonCyan.withValues(alpha:0.12),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha:0.3)),
            ),
            child: const Icon(Icons.groups_outlined, color: AppColors.neonCyan, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOPIC',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Counts column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CountPill(
                count: journalCount,
                label: 'journals',
                color: AppColors.neonCyan,
              ),
              const SizedBox(height: 6),
              _CountPill(
                count: authorCount,
                label: 'authors',
                color: AppColors.neonLime,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha:0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ranked Row ───────────────────────────────────────────────────────────────

class _RankedRow extends StatelessWidget {
  const _RankedRow({
    required this.rank,
    required this.name,
    required this.count,
    required this.accentColor,
    required this.countLabel,
  });

  final int rank;
  final String name;
  final int count;
  final Color accentColor;
  final String countLabel;

  // Rank 1 = full brightness, 2 = 75%, 3 = 60%, rest = 40%
  double get _ringOpacity {
    if (rank == 1) return 1.0;
    if (rank == 2) return 0.75;
    if (rank == 3) return 0.60;
    return 0.40;
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = accentColor.withValues(alpha:_ringOpacity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGlass),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            children: [
              // Left accent bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: ringColor),
              ),
              // Row content
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 11, 12, 11),
                child: Row(
                  children: [
                    // Rank circle
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ringColor.withValues(alpha:0.15),
                        border: Border.all(
                          color: ringColor.withValues(alpha:0.6),
                          width: rank <= 3 ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ringColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: rank == 1 ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: accentColor.withValues(alpha:0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            countLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.accentColor,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Empty Section ────────────────────────────────────────────────────────────

class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor.withValues(alpha:0.4), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
