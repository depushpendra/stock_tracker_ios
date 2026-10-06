import SwiftUI
import Domain

public struct DetailHeroCard: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.layoutPreferences) private var layoutPreferences

    let symbol: Symbol
    let name: String
    let quote: Quote

    public init(symbol: Symbol, name: String, quote: Quote) {
        self.symbol = symbol
        self.name = name
        self.quote = quote
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerRow
            QuotePriceView(quote: quote, priceFont: theme.typography.detailTitle)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(theme.colors.surfaceCard)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(theme.colors.surfaceCardStroke, lineWidth: 1)
        }
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(theme.colors.accentGradient.opacity(0.25))
                .blur(radius: 18)
                .padding(.horizontal, 8)
        }
        .environment(\.layoutDirection, layoutPreferences.layoutDirection)
    }

    private var headerRow: some View {
        HStack(spacing: 14) {
            StockSymbolIconView(ticker: symbol.rawValue, size: 52)
            titleBlock
            Spacer(minLength: 0)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(symbol.rawValue)
                    .font(.title.weight(.bold))
                Text(quote.currencyCode.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(theme.colors.surfaceCardStroke.opacity(0.35)))
            }
            Text(name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
    }
}
