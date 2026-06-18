import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// 실시간 카메라 컨트롤러를 통해 기기 손전등을 토글합니다.
class WalkFlashlight {
  WalkFlashlight._();

  static CameraController? _controller;
  static bool torchOn = false;

  static void bindController(CameraController? controller) {
    _controller = controller;
    if (controller == null || !controller.value.isInitialized) {
      torchOn = false;
    }
  }

  static Future<bool> toggle() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return false;
    }

    try {
      final nextOn = !torchOn;
      await controller.setFlashMode(nextOn ? FlashMode.torch : FlashMode.off);
      torchOn = nextOn;
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('WalkFlashlight.toggle failed: $error');
      }
      return false;
    }
  }

  static Future<void> turnOff() async {
    if (!torchOn) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      torchOn = false;
      return;
    }

    try {
      await controller.setFlashMode(FlashMode.off);
    } catch (_) {
      // ignore
    } finally {
      torchOn = false;
    }
  }
}
