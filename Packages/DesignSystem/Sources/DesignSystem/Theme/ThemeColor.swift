import SwiftUI

/// Semantic color names in `Resources/ThemeColors.xcassets` (light/dark variants).
public enum ThemeColorName: String, Sendable {
    case positive = "Positive"
    case negative = "Negative"
    case neutral = "Neutral"
    case connectionConnected = "ConnectionConnected"
    case connectionConnecting = "ConnectionConnecting"
    case connectionDisconnected = "ConnectionDisconnected"
    case connectionFailed = "ConnectionFailed"
    case accentPrimary = "AccentPrimary"
    case backgroundPrimary = "BackgroundPrimary"
    case backgroundSecondary = "BackgroundSecondary"
    case surfaceCard = "SurfaceCard"
    case surfaceCardStroke = "SurfaceCardStroke"
    case gradientStart = "GradientStart"
    case gradientEnd = "GradientEnd"
}

public enum ThemeColor {
    private static var bundle: Bundle { Bundle.module }

    public static func color(_ name: ThemeColorName) -> Color {
        Color(name.rawValue, bundle: bundle)
    }

    public static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [color(.gradientStart), color(.gradientEnd)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
