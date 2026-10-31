import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

/* ---------- Scaffold chrome ---------- */

class Screen extends StatelessWidget {
  final String titleEn, titleAr;
  final String? titleSubAr; // e.g. "My Cards" + "بطاقاتي"
  final Widget body;
  final List<Widget>? actions;
  final Color? bg;
  const Screen(
      {super.key,
      required this.titleEn,
      required this.titleAr,
      this.titleSubAr,
      required this.body,
      this.actions,
      this.bg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg ?? C.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Row(children: [
              _roundIconBtn(context, Icons.arrow_back_ios_new, App.dir == TextDirection.rtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new, () => Navigator.maybePop(context)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(App.t(titleEn, titleAr), style: T.h2.copyWith(color: C.text)),
                  if (titleSubAr != null)
                    Text(titleSubAr!, style: T.small.copyWith(color: C.muted)),
                ]),
              ),
              ...?actions,
            ]),
          ),
          const SizedBox(height: 10),
          Expanded(child: body),
        ]),
      ),
    );
  }
}

Widget _roundIconBtn(BuildContext context, IconData icon, IconData rtlIcon, VoidCallback onTap) {
  return InkResponse(
    onTap: () {
      HapticFeedback.selectionClick();
      onTap();
    },
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: C.card, shape: BoxShape.circle, border: Border.all(color: C.line)),
      child: Icon(App.dir == TextDirection.rtl ? rtlIcon : icon, size: 18, color: C.text),
    ),
  );
}

/* ---------- Buttons ---------- */

class PrimaryButton extends StatelessWidget {
  final String labelEn, labelAr;
  final VoidCallback? onTap;
  final bool enabled;
  const PrimaryButton(this.labelEn, this.labelAr, {super.key, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: C.gradPrimary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled ? [BoxShadow(color: C.primary.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))] : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled
                ? () {
                    HapticFeedback.mediumImpact();
                    onTap!();
                  }
                : null,
            child: Center(
              child: Text(App.t(labelEn, labelAr),
                  style: T.button.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String labelEn, labelAr;
  final VoidCallback? onTap;
  final Color? color;
  const GhostButton(this.labelEn, this.labelAr, {super.key, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color ?? C.line, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          foregroundColor: color ?? C.text,
        ),
        child: Text(App.t(labelEn, labelAr), style: T.button.copyWith(color: color ?? C.text)),
      ),
    );
  }
}

/* ---------- Small parts ---------- */

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: C.warningSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.warning.withOpacity(0.5)),
      ),
      child: Text('DEMO', style: T.caption.copyWith(color: C.warning)),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String en, ar;
  final String? actionEn, actionAr;
  final VoidCallback? onAction;
  const SectionTitle(this.en, this.ar, {super.key, this.actionEn, this.actionAr, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(children: [
        Expanded(child: Text(App.t(en, ar), style: T.h3.copyWith(color: C.text))),
        if (actionEn != null)
          InkResponse(
            onTap: onAction,
            child: Text(App.t(actionEn!, actionAr ?? actionEn!),
                style: T.semi.copyWith(color: C.primary, fontSize: 13)),
          ),
      ]),
    );
  }
}

class InfoNote extends StatelessWidget {
  final IconData icon;
  final String en, ar;
  final Color? color;
  const InfoNote(this.icon, this.en, this.ar, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? C.secondary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: App.isDark ? Colors.white.withOpacity(0.04) : c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 17, color: c),
        const SizedBox(width: 10),
        Expanded(
          child: Text(App.t(en, ar), style: T.small.copyWith(color: C.sub, height: 1.45)),
        ),
      ]),
    );
  }
}

/* ---------- Payment source picking (cards + wallets) ---------- */

