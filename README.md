<div align="center">

# FocusNotch

**Make your MacBook's notch useful — a Pomodoro timer that lives in the notch.**

When you're not looking, FocusNotch shows the time left in your session on the
left of the notch and your session progress on the right. Hover over it and the
notch expands into a full control panel: progress ring, session tracker,
transport controls, and a one-tap Focus / Do Not Disturb toggle.

</div>

---

## Features

- 🎯 **Notch-native UI** — a panel pinned over the physical notch that floats above every Space and over fullscreen apps. It's click-through when collapsed, so your menu bar keeps working.
- ⏳ **At-a-glance status** — remaining time on the left of the notch, session dots on the right.
- 🖱️ **Hover to expand** — smooth spring animation into a progress ring, "Session X of Y", next-phase preview, and Start / Pause / Skip / Reset controls.
- 🍅 **Real Pomodoro engine** — configurable focus / short break / long break durations, sessions-before-long-break cycles, and optional auto-start. Timing is anchored to an absolute end date, so it stays accurate across sleep and timer coalescing.
- 🌙 **Focus / Do Not Disturb** — automatically enable a macOS Focus while you work, via the Shortcuts app (see [Focus setup](#focus--do-not-disturb-setup)).
- 🔔 **Notifications & sounds** on every phase change.
- 📊 **Menu bar item** mirroring the timer, with the same controls — handy on external displays.
- 🚀 **Launch at login** (via `SMAppService`).
- 🖥️ **Works without a notch** — optionally shows a simulated "island" at the top-center of any Mac.

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 16+ (developed with Xcode 26)
- [XcodeGen](https://github.com/yonyz/XcodeGen) (`brew install xcodegen`) to generate the project

## Build & run

```bash
# 1. Generate the Xcode project from project.yml
xcodegen generate

# 2. Open it
open FocusNotch.xcodeproj

# 3. Select the "FocusNotch" scheme and press ⌘R
```

Or build entirely from the command line:

```bash
xcodegen generate
xcodebuild -project FocusNotch.xcodeproj -scheme FocusNotch -configuration Release build
```

> FocusNotch is an **agent app** (`LSUIElement`) — it has no Dock icon. After
> launching, look for the timer in your menu bar and the panel over your notch.
> Quit it from the menu bar item.

### Regenerating the app icon

The icon is generated from code so there are no binary assets to hand-edit:

```bash
bash Tools/make_icons.sh
```

## Focus / Do Not Disturb setup

Apple provides no public API to toggle Focus directly, so FocusNotch uses the
**Shortcuts** app:

1. Open **Shortcuts** → create a shortcut that runs **Set Focus** → *Do Not Disturb* → **On** (a "Turn On" action). Name it, e.g. `Focus On`.
2. Create a second shortcut that sets the same Focus **Off**. Name it, e.g. `Focus Off`.
3. In **FocusNotch → Settings → Focus**, enable the feature and enter those two names. Use the **Test** buttons to confirm.

FocusNotch then runs `shortcuts run "<name>"` when a focus session starts/ends.

## Architecture

```
Sources/
├── App/            App lifecycle, shared environment
├── Pomodoro/       PomodoroEngine (state machine), PomodoroSettings, PomodoroPhase
├── Focus/          FocusController (Shortcuts CLI bridge)
├── System/         Notifications, sounds, launch-at-login, NSScreen+notch, formatting
├── Notch/          NotchWindow (NSPanel), NotchController (hover state machine),
│                   NotchGeometry, NotchModel, status bar + settings window controllers
└── Views/          SwiftUI: NotchShape, NotchRootView, Closed/Open notch views,
                    reusable components, SettingsView
```

**How the notch panel works.** A borderless, non-activating `NSPanel`
(`Sources/Notch/NotchWindow.swift`) is pinned over the notch at the `.statusBar`
window level with an all-Spaces collection behavior. `NotchController` tracks the
cursor with paired global + local `NSEvent` monitors (needed because the panel
toggles `ignoresMouseEvents` between collapsed/expanded), and flips an observable
`isOpen` flag. The SwiftUI `NotchRootView` animates the `NotchShape` and content
between the two states.

## Distribution

This project is configured for **direct distribution** (notarized DMG / your own
site / Gumroad), not the Mac App Store, because the Focus integration shells out
to the `shortcuts` CLI — which the App Store sandbox forbids. To ship:

1. Set your `DEVELOPMENT_TEAM` and a real `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml`.
2. Archive, sign with a Developer ID certificate (Hardened Runtime is already enabled), and notarize.

To target the **Mac App Store** instead, enable App Sandbox in
`Sources/Resources/FocusNotch.entitlements` and replace the `Process`-based
Focus integration in `FocusController` with an App Intent.

## License

Released under the [MIT License](LICENSE) — good for open-sourcing. If you intend
to **sell a closed-source build**, replace `LICENSE` with your own commercial /
EULA terms before distributing. Fill in `<YOUR NAME>` in the license header
either way.
