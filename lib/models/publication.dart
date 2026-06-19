class Publication {
  const Publication({
    required this.id,
    required this.title,
    required this.publicationYear,
    required this.citationCount,
    required this.journalName,
    required this.authorNames,
    required this.doi,
    required this.abstractText,
  });

  final String id;
  final String title;
  final int? publicationYear;
  final int citationCount;
  final String journalName;
  final List<String> authorNames;
  final String? doi;
  final String? abstractText;

  factory Publication.fromOpenAlex(Map<String, dynamic> json) {
    final primaryLocation = json['primary_location'] as Map<String, dynamic>?;
    final source = primaryLocation?['source'] as Map<String, dynamic>?;
    final authorships = json['authorships'] as List<dynamic>? ?? const [];

    return Publication(
      id: json['id'] as String? ?? '',
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Untitled publication',
      publicationYear: json['publication_year'] as int?,
      citationCount: (json['cited_by_count'] as num?)?.toInt() ?? 0,
      journalName:
          (source?['display_name'] as String?)?.trim().isNotEmpty == true
          ? (source?['display_name'] as String).trim()
          : 'Unknown journal',
      authorNames: authorships
          .whereType<Map<String, dynamic>>()
          .map((authorship) => authorship['author'] as Map<String, dynamic>?)
          .whereType<Map<String, dynamic>>()
          .map((author) => (author['display_name'] as String?)?.trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toList(growable: false),
      doi: _normalizeDoi(json['doi'] as String?),
      abstractText: _decodeAbstract(
        json['abstract_inverted_index'] as Map<String, dynamic>?,
      ),
    );
  }

  String get authorsLabel {
    if (authorNames.isEmpty) {
      return 'Unknown authors';
    }

    return authorNames.join(', ');
  }

  static String? _normalizeDoi(String? doi) {
    final trimmed = doi?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed.replaceFirst(RegExp(r'^https?://doi\.org/'), '');
  }

  static String? _decodeAbstract(Map<String, dynamic>? invertedIndex) {
    if (invertedIndex == null || invertedIndex.isEmpty) {
      return null;
    }

    final positions = <int, String>{};

    invertedIndex.forEach((word, rawIndexes) {
      if (rawIndexes is! List) {
        return;
      }

      for (final rawIndex in rawIndexes) {
        if (rawIndex is int) {
          positions[rawIndex] = word;
        }
      }
    });

    if (positions.isEmpty) {
      return null;
    }

    final orderedWords = positions.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));

    return orderedWords.map((entry) => entry.value).join(' ');
  }
}
