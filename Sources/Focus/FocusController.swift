import AppKit
import ApplicationServices
import Observation

/// Toggles macOS **Do Not Disturb** via the Control Center.
///
/// Apple exposes no public API to set Focus/DND, so FocusNotch automates the
/// Control Center toggle through the Accessibility (AX) system. This requires
/// the user to grant Accessibility permission once; the first attempt prompts
/// for it and opens the relevant Settings pane.
///
/// `isActive` tracks the state *we* set. The manual moon button always toggles;
/// automatic activation during focus sessions is gated by `focusEnabled`.
@MainActor
@Observable
final class FocusController {
    private let settings: PomodoroSettings
    private(set) var isActive = false

    init(settings: PomodoroSettings) {
        self.settings = settings
    }

    /// Whether macOS has granted us Accessibility control.
    var accessibilityGranted: Bool { AXIsProcessTrusted() }

    // MARK: Session-driven (auto)

    func activate() {
        guard settings.focusEnabled, !isActive else { return }
        setDoNotDisturb(true)
    }

    func deactivate() {
        guard isActive else { return }
        setDoNotDisturb(false)
    }

    // MARK: Manual (moon button) — always works

    func toggleManually() {
        setDoNotDisturb(!isActive)
    }

    // MARK: Implementation

    private func setDoNotDisturb(_ on: Bool) {
        guard on != isActive else { return }
        guard ensureAccessibilityPermission() else { return }
        if Self.runToggleScript() {
            isActive = on
        }
    }

    /// Returns true if Accessibility is granted. Otherwise prompts the user and
    /// opens the Accessibility settings pane, and returns false.
    @discardableResult
    func ensureAccessibilityPermission() -> Bool {
        if AXIsProcessTrusted() { return true }
        // Prompt (shows the system dialog) using the documented option key.
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        openAccessibilitySettings()
        return false
    }

    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Clicks Control Center → Focus / Do Not Disturb. Best-effort across
    /// macOS versions; failures are logged and reported via the return value.
    private static func runToggleScript() -> Bool {
        let source = """
        tell application "System Events"
            tell process "ControlCenter"
                set frontmost to true
                try
                    click (first menu bar item of menu bar 1 whose description is "Control Center")
                on error
                    click (last menu bar item of menu bar 1)
                end try
                delay 0.55
                set didClick to false
                try
                    click (first button of window 1 whose description is "Focus")
                    set didClick to true
                end try
                if not didClick then
                    try
                        click (first checkbox of window 1 whose description is "Focus")
                        set didClick to true
                    end try
                end if
                delay 0.45
                try
                    click (first button of window 1 whose description is "Do Not Disturb")
                end try
                try
                    click (first UI element of window 1 whose name is "Do Not Disturb")
                end try
                delay 0.15
                key code 53
            end tell
        end tell
        """
        guard let script = NSAppleScript(source: source) else { return false }
        var error: NSDictionary?
        script.executeAndReturnError(&error)
        if let error {
            NSLog("FocusNotch: Do Not Disturb toggle failed: \(error)")
            return false
        }
        return true
    }
}
