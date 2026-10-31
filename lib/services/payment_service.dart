/* ==================================================================
 * ⚠️  SIMULATION LAYER — nothing here performs a real payment.      ⚠️
 * ==================================================================
 * The prototype fakes the hardware/bank side with delays and mock
 * payloads so the UX can be reviewed end-to-end. Replace each method
 * with the real integration listed next to it. Never present a
 * simulated result to the user as a confirmed real transaction.
 * ------------------------------------------------------------------ */

/// Mock payload returned by the simulated NFC card read.
class NfcReadResult {
  final String last4;
  final String holder;
  final String exp; // MM/yy
  final String panBin; // first 6 digits (BIN) — used to pick the bank design
  const NfcReadResult(this.last4, this.holder, this.exp, this.panBin);
}

class PaymentService {
  PaymentService._();

  /// ── NFC card reading ──────────────────────────────────────────────
  /// REAL: nfc_manager reader mode (ISO 14443-A, APDU SELECT/READ).
  /// Reads PAN, expiry and cardholder name from the EMV app (PPSE/AID).
  /// CVV/CVC is physically NOT readable over NFC — the user must type it
  /// for issuer verification, and it is passed to the PSP and discarded.
  static Future<NfcReadResult> simulateCardRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    return const NfcReadResult('7316', 'OMAR KHALED', '07/28', '453988');
  }

  /// ── NFC availability / device checks ──────────────────────────────
  /// REAL: NfcManager.instance.isAvailable() + HCE feature query
  /// (FEATURE_NFC_HOST_CARD_EMULATION) on Android.
  static Future<bool> nfcAvailable() async => true;

  /// ── Tap-to-pay (HCE) ──────────────────────────────────────────────
  /// REAL REQUIRES ALL OF:
  ///   1. Android HCE service (HostApduService) with PPSE response.
  ///   2. Issuer/network tokenization: Visa VTS or Mastercard MDES,
  ///      provisioned through an approved PSP — a plain PAN must NEVER
  ///      be emulated.
  ///   3. Bank acquirer agreement + PCI DSS scope + network certification.
  /// Reading a card does NOT authorize emulation (spec §4).
  static Future<bool> simulateTerminalTap() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    return true; // demo always authorizes
  }

  /// ── PSP charge (QR / card / wallet / recharge) ─────────────────────
  /// REAL: PSP API call (e.g. Paymob / Fawry / bank gateway) using the
  /// stored TOKEN — the full PAN never leaves the secure enclave.
  static Future<Map<String, String>> simulateCharge({
    required double amount,
    required String method,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    final ref =
        'MP-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    return {'status': 'success', 'ref': ref, 'method': method};
  }

  /// ── Card tokenization (add card) ───────────────────────────────────
  /// REAL: PSP SDK (PCI DSS scope) — card data goes device→PSP directly;
  /// MobiPay only ever receives back [token]. CVV is NOT stored.
  static Future<String> tokenize({required String last4}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return 'tok_new_${last4}_${DateTime.now().millisecondsSinceEpoch % 99999}';
  }

  /// ── Operator recharge ──────────────────────────────────────────────
  /// REAL: official operator APIs / aggregators (Vodafone, Orange, e&,
  /// WE). Balance subscriptions and scratch cards are intentionally NOT
  /// part of MobiPay v2 (spec §7).
  static Future<String> simulateRecharge() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    return 'MP-2026-R${DateTime.now().millisecondsSinceEpoch % 999999}';
  }
}
