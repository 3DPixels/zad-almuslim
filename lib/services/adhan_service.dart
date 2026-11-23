import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class AdhanService {
  // Helper to determine auto method using robust switch case matching
  static CalculationMethod getAutoMethodForCountry(String country) {
    final c = country.toLowerCase();
    switch (c) {
      case _ when c.contains('مصر') || c.contains('egypt'):
        return CalculationMethod.egyptian;
      case _
          when c.contains('سعودي') || c.contains('saudi') || c.contains('ksa'):
        return CalculationMethod.umm_al_qura;
      case _
          when c.contains('إمارات') ||
              c.contains('uae') ||
              c.contains('emirates'):
        return CalculationMethod.dubai;
      case _ when c.contains('قطر') || c.contains('qatar'):
        return CalculationMethod.qatar;
      case _ when c.contains('كويت') || c.contains('kuwait'):
        return CalculationMethod.kuwait;
      case _ when c.contains('تركيا') || c.contains('turkey'):
        return CalculationMethod.turkey;
      case _
          when c.contains('باكستان') ||
              c.contains('pakistan') ||
              c.contains('أفغان') ||
              c.contains('afghan'):
        return CalculationMethod.karachi;
      case _ when c.contains('سنغافور') || c.contains('singapore'):
        return CalculationMethod.singapore;
      case _
          when c.contains('أمريكا') ||
              c.contains('us') ||
              c.contains('كندا') ||
              c.contains('canada'):
        return CalculationMethod.north_america;
      case _
          when c.contains('بريطانيا') ||
              c.contains('uk') ||
              c.contains('kingdom'):
        return CalculationMethod.muslim_world_league;
      default:
        return CalculationMethod.muslim_world_league; // Fallback default
    }
  }

  // Helper to format the method name for the UI
  static String getMethodName(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.egyptian:
        return 'الهيئة العامة المصرية للمساحة';
      case CalculationMethod.umm_al_qura:
        return 'جامعة أم القرى';
      case CalculationMethod.dubai:
        return 'دبي (الإمارات)';
      case CalculationMethod.qatar:
        return 'قطر';
      case CalculationMethod.kuwait:
        return 'الكويت';
      case CalculationMethod.turkey:
        return 'رئاسة الشؤون الدينية التركية';
      case CalculationMethod.karachi:
        return 'جامعة العلوم الإسلامية بكراتشي';
      case CalculationMethod.singapore:
        return 'سنغافورة';
      case CalculationMethod.north_america:
        return 'ISNA (أمريكا الشمالية)';
      case CalculationMethod.muslim_world_league:
        return 'رابطة العالم الإسلامي';
      case CalculationMethod.tehran:
        return 'جامعة طهران';
      case CalculationMethod.other:
      default:
        return 'أخرى';
    }
  }

  CalculationParameters _getCalculationMethod(
    String country,
    CalculationMethod? selectedMethod,
  ) {
    // If a method is explicitly passed, use it. Otherwise, fallback to the switch statement
    final method = selectedMethod ?? getAutoMethodForCountry(country);
    return method.getParameters();
  }

  PrayerTimes getTodayPrayers(
    double lat,
    double lng,
    String country, {
    CalculationMethod? selectedMethod,
  }) {
    final coordinates = Coordinates(lat, lng);
    final params = _getCalculationMethod(country, selectedMethod);

    return PrayerTimes.today(coordinates, params);
  }

  PrayerTimes getTomorrowPrayers(
    double lat,
    double lng,
    String country, {
    CalculationMethod? selectedMethod,
  }) {
    final coordinates = Coordinates(lat, lng);
    final params = _getCalculationMethod(country, selectedMethod);
    final date = DateComponents.from(
      DateTime.now().add(const Duration(days: 1)),
    );

    return PrayerTimes(coordinates, date, params);
  }

  PrayerTimes getPrayersForDate(
    double lat,
    double lng,
    String country,
    DateTime date, {
    CalculationMethod? selectedMethod,
  }) {
    final coordinates = Coordinates(lat, lng);
    final params = _getCalculationMethod(country, selectedMethod);
    return PrayerTimes(coordinates, DateComponents.from(date), params);
  }

  String formatTime(DateTime time) {
    // 'h:mm a' gives you 12-hour format with AM/PM (or ص/م depending on locale)
    return DateFormat('h:mm a', 'ar').format(time);
  }
}
