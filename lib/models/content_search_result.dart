class ContentSearchResult {
  final String fileName;
  final String filePath;
  final List<MatchResult> matches;

  ContentSearchResult({
    required this.fileName,
    required this.filePath,
    required this.matches,
  });
}

class MatchResult {
  final int lineNumber;
  final String matchingLine;

  MatchResult({
    required this.lineNumber,
    required this.matchingLine,
  });
}
