import Foundation
import Observation

/// Bridges Pomodoro phases to macOS Focus / Do Not Disturb.
///
/// Apple exposes no public API to toggle Focus directly, so FocusNotch runs a
/// user-provided Shortcut through the `shortcuts` command-line tool. The user
/// creates two simple shortcuts ("Set Focus" on / off, or "Turn On Do Not
/// Disturb" / "Turn Off Do Not Disturb") and names them in Settings.
@MainActor
@Observable
final class FocusController {
    private let settings: PomodoroSettings

    /// Whether we believe a Focus is currently engaged by us.
    private(set) var isActive = false

    init(settings: PomodoroSettings) {
        self.settings = settings
    }

    /// Turn the configured Focus on (no-op if the feature is disabled).
    func activate() {
        guard settings.focusEnabled, !isActive else { return }
        let name = settings.focusOnShortcut
        guard !name.isEmpty else { return }
        isActive = true
        Self.run(shortcut: name)
    }

    /// Turn the configured Focus off.
    func deactivate() {
        guard isActive else { return }
        isActive = false
        guard settings.focusEnabled else { return }
        let name = settings.focusOffShortcut
        guard !name.isEmpty else { return }
        Self.run(shortcut: name)
    }

    /// Manual toggle used by the expanded notch UI's Focus button.
    func toggleManually() {
        if isActive {
            isActive = false
            if settings.focusEnabled, !settings.focusOffShortcut.isEmpty {
                Self.run(shortcut: settings.focusOffShortcut)
            }
        } else {
            guard settings.focusEnabled, !settings.focusOnShortcut.isEmpty else { return }
            isActive = true
            Self.run(shortcut: settings.focusOnShortcut)
        }
    }

    // MARK: Shortcuts CLI

    /// Run a named shortcut off the main thread. Failures are non-fatal: Focus
    /// is a convenience, not a correctness requirement.
    nonisolated static func run(shortcut name: String) {
        DispatchQueue.global(qos: .utility).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
            process.arguments = ["run", name]
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                NSLog("FocusNotch: failed to run shortcut \"\(name)\": \(error.localizedDescription)")
            }
        }
    }

    /// The names of the user's shortcuts, for the Settings picker. Returns an
    /// empty array if the CLI is unavailable or returns nothing.
    nonisolated static func availableShortcuts() -> [String] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = ["list"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            let output = String(decoding: data, as: UTF8.self)
            return output
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        } catch {
            return []
        }
    }
}
