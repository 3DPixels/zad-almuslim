class SavedZekrEntry {
  final bool isCompleted;
  final int readReps;

  const SavedZekrEntry({required this.isCompleted, required this.readReps});

  Map<String, dynamic> toJson() => {'d': isCompleted, 'r': readReps};

  factory SavedZekrEntry.fromJson(Map<String, dynamic> json) => SavedZekrEntry(
    isCompleted: json['d'] as bool? ?? false,
    readReps: json['r'] as int? ?? 0,
  );
}
