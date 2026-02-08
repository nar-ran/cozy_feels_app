class MoodRecord {
  final DateTime date;
  final String moodIcon;
  final String? note;

  MoodRecord({required this.date, required this.moodIcon, this.note});
}