import SwiftUI

/// Configuration for an unread badge dot on a FabBar tab.
///
/// When set on a ``FabBarTab``, a small colored dot appears near the tab's icon
/// to indicate unread or new content.
///
/// ```swift
/// // Default red dot
/// FabBarTab(value: .activity, title: "Activity", systemImage: "bell.fill",
///           badge: FabBarBadge())
///
/// // Custom color
/// FabBarTab(value: .messages, title: "Messages", systemImage: "message.fill",
///           badge: FabBarBadge(color: .blue))
/// ```
public struct FabBarBadge: Equatable {
    /// The color of the badge dot.
    public let color: Color

    /// Creates a badge with the specified color.
    ///
    /// - Parameter color: The dot color. Defaults to `.red`.
    public init(color: Color = .red) {
        self.color = color
    }
}
