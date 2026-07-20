import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../models/publication.dart';
import '../../services/analytics_service.dart';

class PublicationDetailScreen extends StatefulWidget {
  const PublicationDetailScreen({super.key, required this.publication});

  final Publication publication;

  @override
  State<PublicationDetailScreen> createState() =>
      _PublicationDetailScreenState();
}

class _PublicationDetailScreenState extends State<PublicationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analytics = Provider.of<AnalyticsService>(context, listen: false);
      analytics.logViewPublication(
        widget.publication.title,
        widget.publication.publicationYear,
      );
    });
  }

  String _authorsDisplay() {
    final names = widget.publication.authorNames;
    if (names.isEmpty) return 'Unknown authors';
    if (names.length <= 4) return names.join(', ');
    final shown = names.take(3).join(', ');
    final extra = names.length - 3;
    return '$shown  +$extra more';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _DarkAppBar(title: 'Publication Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: title + authors ───────────────────────────────
            _HeaderCard(
              title: widget.publication.title,
              authorsDisplay: _authorsDisplay(),
            ),
            const SizedBox(height: 16),

            // ── Metadata chips: year / citations / journal ────────────
            _MetadataSection(publication: widget.publication),
            const SizedBox(height: 24),

            // ── DOI ───────────────────────────────────────────────────
            const _SectionHeader(label: 'DOI', accentColor: AppColors.neonCyan),
            const SizedBox(height: 10),
            _DoiCard(doi: widget.publication.doi),
            const SizedBox(height: 24),

            // ── Abstract ──────────────────────────────────────────────
            const _SectionHeader(
              label: 'Abstract',
              accentColor: AppColors.neonLime,
            ),
            const SizedBox(height: 10),
            _AbstractCard(abstractText: widget.publication.abstractText),
          ],
        ),
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
          backgroundColor: AppColors.surface.withValues(alpha: 0.85),
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

// ─── Header Card ─────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.title, required this.authorsDisplay});

  final String title;
  final String authorsDisplay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGlassHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Biotech icon pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.biotech_outlined,
                  color: AppColors.neonCyan,
                  size: 13,
                ),
                SizedBox(width: 5),
                Text(
                  'PUBLICATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.neonCyan,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Title
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          // Authors
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
                size: 15,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  authorsDisplay,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Metadata Section ─────────────────────────────────────────────────────────

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.publication});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // Year chip
        _MetaChip(
          icon: Icons.calendar_month_outlined,
          iconColor: AppColors.neonCyan,
          label: publication.publicationYear?.toString() ?? 'Year unknown',
        ),
        // Citation badge — gold
        _MetaChip(
          icon: Icons.star_rounded,
          iconColor: AppColors.goldBadge,
          label: '${publication.citationCount} Citations',
          isGold: true,
        ),
        // Journal chip
        _MetaChip(
          icon: Icons.menu_book_outlined,
          iconColor: AppColors.neonLime,
          label: publication.journalName,
          maxWidth: 260,
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.isGold = false,
    this.maxWidth,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isGold;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final bg = isGold
        ? AppColors.goldBadge.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.04);
    final border = isGold
        ? AppColors.goldBadge.withValues(alpha: 0.3)
        : AppColors.borderGlass;
    final textColor = isGold ? AppColors.goldBadge : AppColors.textPrimary;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 15),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DOI Card ─────────────────────────────────────────────────────────────────

class _DoiCard extends StatelessWidget {
  const _DoiCard({required this.doi});

  final String? doi;

  Future<void> _copyToClipboard(BuildContext context) async {
    if (doi == null) return;
    await Clipboard.setData(ClipboardData(text: doi!));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('DOI copied to clipboard'),
          backgroundColor: AppColors.surfaceContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDoi = doi != null && doi!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonCyan.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.link_outlined,
              color: AppColors.neonCyan,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasDoi ? doi! : 'DOI not available',
              style: TextStyle(
                fontSize: 13,
                color: hasDoi ? AppColors.textPrimary : AppColors.textSecondary,
                fontStyle: hasDoi ? FontStyle.normal : FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
          if (hasDoi) ...[
            const SizedBox(width: 8),
            // Open in browser
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse('https://doi.org/$doi');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.open_in_new,
                  color: AppColors.neonCyan,
                  size: 15,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _copyToClipboard(context),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.copy_outlined,
                  color: AppColors.neonCyan,
                  size: 15,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Abstract Card ────────────────────────────────────────────────────────────

class _AbstractCard extends StatelessWidget {
  const _AbstractCard({required this.abstractText});

  final String? abstractText;

  @override
  Widget build(BuildContext context) {
    final hasAbstract = abstractText != null && abstractText!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: hasAbstract
          ? Text(
              abstractText!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.65,
              ),
            )
          : Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Abstract not available for this publication.',
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
}

// ─── Section Header ───────────────────────────────────────────────────────────

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
