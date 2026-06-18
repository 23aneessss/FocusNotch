import SwiftUI

/// Entry point. FocusNotch is an agent app (`LSUIElement`), so there is no
/// main window and no Dock icon. All UI lives in the notch panel, the status
/// bar item, and the settings window created by `AppDelegate`.
@main
struct FocusNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // An empty Settings scene keeps SwiftUI's App lifecycle happy without
        // showing any window on launch. The real preferences window is managed
        // by `SettingsWindowController`.
        Settings {
            EmptyView()
        }
    }
}
