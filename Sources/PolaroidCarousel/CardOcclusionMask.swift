#if canImport(UIKit)
import UIKit

/// A stationary cutout of the deck's foreground, in window coordinates.
@MainActor
struct CardOcclusionMask {
    static let padding: CGFloat = 32

    private let frame: CGRect
    private let image: CGImage

    init?(foreground: [UIView], in window: UIWindow) {
        let positioned = foreground.compactMap { view in
            CardHandoffGeometry(card: view, in: window).map { (view, $0) }
        }
        let extent = positioned.reduce(CGRect.null) { extent, item in
            let view = item.0
            return extent.union(view.convert(view.bounds.insetBy(dx: -Self.padding, dy: -Self.padding), to: window))
        }.integral.intersection(window.bounds)
        guard !extent.isEmpty else { return nil }

        let format = UIGraphicsImageRendererFormat()
        format.scale = window.traitCollection.displayScale
        let mask = UIGraphicsImageRenderer(size: extent.size, format: format).image { renderer in
            let context = renderer.cgContext
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(origin: .zero, size: extent.size))
            for (view, geometry) in positioned {
                context.saveGState()
                // Subtract each card's rendered alpha, retaining its rounded edges and shadow.
                context.setBlendMode(.destinationOut)
                context.beginTransparencyLayer(auxiliaryInfo: nil)
                context.translateBy(x: geometry.center.x - extent.minX, y: geometry.center.y - extent.minY)
                context.concatenate(geometry.transform(from: view.bounds.size))
                context.translateBy(x: -view.bounds.midX, y: -view.bounds.midY)
                view.layer.render(in: context)
                context.endTransparencyLayer()
                context.restoreGState()
            }
        }
        guard let image = mask.cgImage else { return nil }
        self.frame = extent
        self.image = image
    }

    func apply(to overlay: UIView, in window: UIWindow) {
        let cutout = overlay.convert(frame, from: window)
        let mask = CALayer()
        mask.frame = overlay.bounds

        let outside = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(mask.bounds)
        path.addRect(cutout)
        outside.path = path
        outside.fillRule = .evenOdd
        outside.fillColor = UIColor.white.cgColor
        mask.addSublayer(outside)

        let silhouette = CALayer()
        silhouette.frame = cutout
        silhouette.contents = image
        mask.addSublayer(silhouette)
        overlay.layer.mask = mask
    }
}
#endif
