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
/// Uses KVO to observe the tab bar's `isHidden` property and immediately
/// re-hide it whenever SwiftUI resets it during tab transitions.
final class TabBarFinderView: UIView {
    var tabBarIsHidden: Bool = true {
        didSet { applyVisibility() }
    }

    private weak var foundTabBar: UITabBar?
    private var observation: NSKeyValueObservation?

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
            DispatchQueue.main.async { [weak self] in
                self?.findAndObserveTabBar()
            }
        } else {
            observation = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        findAndObserveTabBar()
    }

    private func findAndObserveTabBar() {
        guard let tabBar = findTabBar() else { return }
        if tabBar !== foundTabBar {
            foundTabBar = tabBar
            // Observe isHidden so we can re-hide when SwiftUI resets it during tab switches
            observation = tabBar.observe(\.isHidden, options: [.new]) { [weak self] bar, _ in
                guard let self, self.tabBarIsHidden, !bar.isHidden else { return }
                bar.isHidden = true
            }
        }
        applyVisibility()
    }

    private func applyVisibility() {
        foundTabBar?.isHidden = tabBarIsHidden
    }

    private func findTabBar() -> UITabBar? {
        if let cached = foundTabBar, cached.window != nil {
            return cached
        }
        var responder: UIResponder? = self
        while let current = responder {
            if let tabBarController = current as? UITabBarController {
                return tabBarController.tabBar
            }
            responder = current.next
        }
        if let window {
            return findTabBar(in: window)
        }
        return nil
    }

    private func findTabBar(in view: UIView) -> UITabBar? {
        if let tabBar = view as? UITabBar {
            return tabBar
        }
        for subview in view.subviews {
            if let tabBar = findTabBar(in: subview) {
                return tabBar
            }
        }
        return nil
    }
}
