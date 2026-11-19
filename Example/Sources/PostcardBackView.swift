import SwiftUI

struct PostcardBackView: View {
    let postcard: Postcard
    private let ink = Color(red: 0.18, green: 0.20, blue: 0.19)
    private let paper = Color(red: 0.98, green: 0.96, blue: 0.90)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    Text("FIELD NOTES")
                        .font(.caption.monospaced().weight(.semibold))
                        .tracking(1.5)
                        .padding(.top, 4)
                    Spacer(minLength: 8)
                    Image(systemName: "mountain.2")
                        .font(.title2)
                        .padding(10)
                        .background(postcard.horizon.opacity(0.5), in: .rect(cornerRadius: 4))
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(ink.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                        }
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(postcard.title)
                        .font(.title2.weight(.semibold))
                        .fontDesign(.serif)
                        .accessibilityAddTraits(.isHeader)
                    Text(postcard.subtitle)
                        .font(.footnote.monospaced())
                }

                Rectangle()
                    .fill(ink.opacity(0.25))
                    .frame(height: 1)
                    .accessibilityHidden(true)

                Text(postcard.note)
                    .font(.body)
                    .fontDesign(.serif)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
        }
        .foregroundStyle(ink)
        .background(paper, in: .rect(cornerRadius: 4))
        .clipShape(.rect(cornerRadius: 4))
    }
}
