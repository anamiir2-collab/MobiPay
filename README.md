# MobiPay — Unified Digital Payment Application

**MobiPay – الدفع الموحّد** · Flutter 3 · iOS-inspired design · Full Arabic RTL + English LTR

MobiPay is a single place to manage payment methods and choose how to pay:
Egyptian **bank cards**, **e-wallets**, **NFC contactless** payments, **QR** payments
and **mobile balance recharge**.

> ⚠️ **This build is a working prototype.** All money movements are simulated.
> No real transaction is ever performed, and the UI always labels simulated
> results (`DEMO` badges + disclaimers). MobiPay never claims a simulated
> transaction is real.

---

## 1. What's in this repository

```
mobipay/
├── lib/
│   ├── main.dart                  # app entry, theme, RTL/LTR switching
│   ├── core/
│   │   ├── app.dart               # locale (AR/EN), dark mode, change signals
│   │   └── style.dart             # MobiPay design tokens (colors, type, decor)
│   ├── models/models.dart         # BankCard / EWallet / Txn / Operator …
│   ├── data/mock_data.dart        # Egyptian banks, cards, wallets, merchants, txns (MOCK)
│   ├── services/payment_service.dart  # ⚠️ simulation layer + real-integration notes
│   ├── widgets/
│   │   ├── bank_card.dart         # realistic Egyptian bank card visual
│   │   ├── wallet_card.dart       # Vodafone Cash / Orange Cash / e& cash / WE Pay
│   │   ├── qr_painter.dart        # demo QR pattern (visual placeholder)
│   │   ├── fx.dart                # NFC pulse, success burst, laser line, sheets
│   │   └── ui.dart                # buttons, tiles, source picker, tx tile …
│   └── screens/
│       ├── splash / onboarding / unlock
│       ├── main_shell.dart        # bottom nav: Home · Cards · [NFC] · QR · History
│       ├── home_screen.dart       # default method, NFC hero, quick actions
│       ├── my_cards_screen.dart   # "My Cards – بطاقاتي" carousel
│       ├── add_card_screen.dart   # NFC card read + manual entry (flagship)
│       ├── card_detail_screen.dart# masked number, freeze/default/remove
│       ├── my_wallets_screen.dart # "My Wallets – محافظي الإلكترونية"
│       ├── add_wallet_screen.dart
│       ├── nfc_pay_screen.dart    # source → confirm → tap → result
│       ├── qr_scan_screen.dart    # laser viewfinder
│       ├── qr_confirm_screen.dart # merchant review → amount → receipt
│       ├── my_qr_screen.dart      # personal QR
│       ├── recharge_screen.dart   # Vodafone/Orange/e&/WE balance recharge
│       ├── history_screen.dart    # unified + filterable
│       ├── txn_detail_screen.dart # timeline, reference, receipt
│       └── profile_screen.dart    # language, dark mode, security
├── docs/AndroidManifest.xml       # NFC / CAMERA permissions (+ HCE service template)
├── screenshots/                   # rendered UI screenshots (EN + AR RTL samples)
└── pubspec.yaml
```

**Removed in v2** (product decision, spec §7): scratch cards (كروت الفكة),
mobile bundles (شحن الباقات), internet packages, utility bills, donations and
all other prepaid categories. **Only mobile balance recharge remains.**

## 2. Run it

```bash
cd mobipay
flutter create . --org com.mobipay --project-name mobipay   # generates android/ ios/ platforms
flutter pub get
flutter run
```

Merge the permissions from `docs/AndroidManifest.xml` into
`android/app/src/main/AndroidManifest.xml`. No third-party packages are
required for the prototype — everything runs on the Flutter SDK only.

## 3. Feature status matrix (honesty first)

