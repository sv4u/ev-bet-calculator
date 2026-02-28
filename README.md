# Bet EV Calculator (Flutter)

Cross-platform GUI app to compute:

-   Implied probability (from odds)
-   Expected value (EV) using your estimated win probability
-   Push-aware EV (push returns stake, zero profit)
-   EV%, edge, and expected return (stake + EV)

## Supported Platforms

-   Android (debug APK for sideloading)
-   Windows (zip)
-   macOS (zip containing `.app`)
-   Linux (tar.gz bundle)

------------------------------------------------------------------------

## Inputs

-   Stake (currency amount)
-   Odds (one of):
    -   Decimal: `1.91`
    -   American: `-110`, `+150`
    -   Fractional: `5/4`
-   Win probability (%) --- your estimate
-   Push probability (%) --- your estimate
    -   Loss% is computed as `100 - Win% - Push%`

------------------------------------------------------------------------

## Outputs

Let:

-   `S` = stake
-   `D` = decimal odds
-   `pW` = win probability (0..1)
-   `pP` = push probability (0..1)
-   `pL = 1 - pW - pP`

Then:

-   Profit if win: `S * (D - 1)`
-   Implied probability: `1 / D`
-   EV (expected profit): `pW * (S*(D-1)) - pL * S`
-   EV%: `EV / S`
-   Expected return: `S + EV`
-   Edge: `pW - p_implied`

Currency values are displayed with fixed 2 decimals.

------------------------------------------------------------------------

## Persistence

The app persists the last entered values using `shared_preferences`.

Reset button restores defaults:

-   Stake: 10
-   Odds: -110
-   Win%: 55
-   Push%: 5

------------------------------------------------------------------------

## Local Development

### Prerequisites

-   Flutter SDK installed and available on PATH

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

## CI Builds

Artifacts are built automatically:

-   On every push to `main` (artifact names include commit SHA)
-   On every tag `v*` (artifact names include full version tag)

Download location:

-   GitHub → Actions → Select workflow run → Artifacts

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

    version: MAJOR.MINOR.PATCH+BUILD

Example:

    version: 0.1.0+1

Tag format:

-   `vMAJOR.MINOR.PATCH`
-   Prerelease identifiers supported:
    -   `v1.2.0-rc.1`
    -   `v1.2.0-beta.2`

Tag must match the base SemVer from `pubspec.yaml`.

------------------------------------------------------------------------

## Release Process

1.  Update version in `pubspec.yaml`
2.  Commit changes
3.  Create and push tag

``` bash
git commit -am "Release v0.1.0"
git tag v0.1.0
git push origin main --follow-tags
```

Tag pushes automatically create a GitHub Release with attached
artifacts.

Releases are marked as prerelease when:

-   Tag starts with `v0.*`, or
-   Tag contains a prerelease suffix (`-rc.1`, `-beta.1`, etc.)

------------------------------------------------------------------------

## Platform Notes

-   macOS builds are unsigned (Gatekeeper warning expected).
-   Android builds are debug APKs (no signing configured).
