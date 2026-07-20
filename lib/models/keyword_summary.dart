class KeywordSummary {
  const KeywordSummary({
    required this.keyword,
    required this.publicationCount,
    this.trendingScore,
  });

  final String keyword;
  final int publicationCount;
  final double? trendingScore;

  bool get isTrending => trendingScore != null && trendingScore! > 1.2;
}
