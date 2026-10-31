import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';

/* ---------- NFC pulse animation (both NFC scenes) ---------- */

class NfcPulse extends StatefulWidget {
  final double size;
  final bool animate;
  final Color? ringColor;
  const NfcPulse({super.key, this.size = 150, this.animate = true, this.ringColor});

  @override
  State<NfcPulse> createState() => _NfcPulseState();
}

class _NfcPulseState extends State<NfcPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant NfcPulse old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_ctrl.isAnimating) _ctrl.repeat();
    if (!widget.animate && _ctrl.isAnimating) _ctrl.stop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = widget.ringColor ?? C.primary.withOpacity(0.35);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(alignment: Alignment.center, children: [
        if (widget.animate) ...List.generate(3, (i) {
          final start = i / 3;
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final t = ((_ctrl.value - start) % 1.0);
              return Container(
                width: widget.size * (0.42 + t * 0.58),
                height: widget.size * (0.42 + t * 0.58),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ring.withOpacity((1 - t) * 0.8), width: 2),
                ),
              );
            },
          );
        }),
        Container(
          width: widget.size * 0.42,
          height: widget.size * 0.42,
          decoration: BoxDecoration(
            gradient: C.gradPrimaryDeep,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: C.primary.withOpacity(0.45), blurRadius: 26, offset: const Offset(0, 10))],
          ),
          child: const Icon(Icons.contactless_rounded, color: Colors.white, size: 34),
        ),
      ]),
    );
  }
}

/* ---------- Success micro-animation (check + rings) ---------- */

class SuccessBurst extends StatefulWidget {
  final double size;
  const SuccessBurst({super.key, this.size = 110});

  @override
  State<SuccessBurst> createState() => _SuccessBurstState();
}

class _SuccessBurstState extends State<SuccessBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(alignment: Alignment.center, children: [
        ...List.generate(6, (i) {
          final angle = i * math.pi / 3;
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final t = Curves.easeOut.transform(_ctrl.value);
              return Transform.translate(
                offset: Offset(math.cos(angle) * 46 * t, math.sin(angle) * 46 * t),
                child: Opacity(
                  opacity: (1 - t) * 0.9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: [C.primary, C.secondary, C.success, C.warning][i % 4],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        ScaleTransition(
          scale: CurvedAnimation(parent: _ctrl, curve: const Interval(0.15, 0.75, curve: Curves.elasticOut)),
          child: Container(
            width: widget.size * 0.62,
            height: widget.size * 0.62,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [C.success, const Color(0xFF1E9E54)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: C.success.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10))],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
          ),
        ),
      ]),
    );
  }
}

/* ---------- QR laser line (scan screen) ---------- */

class LaserLine extends StatefulWidget {
  const LaserLine({super.key});
  @override
  State<LaserLine> createState() => _LaserLineState();
}

class _LaserLineState extends State<LaserLine> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Align(
          alignment: Alignment(0, _ctrl.value * 1.7 - 0.85),
          child: Container(
            width: double.infinity,
            height: 2.4,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                C.secondary.withOpacity(0),
                C.secondary,
                Colors.white,
                C.secondary,
                C.secondary.withOpacity(0),
              ]),
              boxShadow: [BoxShadow(color: C.secondary.withOpacity(0.8), blurRadius: 12)],
            ),
          ),
        );
      },
    );
  }
}

/* ---------- Bottom sheet helper ---------- */

Future<T?> showSheet<T>(BuildContext context, {required Widget child, double pad = 22}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.fromLTRB(pad, 14, pad, pad + MediaQuery.of(context).padding.bottom * 0.4),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: child,
    ),
  );
}

String progressLabel(double v) => '${(v * 100).round()}%';
