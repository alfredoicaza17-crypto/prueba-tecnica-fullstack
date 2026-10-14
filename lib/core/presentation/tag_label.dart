/// Display formatting only; domain values keep their original case.
String tagLabel(String tag) =>
    tag.isEmpty ? tag : '${tag[0].toUpperCase()}${tag.substring(1)}';
