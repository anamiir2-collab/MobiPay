import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../widgets/ui.dart';
import 'txn_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TxType? _filter;

  static const _filters = <(TxType?, String, String)>[
    (null, 'All', 'الكل'),
    (TxType.nfc, 'NFC', 'NFC'),
    (TxType.qr, 'QR', 'QR'),
    (TxType.card, 'Cards', 'البطاقات'),
    (TxType.wallet, 'Wallets', 'المحافظ'),
    (TxType.recharge, 'Recharge', 'الشحن'),
  ];

  @override
  Widget build(BuildContext context) {
    final items = txns.where((t) => _filter == null || t.type == _filter).toList();
    final groups = <String, List<Txn>>{};
    for (final t in items) {
      groups.putIfAbsent(dateLabelFor(t.date), () => []).add(t);
    }

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 2),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(App.t('Transaction History', 'سجل العمليات'), style: T.h1.copyWith(color: C.text)),
                Text(App.t('NFC · QR · Cards · Wallets · Recharge', 'لامس · QR · بطاقات · محافظ · شحن'),
                    style: T.small.copyWith(color: C.muted)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          /* filter chips */
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _filters.map((f) {
                final sel = _filter == f.$1;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? C.primary : C.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? C.primary : C.line),
                    ),
                    child: Text(App.t(f.$2, f.$3),
                        style: T.semi.copyWith(color: sel ? Colors.white : C.sub, fontSize: 12.5)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.receipt_long_rounded, size: 46, color: C.muted.withOpacity(0.5)),
                      const SizedBox(height: 10),
                      Text(App.t('No transactions yet', 'لا توجد عمليات بعد'),
                          style: T.body.copyWith(color: C.muted)),
                    ]),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                    children: groups.entries.map((g) {
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                          child: Text(g.key, style: T.caption.copyWith(color: C.muted)),
                        ),
                        Container(
                          decoration: D.card(),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (var i = 0; i < g.value.length; i++) ...[
                                if (i > 0) Divider(height: 1, color: C.line, indent: 16, endIndent: 16),
                                TxTile(g.value[i], onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => TxnDetailScreen(txn: g.value[i])));
                                }),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ]);
                    }).toList(),
                  ),
          ),
        ]),
      ),
    );
  }
}
