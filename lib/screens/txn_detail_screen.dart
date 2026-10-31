import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../models/models.dart';
import '../widgets/ui.dart';

class TxnDetailScreen extends StatelessWidget {
  final Txn txn;
  const TxnDetailScreen({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    final out = txn.amount < 0;
    final statusColor = switch (txn.status) {
      TxStatus.success => C.success,
      TxStatus.pending => C.warning,
      TxStatus.failed => C.error,
    };
    final statusLabel = switch (txn.status) {
      TxStatus.success => App.t('Completed', 'مكتملة'),
      TxStatus.pending => App.t('Pending', 'قيد المعالجة'),
      TxStatus.failed => App.t('Failed', 'فاشلة'),
    };
    final typeLabel = switch (txn.type) {
      TxType.nfc => App.t('NFC contactless payment', 'دفع بالتقريب NFC'),
      TxType.qr => App.t('QR payment', 'دفع برمز QR'),
      TxType.card => App.t('Card payment', 'دفع بالبطاقة'),
      TxType.wallet => App.t('Wallet transaction', 'عملية محفظة'),
      TxType.recharge => App.t('Mobile balance recharge', 'شحن رصيد موبايل'),
    };

    return Screen(
      titleEn: 'Transaction',
      titleAr: 'تفاصيل العملية',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /* amount header */
          Container(
            padding: const EdgeInsets.all(22),
            decoration: D.card(),
            child: Column(children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(
                  txn.status == TxStatus.failed
                      ? Icons.close_rounded
                      : txn.type == TxType.nfc
                          ? Icons.contactless_rounded
                          : txn.type == TxType.qr
                              ? Icons.qr_code_2_rounded
                              : txn.type == TxType.wallet
                                  ? Icons.account_balance_wallet_rounded
                                  : txn.type == TxType.recharge
                                      ? Icons.phone_android_rounded
                                      : Icons.credit_card_rounded,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text('${out ? '−' : '+'} EGP ${txn.amount.abs().toStringAsFixed(2)}',
                  style: T.display.copyWith(color: C.text, fontSize: 29)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(statusLabel, style: T.caption.copyWith(color: statusColor, fontSize: 10.5)),
              ),
              const SizedBox(height: 10),
              Text(txn.title, style: T.h3.copyWith(color: C.text, fontSize: 16)),
            ]),
          ),

          /* timeline */
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: D.card(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(App.t('Timeline', 'الجدول الزمني'), style: T.h3.copyWith(color: C.text, fontSize: 14.5)),
              const SizedBox(height: 14),
              _step(App.t('Initiated', 'بدأت العملية'), _t(txn.date, 0), done: true),
              _step(App.t('Authorized', 'تم الاعتماد'), _t(txn.date, 2),
                  done: txn.status != TxStatus.pending, isLast: txn.status == TxStatus.failed, failed: txn.status == TxStatus.failed),
              if (txn.status != TxStatus.failed)
                _step(
                  txn.status == TxStatus.pending ? App.t('Awaiting confirmation', 'بانتظار التأكيد') : App.t('Completed', 'اكتملت'),
                  _t(txn.date, 5),
                  done: txn.status == TxStatus.success,
                  isLast: true,
                ),
            ]),
          ),

          /* details */
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: D.card(),
            child: Column(children: [
              _row(App.t('Date & time', 'التاريخ والوقت'), _full(txn.date)),
              _div(),
              _row(App.t('Type', 'النوع'), typeLabel),
              _div(),
              _row(App.t('Payment method', 'طريقة الدفع'), App.isAr ? txn.arMethod : txn.method),
              _div(),
              _row(App.t('Category', 'الفئة'), txn.category),
              _div(),
              _row(App.t('Reference', 'المرجع'), txn.ref),
            ]),
          ),

          const SizedBox(height: 18),
          PrimaryButton(App.t('Share receipt', 'مشاركة الإيصال'), 'مشاركة الإيصال',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(App.t('Receipt shared (demo)', 'تمت مشاركة الإيصال (تجريبي)')),
                  behavior: SnackBarBehavior.floating))),
          const SizedBox(height: 10),
          GhostButton(App.t('Report a problem', 'الإبلاغ عن مشكلة'), 'الإبلاغ عن مشكلة',
              color: C.error,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(App.t('Support ticket opened (demo)', 'تم فتح تذكرة دعم (تجريبي)')),
                  behavior: SnackBarBehavior.floating))),
        ],
      ),
    );
  }

  Widget _step(String label, String time, {required bool done, bool isLast = false, bool failed = false}) {
    final c = failed ? C.error : (done ? C.success : C.muted);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Column(children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(shape: BoxShape.circle, color: done ? c : Colors.transparent, border: Border.all(color: c, width: 2)),
            child: done ? const Icon(Icons.check_rounded, size: 10, color: Colors.white) : null,
          ),
          if (!isLast) Expanded(child: Container(width: 2, color: C.line)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(children: [
              Expanded(child: Text(label, style: T.semi.copyWith(color: C.text, fontSize: 13.5))),
              Text(time, style: T.small.copyWith(color: C.muted, fontSize: 11.5)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(flex: 2, child: Text(label, style: T.small.copyWith(color: C.muted))),
          Expanded(
              flex: 3,
              child: Text(value,
                  textAlign: App.dir == TextDirection.rtl ? TextAlign.left : TextAlign.right,
                  style: T.semi.copyWith(color: C.text, fontSize: 13))),
        ]),
      );

  Widget _div() => Divider(height: 1, color: C.line);

  String _t(DateTime d, int addMinutes) {
    final t = d.add(Duration(minutes: addMinutes));
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _full(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
