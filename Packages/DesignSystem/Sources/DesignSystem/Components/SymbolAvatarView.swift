import SwiftUI

public struct SymbolAvatarView: View {
    @Environment(\.appTheme) private var theme

    let symbol: String

    public init(symbol: String) {
        self.symbol = symbol
    }

    public var body: some View {
        Text(symbol.prefix(3))
            .font(theme.typography.heroSymbol)
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(theme.colors.accentGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            }
            .accessibilityHidden(true)
    }
}
