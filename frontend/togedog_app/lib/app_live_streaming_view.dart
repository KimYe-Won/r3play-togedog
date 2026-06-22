import 'package:flutter/material.dart';
import 'package:yolo_live_stream/yolo_live_stream.dart';

import 'togedog_accessibility.dart';
import 'walk_ai_manager.dart';
import 'walk_session.dart';

/// 공유 수신 영상을 그리는 위젯.
/// 연결·렌더러는 [WalkAiManager]가 단 하나만 소유하므로, 이 위젯을 화면마다 띄워도
/// 모두 같은 스트림을 그린다. WalkSession.active가 false이면 비활성 오버레이를 띄운다.
class AppLiveStreamingView extends StatelessWidget {
  const AppLiveStreamingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        WalkSession.instance,
        WalkAiManager.instance,
      ]),
      builder: (context, _) {
        final manager = WalkAiManager.instance;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (manager.hasRemoteVideo)
              DetectionOverlay(
                renderer: manager.remoteRenderer,
                detections: manager.detections,
                mirror: manager.remoteIsFrontCamera,
              )
            else
              const ColoredBox(color: Color(0xFF0E0E12)),
            if (!WalkSession.instance.active) const _InactiveView(),
          ],
        );
      },
    );
  }
}

class _InactiveView extends StatelessWidget {
  const _InactiveView();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '카메라 비활성, 시작을 누르세요',
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
              '시작을 누르세요',
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
