enum DiffType { same, added, removed }

class DiffSegment {
  final String text;
  final DiffType type;

  const DiffSegment({required this.text, required this.type});
}

class DiffUtil {
  /// Simple word-by-word diff calculation
  static List<DiffSegment> calculateWordDiff(String original, String modified) {
    if (original.trim() == modified.trim()) {
      return [DiffSegment(text: modified, type: DiffType.same)];
    }

    final originalWords = original.split(RegExp(r'\s+'));
    final modifiedWords = modified.split(RegExp(r'\s+'));

    final List<DiffSegment> segments = [];
    int i = 0;
    int j = 0;

    while (i < originalWords.length && j < modifiedWords.length) {
      if (originalWords[i].toLowerCase() == modifiedWords[j].toLowerCase()) {
        segments.add(DiffSegment(text: '${modifiedWords[j]} ', type: DiffType.same));
        i++;
        j++;
      } else {
        // Look ahead for matches
        int matchInModified = -1;
        for (int k = j; k < modifiedWords.length && k < j + 4; k++) {
          if (originalWords[i].toLowerCase() == modifiedWords[k].toLowerCase()) {
            matchInModified = k;
            break;
          }
        }

        if (matchInModified != -1) {
          while (j < matchInModified) {
            segments.add(DiffSegment(text: '${modifiedWords[j]} ', type: DiffType.added));
            j++;
          }
        } else {
          segments.add(DiffSegment(text: '${modifiedWords[j]} ', type: DiffType.added));
          i++;
          j++;
        }
      }
    }

    while (j < modifiedWords.length) {
      segments.add(DiffSegment(text: '${modifiedWords[j]} ', type: DiffType.added));
      j++;
    }

    return segments;
  }
}
