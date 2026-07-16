import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/keyword_summary.dart';
import '../../services/analytics_service.dart';
import '../../state/keyword_analyzer.dart';
import '../../state/search_provider.dart';
import 'keyword_detail_screen.dart';

class KeywordsScreen extends StatelessWidget {
  const KeywordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final analytics = context.read<AnalyticsService>();
    final keywords = KeywordAnalyzer.analyze(
      provider.publications,
      topic: provider.currentTopic,
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
              ],
            ),
          ),
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
