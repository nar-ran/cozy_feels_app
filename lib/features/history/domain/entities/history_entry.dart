class HistoryEntry {
  final DateTime date;
  final String message;
  final String emojiPath;
  final List<String> tags;

  HistoryEntry({
    required this.date,
    required this.message,
    required this.emojiPath,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'message': message,
        'emojiPath': emojiPath,
        'tags': tags,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        date: DateTime.parse(json['date']),
        message: json['message'] ?? "",
        emojiPath: json['emojiPath'] ?? "",
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}