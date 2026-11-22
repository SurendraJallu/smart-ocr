# Smart OCR mobile app

Flutter application for Android and iOS. The mobile client uploads images to the authenticated Java backend, where Tesseract performs English OCR.

## Requirements

- Flutter stable SDK and bundled Dart SDK
- Android Studio / Android SDK for Android builds
- macOS with Xcode for iOS builds

## Build and run on Windows

Open PowerShell in the repository folder:

```powershell
cd mobile
flutter create --platforms=android,ios --org com.smartocr .
flutter pub get
flutter analyze
flutter test
flutter run
```

To build a local Android debug APK:

```powershell
flutter build apk --debug --dart-define=SMART_OCR_API_URL=http://10.0.2.2:8080/api/v1
```

The APK is created at:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

If platform folders already exist, do not regenerate them. For a physical Android device, use your computer's reachable LAN IP instead of `10.0.2.2`:

```powershell
flutter run --dart-define=SMART_OCR_API_URL=http://YOUR_COMPUTER_LAN_IP:8080/api/v1
```

The default API URL `http://10.0.2.2:8080/api/v1` is for the Android emulator. iOS simulator can use `http://127.0.0.1:8080/api/v1`. Use HTTPS for deployed environments.

## Download the CI demo APK

The Mobile CI workflow builds a debug APK after analysis and tests pass, then uploads it as the `smart-ocr-android-demo` artifact on the GitHub Actions run. Download and unzip that artifact to get `app-debug.apk`.

This CI APK is a demo build, not a Play Store release. It uses the Android emulator API URL. For a physical device, build locally with your computer's LAN IP as shown above.

## Firebase Authentication setup

Create a Firebase project and register the Android and iOS application identifiers. Configure native Firebase files using FlutterFire:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Add generated `google-services.json` and `GoogleService-Info.plist` locally. Do not commit signing keys or service-account secrets. Enable Email/Password sign-in in Firebase Authentication and configure backend `FIREBASE_PROJECT_ID` and `FIREBASE_ISSUER_URI` to the same project.

Server OCR and document saving require a signed-in Firebase user and a backend configured for that same Firebase project. The backend host must have Tesseract OCR and English language data installed.

Without Firebase configuration, the app can launch for UI/demo preview, but authentication, server OCR and document saving are unavailable.

## Current workflow

1. Configure Firebase and sign in.
2. Capture a document with the camera or select an image from the gallery.
3. Upload the image to the authenticated backend for English OCR.
4. Review and edit the recognized text.
5. Select a document type and title, then save the reviewed text to the authenticated user's backend record.

PDF import, multipage scanning, crop/rotate controls, document history UI, export, cloud image storage and document-specific field extraction are follow-on modules.
