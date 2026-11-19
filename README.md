# PolaroidCarousel

A dependency-free iOS 17+ carousel with an overlapping deck, continuous scroll transforms, and snapping. The layout and scrolling are UIKit; a `UIViewRepresentable` hosts SwiftUI card content through `UIHostingConfiguration`. Requires Swift 6.2 or later.

## Try the demo

Open [Example/PolaroidDemo.xcodeproj](Example/PolaroidDemo.xcodeproj), choose the **PolaroidDemo** scheme and an iPhone simulator, then run. **Field Notes** shows five original illustrated postcards. Swipe the deck, tap a card, use the arrow buttons to select one programmatically, or switch between **Fan** and **Stack**. The demo uses the same public SwiftUI API shown below.

On launch, the first card appears over the stack, then the cards fan out with a subtle spring. On supported iPhones, a light selection tick marks each new card as a swipe crosses it. Launch the app afresh to replay the entrance.

The Xcode project already points to the local package. To regenerate it after adding or removing app files, run `xcodegen generate --spec Example/project.yml` from the package directory.

## Use it in another app

Add this directory as a local Swift package in Xcode and link the `PolaroidCarousel` product. The container sets the card height; the width is always 5/8 of that height.

### SwiftUI

```swift
import PolaroidCarousel
import SwiftUI

struct Example: View {
    @State private var index = 0
    private let cards = ["Lake", "Mountain", "Forest"]

    var body: some View {
        PolaroidCarousel(items: cards, selection: $index, accessibilityTitle: { $0 }) { title in
            Text(title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial, in: .rect(cornerRadius: 8))
        }
        .frame(height: 240)
    }
}
```

`selection` is a zero-based index into your own deck. Taps and finished swipes update it, and changes to it scroll to the nearest copy of that card. An empty array renders an empty deck. When replacing items, supply an appropriate selection for the new array. Make render-relevant properties part of your `Equatable` item: the wrapper reloads content when the items change, not on every selection change. Set `isCollapsed` to choose the stacked pose. Use `onCardTap` for actions such as presenting details; card content itself should be visual-only.

### UIKit

```swift
let titles = ["Lake", "Mountain", "Forest"]
let carousel = PolaroidCarouselView { index in
    var content = UIListContentConfiguration.cell()
    content.text = titles[index]
    return content
}
carousel.accessibilityTitleForCard = { titles[$0] }
carousel.onSelectionChange = { index in print("Centered: \(titles[index])") }
carousel.reloadCards(count: titles.count)
// Add carousel to your hierarchy and constrain its width and height.
```

Use `selectCard(at:animated:)` for programmatic navigation, or `reloadCards(count:selectedIndex:)` after changing the dataset. The content provider and callbacks only see logical indexes. VoiceOver sees one adjustable element with the current card’s title and ordinal, not the virtual list.

Both APIs enable the entrance animation and swipe haptics by default. Set `animatesEntrance` or `isHapticFeedbackEnabled` to `false` to opt out. The entrance only plays on the first presentation of an expanded, multi-card deck; it does not replay after a reload. It skips Reduce Motion, as does programmatic scrolling animation. Programmatic navigation does not generate haptics.

## Implementation and tests

The layout keeps a fixed-width row for snapping and interpolates the card transforms independently as the row scrolls. It computes attributes for only a small neighborhood around the viewport. A large virtual row lets the deck wrap, with edge rebasing and nearest-copy selection handled inside the view. The package and example do not require any external artwork, fonts, or binaries.

Run `swift test` from this directory on a Mac to exercise the layout math and deck indexing. The UIKit view and SwiftUI wrapper are iOS-only; the macOS target exists to run these geometry tests without a simulator.
