import SwiftUI
import Core
import Domain
import Localization

public struct PriceChangeIndicatorView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.formattingPreferences) private var formattingPreferences
    let change: Decimal

    public init(change: Decimal) {
        self.change = change
    }

    private var isPositive: Bool { change > 0 }
    private var isNegative: Bool { change < 0 }

    private var arrowSymbolName: String {
        if isPositive { return "arrow.up.right" }
        if isNegative { return "arrow.down.right" }
        return "minus"
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: arrowSymbolName)
            Text(PriceFormatting.signedChange(change, locale: formattingPreferences.locale))
        }
        .environment(\.layoutDirection, .leftToRight)
        .font(.caption.weight(.bold))
        .foregroundStyle(foreground)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(background, in: Capsule())
        .accessibilityLabel(accessibilityText)
    }

    private var foreground: Color {
        if isPositive { return theme.colors.positive }
        if isNegative { return theme.colors.negative }
        return theme.colors.neutral
    }

    private var background: Color {
        foreground.opacity(0.14)
    }

    private var accessibilityText: String {
        if isPositive {
            return L10n.priceChangeUp(PriceFormatting.signedChange(change, locale: formattingPreferences.locale))
        }
        if isNegative {
            return L10n.priceChangeDown(PriceFormatting.signedChange(abs(change), locale: formattingPreferences.locale))
        }
        return L10n.noChange
    }
}
