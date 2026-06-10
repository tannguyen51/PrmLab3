import 'package:flutter/material.dart';

import '../../models/publication.dart';
import '../../state/influential_analyzer.dart';
import '../../state/trend_analyzer.dart';
import '../../widgets/trend_chart.dart';
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
        builder: (_) =>
            TopInfluentialPapersScreen(topic: topic, papers: papers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysis = TrendAnalyzer.analyze(publications);
    final topInfluential = InfluentialAnalyzer.topPapers(publications);
    final previewPapers = topInfluential.take(3).toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Trend Analysis')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _TopicBanner(topic: topic),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'Total Publications',
                  value: '${analysis.totalPublications}',
                ),
                _MetricCard(
                  label: 'Most Active Year',
                  value: analysis.mostActiveYear?.toString() ?? 'N/A',
                ),
                _MetricCard(
                  label: 'Year Range',
                  value: analysis.yearRangeLabel,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Publications by Year',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This chart shows growth or decline in publication activity for the selected topic.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TrendChart(points: analysis.points),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Influential Papers',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (previewPapers.isEmpty)
                    Text(
                      'No publication data to rank by citation count yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...previewPapers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final paper = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${index + 1}. ${paper.title} (${paper.citationCount} citations)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: topInfluential.isEmpty
                          ? null
                          : () =>
                                _openInfluentialPapers(context, topInfluential),
                      icon: const Icon(Icons.leaderboard_outlined),
                      label: const Text('View Full Ranking'),
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

class _TopicBanner extends StatelessWidget {
  const _TopicBanner({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF164E63), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Topic',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            topic,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
