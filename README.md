# Brainrot Clone — Screen Time Control (iOS, SwiftUI)

A functional SwiftUI clone of the *concept* behind "Brainrot: Screen Time Control"
(app blocker + focus coach with a decaying brain avatar), built with original code,
design, and assets.

## Features
- **Home** — animated brain avatar that visibly "rots" through 5 stages as you burn
  through your daily screen-time goal (mint → yellow → orange → red → purple/skull).
- **App Blocker** — toggle blocking per app and set per-app daily limits.
- **Focus Timer** — Pomodoro-style timer (15/25/45/60 min presets) with session history.
- **Smart Schedules** — bedtime/morning/work blocking windows with add/delete/toggle.
- **Insights** — 7-day usage bar chart (bars turn red over goal), weekly average,
  top brainrot app, focus session count.
- **Persistence** — all state saved to `UserDefaults`.

## Run it
Open the folder in Xcode (Swift Package with an iOS application product, iOS 17+),
pick an iPhone simulator, and run. Or:

```bash
xcodebuild -scheme App -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Real blocking (entitlement required)
Currently, usage data is simulated (`AppStore.refreshUsage`, `logMinutes` in
`Sources/ViewModels/AppStore.swift`) so the app is fully usable in the simulator.
To make it actually control screen time on a device, integrate Apple's
**DeviceActivity + FamilyControls + ManagedSettings** frameworks. That requires
the Family Controls entitlement, which you must request from Apple:
https://developer.apple.com/contact/request/family-controls-entitlement/

Note: clones of App Store apps must not copy the original's branding, artwork,
screenshots, or marketing copy. This project re-implements the mechanics only.
