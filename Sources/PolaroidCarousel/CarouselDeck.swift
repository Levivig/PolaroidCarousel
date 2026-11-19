struct CarouselDeck {
    let count: Int

    // Keep a large runway in both directions without risking Int overflow.
    private var repetitions: Int { count > 1 ? min(10_000, Int.max / count) : 1 }
    var virtualCount: Int { count * repetitions }

    init(count: Int) { self.count = max(0, count) }

    func clampedSelection(_ index: Int) -> Int? {
        count > 0 ? min(max(0, index), count - 1) : nil
    }

    func logicalIndex(at item: Int) -> Int { item % count }

    func middleItem(for index: Int) -> Int { repetitions / 2 * count + index }

    func nearestItem(for index: Int, to item: Int) -> Int {
        let base = item - logicalIndex(at: item)
        let current = base + index
        var nearest = current
        if base > 0, item - (current - count) < abs(nearest - item) { nearest = current - count }
        if base < virtualCount - count, current + count - item < abs(nearest - item) { nearest = current + count }
        return nearest
    }

    func rebasedItem(_ item: Int) -> Int {
        let edge = max(count, 4)
        guard repetitions > 2, item < edge || item >= virtualCount - edge else { return item }
        return middleItem(for: logicalIndex(at: item))
    }
}
