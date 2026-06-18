import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'togedog_accessibility.dart';
import 'walk_flashlight.dart';

/// 실시간 카메라 프리뷰. [enabled]가 false이면 카메라를 켜지 않습니다.
class LiveCameraView extends StatefulWidget {
  const LiveCameraView({
    super.key,
    this.fit = BoxFit.cover,
    this.bindFlashlight = false,
    this.enabled = true,
    this.inactiveMessage = '시작을 누르세요',
  });

  final BoxFit fit;
  final bool bindFlashlight;
  final bool enabled;
  final String inactiveMessage;

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView> {
  CameraController? _controller;
  bool _unavailable = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _initCamera();
    }
  }

  @override
  void didUpdateWidget(covariant LiveCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _initCamera();
    } else if (!widget.enabled && oldWidget.enabled) {
      _disposeCamera();
      if (mounted) setState(() => _unavailable = false);
    }
  }

  Future<void> _initCamera() async {
    if (!widget.enabled || _controller != null) return;

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
      if (!mounted || !widget.enabled) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
      if (widget.bindFlashlight) {
        WalkFlashlight.bindController(controller);
      }
    } catch (_) {
      if (mounted) setState(() => _unavailable = true);
    }
  }

  Future<void> _disposeCamera() async {
    if (widget.bindFlashlight) {
      await WalkFlashlight.turnOff();
      WalkFlashlight.bindController(null);
    }
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return _WalkCameraInactiveView(message: widget.inactiveMessage);
    }

    final controller = _controller;
    if (_unavailable ||
        controller == null ||
        !controller.value.isInitialized) {
      return const _CameraPlaceholder();
    }

    return Semantics(
      label: '산책 실시간 카메라 화면',
      child: ClipRect(
        child: FittedBox(
          fit: widget.fit,
          alignment: Alignment.center,
          child: SizedBox(
            width: controller.value.previewSize!.height,
            height: controller.value.previewSize!.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

class _WalkCameraInactiveView extends StatelessWidget {
  const _WalkCameraInactiveView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '카메라 비활성, $message',
      child: Container(
        color: const Color(0xFF2A2A2A),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TogedogA11y.decorative(
              Icon(
                Icons.videocam_off_outlined,
                size: 40,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
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
