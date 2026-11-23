part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool prayerNotifications;
  final bool dailyAzkarNotifications;
  final bool morningNightAzkarNotifications;
  final CalculationMethod? selectedCalculationMethod;

  const SettingsState({
    this.prayerNotifications = false,
    this.dailyAzkarNotifications = false,
    this.morningNightAzkarNotifications = false,
    this.selectedCalculationMethod,
  });

  SettingsState copyWith({
    bool? prayerNotifications,
    bool? dailyAzkarNotifications,
    bool? morningNightAzkarNotifications,
    CalculationMethod? selectedCalculationMethod,
    bool clearCalculationMethod = false, // Helper flag to switch back to Auto
  }) {
    return SettingsState(
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
      dailyAzkarNotifications:
          dailyAzkarNotifications ?? this.dailyAzkarNotifications,
      morningNightAzkarNotifications:
          morningNightAzkarNotifications ?? this.morningNightAzkarNotifications,
      // If clear is true, force it to null. Otherwise, use the new method or fallback to current.
      selectedCalculationMethod: clearCalculationMethod
          ? null
          : (selectedCalculationMethod ?? this.selectedCalculationMethod),
    );
  }

  @override
  List<Object?> get props => [
    prayerNotifications,
    dailyAzkarNotifications,
    morningNightAzkarNotifications,
    selectedCalculationMethod,
  ];
}
