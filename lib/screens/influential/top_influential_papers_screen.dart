import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/publication.dart';
import '../detail/publication_detail_screen.dart';

class TopInfluentialPapersScreen extends StatelessWidget {
  const TopInfluentialPapersScreen({
    super.key,
    required this.topic,
    required this.papers,
  });

  final String topic;
  final List<Publication> papers;

  Future<void> _openDetail(BuildContext context, Publication publication) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PublicationDetailScreen(publication: publication),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const _DarkAppBar(title: 'Top Influential Papers'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          // ── Topic banner ──────────────────────────────────────────────
          _TopicBanner(topic: topic, count: papers.length),
          const SizedBox(height: 20),

          // ── Section header ────────────────────────────────────────────
          const _SectionHeader(
            label: 'Ranked by Citations',
            accentColor: AppColors.goldBadge,
          ),
          const SizedBox(height: 12),

          // ── Paper list ────────────────────────────────────────────────
          if (papers.isEmpty)
            _EmptyState()
          else
            ...papers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RankedPaperCard(
                  rank: entry.key + 1,
                  paper: entry.value,
                  onTap: () => _openDetail(context, entry.value),
                ),
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
  const _TopicBanner({required this.topic, required this.count});

  final String topic;
  final int count;

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
              color: AppColors.goldBadge.withValues(alpha:0.12),
              border: Border.all(color: AppColors.goldBadge.withValues(alpha:0.3)),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.goldBadge,
              size: 20,
            ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldBadge.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.goldBadge.withValues(alpha:0.25)),
            ),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldBadge,
                  ),
                ),
                const Text(
                  'papers',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
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

// ─── Ranked Paper Card ────────────────────────────────────────────────────────

class _RankedPaperCard extends StatelessWidget {
  const _RankedPaperCard({
    required this.rank,
    required this.paper,
    required this.onTap,
  });

  final int rank;
  final Publication paper;
  final VoidCallback onTap;

  // Top 3 get progressively brighter rank ring colours
  Color get _rankColor {
    if (rank == 1) return AppColors.goldBadge;
    if (rank == 2) return AppColors.purpleAccent;
    if (rank == 3) return AppColors.neonLime;
    return AppColors.neonCyan;
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGlass),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Left accent bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: rankColor),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(19, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Rank badge + citation badge row ────────────────
                    Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rankColor.withValues(alpha:0.15),
                            border: Border.all(
                              color: rankColor.withValues(alpha:0.5),
                              width: rank <= 3 ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: rankColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Gold citation badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldBadge.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.goldBadge.withValues(alpha:0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.goldBadge,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${paper.citationCount}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldBadge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Title ──────────────────────────────────────────
                    Text(
                      paper.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Authors ────────────────────────────────────────
                    if (paper.authorNames.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: AppColors.textSecondary,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              paper.authorNames.length <= 3
                                  ? paper.authorNames.join(', ')
                                  : '${paper.authorNames.take(2).join(', ')}  +${paper.authorNames.length - 2} more',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),

                    // ── Year + journal chips ───────────────────────────
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (paper.publicationYear != null)
                          _Chip(
                            icon: Icons.calendar_today_outlined,
                            iconColor: AppColors.neonCyan,
                            label: '${paper.publicationYear}',
                          ),
                        if (paper.journalName.isNotEmpty &&
                            paper.journalName != 'Unknown journal')
                          _Chip(
                            icon: Icons.menu_book_outlined,
                            iconColor: AppColors.neonLime,
                            label: paper.journalName,
                            maxWidth: 220,
                          ),
                      ],
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

// ─── Small Chip ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.maxWidth,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderGlass),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: iconColor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
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

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 44,
            color: AppColors.goldBadge.withValues(alpha:0.4),
          ),
          const SizedBox(height: 14),
          const Text(
            'No papers available for influential ranking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Papers require citation data to be ranked.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
