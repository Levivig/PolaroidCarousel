import CoreGraphics

struct CarouselGeometry {
    let size: CGSize

    var step: CGFloat { size.height * 5 / 8 }
    var inset: CGFloat { (size.width - step) / 2 }

    func offset(forPage page: CGFloat) -> CGFloat { page * step - inset }
    func page(atOffset offset: CGFloat) -> CGFloat { (offset + inset) / step }

    func position(of item: Int, atOffset offset: CGFloat) -> CGFloat {
        CGFloat(item) - page(atOffset: offset)
    }

    func queryRange(midX: CGFloat, count: Int) -> ClosedRange<Int>? {
        let center = Int((midX / step).rounded())
        let lower = max(0, center - 4)
        let upper = min(count - 1, center + 4)
        return lower <= upper ? lower...upper : nil
    }

    struct Pose {
        let angle: CGFloat
        let scale: CGFloat
        let dx: CGFloat
        let dy: CGFloat

        init(_ angle: CGFloat, _ scale: CGFloat, _ dx: CGFloat, _ dy: CGFloat) {
            self.angle = angle
            self.scale = scale
            self.dx = dx
            self.dy = dy
        }

        func interpolated(to other: Self, at fraction: CGFloat) -> Self {
            Self(
                angle + (other.angle - angle) * fraction,
                scale + (other.scale - scale) * fraction,
                dx + (other.dx - dx) * fraction,
                dy + (other.dy - dy) * fraction
            )
        }

        func transform(width: CGFloat, height: CGFloat) -> CGAffineTransform {
            CGAffineTransform(rotationAngle: angle * .pi / 180)
                .concatenating(CGAffineTransform(scaleX: scale, y: scale))
                .concatenating(CGAffineTransform(translationX: dx * width, y: dy * height))
        }
    }

    static func pose(at position: CGFloat, collapsed: Bool) -> Pose? {
        guard (-3...3).contains(position) else { return nil }
        let lower = position.rounded(.down)
        let keyframes = collapsed ? stack : fan
        return keyframes[Int(lower) + 3].interpolated(
            to: keyframes[Int(position.rounded(.up)) + 3], at: position - lower
        )
    }

    static func presentation(at position: CGFloat, collapsed: Bool, cardCount: Int)
        -> (pose: Pose, zIndex: Int)? {
        guard !collapsed, (2...4).contains(cardCount) else {
            guard let pose = pose(at: position, collapsed: collapsed) else { return nil }
            return (pose, -Int(abs(position).rounded()))
        }

        // Use one full cycle of the virtual track. Bias even decks towards the right
        // so the extra card has a stable side and doesn't switch sides at rest.
        let even = cardCount.isMultiple(of: 2)
        let upper = CGFloat(cardCount) / 2 + (even ? 0.25 : 0)
        let lower = upper - CGFloat(cardCount)
        guard position >= lower, position < upper,
              let fan = pose(at: position, collapsed: false) else { return nil }

        // Both ends meet at the same pose behind the deck, so changing which
        // virtual cell represents the card doesn't move it across the screen.
        let edgeDistance = min(position - lower, upper - position)
        let progress = 1 - min(edgeDistance / (even ? 0.25 : 0.5), 1)
        let blend = progress * progress * (3 - 2 * progress)
        let tucked = Pose(0, 0.42, -position, 0)
        let depth = abs(position) + (3 - abs(position)) * blend
        return (fan.interpolated(to: tucked, at: blend), -Int((depth * 1_000).rounded()))
    }

    private static let fan: [Pose] = [
        .init(1.6, 0.58, 2.630, -0.056),
        .init(-8, 0.73, 1.628, -0.054),
        .init(-18.2, 0.67, 0.491, 0.098),
        .init(-7, 0.89, -0.009, -0.024),
        .init(7.9, 0.73, -0.575, -0.053),
        .init(21.3, 0.73, -1.523, 0.079),
        .init(12, 0.58, -2.539, 0.098),
    ]

    private static let stack: [Pose] = [
        .init(0, 0.5, 3, 0),
        .init(8, 0.5, 2, 0),
        .init(0, 0.5, 1, 0),
        .init(-7, 0.801, -0.009, -0.012),
        .init(0, 0.5, -1, 0),
        .init(0, 0.5, -2, 0),
        .init(0, 0.5, -3, 0),
    ]
}
