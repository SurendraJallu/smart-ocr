# Smart OCR mobile app

Flutter application for Android and iOS. The mobile client uploads images to the authenticated Java backend, where Tesseract performs English OCR.

## Requirements

- Flutter stable SDK and bundled Dart SDK
- Android Studio / Android SDK for Android
- macOS with Xcode for iOS builds

## Install and run

```bash
cd mobile
flutter create --platforms=android,ios --org com.smartocr .
flutter pub get
flutter run
```

If platform folders already exist, do not regenerate them. For a physical Android device, pass the reachable API address:

```bash
flutter run --dart-define=SMART_OCR_API_URL=http://YOUR_COMPUTER_LAN_IP:8080/api/v1
```

The default API URL `http://10.0.2.2:8080/api/v1` is for the Android emulator. iOS simulator can use `http://127.0.0.1:8080/api/v1`. Use HTTPS for deployed environments.

## Firebase Authentication setup

Create a Firebase project and register the Android and iOS application identifiers. Configure native Firebase files using FlutterFire:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Add generated `google-services.json` and `GoogleService-Info.plist` locally. Do not commit signing keys or service-account secrets. Enable Email/Password sign-in in Firebase Authentication and configure backend `FIREBASE_PROJECT_ID` and `FIREBASE_ISSUER_URI` to the same project.

Server OCR and document saving require a signed-in Firebase user and a backend configured for that same Firebase project. The backend host must have Tesseract OCR and English language data installed.

## Current workflow

1. Capture a document with the camera or select an image from the gallery.
2. Upload the image to the authenticated backend for English OCR.
3. Review and edit the recognized text.
4. Select a document type and title.
5. Sign in and save reviewed text to the authenticated user's backend record.

PDF import, multipage scanning, crop/rotate controls, document history UI, export, cloud image storage and document-specific field extraction are follow-on modules.
