import SwiftUI
import UIKit

/// A zero-size UIViewRepresentable that finds and hides the native UITabBar
/// in the view hierarchy. Used on iOS < 26 where FabBar replaces the native tab bar.
struct NativeTabBarHider: UIViewRepresentable {
    let isHidden: Bool

    func makeUIView(context: Context) -> TabBarFinderView {
        let view = TabBarFinderView()
        view.tabBarIsHidden = isHidden
        return view
    }

    func updateUIView(_ uiView: TabBarFinderView, context: Context) {
        uiView.tabBarIsHidden = isHidden
    }
}

/// Walks the UIKit view hierarchy to find and hide a UITabBar.
final class TabBarFinderView: UIView {
    var tabBarIsHidden: Bool = true {
        didSet { updateTabBarVisibility() }
    }

    private weak var foundTabBar: UITabBar?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            // Defer to next runloop tick so the full hierarchy is assembled
            DispatchQueue.main.async { [weak self] in
                self?.updateTabBarVisibility()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateTabBarVisibility()
    }

    private func updateTabBarVisibility() {
        guard let tabBar = findTabBar() else { return }
        foundTabBar = tabBar
        tabBar.isHidden = tabBarIsHidden
    }

    private func findTabBar() -> UITabBar? {
        if let cached = foundTabBar, cached.window != nil {
            return cached
        }
        var current: UIView? = self
        while let view = current {
            for sibling in (view.superview?.subviews ?? []) {
                if let tabBar = sibling as? UITabBar {
                    return tabBar
                }
            }
            if let tabBarController = view.next as? UITabBarController {
                return tabBarController.tabBar
            }
            current = view.superview
        }
        return nil
    }
}
