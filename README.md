# Bet EV Calculator (Flutter)

Cross-platform GUI app to compute:

- Implied probability (from odds)
- Expected value (EV) using your estimated win probability
- Push-aware EV (push returns stake, zero profit)
- EV%, edge, and expected return (stake + EV)

## Supported Platforms

- Android (debug APK for sideloading)
- iOS (local run on your devices; not built in CI or published to App Store)
- Windows (zip)
- macOS (zip containing `.app`)
- Linux (tar.gz bundle)

------------------------------------------------------------------------

## Inputs

- Stake (currency amount)
- Odds (one of):
  - Decimal: `1.91`
  - American: `-110`, `+150`
  - Fractional: `5/4`
- Win probability (%) --- your estimate
- Push probability (%) --- your estimate
  - Loss% is computed as `100 - Win% - Push%`

------------------------------------------------------------------------

## Outputs

Let:

- `S` = stake
- `D` = decimal odds
- `pW` = win probability (0..1)
- `pP` = push probability (0..1)
- `pL = 1 - pW - pP`

Then:

- Profit if win: `S * (D - 1)`
- Implied probability: `1 / D`
- EV (expected profit): `pW * (S*(D-1)) - pL * S`
- EV%: `EV / S`
- Expected return: `S + EV`
- Edge: `pW - p_implied`

Currency values are displayed with fixed 2 decimals.

------------------------------------------------------------------------

## Persistence

The app persists the last entered values using `shared_preferences`.

Reset button restores defaults:

- Stake: 10
- Odds: -110
- Win%: 55
- Push%: 5

------------------------------------------------------------------------

## Project Structure

``` text
lib/
├── main.dart                              # Entry point: runApp()
├── app.dart                               # MaterialApp, theme, routing
├── core/
│   └── odds.dart                          # Odds parsing + EV math (pure domain logic)
├── data/
│   └── calculator_preferences.dart        # SharedPreferences persistence layer
└── features/
    └── calculator/
        └── calculator_screen.dart         # Calculator UI + local state

test/
├── odds_test.dart                         # Unit tests for core/odds.dart
└── widget_test.dart                       # Smoke test for the app widget
```

------------------------------------------------------------------------

## Local Development

### Prerequisites

- Flutter SDK installed and available on PATH
- **CocoaPods** (required for iOS and macOS builds; `flutter pub get` triggers `pod install`)

### Run

``` bash
flutter pub get
flutter run
```

### Build locally

Android (debug APK):

``` bash
flutter build apk --debug
```

Windows (release):

``` bash
flutter build windows --release
```

macOS (release):

``` bash
flutter build macos --release
```

Linux (release):

``` bash
flutter config --enable-linux-desktop
flutter build linux --release
```

------------------------------------------------------------------------

## How to run the iOS app

The iOS app is for local use only (no App Store). You need a Mac with Xcode and an Apple ID (a free account is enough for your own devices).

### Prerequisites

- **Mac** with macOS 11 (Big Sur) or later
- **Xcode** from the Mac App Store (includes the iOS Simulator and device tooling)
- **CocoaPods** (`gem install cocoapods` or `brew install cocoapods`)
- **Apple ID** (no paid Developer Program membership required for personal devices)
- **Flutter** installed and on your PATH

### Option A: Run on the iOS Simulator (easiest)

No device or Apple ID setup required:

``` bash
cd /path/to/ev-bet-calculator
flutter pub get
flutter run
```

When prompted, choose an iPhone simulator (e.g. `iPhone 16`). Or specify one directly:

``` bash
flutter run -d "iPhone 16"
```

List available simulators:

``` bash
flutter devices
```

### Option B: Run on your iPhone or iPad

1. **Connect the device** with a USB cable. Unlock the device and tap **Trust** if asked to trust the computer.

2. **Enable Developer Mode** (iOS 16+): On the device go to **Settings → Privacy & Security → Developer Mode** and turn it on. Restart if prompted.

3. **Open the project in Xcode** (one-time setup for code signing):

   ``` bash
   open ios/Runner.xcworkspace
   ```

   Do **not** use `Runner.xcodeproj`; use `Runner.xcworkspace`.

