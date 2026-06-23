import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_shell.dart';
import 'walk_ai_manager.dart';
import 'walk_session.dart';

class WalkIpInputScreen extends StatefulWidget {
  const WalkIpInputScreen({super.key});

  @override
  State<WalkIpInputScreen> createState() => _WalkIpInputScreenState();
}

class _WalkIpInputScreenState extends State<WalkIpInputScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _connecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: WalkAiManager.instance.lastIp);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final ip = _controller.text.trim();
    if (ip.isEmpty) return;

    setState(() {
      _connecting = true;
      _error = null;
    });

    final ok = await WalkAiManager.instance.connect(ip);
    if (!mounted) return;

    if (ok) {
      WalkSession.instance.startWalk();
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _connecting = false;
        _error = '연결 실패. IP를 확인하세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kTogedogDesignWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5FF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          '웨어러블 연결',
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w600,
            fontSize: 16 * scale,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 32 * scale),
            Text(
              '강아지 폰 IP 주소',
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 14 * scale,
                color: const Color(0xFF6A6A6A),
              ),
            ),
            SizedBox(height: 8 * scale),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontSize: 20 * scale,
                color: const Color(0xFF1A1A1A),
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: '192.168.x.x',
                hintStyle: TextStyle(
                  color: const Color(0xFFA5A5A5),
                  fontSize: 20 * scale,
                  letterSpacing: 1.5,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 14 * scale,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scale),
                  borderSide: const BorderSide(color: Color(0xFFD4D4D4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scale),
                  borderSide: const BorderSide(color: Color(0xFFD4D4D4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scale),
                  borderSide: const BorderSide(color: Color(0xFF8756E7), width: 2),
                ),
                errorText: _error,
              ),
              onSubmitted: (_) => _connect(),
            ),
            SizedBox(height: 20 * scale),
            if (_connecting)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF8756E7)),
              )
            else
              GestureDetector(
                onTap: _connect,
                child: Container(
                  height: 50 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8756E7),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  child: Text(
                    '연결',
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w600,
                      fontSize: 15 * scale,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
