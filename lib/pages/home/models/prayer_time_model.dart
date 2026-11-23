import 'package:equatable/equatable.dart';

class PrayerTimeModel extends Equatable {
  final String name;
  final String timeString;
  final DateTime time;
  final bool isPassed;
  final bool isCurrent;

  const PrayerTimeModel({
    required this.name,
    required this.timeString,
    required this.time,
    this.isPassed = false,
    this.isCurrent = false,
  });

  PrayerTimeModel copyWith({
    String? name,
    String? timeString,
    DateTime? time,
    bool? isPassed,
    bool? isCurrent,
  }) {
    return PrayerTimeModel(
      name: name ?? this.name,
      timeString: timeString ?? this.timeString,
      time: time ?? this.time,
      isPassed: isPassed ?? this.isPassed,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  List<Object?> get props => [name, timeString, time, isPassed, isCurrent];
}
