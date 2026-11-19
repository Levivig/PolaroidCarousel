import CoreGraphics

/// A card's center and two edge midpoints, all in the same coordinate space.
struct CardHandoffGeometry {
    let center: CGPoint
    let right: CGPoint
    let bottom: CGPoint

    func converted(by convert: (CGPoint) -> CGPoint) -> Self {
        Self(center: convert(center), right: convert(right), bottom: convert(bottom))
    }

    /// Maps coordinates relative to the flying card's center onto the original card's axes.
    func transform(from size: CGSize) -> CGAffineTransform {
        CGAffineTransform(a: 2 * (right.x - center.x) / size.width,
                          b: 2 * (right.y - center.y) / size.width,
                          c: 2 * (bottom.x - center.x) / size.height,
                          d: 2 * (bottom.y - center.y) / size.height,
                          tx: 0, ty: 0)
    }
}

#if canImport(UIKit)
import UIKit

extension CardHandoffGeometry {
    @MainActor init?(card: UIView, in window: UIWindow) {
        let presentation = card.layer.presentation()
        let windowPresentation = window.layer.presentation()
        let bounds = presentation?.bounds ?? card.bounds
        guard bounds.width > 0, bounds.height > 0 else { return nil }
        func project(_ point: CGPoint) -> CGPoint {
            if let presentation, let windowPresentation, presentation.superlayer != nil {
                return presentation.convert(point, to: windowPresentation)
            }
            return card.convert(point, to: window)
        }
        self.init(center: project(CGPoint(x: bounds.midX, y: bounds.midY)),
                  right: project(CGPoint(x: bounds.maxX, y: bounds.midY)),
                  bottom: project(CGPoint(x: bounds.midX, y: bounds.maxY)))
    }
}
#endif
