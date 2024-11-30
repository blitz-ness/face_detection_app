import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late FaceDetector _faceDetector;
  bool _isProcessing = false;
  List<Face> _detectedFaces = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = CameraController(
        widget.cameras.first,
        ResolutionPreset.max,
      );

      _initializeControllerFuture = _cameraController.initialize().then((_) {
        _cameraController.startImageStream((CameraImage image) async {
          if (_isProcessing) return;
          _isProcessing = true;

          try {
            await _processCameraImage(image);
          } catch (e) {
            print("Error processing image: $e");
          } finally {
            _isProcessing = false;
          }
        });
        setState(() {});
      }).catchError((e) {
        print("Camera initialization error: $e");
      });
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
      ),
    );
  }

  Future<void> _processCameraImage(CameraImage image) async {
    try {
      final inputImage = _convertCameraImage(image);

      final faces = await _faceDetector.processImage(inputImage);

      setState(() {
        _detectedFaces = faces;
      });

      // Log detected faces
      print("Number of faces detected: ${_detectedFaces.length}");
    } catch (e) {
      print("Error processing image: $e");
    }
  }

  InputImage _convertCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    // Determine the correct rotation for the input image
    final imageRotation = InputImageRotationValue.fromRawValue(
            widget.cameras.first.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: imageRotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Face Detection')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_cameraController),
                CustomPaint(
                  painter: FacePainter(
                    faces: _detectedFaces,
                    previewSize: _cameraController.value.previewSize!,
                    screenSize: MediaQuery.of(context).size,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Camera initialization error: ${snapshot.error}"),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size previewSize;
  final Size screenSize;

  FacePainter({
    required this.faces,
    required this.previewSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = screenSize.width / previewSize.height;
    final double scaleY = screenSize.height / previewSize.width;

    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (Face face in faces) {
      final boundingBox = face.boundingBox;

      final rect = Rect.fromLTRB(
        boundingBox.left * scaleX,
        boundingBox.top * scaleY,
        boundingBox.right * scaleX,
        boundingBox.bottom * scaleY,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
