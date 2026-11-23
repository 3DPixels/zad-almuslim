import 'dart:ui'; // Required for the Locale class

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  final Geocoding _geocoding = Geocoding();

  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(const Duration(seconds: 12));
    } catch (_) {
      // Indoors or backgrounded GPS timeout -> fallback to OS cached position
      return await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    }
  }

  Future<Placemark?> getPlacemark(double lat, double lng) async {
    try {
      final placemarks = await _geocoding
          .placemarkFromCoordinates(lat, lng, locale: const Locale('ar'))
          .timeout(const Duration(seconds: 6));
      return placemarks.isNotEmpty ? placemarks.first : null;
    } catch (_) {
      return null;
    }
  }
}
