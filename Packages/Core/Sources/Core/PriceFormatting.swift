import Foundation
import Domain

public enum PriceFormatting {
    public static func currency(
        _ value: Decimal,
        currencyCode: CurrencyCode,
        locale: Locale = .current
    ) -> String {
        value.formatted(
            .currency(code: currencyCode.rawValue)
                .locale(locale)
        )
    }

    public static func percentChange(change: Decimal, baseline: Decimal, locale: Locale = .current) -> String {
        guard baseline != 0 else { return "0%" }
        let ratio = (change as NSDecimalNumber).doubleValue / (baseline as NSDecimalNumber).doubleValue
        let formatted = abs(ratio * 100).formatted(.number.precision(.fractionLength(2)).locale(locale))
        if change > 0 { return "+\(formatted)%" }
        if change < 0 { return "-\(formatted)%" }
        return "\(formatted)%"
    }

    public static func signedChange(_ value: Decimal, locale: Locale = .current) -> String {
        let formatted = abs(value).formatted(.number.precision(.fractionLength(2)).locale(locale))
        if value > 0 { return "+\(formatted)" }
        if value < 0 { return "-\(formatted)" }
        return formatted
    }
}
