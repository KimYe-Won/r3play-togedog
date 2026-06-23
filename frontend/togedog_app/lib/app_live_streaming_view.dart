import 'package:flutter/material.dart';
import 'package:yolo_live_stream/yolo_live_stream.dart';

import 'togedog_accessibility.dart';
import 'walk_ai_manager.dart';
import 'walk_session.dart';

/// LiveStreamingView를 앱 전용으로 래핑한 위젯.
/// WalkSession.active가 false이면 비활성 오버레이를 자동으로 띄운다.
/// 공유 controller로 Walk01↔Walk02↔Walk03/04가 같은 WebRTC 연결을 함께 쓴다.
/// 각 화면은 자기 렌더러로 동일 스트림을 그린다.
class AppLiveStreamingView extends StatelessWidget {
  const AppLiveStreamingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WalkSession.instance,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          LiveStreamingView(
            role: Role.receiver,
            showControlPanel: false,
            controller: WalkAiManager.instance.streamingController,
          ),
          if (!WalkSession.instance.active)
            const _InactiveView(),
        ],
      ),
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
