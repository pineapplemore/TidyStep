# TidyStep

iOS app that encourages room cleaning by tracking movement (steps) and estimating calories. First run shows an onboarding tip; weekly reminder and history are supported.

## Requirements

- Xcode 14+ (or Xcode 15 with iOS 15 SDK)
- iOS 15.0+
- Device with motion sensors (step counting)

## Open in Xcode

1. Open `TidyStep.xcodeproj` in Xcode.
2. Select the **TidyStep** scheme and a simulator or your device.
3. If building for a physical device: choose your **Team** under Signing & Capabilities.
4. Run (⌘R).

## Features (v1)

- **Start / End session**: Tap Start, carry the phone (e.g. in pocket), then End to see duration, steps, and estimated calories.
- **30‑minute check-in**: While a session is active, every 30 minutes an alert asks “Are you still cleaning?” with options: Yes, No (end session), Don’t remind again.
- **2‑hour cap**: After 2 hours, an alert suggests ending the session.
- **Weight**: Optional weight (kg) for more accurate calorie estimate; can be set before starting or in Settings.
- **Weekly reminder**: In Settings, set day and time and toggle on/off; uses local notifications.
- **History**: Last 20 sessions with date, steps, calories, duration.
- **Dark theme**, **English + Simplified Chinese** (follows device language when available).
- **Onboarding**: Shown on first launch, with “Don’t show again”.

## Project structure

- `TidyStep/` – app target
  - `TidyStepApp.swift` – entry point
  - `Models/` – e.g. `CleaningSession`
  - `Services/` – `SessionManager`, `StorageManager`, `NotificationManager`
  - `Views/` – Start, Session, End, History, Settings, Onboarding
  - `Helpers/` – e.g. `Color+Hex`
  - `Resources/` – `Info.plist`, `Assets.xcassets`, `Base.lproj`, `zh-Hans.lproj` (localizations)

## Compatibility

- Built and tested for **iOS 15** (NavigationView, no iOS 16‑only APIs) so it runs on current and older Xcode versions.
- If you use a newer Xcode and want to support only iOS 16+, you can switch to `NavigationStack`, `toolbarBackground`, and `scrollContentBackground` for a more modern look.
