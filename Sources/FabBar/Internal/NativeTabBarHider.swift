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
        // Use the responder chain to find a UITabBarController
        var responder: UIResponder? = self
        while let current = responder {
            if let tabBarController = current as? UITabBarController {
                return tabBarController.tabBar
            }
            responder = current.next
        }
        // Fallback: search from the window root
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
