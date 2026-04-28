# Technology Stack

## Languages & Runtime
- **Dart** `>=3.0.0 <4.0.0` — primary application language
- **Kotlin** — Android runner (MainActivity)
- **Swift** — iOS/macOS runner (AppDelegate, MainFlutterWindow)
- **C++** — Windows/Linux runners (CMake-based)
- **CMake** — Windows and Linux build system

## Framework
- **Flutter** (uses-material-design: true) — cross-platform UI framework
- Targets: iOS, Android, Web, macOS, Linux, Windows

## Key Dependencies (`pubspec.yaml`)
| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.5.1 | State management (StateNotifierProvider) |
| google_sign_in | ^6.2.1 | Google OAuth authentication |
| hive | ^2.2.3 | Local NoSQL storage |
| hive_flutter | ^1.1.0 | Hive Flutter adapter |
| shared_preferences | ^2.2.3 | Simple key-value persistence |

## Dev Dependencies
| Package | Version | Purpose |
|---|---|---|
| flutter_lints | ^5.0.0 | Lint rules |
| flutter_test | sdk | Widget/unit testing |

## Networking
- **dart:io WebSocket** — local Wi-Fi multiplayer (no external server); host binds `HttpServer` on port 4040, guest connects via `ws://host:port`
- Share code format: `192.168.x.x:4040`

## Build & Run Commands
```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build iOS IPA
flutter build ipa

# Build Android APK
flutter build apk

# Build for web
flutter build web

# Run tests
flutter test

# Analyze code
flutter analyze
```

## App Metadata
- **App name**: Crossword Master
- **Package**: `com.example.crossword_master` / `com.example.crosswordMaster` (iOS)
- **Version**: 0.1.0
- **Bundle ID (iOS)**: `838UP2BKV4.com.example.crosswordMaster`

## Platform Configs
- **Android**: Gradle Kotlin DSL (`build.gradle.kts`)
- **iOS**: CocoaPods (`Podfile`), embedded frameworks include AppAuth, GoogleSignIn, GTMAppAuth, GTMSessionFetcher, GoogleUtilities
- **Web**: PWA manifest + icons in `web/`
- **Windows/Linux**: CMake runners in `windows/runner/` and `linux/runner/`
