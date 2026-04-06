import SwiftUI

/// View modifier that positions a FabBar at the bottom of the view.
///
/// This modifier handles all the layout details:
/// - Wraps in `.safeAreaBar(edge: .bottom)` on iOS 26+, `.overlay` on older versions
/// - Applies appropriate padding
/// - Ignores bottom safe area for manual positioning
/// - Hides automatically on regular horizontal size class (iPad)
/// - Injects calculated safe area padding into the environment
struct FabBarModifier<Value: Hashable>: ViewModifier {
    @Binding var selection: Value
    let tabs: [FabBarTab<Value>]
    let action: FabBarAction
    let isVisible: Bool

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var bottomSafeAreaInset: CGFloat = 0

    /// Whether the FabBar should be displayed.
    /// Only shows on compact horizontal size class (iPhone) when visible.
    private var showsFabBar: Bool {
        horizontalSizeClass == .compact && isVisible
    }

    /// Total content margin needed to clear the FabBar.
    private var bottomContentMargin: CGFloat {
        Constants.barHeight + Constants.bottomPadding
    }

    /// The padding to inject into the environment.
    /// This is the total content margin minus the device's safe area inset,
    /// because `safeAreaPadding` adds to the existing safe area.
    /// Returns 0 when the FabBar is not showing.
    private var calculatedPadding: CGFloat {
        showsFabBar ? bottomContentMargin - bottomSafeAreaInset : 0
    }

    @ViewBuilder
    private var fabBarContent: some View {
        if showsFabBar {
            FabBar(selection: $selection, tabs: tabs, action: action)
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.bottom, Constants.bottomPadding)
        }
    }

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .safeAreaBar(edge: .bottom) {
                    fabBarContent
                }
                .ignoresSafeArea(.all, edges: showsFabBar ? [.bottom] : [])
                .modifier(BottomSafeAreaReader(bottomSafeAreaInset: $bottomSafeAreaInset))
                .environment(\.fabBarBottomSafeAreaPadding, calculatedPadding)
        } else {
            content
                .overlay(alignment: .bottom) {
                    fabBarContent
                }
                .background {
                    NativeTabBarHider(isHidden: showsFabBar)
                        .frame(width: 0, height: 0)
                        .allowsHitTesting(false)
                        .accessibility(hidden: true)
                }
                .ignoresSafeArea(.all, edges: showsFabBar ? [.bottom] : [])
                .modifier(BottomSafeAreaReader(bottomSafeAreaInset: $bottomSafeAreaInset))
                .environment(\.fabBarBottomSafeAreaPadding, calculatedPadding)
        }
    }
}

// MARK: - Bottom Safe Area Reader

/// Reads the bottom safe area inset using the best available API for the iOS version.
private struct BottomSafeAreaReader: ViewModifier {
    @Binding var bottomSafeAreaInset: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.onGeometryChange(for: CGFloat.self) { proxy in
                proxy.safeAreaInsets.bottom
            } action: { newValue in
                bottomSafeAreaInset = newValue
            }
        } else {
            content.background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: BottomSafeAreaKey.self,
                        value: proxy.safeAreaInsets.bottom
                    )
                }
            )
            .onPreferenceChange(BottomSafeAreaKey.self) { newValue in
                bottomSafeAreaInset = newValue
            }
        }
    }
}

private struct BottomSafeAreaKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Public API

public extension View {
    /// Adds a FabBar to the bottom of the view.
    ///
    /// This is the recommended way to use FabBar. It handles positioning,
    /// safe area management, and automatically hides on iPad.
    ///
    /// ```swift
    /// TabView(selection: $selectedTab) {
    ///     Tab(value: .home) {
    ///         HomeView()
    ///             .fabBarSafeAreaPadding()
    ///             .toolbarVisibility(.hidden, for: .tabBar)
    ///     }
    ///     // more tabs...
    /// }
    /// .fabBar(selection: $selectedTab, tabs: tabs, action: action)
    /// ```
    ///
    /// - Parameters:
    ///   - selection: A binding to the currently selected tab.
    ///   - tabs: The tabs to display.
    ///   - action: The floating action button configuration.
    ///   - isVisible: Whether the FabBar is visible. Defaults to `true`.
    func fabBar<Value: Hashable>(
        selection: Binding<Value>,
        tabs: [FabBarTab<Value>],
        action: FabBarAction,
        isVisible: Bool = true
    ) -> some View {
        modifier(FabBarModifier(selection: selection, tabs: tabs, action: action, isVisible: isVisible))
    }
}
