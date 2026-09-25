import SwiftUI

// Retune these to the selected design direction once, in Stage 1. Every
// component below and every screen writer reads from here, so changing a token
// restyles the whole app — never hardcode a color, radius or spacing in a
// screen. System surfaces are used for backgrounds so contrast holds in both
// light and dark mode without a second palette.
enum AppTheme {
    // MARK: Color
    static let accent = Color.accentColor
    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let elevatedSurface = Color(uiColor: .tertiarySystemGroupedBackground)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let separator = Color(uiColor: .separator)
    static let positive = Color.green
    static let warning = Color.orange
    static let negative = Color.red
    static let contrastSurface = Color(uiColor: .label)
    static let contrastText = Color(uiColor: .systemBackground)
    static let quietBlue = Color.accentColor.opacity(0.12)

    // MARK: Metrics
    static let spacing: CGFloat = 18
    static let compactSpacing: CGFloat = 8
    static let looseSpacing: CGFloat = 26
    static let cornerRadius: CGFloat = 20
    static let compactCornerRadius: CGFloat = 12
    static let iconSize: CGFloat = 28
    static let minimumTapTarget: CGFloat = 44
    static let fineLineWidth: CGFloat = 1

    // MARK: Type
    static let largeTitle: Font = .system(.largeTitle, design: .default).weight(.bold)
    static let title: Font = .system(.title2, design: .default).weight(.bold)
    static let headline: Font = .system(.headline, design: .default).weight(.semibold)
    static let body: Font = .body
    static let callout: Font = .callout
    static let caption: Font = .caption
    static let monospacedValue: Font = .body.monospacedDigit()

    // MARK: Motion
    // Mutations animate with `spring`; numbers that change in place use
    // `.contentTransition(.numericText())` alongside it.
    static let spring: Animation = .spring(response: 0.35, dampingFraction: 0.8)
    static let quick: Animation = .easeOut(duration: 0.18)
}

extension View {
    /// Standard card treatment: padded, on `surface`, with the theme radius.
    func appCardStyle(padding: CGFloat = AppTheme.spacing) -> some View {
        self
            .padding(padding)
            .background(
                AppTheme.surface,
                in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            )
    }

    /// Full-width screen padding, matching the grouped-list inset.
    func appScreenPadding() -> some View {
        padding(.horizontal, AppTheme.spacing)
    }
}