| Feature | Status | What exists | What reality requires |
|---|---|---|---|
| Egyptian bank cards (10 banks, realistic designs) | ✅ Implemented (visual) | Gradients/emblems approximating each bank's identity; masked `•••• 4582` display; freeze / default / remove | Official bank SVG logos + real card artwork in `assets/banks/` |
| Add card — manual entry | ✅ Implemented (UI) | BIN→bank design detection, live card preview, validation | PCI DSS PSP SDK (Paymob / Fawry / bank gateway); device→PSP flow; tokenization |
| Add card — NFC read | ✅ Implemented (UI) | Reader-mode UX, "CVV not readable over NFC" handling, design picker | `nfc_manager` (ISO 14443/EMV PPSE→AID), issuer verification, `flutter_secure_storage` for tokens |
| Card storage & masking | ✅ Implemented (rule enforced) | Only `last4` + token are ever kept/displayed; CVV/PIN never stored | Real PSP tokens (VTS/MDES lifecycle), secure enclave |
| My Wallets (Vodafone Cash, Orange Cash, e& cash, WE Pay) | ✅ Implemented (visual) | Official-color wallet cards, masked numbers, source selection | Provider APIs (Meeza wallets / PSP aggregation), OTP linking, wallet–bank rails |
| NFC tap-to-pay | 🎨 UI demonstration | Full flow: source → amount → "hold near terminal" → success/decline | **All of:** Android HCE service, issuer tokenization (Visa **VTS** / Mastercard **MDES**) via approved PSP, acquirer/bank agreement, PCI DSS scope, network certification. *Reading a card ≠ being able to emulate it.* |
| QR payments (scan + personal QR) | 🎨 UI demonstration | Scan UX with laser viewfinder, merchant review, amount, receipt; personal QR screen | `mobile_scanner` for camera; **InstaPay / EMVCo** payload from PSP; merchant acquiring agreement |
| Mobile balance recharge | 🎨 UI demonstration | Operators (Vodafone, Orange, e&, WE), prefix detection, amounts, source, receipt | Official operator/aggregator APIs; settlement account |
| Transaction history | ✅ Implemented (local mock) | Unified NFC/QR/card/wallet/recharge list, filters, detail timeline, reference numbers | Backend ledger from the PSP; reconciliation |
| Biometric unlock | 🎨 UI demonstration | Unlock screen + toggle | `local_auth` (Face ID / BiometricPrompt) |
| Arabic RTL / English LTR | ✅ Implemented | Live language switch in Profile, mirrored layouts (`Directionality`) | Full `intl` localization for plurals/dates |

### Regulatory / certification dependencies
- **HCE tap-to-pay**: payment-network certification + issuer approval (VTS/MDES).
  Plain PAN emulation is forbidden — never implement it.
- **QR acceptance**: InstaPay/meeza network rules and merchant onboarding (KYC).
- **PCI DSS**: card data must flow device → PSP only; MobiPay servers never see a PAN.

## 4. Bank card artwork (spec §2)

The prototype approximates each bank's visual identity with its own gradient
and emblem — Banque Misr (green/gold), NBE (navy/gold), CIB (dark blue/gold),
QNB Alahli (maroon/gold), Banque du Caire (blue/gold), AlexBank, AAIB, HDB,
Faisal Islamic Bank, ADIB Egypt.

To reach pixel-accurate realism:

1. Obtain licensed/official SVG logos (or request brand kits from the banks).
2. Place them in `assets/banks/<id>.svg` (declare the folder in `pubspec.yaml`).
3. In `lib/widgets/bank_card.dart`, replace the `_BankEmblem` initials with
   `SvgPicture.asset('assets/banks/${bank.id}.svg')` (add `flutter_svg`).
4. Optionally add per-bank card textures under `assets/banks/cards/`.

The same applies to wallet logos (`assets/wallets/`) and operator logos
(`assets/operators/`).

## 5. Where to plug real services

| Mock in `payment_service.dart` | Replace with |
|---|---|
| `simulateCardRead()` | `nfc_manager` reader mode → APDU PPSE/GPO exchange (PAN/expiry/name only) |
| `simulateTerminalTap()` | HCE `HostApduService` + VTS/MDES provisioned token |
| `simulateCharge()` | PSP charge API using the stored token |
| `tokenize()` | PSP SDK card-entry SDK (PCI scope) |
| `simulateRecharge()` | Operator/aggregator top-up API |
| `DemoQrPainter` | `qr_flutter` with EMVCo/InstaPay payload |

## 6. Design system

Primary `#6C3CE0` · Secondary `#2D9CDB` · Background `#F7F8FA` · Success `#27AE60`
· Error `#EB5757` · Accent `#F2994A`. iOS-inspired: rounded cards (16–24px),
soft shadows, gradient hero actions, Inter typography (add TTFs to
`assets/fonts` and declare in `pubspec.yaml` for production).

## 7. Screenshots

See `screenshots/` — splash → onboarding → unlock → home → cards → add-card
(NFC & manual) → card detail → wallets → NFC pay → QR scan/confirm/my-QR →
recharge → history → transaction detail → profile, plus Arabic RTL and dark
mode samples.
