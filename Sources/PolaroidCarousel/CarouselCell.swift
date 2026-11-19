#if canImport(UIKit)
import UIKit

final class CarouselCell: UICollectionViewCell {
    private weak var returningFront: UIView?

    func attachReturningFront(_ front: UIView) {
        returningFront?.removeFromSuperview()
        // The content view is hidden while the detail is open; the flight is its sibling.
        addSubview(front)
        returningFront = front
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        returningFront?.removeFromSuperview()
        returningFront = nil
    }
}
#endif
