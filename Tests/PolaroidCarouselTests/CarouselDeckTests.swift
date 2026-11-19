import Testing
@testable import PolaroidCarousel

struct CarouselDeckTests {
    @Test func handlesEmptyAndSingleCardDecks() {
        let empty = CarouselDeck(count: 0)
        #expect(empty.virtualCount == 0)
        #expect(empty.clampedSelection(1) == nil)
        let single = CarouselDeck(count: 1)
        #expect(single.virtualCount == 1)
        #expect(single.clampedSelection(12) == 0)
        #expect(single.middleItem(for: 0) == 0)
    }

    @Test func navigatesAcrossTheSeamInBothDirections() {
        let deck = CarouselDeck(count: 5)
        let first = deck.middleItem(for: 0)
        #expect(deck.virtualCount == 50_000)
        #expect(deck.nearestItem(for: 4, to: first) == first - 1)
        #expect(deck.nearestItem(for: 0, to: first - 1) == first)
        #expect(deck.nearestItem(for: 4, to: 0) == 4)
        #expect(deck.nearestItem(for: 0, to: deck.virtualCount - 1) == deck.virtualCount - 5)
    }

    @Test func recentersAtTheEdgesWithoutChangingLogicalSelection() {
        let deck = CarouselDeck(count: 5)
        let last = deck.virtualCount - 1
        #expect(deck.rebasedItem(2) == deck.middleItem(for: 2))
        #expect(deck.rebasedItem(last) == deck.middleItem(for: 4))
        #expect(deck.rebasedItem(25_012) == 25_012)
    }
}
