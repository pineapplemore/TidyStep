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
- **Weekly or interval reminder**: In Settings, choose Weekly (pick day + time), Every 3 days, or Every 5 days; uses local notifications.
- **History**: Last 20 sessions with date, steps, calories, duration.
- **Statistics** (premium tier): This week / This month summary (sessions, duration, steps, calories) and a simple “Last 8 weeks” bar chart.
- **Widget** (optional): Home screen widget showing this week’s sessions and last tidy. Requires adding the Widget Extension in Xcode (see below).
- **Dark theme**, **English + Simplified Chinese** (in-app language toggle).
- **Onboarding**: Shown on first launch, with “Don’t show again”.

## Adding the home screen widget

The main app is already set up with App Group `group.com.tidystep.app` and writes widget data when sessions or reminders change. To show the widget on the home screen:

1. In Xcode: **File → New → Target → Widget Extension**.
2. Product name: **TidyStepWidget**, uncheck “Include Configuration App Intent”, finish.
3. In the **TidyStepWidget** target: **Signing & Capabilities → + Capability → App Groups** → add `group.com.tidystep.app`.
4. Replace the generated widget Swift file with the contents of `TidyStepWidget/TidyStepWidget.swift` in this repo (or add that file to the widget target and remove the generated one).
5. Build and run the app; add the TidyStep widget from the home screen widget gallery.

## Project structure

- `TidyStep/` – app target
  - `TidyStepApp.swift` – entry point
  - `Models/` – e.g. `CleaningSession`, `StatsSummary`
  - `Services/` – `SessionManager`, `StorageManager`, `NotificationManager`, `AppLanguage`, `WidgetDataManager`
  - `Views/` – Start, Session, End, History, **Statistics**, Settings, Onboarding
  - `Helpers/` – e.g. `Color+Hex`
  - `Resources/` – `Info.plist`, `Assets.xcassets`, `Base.lproj`, `zh-Hans.lproj` (localizations)

## Compatibility

- Built and tested for **iOS 15** (NavigationView, no iOS 16‑only APIs) so it runs on current and older Xcode versions.
- If you use a newer Xcode and want to support only iOS 16+, you can switch to `NavigationStack`, `toolbarBackground`, and `scrollContentBackground` for a more modern look.
