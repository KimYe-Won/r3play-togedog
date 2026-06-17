import 'dart:async';

import 'package:flutter/material.dart';

import '../services_bg/audio_service.dart';

class AudioAlertBanner extends StatefulWidget {
  const AudioAlertBanner({super.key, required this.stream});
  final Stream<AudioAlert> stream;

  @override
  State<AudioAlertBanner> createState() => _AudioAlertBannerState();
}

class _AudioAlertBannerState extends State<AudioAlertBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;

  StreamSubscription<AudioAlert>? _sub;
  AudioAlert? _current;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _sub = widget.stream.listen(_onAlert);
  }

  void _onAlert(AudioAlert alert) {
    setState(() => _current = alert);
    _controller.forward(from: 0);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      _controller.reverse();
    });
  }

  Color _bgColor(int priority) {
    switch (priority) {
      case 1: return const Color(0xFFE53935);
      case 2: return const Color(0xFFF57C00);
      default: return const Color(0xFF1976D2);
    }
  }

  IconData _icon(int priority) {
    switch (priority) {
      case 1: return Icons.warning_rounded;
      case 2: return Icons.volume_up_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = _current;
    if (alert == null) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnim,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          color: _bgColor(alert.priority).withOpacity(0.92),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Icon(_icon(alert.priority), color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  alert.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
