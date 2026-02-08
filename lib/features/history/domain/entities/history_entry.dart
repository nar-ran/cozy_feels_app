class HistoryEntry {
  final DateTime date;
  final String message;
  final String emojiPath;

  HistoryEntry({required this.date, required this.message, required this.emojiPath});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'message': message,
    'emojiPath': emojiPath,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    date: DateTime.parse(json['date']),
    message: json['message'],
    emojiPath: json['emojiPath'],
  );
}