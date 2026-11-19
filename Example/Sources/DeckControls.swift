import SwiftUI

struct DeckControls: View {
    let card: Postcard?
    let index: Int
    let count: Int
    @Binding var isCollapsed: Bool
    let previous: () -> Void
    let next: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 14) {
                if let card {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(index + 1) / \(count)")
                            .font(.caption.monospacedDigit().weight(.medium))
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Card \(index + 1) of \(count)")
                        Text(card.title)
                            .font(.title3.weight(.semibold))
                        Text(card.subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No cards")
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                navigationButton("Previous card", symbol: "chevron.backward", action: previous)
                navigationButton("Next card", symbol: "chevron.forward", action: next)
            }
            Picker("Card layout", selection: $isCollapsed) {
                Label("Fan", systemImage: "rectangle.on.rectangle.angled").tag(false)
                Label("Stack", systemImage: "rectangle.stack").tag(true)
            }
            .pickerStyle(.segmented)
        }
    }

    private func navigationButton(_ title: LocalizedStringKey, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .labelStyle(.iconOnly)
                .font(.body.weight(.semibold))
                .frame(width: 44, height: 44)
                .background(.thinMaterial, in: .circle)
        }
        .buttonStyle(.plain)
        .disabled(count < 2)
    }
}
