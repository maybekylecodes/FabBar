import UIKit

/// Factory that creates the appropriate tab bar container based on iOS version.
/// Returns GlassTabBarView on iOS 26+ and BlurTabBarView on iOS 16-25.
@MainActor
enum TabBarContainerFactory {
    static func makeContainer(
        segmentedControl: TabBarSegmentedControl,
        tabCount: Int,
        action: FabBarAction
    ) -> UIView {
        if #available(iOS 26.0, *) {
            return GlassTabBarView(
                segmentedControl: segmentedControl,
                tabCount: tabCount,
                action: action
            )
        } else {
            return BlurTabBarView(
                segmentedControl: segmentedControl,
                tabCount: tabCount,
                action: action
            )
        }
    }
}
