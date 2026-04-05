import UIKit

/// Protocol that both the glass (iOS 26+) and blur (iOS 16-25) tab bar containers implement.
protocol TabBarContainerView: UIView {
    var segmentedControl: TabBarSegmentedControl { get }
    func updateTabCount(_ newCount: Int)
}