class PaySource {
  final BankCard? card;
  final EWallet? wallet;
  const PaySource.card(this.card) : wallet = null;
  const PaySource.wallet(this.wallet) : card = null;
  bool get isCard => card != null;
  String get labelEn => isCard
      ? '${card!.bank.displayEn} ••${card!.last4}'
      : '${wallet!.provider.nameEn} · ${wallet!.masked}';
  String get labelAr => isCard
      ? '${card!.bank.displayAr} ••${card!.last4}'
      : '${wallet!.provider.nameAr} · ${wallet!.masked}';
  Color get color => isCard ? card!.bank.c1 : wallet!.provider.c1;
  String get short => isCard ? card!.bank.short : wallet!.provider.nameEn.substring(0, 2);
}

class SourcePicker extends StatelessWidget {
  final PaySource? selected;
  final ValueChanged<PaySource> onSelect;
  const SourcePicker({super.key, this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final sources = [
      ...userCards.map((c) => PaySource.card(c)),
      ...userWallets.map((w) => PaySource.wallet(w)),
    ];
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: sources.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final s = sources[i];
          final isSel = selected != null &&
              selected!.card?.id == s.card?.id &&
              selected!.wallet?.id == s.wallet?.id &&
              selected!.isCard == s.isCard;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(s);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSel ? C.primarySoft : C.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSel ? C.primary : C.line, width: isSel ? 1.6 : 1),
              ),
              child: Row(children: [
                _SourceDot(s: s),
                const SizedBox(width: 9),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    App.t(s.labelEn, s.labelAr),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.semi.copyWith(fontSize: 12, color: C.text),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _SourceDot extends StatelessWidget {
  final PaySource s;
  const _SourceDot({required this.s});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [s.color, s.color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(s.short, style: T.caption.copyWith(color: Colors.white, fontSize: 9)),
      ),
    );
  }
}

/* ---------- Transaction tile ---------- */

class TxTile extends StatelessWidget {
  final Txn txn;
  final VoidCallback? onTap;
  const TxTile(this.txn, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, tint) = _typeVisual(txn.type);
    final out = txn.amount < 0;
    final statusColor = switch (txn.status) {
      TxStatus.success => C.success,
      TxStatus.pending => C.warning,
      TxStatus.failed => C.error,
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 20, color: C.text),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(txn.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: T.semi.copyWith(color: C.text, fontSize: 14)),
              const SizedBox(height: 2),
              Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(_methodLabel(), maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: T.small.copyWith(color: C.muted, fontSize: 11.5)),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${out ? '−' : '+'} EGP ${txn.amount.abs().toStringAsFixed(2)}',
                style: T.semi.copyWith(color: out ? C.text : C.success, fontSize: 14)),
            const SizedBox(height: 2),
            Text(_dateLabel(txn.date), style: T.small.copyWith(color: C.muted, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }

  String _methodLabel() {
    final st = switch (txn.status) {
      TxStatus.success => '',
      TxStatus.pending => App.t('Pending · ', 'قيد المعالجة · '),
      TxStatus.failed => App.t('Failed · ', 'فشلت · '),
    };
    return App.isAr ? txn.arMethod + st : st + txn.method;
  }

  (IconData, Color) _typeVisual(TxType t) => switch (t) {
        TxType.nfc => (Icons.contactless_rounded, C.primarySoft),
        TxType.qr => (Icons.qr_code_2_rounded, C.secondarySoft),
        TxType.card => (Icons.credit_card_rounded, C.successSoft),
        TxType.wallet => (Icons.account_balance_wallet_rounded, C.warningSoft),
        TxType.recharge => (Icons.phone_android_rounded, C.errorSoft),
      };
}

extension TxnAr on Txn {
  String get arMethod => switch (type) {
        TxType.nfc => method.replaceAll('NFC', 'لامس'),
        TxType.qr => method.replaceAll('QR', 'رمز QR'),
        _ => method,
      };
}

String _dateLabel(DateTime d) {
  final now = DateTime.now();
  final day = DateTime(d.year, d.month, d.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return App.t('Today', 'اليوم');
  if (diff == 1) return App.t('Yesterday', 'أمس');
  return '${d.day}/${d.month}';
}

String dateLabelFor(DateTime d) => _dateLabel(d);
