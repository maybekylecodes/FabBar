import SwiftUI

// MARK: - Environment Key

private struct FabBarBottomSafeAreaPaddingKey: EnvironmentKey {
    static let defaultValue: CGFloat = Constants.barHeight + Constants.bottomPadding
}

extension EnvironmentValues {
    /// The bottom safe area padding needed to clear the FabBar.
    /// This is `barHeight + bottomPadding` minus the device's bottom safe area inset.
    var fabBarBottomSafeAreaPadding: CGFloat {
        get { self[FabBarBottomSafeAreaPaddingKey.self] }
        set { self[FabBarBottomSafeAreaPaddingKey.self] = newValue }
    }
}

// MARK: - View Modifier

/// View modifier that applies bottom safe area padding to clear the FabBar.
struct FabBarSafeAreaPaddingModifier: ViewModifier {
    @Environment(\.fabBarBottomSafeAreaPadding) private var padding

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.safeAreaPadding(.bottom, padding)
        } else {
            content.padding(.bottom, padding)
        }
    }
}

public extension View {
    /// Applies bottom safe area padding to clear the FabBar.
    ///
    /// Use this on scrollable content within each tab to ensure
    /// content isn't hidden behind the FabBar.
    ///
    /// ```swift
    /// Tab(value: .home) {
    ///     HomeView()
    ///         .fabBarSafeAreaPadding()
    ///         .toolbarVisibility(.hidden, for: .tabBar)
    /// }
    /// ```
    func fabBarSafeAreaPadding() -> some View {
        modifier(FabBarSafeAreaPaddingModifier())
    }
}
