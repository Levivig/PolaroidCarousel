# PolaroidCarousel

A dependency-free iOS 16+ carousel with an overlapping deck, continuous scroll transforms, and snapping. Fan mode shows each card once in decks of two to four cards, while still wrapping in both directions. The layout and scrolling are UIKit; a `UIViewRepresentable` hosts SwiftUI card content through `UIHostingConfiguration`, which requires iOS 16. Requires Swift 6.2 or later (Xcode 26 or later).

## Try the demo

Open [Example/PolaroidDemo.xcodeproj](Example/PolaroidDemo.xcodeproj), choose the **PolaroidDemo** scheme and an iPhone simulator, then run. **Field Notes** shows 15 original illustrated postcards. Use **Deck size** to try any count from 0 to 15 without restarting, then swipe in either direction to test wrapping. With two to four cards, **Fan** shows each postcard only once. Tap a postcard to flip it open and read its note, use the arrow buttons to select programmatically, or switch between **Fan** and **Stack**. The demo uses the same public SwiftUI API shown below.

On launch, the first card appears over the stack, then the cards fan out with a subtle spring. On supported iPhones, a light selection tick marks each new card as a swipe crosses it. Launch the app afresh to replay the entrance.

The Xcode project already points to the local package. To regenerate it after adding or removing app files, run `xcodegen generate --spec Example/project.yml` from the package directory.

## Use it in another app

In Xcode, choose **File → Add Package Dependencies…** and enter the repository's SSH URL:

```text
git@github.com:Levivig/PolaroidCarousel.git
```

Choose **Up to Next Minor Version** starting at `0.1.1` (the first version supporting iOS 16), then add the `PolaroidCarousel` library product to your app target. The repository is private: the GitHub account associated with your SSH key must have read access. CI also needs read access, for example through a read-only deploy key. Check your local access with `git ls-remote git@github.com:Levivig/PolaroidCarousel.git`.

If your app uses a `Package.swift`, add the dependency and link its product in your target:

```swift
// In the package's dependencies:
.package(url: "git@github.com:Levivig/PolaroidCarousel.git", .upToNextMinor(from: "0.1.1")),

// In the target's dependencies:
.product(name: "PolaroidCarousel", package: "PolaroidCarousel"),
```

To develop against a local checkout instead, use **Add Local…** in Xcode. The carousel's container sets the card height; the width is always 5/8 of that height.

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
        } back: { title in
            Text("A note from \(title)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial, in: .rect(cornerRadius: 8))
        }
        .frame(height: 240)
    }
}
```

`selection` is the zero-based index of the centered card. Finished swipes update it, and changing it scrolls to the nearest copy. With a `back` builder, tapping a card lifts it from its place, flips it over a dark backdrop, and leaves the deck positioned as it was. Close the detail with the × button, a tap outside the card, or the VoiceOver escape gesture. Reduce Motion uses a fade instead of a flip.

Omit `back` to keep the front-only tap-to-center behavior, and use `onCardTap` if you want to present your own detail. An empty array renders an empty deck. When replacing items, supply an appropriate selection for the new array. Make render-relevant properties part of your `Equatable` item: the wrapper reloads content when the items change, not on every selection change. Set `isCollapsed` to choose the stacked pose.

### UIKit

```swift
let titles = ["Lake", "Mountain", "Forest"]
let carousel = PolaroidCarouselView { index in
    var content = UIListContentConfiguration.cell()
    content.text = titles[index]
    return content
}
carousel.accessibilityTitleForCard = { titles[$0] }
carousel.backConfigurationForCard = { index in
    var content = UIListContentConfiguration.cell()
    content.text = "A note from \(titles[index])"
    return content
}
carousel.onSelectionChange = { index in print("Centered: \(titles[index])") }
carousel.reloadCards(count: titles.count)
// Add carousel to your hierarchy and constrain its width and height.
```

Use `selectCard(at:animated:)` for programmatic navigation, or `reloadCards(count:selectedIndex:)` after changing the dataset. The content providers and callbacks only see logical indexes. Set `backConfigurationForCard` to opt into the built-in modal detail, or leave it unset to handle taps with `onCardTap`. VoiceOver sees one adjustable element with the current card’s title and ordinal, not the virtual list.

Both APIs enable the entrance animation and swipe haptics by default. Set `animatesEntrance` or `isHapticFeedbackEnabled` to `false` to opt out. The entrance only plays on the first presentation of an expanded, multi-card deck; it does not replay after a reload. It skips Reduce Motion, as does programmatic scrolling animation. Programmatic navigation does not generate haptics.

## Implementation and tests

The layout keeps a fixed-width row for snapping and interpolates the card transforms independently as the row scrolls. It computes attributes for only a small neighborhood around the viewport. A large virtual row lets the deck wrap, with edge rebasing and nearest-copy selection handled inside the view. The package and example do not require any external artwork, fonts, or binaries.

Run `swift test` from this directory on a Mac to exercise the layout math and deck indexing. The UIKit view and SwiftUI wrapper are iOS-only; the macOS target exists to run these geometry tests without a simulator.
