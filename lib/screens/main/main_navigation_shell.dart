import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/theme/app_colors.dart';
import '../../services/analytics_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/profile_firebase_service.dart';
import '../../state/search_provider.dart';
import '../journals/journals_screen.dart';
import '../keywords/keywords_screen.dart';
import '../profile/profile_summary.dart';
import '../search/search_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const SearchScreen(),
      const JournalsScreen(),
      const KeywordsScreen(),
      const _ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.neonCyan.withValues(alpha: 0.16),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Journals',
          ),
          NavigationDestination(
            icon: Icon(Icons.label_outline),
            selectedIcon: Icon(Icons.label),
            label: 'Keywords',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool _isExporting = false;
  bool _isLoadingRemoteConfig = false;
  String _reportStatus = 'Ready to export dashboard analytics.';
  String _remoteConfigStatus = 'Loading Remote Config values...';
  String _notificationsStatus = 'Loading notifications...';
  String? _reportUrl;
  Map<String, String> _remoteConfigValues = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profileService = context.read<ProfileFirebaseService>();
      _loadProfileDemoData(profileService);
    });
  }

  Future<void> _loadProfileDemoData(
    ProfileFirebaseService profileService,
  ) async {
    if (!mounted) return;
    setState(() {
      _isLoadingRemoteConfig = true;
      _notificationsStatus = 'Loading notifications...';
      _remoteConfigStatus = 'Loading Remote Config values...';
    });

    try {
      final remoteConfigValues = await profileService.loadRemoteConfigValues();

      if (!mounted) return;
      setState(() {
        _notificationsStatus = 'Notifications ready';
        _remoteConfigValues = remoteConfigValues;
        _remoteConfigStatus = 'Remote Config ready';
        _isLoadingRemoteConfig = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _notificationsStatus = 'Using demo notifications';
        _remoteConfigStatus = 'Remote Config fallback ready';
        _isLoadingRemoteConfig = false;
      });
      debugPrint('Profile demo data load failed: $error');
    }
  }

  Future<void> _exportReport(
    ProfileFirebaseService profileService,
    SearchProvider searchProvider,
  ) async {
    if (!mounted) return;
    setState(() {
      _isExporting = true;
      _reportStatus = 'Generating PDF report...';
    });

    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Journal Trend Analyzer Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Topic: ${searchProvider.currentTopic.isEmpty ? 'No topic yet' : searchProvider.currentTopic}',
                ),
                pw.Text('Publications: ${searchProvider.publications.length}'),
                pw.Text(
                  'Journals discovered: ${searchProvider.publications.map((publication) => publication.journalName).toSet().length}',
                ),
                pw.SizedBox(height: 12),
                pw.Text('Sample publications:'),
                ...searchProvider.publications
                    .take(3)
                    .map((publication) => pw.Text('- ${publication.title}')),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final result = await profileService.exportPdfReport(pdfBytes);

      if (!mounted) return;
      setState(() {
        _isExporting = false;
        _reportStatus = result.message;
        _reportUrl = result.url;
      });

      if (result.success) {
        final analytics = context.read<AnalyticsService>();
        await analytics.logExportPdf(
          searchProvider.currentTopic.isEmpty
              ? 'current session'
              : searchProvider.currentTopic,
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
        _reportStatus = 'Failed to export report: $error';
      });
    }
  }

  Future<void> _triggerCrash(
    ProfileFirebaseService profileService,
    bool handled,
  ) async {
    if (handled) {
      await profileService.generateHandledException();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Handled exception logged to Crashlytics.'),
        ),
      );
    } else {
      await profileService.generateTestCrash();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Test crash requested.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<FirebaseAuthService>();
    final profileService = context.read<ProfileFirebaseService>();
    final user = authService.currentUser;
    final searchProvider = context.watch<SearchProvider>();
    final summary = ProfileSummary.fromSearchState(
      topic: searchProvider.currentTopic,
      publications: searchProvider.publications,
    );
    final notificationsFallback = [
      'New trending research topic.',
      'Highly cited publication alert.',
      'Research trend updates.',
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _ProfileHeaderCard(user: user),
          const SizedBox(height: 16),
          _ProfileInsightCard(summary: summary),
          const SizedBox(height: 16),
          _ActionCard(
            title: 'Research context',
            subtitle: summary.currentTopic,
            icon: Icons.insights_rounded,
            color: AppColors.neonCyan,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Session status',
            subtitle: searchProvider.currentTopic.isEmpty
                ? 'No topic searched yet'
                : 'Showing ${searchProvider.publications.length} papers for your last search',
            icon: Icons.search_rounded,
            color: AppColors.neonLime,
          ),
          const SizedBox(height: 16),
          _FirebaseSectionCard(
            title: 'Notification Center',
            subtitle: _notificationsStatus,
            icon: Icons.notifications_active_rounded,
            color: AppColors.neonCyan,
            onRefresh: () => _loadProfileDemoData(profileService),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final notification in profileService.notificationMessages.isEmpty
                    ? notificationsFallback
                    : profileService.notificationMessages)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          size: 10,
                          color: AppColors.neonLime,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _FirebaseSectionCard(
            title: 'Report Export',
            subtitle: _reportStatus,
            icon: Icons.picture_as_pdf_rounded,
            color: AppColors.neonLime,
            onRefresh: () => _exportReport(profileService, searchProvider),
            isBusy: _isExporting,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _reportStatus,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_reportUrl != null) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    _reportUrl!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neonCyan,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _FirebaseSectionCard(
            title: 'Remote Config Demo',
            subtitle: _remoteConfigStatus,
            icon: Icons.tune_rounded,
            color: AppColors.neonCyan,
            onRefresh: () => _loadProfileDemoData(profileService),
            isBusy: _isLoadingRemoteConfig,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in _remoteConfigValues.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _FirebaseSectionCard(
            title: 'Crashlytics Demo',
            subtitle: 'Generate a handled exception or a test crash.',
            icon: Icons.bug_report_rounded,
            color: const Color(0xFFFF7A59),
            onRefresh: () async {},
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _triggerCrash(profileService, true),
                    icon: const Icon(Icons.error_outline_rounded),
                    label: const Text('Handled exception'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _triggerCrash(profileService, false),
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('Test crash'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.read<AnalyticsService>().logLogout();
                await authService.signOut();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirebaseSectionCard extends StatelessWidget {
  const _FirebaseSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.child,
    required this.onRefresh,
    this.isBusy = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isBusy ? null : () async => onRefresh(),
                icon: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textSecondary,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            backgroundColor: AppColors.neonCyan.withValues(alpha: 0.16),
            child: user?.photoURL == null
                ? const Icon(Icons.person, color: AppColors.neonCyan)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Signed in user',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'No email available',
                  style: const TextStyle(
                    fontSize: 13,
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

class _ProfileInsightCard extends StatelessWidget {
  const _ProfileInsightCard({required this.summary});

  final ProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current research snapshot',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary.currentTopic,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Papers',
                  value: '${summary.publicationCount}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Venues',
                  value: '${summary.journalCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neonLime.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${summary.highlightLabel}: ${summary.highlightValue}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.neonLime,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
