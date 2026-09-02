# exotel-voip-sdk-flutter
Contains SDK, integration guide, sample app package and API documentation.

## Exotel Voice SDK
Download latest flutter plugin sdk from [Plugin directory](./Plugin)

## Exotel Voice Flutter SDK Integration Guide  
File: [Exotel Flutter SDK Integration Guide.pdf](Exotel%20Flutter%20SDK%20Integration%20Guide.pdf)
Documentation: https://docs.exotel.com/voice-apis/client-flutter-sdk

## Firebase setup (required to build the sample apps)

Firebase config files are **not** shipped in this repo (per VST-2003 — previous keys were rotated and purged from git history).

1. Create your own Firebase project at https://console.firebase.google.com/
2. Add Android + iOS apps with the package/bundle IDs used by this SDK.
3. Run `flutterfire configure` to generate `firebase_options.dart`, OR manually:
   - Download `google-services.json` → place at each `android/app/` path listed in `.gitignore`.
   - Download `GoogleService-Info.plist` → place at each `ios/Runner/` path.
4. In GCP Console, restrict all generated API keys (Android: package + SHA-1; iOS: bundle ID).

Templates (with placeholder keys) are provided as `*.sample` alongside each expected location.
