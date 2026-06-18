import SwiftUI

/// A circular progress ring with the remaining time and phase label inside.
struct TimerRing: View {
    let progress: Double          // 0...1 elapsed
    let remaining: TimeInterval
    let phase: PomodoroPhase
    var diameter: CGFloat = 116
    var lineWidth: CGFloat = 9

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0.0001, progress))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: phase.gradient),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)

            VStack(spacing: 2) {
                Text(TimeFormatting.clock(remaining))
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text(phase.title.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(phase.accent)
            }
        }
        .frame(width: diameter, height: diameter)
    }
}
