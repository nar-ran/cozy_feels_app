class MoodEntry {
  final String id;
  final DateTime date;
  final String? note;
  final String iconPath;

  MoodEntry({
    required this.id,
    required this.date,
    this.note,
    required this.iconPath,
  });
}