import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:face_detection_app/splash_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // Initialize cameras
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detector App',
      debugShowCheckedModeBanner: false,
      home: MySplashScreen(cameras: cameras),
    );
  }
}
