#if canImport(UIKit)
import UIKit

/// A horizontally scrolling, wrapping deck with customizable card content.
/// Give the view a height; each card is laid out at 5/8 of that height in width.
public final class PolaroidCarouselView: UIView {
    private let carouselLayout = CarouselLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: carouselLayout)
    private let cardConfiguration: (Int) -> any UIContentConfiguration
    private var deck = CarouselDeck(count: 0)
    private var needsInitialPosition = true
    private var hasPresentedDeck = false
    private var entranceAnimator: UIViewPropertyAnimator?
    private lazy var selectionFeedback = UISelectionFeedbackGenerator()
    private var lastFeedbackItem: Int?
    private weak var activeDetail: CardDetailViewController?
    private var detailSource: IndexPath?
    private var hiddenDetailSource: IndexPath?
    private static let cellID = "PolaroidCard"

    public private(set) var selectedIndex: Int?

    /// Called after a user-driven selection change. Programmatic selection does not call it.
    public var onSelectionChange: ((Int) -> Void)?
    /// Called on tap or VoiceOver activation when no built-in detail is presented.
    public var onCardTap: ((Int) -> Void)? {
        didSet { updateAccessibilityTraits() }
    }
    /// Supply a back configuration to open a two-sided detail card on tap.
    public var backConfigurationForCard: ((Int) -> any UIContentConfiguration)? {
        didSet { updateAccessibilityTraits() }
    }
    /// Supplies the name announced for the centered card. The ordinal is added automatically.
    public var accessibilityTitleForCard: ((Int) -> String?)? {
        didSet { updateAccessibility() }
    }

    public var isCollapsed = false {
        didSet {
            guard oldValue != isCollapsed else { return }
            stopEntrance()
            carouselLayout.isCollapsed = isCollapsed
        }
    }

    /// Fan out on the first presentation of a multi-card deck. Skipped with Reduce Motion.
    public var animatesEntrance = true {
        didSet { if !animatesEntrance { stopEntrance() } }
    }

    /// Play a selection tick when a user swipe or its deceleration crosses a card boundary.
    public var isHapticFeedbackEnabled = true

    /// The provider receives logical (zero-based) indexes, never virtual indexes.
    /// Use visual content here and handle card actions via `backConfigurationForCard` or `onCardTap`.
    public init(cardConfiguration: @escaping (Int) -> any UIContentConfiguration) {
        self.cardConfiguration = cardConfiguration
        super.init(frame: .zero)

        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: Self.cellID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.semanticContentAttribute = .forceLeftToRight
        collectionView.accessibilityElementsHidden = true
        addSubview(collectionView)

        accessibilityLabel = String(localized: "Cards", bundle: .module)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("Use init(cardConfiguration:)") }

    /// Apply a new deck or refresh changed content. An empty deck has no selection.
    public func reloadCards(count: Int, selectedIndex: Int = 0) {
        stopEntrance()
        lastFeedbackItem = nil
        updateDetailSourceVisibility(hidden: false)
        detailSource = nil
        deck = CarouselDeck(count: count)
        self.selectedIndex = deck.clampedSelection(selectedIndex)
        needsInitialPosition = true
        carouselLayout.itemCount = deck.virtualCount
        collectionView.reloadData()
        carouselLayout.invalidateLayout()
        updateAccessibility()
        setNeedsLayout()
    }

    /// Centers the nearest copy of a logical index. Out-of-range requests are clamped.
    public func selectCard(at index: Int, animated: Bool = true) {
        guard let index = deck.clampedSelection(index), index != selectedIndex else { return }
        stopEntrance()
        lastFeedbackItem = nil
        selectedIndex = index
        updateAccessibility()
        guard !needsInitialPosition, let item = nearestVisibleItem() else { return }
        center(item: deck.nearestItem(for: index, to: item), animated: animated)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let oldSize = collectionView.bounds.size
        collectionView.frame = bounds
        let geometry = CarouselGeometry(size: bounds.size)
        guard geometry.step > 0, bounds.width > 0 else { return }
        let inset = UIEdgeInsets(top: 0, left: geometry.inset, bottom: 0, right: geometry.inset)
        if collectionView.contentInset != inset { collectionView.contentInset = inset }

        let shouldPlayEntrance = stageEntranceIfNeeded()
        if needsInitialPosition || oldSize != bounds.size {
            // Reflect the new content size before jumping to the centered card.
            collectionView.layoutIfNeeded()
            needsInitialPosition = false
            if let selectedIndex { center(item: deck.middleItem(for: selectedIndex), animated: false) }
        }
        if shouldPlayEntrance { playEntrance() }
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopEntrance()
            lastFeedbackItem = nil
        } else {
            setNeedsLayout()
        }
    }

    public override func accessibilityIncrement() { moveAccessibilitySelection(by: 1) }
    public override func accessibilityDecrement() { moveAccessibilitySelection(by: -1) }

    public override func accessibilityActivate() -> Bool {
        if let item = nearestVisibleItem(), openDetail(at: IndexPath(item: item, section: 0)) { return true }
        guard let selectedIndex, let onCardTap else { return false }
        onCardTap(selectedIndex)
        return true
    }

    private func stageEntranceIfNeeded() -> Bool {
        guard !hasPresentedDeck, window != nil, deck.count > 0 else { return false }
        hasPresentedDeck = true
        guard deck.count > 1, !isCollapsed, animatesEntrance,
              !UIAccessibility.isReduceMotionEnabled else { return false }
        carouselLayout.isCollapsed = true
        return true
    }

    private func playEntrance() {
        // Commit the starting stack around the selected item before animating its attributes.
        collectionView.layoutIfNeeded()
        let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.8) { [weak self] in
            guard let self else { return }
            carouselLayout.isCollapsed = false
            collectionView.layoutIfNeeded()
        }
        animator.addCompletion { [weak self] _ in self?.entranceAnimator = nil }
        entranceAnimator = animator
        animator.startAnimation(afterDelay: 0.12)
    }

    private func stopEntrance() {
        guard let animator = entranceAnimator else { return }
        entranceAnimator = nil
        if animator.state == .active {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .end)
        }
        carouselLayout.isCollapsed = isCollapsed
        carouselLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
    }

    private func openDetail(at indexPath: IndexPath) -> Bool {
        if activeDetail != nil { return true }
        guard let backConfigurationForCard, let window, var presenter = window.rootViewController else { return false }
        while let presented = presenter.presentedViewController { presenter = presented }
        guard presenter.viewIfLoaded?.window === window, !presenter.isBeingDismissed,
              !presenter.isBeingPresented else { return false }

        detailSource = indexPath
        // Capture the actual card at its carousel layout size, before settling an in-flight entrance.
        let sourceView = detailSourceCell(for: indexPath)?.contentView
        let source = sourceView.flatMap { CardDetailViewController.Source(card: $0, in: window) }
        stopEntrance()
        lastFeedbackItem = nil
        let index = deck.logicalIndex(at: indexPath.item)
        let detail = CardDetailViewController(
            back: backConfigurationForCard(index), source: source,
            returnTarget: { [weak self, weak sourceView, sourceSize = source?.size] in
                guard let self, let window = self.window, let sourceView,
                      let cell = detailSourceCell(for: indexPath), cell.contentView === sourceView,
                      sourceView.bounds.size == sourceSize,
                      let origin = CardHandoffGeometry(card: sourceView, in: window) else { return nil }
                return CardDetailViewController.ReturnTarget(origin: origin, cell: cell)
            },
            setSourceHidden: { [weak self] hidden in
                guard let self, detailSource == indexPath else { return }
                updateDetailSourceVisibility(hidden: hidden)
                if !hidden { detailSource = nil }
            }
        )
        activeDetail = detail
        presenter.present(detail, animated: false)
        return true
    }

    private func detailSourceCell(for indexPath: IndexPath) -> CarouselCell? {
        guard detailSource == indexPath, let window,
              collectionView.indexPathsForVisibleItems.contains(indexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? CarouselCell,
              cell.window === window else { return nil }
        return cell
    }

    private func updateDetailSourceVisibility(hidden: Bool) {
        guard let detailSource else { return }
        hiddenDetailSource = hidden ? detailSource : nil
        collectionView.cellForItem(at: detailSource)?.contentView.alpha = hidden ? 0 : 1
    }

    private func center(item: Int, animated: Bool) {
        let geometry = CarouselGeometry(size: collectionView.bounds.size)
        collectionView.setContentOffset(CGPoint(x: geometry.offset(forPage: CGFloat(item)), y: 0),
                                        animated: animated && !UIAccessibility.isReduceMotionEnabled)
    }

    private func nearestVisibleItem() -> Int? {
        let geometry = CarouselGeometry(size: collectionView.bounds.size)
        guard deck.virtualCount > 0, geometry.step > 0 else { return nil }
        let page = geometry.page(atOffset: collectionView.contentOffset.x).rounded()
        if page <= 0 { return 0 }
        if page >= CGFloat(deck.virtualCount - 1) { return deck.virtualCount - 1 }
        return Int(page)
    }

    private func finishScrolling() {
        lastFeedbackItem = nil
        guard !needsInitialPosition, let item = nearestVisibleItem() else { return }
        let rebased = deck.rebasedItem(item)
        if rebased != item { center(item: rebased, animated: false) }
        publishSelection(deck.logicalIndex(at: item))
    }

    private func publishSelection(_ index: Int) {
        guard selectedIndex != index else { return }
        selectedIndex = index
        updateAccessibility()
        onSelectionChange?(index)
    }

    private func moveAccessibilitySelection(by delta: Int) {
        guard let selectedIndex, deck.count > 1 else { return }
        let candidate = selectedIndex + delta
        let index = candidate < 0 ? deck.count - 1 : candidate % deck.count
        selectCard(at: index, animated: false)
        onSelectionChange?(index)
    }

    private func updateAccessibilityTraits() {
        if deck.count > 1 {
            accessibilityTraits = .adjustable
        } else {
            accessibilityTraits = onCardTap != nil || backConfigurationForCard != nil ? .button : .staticText
        }
    }

    private func updateAccessibility() {
        isAccessibilityElement = selectedIndex != nil
        updateAccessibilityTraits()
        guard let selectedIndex else {
            accessibilityValue = nil
            return
        }
        let ordinal = String(localized: "\(selectedIndex + 1) of \(deck.count)", bundle: .module)
        if let title = accessibilityTitleForCard?(selectedIndex) {
            accessibilityValue = String(localized: "\(title), \(ordinal)", bundle: .module)
        } else {
            accessibilityValue = ordinal
        }
    }
}

extension PolaroidCarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        deck.virtualCount
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellID, for: indexPath)
        cell.contentConfiguration = cardConfiguration(deck.logicalIndex(at: indexPath.item))
        cell.contentView.alpha = hiddenDetailSource == indexPath ? 0 : 1
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if openDetail(at: indexPath) { return }
        stopEntrance()
        lastFeedbackItem = nil
        let index = deck.logicalIndex(at: indexPath.item)
        center(item: indexPath.item, animated: true)
        publishSelection(index)
        onCardTap?(index)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopEntrance()
        guard isHapticFeedbackEnabled, deck.count > 1 else { return }
        lastFeedbackItem = nearestVisibleItem()
        selectionFeedback.prepare()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isHapticFeedbackEnabled, scrollView.isTracking || scrollView.isDecelerating,
              let previousItem = lastFeedbackItem, let item = nearestVisibleItem(), item != previousItem else { return }
        lastFeedbackItem = item
        selectionFeedback.selectionChanged()
        selectionFeedback.prepare()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { finishScrolling() }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { finishScrolling() }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { finishScrolling() }
}
#endif
