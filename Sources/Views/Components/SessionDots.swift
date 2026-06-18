import SwiftUI

/// A row of dots representing focus sessions within the current long-break
/// cycle. Filled dots are completed; the current session pulses subtly.
struct SessionDots: View {
    let completed: Int
    let total: Int
    let current: Int          // 1-based index of the active session
    var accent: Color = .white
    var dotSize: CGFloat = 6
    var spacing: CGFloat = 5
    var highlightCurrent: Bool = true

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                let isCompleted = index < completed
                let isCurrent = highlightCurrent && (index + 1) == current
                Circle()
                    .fill(isCompleted ? accent : accent.opacity(0.28))
                    .frame(width: dotSize, height: dotSize)
                    .overlay(
                        Circle()
                            .strokeBorder(accent, lineWidth: isCurrent ? 1.2 : 0)
                            .padding(-2)
                            .opacity(isCurrent ? 1 : 0)
                    )
            }
        }
    }
}
