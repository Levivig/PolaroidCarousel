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

    @Test(arguments: 2...4)
    func smallFansShowEachLogicalCardOnceThroughoutTheLoop(count: Int) throws {
        let deck = CarouselDeck(count: count)
        let start = deck.middleItem(for: 0)
        for tick in -(count * 32)...(count * 32) {
            let page = CGFloat(start) + CGFloat(tick) / 16
            let offset = geometry.offset(forPage: page)
            let range = try #require(geometry.queryRange(midX: offset + geometry.size.width / 2, count: deck.virtualCount))
            let visible = range.compactMap { item -> Int? in
                let position = geometry.position(of: item, atOffset: offset)
                guard CarouselGeometry.presentation(at: position, collapsed: false, cardCount: count) != nil
                else { return nil }
                return deck.logicalIndex(at: item)
            }
            #expect(visible.sorted() == Array(0..<count), "At page \(page)")
        }
    }

    @Test(arguments: [(2, -0.75, 1.25), (3, -1.5, 1.5), (4, -1.75, 2.25)])
    func smallFanReturningCardMeetsBehindTheDeck(count: Int, lower: CGFloat, upper: CGFloat) throws {
        let trailingPosition = upper - 0.000_001
        let trailing = try #require(CarouselGeometry.presentation(at: trailingPosition, collapsed: false, cardCount: count))
        let leading = try #require(CarouselGeometry.presentation(at: lower, collapsed: false, cardCount: count))
        let foreground = try #require(CarouselGeometry.presentation(at: lower.rounded(.up), collapsed: false, cardCount: count))
        #expect(abs(trailingPosition + trailing.pose.dx - (lower + leading.pose.dx)) < 1e-8)
        #expect(abs(trailing.pose.dy - leading.pose.dy) < 1e-8)
        #expect(abs(trailing.pose.angle - leading.pose.angle) < 1e-8)
        #expect(abs(trailing.pose.scale - leading.pose.scale) < 1e-8)
        #expect(trailing.zIndex == leading.zIndex)
        #expect(leading.zIndex < foreground.zIndex)
    }

    @Test func stackAndLargerFansKeepTheirExistingPoses() {
        for (count, collapsed) in [(1, false), (2, true), (3, true), (4, true), (5, false), (15, false)] {
            for position in stride(from: -3.5 as CGFloat, through: 3.5, by: 0.5) {
                let pose = CarouselGeometry.pose(at: position, collapsed: collapsed)
                let presentation = CarouselGeometry.presentation(at: position, collapsed: collapsed, cardCount: count)
                #expect(presentation?.pose.transform(width: 100, height: 160) == pose?.transform(width: 100, height: 160))
                #expect(presentation?.zIndex == pose.map { _ in -Int(abs(position).rounded()) })
            }
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
