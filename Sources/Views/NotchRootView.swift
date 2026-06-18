import SwiftUI

/// Root content of the notch panel.
///
/// The black `NotchShape` morphs its size and corner radius between the
/// collapsed pill and the expanded panel. The collapsed and expanded layouts
/// are *both* always present but occupy different vertical regions (collapsed in
/// the top notch strip, expanded below it), so cross-fading their opacity never
/// produces overlapping text.
struct NotchRootView: View {
    @Bindable var model: NotchModel
    let engine: PomodoroEngine
    let focus: FocusController

    private var geo: NotchGeometry { model.geometry }
    private var isOpen: Bool { model.isOpen }

    /// While idle the pill collapses to just the notch so it never covers the
    /// menu bar; during a session it widens to show time + sessions.
    private var isActive: Bool { engine.runState != .idle }
    private var collapsedWidth: CGFloat { isActive ? geo.closedWidth : geo.notchWidth }

    private var shapeWidth: CGFloat { isOpen ? geo.openWidth : collapsedWidth }
    private var shapeHeight: CGFloat { isOpen ? geo.openHeight : geo.notchHeight }
    private var radius: CGFloat { isOpen ? geo.openCornerRadius : geo.closedBottomRadius }

    var body: some View {
        ZStack(alignment: .top) {
            // Black silhouette that blends with the physical notch.
            NotchShape(bottomRadius: radius)
                .fill(Color.black)
                .overlay {
                    NotchShape(bottomRadius: radius)
                        .stroke(Color.white.opacity(isOpen ? 0.10 : 0), lineWidth: 1)
                }
                .frame(width: shapeWidth, height: shapeHeight)
                .shadow(color: .black.opacity(isOpen ? 0.5 : 0), radius: 22, y: 12)

            // Collapsed content — lives only in the top notch strip, and only
            // while a session is active (idle stays a clean notch).
            ClosedNotchView(engine: engine, geometry: geo)
                .frame(width: geo.closedWidth, height: geo.notchHeight)
                .opacity((isOpen || !isActive) ? 0 : 1)
                .allowsHitTesting(false)

            // Expanded content — lives only below the notch strip.
            OpenNotchView(engine: engine, focus: focus, geometry: geo)
                .frame(width: geo.openWidth, height: geo.openHeight)
                .opacity(isOpen ? 1 : 0)
                .allowsHitTesting(isOpen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: isOpen)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: isActive)
        .animation(.easeInOut(duration: 0.22), value: isOpen) // opacity cross-fade
    }
}
