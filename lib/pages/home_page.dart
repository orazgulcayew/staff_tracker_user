import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';

import '../main.dart';
import '../widgets/dialogs.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = "Stop Service";
  bool hasConnection = true;
  bool serviceEnabled = false;
  bool isLoading = true;
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.vpn) {
        setState(() {
          hasConnection = true;
        });
      } else {
        setState(() {
          hasConnection = false;
        });
      }
    });

    initializeService();
    checkPermission();
  }

  @override
  void dispose() {
    super.dispose();

    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service App'), actions: [
        TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              showYesNoDialog(context,
                      title: "Hasapdan çykyş",
                      message: "Siz hasabyňyzdan çykmak isleýärsiňizmi?")
                  .then((value) async {
                if (value == true) {
                  await auth.signOut();
                  // ignore: use_build_context_synchronously
                  Phoenix.rebirth(context);
                }
              });
            },
            icon: const Icon(Icons.logout, size: 20),
            label: const Text(
              "Hasapdan çyk",
              style: TextStyle(fontSize: 12),
            )),
        const Gap(16)
      ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: Material(
                elevation: 0.5,
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 32,
                      ),
                      const Gap(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser?.displayName ?? "",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            auth.currentUser?.email ?? "",
                            style: const TextStyle(fontSize: 16),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Gap(16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Material(
                      elevation: 0.5,
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  hasConnection
                                      ? Icons.wifi
                                      : Icons.wifi_off_rounded,
                                  size: 32,
                                  color: hasConnection
                                      ? const Color.fromARGB(255, 36, 239, 46)
                                      : Colors.red,
                                ),
                                const Gap(8),
                                Text(
                                  hasConnection ? "Online" : "Offline",
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                            const Spacer(),
                            const FittedBox(
                              child: Text(
                                "Status",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Material(
                      elevation: 0.5,
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_pin_circle_outlined,
                                  size: 32,
                                ),
                                const Gap(8),
                                StreamBuilder(
                                  stream: geolocatorPlatform.getPositionStream(
                                      locationSettings: const LocationSettings(
                                          accuracy: LocationAccuracy.high)),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    return Column(
                                      children: [
                                        Text("${snapshot.data?.latitude}"),
                                        Text("${snapshot.data?.longitude}"),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Spacer(),
                            const FittedBox(
                              child: Text(
                                "Häzirki nokadyňyz",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Visibility(
              visible: !serviceEnabled,
              child: Material(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(12),
                elevation: 0.5,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 30,
                      ),
                      const Gap(8),
                      const Text(
                        'Gerekli rugsatlary açyň!',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          askLocationPermission();
                        },
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.green),
                        child: const Text('Rugsat ber'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  Future<void> askLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    if (permission == LocationPermission.whileInUse) {
      showMessage();
    }

    if (permission == LocationPermission.always) {
      setState(() {
        this.serviceEnabled = true;
      });
    }
  }

  Future<void> checkPermission() async {
    LocationPermission isLocationServiceEnabled =
        await Geolocator.checkPermission();

    setState(() {
      serviceEnabled = isLocationServiceEnabled == LocationPermission.always;
      isLoading = false;
    });
  }

  void showMessage() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Programmanyň dogry işlemegi üçin hemişelik rugsat gerek!")));
  }

  // Background
  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: true,

        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'AWESOME SERVICE',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
}
