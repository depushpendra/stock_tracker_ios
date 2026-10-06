import SwiftUI
import Core
import Domain

public struct QuotePriceView: View {
    @Environment(\.formattingPreferences) private var formattingPreferences

    let quote: Quote
    var priceFont: Font = .body.monospacedDigit()

    public init(quote: Quote, priceFont: Font = .body.monospacedDigit()) {
        self.quote = quote
        self.priceFont = priceFont
    }

    public var body: some View {
        let currencyCode = formattingPreferences.currencyCode(for: quote)
        VStack(alignment: priceColumnAlignment, spacing: 4) {
            Text(PriceFormatting.currency(quote.price, currencyCode: currencyCode, locale: formattingPreferences.locale))
                .font(priceFont)
                .contentTransition(.numericText())
                .multilineTextAlignment(priceTextAlignment)
            PriceChangeIndicatorView(change: quote.change)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityPriceLabel(currencyCode: currencyCode))
    }

    /// Price sits in the row’s trailing slot; align content to that edge in both LTR and RTL.
    private var priceColumnAlignment: HorizontalAlignment { .trailing }

    private var priceTextAlignment: TextAlignment { .trailing }

    private func accessibilityPriceLabel(currencyCode: CurrencyCode) -> String {
        let formatted = PriceFormatting.currency(
            quote.price,
            currencyCode: currencyCode,
            locale: formattingPreferences.locale
        )
        return "\(currencyCode.rawValue) \(formatted)"
    }
}
