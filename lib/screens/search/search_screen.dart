import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/publication.dart';
import '../detail/publication_detail_screen.dart';
import '../trend/trend_analysis_screen.dart';
import '../../state/search_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/publication_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _submitSearch(BuildContext context) {
    return context.read<SearchProvider>().search(_topicController.text);
  }

  Future<void> _openPublicationDetail(
    BuildContext context,
    Publication publication,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PublicationDetailScreen(publication: publication),
      ),
    );
  }

  Future<void> _openTrendAnalysis(
    BuildContext context,
    SearchProvider provider,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrendAnalysisScreen(
          topic: provider.currentTopic,
          publications: provider.publications,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Trend Analyzer'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<SearchProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: provider.currentTopic.isEmpty
                  ? () async {}
                  : () => provider.search(provider.currentTopic),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchHeader(
                    controller: _topicController,
                    isLoading: provider.isLoading,
                    onSearch: () => _submitSearch(context),
                  ),
                  const SizedBox(height: 20),
                  _SearchSummary(provider: provider),
                  if (provider.publications.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openTrendAnalysis(context, provider),
                        icon: const Icon(Icons.bar_chart_rounded),
                        label: const Text('View Trend Analysis'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (provider.isLoading)
                    const LoadingView(
                      message: 'Loading publications from OpenAlex...',
                    )
                  else if (provider.errorMessage != null)
                    ErrorView(
                      message: provider.errorMessage!,
                      onRetry: provider.currentTopic.isEmpty
                          ? null
                          : () => provider.search(provider.currentTopic),
                    )
                  else if (provider.publications.isEmpty)
                    _EmptyResult(hasSearched: provider.hasSearched)
                  else
                    ...provider.publications.map((publication) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PublicationCard(
                          publication: publication,
                          onTap: () =>
                              _openPublicationDetail(context, publication),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.isLoading,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Analyze publication trends for any research topic.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start with a live OpenAlex search to explore papers, years, citations, and journals.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            enabled: !isLoading,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: 'Enter a topic, for example Artificial Intelligence',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onSearch,
              icon: const Icon(Icons.travel_explore),
              label: const Text('Search OpenAlex'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSummary extends StatelessWidget {
  const _SearchSummary({required this.provider});

  final SearchProvider provider;

  @override
  Widget build(BuildContext context) {
    final label = provider.currentTopic.isEmpty
        ? 'No topic selected yet.'
        : 'Topic: ${provider.currentTopic}';

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(title: 'Current Search', value: label),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Results',
            value: '${provider.publications.length} publications',
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: const Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.hasSearched});

  final bool hasSearched;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            hasSearched ? Icons.find_in_page_outlined : Icons.auto_awesome,
            size: 48,
            color: const Color(0xFF0F766E),
          ),
          const SizedBox(height: 12),
          Text(
            hasSearched
                ? 'No publications matched this topic.'
                : 'Search a topic to start the first analysis slice.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearched
                ? 'Try a broader keyword such as Data Science or Cybersecurity.'
                : 'This screen already runs end-to-end from input to OpenAlex results.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
