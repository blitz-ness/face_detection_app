import 'package:flutter/material.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:face_detection_app/home_page.dart';
import 'package:camera/camera.dart';

class MySplashScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MySplashScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset('assets/face.png'), // Replace with your asset path
      title: const Text(
        "Face Detector App",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey.shade400,
      showLoader: true,
      loadingText: const Text("blitzNess"),
      navigator: HomePage(cameras: cameras), // Pass cameras to HomePage
      durationInSeconds: 5,
    );
  }
}