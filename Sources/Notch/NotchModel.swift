import Foundation
import Observation

/// Observable view-state for the notch panel: whether it's expanded and the
/// current geometry. The SwiftUI root view reads these; `NotchController`
/// mutates them.
@MainActor
@Observable
final class NotchModel {
    var isOpen = false
    var geometry: NotchGeometry

    init(geometry: NotchGeometry) {
        self.geometry = geometry
    }
}
