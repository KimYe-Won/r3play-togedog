import 'package:flutter/material.dart';

void main() {
  runApp(const TogedogApp());
}

class TogedogApp extends StatelessWidget {
  const TogedogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '토게독',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('togedog')),
      ),
    );
  }
}
