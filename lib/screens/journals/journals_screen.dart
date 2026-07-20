import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/journal_summary.dart';
import '../../models/publication.dart';
import '../../services/analytics_service.dart';
import '../../services/profile_firebase_service.dart';
import '../../state/contributors_analyzer.dart';
import '../../state/search_provider.dart';
import 'journal_detail_screen.dart';

class JournalsScreen extends StatefulWidget {
  const JournalsScreen({super.key});

  @override
  State<JournalsScreen> createState() => _JournalsScreenState();
}

class _JournalsScreenState extends State<JournalsScreen> {
  Map<String, String> _remoteConfigValues = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadRemoteConfig();
    });
  }

  Future<void> _loadRemoteConfig() async {
    final profileService = context.read<ProfileFirebaseService>();
    final values = await profileService.loadRemoteConfigValues();
    if (!mounted) return;
    setState(() {
      _remoteConfigValues = values;
    });
  }

  Future<void> _openJournal(
    BuildContext context,
    JournalSummary journal,
    String topic,
    List<Publication> publications,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JournalDetailScreen(
          journal: journal,
          topic: topic,
          publications: publications,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final analytics = context.read<AnalyticsService>();
    final journalLimit = ProfileFirebaseService.parseConfiguredLimit(
      _remoteConfigValues['max_journals'],
      4,
    );
    final journals = ContributorsAnalyzer.analyze(
      provider.publications,
      limit: journalLimit,
    ).topJournals;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Text(
              'Journals',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.currentTopic.isEmpty
                  ? 'Search for a research topic on the Home tab to explore the most active journals.'
                  : 'Review the top venues for "${provider.currentTopic}" and tap a journal to see the latest publications.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            if (provider.currentTopic.isEmpty)
              const _EmptyJournalState(
                icon: Icons.search_off_outlined,
                title: 'Start with a topic search',
                message:
                    'The journal ranking will appear after you search for papers.',
              )
            else if (provider.publications.isEmpty)
              const _EmptyJournalState(
                icon: Icons.bookmarks_outlined,
                title: 'No journal data yet',
                message:
                    'We could not identify journals for this topic. Try a broader search term.',
              )
            else if (journals.isEmpty)
              const _EmptyJournalState(
                icon: Icons.menu_book_outlined,
                title: 'No journal ranking available',
                message:
                    'Publication metadata did not contain a journal value to rank.',
              )
            else ...[
              _JournalSummaryCard(
                count: journals.length,
                topic: provider.currentTopic,
                publications: provider.publications,
              ),
              const SizedBox(height: 16),
              _JournalContributionChart(journals: journals),
              const SizedBox(height: 16),
              ...journals.asMap().entries.map((entry) {
                final journal = entry.value;
                final journalPublications = provider.publications
                    .where(
                      (publication) => publication.journalName == journal.name,
                    )
                    .toList(growable: false);
                final citationTotal = journalPublications.fold<int>(
                  0,
                  (sum, publication) => sum + publication.citationCount,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _JournalRow(
                    rank: entry.key + 1,
                    journal: journal,
                    publicationCount: journalPublications.length,
                    citationCount: citationTotal,
                    onTap: () {
                      analytics.logViewJournal(journal.name);
                      _openJournal(
                        context,
                        journal,
                        provider.currentTopic,
                        provider.publications,
                      );
                    },
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _JournalSummaryCard extends StatelessWidget {
  const _JournalSummaryCard({
    required this.count,
    required this.topic,
    required this.publications,
  });

  final int count;
  final String topic;
  final List<Publication> publications;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonCyan.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.neonCyan,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top journals identified',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$count journals for "$topic"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${publications.length} publications analyzed • ${publications.fold<int>(0, (sum, publication) => sum + publication.citationCount)} total citations',
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

class _JournalRow extends StatelessWidget {
  const _JournalRow({
    required this.rank,
    required this.journal,
    required this.publicationCount,
    required this.citationCount,
    required this.onTap,
  });

  final int rank;
  final JournalSummary journal;
  final int publicationCount;
  final int citationCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGlassHigh),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonCyan.withValues(alpha: 0.14),
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonCyan,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    journal.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$publicationCount papers • $citationCount citations',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _JournalContributionChart extends StatelessWidget {
  const _JournalContributionChart({required this.journals});

  final List<JournalSummary> journals;

  @override
  Widget build(BuildContext context) {
    if (journals.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.neonCyan,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Contribution by Journal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                      sections: _buildSections(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildLegend(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colors = [
      AppColors.neonCyan,
      AppColors.neonLime,
      const Color(0xFFFF7A59),
      const Color(0xFFD0BCFF),
      const Color(0xFFFACC15),
      const Color(0xFF7DD3FC),
      AppColors.purpleAccent,
    ];

    return journals.take(7).toList().asMap().entries.map((entry) {
      final total = journals.fold<int>(0, (s, j) => s + j.publicationCount);
      final percentage = total > 0
          ? (entry.value.publicationCount / total * 100).toStringAsFixed(0)
          : '0';
      return PieChartSectionData(
        color: colors[entry.key % colors.length],
        value: entry.value.publicationCount.toDouble(),
        title: '$percentage%',
        radius: 48,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    final colors = [
      AppColors.neonCyan,
      AppColors.neonLime,
      const Color(0xFFFF7A59),
      const Color(0xFFD0BCFF),
      const Color(0xFFFACC15),
      const Color(0xFF7DD3FC),
      AppColors.purpleAccent,
    ];

    return journals.take(7).toList().asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[entry.key % colors.length],
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                entry.value.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _EmptyJournalState extends StatelessWidget {
  const _EmptyJournalState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

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
        children: [
          Icon(icon, size: 44, color: AppColors.neonCyan),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
