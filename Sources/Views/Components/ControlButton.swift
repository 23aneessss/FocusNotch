import SwiftUI

/// A circular icon button used in the expanded notch controls. Supports a
/// prominent (filled) style for the primary start/pause action.
struct ControlButton: View {
    let systemName: String
    var prominent: Bool = false
    var tint: Color = .white
    var diameter: CGFloat = 34
    var help: String = ""
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(prominent ? tint : Color.white.opacity(isHovering ? 0.18 : 0.10))
                Image(systemName: systemName)
                    .font(.system(size: prominent ? 15 : 13, weight: .semibold))
                    .foregroundStyle(prominent ? Color.black : Color.white)
            }
            .frame(width: diameter, height: diameter)
            .scaleEffect(isHovering ? 1.06 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.12), value: isHovering)
        .help(help)
    }
}
