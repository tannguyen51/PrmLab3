import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/publication.dart';
import '../../state/contributors_analyzer.dart';
import '../../state/search_provider.dart';
import '../../state/trend_analyzer.dart';
import '../contributors/top_contributors_screen.dart';
import '../dashboard/research_dashboard_screen.dart';
import '../detail/publication_detail_screen.dart';
import '../influential/top_influential_papers_screen.dart';
import '../trend/trend_analysis_screen.dart';

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

  Future<void> _submitSearch() {
    return context.read<SearchProvider>().search(_topicController.text);
  }

  void _fillAndSearch(String topic) {
    _topicController.text = topic;
    _submitSearch();
  }

  Future<void> _openDetail(Publication pub) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PublicationDetailScreen(publication: pub),
      ),
    );
  }

  Future<void> _openTrend(SearchProvider provider) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrendAnalysisScreen(
          topic: provider.currentTopic,
          publications: provider.publications,
        ),
      ),
    );
  }

  Future<void> _openDashboard(SearchProvider provider) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResearchDashboardScreen(
          topic: provider.currentTopic,
          publications: provider.publications,
        ),
      ),
    );
  }

  Future<void> _openTopPapers(SearchProvider provider) {
    final sorted = [...provider.publications]
      ..sort((a, b) => b.citationCount.compareTo(a.citationCount));
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopInfluentialPapersScreen(
          topic: provider.currentTopic,
          papers: sorted,
        ),
      ),
    );
  }

  Future<void> _openContributors(SearchProvider provider) {
    final result = ContributorsAnalyzer.analyze(provider.publications);
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopContributorsScreen(
          topic: provider.currentTopic,
          journals: result.topJournals,
          authors: result.topAuthors,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          appBar: _StitchAppBar(),
          body: RefreshIndicator(
            color: AppColors.neonCyan,
            backgroundColor: AppColors.surfaceContainer,
            onRefresh: provider.currentTopic.isEmpty
                ? () async {}
                : () => provider.search(provider.currentTopic),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
              children: [
                _HeroCard(
                  controller: _topicController,
                  isLoading: provider.isLoading,
                  onSearch: _submitSearch,
                  onChipTap: _fillAndSearch,
                ),
                const SizedBox(height: 24),
                _InsightCardsRow(provider: provider),
                const SizedBox(height: 24),
                _QuickActionsSection(
                  hasData: provider.publications.isNotEmpty,
                  onTrendTap: () => _openTrend(provider),
                  onDashboardTap: () => _openDashboard(provider),
                  onTopPapersTap: () => _openTopPapers(provider),
                  onContributorsTap: () => _openContributors(provider),
                ),
                const SizedBox(height: 24),
                if (provider.isLoading)
                  const _LoadingSection()
                else if (provider.errorMessage != null)
                  _ErrorSection(
                    message: provider.errorMessage!,
                    onRetry: provider.currentTopic.isEmpty
                        ? null
                        : () => provider.search(provider.currentTopic),
                  )
                else if (provider.publications.isEmpty)
                  _EmptySection(hasSearched: provider.hasSearched)
                else
                  _PublicationsPreview(
                    publications: provider.publications,
                    onTap: _openDetail,
                  ),
              ],
            ),
          ),
          bottomNavigationBar: _FloatingBottomNav(
            onTrendTap: provider.publications.isNotEmpty
                ? () => _openTrend(provider)
                : null,
            onDashboardTap: provider.publications.isNotEmpty
                ? () => _openDashboard(provider)
                : null,
            onMoreTap: provider.publications.isNotEmpty
                ? () => _openTopPapers(provider)
                : null,
          ),
        );
      },
    );
  }
}

// ─── AppBar ──────────────────────────────────────────────────────────────────

