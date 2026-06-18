import AppKit

extension NSScreen {
    /// Height of the physical notch in points, or `nil` on displays without one.
    var notchHeight: CGFloat? {
        guard safeAreaInsets.top > 0 else { return nil }
        return safeAreaInsets.top
    }

    /// Width of the physical notch in points, derived from the auxiliary menu
    /// bar areas on either side. `nil` on displays without a notch.
    var notchWidth: CGFloat? {
        guard let left = auxiliaryTopLeftArea, let right = auxiliaryTopRightArea else {
            return nil
        }
        let width = frame.width - left.width - right.width
        return width > 0 ? width : nil
    }

    var hasNotch: Bool { notchHeight != nil }

    /// The screen that physically has a notch, if any.
    static var notched: NSScreen? {
        screens.first(where: { $0.hasNotch })
    }
}
