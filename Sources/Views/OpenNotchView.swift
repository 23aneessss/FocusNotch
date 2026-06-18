import SwiftUI

/// The expanded panel shown on hover. A top spacer the height of the physical
/// notch keeps every control clear of the camera hardware. Below it, a balanced
/// row — progress ring (left), phase details (middle), session count (right) —
/// then a row of transport controls and a Focus toggle.
struct OpenNotchView: View {
    @Bindable var engine: PomodoroEngine
    let focus: FocusController
    let geometry: NotchGeometry

    var body: some View {
        VStack(spacing: 0) {
            // Reserve the notch strip so nothing renders behind the camera.
            Color.clear.frame(height: geometry.notchHeight)

            VStack(spacing: 14) {
                HStack(alignment: .center, spacing: 14) {
                    TimerRing(
                        progress: engine.progress,
                        remaining: engine.remaining,
                        phase: engine.phase,
                        diameter: 86
                    )
                    details
                    Spacer(minLength: 8)
                    sessionCount
                }

                controls
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
        .frame(width: geometry.openWidth, height: geometry.openHeight, alignment: .top)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                Image(systemName: engine.phase.symbolName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(engine.phase.accent)
                Text(engine.phase.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            SessionDots(
                completed: engine.cyclePosition,
                total: engine.sessionsBeforeLongBreak,
                current: engine.currentSessionNumber,
                accent: engine.phase.accent,
                dotSize: 7,
                spacing: 6
            )

            Text("Next · \(engine.upcomingPhase.title)")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(1)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var sessionCount: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("\(engine.currentSessionNumber)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text("of \(engine.sessionsBeforeLongBreak)")
                .font(.system(size: 11, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var controls: some View {
        HStack(spacing: 10) {
            ControlButton(
                systemName: engine.isRunning ? "pause.fill" : "play.fill",
                prominent: true,
                tint: engine.phase.accent,
                diameter: 38,
                help: engine.isRunning ? "Pause" : "Start"
            ) {
                engine.toggle()
            }

            ControlButton(systemName: "forward.fill", help: "Skip to next phase") {
                engine.skip()
            }

            ControlButton(systemName: "arrow.counterclockwise", help: "Reset this phase") {
                engine.resetCurrentPhase()
            }

            Spacer(minLength: 0)

            ControlButton(
                systemName: focus.isActive ? "moon.fill" : "moon",
                tint: focus.isActive ? engine.phase.accent : .white,
                help: "Toggle Focus / Do Not Disturb"
            ) {
                focus.toggleManually()
            }
        }
    }
}
