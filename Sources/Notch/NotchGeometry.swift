import AppKit

/// All the sizes the notch UI needs, computed once per screen layout.
///
/// Centering rule: the physical notch is centered on the display, so the empty
/// "gap" in our collapsed pill must also be centered. We therefore use *equal*
/// side widths on both sides of the gap — that keeps the gap aligned with the
/// real notch regardless of how wide the left/right content is.
///
/// Occlusion rule: in the expanded state the physical camera notch still bites
/// into the top-center of our panel. All expanded content is laid out *below*
/// the notch strip (`notchHeight`) so the hardware can never hide it.
struct NotchGeometry: Equatable {
    // View-space
    var notchWidth: CGFloat
    var notchHeight: CGFloat
    var sideWidth: CGFloat          // equal width of each label area beside the notch
    var openWidth: CGFloat
    var openHeight: CGFloat
    var openContentHeight: CGFloat  // openHeight - notchHeight
    var closedBottomRadius: CGFloat
    var openCornerRadius: CGFloat

    // Window / screen-space (global coordinates, bottom-left origin)
    var windowFrame: CGRect
    var closedHoverRect: CGRect   // hover region while a session is active (full pill)
    var notchHoverRect: CGRect    // hover region while idle (notch only)
    var openHoverRect: CGRect

    /// Total collapsed width: notch gap plus both equal side areas.
    var closedWidth: CGFloat { notchWidth + sideWidth * 2 }

    static func compute(for screen: NSScreen) -> NotchGeometry {
        let notchHeight = (screen.notchHeight ?? 32).rounded()
        let notchWidth = (screen.notchWidth ?? 200).rounded()

        let sideWidth: CGFloat = 80
        let closedWidth = notchWidth + sideWidth * 2

        // Snug enough that content fills the panel rather than swimming in it.
        let openContentHeight: CGFloat = 164
        let openHeight = notchHeight + openContentHeight
        let openWidth = max(closedWidth + 24, 366)

        let closedBottomRadius: CGFloat = 11
        let openCornerRadius: CGFloat = 24

        // Window is exactly the expanded panel; the collapsed pill draws inside
        // its top strip. Centered on the display, flush with the top edge, and
        // pixel-aligned to stay crisp.
        let frame = screen.frame
        let centerX = (frame.midX).rounded()
        let topY = frame.maxY

        let windowFrame = CGRect(
            x: (centerX - openWidth / 2).rounded(),
            y: (topY - openHeight).rounded(),
            width: openWidth,
            height: openHeight
        )

        // Collapsed hover region: the pill, with a little vertical slop so the
        // cursor reliably enters from the menu bar.
        let closedHoverWidth = closedWidth + 6
        let closedHoverHeight = notchHeight + 3
        let closedHoverRect = CGRect(
            x: centerX - closedHoverWidth / 2,
            y: topY - closedHoverHeight,
            width: closedHoverWidth,
            height: closedHoverHeight
        )

        // Idle hover region: just the notch, so we don't pop open from menu-bar
        // activity beside it.
        let notchHoverWidth = notchWidth + 6
        let notchHoverRect = CGRect(
            x: centerX - notchHoverWidth / 2,
            y: topY - closedHoverHeight,
            width: notchHoverWidth,
            height: closedHoverHeight
        )

        // Expanded hover region: the whole panel, with a small margin so moving
        // the cursor between controls never slips outside and snaps it shut.
        let openHoverRect = CGRect(
            x: centerX - openWidth / 2 - 6,
            y: topY - openHeight - 6,
            width: openWidth + 12,
            height: openHeight + 6
        )

        return NotchGeometry(
            notchWidth: notchWidth,
            notchHeight: notchHeight,
            sideWidth: sideWidth,
            openWidth: openWidth,
            openHeight: openHeight,
            openContentHeight: openContentHeight,
            closedBottomRadius: closedBottomRadius,
            openCornerRadius: openCornerRadius,
            windowFrame: windowFrame,
            closedHoverRect: closedHoverRect,
            notchHoverRect: notchHoverRect,
            openHoverRect: openHoverRect
        )
    }
}
