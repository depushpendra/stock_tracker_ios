import SwiftUI
import Core
import Domain
import Localization

public struct SymbolDetailInfoCard: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.formattingPreferences) private var formattingPreferences

    let metadata: StockSymbol
    let quote: Quote

    public init(metadata: StockSymbol, quote: Quote) {
        self.metadata = metadata
        self.quote = quote
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.marketData)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                alignment: .leading,
                spacing: 12
            ) {
                infoCell(title: L10n.currency, value: metadata.currencyCode.rawValue)
                infoCell(title: L10n.exchange, value: metadata.exchange)
                infoCell(title: L10n.sector, value: metadata.sector)
                infoCell(title: L10n.country, value: metadata.country)
                infoCell(
                    title: L10n.sessionChange,
                    value: PriceFormatting.signedChange(quote.change, locale: formattingPreferences.locale)
                )
                infoCell(
                    title: L10n.sessionChangePercent,
                    value: percentSessionChange
                )
                infoCell(
                    title: L10n.tickChange,
                    value: PriceFormatting.signedChange(quote.tickChange, locale: formattingPreferences.locale)
                )
                infoCell(title: L10n.openPrice, value: formattedPrice(metadata.seedPrice))
                infoCell(
                    title: L10n.lastUpdated,
                    value: quote.updatedAt.formatted(date: .abbreviated, time: .standard)
                )
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: theme.metrics.cardCornerRadius, style: .continuous)
                .fill(theme.colors.surfaceCard)
        }
        .overlay {
            RoundedRectangle(cornerRadius: theme.metrics.cardCornerRadius, style: .continuous)
                .strokeBorder(theme.colors.surfaceCardStroke, lineWidth: 1)
        }
    }

    private var percentSessionChange: String {
        let baseline = quote.price - quote.change
        return PriceFormatting.percentChange(
            change: quote.change,
            baseline: baseline,
            locale: formattingPreferences.locale
        )
    }

    private func formattedPrice(_ value: Decimal) -> String {
        let code = formattingPreferences.currencyCode(for: quote)
        return PriceFormatting.currency(value, currencyCode: code, locale: formattingPreferences.locale)
    }

    private func infoCell(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.colors.backgroundPrimary.opacity(0.45))
        }
    }
}
