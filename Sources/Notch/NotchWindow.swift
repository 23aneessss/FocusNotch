import AppKit

/// A borderless, non-activating panel pinned over the notch. It floats above
/// normal windows and the menu bar, joins every Space, and stays visible over
/// fullscreen apps. It never becomes the app's main window.
final class NotchWindow: NSPanel {
    init(contentRect: CGRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .statusBar          // above the menu bar (which is at .mainMenu)
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        isMovableByWindowBackground = false
        isMovable = false
        hidesOnDeactivate = false
        ignoresMouseEvents = true   // click-through while collapsed
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle,
        ]
        animationBehavior = .none
    }

    // Allow the panel to receive clicks (e.g. control buttons) without making
    // FocusNotch the active app.
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
