import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  /// ✅ Request Location Permission & Get Current Location
  static Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// ✅ Get City Name from coordinates
  static Future<Map<String, String>> _getCityAndState(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      return {
        'city': 'Unknown',
        'state': 'Unknown',
      };
    }

    final place = placemarks.first;

    final city = (place.subLocality?.isNotEmpty == true)
        ? place.subLocality!
        : (place.locality?.isNotEmpty == true)
            ? place.locality!
            : (place.subAdministrativeArea?.isNotEmpty == true)
                ? place.subAdministrativeArea!
                : 'Unknown';

    final state = place.administrativeArea?.isNotEmpty == true
        ? place.administrativeArea!
        : 'Unknown';

    return {
      'city': city,
      'state': state,
    };
  }

  /// ✅ Get and Save Location + City Name in SharedPreferences
  static Future<void> fetchAndStoreLocation() async {
    try {
      Position position = await _determinePosition();
      final locationData = await _getCityAndState(position);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
      await prefs.setString('cityName', locationData['city']!);
      await prefs.setString('stateName', locationData['state']!);

      print("📍 Latitude: ${position.latitude}");
      print("📍 Longitude: ${position.longitude}");
      print("🏙 City: ${locationData['city']}");
      print("🏞 State: ${locationData['state']}");
    } catch (e) {
      print("⚠️ Location error: $e");
    }
  }

  static Future<void> showFetchingLocationDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false, // prevent closing dialog
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/lo_1.gif', // your image path
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Fetching your location...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please ensure location services are enabled",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
