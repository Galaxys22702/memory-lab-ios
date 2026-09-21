# Memory Lab

Memory Lab is a small SwiftUI diagnostic app for measuring the memory budget that iOS grants to the current app.

It requests Apple's documented memory entitlements:

- `com.apple.developer.kernel.increased-memory-limit`
- `com.apple.developer.kernel.extended-virtual-addressing`

The app displays:

- installed physical memory
- current process footprint
- peak process footprint
- current allocatable headroom reported by `os_proc_available_memory()`
- an estimated current process ceiling (`footprint + headroom`)
- thermal state
- memory-warning count

It also contains a controlled allocation test capped at 256 MB.

## Important limitation

This does not add physical RAM to the iPhone and does not change memory limits system-wide. The entitlements only affect this signed app, and Apple only grants increased headroom on supported device models.

## iPhone-only build path

The intended workflow is:

1. Keep this project in a GitHub repository.
2. GitHub Actions runs Xcode on a hosted macOS runner.
3. Apple cloud signing signs the distribution build.
4. The workflow uploads the build to App Store Connect.
5. Install it on the iPhone using TestFlight.

A physical Mac is not required for this workflow.

## Required Apple setup

You need an active Apple Developer Program membership for Certificates, Identifiers & Profiles, App Store Connect, and TestFlight.

Create/register:

1. A unique Bundle ID for Memory Lab.
2. An App Store Connect app record using that Bundle ID.
3. An App Store Connect API key for CI.
4. Cloud-managed certificate access for the account/key used by CI.

Do not commit the API private key to Git. Put it in GitHub Actions Secrets.

## GitHub Actions secrets

Create these repository secrets:

- `APPLE_TEAM_ID`
- `BUNDLE_ID`
- `APPSTORE_KEY_ID`
- `APPSTORE_ISSUER_ID`
- `APPSTORE_PRIVATE_KEY` — the complete contents of the downloaded `.p8` key

The `.p8` API private key can only be downloaded once. Keep a secure backup and revoke it immediately if it is exposed.

## Validation

`validate.yml` generates the Xcode project with XcodeGen and compiles it for the iOS Simulator without code signing.

`testflight.yml` archives the app, asks Apple for automatic/cloud signing, and uploads the build to App Store Connect for TestFlight.

## Security

Never paste an Apple `.p8`, `.p12`, private key, password, or recovery code into chat, source files, issues, or commits. Store CI credentials only in encrypted repository secrets.
