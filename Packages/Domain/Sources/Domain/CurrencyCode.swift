import Foundation

public enum CurrencyCode: String, Sendable, Codable, CaseIterable, Hashable {
    case usd = "USD"
    case aed = "AED"
    case inr = "INR"

    public static func parse(_ raw: String) -> CurrencyCode? {
        CurrencyCode(rawValue: raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased())
    }
}
