import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../models/models.dart';

/// Egyptian e-wallet visual (spec §3). Production: replace the drawn logo
/// with official provider SVGs from assets/wallets/ (see README).
class WalletCardWidget extends StatelessWidget {
  final EWallet wallet;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  const WalletCardWidget(this.wallet, {super.key, this.selected = false, this.onTap, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final p = wallet.provider;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [p.c1, p.c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          border: selected ? Border.all(color: Colors.white, width: 2.2) : null,
          boxShadow: C.shadowSm,
        ),
        child: Row(children: [
          _WalletLogo(provider: p),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(App.t(p.nameEn, p.nameAr), style: T.semi.copyWith(color: Colors.white, fontSize: 14.5)),
              const SizedBox(height: 3),
              Text(wallet.masked,
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5, fontFamily: 'monospace', letterSpacing: 0.8)),
            ]),
          ),
          if (onRemove != null)
            InkResponse(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
            )
          else
            _RadioDot(selected: selected),
        ]),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Colors.white : Colors.transparent,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
      ),
      child: selected ? const Icon(Icons.check_rounded, size: 14, color: Color(0xFF1B1D28)) : null,
    );
  }
}

class _WalletLogo extends StatelessWidget {
  final WalletProvider provider;
  const _WalletLogo({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
        child: Text(
          _glyph(provider.id),
          style: TextStyle(color: provider.c1, fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
    );
  }

  String _glyph(String id) => switch (id) {
        'vf' => 'Voda', // Vodafone Cash — replace with official mark
        'og' => 'O',
        'et' => 'e&',
        'we' => 'we',
        _ => 'W',
      };
}

/// Small grid tile used on the "Add wallet" screen.
class ProviderTile extends StatelessWidget {
  final WalletProvider provider;
  final bool selected;
  final VoidCallback onTap;
  const ProviderTile(this.provider, {super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? provider.c1 : C.line, width: selected ? 1.8 : 1),
          boxShadow: C.shadowSm,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [provider.c1, provider.c2]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                switch (provider.id) {
                  'vf' => 'V', 'og' => 'O', 'et' => 'e&', _ => 'we',
                },
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(App.t(provider.nameEn, provider.nameAr),
              textAlign: TextAlign.center,
              style: T.semi.copyWith(fontSize: 12, color: C.text)),
        ]),
      ),
    );
  }
}
