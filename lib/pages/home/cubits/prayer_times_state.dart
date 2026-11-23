part of 'prayer_times_cubit.dart';

enum LocationStatus {
  initial,
  loading,
  success,
  serviceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  error,
}

class PrayerTimesState extends Equatable {
  final LocationStatus locationStatus;
  final String locationSource;
  final String locationMessage;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final bool isManualRefresh;

  // Prayer Data
  final List<PrayerTimeModel> prayers;
  final String currentPrayerName;
  final int currentPrayerIndex;
  final DateTime? timerTarget;
  final bool isPostAdhan; // True if within 25 mins after adhan

  const PrayerTimesState({
    this.locationStatus = LocationStatus.initial,
    this.locationSource = '',
    this.locationMessage = '',
    this.city = 'الرياض',
    this.country = 'السعودية',
    this.latitude = 24.7136,
    this.longitude = 46.6753,
    this.isManualRefresh = false,
    this.prayers = const [],
    this.currentPrayerName = '',
    this.currentPrayerIndex = -1,
    this.timerTarget,
    this.isPostAdhan = false,
  });

  PrayerTimesState copyWith({
    LocationStatus? locationStatus,
    String? locationSource,
    String? locationMessage,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    bool? isManualRefresh,
    String? hijriDate,
    List<PrayerTimeModel>? prayers,
    String? currentPrayerName,
    int? currentPrayerIndex,
    DateTime? timerTarget,
    bool? isPostAdhan,
  }) {
    return PrayerTimesState(
      locationStatus: locationStatus ?? this.locationStatus,
      locationSource: locationSource ?? this.locationSource,
      locationMessage: locationMessage ?? this.locationMessage,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isManualRefresh: isManualRefresh ?? this.isManualRefresh,
      prayers: prayers ?? this.prayers,
      currentPrayerName: currentPrayerName ?? this.currentPrayerName,
      currentPrayerIndex: currentPrayerIndex ?? this.currentPrayerIndex,
      timerTarget: timerTarget ?? this.timerTarget,
      isPostAdhan: isPostAdhan ?? this.isPostAdhan,
    );
  }

  @override
  List<Object?> get props => [
    locationStatus,
    locationSource,
    locationMessage,
    city,
    country,
    latitude,
    longitude,
    isManualRefresh,
    prayers,
    currentPrayerName,
    currentPrayerIndex,
    timerTarget,
    isPostAdhan,
  ];
}
