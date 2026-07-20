import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/keyword_summary.dart';
import '../../models/publication.dart';
import '../../services/analytics_service.dart';
import '../../services/profile_firebase_service.dart';
import '../../state/keyword_analyzer.dart';
import '../../state/search_provider.dart';
import 'keyword_detail_screen.dart';

class KeywordsScreen extends StatefulWidget {
  const KeywordsScreen({super.key});

  @override
  State<KeywordsScreen> createState() => _KeywordsScreenState();
}

class _KeywordsScreenState extends State<KeywordsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final analytics = context.read<AnalyticsService>();
    final keywordLimit = ProfileFirebaseService.parseConfiguredLimit(
      _remoteConfigValues['max_keywords'],
      4,
    );
    final keywords = KeywordAnalyzer.analyze(
      provider.publications,
      topic: provider.currentTopic,
      limit: keywordLimit,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: ListView(
          children: [
            const Text(
              'Keywords',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.currentTopic.isEmpty
                  ? 'Explore the most repeated terms from the current topic search.'
                  : 'Keywords for "${provider.currentTopic}" based on titles, abstracts, and author metadata.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            if (provider.currentTopic.isEmpty)
              const _EmptyState(
                icon: Icons.label_outline,
                title: 'Search a topic first',
                message:
                    'The keyword insights will appear here once you search for publications.',
              )
            else if (provider.publications.isEmpty)
              const _EmptyState(
                icon: Icons.search_off_outlined,
                title: 'No keyword data yet',
                message:
                    'Try a broader search term to extract recurring keywords.',
              )
            else if (keywords.isEmpty)
              const _EmptyState(
                icon: Icons.tag_outlined,
                title: 'No keywords found',
                message:
                    'The search results did not contain enough text to build keyword insights.',
              )
            else ...[
              _KeywordSummaryCard(
                count: keywords.length,
                topic: provider.currentTopic,
              ),
              const SizedBox(height: 16),
              _FrequencySnapshotCard(keywords: keywords),
              const SizedBox(height: 16),
              _TrendingKeywordsSection(
                publications: provider.publications,
                topic: provider.currentTopic,
                onKeywordTap: (keyword) {
                  analytics.logViewKeyword(keyword.keyword);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => KeywordDetailScreen(
                        keyword: keyword,
                        topic: provider.currentTopic,
                        publications: provider.publications,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ...keywords.map((keyword) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _KeywordRow(
                    keyword: keyword,
                    onTap: () {
                      analytics.logViewKeyword(keyword.keyword);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => KeywordDetailScreen(
                            keyword: keyword,
                            topic: provider.currentTopic,
                            publications: provider.publications,
                          ),
                        ),
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

class _KeywordSummaryCard extends StatelessWidget {
  const _KeywordSummaryCard({required this.count, required this.topic});

  final int count;
  final String topic;

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
              color: AppColors.neonLime.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.neonLime.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.label_outline,
              color: AppColors.neonLime,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top recurring terms',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$count keywords for "$topic"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focused on recurring research terms and domain-relevant concepts.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
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

class _FrequencySnapshotCard extends StatelessWidget {
  const _FrequencySnapshotCard({required this.keywords});

  final List<KeywordSummary> keywords;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) {
      return const SizedBox.shrink();
    }

    final topKeywords = keywords.take(4).toList(growable: false);
    final maxCount = topKeywords
        .map((keyword) => keyword.publicationCount)
        .reduce((left, right) => left > right ? left : right);

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
          const Text(
            'Frequency snapshot',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          ...topKeywords.map((keyword) {
            final ratio = maxCount <= 0
                ? 0.0
                : keyword.publicationCount / maxCount;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          keyword.keyword,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${keyword.publicationCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonLime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: AppColors.borderGlassHigh,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.neonCyan,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _KeywordRow extends StatelessWidget {
  const _KeywordRow({required this.keyword, required this.onTap});

  final KeywordSummary keyword;
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
                color: AppColors.neonLime.withValues(alpha: 0.14),
              ),
              child: Text(
                '#${keyword.publicationCount}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonLime,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keyword.keyword,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${keyword.publicationCount} publications',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
          Icon(icon, size: 44, color: AppColors.neonLime),
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

class _TrendingKeywordsSection extends StatelessWidget {
  const _TrendingKeywordsSection({
    required this.publications,
    required this.topic,
    required this.onKeywordTap,
  });

  final List<Publication> publications;
  final String topic;
  final void Function(KeywordSummary) onKeywordTap;

  @override
  Widget build(BuildContext context) {
    final trending = KeywordAnalyzer.analyzeTrending(
      publications,
      topic: topic,
      limit: 5,
    );

    if (trending.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A59),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.trending_up, color: Color(0xFFFF7A59), size: 18),
            const SizedBox(width: 6),
            const Text(
              'Trending Keywords',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF7A59).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF7A59).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < trending.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == trending.length - 1 ? 0 : 10,
                  ),
                  child: _TrendingKeywordRow(
                    keyword: trending[i],
                    onTap: () => onKeywordTap(trending[i]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrendingKeywordRow extends StatelessWidget {
  const _TrendingKeywordRow({
    required this.keyword,
    required this.onTap,
  });

  final KeywordSummary keyword;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF7A59).withValues(alpha: 0.14),
              ),
              child: const Icon(
                Icons.trending_up,
                color: Color(0xFFFF7A59),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keyword.keyword,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${keyword.publicationCount} recent publications',
                    style: const TextStyle(
                      fontSize: 12,
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
