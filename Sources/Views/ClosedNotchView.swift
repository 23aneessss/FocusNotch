import SwiftUI

/// The collapsed layout: remaining time hugging the left of the notch, session
/// progress hugging the right. The middle `Color.clear` reserves the exact
/// width of the physical notch, and the two side areas are equal width so the
/// gap stays centered on the real notch.
struct ClosedNotchView: View {
    let engine: PomodoroEngine
    let geometry: NotchGeometry

    var body: some View {
        HStack(spacing: 0) {
            leftContent
                .frame(width: geometry.sideWidth, alignment: .trailing)

            Color.clear
                .frame(width: geometry.notchWidth)

            rightContent
                .frame(width: geometry.sideWidth, alignment: .leading)
        }
        .frame(width: geometry.closedWidth, height: geometry.notchHeight)
        .padding(.bottom, 1)
    }

    // Left of the notch: phase glyph + remaining time. Dimmed when not running.
    private var leftContent: some View {
        HStack(spacing: 5) {
            Image(systemName: engine.phase.symbolName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(engine.phase.accent)
            Text(TimeFormatting.compactClock(engine.remaining))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .opacity(engine.runState == .running ? 1.0 : 0.5)
        }
        .padding(.trailing, 12)
        .fixedSize()
    }

    // Right of the notch: session dots + the current session number.
    private var rightContent: some View {
        HStack(spacing: 6) {
            SessionDots(
                completed: engine.cyclePosition,
                total: engine.sessionsBeforeLongBreak,
                current: engine.currentSessionNumber,
                accent: engine.phase.accent,
                dotSize: 5,
                spacing: 4
            )
            Text("\(engine.currentSessionNumber)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.leading, 12)
        .fixedSize()
    }
}
