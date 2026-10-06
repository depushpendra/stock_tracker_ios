import SwiftUI

public struct AppTheme {
    public struct Colors {
        public var positive: Color
        public var negative: Color
        public var neutral: Color
        public var connectionConnected: Color
        public var connectionConnecting: Color
        public var connectionDisconnected: Color
        public var connectionFailed: Color
        public var accentPrimary: Color
        public var backgroundPrimary: Color
        public var backgroundSecondary: Color
        public var surfaceCard: Color
        public var surfaceCardStroke: Color
        public var gradientStart: Color
        public var gradientEnd: Color

        public var accentGradient: LinearGradient {
            LinearGradient(
                colors: [gradientStart, gradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        nonisolated(unsafe) public static let standard = Colors(
            positive: ThemeColor.color(.positive),
            negative: ThemeColor.color(.negative),
            neutral: ThemeColor.color(.neutral),
            connectionConnected: ThemeColor.color(.connectionConnected),
            connectionConnecting: ThemeColor.color(.connectionConnecting),
            connectionDisconnected: ThemeColor.color(.connectionDisconnected),
            connectionFailed: ThemeColor.color(.connectionFailed),
            accentPrimary: ThemeColor.color(.accentPrimary),
            backgroundPrimary: ThemeColor.color(.backgroundPrimary),
            backgroundSecondary: ThemeColor.color(.backgroundSecondary),
            surfaceCard: ThemeColor.color(.surfaceCard),
            surfaceCardStroke: ThemeColor.color(.surfaceCardStroke),
            gradientStart: ThemeColor.color(.gradientStart),
            gradientEnd: ThemeColor.color(.gradientEnd)
        )
    }

    public struct Typography: Sendable {
        public var listTitle: Font
        public var listSubtitle: Font
        public var price: Font
        public var detailTitle: Font
        public var caption: Font
        public var heroSymbol: Font

        public static let standard = Typography(
            listTitle: .headline.weight(.semibold),
            listSubtitle: .subheadline,
            price: .body.weight(.semibold).monospacedDigit(),
            detailTitle: .system(size: 36, weight: .bold, design: .rounded).monospacedDigit(),
            caption: .caption.weight(.semibold),
            heroSymbol: .title2.weight(.bold)
        )
    }

    public struct Metrics: Sendable {
        public var rowVerticalPadding: CGFloat
        public var statusPillHorizontal: CGFloat
        public var statusPillVertical: CGFloat
        public var cardCornerRadius: CGFloat
        public var cardPadding: CGFloat
        public var listHorizontalInset: CGFloat

        public static let standard = Metrics(
            rowVerticalPadding: 8,
            statusPillHorizontal: 12,
            statusPillVertical: 7,
            cardCornerRadius: 16,
            cardPadding: 14,
            listHorizontalInset: 16
        )
    }

    public var colors: Colors
    public var typography: Typography
    public var metrics: Metrics

    nonisolated(unsafe) public static let standard = AppTheme(
        colors: .standard,
        typography: .standard,
        metrics: .standard
    )

    public init(colors: Colors, typography: Typography, metrics: Metrics) {
        self.colors = colors
        self.typography = typography
        self.metrics = metrics
    }
}

private struct AppThemeKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = AppTheme.standard
}

public extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

public extension View {
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}
