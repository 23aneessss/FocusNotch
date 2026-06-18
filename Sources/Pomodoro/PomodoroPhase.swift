import SwiftUI

/// The phases of a Pomodoro cycle.
enum PomodoroPhase: String, CaseIterable, Identifiable, Codable {
    case work
    case shortBreak
    case longBreak

    var id: String { rawValue }

    var title: String {
        switch self {
        case .work: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }

    var shortTitle: String {
        switch self {
        case .work: return "Focus"
        case .shortBreak: return "Break"
        case .longBreak: return "Long Break"
        }
    }

    var isBreak: Bool { self != .work }

    var symbolName: String {
        switch self {
        case .work: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "figure.walk"
        }
    }

    /// Accent color used across the notch and rings for this phase.
    var accent: Color {
        switch self {
        case .work: return Color(red: 1.0, green: 0.32, blue: 0.27)        // tomato red
        case .shortBreak: return Color(red: 0.25, green: 0.80, blue: 0.55) // mint green
        case .longBreak: return Color(red: 0.30, green: 0.62, blue: 0.95)  // calm blue
        }
    }

    /// A two-stop gradient for progress rings / bars.
    var gradient: [Color] {
        switch self {
        case .work: return [Color(red: 1.0, green: 0.42, blue: 0.27), Color(red: 1.0, green: 0.25, blue: 0.35)]
        case .shortBreak: return [Color(red: 0.30, green: 0.85, blue: 0.60), Color(red: 0.18, green: 0.72, blue: 0.50)]
        case .longBreak: return [Color(red: 0.36, green: 0.70, blue: 1.0), Color(red: 0.28, green: 0.52, blue: 0.92)]
        }
    }
}
