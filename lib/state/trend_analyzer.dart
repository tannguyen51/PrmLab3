import '../models/publication.dart';
import '../models/trend_point.dart';

class TrendAnalysisResult {
  const TrendAnalysisResult({
    required this.points,
    required this.totalPublications,
    required this.mostActiveYear,
    required this.mostActiveCount,
  });

  final List<TrendPoint> points;
  final int totalPublications;
  final int? mostActiveYear;
  final int mostActiveCount;

  String get yearRangeLabel {
    if (points.isEmpty) {
      return 'N/A';
    }

    final firstYear = points.first.year;
    final lastYear = points.last.year;
    if (firstYear == lastYear) {
      return '$firstYear';
    }
    return '$firstYear - $lastYear';
  }
}

class TrendAnalyzer {
  const TrendAnalyzer._();

  static TrendAnalysisResult analyze(List<Publication> publications) {
    final countsByYear = <int, int>{};

    for (final publication in publications) {
      final year = publication.publicationYear;
      if (year == null) {
        continue;
      }
      countsByYear[year] = (countsByYear[year] ?? 0) + 1;
    }

    final sortedYears = countsByYear.keys.toList()..sort();
    final points = sortedYears
        .map((year) => TrendPoint(year: year, count: countsByYear[year] ?? 0))
        .toList(growable: false);

    int? mostActiveYear;
    var mostActiveCount = 0;
    for (final point in points) {
      if (point.count > mostActiveCount) {
        mostActiveCount = point.count;
        mostActiveYear = point.year;
      }
    }

    return TrendAnalysisResult(
      points: points,
      totalPublications: publications.length,
      mostActiveYear: mostActiveYear,
      mostActiveCount: mostActiveCount,
    );
  }
}
