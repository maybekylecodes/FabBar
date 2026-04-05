import UIKit

/// Blur-based fallback tab bar container for iOS 16-25.
/// Provides a visually similar appearance to GlassTabBarView using UIBlurEffect
/// instead of iOS 26's UIGlassEffect.
final class BlurTabBarView: UIView, TabBarContainerView {
    let segmentedControl: TabBarSegmentedControl
    let segmentedBlurView: UIVisualEffectView
    let fabBlurView: UIVisualEffectView
    let fabTintOverlay: UIView
    let fabButton: UIButton

    private let spacing: CGFloat = Constants.fabSpacing
    private let contentPadding: CGFloat = Constants.contentPadding

    private(set) var tabCount: Int
    private var segmentedTrailingConstraint: NSLayoutConstraint?

    init(
        segmentedControl: TabBarSegmentedControl,
        tabCount: Int,
        action: FabBarAction
    ) {
        self.segmentedControl = segmentedControl
        self.tabCount = tabCount

        // Create blur views using ultra-thin material for glass-like translucency
        segmentedBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        fabBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

        // Tint overlay gives the FAB its accent color appearance
        fabTintOverlay = UIView()
        fabTintOverlay.backgroundColor = UIColor.tintColor.withAlphaComponent(0.25)

        // Create FAB button
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: Constants.fabIconPointSize, weight: .medium)
        let buttonImage = UIImage(systemName: action.systemImage, withConfiguration: config)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .white
        button.accessibilityLabel = action.accessibilityLabel
        button.accessibilityTraits = .button
        fabButton = button

        super.init(frame: .zero)

        tintAdjustmentMode = .automatic
        fabBlurView.tintAdjustmentMode = .automatic
        fabButton.tintAdjustmentMode = .automatic

        setupViews(action: action)
    }

    private func setupViews(action: FabBarAction) {
        // Segmented control blur container
        addSubview(segmentedBlurView)
        segmentedBlurView.translatesAutoresizingMaskIntoConstraints = false
        segmentedBlurView.clipsToBounds = true

        segmentedBlurView.contentView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        // FAB blur container
        addSubview(fabBlurView)
        fabBlurView.translatesAutoresizingMaskIntoConstraints = false
        fabBlurView.clipsToBounds = true

        fabBlurView.contentView.addSubview(fabTintOverlay)
        fabTintOverlay.translatesAutoresizingMaskIntoConstraints = false

        fabBlurView.contentView.addSubview(fabButton)
        fabButton.translatesAutoresizingMaskIntoConstraints = false

        fabButton.addAction(UIAction { _ in action.action() }, for: .touchUpInside)

        let segmentedControlBottomInsetAdjustment: CGFloat = 1

        NSLayoutConstraint.activate([
            // Segmented blur view
            segmentedBlurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedBlurView.topAnchor.constraint(equalTo: topAnchor),
            segmentedBlurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Segmented control inside blur view
            segmentedControl.leadingAnchor.constraint(equalTo: segmentedBlurView.contentView.leadingAnchor, constant: contentPadding),
            segmentedControl.trailingAnchor.constraint(equalTo: segmentedBlurView.contentView.trailingAnchor, constant: -contentPadding),
            segmentedControl.topAnchor.constraint(equalTo: segmentedBlurView.contentView.topAnchor, constant: contentPadding),
            segmentedControl.bottomAnchor.constraint(equalTo: segmentedBlurView.contentView.bottomAnchor, constant: -contentPadding - segmentedControlBottomInsetAdjustment),

            // FAB blur view
            fabBlurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            fabBlurView.topAnchor.constraint(equalTo: topAnchor),
            fabBlurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            fabBlurView.widthAnchor.constraint(equalTo: fabBlurView.heightAnchor),

            // Tint overlay fills the FAB area
            fabTintOverlay.leadingAnchor.constraint(equalTo: fabBlurView.contentView.leadingAnchor),
            fabTintOverlay.trailingAnchor.constraint(equalTo: fabBlurView.contentView.trailingAnchor),
            fabTintOverlay.topAnchor.constraint(equalTo: fabBlurView.contentView.topAnchor),
            fabTintOverlay.bottomAnchor.constraint(equalTo: fabBlurView.contentView.bottomAnchor),

            // FAB button fills the blur area
            fabButton.leadingAnchor.constraint(equalTo: fabBlurView.contentView.leadingAnchor),
            fabButton.trailingAnchor.constraint(equalTo: fabBlurView.contentView.trailingAnchor),
            fabButton.topAnchor.constraint(equalTo: fabBlurView.contentView.topAnchor),
            fabButton.bottomAnchor.constraint(equalTo: fabBlurView.contentView.bottomAnchor),
        ])

        segmentedTrailingConstraint = makeSegmentedTrailingConstraint()
        segmentedTrailingConstraint?.isActive = true
    }

    private func makeSegmentedTrailingConstraint() -> NSLayoutConstraint {
        if tabCount >= 3 {
            segmentedBlurView.trailingAnchor.constraint(equalTo: fabBlurView.leadingAnchor, constant: -spacing)
        } else {
            segmentedBlurView.trailingAnchor.constraint(lessThanOrEqualTo: fabBlurView.leadingAnchor, constant: -spacing)
        }
    }

    func updateTabCount(_ newCount: Int) {
        guard newCount != tabCount else { return }
        tabCount = newCount
        segmentedTrailingConstraint?.isActive = false
        segmentedTrailingConstraint = makeSegmentedTrailingConstraint()
        segmentedTrailingConstraint?.isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Capsule shape for segmented control
        segmentedBlurView.layer.cornerRadius = segmentedBlurView.bounds.height / 2
        // Circle shape for FAB (equal width/height)
        fabBlurView.layer.cornerRadius = fabBlurView.bounds.height / 2
        fabTintOverlay.layer.cornerRadius = fabBlurView.bounds.height / 2
        fabTintOverlay.clipsToBounds = true
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        fabTintOverlay.backgroundColor = tintColor?.withAlphaComponent(0.25)
    }
}
