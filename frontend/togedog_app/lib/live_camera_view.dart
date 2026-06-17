import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 실시간 카메라 프리뷰. 권한·기기 미지원 시 플레이스홀더 표시.
class LiveCameraView extends StatefulWidget {
  const LiveCameraView({super.key, this.fit = BoxFit.cover});

  final BoxFit fit;

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView> {
  CameraController? _controller;
  bool _unavailable = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _unavailable = true);
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _unavailable = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_unavailable ||
        controller == null ||
        !controller.value.isInitialized) {
      return const _CameraPlaceholder();
    }

    return ClipRect(
      child: FittedBox(
        fit: widget.fit,
        alignment: Alignment.center,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videocam_outlined,
            size: 40,
            color: Colors.white.withValues(alpha: 0.45),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            Text(
              '카메라 연결 대기',
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
