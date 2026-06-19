import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/dashboard_summary.dart';
import '../../models/publication.dart';
import '../../state/dashboard_analyzer.dart';
import '../detail/publication_detail_screen.dart';

class ResearchDashboardScreen extends StatelessWidget {
  const ResearchDashboardScreen({
    super.key,
    required this.topic,
    required this.publications,
  });

  final String topic;
  final List<Publication> publications;

  Future<void> _openDetail(BuildContext context, Publication publication) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PublicationDetailScreen(publication: publication),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = DashboardAnalyzer.analyze(publications);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _DarkAppBar(title: 'Research Dashboard'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Topic hero ────────────────────────────────────────────────
          _TopicHero(topic: topic, publicationCount: summary.totalPublications),
          const SizedBox(height: 20),

          // ── Metrics row ───────────────────────────────────────────────
          const _SectionHeader(
            label: 'At a Glance',
            accentColor: AppColors.neonCyan,
          ),
          const SizedBox(height: 12),
          _MetricsRow(summary: summary),
          const SizedBox(height: 24),

          // ── Key insights (journal + author) ───────────────────────────
          const _SectionHeader(
            label: 'Key Insights',
            accentColor: AppColors.neonLime,
          ),
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.menu_book_outlined,
            iconColor: AppColors.neonCyan,
            label: 'Top Journal',
            value: summary.topJournal ?? 'No journal data available.',
            hasValue: summary.topJournal != null,
          ),
          const SizedBox(height: 10),
          _InsightCard(
            icon: Icons.person_outline,
            iconColor: AppColors.neonLime,
            label: 'Top Author',
            value: summary.topAuthor ?? 'No author data available.',
            hasValue: summary.topAuthor != null,
          ),
          const SizedBox(height: 24),

          // ── Most influential paper ─────────────────────────────────────
          const _SectionHeader(
            label: 'Most Influential Paper',
            accentColor: AppColors.goldBadge,
          ),
          const SizedBox(height: 12),
          _InfluentialPaperCard(
            paper: summary.mostInfluentialPaper,
            onViewDetails: summary.mostInfluentialPaper == null
                ? null
                : () => _openDetail(context, summary.mostInfluentialPaper!),
          ),
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

// ─── Topic Hero ───────────────────────────────────────────────────────────────

class _TopicHero extends StatelessWidget {
  const _TopicHero({required this.topic, required this.publicationCount});

  final String topic;
  final int publicationCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonCyan.withValues(alpha:0.12),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha:0.3)),
            ),
            child: const Icon(
              Icons.dashboard_outlined,
              color: AppColors.neonCyan,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESEARCH TOPIC',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  topic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Publication count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha:0.25)),
            ),
            child: Column(
              children: [
                Text(
                  '$publicationCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neonCyan,
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

// ─── Metrics Row ──────────────────────────────────────────────────────────────

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.library_books_outlined,
            iconColor: AppColors.neonCyan,
            label: 'Total',
            value: '${summary.totalPublications}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.star_outline_rounded,
            iconColor: AppColors.goldBadge,
            label: 'Avg Citations',
            value: summary.averageCitationCount.toStringAsFixed(1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.calendar_month_outlined,
            iconColor: AppColors.purpleAccent,
            label: 'Peak Year',
            value: summary.mostActiveYear?.toString() ?? 'N/A',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha:0.15),
              border: Border.all(color: iconColor.withValues(alpha:0.3)),
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 20,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Insight Card ─────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.hasValue,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool hasValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: iconColor.withValues(alpha:0.12),
              border: Border.all(color: iconColor.withValues(alpha:0.25)),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: hasValue
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                    height: 1.35,
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

// ─── Most Influential Paper Card ──────────────────────────────────────────────

class _InfluentialPaperCard extends StatelessWidget {
  const _InfluentialPaperCard({
    required this.paper,
    required this.onViewDetails,
  });

  final Publication? paper;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    if (paper == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGlass),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.textSecondary.withValues(alpha:0.5),
              size: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              'No influential paper identified.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Gold left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 3, color: AppColors.goldBadge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Citation badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
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
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${paper!.citationCount} Citations',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldBadge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    paper!.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Authors + year row
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          paper!.authorNames.isEmpty
                              ? 'Unknown authors'
                              : paper!.authorNames.length <= 3
                                  ? paper!.authorNames.join(', ')
                                  : '${paper!.authorNames.take(2).join(', ')}  +${paper!.authorNames.length - 2} more',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (paper!.publicationYear != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceBright,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${paper!.publicationYear}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  // View Details button
                  GestureDetector(
                    onTap: onViewDetails,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldBadge.withValues(alpha:0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.goldBadge.withValues(alpha:0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.open_in_new,
                            color: AppColors.goldBadge,
                            size: 15,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'View Publication Details',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldBadge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
