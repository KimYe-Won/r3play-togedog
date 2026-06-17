import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_onboarding_00.dart';
import 'pet_profile_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PetProfileStore.instance.load();
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
