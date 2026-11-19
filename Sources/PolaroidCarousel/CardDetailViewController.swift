#if canImport(UIKit)
import UIKit

final class CardDetailViewController: UIViewController {
    struct Source {
        let snapshot: UIView
        let size: CGSize
        let origin: CardHandoffGeometry

        @MainActor init?(card: UIView, in window: UIWindow) {
            guard let origin = Self.geometry(of: card, in: window),
                  let snapshot = card.snapshotView(afterScreenUpdates: false) else { return nil }
            self.size = card.bounds.size
            self.origin = origin
            self.snapshot = snapshot
            snapshot.transform = .identity
            snapshot.bounds = CGRect(origin: .zero, size: size)
        }

        @MainActor static func geometry(of card: UIView, in window: UIWindow) -> CardHandoffGeometry? {
            let presentation = card.layer.presentation()
            let windowPresentation = window.layer.presentation()
            let bounds = presentation?.bounds ?? card.bounds
            guard bounds.width > 0, bounds.height > 0 else { return nil }
            func project(_ point: CGPoint) -> CGPoint {
                if let presentation, let windowPresentation, presentation.superlayer != nil {
                    return presentation.convert(point, to: windowPresentation)
                }
                return card.convert(point, to: window)
            }
            return CardHandoffGeometry(
                center: project(CGPoint(x: bounds.midX, y: bounds.midY)),
                right: project(CGPoint(x: bounds.maxX, y: bounds.midY)),
                bottom: project(CGPoint(x: bounds.midX, y: bounds.maxY))
            )
        }
    }

    private enum Phase { case waiting, opening, open, closing }
    private static let flipDuration = 0.7
    private static let dampingRatio: CGFloat = 0.8
    private static let perspective: CGFloat = -1 / 300
    // Avoid an ambiguous rotation direction at exactly 180°.
    private static let halfTurn: CGFloat = .pi - 0.01
    private static let maximumCardHeight: CGFloat = 370
    private static let fadeDuration = 0.2
    private static let landingDuration = 0.10
    private var phase = Phase.waiting
    private let backdrop = UIControl()
    private let card = UIView()
    private let faces = UIView()
    private let closeButton = UIButton(type: .system)
    private let front = UIView()
    private let back: UIView
    private let source: Source?
    private let returnOrigin: () -> CardHandoffGeometry?
    private let setSourceHidden: (Bool) -> Void

