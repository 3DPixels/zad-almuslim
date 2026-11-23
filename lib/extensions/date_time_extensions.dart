import 'package:hijri/hijri_calendar.dart';

extension HijriDateExtension on DateTime {
  String toHijriString() {
    HijriCalendar.setLocal('ar');
    return HijriCalendar.fromDate(this).toFormat("dd MMMM yyyy هـ");
  }
}

extension Format12HourExt on DateTime {
  String format12Hour() {
    final int hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final String minutes = minute.toString().padLeft(2, '0');
    final String period = hour < 12 ? 'ص' : 'م';
    return '$hour12:$minutes $period';
  }
}
