import CoreGraphics
import Testing
@testable import PolaroidCarousel

struct CarouselGeometryTests {
    private let geometry = CarouselGeometry(size: CGSize(width: 300, height: 233))

    @Test func centersCardsAndSnapsToTheNearestPage() {
        #expect(geometry.step == 145.625)
        #expect(geometry.inset == 77.1875)
        #expect(geometry.offset(forPage: 75_007) == 10_922_817.1875)
        let page = geometry.page(atOffset: 10_922_918.9375).rounded()
        #expect(geometry.offset(forPage: page) == 10_922_962.8125)
    }

    @Test func matchesTheRecordedExpandedTransform() throws {
        let distance = geometry.position(of: 75_007, atOffset: 10_922_817)
        let pose = try #require(CarouselGeometry.pose(at: distance, collapsed: false))
        let transform = pose.transform(width: geometry.step, height: geometry.size.height)
        #expect(abs(transform.a - 0.8831978613107473) < 1e-9)
        #expect(abs(transform.b + 0.10814289129059122) < 1e-9)
        #expect(abs(transform.tx + 1.41675) < 1e-8)
        #expect(abs(transform.ty + 5.6007) < 1e-8)
    }

    @Test func collapsesNeighborsBehindTheCenteredCard() throws {
        let center = try #require(CarouselGeometry.pose(at: 0, collapsed: true))
        #expect(center.scale == 0.801)
        for slot in [-3, -2, -1, 1, 2, 3] {
            let pose = try #require(CarouselGeometry.pose(at: CGFloat(slot), collapsed: true))
            #expect(pose.scale == 0.5)
            #expect(CGFloat(slot) + pose.dx == 0)
        }
    }

    @Test func hidesDistantCardsAndBoundsLayoutWork() {
        #expect(CarouselGeometry.pose(at: 3.01, collapsed: false) == nil)
        #expect(CarouselGeometry.pose(at: -3.01, collapsed: true) == nil)
        #expect(geometry.queryRange(midX: 10_922_967, count: 150_000) == 75_003...75_011)
        #expect(geometry.queryRange(midX: 150, count: 3) == 0...2)
        #expect(geometry.queryRange(midX: 150, count: 0) == nil)
    }
}