class _StitchAppBar extends StatelessWidget implements PreferredSizeWidget {
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
          leading: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.biotech_outlined, color: AppColors.neonCyan, size: 22),
          ),
          title: const Text(
            'Journal Trend Analyzer',
            style: TextStyle(
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

// ─── Hero Card ───────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.controller,
    required this.isLoading,
    required this.onSearch,
    required this.onChipTap,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;
  final void Function(String) onChipTap;

  static const _chips = ['Data Science', 'AI', 'Cybersecurity', 'Blockchain'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Orb 1 — top-left purple
            Positioned(
              top: -70,
              left: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF211C84).withValues(alpha:0.45),
                ),
              ),
            ),
            // Orb 2 — bottom-right cyan
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF06B6D4).withValues(alpha:0.35),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Gradient headline
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.neonCyan, AppColors.neonLime],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      'Discover research\ntrends instantly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Search OpenAlex to analyze papers, citations,\njournals, authors, and publication growth.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Search input + button — row on wide screens, column on narrow
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 520;
                      final searchInput = Container(
                        decoration: BoxDecoration(
                          color: AppColors.navyBase,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderGlassHigh),
                        ),
                        child: TextField(
                          controller: controller,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => onSearch(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search keywords, authors, journals...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha:0.55),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      );
                      final searchButton = DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.neonCyanDim, AppColors.neonLime],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withValues(alpha:0.22),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : onSearch,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF00363E),
                                  ),
                                )
                              : const Icon(Icons.arrow_forward, size: 18),
                          label: Text(
                            isLoading ? 'Searching…' : 'Search OpenAlex',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: const Color(0xFF00363E),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: searchInput),
                            const SizedBox(width: 12),
                            SizedBox(width: 180, height: 52, child: searchButton),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          searchInput,
                          const SizedBox(height: 10),
                          SizedBox(height: 48, child: searchButton),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'TRENDING TOPICS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _chips
                        .map(
                          (t) => _TopicChip(
                            label: t,
                            onTap: () => onChipTap(t),
                          ),
                        )
                        .toList(),
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

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.neonCyan.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.neonCyan.withValues(alpha:0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neonCyan,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

// ─── Insight Cards ───────────────────────────────────────────────────────────

class _InsightCardsRow extends StatelessWidget {
  const _InsightCardsRow({required this.provider});

  final SearchProvider provider;

  @override
  Widget build(BuildContext context) {
    final topic = provider.currentTopic.isEmpty ? '—' : provider.currentTopic;
    final count = provider.publications.length;
    int? mostActiveYear;
    if (provider.publications.isNotEmpty) {
      mostActiveYear =
          TrendAnalyzer.analyze(provider.publications).mostActiveYear;
    }

    return Row(
      children: [
        Expanded(
          child: _InsightCard(
            icon: Icons.category_outlined,
            iconColor: AppColors.neonCyan,
            accentColor: AppColors.neonCyan,
            label: 'Topic',
            value: topic,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InsightCard(
            icon: Icons.library_books_outlined,
            iconColor: AppColors.neonLime,
            accentColor: AppColors.neonLime,
            label: 'Results',
            value: count == 0 ? '—' : '$count',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InsightCard(
            icon: Icons.calendar_month_outlined,
            iconColor: AppColors.purpleAccent,
            accentColor: AppColors.purpleAccent,
            label: 'Peak Year',
            value: mostActiveYear?.toString() ?? '—',
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color accentColor;
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha:0.15),
              border: Border.all(color: iconColor.withValues(alpha:0.3)),
            ),
            child: Icon(icon, color: iconColor, size: 16),
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
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 24,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({
    required this.hasData,
    required this.onTrendTap,
    required this.onDashboardTap,
    required this.onTopPapersTap,
    required this.onContributorsTap,
  });

  final bool hasData;
  final VoidCallback onTrendTap;
  final VoidCallback onDashboardTap;
  final VoidCallback onTopPapersTap;
  final VoidCallback onContributorsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: 'Quick Actions', accentColor: AppColors.neonCyan),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 104,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            const items = [
              (Icons.trending_up, AppColors.neonCyan, 'Trend Analysis'),
              (Icons.dashboard_outlined, AppColors.neonLime, 'Research Dashboard'),
              (Icons.workspace_premium_outlined, AppColors.purpleAccent, 'Top Papers'),
              (Icons.groups_outlined, AppColors.neonCyan, 'Journals & Authors'),
            ];
            final (icon, color, label) = items[index];
            final callbacks = [onTrendTap, onDashboardTap, onTopPapersTap, onContributorsTap];
            return _QuickActionButton(
              icon: icon,
              iconColor: color,
              label: label,
              enabled: hasData,
              onTap: callbacks[index],
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.38,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGlass),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderGlass),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Publications Preview ─────────────────────────────────────────────────────

class _PublicationsPreview extends StatelessWidget {
  const _PublicationsPreview({
    required this.publications,
    required this.onTap,
  });

  final List<Publication> publications;
  final void Function(Publication) onTap;

  @override
  Widget build(BuildContext context) {
    final shown = publications.length > 10
        ? publications.sublist(0, 10)
        : publications;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: 'Trending Publications',
          accentColor: AppColors.neonLime,
        ),
        const SizedBox(height: 14),
        ...shown.map(
          (pub) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PublicationPreviewCard(
              publication: pub,
              onTap: () => onTap(pub),
            ),
          ),
        ),
      ],
    );
  }
}

class _PublicationPreviewCard extends StatelessWidget {
  const _PublicationPreviewCard({
    required this.publication,
    required this.onTap,
  });

  final Publication publication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = publication.citationCount > 50
        ? AppColors.neonCyan
        : AppColors.neonLime;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGlass),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: accentColor),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 14, 14, 14),
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year + journal
            Row(
              children: [
                if (publication.publicationYear != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBright,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${publication.publicationYear}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    publication.journalName,
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
            const SizedBox(height: 8),
            // Title
            Text(
              publication.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 5),
            // Authors
            Text(
              publication.authorsLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            // Citation badge
            Align(
              alignment: Alignment.centerRight,
              child: Container(
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
                    const SizedBox(width: 4),
                    Text(
                      '${publication.citationCount} Citations',
                      style: const TextStyle(
                        fontSize: 11,
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
    ),
  );
  }
}

// ─── State Sections ───────────────────────────────────────────────────────────

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              color: AppColors.neonCyan,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading publications from OpenAlex…',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neonCyan,
                side: const BorderSide(color: AppColors.neonCyan),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.hasSearched});

  final bool hasSearched;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Column(
        children: [
          Icon(
            hasSearched ? Icons.find_in_page_outlined : Icons.auto_awesome,
            size: 44,
            color: AppColors.neonCyan,
          ),
          const SizedBox(height: 14),
          Text(
            hasSearched
                ? 'No publications matched this topic.'
                : 'Search a topic to begin your analysis.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearched
                ? 'Try a broader keyword such as Data Science or Cybersecurity.'
                : 'Results come live from OpenAlex — no fake data.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Bottom Nav ──────────────────────────────────────────────────────

class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({
    required this.onTrendTap,
    required this.onDashboardTap,
    required this.onMoreTap,
  });

  final VoidCallback? onTrendTap;
  final VoidCallback? onDashboardTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha:0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderGlassHigh),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha:0.07),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: true,
                onTap: null,
              ),
              _NavItem(
                icon: Icons.trending_up,
                label: 'Trends',
                isActive: false,
                onTap: onTrendTap,
              ),
              _NavItem(
                icon: Icons.dashboard_outlined,
                label: 'Dash',
                isActive: false,
                onTap: onDashboardTap,
              ),
              _NavItem(
                icon: Icons.more_horiz,
                label: 'More',
                isActive: false,
                onTap: onMoreTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.neonCyan : AppColors.textSecondary;
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1.0 : 0.38,
      child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ─── Shared Section Header ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.accentColor});

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
