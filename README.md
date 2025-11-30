# Instagram Clone (Flutter)

Concise Flutter project for an Instagram‑like UI and flows.

## Requirements
- Flutter SDK installed; run `flutter doctor` to verify.
- Xcode (for iOS/macOS), Android Studio/SDK (for Android), CocoaPods on macOS.

## Project Structure
- `lib/`
	- `main.dart` — app entry and routing.
	- `models/` — simple repositories: `chat_repository.dart`, `posts_repository.dart`, `profile_repository.dart`.
	- `screens/` — feature screens (feed, profiles, creation, chat, etc.).
	- `widgets/` — shared UI (carousel, image adapters, sheets).
- `assets/images/` — image assets (declared in `pubspec.yaml`).
- `android/`, `macos/`, `web/` — platform targets.

## Notable Files
- `lib/screens/home_screen.dart` — feed grid and navigation hub.
- `lib/screens/create_post_*` — post creation flow (picker → editor → finalize).
- `lib/widgets/media_carousel.dart` — media paging/indicators.
- `lib/widgets/platform_image*.dart` — platform image abstraction (web/IO/stub).

## Run
From the project root:

```bash
flutter pub get
flutter devices        # pick a device id
flutter run -d <device-id>
```

Examples:
- Android emulator: `flutter run -d emulator-5554`
- iOS simulator: `flutter run -d ios`
- macOS desktop: `flutter run -d macos`
- Web (Chrome): `flutter run -d chrome`

## Platform Notes (brief)
- iOS/macOS: add usage descriptions in `Info.plist` if using camera/gallery/video:
	- `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSMicrophoneUsageDescription`.
- Android: ensure required permissions in `android/app/src/main/AndroidManifest.xml` for camera/gallery as needed.

## Assets
- Place images under `assets/images/`.
- Already referenced in `pubspec.yaml` → `flutter.assets`.

## Dependencies (key)
- `image_picker`, `video_player`, `shared_preferences`, `provider`, `cached_network_image`, `flutter_staggered_grid_view`.

## Dev Tips
- Hot reload: `r` in the running terminal or VS Code Flutter actions.
- Linting: `flutter analyze` (configured via `analysis_options.yaml`).
- Tests: `flutter test` (add tests under `test/`).

## Troubleshooting (quick)
- If iOS/macOS build fails after dependency changes: `cd ios && pod install` or `cd macos && pod install` (then return to root).
- If builds act stale: `flutter clean && flutter pub get`.