import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_tracker_user/services/background_service.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  sl.registerSingleton(sharedPreferences);
  sl.registerSingleton(Geolocator());
  sl.registerSingleton(BackgroundService());
}
