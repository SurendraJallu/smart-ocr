# Mobile application

This directory is reserved for the Flutter application targeting Android and iOS from one Dart codebase.

## Local prerequisites

- Flutter stable SDK (use the version selected by the team)
- Dart SDK bundled with Flutter
- Android Studio and Android SDK for Android builds
- macOS and Xcode for iOS builds

## Generate platform scaffolding

From the repository root, after installing Flutter:

```bash
flutter create --platforms=android,ios --org com.smartocr mobile
cd mobile
flutter doctor
flutter pub get
```

If this directory already contains Flutter project files, do not run `flutter create` over them.

## Planned client modules

- Authentication and session management
- Camera/gallery document import
- Image preview, crop, rotate, and enhancement
- On-device English OCR
- Document classification and field extraction suggestions
- Review/edit/confirm screen
- User-scoped document history
- PDF and spreadsheet export

## Configuration

Do not commit Firebase configuration files or signing credentials. Add environment-specific setup instructions once the Firebase project and application identifiers are selected.
