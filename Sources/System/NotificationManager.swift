import Foundation
import UserNotifications

/// Thin wrapper over `UNUserNotificationCenter` for phase-change alerts.
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private var authorized = false

    private init() {}

    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            Task { @MainActor in self?.authorized = granted }
        }
    }

    func postPhaseChange(finished: PomodoroPhase, next: PomodoroPhase) {
        let content = UNMutableNotificationContent()
        switch next {
        case .work:
            content.title = "Back to focus"
            content.body = "Break's over — starting your next focus session."
        case .shortBreak:
            content.title = "Time for a short break"
            content.body = "Nice work. Step away for a few minutes."
        case .longBreak:
            content.title = "Time for a long break"
            content.body = "You've earned it. Take a proper rest."
        }
        content.sound = nil // sound handled separately by SoundPlayer

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