    init(back: any UIContentConfiguration, source: Source?,
         returnOrigin: @escaping () -> CardHandoffGeometry?, setSourceHidden: @escaping (Bool) -> Void) {
        self.back = back.makeContentView()
        self.source = source
        self.returnOrigin = returnOrigin
        self.setSourceHidden = setSourceHidden
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init(back:source:returnOrigin:setSourceHidden:)") }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.accessibilityViewIsModal = true
        view.accessibilityElementsHidden = true

        backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.92)
        backdrop.alpha = 0
        backdrop.isAccessibilityElement = false
        backdrop.addTarget(self, action: #selector(close), for: .touchUpInside)
        pin(backdrop, in: view)

        view.addSubview(card)
        pin(faces, in: card)
        pin(front, in: faces)
        pin(back, in: faces)
        if let source { front.addSubview(source.snapshot) }
        front.layer.isDoubleSided = false
        back.layer.isDoubleSided = false
        showBack(false)
        front.isUserInteractionEnabled = false
        card.isUserInteractionEnabled = false
        card.isHidden = true

        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(white: 0.20, alpha: 1)
        config.cornerStyle = .capsule
        closeButton.configuration = config
        closeButton.accessibilityLabel = String(localized: "Close card", bundle: .module)
        closeButton.alpha = 0
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if phase == .open { placeExpandedCard() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard phase == .waiting else { return }
        open()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || presentingViewController == nil { setSourceHidden(false) }
    }

    override func accessibilityPerformEscape() -> Bool {
        guard phase == .open else { return false }
        close()
        return true
    }

    private func pin(_ child: UIView, in parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
        ])
    }

    private func placeExpandedCard() {
        let room = view.safeAreaLayoutGuide.layoutFrame.inset(by: UIEdgeInsets(top: 60, left: 18, bottom: 18, right: 18))
        let height = max(1, min(Self.maximumCardHeight, room.height, room.width * 8 / 5))
        card.transform = .identity
        let size = CGSize(width: height * 5 / 8, height: height)
        card.bounds.size = size
        card.center = CGPoint(x: room.midX, y: room.midY)
        if let source {
            // Scale captured pixels, never re-layout the front at the detail size.
            source.snapshot.center = CGPoint(x: size.width / 2, y: size.height / 2)
            source.snapshot.transform = CGAffineTransform(scaleX: size.width / source.size.width,
                                                           y: size.height / source.size.height)
        }
    }

    private func placeCard(at origin: CardHandoffGeometry) {
        let local = origin.converted { view.convert($0, from: view.window) }
        card.center = local.center
        card.transform = local.transform(from: card.bounds.size)
    }

    private func showBack(_ isShowingBack: Bool) {
        // Rotate the faces independently of the lift; the back stays interactive when open.
        var perspective = CATransform3DIdentity
        perspective.m34 = Self.perspective
        front.transform3D = isShowingBack
            ? CATransform3DRotate(perspective, Self.halfTurn, 0, 1, 0) : CATransform3DIdentity
        back.transform3D = isShowingBack
            ? CATransform3DIdentity : CATransform3DRotate(perspective, -Self.halfTurn, 0, 1, 0)
    }

    private func open() {
        phase = .opening
        view.layoutIfNeeded()
        placeExpandedCard()
        let expandedCenter = card.center
        let origin = UIAccessibility.isReduceMotionEnabled ? nil : source?.origin
        if let origin {
            placeCard(at: origin)
        } else {
            showBack(true)
            card.alpha = 0
        }
        card.isHidden = false
        card.layoutIfNeeded()
        setSourceHidden(true)

        let move = {
            self.backdrop.alpha = 1
            self.card.alpha = 1
            self.card.center = expandedCenter
            self.card.transform = .identity
            self.closeButton.alpha = 1
        }
        let finish: () -> Void = {
            self.phase = .open
            self.showBack(true)
            self.front.isHidden = true
            self.placeExpandedCard()
            self.card.isUserInteractionEnabled = true
            self.view.accessibilityElementsHidden = false
            UIAccessibility.post(notification: .screenChanged, argument: nil)
        }
        if origin != nil {
            let animator = UIViewPropertyAnimator(duration: Self.flipDuration, dampingRatio: Self.dampingRatio,
                                                  animations: move)
            // Let the full-size front lift away from the deck before the turn becomes edge-on.
            animator.addAnimations({ self.showBack(true) }, delayFactor: 0.16)
            animator.addCompletion { _ in finish() }
            animator.startAnimation()
        } else {
            UIView.animate(withDuration: Self.fadeDuration, animations: move) { _ in finish() }
        }
    }

    @objc private func close() {
        guard phase == .open else { return }
        phase = .closing
        card.isUserInteractionEnabled = false
        view.accessibilityElementsHidden = true
        let origin = UIAccessibility.isReduceMotionEnabled || source == nil ? nil : returnOrigin()
        let move = {
            self.backdrop.alpha = 0
            self.closeButton.alpha = 0
            if let origin { self.placeCard(at: origin) } else { self.card.alpha = 0 }
        }
        let finish: () -> Void = {
            self.dismiss(animated: false) {
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        }
        if origin != nil {
            front.isHidden = false
            let animator = UIViewPropertyAnimator(duration: Self.flipDuration, dampingRatio: Self.dampingRatio) {
                self.showBack(false)
                move()
            }
            animator.addCompletion { _ in
                // The pixels already align. Dissolve the overlay into the real stacking order
                // so a neighboring card that overlaps the source doesn't pop in on dismissal.
                self.setSourceHidden(false)
                UIView.animate(withDuration: Self.landingDuration) {
                    self.card.alpha = 0
                } completion: { _ in finish() }
            }
            animator.startAnimation()
        } else {
            setSourceHidden(false)
            UIView.animate(withDuration: Self.fadeDuration, animations: move) { _ in finish() }
        }
    }
}
#endif
