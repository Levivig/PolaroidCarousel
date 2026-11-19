import CoreGraphics
import Testing
@testable import PolaroidCarousel

struct CardHandoffGeometryTests {
    @Test func preservesTheOriginalAxesInTheOverlayCoordinateSpace() {
        let origin = CardHandoffGeometry(center: CGPoint(x: 145, y: 256),
                                         right: CGPoint(x: 196, y: 243),
                                         bottom: CGPoint(x: 161, y: 329))
        let local = origin.converted { CGPoint(x: $0.x - 15, y: $0.y - 20) }
        let size = CGSize(width: 231.25, height: 370)
        let transform = local.transform(from: size)
        let right = CGPoint(x: size.width / 2, y: 0).applying(transform)
        let bottom = CGPoint(x: 0, y: size.height / 2).applying(transform)
        #expect(local.center == CGPoint(x: 130, y: 236))
        #expect(abs(right.x + local.center.x - local.right.x) < 1e-9)
        #expect(abs(right.y + local.center.y - local.right.y) < 1e-9)
        #expect(abs(bottom.x + local.center.x - local.bottom.x) < 1e-9)
        #expect(abs(bottom.y + local.center.y - local.bottom.y) < 1e-9)
    }

    @Test func keepsTheExpandedPoseWhenMovingTheFrontIntoARotatedCell() {
        let size = CGSize(width: 231.25, height: 370)
        let center = CGPoint(x: 195, y: 447)
        let expanded = CardHandoffGeometry(center: center,
                                           right: CGPoint(x: center.x + size.width / 2, y: center.y),
                                           bottom: CGPoint(x: center.x, y: center.y + size.height / 2))
        let cellToWindow = CGAffineTransform(rotationAngle: 0.37).scaledBy(x: 0.73, y: 0.73)
            .concatenating(CGAffineTransform(translationX: 274, y: 305))
        let windowToCell = cellToWindow.inverted()
        let local = expanded.converted { $0.applying(windowToCell) }
        let transform = local.transform(from: size)
            .concatenating(CGAffineTransform(translationX: local.center.x, y: local.center.y))
            .concatenating(cellToWindow)

        let topLeft = CGPoint(x: -size.width / 2, y: -size.height / 2).applying(transform)
        #expect(abs(topLeft.x - (center.x - size.width / 2)) < 1e-9)
        #expect(abs(topLeft.y - (center.y - size.height / 2)) < 1e-9)
    }

    @Test func preservesAFrontDetailAtItsOriginalPositionAfterScalingDown() {
        let sourceSize = CGSize(width: 182.5, height: 292)
        let expandedSize = CGSize(width: 231.25, height: 370)
        let sourceTransform = CGAffineTransform(rotationAngle: 0.173).scaledBy(x: 0.73, y: 0.73)
        let origin = CardHandoffGeometry(
            center: .zero,
            right: CGPoint(x: sourceSize.width / 2, y: 0).applying(sourceTransform),
            bottom: CGPoint(x: 0, y: sourceSize.height / 2).applying(sourceTransform)
        )
        let caption = CGPoint(x: 23, y: 119)
        let expanded = caption.applying(CGAffineTransform(scaleX: expandedSize.width / sourceSize.width,
                                                            y: expandedSize.height / sourceSize.height))
        let landed = expanded.applying(origin.transform(from: expandedSize))
        let expected = caption.applying(sourceTransform)
        #expect(abs(landed.x - expected.x) < 1e-9)
        #expect(abs(landed.y - expected.y) < 1e-9)
    }
}
