import 'dart:async';

import 'package:flutter/material.dart';

/// Shows a time-based greeting and a small shining watermark for ~3s on app launch.
class GreetingSplash extends StatefulWidget {
  final Widget child;
  const GreetingSplash({super.key, required this.child});

  @override
  State<GreetingSplash> createState() => _GreetingSplashState();
}

class _GreetingSplashState extends State<GreetingSplash> with SingleTickerProviderStateMixin {
  static bool _alreadyShown = false;

  late final AnimationController _shine;
  Timer? _fadeTimer;
  Timer? _removeTimer;
  bool _show = false;
  bool _fading = false;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    if (!_alreadyShown) {
      _alreadyShown = true;
      _show = true;
      _shine.repeat();
      _fadeTimer = Timer(const Duration(milliseconds: 2600), () {
        if (mounted) setState(() => _fading = true);
      });
      _removeTimer = Timer(const Duration(milliseconds: 3100), () {
        if (!mounted) return;
        _shine.stop();
        setState(() => _show = false);
      });
    }
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _removeTimer?.cancel();
    _shine.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Good night';
  }

  Widget _buildWatermark() {
    return AnimatedBuilder(
      animation: _shine,
      builder: (context, child) {
        final t = -0.3 + _shine.value * 1.6;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => LinearGradient(
            colors: const [Color(0x66FFFFFF), Colors.white, Color(0x66FFFFFF)],
            stops: [
              (t - 0.2).clamp(0.0, 1.0).toDouble(),
              t.clamp(0.0, 1.0).toDouble(),
              (t + 0.2).clamp(0.0, 1.0).toDouble(),
            ],
          ).createShader(rect),
          child: child,
        );
      },
      child: const Text(
        'App developed by Chandan Choudhary',
        style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: _fading,
          child: AnimatedOpacity(
            opacity: _fading ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 450),
            child: Material(
              color: Colors.black,
              child: SafeArea(
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      '${_greeting()},',
                      style: const TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Chandan Choudhary',
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    _buildWatermark(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
