import AppKit
import SwiftUI

/// Hosts the SwiftUI `SettingsView` in a standard titled window. Created lazily
/// from the status bar menu.
@MainActor
final class SettingsWindowController {
    private let environment: AppEnvironment
    private var window: NSWindow?

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func show() {
        if window == nil {
            let view = SettingsView(settings: environment.settings, focus: environment.focus)
            let hosting = NSHostingController(rootView: view)
            let window = NSWindow(contentViewController: hosting)
            window.title = "FocusNotch Settings"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.setContentSize(NSSize(width: 460, height: 560))
            window.center()
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
