import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../widgets/ui.dart';
import 'main_shell.dart';
/// Biometric unlock — UI DEMO ONLY.
/// Real implementation: local_auth (Face ID / fingerprint). The mock below
/// unlocks instantly; production must verify against the OS biometric API.
class UnlockScreen extends StatelessWidget {
  const UnlockScreen({super.key});

  void _unlock(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: C.gradPrimaryDeep),
        child: SafeArea(
          child: Column(children: [
            const Spacer(),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Icon(Icons.face_retouching_natural_rounded, size: 52, color: Colors.white),
            ),
            const SizedBox(height: 26),
            Text(App.t('Unlock MobiPay', 'افتح MobiPay'),
                style: T.h1.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(App.t('Use Face ID to continue securely', 'استخدم Face ID للمتابعة بأمان'),
                style: T.body.copyWith(color: Colors.white.withOpacity(0.72))),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton('Unlock with Face ID', 'الدخول ببصمة الوجه',
                  onTap: () => _unlock(context)),
            ),
            const SizedBox(height: 12),
            GhostButton('Use passcode instead', 'استخدم رمز المرور بدلاً من ذلك',
                color: Colors.white, onTap: () => _unlock(context)),
            const SizedBox(height: 26),
            const DemoBadge(),
            const SizedBox(height: 14),
          ]),
        ),
      ),
    );
  }
}
