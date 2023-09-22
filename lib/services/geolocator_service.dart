import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  GeolocatorService._();

  static final GeolocatorService _instance = GeolocatorService._();

  factory GeolocatorService() {
    return _instance;
  }
}
