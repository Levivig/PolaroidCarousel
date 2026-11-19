#if canImport(UIKit)
import UIKit

final class CarouselLayout: UICollectionViewLayout {
    var itemCount = 0
    var isCollapsed = false {
        didSet { if oldValue != isCollapsed { invalidateLayout() } }
    }

    private var geometry: CarouselGeometry {
        CarouselGeometry(size: collectionView?.bounds.size ?? .zero)
    }

    override var collectionViewContentSize: CGSize {
        let geometry = geometry
        return CGSize(width: CGFloat(itemCount) * geometry.step, height: geometry.size.height)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        collectionView?.bounds != newBounds
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let geometry = geometry
        guard let collectionView, geometry.step > 0,
              let range = geometry.queryRange(midX: rect.midX, count: itemCount) else { return [] }
        let offset = collectionView.bounds.minX
        return range.map { attributes(for: $0, geometry: geometry, offset: offset) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let geometry = geometry
        guard let collectionView, geometry.step > 0, indexPath.section == 0,
              (0..<itemCount).contains(indexPath.item) else { return nil }
        return attributes(for: indexPath.item, geometry: geometry, offset: collectionView.bounds.minX)
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let geometry = geometry
        guard geometry.step > 0, itemCount > 0 else { return proposedContentOffset }
        let page = min(max(0, geometry.page(atOffset: proposedContentOffset.x).rounded()), CGFloat(itemCount - 1))
        return CGPoint(x: geometry.offset(forPage: page), y: proposedContentOffset.y)
    }

    private func attributes(for item: Int, geometry: CarouselGeometry, offset: CGFloat)
        -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
        attributes.size = CGSize(width: geometry.step, height: geometry.size.height)
        attributes.center = CGPoint(x: (CGFloat(item) + 0.5) * geometry.step, y: geometry.size.height / 2)
        let position = geometry.position(of: item, atOffset: offset)
        attributes.zIndex = itemCount / 2 - Int(abs(position).rounded())
        if let pose = CarouselGeometry.pose(at: position, collapsed: isCollapsed) {
            attributes.transform = pose.transform(width: geometry.step, height: geometry.size.height)
        } else {
            attributes.isHidden = true
        }
        return attributes
    }
}
#endif
