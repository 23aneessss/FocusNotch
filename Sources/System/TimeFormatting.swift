import Foundation

enum TimeFormatting {
    /// Formats a duration as `m:ss` (or `mm:ss`), e.g. `25:00`, `4:09`.
    static func clock(_ interval: TimeInterval) -> String {
        let total = Int(interval.rounded())
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Compact form for the menu bar / collapsed notch, always `mm:ss`.
    static func compactClock(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
