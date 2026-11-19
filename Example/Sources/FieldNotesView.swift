import PolaroidCarousel
import SwiftUI

struct FieldNotesView: View {
    @State private var selection = 0
    @State private var isCollapsed = false
    private let cards = Postcard.deck

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                PolaroidCarousel(items: cards, selection: $selection, isCollapsed: isCollapsed,
                                 accessibilityTitle: \.title) { card in
                    PostcardView(postcard: card)
                }
                .frame(height: 292)
                .padding(.vertical, 14)
                .background(Color.primary.opacity(0.045), in: .rect(cornerRadius: 24))
                .clipShape(.rect(cornerRadius: 24))

                DeckControls(card: cards[selection], index: selection, count: cards.count,
                             isCollapsed: $isCollapsed, previous: previous, next: next)
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
                .font(.largeTitle.weight(.bold))
                .fontDesign(.serif)
                .accessibilityAddTraits(.isHeader)
            Text("Swipe or tap a card to explore the deck.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func previous() { selection = (selection + cards.count - 1) % cards.count }
    private func next() { selection = (selection + 1) % cards.count }
}

#Preview {
    FieldNotesView()
}
