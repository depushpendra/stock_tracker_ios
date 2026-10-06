import SwiftUI
import Domain

public struct StockRowCard: View {
    @Environment(\.appTheme) private var theme

    let quote: Quote

    public init(quote: Quote) {
        self.quote = quote
    }

    public var body: some View {
        StockListRowLayout {
            StockSymbolIconView(ticker: quote.symbol.rawValue)
        } title: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(quote.symbol.rawValue)
                        .font(theme.typography.listTitle)
                        .foregroundStyle(.primary)
                    Text(quote.currencyCode.rawValue)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(theme.colors.surfaceCardStroke.opacity(0.35)))
                }
                Text(quote.name)
                    .font(theme.typography.listSubtitle)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
        } price: {
            QuotePriceView(quote: quote)
        }
        .padding(theme.metrics.cardPadding)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: theme.metrics.cardCornerRadius, style: .continuous)
                .fill(theme.colors.surfaceCard)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: theme.metrics.cardCornerRadius, style: .continuous)
                .strokeBorder(theme.colors.surfaceCardStroke, lineWidth: 1)
        }
    }
}
