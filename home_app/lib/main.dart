import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';

import 'models/advanced_sensor.dart';
import 'models/sensor.dart';
import 'routes/splash.dart';

// using and overridden http class because
// I have a self-signed certificate for HTTPS
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // using the overridden http class
  HttpOverrides.global = DevHttpOverrides();

  // initializing hive database
  await Hive.initFlutter();

  // registering custom objects to be stored in the database
  Hive
    ..registerAdapter(SensorAdapter())
    ..registerAdapter(AdvancedSensorAdapter());

  // running the app
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
}
