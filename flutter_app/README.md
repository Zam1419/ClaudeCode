# KSA Landed Cost — Flutter

Cross-platform (iOS + Android) app to calculate landed cost of imports into Saudi Arabia, with EN/AR, ZATCA-aligned customs/VAT rates, and an AdMob banner.

## Setup

This repo only contains the Dart sources (`lib/`) and `pubspec.yaml`. To turn it into a runnable Flutter project:

```bash
cd flutter_app
flutter create .                 # generates ios/, android/, web/, etc.
flutter pub get
flutter run
```

## AdMob configuration

The code uses Google's **test banner unit** (`ca-app-pub-3940256099942544/6300978111`). Before release:

1. Create AdMob app & banner unit IDs.
2. Replace `_testBannerUnit` in `lib/main.dart`.
3. Add your AdMob App ID to:
   - **Android:** `android/app/src/main/AndroidManifest.xml` inside `<application>`:
     ```xml
     <meta-data
         android:name="com.google.android.gms.ads.APPLICATION_ID"
         android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
     ```
   - **iOS:** `ios/Runner/Info.plist`:
     ```xml
     <key>GADApplicationIdentifier</key>
     <string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
     ```

## Localization

EN/AR strings live in `lib/i18n.dart`. RTL is handled automatically via `Directionality`. Tap the floating button to toggle language; choice is persisted with `shared_preferences`.

## Updating rates

`lib/data.dart` holds:
- `kFx` — currency → SAR conversion rates
- `kCategories` — ZATCA-aligned customs duty rates per category

For production, fetch these from Firebase Remote Config or your backend so you can update without resubmitting to the stores.

## Notes

- VAT is fixed at 15% (ZATCA).
- Duty is applied on CIF (value + freight + insurance), VAT on (CIF + duty).
- Clearance fees are passed through in SAR.
- All figures are estimates — verify with a licensed customs broker before commercial use.
