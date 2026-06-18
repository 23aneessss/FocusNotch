import Foundation
import ServiceManagement

/// Wraps `SMAppService` for the modern (macOS 13+) launch-at-login toggle.
enum LaunchAtLogin {
    static var isEnabled: Bool {
        get {
            SMAppService.mainApp.status == .enabled
        }
        set {
            do {
                if newValue {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                NSLog("FocusNotch: launch-at-login change failed: \(error.localizedDescription)")
            }
        }
    }
}
