import 'dart:async';

import 'package:flutter/material.dart';

import '../core/style.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: C.gradPrimaryDeep),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 14))],
              ),
              child: const Icon(Icons.contactless_rounded, size: 46, color: C.primary),
            ),
            const SizedBox(height: 18),
            Text('MobiPay', style: T.display.copyWith(color: Colors.white, fontSize: 32)),
            const SizedBox(height: 6),
            Text('Pay. Tap. Scan.',
                style: T.body.copyWith(color: Colors.white.withOpacity(0.75), letterSpacing: 1.2)),
            const SizedBox(height: 42),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white.withOpacity(0.85)),
            ),
          ]),
        ),
      ),
    );
  }
}
