import 'dart:async';

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_tracker_user/pages/home_page.dart';
import 'package:staff_tracker_user/pages/register_page.dart';

import 'firebase_options.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;
FirebaseFirestore? firestore;
final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  auth = FirebaseAuth.instance;

  runApp(Phoenix(child: const StaffTracker()));
}

class StaffTracker extends StatelessWidget {
  const StaffTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: auth.currentUser != null ? const HomePage() : const RegisterPage(),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  List<Map<String, dynamic>> offlineList = [];
  await Firebase.initializeApp();
  firestore = FirebaseFirestore.instance;

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      /// OPTIONAL for use custom notification
      /// the notification id must be equals with AndroidConfiguration when you call configure() method.
      flutterLocalNotificationsPlugin.show(
        888,
        'COOL SERVICE',
        'Awesome ${DateTime.now()}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'my_foreground',
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            ongoing: true,
          ),
        ),
      );

      // if you don't using custom notification, uncomment this
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Updated at ${DateTime.now()}",
      );
    }
  }

  Timer.periodic(const Duration(seconds: 30), (timer) {
    geolocatorPlatform.getCurrentPosition().then((value) async {
      final connectivityRes = await Connectivity().checkConnectivity();

      if (connectivityRes == ConnectivityResult.mobile ||
          connectivityRes == ConnectivityResult.wifi ||
          connectivityRes == ConnectivityResult.vpn) {
        if (offlineList.isNotEmpty) {
          await firestore
              ?.collection('locations')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .set({"location": FieldValue.arrayUnion(offlineList)},
                  SetOptions(merge: true));
          offlineList.clear();
        }

        if (firestore != null && offlineList.isEmpty) {
          await firestore
              ?.collection('locations')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .set({
            "location": FieldValue.arrayUnion([value.toJson()])
          }, SetOptions(merge: true));
        }
      } else {
        offlineList.add(value.toJson());
      }
    });
  });

  service.invoke(
    'update',
    {"current_date": DateTime.now().toIso8601String()},
  );
}
