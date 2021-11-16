import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

class LocationService {
  static double latitude;
  static double longitude;

  static final GeolocatorPlatform geolocatorAndroid =
      GeolocatorPlatform.instance;

  static Future<void> requestLocationPermission() async {
    return await geolocatorAndroid.requestPermission();
  }

  static Future<void> getCurrentLocation() async {
    latitude = null;
    longitude = null;
    try {
      Position position = await geolocatorAndroid.getCurrentPosition();
      //if the position is null, set location to null island
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }
}
