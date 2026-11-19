#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit

/// SwiftUI bridge for the UIKit carousel. `selection` is a logical index, not a virtual page.
/// Give the carousel an explicit height. Cards should be visual-only; use `onCardTap` for actions.
@MainActor
public struct PolaroidCarousel<Item: Equatable, Card: View>: UIViewRepresentable {
    private let items: [Item]
    @Binding private var selection: Int
    private let isCollapsed: Bool
    private let animatesEntrance: Bool
    private let isHapticFeedbackEnabled: Bool
    private let accessibilityTitle: ((Item) -> String)?
    private let onCardTap: ((Item) -> Void)?
    private let card: (Item) -> Card

    public init(items: [Item], selection: Binding<Int>, isCollapsed: Bool = false,
                animatesEntrance: Bool = true, isHapticFeedbackEnabled: Bool = true,
                accessibilityTitle: ((Item) -> String)? = nil,
                onCardTap: ((Item) -> Void)? = nil,
                @ViewBuilder card: @escaping (Item) -> Card) {
        self.items = items
        self._selection = selection
        self.isCollapsed = isCollapsed
        self.animatesEntrance = animatesEntrance
        self.isHapticFeedbackEnabled = isHapticFeedbackEnabled
        self.accessibilityTitle = accessibilityTitle
        self.onCardTap = onCardTap
        self.card = card
    }

    public func makeCoordinator() -> Coordinator { Coordinator(source: self) }

    public func makeUIView(context: Context) -> PolaroidCarouselView {
        let coordinator = context.coordinator
        let view = PolaroidCarouselView { [weak coordinator] index in
            guard let source = coordinator?.source, source.items.indices.contains(index) else {
                return UIHostingConfiguration { EmptyView() }.margins(.all, 0)
            }
            return UIHostingConfiguration { source.card(source.items[index]) }.margins(.all, 0)
        }
        view.accessibilityTitleForCard = { [weak coordinator] index in
            guard let source = coordinator?.source, source.items.indices.contains(index) else { return nil }
            return source.accessibilityTitle?(source.items[index])
        }
        view.onSelectionChange = { [weak coordinator] index in
            coordinator?.source.selection = index
        }
        applyOptions(to: view)
        view.reloadCards(count: items.count, selectedIndex: selection)
        return view
    }

    public func updateUIView(_ view: PolaroidCarouselView, context: Context) {
        let coordinator = context.coordinator
        let itemsChanged = coordinator.source.items != items
        coordinator.source = self
        view.onCardTap = onCardTap.map { _ in
            { [weak coordinator] index in
                guard let source = coordinator?.source, source.items.indices.contains(index) else { return }
                source.onCardTap?(source.items[index])
            }
        }
        applyOptions(to: view)
        if itemsChanged {
            view.reloadCards(count: items.count, selectedIndex: selection)
        } else {
            view.selectCard(at: selection, animated: !context.transaction.disablesAnimations)
        }
    }

    private func applyOptions(to view: PolaroidCarouselView) {
        view.animatesEntrance = animatesEntrance
        view.isHapticFeedbackEnabled = isHapticFeedbackEnabled
        view.isCollapsed = isCollapsed
    }

    @MainActor
    public final class Coordinator {
        fileprivate var source: PolaroidCarousel

        fileprivate init(source: PolaroidCarousel) { self.source = source }
    }
}
#endif
