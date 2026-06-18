import AppKit

/// Plays a short system sound on phase transitions. Uses built-in named system
/// sounds so the app ships without bundling audio assets.
enum SoundPlayer {
    @MainActor
    static func playTransition(into phase: PomodoroPhase) {
        let name: NSSound.Name
        switch phase {
        case .work:
            name = "Submarine"   // a focused, grounding tone
        case .shortBreak:
            name = "Glass"       // light and pleasant
        case .longBreak:
            name = "Hero"        // celebratory
        }
        NSSound(named: name)?.play()
    }
}
