import '../models/publication.dart';

class InfluentialAnalyzer {
  const InfluentialAnalyzer._();

  static List<Publication> topPapers(
    List<Publication> publications, {
    int limit = 10,
  }) {
    if (limit <= 0) {
      return const [];
    }

    final ranked = List<Publication>.from(publications)
      ..sort((left, right) {
        final byCitation = right.citationCount.compareTo(left.citationCount);
        if (byCitation != 0) {
          return byCitation;
        }

        final leftYear = left.publicationYear ?? 0;
        final rightYear = right.publicationYear ?? 0;
        final byYear = rightYear.compareTo(leftYear);
        if (byYear != 0) {
          return byYear;
        }

        return left.title.compareTo(right.title);
      });

    return ranked.take(limit).toList(growable: false);
  }
}
