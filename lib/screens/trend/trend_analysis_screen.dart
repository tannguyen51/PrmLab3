import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/publication.dart';
import '../../state/contributors_analyzer.dart';
import '../../state/dashboard_analyzer.dart';
import '../../state/influential_analyzer.dart';
import '../../state/trend_analyzer.dart';
import '../../widgets/trend_chart.dart';
import '../contributors/top_contributors_screen.dart';
import '../dashboard/research_dashboard_screen.dart';
import '../influential/top_influential_papers_screen.dart';

class TrendAnalysisScreen extends StatelessWidget {
  const TrendAnalysisScreen({
    super.key,
    required this.topic,
    required this.publications,
  });

  final String topic;
  final List<Publication> publications;

  Future<void> _openInfluentialPapers(
    BuildContext context,
    List<Publication> papers,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopInfluentialPapersScreen(topic: topic, papers: papers),
      ),
    );
  }

  Future<void> _openContributors(
    BuildContext context,
    ContributorsResult contributors,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopContributorsScreen(
          topic: topic,
          journals: contributors.topJournals,
          authors: contributors.topAuthors,
        ),
      ),
    );
  }

  Future<void> _openDashboard(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ResearchDashboardScreen(topic: topic, publications: publications),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysis = TrendAnalyzer.analyze(publications);
    final topInfluential = InfluentialAnalyzer.topPapers(publications);
    final previewPapers = topInfluential.take(3).toList(growable: false);
    final contributors = ContributorsAnalyzer.analyze(publications);
    final dashboard = DashboardAnalyzer.analyze(publications);
    final previewJournals = contributors.topJournals.take(3).toList(growable: false);
    final previewAuthors = contributors.topAuthors.take(3).toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _DarkAppBar(title: 'Trend Analysis'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Topic hero ────────────────────────────────────────────────
          _TopicHero(topic: topic),
          const SizedBox(height: 20),

          // ── Metrics ───────────────────────────────────────────────────
          const _SectionHeader(
            label: 'Overview',
            accentColor: AppColors.neonCyan,
          ),
          const SizedBox(height: 12),
          _MetricsRow(analysis: analysis),
          const SizedBox(height: 24),

          // ── Chart ─────────────────────────────────────────────────────
          const _SectionHeader(
            label: 'Publications by Year',
            accentColor: AppColors.neonCyan,
          ),
          const SizedBox(height: 12),
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Annual publication activity for this research topic.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TrendChart(points: analysis.points),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Top Influential Papers ────────────────────────────────────
          const _SectionHeader(
            label: 'Top Influential Papers',
            accentColor: AppColors.goldBadge,
          ),
          const SizedBox(height: 12),
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (previewPapers.isEmpty)
                  const _EmptyNote(text: 'No citation data available to rank papers.')
                else
                  ...previewPapers.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PaperRankRow(
                        rank: entry.key + 1,
                        paper: entry.value,
                      ),
                    );
                  }),
                const SizedBox(height: 4),
                _TintedButton(
                  icon: Icons.leaderboard_outlined,
                  label: 'View Full Ranking',
                  accentColor: AppColors.goldBadge,
                  enabled: topInfluential.isNotEmpty,
                  onTap: topInfluential.isEmpty
                      ? null
                      : () => _openInfluentialPapers(context, topInfluential),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Dashboard Preview ─────────────────────────────────────────
          const _SectionHeader(
            label: 'Dashboard Preview',
            accentColor: AppColors.purpleAccent,
          ),
          const SizedBox(height: 12),
          _GlassCard(
            child: Column(
              children: [
                _InsightRow(
                  icon: Icons.menu_book_outlined,
                  iconColor: AppColors.neonCyan,
                  label: 'Top Journal',
                  value: dashboard.topJournal ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _InsightRow(
                  icon: Icons.person_outline,
                  iconColor: AppColors.neonLime,
                  label: 'Top Author',
                  value: dashboard.topAuthor ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _InsightRow(
                  icon: Icons.workspace_premium_outlined,
                  iconColor: AppColors.goldBadge,
                  label: 'Most Influential',
                  value: dashboard.mostInfluentialPaper?.title ?? 'N/A',
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                _TintedButton(
                  icon: Icons.dashboard_outlined,
                  label: 'Open Research Dashboard',
                  accentColor: AppColors.purpleAccent,
                  enabled: true,
                  onTap: () => _openDashboard(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Top Journals & Authors ─────────────────────────────────────
          const _SectionHeader(
            label: 'Top Journals & Authors',
            accentColor: AppColors.neonLime,
          ),
          const SizedBox(height: 12),
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most active venues and contributing researchers for this topic.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                _RankList(
                  dotColor: AppColors.neonCyan,
                  label: 'Journals',
                  items: previewJournals
                      .map((j) => '${j.name}  ·  ${j.publicationCount} papers')
                      .toList(),
                  emptyText: 'No journal data yet.',
                ),
                const SizedBox(height: 12),
                _RankList(
                  dotColor: AppColors.neonLime,
                  label: 'Authors',
                  items: previewAuthors
                      .map((a) => '${a.name}  ·  ${a.publicationCount} papers')
                      .toList(),
                  emptyText: 'No author data yet.',
                ),
                const SizedBox(height: 14),
                _TintedButton(
                  icon: Icons.groups_2_outlined,
                  label: 'View Top Journals & Authors',
                  accentColor: AppColors.neonLime,
                  enabled: contributors.topJournals.isNotEmpty ||
                      contributors.topAuthors.isNotEmpty,
                  onTap: (contributors.topJournals.isEmpty &&
                          contributors.topAuthors.isEmpty)
                      ? null
                      : () => _openContributors(context, contributors),
                ),
              ],
            ),
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
  const _TopicHero({required this.topic});

  final String topic;

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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonCyan.withValues(alpha:0.12),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha:0.3)),
            ),
            child: const Icon(
              Icons.trending_up,
              color: AppColors.neonCyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TREND TOPIC',
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
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
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
  const _MetricsRow({required this.analysis});

  final TrendAnalysisResult analysis;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.library_books_outlined,
            iconColor: AppColors.neonCyan,
            label: 'Total',
            value: '${analysis.totalPublications}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.calendar_month_outlined,
            iconColor: AppColors.neonLime,
            label: 'Peak Year',
            value: analysis.mostActiveYear?.toString() ?? 'N/A',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.date_range_outlined,
            iconColor: AppColors.purpleAccent,
            label: 'Range',
            value: analysis.yearRangeLabel,
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

// ─── Glass Card ───────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: child,
    );
  }
}

// ─── Tinted Action Button ─────────────────────────────────────────────────────

class _TintedButton extends StatelessWidget {
  const _TintedButton({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.38,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha:0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withValues(alpha:0.28)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accentColor, size: 17),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Paper Rank Row ───────────────────────────────────────────────────────────

class _PaperRankRow extends StatelessWidget {
  const _PaperRankRow({required this.rank, required this.paper});

  final int rank;
  final Publication paper;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.goldBadge.withValues(alpha:0.15),
            border: Border.all(color: AppColors.goldBadge.withValues(alpha:0.4)),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.goldBadge,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paper.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.goldBadge,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${paper.citationCount} citations',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.goldBadge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Insight Row ──────────────────────────────────────────────────────────────

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: iconColor.withValues(alpha:0.12),
            border: Border.all(color: iconColor.withValues(alpha:0.25)),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Rank List ────────────────────────────────────────────────────────────────

class _RankList extends StatelessWidget {
  const _RankList({
    required this.dotColor,
    required this.label,
    required this.items,
    required this.emptyText,
  });

  final Color dotColor;
  final String label;
  final List<String> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: dotColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            emptyText,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          )
        else
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Text(
                    '${entry.key + 1}.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: dotColor.withValues(alpha:0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
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

// ─── Empty Note ───────────────────────────────────────────────────────────────

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.textSecondary.withValues(alpha:0.5),
            size: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
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
