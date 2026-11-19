import PolaroidCarousel
import SwiftUI

struct FieldNotesView: View {
    @State private var selection = 0
    @State private var isCollapsed = false
    @State private var cardCount = Postcard.deck.count

    var body: some View {
        let cards = Array(Postcard.deck.prefix(cardCount))
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                Menu {
                    Picker("Deck size", selection: Binding(get: { cardCount }, set: setCardCount)) {
                        ForEach(0...Postcard.deck.count, id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                } label: {
                    Label("Deck size: \(cardCount)", systemImage: "rectangle.on.rectangle")
                }

                PolaroidCarousel(items: cards, selection: $selection, isCollapsed: isCollapsed,
                                 accessibilityTitle: \.title) { card in
                    PostcardView(postcard: card)
                } back: { card in
                    PostcardBackView(postcard: card)
                }
                .frame(height: 280)
                .padding(.vertical, 14)
                .background(Color.primary.opacity(0.045), in: .rect(cornerRadius: 24))
                .clipShape(.rect(cornerRadius: 24))

                DeckControls(card: cards.indices.contains(selection) ? cards[selection] : nil,
                             index: selection, count: cards.count, isCollapsed: $isCollapsed,
                             previous: { moveSelection(by: -1) }, next: { moveSelection(by: 1) })
            }
            .frame(maxWidth: 460)
            .padding(.horizontal, 18)
            .padding(.vertical, 26)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemBackground))
        .tint(Color(uiColor: .systemTeal))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("POSTCARD COLLECTION", systemImage: "viewfinder")
                .font(.caption.monospaced().weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("Field Notes")
                .font(.system(.largeTitle, design: .serif).weight(.bold))
                .accessibilityAddTraits(.isHeader)
            Text("Swipe the deck. Tap a card to read the note on the back.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func setCardCount(_ count: Int) {
        selection = min(selection, max(0, count - 1))
        cardCount = count
    }

    private func moveSelection(by delta: Int) {
        guard cardCount > 1 else { return }
        selection = (selection + delta + cardCount) % cardCount
    }
}

#Preview {
    FieldNotesView()
}
