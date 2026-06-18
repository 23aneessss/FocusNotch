import Foundation

/// Owns the long-lived model objects and wires them together. A single
/// instance is created by `AppDelegate` and shared across the notch panel,
/// the status bar item, and the settings window.
@MainActor
final class AppEnvironment {
    let settings: PomodoroSettings
    let focus: FocusController
    let engine: PomodoroEngine

    init() {
        let settings = PomodoroSettings()
        let focus = FocusController(settings: settings)
        self.settings = settings
        self.focus = focus
        self.engine = PomodoroEngine(settings: settings, focus: focus)
    }
}
