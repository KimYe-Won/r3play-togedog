import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const YoloCocoBenchApp());
}

class YoloCocoBenchApp extends StatelessWidget {
  const YoloCocoBenchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BenchScreen(),
    );
  }
}

class BenchScreen extends StatefulWidget {
  const BenchScreen({super.key});

  @override
  State<BenchScreen> createState() => _BenchScreenState();
}

class _BenchScreenState extends State<BenchScreen> {
  bool _hasPermission = false;
  double _fps = 0;
  double _latencyMs = 0;
  int _detCount = 0;

  @override
  void initState() {
    super.initState();
    _requestCamera();
  }

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();
    if (mounted) setState(() => _hasPermission = status.isGranted);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('카메라 권한이 필요합니다', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          YOLOView(
            modelPath: 'assets/yolo26n_coco_float16.tflite',
            task: YOLOTask.detect,
            useGpu: true,
            confidenceThreshold: 0.25,
            iouThreshold: 0.45,
            onResult: (results) {
              if (mounted) setState(() => _detCount = results.length);
            },
            onPerformanceMetrics: (metrics) {
              if (mounted) {
                setState(() {
                  _fps = metrics.fps;
                  _latencyMs = metrics.processingTimeMs;
                });
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'COCO 80cls  |  '
                  'FPS: ${_fps.toStringAsFixed(1)}  |  '
                  '${_latencyMs.toStringAsFixed(0)}ms  |  '
                  'Det: $_detCount',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
