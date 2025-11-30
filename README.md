# Instagram Clone (Flutter)

Concise Flutter project for an Instagram‑like UI and flows.

## Requirements
- Flutter SDK installed; run `flutter doctor` to verify.
- Android Studio / Android SDK (for emulator and device tooling).

## Project Structure
- `lib/`
	- `main.dart` — app entry and routing.
	- `models/` — simple repositories: `chat_repository.dart`, `posts_repository.dart`, `profile_repository.dart`.
	- `screens/` — feature screens (feed, profiles, creation, chat, etc.).
	- `widgets/` — shared UI (carousel, image adapters, sheets).
- `assets/images/` — image assets (declared in `pubspec.yaml`).
- `android/`, `macos/`, `web/` — platform targets.
- `android/` — Android platform target (this README focuses on Android).

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

Examples (Android):
- Android emulator: `flutter run -d emulator-5554`
- Physical device: `flutter run -d <device-id>`

## Android Notes (brief)
- Permissions: update `android/app/src/main/AndroidManifest.xml` when enabling camera/gallery/microphone.
- Application ID: set `applicationId` in `android/app/build.gradle.kts` (`defaultConfig`).
- SDK: ensure `minSdk`/`targetSdk` values in `android/app/build.gradle.kts` meet dependency requirements.

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
- If Android build fails after dependency changes: `flutter clean && flutter pub get` then rebuild.
- If emulator/device not detected: `flutter devices` and ensure Android SDK path is configured.