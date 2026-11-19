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
