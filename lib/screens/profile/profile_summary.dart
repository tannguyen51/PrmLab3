import '../../models/publication.dart';

class ProfileSummary {
  const ProfileSummary({
    required this.currentTopic,
    required this.publicationCount,
    required this.journalCount,
    required this.highlightLabel,
    required this.highlightValue,
  });

  final String currentTopic;
  final int publicationCount;
  final int journalCount;
  final String highlightLabel;
  final String highlightValue;

  factory ProfileSummary.fromSearchState({
    required String topic,
    required List<Publication> publications,
  }) {
    final journalCounts = <String, int>{};
    for (final publication in publications) {
      final journal = publication.journalName.trim();
      if (journal.isNotEmpty && journal != 'Unknown journal') {
        journalCounts[journal] = (journalCounts[journal] ?? 0) + 1;
      }
    }

    final rankedJournals = journalCounts.entries.toList()
      ..sort((left, right) {
        final byCount = right.value.compareTo(left.value);
        if (byCount != 0) {
          return byCount;
        }
        return left.key.compareTo(right.key);
      });

    final topJournal = rankedJournals.isEmpty ? null : rankedJournals.first;

    return ProfileSummary(
      currentTopic: topic.isEmpty ? 'No topic searched yet' : topic,
      publicationCount: publications.length,
      journalCount: journalCounts.length,
      highlightLabel: 'Top venue',
      highlightValue: topJournal == null ? 'No venue data' : topJournal.key,
    );
  }
}