4. **Set your Apple ID for signing:**  
   In Xcode, select the **Runner** project in the left sidebar → select the **Runner** target → open **Signing & Capabilities**.  
   Under **Team**, choose your Apple ID (or add it via **Add an Account…**).  
   Xcode will create a free provisioning profile for you.

5. **Select your device** in the device dropdown at the top of Xcode, then press **Run** (▶), or close Xcode and run from the terminal:

   ``` bash
   flutter run
   ```

   Flutter will list connected devices; pick your iPhone or iPad.

### Troubleshooting

- **"Could not find a valid signing identity"**  
  In Xcode → Signing & Capabilities, ensure a **Team** is selected and that you’re signed in with an Apple ID (Xcode → Settings → Accounts).

- **"Untrusted Developer" on device**  
  On the device: **Settings → General → VPN & Device Management** → tap your developer app profile → **Trust**.

- **Simulator not listed**  
  Open Xcode once and go to **Xcode → Settings → Platforms** to install an iOS simulator version.

------------------------------------------------------------------------

## CI Builds

Three workflows:

| Workflow | Trigger | What it does |
| -------- | ------- | ------------ |
| **Build Artifacts** | Push to `main` | Builds Windows, macOS, Linux, Android and uploads artifacts (no release). Artifact names include commit SHA. |
| **Publish** | Manual | Reads version from `pubspec.yaml`, builds all platforms, creates a GitHub Release with that version. Does not change `pubspec.yaml`. |
| **Bump and Publish** | Manual | You choose **major**, **minor**, or **hotfix**. Workflow bumps `pubspec.yaml`, pushes to `main`, builds, then creates the GitHub Release. |

Download build artifacts:

- GitHub → Actions → select a workflow run → **Artifacts**

------------------------------------------------------------------------

## Linux Usage

``` bash
tar -xzf ev_bet_calculator-linux-x64-<id>.tar.gz
./bundle/ev_bet_calculator
```

------------------------------------------------------------------------

## Android Installation

Download the debug APK artifact and sideload it.

You may need to enable "Install unknown apps" on your device.

------------------------------------------------------------------------

## Semantic Versioning

`pubspec.yaml` format:

```pubspec
    version: MAJOR.MINOR.PATCH+BUILD
```

Example:

```pubspec
    version: 0.1.0+1
```

Release tags follow `vMAJOR.MINOR.PATCH` (e.g. `v0.1.0`). Prerelease suffixes like `v1.2.0-rc.1` are supported.

------------------------------------------------------------------------

## Release Process

You do **not** edit `pubspec.yaml` by hand for releases. Use one of the two manual workflows.

### Option A: Publish (release current version)

Use when `pubspec.yaml` already has the version you want to release.

1. Ensure `pubspec.yaml` has the desired version (e.g. `0.1.0+1`) and that change is on `main`.
2. In GitHub go to **Actions → Publish** and click **Run workflow**.
3. Select branch **main** and run. The workflow builds and creates a GitHub Release with the version from `pubspec.yaml` (e.g. tag `v0.1.0`).

### Option B: Bump and Publish (bump version, then release)

Use when you want the workflow to bump the version for you.

1. In GitHub go to **Actions → Bump and Publish** and click **Run workflow**.
2. Select branch **main** and choose **Bump type**: **major**, **minor**, or **hotfix**.
   - **major**: e.g. `0.1.0` → `1.0.0`
   - **minor**: e.g. `0.1.0` → `0.2.0`
   - **hotfix**: e.g. `0.1.0` → `0.1.1`
3. Run the workflow. It will update `pubspec.yaml`, commit and push to `main`, build, then create the GitHub Release with the new version.

Releases are marked as prerelease when:

- Version starts with `v0.*`, or
- Version contains a prerelease suffix (`-rc.1`, `-beta.1`, etc.)

------------------------------------------------------------------------

## Platform Notes

- macOS builds are unsigned (Gatekeeper warning expected).
- Android builds are debug APKs (no signing configured).
- iOS is supported for local development and personal device install only; no iOS artifact is produced by CI.
