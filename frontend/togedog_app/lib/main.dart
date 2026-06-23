import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'guidance_mode_store.dart';
import 'main_onboarding_00.dart';
import 'pet_profile_store.dart';
import 'walk_ai_manager.dart';
import 'wearable_connection_store.dart';

// 백엔드 작업
import 'backend_session_store.dart';
import 'consent_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    PetProfileStore.instance.load(),
    GuidanceModeStore.instance.load(),
    WearableConnectionStore.instance.load(),
    WalkAiManager.instance.init(),
    BackendSessionStore.instance.load(), //[백엔드 연동] ID 복원
    ConsentStore.instance.load(), //[백엔드 연동] 동의 상태 복원
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const TogeDogApp());
}

class TogeDogApp extends StatelessWidget {
  const TogeDogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
