class Reminder {
  final String id;
  final int hour; // 0-23
  final int minute; // 0-59
  final List<bool> days; // L, M, M, J, V, S, D
  final bool isActive;

  Reminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.days,
    this.isActive = true,
  });

  Reminder copyWith({
    String? id,
    int? hour,
    int? minute,
    List<bool>? days,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
    );
  }
}